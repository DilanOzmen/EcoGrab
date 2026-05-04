using FoodWaste.Business.Abstractions;
using FoodWaste.Business.Models.Customer;
using FoodWaste.Data;
using FoodWaste.Entities;
using Microsoft.EntityFrameworkCore;

namespace FoodWaste.Business.Services;

public class CustomerService(FoodWasteDbContext dbContext, INotificationService notificationService) : ICustomerService
{
    public async Task<IReadOnlyList<NearbyRestaurantDto>> GetRestaurantsAsync(string? city, string? search, string? homeCategory, CancellationToken cancellationToken = default)
    {
        var now = DateTime.UtcNow;
        var query = dbContext.Restaurants
            .AsNoTracking()
            .Where(x => !x.IsDeleted)
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(city))
        {
            var cityValue = city.Trim();
            query = query.Where(x => x.City == cityValue);
        }

        if (!string.IsNullOrWhiteSpace(search))
        {
            var searchValue = search.Trim();
            query = query.Where(x => x.Name.Contains(searchValue) || x.Address.Contains(searchValue));
        }

        var homeCategoryProductCategories = GetHomeCategoryProductCategories(homeCategory);
        if (homeCategoryProductCategories.Count > 0)
        {
            query = query.Where(x => x.Products.Any(p => !p.IsDeleted
                && p.IsActive
                && p.Stock > 0
                && p.ExpiryDate > now
                && p.DiscountedPrice < p.OriginalPrice
                && homeCategoryProductCategories.Contains(p.Category)));
        }

        return await query
            .OrderBy(x => x.Name)
            .Select(x => new NearbyRestaurantDto(
                x.Id,
                x.Name,
                x.Address,
                x.City,
                x.Latitude,
                x.Longitude,
                0))
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<CustomerProductDto>> GetProductsAsync(CustomerProductFilterModel filter, CancellationToken cancellationToken = default)
    {
        var now = DateTime.UtcNow;

        var query = dbContext.Products
            .AsNoTracking()
            .Where(x => !x.IsDeleted && x.IsActive && x.Stock > 0 && x.ExpiryDate > now
                        && x.DiscountedPrice < x.OriginalPrice
                        && x.Restaurant != null && !x.Restaurant.IsDeleted)
            .Include(x => x.Restaurant)
            .Include(x => x.Images)
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(filter.Search))
        {
            var search = filter.Search.Trim();
            query = query.Where(x => x.Name.Contains(search) || x.Description.Contains(search));
        }

        if (!string.IsNullOrWhiteSpace(filter.Category))
        {
            var category = filter.Category.Trim();
            query = query.Where(x => x.Category == category);
        }

        var homeCategoryProductCategories = GetHomeCategoryProductCategories(filter.HomeCategory);
        if (homeCategoryProductCategories.Count > 0)
        {
            query = query.Where(x => homeCategoryProductCategories.Contains(x.Category));
        }

        if (filter.MinPrice.HasValue)
        {
            query = query.Where(x => x.DiscountedPrice >= filter.MinPrice.Value);
        }

        if (filter.MaxPrice.HasValue)
        {
            query = query.Where(x => x.DiscountedPrice <= filter.MaxPrice.Value);
        }

        var raw = await query
            .OrderBy(x => x.ExpiryDate)
            .ToListAsync(cancellationToken);

        var locationByProductId = raw.ToDictionary(
            x => x.Id,
            x => new
            {
                Latitude = x.Restaurant?.Latitude ?? 0,
                Longitude = x.Restaurant?.Longitude ?? 0
            });

        var projected = raw
            .Select(x =>
            {
                var discountPercent = x.OriginalPrice <= 0
                    ? 0
                    : Math.Round((x.OriginalPrice - x.DiscountedPrice) * 100 / x.OriginalPrice, 2);

                return new CustomerProductDto(
                    x.Id,
                    x.RestaurantId,
                    x.Restaurant?.Name ?? "Unknown Restaurant",
                    x.Category,
                    x.Name,
                    x.Description,
                    x.OriginalPrice,
                    x.DiscountedPrice,
                    discountPercent,
                    x.Stock,
                    x.ExpiryDate,
                    x.Images
                        .Where(i => !i.IsDeleted)
                        .OrderByDescending(i => i.IsPrimary)
                        .ThenBy(i => i.Id)
                        .Select(i => i.ImageUrl)
                        .FirstOrDefault());
            });

        if (filter.MinDiscountPercent.HasValue)
        {
            projected = projected.Where(x => x.DiscountPercent >= filter.MinDiscountPercent.Value);
        }

        if (filter.Latitude.HasValue && filter.Longitude.HasValue)
        {
            var radiusKm = filter.RadiusKm.GetValueOrDefault(5);
            projected = projected.Where(x =>
                CalculateDistanceKm(filter.Latitude.Value, filter.Longitude.Value,
                    locationByProductId[x.Id].Latitude,
                    locationByProductId[x.Id].Longitude) <= radiusKm);
        }

        return projected.ToList();
    }

    public async Task<IReadOnlyList<CustomerProductDto>> GetProductsByRestaurantAsync(int restaurantId, CancellationToken cancellationToken = default)
    {
        var now = DateTime.UtcNow;

        return await dbContext.Products
            .AsNoTracking()
            .Where(x => !x.IsDeleted
                        && x.RestaurantId == restaurantId
                        && x.IsActive
                        && x.Stock > 0
                        && x.ExpiryDate > now
                        && x.DiscountedPrice < x.OriginalPrice
                        && x.Restaurant != null
                        && !x.Restaurant.IsDeleted)
            .OrderBy(x => x.ExpiryDate)
            .Select(x => new CustomerProductDto(
                x.Id,
                x.RestaurantId,
                x.Restaurant != null ? x.Restaurant.Name : "Unknown Restaurant",
                x.Category,
                x.Name,
                x.Description,
                x.OriginalPrice,
                x.DiscountedPrice,
                x.OriginalPrice <= 0 ? 0 : Math.Round((x.OriginalPrice - x.DiscountedPrice) * 100 / x.OriginalPrice, 2),
                x.Stock,
                x.ExpiryDate,
                x.Images
                    .Where(i => !i.IsDeleted)
                    .OrderByDescending(i => i.IsPrimary)
                    .ThenBy(i => i.Id)
                    .Select(i => i.ImageUrl)
                    .FirstOrDefault()))
            .ToListAsync(cancellationToken);
    }

    public async Task<CustomerProductDto?> GetProductDetailAsync(int productId, CancellationToken cancellationToken = default)
    {
        var now = DateTime.UtcNow;

        var product = await dbContext.Products
            .AsNoTracking()
            .Include(x => x.Restaurant)
            .Where(x => x.Id == productId
                        && !x.IsDeleted
                        && x.IsActive
                        && x.Stock > 0
                        && x.ExpiryDate > now
                        && x.DiscountedPrice < x.OriginalPrice
                        && x.Restaurant != null
                        && !x.Restaurant.IsDeleted)
            .Select(x => new CustomerProductDto(
                x.Id,
                x.RestaurantId,
                x.Restaurant != null ? x.Restaurant.Name : "Unknown Restaurant",
                x.Category,
                x.Name,
                x.Description,
                x.OriginalPrice,
                x.DiscountedPrice,
                x.OriginalPrice <= 0 ? 0 : Math.Round((x.OriginalPrice - x.DiscountedPrice) * 100 / x.OriginalPrice, 2),
                x.Stock,
                x.ExpiryDate,
                x.Images
                    .Where(i => !i.IsDeleted)
                    .OrderByDescending(i => i.IsPrimary)
                    .ThenBy(i => i.Id)
                    .Select(i => i.ImageUrl)
                    .FirstOrDefault()))
            .FirstOrDefaultAsync(cancellationToken);

        return product;
    }

    public async Task<RestaurantDetailDto?> GetRestaurantDetailAsync(int restaurantId, CancellationToken cancellationToken = default)
    {
        return await dbContext.Restaurants
            .AsNoTracking()
            .Where(x => x.Id == restaurantId && !x.IsDeleted)
            .Select(x => new RestaurantDetailDto(
                x.Id,
                x.Name,
                x.Address,
                x.City,
                x.Phone,
                x.Latitude,
                x.Longitude))
            .FirstOrDefaultAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<NearbyRestaurantDto>> GetNearbyRestaurantsAsync(double latitude, double longitude, double radiusKm, CancellationToken cancellationToken = default)
    {
        var restaurants = await dbContext.Restaurants
            .AsNoTracking()
            .Where(x => !x.IsDeleted)
            .Select(x => new NearbyRestaurantDto(
                x.Id,
                x.Name,
                x.Address,
                x.City,
                x.Latitude,
                x.Longitude,
                0))
            .ToListAsync(cancellationToken);

        return restaurants
            .Select(x => x with { DistanceKm = CalculateDistanceKm(latitude, longitude, x.Latitude, x.Longitude) })
            .Where(x => x.DistanceKm <= radiusKm)
            .OrderBy(x => x.DistanceKm)
            .ToList();
    }

    public async Task<CustomerOrderDto?> ReserveAsync(int userId, int productId, int quantity, CancellationToken cancellationToken = default)
    {
        if (quantity <= 0)
        {
            return null;
        }

        await using var transaction = await dbContext.Database.BeginTransactionAsync(cancellationToken);

        var product = await dbContext.Products
            .Include(x => x.Restaurant)
            .FirstOrDefaultAsync(x => x.Id == productId && !x.IsDeleted && x.Restaurant != null && !x.Restaurant.IsDeleted, cancellationToken);

        if (product is null || !product.IsActive || product.ExpiryDate <= DateTime.UtcNow || product.Stock < quantity)
        {
            return null;
        }

        product.Stock -= quantity;
        if (product.Stock <= 0)
        {
            product.IsActive = false;
        }

        var order = new Order
        {
            UserId = userId,
            Status = OrderStatus.Pending,
            ReservedUntil = DateTime.UtcNow.AddMinutes(15),
            TotalAmount = product.DiscountedPrice * quantity,
            Items =
            [
                new OrderItem
                {
                    ProductId = product.Id,
                    Quantity = quantity,
                    UnitPrice = product.DiscountedPrice
                }
            ]
        };

        dbContext.Orders.Add(order);
        await dbContext.SaveChangesAsync(cancellationToken);
        await transaction.CommitAsync(cancellationToken);

        await CreateReservationNotificationsAsync(userId, product.Restaurant?.OwnerUserId, order.Id, cancellationToken);

        return new CustomerOrderDto(
            order.Id,
            order.CreatedAt,
            order.Status.ToString(),
            order.TotalAmount,
            [new CustomerOrderItemDto(product.Id, product.Name, quantity, product.DiscountedPrice)]);
    }

    public async Task<CustomerOrderDto?> CreateOrderAsync(int userId, int productId, int quantity, CancellationToken cancellationToken = default)
    {
        if (quantity <= 0)
        {
            return null;
        }

        await using var transaction = await dbContext.Database.BeginTransactionAsync(cancellationToken);

        var product = await dbContext.Products
            .Include(x => x.Restaurant)
            .FirstOrDefaultAsync(x => x.Id == productId && !x.IsDeleted && x.Restaurant != null && !x.Restaurant.IsDeleted, cancellationToken);

        if (product is null || !product.IsActive || product.ExpiryDate <= DateTime.UtcNow || product.Stock < quantity)
        {
            return null;
        }

        product.Stock -= quantity;
        if (product.Stock <= 0)
        {
            product.IsActive = false;
        }

        var order = new Order
        {
            UserId = userId,
            Status = OrderStatus.Confirmed,
            ConfirmedAt = DateTime.UtcNow,
            TotalAmount = product.DiscountedPrice * quantity,
            Items =
            [
                new OrderItem
                {
                    ProductId = product.Id,
                    Quantity = quantity,
                    UnitPrice = product.DiscountedPrice
                }
            ]
        };

        dbContext.Orders.Add(order);
        await dbContext.SaveChangesAsync(cancellationToken);
        await transaction.CommitAsync(cancellationToken);

        await notificationService.CreateAsync(userId, "OrderCreated", "Siparis olusturuldu", $"#{order.Id} nolu siparisiniz olusturuldu.", cancellationToken);
        if (product.Restaurant?.OwnerUserId is int sellerUserId)
        {
            await notificationService.CreateAsync(sellerUserId, "OrderReceived", "Yeni siparis", $"#{order.Id} nolu yeni siparis alindi.", cancellationToken);
        }

        return BuildCustomerOrderDto(order, product.Name);
    }

    public async Task<CustomerOrderDto?> CancelReservationAsync(int userId, int orderId, CancellationToken cancellationToken = default)
    {
        await using var transaction = await dbContext.Database.BeginTransactionAsync(cancellationToken);

        var order = await dbContext.Orders
            .Include(x => x.Items)
                .ThenInclude(i => i.Product)
                    .ThenInclude(p => p!.Restaurant)
            .FirstOrDefaultAsync(x => x.Id == orderId && x.UserId == userId && !x.IsDeleted, cancellationToken);

        if (order is null || (order.Status != OrderStatus.Pending && order.Status != OrderStatus.Confirmed))
        {
            return null;
        }

        order.Status = OrderStatus.Cancelled;
        order.CancelledAt = DateTime.UtcNow;

        foreach (var item in order.Items)
        {
            if (item.Product is null)
            {
                continue;
            }

            item.Product.Stock += item.Quantity;
            if (item.Product.ExpiryDate > DateTime.UtcNow && item.Product.Stock > 0)
            {
                item.Product.IsActive = true;
            }
        }

        await dbContext.SaveChangesAsync(cancellationToken);
        await transaction.CommitAsync(cancellationToken);

        await notificationService.CreateAsync(userId, "OrderCancelled", "Siparis iptal edildi", $"#{order.Id} nolu siparisiniz iptal edildi.", cancellationToken);

        var sellerUserIds = order.Items
            .Where(x => x.Product?.Restaurant?.OwnerUserId != null)
            .Select(x => x.Product!.Restaurant!.OwnerUserId!.Value)
            .Distinct()
            .ToList();

        foreach (var sellerUserId in sellerUserIds)
        {
            await notificationService.CreateAsync(sellerUserId, "OrderCancelled", "Siparis iptali", $"#{order.Id} nolu siparis iptal edildi.", cancellationToken);
        }

        return new CustomerOrderDto(
            order.Id,
            order.CreatedAt,
            order.Status.ToString(),
            order.TotalAmount,
            order.Items.Select(x => new CustomerOrderItemDto(
                x.ProductId,
                x.Product?.Name ?? "Unknown Product",
                x.Quantity,
                x.UnitPrice)).ToList());
    }

    public async Task<IReadOnlyList<CustomerOrderDto>> GetMyReservationsAsync(int userId, CancellationToken cancellationToken = default)
    {
        var now = DateTime.UtcNow;

        return await dbContext.Orders
            .AsNoTracking()
            .Include(x => x.Items)
                .ThenInclude(i => i.Product)
            .Where(x => x.UserId == userId
                        && !x.IsDeleted
                        && x.Status == OrderStatus.Pending
                        && x.ReservedUntil != null
                        && x.ReservedUntil > now)
            .OrderByDescending(x => x.CreatedAt)
            .Select(x => new CustomerOrderDto(
                x.Id,
                x.CreatedAt,
                x.Status.ToString(),
                x.TotalAmount,
                x.Items.Select(i => new CustomerOrderItemDto(
                    i.ProductId,
                    i.Product != null ? i.Product.Name : "Unknown Product",
                    i.Quantity,
                    i.UnitPrice)).ToList()))
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<CustomerOrderDto>> GetMyOrdersAsync(int userId, bool onlyActive, CancellationToken cancellationToken = default)
    {
        var query = dbContext.Orders
            .AsNoTracking()
            .Include(x => x.Items)
                .ThenInclude(i => i.Product)
            .Where(x => x.UserId == userId && !x.IsDeleted)
            .AsQueryable();

        if (onlyActive)
        {
            query = query.Where(x => x.Status == OrderStatus.Pending || x.Status == OrderStatus.Confirmed);
        }

        return await query
            .OrderByDescending(x => x.CreatedAt)
            .Select(x => new CustomerOrderDto(
                x.Id,
                x.CreatedAt,
                x.Status.ToString(),
                x.TotalAmount,
                x.Items.Select(i => new CustomerOrderItemDto(
                    i.ProductId,
                    i.Product != null ? i.Product.Name : "Unknown Product",
                    i.Quantity,
                    i.UnitPrice)).ToList()))
            .ToListAsync(cancellationToken);
    }

    public async Task<CustomerOrderDto?> GetMyOrderDetailAsync(int userId, int orderId, CancellationToken cancellationToken = default)
    {
        return await dbContext.Orders
            .AsNoTracking()
            .Include(x => x.Items)
                .ThenInclude(i => i.Product)
            .Where(x => x.Id == orderId && x.UserId == userId && !x.IsDeleted)
            .Select(x => new CustomerOrderDto(
                x.Id,
                x.CreatedAt,
                x.Status.ToString(),
                x.TotalAmount,
                x.Items.Select(i => new CustomerOrderItemDto(
                    i.ProductId,
                    i.Product != null ? i.Product.Name : "Unknown Product",
                    i.Quantity,
                    i.UnitPrice)).ToList()))
            .FirstOrDefaultAsync(cancellationToken);
    }

    private static double CalculateDistanceKm(double lat1, double lon1, double lat2, double lon2)
    {
        const double earthRadiusKm = 6371;

        var dLat = DegreesToRadians(lat2 - lat1);
        var dLon = DegreesToRadians(lon2 - lon1);

        var a = Math.Sin(dLat / 2) * Math.Sin(dLat / 2)
                + Math.Cos(DegreesToRadians(lat1)) * Math.Cos(DegreesToRadians(lat2))
                * Math.Sin(dLon / 2) * Math.Sin(dLon / 2);

        var c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));
        return earthRadiusKm * c;
    }

    private static double DegreesToRadians(double degrees) => degrees * Math.PI / 180;

    private static IReadOnlyList<string> GetHomeCategoryProductCategories(string? homeCategory)
    {
        return NormalizeHomeCategory(homeCategory) switch
        {
            "market" => ["Kahvaltilik", "Meyve", "Sut Urunleri"],
            "kafe" => ["Atistirmalik", "Fast Food", "Ev Yemegi"],
            "firin" => ["Firincilik", "Tatli"],
            "icecek" => ["Icecek"],
            _ => []
        };
    }

    private static string NormalizeHomeCategory(string? value)
    {
        return value?
            .Trim()
            .ToLowerInvariant()
            .Replace('ı', 'i')
            .Replace('İ', 'i')
            .Replace('ş', 's')
            .Replace('ç', 'c')
            .Replace('ö', 'o')
            .Replace('ü', 'u')
            .Replace('ğ', 'g') ?? string.Empty;
    }

    private async Task CreateReservationNotificationsAsync(int userId, int? sellerUserId, int orderId, CancellationToken cancellationToken)
    {
        await notificationService.CreateAsync(userId, "ReservationCreated", "Rezervasyon olusturuldu", $"#{orderId} nolu rezervasyonunuz olusturuldu.", cancellationToken);
        if (sellerUserId.HasValue)
        {
            await notificationService.CreateAsync(sellerUserId.Value, "ReservationReceived", "Yeni rezervasyon", $"#{orderId} nolu yeni rezervasyon alindi.", cancellationToken);
        }
    }

    private static CustomerOrderDto BuildCustomerOrderDto(Order order, string productName)
    {
        var firstItem = order.Items.First();
        return new CustomerOrderDto(
            order.Id,
            order.CreatedAt,
            order.Status.ToString(),
            order.TotalAmount,
            [new CustomerOrderItemDto(firstItem.ProductId, productName, firstItem.Quantity, firstItem.UnitPrice)]);
    }
}

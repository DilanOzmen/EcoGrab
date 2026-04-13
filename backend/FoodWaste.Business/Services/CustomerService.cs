using FoodWaste.Business.Abstractions;
using FoodWaste.Business.Models.Customer;
using FoodWaste.Data;
using FoodWaste.Entities;
using Microsoft.EntityFrameworkCore;

namespace FoodWaste.Business.Services;

public class CustomerService(FoodWasteDbContext dbContext) : ICustomerService
{
    public async Task<IReadOnlyList<CustomerProductDto>> GetProductsAsync(CustomerProductFilterModel filter, CancellationToken cancellationToken = default)
    {
        var now = DateTime.UtcNow;

        var query = dbContext.Products
            .AsNoTracking()
            .Where(x => !x.IsDeleted && x.IsActive && x.Stock > 0 && x.ExpiryDate > now
                        && x.Restaurant != null && !x.Restaurant.IsDeleted)
            .Include(x => x.Restaurant)
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(filter.Category))
        {
            var category = filter.Category.Trim();
            query = query.Where(x => x.Category == category);
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
                    x.ExpiryDate);
            });

        if (filter.MinDiscountPercent.HasValue)
        {
            projected = projected.Where(x => x.DiscountPercent >= filter.MinDiscountPercent.Value);
        }

        return projected.ToList();
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

        return new CustomerOrderDto(
            order.Id,
            order.CreatedAt,
            order.Status.ToString(),
            order.TotalAmount,
            [new CustomerOrderItemDto(product.Id, product.Name, quantity, product.DiscountedPrice)]);
    }

    public async Task<CustomerOrderDto?> CancelReservationAsync(int userId, int orderId, CancellationToken cancellationToken = default)
    {
        await using var transaction = await dbContext.Database.BeginTransactionAsync(cancellationToken);

        var order = await dbContext.Orders
            .Include(x => x.Items)
                .ThenInclude(i => i.Product)
            .FirstOrDefaultAsync(x => x.Id == orderId && x.UserId == userId && !x.IsDeleted, cancellationToken);

        if (order is null || order.Status != OrderStatus.Pending)
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
}

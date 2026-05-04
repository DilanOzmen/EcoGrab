using FoodWaste.Business.Abstractions;
using FoodWaste.Business.Models.Seller;
using FoodWaste.Data;
using FoodWaste.Entities;
using Microsoft.EntityFrameworkCore;

namespace FoodWaste.Business.Services;

public class SellerService(FoodWasteDbContext dbContext) : ISellerService
{
    public async Task<IReadOnlyList<SellerProductDto>> GetMyProductsAsync(int sellerUserId, CancellationToken cancellationToken = default)
    {
        return await dbContext.Products
            .AsNoTracking()
            .Where(x => !x.IsDeleted && x.Restaurant != null && x.Restaurant.OwnerUserId == sellerUserId && !x.Restaurant.IsDeleted)
            .Select(x => new SellerProductDto(
                x.Id,
                x.RestaurantId,
                x.Restaurant!.Name,
                x.Category,
                x.Name,
                x.Description,
                x.OriginalPrice,
                x.DiscountedPrice,
                x.Stock,
                x.ExpiryDate,
                x.IsActive,
                x.Images
                    .Where(i => !i.IsDeleted)
                    .OrderByDescending(i => i.IsPrimary)
                    .ThenBy(i => i.Id)
                    .Select(i => i.ImageUrl)
                    .FirstOrDefault()))
            .ToListAsync(cancellationToken);
    }

    public async Task<SellerProductDto?> CreateProductAsync(int sellerUserId, SellerProductCreateModel model, CancellationToken cancellationToken = default)
    {
        var restaurant = await dbContext.Restaurants
            .FirstOrDefaultAsync(x => x.Id == model.RestaurantId && x.OwnerUserId == sellerUserId && !x.IsDeleted, cancellationToken);

        if (restaurant is null)
        {
            return null;
        }

        var product = new Product
        {
            RestaurantId = model.RestaurantId,
            Category = model.Category.Trim(),
            Name = model.Name.Trim(),
            Description = model.Description.Trim(),
            OriginalPrice = model.OriginalPrice,
            DiscountedPrice = model.DiscountedPrice,
            Stock = model.Stock,
            ExpiryDate = model.ExpiryDate,
            IsActive = model.IsActive
        };

        dbContext.Products.Add(product);
        await dbContext.SaveChangesAsync(cancellationToken);

        return new SellerProductDto(
            product.Id,
            restaurant.Id,
            restaurant.Name,
            product.Category,
            product.Name,
            product.Description,
            product.OriginalPrice,
            product.DiscountedPrice,
            product.Stock,
            product.ExpiryDate,
            product.IsActive,
            null);
    }

    public async Task<SellerProductDto?> UpdateProductAsync(int sellerUserId, int productId, SellerProductUpdateModel model, CancellationToken cancellationToken = default)
    {
        var product = await dbContext.Products
            .Include(x => x.Restaurant)
            .FirstOrDefaultAsync(x => x.Id == productId && !x.IsDeleted && x.Restaurant != null && x.Restaurant.OwnerUserId == sellerUserId && !x.Restaurant.IsDeleted, cancellationToken);

        if (product is null || product.Restaurant is null)
        {
            return null;
        }

        if (!model.IsActive)
        {
            var hasOpenOrders = await dbContext.OrderItems
                .AnyAsync(x => x.ProductId == productId
                               && !x.IsDeleted
                               && x.Order != null
                               && !x.Order.IsDeleted
                               && (x.Order.Status == OrderStatus.Pending || x.Order.Status == OrderStatus.Confirmed),
                    cancellationToken);

            if (hasOpenOrders)
            {
                return null;
            }
        }

        product.Category = model.Category.Trim();
        product.Name = model.Name.Trim();
        product.Description = model.Description.Trim();
        product.OriginalPrice = model.OriginalPrice;
        product.DiscountedPrice = model.DiscountedPrice;
        product.Stock = model.Stock;
        product.ExpiryDate = model.ExpiryDate;
        product.IsActive = model.IsActive;

        await dbContext.SaveChangesAsync(cancellationToken);

        return new SellerProductDto(
            product.Id,
            product.RestaurantId,
            product.Restaurant.Name,
            product.Category,
            product.Name,
            product.Description,
            product.OriginalPrice,
            product.DiscountedPrice,
            product.Stock,
            product.ExpiryDate,
            product.IsActive,
            await dbContext.ProductImages
                .Where(x => x.ProductId == product.Id && !x.IsDeleted)
                .OrderByDescending(x => x.IsPrimary)
                .ThenBy(x => x.Id)
                .Select(x => x.ImageUrl)
                .FirstOrDefaultAsync(cancellationToken));
    }

    public async Task<bool> DeleteProductAsync(int sellerUserId, int productId, CancellationToken cancellationToken = default)
    {
        var product = await dbContext.Products
            .Include(x => x.Restaurant)
            .FirstOrDefaultAsync(x => x.Id == productId && !x.IsDeleted && x.Restaurant != null && x.Restaurant.OwnerUserId == sellerUserId && !x.Restaurant.IsDeleted, cancellationToken);

        if (product is null)
        {
            return false;
        }

        var hasOpenOrders = await dbContext.OrderItems
            .AnyAsync(x => x.ProductId == productId
                           && !x.IsDeleted
                           && x.Order != null
                           && !x.Order.IsDeleted
                           && (x.Order.Status == OrderStatus.Pending || x.Order.Status == OrderStatus.Confirmed),
                cancellationToken);

        if (hasOpenOrders)
        {
            return false;
        }

        product.IsDeleted = true;
        product.DeletedAt = DateTime.UtcNow;
        product.UpdatedAt = DateTime.UtcNow;
        product.IsActive = false;
        await dbContext.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task<IReadOnlyList<SellerActiveOrderDto>> GetOrdersAsync(int sellerUserId, bool onlyActive, CancellationToken cancellationToken = default)
    {
        var query = dbContext.Orders
            .AsNoTracking()
            .Where(x => !x.IsDeleted
                        && x.Items.Any(i => i.Product != null
                                            && !i.Product.IsDeleted
                                            && i.Product.Restaurant != null
                                            && !i.Product.Restaurant.IsDeleted
                                            && i.Product.Restaurant.OwnerUserId == sellerUserId));

        if (onlyActive)
        {
            query = query.Where(x => x.Status == OrderStatus.Pending || x.Status == OrderStatus.Confirmed);
        }

        return await query
            .OrderByDescending(x => x.CreatedAt)
            .Select(x => new SellerActiveOrderDto(
                x.Id,
                x.UserId,
                x.User != null ? x.User.FullName : "Unknown Customer",
                x.CreatedAt,
                x.Status.ToString(),
                x.TotalAmount,
                x.Items
                    .Where(i => i.Product != null
                                && !i.Product.IsDeleted
                                && i.Product.Restaurant != null
                                && !i.Product.Restaurant.IsDeleted
                                && i.Product.Restaurant.OwnerUserId == sellerUserId)
                    .Select(i => new SellerActiveOrderItemDto(
                        i.ProductId,
                        i.Product != null ? i.Product.Name : "Unknown Product",
                        i.Quantity,
                        i.UnitPrice))
                    .ToList()))
                    .ToListAsync(cancellationToken);
    }

    public async Task<SellerProductImageDto?> AddProductImageAsync(int sellerUserId, int productId, string imageUrl, string storageKey, bool isPrimary, CancellationToken cancellationToken = default)
    {
        var product = await dbContext.Products
            .Include(x => x.Restaurant)
            .FirstOrDefaultAsync(x => x.Id == productId && !x.IsDeleted && x.Restaurant != null && x.Restaurant.OwnerUserId == sellerUserId && !x.Restaurant.IsDeleted, cancellationToken);

        if (product is null)
        {
            return null;
        }

        if (isPrimary)
        {
            await dbContext.ProductImages
                .Where(x => x.ProductId == productId && x.IsPrimary && !x.IsDeleted)
                .ExecuteUpdateAsync(s => s.SetProperty(p => p.IsPrimary, false), cancellationToken);
        }

        var image = new ProductImage
        {
            ProductId = productId,
            ImageUrl = imageUrl.Trim(),
            StorageKey = storageKey.Trim(),
            IsPrimary = isPrimary
        };

        dbContext.ProductImages.Add(image);
        await dbContext.SaveChangesAsync(cancellationToken);

        return new SellerProductImageDto(image.Id, image.ProductId, image.ImageUrl, image.StorageKey, image.IsPrimary);
    }

    public async Task<IReadOnlyList<SellerProductImageDto>> GetProductImagesAsync(int sellerUserId, int productId, CancellationToken cancellationToken = default)
    {
        var canAccess = await dbContext.Products
            .AnyAsync(x => x.Id == productId && !x.IsDeleted && x.Restaurant != null && x.Restaurant.OwnerUserId == sellerUserId && !x.Restaurant.IsDeleted, cancellationToken);

        if (!canAccess)
        {
            return [];
        }

        return await dbContext.ProductImages
            .AsNoTracking()
            .Where(x => x.ProductId == productId && !x.IsDeleted)
            .OrderByDescending(x => x.IsPrimary)
            .ThenBy(x => x.Id)
            .Select(x => new SellerProductImageDto(x.Id, x.ProductId, x.ImageUrl, x.StorageKey, x.IsPrimary))
            .ToListAsync(cancellationToken);
    }

    public async Task<SellerActiveOrderDto?> GetOrderDetailAsync(int sellerUserId, int orderId, CancellationToken cancellationToken = default)
    {
        return await dbContext.Orders
            .AsNoTracking()
            .Where(x => x.Id == orderId
                        && !x.IsDeleted
                        && x.Items.Any(i => i.Product != null
                                            && !i.Product.IsDeleted
                                            && i.Product.Restaurant != null
                                            && !i.Product.Restaurant.IsDeleted
                                            && i.Product.Restaurant.OwnerUserId == sellerUserId))
            .Select(x => new SellerActiveOrderDto(
                x.Id,
                x.UserId,
                x.User != null ? x.User.FullName : "Unknown Customer",
                x.CreatedAt,
                x.Status.ToString(),
                x.TotalAmount,
                x.Items
                    .Where(i => i.Product != null
                                && !i.Product.IsDeleted
                                && i.Product.Restaurant != null
                                && !i.Product.Restaurant.IsDeleted
                                && i.Product.Restaurant.OwnerUserId == sellerUserId)
                    .Select(i => new SellerActiveOrderItemDto(
                        i.ProductId,
                        i.Product != null ? i.Product.Name : "Unknown Product",
                        i.Quantity,
                        i.UnitPrice))
                    .ToList()))
            .FirstOrDefaultAsync(cancellationToken);
    }

    public async Task<bool> DeleteProductImageAsync(int sellerUserId, int productId, int imageId, CancellationToken cancellationToken = default)
    {
        var image = await dbContext.ProductImages
            .Include(x => x.Product)
                .ThenInclude(p => p!.Restaurant)
            .FirstOrDefaultAsync(x => x.Id == imageId && x.ProductId == productId
                                      && !x.IsDeleted
                                      && x.Product != null
                                      && !x.Product.IsDeleted
                                      && x.Product.Restaurant != null
                                      && !x.Product.Restaurant.IsDeleted
                                      && x.Product.Restaurant.OwnerUserId == sellerUserId,
                cancellationToken);

        if (image is null)
        {
            return false;
        }

        image.IsDeleted = true;
        image.DeletedAt = DateTime.UtcNow;
        image.UpdatedAt = DateTime.UtcNow;
        await dbContext.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task<IReadOnlyList<SellerActiveOrderDto>> GetActiveOrdersAsync(int sellerUserId, CancellationToken cancellationToken = default)
    {
        return await dbContext.Orders
            .AsNoTracking()
            .Where(x => !x.IsDeleted
                        && (x.Status == OrderStatus.Pending || x.Status == OrderStatus.Confirmed)
                        && x.Items.Any(i => i.Product != null
                                            && !i.Product.IsDeleted
                                            && i.Product.Restaurant != null
                                            && !i.Product.Restaurant.IsDeleted
                                            && i.Product.Restaurant.OwnerUserId == sellerUserId))
            .OrderByDescending(x => x.CreatedAt)
            .Select(x => new SellerActiveOrderDto(
                x.Id,
                x.UserId,
                x.User != null ? x.User.FullName : "Unknown Customer",
                x.CreatedAt,
                x.Status.ToString(),
                x.TotalAmount,
                x.Items
                    .Where(i => i.Product != null
                                && !i.Product.IsDeleted
                                && i.Product.Restaurant != null
                                && !i.Product.Restaurant.IsDeleted
                                && i.Product.Restaurant.OwnerUserId == sellerUserId)
                    .Select(i => new SellerActiveOrderItemDto(
                        i.ProductId,
                        i.Product != null ? i.Product.Name : "Unknown Product",
                        i.Quantity,
                        i.UnitPrice))
                    .ToList()))
            .ToListAsync(cancellationToken);
    }

    public async Task<bool> UpdateOrderStatusAsync(int sellerUserId, int orderId, string status, CancellationToken cancellationToken = default)
    {
        if (!Enum.TryParse<OrderStatus>(status, true, out var newStatus))
        {
            return false;
        }

        if (newStatus != OrderStatus.Confirmed && newStatus != OrderStatus.Completed)
        {
            return false;
        }

        var order = await dbContext.Orders
            .Include(x => x.Items)
                .ThenInclude(i => i.Product)
                    .ThenInclude(p => p!.Restaurant)
            .FirstOrDefaultAsync(x => x.Id == orderId && !x.IsDeleted, cancellationToken);

        if (order is null)
        {
            return false;
        }

        var hasOwnership = order.Items.Any(i => i.Product != null
                                                && i.Product.Restaurant != null
                                                && i.Product.Restaurant.OwnerUserId == sellerUserId);

        if (!hasOwnership)
        {
            return false;
        }

        order.Status = newStatus;
        if (newStatus == OrderStatus.Confirmed)
        {
            order.ConfirmedAt = DateTime.UtcNow;
        }
        else if (newStatus == OrderStatus.Completed)
        {
            order.CompletedAt = DateTime.UtcNow;
        }

        await dbContext.SaveChangesAsync(cancellationToken);
        return true;
    }
}

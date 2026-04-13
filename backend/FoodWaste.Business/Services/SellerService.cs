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
            .Where(x => x.Restaurant != null && x.Restaurant.OwnerUserId == sellerUserId)
            .Select(x => new SellerProductDto(
                x.Id,
                x.RestaurantId,
                x.Restaurant!.Name,
                x.Name,
                x.Description,
                x.OriginalPrice,
                x.DiscountedPrice,
                x.Stock,
                x.ExpiryDate,
                x.IsActive))
            .ToListAsync(cancellationToken);
    }

    public async Task<SellerProductDto?> CreateProductAsync(int sellerUserId, SellerProductCreateModel model, CancellationToken cancellationToken = default)
    {
        var restaurant = await dbContext.Restaurants
            .FirstOrDefaultAsync(x => x.Id == model.RestaurantId && x.OwnerUserId == sellerUserId, cancellationToken);

        if (restaurant is null)
        {
            return null;
        }

        var product = new Product
        {
            RestaurantId = model.RestaurantId,
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
            product.Name,
            product.Description,
            product.OriginalPrice,
            product.DiscountedPrice,
            product.Stock,
            product.ExpiryDate,
            product.IsActive);
    }

    public async Task<SellerProductDto?> UpdateProductAsync(int sellerUserId, int productId, SellerProductUpdateModel model, CancellationToken cancellationToken = default)
    {
        var product = await dbContext.Products
            .Include(x => x.Restaurant)
            .FirstOrDefaultAsync(x => x.Id == productId && x.Restaurant != null && x.Restaurant.OwnerUserId == sellerUserId, cancellationToken);

        if (product is null || product.Restaurant is null)
        {
            return null;
        }

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
            product.Name,
            product.Description,
            product.OriginalPrice,
            product.DiscountedPrice,
            product.Stock,
            product.ExpiryDate,
            product.IsActive);
    }

    public async Task<bool> DeleteProductAsync(int sellerUserId, int productId, CancellationToken cancellationToken = default)
    {
        var product = await dbContext.Products
            .Include(x => x.Restaurant)
            .FirstOrDefaultAsync(x => x.Id == productId && x.Restaurant != null && x.Restaurant.OwnerUserId == sellerUserId, cancellationToken);

        if (product is null)
        {
            return false;
        }

        dbContext.Products.Remove(product);
        await dbContext.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task<IReadOnlyList<SellerActiveOrderDto>> GetActiveOrdersAsync(int sellerUserId, CancellationToken cancellationToken = default)
    {
        return await dbContext.Orders
            .AsNoTracking()
            .Where(x => (x.Status == OrderStatus.Pending || x.Status == OrderStatus.Confirmed)
                        && x.Items.Any(i => i.Product != null
                                            && i.Product.Restaurant != null
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
                                && i.Product.Restaurant != null
                                && i.Product.Restaurant.OwnerUserId == sellerUserId)
                    .Select(i => new SellerActiveOrderItemDto(
                        i.ProductId,
                        i.Product != null ? i.Product.Name : "Unknown Product",
                        i.Quantity,
                        i.UnitPrice))
                    .ToList()))
            .ToListAsync(cancellationToken);
    }
}

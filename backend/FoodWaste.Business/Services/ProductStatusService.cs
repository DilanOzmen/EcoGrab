using FoodWaste.Business.Abstractions;
using FoodWaste.Data;
using FoodWaste.Entities;
using Microsoft.EntityFrameworkCore;

namespace FoodWaste.Business.Services;

public class ProductStatusService(FoodWasteDbContext dbContext, INotificationService notificationService) : IProductStatusService
{
    public async Task<int> RefreshProductStatusesAsync(CancellationToken cancellationToken = default)
    {
        var now = DateTime.UtcNow;
        var productsToDeactivate = await dbContext.Products
            .Include(x => x.Restaurant)
            .Where(x => !x.IsDeleted && x.IsActive && (x.Stock <= 0 || x.ExpiryDate <= now))
            .ToListAsync(cancellationToken);

        foreach (var product in productsToDeactivate)
        {
            product.IsActive = false;
            product.UpdatedAt = now;
        }

        await dbContext.SaveChangesAsync(cancellationToken);

        foreach (var product in productsToDeactivate)
        {
            if (product.Restaurant?.OwnerUserId is int sellerUserId)
            {
                var reason = product.ExpiryDate <= now
                    ? "urunun suresi doldu"
                    : "urunun stogu bitti";
                await notificationService.CreateAsync(
                    sellerUserId,
                    "ProductAutoPassive",
                    "Urun pasife alindi",
                    $"{product.Name} urunu pasife alindi: {reason}.",
                    cancellationToken);
            }
        }

        return productsToDeactivate.Count;
    }
}

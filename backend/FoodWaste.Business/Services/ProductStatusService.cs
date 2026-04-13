using FoodWaste.Business.Abstractions;
using FoodWaste.Data;
using Microsoft.EntityFrameworkCore;

namespace FoodWaste.Business.Services;

public class ProductStatusService(FoodWasteDbContext dbContext) : IProductStatusService
{
    public async Task<int> RefreshProductStatusesAsync(CancellationToken cancellationToken = default)
    {
        var now = DateTime.UtcNow;
        var updated = await dbContext.Products
            .Where(x => !x.IsDeleted && x.IsActive && (x.Stock <= 0 || x.ExpiryDate <= now))
            .ExecuteUpdateAsync(x => x
                .SetProperty(p => p.IsActive, false)
                .SetProperty(p => p.UpdatedAt, now), cancellationToken);

        return updated;
    }
}

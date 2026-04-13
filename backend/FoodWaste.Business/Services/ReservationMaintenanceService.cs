using FoodWaste.Business.Abstractions;
using FoodWaste.Data;
using FoodWaste.Entities;
using Microsoft.EntityFrameworkCore;

namespace FoodWaste.Business.Services;

public class ReservationMaintenanceService(FoodWasteDbContext dbContext, INotificationService notificationService) : IReservationMaintenanceService
{
    public async Task<int> ExpirePendingReservationsAsync(CancellationToken cancellationToken = default)
    {
        var now = DateTime.UtcNow;

        var expiredOrders = await dbContext.Orders
            .Include(x => x.Items)
                .ThenInclude(i => i.Product)
                    .ThenInclude(p => p!.Restaurant)
            .Where(x => !x.IsDeleted
                        && x.Status == OrderStatus.Pending
                        && x.ReservedUntil != null
                        && x.ReservedUntil <= now)
            .ToListAsync(cancellationToken);

        if (expiredOrders.Count == 0)
        {
            return 0;
        }

        foreach (var order in expiredOrders)
        {
            order.Status = OrderStatus.Cancelled;
            order.CancelledAt = now;
            order.UpdatedAt = now;

            foreach (var item in order.Items)
            {
                if (item.Product is null)
                {
                    continue;
                }

                if (item.Product.IsDeleted)
                {
                    continue;
                }

                item.Product.Stock += item.Quantity;
                if (item.Product.Stock > 0 && item.Product.ExpiryDate > now)
                {
                    item.Product.IsActive = true;
                }

                item.Product.UpdatedAt = now;
            }
        }

        await dbContext.SaveChangesAsync(cancellationToken);

        foreach (var order in expiredOrders)
        {
            await notificationService.CreateAsync(
                order.UserId,
                "ReservationExpired",
                "Rezervasyon suresi doldu",
                $"#{order.Id} nolu rezervasyonunuzun suresi doldu.",
                cancellationToken);

            var sellerUserIds = order.Items
                .Where(x => x.Product?.Restaurant?.OwnerUserId != null)
                .Select(x => x.Product!.Restaurant!.OwnerUserId!.Value)
                .Distinct()
                .ToList();

            foreach (var sellerUserId in sellerUserIds)
            {
                await notificationService.CreateAsync(
                    sellerUserId,
                    "ReservationExpired",
                    "Rezervasyon suresi doldu",
                    $"#{order.Id} nolu rezervasyonun suresi doldu.",
                    cancellationToken);
            }
        }

        return expiredOrders.Count;
    }
}

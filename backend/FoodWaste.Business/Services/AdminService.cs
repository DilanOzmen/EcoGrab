using FoodWaste.Business.Abstractions;
using FoodWaste.Business.Models.Admin;
using FoodWaste.Data;
using FoodWaste.Entities;
using Microsoft.EntityFrameworkCore;

namespace FoodWaste.Business.Services;

public class AdminService(FoodWasteDbContext dbContext) : IAdminService
{
    public async Task<IReadOnlyList<PendingSellerDto>> GetPendingSellersAsync(CancellationToken cancellationToken = default)
    {
        return await dbContext.Users
            .AsNoTracking()
            .Where(x => x.Role == UserRole.Seller && !x.IsApproved && x.IsActive && !x.IsDeleted)
            .OrderByDescending(x => x.CreatedAt)
            .Select(x => new PendingSellerDto(
                x.Id,
                x.FullName,
                x.Email,
                x.Phone,
                x.CreatedAt))
            .ToListAsync(cancellationToken);
    }

    public async Task<bool> SetSellerApprovalAsync(int userId, bool isApproved, int? adminUserId, CancellationToken cancellationToken = default)
    {
        var seller = await dbContext.Users
            .FirstOrDefaultAsync(x => x.Id == userId && x.Role == UserRole.Seller && !x.IsDeleted, cancellationToken);

        if (seller is null)
        {
            return false;
        }

        seller.IsApproved = isApproved;
        dbContext.AdminActionLogs.Add(new AdminActionLog
        {
            AdminUserId = adminUserId,
            ActionType = "SellerApproval",
            TargetType = "User",
            TargetId = userId,
            Reason = isApproved ? "Seller approved" : "Seller rejected"
        });
        await dbContext.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task<bool> SetUserActiveAsync(int userId, bool isActive, int? adminUserId, CancellationToken cancellationToken = default)
    {
        var user = await dbContext.Users.FirstOrDefaultAsync(x => x.Id == userId && !x.IsDeleted, cancellationToken);
        if (user is null)
        {
            return false;
        }

        user.IsActive = isActive;
        dbContext.AdminActionLogs.Add(new AdminActionLog
        {
            AdminUserId = adminUserId,
            ActionType = "UserActiveState",
            TargetType = "User",
            TargetId = userId,
            Reason = isActive ? "User activated" : "User deactivated"
        });
        await dbContext.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task<bool> SetProductActiveAsync(int productId, bool isActive, int? adminUserId, CancellationToken cancellationToken = default)
    {
        var product = await dbContext.Products.FirstOrDefaultAsync(x => x.Id == productId && !x.IsDeleted, cancellationToken);
        if (product is null)
        {
            return false;
        }

        product.IsActive = isActive;
        dbContext.AdminActionLogs.Add(new AdminActionLog
        {
            AdminUserId = adminUserId,
            ActionType = "ProductActiveState",
            TargetType = "Product",
            TargetId = productId,
            Reason = isActive ? "Product activated" : "Product deactivated"
        });
        await dbContext.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task<AdminDashboardDto> GetDashboardMetricsAsync(CancellationToken cancellationToken = default)
    {
        var totalUsers = await dbContext.Users.CountAsync(x => !x.IsDeleted, cancellationToken);
        var activeUsers = await dbContext.Users.CountAsync(x => x.IsActive && !x.IsDeleted, cancellationToken);
        var totalOrders = await dbContext.Orders.CountAsync(x => !x.IsDeleted, cancellationToken);
        var completedSalesTotal = await dbContext.Orders
            .Where(x => x.Status == OrderStatus.Completed && !x.IsDeleted)
            .SumAsync(x => (decimal?)x.TotalAmount, cancellationToken) ?? 0;

        return new AdminDashboardDto(totalUsers, activeUsers, totalOrders, completedSalesTotal);
    }
}

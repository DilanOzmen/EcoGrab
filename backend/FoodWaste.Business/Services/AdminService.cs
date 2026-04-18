using FoodWaste.Business.Abstractions;
using FoodWaste.Business.Models.Admin;
using FoodWaste.Data;
using FoodWaste.Entities;
using Microsoft.EntityFrameworkCore;

namespace FoodWaste.Business.Services;

public class AdminService(FoodWasteDbContext dbContext, INotificationService notificationService) : IAdminService
{
    public async Task<PagedResultDto<AdminUserModerationDto>> GetUsersAsync(
        string? search,
        bool? isActive,
        string? role,
        string? sortBy,
        string? sortDir,
        int page,
        int pageSize,
        CancellationToken cancellationToken = default)
    {
        var query = dbContext.Users
            .AsNoTracking()
            .Where(x => !x.IsDeleted);

        if (!string.IsNullOrWhiteSpace(search))
        {
            var value = search.Trim();
            query = query.Where(x => x.FullName.Contains(value) || x.Email.Contains(value) || x.Phone.Contains(value));
        }

        if (isActive.HasValue)
        {
            query = query.Where(x => x.IsActive == isActive.Value);
        }

        if (!string.IsNullOrWhiteSpace(role) && Enum.TryParse<UserRole>(role, true, out var parsedRole))
        {
            query = query.Where(x => x.Role == parsedRole);
        }

        query = ApplyUserSorting(query, sortBy, sortDir);
        return await BuildUserPagedResultAsync(query, page, pageSize, cancellationToken);
    }

    public async Task<PagedResultDto<AdminUserModerationDto>> GetSellersAsync(
        string? search,
        bool? isActive,
        bool? isApproved,
        string? sortBy,
        string? sortDir,
        int page,
        int pageSize,
        CancellationToken cancellationToken = default)
    {
        var query = dbContext.Users
            .AsNoTracking()
            .Where(x => !x.IsDeleted && x.Role == UserRole.Seller);

        if (!string.IsNullOrWhiteSpace(search))
        {
            var value = search.Trim();
            query = query.Where(x => x.FullName.Contains(value) || x.Email.Contains(value) || x.Phone.Contains(value));
        }

        if (isActive.HasValue)
        {
            query = query.Where(x => x.IsActive == isActive.Value);
        }

        if (isApproved.HasValue)
        {
            query = query.Where(x => x.IsApproved == isApproved.Value);
        }

        query = ApplyUserSorting(query, sortBy, sortDir);
        return await BuildUserPagedResultAsync(query, page, pageSize, cancellationToken);
    }

    public async Task<PagedResultDto<AdminProductModerationDto>> GetProductsAsync(
        string? search,
        int? restaurantId,
        string? category,
        bool? isActive,
        string? sortBy,
        string? sortDir,
        int page,
        int pageSize,
        CancellationToken cancellationToken = default)
    {
        var query = dbContext.Products
            .AsNoTracking()
            .Where(x => !x.IsDeleted && x.Restaurant != null && !x.Restaurant.IsDeleted);

        if (!string.IsNullOrWhiteSpace(search))
        {
            var value = search.Trim();
            query = query.Where(x => x.Name.Contains(value) || x.Description.Contains(value));
        }

        if (restaurantId.HasValue)
        {
            query = query.Where(x => x.RestaurantId == restaurantId.Value);
        }

        if (!string.IsNullOrWhiteSpace(category))
        {
            var value = category.Trim();
            query = query.Where(x => x.Category == value);
        }

        if (isActive.HasValue)
        {
            query = query.Where(x => x.IsActive == isActive.Value);
        }

        query = ApplyProductSorting(query, sortBy, sortDir);

        var (safePage, safePageSize) = NormalizePaging(page, pageSize);
        var totalCount = await query.CountAsync(cancellationToken);
        var items = await query
            .Skip((safePage - 1) * safePageSize)
            .Take(safePageSize)
            .Select(x => new AdminProductModerationDto(
                x.Id,
                x.RestaurantId,
                x.Restaurant != null ? x.Restaurant.Name : "Unknown Restaurant",
                x.Name,
                x.Category,
                x.OriginalPrice,
                x.DiscountedPrice,
                x.Stock,
                x.IsActive,
                x.ExpiryDate,
                x.CreatedAt))
            .ToListAsync(cancellationToken);

        return new PagedResultDto<AdminProductModerationDto>(items, safePage, safePageSize, totalCount);
    }

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

        await notificationService.CreateAsync(
            userId,
            "SellerApproval",
            isApproved ? "Satici hesabi onaylandi" : "Satici hesabi reddedildi",
            isApproved
                ? "Satici hesabiniza erisim acildi."
                : "Satici hesabi basvurunuz reddedildi.",
            cancellationToken);

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

        await notificationService.CreateAsync(
            userId,
            "AccountState",
            isActive ? "Hesabiniz aktif" : "Hesabiniz pasif",
            isActive ? "Hesabiniz yeniden aktif edildi." : "Hesabiniz yonetici tarafindan pasife alindi.",
            cancellationToken);

        return true;
    }

    public async Task<bool> SetProductActiveAsync(int productId, bool isActive, int? adminUserId, CancellationToken cancellationToken = default)
    {
        var product = await dbContext.Products.FirstOrDefaultAsync(x => x.Id == productId && !x.IsDeleted, cancellationToken);
        if (product is null)
        {
            return false;
        }

        if (!isActive)
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
                return false;
            }
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

        var ownerUserId = await dbContext.Restaurants
            .AsNoTracking()
            .Where(x => x.Id == product.RestaurantId && !x.IsDeleted && x.OwnerUserId != null)
            .Select(x => x.OwnerUserId)
            .FirstOrDefaultAsync(cancellationToken);

        if (ownerUserId.HasValue)
        {
            await notificationService.CreateAsync(
                ownerUserId.Value,
                "ProductState",
                isActive ? "Urun aktif" : "Urun pasif",
                $"{product.Name} urununun durumu yonetici tarafindan {(isActive ? "aktif" : "pasif")} olarak guncellendi.",
                cancellationToken);
        }

        return true;
    }

    public async Task<bool> RemoveProductAsync(int productId, int? adminUserId, CancellationToken cancellationToken = default)
    {
        var product = await dbContext.Products.FirstOrDefaultAsync(x => x.Id == productId && !x.IsDeleted, cancellationToken);
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
        product.IsActive = false;
        product.UpdatedAt = DateTime.UtcNow;

        dbContext.AdminActionLogs.Add(new AdminActionLog
        {
            AdminUserId = adminUserId,
            ActionType = "ProductRemoved",
            TargetType = "Product",
            TargetId = productId,
            Reason = "Product removed by admin"
        });

        await dbContext.SaveChangesAsync(cancellationToken);

        var ownerUserId = await dbContext.Restaurants
            .AsNoTracking()
            .Where(x => x.Id == product.RestaurantId && !x.IsDeleted && x.OwnerUserId != null)
            .Select(x => x.OwnerUserId)
            .FirstOrDefaultAsync(cancellationToken);

        if (ownerUserId.HasValue)
        {
            await notificationService.CreateAsync(
                ownerUserId.Value,
                "ProductRemoved",
                "Urun kaldirildi",
                $"{product.Name} urunu yonetici tarafindan sistemden kaldirildi.",
                cancellationToken);
        }

        return true;
    }

    public async Task<AdminDashboardDto> GetDashboardMetricsAsync(CancellationToken cancellationToken = default)
    {
        var totalUsers = await dbContext.Users.CountAsync(x => !x.IsDeleted, cancellationToken);
        var activeUsers = await dbContext.Users.CountAsync(x => x.IsActive && !x.IsDeleted, cancellationToken);
        var activeSellers = await dbContext.Users.CountAsync(x => x.Role == UserRole.Seller && x.IsActive && x.IsApproved && !x.IsDeleted, cancellationToken);
        var totalOrders = await dbContext.Orders.CountAsync(x => !x.IsDeleted, cancellationToken);
        var activeProducts = await dbContext.Products.CountAsync(x => x.IsActive && !x.IsDeleted, cancellationToken);
        var completedSalesTotal = await dbContext.Orders
            .Where(x => x.Status == OrderStatus.Completed && !x.IsDeleted)
            .SumAsync(x => (decimal?)x.TotalAmount, cancellationToken) ?? 0;

        return new AdminDashboardDto(totalUsers, activeUsers, activeSellers, totalOrders, activeProducts, completedSalesTotal);
    }

    private static (int Page, int PageSize) NormalizePaging(int page, int pageSize)
    {
        var safePage = page < 1 ? 1 : page;
        var safePageSize = pageSize switch
        {
            < 1 => 20,
            > 100 => 100,
            _ => pageSize
        };

        return (safePage, safePageSize);
    }

    private static IQueryable<User> ApplyUserSorting(IQueryable<User> query, string? sortBy, string? sortDir)
    {
        var isDesc = !string.Equals(sortDir, "asc", StringComparison.OrdinalIgnoreCase);
        return (sortBy ?? "createdAt").ToLowerInvariant() switch
        {
            "fullname" => isDesc ? query.OrderByDescending(x => x.FullName) : query.OrderBy(x => x.FullName),
            "email" => isDesc ? query.OrderByDescending(x => x.Email) : query.OrderBy(x => x.Email),
            _ => isDesc ? query.OrderByDescending(x => x.CreatedAt) : query.OrderBy(x => x.CreatedAt)
        };
    }

    private static IQueryable<Product> ApplyProductSorting(IQueryable<Product> query, string? sortBy, string? sortDir)
    {
        var isDesc = !string.Equals(sortDir, "asc", StringComparison.OrdinalIgnoreCase);
        return (sortBy ?? "createdAt").ToLowerInvariant() switch
        {
            "name" => isDesc ? query.OrderByDescending(x => x.Name) : query.OrderBy(x => x.Name),
            "discountedprice" => isDesc ? query.OrderByDescending(x => x.DiscountedPrice) : query.OrderBy(x => x.DiscountedPrice),
            "stock" => isDesc ? query.OrderByDescending(x => x.Stock) : query.OrderBy(x => x.Stock),
            _ => isDesc ? query.OrderByDescending(x => x.CreatedAt) : query.OrderBy(x => x.CreatedAt)
        };
    }

    private static async Task<PagedResultDto<AdminUserModerationDto>> BuildUserPagedResultAsync(
        IQueryable<User> query,
        int page,
        int pageSize,
        CancellationToken cancellationToken)
    {
        var (safePage, safePageSize) = NormalizePaging(page, pageSize);
        var totalCount = await query.CountAsync(cancellationToken);
        var items = await query
            .Skip((safePage - 1) * safePageSize)
            .Take(safePageSize)
            .Select(x => new AdminUserModerationDto(
                x.Id,
                x.FullName,
                x.Email,
                x.Phone,
                x.Role.ToString(),
                x.IsActive,
                x.IsApproved,
                x.CreatedAt))
            .ToListAsync(cancellationToken);

        return new PagedResultDto<AdminUserModerationDto>(items, safePage, safePageSize, totalCount);
    }
}

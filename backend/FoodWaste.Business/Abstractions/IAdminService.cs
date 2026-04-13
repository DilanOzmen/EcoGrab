using FoodWaste.Business.Models.Admin;

namespace FoodWaste.Business.Abstractions;

public interface IAdminService
{
    Task<IReadOnlyList<AdminUserModerationDto>> GetUsersAsync(CancellationToken cancellationToken = default);
    Task<IReadOnlyList<AdminUserModerationDto>> GetSellersAsync(CancellationToken cancellationToken = default);
    Task<IReadOnlyList<AdminProductModerationDto>> GetProductsAsync(CancellationToken cancellationToken = default);
    Task<IReadOnlyList<PendingSellerDto>> GetPendingSellersAsync(CancellationToken cancellationToken = default);
    Task<bool> SetSellerApprovalAsync(int userId, bool isApproved, int? adminUserId, CancellationToken cancellationToken = default);
    Task<bool> SetUserActiveAsync(int userId, bool isActive, int? adminUserId, CancellationToken cancellationToken = default);
    Task<bool> SetProductActiveAsync(int productId, bool isActive, int? adminUserId, CancellationToken cancellationToken = default);
    Task<bool> RemoveProductAsync(int productId, int? adminUserId, CancellationToken cancellationToken = default);
    Task<AdminDashboardDto> GetDashboardMetricsAsync(CancellationToken cancellationToken = default);
}

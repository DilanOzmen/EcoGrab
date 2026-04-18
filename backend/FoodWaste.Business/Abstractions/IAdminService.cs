using FoodWaste.Business.Models.Admin;

namespace FoodWaste.Business.Abstractions;

public interface IAdminService
{
    Task<PagedResultDto<AdminUserModerationDto>> GetUsersAsync(
        string? search,
        bool? isActive,
        string? role,
        string? sortBy,
        string? sortDir,
        int page,
        int pageSize,
        CancellationToken cancellationToken = default);

    Task<PagedResultDto<AdminUserModerationDto>> GetSellersAsync(
        string? search,
        bool? isActive,
        bool? isApproved,
        string? sortBy,
        string? sortDir,
        int page,
        int pageSize,
        CancellationToken cancellationToken = default);

    Task<PagedResultDto<AdminProductModerationDto>> GetProductsAsync(
        string? search,
        int? restaurantId,
        string? category,
        bool? isActive,
        string? sortBy,
        string? sortDir,
        int page,
        int pageSize,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyList<PendingSellerDto>> GetPendingSellersAsync(CancellationToken cancellationToken = default);
    Task<bool> SetSellerApprovalAsync(int userId, bool isApproved, int? adminUserId, CancellationToken cancellationToken = default);
    Task<bool> SetUserActiveAsync(int userId, bool isActive, int? adminUserId, CancellationToken cancellationToken = default);
    Task<bool> SetProductActiveAsync(int productId, bool isActive, int? adminUserId, CancellationToken cancellationToken = default);
    Task<bool> RemoveProductAsync(int productId, int? adminUserId, CancellationToken cancellationToken = default);
    Task<AdminDashboardDto> GetDashboardMetricsAsync(CancellationToken cancellationToken = default);
}

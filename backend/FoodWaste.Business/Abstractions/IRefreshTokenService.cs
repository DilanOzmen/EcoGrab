using FoodWaste.Entities;

namespace FoodWaste.Business.Abstractions;

public interface IRefreshTokenService
{
    Task<string> IssueAsync(int userId, string deviceInfo, string ipAddress, CancellationToken cancellationToken = default);
    Task<RefreshToken?> GetValidTokenAsync(string plainToken, CancellationToken cancellationToken = default);
    Task RevokeAsync(string plainToken, CancellationToken cancellationToken = default);
}

using System.Security.Cryptography;
using System.Text;
using FoodWaste.Business.Abstractions;
using FoodWaste.Data;
using FoodWaste.Entities;
using Microsoft.EntityFrameworkCore;

namespace FoodWaste.Business.Services;

public class RefreshTokenService(FoodWasteDbContext dbContext) : IRefreshTokenService
{
    private static readonly TimeSpan RefreshTokenLifetime = TimeSpan.FromDays(7);

    public async Task<string> IssueAsync(int userId, string deviceInfo, string ipAddress, CancellationToken cancellationToken = default)
    {
        var plainToken = GenerateSecureToken();
        var hashedToken = HashToken(plainToken);

        var token = new RefreshToken
        {
            UserId = userId,
            TokenHash = hashedToken,
            ExpiresAt = DateTime.UtcNow.Add(RefreshTokenLifetime),
            DeviceInfo = Truncate(deviceInfo, 200),
            IpAddress = Truncate(ipAddress, 64)
        };

        dbContext.RefreshTokens.Add(token);
        await dbContext.SaveChangesAsync(cancellationToken);
        return plainToken;
    }

    public async Task<RefreshToken?> GetValidTokenAsync(string plainToken, CancellationToken cancellationToken = default)
    {
        var hash = HashToken(plainToken);
        return await dbContext.RefreshTokens
            .FirstOrDefaultAsync(x => x.TokenHash == hash
                                      && !x.IsDeleted
                                      && x.RevokedAt == null
                                      && x.ExpiresAt > DateTime.UtcNow, cancellationToken);
    }

    public async Task RevokeAsync(string plainToken, CancellationToken cancellationToken = default)
    {
        var hash = HashToken(plainToken);
        var token = await dbContext.RefreshTokens
            .FirstOrDefaultAsync(x => x.TokenHash == hash && !x.IsDeleted, cancellationToken);

        if (token is null)
        {
            return;
        }

        token.RevokedAt ??= DateTime.UtcNow;
        token.UpdatedAt = DateTime.UtcNow;
        await dbContext.SaveChangesAsync(cancellationToken);
    }

    private static string GenerateSecureToken()
    {
        var bytes = RandomNumberGenerator.GetBytes(64);
        return Convert.ToBase64String(bytes);
    }

    private static string HashToken(string plainToken)
    {
        var hashBytes = SHA256.HashData(Encoding.UTF8.GetBytes(plainToken));
        return Convert.ToBase64String(hashBytes);
    }

    private static string Truncate(string value, int maxLength)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            return string.Empty;
        }

        return value.Length <= maxLength ? value : value[..maxLength];
    }
}

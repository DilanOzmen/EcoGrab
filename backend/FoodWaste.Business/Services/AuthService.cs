using FoodWaste.Business.Abstractions;
using FoodWaste.Business.Models;
using FoodWaste.Data;
using FoodWaste.Entities;
using Microsoft.EntityFrameworkCore;

namespace FoodWaste.Business.Services;

public class AuthService(FoodWasteDbContext dbContext) : IAuthService
{
    public async Task<AuthResult> RegisterAsync(
        string fullName,
        string email,
        string password,
        string phone,
        string role,
        CancellationToken cancellationToken = default)
    {
        var normalizedEmail = email.Trim().ToLowerInvariant();

        var emailExists = await dbContext.Users
            .AnyAsync(x => x.Email == normalizedEmail && !x.IsDeleted, cancellationToken);

        if (emailExists)
        {
            return new AuthResult(false, "Bu e-posta zaten kayitli.", 0, string.Empty, string.Empty, string.Empty);
        }

        if (!Enum.TryParse<UserRole>(role, true, out var userRole))
        {
            return new AuthResult(false, "Gecersiz rol secimi.", 0, string.Empty, string.Empty, string.Empty);
        }

        if (userRole == UserRole.Admin)
        {
            return new AuthResult(false, "Admin rolu kayit uzerinden olusturulamaz.", 0, string.Empty, string.Empty, string.Empty);
        }

        var user = new User
        {
            FullName = fullName.Trim(),
            Email = normalizedEmail,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(password),
            Phone = phone.Trim(),
            Role = userRole,
            IsActive = true,
            IsApproved = userRole != UserRole.Seller
        };

        dbContext.Users.Add(user);
        await dbContext.SaveChangesAsync(cancellationToken);

        return new AuthResult(true, null, user.Id, user.FullName, user.Email, user.Role.ToString());
    }

    public async Task<AuthResult> LoginAsync(string email, string password, CancellationToken cancellationToken = default)
    {
        var normalizedEmail = email.Trim().ToLowerInvariant();

        var user = await dbContext.Users
            .FirstOrDefaultAsync(x => x.Email == normalizedEmail && !x.IsDeleted, cancellationToken);

        if (user is null)
        {
            return new AuthResult(false, "E-posta veya sifre hatali.", 0, string.Empty, string.Empty, string.Empty);
        }

        var passwordValid = BCrypt.Net.BCrypt.Verify(password, user.PasswordHash);
        if (!passwordValid)
        {
            return new AuthResult(false, "E-posta veya sifre hatali.", 0, string.Empty, string.Empty, string.Empty);
        }

        if (!user.IsActive)
        {
            return new AuthResult(false, "Hesabiniz pasif durumda.", 0, string.Empty, string.Empty, string.Empty);
        }

        if (user.Role == UserRole.Seller && !user.IsApproved)
        {
            return new AuthResult(false, "Satici hesabi henuz onaylanmadi.", 0, string.Empty, string.Empty, string.Empty);
        }

        user.LastLoginAt = DateTime.UtcNow;
        await dbContext.SaveChangesAsync(cancellationToken);

        return new AuthResult(true, null, user.Id, user.FullName, user.Email, user.Role.ToString());
    }
}

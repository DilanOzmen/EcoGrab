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
        CancellationToken cancellationToken = default)
    {
        var normalizedEmail = email.Trim().ToLowerInvariant();

        var emailExists = await dbContext.Users
            .AnyAsync(x => x.Email == normalizedEmail, cancellationToken);

        if (emailExists)
        {
            return new AuthResult(false, "Bu e-posta zaten kayitli.", 0, string.Empty, string.Empty, string.Empty);
        }

        var user = new User
        {
            FullName = fullName.Trim(),
            Email = normalizedEmail,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(password),
            Phone = phone.Trim(),
            Role = UserRole.Customer
        };

        dbContext.Users.Add(user);
        await dbContext.SaveChangesAsync(cancellationToken);

        return new AuthResult(true, null, user.Id, user.FullName, user.Email, user.Role.ToString());
    }

    public async Task<AuthResult> LoginAsync(string email, string password, CancellationToken cancellationToken = default)
    {
        var normalizedEmail = email.Trim().ToLowerInvariant();

        var user = await dbContext.Users
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Email == normalizedEmail, cancellationToken);

        if (user is null)
        {
            return new AuthResult(false, "E-posta veya sifre hatali.", 0, string.Empty, string.Empty, string.Empty);
        }

        var passwordValid = BCrypt.Net.BCrypt.Verify(password, user.PasswordHash);
        if (!passwordValid)
        {
            return new AuthResult(false, "E-posta veya sifre hatali.", 0, string.Empty, string.Empty, string.Empty);
        }

        return new AuthResult(true, null, user.Id, user.FullName, user.Email, user.Role.ToString());
    }
}

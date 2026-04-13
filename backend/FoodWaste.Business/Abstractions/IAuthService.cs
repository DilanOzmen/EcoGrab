using FoodWaste.Business.Models;

namespace FoodWaste.Business.Abstractions;

public interface IAuthService
{
    Task<AuthResult> RegisterAsync(string fullName, string email, string password, string phone, string role, CancellationToken cancellationToken = default);
    Task<AuthResult> LoginAsync(string email, string password, CancellationToken cancellationToken = default);
}

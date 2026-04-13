namespace FoodWaste.API.Services;

public interface IJwtTokenService
{
    string GenerateToken(int userId, string fullName, string email, string role);
}

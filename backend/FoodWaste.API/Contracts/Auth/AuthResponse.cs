namespace FoodWaste.API.Contracts.Auth;

public sealed record AuthResponse(int UserId, string FullName, string Email, string Role, string Token);

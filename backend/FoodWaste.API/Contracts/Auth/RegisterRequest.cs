namespace FoodWaste.API.Contracts.Auth;

public sealed record RegisterRequest(string FullName, string Email, string Password, string Phone, string Role);

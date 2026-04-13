namespace FoodWaste.Business.Models;

public sealed record AuthResult(bool IsSuccess, string? ErrorMessage, int UserId, string FullName, string Email, string Role);

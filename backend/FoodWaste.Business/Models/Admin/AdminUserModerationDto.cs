namespace FoodWaste.Business.Models.Admin;

public sealed record AdminUserModerationDto(
    int Id,
    string FullName,
    string Email,
    string Phone,
    string Role,
    bool IsActive,
    bool IsApproved,
    DateTime CreatedAt);
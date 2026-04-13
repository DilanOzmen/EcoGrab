namespace FoodWaste.Business.Models.Admin;

public sealed record PendingSellerDto(
    int UserId,
    string FullName,
    string Email,
    string Phone,
    DateTime CreatedAt);

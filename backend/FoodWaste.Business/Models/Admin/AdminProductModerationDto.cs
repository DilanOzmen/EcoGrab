namespace FoodWaste.Business.Models.Admin;

public sealed record AdminProductModerationDto(
    int Id,
    int RestaurantId,
    string RestaurantName,
    string ProductName,
    string Category,
    decimal OriginalPrice,
    decimal DiscountedPrice,
    int Stock,
    bool IsActive,
    DateTime ExpiryDate,
    DateTime CreatedAt);
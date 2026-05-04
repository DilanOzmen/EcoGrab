namespace FoodWaste.Business.Models.Seller;

public sealed record SellerProductDto(
    int Id,
    int RestaurantId,
    string RestaurantName,
    string Category,
    string Name,
    string Description,
    decimal OriginalPrice,
    decimal DiscountedPrice,
    int Stock,
    DateTime ExpiryDate,
    bool IsActive,
    string? PrimaryImageUrl);

namespace FoodWaste.Business.Models.Customer;

public sealed record CustomerProductDto(
    int Id,
    int RestaurantId,
    string RestaurantName,
    string Category,
    string Name,
    string Description,
    decimal OriginalPrice,
    decimal DiscountedPrice,
    decimal DiscountPercent,
    int Stock,
    DateTime ExpiryDate);

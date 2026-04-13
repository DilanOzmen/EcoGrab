namespace FoodWaste.API.Contracts.Seller;

public sealed record CreateProductRequest(
    int RestaurantId,
    string Name,
    string Description,
    decimal OriginalPrice,
    decimal DiscountedPrice,
    int Stock,
    DateTime ExpiryDate,
    bool IsActive);

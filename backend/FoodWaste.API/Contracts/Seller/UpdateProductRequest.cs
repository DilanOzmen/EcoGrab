namespace FoodWaste.API.Contracts.Seller;

public sealed record UpdateProductRequest(
    string Name,
    string Description,
    decimal OriginalPrice,
    decimal DiscountedPrice,
    int Stock,
    DateTime ExpiryDate,
    bool IsActive);

namespace FoodWaste.Business.Models.Seller;

public sealed record SellerProductCreateModel(
    int RestaurantId,
    string Name,
    string Description,
    decimal OriginalPrice,
    decimal DiscountedPrice,
    int Stock,
    DateTime ExpiryDate,
    bool IsActive);

namespace FoodWaste.Business.Models.Seller;

public sealed record SellerProductUpdateModel(
    string Name,
    string Description,
    decimal OriginalPrice,
    decimal DiscountedPrice,
    int Stock,
    DateTime ExpiryDate,
    bool IsActive);

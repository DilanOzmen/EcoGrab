namespace FoodWaste.Business.Models.Seller;

public sealed record SellerProductImageDto(
    int Id,
    int ProductId,
    string ImageUrl,
    string StorageKey,
    bool IsPrimary);

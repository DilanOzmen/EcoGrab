namespace FoodWaste.API.Contracts.Seller;

public sealed record AddProductImageRequest(string ImageUrl, string StorageKey, bool IsPrimary);

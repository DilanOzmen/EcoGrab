namespace FoodWaste.Business.Models.Customer;

public sealed record CustomerProductFilterModel(
    string? Category,
    decimal? MinPrice,
    decimal? MaxPrice,
    decimal? MinDiscountPercent);

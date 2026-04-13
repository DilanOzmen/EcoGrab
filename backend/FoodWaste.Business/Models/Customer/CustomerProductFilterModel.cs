namespace FoodWaste.Business.Models.Customer;

public sealed record CustomerProductFilterModel(
    string? Search,
    string? Category,
    decimal? MinPrice,
    decimal? MaxPrice,
    decimal? MinDiscountPercent,
    double? Latitude,
    double? Longitude,
    double? RadiusKm);

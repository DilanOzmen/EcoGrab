namespace FoodWaste.Business.Models.Customer;

public sealed record NearbyRestaurantDto(
    int Id,
    string Name,
    string Address,
    string City,
    double Latitude,
    double Longitude,
    double DistanceKm);

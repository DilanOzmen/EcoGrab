namespace FoodWaste.Business.Models.Customer;

public sealed record RestaurantDetailDto(
    int Id,
    string Name,
    string Address,
    string City,
    string Phone,
    double Latitude,
    double Longitude);

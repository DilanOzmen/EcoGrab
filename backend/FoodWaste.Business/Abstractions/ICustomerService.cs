using FoodWaste.Business.Models.Customer;

namespace FoodWaste.Business.Abstractions;

public interface ICustomerService
{
    Task<IReadOnlyList<NearbyRestaurantDto>> GetRestaurantsAsync(string? city, string? search, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<CustomerProductDto>> GetProductsAsync(CustomerProductFilterModel filter, CancellationToken cancellationToken = default);
    Task<CustomerProductDto?> GetProductDetailAsync(int productId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<CustomerProductDto>> GetProductsByRestaurantAsync(int restaurantId, CancellationToken cancellationToken = default);
    Task<RestaurantDetailDto?> GetRestaurantDetailAsync(int restaurantId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<NearbyRestaurantDto>> GetNearbyRestaurantsAsync(double latitude, double longitude, double radiusKm, CancellationToken cancellationToken = default);
    Task<CustomerOrderDto?> ReserveAsync(int userId, int productId, int quantity, CancellationToken cancellationToken = default);
    Task<CustomerOrderDto?> CreateOrderAsync(int userId, int productId, int quantity, CancellationToken cancellationToken = default);
    Task<CustomerOrderDto?> CancelReservationAsync(int userId, int orderId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<CustomerOrderDto>> GetMyReservationsAsync(int userId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<CustomerOrderDto>> GetMyOrdersAsync(int userId, bool onlyActive, CancellationToken cancellationToken = default);
    Task<CustomerOrderDto?> GetMyOrderDetailAsync(int userId, int orderId, CancellationToken cancellationToken = default);
}

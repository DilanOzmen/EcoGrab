using FoodWaste.Business.Models.Customer;

namespace FoodWaste.Business.Abstractions;

public interface ICustomerService
{
    Task<IReadOnlyList<CustomerProductDto>> GetProductsAsync(CustomerProductFilterModel filter, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<NearbyRestaurantDto>> GetNearbyRestaurantsAsync(double latitude, double longitude, double radiusKm, CancellationToken cancellationToken = default);
    Task<CustomerOrderDto?> ReserveAsync(int userId, int productId, int quantity, CancellationToken cancellationToken = default);
    Task<CustomerOrderDto?> CancelReservationAsync(int userId, int orderId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<CustomerOrderDto>> GetMyOrdersAsync(int userId, bool onlyActive, CancellationToken cancellationToken = default);
}

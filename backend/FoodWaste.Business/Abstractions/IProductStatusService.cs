namespace FoodWaste.Business.Abstractions;

public interface IProductStatusService
{
    Task<int> RefreshProductStatusesAsync(CancellationToken cancellationToken = default);
}

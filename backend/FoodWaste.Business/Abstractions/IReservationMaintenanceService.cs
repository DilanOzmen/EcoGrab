namespace FoodWaste.Business.Abstractions;

public interface IReservationMaintenanceService
{
    Task<int> ExpirePendingReservationsAsync(CancellationToken cancellationToken = default);
}

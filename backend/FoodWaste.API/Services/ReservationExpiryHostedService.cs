using FoodWaste.Business.Abstractions;

namespace FoodWaste.API.Services;

public class ReservationExpiryHostedService(IServiceScopeFactory scopeFactory, ILogger<ReservationExpiryHostedService> logger) : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                using var scope = scopeFactory.CreateScope();
                var maintenance = scope.ServiceProvider.GetRequiredService<IReservationMaintenanceService>();
                await maintenance.ExpirePendingReservationsAsync(stoppingToken);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Reservation expiry job failed.");
            }

            await Task.Delay(TimeSpan.FromMinutes(1), stoppingToken);
        }
    }
}

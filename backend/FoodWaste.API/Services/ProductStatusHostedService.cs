using FoodWaste.Business.Abstractions;

namespace FoodWaste.API.Services;

public class ProductStatusHostedService(IServiceScopeFactory scopeFactory, ILogger<ProductStatusHostedService> logger) : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                using var scope = scopeFactory.CreateScope();
                var productStatusService = scope.ServiceProvider.GetRequiredService<IProductStatusService>();
                await productStatusService.RefreshProductStatusesAsync(stoppingToken);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Product status refresh failed.");
            }

            await Task.Delay(TimeSpan.FromMinutes(5), stoppingToken);
        }
    }
}

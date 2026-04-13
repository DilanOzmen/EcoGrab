using FoodWaste.Business.Abstractions;
using FoodWaste.Business.Services;
using Microsoft.Extensions.DependencyInjection;

namespace FoodWaste.Business;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddBusiness(this IServiceCollection services)
    {
        services.AddScoped<IAuthService, AuthService>();
        services.AddScoped<IAuthValidationService, AuthValidationService>();
        services.AddScoped<IRefreshTokenService, RefreshTokenService>();
        services.AddScoped<ISellerService, SellerService>();
        services.AddScoped<ICustomerService, CustomerService>();
        services.AddScoped<IAdminService, AdminService>();
        services.AddScoped<INotificationService, NotificationService>();
        services.AddScoped<IProductStatusService, ProductStatusService>();
        services.AddScoped<IReservationMaintenanceService, ReservationMaintenanceService>();
        return services;
    }
}

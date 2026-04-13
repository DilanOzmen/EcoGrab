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
        services.AddScoped<ISellerService, SellerService>();
        return services;
    }
}

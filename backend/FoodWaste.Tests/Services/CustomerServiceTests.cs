using FoodWaste.Business.Abstractions;
using FoodWaste.Business.Models.Customer;
using FoodWaste.Business.Models.Notification;
using FoodWaste.Business.Services;
using FoodWaste.Data;
using FoodWaste.Entities;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace FoodWaste.Tests.Services;

public class CustomerServiceTests
{
    [Fact]
    public async Task GetProductsAsync_ReturnsOnlyDiscountedProducts()
    {
        await using var dbContext = CreateContext();

        var restaurant = new Restaurant
        {
            Name = "Restaurant",
            Address = "Address",
            City = "Istanbul",
            Phone = "5550000001",
            Latitude = 41,
            Longitude = 29
        };
        dbContext.Restaurants.Add(restaurant);
        await dbContext.SaveChangesAsync();

        dbContext.Products.AddRange(
            new Product
            {
                RestaurantId = restaurant.Id,
                Category = "Food",
                Name = "Discounted",
                Description = "Desc",
                OriginalPrice = 100,
                DiscountedPrice = 80,
                Stock = 5,
                ExpiryDate = DateTime.UtcNow.AddDays(1),
                IsActive = true
            },
            new Product
            {
                RestaurantId = restaurant.Id,
                Category = "Food",
                Name = "NotDiscounted",
                Description = "Desc",
                OriginalPrice = 100,
                DiscountedPrice = 100,
                Stock = 5,
                ExpiryDate = DateTime.UtcNow.AddDays(1),
                IsActive = true
            });

        await dbContext.SaveChangesAsync();

        var service = new CustomerService(dbContext, new TestNotificationService());
        var filter = new CustomerProductFilterModel(null, null, null, null, null, null, null, null);

        var result = await service.GetProductsAsync(filter);

        Assert.Single(result);
        Assert.Equal("Discounted", result[0].Name);
    }

    [Fact]
    public async Task GetProductDetailAsync_ReturnsNull_ForNonDiscountedProduct()
    {
        await using var dbContext = CreateContext();

        var restaurant = new Restaurant
        {
            Name = "Restaurant",
            Address = "Address",
            City = "Istanbul",
            Phone = "5550000001",
            Latitude = 41,
            Longitude = 29
        };
        dbContext.Restaurants.Add(restaurant);
        await dbContext.SaveChangesAsync();

        var product = new Product
        {
            RestaurantId = restaurant.Id,
            Category = "Food",
            Name = "NotDiscounted",
            Description = "Desc",
            OriginalPrice = 100,
            DiscountedPrice = 100,
            Stock = 5,
            ExpiryDate = DateTime.UtcNow.AddDays(1),
            IsActive = true
        };
        dbContext.Products.Add(product);
        await dbContext.SaveChangesAsync();

        var service = new CustomerService(dbContext, new TestNotificationService());

        var result = await service.GetProductDetailAsync(product.Id);

        Assert.Null(result);
    }

    [Fact]
    public async Task GetProductDetailAsync_ReturnsProduct_ForDiscountedActiveProduct()
    {
        await using var dbContext = CreateContext();

        var restaurant = new Restaurant
        {
            Name = "Restaurant",
            Address = "Address",
            City = "Istanbul",
            Phone = "5550000001",
            Latitude = 41,
            Longitude = 29
        };
        dbContext.Restaurants.Add(restaurant);
        await dbContext.SaveChangesAsync();

        var product = new Product
        {
            RestaurantId = restaurant.Id,
            Category = "Food",
            Name = "Discounted",
            Description = "Desc",
            OriginalPrice = 100,
            DiscountedPrice = 80,
            Stock = 5,
            ExpiryDate = DateTime.UtcNow.AddDays(1),
            IsActive = true
        };
        dbContext.Products.Add(product);
        await dbContext.SaveChangesAsync();

        var service = new CustomerService(dbContext, new TestNotificationService());

        var result = await service.GetProductDetailAsync(product.Id);

        Assert.NotNull(result);
        Assert.Equal(product.Id, result!.Id);
        Assert.Equal("Discounted", result.Name);
    }

    private static FoodWasteDbContext CreateContext()
    {
        var options = new DbContextOptionsBuilder<FoodWasteDbContext>()
            .UseInMemoryDatabase($"FoodWasteTests-{Guid.NewGuid()}")
            .Options;

        return new FoodWasteDbContext(options);
    }

    private sealed class TestNotificationService : INotificationService
    {
        public Task CreateAsync(int userId, string type, string title, string message, CancellationToken cancellationToken = default)
            => Task.CompletedTask;

        public Task<IReadOnlyList<NotificationDto>> GetMyNotificationsAsync(int userId, CancellationToken cancellationToken = default)
            => Task.FromResult<IReadOnlyList<NotificationDto>>([]);

        public Task<bool> MarkAsReadAsync(int userId, int notificationId, CancellationToken cancellationToken = default)
            => Task.FromResult(false);
    }
}

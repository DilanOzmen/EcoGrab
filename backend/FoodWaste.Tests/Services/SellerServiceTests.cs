using FoodWaste.Business.Models.Seller;
using FoodWaste.Business.Services;
using FoodWaste.Data;
using FoodWaste.Entities;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace FoodWaste.Tests.Services;

public class SellerServiceTests
{
    [Fact]
    public async Task UpdateProductAsync_DeactivateWithOpenOrders_ReturnsNull()
    {
        await using var dbContext = CreateContext();

        const int sellerUserId = 100;
        dbContext.Users.Add(new User
        {
            Id = sellerUserId,
            FullName = "Seller",
            Email = "seller@test.com",
            PasswordHash = "hash",
            Phone = "5550000000",
            Role = UserRole.Seller,
            IsApproved = true,
            IsActive = true
        });

        var restaurant = new Restaurant
        {
            OwnerUserId = sellerUserId,
            Name = "Seller Restaurant",
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
            Name = "Product",
            Description = "Desc",
            OriginalPrice = 100,
            DiscountedPrice = 70,
            Stock = 10,
            ExpiryDate = DateTime.UtcNow.AddDays(1),
            IsActive = true
        };
        dbContext.Products.Add(product);
        await dbContext.SaveChangesAsync();

        var order = new Order
        {
            UserId = sellerUserId,
            Status = OrderStatus.Pending,
            TotalAmount = 70
        };
        dbContext.Orders.Add(order);
        await dbContext.SaveChangesAsync();

        dbContext.OrderItems.Add(new OrderItem
        {
            OrderId = order.Id,
            ProductId = product.Id,
            Quantity = 1,
            UnitPrice = 70
        });
        await dbContext.SaveChangesAsync();

        var service = new SellerService(dbContext);

        var result = await service.UpdateProductAsync(
            sellerUserId,
            product.Id,
            new SellerProductUpdateModel("Food", "Product", "Desc", 100, 70, 10, DateTime.UtcNow.AddDays(1), false));

        Assert.Null(result);
    }

    private static FoodWasteDbContext CreateContext()
    {
        var options = new DbContextOptionsBuilder<FoodWasteDbContext>()
            .UseInMemoryDatabase($"FoodWasteTests-{Guid.NewGuid()}")
            .Options;

        return new FoodWasteDbContext(options);
    }
}

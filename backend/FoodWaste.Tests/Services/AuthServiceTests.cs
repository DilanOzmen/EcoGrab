using FoodWaste.Business.Services;
using FoodWaste.Data;
using FoodWaste.Entities;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace FoodWaste.Tests.Services;

public class AuthServiceTests
{
    [Fact]
    public async Task RegisterAsync_Seller_SetsIsApprovedFalse()
    {
        await using var dbContext = CreateContext();
        var service = new AuthService(dbContext);

        var result = await service.RegisterAsync("Seller User", "seller@example.com", "Abcd1234!", "5550001111", "Seller");

        Assert.True(result.IsSuccess);
        var createdUser = await dbContext.Users.FirstAsync(x => x.Email == "seller@example.com");
        Assert.Equal(UserRole.Seller, createdUser.Role);
        Assert.False(createdUser.IsApproved);
    }

    [Fact]
    public async Task RegisterAsync_AdminRole_ReturnsFailure()
    {
        await using var dbContext = CreateContext();
        var service = new AuthService(dbContext);

        var result = await service.RegisterAsync("Admin User", "admin@example.com", "Abcd1234!", "5550001111", "Admin");

        Assert.False(result.IsSuccess);
        Assert.Contains("Admin", result.ErrorMessage ?? string.Empty);
    }

    [Fact]
    public async Task LoginAsync_InactiveUser_ReturnsFailure()
    {
        await using var dbContext = CreateContext();
        dbContext.Users.Add(new User
        {
            FullName = "Inactive User",
            Email = "inactive@example.com",
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("Abcd1234!"),
            Phone = "5550001111",
            Role = UserRole.Customer,
            IsActive = false,
            IsApproved = true
        });
        await dbContext.SaveChangesAsync();

        var service = new AuthService(dbContext);
        var result = await service.LoginAsync("inactive@example.com", "Abcd1234!");

        Assert.False(result.IsSuccess);
        Assert.Contains("pasif", result.ErrorMessage ?? string.Empty, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public async Task LoginAsync_ValidCredentials_UpdatesLastLoginAt()
    {
        await using var dbContext = CreateContext();
        dbContext.Users.Add(new User
        {
            FullName = "Active User",
            Email = "active@example.com",
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("Abcd1234!"),
            Phone = "5550001111",
            Role = UserRole.Customer,
            IsActive = true,
            IsApproved = true
        });
        await dbContext.SaveChangesAsync();

        var service = new AuthService(dbContext);
        var result = await service.LoginAsync("active@example.com", "Abcd1234!");

        Assert.True(result.IsSuccess);
        var user = await dbContext.Users.FirstAsync(x => x.Email == "active@example.com");
        Assert.NotNull(user.LastLoginAt);
    }

    private static FoodWasteDbContext CreateContext()
    {
        var options = new DbContextOptionsBuilder<FoodWasteDbContext>()
            .UseInMemoryDatabase($"FoodWasteTests-{Guid.NewGuid()}")
            .Options;

        return new FoodWasteDbContext(options);
    }
}

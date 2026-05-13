using System.Security.Claims;
using FoodWaste.API.Common;
using FoodWaste.API.Contracts.Customer;
using FoodWaste.Business.Abstractions;
using FoodWaste.Business.Models.Customer;
using FoodWaste.Data;
using FoodWaste.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace FoodWaste.API.Controllers;

[ApiController]
[Authorize(Roles = IdentityRoles.Customer)]
[Route("api/customer")]
public class CustomerController(ICustomerService customerService, FoodWasteDbContext dbContext) : ControllerBase
{
    private const string DefaultProductImagePath = "/images/nevmekan-sicak-cikolata.jpg";

    [AllowAnonymous]
    [HttpGet("restaurants")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<IActionResult> GetRestaurants(
        [FromQuery] string? city,
        [FromQuery] string? search,
        [FromQuery] string? homeCategory,
        CancellationToken cancellationToken)
    {
        var restaurants = await customerService.GetRestaurantsAsync(city, search, homeCategory, cancellationToken);
        return Ok(restaurants);
    }

    [AllowAnonymous]
    [HttpGet("products")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<IActionResult> GetProducts(
        [FromQuery] string? search,
        [FromQuery] string? category,
        [FromQuery] string? homeCategory,
        [FromQuery] decimal? minPrice,
        [FromQuery] decimal? maxPrice,
        [FromQuery] decimal? minDiscountPercent,
        [FromQuery] double? latitude,
        [FromQuery] double? longitude,
        [FromQuery] double? radiusKm,
        CancellationToken cancellationToken)
    {
        var filter = new CustomerProductFilterModel(search, category, homeCategory, minPrice, maxPrice, minDiscountPercent, latitude, longitude, radiusKm);
        var products = await customerService.GetProductsAsync(filter, cancellationToken);
        return Ok(products);
    }

    [AllowAnonymous]
    [HttpGet("products/filter")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> GetFilteredProducts([FromQuery] string? category, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(category))
        {
            return BadRequest(new ApiErrorResponse("Kategori parametresi bos olamaz."));
        }

        var now = DateTime.UtcNow;
        var products = await dbContext.Products
            .AsNoTracking()
            .Where(p => p.Category == category && p.IsActive && p.ExpiryDate > now && !p.IsDeleted && p.Stock > 0 && p.DiscountedPrice < p.OriginalPrice)
            .OrderBy(p => p.ExpiryDate)
            .Select(p => new
            {
                p.Id,
                p.RestaurantId,
                Restaurant = p.Restaurant!.Name,
                p.Category,
                p.Name,
                p.Description,
                p.OriginalPrice,
                p.DiscountedPrice,
                DiscountPercent = p.OriginalPrice <= 0 ? 0 : Math.Round((p.OriginalPrice - p.DiscountedPrice) * 100 / p.OriginalPrice, 2),
                p.Stock,
                p.ExpiryDate,
                PrimaryImage = p.Images.Where(i => !i.IsDeleted).OrderByDescending(i => i.IsPrimary).Select(i => i.ImageUrl).FirstOrDefault() ?? DefaultProductImagePath
            })
            .ToListAsync(cancellationToken);

        return Ok(products);
    }

    [AllowAnonymous]
    [HttpGet("restaurants/{restaurantId:int}/products")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<IActionResult> GetRestaurantProducts(int restaurantId, CancellationToken cancellationToken)
    {
        if (restaurantId <= 0)
        {
            return BadRequest(new ApiErrorResponse("Gecersiz restoran."));
        }

        var products = await customerService.GetProductsByRestaurantAsync(restaurantId, cancellationToken);
        return Ok(products);
    }

    [AllowAnonymous]
    [HttpGet("products/{productId:int}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetProductDetail(int productId, CancellationToken cancellationToken)
    {
        if (productId <= 0)
        {
            return BadRequest(new ApiErrorResponse("Gecersiz urun."));
        }

        var product = await customerService.GetProductDetailAsync(productId, cancellationToken);
        return product is null
            ? NotFound(new ApiErrorResponse("Urun bulunamadi."))
            : Ok(product);
    }

    [AllowAnonymous]
    [HttpGet("restaurants/{restaurantId:int}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetRestaurantDetail(int restaurantId, CancellationToken cancellationToken)
    {
        if (restaurantId <= 0)
        {
            return BadRequest(new ApiErrorResponse("Gecersiz restoran."));
        }

        var restaurant = await customerService.GetRestaurantDetailAsync(restaurantId, cancellationToken);
        return restaurant is null
            ? NotFound(new ApiErrorResponse("Restoran bulunamadi."))
            : Ok(restaurant);
    }

    [AllowAnonymous]
    [HttpGet("restaurants/nearby")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> GetNearbyRestaurants(
        [FromQuery] double latitude,
        [FromQuery] double longitude,
        [FromQuery] double radiusKm = 5,
        CancellationToken cancellationToken = default)
    {
        if (radiusKm <= 0)
        {
            return BadRequest(new ApiErrorResponse("Yaricap 0'dan buyuk olmalidir."));
        }

        var restaurants = await customerService.GetNearbyRestaurantsAsync(latitude, longitude, radiusKm, cancellationToken);
        return Ok(restaurants);
    }

    [HttpPost("orders/reserve")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> Reserve([FromBody] ReserveRequest request, CancellationToken cancellationToken)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var order = await customerService.ReserveAsync(userId, request.ProductId, request.Quantity, cancellationToken);
        return order is null
            ? BadRequest(new ApiErrorResponse("Rezervasyon yapilamadi. Stok veya urun durumu uygun degil."))
            : Ok(order);
    }

    [HttpPost("orders/create")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> CreateOrder([FromBody] CreateOrderRequest request, CancellationToken cancellationToken)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var order = await customerService.CreateOrderAsync(userId, request.ProductId, request.Quantity, cancellationToken);
        return order is null
            ? BadRequest(new ApiErrorResponse("Siparis olusturulamadi. Stok veya urun durumu uygun degil."))
            : Ok(order);
    }

    [HttpPost("orders/{orderId:int}/cancel")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> CancelReservation(int orderId, CancellationToken cancellationToken)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var order = await customerService.CancelReservationAsync(userId, orderId, cancellationToken);
        return order is null
            ? NotFound(new ApiErrorResponse("Siparis bulunamadi veya iptal edilemedi."))
            : Ok(order);
    }

    [HttpGet("orders/my")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetMyOrders([FromQuery] bool onlyActive = false, CancellationToken cancellationToken = default)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var orders = await customerService.GetMyOrdersAsync(userId, onlyActive, cancellationToken);
        return Ok(orders);
    }

    [HttpGet("orders/{orderId:int}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetMyOrderDetail(int orderId, CancellationToken cancellationToken)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var order = await customerService.GetMyOrderDetailAsync(userId, orderId, cancellationToken);
        return order is null
            ? NotFound(new ApiErrorResponse("Siparis bulunamadi."))
            : Ok(order);
    }

    [HttpGet("reservations/my")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetMyReservations(CancellationToken cancellationToken = default)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized();
        }

        var reservations = await customerService.GetMyReservationsAsync(userId, cancellationToken);
        return Ok(reservations);
    }

    private bool TryGetUserId(out int userId)
    {
        userId = 0;
        var claim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        return int.TryParse(claim, out userId);
    }
}

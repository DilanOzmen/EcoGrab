using System.Security.Claims;
using FoodWaste.API.Common;
using FoodWaste.API.Contracts.Customer;
using FoodWaste.Business.Abstractions;
using FoodWaste.Business.Models.Customer;
using FoodWaste.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FoodWaste.API.Controllers;

[ApiController]
[Authorize(Roles = IdentityRoles.Customer)]
[Route("api/customer")]
public class CustomerController(ICustomerService customerService) : ControllerBase
{
    [AllowAnonymous]
    [HttpGet("products")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<IActionResult> GetProducts(
        [FromQuery] string? category,
        [FromQuery] decimal? minPrice,
        [FromQuery] decimal? maxPrice,
        [FromQuery] decimal? minDiscountPercent,
        CancellationToken cancellationToken)
    {
        var filter = new CustomerProductFilterModel(category, minPrice, maxPrice, minDiscountPercent);
        var products = await customerService.GetProductsAsync(filter, cancellationToken);
        return Ok(products);
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

    private bool TryGetUserId(out int userId)
    {
        userId = 0;
        var claim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        return int.TryParse(claim, out userId);
    }
}

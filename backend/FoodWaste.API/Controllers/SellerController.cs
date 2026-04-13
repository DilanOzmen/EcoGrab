using System.Security.Claims;
using FoodWaste.API.Common;
using FoodWaste.API.Contracts.Seller;
using FoodWaste.Business.Abstractions;
using FoodWaste.Business.Models.Seller;
using FoodWaste.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FoodWaste.API.Controllers;

[ApiController]
[Authorize(Roles = IdentityRoles.Seller)]
[Route("api/seller")]
public class SellerController(ISellerService sellerService) : ControllerBase
{
    [HttpGet("products")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetMyProducts(CancellationToken cancellationToken)
    {
        if (!TryGetUserId(out var sellerUserId))
        {
            return Unauthorized();
        }

        var products = await sellerService.GetMyProductsAsync(sellerUserId, cancellationToken);
        return Ok(products);
    }

    [HttpPost("products")]
    [ProducesResponseType(StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> CreateProduct([FromBody] CreateProductRequest request, CancellationToken cancellationToken)
    {
        if (!TryGetUserId(out var sellerUserId))
        {
            return Unauthorized();
        }

        if (request.RestaurantId <= 0 || string.IsNullOrWhiteSpace(request.Name) || request.Stock < 0)
        {
            return BadRequest(new ApiErrorResponse("Gecersiz urun istegi."));
        }

        var model = new SellerProductCreateModel(
            request.RestaurantId,
            request.Name,
            request.Description,
            request.OriginalPrice,
            request.DiscountedPrice,
            request.Stock,
            request.ExpiryDate,
            request.IsActive);

        var product = await sellerService.CreateProductAsync(sellerUserId, model, cancellationToken);
        if (product is null)
        {
            return BadRequest(new ApiErrorResponse("Bu restoranda urun ekleme yetkiniz yok."));
        }

        return CreatedAtAction(nameof(GetMyProducts), new { id = product.Id }, product);
    }

    [HttpPut("products/{productId:int}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UpdateProduct(int productId, [FromBody] UpdateProductRequest request, CancellationToken cancellationToken)
    {
        if (!TryGetUserId(out var sellerUserId))
        {
            return Unauthorized();
        }

        if (productId <= 0 || string.IsNullOrWhiteSpace(request.Name) || request.Stock < 0)
        {
            return BadRequest(new ApiErrorResponse("Gecersiz urun guncelleme istegi."));
        }

        var model = new SellerProductUpdateModel(
            request.Name,
            request.Description,
            request.OriginalPrice,
            request.DiscountedPrice,
            request.Stock,
            request.ExpiryDate,
            request.IsActive);

        var updated = await sellerService.UpdateProductAsync(sellerUserId, productId, model, cancellationToken);
        return updated is null
            ? NotFound(new ApiErrorResponse("Urun bulunamadi veya bu urunu guncelleme yetkiniz yok."))
            : Ok(updated);
    }

    [HttpDelete("products/{productId:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> DeleteProduct(int productId, CancellationToken cancellationToken)
    {
        if (!TryGetUserId(out var sellerUserId))
        {
            return Unauthorized();
        }

        var deleted = await sellerService.DeleteProductAsync(sellerUserId, productId, cancellationToken);
        return deleted
            ? NoContent()
            : NotFound(new ApiErrorResponse("Urun bulunamadi veya bu urunu silme yetkiniz yok."));
    }

    [HttpGet("orders/active")]
    [ProducesResponseType(typeof(IReadOnlyList<SellerActiveOrderDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetActiveOrders(CancellationToken cancellationToken)
    {
        if (!TryGetUserId(out var sellerUserId))
        {
            return Unauthorized();
        }

        var orders = await sellerService.GetActiveOrdersAsync(sellerUserId, cancellationToken);
        return Ok(orders);
    }

    private bool TryGetUserId(out int userId)
    {
        userId = 0;
        var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        return int.TryParse(userIdClaim, out userId);
    }
}

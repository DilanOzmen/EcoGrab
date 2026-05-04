using System.Security.Claims;
using FoodWaste.API.Common;
using FoodWaste.API.Contracts.Seller;
using FoodWaste.Business.Abstractions;
using FoodWaste.Business.Models.Seller;
using FoodWaste.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
using System.IO;
using System.Threading.Tasks;

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

        if (request.RestaurantId <= 0 || string.IsNullOrWhiteSpace(request.Category) || string.IsNullOrWhiteSpace(request.Name) || request.Stock < 0)
        {
            return BadRequest(new ApiErrorResponse("Gecersiz urun istegi."));
        }

        var model = new SellerProductCreateModel(
            request.RestaurantId,
            request.Category,
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

        if (productId <= 0 || string.IsNullOrWhiteSpace(request.Category) || string.IsNullOrWhiteSpace(request.Name) || request.Stock < 0)
        {
            return BadRequest(new ApiErrorResponse("Gecersiz urun guncelleme istegi."));
        }

        var model = new SellerProductUpdateModel(
            request.Category,
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

    [HttpGet("products/{productId:int}/images")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetProductImages(int productId, CancellationToken cancellationToken)
    {
        if (!TryGetUserId(out var sellerUserId))
        {
            return Unauthorized();
        }

        var images = await sellerService.GetProductImagesAsync(sellerUserId, productId, cancellationToken);
        return Ok(images);
    }

    [HttpPost("products/{productId:int}/images")]
    [ProducesResponseType(StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> AddProductImage(int productId, [FromBody] AddProductImageRequest request, CancellationToken cancellationToken)
    {
        if (!TryGetUserId(out var sellerUserId))
        {
            return Unauthorized();
        }

        if (productId <= 0 || string.IsNullOrWhiteSpace(request.ImageUrl) || string.IsNullOrWhiteSpace(request.StorageKey))
        {
            return BadRequest(new ApiErrorResponse("Gecersiz urun gorsel istegi."));
        }

        var image = await sellerService.AddProductImageAsync(
            sellerUserId,
            productId,
            request.ImageUrl,
            request.StorageKey,
            request.IsPrimary,
            cancellationToken);

        return image is null
            ? NotFound(new ApiErrorResponse("Urun bulunamadi veya bu urune gorsel ekleme yetkiniz yok."))
            : CreatedAtAction(nameof(GetProductImages), new { productId }, image);
    }

    [HttpDelete("products/{productId:int}/images/{imageId:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> DeleteProductImage(int productId, int imageId, CancellationToken cancellationToken)
    {
        if (!TryGetUserId(out var sellerUserId))
        {
            return Unauthorized();
        }

        var deleted = await sellerService.DeleteProductImageAsync(sellerUserId, productId, imageId, cancellationToken);
        return deleted
            ? NoContent()
            : NotFound(new ApiErrorResponse("Gorsel bulunamadi veya silme yetkiniz yok."));
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

    [HttpGet("orders")]
    [ProducesResponseType(typeof(IReadOnlyList<SellerActiveOrderDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetOrders([FromQuery] bool onlyActive = false, CancellationToken cancellationToken = default)
    {
        if (!TryGetUserId(out var sellerUserId))
        {
            return Unauthorized();
        }

        var orders = await sellerService.GetOrdersAsync(sellerUserId, onlyActive, cancellationToken);
        return Ok(orders);
    }

    [HttpGet("orders/{orderId:int}")]
    [ProducesResponseType(typeof(SellerActiveOrderDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetOrderDetail(int orderId, CancellationToken cancellationToken)
    {
        if (!TryGetUserId(out var sellerUserId))
        {
            return Unauthorized();
        }

        var order = await sellerService.GetOrderDetailAsync(sellerUserId, orderId, cancellationToken);
        return order is null
            ? NotFound(new ApiErrorResponse("Siparis bulunamadi."))
            : Ok(order);
    }

    [HttpPut("orders/{orderId:int}/status")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UpdateOrderStatus(int orderId, [FromBody] UpdateOrderStatusRequest request, CancellationToken cancellationToken)
    {
        if (!TryGetUserId(out var sellerUserId))
        {
            return Unauthorized();
        }

        if (orderId <= 0 || string.IsNullOrWhiteSpace(request.Status))
        {
            return BadRequest(new ApiErrorResponse("Gecersiz siparis durum guncelleme istegi."));
        }

        var updated = await sellerService.UpdateOrderStatusAsync(sellerUserId, orderId, request.Status, cancellationToken);
        return updated
            ? NoContent()
            : NotFound(new ApiErrorResponse("Siparis bulunamadi veya durum guncellenemedi."));
    }

    private bool TryGetUserId(out int userId)
    {
        userId = 0;
        var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        return int.TryParse(userIdClaim, out userId);
    }

    [HttpPost("upload-image")]
    public async Task<IActionResult> UploadProductImage(IFormFile file)
    {
        if (file == null || file.Length == 0)
            return BadRequest(new { message = "Dosya secilmedi." });

        if (!file.ContentType.StartsWith("image/", StringComparison.OrdinalIgnoreCase))
            return BadRequest(new { message = "Sadece resim dosyalari yuklenebilir." });

        // 1. Resimlerin kaydedileceği klasör yolu
        var uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads");

        // 2. Klasör yoksa oluştur
        if (!Directory.Exists(uploadsFolder))
            Directory.CreateDirectory(uploadsFolder);

        // 3. Dosya adını benzersiz yap (Aynı isimli resimler karışmasın)
        var fileName = $"{Guid.NewGuid()}{Path.GetExtension(file.FileName)}";
        var filePath = Path.Combine(uploadsFolder, fileName);

        // 4. Dosyayı fiziksel olarak kaydet
        using (var stream = new FileStream(filePath, FileMode.Create))
        {
            await file.CopyToAsync(stream);
        }

        var relativePath = $"/uploads/{fileName}";
        var absoluteUrl = $"{Request.Scheme}://{Request.Host}{relativePath}";

        return Ok(new
        {
            imageUrl = absoluteUrl,
            storageKey = fileName
        });
    }
}

using FoodWaste.Business.Models.Seller;

namespace FoodWaste.Business.Abstractions;

public interface ISellerService
{
    Task<IReadOnlyList<SellerProductDto>> GetMyProductsAsync(int sellerUserId, CancellationToken cancellationToken = default);
    Task<SellerProductDto?> CreateProductAsync(int sellerUserId, SellerProductCreateModel model, CancellationToken cancellationToken = default);
    Task<SellerProductDto?> UpdateProductAsync(int sellerUserId, int productId, SellerProductUpdateModel model, CancellationToken cancellationToken = default);
    Task<bool> DeleteProductAsync(int sellerUserId, int productId, CancellationToken cancellationToken = default);
    Task<SellerProductImageDto?> AddProductImageAsync(int sellerUserId, int productId, string imageUrl, string storageKey, bool isPrimary, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<SellerProductImageDto>> GetProductImagesAsync(int sellerUserId, int productId, CancellationToken cancellationToken = default);
    Task<bool> DeleteProductImageAsync(int sellerUserId, int productId, int imageId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<SellerActiveOrderDto>> GetActiveOrdersAsync(int sellerUserId, CancellationToken cancellationToken = default);
    Task<bool> UpdateOrderStatusAsync(int sellerUserId, int orderId, string status, CancellationToken cancellationToken = default);
}

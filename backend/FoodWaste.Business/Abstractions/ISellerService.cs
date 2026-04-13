using FoodWaste.Business.Models.Seller;

namespace FoodWaste.Business.Abstractions;

public interface ISellerService
{
    Task<IReadOnlyList<SellerProductDto>> GetMyProductsAsync(int sellerUserId, CancellationToken cancellationToken = default);
    Task<SellerProductDto?> CreateProductAsync(int sellerUserId, SellerProductCreateModel model, CancellationToken cancellationToken = default);
    Task<SellerProductDto?> UpdateProductAsync(int sellerUserId, int productId, SellerProductUpdateModel model, CancellationToken cancellationToken = default);
    Task<bool> DeleteProductAsync(int sellerUserId, int productId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<SellerActiveOrderDto>> GetActiveOrdersAsync(int sellerUserId, CancellationToken cancellationToken = default);
}

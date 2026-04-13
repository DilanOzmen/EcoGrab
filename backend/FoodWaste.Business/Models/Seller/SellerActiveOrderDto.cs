namespace FoodWaste.Business.Models.Seller;

public sealed record SellerActiveOrderDto(
    int OrderId,
    int CustomerId,
    string CustomerName,
    DateTime CreatedAt,
    string Status,
    decimal TotalAmount,
    IReadOnlyList<SellerActiveOrderItemDto> Items);

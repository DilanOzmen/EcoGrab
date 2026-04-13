namespace FoodWaste.Business.Models.Seller;

public sealed record SellerActiveOrderItemDto(
    int ProductId,
    string ProductName,
    int Quantity,
    decimal UnitPrice);

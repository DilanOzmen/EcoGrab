namespace FoodWaste.Business.Models.Customer;

public sealed record CustomerOrderItemDto(
    int ProductId,
    string ProductName,
    int Quantity,
    decimal UnitPrice);

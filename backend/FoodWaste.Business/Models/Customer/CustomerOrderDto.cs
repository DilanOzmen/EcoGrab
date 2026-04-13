namespace FoodWaste.Business.Models.Customer;

public sealed record CustomerOrderDto(
    int Id,
    DateTime CreatedAt,
    string Status,
    decimal TotalAmount,
    IReadOnlyList<CustomerOrderItemDto> Items);

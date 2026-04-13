namespace FoodWaste.API.Contracts.Customer;

public sealed record CreateOrderRequest(int ProductId, int Quantity);

namespace FoodWaste.Business.Models.Admin;

public sealed record AdminDashboardDto(
    int TotalUsers,
    int ActiveUsers,
    int TotalOrders,
    decimal CompletedSalesTotal);

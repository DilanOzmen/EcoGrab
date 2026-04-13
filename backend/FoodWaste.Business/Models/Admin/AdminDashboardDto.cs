namespace FoodWaste.Business.Models.Admin;

public sealed record AdminDashboardDto(
    int TotalUsers,
    int ActiveUsers,
    int ActiveSellers,
    int TotalOrders,
    int ActiveProducts,
    decimal CompletedSalesTotal);

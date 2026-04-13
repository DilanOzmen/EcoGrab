using FoodWaste.API.Common;
using FoodWaste.API.Contracts.Admin;
using FoodWaste.Business.Abstractions;
using FoodWaste.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace FoodWaste.API.Controllers;

[ApiController]
[Authorize(Roles = IdentityRoles.Admin)]
[Route("api/admin")]
public class AdminController(IAdminService adminService) : ControllerBase
{
    [HttpGet("sellers/pending")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<IActionResult> GetPendingSellers(CancellationToken cancellationToken)
    {
        var pendingSellers = await adminService.GetPendingSellersAsync(cancellationToken);
        return Ok(pendingSellers);
    }

    [HttpPut("sellers/{userId:int}/approval")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> SetSellerApproval(int userId, [FromBody] SellerApprovalRequest request, CancellationToken cancellationToken)
    {
        var adminUserId = TryGetAdminUserId();
        var updated = await adminService.SetSellerApprovalAsync(userId, request.IsApproved, adminUserId, cancellationToken);
        return updated
            ? NoContent()
            : NotFound(new ApiErrorResponse("Satici bulunamadi."));
    }

    [HttpPut("users/{userId:int}/active")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> SetUserActive(int userId, [FromBody] UserActiveRequest request, CancellationToken cancellationToken)
    {
        var adminUserId = TryGetAdminUserId();
        var updated = await adminService.SetUserActiveAsync(userId, request.IsActive, adminUserId, cancellationToken);
        return updated
            ? NoContent()
            : NotFound(new ApiErrorResponse("Kullanici bulunamadi."));
    }

    [HttpPut("products/{productId:int}/active")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> SetProductActive(int productId, [FromBody] ProductActiveRequest request, CancellationToken cancellationToken)
    {
        var adminUserId = TryGetAdminUserId();
        var updated = await adminService.SetProductActiveAsync(productId, request.IsActive, adminUserId, cancellationToken);
        return updated
            ? NoContent()
            : NotFound(new ApiErrorResponse("Urun bulunamadi."));
    }

    [HttpGet("dashboard")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<IActionResult> GetDashboard(CancellationToken cancellationToken)
    {
        var metrics = await adminService.GetDashboardMetricsAsync(cancellationToken);
        return Ok(metrics);
    }

    private int? TryGetAdminUserId()
    {
        var idClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        return int.TryParse(idClaim, out var adminUserId) ? adminUserId : null;
    }
}

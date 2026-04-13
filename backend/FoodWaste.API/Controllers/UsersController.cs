using System.Security.Claims;
using FoodWaste.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace FoodWaste.API.Controllers;

[ApiController]
[Authorize]
[Route("api/[controller]")]
public class UsersController(FoodWasteDbContext dbContext) : ControllerBase
{
    [HttpGet("me")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> Me(CancellationToken cancellationToken)
    {
        var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }

        var user = await dbContext.Users
            .AsNoTracking()
            .Where(x => x.Id == userId)
            .Select(x => new
            {
                x.Id,
                x.FullName,
                x.Email,
                x.Phone,
                Role = x.Role.ToString(),
                x.CreatedAt
            })
            .FirstOrDefaultAsync(cancellationToken);

        return user is null ? Unauthorized() : Ok(user);
    }
}

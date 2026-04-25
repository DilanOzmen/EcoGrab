using FoodWaste.API.Contracts.Auth;
using FoodWaste.API.Common;
using FoodWaste.API.Services;
using FoodWaste.Business.Abstractions;
using FoodWaste.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace FoodWaste.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController(
    IAuthService authService,
    IAuthValidationService authValidationService,
    IJwtTokenService jwtTokenService,
    IRefreshTokenService refreshTokenService,
    FoodWasteDbContext dbContext) : ControllerBase
{
    [HttpPost("register")]
    [ProducesResponseType(typeof(AuthResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Register([FromBody] RegisterRequest request, CancellationToken cancellationToken)
    {
        var errors = authValidationService.ValidateRegister(request.FullName, request.Email, request.Password, request.Role);
        if (errors.Count > 0)
        {
            return BadRequest(new ApiErrorResponse("Gecersiz kayit istegi.", errors));
        }

        var result = await authService.RegisterAsync(
            request.FullName,
            request.Email,
            request.Password,
            request.Phone,
            request.Role,
            cancellationToken);

        if (!result.IsSuccess)
        {
            return BadRequest(new ApiErrorResponse(result.ErrorMessage ?? "Kayit basarisiz."));
        }

        var token = jwtTokenService.GenerateToken(result.UserId, result.FullName, result.Email, result.Role);
        var refreshToken = await refreshTokenService.IssueAsync(
            result.UserId,
            Request.Headers.UserAgent.ToString(),
            HttpContext.Connection.RemoteIpAddress?.ToString() ?? string.Empty,
            cancellationToken);

        return Ok(new AuthResponse(result.UserId, result.FullName, result.Email, result.Role, token, refreshToken));
    }

    [HttpPost("login")]
    [ProducesResponseType(typeof(AuthResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Login([FromBody] LoginRequest request, CancellationToken cancellationToken)
    {
        var errors = authValidationService.ValidateLogin(request.Email, request.Password);
        if (errors.Count > 0)
        {
            return BadRequest(new ApiErrorResponse("Gecersiz giris istegi.", errors));
        }

        var result = await authService.LoginAsync(request.Email, request.Password, cancellationToken);

        if (!result.IsSuccess)
        {
            return BadRequest(new ApiErrorResponse(result.ErrorMessage ?? "Giris basarisiz."));
        }

        var token = jwtTokenService.GenerateToken(result.UserId, result.FullName, result.Email, result.Role);
        var refreshToken = await refreshTokenService.IssueAsync(
            result.UserId,
            Request.Headers.UserAgent.ToString(),
            HttpContext.Connection.RemoteIpAddress?.ToString() ?? string.Empty,
            cancellationToken);

        return Ok(new AuthResponse(result.UserId, result.FullName, result.Email, result.Role, token, refreshToken));
    }

    [HttpPost("refresh")]
    [ProducesResponseType(typeof(AuthResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Refresh([FromBody] RefreshTokenRequest request, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(request.RefreshToken))
        {
            return BadRequest(new ApiErrorResponse("Refresh token zorunludur."));
        }

        var tokenEntity = await refreshTokenService.GetValidTokenAsync(request.RefreshToken, cancellationToken);
        if (tokenEntity is null)
        {
            return BadRequest(new ApiErrorResponse("Gecersiz veya suresi dolmus refresh token."));
        }

        var user = await dbContext.Users
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == tokenEntity.UserId, cancellationToken);

        if (user is null || !user.IsActive || (user.Role == Entities.UserRole.Seller && !user.IsApproved))
        {
            return BadRequest(new ApiErrorResponse("Kullanici durumu token yenileme icin uygun degil."));
        }

        await refreshTokenService.RevokeAsync(request.RefreshToken, cancellationToken);
        var newRefreshToken = await refreshTokenService.IssueAsync(
            user.Id,
            Request.Headers.UserAgent.ToString(),
            HttpContext.Connection.RemoteIpAddress?.ToString() ?? string.Empty,
            cancellationToken);

        var jwt = jwtTokenService.GenerateToken(user.Id, user.FullName, user.Email, user.Role.ToString());
        return Ok(new AuthResponse(user.Id, user.FullName, user.Email, user.Role.ToString(), jwt, newRefreshToken));
    }

    [HttpPost("logout")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> Logout([FromBody] LogoutRequest request, CancellationToken cancellationToken)
    {
        if (!string.IsNullOrWhiteSpace(request.RefreshToken))
        {
            await refreshTokenService.RevokeAsync(request.RefreshToken, cancellationToken);
        }

        return NoContent();
    }
}

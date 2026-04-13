using FoodWaste.API.Contracts.Auth;
using FoodWaste.API.Common;
using FoodWaste.API.Services;
using FoodWaste.Business.Abstractions;
using Microsoft.AspNetCore.Mvc;

namespace FoodWaste.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController(
    IAuthService authService,
    IAuthValidationService authValidationService,
    IJwtTokenService jwtTokenService) : ControllerBase
{
    [HttpPost("register")]
    [ProducesResponseType(typeof(AuthResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Register([FromBody] RegisterRequest request, CancellationToken cancellationToken)
    {
        var errors = authValidationService.ValidateRegister(request.FullName, request.Email, request.Password);
        if (errors.Count > 0)
        {
            return BadRequest(new ApiErrorResponse("Gecersiz kayit istegi.", errors));
        }

        var result = await authService.RegisterAsync(
            request.FullName,
            request.Email,
            request.Password,
            request.Phone,
            cancellationToken);

        if (!result.IsSuccess)
        {
            return BadRequest(new ApiErrorResponse(result.ErrorMessage ?? "Kayit basarisiz."));
        }

        var token = jwtTokenService.GenerateToken(result.UserId, result.FullName, result.Email, result.Role);
        return Ok(new AuthResponse(result.UserId, result.FullName, result.Email, result.Role, token));
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
        return Ok(new AuthResponse(result.UserId, result.FullName, result.Email, result.Role, token));
    }
}

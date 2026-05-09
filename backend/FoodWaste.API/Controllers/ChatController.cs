using FoodWaste.Business.Abstractions;
using FoodWaste.Business.Models.Chat;
using Microsoft.AspNetCore.Mvc;

namespace FoodWaste.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ChatController(IChatService chatService) : ControllerBase
{
    [HttpPost("ask")]
    public async Task<IActionResult> Ask([FromBody] ChatRequestModel request)
    {
        var response = await chatService.GetAiResponseAsync(request);
        return Ok(response);
    }
}

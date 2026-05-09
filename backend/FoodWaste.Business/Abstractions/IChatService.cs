using FoodWaste.Business.Models.Chat;

namespace FoodWaste.Business.Abstractions;

public interface IChatService
{
    Task<ChatResponseModel> GetAiResponseAsync(ChatRequestModel request);
}
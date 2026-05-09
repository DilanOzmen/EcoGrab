using System.Text;
using System.Text.Json;
using FoodWaste.Business.Models.Chat;
using FoodWaste.Business.Models.Customer;
using FoodWaste.Business.Abstractions;
using Microsoft.Extensions.Configuration;

namespace FoodWaste.Business.Services;

public class ChatService(IConfiguration config, ICustomerService customerService) : IChatService
{
    private readonly string _apiKey = config["GeminiConfig:ApiKey"] ?? "";
    private readonly HttpClient _httpClient = new();

    public async Task<ChatResponseModel> GetAiResponseAsync(ChatRequestModel request)
    {
        try
        {
            // 1. Yakındaki Ürünleri Çekiyoruz
            var nearbyProducts = await customerService.GetProductsAsync(new CustomerProductFilterModel(
                null, null, null, null, null, null, request.Latitude, request.Longitude, request.RadiusKm
            ));

            // 2. AI için Context Oluşturuyoruz
            var context = new StringBuilder("Sen EcoGrab asistanısın. Yakındaki güncel fırsatlar:\n");
            foreach (var p in nearbyProducts.Take(5))
            {
                context.AppendLine($"- {p.RestaurantName}: {p.Name} ({p.DiscountedPrice} TL)");
            }

            string promptText = $"{context}\nKullanıcı Mesajı: {request.UserMessage}\nLütfen çok samimi ve yardımsever bir dille cevap ver.";

            // 3. Google API İstek Formatı (En Güncel Yapı)
            var requestBody = new
            {
                contents = new[] 
                { 
                    new 
                    { 
                        role = "user", 
                        parts = new[] { new { text = promptText } } 
                    } 
                }
            };

            var jsonRequest = JsonSerializer.Serialize(requestBody);
            var content = new StringContent(jsonRequest, Encoding.UTF8, "application/json");

            // KRİTİK NOKTA: Gemini-3-Flash-Preview için v1alpha ve doğru model ismi
            var response = await _httpClient.PostAsync(
                $"https://generativelanguage.googleapis.com/v1alpha/models/gemini-3-flash-preview:generateContent?key={_apiKey}", 
                content);

            var jsonResponse = await response.Content.ReadAsStringAsync();
            
            if (!response.IsSuccessStatusCode)
            {
                return new ChatResponseModel($"Bağlantı Sorunu ({response.StatusCode}): {jsonResponse}");
            }

            // 4. Yanıtı Güvenli Şekilde Ayıklıyoruz
            using var doc = JsonDocument.Parse(jsonResponse);
            
            if (doc.RootElement.TryGetProperty("candidates", out var candidates) && candidates.GetArrayLength() > 0)
            {
                var firstCandidate = candidates[0];
                if (firstCandidate.TryGetProperty("content", out var contentNode) &&
                    contentNode.TryGetProperty("parts", out var parts) && parts.GetArrayLength() > 0)
                {
                    var aiText = parts[0].GetProperty("text").GetString();
                    return new ChatResponseModel(aiText ?? "Mesaj içeriği boş.");
                }
            }

            return new ChatResponseModel("API'den beklenmedik bir yanıt formatı geldi.");
        }
        catch (Exception ex)
        {
            return new ChatResponseModel($"Sistem Hatası: {ex.Message}");
        }
    }
}
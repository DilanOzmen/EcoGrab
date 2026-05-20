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
            var hasLocation = request.Latitude.HasValue && request.Longitude.HasValue;
            var effectiveRadius = request.RadiusKm > 0 ? request.RadiusKm : 5;

            // 1. Yakındaki ürünleri çekiyoruz.
            var nearbyProducts = await customerService.GetProductsAsync(new CustomerProductFilterModel(
                null, null, null, null, null, null, request.Latitude, request.Longitude, effectiveRadius
            ));

            // 2. Yakındaki restoranları çekiyoruz (konum verilmişse).
            var nearbyRestaurants = hasLocation
                ? await customerService.GetNearbyRestaurantsAsync(
                    request.Latitude!.Value,
                    request.Longitude!.Value,
                    effectiveRadius)
                : Array.Empty<NearbyRestaurantDto>();

            // 3. AI için zengin konum context'i oluşturuyoruz.
            var context = new StringBuilder();
            context.AppendLine("Sen EcoGrab asistanısın.");
            context.AppendLine("Gorevin, kullaniciya yakinindaki restoranlardan urun onermektir.");

            if (hasLocation)
            {
                context.AppendLine($"Kullanici konumu: {request.Latitude:0.000000}, {request.Longitude:0.000000}");
                context.AppendLine($"Arama yaricapi: {effectiveRadius:0.#} km");
            }

            if (nearbyRestaurants.Count > 0)
            {
                context.AppendLine("Yakin restoranlar:");
                foreach (var restaurant in nearbyRestaurants.Take(5))
                {
                    context.AppendLine($"- {restaurant.Name} ({restaurant.City}) - {restaurant.DistanceKm:0.0} km");
                }
            }
            else
            {
                context.AppendLine("Yakin restoran bilgisi bulunamadi.");
            }

            if (nearbyProducts.Count > 0)
            {
                context.AppendLine("Yakin urun firsatlari:");
                foreach (var p in nearbyProducts.Take(8))
                {
                    context.AppendLine($"- {p.RestaurantName}: {p.Name} ({p.DiscountedPrice:0.##} TL)");
                }
            }
            else
            {
                context.AppendLine("Yakin urun bulunamadi.");
            }

            string promptText = $"{context}\nKullanici mesaji: {request.UserMessage}\nYanitta en az 1 yakin restoran ve 1 urun oner. Mesafe veya yakinlik bilgisini belirt. Samimi ve kisa cevap ver.";

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
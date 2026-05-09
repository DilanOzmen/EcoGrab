namespace FoodWaste.Business.Models.Chat;

public record ChatRequestModel(
    string UserMessage,    // Kullanıcının chatbot'a yazdığı yazı
    double? Latitude,      // Mevcut konum enlemi
    double? Longitude,     // Mevcut konum boylamı
    double RadiusKm = 5    // Arama çapı
);

public record ChatResponseModel(
    string AiResponse      // Gemini'dan gelen cevap
);

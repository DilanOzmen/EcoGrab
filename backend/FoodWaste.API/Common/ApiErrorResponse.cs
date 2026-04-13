namespace FoodWaste.API.Common;

public sealed record ApiErrorResponse(string Message, IReadOnlyList<string>? Errors = null);

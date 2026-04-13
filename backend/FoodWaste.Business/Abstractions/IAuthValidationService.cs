namespace FoodWaste.Business.Abstractions;

public interface IAuthValidationService
{
    IReadOnlyList<string> ValidateRegister(string fullName, string email, string password);
    IReadOnlyList<string> ValidateLogin(string email, string password);
}

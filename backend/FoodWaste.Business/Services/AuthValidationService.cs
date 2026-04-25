using System.Net.Mail;
using System.Text.RegularExpressions;
using FoodWaste.Business.Abstractions;

namespace FoodWaste.Business.Services;

public class AuthValidationService : IAuthValidationService
{
    private static readonly Regex PasswordRegex = new(
        "^.{6,}$",
        RegexOptions.Compiled);

    public IReadOnlyList<string> ValidateRegister(string fullName, string email, string password, string role)
    {
        var errors = new List<string>();

        if (string.IsNullOrWhiteSpace(fullName))
        {
            errors.Add("Ad soyad zorunludur.");
        }

        if (!IsValidEmail(email))
        {
            errors.Add("Gecerli bir e-posta giriniz.");
        }

        if (!IsStrongPassword(password))
        {
            errors.Add("Sifre en az 6 karakter olmalidir.");
        }

        if (!IsValidRegisterRole(role))
        {
            errors.Add("Rol sadece Customer veya Seller olabilir.");
        }

        return errors;
    }

    public IReadOnlyList<string> ValidateLogin(string email, string password)
    {
        var errors = new List<string>();

        if (!IsValidEmail(email))
        {
            errors.Add("Gecerli bir e-posta giriniz.");
        }

        if (string.IsNullOrWhiteSpace(password))
        {
            errors.Add("Sifre zorunludur.");
        }

        return errors;
    }

    private static bool IsValidEmail(string email)
    {
        if (string.IsNullOrWhiteSpace(email))
        {
            return false;
        }

        try
        {
            _ = new MailAddress(email);
            return true;
        }
        catch
        {
            return false;
        }
    }

    private static bool IsStrongPassword(string password)
    {
        if (string.IsNullOrWhiteSpace(password))
        {
            return false;
        }

        return PasswordRegex.IsMatch(password);
    }

    private static bool IsValidRegisterRole(string role)
    {
        if (string.IsNullOrWhiteSpace(role))
        {
            return false;
        }

        return role.Equals("Customer", StringComparison.OrdinalIgnoreCase)
             || role.Equals("Seller", StringComparison.OrdinalIgnoreCase);
    }
}

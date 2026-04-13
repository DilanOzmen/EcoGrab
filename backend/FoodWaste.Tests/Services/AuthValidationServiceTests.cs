using FoodWaste.Business.Services;
using Xunit;

namespace FoodWaste.Tests.Services;

public class AuthValidationServiceTests
{
    private readonly AuthValidationService _service = new();

    [Fact]
    public void ValidateRegister_ValidCustomer_ReturnsNoErrors()
    {
        var errors = _service.ValidateRegister("Test User", "test@example.com", "Abcd1234!", "Customer");

        Assert.Empty(errors);
    }

    [Fact]
    public void ValidateRegister_InvalidRole_ReturnsRoleError()
    {
        var errors = _service.ValidateRegister("Test User", "test@example.com", "Abcd1234!", "Manager");

        Assert.Contains(errors, e => e.Contains("Rol"));
    }

    [Fact]
    public void ValidateLogin_InvalidEmailAndEmptyPassword_ReturnsTwoErrors()
    {
        var errors = _service.ValidateLogin("wrong-mail", "");

        Assert.Equal(2, errors.Count);
    }
}

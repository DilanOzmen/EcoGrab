namespace FoodWaste.Entities;

public class User : BaseEntity
{
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public string Phone { get; set; } = string.Empty;
    public UserRole Role { get; set; } = UserRole.Customer;
    public bool IsActive { get; set; } = true;
    public bool IsApproved { get; set; } = true;
    public bool EmailVerified { get; set; }
    public DateTime? EmailVerifiedAt { get; set; }
    public bool PhoneVerified { get; set; }
    public DateTime? LastLoginAt { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public ICollection<Order> Orders { get; set; } = new List<Order>();
    public ICollection<Restaurant> OwnedRestaurants { get; set; } = new List<Restaurant>();
    public ICollection<RefreshToken> RefreshTokens { get; set; } = new List<RefreshToken>();
    public ICollection<AdminActionLog> AdminActionLogs { get; set; } = new List<AdminActionLog>();
}

namespace FoodWaste.Entities;

public class AdminActionLog : BaseEntity
{
    public int? AdminUserId { get; set; }
    public string ActionType { get; set; } = string.Empty;
    public string TargetType { get; set; } = string.Empty;
    public int TargetId { get; set; }
    public string Reason { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public User? AdminUser { get; set; }
}

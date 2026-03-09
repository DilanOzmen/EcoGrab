namespace FoodWaste.Entities;

public class Product : BaseEntity
{
    public int RestaurantId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal OriginalPrice { get; set; }
    public decimal DiscountedPrice { get; set; }
    public int Stock { get; set; }
    public DateTime ExpiryDate { get; set; }
    public bool IsActive { get; set; } = true;

    public Restaurant? Restaurant { get; set; }
    public ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();
}

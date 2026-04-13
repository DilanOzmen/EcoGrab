namespace FoodWaste.Entities;

public class Product : BaseEntity
{
    public int RestaurantId { get; set; }
    public string Category { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal OriginalPrice { get; set; }
    public decimal DiscountedPrice { get; set; }
    public int Stock { get; set; }
    public DateTime ExpiryDate { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public bool IsActive { get; set; } = true;
    public byte[] RowVersion { get; set; } = Array.Empty<byte>();

    public Restaurant? Restaurant { get; set; }
    public ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();
    public ICollection<ProductImage> Images { get; set; } = new List<ProductImage>();
}

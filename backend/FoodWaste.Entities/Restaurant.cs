namespace FoodWaste.Entities;

public class Restaurant : BaseEntity
{
    public int? OwnerUserId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Address { get; set; } = string.Empty;
    public string City { get; set; } = string.Empty;
    public string Phone { get; set; } = string.Empty;
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public User? OwnerUser { get; set; }
    public ICollection<Product> Products { get; set; } = new List<Product>();
}

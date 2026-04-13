using FoodWaste.Entities;
using Microsoft.EntityFrameworkCore;

namespace FoodWaste.Data;

public class FoodWasteDbContext(DbContextOptions<FoodWasteDbContext> options) : DbContext(options)
{
	public DbSet<User> Users => Set<User>();
	public DbSet<Restaurant> Restaurants => Set<Restaurant>();
	public DbSet<Product> Products => Set<Product>();
	public DbSet<Order> Orders => Set<Order>();
	public DbSet<OrderItem> OrderItems => Set<OrderItem>();

	protected override void OnModelCreating(ModelBuilder modelBuilder)
	{
		modelBuilder.Entity<User>(entity =>
		{
			entity.Property(x => x.FullName).HasMaxLength(120).IsRequired();
			entity.Property(x => x.Email).HasMaxLength(150).IsRequired();
			entity.Property(x => x.Phone).HasMaxLength(20);
			entity.Property(x => x.Role).HasConversion<string>().HasMaxLength(20).IsRequired();
			entity.HasIndex(x => x.Email).IsUnique();
		});

		modelBuilder.Entity<Restaurant>(entity =>
		{
			entity.Property(x => x.Name).HasMaxLength(120).IsRequired();
			entity.Property(x => x.City).HasMaxLength(80).IsRequired();

			entity
				.HasOne(x => x.OwnerUser)
				.WithMany(x => x.OwnedRestaurants)
				.HasForeignKey(x => x.OwnerUserId)
				.OnDelete(DeleteBehavior.Restrict);
		});

		modelBuilder.Entity<Product>(entity =>
		{
			entity.Property(x => x.Name).HasMaxLength(120).IsRequired();
			entity.Property(x => x.OriginalPrice).HasColumnType("decimal(18,2)");
			entity.Property(x => x.DiscountedPrice).HasColumnType("decimal(18,2)");

			entity
				.HasOne(x => x.Restaurant)
				.WithMany(x => x.Products)
				.HasForeignKey(x => x.RestaurantId)
				.OnDelete(DeleteBehavior.Cascade);
		});

		modelBuilder.Entity<Order>(entity =>
		{
			entity.Property(x => x.TotalAmount).HasColumnType("decimal(18,2)");
			entity
				.HasOne(x => x.User)
				.WithMany(x => x.Orders)
				.HasForeignKey(x => x.UserId)
				.OnDelete(DeleteBehavior.Restrict);
		});

		modelBuilder.Entity<OrderItem>(entity =>
		{
			entity.Property(x => x.UnitPrice).HasColumnType("decimal(18,2)");
			entity
				.HasOne(x => x.Order)
				.WithMany(x => x.Items)
				.HasForeignKey(x => x.OrderId)
				.OnDelete(DeleteBehavior.Cascade);

			entity
				.HasOne(x => x.Product)
				.WithMany(x => x.OrderItems)
				.HasForeignKey(x => x.ProductId)
				.OnDelete(DeleteBehavior.Restrict);
		});
	}
}

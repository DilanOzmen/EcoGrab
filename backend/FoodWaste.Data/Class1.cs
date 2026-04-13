using FoodWaste.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.ChangeTracking;
using System.Linq.Expressions;

namespace FoodWaste.Data;

public class FoodWasteDbContext(DbContextOptions<FoodWasteDbContext> options) : DbContext(options)
{
	public DbSet<User> Users => Set<User>();
	public DbSet<Restaurant> Restaurants => Set<Restaurant>();
	public DbSet<Product> Products => Set<Product>();
	public DbSet<Order> Orders => Set<Order>();
	public DbSet<OrderItem> OrderItems => Set<OrderItem>();
	public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();
	public DbSet<ProductImage> ProductImages => Set<ProductImage>();
	public DbSet<AdminActionLog> AdminActionLogs => Set<AdminActionLog>();
	public DbSet<Notification> Notifications => Set<Notification>();

	protected override void OnModelCreating(ModelBuilder modelBuilder)
	{
		modelBuilder.Entity<User>(entity =>
		{
			entity.Property(x => x.FullName).HasMaxLength(120).IsRequired();
			entity.Property(x => x.Email).HasMaxLength(150).IsRequired();
			entity.Property(x => x.Phone).HasMaxLength(20);
			entity.Property(x => x.Role).HasConversion<string>().HasMaxLength(20).IsRequired();
			entity.Property(x => x.UpdatedAt).HasColumnType("datetime2");
			entity.Property(x => x.DeletedAt).HasColumnType("datetime2");
			entity.Property(x => x.IsDeleted).HasDefaultValue(false);
			entity.Property(x => x.IsActive).HasDefaultValue(true);
			entity.Property(x => x.IsApproved).HasDefaultValue(true);
			entity.Property(x => x.EmailVerified).HasDefaultValue(false);
			entity.Property(x => x.PhoneVerified).HasDefaultValue(false);
			entity.Property(x => x.LastLoginAt).HasColumnType("datetime2");
			entity.HasIndex(x => x.Email).IsUnique();
			entity.HasIndex(x => new { x.Role, x.IsApproved, x.IsActive });
		});

		modelBuilder.Entity<Restaurant>(entity =>
		{
			entity.Property(x => x.Name).HasMaxLength(120).IsRequired();
			entity.Property(x => x.City).HasMaxLength(80).IsRequired();
			entity.Property(x => x.Latitude).HasColumnType("float");
			entity.Property(x => x.Longitude).HasColumnType("float");
			entity.Property(x => x.UpdatedAt).HasColumnType("datetime2");
			entity.Property(x => x.DeletedAt).HasColumnType("datetime2");
			entity.Property(x => x.IsDeleted).HasDefaultValue(false);
			entity.HasIndex(x => new { x.Latitude, x.Longitude });

			entity
				.HasOne(x => x.OwnerUser)
				.WithMany(x => x.OwnedRestaurants)
				.HasForeignKey(x => x.OwnerUserId)
				.OnDelete(DeleteBehavior.Restrict);
		});

		modelBuilder.Entity<Product>(entity =>
		{
			entity.Property(x => x.Category).HasMaxLength(60).IsRequired();
			entity.Property(x => x.Name).HasMaxLength(120).IsRequired();
			entity.Property(x => x.OriginalPrice).HasColumnType("decimal(18,2)");
			entity.Property(x => x.DiscountedPrice).HasColumnType("decimal(18,2)");
			entity.Property(x => x.CreatedAt).HasColumnType("datetime2");
			entity.Property(x => x.UpdatedAt).HasColumnType("datetime2");
			entity.Property(x => x.DeletedAt).HasColumnType("datetime2");
			entity.Property(x => x.IsDeleted).HasDefaultValue(false);
			entity.Property(x => x.RowVersion).IsRowVersion();
			entity.HasIndex(x => new { x.RestaurantId, x.IsActive, x.ExpiryDate });
			entity.HasIndex(x => new { x.Category, x.DiscountedPrice });
			entity.ToTable(t =>
			{
				t.HasCheckConstraint("CK_Products_Stock_NonNegative", "[Stock] >= 0");
				t.HasCheckConstraint("CK_Products_Discount_NonNegative", "[DiscountedPrice] >= 0");
				t.HasCheckConstraint("CK_Products_Prices_Valid", "[OriginalPrice] >= [DiscountedPrice]");
			});

			entity
				.HasOne(x => x.Restaurant)
				.WithMany(x => x.Products)
				.HasForeignKey(x => x.RestaurantId)
				.OnDelete(DeleteBehavior.Cascade);
		});

		modelBuilder.Entity<Order>(entity =>
		{
			entity.Property(x => x.TotalAmount).HasColumnType("decimal(18,2)");
			entity.Property(x => x.UpdatedAt).HasColumnType("datetime2");
			entity.Property(x => x.DeletedAt).HasColumnType("datetime2");
			entity.Property(x => x.IsDeleted).HasDefaultValue(false);
			entity.Property(x => x.ReservedUntil).HasColumnType("datetime2");
			entity.Property(x => x.ConfirmedAt).HasColumnType("datetime2");
			entity.Property(x => x.CompletedAt).HasColumnType("datetime2");
			entity.Property(x => x.CancelledAt).HasColumnType("datetime2");
			entity.Property(x => x.RowVersion).IsRowVersion();
			entity.HasIndex(x => new { x.UserId, x.CreatedAt });
			entity
				.HasOne(x => x.User)
				.WithMany(x => x.Orders)
				.HasForeignKey(x => x.UserId)
				.OnDelete(DeleteBehavior.Restrict);
		});

		modelBuilder.Entity<OrderItem>(entity =>
		{
			entity.Property(x => x.CreatedAt).HasColumnType("datetime2");
			entity.Property(x => x.UnitPrice).HasColumnType("decimal(18,2)");
			entity.Property(x => x.UpdatedAt).HasColumnType("datetime2");
			entity.Property(x => x.DeletedAt).HasColumnType("datetime2");
			entity.Property(x => x.IsDeleted).HasDefaultValue(false);
			entity.HasIndex(x => x.OrderId);
			entity.ToTable(t => t.HasCheckConstraint("CK_OrderItems_Quantity_Positive", "[Quantity] > 0"));
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

		modelBuilder.Entity<RefreshToken>(entity =>
		{
			entity.Property(x => x.TokenHash).HasMaxLength(512).IsRequired();
			entity.Property(x => x.DeviceInfo).HasMaxLength(200);
			entity.Property(x => x.IpAddress).HasMaxLength(64);
			entity.Property(x => x.UpdatedAt).HasColumnType("datetime2");
			entity.Property(x => x.DeletedAt).HasColumnType("datetime2");
			entity.Property(x => x.IsDeleted).HasDefaultValue(false);
			entity.HasIndex(x => x.TokenHash).IsUnique();
			entity.HasIndex(x => new { x.UserId, x.ExpiresAt });

			entity
				.HasOne(x => x.User)
				.WithMany(x => x.RefreshTokens)
				.HasForeignKey(x => x.UserId)
				.OnDelete(DeleteBehavior.Cascade);
		});

		modelBuilder.Entity<ProductImage>(entity =>
		{
			entity.Property(x => x.ImageUrl).HasMaxLength(500).IsRequired();
			entity.Property(x => x.StorageKey).HasMaxLength(250).IsRequired();
			entity.Property(x => x.UpdatedAt).HasColumnType("datetime2");
			entity.Property(x => x.DeletedAt).HasColumnType("datetime2");
			entity.Property(x => x.IsDeleted).HasDefaultValue(false);
			entity.HasIndex(x => new { x.ProductId, x.IsPrimary });

			entity
				.HasOne(x => x.Product)
				.WithMany(x => x.Images)
				.HasForeignKey(x => x.ProductId)
				.OnDelete(DeleteBehavior.Cascade);
		});

		modelBuilder.Entity<AdminActionLog>(entity =>
		{
			entity.Property(x => x.ActionType).HasMaxLength(80).IsRequired();
			entity.Property(x => x.TargetType).HasMaxLength(80).IsRequired();
			entity.Property(x => x.Reason).HasMaxLength(500);
			entity.Property(x => x.UpdatedAt).HasColumnType("datetime2");
			entity.Property(x => x.DeletedAt).HasColumnType("datetime2");
			entity.Property(x => x.IsDeleted).HasDefaultValue(false);
			entity.HasIndex(x => new { x.AdminUserId, x.CreatedAt });

			entity
				.HasOne(x => x.AdminUser)
				.WithMany(x => x.AdminActionLogs)
				.HasForeignKey(x => x.AdminUserId)
				.OnDelete(DeleteBehavior.Restrict);
		});

		modelBuilder.Entity<Notification>(entity =>
		{
			entity.Property(x => x.Type).HasMaxLength(50).IsRequired();
			entity.Property(x => x.Title).HasMaxLength(120).IsRequired();
			entity.Property(x => x.Message).HasMaxLength(1000).IsRequired();
			entity.Property(x => x.UpdatedAt).HasColumnType("datetime2");
			entity.Property(x => x.DeletedAt).HasColumnType("datetime2");
			entity.Property(x => x.IsDeleted).HasDefaultValue(false);
			entity.HasIndex(x => new { x.UserId, x.IsRead, x.CreatedAt });

			entity
				.HasOne(x => x.User)
				.WithMany(x => x.Notifications)
				.HasForeignKey(x => x.UserId)
				.OnDelete(DeleteBehavior.Cascade);
		});

		ApplySoftDeleteQueryFilters(modelBuilder);
	}

	public override int SaveChanges(bool acceptAllChangesOnSuccess)
	{
		UpdateAuditFields();
		return base.SaveChanges(acceptAllChangesOnSuccess);
	}

	public override Task<int> SaveChangesAsync(bool acceptAllChangesOnSuccess, CancellationToken cancellationToken = default)
	{
		UpdateAuditFields();
		return base.SaveChangesAsync(acceptAllChangesOnSuccess, cancellationToken);
	}

	private void UpdateAuditFields()
	{
		var now = DateTime.UtcNow;
		foreach (var entry in ChangeTracker.Entries<BaseEntity>())
		{
			if (entry.State == EntityState.Added)
			{
				entry.Entity.UpdatedAt = now;
			}
			else if (entry.State == EntityState.Modified)
			{
				entry.Entity.UpdatedAt = now;
			}
			else if (entry.State == EntityState.Deleted)
			{
				entry.State = EntityState.Modified;
				entry.Entity.IsDeleted = true;
				entry.Entity.DeletedAt = now;
				entry.Entity.UpdatedAt = now;
			}
		}
	}

	private static void ApplySoftDeleteQueryFilters(ModelBuilder modelBuilder)
	{
		foreach (var entityType in modelBuilder.Model.GetEntityTypes())
		{
			if (!typeof(BaseEntity).IsAssignableFrom(entityType.ClrType))
			{
				continue;
			}

			var parameter = Expression.Parameter(entityType.ClrType, "e");
			var propMethod = typeof(EF).GetMethod(nameof(EF.Property))!.MakeGenericMethod(typeof(bool));
			var isDeletedProperty = Expression.Call(propMethod, parameter, Expression.Constant(nameof(BaseEntity.IsDeleted)));
			var filterBody = Expression.Equal(isDeletedProperty, Expression.Constant(false));
			var lambda = Expression.Lambda(filterBody, parameter);

			modelBuilder.Entity(entityType.ClrType).HasQueryFilter(lambda);
		}
	}
}

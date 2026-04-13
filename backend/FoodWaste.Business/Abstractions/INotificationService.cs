using FoodWaste.Business.Models.Notification;

namespace FoodWaste.Business.Abstractions;

public interface INotificationService
{
    Task CreateAsync(int userId, string type, string title, string message, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<NotificationDto>> GetMyNotificationsAsync(int userId, CancellationToken cancellationToken = default);
    Task<bool> MarkAsReadAsync(int userId, int notificationId, CancellationToken cancellationToken = default);
}

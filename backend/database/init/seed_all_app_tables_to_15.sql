USE FoodWasteDb;
GO

SET NOCOUNT ON;
GO

DECLARE @MissingRefreshTokens int = 15 - (SELECT COUNT(*) FROM RefreshTokens WHERE IsDeleted = 0);
IF @MissingRefreshTokens > 0
BEGIN
    ;WITH targetUsers AS (
        SELECT ROW_NUMBER() OVER (ORDER BY Id) AS RowNum, Id
        FROM Users
        WHERE IsDeleted = 0
    ),
    counts AS (
        SELECT COUNT(*) AS UserCount
        FROM targetUsers
    ),
    numbers AS (
        SELECT TOP (@MissingRefreshTokens) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNum
        FROM sys.all_objects
    )
    INSERT INTO RefreshTokens (UserId, TokenHash, ExpiresAt, RevokedAt, DeviceInfo, IpAddress, CreatedAt, UpdatedAt, IsDeleted, DeletedAt)
    SELECT users.Id,
           CONVERT(varchar(64), HASHBYTES('SHA2_256', CONCAT('seed-refresh-token-', numbers.RowNum, '-', users.Id)), 2),
           DATEADD(day, 30, SYSUTCDATETIME()),
           NULL,
           CONCAT('SeedDevice-', numbers.RowNum),
           CONCAT('10.0.0.', numbers.RowNum),
           SYSUTCDATETIME(),
           SYSUTCDATETIME(),
           0,
           NULL
    FROM numbers
    CROSS JOIN counts
    INNER JOIN targetUsers AS users ON users.RowNum = ((numbers.RowNum - 1) % counts.UserCount) + 1;
END;
GO

DECLARE @MissingOrders int = 15 - (SELECT COUNT(*) FROM Orders WHERE IsDeleted = 0);
IF @MissingOrders > 0
BEGIN
    ;WITH customerUsers AS (
        SELECT ROW_NUMBER() OVER (ORDER BY Id) AS RowNum, Id
        FROM Users
        WHERE Role = 'Customer' AND IsDeleted = 0
    ),
    seededProducts AS (
        SELECT ROW_NUMBER() OVER (ORDER BY Id) AS RowNum, Id, DiscountedPrice
        FROM Products
        WHERE IsDeleted = 0
    ),
    customerCounts AS (
        SELECT COUNT(*) AS CustomerCount FROM customerUsers
    ),
    productCounts AS (
        SELECT COUNT(*) AS ProductCount FROM seededProducts
    ),
    numbers AS (
        SELECT TOP (@MissingOrders) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNum
        FROM sys.all_objects
    )
    INSERT INTO Orders (UserId, CreatedAt, TotalAmount, Status, CancelledAt, CompletedAt, ConfirmedAt, ReservedUntil, UpdatedAt, IsDeleted, DeletedAt)
    SELECT customers.Id,
           DATEADD(hour, -numbers.RowNum, SYSUTCDATETIME()),
           CAST(products.DiscountedPrice * ((((numbers.RowNum - 1) % 3) + 1)) AS decimal(18,2)),
           CASE numbers.RowNum % 4
               WHEN 1 THEN 1
               WHEN 2 THEN 2
               WHEN 3 THEN 3
               ELSE 4
           END,
           CASE WHEN numbers.RowNum % 4 = 0 THEN DATEADD(minute, -numbers.RowNum, SYSUTCDATETIME()) ELSE NULL END,
           CASE WHEN numbers.RowNum % 4 = 3 THEN DATEADD(minute, -numbers.RowNum, SYSUTCDATETIME()) ELSE NULL END,
           CASE WHEN numbers.RowNum % 4 IN (2, 3) THEN DATEADD(minute, -numbers.RowNum, SYSUTCDATETIME()) ELSE NULL END,
           CASE WHEN numbers.RowNum % 4 = 1 THEN DATEADD(minute, 45, SYSUTCDATETIME()) ELSE NULL END,
           SYSUTCDATETIME(),
           0,
           NULL
    FROM numbers
    CROSS JOIN customerCounts
    CROSS JOIN productCounts
    INNER JOIN customerUsers AS customers ON customers.RowNum = ((numbers.RowNum - 1) % customerCounts.CustomerCount) + 1
    INNER JOIN seededProducts AS products ON products.RowNum = ((numbers.RowNum - 1) % productCounts.ProductCount) + 1;
END;
GO

DECLARE @MissingOrderItems int = 15 - (SELECT COUNT(*) FROM OrderItems WHERE IsDeleted = 0);
IF @MissingOrderItems > 0
BEGIN
    ;WITH availableOrders AS (
        SELECT TOP (@MissingOrderItems)
               ROW_NUMBER() OVER (ORDER BY orders.Id) AS RowNum,
               orders.Id
        FROM Orders AS orders
        WHERE orders.IsDeleted = 0
          AND NOT EXISTS (
              SELECT 1
              FROM OrderItems AS existing
              WHERE existing.OrderId = orders.Id AND existing.IsDeleted = 0
          )
        ORDER BY orders.Id
    ),
    seededProducts AS (
        SELECT ROW_NUMBER() OVER (ORDER BY Id) AS RowNum, Id, DiscountedPrice
        FROM Products
        WHERE IsDeleted = 0
    ),
    productCounts AS (
        SELECT COUNT(*) AS ProductCount FROM seededProducts
    )
    INSERT INTO OrderItems (OrderId, ProductId, Quantity, UnitPrice, CreatedAt, UpdatedAt, IsDeleted, DeletedAt)
    SELECT orders.Id,
           products.Id,
           ((orders.RowNum - 1) % 3) + 1,
           products.DiscountedPrice,
           SYSUTCDATETIME(),
           SYSUTCDATETIME(),
           0,
           NULL
    FROM availableOrders AS orders
    CROSS JOIN productCounts
    INNER JOIN seededProducts AS products ON products.RowNum = ((orders.RowNum - 1) % productCounts.ProductCount) + 1;

    UPDATE orders
    SET TotalAmount = totals.TotalAmount,
        UpdatedAt = SYSUTCDATETIME()
    FROM Orders AS orders
    INNER JOIN (
        SELECT OrderId, SUM(UnitPrice * Quantity) AS TotalAmount
        FROM OrderItems
        WHERE IsDeleted = 0
        GROUP BY OrderId
    ) AS totals ON totals.OrderId = orders.Id;
END;
GO

DECLARE @MissingProductImages int = 15 - (SELECT COUNT(*) FROM ProductImages WHERE IsDeleted = 0);
IF @MissingProductImages > 0
BEGIN
    ;WITH productsWithoutImages AS (
        SELECT TOP (@MissingProductImages) Id
        FROM Products
        WHERE IsDeleted = 0
          AND NOT EXISTS (
              SELECT 1
              FROM ProductImages AS existing
              WHERE existing.ProductId = Products.Id AND existing.IsDeleted = 0
          )
        ORDER BY Id
    )
    INSERT INTO ProductImages (ProductId, ImageUrl, StorageKey, IsPrimary, CreatedAt, UpdatedAt, IsDeleted, DeletedAt)
    SELECT Id,
           CONCAT('https://picsum.photos/seed/foodwaste-', Id, '/800/600'),
           CONCAT('products/product-', Id, '-primary.jpg'),
           1,
           SYSUTCDATETIME(),
           SYSUTCDATETIME(),
           0,
           NULL
    FROM productsWithoutImages;
END;
GO

DECLARE @MissingNotifications int = 15 - (SELECT COUNT(*) FROM Notifications WHERE IsDeleted = 0);
IF @MissingNotifications > 0
BEGIN
    ;WITH targetUsers AS (
        SELECT ROW_NUMBER() OVER (ORDER BY Id) AS RowNum, Id
        FROM Users
        WHERE IsDeleted = 0
    ),
    counts AS (
        SELECT COUNT(*) AS UserCount
        FROM targetUsers
    ),
    numbers AS (
        SELECT TOP (@MissingNotifications) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNum
        FROM sys.all_objects
    )
    INSERT INTO Notifications (UserId, Type, Title, Message, IsRead, CreatedAt, UpdatedAt, IsDeleted, DeletedAt)
    SELECT users.Id,
           CASE numbers.RowNum % 3
               WHEN 1 THEN 'reservation'
               WHEN 2 THEN 'campaign'
               ELSE 'system'
           END,
           CONCAT('Seed Bildirim ', numbers.RowNum),
           CONCAT('Bu otomatik olusturulmus ornek bildirim kaydidir. Kayit no: ', numbers.RowNum),
           CASE WHEN numbers.RowNum % 2 = 0 THEN 1 ELSE 0 END,
           SYSUTCDATETIME(),
           SYSUTCDATETIME(),
           0,
           NULL
    FROM numbers
    CROSS JOIN counts
    INNER JOIN targetUsers AS users ON users.RowNum = ((numbers.RowNum - 1) % counts.UserCount) + 1;
END;
GO

DECLARE @MissingAdminActionLogs int = 15 - (SELECT COUNT(*) FROM AdminActionLogs WHERE IsDeleted = 0);
IF @MissingAdminActionLogs > 0
BEGIN
    ;WITH numbers AS (
        SELECT TOP (@MissingAdminActionLogs) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNum
        FROM sys.all_objects
    )
    INSERT INTO AdminActionLogs (AdminUserId, ActionType, TargetType, TargetId, Reason, CreatedAt, UpdatedAt, IsDeleted, DeletedAt)
    SELECT NULL,
           CASE numbers.RowNum % 3
               WHEN 1 THEN 'ApproveSeller'
               WHEN 2 THEN 'HighlightProduct'
               ELSE 'ReviewRestaurant'
           END,
           CASE numbers.RowNum % 3
               WHEN 1 THEN 'User'
               WHEN 2 THEN 'Product'
               ELSE 'Restaurant'
           END,
           numbers.RowNum,
           CONCAT('Seed admin log kaydi ', numbers.RowNum),
           SYSUTCDATETIME(),
           SYSUTCDATETIME(),
           0,
           NULL
    FROM numbers;
END;
GO

SELECT 'Users' AS TableName, COUNT(*) AS TotalRows FROM Users WHERE IsDeleted = 0
UNION ALL SELECT 'Restaurants', COUNT(*) FROM Restaurants WHERE IsDeleted = 0
UNION ALL SELECT 'Products', COUNT(*) FROM Products WHERE IsDeleted = 0
UNION ALL SELECT 'Orders', COUNT(*) FROM Orders WHERE IsDeleted = 0
UNION ALL SELECT 'OrderItems', COUNT(*) FROM OrderItems WHERE IsDeleted = 0
UNION ALL SELECT 'RefreshTokens', COUNT(*) FROM RefreshTokens WHERE IsDeleted = 0
UNION ALL SELECT 'ProductImages', COUNT(*) FROM ProductImages WHERE IsDeleted = 0
UNION ALL SELECT 'Notifications', COUNT(*) FROM Notifications WHERE IsDeleted = 0
UNION ALL SELECT 'AdminActionLogs', COUNT(*) FROM AdminActionLogs WHERE IsDeleted = 0;
GO

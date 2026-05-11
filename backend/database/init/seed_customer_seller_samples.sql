SET NOCOUNT ON;

-- Sample Seller and Customer accounts for demo/testing.
DECLARE @Users TABLE
(
    FullName nvarchar(200) NOT NULL,
    Email nvarchar(256) NOT NULL,
    PasswordHash nvarchar(500) NOT NULL,
    Phone nvarchar(50) NOT NULL,
    Role nvarchar(20) NOT NULL,
    IsActive bit NOT NULL,
    IsApproved bit NOT NULL,
    EmailVerified bit NOT NULL,
    EmailVerifiedAt datetime2(7) NULL,
    PhoneVerified bit NOT NULL,
    LastLoginAt datetime2(7) NULL,
    CreatedAt datetime2(7) NOT NULL,
    UpdatedAt datetime2(7) NULL,
    IsDeleted bit NOT NULL,
    DeletedAt datetime2(7) NULL
);

-- Password hash corresponds to a demo password used in existing seed scripts.
INSERT INTO @Users
(
    FullName,
    Email,
    PasswordHash,
    Phone,
    Role,
    IsActive,
    IsApproved,
    EmailVerified,
    EmailVerifiedAt,
    PhoneVerified,
    LastLoginAt,
    CreatedAt,
    UpdatedAt,
    IsDeleted,
    DeletedAt
)
VALUES
(N'Kadıköy Satıcı Örnek', N'kadikoy.satici.ornek@foodwaste.com', N'$2a$11$idhV74Jiek6YwLH5qyN1N.JxjWys2.SjjwuS7HRuGf8n9uWzD1LE6', N'5553000001', N'Seller', 1, 1, 1, SYSUTCDATETIME(), 0, NULL, SYSUTCDATETIME(), NULL, 0, NULL),
(N'Üsküdar Satıcı Örnek', N'uskudar.satici.ornek@foodwaste.com', N'$2a$11$idhV74Jiek6YwLH5qyN1N.JxjWys2.SjjwuS7HRuGf8n9uWzD1LE6', N'5553000002', N'Seller', 1, 1, 1, SYSUTCDATETIME(), 0, NULL, SYSUTCDATETIME(), NULL, 0, NULL),
(N'Buse Yıldız', N'buse.yildiz.ornek@foodwaste.com', N'$2a$11$idhV74Jiek6YwLH5qyN1N.JxjWys2.SjjwuS7HRuGf8n9uWzD1LE6', N'5554000001', N'Customer', 1, 1, 1, SYSUTCDATETIME(), 0, NULL, SYSUTCDATETIME(), NULL, 0, NULL),
(N'Emre Çelik', N'emre.celik.ornek@foodwaste.com', N'$2a$11$idhV74Jiek6YwLH5qyN1N.JxjWys2.SjjwuS7HRuGf8n9uWzD1LE6', N'5554000002', N'Customer', 1, 1, 1, SYSUTCDATETIME(), 0, NULL, SYSUTCDATETIME(), NULL, 0, NULL);

MERGE Users AS target
USING @Users AS source
ON target.Email = source.Email
WHEN MATCHED THEN
    UPDATE SET
        target.FullName = source.FullName,
        target.PasswordHash = source.PasswordHash,
        target.Phone = source.Phone,
        target.Role = source.Role,
        target.IsActive = source.IsActive,
        target.IsApproved = source.IsApproved,
        target.EmailVerified = source.EmailVerified,
        target.EmailVerifiedAt = source.EmailVerifiedAt,
        target.PhoneVerified = source.PhoneVerified,
        target.LastLoginAt = source.LastLoginAt,
        target.IsDeleted = source.IsDeleted,
        target.DeletedAt = source.DeletedAt,
        target.UpdatedAt = SYSUTCDATETIME()
WHEN NOT MATCHED BY TARGET THEN
    INSERT
    (
        FullName,
        Email,
        PasswordHash,
        Phone,
        Role,
        IsActive,
        IsApproved,
        EmailVerified,
        EmailVerifiedAt,
        PhoneVerified,
        LastLoginAt,
        CreatedAt,
        UpdatedAt,
        IsDeleted,
        DeletedAt
    )
    VALUES
    (
        source.FullName,
        source.Email,
        source.PasswordHash,
        source.Phone,
        source.Role,
        source.IsActive,
        source.IsApproved,
        source.EmailVerified,
        source.EmailVerifiedAt,
        source.PhoneVerified,
        source.LastLoginAt,
        source.CreatedAt,
        source.UpdatedAt,
        source.IsDeleted,
        source.DeletedAt
    );

SELECT Role, COUNT(*) AS UserCount
FROM Users
WHERE Email IN (SELECT Email FROM @Users)
GROUP BY Role;

SELECT FullName, Email, Role, Phone
FROM Users
WHERE Email IN (SELECT Email FROM @Users)
ORDER BY Role, FullName;

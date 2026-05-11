$ErrorActionPreference = 'Stop'

$Server = 'foodwastedb.database.windows.net'
$Database = 'foodwastedb'
$User = 'foodwastedb'
$Password = 'Bacilar2023'

$Sql = @'
SET NOCOUNT ON;

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

INSERT INTO @Users VALUES
(N'Beşiktaş Esnaf Temsilcisi', N'besiktas_satici@ecograb.com', N'$2a$10$fWlTkOe2L4s7/E1X7.8rH.uCyg1Y7pF9k2K3vJ8hL5mN6pO9qR0Uu', N'5551234567', N'Seller', 1, 1, 1, NULL, 0, NULL, '2026-05-11T20:58:37.5200000', NULL, 0, NULL),
(N'Üsküdar Esnaf Temsilcisi', N'uskudar_satici@ecograb.com', N'$2a$10$fWlTkOe2L4s7/E1X7.8rH.uCyg1Y7pF9k2K3vJ8hL5mN6pO9qR0Uu', N'5552234567', N'Seller', 1, 1, 1, NULL, 0, NULL, '2026-05-11T20:58:37.5200000', NULL, 0, NULL),
(N'Ümraniye Esnaf Temsilcisi', N'umraniye_satici@ecograb.com', N'$2a$10$fWlTkOe2L4s7/E1X7.8rH.uCyg1Y7pF9k2K3vJ8hL5mN6pO9qR0Uu', N'5553234567', N'Seller', 1, 1, 1, NULL, 0, NULL, '2026-05-11T20:58:37.5200000', NULL, 0, NULL),
(N'Maltepe Esnaf Temsilcisi', N'maltepe_satici@ecograb.com', N'$2a$10$fWlTkOe2L4s7/E1X7.8rH.uCyg1Y7pF9k2K3vJ8hL5mN6pO9qR0Uu', N'5554234567', N'Seller', 1, 1, 1, NULL, 0, NULL, '2026-05-11T20:58:37.5200000', NULL, 0, NULL),
(N'Pendik Esnaf Temsilcisi', N'pendik_satici@ecograb.com', N'$2a$10$fWlTkOe2L4s7/E1X7.8rH.uCyg1Y7pF9k2K3vJ8hL5mN6pO9qR0Uu', N'5555234567', N'Seller', 1, 1, 1, NULL, 0, NULL, '2026-05-11T20:58:37.5200000', NULL, 0, NULL),
(N'Tuzla Esnaf Temsilcisi', N'tuzla_satici@ecograb.com', N'$2a$10$fWlTkOe2L4s7/E1X7.8rH.uCyg1Y7pF9k2K3vJ8hL5mN6pO9qR0Uu', N'5556234567', N'Seller', 1, 1, 1, NULL, 0, NULL, '2026-05-11T20:58:37.5200000', NULL, 0, NULL),
(N'Kadıköy Esnaf Temsilcisi', N'kadikoy_satici@ecograb.com', N'$2a$10$fWlTkOe2L4s7/E1X7.8rH.uCyg1Y7pF9k2K3vJ8hL5mN6pO9qR0Uu', N'5557234567', N'Seller', 1, 1, 1, NULL, 0, NULL, '2026-05-11T20:58:37.5200000', NULL, 0, NULL),
(N'Beyoğlu Esnaf Temsilcisi', N'beyoglu_satici@ecograb.com', N'$2a$10$fWlTkOe2L4s7/E1X7.8rH.uCyg1Y7pF9k2K3vJ8hL5mN6pO9qR0Uu', N'5558234567', N'Seller', 1, 1, 1, NULL, 0, NULL, '2026-05-11T20:58:37.5200000', NULL, 0, NULL),
(N'Sarıyer Esnaf Temsilcisi', N'sariyer_satici@ecograb.com', N'$2a$10$fWlTkOe2L4s7/E1X7.8rH.uCyg1Y7pF9k2K3vJ8hL5mN6pO9qR0Uu', N'5559234567', N'Seller', 1, 1, 1, NULL, 0, NULL, '2026-05-11T20:58:37.5200000', NULL, 0, NULL),
(N'Bakırköy Esnaf Temsilcisi', N'bakirkoy_satici@ecograb.com', N'$2a$10$fWlTkOe2L4s7/E1X7.8rH.uCyg1Y7pF9k2K3vJ8hL5mN6pO9qR0Uu', N'5550234567', N'Seller', 1, 1, 1, NULL, 0, NULL, '2026-05-11T20:58:37.5200000', NULL, 0, NULL),
(N'Pando Satıcı', N'pando@foodwaste.com', N'$2a$11$idhV74Jiek6YwLH5qyN1N.JxjWys2.SjjwuS7HRuGf8n9uWzD1LE6', N'5551000001', N'Seller', 1, 1, 1, '2026-05-11T21:28:15.4000000', 0, NULL, '2026-05-11T21:15:44.8100000', NULL, 0, NULL),
(N'7-GR Satıcı', N'7gr@foodwaste.com', N'Password123', N'5551000002', N'Seller', 1, 1, 1, NULL, 0, NULL, '2026-05-11T21:15:44.8100000', NULL, 0, NULL),
(N'Karadeniz Satıcı', N'karadeniz@foodwaste.com', N'$2a$11$idhV74Jiek6YwLH5qyN1N.JxjWys2.SjjwuS7HRuGf8n9uWzD1LE6', N'5551000002', N'Seller', 1, 1, 1, '2026-05-11T21:28:15.4700000', 0, NULL, '2026-05-11T21:15:44.8133333', NULL, 0, NULL),
(N'Çınaraltı Satıcı', N'cinaralti@foodwaste.com', N'$2a$11$idhV74Jiek6YwLH5qyN1N.JxjWys2.SjjwuS7HRuGf8n9uWzD1LE6', N'5551000003', N'Seller', 1, 1, 1, '2026-05-11T21:28:15.5600000', 0, NULL, '2026-05-11T21:15:44.8166667', NULL, 0, NULL),
(N'Nevmekan Satıcı', N'nevmekan@foodwaste.com', N'$2a$11$idhV74Jiek6YwLH5qyN1N.JxjWys2.SjjwuS7HRuGf8n9uWzD1LE6', N'5551000004', N'Seller', 1, 1, 1, '2026-05-11T21:28:15.6100000', 0, NULL, '2026-05-11T21:15:44.8200000', NULL, 0, NULL),
(N'Kanaat Satıcı', N'kanaat@foodwaste.com', N'$2a$11$idhV74Jiek6YwLH5qyN1N.JxjWys2.SjjwuS7HRuGf8n9uWzD1LE6', N'5551000005', N'Seller', 1, 1, 1, '2026-05-11T21:28:15.6600000', 0, NULL, '2026-05-11T21:15:44.8233333', NULL, 0, NULL),
(N'Lider Pide Satıcı', N'liderpide@foodwaste.com', N'$2a$11$idhV74Jiek6YwLH5qyN1N.JxjWys2.SjjwuS7HRuGf8n9uWzD1LE6', N'5551000006', N'Seller', 1, 1, 1, '2026-05-11T21:28:15.7100000', 0, NULL, '2026-05-11T21:15:44.8266667', NULL, 0, NULL),
(N'Sarıyer Börek Satıcı', N'sariyer@foodwaste.com', N'$2a$11$idhV74Jiek6YwLH5qyN1N.JxjWys2.SjjwuS7HRuGf8n9uWzD1LE6', N'5551000007', N'Seller', 1, 1, 1, '2026-05-11T21:28:15.7633333', 0, NULL, '2026-05-11T21:15:44.8300000', NULL, 0, NULL),
(N'Happy Moons Satıcı', N'happymoons@foodwaste.com', N'$2a$11$idhV74Jiek6YwLH5qyN1N.JxjWys2.SjjwuS7HRuGf8n9uWzD1LE6', N'5551000008', N'Seller', 1, 1, 1, '2026-05-11T21:28:15.8133333', 0, NULL, '2026-05-11T21:15:44.8333333', NULL, 0, NULL),
(N'Beşçeşmeler Satıcı', N'bescesmeler@foodwaste.com', N'$2a$11$idhV74Jiek6YwLH5qyN1N.JxjWys2.SjjwuS7HRuGf8n9uWzD1LE6', N'5551000009', N'Seller', 1, 1, 1, '2026-05-11T21:28:15.8666667', 0, NULL, '2026-05-11T21:15:44.8366667', NULL, 0, NULL),
(N'Mendel Satıcı', N'mendels@foodwaste.com', N'$2a$11$idhV74Jiek6YwLH5qyN1N.JxjWys2.SjjwuS7HRuGf8n9uWzD1LE6', N'5551000010', N'Seller', 1, 1, 1, '2026-05-11T21:28:15.9366667', 0, NULL, '2026-05-11T21:15:44.8400000', NULL, 0, NULL),
(N'Cemil Usta Satıcı', N'cemilusta@foodwaste.com', N'$2a$11$idhV74Jiek6YwLH5qyN1N.JxjWys2.SjjwuS7HRuGf8n9uWzD1LE6', N'5551000011', N'Seller', 1, 1, 1, '2026-05-11T21:28:15.9900000', 0, NULL, '2026-05-11T21:15:44.8433333', NULL, 0, NULL),
(N'Pendik Marina Satıcı', N'marina@foodwaste.com', N'$2a$11$idhV74Jiek6YwLH5qyN1N.JxjWys2.SjjwuS7HRuGf8n9uWzD1LE6', N'5551000012', N'Seller', 1, 1, 1, '2026-05-11T21:28:16.0433333', 0, NULL, '2026-05-11T21:15:44.8466667', NULL, 0, NULL),
(N'Saklı Bahçe Satıcı', N'saklibahce@foodwaste.com', N'Password123', N'5551000014', N'Seller', 1, 1, 1, NULL, 0, NULL, '2026-05-11T21:15:44.8500000', NULL, 0, NULL),
(N'Köfteci Yusuf Satıcı', N'yusuf@foodwaste.com', N'Password123', N'5551000015', N'Seller', 1, 1, 1, NULL, 0, NULL, '2026-05-11T21:15:44.8500000', NULL, 0, NULL),
(N'Filizler Satıcı', N'filizler@foodwaste.com', N'$2a$11$idhV74Jiek6YwLH5qyN1N.JxjWys2.SjjwuS7HRuGf8n9uWzD1LE6', N'5551000013', N'Seller', 1, 1, 1, '2026-05-11T21:28:16.1333333', 0, NULL, '2026-05-11T21:15:44.8566667', NULL, 0, NULL),
(N'Meraklı Köfteci Satıcı', N'merakli@foodwaste.com', N'$2a$11$idhV74Jiek6YwLH5qyN1N.JxjWys2.SjjwuS7HRuGf8n9uWzD1LE6', N'5551000014', N'Seller', 1, 1, 1, '2026-05-11T21:28:16.1900000', 0, NULL, '2026-05-11T21:15:44.8600000', NULL, 0, NULL),
(N'Tuzla Balıkçı Satıcı', N'tuzlabalik@foodwaste.com', N'$2a$11$idhV74Jiek6YwLH5qyN1N.JxjWys2.SjjwuS7HRuGf8n9uWzD1LE6', N'5551000015', N'Seller', 1, 1, 1, '2026-05-11T21:28:16.2466667', 0, NULL, '2026-05-11T21:15:44.8600000', NULL, 0, NULL),
(N'Baylan Satıcı', N'baylan@foodwaste.com', N'$2a$11$idhV74Jiek6YwLH5qyN1N.JxjWys2.SjjwuS7HRuGf8n9uWzD1LE6', N'5551000016', N'Seller', 1, 1, 1, '2026-05-11T21:28:16.3066667', 0, NULL, '2026-05-11T21:15:44.8633333', NULL, 0, NULL),
(N'Çiya Satıcı', N'ciya@foodwaste.com', N'$2a$11$idhV74Jiek6YwLH5qyN1N.JxjWys2.SjjwuS7HRuGf8n9uWzD1LE6', N'5551000017', N'Seller', 1, 1, 1, '2026-05-11T21:28:16.3600000', 0, NULL, '2026-05-11T21:15:44.8666667', NULL, 0, NULL),
(N'Zapata Satıcı', N'zapata@foodwaste.com', N'$2a$11$idhV74Jiek6YwLH5qyN1N.JxjWys2.SjjwuS7HRuGf8n9uWzD1LE6', N'5551000018', N'Seller', 1, 1, 1, '2026-05-11T21:28:16.4100000', 0, NULL, '2026-05-11T21:15:44.8700000', NULL, 0, NULL),
(N'Galata Simitçi Satıcı', N'galata@foodwaste.com', N'$2a$11$idhV74Jiek6YwLH5qyN1N.JxjWys2.SjjwuS7HRuGf8n9uWzD1LE6', N'5551000019', N'Seller', 1, 1, 1, '2026-05-11T21:28:16.4600000', 0, NULL, '2026-05-11T21:15:44.8733333', NULL, 0, NULL),
(N'Güllüoğlu Satıcı', N'gulluoglu@foodwaste.com', N'$2a$11$idhV74Jiek6YwLH5qyN1N.JxjWys2.SjjwuS7HRuGf8n9uWzD1LE6', N'5551000020', N'Seller', 1, 1, 1, '2026-05-11T21:28:16.5100000', 0, NULL, '2026-05-11T21:15:44.8766667', NULL, 0, NULL),
(N'Yeniköy Kahvesi Satıcı', N'yenikoy@foodwaste.com', N'$2a$11$idhV74Jiek6YwLH5qyN1N.JxjWys2.SjjwuS7HRuGf8n9uWzD1LE6', N'5551000021', N'Seller', 1, 1, 1, '2026-05-11T21:28:16.5633333', 0, NULL, '2026-05-11T21:15:44.8800000', NULL, 0, NULL),
(N'Meşhur Pideci Satıcı', N'sariyerpide@foodwaste.com', N'$2a$11$idhV74Jiek6YwLH5qyN1N.JxjWys2.SjjwuS7HRuGf8n9uWzD1LE6', N'5551000022', N'Seller', 1, 1, 1, '2026-05-11T21:28:16.6600000', 0, NULL, '2026-05-11T21:15:44.8833333', NULL, 0, NULL),
(N'Eleos Satıcı', N'eleos@foodwaste.com', N'$2a$11$idhV74Jiek6YwLH5qyN1N.JxjWys2.SjjwuS7HRuGf8n9uWzD1LE6', N'5551000023', N'Seller', 1, 1, 1, '2026-05-11T21:28:16.7100000', 0, NULL, '2026-05-11T21:15:44.8866667', NULL, 0, NULL),
(N'Asım Usta', N'karadenizdoner@foodwaste.com', N'Password123', N'5552000002', N'Seller', 1, 1, 1, NULL, 0, NULL, '2026-05-11T21:17:54.2200000', NULL, 0, NULL),
(N'Ayşenur Kendirci', N'aysenurkendirci@gmail.com', N'$2a$11$idhV74Jiek6YwLH5qyN1N.JxjWys2.SjjwuS7HRuGf8n9uWzD1LE6', N'5552000001', N'Customer', 1, 1, 1, '2026-05-11T21:28:15.1333333', 0, NULL, '2026-05-11T21:26:56.1800000', NULL, 0, NULL),
(N'Mehmet Yılmaz', N'mehmet.yilmaz@test.com', N'$2a$11$idhV74Jiek6YwLH5qyN1N.JxjWys2.SjjwuS7HRuGf8n9uWzD1LE6', N'5552000002', N'Customer', 1, 1, 1, '2026-05-11T21:28:15.1900000', 0, NULL, '2026-05-11T21:26:56.2333333', NULL, 0, NULL),
(N'Elif Demir', N'elif.demir@test.com', N'$2a$11$idhV74Jiek6YwLH5qyN1N.JxjWys2.SjjwuS7HRuGf8n9uWzD1LE6', N'5552000003', N'Customer', 1, 1, 1, '2026-05-11T21:28:15.2466667', 0, NULL, '2026-05-11T21:26:56.3033333', NULL, 0, NULL),
(N'Can Kaya', N'can.kaya@test.com', N'$2a$11$idhV74Jiek6YwLH5qyN1N.JxjWys2.SjjwuS7HRuGf8n9uWzD1LE6', N'5552000004', N'Customer', 1, 1, 1, '2026-05-11T21:28:15.3000000', 0, NULL, '2026-05-11T21:26:56.3566667', NULL, 0, NULL),
(N'Zeynep Aydın', N'zeynep.aydin@test.com', N'$2a$11$idhV74Jiek6YwLH5qyN1N.JxjWys2.SjjwuS7HRuGf8n9uWzD1LE6', N'5552000005', N'Customer', 1, 1, 1, '2026-05-11T21:28:15.3500000', 0, NULL, '2026-05-11T21:26:56.4100000', NULL, 0, NULL);

MERGE [Users] AS target
USING @Users AS source
ON target.[Email] = source.[Email]
WHEN MATCHED THEN
    UPDATE SET
        target.[FullName] = source.[FullName],
        target.[PasswordHash] = source.[PasswordHash],
        target.[Phone] = source.[Phone],
        target.[Role] = source.[Role],
        target.[IsActive] = source.[IsActive],
        target.[IsApproved] = source.[IsApproved],
        target.[EmailVerified] = source.[EmailVerified],
        target.[EmailVerifiedAt] = source.[EmailVerifiedAt],
        target.[PhoneVerified] = source.[PhoneVerified],
        target.[LastLoginAt] = source.[LastLoginAt],
        target.[CreatedAt] = source.[CreatedAt],
        target.[UpdatedAt] = source.[UpdatedAt],
        target.[IsDeleted] = source.[IsDeleted],
        target.[DeletedAt] = source.[DeletedAt]
WHEN NOT MATCHED BY TARGET THEN
    INSERT ([FullName], [Email], [PasswordHash], [Phone], [Role], [IsActive], [IsApproved], [EmailVerified], [EmailVerifiedAt], [PhoneVerified], [LastLoginAt], [CreatedAt], [UpdatedAt], [IsDeleted], [DeletedAt])
    VALUES (source.[FullName], source.[Email], source.[PasswordHash], source.[Phone], source.[Role], source.[IsActive], source.[IsApproved], source.[EmailVerified], source.[EmailVerifiedAt], source.[PhoneVerified], source.[LastLoginAt], source.[CreatedAt], source.[UpdatedAt], source.[IsDeleted], source.[DeletedAt]);

SELECT COUNT(*) AS AppliedUserCount
FROM [Users]
WHERE [Email] IN (SELECT [Email] FROM @Users);

SELECT COUNT(*) AS PlainPasswordCount
FROM [Users]
WHERE [Email] IN (SELECT [Email] FROM @Users)
  AND [PasswordHash] = N'Password123';
'@

$ConnectionString = "Server=tcp:$Server,1433;Initial Catalog=$Database;Persist Security Info=False;User ID=$User;Password=$Password;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
$Connection = New-Object System.Data.SqlClient.SqlConnection
$Connection.ConnectionString = $ConnectionString
$Connection.Open()

try {
    $Command = $Connection.CreateCommand()
    $Command.CommandText = $Sql
    $Command.CommandTimeout = 1200

    $Reader = $Command.ExecuteReader()
    if ($Reader.Read()) {
        Write-Host "AppliedUserCount=$($Reader.GetInt32(0))" -ForegroundColor Cyan
    }
    if ($Reader.NextResult() -and $Reader.Read()) {
        Write-Host "PlainPasswordCount=$($Reader.GetInt32(0))" -ForegroundColor Yellow
    }
    $Reader.Close()
}
finally {
    $Connection.Close()
    $Connection.Dispose()
}

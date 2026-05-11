$ErrorActionPreference = 'Stop'

$Server = 'foodwastedb.database.windows.net'
$Database = 'foodwastedb'
$User = 'foodwastedb'
$Password = 'Bacilar2023'

$Sql = @"
SET NOCOUNT ON;

DECLARE @Expected TABLE
(
    [Name] nvarchar(200) NOT NULL,
    [Address] nvarchar(500) NOT NULL,
    [City] nvarchar(100) NOT NULL,
    [Phone] nvarchar(50) NOT NULL,
    [Latitude] float NOT NULL,
    [Longitude] float NOT NULL
);

INSERT INTO @Expected ([Name], [Address], [City], [Phone], [Latitude], [Longitude]) VALUES
(N'Pando Kaymak', N'Sinanpaşa, Mumcu Bakkal Sk. No:5, 34353 Beşiktaş/İstanbul', N'Beşiktaş', N'2120000001', 41.0428, 29.0075),
(N'Karadeniz Döner', N'Sinanpaşa, Mumcu Bakkal Sk. No:6, 34353 Beşiktaş/İstanbul', N'Beşiktaş', N'2120000002', 41.0422, 29.0072),
(N'Mendels Coffee', N'İdealtepe, Rıfkı Tongsir Cd. No:57, 34841 Maltepe/İstanbul', N'Maltepe', N'2160000003', 40.9234, 29.1305),
(N'Meşhur Sarıyer Börekçisi', N'Yamanevler, Alemdağ Cd. No:169, 34768 Ümraniye/İstanbul', N'Ümraniye', N'2160000004', 41.0245, 29.1055),
(N'Zapata Bakery', N'Caferağa, Şevki Bey Sk. No:31, 34710 Kadıköy/İstanbul', N'Kadıköy', N'2160000005', 40.9855, 29.0288),
(N'Karaköy Güllüoğlu', N'Kemankeş Cd. Katlı Otopark Altı, Karaköy', N'Beyoğlu', N'2120000006', 41.0248, 28.9812),
(N'Çengelköy Tarihi Çınaraltı', N'Çengelköy Mah. Çınaraltı Camii Sk. No:4, Üsküdar', N'Üsküdar', N'2160000001', 41.0506, 29.0522),
(N'Nevmekan Sahil', N'Aziz Mahmut Hüdayi, Üsküdar Harem Sahil Yolu No:28', N'Üsküdar', N'2160000002', 41.0268, 29.0155),
(N'Kanaat Lokantası', N'Sultantepe, Selmani Pak Cd. No:9, Üsküdar', N'Üsküdar', N'2160000003', 41.0262, 29.0152),
(N'Lider Pide', N'Tepeüstü, Alemdağ Cd. No:542, Ümraniye', N'Ümraniye', N'2160000004', 41.0256, 29.1064),
(N'Happy Moons Canpark', N'Canpark AVM, Ümraniye', N'Ümraniye', N'2160000006', 41.0298, 29.1132),
(N'Cemil Usta Köfteci', N'İdealtepe Sahil Yolu No:103, Maltepe', N'Maltepe', N'2160000009', 40.9180, 29.1322),
(N'Pendik Marina Balıkçısı', N'Pendik Marina, Batı Mah.', N'Pendik', N'2160000010', 40.8752, 29.2305),
(N'Filizler Köftecisi', N'Cami Mah. Sahil Yolu No:15, Tuzla', N'Tuzla', N'2160000013', 40.8162, 29.3032),
(N'Tuzla Balıkçısı', N'Postane Mah. Cafer Sk. No:5, Tuzla', N'Tuzla', N'2160000015', 40.8148, 29.3015),
(N'Baylan Pastanesi', N'Caferağa, Muvakkithane Cd. No:9, Kadıköy', N'Kadıköy', N'2160000016', 40.9898, 29.0255),
(N'Çiya Sofrası', N'Caferağa, Güneşli Bahçe Sk. No:43, Kadıköy', N'Kadıköy', N'2160000017', 40.9905, 29.0248),
(N'Galata Simitçisi', N'Kemankeş Karamustafa Paşa, Mumhane Cd. No:47, Karaköy', N'Beyoğlu', N'2120000019', 41.0242, 28.9735),
(N'Eleos Restaurant', N'Yeşilköy, Cümbüş Sk. No:9, Bakırköy', N'Bakırköy', N'2120000021', 40.9782, 28.8745);

UPDATE r
SET
    r.[Name] = e.[Name],
    r.[Address] = e.[Address],
    r.[City] = e.[City],
    r.[Latitude] = e.[Latitude],
    r.[Longitude] = e.[Longitude],
    r.[IsDeleted] = 0,
    r.[DeletedAt] = NULL
FROM [Restaurants] r
INNER JOIN @Expected e ON e.[Phone] = r.[Phone];

INSERT INTO [Restaurants] ([Name], [Address], [City], [Phone], [Latitude], [Longitude], [OwnerUserId], [CreatedAt], [IsDeleted])
SELECT
    e.[Name],
    e.[Address],
    e.[City],
    e.[Phone],
    e.[Latitude],
    e.[Longitude],
    NULL,
    GETUTCDATE(),
    0
FROM @Expected e
WHERE NOT EXISTS (
    SELECT 1 FROM [Restaurants] r WHERE r.[Phone] = e.[Phone]
);

SELECT COUNT(*) AS MatchedCount
FROM [Restaurants] r
INNER JOIN @Expected e ON e.[Phone] = r.[Phone]
WHERE r.[Name] = e.[Name]
  AND r.[Address] = e.[Address]
  AND r.[City] = e.[City];

SELECT COUNT(*) AS TotalExpected FROM @Expected;
"@

$ConnectionString = "Server=tcp:$Server,1433;Initial Catalog=$Database;Persist Security Info=False;User ID=$User;Password=$Password;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
$Connection = New-Object System.Data.SqlClient.SqlConnection
$Connection.ConnectionString = $ConnectionString
$Connection.Open()

try {
    $Command = $Connection.CreateCommand()
    $Command.CommandText = $Sql
    $Command.CommandTimeout = 600

    $Reader = $Command.ExecuteReader()
    if ($Reader.Read()) {
        Write-Host "MatchedCount=$($Reader.GetInt32(0))" -ForegroundColor Cyan
    }
    if ($Reader.NextResult() -and $Reader.Read()) {
        Write-Host "TotalExpected=$($Reader.GetInt32(0))" -ForegroundColor Cyan
    }
    $Reader.Close()
}
finally {
    $Connection.Close()
    $Connection.Dispose()
}

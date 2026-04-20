USE FoodWasteDb;
GO

SET NOCOUNT ON;
GO

UPDATE Users
SET IsApproved = 1,
    UpdatedAt = SYSUTCDATETIME()
WHERE Email IN (
    'yagmur@mail.com',
    'ahmet@mail.com',
    'merve@mail.com',
    'can@mail.com',
    'zeynep@mail.com',
    'ali@mail.com',
    'fatma@mail.com',
    'murat@mail.com',
    'gamze@mail.com',
    'huseyin@mail.com'
);
GO

INSERT INTO Restaurants (Name, Address, City, Phone, CreatedAt, OwnerUserId, Latitude, Longitude, IsDeleted, UpdatedAt, DeletedAt)
SELECT seed.Name, seed.Address, seed.City, seed.Phone, SYSUTCDATETIME(), users.Id, seed.Latitude, seed.Longitude, 0, SYSUTCDATETIME(), NULL
FROM (VALUES
    ('Lezzet Sofrasi', 'Kadikoy Merkez', 'Istanbul', '02160000011', 'yagmur@mail.com', CAST(40.9901 AS float), CAST(29.0284 AS float)),
    ('Taze Marketim', 'Besiktas Merkez', 'Istanbul', '02160000012', 'ahmet@mail.com', CAST(41.0422 AS float), CAST(29.0083 AS float)),
    ('Kahve Molasi', 'Sisli Merkez', 'Istanbul', '02160000013', 'merve@mail.com', CAST(41.0600 AS float), CAST(28.9870 AS float)),
    ('Donerci Ali', 'Uskudar Merkez', 'Istanbul', '02160000014', 'can@mail.com', CAST(41.0267 AS float), CAST(29.0167 AS float)),
    ('Yesil Bakkal', 'Maltepe Merkez', 'Istanbul', '02160000015', 'zeynep@mail.com', CAST(40.9443 AS float), CAST(29.1325 AS float)),
    ('Gunes Kafe', 'Kadikoy Moda', 'Istanbul', '02160000016', 'ali@mail.com', CAST(40.9811 AS float), CAST(29.0234 AS float)),
    ('Anadolu Lokantasi', 'Pendik Merkez', 'Istanbul', '02160000017', 'fatma@mail.com', CAST(40.8767 AS float), CAST(29.2325 AS float)),
    ('Super Market', 'Atasehir Merkez', 'Istanbul', '02160000018', 'murat@mail.com', CAST(40.9847 AS float), CAST(29.1067 AS float)),
    ('Deniz Manzarasi Kafe', 'Sariyer Merkez', 'Istanbul', '02160000019', 'gamze@mail.com', CAST(41.1667 AS float), CAST(29.0500 AS float)),
    ('Kose Restoran', 'Fatih Merkez', 'Istanbul', '02160000020', 'huseyin@mail.com', CAST(41.0122 AS float), CAST(28.9760 AS float)),
    ('Mini Market', 'Kartal Merkez', 'Istanbul', '02160000021', 'yagmur@mail.com', CAST(40.8886 AS float), CAST(29.1856 AS float)),
    ('Tatli Dunyasi', 'Beyoglu Merkez', 'Istanbul', '02160000022', 'ahmet@mail.com', CAST(41.0370 AS float), CAST(28.9763 AS float)),
    ('Ev Yemekleri', 'Bakirkoy Merkez', 'Istanbul', '02160000023', 'merve@mail.com', CAST(40.9780 AS float), CAST(28.8710 AS float)),
    ('Doga Market', 'Beykoz Merkez', 'Istanbul', '02160000024', 'can@mail.com', CAST(41.1167 AS float), CAST(29.1000 AS float)),
    ('Kitap Kafe', 'Moda Sahil', 'Istanbul', '02160000025', 'zeynep@mail.com', CAST(40.9850 AS float), CAST(29.0250 AS float))
) AS seed(Name, Address, City, Phone, OwnerEmail, Latitude, Longitude)
INNER JOIN Users AS users ON users.Email = seed.OwnerEmail AND users.IsDeleted = 0
WHERE NOT EXISTS (
    SELECT 1
    FROM Restaurants AS existing
    WHERE existing.Name = seed.Name AND existing.IsDeleted = 0
);
GO

INSERT INTO Products (RestaurantId, Name, Description, OriginalPrice, DiscountedPrice, Stock, ExpiryDate, IsActive, Category, IsDeleted, UpdatedAt, CreatedAt, DeletedAt)
SELECT restaurants.Id, seed.Name, seed.Description, seed.OriginalPrice, seed.DiscountedPrice, seed.Stock, seed.ExpiryDate, 1, seed.Category, 0, SYSUTCDATETIME(), SYSUTCDATETIME(), NULL
FROM (VALUES
    ('Lezzet Sofrasi', 'Karisik Pizza', 'Gunluk taze pizza', CAST(200.00 AS decimal(18,2)), CAST(100.00 AS decimal(18,2)), 4, CAST('2026-04-22' AS datetime2), 'Ana Yemek'),
    ('Taze Marketim', 'Tam Bugday Ekmek', 'Aksamdan kalan taze ekmek', CAST(15.00 AS decimal(18,2)), CAST(7.50 AS decimal(18,2)), 20, CAST('2026-04-21' AS datetime2), 'Firincilik'),
    ('Kahve Molasi', 'Latte', 'Gun sonu kahve indirimi', CAST(80.00 AS decimal(18,2)), CAST(40.00 AS decimal(18,2)), 5, CAST('2026-04-21' AS datetime2), 'Icecek'),
    ('Donerci Ali', 'Adana Durum', 'Paket servise hazir', CAST(150.00 AS decimal(18,2)), CAST(80.00 AS decimal(18,2)), 3, CAST('2026-04-21' AS datetime2), 'Fast Food'),
    ('Yesil Bakkal', 'Suzme Yogurt', 'STT yaklasiyor', CAST(60.00 AS decimal(18,2)), CAST(30.00 AS decimal(18,2)), 10, CAST('2026-04-25' AS datetime2), 'Sut Urunleri'),
    ('Gunes Kafe', 'Cilekli Pasta', 'Dilim pasta', CAST(100.00 AS decimal(18,2)), CAST(50.00 AS decimal(18,2)), 2, CAST('2026-04-21' AS datetime2), 'Tatli'),
    ('Anadolu Lokantasi', 'Kuru Fasulye Pilav', 'Porsiyon menu', CAST(120.00 AS decimal(18,2)), CAST(60.00 AS decimal(18,2)), 6, CAST('2026-04-21' AS datetime2), 'Ana Yemek'),
    ('Super Market', 'Organik Yumurta', '10lu paket', CAST(70.00 AS decimal(18,2)), CAST(45.00 AS decimal(18,2)), 8, CAST('2026-04-28' AS datetime2), 'Kahvaltilik'),
    ('Deniz Manzarasi Kafe', 'Soguk Sandvic', 'Ton balikli', CAST(90.00 AS decimal(18,2)), CAST(45.00 AS decimal(18,2)), 12, CAST('2026-04-22' AS datetime2), 'Atistirmalik'),
    ('Kose Restoran', 'Kuzu Sis', 'Izgara menu', CAST(300.00 AS decimal(18,2)), CAST(180.00 AS decimal(18,2)), 2, CAST('2026-04-21' AS datetime2), 'Izgara'),
    ('Mini Market', 'Muz (1 Kg)', 'Olgunlasmis tatli muz', CAST(50.00 AS decimal(18,2)), CAST(25.00 AS decimal(18,2)), 15, CAST('2026-04-23' AS datetime2), 'Meyve'),
    ('Tatli Dunyasi', 'Brownie', 'Ev yapimi', CAST(70.00 AS decimal(18,2)), CAST(35.00 AS decimal(18,2)), 7, CAST('2026-04-22' AS datetime2), 'Tatli'),
    ('Ev Yemekleri', 'Zeytinyagli Sarma', 'Gunluk yapim', CAST(110.00 AS decimal(18,2)), CAST(55.00 AS decimal(18,2)), 9, CAST('2026-04-22' AS datetime2), 'Ev Yemegi'),
    ('Doga Market', 'Beyaz Peynir', 'Yarim yagli', CAST(140.00 AS decimal(18,2)), CAST(90.00 AS decimal(18,2)), 4, CAST('2026-05-01' AS datetime2), 'Sut Urunleri'),
    ('Kitap Kafe', 'Bitki Cayi', 'Fincan servis', CAST(50.00 AS decimal(18,2)), CAST(25.00 AS decimal(18,2)), 10, CAST('2026-04-21' AS datetime2), 'Icecek')
) AS seed(RestaurantName, Name, Description, OriginalPrice, DiscountedPrice, Stock, ExpiryDate, Category)
INNER JOIN Restaurants AS restaurants ON restaurants.Name = seed.RestaurantName AND restaurants.IsDeleted = 0
WHERE NOT EXISTS (
    SELECT 1
    FROM Products AS existing
    WHERE existing.Name = seed.Name
      AND existing.RestaurantId = restaurants.Id
      AND existing.IsDeleted = 0
);
GO

SELECT COUNT(*) AS UsersCount FROM Users WHERE IsDeleted = 0;
SELECT COUNT(*) AS RestaurantsCount FROM Restaurants WHERE IsDeleted = 0;
SELECT COUNT(*) AS ProductsCount FROM Products WHERE IsDeleted = 0;
GO
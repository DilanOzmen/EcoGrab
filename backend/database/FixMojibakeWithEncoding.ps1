$ErrorActionPreference = 'Stop'

$Server = 'foodwastedb.database.windows.net'
$Database = 'foodwastedb'
$User = 'foodwastedb'
$Password = 'Bacilar2023'

$ConnectionString = "Server=tcp:$Server,1433;Initial Catalog=$Database;Persist Security Info=False;User ID=$User;Password=$Password;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
$Connection = New-Object System.Data.SqlClient.SqlConnection
$Connection.ConnectionString = $ConnectionString
$Connection.Open()

$targets = @(
    @{ Table = 'Users'; Column = 'FullName' },
    @{ Table = 'Restaurants'; Column = 'Name' },
    @{ Table = 'Restaurants'; Column = 'Address' },
    @{ Table = 'Restaurants'; Column = 'City' },
    @{ Table = 'Products'; Column = 'Category' },
    @{ Table = 'Products'; Column = 'Name' },
    @{ Table = 'Products'; Column = 'Description' }
)

$cp1254 = [System.Text.Encoding]::GetEncoding(1254)
$utf8 = [System.Text.Encoding]::UTF8

function Convert-MojibakeToTurkish {
    param([string]$Text)

    if ([string]::IsNullOrEmpty($Text)) {
        return $Text
    }

    $bytes = $cp1254.GetBytes($Text)
    $decoded = $utf8.GetString($bytes)

    if ([string]::IsNullOrEmpty($decoded)) {
        return $Text
    }

    return $decoded
}

try {
    foreach ($target in $targets) {
        $table = $target.Table
        $column = $target.Column

        $selectSql = "SELECT [Id], [$column] FROM [$table] WHERE [$column] IS NOT NULL AND (CHARINDEX(NCHAR(195), [$column]) > 0 OR CHARINDEX(NCHAR(196), [$column]) > 0 OR CHARINDEX(NCHAR(197), [$column]) > 0);"
        $selectCmd = $Connection.CreateCommand()
        $selectCmd.CommandText = $selectSql
        $selectCmd.CommandTimeout = 600

        $reader = $selectCmd.ExecuteReader()
        $rows = @()
        while ($reader.Read()) {
            $rows += [PSCustomObject]@{
                Id = [int]$reader['Id']
                Value = [string]$reader[$column]
            }
        }
        $reader.Close()

        $updated = 0
        foreach ($row in $rows) {
            $fixed = Convert-MojibakeToTurkish -Text $row.Value
            if ($fixed -ne $row.Value) {
                $updateSql = "UPDATE [$table] SET [$column] = @value WHERE [Id] = @id;"
                $updateCmd = $Connection.CreateCommand()
                $updateCmd.CommandText = $updateSql
                $updateCmd.CommandTimeout = 600
                [void]$updateCmd.Parameters.Add('@value', [System.Data.SqlDbType]::NVarChar, -1)
                [void]$updateCmd.Parameters.Add('@id', [System.Data.SqlDbType]::Int)
                $updateCmd.Parameters['@value'].Value = $fixed
                $updateCmd.Parameters['@id'].Value = $row.Id
                [void]$updateCmd.ExecuteNonQuery()
                $updated++
            }
        }

        Write-Host "$table.$column updated=$updated" -ForegroundColor Cyan
    }

    $verifyCmd = $Connection.CreateCommand()
    $verifyCmd.CommandText = @"
SELECT 'Users.FullName' AS FieldName, COUNT(*) AS BadCount FROM Users WHERE CHARINDEX(NCHAR(195), FullName) > 0 OR CHARINDEX(NCHAR(196), FullName) > 0 OR CHARINDEX(NCHAR(197), FullName) > 0
UNION ALL
SELECT 'Restaurants.Name', COUNT(*) FROM Restaurants WHERE CHARINDEX(NCHAR(195), Name) > 0 OR CHARINDEX(NCHAR(196), Name) > 0 OR CHARINDEX(NCHAR(197), Name) > 0
UNION ALL
SELECT 'Restaurants.Address', COUNT(*) FROM Restaurants WHERE CHARINDEX(NCHAR(195), Address) > 0 OR CHARINDEX(NCHAR(196), Address) > 0 OR CHARINDEX(NCHAR(197), Address) > 0
UNION ALL
SELECT 'Restaurants.City', COUNT(*) FROM Restaurants WHERE CHARINDEX(NCHAR(195), City) > 0 OR CHARINDEX(NCHAR(196), City) > 0 OR CHARINDEX(NCHAR(197), City) > 0
UNION ALL
SELECT 'Products.Category', COUNT(*) FROM Products WHERE CHARINDEX(NCHAR(195), Category) > 0 OR CHARINDEX(NCHAR(196), Category) > 0 OR CHARINDEX(NCHAR(197), Category) > 0
UNION ALL
SELECT 'Products.Name', COUNT(*) FROM Products WHERE CHARINDEX(NCHAR(195), Name) > 0 OR CHARINDEX(NCHAR(196), Name) > 0 OR CHARINDEX(NCHAR(197), Name) > 0
UNION ALL
SELECT 'Products.Description', COUNT(*) FROM Products WHERE CHARINDEX(NCHAR(195), Description) > 0 OR CHARINDEX(NCHAR(196), Description) > 0 OR CHARINDEX(NCHAR(197), Description) > 0;
"@
    $verifyCmd.CommandTimeout = 600

    $verifyReader = $verifyCmd.ExecuteReader()
    while ($verifyReader.Read()) {
        Write-Host ($verifyReader['FieldName'].ToString() + '=' + $verifyReader['BadCount'].ToString()) -ForegroundColor Yellow
    }
    $verifyReader.Close()
}
finally {
    $Connection.Close()
    $Connection.Dispose()
}

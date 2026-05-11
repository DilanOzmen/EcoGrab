// Geçici test dosyası
// Çalıştır: dotnet-script TestHash.cs veya csc ile derle
using BCrypt.Net;

var password = args.Length > 0 ? args[0] : "Abcd1234!";
var hash = BCrypt.Net.BCrypt.HashPassword(password, 11);
var verified = BCrypt.Net.BCrypt.Verify(password, hash);
Console.WriteLine($"Password: [{password}]");
Console.WriteLine($"Hash: {hash}");
Console.WriteLine($"Verify: {verified}");

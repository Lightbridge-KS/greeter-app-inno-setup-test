using Microsoft.Extensions.Configuration;

var configuration = new ConfigurationBuilder()
    .SetBasePath(AppContext.BaseDirectory)
    .AddJsonFile("appsettings.json", optional: false, reloadOnChange: false)
    .Build();

var greeting = configuration["Greeting"] ?? "Hello";
var recipient = configuration["Recipient"] ?? "World";

Console.WriteLine($"{greeting}, {recipient}!");
Console.WriteLine($"App Version: {configuration["AppVersion"] ?? "unknown"}");
Console.WriteLine($"Install Path: {AppContext.BaseDirectory}");

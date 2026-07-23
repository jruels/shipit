using System.Net;
using System.Net.Http.Json;
using Microsoft.AspNetCore.Mvc.Testing;
using Xunit;

namespace ShipIt.Tests;

public class ShipmentApiTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;

    public ShipmentApiTests(WebApplicationFactory<Program> factory) => _factory = factory;

    [Fact]
    public async Task Lists_the_seeded_shipments()
    {
        var client = _factory.CreateClient();
        var items = await client.GetFromJsonAsync<List<ShipmentDto>>("/api/shipments");
        Assert.NotNull(items);
        Assert.True(items!.Count >= 2);
    }

    [Fact]
    public async Task Creates_a_shipment()
    {
        var client = _factory.CreateClient();
        var response = await client.PostAsJsonAsync("/api/shipments", new { destination = "Denver" });
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);

        var created = await response.Content.ReadFromJsonAsync<ShipmentDto>();
        Assert.NotNull(created);
        Assert.Equal("Denver", created!.Destination);
        Assert.False(string.IsNullOrWhiteSpace(created.Id));
    }

    [Fact]
    public async Task Rejects_an_empty_destination()
    {
        var client = _factory.CreateClient();
        var response = await client.PostAsJsonAsync("/api/shipments", new { destination = "" });
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    private record ShipmentDto(string Id, string Destination, string Status, DateTimeOffset CreatedAt);
}

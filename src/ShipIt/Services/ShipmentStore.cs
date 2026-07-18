using System.Collections.Concurrent;
using ShipIt.Models;

namespace ShipIt.Services;

/// <summary>
/// In-memory shipment store. Deliberately simple: no database, so the app runs
/// anywhere with no dependencies. Seeded with a couple of shipments so the API
/// and the CI tests have something to read.
/// </summary>
public class ShipmentStore
{
    private readonly ConcurrentDictionary<string, Shipment> _items = new();

    public ShipmentStore()
    {
        Add("Seattle");
        Add("Austin");
    }

    public IReadOnlyCollection<Shipment> All() =>
        _items.Values.OrderBy(s => s.CreatedAt).ToList();

    public Shipment? Get(string id) =>
        _items.TryGetValue(id, out var shipment) ? shipment : null;

    public Shipment Add(string destination)
    {
        var shipment = new Shipment(
            Id: Guid.NewGuid().ToString("N")[..8],
            Destination: destination,
            Status: "created",
            CreatedAt: DateTimeOffset.UtcNow);
        _items[shipment.Id] = shipment;
        return shipment;
    }
}

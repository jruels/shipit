namespace ShipIt.Models;

/// <summary>A tracked shipment. Immutable; the store creates new ones.</summary>
public record Shipment(string Id, string Destination, string Status, DateTimeOffset CreatedAt);

/// <summary>Request body for creating a shipment.</summary>
public record ShipmentInput(string Destination);

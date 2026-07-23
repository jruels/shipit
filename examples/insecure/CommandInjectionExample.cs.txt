// Lab 4, Step 6 — copy ONE of these into src/ShipIt/Program.cs (next to the other
// app.MapGet(...) calls), open a PR, and watch the CodeQL check react.
//
// You also need this using at the top of Program.cs:
//     using System.Diagnostics;

// ---------------------------------------------------------------------------
// VULNERABLE — CodeQL flags this as command injection (cs/command-line-injection).
// The route parameter {host} flows unmodified into a shell command line.
// ---------------------------------------------------------------------------
app.MapGet("/trace/{host}", (string host) =>
{
    // BAD: user input concatenated into a shell command.
    Process.Start("/bin/sh", $"-c \"ping -c 1 {host}\"");
    return Results.Ok($"tracing {host}");
});

// ---------------------------------------------------------------------------
// FIXED — no shell, and the input is validated. CodeQL no longer flags it.
// ---------------------------------------------------------------------------
app.MapGet("/trace/{host}", (string host) =>
{
    // Only allow simple hostnames; run the binary directly with an argument list
    // (no shell = nothing to inject into).
    if (!System.Text.RegularExpressions.Regex.IsMatch(host, "^[A-Za-z0-9.-]{1,253}$"))
        return Results.BadRequest("invalid host");

    var psi = new ProcessStartInfo("ping");
    psi.ArgumentList.Add("-c");
    psi.ArgumentList.Add("1");
    psi.ArgumentList.Add(host);
    Process.Start(psi);
    return Results.Ok($"tracing {host}");
});

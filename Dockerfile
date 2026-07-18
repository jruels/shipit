FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY src/ShipIt/ShipIt.csproj src/ShipIt/
RUN dotnet restore src/ShipIt/ShipIt.csproj
COPY . .
RUN dotnet publish src/ShipIt -c Release -o /app --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
COPY --from=build /app .
USER $APP_UID
ENTRYPOINT ["dotnet", "ShipIt.dll"]

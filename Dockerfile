# build stage: compile and publish using the SDK
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# copy the project file and restore first, so this layer stays cached
COPY src/ShipIt/ShipIt.csproj src/ShipIt/
RUN dotnet restore src/ShipIt/ShipIt.csproj

# now copy the rest of the source and publish (no --no-restore: publish
# re-verifies the restore state cheaply when the cache above is warm, and
# without it a real package dependency can fail here with NETSDK1064 on some
# CI runners even though the restore step above reported success)
COPY . .
RUN dotnet publish src/ShipIt -c Release -o /app

# runtime stage: small image, only the published app
FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
COPY --from=build /app .
USER $APP_UID
ENTRYPOINT ["dotnet", "ShipIt.dll"]
# ── Build stage ──
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Restore against the csproj alone so the restore layer is cached until dependencies change.
COPY SRC/SRC.csproj SRC/
RUN dotnet restore SRC/SRC.csproj

# Copy everything else and publish
COPY SRC/ SRC/
RUN dotnet publish SRC/SRC.csproj -c Release -o /app/publish --no-restore

# ── Runtime stage ──
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app
EXPOSE 8080

COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "SRC.dll"]

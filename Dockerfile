# The auth service (SCRUM-34): issues the tokens every other Wonrich service validates.
#
# The project lives in SRC/ and its assembly is named SRC, so the published entry point is SRC.dll
# rather than a name matching the service.

# ── Build stage ──
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# csproj first, so the restore layer is cached against the dependency list alone and a source-only
# change does not re-run restore. This project has no ProjectReferences, so it is the only one.
COPY SRC/SRC.csproj SRC/
RUN dotnet restore SRC/SRC.csproj

COPY SRC/ SRC/
RUN dotnet publish SRC/SRC.csproj -c Release -o /app/publish --no-restore

# ── Runtime stage ──
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app
EXPOSE 8080

COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "SRC.dll"]

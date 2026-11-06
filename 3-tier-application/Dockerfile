
FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src

COPY api/ ./api/

WORKDIR /src/api/Basic3TierAPI

RUN dotnet restore Basic3TierAPI.csproj
RUN dotnet build Basic3TierAPI.csproj -c Release -o /app/build

FROM build AS publish
RUN dotnet publish Basic3TierAPI.csproj -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Basic3TierAPI.dll"]

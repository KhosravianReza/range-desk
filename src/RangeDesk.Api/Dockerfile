# API + Angular shell in one image. Build context: the repo root.
#   docker build -f src/RangeDesk.Api/Dockerfile -t rangedesk-api:local .

# Stage 1: build Angular into static files
FROM node:24-alpine AS web
WORKDIR /src/web
COPY src/RangeDesk.Web/package.json src/RangeDesk.Web/package-lock.json ./
RUN npm ci
COPY src/RangeDesk.Web/ ./
RUN npx ng build

# Stage 2: build and publish the API
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY global.json Directory.Build.props Directory.Packages.props .editorconfig ./
COPY src/RangeDesk.Api/RangeDesk.Api.csproj src/RangeDesk.Api/
RUN dotnet restore src/RangeDesk.Api/RangeDesk.Api.csproj
COPY src/RangeDesk.Api/ src/RangeDesk.Api/
RUN dotnet publish src/RangeDesk.Api/RangeDesk.Api.csproj -c Release -o /out --no-restore

# Stage 3: runtime only: no SDK, no Node, no source code
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app
COPY --from=build /out ./
COPY --from=web /src/web/dist/rangedesk-web/browser ./wwwroot
USER $APP_UID
EXPOSE 8080
ENTRYPOINT ["dotnet", "RangeDesk.Api.dll"]

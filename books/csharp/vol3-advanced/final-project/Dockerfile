# syntax=docker/dockerfile:1
# ---------- Stage 1: build & publish (SDK image, ~1 GB, not shipped) ----------
FROM mcr.microsoft.com/dotnet/sdk:10.0.401 AS build
WORKDIR /src

# Copy only project files first -> "dotnet restore" layer is cached until a .csproj changes.
COPY global.json Directory.Build.props TaskBoard.slnx ./
COPY src/TaskBoard.Domain/TaskBoard.Domain.csproj src/TaskBoard.Domain/
COPY src/TaskBoard.Application/TaskBoard.Application.csproj src/TaskBoard.Application/
COPY src/TaskBoard.Infrastructure/TaskBoard.Infrastructure.csproj src/TaskBoard.Infrastructure/
COPY src/TaskBoard.Api/TaskBoard.Api.csproj src/TaskBoard.Api/
# Optional secret "ca_bundle": only needed behind a TLS-inspecting corporate proxy
# (see README). Without the secret this is a normal "dotnet restore".
RUN --mount=type=secret,id=ca_bundle,required=false \
    if [ -f /run/secrets/ca_bundle ]; then export SSL_CERT_FILE=/run/secrets/ca_bundle; fi && \
    dotnet restore src/TaskBoard.Api/TaskBoard.Api.csproj

# Copy the source and publish a Release build.
COPY src/ src/
RUN dotnet publish src/TaskBoard.Api/TaskBoard.Api.csproj -c Release -o /app/publish --no-restore

# ---------- Stage 2: runtime (ASP.NET Core runtime only, much smaller) ----------
FROM mcr.microsoft.com/dotnet/aspnet:10.0.12 AS final
WORKDIR /app

# The SQLite file lives in /app/data (mount a volume here to keep data).
RUN mkdir -p /app/data && chown app:app /app/data
ENV ASPNETCORE_HTTP_PORTS=8080 \
    ConnectionStrings__TaskBoard="Data Source=/app/data/taskboard.db"

COPY --from=build /app/publish .

# Run as the non-root "app" user that the official .NET images provide.
USER app
EXPOSE 8080
ENTRYPOINT ["dotnet", "TaskBoard.Api.dll"]

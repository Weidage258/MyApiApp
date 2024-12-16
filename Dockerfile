# 使用官方 .NET 运行时镜像作为基础镜像
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80

# 使用 SDK 镜像来构建应用程序
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["MyApiApp/MyApiApp.csproj", "MyApiApp/"]
RUN dotnet restore "MyApiApp/MyApiApp.csproj"
COPY . .
WORKDIR "/src/MyApiApp"
RUN dotnet build "MyApiApp.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "MyApiApp.csproj" -c Release -o /app/publish

# 生成最终的镜像
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "MyApiApp.dll"]
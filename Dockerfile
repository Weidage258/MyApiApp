# 使用官方 .NET 运行时镜像作为基础镜像
FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 44375

# 使用 SDK 镜像来构建应用程序
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src

# 复制 MyApiApp 项目的 csproj 文件
COPY ./MyApiApp/MyApiApp.csproj /src/MyApiApp/

# 设置当前工作目录为 MyApiApp 并恢复依赖项
WORKDIR /src/MyApiApp
RUN dotnet restore

# 复制整个 MyApiApp 项目文件到容器
COPY ./src/MyApiApp/

# 构建项目
RUN dotnet build -c Release -o /app/build

# 发布应用程序
RUN dotnet publish -c Release -o /app/publish

# 使用运行时镜像
FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS runtime
WORKDIR /app

# 复制发布的应用程序文件
COPY --from=build /app/publish .

# 设置 ASP.NET Core 环境变量，监听 44375 端口
ENV ASPNETCORE_URLS=http://+:44375

# 设置容器启动命令
ENTRYPOINT ["dotnet", "MyApiApp.dll"]
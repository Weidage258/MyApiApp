# 使用官方 .NET 运行时镜像作为基础镜像
FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 44375

# 使用 SDK 镜像来构建应用程序
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src

# 复制主应用程序项目文件到容器中
COPY MyApiApp/MyApiApp.csproj /src/MyApiApp/

# 进入 /src 目录并恢复项目依赖
WORKDIR /src
RUN dotnet restore

# 复制主应用程序代码到容器中
COPY MyApiApp /src/MyApiApp

# 构建主应用程序
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

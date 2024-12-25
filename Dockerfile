# 使用官方 .NET 运行时镜像作为基础镜像
FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 44375

# 使用 SDK 镜像来构建应用程序
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src

# 复制解决方案文件到容器中
COPY MyApiApp/MyApiApp.sln /src/

# 复制 MyApiApp 和 MyApiTest 的项目文件到容器中
COPY MyApiApp/MyApiApp.csproj /src/MyApiApp/
COPY myApiTest/myApiTest.csproj /src/myApiTest/

# 恢复项目的依赖
WORKDIR /src
RUN dotnet restore /src/MyApiApp.sln

# 复制整个项目文件夹到容器中
COPY . /src/

# 构建解决方案
RUN dotnet build /src/MyApiApp.sln -c Release -o /app/build

# 发布应用程序
RUN dotnet publish /src/MyApiApp.sln -c Release -o /app/publish

# 使用运行时镜像
FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS runtime

WORKDIR /app
COPY --from=build /app/publish .

# 设置 ASP.NET Core 环境变量，监听 44375 端口
ENV ASPNETCORE_URLS=http://+:44375

# 设置容器启动命令
ENTRYPOINT ["dotnet", "MyApiApp.dll"]

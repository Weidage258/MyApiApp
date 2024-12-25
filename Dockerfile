9__wV1P58Rh0mX2k66ry 


# 使用官方 .NET 运行时镜像作为基础镜像
FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 44375

# 使用 SDK 镜像来构建应用程序
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src

# 复制 MyApiApp.csproj 文件到容器中的 /src 目录
COPY MyApiApp.csproj /src/

# 进入 /src 目录并恢复项目依赖
WORKDIR /src
RUN dotnet restore

# 复制整个 MyApiApp 文件夹到容器
COPY . /src/

# 构建项目
RUN dotnet build -c Release -o /app/build

# 发布应用程序
RUN dotnet publish -c Release -o /app/publish

# 使用运行时镜像
FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS runtime

# 设置工作目录
WORKDIR /app

# 复制发布的应用程序文件
COPY --from=build /app/publish .

# 设置 ASP.NET Core 环境变量，监听 44375 端口
ENV ASPNETCORE_URLS=http://+:44375

# 设置容器启动命令
ENTRYPOINT ["dotnet", "MyApiApp.dll"]

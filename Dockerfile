# 使用官方 .NET 运行时镜像作为基础镜像
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 44375

# 使用 SDK 镜像来构建应用程序
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src

# 复制 MyApiApp.csproj 文件到容器中的 /src/MyApiApp 目录
COPY ["MyApiApp/MyApiApp.csproj", "MyApiApp/"]

# 恢复依赖项
RUN dotnet restore "MyApiApp/MyApiApp.csproj"

# 复制项目文件到容器（包括源代码和其他文件）
COPY . .

# 设置工作目录为 MyApiApp
WORKDIR "/src/MyApiApp"

# 构建应用
RUN dotnet build "MyApiApp.csproj" -c Release -o /app/build

# 发布应用
FROM build AS publish
RUN dotnet publish "MyApiApp.csproj" -c Release -o /app/publish

# 生成最终的镜像
FROM base AS final
WORKDIR /app

# 从构建阶段复制发布的文件到最终镜像
COPY --from=publish /app/publish .

# 设置容器启动时执行的命令
ENTRYPOINT ["dotnet", "MyApiApp.dll"]

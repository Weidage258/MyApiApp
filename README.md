# MyApiApp，.github/workflows编写

### 步骤一：创建简单的 .NET Core Web API 项目

首先，我们需要创建一个简单的 .NET Core Web API 项目。可以在本地开发环境中创建并推送到 GitHub 仓库，或者直接在 GitHub 上创建一个新的仓库并开始开发。

#### 1. 创建 .NET Core Web API 项目

在你的开发环境中（假设你已经安装了 .NET SDK），可以通过以下命令创建一个新的 .NET Core Web API 项目：

```
bashCopy Codedotnet new webapi -n MyApiApp
cd MyApiApp
```

这个命令会创建一个名为 `MyApiApp` 的 Web API 项目，里面包含一个默认的 `WeatherForecastController`。

#### 2. 推送到 GitHub 仓库

1. 在 GitHub 上创建一个新的仓库（例如 `myapiapp`）。
2. 将本地代码推送到 GitHub 上：

```
bashCopy Codegit init
git remote add origin https://github.com/your-username/myapiapp.git
git add .
git commit -m "Initial commit"
git push -u origin master
```

### 步骤二：编写 `Dockerfile` 来容器化项目

为了在 Docker 容器中运行该应用程序，我们需要编写一个 `Dockerfile`。在项目根目录下创建一个 `Dockerfile` 文件，内容如下：

```
dockerfileCopy Code# 使用官方 .NET 运行时镜像作为基础镜像
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
```

### 解释 `Dockerfile` 各个部分：

1. **基础镜像**：使用官方的 .NET 6.0 运行时镜像 `aspnet:6.0` 作为基础镜像，这样我们只需要包含应用运行所需的环境。
2. **构建镜像**：使用 `dotnet/sdk:6.0` 镜像来构建应用。首先恢复依赖（`dotnet restore`），然后构建和发布应用（`dotnet build` 和 `dotnet publish`）。
3. **最终镜像**：将构建好的应用复制到最终的运行镜像中，并通过 `ENTRYPOINT` 指定容器启动时运行的命令。

### 步骤三：配置 GitHub Actions

我们将使用 GitHub Actions 来实现自动化构建和部署。以下是我们需要的配置：

#### 1. 创建 GitHub Actions 配置文件

在 GitHub 仓库中创建 `.github/workflows/deploy.yml` 文件，定义 CI/CD 工作流：

```
yamlCopy Codename: CI/CD Pipeline

on:
  push:
    branches:
      - main  # 触发事件：每次推送到 main 分支

jobs:
  build:
    runs-on: ubuntu-latest  # 在 Ubuntu 环境中运行

    steps:
      # Step 1: Checkout 代码
      - name: Checkout code
        uses: actions/checkout@v2

      # Step 2: 设置 Docker Buildx（用于构建 Docker 镜像）
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      # Step 3: Docker Hub 登录（通过 GitHub Secrets 存储 Docker Hub 用户名和访问令牌）
      - name: Log in to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_ACCESS_TOKEN }}

      # Step 4: 构建 Docker 镜像
      - name: Build Docker image
        run: |
          docker build -t ${{ secrets.DOCKER_USERNAME }}/myapiapp:latest .

      # Step 5: 推送 Docker 镜像到 Docker Hub
      - name: Push Docker image
        run: |
          docker push ${{ secrets.DOCKER_USERNAME }}/myapiapp:latest

  deploy:
    runs-on: ubuntu-latest
    needs: build  # 确保部署是在构建之后执行

    steps:
      # Step 6: Checkout 代码
      - name: Checkout code
        uses: actions/checkout@v2

      # Step 7: 部署到阿里云服务器
      - name: Deploy Docker image to Alibaba Cloud server
        run: |
          ssh -o StrictHostKeyChecking=no ${{ secrets.SSH_USERNAME }}@${{ secrets.SERVER_IP }} << 'EOF'
            docker pull ${{ secrets.DOCKER_USERNAME }}/myapiapp:latest
            docker stop myapiapp-container || true
            docker rm myapiapp-container || true
            docker run -d --name myapiapp-container -p 80:80 ${{ secrets.DOCKER_USERNAME }}/myapiapp:latest
          EOF
```

### 工作流说明：

1. **`on.push`**：当有新的提交推送到 `main` 分支时触发工作流。

2. `build` job

   ：

   - **Checkout 代码**：拉取代码到运行环境。
   - **设置 Docker Buildx**：支持构建多平台镜像。
   - **Docker 登录**：登录到 Docker Hub，使用存储在 GitHub Secrets 中的 Docker Hub 用户名和访问令牌。
   - **构建 Docker 镜像**：使用 `docker build` 命令构建 Docker 镜像。
   - **推送 Docker 镜像**：将构建好的镜像推送到 Docker Hub。

3. `deploy` job

   ：

   - **Checkout 代码**：再次拉取代码。
   - **部署到阿里云服务器**：通过 SSH 登录到阿里云的 Ubuntu 服务器，拉取 Docker 镜像并启动容器。

### 步骤四：配置 GitHub Secrets

为了保护敏感信息，我们需要在 GitHub 仓库中配置一些 Secrets。

1. **`DOCKER_USERNAME`**：Docker Hub 用户名。
2. **`DOCKER_ACCESS_TOKEN`**：Docker Hub 访问令牌（可以在 Docker Hub 的帐户设置中生成）。
3. **`SSH_USERNAME`**：阿里云服务器的 SSH 用户名（如 `root`）。
4. **`SERVER_IP`**：阿里云服务器的 IP 地址。
5. **`SSH_PRIVATE_KEY`**：用于 SSH 登录的私钥，存储在 GitHub Secrets 中。

### 步骤五：配置阿里云服务器

1. **安装 Docker**：确保你的阿里云 Ubuntu 服务器上已经安装了 Docker。可以通过以下命令安装 Docker：

   ```
   sudo apt update
   sudo apt install -y docker.io
   sudo systemctl enable --now docker
   ```

2. **允许远程 SSH 登录**：确保服务器允许通过 SSH 登录，且你能够将私钥添加到 GitHub Secrets 中。

### 总结

1. 创建并推送一个简单的 .NET Core Web API 项目到 GitHub。
2. 编写 `Dockerfile` 将该应用容器化。
3. 在 GitHub Actions 中配置自动构建 Docker 镜像并推送到 Docker Hub。
4. 配置 GitHub Actions 通过 SSH 将 Docker 镜像部署到阿里云服务器。

每次你将代码推送到 `main` 分支时，GitHub Actions 将自动构建并部署该应用程序。

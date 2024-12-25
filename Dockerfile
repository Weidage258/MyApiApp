FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 44375

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src

COPY MyApiApp/MyApiApp.sln ./
COPY MyApiApp/MyApiApp.csproj ./MyApiApp/
COPY myApiTest/myApiTest.csproj ./myApiTest/

RUN dotnet restore MyApiApp.sln
COPY . .
RUN dotnet build MyApiApp.sln -c Release -o /app/build
RUN dotnet publish MyApiApp.sln -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .
ENV ASPNETCORE_URLS=http://+:44375
ENTRYPOINT ["dotnet", "MyApiApp.dll"]
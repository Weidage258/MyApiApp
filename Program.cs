var builder = WebApplication.CreateBuilder(args);



// Add services to the container.
builder.Services.AddControllers();

// Swagger/OpenAPI 配置
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// 配置中间件
app.UseSwagger();
app.UseSwaggerUI();

// 在开发环境中不使用 HTTPS 重定向
if (!app.Environment.IsDevelopment())
{
  //  app.UseHttpsRedirection();
}

app.UseAuthorization();
app.MapControllers();

app.Run();
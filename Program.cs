var builder = WebApplication.CreateBuilder(args);



// Add services to the container.
builder.Services.AddControllers();

// Swagger/OpenAPI ����
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// �����м��
app.UseSwagger();
app.UseSwaggerUI();

// �ڿ��������в�ʹ�� HTTPS �ض���
if (!app.Environment.IsDevelopment())
{
  //  app.UseHttpsRedirection();
}

app.UseAuthorization();
app.MapControllers();

app.Run();
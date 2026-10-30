var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddOpenApi();

var app = builder.Build();

app.UseDefaultFiles(); // Rewrites "/" to "/index.html", then:
app.UseStaticFiles(); // Serves files from wwwroot/

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.Run();

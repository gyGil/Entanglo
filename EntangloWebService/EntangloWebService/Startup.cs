/// \file  Startup
///
/// Major <b>Startup.cs</b>
/// \details <b>Details</b>
/// -   This file starts up / runs the project. Before running it handles the configuration
///     of the applications services and HTTP pipeline. Also sets up the initial database
///     connection.
///   
/// <ul><li>\author     Geunyoung Gil & Marcus Rankin</li>
///     <li>\copyright  Entanglo - BillClub</li>"
/// </ul>

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Http;
using DatabaseServices;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Rewrite;
using Microsoft.AspNetCore.Identity;
using System.IdentityModel.Tokens.Jwt;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using DomainModels;
using System.Text;

namespace EntangloWebService
{
    public class Startup
    {
        static public bool exception = false;

        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }


        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            // Allow to CORS
            services.AddCors(options =>
            {
                options.AddPolicy("AllowLocalhostOrigin",
                    builder => builder.AllowAnyOrigin());
            });

            // Add Entity Framework Database Context
            services.AddDbContext<EntangloDbContext>(options =>
                options.UseNpgsql(Configuration.GetConnectionString("MainConnection"), b => b.MigrationsAssembly("EntangloWebService")));

            services.AddIdentity<ApplicationUser, IdentityRole>()
                .AddEntityFrameworkStores<EntangloDbContext>()
                .AddDefaultTokenProviders();

            services.Configure<IdentityOptions>(options =>
            {
                // Password settings
                options.Password.RequireDigit = true;
                options.Password.RequiredLength = 8;
                options.Password.RequireNonAlphanumeric = false;
                options.Password.RequireUppercase = true;
                options.Password.RequireLowercase = false;
                options.Password.RequiredUniqueChars = 6;

                // Lockout settings
                options.Lockout.DefaultLockoutTimeSpan = TimeSpan.FromMinutes(30);
                options.Lockout.MaxFailedAccessAttempts = 10;
                options.Lockout.AllowedForNewUsers = true;

                // User settings
                options.User.RequireUniqueEmail = true;
            });

            services.ConfigureApplicationCookie(options =>
            {
                // Cookie settings
                options.Cookie.HttpOnly = true;
                options.Cookie.Expiration = TimeSpan.FromDays(150);
                options.LoginPath = "/Account/Login"; // If the LoginPath is not set here, ASP.NET Core will default to /Account/Login
                options.LogoutPath = "/Account/Logout"; // If the LogoutPath is not set here, ASP.NET Core will default to /Account/Logout
                options.AccessDeniedPath = "/Account/AccessDenied"; // If the AccessDeniedPath is not set here, ASP.NET Core will default to /Account/AccessDenied
                options.SlidingExpiration = true;
            });



            // Add application services.
            services.AddTransient<IEmailSender, AuthMessageSender>();
            services.AddTransient<ISmsSender, AuthMessageSender>();
            services.Configure<SMSoptions>(Configuration);

            // Add MVC Framework
            services.AddMvc();
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IHostingEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
                app.UseBrowserLink();
                app.UseDatabaseErrorPage();
            }
            else
            {
                Startup.exception = true;
                app.UseExceptionHandler("/Main/Error");
            }

            // Forces HTTPS for all requests (globally)
            var options = new RewriteOptions()
                .AddRedirectToHttps();

            app.UseRewriter(options);

            app.UseStaticFiles();

            app.UseAuthentication();

            app.UseMvc();

            // Shows UserCors with CorsPolicyBuilder
            app.UseCors("AllowLocalhostOrigin");

            app.Run(async (context) =>
            {
                string imagePath = "Nothing";

                // Change background of server to notify of status
                if (Startup.exception)
                {
                    imagePath = "database(error).gif";
                    Startup.exception = false;
                }
                else
                {
                    imagePath = "database.gif";
                }

                byte[] imageBytes = System.IO.File.ReadAllBytes(imagePath);

                await context.Response.Body.WriteAsync(imageBytes, 0, imageBytes.Length);
            });
        }
    }
}

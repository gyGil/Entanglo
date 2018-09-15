/// \file  EntangloDbContext
///
/// Major <b>EntangloDbContext.cs</b>
/// \details <b>Details</b>
/// -   This file sets up the Entanglo database context options and initializes
///     the Users data set.
///   
/// <ul><li>\author     Geunyoung Gil & Marcus Rankin</li>
///     <li>\copyright  Entanglo - BillClub</li>"
/// </ul>

using System;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;
using DomainModels;
using DomainModels.AiModels;


namespace DatabaseServices
{
    public class EntangloDbContext : IdentityDbContext<ApplicationUser>
    {
        public EntangloDbContext(DbContextOptions<EntangloDbContext> options) :
            base(options)
        { }

        protected override void OnModelCreating(ModelBuilder builder)
        {
            base.OnModelCreating(builder);

            // Customize the ASP.NET Identity model and override the defaults if needed.
            // For example, you can rename the ASP.NET Identity table names and more.
            // Add your customizations after calling base.OnModelCreating(builder);

            // Identity Code
            //modelBuilder.Entity<User>().ToTable("user");
            //modelBuilder.Entity<ApplicationUser>().ToTable("appusers");

            // Create table for WordRecom
            builder.Entity<WordRecom>().ToTable("wordrecom");
        }
    }
}

/// \file  Program
///
/// Major <b>Program.cs</b>
/// \details <b>Details</b>
/// -   This file is the web-service solution entry point. It builds the web host and
///     initializes the main Entanglo database context.
///   
/// <ul><li>\author     Geunyoung Gil & Marcus Rankin</li>
///     <li>\copyright  Entanglo - BillClub</li>"
/// </ul>

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.DependencyInjection;
using DatabaseServices;
using Microsoft.Extensions.Configuration;

namespace EntangloWebService
{
    public class Program
    {
        public static void Main(string[] args)
        {
            BuildWebHost(args).Run();
        }

        /// Original Web Host Building Function
        public static IWebHost BuildWebHost(string[] args) =>
            WebHost.CreateDefaultBuilder(args)
                .UseStartup<Startup>()
                .Build();
    }
}
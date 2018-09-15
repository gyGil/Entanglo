/// \file  DbConnectionManager
///
/// Major <b>DbConnectionManager.cs</b>
/// \details <b>Details</b>
/// -   This file handles the configuration and connection string extraction of users
///     databases. 
///     
///     Note: currently not completely implemented. Defaulting.
///   
/// <ul><li>\author     Geun Young Gil & Marcus Rankin</li>
///     <li>\copyright  Entanglo - BillClub</li>"
/// </ul>

using System;
using System.Collections.Generic;
using System.Text;
using Npgsql;
using Microsoft.Extensions.Configuration;
using DomainModels;

namespace DatabaseServices
{
    public class DbConnectionManager
    {
        private string connectionString;

        public string ConnectionString
        {
            get { return connectionString; }
            set
            {
                if (value != null)
                { connectionString = value; }
            }
        }

        private IConfiguration configuration;

        public IConfiguration Configuration
        {
            get { return configuration; }
            set
            {
                if (value != null)
                {
                    configuration = value;
                }
            }
        }

        /// <summary>
        /// For holding current User's information
        /// </summary>
        private User user;

        public User User
        {
            get { return user; }
            set
            {
                if (value != null)
                {
                    user = value;
                }
            }
        }
        /* SHOULD MAKE USER EXIST CHECK AND USER DATA RETRIEVAL FOR GETTING
           USERS DATABASE ID'S, DATABASE NAME LISTING, GROUP ROLES */

        /// <summary>
        /// Constructor: Takes no arguments
        /// </summary>
        public DbConnectionManager()
        {

        }

        /// <summary>
        /// Constructor: If connection string is already known
        /// </summary>
        /// <param name="_connectionString"></param>
        public DbConnectionManager(string _connectionString)
        {
            ConnectionString = _connectionString;
        }

        /// <summary>
        /// Constructor: If the configuration and connection string is already known
        /// </summary>
        /// <param name="_configuration"></param>
        /// <param name="_connectionString"></param>
        public DbConnectionManager(IConfiguration _configuration, string _connectionString)
        {
            Configuration = _configuration;
            ConnectionString = _connectionString;
        }

        /// <summary>
        /// GetUserConnection:  Retrieves a connection to a database of a specific User based
        ///                     on a connection string name that relates to the appsettings.json
        ///                     file.
        /// </summary>
        /// <param name="connection">Connection string name</param>
        /// <param name="configuration">Configuration object</param>
        /// <returns name="pgConn">PostgreSQL database connection</returns>
        public NpgsqlConnection GetUserConnection(string connection, IConfiguration configuration)
        {
            var connectionString = configuration.GetSection("ConnectionStrings").GetSection(connection).Value;

            NpgsqlConnection pgConn = new NpgsqlConnection(connectionString);

            return pgConn;
        }

        
    }
}

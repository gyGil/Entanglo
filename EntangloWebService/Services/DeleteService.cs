/// \file  DeleteService
///
/// Major <b>DeleteService.cs</b>
/// \details <b>Details</b>
/// -   This file handles the interaction between the Delete Controller and the Delete 
///     Repository of the Database Access Library. It sets up the required configuration
///     and user database connection required to query the delete repository.
///   
/// <ul><li>\author     Geun Young Gil & Marcus Rankin</li>
///     <li>\copyright  Entanglo - BillClub</li>"
/// </ul>

using System;
using System.Collections.Generic;
using System.Text;
using Npgsql;
using Microsoft.Extensions.Configuration;
using DataAccessLibrary;
using DomainModels;

namespace DatabaseServices
{
    public class DeleteService
    {
        private IConfiguration configuration;

        private NpgsqlConnection connection;

        public NpgsqlConnection Connection
        {
            get { return connection; }
            set
            {
                if (value != null)
                {
                    connection = value;
                }
            }
        }

        private User user;

        public User User
        {
            get { return user; }
            set
            {
                if (value != null)
                { user = value; }
            }
        }

        /// <summary>
        ///  Create Database connection manager for selecting correct users connection
        /// </summary>
        private DbConnectionManager userConnManager = new DbConnectionManager();


        public DeleteService(IConfiguration _configuration, string userConnection)
        {
            configuration = _configuration;
            Connection = userConnManager.GetUserConnection(userConnection, configuration);
        }

        public string OldUser(User oldUser)
        {
            string queryStatus = "User: " + oldUser.UserName + " not deleted!";

            string response = "Error Deleting Old User";

            bool userDeleted = false;

            DeleteRepo delete = new DeleteRepo(connection);

            try
            {
                response = delete.OldUser(oldUser, user);
                userDeleted = true;
            }
            catch (NpgsqlException pgex)
            {
                throw pgex;
            }
            catch (Exception ex)
            {
                throw ex;
            }

            if (userDeleted)
            {
                queryStatus = "User: " + oldUser.UserName + " deleted successfully!";
            }    

            GC.SuppressFinalize(delete);

            return queryStatus;
        }

        public string Database(Database database)
        {
            string queryStatus = "Database: " + database.DatabaseName + " not deleted!";

            string response = "Error Deleting Database";

            bool dbDeleted = false;

            DeleteRepo delete = new DeleteRepo(connection);

            try
            {
                response = delete.Database(database, user);
                dbDeleted = true;
            }
            catch (NpgsqlException pgex)
            {
                throw pgex;
            }
            catch (Exception ex)
            {
                throw ex;
            }

            if (dbDeleted)
            {
                User.Databases.RemoveAt(User.Databases.IndexOf(database));

                queryStatus = "Database: " + database.DatabaseName + " deleted successfully!";
            }   

            GC.SuppressFinalize(delete);

            return queryStatus;
        }

        public string Table(Table table)
        {
            string queryStatus = "Table: " + table.TableName + " not deleted!";

            string response = "Error Deleting Table";

            bool tableDeleted = false;

            DeleteRepo delete = new DeleteRepo(connection);

            try
            {
                response = delete.Table(table, user);
                tableDeleted = true;
            }
            catch (NpgsqlException pgex)
            {
                throw pgex;
            }
            catch (Exception ex)
            {
                throw ex;
            }

            if (tableDeleted)
            {
                queryStatus = "Table: " + table.TableName + " deleted successfully!";
            }   

            GC.SuppressFinalize(delete);

            return queryStatus;
        }

        public string Column(Column column)
        {
            string queryStatus = "Column: " + column.ColumnName + " not deleted!";

            string response = "Error Deleting Column";

            bool columnDeleted = false;

            DeleteRepo delete = new DeleteRepo(connection);

            try
            {
                response = delete.Column(column, user);
                columnDeleted = true;
            }
            catch (NpgsqlException pgex)
            {
                throw pgex;
            }
            catch (Exception ex)
            {
                throw ex;
            }

            if (columnDeleted)
            {
                queryStatus = "Column: " + column.ColumnName + " deleted successfully!";
            }   

            GC.SuppressFinalize(delete);

            return queryStatus;
        }

        public bool Profile()
        {
            DeleteRepo delete = new DeleteRepo(connection);

            try
            {
                if (delete.Profile())
                    return true;
            }
            catch (NpgsqlException pgex)
            {
                throw pgex;
            }
            catch (Exception ex)
            {
                throw ex;
            }

            GC.SuppressFinalize(delete);

            return false;
        }

        public bool ProfileData()
        {
            DeleteRepo delete = new DeleteRepo(connection);

            try
            {
                if (delete.ProfileData())
                    return true;
            }
            catch (NpgsqlException pgex)
            {
                throw pgex;
            }
            catch (Exception ex)
            {
                throw ex;
            }

            GC.SuppressFinalize(delete);

            return false;
        }

        public bool UserTables()
        {
            DeleteRepo delete = new DeleteRepo(connection);

            try
            {
                if (delete.UserTables())
                    return true;
            }
            catch (NpgsqlException pgex)
            {
                throw pgex;
            }
            catch (Exception ex)
            {
                throw ex;
            }

            GC.SuppressFinalize(delete);

            return false;
        }
    }
}

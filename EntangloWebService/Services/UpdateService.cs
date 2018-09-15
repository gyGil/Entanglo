/// \file  UpdateService
///
/// Major <b>UpdateService.cs</b>
/// \details <b>Details</b>
/// -   This file handles the interaction between the Update Controller and the Update 
///     Repository of the Database Access Library. It sets up the required configuration
///     and user database connection required to query the update repository.
///   
/// <ul><li>\author     Geun Young Gil & Marcus Rankin</li>
///     <li>\copyright  Entanglo - BillClub</li>"
/// </ul>

using System;
using System.Collections.Generic;
using System.Text;
using Microsoft.Extensions.Configuration;
using Npgsql;
using DomainModels;
using DataAccessLibrary;

namespace DatabaseServices
{
    public class UpdateService
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

        private DbConnectionManager userConnManager = new DbConnectionManager();

        public UpdateService(IConfiguration _configuration, string userConnection)
        {
            configuration = _configuration;
            Connection = userConnManager.GetUserConnection(userConnection, configuration);
        }

        public string OldUser(User oldUser)
        {
            string queryStatus = "User: " + oldUser.UserName + " not updated!";

            string response = "Error Updating Existing User";

            bool userUpdated = false;

            UpdateRepo update = new UpdateRepo(connection);

            try
            {
                response = update.User(oldUser, user);
                userUpdated = true;
            }
            catch (NpgsqlException pgex)
            {
                throw pgex;
            }
            catch (Exception ex)
            {
                throw ex;
            }

            if (userUpdated)
            {
                queryStatus = "User: " + oldUser.UserName + " updated successfully!";
            }    /// Note: need to add database ID too but not sure what that will look like right now

            GC.SuppressFinalize(update);

            return queryStatus;
        }

        public string Database(Database database)
        {
            string queryStatus = "Database: " + database.DatabaseName + " not updated!";

            string response = "Error Updating Existing Database";

            bool dbUpdated = false;

            UpdateRepo update = new UpdateRepo(connection);

            try
            {
                response = update.Database(database, user);
                dbUpdated = true;
            }
            catch (NpgsqlException pgex)
            {
                throw pgex;
            }
            catch (Exception ex)
            {
                throw ex;
            }

            if (dbUpdated)
            {
                queryStatus = "Database: " + database.DatabaseName + " updated successfully!";
            }    /// Note: need to add database ID too but not sure what that will look like right now

            GC.SuppressFinalize(update);

            return queryStatus;
        }

        public string Table(Table table)
        {
            string queryStatus = "Table: " + table.TableName + " not updated!";

            string response = "Error Updating Existing Table";

            bool tableUpdated = false;

            UpdateRepo update = new UpdateRepo(connection);

            try
            {
                response = update.Table(table, user);
                tableUpdated = true;
            }
            catch (NpgsqlException pgex)
            {
                throw pgex;
            }
            catch (Exception ex)
            {
                throw ex;
            }

            if (tableUpdated)
            {
                queryStatus = "Table: " + table.TableName + " updated successfully!";
            }    /// Note: need to add database ID too but not sure what that will look like right now

            GC.SuppressFinalize(update);

            return queryStatus;
        }

        public string Column(Column column)
        {
            string queryStatus = "Column: " + column.ColumnName + " not updated!";

            string response = "Error Updating Existing Column";

            bool columnUpdated = false;

            UpdateRepo update = new UpdateRepo(connection);

            try
            {
                response = update.Column(column, user);
                columnUpdated = true;
            }
            catch (NpgsqlException pgex)
            {
                throw pgex;
            }
            catch (Exception ex)
            {
                throw ex;
            }

            if (columnUpdated)
            {
                queryStatus = "Column: " + column.ColumnName + " udpated successfully!";
            }    /// Note: need to add database ID too but not sure what that will look like right now

            GC.SuppressFinalize(update);

            return queryStatus;
        }
    }
}

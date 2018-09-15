/// \file  ReadService
///
/// Major <b>ReadService.cs</b>
/// \details <b>Details</b>
/// -   This file handles the interaction between the Read Controller and the Read 
///     Repository of the Database Access Library. It sets up the required configuration
///     and user database connection required to query the read repository.
///     
///     Note: future implementations to handle security/roles/access reads, data profile
///           reads and whatever else is required.
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
    public class ReadService
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


        public ReadService(IConfiguration _configuration, string userConnection)
        {
            configuration = _configuration;
            Connection = userConnManager.GetUserConnection(userConnection, configuration);
        }

        public string SingleUser(User singleUser)
        {
            string response = "";

            bool userFound = false;

            ReadRepo read = new ReadRepo(connection);

            try
            {
                response = read.SingleUser(singleUser, user);
                userFound = true;
            }
            catch (NpgsqlException pgex)
            {
                throw pgex;
            }
            catch (Exception ex)
            {
                throw ex;
            }

            /// In case exceptions are not caught (return default message)
            if (!userFound)
            {
                response = "User: " + singleUser.UserName + " not found!"; ;
            }    /// Note: need to add database ID too but not sure what that will look like right now

            GC.SuppressFinalize(read);

            return response;
        }

        public string Users()
        {
            string response = "";

            bool userFound = false;

            ReadRepo read = new ReadRepo(connection);

            try
            {
                response = read.Users(user);
                userFound = true;
            }
            catch (NpgsqlException pgex)
            {
                throw pgex;
            }
            catch (Exception ex)
            {
                throw ex;
            }

            /// In case exceptions are not caught (return default message)
            if (!userFound)
            {
                response = "Users: All Users were not found!";
            }    /// Note: need to add database ID too but not sure what that will look like right now

            GC.SuppressFinalize(read);

            return response;
        }

        public string Databases(User singleUser)
        {
            string response = "";

            bool dbFound = false;

            ReadRepo read = new ReadRepo(connection);

            try
            {
                response = read.Databases(singleUser, user);
                dbFound = true;
            }
            catch (NpgsqlException pgex)
            {
                throw pgex;
            }
            catch (Exception ex)
            {
                throw ex;
            }

            /// In case exceptions are not caught (return default message)
            if (!dbFound)
            {
                response = "User: " + singleUser.UserName + " databases not found!";
            }    /// Note: need to add database ID too but not sure what that will look like right now

            GC.SuppressFinalize(read);

            return response;
        }

        public string Tables(User singleUser, string databaseName)
        {
            string response = "";

            bool tablesFound = false;

            ReadRepo read = new ReadRepo(connection);

            try
            {
                response = read.Tables(singleUser, databaseName, user);
                tablesFound = true;
            }
            catch (NpgsqlException pgex)
            {
                throw pgex;
            }
            catch (Exception ex)
            {
                throw ex;
            }

            /// In case exceptions are not caught (return default message)
            if (!tablesFound)
            {
                response = "User: " + singleUser.UserName + " tables not found!";
            }    /// Note: need to add database ID too but not sure what that will look like right now

            GC.SuppressFinalize(read);

            return response;
        }

        public string Columns(User singleUser, string databaseName, string tableName)
        {
            string response = "";

            bool colunnsFound = false;

            ReadRepo read = new ReadRepo(connection);

            try
            {
                response = read.Columns(singleUser, databaseName, tableName, user);
                colunnsFound = true;
            }
            catch (NpgsqlException pgex)
            {
                throw pgex;
            }
            catch (Exception ex)
            {
                throw ex;
            }

            /// In case exceptions are not caught (return default message)
            if (!colunnsFound)
            {
                response = "User: " + singleUser.UserName + " table columns not found!";
            }    /// Note: need to add database ID too but not sure what that will look like right now

            GC.SuppressFinalize(read);

            return response;
        }

        public string WordRecom(string targetWord)
        {
            string response = "";

            bool targetWordFound = false;

            ReadRepo read = new ReadRepo(connection);

            try
            {
                response = read.WordRecom(targetWord);
                targetWordFound = true;
            }
            catch (NpgsqlException pgex)
            {
                throw pgex;
            }
            catch (Exception ex)
            {
                throw ex;
            }

            /// In case exceptions are not caught (return default message)
            if (!targetWordFound)
            {
                response = "Target Word is not found!";
            }    /// Note: need to add database ID too but not sure what that will look like right now

            GC.SuppressFinalize(read);

            return response;
        }

        public string Profile()
        {
            string response = "";

            bool profileFound = false;

            ReadRepo read = new ReadRepo(connection);

            try
            {
                response = read.Profile();
                profileFound = true;
            }
            catch (NpgsqlException pgex)
            {
                throw pgex;
            }
            catch (Exception ex)
            {
                throw ex;
            }

            /// In case exceptions are not caught (return default message)
            if (!profileFound)
            {
                response = "Profile is not found!";
            }    /// Note: need to add database ID too but not sure what that will look like right now

            GC.SuppressFinalize(read);

            return response;
        }

        public string ProfileData(int profileId)
        {
            string response = "";

            bool profileFound = false;

            ReadRepo read = new ReadRepo(connection);

            try
            {
                response = read.ProfileData(profileId);
                profileFound = true;
            }
            catch (NpgsqlException pgex)
            {
                throw pgex;
            }
            catch (Exception ex)
            {
                throw ex;
            }

            /// In case exceptions are not caught (return default message)
            if (!profileFound)
            {
                response = "Profile is not found!";
            }    /// Note: need to add database ID too but not sure what that will look like right now

            GC.SuppressFinalize(read);

            return response;
        }

        public string UserTables()
        {
            string response = "";

            ReadRepo read = new ReadRepo(connection);

            try
            {
                response = read.UserTables();
            }
            catch (NpgsqlException pgex)
            {
                throw pgex;
            }
            catch (Exception ex)
            {
                throw ex;
            }


            GC.SuppressFinalize(read);

            return response;
        }

        public List<List<string>> DataTable(string tableName)
        {
            List<List<string>> ret = null;
            ReadRepo read = new ReadRepo(connection);

            try
            {
                ret = read.DataTable(tableName);
            }
            catch (NpgsqlException pgex)
            {
                throw pgex;
            }
            catch (Exception ex)
            {
                throw ex;
            }


            GC.SuppressFinalize(read);

            return ret;
        }
    }
}

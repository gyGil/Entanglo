/// \file  CreateService
///
/// Major <b>CreateService.cs</b>
/// \details <b>Details</b>
/// -   This file handles the interaction between the Create Controller and the Create 
///     Repository of the Database Access Library. It sets up the required configuration
///     and user database connection required to query the create repository.
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
using DomainModels.AiModels;

namespace DatabaseServices
{
    public class CreateService
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


        public CreateService(IConfiguration _configuration, string userConnection)
        {
            configuration = _configuration;
            Connection = userConnManager.GetUserConnection(userConnection, configuration);
        }


        public string NewUser(User newUser)
        {
            string queryStatus = "User: " + newUser.UserName + " not created!";

            string response = "Error Creating New User";

            bool userCreated = false;

            CreateRepo create = new CreateRepo(connection);

            try
            {
                response = create.NewUser(newUser, user);
                userCreated = true;
            }
            catch (NpgsqlException pgex)
            {
                throw pgex;
            }
            catch (Exception ex)
            {
                throw ex;
            }

            if (userCreated)
            {
                queryStatus = "User: " + newUser.UserName + " created successfully!";
            }    /// Note: need to add database ID too but not sure what that will look like right now

            GC.SuppressFinalize(create);

            return queryStatus;
        }

        public string Database(Database database)
        {
            string queryStatus = "Database: " + database.DatabaseName + " not created!";

            string response = "Error Creating New Database";

            bool dbCreated = false;

            CreateRepo create = new CreateRepo(connection);

            try
            {
                response = create.Database(database, user);
                dbCreated = true;
            }
            catch (NpgsqlException pgex)
            {
                throw pgex;
            }
            catch (Exception ex)
            {
                throw ex;
            }

            if (dbCreated)
            {
                User.Databases.Add(database);

                queryStatus = "Database: " + database.DatabaseName + " created successfully!";
            }    /// Note: need to add database ID too but not sure what that will look like right now

            GC.SuppressFinalize(create);

            return queryStatus;
        }

        public string Table(NewTable table)
        {
            string queryStatus = "Table: " + table.TableName + " not created!";

            string response = "Error Creating New Table";

            bool tableCreated = false;

            CreateRepo create = new CreateRepo(connection);

            try
            {
                response = create.Table(table, user);
                tableCreated = true;
            }
            catch (NpgsqlException pgex)
            {
                throw pgex;
            }
            catch (Exception ex)
            {
                throw ex;
            }

            if (tableCreated)
            {
                //User.Databases.Find(dB => dB.DatabaseName == table.DatabaseName).DatabaseTables.Add(table);

                queryStatus = "Table: " + table.TableName + " created successfully!";
            }    /// Note: need to add database ID too but not sure what that will look like right now

            GC.SuppressFinalize(create);

            return queryStatus;
        }

        public string Column(Column column)
        {
            string queryStatus = "Column: " + column.ColumnName + " not created!";

            string response = "Error Creating New Column";

            bool columnCreated = false;

            CreateRepo create = new CreateRepo(connection);

            try
            {
                response = create.Column(column, user);
                columnCreated = true;
            }
            catch (NpgsqlException pgex)
            {
                throw pgex;
            }
            catch (Exception ex)
            {
                throw ex;
            }

            if (columnCreated)
            {
                queryStatus = "Column: " + column.ColumnName + " created successfully!";
            }    /// Note: need to add database ID too but not sure what that will look like right now

            GC.SuppressFinalize(create);

            return queryStatus;
        }

        public string Profile(Profile profile)
        {
            string queryStatus = "Profile: " + profile.Name + " not created!";

            string response = "Error Creating New Profile";

            bool profileCreated = false;

            CreateRepo create = new CreateRepo(connection);

            try
            {
                response = create.Profile(profile);
                profileCreated = true;
            }
            catch (NpgsqlException pgex)
            {
                throw pgex;
            }
            catch (Exception ex)
            {
                throw ex;
            }

            if (profileCreated)
            {
                queryStatus = "Profile: " + profile.Name + " created successfully!";
            }    /// Note: need to add database ID too but not sure what that will look like right now

            GC.SuppressFinalize(create);

            return queryStatus;
        }

        public string ProfileData(ProfileData profileData)
        {
            string queryStatus = "Profile Data is not created! (Profile Id: " + profileData.ProfileId + ")";

            string response = "Error Creating New Profile Data";

            bool profileDataCreated = false;

            CreateRepo create = new CreateRepo(connection);

            try
            {
                response = create.ProfileData(profileData);
                profileDataCreated = true;
            }
            catch (NpgsqlException pgex)
            {
                throw pgex;
            }
            catch (Exception ex)
            {
                throw ex;
            }

            if (profileDataCreated)
            {
                queryStatus = "Profile Data is created successfully! (Profile Id: " + profileData.ProfileId + ")";
            }    /// Note: need to add database ID too but not sure what that will look like right now

            GC.SuppressFinalize(create);

            return queryStatus;
        }

        public bool InsertData(DataPoint data)
        {
            bool response = false;

            CreateRepo create = new CreateRepo(connection);

            try
            {
                response = create.InsertData(data);
            }
            catch (NpgsqlException pgex)
            {
                throw pgex;
            }
            catch (Exception ex)
            {
                throw ex;
            }

            GC.SuppressFinalize(create);

            return response;
        }
    }
}

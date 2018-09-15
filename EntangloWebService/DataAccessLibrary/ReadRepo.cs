/// \file  ReadRepo
///
/// Major <b>ReadRepo.cs</b>
/// \details <b>Details</b>
/// -   This file handles the building of all read/get stored procedure calls
///     Executes the stored procedures and handles the return values and error
///     message handling of the connected database.
///   
/// <ul><li>\author     Geun Young Gil & Marcus Rankin</li>
///     <li>\copyright  Entanglo - BillClub</li>"
/// </ul>

using System;
using System.Collections.Generic;
using System.Text;
using Npgsql;
using DomainModels;

namespace DataAccessLibrary
{
    public class ReadRepo
    {
        private NpgsqlConnection Connection { get; set; }

        /// <summary>
        /// Constructor: Default constructor
        /// 
        /// <param name="connection">NpgsqlConnection</param>
        /// <returns name="">ReadRepo</returns>
        /// 
        /// </summary>
        public ReadRepo(NpgsqlConnection connection)
        {
            Connection = connection;
        }

        /// <summary>
        /// SingleUser: Searches for a user based on the specified user object.
        ///             Verifies access of the requesting user and existence of the 
        ///             searched user within the stored procedure (getuser)
        ///             before actually searching and returning information on the
        ///             requested user.
        /// </summary>
        /// 
        /// <param name="singleUser">User</param>
        /// <param name="user">User</param>
        /// 
        /// <returns name="response">string</returns>
        public string SingleUser(User singleUser, User user)
        {
            string response = "NULL";

            string userResponse = "";

            /// Using the passed in connection
            using (Connection)
            {
                Connection.Open();
                /// Create postgres command
                using (var command = new NpgsqlCommand())
                {   /// Build command with passed in connection and user
                    command.Connection = Connection;

                    try
                    {   /// Execute a non returning data query
                        using (var procCommand = new NpgsqlCommand("getuser", Connection))
                        {
                            procCommand.CommandType = System.Data.CommandType.StoredProcedure;

                            procCommand.Parameters.Add(new NpgsqlParameter("", singleUser.UserName));

                            procCommand.Parameters.Add(new NpgsqlParameter("", user.UserName));

                            using (var dataReader = procCommand.ExecuteReader())
                            {
                                while (dataReader.Read())
                                {
                                    userResponse = dataReader.GetString(0);
                                }
                            }

                            if (userResponse == "")
                            {
                                userResponse = "Returned Data Set is either NULL or Empty!";
                            }
                            else
                            {
                                /// change to json object
                                response = userResponse;
                            }
                        }

                    }   /// Error checking
                    catch (NpgsqlException pgex)
                    {
                        throw pgex;
                    }
                    catch (Exception ex)
                    {
                        throw ex;
                    }
                }
            }

            return response;   /// Return user found status
        }

        /// <summary>
        /// Users:  Searches for all users.
        ///         Verifies access of the requesting users within the stored 
        ///         procedure (getusers) before actually searching and returning 
        ///         information on all the requested users.
        /// </summary>
        /// 
        /// <param name="user">User</param>
        /// 
        /// <returns name="response">string</returns>
        public string Users(User user)
        {
            string response = "NULL";

            string userResponse = "";

            /// Using the passed in connection
            using (Connection)
            {
                Connection.Open();
                /// Create postgres command
                using (var command = new NpgsqlCommand())
                {   /// Build command with passed in connection and user
                    command.Connection = Connection;

                    try
                    {   /// Execute a non returning data query
                        using (var procCommand = new NpgsqlCommand("getusers", Connection))
                        {
                            procCommand.CommandType = System.Data.CommandType.StoredProcedure;

                            procCommand.Parameters.Add(new NpgsqlParameter("", user.UserName));

                            using (var dataReader = procCommand.ExecuteReader())
                            {
                                while (dataReader.Read())
                                {
                                    userResponse = dataReader.GetString(0);
                                }
                            }

                            if (userResponse == "")
                            {
                                userResponse = "Returned Data Set is either NULL or Empty!";
                            }
                            else
                            {
                                /// change to json object
                                response = userResponse;
                            }
                        }

                    }   /// Error checking
                    catch (NpgsqlException pgex)
                    {
                        throw pgex;
                    }
                    catch (Exception ex)
                    {
                        throw ex;
                    }
                }
            }

            return response;   /// Return users returned status
        }

        /// <summary>
        /// Databases:  Searches for all user databases based on the specified user object.
        ///             Verifies access of the requesting user and existence of the 
        ///             searched user within the stored procedure (getdatabases)
        ///             before actually searching and returning information on the
        ///             requested users databases.
        /// </summary>
        /// 
        /// <param name="singleUser">User</param>
        /// <param name="user">User</param>
        /// 
        /// <returns name="response">string</returns>
        public string Databases(User singleUser, User user)
        {
            string response = "NULL";

            string userResponse = "";

            /// Using the passed in connection
            using (Connection)
            {
                Connection.Open();
                /// Create postgres command
                using (var command = new NpgsqlCommand())
                {   /// Build command with passed in connection and user
                    command.Connection = Connection;

                    try
                    {   /// Execute a non returning data query
                        using (var procCommand = new NpgsqlCommand("getdatabases", Connection))
                        {
                            procCommand.CommandType = System.Data.CommandType.StoredProcedure;

                            procCommand.Parameters.Add(new NpgsqlParameter("", singleUser.UserName));

                            procCommand.Parameters.Add(new NpgsqlParameter("", user.UserName));

                            using (var dataReader = procCommand.ExecuteReader())
                            {
                                while (dataReader.Read())
                                {
                                    userResponse = dataReader.GetString(0);
                                }
                            }

                            if (userResponse == "")
                            {
                                userResponse = "Returned Data Set is either NULL or Empty!";
                            }
                            else
                            {
                                /// change to json object
                                response = userResponse;
                            }
                        }

                    }   /// Error checking
                    catch (NpgsqlException pgex)
                    {
                        throw pgex;
                    }
                    catch (Exception ex)
                    {
                        throw ex;
                    }
                }
            }

            return response;   /// Return user databases found status
        }

        /// <summary>
        /// Tables: Searches for all user tables based on the specified user object
        ///         and specified database. Verifies access of the requesting user 
        ///         and existence of the searched user and specified database within 
        ///         the stored procedure (gettables) before actually searching and 
        ///         returning information on the requested users tables.
        /// </summary>
        /// 
        /// <param name="singleUser">User</param>
        /// <param name="databaseName"></param>
        /// <param name="user">User</param>
        /// 
        /// <returns name="response">string</returns>
        public string Tables(User singleUser, string databaseName, User user)
        {
            string response = "NULL";

            string userResponse = "";

            /// Using the passed in connection
            using (Connection)
            {
                Connection.Open();
                /// Create postgres command
                using (var command = new NpgsqlCommand())
                {   /// Build command with passed in connection and user
                    command.Connection = Connection;

                    try
                    {   /// Execute a non returning data query
                        using (var procCommand = new NpgsqlCommand("gettables", Connection))
                        {
                            procCommand.CommandType = System.Data.CommandType.StoredProcedure;

                            procCommand.Parameters.Add(new NpgsqlParameter("", singleUser.UserName));

                            procCommand.Parameters.Add(new NpgsqlParameter("", databaseName));

                            procCommand.Parameters.Add(new NpgsqlParameter("", user.UserName));

                            using (var dataReader = procCommand.ExecuteReader())
                            {
                                while (dataReader.Read())
                                {
                                    userResponse = dataReader.GetString(0);
                                }
                            }

                            if (userResponse == "")
                            {
                                userResponse = "Returned Data Set is either NULL or Empty!";
                            }
                            else
                            {
                                /// change to json object
                                response = userResponse;
                            }
                        }

                    }   /// Error checking
                    catch (NpgsqlException pgex)
                    {
                        throw pgex;
                    }
                    catch (Exception ex)
                    {
                        throw ex;
                    }
                }
            }

            return response;   /// Return user tables found status
        }

        /// <summary>
        /// Columns: Searches for all user columns based on the specified user object
        ///         and specified table. Verifies access of the requesting user 
        ///         and existence of the searched user and specified table within 
        ///         the stored procedure (getcolumns) before actually searching and 
        ///         returning information on the requested users table columns.
        /// </summary>
        /// 
        /// <param name="singleUser">User</param>
        /// <param name="databaseName">string</param>
        /// <param name="tableName">string</param>
        /// <param name="user">User</param>
        /// 
        /// <returns name="response">string</returns>
        public string Columns(User singleUser, string databaseName, string tableName, User user)
        {
            string response = "NULL";

            string userResponse = "";

            /// Using the passed in connection
            using (Connection)
            {
                Connection.Open();
                /// Create postgres command
                using (var command = new NpgsqlCommand())
                {   /// Build command with passed in connection and user
                    command.Connection = Connection;

                    try
                    {   /// Execute a non returning data query
                        using (var procCommand = new NpgsqlCommand("getcolumns", Connection))
                        {
                            procCommand.CommandType = System.Data.CommandType.StoredProcedure;

                            procCommand.Parameters.Add(new NpgsqlParameter("", singleUser.UserName));

                            procCommand.Parameters.Add(new NpgsqlParameter("", databaseName));

                            procCommand.Parameters.Add(new NpgsqlParameter("", tableName));

                            procCommand.Parameters.Add(new NpgsqlParameter("", user.UserName));

                            using (var dataReader = procCommand.ExecuteReader())
                            {
                                while (dataReader.Read())
                                {
                                    userResponse = dataReader.GetString(0);
                                }
                            }

                            if (userResponse == "")
                            {
                                userResponse = "Returned Data Set is either NULL or Empty!";
                            }
                            else
                            {
                                /// change to json object
                                response = userResponse;
                            }
                        }

                    }   /// Error checking
                    catch (NpgsqlException pgex)
                    {
                        throw pgex;
                    }
                    catch (Exception ex)
                    {
                        throw ex;
                    }
                }
            }

            return response;   /// Return user columns found status
        }

        
        /// <summary>
        /// WordRecommendation: get 20 close words for target word
        /// </summary>
        /// 
        /// <param name="targetWord">string</param>
        /// 
        /// <returns name="response">string</returns>
        public string WordRecom(string targetWord)
        {
            string response = "NULL";

            string userResponse = "";

            /// Using the passed in connection
            using (Connection)
            {
                Connection.Open();
                /// Create postgres command
                using (var command = new NpgsqlCommand())
                {   /// Build command with passed in connection and user
                    command.Connection = Connection;

                    try
                    {   /// Execute a non returning data query
                        using (var procCommand = new NpgsqlCommand("getwordrecom", Connection))
                        {
                            procCommand.CommandType = System.Data.CommandType.StoredProcedure;

                            procCommand.Parameters.Add(new NpgsqlParameter("", targetWord));

                            using (var dataReader = procCommand.ExecuteReader())
                            {
                                while (dataReader.Read())
                                {
                                    userResponse = dataReader.GetString(0);
                                }
                            }

                            if (userResponse == "")
                            {
                                userResponse = "Returned Data Set is either NULL or Empty!";
                            }
                            else
                            {
                                /// change to json object
                                response = userResponse;
                            }
                        }

                    }   /// Error checking
                    catch (NpgsqlException pgex)
                    {
                        throw pgex;
                    }
                    catch (Exception ex)
                    {
                        throw ex;
                    }
                }
            }

            return response;   /// Return user columns found status
        }

        public string Profile()
        {
            string response = "NULL";

            string userResponse = "";

            /// Using the passed in connection
            using (Connection)
            {
                Connection.Open();
                /// Create postgres command
                using (var command = new NpgsqlCommand())
                {   /// Build command with passed in connection and user
                    command.Connection = Connection;

                    try
                    {   /// Execute a non returning data query
                        using (var procCommand = new NpgsqlCommand("getprofile", Connection))
                        {
                            procCommand.CommandType = System.Data.CommandType.StoredProcedure;

                            using (var dataReader = procCommand.ExecuteReader())
                            {
                                while (dataReader.Read())
                                {
                                    userResponse = dataReader.GetString(0);
                                }
                            }

                            if (userResponse == "")
                            {
                                userResponse = "Returned Data Set is either NULL or Empty!";
                            }
                            else
                            {
                                /// change to json object
                                response = userResponse;
                            }
                        }

                    }   /// Error checking
                    catch (NpgsqlException pgex)
                    {
                        throw pgex;
                    }
                    catch (Exception ex)
                    {
                        throw ex;
                    }
                }
            }

            return response;   /// Return user columns found status
        }

        public string ProfileData(int profileId)
        {
            string response = "NULL";

            string userResponse = "";

            /// Using the passed in connection
            using (Connection)
            {
                Connection.Open();
                /// Create postgres command
                using (var command = new NpgsqlCommand())
                {   /// Build command with passed in connection and user
                    command.Connection = Connection;

                    try
                    {   /// Execute a non returning data query
                        using (var procCommand = new NpgsqlCommand("getprofiledata", Connection))
                        {
                            procCommand.CommandType = System.Data.CommandType.StoredProcedure;
                            procCommand.Parameters.Add(new NpgsqlParameter("", profileId));

                            using (var dataReader = procCommand.ExecuteReader())
                            {
                                while (dataReader.Read())
                                {
                                    userResponse = dataReader.GetString(0);
                                }
                            }

                            if (userResponse == "")
                            {
                                userResponse = "Returned Data Set is either NULL or Empty!";
                            }
                            else
                            {
                                /// change to json object
                                response = userResponse;
                            }
                        }

                    }   /// Error checking
                    catch (NpgsqlException pgex)
                    {
                        throw pgex;
                    }
                    catch (Exception ex)
                    {
                        throw ex;
                    }
                }
            }

            return response;   /// Return user columns found status
        }

        public string UserTables()
        {
            string response = "NULL";

            string userResponse = "";

            /// Using the passed in connection
            using (Connection)
            {
                Connection.Open();
                /// Create postgres command
                using (var command = new NpgsqlCommand())
                {   /// Build command with passed in connection and user
                    command.Connection = Connection;

                    try
                    {   /// Execute a non returning data query
                        using (var procCommand = new NpgsqlCommand("getusertables", Connection))
                        {
                            procCommand.CommandType = System.Data.CommandType.StoredProcedure;

                            using (var dataReader = procCommand.ExecuteReader())
                            {
                                while (dataReader.Read())
                                {
                                    userResponse = dataReader.GetString(0);
                                }
                            }

                            if (userResponse == "")
                            {
                                userResponse = "Returned Data Set is either NULL or Empty!";
                            }
                            else
                            {
                                /// change to json object
                                response = userResponse;
                            }
                        }

                    }   /// Error checking
                    catch (NpgsqlException pgex)
                    {
                        throw pgex;
                    }
                    catch (Exception ex)
                    {
                        throw ex;
                    }
                }
            }

            return response;   /// Return user columns found status
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="tableName"></param>
        /// <returns>(colsResponse, dataResponse)</returns>
        public List<List<string>> DataTable(string tableName)
        {
            List<List<string>> ret = new List<List<string>>();
            const int startIdx = 4;
            /// Using the passed in connection
            using (Connection)
            {
                Connection.Open();
                /// Create postgres command
                using (var command = new NpgsqlCommand())
                {   /// Build command with passed in connection and user
                    command.Connection = Connection;

                    try
                    {
                        // select * from "user".businesscard
                        // select column_name from information_schema.columns where table_name = 'businesscard';
                        // Build Sql query  
                        string readColNamesSql = "select column_name from information_schema.columns where table_name = '" + tableName + "'";

                        using (var procCommand = new NpgsqlCommand(readColNamesSql, Connection))
                        {
                            using (var dataReader = procCommand.ExecuteReader())
                            {
                                List<string> row = new List<string>();
                                int i = 0;
                                while (dataReader.Read())
                                {         
                                    if (i++ > (startIdx - 1))
                                        row.Add(dataReader.GetString(0));                                        
                                }
                                ret.Add(row);
                            }
                        }

                        string readDataSql = "select * from \"user\"." + tableName;                    

                        using (var procCommand = new NpgsqlCommand(readDataSql, Connection))
                        {
                            using (var dataReader = procCommand.ExecuteReader())
                            {
                                int numRow = 0;
                                while (dataReader.Read())
                                {
                                    if (numRow++ < 1) continue; // skip first row
                                    List<string> row = new List<string>();
                                    for (int i = startIdx; i < dataReader.FieldCount; ++i)
                                        if (dataReader.IsDBNull(i))
                                            row.Add("");
                                        else
                                            row.Add(dataReader.GetString(i));
                                    if (row.Count > 0)
                                        ret.Add(row);
                                }
                            }
                        }
                    }   /// Error checking
                    catch (NpgsqlException pgex)
                    {
                        throw pgex;
                    }
                    catch (Exception ex)
                    {
                        throw ex;
                    }
                }
            }

            return ret;   /// Return column creation status
        }

    }
}

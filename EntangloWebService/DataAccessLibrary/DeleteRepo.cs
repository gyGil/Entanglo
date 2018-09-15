/// \file  DeleteRepo
///
/// Major <b>DeleteRepo.cs</b>
/// \details <b>Details</b>
/// -   This file handles the building of all delete/delete stored procedure calls
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
    public class DeleteRepo
    {
        private NpgsqlConnection Connection { get; set; }

        /// <summary>
        /// Constructor: Default constructor
        /// 
        /// <param name="connection">NpgsqlConnection</param>
        /// <returns name="">DeleteRepo</returns>
        /// 
        /// </summary>
        public DeleteRepo(NpgsqlConnection connection)
        {
            Connection = connection;
        }

        /// <summary>
        /// OldUser:    Deletes a current user based on the specified user object.
        ///             Verifies prior existence of user within the stored procedure (deleteuser)
        ///             before deleting the old user.
        /// </summary>
        /// 
        /// <param name="oldUser">User</param>
        /// <param name="user">User</param>
        /// 
        /// <returns name="response">string</returns>
        public string OldUser(User oldUser, User user)
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
                        using (var procCommand = new NpgsqlCommand("deleteuser", Connection))
                        {
                            procCommand.CommandType = System.Data.CommandType.StoredProcedure;

                            procCommand.Parameters.Add(new NpgsqlParameter("", oldUser.UserKey));
                            procCommand.Parameters.Add(new NpgsqlParameter("", oldUser.UserName));

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

            return response;   /// Return user deletion status
        }

        /// <summary>
        /// Database:   Deletes a current database based on the specified database name.
        ///             Verified within stored procedure (deletedatabase) which checks 
        ///             if the current deleted database was deleted successfully.
        /// </summary>
        /// 
        /// <param name="database">Database</param>
        /// <param name="user">User</param>
        /// 
        /// <returns name="response">string</returns>
        public string Database(Database database, User user)
        {
            string response = "NULL";

            string dBresponse = "";

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
                        using (var procCommand = new NpgsqlCommand("deletedatabase", Connection))
                        {
                            procCommand.CommandType = System.Data.CommandType.StoredProcedure;

                            procCommand.Parameters.Add(new NpgsqlParameter("", database.DatabaseName));
                            procCommand.Parameters.Add(new NpgsqlParameter("", user.UserName));

                            using (var dataReader = procCommand.ExecuteReader())
                            {
                                while (dataReader.Read())
                                {
                                    dBresponse = dataReader.GetString(0);
                                }
                            }

                            if (dBresponse == "")
                            {
                                dBresponse = "Returned Data Set is either NULL or Empty!";
                            }
                            else
                            {
                                /// change to json object
                                response = dBresponse;
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

            return response;   /// Return database deletion status
        }

        /// <summary>
        /// Table:   Deletes a current table based on the specified table name.
        ///          Verifies existence of associated database before deleting within the
        ///          stored procedure (deletetable) which checks if the database exists and 
        ///          afterwards if the current deleted table was deleted successfully.
        /// </summary>
        /// 
        /// <param name="table">Table</param>
        /// <param name="user">User</param>
        /// 
        /// <returns name="response">string</returns>
        public string Table(Table table, User user)
        {
            string response = "NULL";

            string tblResponse = "";

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
                        using (var procCommand = new NpgsqlCommand("deletetable", Connection))
                        {
                            procCommand.CommandType = System.Data.CommandType.StoredProcedure;

                            procCommand.Parameters.Add(new NpgsqlParameter("", table.DatabaseName));
                            procCommand.Parameters.Add(new NpgsqlParameter("", table.TableName));

                            procCommand.Parameters.Add(new NpgsqlParameter("", user.UserName));

                            using (var dataReader = procCommand.ExecuteReader())
                            {
                                while (dataReader.Read())
                                {
                                    tblResponse = dataReader.GetString(0);
                                }
                            }

                            if (tblResponse == "")
                            {
                                tblResponse = "Returned Data Set is either NULL or Empty!";
                            }
                            else
                            {
                                /// change to json object
                                response = tblResponse;
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

            return response;   /// Return table deletion status
        }

        /// <summary>
        /// Column: Deletes a current column based on the specified column object.
        ///         Verifies existence of associated database and table before deleting within 
        ///         the stored procedure (deletecolumn) which checks if the database and the
        ///         table exists and afterwards if the current deleted column was deleted successfully.
        /// </summary>
        /// 
        /// <param name="column">Column</param>
        /// <param name="user">User</param>
        /// 
        /// <returns name="response">string</returns>
        public string Column(Column column, User user)
        {
            string response = "NULL";

            string colResponse = "";

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
                        using (var procCommand = new NpgsqlCommand("deletecolumn", Connection))
                        {
                            procCommand.CommandType = System.Data.CommandType.StoredProcedure;

                            procCommand.Parameters.Add(new NpgsqlParameter("", column.DatabaseName));
                            procCommand.Parameters.Add(new NpgsqlParameter("", column.TableName));
                            procCommand.Parameters.Add(new NpgsqlParameter("", column.ColumnName));

                            procCommand.Parameters.Add(new NpgsqlParameter("", user.UserName));

                            using (var dataReader = procCommand.ExecuteReader())
                            {
                                while (dataReader.Read())
                                {
                                    colResponse = dataReader.GetString(0);
                                }
                            }

                            if (colResponse == "")
                            {
                                colResponse = "Returned Data Set is either NULL or Empty!";
                            }
                            else
                            {
                                /// change to json object
                                response = colResponse;
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

            return response;   /// Return column deletion status
        }


        public bool Profile()
        {        
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
                        // ex.  DELETE FROM public.profile
                        // Build Sql query
                        string sqlstr = "DELETE FROM public.profile";

                        using (var cmd = new NpgsqlCommand(sqlstr, Connection))
                        {
                            if (cmd.ExecuteNonQuery() >= 0)
                                return true;

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

            return false;   /// Return column creation status
        }

        public bool ProfileData()
        {
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
                        // ex.  DELETE FROM public.profile
                        // Build Sql query
                        string sqlstr = "DELETE FROM public.profiledata";

                        using (var cmd = new NpgsqlCommand(sqlstr, Connection))
                        {
                            if (cmd.ExecuteNonQuery() >= 0)
                                return true;

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

            return false;   /// Return column creation status
        }

        public bool UserTables()
        {
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
                        // ex.  DROP SCHEMA "user" CASCADE;
                        //      CREATE SCHEMA "user";
                        // Build Sql query
                        string sqlstr = "DROP SCHEMA \"user\" CASCADE";
                        bool successDrop = false;
                        using (var cmd = new NpgsqlCommand(sqlstr, Connection))
                        {
                            if (cmd.ExecuteNonQuery() == -1)
                                successDrop = true;

                        }

                        if (successDrop)
                        {
                            sqlstr = "CREATE SCHEMA \"user\"";
                            using (var cmd = new NpgsqlCommand(sqlstr, Connection))
                            {
                                if (cmd.ExecuteNonQuery() == -1)
                                    return true;
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

            return false;   /// Return column creation status
        }
    }
}

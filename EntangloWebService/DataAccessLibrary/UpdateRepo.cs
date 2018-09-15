/// \file  UpdateRepo
///
/// Major <b>UpdateRepo.cs</b>
/// \details <b>Details</b>
/// -   This file handles the building of all update/put stored procedure calls
///     Executes the stored procedures and handles the return values and error
///     message handling of the connected database.
///   
/// <ul><li>\author     Geun Young Gil & Marcus Rankin</li>
///     <li>\copyright  Entanglo - BillClub</li>"
/// </ul>

using DomainModels;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Text;
using Npgsql;
using System.Data;
using System.Linq;

namespace DataAccessLibrary
{
    public class UpdateRepo
    {
        private NpgsqlConnection Connection { get; set; }

        /// <summary>
        /// Constructor: Default constructor
        /// 
        /// <param name="connection">NpgsqlConnection</param>
        /// <returns name="">UpdateRepo</returns>
        /// 
        /// </summary>
        public UpdateRepo(NpgsqlConnection connection)
        {
            Connection = connection;
        }

        /// <summary>
        /// User:   Updates an existing User based on the specified User object.
        ///         Updates and verifies a successful update by calling 'updateuser' 
        ///         stored procedure which updates the users information and verifies
        ///         the update.
        /// </summary>
        /// <param name="connection">NpgsqlConnection</param>
        /// <param name="user">User</param>
        /// <returns name="userUpdate">bool</returns>
        public string User(User updateUser, User user)
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
                        using (var procCommand = new NpgsqlCommand("updateuser", Connection))
                        {
                            procCommand.CommandType = System.Data.CommandType.StoredProcedure;

                            procCommand.Parameters.Add(new NpgsqlParameter("", updateUser.UserKey));
                            procCommand.Parameters.Add(new NpgsqlParameter("", updateUser.UserName));
                            procCommand.Parameters.Add(new NpgsqlParameter("", updateUser.UserPassword));
                            procCommand.Parameters.Add(new NpgsqlParameter("", updateUser.Email));
                            //procCommand.Parameters.Add(new NpgsqlParameter("", updateUser.DatabaseName));
                            procCommand.Parameters.Add(new NpgsqlParameter("", updateUser.Note));

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

            return response;   /// Return user update status
        }

        /// <summary>
        /// Database:   Updates an existing database based on the specified database Name.
        ///             Verified within the stored procedure (updatedatabase) which checks 
        ///             if the databse exists and if new update of the database occurred.
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
                        using (var procCommand = new NpgsqlCommand("updatedatabase", Connection))
                        {
                            procCommand.CommandType = System.Data.CommandType.StoredProcedure;

                            procCommand.Parameters.Add(new NpgsqlParameter("", database.DatabaseName));
                            procCommand.Parameters.Add(new NpgsqlParameter("", database.DatabaseTemplate));

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

            return response;   /// Return database update status
        }


        /// <summary>
        /// Table:   Updates an existing table based on the specified table Name.
        ///          Verifies existence of associated database before updating within the
        ///          stored procedure (updatetable) which checks if the database exists and 
        ///          afterwards if the table exists within that database. Verifies update
        ///          to table was completed successfully.
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

            List<string> colNames = new List<string>();
            List<string> colTypes = new List<string>();
            List<string> colSizes = new List<string>();
            List<string> colConstraints = new List<string>();
            List<string> colDefaultValues = new List<string>();

            string[] columnNames = { "" };
            string[] columnTypes = { "" };
            string[] columnSizes = { "" };
            string[] columnConstraints = { "" };
            string[] columnDefaultValues = { "" };

            if (table.TableColumns.Count != 0)
            {
                foreach (Column col in table.TableColumns)
                {
                    colNames.Add(col.ColumnName);
                    colTypes.Add(col.ColumnDataType);
                    colSizes.Add(col.ColumnSize);
                    colConstraints.Add(col.ColumnConstraint);
                    colDefaultValues.Add(col.ColumnDefaultValue);
                }

                columnNames = colNames.ToArray();
                columnTypes = colTypes.ToArray();
                columnSizes = colSizes.ToArray();
                columnConstraints = colConstraints.ToArray();
                columnDefaultValues = colDefaultValues.ToArray();
            }

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
                        using (var procCommand = new NpgsqlCommand("updatetable", Connection))
                        {
                            procCommand.CommandType = System.Data.CommandType.StoredProcedure;

                            procCommand.Parameters.Add(new NpgsqlParameter("", table.DatabaseName));
                            procCommand.Parameters.Add(new NpgsqlParameter("", table.TableName));

                            procCommand.Parameters.Add(new NpgsqlParameter("", columnNames));
                            procCommand.Parameters.Add(new NpgsqlParameter("", columnTypes));
                            procCommand.Parameters.Add(new NpgsqlParameter("", columnSizes));
                            procCommand.Parameters.Add(new NpgsqlParameter("", columnConstraints));
                            procCommand.Parameters.Add(new NpgsqlParameter("", columnDefaultValues));

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

            return response;   /// Return table update status
        }

        /// <summary>
        /// Column: Update an existing column based on the specified column object.
        ///         Verifies existence of associated database and table before updating within 
        ///         the stored procedure (updatecolumn) which checks if the database and the
        ///         table exists. Verifies that the column was updated successfully.
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
                        using (var procCommand = new NpgsqlCommand("updatecolumn", Connection))
                        {
                            procCommand.CommandType = System.Data.CommandType.StoredProcedure;

                            procCommand.Parameters.Add(new NpgsqlParameter("", column.DatabaseName));
                            procCommand.Parameters.Add(new NpgsqlParameter("", column.TableName));
                            procCommand.Parameters.Add(new NpgsqlParameter("", column.ColumnName));
                            procCommand.Parameters.Add(new NpgsqlParameter("", column.ColumnDataType));
                            procCommand.Parameters.Add(new NpgsqlParameter("", column.ColumnConstraint));
                            procCommand.Parameters.Add(new NpgsqlParameter("", column.ColumnDefaultValue));

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

            return response;   /// Return column update status
        }
    }
}

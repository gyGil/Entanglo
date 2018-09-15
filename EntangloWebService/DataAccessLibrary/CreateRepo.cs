/// \file  CreateRepo
///
/// Major <b>CreateRepo.cs</b>
/// \details <b>Details</b>
/// -   This file handles the building of all create/post stored procedure calls
///     Executes the stored procedures and handles the return values and error
///     message handling of the connected database.
///   
/// <ul><li>\author     Geun Young Gil & Marcus Rankin</li>
///     <li>\copyright  Entanglo - BillClub</li>"
/// </ul>
/// 
using System;
using System.Collections.Generic;
using System.Text;
using Npgsql;
using System.Data;
using DomainModels;
using Newtonsoft.Json.Linq;
using System.Diagnostics;
using System.Net.Http;
using Newtonsoft.Json;
using DomainModels.AiModels;
using NpgsqlTypes;

namespace DataAccessLibrary
{
    public class CreateRepo
    {
        private NpgsqlConnection Connection { get; set; }

        /// <summary>
        /// Constructor: Default constructor
        /// 
        /// <param name="connection">NpgsqlConnection</param>
        /// <returns name="">CreateRepo</returns>
        /// 
        /// </summary>
        public CreateRepo(NpgsqlConnection connection)
        {
            Connection = connection;
        }

        /// <summary>
        /// NewUser:    Creates a new user based on the specified user object.
        ///             Verifies prior existence of user within the stored procedure (createuser)
        ///             before creating the new user as to not duplicate any users.
        /// </summary>
        /// 
        /// <param name="newUser">User</param>
        /// <param name="user">User</param>
        /// 
        /// <returns name="response">string</returns>
        public string NewUser(User newUser, User user)
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
                        using (var procCommand = new NpgsqlCommand("createuser", Connection))
                        {
                            procCommand.CommandType = System.Data.CommandType.StoredProcedure;

                            procCommand.Parameters.Add(new NpgsqlParameter("", newUser.UserKey));
                            procCommand.Parameters.Add(new NpgsqlParameter("", newUser.UserName));
                            procCommand.Parameters.Add(new NpgsqlParameter("", newUser.UserPassword));
                            procCommand.Parameters.Add(new NpgsqlParameter("", newUser.Email));
                            //procCommand.Parameters.Add(new NpgsqlParameter("", newUser.DatabaseName));
                            procCommand.Parameters.Add(new NpgsqlParameter("", newUser.Note));

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

            return response;   /// Return user creation status
        }

        /// <summary>
        /// Database:   Creates a new database based on the specified database name.
        ///             Verified within stored procedure (createdatabase) which checks 
        ///             if the newly created database exists.
        /// </summary>
        /// 
        /// <param name="database">Database</param>
        /// <param name="user">User</param>
        /// 
        /// <returns name="response">string</returns>
        public string Database(Database database, User user)
        {
            //bool dbCreated = false;

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
                        using (var procCommand = new NpgsqlCommand("createdatabase", Connection))
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

            return response;   /// Return database creation status
        }


        /// <summary>
        /// Table:   Creates a new table based on the specified table name.
        ///          Verifies existence of associated database before creating within the
        ///          stored procedure (createtable) which checks if the database exists and 
        ///          afterwards if the newly created table was created and added successfully.
        /// </summary>
        /// 
        /// <param name="table">Table</param>
        /// <param name="user">User</param>
        /// 
        /// <returns name="response">string</returns>
        public string Table(NewTable table, User user)
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

            //var JsonDataString = new StringContent(table.JsonData, System.Text.Encoding.UTF8, "application/json");
            //var JsonDataString = JToken.Parse(table.JsonData).ToString();
            //var RawDataProfileString = JToken.Parse(table.RawDataProfile).ToString();
            //var DataProfileString = JToken.Parse(table.DataProfile).ToString();


            var jsonDataString = table.JsonData;//.Replace(@"\", "");
            //Console.WriteLine(JsonDataString);
            //var jsonDataString = JsonConvert.SerializeObject(table.JsonData);
            //var jsonDataString = JsonConvert.DeserializeObject(table.JsonData);
            //Console.WriteLine(JsonDataString);
            var rawDataProfileString = table.RawDataProfile.Replace(@"\", "");
            var dataProfileString = table.DataProfile.Replace(@"\", "");

            //var jsonDataString = JObject.Parse(table.JsonData).ToString().Replace(@"\", "");
            //var rawDataProfileString = JObject.Parse(table.RawDataProfile).ToString();
            //var dataProfileString = JObject.Parse(table.DataProfile).ToString();
            //Debug.WriteLine(JsonDataString);
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
                        using (var procCommand = new NpgsqlCommand("createtable", Connection))
                        {
                            procCommand.CommandType = System.Data.CommandType.StoredProcedure;

                            procCommand.Parameters.Add(new NpgsqlParameter("", table.Schema));
                            procCommand.Parameters.Add(new NpgsqlParameter("", table.TableName));
                            procCommand.Parameters.Add(new NpgsqlParameter("", table.TableUuid));
                            //procCommand.Parameters.Add(new NpgsqlParameter("", table.JsonData));
                            //procCommand.Parameters.Add(new NpgsqlParameter("", NpgsqlTypes.NpgsqlDbType.Jsonb, table.JsonData.Length, "", ParameterDirection.Input, false, 0, 0, DataRowVersion.Current, table.JsonData));
                            //procCommand.Parameters.Add(new NpgsqlParameter("", NpgsqlTypes.NpgsqlDbType.Jsonb, table.RawDataProfile.Length, "", ParameterDirection.Input, false, 0, 0, DataRowVersion.Current, table.RawDataProfile));
                            //procCommand.Parameters.Add(new NpgsqlParameter("", NpgsqlTypes.NpgsqlDbType.Jsonb, table.DataProfile.Length, "", ParameterDirection.Input, false, 0, 0, DataRowVersion.Current, table.DataProfile));
                            //procCommand.Parameters.Add(new NpgsqlParameter("", table.JsonData.Replace("\\", "")));
                            //procCommand.Parameters.Add(new NpgsqlParameter("", table.RawDataProfile.Replace("\\", "")));
                            //procCommand.Parameters.Add(new NpgsqlParameter("", table.DataProfile.Replace("\\", "")));
                            procCommand.Parameters.Add(new NpgsqlParameter("", jsonDataString));
                            procCommand.Parameters.Add(new NpgsqlParameter("", rawDataProfileString));
                            procCommand.Parameters.Add(new NpgsqlParameter("", dataProfileString));

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

            return response;   /// Return table creation status
        }

        /// <summary>
        /// Column: Creates a new column based on the specified column object.
        ///         Verifies existence of associated database and table before creating within 
        ///         the stored procedure (createcolumn) which checks if the database and the
        ///         table exists and afterwards if the newly created column was created and 
        ///         added successfully.
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
                        using (var procCommand = new NpgsqlCommand("createcolumn", Connection))
                        {
                            procCommand.CommandType = System.Data.CommandType.StoredProcedure;

                            procCommand.Parameters.Add(new NpgsqlParameter("", column.DatabaseName));
                            procCommand.Parameters.Add(new NpgsqlParameter("", column.TableName));
                            procCommand.Parameters.Add(new NpgsqlParameter("", column.ColumnName));
                            procCommand.Parameters.Add(new NpgsqlParameter("", column.ColumnDataType));
                            procCommand.Parameters.Add(new NpgsqlParameter("", column.ColumnSize));
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

            return response;   /// Return column creation status
        }

        public string Profile(Profile profile)
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
                        using (var procCommand = new NpgsqlCommand("createprofile", Connection))
                        {
                            procCommand.CommandType = System.Data.CommandType.StoredProcedure;
                            procCommand.Parameters.Add(new NpgsqlParameter("", profile.Name));
                            var jsonPara = new NpgsqlParameter("", profile.Pattern);
                            jsonPara.NpgsqlDbType = NpgsqlDbType.Json;
                            procCommand.Parameters.Add(jsonPara);
                            procCommand.Parameters.Add(new NpgsqlParameter("", profile.User));

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

            return response;   /// Return column creation status
        }

        public string ProfileData(ProfileData profileData)
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
                        using (var procCommand = new NpgsqlCommand("createprofiledata", Connection))
                        {
                            procCommand.CommandType = System.Data.CommandType.StoredProcedure;
                            procCommand.Parameters.Add(new NpgsqlParameter("", profileData.ProfileId));
                            procCommand.Parameters.Add(new NpgsqlParameter("", profileData.DataTableName));
                            var jsonPara = new NpgsqlParameter("", profileData.Recipe);
                            jsonPara.NpgsqlDbType = NpgsqlDbType.Json;
                            procCommand.Parameters.Add(jsonPara);
                            

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

            return response;   /// Return column creation status
        }

        /// <summary>
        /// Insert data to table
        /// </summary>
        /// <param name="data"></param>
        /// <returns>true: Success, false: Fail</returns>
        public bool InsertData(DataPoint data)
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
                        // ex.  insert into "user".tblname5 (tableuuid, jsondata, rawdataprofile, colname1, colname2) values ('','{}','{}', 'aa', 'bb')
                        // Build Sql query
                        string colNames = "";
                        string colVals = "";
                        for (int i = 0; i < data.Columns.Count; ++i)
                        {
                            if (i < (data.Columns.Count - 1))
                            {
                                colNames += data.Columns[i].Name + ", ";
                                colVals += "'" + data.Columns[i].Value + "', ";
                            }
                            else
                            {
                                colNames += data.Columns[i].Name;
                                colVals += "'" + data.Columns[i].Value + "'";
                            }
                        }

                        string sqlstr = "INSERT INTO \"user\"." + data.TableName + 
                                        " (tableuuid, jsondata, rawdataprofile, " + colNames +
                                        ") VALUES ('', '{}', '{}', " + colVals + ")";


                        using (var cmd = new NpgsqlCommand(sqlstr, Connection))
                            if (cmd.ExecuteNonQuery() > 0)
                                return true;

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
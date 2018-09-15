﻿/// \file  DeleteController
///
/// Major <b>DeleteController.cs</b>
/// \details <b>Details</b>
/// -   This file is a controller that handles all the service calls and
///     routing for any deletes/delete made to a user, database, table, and columns
///   
/// <ul><li>\author     Geunyoung Gil & Marcus Rankin</li>
///     <li>\copyright  Entanglo - BillClub</li>"
/// </ul>

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using DomainModels;
using DatabaseServices;
using Npgsql;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace EntangloWebService.Controllers
{
    [Produces("application/json")]
    [Route("Entanglo/[controller]")]
    public class DeleteController : Controller
    {
        private IConfiguration configuration;
        private readonly ILogger<DeleteController> logger = null;
        private DeleteService delete;
        private User user = new DomainModels.User(1, "Marcus Rankin", "pa55w0rd", "blah@blah.com");

        public DeleteController(IConfiguration _configuration, ILogger<DeleteController> _logger)
        {
            configuration = _configuration;
            logger = _logger;
            delete = new DeleteService(configuration, "MainConnection");
        }

        // DELETE: Entanglo/Delete/User
        [HttpDelete]
        [Consumes("application/json")]
        [Route("User")]
        public new IActionResult User([FromBody] User oldUser)
        {
            logger.LogInformation("User: " + user.UserName + "\tDelete User Attempt: " + user.UserName, oldUser);

            if (!ModelState.IsValid)
            {
                logger.LogWarning("User: " + user.UserName + "\tUser Model Invalid!", oldUser);
                return (BadRequest(ModelState));
            }

            string queryStatus = "";

            /* Once User login is confirmed, pass to Service for access */
            try
            {
                delete.User = user;
            }
            catch (Exception ex)
            {
                queryStatus = "Error Initializing User with Delete Service: " + ex.Message;
                logger.LogWarning(new EventId(2, "Initialize User Error"), ex, "User: " + user.UserName + "\tUser Model Invalid!", user);
            }

            try
            {
                queryStatus = delete.OldUser(oldUser);
                logger.LogInformation("User: " + user.UserName + "\tUser Deleted Successfully", oldUser);
            }
            catch (NpgsqlException pgex)
            {
                queryStatus = "Postgres Error: " + pgex.Message;
                logger.LogError(new EventId(2, "Delete Column Error"), pgex, "User: " + user.UserName + "\tError Deleting User!", oldUser);
            }
            catch (Exception ex)
            {
                queryStatus = "User Deletion Error: " + ex.Message;
                logger.LogError(new EventId(2, "Delete User Error"), ex, "User: " + user.UserName + "\tError Deletng User!", oldUser);
            }

            return Ok(queryStatus);
        }

        // DELETE: Entanglo/Delete/Database
        [HttpDelete]
        [Consumes("application/json")]
        [Route("Database")]
        public IActionResult Database([FromBody] Database database)
        {
            logger.LogInformation("User: " + user.UserName + "\tDelete Database Attempt: " + database.DatabaseName, database);

            if (!ModelState.IsValid)
            {
                logger.LogWarning("User: " + user.UserName + "\tDatabase Model Invalid!", database);
                return (BadRequest(ModelState));
            }

            string queryStatus = "";

            /* Once User login is confirmed, pass to Service for access */
            try
            {
                delete.User = user;
            }
            catch (Exception ex)
            {
                queryStatus = "Error Initializing User with Delete Service: " + ex.Message;
                logger.LogWarning(new EventId(2, "Initialize User Error"), ex, "User: " + user.UserName + "\tUser Model Invalid!", user);
            }

            try
            {
                queryStatus = delete.Database(database);
                logger.LogInformation("User: " + user.UserName + "\tDatabase Deleted Successfully", database);
            }
            catch (NpgsqlException pgex)
            {
                queryStatus = "Postgres Error: " + pgex.Message;
                logger.LogError(new EventId(2, "Delete Database Error"), pgex, "User: " + user.UserName + "\tError Deleting Database!", database);
            }
            catch (Exception ex)
            {
                queryStatus = "Database Deletion Error: " + ex.Message;
                logger.LogError(new EventId(2, "Delete Database Error"), ex, "User: " + user.UserName + "\tError Deleting Database!", database);
            }

            return Ok(queryStatus);
        }


        // DELETE: Entanglo/Delete/Table
        [HttpDelete]
        [Consumes("application/json")]
        [Route("Table")]
        public IActionResult Table([FromBody] Table table)
        {
            logger.LogInformation("User: " + user.UserName + "\tDelete Table Attempt: " + table.TableName, table);

            if (!ModelState.IsValid)
            {
                logger.LogWarning("User: " + user.UserName + "\tTable Model Invalid!", table);
                return (BadRequest(ModelState));
            }

            string queryStatus = "";

            /* Once User login is confirmed, pass to Service for access */
            try
            {
                delete.User = user;
            }
            catch (Exception ex)
            {
                queryStatus = "Error Initializing User with Delete Service: " + ex.Message;
                logger.LogWarning(new EventId(2, "Initialize User Error"), ex, "User: " + user.UserName + "\tUser Model Invalid!", user);
            }

            try
            {
                queryStatus = delete.Table(table);
                logger.LogInformation("User: " + user.UserName + "\tTable Deleted Successfully", table);
            }
            catch (NpgsqlException pgex)
            {
                queryStatus = "Postgres Error: " + pgex.Message;
                logger.LogError(new EventId(2, "Delete Table Error"), pgex, "User: " + user.UserName + "\tError Deleting Table!", table);
            }
            catch (Exception ex)
            {
                queryStatus = "Table Deletion Error: " + ex.Message;
                logger.LogError(new EventId(2, "Delete Table Error"), ex, "User: " + user.UserName + "\tError Deleting Table!", table);
            }

            return Ok(queryStatus);
        }


        // DELETE: Entanglo/Delete/Column
        [HttpDelete]
        [Consumes("application/json")]
        [Route("Column")]
        public IActionResult Column([FromBody] Column column)
        {
            logger.LogInformation("User: " + user.UserName + "\tDelete Column Attempt: " + column.ColumnName, column);

            if (!ModelState.IsValid)
            {
                logger.LogWarning("User: " + user.UserName + "\tColumn Model Invalid!", column);
                return (BadRequest(ModelState));
            }

            string queryStatus = "";

            /* Once User login is confirmed, pass to Service for access */
            try
            {
                delete.User = user;
            }
            catch (Exception ex)
            {
                queryStatus = "Error Initializing User with Delete Service: " + ex.Message;
                logger.LogWarning(new EventId(2, "Initialize User Error"), ex, "User: " + user.UserName + "\tUser Model Invalid!", user);
            }

            try
            {
                queryStatus = delete.Column(column);
                logger.LogInformation("User: " + user.UserName + "\tColumn Deleted Successfully", column);
            }
            catch (NpgsqlException pgex)
            {
                queryStatus = "Postgres Error: " + pgex.Message;
                logger.LogError(new EventId(2, "Delete Column Error"), pgex, "User: " + user.UserName + "\tError Deleting Column!", column);
            }
            catch (Exception ex)
            {
                queryStatus = "Column Deletion Error: " + ex.Message;
                logger.LogError(new EventId(2, "Delete Column Error"), ex, "User: " + user.UserName + "\tError Deleting Column!", column);
            }

            return Ok(queryStatus);
        }

        // DELETE: Entanglo/Delete/Column
        [HttpDelete]
        [Consumes("application/json")]
        [Route("Profile")]
        public IActionResult Profile()
        {
            logger.LogInformation("User: " + user.UserName + "\tDelete Column Attempt: ");

            if (!ModelState.IsValid)
            {
                logger.LogWarning("User: " + user.UserName + "\tColumn Model Invalid!");
                return (BadRequest(ModelState));
            }

            string queryStatus = "";

            /* Once User login is confirmed, pass to Service for access */
            try
            {
                delete.User = user;
            }
            catch (Exception ex)
            {
                queryStatus = "Error Initializing User with Delete Service: " + ex.Message;
                logger.LogWarning(new EventId(2, "Initialize User Error"), ex, "User: " + user.UserName + "\tUser Model Invalid!", user);
            }

            try
            {
                if (delete.Profile())
                    return Ok(queryStatus);
                logger.LogInformation("User: " + user.UserName + "\tColumn Deleted Successfully");
            }
            catch (NpgsqlException pgex)
            {
                queryStatus = "Postgres Error: " + pgex.Message;
                logger.LogError(new EventId(2, "Delete Column Error"), pgex, "User: " + user.UserName + "\tError Deleting Column!");
            }
            catch (Exception ex)
            {
                queryStatus = "Column Deletion Error: " + ex.Message;
                logger.LogError(new EventId(2, "Delete Column Error"), ex, "User: " + user.UserName + "\tError Deleting Column!");
            }

            return BadRequest(queryStatus);
        }

        [HttpDelete]
        [Consumes("application/json")]
        [Route("ProfileData")]
        public IActionResult ProfileData()
        {
            logger.LogInformation("User: " + user.UserName + "\tDelete Column Attempt: ");

            if (!ModelState.IsValid)
            {
                logger.LogWarning("User: " + user.UserName + "\tColumn Model Invalid!");
                return (BadRequest(ModelState));
            }

            string queryStatus = "";

            /* Once User login is confirmed, pass to Service for access */
            try
            {
                delete.User = user;
            }
            catch (Exception ex)
            {
                queryStatus = "Error Initializing User with Delete Service: " + ex.Message;
                logger.LogWarning(new EventId(2, "Initialize User Error"), ex, "User: " + user.UserName + "\tUser Model Invalid!", user);
            }

            try
            {
                if (delete.ProfileData())
                    return Ok(queryStatus);
                logger.LogInformation("User: " + user.UserName + "\tColumn Deleted Successfully");
            }
            catch (NpgsqlException pgex)
            {
                queryStatus = "Postgres Error: " + pgex.Message;
                logger.LogError(new EventId(2, "Delete Column Error"), pgex, "User: " + user.UserName + "\tError Deleting Column!");
            }
            catch (Exception ex)
            {
                queryStatus = "Column Deletion Error: " + ex.Message;
                logger.LogError(new EventId(2, "Delete Column Error"), ex, "User: " + user.UserName + "\tError Deleting Column!");
            }

            return BadRequest(queryStatus);
        }

        [HttpDelete]
        [Consumes("application/json")]
        [Route("UserTables")]
        public IActionResult UserTables()
        {
            logger.LogInformation("User: " + user.UserName + "\tDelete Column Attempt: ");

            if (!ModelState.IsValid)
            {
                logger.LogWarning("User: " + user.UserName + "\tColumn Model Invalid!");
                return (BadRequest(ModelState));
            }

            string queryStatus = "";

            /* Once User login is confirmed, pass to Service for access */
            try
            {
                delete.User = user;
            }
            catch (Exception ex)
            {
                queryStatus = "Error Initializing User with Delete Service: " + ex.Message;
                logger.LogWarning(new EventId(2, "Initialize User Error"), ex, "User: " + user.UserName + "\tUser Model Invalid!", user);
            }

            try
            {
                if (delete.UserTables())
                    return Ok(queryStatus);
                logger.LogInformation("User: " + user.UserName + "\tColumn Deleted Successfully");
            }
            catch (NpgsqlException pgex)
            {
                queryStatus = "Postgres Error: " + pgex.Message;
                logger.LogError(new EventId(2, "Delete Column Error"), pgex, "User: " + user.UserName + "\tError Deleting Column!");
            }
            catch (Exception ex)
            {
                queryStatus = "Column Deletion Error: " + ex.Message;
                logger.LogError(new EventId(2, "Delete Column Error"), ex, "User: " + user.UserName + "\tError Deleting Column!");
            }

            return BadRequest(queryStatus);
        }
    }
}
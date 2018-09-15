/// \file  UpdateController
///
/// Major <b>UpdateController.cs</b>
/// \details <b>Details</b>
/// -   This file is a controller that handles all the service calls and
///     routing for any updates/put made to a user, database, table, and columns
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
using Microsoft.Extensions.Configuration;
using DatabaseServices;
using DomainModels;
using Npgsql;
using Microsoft.Extensions.Logging;

namespace EntangloWebService.Controllers
{
    [Produces("application/json")]
    [Route("Entanglo/[controller]")]
    public class UpdateController : Controller
    {
        private IConfiguration configuration;
        private readonly ILogger<UpdateController> logger = null;
        private UpdateService update;
        private User user = new DomainModels.User(1, "Marcus Rankin", "pa55w0rd", "blah@blah.com");


        public UpdateController(IConfiguration _configuration, ILogger<UpdateController> _logger)
        {
            configuration = _configuration;
            logger = _logger;
            update = new UpdateService(configuration, "MainConnection");
        }

        // PUT: Entanglo/Update/User
        [HttpPut]
        [Consumes("application/json")]
        [Route("User")]
        public new IActionResult User([FromBody] User singleUser)
        {
            logger.LogInformation("User: " + user.UserName + "\tUpdate User Attempt: " + user.UserName, singleUser);

            if (!ModelState.IsValid)
            {
                logger.LogWarning("User: " + user.UserName + "\tUser Model Invalid!", singleUser);
                return (BadRequest(ModelState));
            }

            string queryStatus = "";

            /* Once User login is confirmed, pass to Service for access */
            try
            {
                update.User = user;
            }
            catch (Exception ex)
            {
                queryStatus = "Error Initializing User with Update Service: " + ex.Message;
                logger.LogWarning(new EventId(2, "Initialize User Error"), ex, "User: " + user.UserName + "\tUser Model Invalid!", user);
            }

            try
            {
                queryStatus = update.OldUser(singleUser);
                logger.LogInformation("User: " + user.UserName + "\tUser Updated Successfully", singleUser);
            }
            catch (NpgsqlException pgex)
            {
                queryStatus = "Postgres Error: " + pgex.Message;
                logger.LogError(new EventId(2, "Update User Error"), pgex, "User: " + user.UserName + "\tError Updating User!", singleUser);
            }
            catch (Exception ex)
            {
                queryStatus = "User Updating Error: " + ex.Message;
                logger.LogError(new EventId(2, "Update User Error"), ex, "User: " + user.UserName + "\tError Updating User!", singleUser);
            }

            return Ok(queryStatus);
        }

        // PUT: Entanglo/Update/Database
        [HttpPut]
        [Consumes("application/json")]
        [Route("Database")]
        public IActionResult Database([FromBody] Database database)
        {
            logger.LogInformation("User: " + user.UserName + "\tUpdate Database Attempt: " + database.DatabaseName, database);

            if (!ModelState.IsValid)
            {
                logger.LogWarning("User: " + user.UserName + "\tDatabase Model Invalid!", database);
                return (BadRequest(ModelState));
            }

            string queryStatus = "";

            /* Once User login is confirmed, pass to Service for access */
            try
            {
                update.User = user;;
            }
            catch (Exception ex)
            {
                queryStatus = "Error Initializing User with Update Service: " + ex.Message;
                logger.LogWarning(new EventId(2, "Initialize User Error"), ex, "User: " + user.UserName + "\tUser Model Invalid!", user);
            }

            try
            {
                queryStatus = update.Database(database);
                logger.LogInformation("User: " + user.UserName + "\tDatabase Updated Successfully", database);
            }
            catch (NpgsqlException pgex)
            {
                queryStatus = "Postgres Error: " + pgex.Message;
                logger.LogError(new EventId(2, "Update Database Error"), pgex, "User: " + user.UserName + "\tError Updating Database!", database);
            }
            catch (Exception ex)
            {
                queryStatus = "Database Updating Error: " + ex.Message;
                logger.LogError(new EventId(2, "Update Database Error"), ex, "User: " + user.UserName + "\tError Updating Database!", database);
            }

            return Ok(queryStatus);
        }


        // PUT: Entanglo/Update/Table
        [HttpPut]
        [Consumes("application/json")]
        [Route("Table")]
        public IActionResult Table([FromBody] Table table)
        {
            logger.LogInformation("User: " + user.UserName + "\tUpdate Table Attempt: " + table.TableName, table);

            if (!ModelState.IsValid)
            {
                logger.LogWarning("User: " + user.UserName + "\tTable Model Invalid!", table);
                return (BadRequest(ModelState));
            }

            string queryStatus = "";

            /* Once User login is confirmed, pass to Service for access */
            try
            {
                update.User = user;
            }
            catch (Exception ex)
            {
                queryStatus = "Error Initializing User with Update Service: " + ex.Message;
                logger.LogWarning(new EventId(2, "Initialize User Error"), ex, "User: " + user.UserName + "\tUser Model Invalid!", user);
            }

            try
            {
                queryStatus = update.Table(table);
                logger.LogInformation("User: " + user.UserName + "\tTable Updated Successfully", table);
            }
            catch (NpgsqlException pgex)
            {
                queryStatus = "Postgres Error: " + pgex.Message;
                logger.LogError(new EventId(2, "Update Table Error"), pgex, "User: " + user.UserName + "\tError Updating Table!", table);
            }
            catch (Exception ex)
            {
                queryStatus = "Table Updating Error: " + ex.Message;
                logger.LogError(new EventId(2, "Update Table Error"), ex, "User: " + user.UserName + "\tError Updating Table!", table);
            }

            return Ok(queryStatus);
        }


        // PUT: Entanglo/Update/Column
        [HttpPut]
        [Consumes("application/json")]
        [Route("Column")]
        public IActionResult Column([FromBody] Column column)
        {
            logger.LogInformation("User: " + user.UserName + "\tUpdate Column Attempt: " + column.ColumnName, column);

            if (!ModelState.IsValid)
            {
                logger.LogWarning("User: " + user.UserName + "\tColumn Model Invalid!", column);
                return (BadRequest(ModelState));
            }

            string queryStatus = "";

            /* Once User login is confirmed, pass to Service for access */
            try
            {
                update.User = user;
            }
            catch (Exception ex)
            {
                queryStatus = "Error Initializing User with Update Service: " + ex.Message;
                logger.LogWarning(new EventId(2, "Initialize User Error"), ex, "User: " + user.UserName + "\tUser Model Invalid!", user);
            }

            try
            {
                queryStatus = update.Column(column);
                logger.LogInformation("User: " + user.UserName + "\tColumn Updated Successfully", column);
            }
            catch (NpgsqlException pgex)
            {
                queryStatus = "Postgres Error: " + pgex.Message;
                logger.LogError(new EventId(2, "Update Column Error"), pgex, "User: " + user.UserName + "\tError Updating Column!", column);
            }
            catch (Exception ex)
            {
                queryStatus = "Column Updating Error: " + ex.Message;
                logger.LogError(new EventId(2, "Update Column Error"), ex, "User: " + user.UserName + "\tError Updating Column!", column);
            }

            return Ok(queryStatus);
        }

    }
}

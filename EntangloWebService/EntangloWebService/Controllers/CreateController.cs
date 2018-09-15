/// \file  CreateController
///
/// Major <b>CreateController.cs</b>
/// \details <b>Details</b>
/// -   This file is a controller that handles all the service calls and
///     routing for any creates/post made to a user, database, table, and columns
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
using Microsoft.AspNetCore.Identity;
using DomainModels.AiModels;

namespace EntangloWebService.Controllers
{
    [Produces("application/json")]
    [Route("Entanglo/[controller]")]
    public class CreateController : Controller
    {
        private IConfiguration configuration;
        private readonly ILogger<CreateController> logger = null;
        private CreateService create;
        //private User user = new DomainModels.User(1, "Marcus Rankin", "pa55w0rd", "blah@blah.com");
        private readonly UserManager<ApplicationUser> userManager;

        private ApplicationUser appUser;
        private User user = new User("user@entanglo.com");

        /* CREATE LOGIN/AUTHENTICATION FUNCTION 
         
           Once verified pull User info from Main dB
           for database list retrieval and addition  */
        

        public CreateController(IConfiguration _configuration, ILogger<CreateController> _logger, UserManager<ApplicationUser> _userManager)
        {
            configuration = _configuration;
            logger = _logger;
            userManager = _userManager;
            create = new CreateService(configuration, "MainConnection");

        }

        [HttpGet]
        [Route("GetUser")]
        public async Task<IActionResult> GetUser()
        {
            appUser = await GetCurrentUserAsync();

            user.UserName = appUser.UserName;
            user.Email = appUser.Email;

            return Ok();
        }

        private Task<ApplicationUser> GetCurrentUserAsync() => userManager.GetUserAsync(HttpContext.User);

        [HttpPost]
        [Route("Test")]
        [Consumes("text/plain")]
        //[Consumes("application/json")]
        public IActionResult Test(string test)
        {
            test = test + "\tReceived!";


            return Ok(test);
        }


        // POST: Entanglo/Create/User
        [HttpPost]
        [Consumes("application/json")]
        [Route("User")]
        public new IActionResult User([FromBody] User singleUser)
        {
            GetUser();
            logger.LogInformation("User: " + user.UserName + "\tCreate User Attempt: " + user.UserName, singleUser);

            if (!ModelState.IsValid)
            {
                logger.LogWarning("User: " + user.UserName + "\tUser Model Invalid!", singleUser);
                return (BadRequest(ModelState));
            }

            string queryStatus = "";

            /* Once User login is confirmed, pass to Service for access */
            try
            {
                create.User = user;
            }
            catch (Exception ex)
            {
                queryStatus = "Error Initializing User with Create Service: " + ex.Message;
                logger.LogWarning(new EventId(2, "Initialize User Error"), ex, "User: " + user.UserName + "\tUser Model Invalid!", user);
            }

            try
            {
                queryStatus = create.NewUser(singleUser);
                logger.LogInformation("User: " + user.UserName + "\tUser Created Successfully", singleUser);
            }
            catch (NpgsqlException pgex)
            {
                queryStatus = "Postgres Error: " + pgex.Message;
                logger.LogError(new EventId(2, "Create User Error"), pgex, "User: " + user.UserName + "\tError Creating User!", singleUser);
            }
            catch (Exception ex)
            {
                queryStatus = "User Creation Error: " + ex.Message;
                logger.LogError(new EventId(2, "Create User Error"), ex, "User: " + user.UserName + "\tError Creating User!", singleUser);
            }

            return Ok(queryStatus);
        }


        // POST: Entanglo/Create/Database
        [HttpPost]
        [Consumes("application/json")]
        [Route("Database")]
        public IActionResult Database([FromBody] Database database)
        {
            logger.LogInformation("User: " + user.UserName + "\tCreate Database Attempt: " + database.DatabaseName, database);

            if (!ModelState.IsValid)
            {
                logger.LogWarning("User: " + user.UserName + "\tDatabase Model Invalid!", database);
                return (BadRequest(ModelState));
            }

            string queryStatus = "";

            /* Once User login is confirmed, pass to Service for access */
            try
            {
                create.User = user;
            }
            catch (Exception ex)
            {
                queryStatus = "Error Initializing User with Create Service: " + ex.Message;
                logger.LogWarning(new EventId(2, "Initialize User Error"), ex, "User: " + user.UserName + "\tUser Model Invalid!", user);
            }

            try
            {
                queryStatus = create.Database(database);
                logger.LogInformation("User: " + user.UserName + "\tDatabase Created Successfully", database);
            }
            catch (NpgsqlException pgex)
            {
                queryStatus = "Postgres Error: " + pgex.Message;
                logger.LogError(new EventId(2, "Create Database Error"), pgex, "User: " + user.UserName + "\tError Creating Database!", database);
            }
            catch (Exception ex)
            {
                queryStatus = "Database Creation Error: " + ex.Message;
                logger.LogError(new EventId(2, "Create Database Error"), ex, "User: " + user.UserName + "\tError Creating Database!", database);
            }

            return Ok(queryStatus);
        }


        // POST: Entanglo/Create/Table
        [HttpPost]
        [Consumes("application/json")]
        [Route("Table")]
        public IActionResult Table([FromBody] NewTable table)
        {
            logger.LogInformation("User: " + user.UserName + "\tCreate Table Attempt: " + table.TableName, table);

            if (!ModelState.IsValid)
            {
                logger.LogWarning("User: " + user.UserName + "\tTable Model Invalid!", table);
                return (BadRequest(ModelState));
            }

            string queryStatus = "";

            /* Once User login is confirmed, pass to Service for access */
            try
            {
                create.User = user;
            }
            catch (Exception ex)
            {
                queryStatus = "Error Initializing User with Create Service: " + ex.Message;
                logger.LogWarning(new EventId(2, "Initialize User Error"), ex, "User: " + user.UserName + "\tUser Model Invalid!", user);
                return BadRequest(queryStatus);
            }

            try
            {
                queryStatus = create.Table(table);
                logger.LogInformation("User: " + user.UserName + "\tTable Created Successfully", table);
            }
            catch (NpgsqlException pgex)
            {
                queryStatus = "Postgres Error: " + pgex.Message;
                logger.LogError(new EventId(2, "Create Table Error"), pgex, "User: " + user.UserName + "\tError Creating Table!", table);
                return BadRequest(queryStatus);
            }
            catch (Exception ex)
            {
                queryStatus = "Table Creation Error: " + ex.Message;
                logger.LogError(new EventId(2, "Create Table Error"), ex, "User: " + user.UserName + "\tError Creating Table!", table);
                return BadRequest(queryStatus);
            }

            return Ok(queryStatus);
        }


        // POST: Entanglo/Create/Column
        [HttpPost]
        [Consumes("application/json")]
        [Route("Column")]
        public IActionResult Column([FromBody] Column column)
        {
            logger.LogInformation("User: " + user.UserName + "\tCreate Column Attempt: " + column.ColumnName, column);

            if (!ModelState.IsValid)
            {
                logger.LogWarning("User: " + user.UserName + "\tColumn Model Invalid!", column);
                return (BadRequest(ModelState));
            }

            string queryStatus = "";

            /* Once User login is confirmed, pass to Service for access */
            try
            {
                create.User = user;
            }
            catch (Exception ex)
            {
                queryStatus = "Error Initializing User with Create Service: " + ex.Message;
                logger.LogWarning(new EventId(2, "Initialize User Error"), ex, "User: " + user.UserName + "\tUser Model Invalid!", user);
            }

            try
            {
                queryStatus = create.Column(column);
                logger.LogInformation("User: " + user.UserName + "\tColumn Created Successfully", column);
            }
            catch (NpgsqlException pgex)
            {
                queryStatus = "Postgres Error: " + pgex.Message;
                logger.LogError(new EventId(2, "Create Column Error"), pgex, "User: " + user.UserName + "\tError Creating Column!", column);
            }
            catch (Exception ex)
            {
                queryStatus = "Column Creation Error: " + ex.Message;
                logger.LogError(new EventId(2, "Create Column Error"), ex, "User: " + user.UserName + "\tError Creating Column!", column);
            }

            return Ok(queryStatus);
        }

        // POST: Entanglo/Create/Profile
        [HttpPost]
        [Consumes("application/json")]
        [Route("Profile")]
        public IActionResult Profile([FromBody] Profile profile)
        {
            logger.LogInformation("Profile: " + user.UserName + "\tCreate Profile Attempt.");

            if (!ModelState.IsValid)
            {
                logger.LogWarning("User: " + user.UserName + "\tProfile Model Invalid!");
                return (BadRequest(ModelState));
            }

            string queryStatus = "";

            /* Once User login is confirmed, pass to Service for access */
            try
            {
                create.User = user;
            }
            catch (Exception ex)
            {
                queryStatus = "Error Initializing User with Create Service: " + ex.Message;
                logger.LogWarning(new EventId(2, "Initialize User Error"), ex, "User: " + user.UserName + "\tUser Model Invalid!", user);
                return BadRequest(queryStatus);
            }

            try
            {
                queryStatus = create.Profile(profile);
                logger.LogInformation("User: " + user.UserName + "\tProfile Created Successfully", profile);
            }
            catch (NpgsqlException pgex)
            {
                queryStatus = "Postgres Error: " + pgex.Message;
                logger.LogError(new EventId(2, "Create Profile Error"), pgex, "User: " + user.UserName + "\tError Creating Profile!", profile);
                return BadRequest(queryStatus);
            }
            catch (Exception ex)
            {
                queryStatus = "Profile Creation Error: " + ex.Message;
                logger.LogError(new EventId(2, "Create Profile Error"), ex, "User: " + user.UserName + "\tError Creating Profile!", profile);
                return BadRequest(queryStatus);
            }

            return Ok(queryStatus);
        }

        // POST: Entanglo/Create/ProfileData
        [HttpPost]
        [Consumes("application/json")]
        [Route("ProfileData")]
        public IActionResult ProfileData([FromBody] ProfileData profileData)
        {
            logger.LogInformation("Profile Data: Create Profile Data Attempt.");

            if (!ModelState.IsValid)
            {
                logger.LogWarning("Profile Data Model Invalid!");
                return (BadRequest(ModelState));
            }

            string queryStatus = "";

            /* Once User login is confirmed, pass to Service for access */
            try
            {
                create.User = user;
            }
            catch (Exception ex)
            {
                queryStatus = "Error Initializing User with Create Service: " + ex.Message;
                logger.LogWarning(new EventId(2, "Initialize User Error"), ex, "User: " + user.UserName + "\tUser Model Invalid!", user);
                return BadRequest(queryStatus);
            }

            try
            {
                queryStatus = create.ProfileData(profileData);
                logger.LogInformation("User: " + user.UserName + "\tProfile Created Successfully", profileData);
            }
            catch (NpgsqlException pgex)
            {
                queryStatus = "Postgres Error: " + pgex.Message;
                logger.LogError(new EventId(2, "Create Profile Error"), pgex, "User: " + user.UserName + "\tError Creating Profile!", profileData);
                return BadRequest(queryStatus);
            }
            catch (Exception ex)
            {
                queryStatus = "Profile Data Creation Error: " + ex.Message;
                logger.LogError(new EventId(2, "Create Profile Data Error"), ex, "User: " + user.UserName + "\tError Creating Profile!", profileData);
                return BadRequest(queryStatus);
            }

            return Ok(queryStatus);
        }

        // POST: Entanglo/Create/InsertData
        [HttpPost]
        [Consumes("application/json")]
        [Route("InsertData")]
        public IActionResult InsertData([FromBody] DataPoint data)
        {
            logger.LogInformation("Insert Data: Insert Profile Attempt.");
            bool ret = false;

            if (!ModelState.IsValid)
            {
                logger.LogWarning("Insert Data Model Invalid!");
                return (BadRequest(ModelState));
            }

            string queryStatus = "";

            /* Once User login is confirmed, pass to Service for access */
            try
            {
                create.User = user;
            }
            catch (Exception ex)
            {
                queryStatus = "Error Initializing User with Create Service: " + ex.Message;
                logger.LogWarning(new EventId(2, "Initialize User Error"), ex, "User: " + user.UserName + "\tUser Model Invalid!", user);
                return BadRequest(queryStatus);
            }

            try
            {
                if (create.InsertData(data))
                {
                    logger.LogInformation("User: " + user.UserName + "\t" + "Data inserted Successfully");
                    return Ok("Data inserted Successfully");
                }
                
            }
            catch (NpgsqlException pgex)
            {
                queryStatus = "Postgres Error: " + pgex.Message;
                logger.LogError(new EventId(2, "Insert Data"), pgex, "User: " + user.UserName + "\tError Insert Data!");
                return BadRequest(queryStatus);
            }
            catch (Exception ex)
            {
                queryStatus = "Insert Data: " + ex.Message;
                logger.LogError(new EventId(2, "Insert Data Error"), ex, "User: " + user.UserName + "\tError Insert Data!");
                return BadRequest(queryStatus);
            }

            return BadRequest(queryStatus);
        }
    }
}

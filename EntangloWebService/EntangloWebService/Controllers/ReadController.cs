/// \file  ReadController
///
/// Major <b>ReadController.cs</b>
/// \details <b>Details</b>
/// -   This file is a controller that handles all the service calls and
///     routing for any read/get queries made regarding a user, users,
///     databases, tables, and columns
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
using Microsoft.AspNetCore.Cors;
using Newtonsoft.Json;

namespace EntangloWebService.Controllers
{
    [Produces("application/json")]
    [Route("Entanglo/[controller]")]
    public class ReadController : Controller
    {
        private IConfiguration configuration;
        private readonly ILogger<ReadController> logger = null;
        private ReadService read;
        private User user =  new DomainModels.User(1, "mrankin@entanglo.com", "pa55w0rd", "mrankin@entanglo.com");


        /* CREATE LOGIN/AUTHENTICATION FUNCTION 
         
           Once verified pull User info from Main dB
           for database list retrieval and addition  */


        public ReadController(IConfiguration _configuration, ILogger<ReadController> _logger)
        {
            configuration = _configuration;
            logger = _logger;
            read = new ReadService(configuration, "MainConnection");
        }


        // GET: Entanglo/Read/User
        [HttpGet]
        //[Consumes("application/json")]
        [Route("User")]
        public new IActionResult User(string getUser)
        {
            User singleUser = new User(getUser);

            logger.LogInformation("User: " + user.UserName + "\tRead User Attempt: " + user.UserName, singleUser);

            if (!ModelState.IsValid)
            {
                logger.LogWarning("User: " + user.UserName + "\tUser Model Invalid!", singleUser);
                return (BadRequest(ModelState));
            }

            string queryStatus = "";

            /* Once User login is confirmed, pass to Service for access */
            try
            {
                read.User = user;
            }
            catch (Exception ex)
            {
                queryStatus = "Error Initializing User with Read Service: " + ex.Message;
                logger.LogWarning(new EventId(2, "Initialize User Error"), ex, "User: " + user.UserName + "\tUser Model Invalid!", user);
            }

            try
            {
                queryStatus = read.SingleUser(singleUser);
                logger.LogInformation("User: " + user.UserName + "\tUser Found Successfully", singleUser);
            }
            catch (NpgsqlException pgex)
            {
                queryStatus = "Postgres Error: " + pgex.Message;
                logger.LogError(new EventId(2, "Read User Error"), pgex, "User: " + user.UserName + "\tError Reading User!", singleUser);
            }
            catch (Exception ex)
            {
                queryStatus = "User Reading Error: " + ex.Message;
                logger.LogError(new EventId(2, "Read User Error"), ex, "User: " + user.UserName + "\tError Reading User!", singleUser);
            }

            return Ok(queryStatus);
        }

        // GET: Entanglo/Read/Users
        [HttpGet]
        //[Consumes("application/json")]
        [Route("Users")]
        public IActionResult Users()
        {
            logger.LogInformation("Users: " + user.UserName + "\tRead All Users Attempt: " + user.UserName, "All Users");

            if (!ModelState.IsValid)
            {
                logger.LogWarning("Users: " + user.UserName + "\tUser Model Invalid!", user);
                return (BadRequest(ModelState));
            }

            string queryStatus = "";

            /* Once User login is confirmed, pass to Service for access */
            try
            {
                read.User = user;
            }
            catch (Exception ex)
            {
                queryStatus = "Error Initializing User with Read Service: " + ex.Message;
                logger.LogWarning(new EventId(2, "Initialize User Error"), ex, "User: " + user.UserName + "\tUser Model Invalid!", user);
            }

            try
            {
                queryStatus = read.Users();
                logger.LogInformation("User: " + user.UserName + "\tUsers Found Successfully", "All Users");
            }
            catch (NpgsqlException pgex)
            {
                queryStatus = "Postgres Error: " + pgex.Message;
                logger.LogError(new EventId(2, "Read Users Error"), pgex, "Users: " + user.UserName + "\tError Reading Users!", "All Users");
            }
            catch (Exception ex)
            {
                queryStatus = "User Reading Error: " + ex.Message;
                logger.LogError(new EventId(2, "Read Users Error"), ex, "Users: " + user.UserName + "\tError Reading Users!", "All Users");
            }

            return Ok(queryStatus);
        }

        // GET: Entanglo/Read/Databases
        [HttpGet]
        //[Consumes("application/json")]
        [Route("Databases")]
        public IActionResult Databases(string getUser)
        {
            User singleUser = new User(getUser);

            logger.LogInformation("User: " + user.UserName + "\tRead Databases Attempt: " + user.UserName, singleUser);

            if (!ModelState.IsValid)
            {
                logger.LogWarning("User: " + user.UserName + "\tUser Model Invalid!", user);
                return (BadRequest(ModelState));
            }

            string queryStatus = "";

            /* Once User login is confirmed, pass to Service for access */
            try
            {
                read.User = user;
            }
            catch (Exception ex)
            {
                queryStatus = "Error Initializing User with Read Service: " + ex.Message;
                logger.LogWarning(new EventId(2, "Initialize User Error"), ex, "User: " + user.UserName + "\tUser Model Invalid!", user);
            }

            try
            {
                queryStatus = read.Databases(singleUser);
                logger.LogInformation("User: " + user.UserName + "\tDatabases Found Successfully", singleUser);
            }
            catch (NpgsqlException pgex)
            {
                queryStatus = "Postgres Error: " + pgex.Message;
                logger.LogError(new EventId(2, "Read Databases Error"), pgex, "User: " + user.UserName + "\tError Reading Databases!", singleUser);
            }
            catch (Exception ex)
            {
                queryStatus = "User Reading Error: " + ex.Message;
                logger.LogError(new EventId(2, "Read Databases Error"), ex, "User: " + user.UserName + "\tError Reading Databases!", singleUser);
            }

            return Ok(queryStatus);
        }


        // GET: Entanglo/Read/Tables
        [HttpGet]
        //[Consumes("application/json")]
        [Route("Tables")]
        public IActionResult Tables(string getUser, string db)
        {
            User singleUser = new User(getUser);

            Database database = new Database(db);

            logger.LogInformation("User: " + user.UserName + "\tRead Tables Attempt: " + user.UserName + "\tDatabase: " + database.DatabaseName, singleUser);

            if (!ModelState.IsValid)
            {
                logger.LogWarning("User: " + user.UserName + "\tUser Model Invalid!", user);
                return (BadRequest(ModelState));
            }

            string queryStatus = "";

            /* Once User login is confirmed, pass to Service for access */
            try
            {
                read.User = user;
            }
            catch (Exception ex)
            {
                queryStatus = "Error Initializing User with Read Service: " + ex.Message;
                logger.LogWarning(new EventId(2, "Initialize User Error"), ex, "User: " + user.UserName + "\tUser Model Invalid!", user);
            }

            try
            {
                queryStatus = read.Tables(singleUser, database.DatabaseName);
                logger.LogInformation("User: " + user.UserName + "\tTables Found Successfully", singleUser);
            }
            catch (NpgsqlException pgex)
            {
                queryStatus = "Postgres Error: " + pgex.Message;
                logger.LogError(new EventId(2, "Read Tables Error"), pgex, "User: " + user.UserName + "\tError Reading Tables!", singleUser);
                return BadRequest(queryStatus);
            }
            catch (Exception ex)
            {
                queryStatus = "Tables Reading Error: " + ex.Message;
                logger.LogError(new EventId(2, "Read Tables Error"), ex, "User: " + user.UserName + "\tError Reading Tables!", singleUser);
                return BadRequest(queryStatus);
            }

            return Ok(queryStatus);
        }

        // GET: Entanglo/Read/Columns
        [HttpGet]
        //[Consumes("application/json")]
        [Route("Columns")]
        public IActionResult Columns(string getUser, string db, string tbl)
        {
            User singleUser = new User(getUser);

            Database database = new Database(db);

            Table table = new Table(tbl);

            logger.LogInformation("User: " + user.UserName + "\tRead Columns Attempt: " + user.UserName + "\tTable: " + table.TableName, singleUser);

            if (!ModelState.IsValid)
            {
                logger.LogWarning("User: " + user.UserName + "\tUser Model Invalid!", user);
                return (BadRequest(ModelState));
            }

            string queryStatus = "";

            /* Once User login is confirmed, pass to Service for access */
            try
            {
                read.User = user;
            }
            catch (Exception ex)
            {
                queryStatus = "Error Initializing User with Read Service: " + ex.Message;
                logger.LogWarning(new EventId(2, "Initialize User Error"), ex, "User: " + user.UserName + "\tUser Model Invalid!", user);
            }

            try
            {
                queryStatus = read.Columns(singleUser, database.DatabaseName, table.TableName);
                logger.LogInformation("User: " + user.UserName + "\tColumns Found Successfully", singleUser);
            }
            catch (NpgsqlException pgex)
            {
                queryStatus = "Postgres Error: " + pgex.Message;
                logger.LogError(new EventId(2, "Read Columns Error"), pgex, "User: " + user.UserName + "\tError Reading Columns!", singleUser);
            }
            catch (Exception ex)
            {
                queryStatus = "Columns Reading Error: " + ex.Message;
                logger.LogError(new EventId(2, "Read Columns Error"), ex, "User: " + user.UserName + "\tError Reading Columns!", singleUser);
            }

            return Ok(queryStatus);
        }

        // GET: Entanglo/Read/WordRecom
        [HttpGet]
        [Route("WordRecom")]
        public IActionResult WordRecom(string targetWord)
        {
            logger.LogInformation("");

            string queryStatus = "";

            try
            {
                queryStatus = read.WordRecom(targetWord);
                logger.LogInformation("Target word Found Successfully");
            }
            catch (NpgsqlException pgex)
            {
                queryStatus = "Postgres Error: " + pgex.Message;
                logger.LogError(new EventId(2, "Read closest words for target word Error"), pgex, "\tErrorReading closest words for target word Error");
                return BadRequest(queryStatus);
            }
            catch (Exception ex)
            {
                queryStatus = "Columns Reading Error: " + ex.Message;
                logger.LogError(new EventId(2, "Read closest words for target word Error"), ex, "\tErrorReading closest words for target word Error");
                return BadRequest(queryStatus);
            }

            return Ok(queryStatus);
        }

        // GET: Entanglo/Read/Profile
        [HttpGet]
        [Route("Profile")]
        public IActionResult Profile()
        {
            logger.LogInformation("");

            string queryStatus = "";

            try
            {
                queryStatus = read.Profile();
                logger.LogInformation("Profile Found Successfully");
            }
            catch (NpgsqlException pgex)
            {
                queryStatus = "Postgres Error: " + pgex.Message;
                logger.LogError(new EventId(2, "Read Profile Error"), pgex, "\tErrorReading Profile Error");
                return BadRequest(queryStatus);
            }
            catch (Exception ex)
            {
                queryStatus = "Profile Reading Error: " + ex.Message;
                logger.LogError(new EventId(2, "Read Profile Error"), ex, "\tErrorReading Profile Error");
                return BadRequest(queryStatus);
            }
            /*
            return new JsonResult(JsonConvert.DeserializeObject(queryStatus), new JsonSerializerSettings()
            {
                Formatting = Formatting.Indented
            });
            */
            return Ok(JsonConvert.DeserializeObject(queryStatus));
        }

        [HttpGet]
        [Route("ProfileData")]
        public IActionResult ProfileData(int profileId)
        {
            logger.LogInformation("");

            string queryStatus = "";

            try
            {
                queryStatus = read.ProfileData(profileId);
                logger.LogInformation("ProfileData Found Successfully");
            }
            catch (NpgsqlException pgex)
            {
                queryStatus = "Postgres Error: " + pgex.Message;
                logger.LogError(new EventId(2, "Read ProfileData Error"), pgex, "\tErrorRead ProfileData Error");
                return BadRequest(queryStatus);
            }
            catch (Exception ex)
            {
                queryStatus = "Columns Reading Error: " + ex.Message;
                logger.LogError(new EventId(2, "Read ProfileData Error"), ex, "\tErrorRead ProfileData Error");
                return BadRequest(queryStatus);
            }
            /*
            return new JsonResult(JsonConvert.DeserializeObject(queryStatus), new JsonSerializerSettings()
            {
                Formatting = Formatting.Indented
            });
            */
            return Ok(JsonConvert.DeserializeObject(queryStatus));
        }

        [HttpGet]
        [Route("UserTables")]
        public IActionResult UserTables()
        {
            logger.LogInformation("");

            string queryStatus = "";

            try
            {
                queryStatus = read.UserTables();
                logger.LogInformation("User tables Found Successfully");
            }
            catch (NpgsqlException pgex)
            {
                queryStatus = "Postgres Error: " + pgex.Message;
                logger.LogError(new EventId(2, "Read User tables Error"), pgex, "\tErrorRead User tables Error");
                return BadRequest(queryStatus);
            }
            catch (Exception ex)
            {
                queryStatus = "Read User tables Error: " + ex.Message;
                logger.LogError(new EventId(2, "Read User tables Error"), ex, "\tErrorRead User tables Error");
                return BadRequest(queryStatus);
            }

            return Ok(JsonConvert.DeserializeObject(queryStatus));
        }

        [HttpGet]
        [Route("DataTable")]
        public IActionResult DataTable(string tableName)
        {
            logger.LogInformation("");

            string queryStatus = "Fail to read data.";

            List<List<string>> ret = null;

            try
            {
                ret = read.DataTable(tableName);
                logger.LogInformation("DataTable Found Successfully");
            }
            catch (NpgsqlException pgex)
            {
                queryStatus = "Postgres Error: " + pgex.Message;
                logger.LogError(new EventId(2, "Read DataTable Error"), pgex, "\tErrorReading DataTable Error");
                return BadRequest(queryStatus);
            }
            catch (Exception ex)
            {
                queryStatus = "DataTable Reading Error: " + ex.Message;
                logger.LogError(new EventId(2, "Read DataTable Error"), ex, "\tErrorReading DataTable Error");
                return BadRequest(queryStatus);
            }

            if (ret == null)
                return BadRequest(queryStatus);

            return Ok(ret);
        }
    }
}

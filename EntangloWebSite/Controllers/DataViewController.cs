/// Major <b>Data view APIs</b>
/// \details <b>Details</b>
/// -  It provides API to request data from DB
///   
/// <ul><li>\author     Geun Young Gil & Marcus Rankin</li>
///     <li>\copyright  Entanglo - BillClub</li>"
/// </ul>
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using EntangloWebSite.Services;
using EntangloWebSite.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;

namespace EntangloWebSite.Controllers
{
    [Produces("application/json")]
    [Route("api/DataView")]
    public class DataViewController : Controller
    {
        private DataViewService dataViewService;

        public DataViewController()
        {
            dataViewService = new DataViewService();
        }


        // GET: api/DataView/UserTables
        [HttpGet("UserTables")]
        public async Task<IActionResult> GetUserTables()
        {
            try
            {
                List<string> ret = await dataViewService.ReadUserTables();
                if (ret != null)
                    return Ok(ret);
            }
            catch (Exception e)
            {
                return BadRequest(e.Message);
            }

            return BadRequest("Unknown Error!");
        }

        [HttpGet("DataTables")]
        public async Task<IActionResult> GetDataTable(string tableName)
        {
            try
            {
                List<List<string>> ret = await dataViewService.ReadDataTable(tableName);
                if (ret != null)
                    return Ok(ret);
            }
            catch (Exception e)
            {
                return BadRequest(e.Message);
            }

            return BadRequest("Unknown Error!");
        }

        [HttpDelete("DelProfile")]
        public async Task<IActionResult> DeleteProfile()
        {
            try
            {
                bool ret = await dataViewService.DeleteProfile();
                if (ret)
                    return Ok(ret);
            }
            catch (Exception e)
            {
                return BadRequest(e.Message);
            }

            return BadRequest("Fail to delete.");
        }

        [HttpDelete("DelProfileData")]
        public async Task<IActionResult> DeleteProfileData()
        {
            try
            {
                bool ret = await dataViewService.DeleteProfileData();
                if (ret)
                    return Ok(ret);
            }
            catch (Exception e)
            {
                return BadRequest(e.Message);
            }

            return BadRequest("Fail to delete.");
        }

        [HttpDelete("DelUserTables")]
        public async Task<IActionResult> DeleteUserTables()
        {
            try
            {
                bool ret = await dataViewService.DeleteUserTables();
                if (ret)
                    return Ok(ret);
            }
            catch (Exception e)
            {
                return BadRequest(e.Message);
            }

            return BadRequest("Fail to delete.");
        }

        // GET: api/DataView/5
        [HttpGet("{id}", Name = "Get")]
        public string Get(int id)
        {
            return "value";
        }
        
        // POST: api/DataView
        [HttpPost]
        public void Post([FromBody]string value)
        {
        }
        
        // PUT: api/DataView/5
        [HttpPut("{id}")]
        public void Put(int id, [FromBody]string value)
        {
        }
        
        // DELETE: api/ApiWithActions/5
        [HttpDelete("{id}")]
        public void Delete(int id)
        {
        }
    }
}

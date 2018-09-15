/// Major <b>AI APIs (Word recommendation)</b>
/// \details <b>Details</b>
/// -  It provides API to request word recommendation for Front-end
///   
/// <ul><li>\author     Geun Young Gil & Marcus Rankin</li>
///     <li>\copyright  Entanglo - BillClub</li>"
/// </ul>
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EntangloWebSite.Services;
using EntangloWebSite.ViewModels;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;

namespace EntangloWebSite.Controllers
{
    [Produces("application/json")]
    [Route("api/ai")]
    public class AiController : Controller
    {
        private AiService aiService;

        public AiController()
        {
            aiService = new AiService();
        }

        // GET: api/Ai/WordRecom
        [HttpPost("wordrecom")]
        public async Task<IActionResult> Post([FromBody]WordRecomArgsModel model)
        {
            if (model.TargetWord == null) return new StatusCodeResult(400);

            model.TargetWord = model.TargetWord.Trim().ToLower();

            if (model.TargetWord == "") return new StatusCodeResult(400);

            WordRecomResultViewModel result = await this.aiService.GetAsyncWordRecom(model);

            return new JsonResult(result, new JsonSerializerSettings()
            {
                Formatting = Formatting.Indented
            });
        }
        
        
        /*
        // GET: api/Ai
        [HttpGet("test")]
        public IEnumerable<string> Get()
        {
            return new string[] { "value1", "value2" };
        }
        
        // GET: api/Ai/WordRecom
        [HttpGet("WordRecom")]
        public string Get(string targetWord)
        {
            return "value";
        }
        
        // POST: api/Ai
        [HttpPost]
        public void Post([FromBody]string value)
        {
        }
        
        // PUT: api/Ai/5
        [HttpPut("{id}")]
        public void Put(int id, [FromBody]string value)
        {
        }
        
        // DELETE: api/ApiWithActions/5
        [HttpDelete("{id}")]
        public void Delete(int id)
        {
        }
        */
    }
}

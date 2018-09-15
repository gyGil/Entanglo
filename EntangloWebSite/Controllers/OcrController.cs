/// Major <b>OCR & NLP APIs</b>
/// \details <b>Details</b>
/// -  APIs to provide OCR and NLP service for Front-End
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

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace EntangloWebSite.Controllers
{
    [Route("api/[controller]")]
    public class OcrController : Controller
    {
        private OcrService ocrService;
        private NlpService nlpService;

        public OcrController()
        {
            ocrService = new OcrService();
            nlpService = new NlpService();
        }

        // GET: api/
        [HttpGet]
        public IEnumerable<string> Get()
        {
            return new string[] { "value1", "value2" };
        }

        // GET api/ocr/5
        [HttpGet("{id}")]
        public string Get(int id)
        {
            return "value";
        }

        /// <summary>
        /// OCR + NLP Request
        /// </summary>
        /// <param name="ocrModel"></param>
        /// <returns></returns>
        // Post api/ocr/main
        [HttpPost("main")]
        public async Task<IActionResult> Main([FromBody]OcrImgArgsModel ocrModel)
        {
            NlpMainResultViewModel result = null;

            // OCR
            if (ocrModel == null) return new StatusCodeResult(500);

            OcrImgResultViewModel ocrResult = null;
            try
            {
                ocrResult = await ocrService.PostAsyncGoogleOcr(ocrModel);
            }
            catch (Exception e)
            {
                result = new NlpMainResultViewModel();
                result.StatusCode = System.Net.HttpStatusCode.BadRequest;
                result.Language = "en";
                result.Note = "Invalid OCR Request." + " " + e.Message;

                return new JsonResult(result, new JsonSerializerSettings()
                {
                    Formatting = Formatting.Indented
                });
            }

            if (ocrResult.Text == "")
            {
                result = new NlpMainResultViewModel();
                result.StatusCode = System.Net.HttpStatusCode.BadRequest;
                result.Language = "en";
                result.Note = "Text is not found in a requested image";

                return new JsonResult(result, new JsonSerializerSettings()
                {
                    Formatting = Formatting.Indented
                });
            }

            // NLP
            NlpArgModel nlpModel = new NlpArgModel();
            nlpModel.Text = ocrResult.Text;

            try
            {
                result = await nlpService.PostAsyncMainNlp(nlpModel);
            }
            catch (Exception e)
            {
                result = new NlpMainResultViewModel();
                result.StatusCode = System.Net.HttpStatusCode.BadRequest;
                result.Language = "en";
                result.Note = e.Message;

                return new JsonResult(result, new JsonSerializerSettings()
                {
                    Formatting = Formatting.Indented
                });
            }

            return new JsonResult(result, new JsonSerializerSettings()
            {
                Formatting = Formatting.None
            });
        }

        /// <summary>
        /// OCR + NLP Request (Alternative - Not used)
        /// </summary>
        /// <param name="ocrModel"></param>
        /// <returns></returns>
        // Post api/ocr/main/create
        [HttpPost("main/create")]
        public async Task<IActionResult> MainCreate([FromBody]MainCreateArg model)
        {
            NlpMainResultViewModel result = null;

            model.TableName = Regex.Replace(model.TableName, @"\s+", "");

            if (model.TableName.Length < 1)
            {
                result = new NlpMainResultViewModel();
                result.StatusCode = System.Net.HttpStatusCode.BadRequest;
                result.Language = "en"; 
                result.Note = "Table name is not valid.";

                return new JsonResult(result, new JsonSerializerSettings()
                {
                    Formatting = Formatting.Indented
                });
            }

            if (model.Entities.Count < 1)
            {
                result = new NlpMainResultViewModel();
                result.StatusCode = System.Net.HttpStatusCode.BadRequest;
                result.Language = "en";
                result.Note = "Entities are required.";

                return new JsonResult(result, new JsonSerializerSettings()
                {
                    Formatting = Formatting.Indented
                });
            }

            // create Profile Data
            if (!await nlpService.CreateProfileData(model))
            {
                result = new NlpMainResultViewModel();
                result.StatusCode = System.Net.HttpStatusCode.BadRequest;
                result.Language = "en";
                result.Note = "Fail to create profile data.";

                return new JsonResult(result, new JsonSerializerSettings()
                {
                    Formatting = Formatting.Indented
                });
            } 

            // create Data Table
            if (!await nlpService.CreateDataTable(model))
            {
                result = new NlpMainResultViewModel();
                result.StatusCode = System.Net.HttpStatusCode.BadRequest;
                result.Language = "en";
                result.Note = "Fail to create data table.";

                return new JsonResult(result, new JsonSerializerSettings()
                {
                    Formatting = Formatting.Indented
                });
            }

            // Insert into table
            InsertDataModel dataPoint = new InsertDataModel();
            dataPoint.TableName = model.TableName;
            foreach (NlpMainEntity entity in model.Entities)
            {
                Colume col = new Colume();
                col.Name = entity.Type;
                col.Value = entity.Name;
                dataPoint.Columns.Add(col);
            }

            if (!await nlpService.InsertDataIntoTable(dataPoint))
            {
                result = new NlpMainResultViewModel();
                result.StatusCode = System.Net.HttpStatusCode.BadRequest;
                result.Language = "en";
                result.Note = "Fail to insert data into table.";

                return new JsonResult(result, new JsonSerializerSettings()
                {
                    Formatting = Formatting.Indented
                });
            }

            // Success Return
            result = new NlpMainResultViewModel();
            result.StatusCode = System.Net.HttpStatusCode.OK;
            result.Language = "en";
            result.Note = "Success to insert data.";

            return new JsonResult(result, new JsonSerializerSettings()
            {
                Formatting = Formatting.Indented
            });
        }

        /// <summary>
        /// OCR Request
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        // POST api/ocr
        [HttpPost]
        public async Task<IActionResult>  Post([FromBody]OcrImgArgsModel model)
        {
            if (model == null) return new StatusCodeResult(500);
            OcrImgResultViewModel result = null;
            try
            {
                result = await ocrService.PostAsyncGoogleOcr(model);
            }
            catch (Exception e)
            {
                result = new OcrImgResultViewModel();
                result.StatusCode = System.Net.HttpStatusCode.BadRequest;
                result.Locale = "en";
                result.Text = "Invalid OCR Request." + " " + e.Message;
            }

            return new JsonResult(result, new JsonSerializerSettings() {
                Formatting = Formatting.Indented
            });
        }

        /// <summary>
        /// NLP Request
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        // POST api/ocr/nlp
        [HttpPost("nlp")]
        public async Task<IActionResult> Post([FromBody]NlpArgModel model)
        {
            if (model == null) return new StatusCodeResult(500);

            // NlpResultViewModel result = await nlpService.PostAsyncGoogleNlp(model);
            NlpResultViewModel result = await nlpService.PostAsyncWatsonNlp(model);

            return new JsonResult(result, new JsonSerializerSettings()
            {
                Formatting = Formatting.Indented
            });
        }


        /// <summary>
        /// Test Create Profile
        /// </summary>
        /// <returns></returns>
        // Post api/ocr/test/createprofile
        [HttpGet("test/createprofile")]
        public async Task<IActionResult> CreateProfile()
        {
            List<NlpMainEntity> entities = new List<NlpMainEntity>();
            NlpMainEntity entity = new NlpMainEntity();
            entity.Type = "Test Type";
            entity.Name = "Test Name";
            entities.Add(entity);
            entity = new NlpMainEntity();
            entity.Type = "Test2 Type";
            entity.Name = "Test2 Name";
            entities.Add(entity);

            HttpClient client = new HttpClient();
            string url = @"https://localhost:44333" + @"/Entanglo/Create/Profile";
            string body = nlpService.CreateReqBodyCreateProfile(entities);
            var stringContent = new StringContent(body, Encoding.UTF8, "application/json");
            HttpResponseMessage response = await client.PostAsync(url, stringContent);

            return new JsonResult(response, new JsonSerializerSettings()
            {
                Formatting = Formatting.Indented
            });
        }

        // Post api/ocr/test/createprofiledata
        [HttpPost("test/createprofiledata")]
        public async Task<IActionResult> CreateProfileData([FromBody]MainCreateArg model)
        {
            string response = "Fail to create profile data.";

            bool result = await nlpService.CreateProfileData(model);

            if (result)
                response = "Success to create profile data";

            return new JsonResult(response, new JsonSerializerSettings()
            {
                Formatting = Formatting.Indented
            });
        }

        // Post api/ocr/test/createdatatable
        [HttpPost("test/createdatatable")]
        public async Task<IActionResult> CreateDataTable([FromBody]MainCreateArg model)
        {
            string response = "Fail to create data table.";

            bool result = await nlpService.CreateDataTable(model);

            if (result)
                response = "Success to create data table.";

            return new JsonResult(response, new JsonSerializerSettings()
            {
                Formatting = Formatting.Indented
            });
        }

        // Post api/ocr/test/readprofile
        [HttpGet("test/readprofile")]
        public async Task<IActionResult> FindProfile()
        {
            List<NlpMainEntity> entities = new List<NlpMainEntity>();
            NlpMainEntity entity = new NlpMainEntity();
            entity.Type = "Test Type";
            entity.Name = "Test Name";
            entities.Add(entity);
            entity = new NlpMainEntity();
            entity.Type = "Test2 Type";
            entity.Name = "Test2 Name";
            entities.Add(entity);


            (int similarity, int profile_id) = await nlpService.FindProfile(entities);

            string response = "similarity: " + similarity + "\nprofile id: " + profile_id;

            return new JsonResult(response, new JsonSerializerSettings()
            {
                Formatting = Formatting.Indented
            });
        }

        // Post api/ocr/test/readprofile
        [HttpGet("test/readprofiledata")]
        public async Task<IActionResult> FindProfileData(int profileId)
        {
            List<ResServiceProfileData> result = await nlpService.FindProfileData(profileId);

            //string response = "similarity: " + similarity + "\nprofile id: " + profile_id;

            return new JsonResult(result, new JsonSerializerSettings()
            {
                Formatting = Formatting.Indented
            });
        }

        // PUT api/ocr/5
        [HttpPut("{id}")]
        public void Put(int id, [FromBody]string value)
        {
        }

        // DELETE api/ocr/5
        [HttpDelete("{id}")]
        public void Delete(int id)
        {
        }
    }
}

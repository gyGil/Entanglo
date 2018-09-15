/// Major <b>NLP Service</b>
/// \details <b>Details</b>
/// -  This class provide OCR service to read text from a image
///   
/// <ul><li>\author     Geun Young Gil & Marcus Rankin</li>
///     <li>\copyright  Entanglo - BillClub</li>"
/// </ul>
using EntangloWebSite.ViewModels;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;

namespace EntangloWebSite.Services
{
    public static class GoogleOcrType
    {
        public const string
            Image = "TEXT_DETECTION",   // ex. jpg, jpeg, png
            Document = "DOCUMENT_TEXT_DETECTION";   //  pdf
    }

    public class OcrService
    {
        /*
        *   [NOTE]
        *   Google OCR service api path and key was deleted for privacy protection
         */
        /// <summary>
        /// Request for OCR service
        /// </summary>
        /// <param name="model"></param>
        /// <returns>recognized text</returns>
        public async Task<OcrImgResultViewModel> PostAsyncGoogleOcr(OcrImgArgsModel model)
        {
            OcrImgResultViewModel ocrImgResult = new OcrImgResultViewModel();
            try
            {
                HttpClient client = new HttpClient();
                string body = this.CreateReqBodyGoogleOcr(model.Base64_image);

                var stringContent = new StringContent(body, Encoding.UTF8, "application/json");
                HttpResponseMessage response = await client.PostAsync(googleOcrUrl + googleOcrKey, stringContent);
                
                ocrImgResult.StatusCode = response.StatusCode;

                if (response.IsSuccessStatusCode)
                {

                    string responseBody = await response.Content.ReadAsStringAsync();
                    dynamic responseObject = JObject.Parse(responseBody);
                    // Check for existence of locale and description
                    ocrImgResult.Locale = responseObject.responses[0].textAnnotations[0].locale;
                    ocrImgResult.Text = responseObject.responses[0].textAnnotations[0].description;

                }
            }
            catch (Exception ex)
            {
                string errorMsg = "";
                if (ocrImgResult.Locale == null || ocrImgResult.Text == null)
                {
                    errorMsg = "NO DATA FOUND IN IMAGE";
                }

                throw new Exception(errorMsg, ex);
            }

            return ocrImgResult;
        }

        /// <summary>
        /// Build format to reguest OCR
        /// </summary>
        /// <param name="model"></param>
        /// <returns>Entities</returns>
        private string CreateReqBodyGoogleOcr(string base64_img, string type = GoogleOcrType.Image, int maxResults = 1)
        {
            JObject body = new JObject(
                new JProperty("requests",
                    new JArray(new JObject(
                        new JProperty("image",
                            new JObject(new JProperty("content", base64_img))
                        ),
                        new JProperty("features",
                            new JArray(new JObject(
                                new JProperty("type", type),
                                new JProperty("maxResults", maxResults)
                            ))
                        )
                    ))
                )
            ); 

            return body.ToString();
        }
    }
}

/// Major <b>AI service (Word recommendation)</b>
/// \details <b>Details</b>
/// -  It provides the services to get Top 10 closest words for target word
///   
/// <ul><li>\author     Geun Young Gil & Marcus Rankin</li>
///     <li>\copyright  Entanglo - BillClub</li>"
/// </ul>
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using EntangloWebSite.ViewModels;
using Newtonsoft.Json.Linq;

///
namespace EntangloWebSite.Services
{
    public class AiService
    {
        // Local host
        // private const string servisHostUrl = @"https://localhost:44333";

        // Azure Service
        private const string servisHostUrl = @"https://entanglowebservice20180424101018.azurewebsites.net/";

        private const string wordRecomUrl = @"/Entanglo/Read/WordRecom";

        /// <summary>
        /// Get words closet to target word for word recommendation
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public async Task<WordRecomResultViewModel> GetAsyncWordRecom(WordRecomArgsModel model)
        {
            WordRecomResultViewModel wordRecomResult = new WordRecomResultViewModel();
            try
            {
                HttpClient client = new HttpClient();

                string url = servisHostUrl + wordRecomUrl + @"?TargetWord=" + model.TargetWord;

                HttpResponseMessage response = await client.GetAsync(url);
                //HttpResponseMessage response = await client.GetAsync("https://postman-echo.com/get?foo1=bar1&foo2=bar2");

                wordRecomResult.StatusCode = response.StatusCode;

                if (response.IsSuccessStatusCode)
                {
                    var responseBody = await response.Content.ReadAsStringAsync();

                    // Before process: "\"[{\\\"TargetWord\\\":\\\"book\\\",\\\"C1\\\":\\\"books\\\",\\\"C2\\\":\\\"novel\\\",\\\"C3\\\":\\\"diary\\\",\\\"C4\\\":\\\"pamphlet\\\",\\\"C5\\\":\\\"preface\\\",\\\"C6\\\":\\\"autobiography\\\",\\\"C7\\\":\\\"memoir\\\",\\\"C8\\\":\\\"chapter\\\",\\\"C9\\\":\\\"essay\\\",\\\"C10\\\":\\\"poem\\\",\\\"C11\\\":\\\"story\\\",\\\"C12\\\":\\\"chronicles\\\",\\\"C13\\\":\\\"treatise\\\",\\\"C14\\\":\\\"memoirs\\\",\\\"C15\\\":\\\"commentary\\\",\\\"C16\\\":\\\"chapters\\\",\\\"C17\\\":\\\"midrash\\\",\\\"C18\\\":\\\"bible\\\",\\\"C19\\\":\\\"verse\\\",\\\"C20\\\":\\\"manuscript\\\"}]\""
                    // After process: "[{\"TargetWord\":\"book\",\"C1\":\"books\",\"C2\":\"novel\",\"C3\":\"diary\",\"C4\":\"pamphlet\",\"C5\":\"preface\",\"C6\":\"autobiography\",\"C7\":\"memoir\",\"C8\":\"chapter\",\"C9\":\"essay\",\"C10\":\"poem\",\"C11\":\"story\",\"C12\":\"chronicles\",\"C13\":\"treatise\",\"C14\":\"memoirs\",\"C15\":\"commentary\",\"C16\":\"chapters\",\"C17\":\"midrash\",\"C18\":\"bible\",\"C19\":\"verse\",\"C20\":\"manuscript\"}]"
                    responseBody = responseBody.Trim(new Char[] { ' ', '\\', '"' });
                    responseBody = responseBody.Replace("\\\"", "\"");

                    JArray a = JArray.Parse(responseBody);
                    foreach (JObject o in a.Children<JObject>())
                    {
                        foreach (JProperty p in o.Properties())
                        {
                            if (p.Name.Equals("TargetWord"))
                                wordRecomResult.TargetWord = (string)p.Value;
                            else
                                wordRecomResult.ClosestWords.Add((string)p.Value);
                            
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return wordRecomResult;
        }
    }
}

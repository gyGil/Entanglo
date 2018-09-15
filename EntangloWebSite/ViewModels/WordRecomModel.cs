/// Major <b>Word recommendation View Models</b>
/// \details <b>Details</b>
/// - Models for Word recommendation 
/// -Send a word to service, then serivce will return Top 10 Close Words of a requested word
///   
/// <ul><li>\author     Geun Young Gil & Marcus Rankin</li>
///     <li>\copyright  Entanglo - BillClub</li>"
/// </ul>

using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EntangloWebSite.ViewModels
{
    /// <summary>
    /// The request model with target word to find Top 10 close words
    /// </summary>
    [JsonObject(MemberSerialization.OptOut)]
    public class WordRecomArgsModel
    {
        public string TargetWord { get; set; }
    }

    /// <summary>
    /// The result model with target word and Top 10 close words
    /// </summary>
    [JsonObject(MemberSerialization.OptOut)]
    public class WordRecomResultViewModel
    {
        public System.Net.HttpStatusCode StatusCode { get; set; }
        public string TargetWord { get; set; }
        public List<string> ClosestWords { get; set; }

        public WordRecomResultViewModel()
        {
            ClosestWords = new List<string>();
        }
    }
}

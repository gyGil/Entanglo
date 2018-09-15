/// Major <b>ViewModels</b>
/// \details <b>Details</b>
/// -   This class is for models to receive data from service
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
    [JsonObject(MemberSerialization.OptOut)]
    public class TableName
    {
        public string table_name { get; set; }
    }
}

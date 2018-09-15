/// Major <b>NLP View Models</b>
/// \details <b>Details</b>
/// - Models to contain data from service api
/// - Models to return result of NLP service to Front-End
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
    /// Args for NLP service request
    /// </summary>
    [JsonObject(MemberSerialization.OptOut)]
    public class NlpArgModel
    {
        public string Text { get; set; }
    }

    /// <summary>
    /// Model returns NLP service result to Front-end
    /// </summary>
    [JsonObject(MemberSerialization.OptOut)]
    public class NlpMainResultViewModel
    {
        public System.Net.HttpStatusCode StatusCode { get; set; }
        public string Language { get; set; }
        public int ResultCode { get; set; }
        public string Note { get; set; }
        public List<NlpMainEntity> Entities = new List<NlpMainEntity>();
    }

    [JsonObject(MemberSerialization.OptOut)]
    public class NlpResultViewModel
    {
        public System.Net.HttpStatusCode StatusCode { get; set; }
        public string Language { get; set; }
        public List<NlpEntity> Entities = new List<NlpEntity>();
    }

    /// <summary>
    /// Model contains Entity result from NLP service
    /// </summary>
    [JsonObject(MemberSerialization.OptOut)]
    public class NlpMainEntity
    {
        public string Name { get; set; }
        public string Type { get; set; }
        public List<NlpEntityIdexInfo> IndexInfo = new List<NlpEntityIdexInfo>();
    }

    [JsonObject(MemberSerialization.OptOut)]
    public class NlpEntity
    {
        public string Name { get; set; }
        public string Type { get; set; }
    }


    /// <summary>
    /// Model contains Entity Index result from NLP service
    /// </summary>
    [JsonObject(MemberSerialization.OptOut)]
    public class NlpEntityIdexInfo
    {
        public int line { get; set; }
        public int start { get; set; }
        public int end { get; set; }

       public NlpEntityIdexInfo(int line, int start, int end)
        {
            this.line = line;
            this.start = start;
            this.end = end;
        }
    }

    /// <summary>
    /// Model contains profile and table info to create profile in Database through Entanglo Service
    /// </summary>
    [JsonObject(MemberSerialization.OptOut)]
    public class MainCreateArg
    {
        public int ProfileId { get; set; }
        public string TableName { get; set; }
        public List<NlpMainEntity> Entities = new List<NlpMainEntity>();
    }

    /// <summary>
    /// Model contains profile info from Entanglo service
    /// </summary>
    [JsonObject(MemberSerialization.OptOut)]
    public class ResServiceProfileData
    {
        public string DataTableName { get; set; }
        public List<NlpMainEntity> Recipe = new List<NlpMainEntity>();
    }

    /// <summary>
    /// Model to insert data into table
    /// </summary>
    [JsonObject(MemberSerialization.OptOut)]
    public class InsertDataModel
    {
        public string TableName { get; set; }
        public List<Colume> Columns = new List<Colume>();
    }

    /// <summary>
    /// Column for inserting into table
    /// </summary>
    [JsonObject(MemberSerialization.OptOut)]
    public class Colume
    {
        public string Name { get; set; }
        public string Value { get; set; }
    }
}

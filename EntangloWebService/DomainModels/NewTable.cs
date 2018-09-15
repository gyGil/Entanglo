/// \file  Table
///
/// Major <b>Table.cs</b>
/// \details <b>Details</b>
/// -   This file models a table and the required table information required to 
///     dynamically create a table.
///     It contains multiple constructors for different levels of table creation.
///   
/// <ul><li>\author     Geun Young Gil & Marcus Rankin</li>
///     <li>\copyright  Entanglo - BillClub</li>"
/// </ul>

using System;
using System.Collections.Generic;
using System.Text;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace DomainModels
{
    public class NewTable
    {
        public int Id { get; set; }
        public string Schema { get; set; } = "";
        public string TableName { get; set; } = "";
        public string TableUuid { get; set; } = "";

        public string JsonData { get; set; } = @"{"":""}";
        public string RawDataProfile { get; set; } = @"{}";
        public string DataProfile { get; set; } = @"{}";

        //public JObject JsonData { get; set; } = null;
        //public JObject RawDataProfile { get; set; } = null;
        //public JObject DataProfile { get; set; } = null;
        public List<Column> TableColumns { get; set; }
        public DateTime? TableCreated { get; set; } = null;
        public DateTime? TableModified { get; set; } = null;
        public DateTime? TableRemoved { get; set; } = null;
    }
}

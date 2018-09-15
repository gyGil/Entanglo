using System;
using System.Collections.Generic;
using System.Text;

namespace DomainModels.AiModels
{
    public class Profile
    {
        public string Name { get; set; }
        public string Pattern { get; set; }
        public string User { get; set; }
    }

    public class ProfileData
    {
        public int ProfileId { get; set; }
        public string DataTableName { get; set; }
        public string Recipe { get; set; }
    }

    public class DataPoint
    {
        public string TableName { get; set; }
        public List<DataPointColumn> Columns = new List<DataPointColumn>();
    }

    public class DataPointColumn
    {
        public string Name { get; set; }
        public string Value { get; set; }
    }
}


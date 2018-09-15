/// \file  Database
///
/// Major <b>Database.cs</b>
/// \details <b>Details</b>
/// -   This file models a database and the required database information required to 
///     dynamically create a database.
///     It contains multiple constructors for different levels of database creation.
///   
/// <ul><li>\author     Geun Young Gil & Marcus Rankin</li>
///     <li>\copyright  Entanglo - BillClub</li>"
/// </ul>

using System;
using System.Collections.Generic;
using System.Text;

namespace DomainModels
{
    public class Database
    {
        public int Id { get; set; }
        public string DatabaseName { get; set; } = "";
        public List<Table> DatabaseTables { get; set; }
        public string DatabaseTemplate { get; set; } = "";
        public DateTime? DatabaseCreated { get; set; } = null;
        public DateTime? DatabaseModified { get; set; } = null;
        public DateTime? DatabaseRemoved { get; set; } = null;

        public Database()
        {

        }

        public Database(string _databaseName)
        {
            DatabaseName = _databaseName;
            DatabaseCreated = DateTime.Now;
        }

        public Database(string _databaseName, List<Table> _databaseTables)
        {
            DatabaseName = _databaseName;
            if (_databaseTables.Count == 0) { DatabaseTables = new List<Table>(); }
            else { DatabaseTables = _databaseTables; }

            DatabaseCreated = DateTime.Now;
        }

        public Database(string _databaseName, string _databaseTemplate, List<Table> _databaseTables)
        {
            DatabaseName = _databaseName;
            DatabaseTemplate = _databaseTemplate;
            if (_databaseTables.Count == 0) { DatabaseTables = new List<Table>(); }
            else { DatabaseTables = _databaseTables; }

            DatabaseCreated = DateTime.Now;
        }
    }
}

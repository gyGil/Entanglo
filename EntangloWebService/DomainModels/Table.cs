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

namespace DomainModels
{
    public class Table
    {
        public int Id { get; set; }
        public string DatabaseName { get; set; } = "";
        public string TableName { get; set; } = "";
        public List<Column> TableColumns { get; set; }
        public string TableTemplate { get; set; } = "";
        public DateTime? TableCreated { get; set; } = null;
        public DateTime? TableModified { get; set; } = null;
        public DateTime? TableRemoved { get; set; } = null;

        public Table()
        {
            TableColumns = new List<Column>();
        }

        public Table(string _tableName)
        {
            TableName = _tableName;

            TableColumns = new List<Column>();
            TableCreated = DateTime.Now;
        }

        public Table(string _databaseName, string _tableName)
        {
            DatabaseName = _databaseName;
            TableName = _tableName;

            TableColumns = new List<Column>();
            TableCreated = DateTime.Now;
        }

        public Table(string _databaseName, string _tableName, List<Column> _tableColumns)
        {
            DatabaseName = _databaseName;
            TableName = _tableName;

            TableColumns = new List<Column>();
            if (_tableColumns.Count == 0) { TableColumns = new List<Column>(); }
            else { TableColumns = _tableColumns; }

            TableCreated = DateTime.Now;
        }

        public Table(string _databaseName, string _tableName, string _tableTemplate, List<Column> _tableColumns)
        {
            DatabaseName = _databaseName;
            TableName = _tableName;
            TableTemplate = _tableTemplate;

            TableColumns = new List<Column>();
            if (_tableColumns.Count == 0) { TableColumns = new List<Column>(); }
            else { TableColumns = _tableColumns; }

            TableCreated = DateTime.Now;
        }
    }
}

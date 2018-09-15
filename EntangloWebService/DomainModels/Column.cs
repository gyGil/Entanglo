/// \file  Column
///
/// Major <b>Column.cs</b>
/// \details <b>Details</b>
/// -   This file models a column and the required column information required to 
///     dynamically create a column.
///     It contains multiple constructors for different levels of column creation.
///   
/// <ul><li>\author     Geun Young Gil & Marcus Rankin</li>
///     <li>\copyright  Entanglo - BillClub</li>"
/// </ul>

using System;
using System.Collections.Generic;
using System.Text;

namespace DomainModels
{
    public class Column
    {
        public int Id { get; set; }
        public string DatabaseName { get; set; } = "";
        public string TableName { get; set; } = "";
        public string ColumnName { get; set; } = "";
        public string ColumnDataType { get; set; } = "";
        public string ColumnSize { get; set; } = "";
        public string ColumnConstraint { get; set; } = "";
        public string ColumnDefaultValue { get; set; } = "";
        public DateTime? ColumnCreated { get; set; } = null;
        public DateTime? ColumnModified { get; set; } = null;
        public DateTime? ColumnRemoved { get; set; } = null;

        public Column()
        {

        }

        public Column(string _databaseName, string _tableName, string _columnName)
        {
            DatabaseName = _databaseName;
            TableName = _tableName;
            ColumnName = _columnName;

            ColumnDataType = "TEXT";
            ColumnConstraint = "TEXT";
            ColumnDefaultValue = "NULL";
            ColumnCreated = DateTime.Now;
        }

        public Column(string _databaseName, string _tableName, string _columnName, string _columnDataType, string _columnSize)
        {
            DatabaseName = _databaseName;
            TableName = _tableName;
            ColumnName = _columnName;
            ColumnSize = _columnSize;

            if (DataType.Types.Contains(_columnDataType)) { ColumnDataType = _columnDataType; }
            else { ColumnDataType = "TEXT"; }

            ColumnConstraint = "TEXT";
            ColumnDefaultValue = "NULL";
            ColumnCreated = DateTime.Now;
        }

        public Column(string _databaseName, string _tableName, string _columnName, string _columnDataType, string _columnSize, string _columnConstraint)
        {
            DatabaseName = _databaseName;
            TableName = _tableName;
            ColumnName = _columnName;
            ColumnSize = _columnSize;

            if (DataType.Types.Contains(_columnDataType)) { ColumnDataType = _columnDataType; }
            else { ColumnDataType = "TEXT"; }

            if (DataType.Types.Contains(_columnConstraint)) { ColumnConstraint = _columnConstraint; }
            else { ColumnConstraint = "TEXT"; }

            ColumnDefaultValue = "NULL";
            ColumnCreated = DateTime.Now;
        }

        public Column(string _databaseName, string _tableName, string _columnName, string _columnDataType, string _columnSize, string _columnConstraint, string _columnDefaultValue)
        {
            DatabaseName = _databaseName;
            TableName = _tableName;
            ColumnName = _columnName;
            ColumnSize = _columnSize;

            if (DataType.Types.Contains(_columnDataType)) { ColumnDataType = _columnDataType; }
            else { ColumnDataType = "TEXT"; }

            if (DataType.Types.Contains(_columnConstraint)) { ColumnConstraint = _columnConstraint; }
            else { ColumnConstraint = "TEXT"; }

            if (DataType.Types.Contains(_columnDefaultValue)) { ColumnDefaultValue = _columnDefaultValue; }
            else { ColumnDefaultValue = "NULL"; }

            ColumnCreated = DateTime.Now;
        }
    }
}

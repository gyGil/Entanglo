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
    public class NewColumn
    {
        public string ColumnName { get; set; } = "";
        public string ColumnDataType { get; set; } = "";
        public string ColumnSize { get; set; } = "";
        public string ColumnConstraint { get; set; } = "";
        public string ColumnDefaultValue { get; set; } = "";
        public DateTime? ColumnCreated { get; set; } = null;
        public DateTime? ColumnModified { get; set; } = null;
        public DateTime? ColumnRemoved { get; set; } = null;
    }
}

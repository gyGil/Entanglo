/// \file  DataType
///
/// Major <b>DataType.cs</b>
/// \details <b>Details</b>
/// -   This file is used for verifying column data types to be of the
///     PostgreSQL data type list.
///   
/// <ul><li>\author     Geun Young Gil & Marcus Rankin</li>
///     <li>\copyright  Entanglo - BillClub</li>"
/// </ul>

using System;
using System.Collections.Generic;
using System.Text;

namespace DomainModels
{
    /// <summary>
    /// PostgreSQL accepted data types. 
    /// Column creation datatype is cross-checked with this list to verify validity
    ///     prior to calling 'creatcolumn' stored procedure.
    /// </summary>
    public static class DataType
    {
        public static readonly string[] typeList = {
            "NULL", "CHAR", "CHARACTER", "VARCHAR", "CHARACTER VARYING", "TEXT",
            "BIT", "VARBIT", "SMALLINT", "INTEGER", "BIGINT",
            "SMALLSERIAL", "SERIAL", "BIGSERIAL", "NUMERIC", "DOUBLE PRECISION",
            "REAL", "MONEY", "BOOL", "BOOLEAN",
            "DATE", "TIMESTAMP", "TIMESTAMP WITHOUT TIME ZONE", "TIMESTAMP WITH TIME ZONE",
            "TIME", "TIME WITHOUT TIME ZONE", "TIME WITH TIME ZONE",
            "JSONB"};

        public static readonly HashSet<string> Types = new HashSet<string>(typeList);
    }
}

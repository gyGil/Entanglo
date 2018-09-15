select addjson('{
  "DatabaseName": "entanglo",
  "TableName": "tblName4",
  "TableColumns": [
    { 
      "DatabaseName": "entanglo.dev",
      "TableName": "tblName3",
      "ColumnName": "colName1",
      "ColumnDataType": "text",
      "ColumnSize": "50",
      "ColumnConstraint": "",
      "ColumnDefaultValue": "null"
    },
    {
      "DatabaseName": "entanglo.dev",
      "TableName": "tblName3",
      "ColumnName": "colName2",
      "ColumnDataType": "text",
      "ColumnSize": "50",
      "ColumnConstraint": "",
      "ColumnDefaultValue": "null"
    }]
}')


select addjson('{
	"main": {
		"place": "1",
		"posx": "-603.5999999999999",
		"posy": "564.5",
		"tableUuid": "35A8C3B9-03F2-440C-AF72-D318A34D59F9"
	},
	"table": {
		"name": "Hydro",
		"place": "0",
		"positionx": "-603.5999999999999",
		"positiony": "564.5",
		"xcord": "402.4",
		"ycord": "264.5",
		"abbr": "Hydro"
	},
	"columns": {
		"column1": {
			"name": "BillingDate",
			"place": "1",
			"positionx": "-61.76180576380881",
			"positiony": "726.3211129848894",
			"xcord": "402.4",
			"ycord": "464.5",
			"abbr": "BillingDate"
		},
		"column2": {
			"name": "DueDate",
			"place": "2",
			"positionx": "-61.76180576380881",
			"positiony": "416.3211129848894",
			"xcord": "402.4",
			"ycord": "364.5",
			"abbr": "DueDate"
		},
		"column3": {
			"name": "Address",
			"place": "3",
			"positionx": "-331.7618057638088",
			"positiony": "571.3211129848894",
			"xcord": "402.4",
			"ycord": "264.5",
			"abbr": "Address"
		},
		"column4": {
			"name": "Rate",
			"place": "0",
			"positionx": "402.4",
			"positiony": "164.5",
			"xcord": "402.4",
			"ycord": "164.5",
			"abbr": "Rate"
		},
		"column5": {
			"name": "CostPerUnit",
			"place": "0",
			"positionx": "402.4",
			"positiony": "64.5",
			"xcord": "402.4",
			"ycord": "64.5",
			"abbr": "CostPerUnit"
		},
		"column6": {
			"name": "BillTotal",
			"place": "0",
			"positionx": "402.4",
			"positiony": "-35.5",
			"xcord": "402.4",
			"ycord": "-35.5",
			"abbr": "BillTotal"
		},
		"column7": {
			"name": "StartDate",
			"place": "0",
			"positionx": "402.4",
			"positiony": "-135.5",
			"xcord": "402.4",
			"ycord": "-135.5",
			"abbr": "StartDate"
		},
		"column8": {
			"name": "EndDate",
			"place": "0",
			"positionx": "402.4",
			"positiony": "-235.5",
			"xcord": "402.4",
			"ycord": "-235.5",
			"abbr": "EndDate"
		},
		"column9": {
			"name": "Chart",
			"place": "0",
			"positionx": "402.4",
			"positiony": "-335.5",
			"xcord": "402.4",
			"ycord": "-335.5",
			"abbr": "Chart"
		},
		"column10": {
			"name": "Company",
			"place": "0",
			"positionx": "402.4",
			"positiony": "-435.5",
			"xcord": "402.4",
			"ycord": "-435.5",
			"abbr": "Company"
		}
	}
}')


/* ALL DATA FROM SPECIFIC ROW */
select * from "user".tblname4 where id = 1

/* DATABASE NAME */
select jsondata ->> 'main' as DatabaseName from "user".tblname4

select jsondata -> 'main' as main from "user".tblname4

select * from "user".tblname4

/* PARENT OBJECTS AND DATA */
select json_each(jsondata::json) from json where json_id = 3

/* OBJECT KEYS OF NESTED COLUMN ARRAY */
select json_object_keys((select jsondata::json->'columns')) from json where json_id = 3;

/* SPECIFIC ELEMENT FROM NESTED ARRAY */
select json_each(jsondata::json) #>> '{columns, name}' from json where json_id = 3;

/* LIST ROWS WHERE CHILD ELEMENT NAME EXISTS IN ELEMENT COLUMN1 WHICH EXISTS IN COLUMNS IS EQUAL TO BILLING DATE */
select * from json where jsondata #> '{columns, column1, name}' = '"BillingDate"';

select * from json where jsondata = '{"column1": "BillingDate"}';

select * from json where jsondata

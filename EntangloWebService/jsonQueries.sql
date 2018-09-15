create schema if not exists "user" authorization "admin_dev"

create schema if not exists "blah"

create table "blah".table1(
	id serial
	)

create table "blah"."table2"(
	id serial,
	num integer not null default 0
	)



select createtable('user', 'tblName4', '35A8C3B9-03F2-440C-AF72-D318A34D59F9','{"main":{"place":1,"posx":-990.5999999999999,"posy":564.5,"tableUuid":"96A845CF-047F-415C-94A6-359DF293D082"},"table":{"name":"Movies","place":0,"positionx":-990.5999999999999,"positiony":564.5,"xcord":660.4,"ycord":464.5,"abbr":"Movies"}}', '{}', '{}', '{}', '{}', '{}', '{}', '{}', 'user')

select exists ( select 1 from information_schema.tables
where table_schema = 'public'
and table_name = 'user');


DROP FUNCTION public.createtable(text, text, text, text, text, text, text[], text[], text[], text[], text[], text);


INSERT INTO  "user".tblname4 (tableuuid, jsondata, rawdataprofile) VALUES ('35A8C3B9-03F2-440C-AF72-D318A34D59F9', '{"main":{"place":1,"posx":-990.5999999999999,"posy":564.5,"tableUuid":"96A845CF-047F-415C-94A6-359DF293D082"},"table":{"name":"Movies","place":0,"positionx":-990.5999999999999,"positiony":564.5,"xcord":660.4,"ycord":464.5,"abbr":"Movies"}}', '{"main":{"place":1,"posx":-990.5999999999999,"posy":564.5,"tableUuid":"96A845CF-047F-415C-94A6-359DF293D082"},"table":{"name":"Movies","place":0,"positionx":-990.5999999999999,"positiony":564.5,"xcord":660.4,"ycord":464.5,"abbr":"Movies"}}'::jsonb);

_insertString := 'INSERT INTO "' || _schema || '".' || _tableName || ' (tableuuid, jsondata, rawdataprofile) VALUES (' || _tableUuid || ', ' || jsonData || ', ' || rawDataProfile || ')';

truncate table "user".tblname4
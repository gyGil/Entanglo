-- Function: addtestentrypart(text, text, text, integer)

-- DROP FUNCTION addtestentrypart(text, text, text, integer);

CREATE OR REPLACE FUNCTION addtestentrypart(
	text,
	text,
	text,
	integer
	)
  RETURNS boolean AS
  $BODY$
  DECLARE

	_item_number   	ALIAS FOR $1;
	_revision	ALIAS for $2;
	_serialnumber	ALIAS FOR $3;
	_entry_id	ALIAS for $4;

	_item_id	integer;
	_part_id	integer;

	_entryPartAdded	boolean := false;

  begin

	/* Get item ID from item number */
	select item_id into _item_id from item where upper(item_number) = upper(_item_number);

	/* Get part ID from item number and serial number */
	SELECT 	part_id into _part_id from part inner join item on part_item_id = item_id
	where 	upper(item_number) = upper(_item_number) and upper(part_serialnumber) = upper(_serialnumber);

	/* Check if item ID and part ID were retrieved successfully */
	if _item_id is null or _part_id is null then
		raise exception 'addtestentrypart: ERROR ADDING TEST ENTRY PART AS EITHER THE ITEM ID "%" OR PART ID "%" IS NULL', _item_id, _part_id;
	end if;

	/* Add sub-assembly parts to parent part and add to test entry part table */
	if addentrypartsubass(_item_number, _revision, _serialnumber) is true then
		insert into testentrypart (testentrypart_entry_id,
						testentrypart_part_id,
						testentrypart_orig_item_id,
						testentrypart_orig_rev,
						testentrypart_orig_partnumber,
						testentrypart_created_timestamp)
		VALUES				(_entry_id,
						_part_id,
						_item_id,
						_revision,
						_serialnumber,
						now()::timestamp without time zone);

		_entryPartAdded := true;	-- Set entry part added status
	else
		raise exception 'addtestentrypart: ERROR ADDING TEST ENTRY PART AS THERE WAS AN ERROR ASSOCIATING SUB-ASSEMBLY PARTS TO PART NUMBER "%"', _serialnumber;
	end if;

	return _entryPartAdded;			-- Return entry part added status
  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function addtestentrypart(text, text, text, integer)
  owner to postgres;
COMMENT ON function addtestentrypart(text, text, text, integer)
  IS '[*New* --mrankin--] Adds a part and its sub-assemblies to a test entry';
-- Function: updateflowdef(integer, text, text, integer, boolean, boolean)

-- DROP FUNCTION updateflowdef(integer, text, text, integer, boolean, boolean);

CREATE OR REPLACE FUNCTION updateflowdef(
	integer,
	text,
	text,
	integer,
	boolean,
	boolean
	)
  RETURNS boolean AS
  $BODY$
  DECLARE

	_flowdef_id		ALIAS FOR $1;		-- Flow definition ID of the flow definition to update
	_flowdef_name   	ALIAS FOR $2;		-- Flow definition name to be updated
	_flowdef_description	ALIAS FOR $3;		-- Flow definition description to be updated
	_flowdef_type_id	ALIAS for $4;		-- Test flow type id (testtype) 
	_flowdef_multiflow	ALIAS for $5;		-- Test flow multiflow status
	_flowdef_override	ALIAS for $6;		-- Flow definition override to be updated

	_returned_flowdef_id	integer;		-- Flow definition ID of returned query
	_flowdefUpdated		boolean := false;	-- Flow definition updated status

  begin

	/* Check that flow definition ID is valid */
	if _flowdef_id is null then
		raise exception 'updateflowdef: ERROR UPDATING FLOW DEFINITION AS FLOW DEF ID IS NULL';
	END IF;

	/* Check that flow definition ID exists */
	if (select exists(select 1 from testflowdef where testflowdef_id = _flowdef_id)) is false then
		raise exception 'updateflowdef: ERROR UPDATING FLOW DEFINITION AS FLOW DEF ID "%" DOES NOT EXIST', _flowdef_id;
	end if;

	/* Check if test flow name already exists */
	if (select exists(select 1 from testflowdef where upper(testflowdef_name) = upper(_flowdef_name))) is true then
		raise exception 'updateflowdef: ERROR UPDATING FLOW DEFINITION AS TEST FLOW NAME "%" ALREADY EXISTS', _flowdef_name;
	end if;

	/* Check if test type id exists */
	If (select exists(select 1 from testtype where testtype_id = _flowdef_type_id)) is false then
		raise exception 'updateflowdef: ERROR UPDATING FLOW DEFINITION AS TEST FLOW TYPE ID "%" DOES NOT EXIST', _flowdef_type_id;
	end if;
	
	/* Update flow definition name if not null or blank */
	if _flowdef_name is not null and _flowdef_name != '' then
		update testflowdef set testflowdef_name = _flowdef_name where testflowdef_id = _flowdef_id
		returning testflowdef_id into _returned_flowdef_id;

		/* Check that flow definition name was updated successfully */
		if _returned_flowdef_id is null then
			raise exception 'updateflowdef: ERROR UPDATING FLOW DEFINITION NAME AS FLOW DEF ID IS NULL';
		END IF;
	end if;

	/* Update flow definition description if not null or blank */
	if _flowdef_description is not null and _flowdef_description != '' then
		update testflowdef set testflowdef_description = _flowdef_description where testflowdef_id = _flowdef_id
		returning testflowdef_id into _returned_flowdef_id;

		/* Check that flow definition description was updated successfully */
		if _returned_flowdef_id is null then
			raise exception 'updateflowdef: ERROR UPDATING FLOW DEFINITION DESCRIPTION AS FLOW DEF ID IS NULL';
		END IF;
	end if;

	/* Update flow definition type ID if not null */
	if _flowdef_type_id is not null then
		update testflowdef set testflowdef_type_id = _flowdef_type_id where testflowdef_id = _flowdef_id
		returning testflowdef_id into _returned_flowdef_id;

		/* Check that flow definition type ID was updated successfully */
		if _returned_flowdef_id is null then
			raise exception 'updateflowdef: ERROR UPDATING FLOW DEFINITION TYPE ID AS FLOW DEF ID IS NULL';
		END IF;
	end if;

	/* Update flow definition multiflow if not null */
	if _flowdef_multiflow is not null then

		/* Check if the flow multiflow is different than it's current status */
		if (select exists(select 1 from testflowdef where testflowdef_id = _flowdef_id
			and testflowdef_multiflow = _flowdef_multiflow)) is false then
			
			update testflowdef set testflowdef_multiflow = _flowdef_multiflow where testflowdef_id = _flowdef_id
			returning testflowdef_id into _returned_flowdef_id;

			/* Check that flow definition override was updated successfully */
			if _returned_flowdef_id is null then
				raise exception 'updateflowdef: ERROR UPDATING FLOW DEFINITION MULTIFLOW AS FLOW DEF ID IS NULL';
			END IF;
		end if;
	end if;

	/* Update flow definition override if not null */
	if _flowdef_override is not null then

		/* Check if the flow override is different than it's current status */
		if (select exists(select 1 from testflowdef where testflowdef_id = _flowdef_id
			and testflowdef_override = _flowdef_override)) is false then
			--raise exception 'I am now here';
			update testflowdef set testflowdef_override = _flowdef_override where testflowdef_id = _flowdef_id
			returning testflowdef_id into _returned_flowdef_id;

			/* Check that flow definition override was updated successfully */
			if _returned_flowdef_id is null then
				raise exception 'updateflowdef: ERROR UPDATING FLOW DEFINITION OVERRIDE AS FLOW DEF ID IS NULL';
			END IF;
		end if;
	end if;

	/* Check if either flow definition name or flow definition description or flow definition override were valid */
	if _returned_flowdef_id is null then
		raise exception 'updateflowdef: ERROR UPDATING TEST FLOW DEFINITION AS FLOW DEFINITION NAME, FLOW DEFINITION DESCRIPTION AND FLOW DEFINITION OVERRIDE ARE BLANK, NULL OR UNCHANGED';
	END IF;

	/* Update flow definition modified timestamp */
	update testflowdef set testflowdef_modified_timestamp = now()::timestamp without time zone
		where testflowdef_id = _flowdef_id;

	/* Check that flow definition modified timestamp was updated successfully */
	if (select testflowdef_modified_timestamp from testflowdef where testflowdef_id = _flowdef_id) is null then
		raise exception 'updateflowdef: ERROR UPDATING FLOW DEFINITION AS MODIFIED TIMESTAMP OF FLOW DEF ID "%" IS NULL', _returned_flowdef_id;
	else
		_flowdefUpdated := true;	-- Set flow definition updated status
	end if;

	return _flowdefUpdated;			-- Return flow definition updated status
  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function updateflowdef(integer, text, text, integer, boolean, boolean)
  owner to postgres;
COMMENT ON function updateflowdef(integer, text, text, integer, boolean, boolean)
  IS '[*New* --mrankin--] Updates a test flow definition';
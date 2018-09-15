-- Function: addflowdef(text, text, integer, boolean, boolean)

-- DROP FUNCTION addflowdef(text, text, integer, boolean, boolean);

CREATE OR REPLACE FUNCTION addflowdef(
    text,
    text,
    integer,
    boolean,
    boolean
	)
  RETURNS boolean AS
  $BODY$
  DECLARE

	_testflow_name		ALIAS FOR $1;		-- Test flow name (not null)
	_testflow_description	ALIAS FOR $2;		-- Test flow description (not null)
	_testflow_type_id	ALIAS for $3;		-- Test flow type id (testtype) (not null)
	_testflow_multiflow	ALIAS for $4;		-- Test flow multiflow status (default false)
	_testflow_override	ALIAS FOR $5;		-- Test flow override (default false)
	
	_flowdef_id		integer;		-- For checking successful test flow definition addition
	_flowDefAdded		boolean := false;	-- Flow definition addition status

  begin

	/* Check that the test flow name is not null or blank */
	if _testflow_name is null or _testflow_name = '' then
		raise exception 'addflowdef: ERROR ADDING FLOW DEFINITION AS TEST NAME IS NULL OR BLANK';
	end if;

	/* Check that the test description is not null or blank */
	if _testflow_description is null or _testflow_description = '' then
		raise exception 'addflowdef: ERROR ADDING FLOW DEFINITION AS TEST DESCRIPTION IS NULL OR BLANK';
	end if;

	/* Check if test flow name already exists */
	if (select exists(select 1 from testflowdef where upper(testflowdef_name) = upper(_testflow_name))) is true then
		raise exception 'addflowdef: ERROR ADDING FLOW DEFINITION AS TEST FLOW NAME "%" ALREADY EXISTS', _testflow_name;
	end if;

	/* Check if test type id exists */
	If (select exists(select 1 from testtype where testtype_id = _testflow_type_id)) is false then
		raise exception 'addflowdef: ERROR ADDING FLOW DEFINITION AS TEST FLOW TYPE ID "%" DOES NOT EXIST', _testflow_type_id;
	end if;

	/* Check if multiflow is null */
	if _testflow_multiflow is null then
		_testflow_multiflow := false;
	end if;

	/* Check if override is null */
	If _testflow_override is null then
		_testflow_override := false;
	end if;

	/* Add new test flow definition */
	insert into testflowdef (testflowdef_name,
				testflowdef_description,
				testflowdef_type_id,
				testflowdef_multiflow,
				testflowdef_override,
				testflowdef_created_timestamp)
	values			(_testflow_name,
				_testflow_description,
				_testflow_type_id,
				_testflow_multiflow,
				_testflow_override,
				now()::timestamp without time zone)
	returning testflowdef_id into _flowdef_id;

	/* Check that test flow definition was added successfully */
	if _flowdef_id is null then
		raise exception 'addflowdef: ERROR ADDING FLOW DEFINITION AS FLOW DEFINITION ID IS NULL';
	ELSE 
		_flowDefAdded := true;		-- Set test flow definition creation status
	end if;

	return _flowDefAdded;			-- Return test flow definition creation status

  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function addflowdef(text, text, integer, boolean, boolean)
  owner to postgres;
COMMENT ON function addflowdef(text, text, integer, boolean, boolean)
  IS '[*New* --mrankin--] Adds a new test definition';
  
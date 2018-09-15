-- Function: public.createtestentry(text, text, integer, text, text)

-- DROP FUNCTION public.createtestentry(text, text, integer, text, text);

CREATE OR REPLACE FUNCTION public.createtestentry(
    text,
    text,
    integer,
    text,
    text)
  RETURNS integer AS
$BODY$
  DECLARE

	  _item_number   ALIAS FOR $1;
	  _serialnumber	ALIAS FOR $2;
	  _test_id	ALIAS FOR $3;
	  _username 	ALIAS FOR $4;
	  _result	ALIAS FOR $5;

	  _item_id	integer;
	  _part_id	integer;
	  _part_rev	text;
	  _user_id	integer;
	  _entry_id	integer;

	  _r		record;

	  _flag_freshproduction BOOLEAN;
	  _flag_firstpass BOOLEAN;

  begin
	/* Check if item number was retrieved successfully */
	IF _item_number IS NULL or _item_number = '' THEN
		RAISE EXCEPTION 'createtestentry: ERROR CREATING TEST ENTRY AS ITEMNUMBER IS NULL OR BLANK';
	end if;
	
	/* Check if serialnumber was retrieved successfully */
	IF _serialnumber IS NULL or _serialnumber = '' THEN
		RAISE EXCEPTION 'createtestentry: ERROR CREATING TEST ENTRY AS SERIALNUMBER IS NULL OR BLANK';
	end if;

	-- Get part ID for entry
	select getpartid(_item_number, _serialnumber) into _part_id;

	/* Check if part ID is null */
	IF _part_id IS NULL THEN
		RAISE EXCEPTION 'createtestentry: ERROR CREATING TEST ENTRY AS PART ID: %', _part_id;
	end if;

	-- Get rev for entry
	select part_rev into _part_rev from part where part_id = _part_id;

	/* Check if part rev was retrieved successfully */
	IF _part_rev IS NULL or _part_rev = '' THEN
		RAISE EXCEPTION 'createtestentry: ERROR CREATING TEST ENTRY AS PART REV IS NULL OR BLANK';
	end if;

	-- Check parts existence/validity
	-- Note: Don't know what pCode is and set pAllowInactive to FALSE as I think we want Active Parts
	PERFORM (select validatepart(_item_number, _serialnumber, null, false));

	-- Check Test ID
	IF _test_id != (SELECT testdef_id FROM testdef WHERE testdef_id = _test_id) THEN
		RAISE EXCEPTION 'createtestentry: TEST ID NOT FOUND';
	END IF;


	-- Get item ID for entry
	select item_id into _item_id from item where item_number = _item_number;

	-- Get user ID for entry
	select usr_id into _user_id from usr where usr_username = _username;
	

	-- Check if first pass
	_flag_firstpass := false;
	
	if ((select testentry_id
		from testentry
		left outer join part
		on part_id = testentry_part_id
		inner join item
		on part_item_id = item_id
		where testentry_test_id = _test_id
			and item_number like (split_part(_item_number, '-', 1) || '-' || split_part(_item_number, '-', 2) || '%') 
			and part_serialnumber = _serialnumber
			and testentry_created_timestamp <= now() limit 1) is null) then
			_flag_firstpass := true;
	end if;


	-- Check if fresh production
	_flag_freshproduction := false;

	if ((select lochist_id
		from lochist
		left outer join part
		on part_id = lochist_part_id
		inner join item
		on part_item_id = item_id
		where item_number like (split_part(_item_number, '-', 1) || '-' || split_part(_item_number, '-', 2) || '%') 
		and part_serialnumber = _serialnumber
		and cast((lochist_timestamp || '') as timestamp without time zone) <= now() limit 1) is null) then
		_flag_freshproduction := true;
	end if;


	-- Insert test entry info and get entry ID
	INSERT 	INTO 	testentry (testentry_test_id, 
				testentry_part_id,
				testentry_orig_item_id,
				testentry_orig_rev,
				testentry_orig_serialnumber,
				testentry_result,
				testentry_created_user_id, 
				testentry_created_timestamp, 
				testentry_flag_firstpass, 
				testentry_flag_freshproduction)
		VALUES	(_test_id,
				_part_id, 
				_item_id,
				_part_rev,
				_serialnumber,
				_result,
				_user_id, 
				now()::timestamp without time zone, 
				_flag_firstpass, 
				_flag_freshproduction)
		RETURNING testentry_id INTO _entry_id;

	IF _entry_id IS NULL THEN
		RAISE EXCEPTION 'createtestentry: ERROR SUBMITTING TEST ENTRY (NO ENTRY ID)';
	END IF;	

	/* Add test entry part link for parent */
	PERFORM (select addtestentrypart(_item_number, _part_rev, _serialnumber, _entry_id));

	/* Get all sub-assemblies of parent part */
	FOR _r IN

		SELECT *

		FROM summsubass(	_item_number,

					_part_rev,

					_serialnumber)
					
	/* Activate all child parts of parent part if they exist */
	LOOP

		IF _r.c_item_number IS NOT NULL THEN

			PERFORM (SELECT addtestentrypart(_r.c_item_number,
							_r.c_part_rev,
							_r.c_part_serialnumber,
							_entry_id));

		END IF;

	END LOOP;
	
	return _entry_id;
	
  end;
  $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.createtestentry(text, text, integer, text, text)
  OWNER TO postgres;
GRANT EXECUTE ON FUNCTION public.createtestentry(text, text, integer, text, text) TO ames_admin;
GRANT EXECUTE ON FUNCTION public.createtestentry(text, text, integer, text, text) TO postgres;
GRANT EXECUTE ON FUNCTION public.createtestentry(text, text, integer, text, text) TO public;
COMMENT ON FUNCTION public.createtestentry(text, text, integer, text, text) IS '[*New* --mrankin--] Creates a new test entry and return the entry ID';

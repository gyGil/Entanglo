-- Function: updatetest(integer, text, text, boolean, integer)

-- DROP FUNCTION updatetest(integer, text, text, boolean, integer);

CREATE OR REPLACE FUNCTION updatetest(
	integer,
	text,
	text,
	boolean,
	integer
	)
  RETURNS boolean AS
  $BODY$
  DECLARE

	_test_id		ALIAS FOR $1;		-- Test ID of test definition to update
	_testname   		ALIAS FOR $2;		-- Test name to be updated
	_testdescription	ALIAS FOR $3;		-- Test description to be updated
	_testlocked		ALIAS for $4;		-- Test locked status
	_testtype_id		ALIAS for $5;		-- Test type ID

	_returned_test_id	integer;		-- Test ID of returned query
	_testUpdated		boolean := false;	-- Test updated status

  begin

	/* Check that test ID is valid */
	if _test_id is null then
		raise exception 'updatetest: ERROR UPDATING TEST DEFINITION AS TEST ID IS NULL';
	END IF;

	/* Check that test ID exists */
	if (select exists(select 1 from testdef where testdef_id = _test_id)) is false then
		raise exception 'updatetest: ERROR UPDATING TEST DEFINITION AS TEST ID "%" DOES NOT EXIST', _test_id;
	end if;
	
	/* Update test name if not null or blank */
	if _testname is not null and _testname != '' then
		update testdef set testdef_name = _testname where testdef_id = _test_id
		returning testdef_id into _returned_test_id;

		/* Check that test name was updated successfully */
		if _returned_test_id is null then
			raise exception 'updatetest: ERROR UPDATING TEST NAME AS TEST ID IS NULL';
		END IF;
	end if;

	/* Update test description if not null or blank */
	if _testdescription is not null and _testdescription != '' then
		update testdef set testdef_description = _testdescription where testdef_id = _test_id
		returning testdef_id into _returned_test_id;

		/* Check that test description was updated successfully */
		if _returned_test_id is null then
			raise exception 'updatetest: ERROR UPDATING TEST DESCRIPTION AS TEST ID IS NULL';
		END IF;
	end if;

	/* Update test locked status if not null */
	if _testlocked is not null then
		update testdef set testdef_locked = _testlocked where testdef_id = _test_id
		returning testdef_id into _returned_test_id;

		/* Check that test locked status was updated successfully */
		if _returned_test_id is null then
			raise exception 'updatetest: ERROR UPDATING TEST LOCKED STATUS AS TEST ID IS NULL';
		END IF;
	END IF;

	/* Update test type id if not null */
	if _testtype_id is not null then
		update testdef set testdef_type_id = _testtype_id where testdef_id = _test_id
		returning testdef_id into _returned_test_id;

		/* Check that test type id was updated successfully */
		if _returned_test_id is null then
			raise exception 'updatetest: ERROR UPDATING TEST TYPE ID AS TEST ID IS NULL';
		END IF;
	END IF;

	/* Check if either test name or test description were valid */
	if _returned_test_id is null then
		raise exception 'updatetest: ERROR UPDATING TEST DEFINITION AS BOTH TEST NAME AND TEST DESCRIPTION ARE BLANK OR NULL';
	END IF;

	/* Update test modified timestamp */
	update testdef set testdef_modified_timestamp = now()::timestamp without time zone
		where testdef_id = _test_id;

	/* Check that test modified timestamp was updated successfully */
	if (select testdef_modified_timestamp from testdef where testdef_id = _test_id) is null then
		raise exception 'updatetest: ERROR UPDATING TEST AS MODIFIED TIMESTAMP OF TEST ID "%" IS NULL', _returned_test_id;
	else
		_testUpdated := true;	-- Set test updated status
	end if;

	return _testUpdated;		-- Return test updated status
  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function updatetest(integer, text, text, boolean, integer)
  owner to postgres;
COMMENT ON function updatetest(integer, text, text, boolean, integer)
  IS '[*New* --mrankin--] Updates a test definition';
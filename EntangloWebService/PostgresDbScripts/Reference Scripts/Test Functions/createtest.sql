-- Function: createtest(text, text)

-- DROP FUNCTION createtest(text, text);

CREATE OR REPLACE FUNCTION createtest(
    text,
    text,
    integer
	)
  RETURNS boolean AS
  $BODY$
  DECLARE

	_testname   		ALIAS FOR $1;		-- Test name to be created
	_testdescription	ALIAS FOR $2;		-- Test description of new test
	_testtype		ALIAS for $3;		-- Test type of new test

	_test_id		integer;		-- Test ID of newly created test
	_testCreated		boolean := false;	-- Test creation status

  begin

	/* Check that test name is not null or blank */
	if _testname is null or _testname = '' then
		raise exception 'createtest: ERROR CREATING TEST AS TEST NAME IS NULL OR BLANK';
	end if;

	/* Check that test description is not null or blank */
	if _testdescription is null OR _testdescription = '' then
		raise exception 'createtest: ERROR CREATING TEST AS TEST DESCRIPTION IS NULL OR BLANK';
	end if;

	/* Check that test type is not null or blank */
	if _testtype is null then
		raise exception 'createtest: ERROR CREATING TEST AS TEST TYPE IS NULL OR BLANK';
	end if;

-- 	if _testtype !~ '^[0-9]' then
-- 		raise exception 'createtest: ERROR CREATING TEST AS TEST TYPE IS NOT A NUMBER';
-- 	end if

	/* Check that the test name doesn't already exist */
	if (select exists(select 1 from testdef where testdef_name = _testname)) is true then
		raise exception 'createtest: ERROR CREATING TEST AS TEST ALREADY EXISTS: %', _testname;
	end if;

	/* Check that the test type exists */
	if (select exists(select 1 from testtype where testtype_id = _testtype)) is false then
		raise exception 'createtest: ERROR CREATING TEST AS THE TEST TYPE "%" DOES NOT EXIST', _testtype;
	end if;

	/* Create new test */
	insert into testdef (testdef_name, testdef_description, testdef_type_id, testdef_created_timestamp)
	values (_testname, _testdescription, _testtype, now()::timestamp without time zone)
	returning testdef_id into _test_id;

	/* Check that test was created successfully */
	if _test_id is null then
		raise exception 'createtest: ERROR CREATING TEST AS TEST ID IS NULL';
	else
		_testCreated := true;	-- Set test create status
	end if;

	return _testCreated;		-- Return test creation status
  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function createtest(text, text)
  owner to postgres;
COMMENT ON function createtest(text, text)
  IS '[*New* --mrankin--] Creates a new test';
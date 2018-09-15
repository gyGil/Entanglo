-- Function: removetest(text)

-- DROP FUNCTION removetest(text);

CREATE OR REPLACE FUNCTION removetest(
	integer
	)
  RETURNS boolean AS
  $BODY$
  DECLARE

	_test_id   	ALIAS FOR $1;		-- Test ID to be removed

	_testdef_void	text;			-- Test void timestamp
	_testVoid	boolean := false;	-- Test void status

  begin

	/* Check if test ID is null */
	if _test_id is null then
		raise exception 'removetest: ERROR REMOVING TEST AS TEST ID IS NULL';
	end if;

	/* Check that test ID actully exists */
	if (select exists(select 1 from testdef where testdef_id = _test_id)) is false then
		raise exception 'removeest: ERROR REMOVING TEST AS TEST ID "%" DOES NOT EXIST', _test_id;
	end if;

	/* Check if test has any associated field */
	if (select exists(select 1 from testfield where testfield_test_id = _test_id limit 1)) is true then
		/* Void the associated test fields */
		update testfield set testfield_void = now()::timestamp without time zone
		where testfield_test_id = _test_id;

		/* Check if fields from test were voided successfully */
		if (select testfield_void from testfield where testfield_test_id = _test_id limit 1) is null then
			raise exception 'removetest: ERROR REMOVING FIELD FROM TEST WITH TEST ID "%" AS TEST FIELD VOID TIME STAMP DOES NOT EXIST', _test_id;
		end if;
	end if;

	/* Remove test based on test ID */
	update testdef set testdef_void = now()::timestamp without time zone
	where testdef_id = _test_id;

	/* Check that test was voided successfully */
	if (select testdef_void from testdef where testdef_id = _test_id) is null then
		raise exception 'removetest: ERROR REMOVING TEST FOR TEST ID "%" AS TEST VOID TIME STAMP DOES NOT EXIST', _test_id;
	else
		_testVoid := true;	-- Set test void status
	end if; 

	return _testVoid;		-- Return test void status
  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function removetest(integer)
  owner to postgres;
COMMENT ON function removetest(integer)
  IS '[*New* --mrankin--] Voids a test from the test definition table';
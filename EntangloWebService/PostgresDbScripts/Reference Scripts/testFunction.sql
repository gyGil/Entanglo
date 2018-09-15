-- Function: testfunction(integer, text, text)

-- DROP FUNCTION testfunction(integer, text, text);

CREATE OR REPLACE FUNCTION testfunction(
    integer,
    text,
    text
	)
  RETURNS boolean AS
  $BODY$
  DECLARE

	_param1			ALIAS for $1;		-- Parameter 1
	_param2   		ALIAS FOR $2;		-- Parameter 2
	_param3			ALIAS FOR $3;		-- Parameter 3

	_testStatus		boolean := false;	-- Test function status
  begin

	/* Update type name if not null or blank */
	if _param2 is not null and _param2 != '' then
		/* Check that the test type name doesn't already exist */
		if (select Exists(select testtype_name from testtype where upper(testtype_name) = upper(_param2) 
		group by testtype_name having count(*) > 1)) is false then
			_testStatus := false;
		else
			_testStatus := true;
		end if;
	end if;

	return _testStatus;		-- Return type updated status

  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function testfunction(integer, text, text)
  owner to postgres;
COMMENT ON function testfunction(integer, text, text)
  IS '[*New* --mrankin--] Test function for testing loops and statements';
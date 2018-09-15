-- Function: getflowseq(integer[])

-- DROP FUNCTION getflowseq(integer[]);

CREATE OR REPLACE FUNCTION getflowseq(
    integer[]
	)
  RETURNS boolean AS
  $BODY$
  DECLARE

	_test_seq		ALIAS FOR $1;		-- Flow sequence

	i			integer := 1;		-- Flow sequence iterator

	_test_seq_length	integer;		-- Amount of sequences in flow
	
	_flowseq_id		integer;		-- For checking successful test flow sequence creation
	_other_flowseq_id	integer;		-- For checking if previous sequence default was flipped
	_flowCreated		boolean := false;	-- Test creation status

  begin

	/* Get amount of sequences in flow */
	select array_length(_test_seq, 1) into _test_seq_length;

	/* Verify that the flow sequences exist as test definitions */
	while i <= _test_seq_length
	loop	/* Check each flow sequence against each test definition */
		if (select exists(select 1 from testdef where testdef_id = _test_seq[i])) is false then
			raise exception 'createtestflow: ERROR CREATING FLOW SEQUENCE AS SEQUENCE "%" DOES NOT EXIST AS A TEST DEFINITION', _test_seq[i];
		end if;

		

		i := i + 1;	-- Increment flow sequence iterator
	end loop;
	

  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function getflowseq(integer[])
  owner to postgres;
COMMENT ON function getflowseq(integer[])
  IS '[*New* --mrankin--] Gets all tests within a flow sequence';
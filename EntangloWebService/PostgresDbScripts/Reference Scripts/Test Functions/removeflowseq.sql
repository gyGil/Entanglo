-- Function: removeflowseq(integer)

-- DROP FUNCTION removeflowseq(integer);

CREATE OR REPLACE FUNCTION removeflowseq(
	integer
	)
  RETURNS boolean AS
  $BODY$
  DECLARE

	_flowseq_id  		ALIAS FOR $1;		-- Test flow sequence ID

	_flowSeqRemoved		boolean := false;	-- Flow sequence removal status

  begin

	/* Check if sequence ID is null */
	if _flowseq_id is null then
		raise exception 'removeflowseq: ERROR REMOVING FLOW SEQUENCE AS SEQUENCE ID IS NULL';
	end if;

	/* Check if sequence ID exists */
	if (select exists(select 1 from testflowseq where testflowseq_id = _flowseq_id and testflowseq_void_timestamp is null)) is false then
		raise exception 'removeflowseq: ERROR REMOVING FLOW SEQUENCE AS SEQUENCE ID "%" DOES NOT EXIST OR IS VOIDED', _flowseq_id;
	end if;

	/* Remove the test flow sequence */
	update testflowseq set testflowseq_void_timestamp = now()::timestamp without time zone
	where testflowseq_id = _flowseq_id;

	/* Check if flow sequence was removed successfully */
	if (select testflowseq_void_timestamp from testflowseq where testflowseq_id = _flowseq_id) is null then
		raise exception 'removeflowseq: ERROR REMOVING FLOW SEQUENCE WITH FLOW SEQUENCE ID "%" AS FLOW SEQUENCE REMOVED TIMESTAMP IS NULL', _flowseq_id;
	else
		_flowSeqRemoved := true;	-- Set flow sequence removed status
	end if;

	return _flowSeqRemoved;			-- Return flow sequence removed status

  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function removeflowseq(integer)
  owner to postgres;
COMMENT ON function removeflowseq(integer)
  IS '[*New* --mrankin--] Removes a test flow sequence';
-- Function: overridetestflow

-- DROP FUNCTION overridetestflow(text, boolean);

CREATE OR REPLACE FUNCTION overridetestflow(
	text,
	boolean
	)
  RETURNS boolean AS
  $BODY$
  DECLARE

	_flowdef_name		ALIAS FOR $1;		-- Flow definition name
	_flowdef_override  	ALIAS FOR $2;		-- Flow definition override status

	_flowdef_id		integer;		-- Flow definition ID
	_user_id		integer;		-- Current users ID
	_returned_flowdef_id	integer;		-- Updated override returned flow definition ID
	_flowdefOverridden	boolean := false;	-- Flow definition override status

  begin

	/* Check user has privileges to override flow definition */
	_user_id := (select getusrid());
	PERFORM (select checkpriv('testflowoverride'));

	/* Get flow definition ID of specified flow definition name */
	select testflowdef_id from testflowdef where upper(testflowdef_name) = upper(_flowdef_name) into _flowdef_id;

	/* Check if flow definition ID selection was successful */
	if _flowdef_id is null then
		raise exception 'testflowoverride: ERROR OVERRIDING FLOW DEFINITION AS FLOW DEFINITION ID IS NULL';
	end if;

	/* Check if the flow definition name exists or is not voided */
	if (select exists(select testflowdef_id from testflowdef where testflowdef_id = _flowdef_id
				AND testflowdef_void_timestamp is null)) is false then
		raise exception 'testflowoverride: ERROR OVERRIDING FLOW DEFINITION AS FLOW NAME "%" OF FLOW ID "%" DOES NOT EXIST OR IS VOIDED', _flowdef_name, _flowdef_id;
	end if;

	/* Check if the flow definition override is valid */
	if _flowdef_override is null then
		raise exception 'testflowoverride: ERROR OVERRIDING FLOW DEFINITION AS THE FLOW OVERRIDE IS NULL';
	end if;

	/* Check that the current flow override status is different */
	if (select exists(select 1 from testflowdef where testflowdef_id = _flowdef_id
			and testflowdef_override = _flowdef_override)) is true then
		raise exception 'testflowoverride: ERROR OVERRIDING FLOW DEFINITION AS THE FLOW OVERRIDE "%" DID NOT CHANGE', _flowdef_override;
	end if;

	/* Update flow definition with override status */
	update testflowdef set testflowdef_override = _flowdef_override,
				testflowdef_modified_timestamp = now()::timestamp without time zone
	where testflowdef_id = _flowdef_id 
	returning testflowdef_id into _returned_flowdef_id;

	/* Check that flow definition override was updated successfully */
	if _returned_flowdef_id is null then
		raise exception 'testflowoverride: ERROR OVERRIDING FLOW DEFINTION AS THE RETURNED FLOW DEFINITION ID IS NULL';
	else
		_flowdefOverridden := true;	-- Set flow definition updated status
	end if;

	return _flowdefOverridden;			-- Return flow definition updated status

  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function overridetestflow(text, boolean)
  owner to postgres;
COMMENT ON function overridetestflow(text, boolean)
  IS '[*New* --mrankin--] Activates or deactivates a flow definition override';
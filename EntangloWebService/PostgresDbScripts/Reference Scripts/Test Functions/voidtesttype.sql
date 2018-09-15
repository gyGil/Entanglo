-- Function: voidtesttype(integer)

-- DROP FUNCTION voidtesttype(integer);

CREATE OR REPLACE FUNCTION voidtesttype(
    integer
	)
  RETURNS boolean AS
  $BODY$
  DECLARE

	_type_id		ALIAS for $1;		-- Type id to be voided

	_typeVoided		boolean := false;	-- Type voided status

  begin

	/* Check that type ID is valid */
	if _type_id is null then
		raise exception 'voidtesttype: ERROR VOIDING TEST TYPE AS TYPE ID IS NULL';
	END IF;

	/* Check that type ID exists */
	if (select exists(select 1 from testtype where testtype_id = _type_id)) is false then
		raise exception 'voidtesttype: ERROR VOIDING TEST TYPE AS TYPE ID "%" DOES NOT EXIST', _type_id;
	end if;

	-- Check if the type has already been voided
	if (select testtype_void_timestamp from testtype where testtype_id = _type_id) is not null then
		return true;
	else
		update testtype set testtype_void_timestamp = now()::timestamp without time zone
		where testtype_id = _type_id;
	end if;
	
	-- Check if type voided successfully
	if (select testtype_void_timestamp from testtype where testtype_id = _type_id) is null then
		raise exception 'voidtesttype: ERROR VOIDING TEST TYPE WITH TYPE ID: %', _type_id;
	else
		_typeVoided := true;
	end if;

	return _typeVoided;		-- Return type voided status

  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function voidtesttype(integer)
  owner to postgres;
COMMENT ON function voidtesttype(integer)
  IS '[*New* --mrankin--] Voids a test type';
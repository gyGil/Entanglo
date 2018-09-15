-- Function: updatetesttype(integer, text, text)

-- DROP FUNCTION updatetesttype(integer, text, text);

CREATE OR REPLACE FUNCTION updatetesttype(
    integer,
    text,
    text
	)
  RETURNS boolean AS
  $BODY$
  DECLARE

	_type_id		ALIAS for $1;		-- Type id to be updated
	_typename   		ALIAS FOR $2;		-- Type name to be updated
	_typedescription	ALIAS FOR $3;		-- Type description to be updated

	_returned_type_id	integer;		-- Type ID of updated type
	_typeUpdated		boolean := false;	-- Type updated status

  begin

	/* Check that type ID is valid */
	if _type_id is null then
		raise exception 'updatetesttype: ERROR UPDATING TYPE DEFINITION AS TYPE ID IS NULL';
	END IF;

	/* Check that type ID exists */
	if (select exists(select 1 from testtype where testtype_id = _type_id)) is false then
		raise exception 'updatetesttype: ERROR UPDATING TYPE DEFINITION AS TYPE ID "%" DOES NOT EXIST', _type_id;
	end if;

	/* Update type name if not null or blank */
	if _typename is not null and _typename != '' then
		/* Check that the test type name doesn't already exist */
		if (select exists(select testtype_name from testtype where upper(testtype_name) = upper(_typename) 
		and testtype_id != _type_id))
		is false then
			update testtype set testtype_name = _typename where testtype_id = _type_id
			returning testtype_id into _returned_type_id;

			/* Check that type name was updated successfully */
			if _returned_type_id is null then
				raise exception 'updatetesttype: ERROR UPDATING TYPE NAME AS TYPE ID IS NULL';
			END IF;
		else 
			raise exception 'updatetesttype: ERROR UPDATING TEST TYPE AS TYPE NAME "%" ALREADY EXISTS', _typename;
		end if;
	end if;

	/* Update type description if not null or blank */
	if _typedescription is not null and _typedescription != '' then
		update testtype set testtype_description = _typedescription where testtype_id = _type_id
		returning testtype_id into _returned_type_id;

		/* Check that type description was updated successfully */
		if _returned_type_id is null then
			raise exception 'updatetesttype: ERROR UPDATING TYPE DESCRIPTION AS TYPE ID IS NULL';
		END IF;
	end if;

	/* Check if either type name or type description were valid */
	if _returned_type_id is null then
		raise exception 'updatetesttype: ERROR UPDATING TEST TYPE AS BOTH TYPE NAME AND TYPE DESCRIPTION ARE BLANK OR NULL';
	END IF;

	/* Update type modified timestamp */
	update testtype set testtype_modified_timestamp = now()::timestamp without time zone
		where testtype_id = _type_id;

	/* Check that type modified timestamp was updated successfully */
	if (select testtype_modified_timestamp from testtype where testtype_id = _type_id) is null then
		raise exception 'updatetesttype: ERROR UPDATING TYPE AS MODIFIED TIMESTAMP OF TYPE ID "%" IS NULL', _returned_type_id;
	else
		_typeUpdated := true;	-- Set type updated status
	end if;

	return _typeUpdated;		-- Return type updated status

  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function updatetesttype(integer, text, text)
  owner to postgres;
COMMENT ON function updatetesttype(integer, text, text)
  IS '[*New* --mrankin--] Updates a test type';
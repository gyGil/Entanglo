-- Function: addtesttype(text, text)

-- DROP FUNCTION addtesttype(text, text);

CREATE OR REPLACE FUNCTION addtesttype(
    text,
    text
	)
  RETURNS boolean AS
  $BODY$
  DECLARE

	_typename   		ALIAS FOR $1;		-- Type name to be created
	_typedescription	ALIAS FOR $2;		-- Type description of new test

	_type_id		integer;		-- Type ID of newly added type
	_typeCreated		boolean := false;	-- Type addition status

  begin

	/* Check that type name is not null or blank */
	if _typename is null or _typename = '' then
		raise exception 'addtesttype: ERROR ADDING TEST TYPE AS TEST TYPE NAME IS NULL OR BLANK';
	end if;

	/* Check that type description is not null or blank */
	if _typedescription is null OR _typedescription = '' then
		raise exception 'addtesttype: ERROR ADDING TEST TYPE AS TEST TYPE DESCRIPTION IS NULL OR BLANK';
	end if;

	/* Check that the test type doesn't already exist */
	if (select exists(select 1 from testtype where upper(testtype_name) = upper(_typename))) is true then
		/* Get test type ID of already existing test type */
		select testtype_id from testtype where upper(testtype_name) = upper(_typename) into _type_id;
		/* Check that the existing test type isn't voided */
		if (select testtype_void_timestamp from testtype where testtype_id = _type_id) is null then
			raise exception 'addtesttype: ERROR ADDING TEST TYPE AS TEST TYPE ALREADY EXISTS: %', _typename;
		eLSE
			/* Remove void from test type if type name exists (instead of creating a new one) */
			update testtype set testtype_void_timestamp = null where testtype_id = _type_id;
			/* Check that the test type void was removed successfully */
			if (select testtype_void_timestamp from testtype where testtype_id = _type_id) is not null then
				raise exception 'addtesttype: ERROR ADDING TEST TYPE AS UNABLE TO REMOVE TEST TYPE VOID TIMESTAMP OF TEST TYPE "%"', _typename;
			end if;

			/* Update test type after void is removed */
			Select updatetesttype (_type_id,
					       _typename,
					       _typedescription);
			if not FOUND then 
				raise exception 'addtesttype: ERROR ADDING TEST TYPE AS UPDATE OF TEST TYPE "%" AFTER VOID REMOVED WAS UNSUCCESSFUL', _typename;
			else
				_typeCreated := true;
			end if;
		end if;
	else 
		/* Add new type */
		insert into testtype (testtype_name, testtype_description, testtype_created_timestamp)
		values (_typename, _typedescription, now()::timestamp without time zone)
		returning testtype_id into _type_id;

		/* Check that type was added successfully */
		if _type_id is null then
			raise exception 'addtesttype: ERROR ADDING TEST TYPE AS TEST TYPE ID IS NULL';
		else
			_typeCreated := true;	-- Set type create status
		end if;
	end if;

	return _typeCreated;		-- Return type creation status

  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function addtesttype(text, text)
  owner to postgres;
COMMENT ON function addtesttype(text, text)
  IS '[*New* --mrankin--] Adds a new test type';
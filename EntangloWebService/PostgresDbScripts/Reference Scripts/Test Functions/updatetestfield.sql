-- Function: updatetestfield(integer, integer, text, text, integer, boolean, integer, text, text, text, boolean, text, boolean, boolean)

-- DROP FUNCTION updatetestfield(integer, integer, text, text, integer, boolean, integer, text, text, text, boolean, text, boolean, boolean);

CREATE OR REPLACE FUNCTION updatetestfield(
	integer,
	integer,
	text,
	text,
	integer,
	boolean,
	integer,
	text,
	text,
	text,
	boolean,
	text,
	boolean,
	boolean
	)
  RETURNS boolean AS
  $BODY$
  DECLARE

	_test_id 		ALIAS for $1;
	_field_id		ALIAS for $2;
	_field_name		ALIAS FOR $3; 
	_field_description	ALIAS for $4;
	_datatype_id		ALIAS FOR $5;
	_field_required		ALIAS FOR $6; 
	_position		ALIAS FOR $7; 
	_min_limit		ALIAS FOR $8; 
	_max_limit		ALIAS FOR $9;
	_unit_of_measure	ALIAS FOR $10;
	_result_required	ALIAS FOR $11;
	_defaultvalue		ALIAS for $12;
	_comborestricted	ALIAS FOR $13;
	_readonly		ALIAS FOR $14;

	--_testdef_name		text;			-- For displaying test name in error message
	_testfield_id		INTEGER;		-- For checking if test field creation was successful
 	--_fieldRemoved		boolean := false;	-- Test field removal status
	_fieldAdded		boolean := false;	-- Test field creation status

  begin

	/* Check that field name is not null or blank */
	if _field_id is null then
		raise exception 'updatetestfield: ERROR UPDATING TEST FIELD WITH TEST ID "%" AS FIELD ID IS NULL', _test_id;
	end if;

	/* Check that field name is not null or blank */
	if _field_name is null or _field_name = '' then
		raise exception 'updatetestfield: ERROR UPDATING TEST FIELD WITH TEST ID "%" AS FIELD NAME IS NULL OR BLANK', _test_id;
	end if;

	/* Check that field description is not null or blank */
	if _field_description is null or _field_description = '' then
		raise exception 'updatetestfield: ERROR UPDATING TEST FIELD WITH TEST ID "%" AS FIELD DESCRIPTION IS NULL OR BLANK', _test_id;
	end if;

	/* Check that the field is not already voided */
	if (select testfield_void_timestamp from testfield where testfield_id = _field_id) is not null then
		raise exception 'updatetestfield: ERROR UPDATING TEST FIELD WITH TEST ID "%" AS FIELD IS ALREADY VOIDED', _test_id;
	end if;
	
-- 	/* Remove previous field data */
-- 	if (select removetestfield(_field_id )) is false then
-- 		raise exception 'updatetestfield: ERROR UPDATING TEST FIELD WITH TEST ID "%" AND FIELD ID "%" AS PREVIOUS FIELD REMOVAL FAILED', _test_id, _testfield_id;
-- 	ELSE
-- 		_fieldRemoved := true;	-- Set field removed status
-- 	end if;

-- 	/* Add new field data if previous field data removed successfully */
-- 	if _fieldRemoved then
-- 		/* Add updated field data */
-- 		if (select addtestfield(_test_id,
-- 					_field_name,
-- 					_field_description,
-- 					_datatype_id,
-- 					_field_required,
-- 					_position,
-- 					_min_limit,
-- 					_max_limit,
-- 					_unit_of_measure,
-- 					_result_required,
-- 					_defaultvalue,
-- 					_comborestricted,
-- 					_readonly)) 
-- 		is false then
-- 			raise exception 'updatetestfield: ERROR UPDATING TEST FIELD WITH TEST ID "%" AND FIELD ID "%" AS NEW FIELD DATA ADDITION FAILED', _test_id, _testfield_id;
-- 		else 
-- 			_fieldAdded := true;	-- Set field updated status
-- 
-- 			/* Update test modified timestamp of associated field that was updated */
-- 			update testdef set testdef_modified_timestamp = now()::timestamp without time zone
-- 			where testdef_id = _test_id;
-- 
-- 			/* Check if test modified timestamp was updated successfully */
-- 			if (select testdef_modified_timestamp from testdef where testdef_id = _test_id) is null then
-- 				raise exception 'updatetestfield: ERROR UPDATING TEST MODIFIED TIMESTAMP OF TEST ID "%" OF UPDATED FIELD AS MODIFIED TIMESTAMP IS NULL', _test_id;
-- 			end if;
-- 		end if;
-- 	else
-- 		raise exception 'updatetestfield: ERROR UPDATING TEST FIELD WITH TEST ID "%" AND FIELD ID "%" AS FIELD REMOVAL FAILED', _test_id, _testfield_id;
-- 	end if;

	if (select exists(
		select 1 from testfield 
		where upper(testfield_name) = upper(_field_name) 
		and testfield_test_id = _test_id 
		AND testfield_id != _field_id)) 
		is false then
			/* Attempt to Update the field with given values */
			Update testfield set testfield_test_id = _test_id,
					 testfield_name = _field_name,
					 testfield_description = _field_description,
					 testfield_datatype_id = _datatype_id,
					 testfield_required = _field_required,
					 testfield_position = _position,
					 testfield_modified_timestamp = now()::timestamp without time zone,
					 testfield_min_limit = _min_limit,
					 testfield_max_limit = _max_limit,
					 testfield_uom = _unit_of_measure,
					 testfield_result_required = _result_required,
					 testfield_defaultvalue = _defaultvalue,
					 testfield_comborestricted = _comborestricted,
					 testfield_readonly = _readonly
			where testfield_id = _field_id;
			
			if not FOUND then 
				raise exception 'updatetestfield: ERROR UPDATING TEST FIELD AS UPDATE NOT FOUND FOR TEST ID "%" AND FIELD ID "%"', _test_id, _field_id;
				_fieldAdded := false;
			else 
				_fieldAdded := true;
			end if;
	else
		raise exception 'updatetestfield: ERROR UPDATING TEST FIELD AS THE UPDATED FIELD NAME "%" AND TEST ID "%" ALREADY EXIST', _field_name, _test_id;
	end if;
			
	return _fieldAdded;			-- Return field updated status
  end;
  $BODY$
  language plpgsql volatile
  cost 100;
 alter function updatetestfield(integer, integer, text, text, integer, boolean, integer, text, text, text, boolean, text, boolean, boolean)
   owner to postgres;		
 COMMENT ON function updatetestfield(integer, integer, text, text, integer, boolean, integer, text, text, text, boolean, text, boolean, boolean)
  IS '[*New* --mrankin--] Updates a test field of a specified test';
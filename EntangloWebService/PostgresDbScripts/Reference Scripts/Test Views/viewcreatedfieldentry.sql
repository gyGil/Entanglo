-- View: public.viewcreatedfieldentry

-- DROP VIEW public.viewcreatedfieldentry;

CREATE OR REPLACE VIEW public.viewcreatedfieldentry AS 

	SELECT 		testvalue_entry_id,
			testfield_test_id,
			testdef_name,
			testvalue_field_id,
			testfield_name,
			testfield_description,
			testfield_datatype_id,
			datatype_type,
			testfield_uom,
			testvalue_min_limit,
			testvalue_max_limit,
			testvalue_value,
			testvalue_result,
			testfield_position,
			testfield_defaultvalue,
			testfield_comborestricted,
			testentry_created_timestamp,
			testentry_completed_timestamp
	FROM        	testvalue
	inner join 	testfield on testvalue_field_id = testfield_id
	inner join	testentry on testvalue_entry_id = testentry_id
	inner join 	testdef on testfield_test_id = testdef_id
	inner join 	datatype on testfield_datatype_id = datatype_id
	where         	testvalue_void_timestamp IS NULL
	ORDER BY    	testvalue_id;

ALTER TABLE public.viewcreatedfieldentry
  OWNER TO admin;
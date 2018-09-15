-- View: public.viewfieldentry

-- DROP VIEW public.viewfieldentry;

CREATE OR REPLACE VIEW public.viewfieldentry AS 

	select 		testdef_id, 
			testdef_name,
			testfield_id, 
			testfield_name, 
			testfield_description, 
			datatype_id, 
			datatype_type, 
			testfield_uom,
			testfield_min_limit, 
			testfield_max_limit,
			testfield_position, 
			testfield_defaultvalue,
			testfield_comborestricted
	from 		testfield
	inner join 	testdef on testfield_test_id = testdef_id
	inner join 	datatype on testfield_datatype_id = datatype_id
	order by 	testdef_id, testfield_position;

ALTER TABLE public.viewfieldentry
  OWNER TO admin;

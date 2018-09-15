-- View: public.viewtestrecords

-- DROP VIEW public.viewtestrecords;

create or replace view public.viewtestrecords as

	Select 		testtype_name, 
			testentry_id,
			item_number,
			part_serialnumber,
			testentry_orig_serialnumber,
			testdef_name,
			testdef_description,
			testentry_result,
			testentry_created_timestamp,
			usr_username,
			testentry_completed_timestamp
	from 		testentry
	inner join 	item on testentry_orig_item_id = item_id
	inner join 	part on testentry_part_id = part_id
	inner join 	testdef on testentry_test_id = testdef_id
	inner join 	testtype on testdef_type_id = testtype_id
	inner join 	usr on testentry_created_user_id = usr_id
	order by 	testentry_id;

alter table public.viewtestrecords
  owner to admin;
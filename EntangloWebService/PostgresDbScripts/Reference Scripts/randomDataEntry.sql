/* SERIAL TABLE */

insert into serialtable(serialtable_partnumber,
			serialtable_serialnumber,
			--serialtable_transactionid,
			serialtable_printed,
			--serialtable_workorder,
			--serialtable_activedate,
			--serialtable_expireddate,
			serialtable_active,
			serialtable_itemid,
			serialtable_parent_partkey,
			--serialtable_inv_loc_id,
			serialtable_notes,
			--serialtable_con_id,
			--serialtable_thirdpartyserial,
			--serialtable_thirdpartyid,
			--serialtable_genby,
			--serialtable_inv_cust_id,
			serialtable_show_on_sr--,
			--serialtable_serial_seq_num,
			--serialtable_workorder_subnumber,
			--serialtable_allocorder,
			--serialtable_refurb
			)
--values('SKU-100003-02', 'SR9999999', true, true, 0001, 0001, 'TestData', true); 
--values('SKU-100003-02', 'SR8888888', false, true, 0002, 0002, 'TestData', true); 
values('SKU-100003-02', 'SR6666666', true, true, 0004, 0004, 'TestData', true); 

select * from serialtable


/* TEST DEFINITION */

insert into testdef(testdef_name,
		testdef_description,
		testdef_created--,
		--testdef_modified,
		--testdef_removed,
		--testdef_locked
		)
--values('SR_System_Flyer_Test', 'Test the flyers system', now()); 
--values('SR_BaseStation_Test', 'Test the basestation', now()); 
values('SR_Mag_Calibration_Test', 'Calibrate the Magnetometer', now()); 

select * from testdef



/* FIELD TABLE */

insert into testfield(testfield_test_id,
			testfield_name,
			testfield_datatype_id,
			testfield_required, 
			--testfield_position, 
			--testfield_created,
			--testfield_modified,
			--testfield_removed, 
			testfield_min_limit,
			testfield_max_limit,
			testfield_uom--,
			--testfield_result_required,
			--testfield_defaultvalue,
			--testfield_comborestricted, 
			--testfield_readonly 
			)
--values(1, 'Network_Connection', 3, false, '1', '1', 'N/A'); 
--values(1, 'RSSI', 3, false, '-85', '-65', 'N/A'); 
--values(1, 'CNO', 3, false, '10', '30', 'N/A'); 
--values(2, 'Base_Network_Connection', 3, false, '1', '1', 'N/A'); 
--values(2, 'Base_RSSI', 3, false, '-85', '-65', 'N/A'); 
--values(2, 'Base_CNO', 3, false, '10', '30', 'N/A'); 
--values(3, 'X', 3, false, '0', '50', 'N/A'); 
--values(3, 'Y', 3, false, '0', '50', 'N/A'); 
values(3, 'Z', 3, false, '-25', '25', 'N/A'); 

select * from testfield

insert into testtype (testtype_type)
values ('C8');

alter table testtype rename testtype_type to testtype_name

select testdef_name, testdef_description, testtype_name, testdef_created_timestamp, testdef_locked 
from testdef inner join testtype on testdef_type_id = testtype_id

select testflowitem_flow_id, testflowitem_item_number, testtype_name, testflowitem_created_timestamp
from testflowitem inner join testtype on testflowitem_type_id = testtype_id


/* TEST ENTRY */
_result boolean;

select getpartid('SKU-100001', 'SR0001027')
select * from part where part_id = 2

select createtestentry('SKU-100001', 'SR0001027', 3, 'mrankin', 'Pass');--, now()::text);

select * from testentry

select addtestvalue(1, 8, '10', 'Fail', '0', '50');

select * from testvalue

select closetestentry(4, 6);

select updatetestentry(135, 'mrankin', 'Pass', '{"49", "-35", "Fail", "-25", "25", "48", "50", "Pass", "0", "50"}', false);
select * from testentry order by testentry_id desc;
select * from testvalue inner join testentry on testvalue_entry_id = testentry_id where testvalue_entry_id = 135
select * from testdef
select * from testfield

-- Check if entry ID exists
SELECT testentry_complete_user_id from testentry where testentry_id = 11;

select submittestentry('SKU-100001', 'SR5000040', 27, 'mrankin', 'Fail', '{"54", "12", "Pass", "20", "10", "55", "3", "Fail", "10", "5"}', true);

select getflowcheck('SKU-100001', 'SR5000040', 27, 12)
select * from testflowseq
select testflowseq_test_seq[5 - 1] from testflowseq where testflowseq_id = 10;

select testflowitem_flow_id from testflowitem where testflowitem_item_id = 1 and testflowitem_type_id = 12
select testflowseq_id from testflowseq where testflowseq_flow_id = 12 and testflowseq_default

select part_id from part where part_serialnumber = 'SR7000039';

select * from testentry where testentry_orig_serialnumber = 'SR8004016' order by testentry_created_timestamp

select current_flowcheck, current_station, last_passed_station, target_station from getflowcheck('SKU-100001', 'SR8004016', 1)

select * from part


select * from testentry
select * from testfield

/* UPDATE TEST ENTRY */
select updatetestentry(6, 'fyourself', 'Pass', '{}');
select voidtestvalue(4);

select voidtestentry(4);


/* TEST AND FIELD CREATION/REMOVE/UPDATE */
select * from testdef
select createtest('OX_Test_1', 'First test of Oxcart', 1);
select createtest('OX_Test_2', 'Second test of Oxcart');

select addtestfield(4, 'flight_test_field_2', 'test_field 2 desc.', 3, true, 1, '-10', '10', 'mV', true, 'N/A', true, false);

select updatetestfield(21, 28, 'Dev Field 2', 'Field description Dev 2', 4, true, 1, '10', '20', 'mV', true, 'N/A', false, true);

select updatetest(6, '', 'Oxcart secondary test');

select removetest(3);

select removetestfield(28);

select * from testdef 
select * from testfield
select * from datatype


/* FLOW CREATION/REMOVE/UPDATE */	
select createtestflow(2, '{11,12,13,4}', false);

select addflowitem(1, 'SKU-100003', false, false, 1);

select addflowdef(13, 'SR_Test_Name', 'This is a test description');

select removeflowitem('SKU-100003')


/* Get flow item flow ID */
select testflowitem_flow_id from testflowitem where testflowitem_id = 3 --into _flowitem_flow_id;

/* Get amount of flow sequences for the item */
select count(*) from testflowseq where testflowseq_flow_id = 3 --into _amtSequences;

/* Get first found flow sequence ID of item flow ID */
select testflowseq_id from testflowseq where testflowseq_flow_id = 3
and testflowseq_void is null limit 1 --into _temp_flowseq_id;

/* Remove flow sequence found */
select removeflowseq(4);

select removeflowdef('SR_Battery_Flow')

select removeflowseq(4)

alter table testdef rename testdef_removed to testdef_void

alter table testfield drop column testfield_void --testfield_modified


select updateflowdef(3, 'SR_Battery_Flow', 'Sky Ranger flyer battery test station flow', FALSE)

SELECT updateflowitem(4, 'SKU-100003', false, false, 1)

SELECT updateflowseq(2, 2, '{6,7,8,9,10,11}', false)


select testflowoverride('sr_base_flow', false);


/* FLOW CHECK: FIND PREVIOUS TEST AND STATUS */
select testentry_id from testentry te1 where upper(testentry_orig_serialnumber) = upper('SR8004016')
	and testentry_created_timestamp = (select MAX(testentry_created_timestamp) from testentry te2 
	where upper(te2.testentry_orig_serialnumber) = upper('SR8004016'))

-- select * from 
-- (
select /*testentry_created_timestamp*/testentry_test_id from testentry where upper(testentry_orig_serialnumber) = upper('SR8004016')
and testentry_test_id != 3
order by testentry_created_timestamp desc
limit 1
-- ) lasttests
-- order by testentry_created_timestamp asc
-- limit 1

select (select upper(testentry_result) from testentry where testentry_id = 20) = 'FAIL' as "Recent Entry Status"

create extension intarray

select icount(testflowseq_test_seq) "Sequences In Flow" from testflowseq where testflowseq_id = 2

select idx(testflowseq_test_seq, 11) as "Index Location" from testflowseq where testflowseq_id = 2

-- Get location of current (about to test) test id
-- Get the test id of the last 
-- Check if the sequence before the current test id is the last test id
-- Check if the last test id entry was a pass
-- Return bool based on current station to be tested is correct according to flow

select /*testentry_id, testentry_test_id, testentry_orig_serialnumber, */upper(testentry_result)/*, testentry_created_timestamp*/ from testentry where testentry_id = 20 and upper(testentry_result) = 'FAIL'

/* current test index */
select idx(testflowseq_test_seq, 7) from testflowseq where testflowseq_id = 4

/* recent test index */
select idx(testflowseq_test_seq, 4) from testflowseq where testflowseq_id = 4

select (4 - 1) = 3

select getflowcheck('SKU-100001', 'SR8004016', 3)

select * from part



insert into testflowdef(testflowdef_name, testflowdef_description, testflowdef_type_id)
values ('SR_Flyer_Flow', 'Sky Ranger flyer test station flow', 1);
insert into testflowdef(testflowdef_name, testflowdef_description, testflowdef_type_id)
values ('SR_Base_Flow', 'Sky Ranger Base test station flow', 1);
insert into testflowdef(testflowdef_name, testflowdef_description, testflowdef_type_id)
values ('SR_Battery_Flow', 'Sky Ranger flyer battery test station flow', 6);
insert into testflowdef(testflowdef_name, testflowdef_description, testflowdef_type_id)
values ('OX_Flyer_Flow', 'OX Cart Flyer test station flow', 5);
insert into testflowdef(testflowdef_name, testflowdef_description, testflowdef_type_id)
values ('OX_Base_Flow', 'OX Cart Base test station flow', 5);
insert into testflowdef(testflowdef_name, testflowdef_description, testflowdef_type_id)
values ('OX_Battery_Flow', 'OX Cart battery test station flow', 6);


delete from testflowdef where testflowdef_id = 1
drop table testflowdef

select * from testflowdef

select * from testtype

select addflowdef('SR_Flyer_Flow_2', 'Sky Ranger flyer test station flow number 2', 1, null, null);


insert into testflowseq(testflowseq_flow_id, testflowseq_test_seq)
--values (1, '{1,2,3,4,5}')
--values (2, '{6,7,8,9}')
values (3, '{10,11,12}')

select * from testflowseq


insert into testflowitem(testflowitem_flow_id, testflowitem_item_id, testflowitem_type_id, testflowitem_override)
--values (1, 'SKU-100001', false, true);
values (1, 1, 1, FALSE);

select * from testflowitem

select * from item

/* Get test flow item table column names of id's */
select testflowitem_id, testflowdef_name, item_number, testtype_name, testflowitem_override, testflowitem_created_timestamp, testflowitem_modified_timestamp, testflowitem_void_timestamp
from testflowitem
inner join testflowdef on testflowitem_flow_id = testflowdef_id
inner join item on testflowitem_item_id = item_id
inner join testtype on testflowitem_type_id = testtype_id

select addflowitem(2, 2, false);
select removeflowitem(4);
select updateflowitem(4, 1, 1, 1, true);


/* FLOW TABLE TESTING */
select testflowitem_item_number as "Item", 
	testflowseq_flow_id as "Flow ID", 
	testflowdef_order as "Test Order Number",
	testflowseq_test_seq as "Flow Order",
	testflowdef_name as "Test Station" 
from testflowitem
inner join testflowseq on testflowitem_flow_id = testflowseq_flow_id
inner join testflowdef on testflowdef_order = ANy(testflowseq_test_seq)


/* TEST TYPE TESTING */
select * from testtype
select * from testdef

select current_flowcheck from getflowcheck('SKU-100001', 'SR8004016', 1)

select createtestentry('SKU-100001', 'SR8004016', 1, 'mrankin', 'Fail')

select validatepart('SKU-100001', '01', 'SR8004016', null, false)

SELECT 	part_id,

	part_active

	FROM viewpart

	WHERE item_number = 'SKU-100001'

	AND part_serialnumber = 'SR8004016';

select * from part where part_serialnumber = 'SR5000040'

select getflowcheck('SKU-100001', 'SR5000040', 1)

select getpartid('SKU-100001', 'SR5000040')

select * from testvalue



select * from datatype
select * from testentry
select * from testtype
select * from item
select * from testdef
select * from usr

select * from viewtestrecords
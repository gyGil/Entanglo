--select * from testflowitem

select testflowitem_id, testflowdef_id, testflowdef_name, testflowitem_item_id, item_number, item_description, testtype_name, testflowitem_override, 
	testflowitem_created_timestamp, testflowitem_modified_timestamp
from testflowitem
inner join testflowdef on testflowitem_flow_id = testflowdef_id
inner join item on testflowitem_item_id = item_id
inner join testtype on testflowitem_type_id = testtype_id
order by testflowdef_name



select item_number from item inner join testflowitem on item_id = testflowitem_item_id
	where testflowitem_id = 20
	and testflowitem_item_id = item_id;-- into _item_number;



select exists(select 1 from testflowitem where testflowitem_id = 20 and testflowitem_void_timestamp is null)


SELECT      	testflowitem_id,
		testflowitem_flow_id,
		testflowitem_item_id,
		testflowitem_type_id,
		testflowitem_override,
		item_number, 
		item_description,
		testflowdef_name,
		testflowitem_created_timestamp,
		testflowitem_modified_timestamp
FROM        	testflowitem
INNER JOIN  	item ON testflowitem_item_id = item_id
INNER JOIN  	testflowdef ON testflowitem_flow_id = testflowdef_id
--WHERE       	testflowitem_flow_id = 9
ORDER BY    	testflowitem_id;


SELECT removeflowitem(2)

select * from item

select * from testtype

select * from testflowdef

select * from testflowitem

select * from part

select addflowitem(9, 1, false)

select testtype_id, testtype_name, testflowdef_id, testflowdef_name, item_id, item_number, item_description, testflowitem_override, testflowitem_modified_timestamp
from testflowitem
inner join testtype on testflowitem_type_id = testtype_id
inner join testflowdef on testflowitem_flow_id = testflowdef_id
inner join item on testflowitem_item_id = item_id
order by testtype_name



select * from testflowseq

alter table testflowseq
ALTER Column testflowseq_name SET not null


SELECT      	testflowseq_id,
		testflowseq_flow_id,
		testflowseq_name,
		testflowseq_description,
		testflowseq_test_seq,
		testflowseq_default,
		testflowseq_created_timestamp CreatedTimestamp,
		testflowseq_modified_timestamp ModifiedTimestamp,
		testflowseq_void_timestamp VoidTimestamp
FROM        	testflowseq
INNER JOIN  	testflowdef on testflowseq_flow_id = testflowdef_id
--where 		testflowdef_id = 9
ORDER BY    	testflowseq_id

select createtestflow(9, 'Test Dev Seq 3', 'test dev seq 3 desc', '{}', false)

select updateflowseq(7, 9, '', '', '{11,12,13}', true)


SELECT      	testdef_id TestId,
		testdef_name TestName,
		testdef_description TestDescription,
		testdef_created_timestamp CreatedTimestamp,
		testdef_modified_timestamp ModifiedTimestamp,
		testdef_void_timestamp VoidTimestamp,
		testdef_locked TestLocked,
		testdef_type_id TestTypeId
FROM        	testdef
ORDER BY    	testdef_id


select * from testdef

select * from testflowseq

select * from testflowitem

select * from part order by part_id

select * from item

select * from testtype

select * from partstate


select item_number, testtype_name, testflowseq_test_seq 
from testflowseq
inner join testflowitem on testflowseq_flow_id = testflowitem_flow_id
inner join item on testflowitem_item_id = item_id
inner join testtype on testflowitem_type_id = testtype_id
where testflowitem_item_id = 10
and testflowitem_flow_id = testflowseq_flow_id
and testflowseq_default = true
and testflowitem_type_id = testtype_id 
and upper(testtype_name) = 'TEST'


/* Part Test Sequences */
SELECT      	testflowseq_id FlowSeqId,
		testflowseq_flow_id FlowSeqFlowId,
		testflowseq_name FlowSeqName,
		testflowseq_description FlowSeqDescription,
		testflowseq_test_seq FlowTestSeq,
		testflowseq_default FlowSeqDefault,
		testflowseq_created_timestamp CreatedTimestamp,
		testflowseq_modified_timestamp ModifiedTimestamp,
		testflowseq_void_timestamp VoidTimestamp
FROM        	testflowseq
INNER JOIN  	testflowitem on testflowseq_flow_id = testflowitem_flow_id
INNER JOIN  	testtype on testflowitem_type_id = testtype_id
WHERE       	testflowitem_item_id = 1 -- ItemId
AND         	testflowitem_flow_id = testflowseq_flow_id
AND         	upper(testtype_name) = upper('Test') -- PartStateName
ORDER BY    	testflowseq_id;

select * from testdef
select * from part
select * from item
select * from testentry

select testdef_name, part_serialnumber, item_number, testentry_orig_serialnumber, testentry_result, testentry_created_timestamp
from testentry
inner join testdef on testentry_test_id = testdef_id
inner join part on testentry_part_id = part_id
inner join item on testentry_orig_item_id = item_id
order by part_serialnumber, testentry_created_timestamp



/* FIELD ENTRY */
select * from viewfieldentry where testdef_id = 1

select * from viewfieldentry;

SELECT      	testdef_id TestId,
		testdef_name TestName,
		testfield_id FieldId,
		testfield_name FieldName,
		testfield_description FieldDescription,
		datatype_id DataTypeID,
		datatype_type DataTypeName,
		testfield_uom UnitOfMeasure,
		testfield_min_limit MinLimit,
		testfield_max_limit MaxLimit,
		testfield_position FieldPosition,
		testfield_defaultvalue DefaultValue,
		testfield_comborestricted ComboRestricted
FROM        	viewfieldentry
WHERE       	testdef_id = 1;

select * from partstate
select * from testvalue
select * from datatype
select * from testvalue
select * from testentry

/* Test Record View Query */
Select 		testentry_id,
		testtype_name,
		item_number,
		testentry_orig_serialnumber,
		testdef_name,
		testdef_description,
		testentry_result,
		testentry_created_timestamp,
		usr_username,
		testentry_completed_timestamp
from 		viewtestrecords
order by	testentry_id;


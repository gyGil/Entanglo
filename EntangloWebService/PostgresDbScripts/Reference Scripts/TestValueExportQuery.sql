Select * from viewtestrecords
inner join testvalue
on (testentry_id = testvalue_entry_id)
where testvalue_created_timestamp-- = '2017-08-23 12:00:00.00'
between '2017-08-01' and '2017-08-24'
and upper(testdef_name) = upper('sr_mag_calibration_test')
order by testvalue_created_timestamp desc
limit 100

select count(testvalue_entry_id) from testvalue where testvalue_entry_id = 116

select count(testentry_id) from viewtestrecords where testentry_id = 116


Select * from viewtestrecords
inner join testvalue
on (testentry_id = testvalue_entry_id)
where upper(testdef_name) = upper('SR_Mag_Calibration_Test')
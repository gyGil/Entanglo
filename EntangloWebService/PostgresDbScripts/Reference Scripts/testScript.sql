/* Test Function for Loops and Statements */

do language plpgsql $$
	begin
		if (select exists(select testtype_name from testtype where upper(testtype_name) = upper('test type 1') 
			and testtype_id != 6)) is true then 
			raise notice 'TRUE';
		else
			raise notice 'FALSE';
		end if;
	end;
$$;

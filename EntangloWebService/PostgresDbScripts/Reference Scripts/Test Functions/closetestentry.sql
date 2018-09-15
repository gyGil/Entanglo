-- Function: closetestentry(integer)

-- DROP FUNCTION closetestentry(integer);

CREATE OR REPLACE FUNCTION closetestentry(
    integer,
    integer)
  RETURNS boolean AS
  $BODY$
  DECLARE

	_entry_id   ALIAS FOR $1;		-- Test entry id to complete
	_user_id    ALIAS for $2;		-- Test entry user id to complete

	_entryCompleted	boolean := false;	-- Status of test entry completion
		
  begin

	-- Check if user ID exists
	if (select usr_id from usr where usr_id = _user_id limit 1) is null then
		raise exception 'closetestentry: USER ID DOES NOT EXIST';
	END IF;
	
	-- Check if entry ID is valid
	if _entry_id is null then
		raise exception 'closetestentry: UNABLE TO COMPLETE ENTRY AS IT IS NULL';
	END IF;

	-- Check if entry ID exists
	IF (SELECT testentry_id from testentry where testentry_id = _entry_id limit 1) is null then
		raise exception 'closetestentry: TEST ENTRY DOES NOT EXIST';
	end if;

	-- Check if test entry has already been closed (return true and disregard if so)
	if (select testentry_completed_user_id from testentry where testentry_id = _entry_id) is not null then
	--if (select exists(select testentry_complete_user_id from testentry where testentry_id = _entry_id)) then
		_entryCompleted := true;
		return _entryCompleted;	-- Return result of test entry (already closed)
	end if;
	
	-- Attempt to complete user id associated with the test entry
	update testentry set testentry_completed_user_id = _user_id
	where testentry_id = _entry_id;
	
	-- Attempt to complete test entry if user id completion was successful
	if found then 
		update testentry set testentry_completed_timestamp = now()::timestamp without time zone
		where testentry_id = _entry_id;

		if found then 
			_entryCompleted := true;	-- Set entry completed to successful
		else
			-- Raise exception if completion of test entry was unsuccessful
			raise exception 'closetestentry: UNABLE TO COMPLETE TEST ENTRY';
		end if;
	else 
		-- Raise exception if completion of user id was unsuccessful
		raise exception 'closetestentry: UNABLE TO COMPLETE USER ID';
	END IF;

	return _entryCompleted;	-- Return result of test entry (only true if both user id and test entry was completed)

  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function closetestentry(integer, integer)
  owner to postgres;
COMMENT ON function closetestentry(integer, integer)
  IS '[*New* --mrankin--] Checks if user ID and test entry ID is valid and completes with timestamp if still open';
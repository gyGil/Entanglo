/*#######################################################################################################
  #	TYPE: 		Stored Procedure								#
  #	NAME:		deleteuser									#
  #	SUMMARY: 	Deletes a specified user.							#
  #	PARAMETERS:	user key, user name, requesting user						#
  #	RETURNS:	status message (string)								#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/

-- Function: deleteuser(text, text)

-- DROP FUNCTION deleteuser(text, text);

CREATE OR REPLACE FUNCTION deleteuser(
    text, 
    text
	)
  RETURNS text AS
  $BODY$
  DECLARE

	--_userKey   		ALIAS FOR $1;		-- Unique user identifier
	_userName		ALIAS FOR $1;		-- Users name
	_reqUser		ALIAS FOR $2;		-- Requesting User	

	_req_user_id		text;		-- Requesting users id
	_req_user_access	boolean := false;	-- Requesting users delete access rights

	_user_id		text;		-- Returned user id after removal
	_user_removed		boolean := false;	-- User deleted status

	_response		text;			-- Response message

  begin

	/* Check that the requesting user is not null or blank */
	if _reqUser is null or _reqUser = '' then
		raise exception 'deleteuser: ERROR DELETING USER AS REQUESTING USER "%" IS NULL OR BLANK', _reqUser;
	end if;

	/* Check that the requesting user exists */
	if (select exists(select 1 from "AspNetUsers" where upper("UserName") = upper(_reqUser))) is true then
		select "Id" from "AspNetUsers" into _req_user_id where upper("UserName") = upper(_reqUser);
		if _req_user_id is null then
			raise exception 'deleteuser: ERROR DELETING USER AS REQUESTING USER "%" DOES NOT EXIST!', _reqUser;
		end if;
	end if;
	
	/* Check that the requesting user has access to delete another user */
	select checkaccess(_reqUser, 'deleteuser') into _req_user_access;
	if _req_user_access is false then
		raise exception 'deleteuser: ERROR DELETING USER AS REQUESTING USER "%" DOES NOT HAVE ACCESS TO "DELETE USER"!', _reqUser;
	end if;
	

	/* Check that the user name is not null or blank */
	if _userName is null OR _userName = '' then
		raise exception 'deleteuser: ERROR DELETING USER AS USER NAME IS NULL OR BLANK';
	end if;

	/* Check if the user key was given and is not null or blank */
	-- if _userKey is null or _userKey = 0 then 
-- 		select "UserKey" from "AspNetUsers" into _userKey where upper("UserName") = upper(_userName);
-- 		if _userKey is null then
-- 			raise exception 'deleteuser ERROR DELETING USER AS THE USER KEY IS NULL!';
-- 		END IF;
-- 	END IF;

	/* Verify that the users unique user name and user key exists */
 	if (select exists(select 1 from "AspNetUsers" where upper("UserName") = upper(_userName))) is false then
		raise exception 'deleteuser: ERROR DELETING USER AS UNIQUE USER NAME "%" DOES NOT EXIST!', _userName;
	end if;


	/* Delete user */
	delete from "AspNetUsers" where upper("UserName") = upper(_userName);
	
	/* Add user removed timestamp */
	--update "AspNetUsers" set "UserRemoved" = now()::timestamp without time zone where upper("UserName") = upper(_userName) and "UserKey" = _userKey and "UserRemoved" is null;

	/* Verify user was deleted successfully */
	--IF (select exists(select "UserRemoved" from "AspNetUsers" where upper("UserName") = upper(_userName) and "UserKey" = _userKey and "UserRemoved" is null)) is true then
	if (select exists(select "UserName" from "AspNetUsers" where "UserName" = _userName)) is true then
		raise exception 'deleteuser: ERROR DELETING USER AS USERNAME STILL EXISTS!';
	else
		_user_removed := true;
		_response := 'deleteuser: USER "' || _userName || '" WAS DELETED SUCCESSFULLY BY REQUESTING USER "' || _reqUser || '"';
	end if;


	return _response;		-- Return user created response message
  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function deleteuser(text, text)
  owner to ggil;
COMMENT ON function deleteuser(text, text)
  IS '[*New* --Marcus--] Deletes a user';
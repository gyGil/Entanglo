/*#######################################################################################################
  #	TYPE: 		Stored Procedure								#
  #	NAME:		updateuser									#
  #	SUMMARY: 	Updates a users specified information.						#
  #	PARAMETERS:	user key, user name, user password, user email, user note, requesting user name	#
  #	RETURNS:	status message (string)								#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/

-- Function: updateuser(text, text, text, text)

-- DROP FUNCTION updateuser(text, text, text, text);

CREATE OR REPLACE FUNCTION updateuser( 
    text, 
    text, 
    text, 
    text
	)
  RETURNS text AS
  $BODY$
  DECLARE

	_userName		ALIAS FOR $1;		-- Users name
	_userPhoneNumber	ALIAS for $2;		-- Users password
	_userEmail		ALIAS FOR $3;		-- Users email
	_reqUser		ALIAS FOR $4;		-- Requesting User

	--udUserKey		boolean := false;	-- Update user key status
	udUserName		boolean := false;	-- Update user name status
	udUserPassword		boolean := false;	-- Update user password status
	udUserEmail		boolean := false;	-- Update user email status
	udUserNote		boolean := false;	-- Update user note status

	_req_user_id		text;		-- Requesting users id
	_req_user_access	boolean := false;	-- Requesting users update access rights

	_currentDatabase	text;			-- Users current database name
	
	_user_updated		boolean := false;	-- User created status

	_response		text;			-- Response message

  begin

	/* Check that the requesting user is not null or blank */
	if _reqUser is null or _reqUser = '' then
		raise exception 'updateuser: ERROR UPDATING USER AS REQUESTING USER "%" IS NULL OR BLANK', _reqUser;
	end if;

	/* Check that the requesting user exists */
	if (select exists(select 1 from "AspNetUsers" where upper("UserName") = upper(_reqUser))) is true then
		select "Id" from "AspNetUsers" into _req_user_id where upper("UserName") = upper(_reqUser);
		if _req_user_id is null then
			raise exception 'updateuser: ERROR UPDATING USER AS REQUESTING USER "%" DOES NOT EXIST!', _reqUser;
		end if;
	end if;
	
	/* Check that the requesting user has access to create another user */
	select checkaccess(_reqUser, 'updateuser') into _req_user_access;
	if _req_user_access is false then
		raise exception 'updateuser: ERROR UPDATING USER AS REQUESTING USER "%" DOES NOT HAVE ACCESS TO "UPDATE USER"!', _reqUser;
	end if;

	/* Validate User Name before update */
	if _userName != '' then
		if length(_userName) > 100 then
			RAISE EXCEPTION 'updateuser: ERROR UPDATING USER AS USER NAME IS TOO LARGE!';
		else
			udUserName := true;
		end if;
	end if;

	/* Validate User Password before update */
	if _userPhoneNumber != '' then
		if length(_userPhoneNumber) > 12 then
			RAISE EXCEPTION 'updateuser: ERROR UPDATING USER PHONENUMBER AS PHONENUMBER IS TOO LARGE!';
		else
			udUserPassword := true;
		end if;
	end if;

	/* Validate User Email before update */
	if _userEmail != '' then
		if length(_userEmail) > 50 then
			RAISE EXCEPTION 'updateuser: ERROR UPDATING USER EMAIL AS EMAIL IS TOO LARGE!';
		else
			udUserEmail := true;
		end if;
	end if;


	/* Should check that the new password meets password requirement restrictions */
	-- If not implemented in the backend (Web Service)
	-- Possibly double check here
	-- Force #chars, uppercase, lowercase, numbers, special characters, not same as last password, etc...


	select current_database() into _currentDatabase;

	/* Update user */
	UPDATE "AspNetUsers" SET "UserName" = _userName,
			  "PhoneNumber" = _userPhoneNumber,
			  "Email" = _userEmail
		      where "UserName" = _userName;

	/* Check that the user was updated successfully */
	/* Check that the requesting user exists */

	-- if (select exists(select 1 from "AspNetUsers" where upper("UserName") = upper(_userName))) is false then
-- 		raise exception 'updateuser: ERROR UPDATING USER AS UPDATE WAS NOT FOUND!';
-- 	else
		--update "AspNetUsers" set "UserModified" = now()::timestamp without time zone;
		_user_updated := true;	-- Set user updated status
		_response := 'updateuser: USER "' || _userName || '" WAS UPDATED SUCCESSFULLY IN DATABASE "' || _currentDatabase || '" BY REQUESTING USER "' || _reqUser || '"';
	--end if; 

	return _response;		-- Return user updated response message
  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function updateuser(text, text, text, text)
  owner to ggil;
COMMENT ON function updateuser(text, text, text, text)
  IS '[*New* --Marcus--] Updates an existing user';
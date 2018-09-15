/*#######################################################################################################
  #	TYPE: 		Stored Procedure								#
  #	NAME:		getuser										#
  #	SUMMARY: 	Retrieves a specified users information.					#
  #	PARAMETERS:	user name, requesting user name							#
  #	RETURNS:	query (json)									#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/

-- Function: getuser(text, text)

-- DROP FUNCTION getuser(text, text);

CREATE OR REPLACE FUNCTION getuser(
    --integer, 
    text, 
    text
	)
  RETURNS json /*(userid integer, userkey integer, username character varying (50), userpassword character varying (50),
		databasename character varying (50), useremail character varying (50), usernote character varying (200),
		usercreated timestamp without time zone, usermodified timestamp without time zone, 
		userremoved timestamp without time zone)*/
	as
  $BODY$
  DECLARE

	--_userKey   		ALIAS FOR $1;		-- Unique user identifier
	_userName		ALIAS FOR $1;		-- Users name
	_reqUser		ALIAS FOR $2;		-- Requesting User	

	_req_user_id		text;		-- Requesting users id
	_req_user_access	boolean := false;	-- Requesting users create access rights


  begin

	/* Check that the requesting user is not null or blank */
	if _reqUser is null or _reqUser = '' then
		raise exception 'getuser: ERROR RETRIEVING USER AS REQUESTING USER "%" IS NULL OR BLANK', _reqUser;
	end if;

	/* Check that the requesting user exists */
	if (select exists(select 1 from "AspNetUsers" where upper("UserName") = upper(_reqUser))) is true then
		select "Id" from "AspNetUsers" into _req_user_id where upper("UserName") = upper(_reqUser);
		if _req_user_id is null then
			raise exception 'getuser: ERROR RETRIEVING USER AS REQUESTING USER "%" DOES NOT EXIST!', _reqUser;
		end if;
	end if;
	
	/* Check that the requesting user has access to read another users information */
	select checkaccess(_reqUser, 'getuser') into _req_user_access;
	if _req_user_access is false then
		raise exception 'getuser: ERROR RETRIEVING USER AS REQUESTING USER "%" DOES NOT HAVE ACCESS TO "READ USER"!', _reqUser;
	end if;

	/* Check that the user name is not null or blank */
	if _userName is null OR _userName = '' then
		raise exception 'getuser: ERROR RETRIEVING USER AS USER NAME IS NULL OR BLANK';
	end if;

	/* Verify that the users name doesn't exist */
 	if (select exists(select 1 from "AspNetUsers" where upper("UserName") = upper(_userName))) is false then
		raise exception 'getuser: ERROR RETRIEVING USER AS USER NAME "%" DOES NOT EXIST!', _userName;
	end if;

-- 	/* Check if the user key was given and is not null or blank */
-- 	if _userKey is null or _userKey = 0 then 
-- 		raise exception 'getuser ERROR RETRIEVING USER AS THE USER KEY IS NULL!';
-- 	END IF;
-- 
-- 	/* Verify that the users unique user name and user key doesn't already exist */
--  	if (select exists(select 1 from "user" where "UserKey" = _userKey)) is FALSE then
-- 		raise exception 'getuser: ERROR RETRIEVING USER AS UNIQUE USER KEY "%" DOES NOT EXIST!', _userKey;
-- 	end if;

	/* Query User */
	--return QUERY 
	return
	array_to_json(array_agg(row_to_json(r))) from ( select "Id", "Email", "UserName", "PhoneNumber", "NormalizedUserName"
	from "AspNetUsers" WHERE lower("UserName") = lower(_userName)) r;
	--from "AspNetUsers" WHERE lower("UserName") = lower(_userName) and "UserKey" = _userKey;

-- 	return _response;		-- Return user created response message

  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function getuser(text, text)
  owner to ggil;
COMMENT ON function getuser(text, text)
  IS '[*New* --Marcus--] Returns a specified users information';
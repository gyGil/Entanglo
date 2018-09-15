/*#######################################################################################################
  #	TYPE: 		Stored Procedure								#
  #	NAME:		getusers									#
  #	SUMMARY: 	Retrieves all currently active users.						#
  #	PARAMETERS:	requesting user name								#
  #	RETURNS:	query (json)									#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/

-- Function: getusers(text)

-- DROP FUNCTION getusers(text);

CREATE OR REPLACE FUNCTION getusers(
    text
	)
  RETURNS json as
  $BODY$
  DECLARE

	_reqUser		ALIAS FOR $1;		-- Requesting User	

	_req_user_id		text;		-- Requesting users id
	_req_user_access	boolean := false;	-- Requesting users create access rights


  begin

	/* Check that the requesting user is not null or blank */
	if _reqUser is null or _reqUser = '' then
		raise exception 'getusers: ERROR RETRIEVING USERS AS REQUESTING USER "%" IS NULL OR BLANK', _reqUser;
	end if;

	/* Check that the requesting user exists */
	if (select exists(select 1 from "AspNetUsers" where upper("UserName") = upper(_reqUser))) is true then
		select "Id" from "AspNetUsers" into _req_user_id where upper("UserName") = upper(_reqUser);
		if _req_user_id is null then
			raise exception 'getusers: ERROR RETRIEVING USERS AS REQUESTING USER "%" DOES NOT EXIST!', _reqUser;
		end if;
	end if;
	
	/* Check that the requesting user has access to read another users information */
	select checkaccess(_reqUser, 'getusers') into _req_user_access;
	if _req_user_access is false then
		raise exception 'getusers: ERROR RETRIEVING USERS AS REQUESTING USER "%" DOES NOT HAVE ACCESS TO "READ USERS"!', _reqUser;
	end if;


	/* Query Users */
	return
	array_to_json(array_agg(row_to_json(r))) from ( select "Id", "Email", "UserName", "PhoneNumber", "NormalizedUserName"
	from "AspNetUsers") r;

  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function getusers(text)
  owner to ggil;
COMMENT ON function getusers(text)
  IS '[*New* --Marcus--] Returns all current active users information';
/*#######################################################################################################
  #	TYPE: 		Stored Procedure								#
  #	NAME:		checkaccess									#
  #	SUMMARY: 	Checks a users access to perform a certain task (i.e. create, read, update, 	#
  #			delete a user, database, table or column)					#
  #	PARAMETERS:	user id, task									#
  #	RETURNS:	access status (true/false)							#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/


-- Function: checkaccess(text, text)

-- DROP FUNCTION checkaccess(text, text);

CREATE OR REPLACE FUNCTION checkaccess(
    text,
    text
	)
  RETURNS boolean AS
  $BODY$
  DECLARE

	_email   		ALIAS FOR $1;		-- User id
	_task			ALIAS FOR $2;		-- Task to perform

	_position		integer;		-- User last name starting position
	_userRole		text;			-- User role name (first letter of first name and last name)
	_userName		text;			-- User name

	_userHasAccess		boolean := false;	-- Users access to perform a task
	
  begin

	/* Check that the user id is not null */
	if _email is null or _email = '' then
		raise exception 'checkaccess: ERROR CHECKING USERS ACCESS AS USER ID IS NULL OR BLANK!';
	end if;

	/* Check that the user id exists */
	if (select exists(select 1 from "AspNetUsers" where "Email" = _email)) is false then
		raise exception 'checkaccess: ERROR CHECKING USERS ACCESS AS USER ID "%" DOES NOT EXIST!', _email;
	end if;

	/* Check that the task is not null or blank */
	if _task is null or _task = '' then
		RAISE EXCEPTION 'checkaccess: ERROR CHECKING USERS ACCESS AS TASK IS NULL OR BLANK!';
	end if;




	-- NEED TO PUT THIS IN A FUNCTION THAT AUTO CREATES ROLE NAME OFF OF USERNAME AND LINKS IN (ROLE) TABLE
	/* Get user name from user id */
	select "UserName" from "AspNetUsers" where "Email" = _email into _userName;
	
	/* Check that user name was retrieved successfully */
	if _userName is null then
		raise exception 'checkaccess: ERROR CHECKING USER ACCESS AS USER NAME OF USER ID "%" WAS NOT FOUND!', _email;
	end if;
	
	/* Create role name from user name */	
	_position := position(' ' in _userName) + 1;
	_userRole := substring(_userName, 1, 1) || substring(_userName, _position, length(_userName));

	/* Check that the user has access to perform task */
	-- Match user Id with task list and return boolean value stating the users accss rights to the specified task
	-- Complete tasks list, roles not created yet
	-- Complete this process later


	

	/* Check that test was created successfully */
	if _task is null or _task = '' then
		_userHasAccess := false;
	else
		_userHasAccess := true;	-- Set user access status
	end if;

	return _userHasAccess;		-- Return user access status
  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function checkaccess(text, text)
  owner to ggil;
COMMENT ON function checkaccess(text, text)
  IS '[*New* --Marcus--] Checks a users access rights';
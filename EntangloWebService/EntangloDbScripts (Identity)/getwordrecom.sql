/*#######################################################################################################
  #	TYPE: 		Stored Procedure								#
  #	NAME:		getwordrecom										#
  #	SUMMARY: 	Retrieves 20 close words for target word					#
  #	PARAMETERS:	targetWord							#
  #	RETURNS:	query (json)									#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/

-- Function: getwordrecom(text)

-- DROP FUNCTION getwordrecom(text);

CREATE OR REPLACE FUNCTION getwordrecom(
    --integer, 
    text
	)
  RETURNS json /*(targetword text, closewords text[])*/
	as
  $BODY$
  DECLARE

	--_userKey   		ALIAS FOR $1;		-- Unique user identifier
	_targetWord		ALIAS FOR $1;		-- Target Word

	_quot_target_word   text;       -- quotated target word -- ex. 'word' -> '"word"'
	_req_user_id		text;		-- Requesting users id
	_req_user_access	boolean := false;	-- Requesting users create access rights


  begin
	/* Check that the requesting user is not null or blank */
	if _targetWord is null or _targetWord = '' then
		raise exception 'getwordrecom: ERROR RETRIEVING CLOSE WORD LIST AS REQUESTING TARGET WORD "%" IS NULL OR BLANK', _targetWord;
	end if;
	
	/* quotate target word */
	-- _quot_target_word := '"' || _targetWord || '"';
	
	/* Check that the requesting targetWord */
	if (select exists(select 1 from "wordrecom" where "TargetWord" = _targetWord)) is false then
		raise exception 'getwordrecom: ERROR RETRIEVING TargetWord AS REQUESTING TargetWord "%" DOES NOT EXIST!', _targetWord;
	end if;
  
  
	return
	array_to_json(array_agg(row_to_json(r))) from ( select "TargetWord", "C1", "C2", "C3", "C4", "C5", "C6", "C7", "C8", "C9", "C10", "C11", "C12", "C13", "C14", "C15", "C16", "C17", "C18", "C19", "C20"
	from "wordrecom" WHERE "TargetWord" = _targetWord) r;
	--from "AspNetUsers" WHERE lower("UserName") = lower(_userName) and "UserKey" = _userKey;

-- 	return _response;		-- Return user created response message

  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function getwordrecom(text)
  owner to ggil;
COMMENT ON function getwordrecom(text)
  IS '[*New* --Marcus--] Returns a specified users information';
-- Function: public.validatepart(text, text, text, boolean)

-- DROP FUNCTION public.validatepart(text, text, text, boolean);

CREATE OR REPLACE FUNCTION public.validatepart(
    text,
    text,
    text DEFAULT NULL::text,
    boolean DEFAULT false)
  RETURNS boolean AS
$BODY$DECLARE
	pItemNumber 	ALIAS FOR $1;
	pSerialNumber 	ALIAS FOR $2;
	pCode		ALIAS FOR $3;
	pAllowInactive	ALIAS FOR $4;
	_viewpart	RECORD;
	_code		TEXT;
BEGIN
	PERFORM (SELECT checkpriv('validatepart'));

	SELECT 	part_id,
		part_active
	INTO _viewpart
	FROM viewpart
	WHERE item_number = pItemNumber 
	AND part_serialnumber = pSerialNumber;

	IF pCode IS NULL THEN
		_code := '';
	ELSE
		_code := ' ' || pCode;
	END IF;

	IF _viewpart.part_id IS NULL THEN
		RAISE EXCEPTION 'validatepart:% Item Number % Serial Number % Not Found in AeryonMES.', 
			_code,
			pItemNumber, 
			pSerialNumber;
	ELSIF _viewpart.part_active = false AND pAllowInactive = false THEN
		RAISE EXCEPTION 'validatepart:% Item Number % Serial Number % Is Inactive.', 
			_code,
			pItemNumber, 
			pSerialNumber;
	END IF;

	RETURN true;
END;

	$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.validatepart(text, text, text, boolean)
  OWNER TO admin;

-- Function: public.getpartid(text, text)

-- DROP FUNCTION public.getpartid(text, text);

CREATE OR REPLACE FUNCTION public.getpartid(
    text,
    text)
  RETURNS integer AS
$BODY$DECLARE
	pItemNumber 	ALIAS FOR $1;
	pSerialNumber 	ALIAS FOR $2;
	_partid 	INTEGER;
BEGIN
	PERFORM (SELECT checkpriv('getpartid'));
	PERFORM (SELECT validatepart(pItemNumber, pSerialNumber, null, true));

	SELECT part_id
	INTO _partid
	FROM part
	WHERE part_item_id = getitemid(pItemNumber) 
	AND part_serialnumber = pSerialNumber;

	RETURN _partid;
END;

	$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.getpartid(text, text)
  OWNER TO admin;

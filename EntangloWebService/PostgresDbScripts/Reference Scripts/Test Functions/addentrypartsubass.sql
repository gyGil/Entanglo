-- Function: addentrypartsubass(integer, text, text, text, text, text)

-- DROP FUNCTION addentrypartsubass(integer, text, text, text, text, text);

CREATE OR REPLACE FUNCTION addentrypartsubass(
	text,
	text,
	text
	)
  RETURNS boolean AS
  $BODY$
  DECLARE

	pItemNumber 		ALIAS FOR $1;
	pRevision 		ALIAS FOR $2;
	pSerialNumber 		ALIAS FOR $3;

	_usrId 			INTEGER;
	_r 			RECORD;

	_subassAdded		boolean := TRUE;

  begin

	/* Validate user ID */
	_usrID := (SELECT getusrid()); 

	/* Validate privileges to complete action */
	PERFORM (SELECT checkpriv('addentrypartsubass'));

	/* Validate part to be activated */
	PERFORM (SELECT validatepart(pItemNumber, pRevision, pSerialNumber, null, true));

	
	/* Activate parent part if not already active */
	PERFORM (SELECT activatepart(	pItemNumber,

					pRevision,

					pSerialNumber));
	/* Get all sub-assemblies of parent part */
	FOR _r IN

		SELECT *

		FROM summsubass(	pItemNumber,

					pRevision,

					pSerialNumber)
					
	/* Activate all child parts of parent part if they exist */
	LOOP

		IF _r.c_item_number IS NOT NULL THEN

			PERFORM (SELECT activatepart(	_r.c_item_number,

							_r.c_part_rev,

							_r.c_part_serialnumber));

		END IF;

	END LOOP;
	
	return _subassAdded;	-- Return sub-assemblies added status
  end;
  $BODY$
  language plpgsql volatile
  cost 100;
 alter function addentrypartsubass(TEXT, text, text)
   owner to postgres;		
 COMMENT ON function addentrypartsubass(TEXT, text, text)
  IS '[*New* --mrankin--] Adds all sub-assemblies (child parts) to main assembly (parent part) for each test entry';
					
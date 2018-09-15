--
-- TOC entry 341 (class 1255 OID 36777)
-- Name: activatepart(text, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION activatepart(text, text, text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pItemNumber ALIAS FOR $1;

	pRevision ALIAS FOR $2;

	pSerialNumber ALIAS FOR $3;

	_viewpart RECORD;

	_usrId INTEGER;

	_partActiveHistId INTEGER;

	_message TEXT;

  

BEGIN

	_usrID := (SELECT getusrid()); 

	PERFORM (SELECT checkpriv('activatepart'));

	PERFORM (SELECT validatepart(pItemNumber, pRevision, pSerialNumber, null, true));

	

	SELECT 	part_id,

		part_rev,

		item_id, 

		item_number,

		part_active,

		part_serialnumber, 

		part_sequencenumber,

		part_cust_id,

		loc_number

	INTO _viewpart

	FROM viewpart

	WHERE item_number = pItemNumber 

	AND part_serialnumber = pSerialNumber 

	AND part_rev = pRevision;



	IF _viewpart.part_active THEN

		RETURN true;

	END IF;

	

	UPDATE part SET (part_active) =

			(true)

	WHERE part_id = _viewpart.part_id;



	INSERT INTO partactivehist (	partactivehist_part_id, 

					partactivehist_new_activestate,

					partactivehist_usr_id,

					partactivehist_orig_item_id,

					partactivehist_orig_rev,

					partactivehist_orig_serialnumber)

		VALUES (		_viewpart.part_id, 

					true,

					_usrId,

					_viewpart.item_id,

					_viewpart.part_rev,

					_viewpart.part_serialnumber)

		RETURNING partactivehist_id INTO _partActiveHistId;



	_message := 	pItemNumber || ' ' ||  

			pRevision || ' ' || 

			pSerialNumber || ' made Active.';



	PERFORM (SELECT enterpartlog(	'Manufacturing'::TEXT, 

					'Activated'::TEXT,

					pItemNumber,

					pRevision,

					pSerialNumber,

					'Active History'::TEXT,

					_partActiveHistId,

					_message));



	RETURN true;

END;$_$;


ALTER FUNCTION public.activatepart(text, text, text) OWNER TO admin;

--
-- TOC entry 342 (class 1255 OID 36778)
-- Name: activatesummsubass(text, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION activatesummsubass(text, text, text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pItemNumber ALIAS FOR $1;

	pRevision ALIAS FOR $2;

	pSerialNumber ALIAS FOR $3;

	_usrId INTEGER;

	_r RECORD;

  

BEGIN

	_usrID := (SELECT getusrid()); 

	PERFORM (SELECT checkpriv('activatesummsubass'));

	PERFORM (SELECT validatepart(pItemNumber, pRevision, pSerialNumber, null, true));

	

	PERFORM (SELECT activatepart(	pItemNumber,

					pRevision,

					pSerialNumber));

	

	FOR _r IN

		SELECT *

		FROM summsubass(	pItemNumber,

					pRevision,

					pSerialNumber)

	LOOP

		IF _r.c_item_number IS NOT NULL THEN

			PERFORM (SELECT activatepart(	_r.c_item_number,

							_r.c_part_rev,

							_r.c_part_serialnumber));

		END IF;

	END LOOP;

		  

	RETURN true;

END;$_$;


ALTER FUNCTION public.activatesummsubass(text, text, text) OWNER TO admin;

--
-- TOC entry 328 (class 1255 OID 36779)
-- Name: addcustparam(text, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION addcustparam(text, text, text) RETURNS integer
    LANGUAGE plpgsql
    AS $_$DECLARE

	pType 			ALIAS FOR $1;

	pParam	 		ALIAS FOR $2;

	pDataType		ALIAS FOR $3;

	_custParam 		RECORD;

	_dataTypeId 		INTEGER;

	_custParamId		INTEGER;

  

BEGIN

	PERFORM (SELECT getusrid());

	PERFORM (SELECT checkpriv('addcustparam'));



	IF pParam IS NULL THEN

		RAISE EXCEPTION 'addcustparam: Custom Parameter Name cannot be null.';

	END IF;



	IF pType != 'r' AND pType != 'p' THEN

		RAISE EXCEPTION 'addcustparam: Custom Parameter must be of Type r or p.';

	END IF;

	

	SELECT 	custparam_id,

		custparam_type, 

		custparam_param,

		custparam_datatype_id,

		datatype_type	

	INTO _custParam

	FROM custparam

	LEFT OUTER JOIN datatype

		ON datatype.datatype_id = custparam.custparam_datatype_id

	WHERE custparam_param = pParam 

	AND custparam_type = pType

	AND custparam_void_timestamp IS NULL;



	_dataTypeId := (SELECT getdatatypeid(pDataType));



	IF _custParam.custparam_id IS NOT NULL THEN

		RAISE EXCEPTION 'Custom Parameter % of Type % already exists with Data Type %.',

			pParam,

			pType,

			_custParam.datatype_type;	

	END IF;



	INSERT INTO custparam(	custparam_type,

				custparam_param,

				custparam_datatype_id)

		VALUES (	pType,

				pParam,

				_dataTypeId)

		RETURNING custparam_id INTO _custParamId;

				

	RETURN _custParamId;

END;$_$;


ALTER FUNCTION public.addcustparam(text, text, text) OWNER TO admin;

--
-- TOC entry 344 (class 1255 OID 36780)
-- Name: addcustparamcombo(text, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION addcustparamcombo(text, text, text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pType 			ALIAS FOR $1;

	pParam	 		ALIAS FOR $2;

	pValue			ALIAS FOR $3;

	_custParamCombo		RECORD;

	_custParamId		INTEGER;

  

BEGIN

	PERFORM (SELECT getusrid());

	PERFORM (SELECT checkpriv('addcustparamcombo'));



	IF pParam IS NULL THEN

		RAISE EXCEPTION 'addcustparamcombo: Custom Parameter Name cannot be null.';

	END IF;



	IF pType != 'r' AND pType != 'p' THEN

		RAISE EXCEPTION 'addcustparamcombo: Custom Parameter must be of Type r or p.';

	END IF;



	_custParamId := (SELECT getcustparamid(pType, pParam));

	

	SELECT 	custparamcombo_id,

		custparamcombo_custparam_id, 

		custparamcombo_value,

		custparamcombo_active

	INTO _custParamCombo

	FROM custparamcombo

	WHERE custparamcombo_custparam_id = _custParamId

	AND custparamcombo_value = pValue;



	IF _custParamCombo.custparamcombo_id IS NOT NULL AND _custParamCombo.custparamcombo_active = true THEN

		RETURN true;

	ELSIF _custParamCombo.custparamcombo_id IS NOT NULL AND _custParamCombo.custparamcombo_active = false THEN 

		UPDATE custparamcombo 

		SET custparamcombo_active = true 

		WHERE custparamcombo_custparam_id = _custParamId 

		AND custparamcombo_value = pValue;



		RETURN true;

	END IF;



	INSERT INTO custparamcombo(	custparamcombo_custparam_id, 

					custparamcombo_value)

		VALUES (	_custParamId,

				pValue);

				

	RETURN true;

END;$_$;


ALTER FUNCTION public.addcustparamcombo(text, text, text) OWNER TO admin;

--
-- TOC entry 345 (class 1255 OID 36781)
-- Name: addcustparamlinkitem(text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION addcustparamlinkitem(text, text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pParam	 		ALIAS FOR $1;

	pItemNumber			ALIAS FOR $2;

	_itemCustParamLink		RECORD;

	_custParamId		INTEGER;

	_itemId			INTEGER;



  

BEGIN

	PERFORM (SELECT getusrid());

	PERFORM (SELECT checkpriv('addcustparamlinkitem'));



	_custParamId := (SELECT getcustparamid('p', pParam));

	

	_itemId := (SELECT getitemid(pItemNumber));



	SELECT 	itemitemcustparamlink_id,

		itemcustparamlink_custparam_id, 

		itemcustparamlink_item_id,

		itemcustparamlink_recordtype_id,

		itemcustparamlink_active

	INTO _itemCustParamLink

	FROM itemcustparamlink

	WHERE itemcustparamlink_custparam_id = _custParamId

	AND itemcustparamlink_item_id = _itemId;



	IF _itemCustParamLink.itemcustparamlink_id IS NOT NULL AND _itemCustParamLink.itemcustparamlink_active = true THEN

		RETURN true;

	ELSIF _itemCustParamLink.itemcustparamlink_id IS NOT NULL AND _itemCustParamLink.itemcustparamlink_active = false THEN

		UPDATE itemcustparamlink 

		SET itemcustparamlink_active = true 

		WHERE itemcustparamlink_custparam_id = _custParamId 

		AND itemcustparamlink_item_id = _itemId;



		RETURN true;

	END IF;



	INSERT INTO itemcustparamlink(	itemcustparamlink_custparam_id, 

					itemcustparamlink_item_id)

	VALUES (	_custParamId,

			_itemId);

					

	RETURN true;

END;$_$;


ALTER FUNCTION public.addcustparamlinkitem(text, text) OWNER TO admin;

--
-- TOC entry 346 (class 1255 OID 36782)
-- Name: addcustparamlinkrecord(text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION addcustparamlinkrecord(text, text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pParam	 		ALIAS FOR $1;

	pRecordType			ALIAS FOR $2;

	_recordcustparamlink		RECORD;

	_custParamId		INTEGER;

	_recordTypeId			INTEGER;



  

BEGIN

	PERFORM (SELECT getusrid());

	PERFORM (SELECT checkpriv('addcustparamlinkrecord'));



	_custParamId := (SELECT getcustparamid('r', pParam));



	_recordTypeId := (SELECT getrecordtypeid(pRecordType));



	SELECT 	recordcustparamlink_id,

		recordcustparamlink_custparam_id, 

		recordcustparamlink_item_id,

		recordcustparamlink_recordtype_id,

		recordcustparamlink_active

	INTO _recordcustparamlink

	FROM recordcustparamlink

	WHERE recordcustparamlink_custparam_id = _custParamId

	AND recordcustparamlink_recordtype_id = _recordTypeId;



	IF _recordcustparamlink.recordcustparamlink_id IS NOT NULL AND _recordcustparamlink.recordcustparamlink_active = true THEN

		RETURN true;

	ELSIF _recordcustparamlink.recordcustparamlink_id IS NOT NULL AND _recordcustparamlink.recordcustparamlink_active = false THEN

		UPDATE recordcustparamlink 

		SET recordcustparamlink_active = true 

		WHERE recordcustparamlink_custparam_id = _custParamId 

		AND recordcustparamlink_recordtype_id = _recordTypeId;



		RETURN true;

	END IF;



	INSERT INTO recordcustparamlink(	recordcustparamlink_custparam_id, 

					recordcustparamlink_recordtype_id)

	VALUES (	_custParamId,

			_recordTypeId);

					

	RETURN true;

END;$_$;


ALTER FUNCTION public.addcustparamlinkrecord(text, text) OWNER TO admin;

--
-- TOC entry 343 (class 1255 OID 36783)
-- Name: addcustparamvaluepart(text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION addcustparamvaluepart(text, text, text, text, text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pParam	 		ALIAS FOR $1;

	pItemNumber		ALIAS FOR $2;

	pRevision		ALIAS FOR $3;

	pSerialNumber		ALIAS FOR $4;

	pValue			ALIAS FOR $5;

	_custParamValue		TEXT;

	_partId 		INTEGER;

	_custParamId		INTEGER;

	_r			RECORD;

	_message		TEXT;

	_action			TEXT;

	_partCustParamValueId	INTEGER;

  

BEGIN

	PERFORM (SELECT getusrid());

	PERFORM (SELECT checkpriv('addcustparamvaluepart'));



	_custParamId := (SELECT getcustparamid('p', pParam));

		

	_partId := (SELECT getpartid(pItemNumber, pRevision, pSerialNumber));



	_custParamValue := (SELECT getcustparamvaluepart(pParam, pItemNumber, pRevision, pSerialNumber));



	IF _custParamValue = pValue THEN

		RETURN true;

	END IF;



	



	IF pValue IS NULL THEN

		PERFORM (SELECT removecustparamvaluepart(pParam, pItemNumber, pRevision, pSerialNumber));

		RETURN true;

	ELSE

		PERFORM (SELECT removecustparamvaluepart(pParam, pItemNumber, pRevision, pSerialNumber, false));

	END IF;

	

	INSERT INTO partcustparamvalue

		(partcustparamvalue_custparam_id,

		 partcustparamvalue_part_id,

		 partcustparamvalue_value)

	VALUES	(_custParamId,

		 _partId,

		 pValue)

	RETURNING partcustparamvalue_id INTO _partCustParamValueId;



	IF _custParamValue IS NULL THEN

		_message := 'Custom Parameter ' ||

			pParam || ' added with value ' ||

			pValue || ' for ' ||

			pItemNumber || ' ' ||  

			pRevision || ' ' || 

			pSerialNumber || '.';

		_action := 'Custom Parameter Added';

		

	ELSE

		_message := 'Custom Parameter ' ||

			pParam || ' value modified from ' ||

			_custParamValue || ' to ' ||

			pValue || ' for ' ||

			pItemNumber || ' ' ||  

			pRevision || ' ' || 

			pSerialNumber || '.';

		_action := 'Custom Parameter Modified';

	END IF;



	PERFORM (SELECT enterpartlog(	'Custom Parameter'::TEXT, 

						_action,

						pItemNumber,

						pRevision,

						pSerialNumber,

						'Part Custom Parameter Value History'::TEXT,

						_partCustParamValueId,

						_message));

						

	RETURN true;

END;$_$;


ALTER FUNCTION public.addcustparamvaluepart(text, text, text, text, text) OWNER TO admin;

--
-- TOC entry 349 (class 1255 OID 36784)
-- Name: addcustparamvaluerecord(text, text, integer, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION addcustparamvaluerecord(text, text, integer, text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pParam	 		ALIAS FOR $1;

	pRecordType		ALIAS FOR $2;

	pRecordId		ALIAS FOR $3;

	pValue			ALIAS FOR $4;

	_custParamValue		TEXT;

	_recordTypeId 		INTEGER;

	_custParamId		INTEGER;

	_r			RECORD;

	_message		TEXT;

	_action			TEXT;

	_recordCustParamValueId INTEGER;

  

BEGIN

	PERFORM (SELECT getusrid());

	PERFORM (SELECT checkpriv('addcustparamvaluerecord'));



	IF pRecordId IS NULL THEN

		RAISE EXCEPTION 'addcustparamvaluerecord: Record ID cannot be null.';

	END IF;	



	_custParamId := (SELECT getcustparamid('r', pParam));

		

	_recordTypeId := (SELECT getrecordtypeid(pRecordType));



	_custParamValue := (SELECT getcustparamvaluerecord(pParam, pRecordType, pRecordId));



	IF _custParamValue = pValue THEN

		RETURN true;

	END IF;



	IF pValue IS NULL THEN

		PERFORM (SELECT removecustparamvaluerecord(pParam, pRecordType, pRecordId));

		RETURN true;

	ELSE

		PERFORM (SELECT removecustparamvaluerecord(pParam, pRecordType, pRecordId, false));

	END IF;



	INSERT INTO recordcustparamvalue

		(recordcustparamvalue_custparam_id,

		 recordcustparamvalue_recordtype_id,

		 recordcustparamvalue_record_id,

		 recordcustparamvalue_value)

	VALUES	(_custParamId,

		 _recordTypeId,

		 pRecordId,

		 pValue)

	RETURNING recordcustparamvalue_id INTO _recordCustParamValueId;



	IF _custParamValue IS NULL THEN

		_message := 'Custom Parameter ' ||

			pParam || ' added with value ' ||

			pValue || ' for ' ||

			pRecordType || ' with ID ' ||  

			pRecordId || '.';

		_action := 'Custom Parameter Added';

		

	ELSE

		_message := 'Custom Parameter ' ||

			pParam || ' value modified from ' ||

			_custParamValue || ' to ' ||

			pValue || ' for ' ||

			pRecordType || ' with ID ' ||  

			pRecordId || '.';

		_action := 'Custom Parameter Modified';

	END IF;



	PERFORM (SELECT enterrecordlog(	'Custom Parameter'::TEXT, 

						_action,

						pRecordType,

						pRecordId,

						'Record Custom Parameter Value History'::TEXT,

						_recordCustParamValueId,

						_message));

	

	RETURN true;

END;$_$;


ALTER FUNCTION public.addcustparamvaluerecord(text, text, integer, text) OWNER TO admin;

--
-- TOC entry 350 (class 1255 OID 36785)
-- Name: adddoclinkpart(text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION adddoclinkpart(text, text, text, text, text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pDocType 		ALIAS FOR $1;

	pDocNumber		ALIAS FOR $2;

	pItemNumber		ALIAS FOR $3;

	pRevision		ALIAS FOR $4;

	pSerialNumber		ALIAS FOR $5;

	_partId 		INTEGER;

	_docTypeId		INTEGER;

	_message		TEXT;

	_checkPartDocLinkId	INTEGER;

	_partDocLinkId		INTEGER;

  

BEGIN

	PERFORM (SELECT getusrid());

	PERFORM (SELECT checkpriv('adddoclinkpart'));



	_docTypeId := (SELECT getdoctypeid(pDocType));

		

	_partId := (SELECT getpartid(pItemNumber, pRevision, pSerialNumber));



	_checkPartDocLinkId := (SELECT partdoclink_id

				FROM viewpartdoclink

				WHERE 	doctype_name = pDocType

				AND	partdoclink_docnumber = pDocNumber

				AND 	part_id = _partId

				AND	partdoclink_void_timestamp IS NULL);



	IF _checkPartDocLinkId IS NOT NULL THEN

		RETURN true;

	END IF;

	

	INSERT INTO partdoclink

		(partdoclink_doctype_id,

		 partdoclink_part_id,

		 partdoclink_docnumber)

	VALUES	(_docTypeId,

		 _partId,

		 pDocNumber)

	RETURNING partdoclink_id INTO _partDocLinkId;



	_message := 'Document Link ' ||

		pDocType || ' added with Document Number ' ||

		pDocNumber || ' for ' ||

		pItemNumber || ' ' ||  

		pRevision || ' ' || 

		pSerialNumber || '.';



	PERFORM (SELECT enterpartlog(	'Document Link'::TEXT, 

					'Document Link Added'::TEXT,

					pItemNumber,

					pRevision,

					pSerialNumber,

					'Part Document Link History'::TEXT,

					_partDocLinkId,

					_message));

						

	RETURN true;

END;$_$;


ALTER FUNCTION public.adddoclinkpart(text, text, text, text, text) OWNER TO admin;

--
-- TOC entry 355 (class 1255 OID 36786)
-- Name: adddoclinkrecord(text, text, text, integer); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION adddoclinkrecord(text, text, text, integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pDocType 		ALIAS FOR $1;

	pDocNumber		ALIAS FOR $2;

	pRecordType		ALIAS FOR $3;

	pRecordId		ALIAS FOR $4;

	_recordTypeId 		INTEGER;

	_docTypeId		INTEGER;

	_message		TEXT;

	_checkRecordDocLinkId	INTEGER;

	_recordDocLinkId	INTEGER;

  

BEGIN

	PERFORM (SELECT getusrid());

	PERFORM (SELECT checkpriv('adddoclinkpart'));



	_docTypeId := (SELECT getdoctypeid(pDocType));

		

	_recordTypeId := (SELECT getrecordtypeid(pRecordType));



	_checkRecordDocLinkId := (SELECT recorddoclink_id

				FROM viewrecorddoclink

				WHERE 	doctype_name = pDocType

				AND	recorddoclink_docnumber = pDocNumber

				AND 	recordtype_name = pRecordType

				AND 	recorddoclink_record_id = pRecordId

				AND	recorddoclink_void_timestamp IS NULL);



	IF _checkRecordDocLinkId IS NOT NULL THEN

		RETURN true;

	END IF;

	

	INSERT INTO recorddoclink

		(recorddoclink_doctype_id,

		 recorddoclink_recordtype_id,

		 recorddoclink_record_id,

		 recorddoclink_docnumber)

	VALUES	(_docTypeId,

		 _recordTypeId,

		 pRecordId,

		 pDocNumber)

	RETURNING recorddoclink_id INTO _recordDocLinkId;



	_message := 'Document Link ' ||

		pDocType || ' added with Document Number ' ||

		pDocNumber || ' for ' ||

		pRecordType || ' with ID ' ||  

		pRecordId || '.';



	PERFORM (SELECT enterrecordlog(	'Document Link'::TEXT, 

					'Document Link Added'::TEXT,

					pRecordType,

					pRecordId,

					'Record Document Link History'::TEXT,

					_recordDocLinkId,

					_message));

						

	RETURN true;

END;$_$;


ALTER FUNCTION public.adddoclinkrecord(text, text, text, integer) OWNER TO admin;

--
-- TOC entry 356 (class 1255 OID 36787)
-- Name: addfilepart(text, text, text, text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION addfilepart(text, text, text, text, text, text, text DEFAULT NULL::text, text DEFAULT NULL::text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$

DECLARE

  pItemNumber ALIAS FOR $1;

  pRevision ALIAS FOR $2;

  pSerialNumber ALIAS FOR $3;

  pFileName ALIAS FOR $4;

  pFileType ALIAS FOR $5;

  pHexData	ALIAS FOR $6;

  pHexThumbnail ALIAS FOR $7;

  pCustFileType ALIAS FOR $8;

  _partId	INTEGER;

  _fileTypeId	INTEGER;

  _custFileTypeId	INTEGER;

  _partFileDataId INTEGER;

  _partFileThumbnailId INTEGER;

  _partFileId INTEGER;

  _message TEXT;

  

BEGIN

	PERFORM (SELECT getusrid());

	PERFORM (SELECT checkpriv('addfilepart'));

		

	_partId := (SELECT getpartid(pItemNumber, pRevision, pSerialNumber));

	_fileTypeId := (SELECT getfiletypeid(pFileType));



	IF pCustFileType IS NOT NULL THEN

		_custFileTypeId := (SELECT getcustfiletypeid(pCustFileType));

	ELSE

		_custFileTypeId := null;

	END IF;



	SELECT partfile_id

	INTO _partFileId

	FROM partfile

	WHERE partfile_filename = pFileName

	AND partfile_part_id = _partId

	AND partfile_void_timestamp IS NULL;



	IF _partFileId IS NOT NULL THEN

		RAISE EXCEPTION 'addfilepart: File with Name % and File Type % already exists for Item Number % Revision % Serial Number %.', 

			pFileName,

			pFileType,

			pItemNumber,

			pRevision,

			pSerialNumber;

	END IF;



	INSERT INTO partfiledata

	(partfiledata_data) VALUES (decode(pHexData, $$hex$$))

	RETURNING partfiledata_id INTO _partFileDataId;



	IF pHexThumbnail IS NOT NULL THEN

		INSERT INTO partfilethumbnail

		(partfilethumbnail_data) VALUES (decode(pHexThumbnail, $$hex$$))

		RETURNING partfilethumbnail_id INTO _partFileThumbnailId;

	ELSE

		_partFileThumbnailId := null;

	END IF;



	INSERT INTO partfile

		(partfile_part_id,

		 partfile_filetype_id,

		 partfile_filename,

		 partfile_partfiledata_id,

		 partfile_partfilethumbnail_id,

		 partfile_custfiletype_id)

	VALUES	(_partId,

		 _fileTypeId,

		 pFileName,

		 _partFileDataId,

		 _partFileThumbnailId,

		 _custFileTypeId)

	RETURNING partfile_id INTO _partFileId;



	IF pCustFileType IS NOT NULL THEN

		_message := 	'File ' || 

				pFileName || ' of File Type ' || 

				pFileType || ' with Custom File Type ' || 

				pCustFileType || ' attached to Part ' || 

				pItemNumber || ' ' || 

				pRevision || ' ' || 

				pSerialNumber || '.';

	ELSE

		_message := 	'File ' || 

				pFileName || ' of File Type ' || 

				pFileType || ' attached to Part ' || 

				pItemNumber || ' ' || 

				pRevision || ' ' || 

				pSerialNumber || '.';

	END IF;

	

	PERFORM (SELECT enterpartlog(	'File Attachement'::TEXT, 

					'File Attached'::TEXT,

					pItemNumber,

					pRevision,

					pSerialNumber,

					'Part File Attachement History'::TEXT,

					_partFileId,

					_message));



	RETURN true;

END$_$;


ALTER FUNCTION public.addfilepart(text, text, text, text, text, text, text, text) OWNER TO admin;

--
-- TOC entry 357 (class 1255 OID 36788)
-- Name: addfilerecord(text, integer, text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION addfilerecord(text, integer, text, text, text, text DEFAULT NULL::text, text DEFAULT NULL::text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$

DECLARE

  pRecordType ALIAS FOR $1;

  pRecordId ALIAS FOR $2;

  pFileName ALIAS FOR $3;

  pFileType ALIAS FOR $4;

  pHexData	ALIAS FOR $5;

  pHexThumbnail ALIAS FOR $6;

  pCustFileType ALIAS FOR $7;

  _recordTypeId	INTEGER;

  _fileTypeId	INTEGER;

  _recordFileDataId INTEGER;

  _recordFileThumbnailId INTEGER;

  _recordFileId INTEGER;

  _custFileTypeId	INTEGER;

  _message TEXT;

  

BEGIN

	PERFORM (SELECT getusrid());

	PERFORM (SELECT checkpriv('addfilerecord'));

		

	_recordTypeId := (SELECT getrecordtypeid(pRecordType));

	_fileTypeId := (SELECT getfiletypeid(pFileType));



	IF pCustFileType IS NOT NULL THEN

		_custFileTypeId := (SELECT getcustfiletypeid(pCustFileType));

	ELSE

		_custFileTypeId := null;

	END IF;

	

	SELECT recordfile_id

	INTO _recordFileId

	FROM recordfile

	WHERE recordfile_filename = pFileName

	AND recordfile_recordtype_id = _recordTypeId

	AND recordfile_record_id = pRecordId

	AND recordfile_void_timestamp IS NULL;



	IF _recordFileId IS NOT NULL THEN

		RAISE EXCEPTION 'addfilerecord: File with Name % and File Type % already exists for Record Type % with ID %.', 

			pFileName,

			pFileType,

			pRecordType,

			pRecordId;

	END IF;



	INSERT INTO recordfiledata

	(recordfiledata_data) VALUES (decode(pHexData, $$hex$$))

	RETURNING recordfiledata_id INTO _recordFileDataId;



	IF pHexThumbnail IS NOT NULL THEN

		INSERT INTO recordfilethumbnail

		(recordfilethumbnail_data) VALUES (decode(pHexThumbnail, $$hex$$))

		RETURNING recordfilethumbnail_id INTO _recordFileThumbnailId;

	ELSE

		_recordFileThumbnailId := null;

	END IF;



	INSERT INTO recordfile

		(recordfile_recordtype_id,

		 recordfile_record_id,

		 recordfile_filetype_id,

		 recordfile_filename,

		 recordfile_recordfiledata_id,

		 recordfile_recordfilethumbnail_id,

		 recordfile_custfiletype_id)

	VALUES	(_recordTypeId,

		 pRecordId,

		 _fileTypeId,

		 pFileName,

		 _recordFileDataId,

		 _recordFileThumbnailId,

		 _custFileTypeId)

	RETURNING recordfile_id INTO _recordFileId;



	IF pCustFileType IS NOT NULL THEN

		_message := 	'File ' || 

				pFileName || ' of File Type ' || 

				pFileType || ' with Custom File Type ' || 

				pCustFileType || ' attached to Record Type ' || 

				pRecordType || ' with ID ' || 

				pRecordId || '.';

	ELSE

		_message := 	'File ' || 

				pFileName || ' of File Type ' || 

				pFileType || ' attached to Record Type ' || 

				pRecordType || ' with ID ' || 

				pRecordId || '.';

	END IF;



	PERFORM (SELECT enterrecordlog(	'File Attachement'::TEXT, 

					'File Attached'::TEXT,

					pRecordType,

					pRecordId,

					'Record File Attachement History'::TEXT,

					_recordFileId,

					_message));



	RETURN true;

END$_$;


ALTER FUNCTION public.addfilerecord(text, integer, text, text, text, text, text) OWNER TO admin;

--
-- TOC entry 347 (class 1255 OID 36789)
-- Name: addrolepriv(text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION addrolepriv(text, text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pPriv 			ALIAS FOR $1;

	pRole 		ALIAS FOR $2;

	_rolePriv 		RECORD;

	_roleId 			INTEGER;

	_privId			INTEGER;

  

BEGIN

	PERFORM (SELECT getusrid());

	PERFORM (SELECT checkpriv('addrolepriv'));

	_roleId := (SELECT getroleid(pRole));

	_privId := (SELECT getprivid(pPriv));

	

	SELECT 	rolepriv_id,

		rolepriv_priv_id, 

		rolepriv_role_id 	

	INTO _rolePriv

	FROM rolepriv

	WHERE rolepriv_priv_id = _privId 

	AND rolepriv_role_id = _roleId;



	IF _rolePriv.rolepriv_id IS NOT NULL THEN

		RETURN true;

	END IF;



	INSERT INTO rolepriv (	rolepriv_priv_id,

				rolepriv_role_id)

		VALUES (	_privId,

				_roleId);

				

	RETURN true;

END;$_$;


ALTER FUNCTION public.addrolepriv(text, text) OWNER TO admin;

--
-- TOC entry 348 (class 1255 OID 36790)
-- Name: addroleprivmodule(text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION addroleprivmodule(text, text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pModule			ALIAS FOR $1;

	pRole 		ALIAS FOR $2;

	_r			RECORD;

	_moduleId 		INTEGER;

	_roleId			INTEGER;

  

BEGIN

	PERFORM (SELECT getusrid());

	PERFORM (SELECT checkpriv('addroleprivmodule'));

	_moduleId := (SELECT getmoduleid(pModule));

	_roleId := (SELECT getroleid(pRole));



	FOR _r IN

		SELECT priv_name

		FROM priv

		WHERE priv_module_id = _moduleId

	LOOP

		IF _r.priv_name IS NOT NULL THEN

			PERFORM (SELECT addrolepriv(	_r.priv_name,

							pRole));

		END IF;

	END LOOP;

	

	RETURN true;

END;$_$;


ALTER FUNCTION public.addroleprivmodule(text, text) OWNER TO admin;

--
-- TOC entry 362 (class 1255 OID 36791)
-- Name: addusrpriv(text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION addusrpriv(text, text DEFAULT "current_user"()) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pPriv 			ALIAS FOR $1;

	pUserName 		ALIAS FOR $2;

	_usrPriv 		RECORD;

	_usrId 			INTEGER;

	_privId			INTEGER;

  

BEGIN

	PERFORM (SELECT getusrid());

	PERFORM (SELECT checkpriv('addusrpriv'));

	_usrId := (SELECT getusrid(pUserName));

	_privId := (SELECT getprivid(pPriv));

	

	SELECT 	usrpriv_id,

		usrpriv_priv_id, 

		usrpriv_usr_id 	

	INTO _usrPriv

	FROM usrpriv

	WHERE usrpriv_priv_id = _privId 

	AND usrpriv_usr_id = _usrId;



	IF _usrPriv.usrpriv_id IS NOT NULL THEN

		RETURN true;

	END IF;



	INSERT INTO usrpriv (	usrpriv_priv_id,

				usrpriv_usr_id)

		VALUES (	_privId,

				_usrId);

				

	RETURN true;

END;$_$;


ALTER FUNCTION public.addusrpriv(text, text) OWNER TO admin;

--
-- TOC entry 363 (class 1255 OID 36792)
-- Name: addusrprivmodule(text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION addusrprivmodule(text, text DEFAULT "current_user"()) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pModule			ALIAS FOR $1;

	pUserName 		ALIAS FOR $2;

	_r			RECORD;

	_moduleId 		INTEGER;

	_usrId			INTEGER;

  

BEGIN

	PERFORM (SELECT getusrid());

	PERFORM (SELECT checkpriv('addusrprivmodule'));

	_moduleId := (SELECT getmoduleid(pModule));

	_usrId := (SELECT getusrid(pUserName));



	FOR _r IN

		SELECT priv_name

		FROM priv

		WHERE priv_module_id = _moduleId

	LOOP

		IF _r.priv_name IS NOT NULL THEN

			PERFORM (SELECT addusrpriv(	_r.priv_name,

							pUserName));

		END IF;

	END LOOP;

	

	RETURN true;

END;$_$;


ALTER FUNCTION public.addusrprivmodule(text, text) OWNER TO admin;

--
-- TOC entry 364 (class 1255 OID 36793)
-- Name: addusrrole(text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION addusrrole(text, text DEFAULT "current_user"()) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pRole			ALIAS FOR $1;

	pUserName 		ALIAS FOR $2;

	_usrRole 		RECORD;

	_roleId 		INTEGER;

	_usrId			INTEGER;

  

BEGIN

	PERFORM (SELECT getusrid());

	PERFORM (SELECT checkpriv('addusrrole'));

	_roleId := (SELECT getroleid(pRole));

	_usrId := (SELECT getusrid(pUserName));

	

	SELECT 	usrrole_id,

		usrrole_usr_id, 

		usrrole_role_id 	

	INTO _usrRole

	FROM usrrole

	WHERE usrrole_usr_id = _usrId 

	AND usrrole_role_id = _roleId;



	IF _usrRole.usrrole_id IS NOT NULL THEN

		RETURN true;

	END IF;



	INSERT INTO usrrole (	usrrole_usr_id,

				usrrole_role_id)

		VALUES (	_usrId,

				_roleId);

				

	RETURN true;

END;$_$;


ALTER FUNCTION public.addusrrole(text, text) OWNER TO admin;

--
-- TOC entry 365 (class 1255 OID 36794)
-- Name: addwatcherpart(text, text, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION addwatcherpart(text, text, text, text DEFAULT "current_user"()) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pItemNumber		ALIAS FOR $1;

	pRevision		ALIAS FOR $2;

	pSerialNumber		ALIAS FOR $3;

	pUser			ALIAS FOR $4;

	_partId 		INTEGER;

	_usrId			INTEGER;

	_partWatcherId		INTEGER;

  

BEGIN

	_usrId := (SELECT getusrid(pUser));

	

	PERFORM (SELECT checkpriv('addwatcherpart'));

		

	_partId := (SELECT getpartid(pItemNumber, pRevision, pSerialNumber));



	_partWatcherId := 	(SELECT partwatcher_id 

				 FROM partwatcher

				 WHERE partwatcher_part_id = _partId

				 AND partwatcher_usr_id = _usrId);



	IF _partWatcherId IS NOT NULL THEN

		RETURN true;

	END IF;

	

	INSERT INTO partwatcher

		(partwatcher_part_id,

		 partwatcher_usr_id)

	VALUES	(_partId,

		 _usrId);

	

	RETURN true;

END;$_$;


ALTER FUNCTION public.addwatcherpart(text, text, text, text) OWNER TO admin;

--
-- TOC entry 368 (class 1255 OID 36795)
-- Name: addwatcherrecord(text, integer, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION addwatcherrecord(text, integer, text DEFAULT "current_user"()) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pRecordType		ALIAS FOR $1;

	pRecordId		ALIAS FOR $2;

	pUser			ALIAS FOR $3;

	_recordTypeId 		INTEGER;

	_usrId			INTEGER;

	_recordWatcherId		INTEGER;

  

BEGIN

	_usrId := (SELECT getusrid(pUser));

	

	PERFORM (SELECT checkpriv('addwatcherrecord'));

		

	_recordTypeId := (SELECT getrecordtypeid(pRecordType));



	_recordWatcherId := 	(SELECT recordwatcher_id 

				 FROM recordwatcher

				 WHERE recordwatcher_recordtype_id = _recordTypeId

				 AND recordwatcher_record_id = pRecordId

				 AND recordwatcher_usr_id = _usrId);



	IF _recordWatcherId IS NOT NULL THEN

		RETURN true;

	END IF;

	

	INSERT INTO recordwatcher

		(recordwatcher_recordtype_id, 

		 recordwatcher_record_id, 

		 recordwatcher_usr_id)

	VALUES 	(_recordTypeId,

		 pRecordId, 

		 _usrId);

	

	RETURN true;

END;$_$;


ALTER FUNCTION public.addwatcherrecord(text, integer, text) OWNER TO admin;

--
-- TOC entry 369 (class 1255 OID 36796)
-- Name: allocpart(text, text, text, text, text, text, text, integer, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION allocpart(text, text, text, text, text, text, text DEFAULT 'AMDA007'::text, integer DEFAULT 0, text DEFAULT NULL::text, text DEFAULT NULL::text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pParentItemNumber ALIAS FOR $1;

	pParentRevision ALIAS FOR $2;

	pParentSerialNumber ALIAS FOR $3;

	pItemNumber ALIAS FOR $4;

	pRevision ALIAS FOR $5;

	pSerialNumber ALIAS FOR $6;

	pAllocCode ALIAS FOR $7;	

	pAllocPos ALIAS FOR $8;

	pLine	ALIAS FOR $9;

	pStation ALIAS FOR $10;

	_parentviewpart RECORD;

	_viewpart RECORD;

	_allocCheck RECORD;

	_locationId INTEGER;

	_partStateId INTEGER;

	_deallocCheck BOOLEAN;

	_usrId INTEGER;

	_partAllocHistId INTEGER;

	_message TEXT;

	_r RECORD;

	_lineId INTEGER;

	_stationId	INTEGER;

  

BEGIN

	_usrID := (SELECT getusrid()); 

	PERFORM (SELECT checkpriv('allocpart'));

	PERFORM (SELECT validatepart(pItemNumber, pRevision, pSerialNumber, 'Child'));

	PERFORM (SELECT validatepart(pParentItemNumber, pParentRevision, pParentSerialNumber, 'Parent'));



	IF pStation IS NULL THEN

		_stationId := null;

	ELSE

		_stationId := (SELECT getstationid(pStation));

	END IF;



	IF pLine IS NULL THEN

		_lineId := null;

	ELSE

		_lineId := (SELECT getstationid(pStation));

	END IF;



	--Ensure Child is Valid

	SELECT 	part_id, 

		item_id, 

		item_number, 

		part_rev,

		part_serialnumber, 

		part_sequencenumber,

		parent_part_id,

		parent_item_number,

		parent_part_rev,

		parent_part_serialnumber

	INTO _viewpart

	FROM viewpart

	WHERE item_number = pItemNumber 

	AND part_serialnumber = pSerialNumber 

	AND part_rev = pRevision;



	--Ensure Parent is Valid

	SELECT 	part_id, 

		item_id, 

		item_number,

		cust_number,

		loc_number,

		partstate_name,

		part_rev,

		part_serialnumber, 

		part_sequencenumber,

		parent_part_id

	INTO _parentviewpart

	FROM viewpart

	WHERE item_number = pParentItemNumber 

	AND part_serialnumber = pParentSerialNumber 

	AND part_rev = pParentRevision;

	

	IF _parentviewpart.part_id = _viewpart.part_id THEN

		RAISE EXCEPTION 'allocpart: Parent Item Number % Revision % Serial Number % cannot be allocated to itself.', 

			pParentItemNumber, 

			pParentRevision, 

			pParentSerialNumber;

	END IF;



	SELECT *

	INTO _r

	FROM summsubass(	pItemNumber,

				pRevision,

				pSerialNumber)

	WHERE c_item_number = pParentItemNumber

	AND c_part_rev = pParentRevision

	AND c_part_serialnumber = pParentSerialNumber;



	IF _r.t_item_number IS NOT NULL THEN

		RAISE EXCEPTION 'allocpart: Parent Item Number % Revision % Serial Number % exists within Child Item Number % Revision % Serial Number % summarized subassembly.', 

			pParentItemNumber, 

			pParentRevision, 

			pParentSerialNumber,

			pItemNumber,

			pRevision,

			pSerialNumber;

	END IF;



	SELECT *

	INTO _allocCheck

	FROM checkalloc(pParentItemNumber, pParentRevision, pParentSerialNumber, pItemNumber, pRevision, pSerialNumber, pAllocPos);



	IF _allocCheck.oCode != pAllocCode THEN

		RAISE EXCEPTION 'allocpart: Allocation Code % returned by checkalloc does not match expected Allocation Code %.',

			_allocCheck.oCode,

			pAllocCode;

	END IF;



	IF (_allocCheck.oCode = pAllocCode) AND (pAllocCode = 'AMDA001') THEN

		_deallocCheck := (SELECT deallocpart(_viewpart.parent_item_number, _viewpart.parent_part_rev, _viewpart.parent_part_serialnumber, pItemNumber, pRevision, pSerialNumber, 'AMDD002', pLine, pStation));

		IF _deallocCheck = false THEN

			RAISE EXCEPTION 'allocpart: Could not deallocated Child Item Number % Revision % Serial Number % from its Parent Item Number % Revision % Serial Number %.',

				pItemNumber, 

				pRevision, 

				pSerialNumber, 

				_viewpart.parent_item_number, 

				_viewpart.parent_part_rev, 

				_viewpart.parent_part_serialnumber;

		END IF;

	ELSIF (_allocCheck.oCode = pAllocCode) AND (pAllocCode = 'AMDA002') THEN

		RETURN true; 

	ELSIF (_allocCheck.oCode = pAllocCode) AND (pAllocCode = 'AMDA003') THEN

		-- Log as allocation exception with code.

	ELSIF (_allocCheck.oCode = pAllocCode) AND (pAllocCode = 'AMDA004') THEN

		-- Log as allocation exception with code.

	ELSIF (_allocCheck.oCode = pAllocCode) AND (pAllocCode = 'AMDA005') THEN

		-- Log as allocation exception with code.

	ELSIF (_allocCheck.oCode = pAllocCode) AND (pAllocCode = 'AMDA006') THEN

		-- Log as allocation exception with code.

	END IF;



	UPDATE 	part

	SET 	(part_parent_part_id,

		 part_allocpos) =

		(_parentviewpart.part_id,

		 pAllocPos)

	WHERE part_id = _viewpart.part_id;



	IF _parentviewpart.loc_number IS NOT NULL THEN

		PERFORM (SELECT changelocsummsubass(pItemNumber, pRevision, pSerialNumber, _parentviewpart.loc_number));

	END IF;

	

	--IF _parentviewpart.cust_number IS NOT NULL THEN

		--PERFORM (SELECT changecustpart(pItemNumber, pRevision, pSerialNumber, _parentviewpart.cust_number));

	--END IF;

	

	INSERT INTO partallochist

		(partallochist_parent_part_id,

		 partallochist_child_part_id,

		 partallochist_allocpos,

		 partallochist_alloctype,

		 partallochist_alloccode,

		 partallochist_usr_id,

		 partallochist_parent_orig_item_id,

		 partallochist_parent_orig_rev,

		 partallochist_parent_orig_serialnumber,

		 partallochist_child_orig_item_id,

		 partallochist_child_orig_rev,

		 partallochist_child_orig_serialnumber,

		 partallochist_line_id,

		 partallochist_station_id)

	VALUES	(_parentviewpart.part_id,

		 _viewpart.part_id,

		 pAllocPos,

		 'a',

		 pAllocCode,

		 _usrId,

		 _parentviewpart.item_id,

		 _parentviewpart.part_rev,

		 _parentviewpart.part_serialnumber,

		 _viewpart.item_id,

		 _viewpart.part_rev,

		 _viewpart.part_serialnumber,

		 _lineId,

		 _stationId)

	RETURNING partallochist_id INTO _partAllocHistId;

	

	_message := 	pItemNumber || ' ' || 

			pRevision || ' ' || 

			pSerialNumber || ' allocated to ' || 

			pParentItemNumber || ' ' || 

			pParentRevision || ' ' || 

			pParentSerialNumber || ' with allocation code ' ||

			pAllocCode || '.';



	PERFORM (SELECT enterpartlog(	'Manufacturing'::TEXT, 

					'Allocated'::TEXT,

					pParentItemNumber,

					pParentRevision,

					pParentSerialNumber,

					'Allocation History'::TEXT,

					_partAllocHistId,

					_message,

					null,

					null,

					pLine,

					pStation));



	PERFORM (SELECT enterpartlog(	'Manufacturing'::TEXT, 

					'Allocated'::TEXT,

					pItemNumber,

					pRevision,

					pSerialNumber,

					'Allocation History'::TEXT,

					_partAllocHistId,

					_message,

					null,

					null,

					pLine,

					pStation));



	PERFORM (SELECT changestatesummsubass(pItemNumber, pRevision, pSerialNumber, _parentviewpart.partstate_name, true, true));



	RETURN true;

END;$_$;


ALTER FUNCTION public.allocpart(text, text, text, text, text, text, text, integer, text, text) OWNER TO admin;

--
-- TOC entry 370 (class 1255 OID 36799)
-- Name: changecustparam(text, text, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION changecustparam(text, text, text, text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pType 			ALIAS FOR $1;

	pParam	 		ALIAS FOR $2;

	pNewParam		ALIAS FOR $3;

	pNewDataType		ALIAS FOR $4;

	_dataTypeId		INTEGER;

	_custParam 		RECORD;

	_newCustParam 		RECORD;

	_custParamId		INTEGER;

  

BEGIN

	PERFORM (SELECT getusrid());

	PERFORM (SELECT checkpriv('changecustparam'));



	IF pParam IS NULL THEN

		RAISE EXCEPTION 'changecustparam: Custom Parameter Name cannot be null.';

	END IF;



	IF pType != 'r' AND pType != 'p' THEN

		RAISE EXCEPTION 'changecustparam: Custom Parameter must be of Type r or p.';

	END IF;

	

	SELECT 	custparam_id,

		custparam_type, 

		custparam_param,

		custparam_datatype_id,

		datatype_type 	

	INTO _custParam

	FROM custparam

	LEFT OUTER JOIN datatype

		ON datatype.datatype_id = custparam.custparam_datatype_id

	WHERE custparam_param = pParam 

	AND custparam_type = pType

	AND custparam_void_timestamp IS NULL;



	IF _custParam.custparam_id IS NULL THEN

		RAISE EXCEPTION 'Custom Parameter % of Type % does not exist.',

			pParam,

			pType;

	END IF;



	SELECT 	custparam_id,

		custparam_type, 

		custparam_param,

		custparam_datatype_id,

		datatype_type 	

	INTO _newCustParam

	FROM custparam

	LEFT OUTER JOIN datatype

		ON datatype.datatype_id = custparam.custparam_datatype_id

	WHERE custparam_param = pNewParam 

	AND custparam_type = pType

	AND custparam_void_timestamp IS NULL;



	IF _newCustParam.custparam_id IS NOT NULL THEN

		RAISE EXCEPTION 'New Custom Parameter % of Type % already exists.',

			pParam,

			pType;

	END IF;



	IF pParam != pNewParam THEN

		UPDATE 	custparam

		SET 	(custparam_param)

		= 	(pNewParam)

		WHERE 	custparam_id = _custParam.custparam_id;

	END IF;

	

	IF pNewDataType != _custParam.datatype_type THEN

		PERFORM (SELECT removecustparam(pType, pNewParam));

		_custParamId := (SELECT addcustparam(pType, pNewParam, pNewDataType));

		PERFORM (SELECT transfercustparamlink(_custParam.custparam_id, _custParamId));

		PERFORM (SELECT transfercustparamcombo(_custParam.custparam_id, _custParamId));

	END IF;

				

	RETURN true;

END;$_$;


ALTER FUNCTION public.changecustparam(text, text, text, text) OWNER TO admin;

--
-- TOC entry 371 (class 1255 OID 36800)
-- Name: changecustpart(text, text, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION changecustpart(text, text, text, text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pItemNumber ALIAS FOR $1;

	pRevision ALIAS FOR $2;

	pSerialNumber ALIAS FOR $3;

	pCustNumber ALIAS FOR $4;

	_viewpart RECORD;

	_item RECORD;

	_partId INTEGER;

	_usrId INTEGER;

	_custId INTEGER;

	_custHistId INTEGER;

	_message TEXT;

	_r RECORD;

  

BEGIN

	_usrID := (SELECT getusrid()); 

	PERFORM (SELECT checkpriv('changecustpart'));

	PERFORM (SELECT validatepart(pItemNumber, pRevision, pSerialNumber));



	SELECT 	part_id, 

		item_id, 

		item_number,

		part_rev, 

		part_serialnumber, 

		part_sequencenumber,

		part_cust_id,

		cust_number,

		loc_number

	INTO _viewpart

	FROM viewpart

	WHERE item_number = pItemNumber 

	AND part_serialnumber = pSerialNumber 

	AND part_rev = pRevision;



	IF pCustNumber IS NOT NULL THEN

		_custId := (SELECT getcustid(pCustNumber));

	ELSE

		_custId := null;

	END IF;



	IF _custId = _viewpart.part_cust_id THEN

		RETURN true;

	ELSIF _custId IS NULL AND _viewpart.part_cust_id IS NULL THEN

		RETURN true;

	END IF;



	UPDATE part SET (part_cust_id) =

			(_custId)

	WHERE part_id = _viewpart.part_id;



	INSERT INTO custhist (	custhist_part_id, 

				 custhist_start_cust_id, 

				 custhist_end_cust_id,

				 custhist_usr_id,

				 custhist_orig_item_id,

				 custhist_orig_rev,

				 custhist_orig_serialnumber)

		VALUES (	_viewpart.part_id, 

				_viewpart.part_cust_id, 

				_custId,

				_usrId,

				_viewpart.item_id,

				_viewpart.part_rev,

				_viewpart.part_serialnumber)

		RETURNING custhist_id INTO _custHistId;



	IF _viewpart.cust_number IS NULL THEN

		_message := 	pItemNumber || ' ' ||  

				pRevision || ' ' || 

				pSerialNumber || ' Customer changed from <null> to ' ||

				pCustNumber || '.';

	ELSIF _custId IS NULL THEN

		_message := 	pItemNumber || ' ' ||  

				pRevision || ' ' || 

				pSerialNumber || ' Customer changed from ' || 

				_viewpart.cust_number || ' to <null>.';

	ELSE

		_message := 	pItemNumber || ' ' ||  

				pRevision || ' ' || 

				pSerialNumber || ' Customer changed from ' ||

				_viewpart.cust_number || ' to ' ||

				pCustNumber || '.';

	END IF;



	PERFORM (SELECT enterpartlog(	'Manufacturing'::TEXT, 

					'Customer Changed'::TEXT,

					pItemNumber,

					pRevision,

					pSerialNumber,

					'Customer History'::TEXT,

					_custHistId,

					_message));

		  

	RETURN true;

END;$_$;


ALTER FUNCTION public.changecustpart(text, text, text, text) OWNER TO admin;

--
-- TOC entry 372 (class 1255 OID 36801)
-- Name: changecustsummsubass(text, text, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION changecustsummsubass(text, text, text, text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pItemNumber ALIAS FOR $1;

	pRevision ALIAS FOR $2;

	pSerialNumber ALIAS FOR $3;

	pCustNumber ALIAS FOR $4;

	_usrId INTEGER;

	_r RECORD;

  

BEGIN

	_usrID := (SELECT getusrid()); 

	PERFORM (SELECT checkpriv('changecustsummsubass'));

	PERFORM (SELECT validatepart(pItemNumber, pRevision, pSerialNumber));



	PERFORM (SELECT changecustpart(	pItemNumber,

					pRevision,

					pSerialNumber,

					pCustNumber));

	

	FOR _r IN

		SELECT *

		FROM summsubass(	pItemNumber,

					pRevision,

					pSerialNumber)

	LOOP

		IF _r.c_item_number IS NOT NULL THEN

			PERFORM (SELECT changecustpart(	_r.c_item_number,

							_r.c_part_rev,

							_r.c_part_serialnumber,

							pCustNumber));

		END IF;

	END LOOP;

		  

	RETURN true;

END;$_$;


ALTER FUNCTION public.changecustsummsubass(text, text, text, text) OWNER TO admin;

--
-- TOC entry 373 (class 1255 OID 36802)
-- Name: changelocpart(text, text, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION changelocpart(text, text, text, text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pItemNumber ALIAS FOR $1;

	pRevision ALIAS FOR $2;

	pSerialNumber ALIAS FOR $3;

	pLocNumber ALIAS FOR $4;

	_viewpart RECORD;

	_item RECORD;

	_partId INTEGER;

	_usrId INTEGER;

	_locId INTEGER;

	_locHistId INTEGER;

	_message TEXT;

	_r RECORD;

  

BEGIN

	_usrID := (SELECT getusrid()); 

	PERFORM (SELECT checkpriv('changelocpart'));

	PERFORM (SELECT validatepart(pItemNumber, pRevision, pSerialNumber));

	

	SELECT 	part_id, 

		item_id, 

		item_number,

		part_rev, 

		part_serialnumber, 

		part_sequencenumber,

		part_loc_id,

		loc_number

	INTO _viewpart

	FROM viewpart

	WHERE item_number = pItemNumber 

	AND part_serialnumber = pSerialNumber 

	AND part_rev = pRevision;

	

	_locId := (SELECT getlocid(pLocNumber));



	IF _locId = _viewpart.part_loc_id THEN

		RETURN true;

	END IF;



	UPDATE part SET (part_loc_id) =

			(_locId)

	WHERE part_id = _viewpart.part_id;



	INSERT INTO lochist (	lochist_part_id, 

				lochist_start_loc_id, 

				lochist_end_loc_id,

				lochist_usr_id,

				lochist_orig_item_id,

				lochist_orig_rev,

				lochist_orig_serialnumber)

		VALUES (	_viewpart.part_id, 

				_viewpart.part_loc_id, 

				_locId,

				_usrId,

				_viewpart.item_id,

				_viewpart.part_rev,

				_viewpart.part_serialnumber)

		RETURNING lochist_id INTO _locHistId;



	_message := 	pItemNumber || ' ' ||  

			pRevision || ' ' || 

			pSerialNumber || ' Location changed from ' ||

			_viewpart.loc_number || ' to ' ||

			pLocNumber || '.';



	PERFORM (SELECT enterpartlog(	'Manufacturing'::TEXT, 

					'Location Changed'::TEXT,

					pItemNumber,

					pRevision,

					pSerialNumber,

					'Location History'::TEXT,

					_locHistId,

					_message));

	

	RETURN true;

END;$_$;


ALTER FUNCTION public.changelocpart(text, text, text, text) OWNER TO admin;

--
-- TOC entry 374 (class 1255 OID 36803)
-- Name: changelocsummsubass(text, text, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION changelocsummsubass(text, text, text, text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pItemNumber ALIAS FOR $1;

	pRevision ALIAS FOR $2;

	pSerialNumber ALIAS FOR $3;

	pLocNumber ALIAS FOR $4;

	_usrId INTEGER;

	_r RECORD;

  

BEGIN

	_usrID := (SELECT getusrid()); 

	PERFORM (SELECT checkpriv('changelocsummsubass'));

	PERFORM (SELECT validatepart(pItemNumber, pRevision, pSerialNumber));

	

	PERFORM (SELECT changelocpart(	pItemNumber,

					pRevision,

					pSerialNumber,

					pLocNumber));

	

	FOR _r IN

		SELECT *

		FROM summsubass(	pItemNumber,

					pRevision,

					pSerialNumber)

	LOOP

		IF _r.c_item_number IS NOT NULL THEN

			PERFORM (SELECT changelocpart(	_r.c_item_number,

							_r.c_part_rev,

							_r.c_part_serialnumber,

							pLocNumber));

		END IF;

	END LOOP;

	

	RETURN true;

END;$_$;


ALTER FUNCTION public.changelocsummsubass(text, text, text, text) OWNER TO admin;

--
-- TOC entry 375 (class 1255 OID 36804)
-- Name: changerevpart(text, text, text, text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION changerevpart(text, text, text, text, text, text, text DEFAULT NULL::text, text DEFAULT NULL::text) RETURNS TABLE(_partnumber text, _revision text, _serialnumber text, _sequencenumber integer, _itemfreqcode text, _partrevhistid integer)
    LANGUAGE plpgsql
    AS $_$DECLARE

	pItemNumber ALIAS FOR $1;

	pCurrentRevision ALIAS FOR $2;

	pSerialNumber ALIAS FOR $3;

	pDocNumber ALIAS FOR $4;

	pDocType ALIAS FOR $5;

	pTargetRevision ALIAS FOR $6;

	pLine ALIAS FOR $7;

	pStation ALIAS FOR $8;

	_viewpart RECORD;

	_item RECORD;

	_docTypeId INTEGER;

	_partid INTEGER;

	_usrId INTEGER;

	_lineId	INTEGER;

	_stationId INTEGER;

  

BEGIN

	_usrID := (SELECT getusrid()); 

	PERFORM (SELECT checkpriv('changerevpart'));

	PERFORM (SELECT validatepart(pItemNumber, pCurrentRevision, pSerialNumber));



	SELECT 	part_id, 

		item_id, 

		item_number,

		part_rev,

		part_serialnumber, 

		part_sequencenumber

	INTO _viewpart

	FROM viewpart

	WHERE item_number = pItemNumber AND part_serialnumber = pSerialNumber AND part_rev = pCurrentRevision;



	SELECT 	item_id, 

		item_serialstream_id, 

		serialprefix_prefix, 

		serialpattern_pattern, 

		itemfreqcode_freqcode

	INTO _item

	FROM item 

	LEFT OUTER JOIN serialstream ON item_serialstream_id = serialstream_id

	LEFT OUTER JOIN serialprefix ON item_serialprefix_id = serialprefix_id

	LEFT OUTER JOIN serialpattern ON serialprefix_serialpattern_id = serialpattern_id

	LEFT OUTER JOIN itemfreqcode ON item_itemfreqcode_id = itemfreqcode_id

	WHERE item_number = pItemNumber 

	AND item_active = true;



	IF _item.item_id IS NULL THEN

		RAISE EXCEPTION 'Item Number % not found in AeryonMES', pItemNumber;

	END IF;



	IF (SELECT itemrev_id

	    FROM itemrev

	    WHERE itemrev_item_id = _item.item_id

	    AND itemrev_rev = pTargetRevision) IS NULL THEN

		RAISE EXCEPTION 'Target Revision % of Selected Item % Not Found in AeryonMES', pTargetRevision, pItemNumber;

	END IF;



	_docTypeId := (SELECT getdoctypeid(pDocType));



	IF pStation IS NULL THEN

		_stationId := null;

	ELSE

		_stationId := (SELECT getstationid(pStation));

	END IF;



	IF pLine IS NULL THEN

		_lineId := null;

	ELSE

		_lineId := (SELECT getstationid(pStation));

	END IF;



	UPDATE part SET (  

				part_rev

				)

			= (

				pTargetRevision

				)

			WHERE part_id = _viewpart.part_id;



	INSERT INTO partrevhist (partrevhist_part_id, 

				 partrevhist_start_rev, 

				 partrevhist_end_rev,

				 partrevhist_usr_id,

				 partrevhist_orig_item_id,

				 partrevhist_orig_rev,

				 partrevhist_orig_serialnumber,

				 partrevhist_doctype_id,

				 partrevhist_docnumber,

				 partrevhist_line_id,

				 partrevhist_station_id)

		VALUES (_viewpart.part_id, 

			pCurrentRevision, 

			pTargetRevision,

			_usrId,

			_viewpart.item_id,

			_viewpart.part_rev,

			_viewpart.part_serialnumber,

			_docTypeId,

			pDocNumber,

			_lineId,

			_stationId)

		RETURNING partrevhist_id INTO _partRevHistId;

		  

	_partnumber := pItemNumber;

	_serialnumber := pSerialNumber;

	_revision := pTargetRevision;

	_itemfreqcode := _item.itemfreqcode_freqcode;

	_sequencenumber := _viewpart.part_sequencenumber;

	

	RETURN NEXT;

	RETURN;

END;$_$;


ALTER FUNCTION public.changerevpart(text, text, text, text, text, text, text, text) OWNER TO admin;

--
-- TOC entry 378 (class 1255 OID 36805)
-- Name: changestatepart(text, text, text, text, boolean, boolean); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION changestatepart(text, text, text, text, boolean DEFAULT false, boolean DEFAULT false) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pItemNumber 		ALIAS FOR $1;

	pRevision 		ALIAS FOR $2;

	pSerialNumber 		ALIAS FOR $3;

	pTargetState 		ALIAS FOR $4;

	pOverride		ALIAS FOR $5;

	pForce			ALIAS FOR $6;

	_viewpart 		RECORD;

	_currentPartStateId	INTEGER;

	_targetPartStateId 	INTEGER;

	_partStateHistId	INTEGER;

	_usrId 			INTEGER;

	_message		TEXT;

  

BEGIN

	_usrID := (SELECT getusrid()); 

	PERFORM (SELECT checkpriv('changestatepart'));

	PERFORM (SELECT validatepart(pItemNumber, pRevision, pSerialNumber));



	SELECT 	part_id, 

		item_id, 

		item_number,

		part_rev,

		part_serialnumber, 

		part_sequencenumber,

		partstate_name

	INTO _viewpart

	FROM viewpart

	WHERE item_number = pItemNumber AND part_serialnumber = pSerialNumber AND part_rev = pRevision;



	IF _viewpart.partstate_name = pTargetState THEN

		RETURN true;

	END IF;



	IF (NOT pForce) THEN

		PERFORM (SELECT checkpartstateflow(_viewpart.partstate_name, pTargetState, pOverride));

	ELSE

		pOverride := true;

	END IF;



	_currentPartStateId := (SELECT getpartstateid(_viewpart.partstate_name));

	_targetPartStateId := (SELECT getpartstateid(pTargetState));

	

	UPDATE part SET (  

				part_partstate_id

				)

			= (

				_targetPartStateId

				)

		WHERE part_id = _viewpart.part_id;



	INSERT INTO partstatehist (partstatehist_part_id, 

				 partstatehist_start_partstate_id, 

				 partstatehist_end_partstate_id,

				 partstatehist_usr_id,

				 partstatehist_orig_item_id,

				 partstatehist_orig_rev,

				 partstatehist_orig_serialnumber,

				 partstatehist_overridden)

		VALUES (_viewpart.part_id, 

			_currentPartStateId, 

			_targetPartStateId,

			_usrId,

			_viewpart.item_id,

			_viewpart.part_rev,

			_viewpart.part_serialnumber,

			pOverride)

		RETURNING partstatehist_id INTO _partStateHistId;



	_message := 	pItemNumber || ' ' ||  

			pRevision || ' ' || 

			pSerialNumber || ' part state changed from ' ||

			_viewpart.partstate_name || ' to ' ||

			pTargetState || '.';

	

	PERFORM (SELECT enterpartlog(	'Part State Control'::TEXT, 

					'Part State Changed'::TEXT,

					pItemNumber,

					pRevision,

					pSerialNumber,

					'Part State History'::TEXT,

					_partStateHistId,

					_message));

	

	RETURN true;

END;$_$;


ALTER FUNCTION public.changestatepart(text, text, text, text, boolean, boolean) OWNER TO admin;

--
-- TOC entry 379 (class 1255 OID 36806)
-- Name: changestatesummsubass(text, text, text, text, boolean, boolean); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION changestatesummsubass(text, text, text, text, boolean DEFAULT false, boolean DEFAULT false) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pItemNumber ALIAS FOR $1;

	pRevision ALIAS FOR $2;

	pSerialNumber ALIAS FOR $3;

	pTargetPartState ALIAS FOR $4;

	pOverride ALIAS FOR $5;

	pForce ALIAS FOR $6;

	_usrId INTEGER;

	_r RECORD;

  

BEGIN

	_usrID := (SELECT getusrid()); 

	PERFORM (SELECT checkpriv('changestatesummsubass'));

	PERFORM (SELECT validatepart(pItemNumber, pRevision, pSerialNumber));

	

	PERFORM (SELECT changestatepart(pItemNumber,

					pRevision,

					pSerialNumber,

					pTargetPartState,

					pOverride,

					pForce));

	

	FOR _r IN

		SELECT *

		FROM summsubass(	pItemNumber,

					pRevision,

					pSerialNumber)

	LOOP

		IF _r.c_item_number IS NOT NULL THEN

			PERFORM (SELECT changestatepart(_r.c_item_number,

							_r.c_part_rev,

							_r.c_part_serialnumber,

							pTargetPartState,

							pOverride,

							pForce));

		END IF;

	END LOOP;

		  

	RETURN true;

END;$_$;


ALTER FUNCTION public.changestatesummsubass(text, text, text, text, boolean, boolean) OWNER TO admin;

--
-- TOC entry 380 (class 1255 OID 36807)
-- Name: checkalloc(text, text, text, text, text, text, integer); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION checkalloc(text, text, text, text, text, text, integer DEFAULT 1) RETURNS TABLE(ocode text, omessage text)
    LANGUAGE plpgsql
    AS $_$DECLARE

	pParentItemNumber ALIAS FOR $1;

	pParentRevision ALIAS FOR $2;

	pParentSerialNumber ALIAS FOR $3;

	pItemNumber ALIAS FOR $4;

	pRevision ALIAS FOR $5;

	pSerialNumber ALIAS FOR $6;

	pAllocPos ALIAS FOR $7;

	_parentviewpart RECORD;

	_viewpart RECORD;

	_qtyPerCurrent INTEGER;

	_qtyAllocCurrent INTEGER;

	_qtyPerAny INTEGER;

	_qtyAllocAny INTEGER;

	_locationId INTEGER;

	_partStateId INTEGER;

	_r RECORD;

	_error BOOLEAN;

  

BEGIN

	PERFORM (SELECT checkpriv('checkalloc'));

	BEGIN

		PERFORM (SELECT validatepart(pItemNumber, pRevision, pSerialNumber, 'Child'));

	EXCEPTION

		WHEN raise_exception THEN

			oCode := 	'AMDA008';

			oMessage := 	'Child Item Number ' || pItemNumber || 

					' Revision ' || pRevision || 

					' Serial Number ' || pSerialNumber || 

					' does not exist.';

			RETURN NEXT;

			RETURN;

			

	END;

	PERFORM (SELECT validatepart(pParentItemNumber, pParentRevision, pParentSerialNumber, 'Parent'));



	SELECT 	part_id, 

		item_id, 

		item_number, 

		part_serialnumber, 

		part_sequencenumber,

		part_allocpos,

		parent_part_id,

		parent_item_number,

		parent_part_rev,

		parent_part_serialnumber

	INTO _viewpart

	FROM viewpart

	WHERE item_number = pItemNumber 

	AND part_serialnumber = pSerialNumber 

	AND part_rev = pRevision;



	SELECT 	part_id, 

		item_id, 

		item_number, 

		part_serialnumber, 

		part_sequencenumber

		parent_part_id

	INTO _parentviewpart

	FROM viewpart

	WHERE item_number = pParentItemNumber 

	AND part_serialnumber = pParentSerialNumber 

	AND part_rev = pParentRevision;



	_error := false;



	IF _viewpart.parent_part_id = _parentviewpart.part_id AND _viewpart.part_allocpos = pAllocPos THEN

		oCode := 	'AMDA002';

		oMessage := 	'Child Item Number ' || pItemNumber || 

				' Revision ' || pRevision || 

				' Serial Number ' || pSerialNumber || 

				' is already allocated to Parent Item Number ' || pParentItemNumber || 

				' Revision ' || pParentRevision || 

				' Serial Number ' || pParentSerialNumber || 

				'.';

		RETURN NEXT;

		RETURN;

	END IF;



	IF _viewpart.parent_part_id IS NOT NULL THEN

		oCode := 	'AMDA001';

		oMessage := 	'Child Item Number ' || pItemNumber || 

				' Revision ' || pRevision || 

				' Serial Number ' || pSerialNumber || 

				' is allocated to Parent Item Number ' || _viewpart.parent_item_number || 

				' Revision ' || _viewpart.parent_part_rev || 

				' Serial Number ' || _viewpart.parent_part_serialnumber || 

				' in allocation position ' || _viewpart.part_allocpos || 

				'.';

		RETURN NEXT;

		_error = true;

	END IF;



	_qtyPerCurrent := (SELECT checkserialbom(pParentItemNumber, pParentRevision, pItemNumber, pRevision));

	_qtyPerAny := (SELECT checkserialbom(pParentItemNumber, pParentRevision, pItemNumber, null));



	IF _qtyPerAny <= 0 THEN

		oCode := 	'AMDA003';

		oMessage := 	'Child Item Number ' || pItemNumber || 

				' Revision ANY Serial Number ' || pSerialNumber || 

				' not found in BOM of Parent Item Number  ' || pParentItemNumber || 

				' Revision ' || pParentRevision || 

				' Serial Number ' || pParentSerialNumber || 

				'.'; 

		RETURN NEXT;

		_error = true;

	ELSIF _qtyPerCurrent <= 0 THEN

		oCode := 	'AMDA004';

		oMessage := 	'Child Item Number ' || pItemNumber || 

				' Revision ' || pRevision || 

				' Serial Number ' || pSerialNumber || 

				' not found in BOM of Parent Item Number ' || pParentItemNumber || 

				' Revision ' || pParentRevision || 

				' Serial Number ' || pParentSerialNumber || 

				'.';

		RETURN NEXT;

		_error = true;

	END IF;



	_qtyAllocCurrent := 	(SELECT COUNT(c_item_number) 

				FROM serialsubass(pParentItemNumber, pParentRevision, pParentSerialNumber) 

				WHERE p_item_number = pParentItemNumber 

				AND c_item_number = pItemNumber

				AND c_part_rev = pRevision);

	_qtyAllocAny	:= 	(SELECT COUNT(c_item_number) 

				FROM serialsubass(pParentItemNumber, pParentRevision, pParentSerialNumber) 

				WHERE p_item_number = pParentItemNumber 

				AND c_item_number = pItemNumber);



	IF (_qtyPerCurrent > 0 AND _qtyAllocCurrent >= _qtyPerCurrent) THEN

		oCode := 	'AMDA005';

		oMessage := 	'Qty ' || _qtyAllocCurrent || 

				' of Item Number ' || pItemNumber || 

				' Revision ' || pRevision || 

				' already allocted to Parent Item Number ' || pParentItemNumber || 

				' Revision ' || pParentRevision || 

				' Serial Number ' || pParentSerialNumber || 

				'. Only ' || _qtyPerCurrent || 

				' may be allocated as per BOM Qty Per.';

		RETURN NEXT;

		_error = true;

	ELSIF (_qtyPerAny > 0 AND _qtyAllocAny >= _qtyPerAny) THEN

		oCode := 	'AMDA006';

		oMessage := 	'Qty ' || _qtyAllocAny || 

				' of Item Number ' || pItemNumber || 

				' Revision ANY already allocted to Parent Item Number ' || pParentItemNumber || 

				' Revision ' || pParentRevision || 

				' Serial Number ' || pParentSerialNumber || 

				'. Only ' || _qtyPerAny || 

				' may be allocated as per BOM Qty Per.';

		RETURN NEXT;

		_error = true;

	END IF;



	IF (NOT _error) THEN

		oCode := 	'AMDA007';

		oMessage := 	'Child Item Number ' || pItemNumber || 

				' Revision ' || pRevision || 

				' Serial Number ' || pSerialNumber || 

				' can be allocated to Parent Item Number ' || pParentItemNumber || 

				' Revision ' || pParentRevision || 

				' Serial Number ' || pParentSerialNumber || 

				'.';

		RETURN NEXT;

	END IF;



	RETURN;

END;$_$;


ALTER FUNCTION public.checkalloc(text, text, text, text, text, text, integer) OWNER TO admin;

--
-- TOC entry 381 (class 1255 OID 36808)
-- Name: checkpartstateflow(text, text, boolean); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION checkpartstateflow(text, text, boolean DEFAULT false) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$

DECLARE

	pCurrentState	ALIAS FOR $1;

	pTargetState	ALIAS FOR $2;

	pOverride	ALIAS FOR $3;

	_stateInfo	RECORD;

BEGIN

	PERFORM (SELECT checkpriv('checkpartstateflow'));

	PERFORM (SELECT getpartstateid(pCurrentState));

	PERFORM (SELECT getpartstateid(pTargetState));



	IF pCurrentState = pTargetState THEN

		RETURN true;

	END IF;

		

	SELECT 	start_partstate_id,

		start_partstate_name,

		start_partstate_active,

		end_partstate_id,

		end_partstate_name,

		end_partstate_active,

		partstateflow_id,

		partstateflow_active,

		partstateflow_overridereq

	INTO _stateInfo

	FROM viewpartstateflow

	WHERE start_partstate_name = pCurrentState

	AND end_partstate_name = pTargetState;



	IF _stateInfo.partstateflow_id IS NULL THEN

		RAISE EXCEPTION 'checkpartstateflow: Part State Flow does not exist for Current State % to Target State %.', 

			pCurrentState,

			pTargetState;

	ELSIF _stateInfo.partstateflow_active = false THEN

		RAISE EXCEPTION 'checkpartstateflow: Part State Flow is not active for Current State % to Target State %.', 

			pCurrentState,

			pTargetState;

	ELSIF _stateInfo.end_partstate_active = false THEN

		RAISE EXCEPTION 'checkpartstateflow: Target Part State % is not active.', 

			pTargetState;

	ELSIF _stateInfo.partstateflow_overridereq = true AND pOverride = false THEN

		RAISE EXCEPTION 'checkpartstateflow: Part State Flow requires override for Current State % to Target State %.', 

			pCurrentState,

			pTargetState;

	ELSIF _stateInfo.partstateflow_overridereq = true AND pOverride = true THEN

		PERFORM (SELECT checkpriv('checkpartstateflowoverride'));

	END IF;



	RETURN true;

END;

$_$;


ALTER FUNCTION public.checkpartstateflow(text, text, boolean) OWNER TO admin;

--
-- TOC entry 351 (class 1255 OID 36809)
-- Name: checkpriv(text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION checkpriv(text, text DEFAULT "current_user"()) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$

DECLARE

	pPriv 		ALIAS FOR $1;

	pUserName	ALIAS FOR $2;

	_privGranted 	RECORD;

	_usrId		INTEGER;

BEGIN		

	SELECT usr_username, priv_name

	INTO _privGranted

	FROM viewprivgranted

	WHERE usr_username = pUserName

	AND priv_name = pPriv;



	IF _privGranted.usr_username IS NULL 

	OR (_privGranted.usr_username != pUserName) 

	OR (_privGranted.priv_name != pPriv) THEN

		RAISE EXCEPTION 'checkpriv: User Name % does not have Privilege %.', 

			pUserName,

			pPriv;

	END IF;



	RETURN true;

END;

$_$;


ALTER FUNCTION public.checkpriv(text, text) OWNER TO admin;

--
-- TOC entry 352 (class 1255 OID 36810)
-- Name: checkserialbom(text, text, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION checkserialbom(text, text, text, text) RETURNS integer
    LANGUAGE plpgsql
    AS $_$DECLARE

	pParentItemNumber ALIAS FOR $1;

	pParentRevision ALIAS FOR $2;

	pItemNumber ALIAS FOR $3;

	pRevision ALIAS FOR $4;

	_parentitem RECORD;

	_item RECORD;

	_serialbom RECORD;

  

BEGIN

	PERFORM (SELECT checkpriv('checkserialbom'));

	

	IF pRevision IS NULL THEN

		pRevision = '%';

	END IF;



	SELECT item_id, item_serialstream_id, serialprefix_prefix, serialpattern_pattern, itemfreqcode_freqcode

	INTO _parentitem

	FROM item 

	LEFT OUTER JOIN serialstream ON item_serialstream_id = serialstream_id

	LEFT OUTER JOIN serialprefix ON item_serialprefix_id = serialprefix_id

	LEFT OUTER JOIN serialpattern ON serialprefix_serialpattern_id = serialpattern_id

	LEFT OUTER JOIN itemfreqcode ON item_itemfreqcode_id = itemfreqcode_id

	WHERE item_number = pParentItemNumber 

	AND item_active = true;



	IF _parentitem.item_id IS NULL THEN

		RAISE EXCEPTION 'checkserialbom: Parent Item Number % not found in AeryonMES', pParentItemNumber;

	END IF;



	IF (SELECT itemrev_id

	    FROM itemrev

	    WHERE itemrev_item_id = _parentitem.item_id

	    AND itemrev_rev = pParentRevision) IS NULL THEN

		RAISE EXCEPTION 'checkserialbom: Parent Revision % of Selected Parent Item % Not Found in AeryonMES', pParentRevision, pParentItemNumber;

	END IF;



	SELECT item_id, item_serialstream_id, serialprefix_prefix, serialpattern_pattern, itemfreqcode_freqcode

	INTO _item

	FROM item 

	LEFT OUTER JOIN serialstream ON item_serialstream_id = serialstream_id

	LEFT OUTER JOIN serialprefix ON item_serialprefix_id = serialprefix_id

	LEFT OUTER JOIN serialpattern ON serialprefix_serialpattern_id = serialpattern_id

	LEFT OUTER JOIN itemfreqcode ON item_itemfreqcode_id = itemfreqcode_id

	WHERE item_number = pItemNumber 

	AND item_active = true;



	IF _item.item_id IS NULL THEN

		RAISE EXCEPTION 'checkserialbom: Item Number % not found in AeryonMES', pItemNumber;

	END IF;



	IF (SELECT itemrev_id

	    FROM itemrev

	    WHERE itemrev_item_id = _item.item_id

	    AND itemrev_rev LIKE pRevision LIMIT 1) IS NULL THEN

		RAISE EXCEPTION 'checkserialbom: Revision % of Selected Item % Not Found in AeryonMES', pRevision, pItemNumber;

	END IF;



	SELECT *

	INTO _serialbom

	FROM serialbom(pParentItemNumber, pParentRevision)

	WHERE c_item_number = pItemNumber

	AND c_bom_itemrev LIKE pRevision;





	IF _serialbom.c_item_number IS NULL THEN

		RETURN 0; 

	END IF;

	

	RETURN _serialbom.c_bom_qtyper;

END;$_$;


ALTER FUNCTION public.checkserialbom(text, text, text, text) OWNER TO admin;

--
-- TOC entry 353 (class 1255 OID 36811)
-- Name: checksummbom(text, text, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION checksummbom(text, text, text, text) RETURNS integer
    LANGUAGE plpgsql
    AS $_$DECLARE

	pParentItemNumber ALIAS FOR $1;

	pParentRevision ALIAS FOR $2;

	pItemNumber ALIAS FOR $3;

	pRevision ALIAS FOR $4;

	_parentitem RECORD;

	_item RECORD;

	_summbom RECORD;

  

BEGIN

	PERFORM (SELECT checkpriv('checksummbom'));



	IF pRevision IS NULL THEN

		pRevision = '%';

	END IF;



	SELECT item_id, item_serialstream_id, serialprefix_prefix, serialpattern_pattern, itemfreqcode_freqcode

	INTO _parentitem

	FROM item 

	LEFT OUTER JOIN serialstream ON item_serialstream_id = serialstream_id

	LEFT OUTER JOIN serialprefix ON item_serialprefix_id = serialprefix_id

	LEFT OUTER JOIN serialpattern ON serialprefix_serialpattern_id = serialpattern_id

	LEFT OUTER JOIN itemfreqcode ON item_itemfreqcode_id = itemfreqcode_id

	WHERE item_number = pParentItemNumber 

	AND item_active = true;



	IF _parentitem.item_id IS NULL THEN

		RAISE EXCEPTION 'checksummbom: Parent Item Number % not found in AeryonMES', pParentItemNumber;

	END IF;



	IF (SELECT itemrev_id

	    FROM itemrev

	    WHERE itemrev_item_id = _parentitem.item_id

	    AND itemrev_rev = pParentRevision) IS NULL THEN

		RAISE EXCEPTION 'checksummbom: Parent Revision % of Selected Parent Item % Not Found in AeryonMES', pParentRevision, pParentItemNumber;

	END IF;



	SELECT item_id, item_serialstream_id, serialprefix_prefix, serialpattern_pattern, itemfreqcode_freqcode

	INTO _item

	FROM item 

	LEFT OUTER JOIN serialstream ON item_serialstream_id = serialstream_id

	LEFT OUTER JOIN serialprefix ON item_serialprefix_id = serialprefix_id

	LEFT OUTER JOIN serialpattern ON serialprefix_serialpattern_id = serialpattern_id

	LEFT OUTER JOIN itemfreqcode ON item_itemfreqcode_id = itemfreqcode_id

	WHERE item_number = pItemNumber 

	AND item_active = true;



	IF _item.item_id IS NULL THEN

		RAISE EXCEPTION 'checksummbom: Item Number % not found in AeryonMES', pItemNumber;

	END IF;



	IF (SELECT itemrev_id

	    FROM itemrev

	    WHERE itemrev_item_id = _item.item_id

	    AND itemrev_rev LIKE pRevision LIMIT 1) IS NULL THEN

		RAISE EXCEPTION 'checksummbom: Revision % of Selected Item % Not Found in AeryonMES', pRevision, pItemNumber;

	END IF;



	SELECT *

	INTO _summbom

	FROM summbom(pParentItemNumber, pParentRevision)

	WHERE c_item_number = pItemNumber

	AND c_bom_itemrev LIKE pRevision;





	IF _summbom.c_item_number IS NULL THEN

		RETURN 0; 

	END IF;

	

	RETURN _summbom.c_bom_qtyper;

END;$_$;


ALTER FUNCTION public.checksummbom(text, text, text, text) OWNER TO admin;

--
-- TOC entry 382 (class 1255 OID 36812)
-- Name: deactivatepart(text, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION deactivatepart(text, text, text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pItemNumber ALIAS FOR $1;

	pRevision ALIAS FOR $2;

	pSerialNumber ALIAS FOR $3;

	_viewpart RECORD;

	_usrId INTEGER;

	_partActiveHistId INTEGER;

	_message TEXT;

  

BEGIN

	_usrID := (SELECT getusrid()); 

	PERFORM (SELECT checkpriv('deactivatepart'));

	PERFORM (SELECT validatepart(pItemNumber, pRevision, pSerialNumber, null, true));



	SELECT 	part_id, 

		item_id, 

		item_number,

		part_active,

		part_rev,

		part_serialnumber, 

		part_sequencenumber,

		part_cust_id,

		loc_number

	INTO _viewpart

	FROM viewpart

	WHERE item_number = pItemNumber 

	AND part_serialnumber = pSerialNumber 

	AND part_rev = pRevision;



	IF _viewpart.part_active IS false THEN

		RETURN true;

	END IF;

	

	UPDATE part SET (part_active) =

			(false)

	WHERE part_id = _viewpart.part_id;



	INSERT INTO partactivehist (	partactivehist_part_id, 

					partactivehist_new_activestate,

					partactivehist_usr_id,

					partactivehist_orig_item_id,

					partactivehist_orig_rev,

					partactivehist_orig_serialnumber)

		VALUES (		_viewpart.part_id, 

					false,

					_usrId,

					_viewpart.item_id,

					_viewpart.part_rev,

					_viewpart.part_serialnumber)

		RETURNING partactivehist_id INTO _partActiveHistId;



	_message := 	pItemNumber || ' ' ||  

			pRevision || ' ' || 

			pSerialNumber || ' made Inactive.';



	PERFORM (SELECT enterpartlog(	'Manufacturing'::TEXT, 

					'Deactivated'::TEXT,

					pItemNumber,

					pRevision,

					pSerialNumber,

					'Active History'::TEXT,

					_partActiveHistId,

					_message));



	RETURN true;

END;$_$;


ALTER FUNCTION public.deactivatepart(text, text, text) OWNER TO admin;

--
-- TOC entry 383 (class 1255 OID 36813)
-- Name: deactivatesummsubass(text, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION deactivatesummsubass(text, text, text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pItemNumber ALIAS FOR $1;

	pRevision ALIAS FOR $2;

	pSerialNumber ALIAS FOR $3;

	_usrId INTEGER;

	_r RECORD;

  

BEGIN

	_usrID := (SELECT getusrid()); 

	PERFORM (SELECT checkpriv('deactivatesummsubass'));

	PERFORM (SELECT validatepart(pItemNumber, pRevision, pSerialNumber, null, true));

	

	PERFORM (SELECT deactivatepart(	pItemNumber,

					pRevision,

					pSerialNumber));

	

	FOR _r IN

		SELECT *

		FROM summsubass(	pItemNumber,

					pRevision,

					pSerialNumber)

	LOOP

		IF _r.c_item_number IS NOT NULL THEN

			PERFORM (SELECT deactivatepart(	_r.c_item_number,

							_r.c_part_rev,

							_r.c_part_serialnumber));

		END IF;

	END LOOP;

		  

	RETURN true;

END;$_$;


ALTER FUNCTION public.deactivatesummsubass(text, text, text) OWNER TO admin;

--
-- TOC entry 384 (class 1255 OID 36814)
-- Name: deallocpart(text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION deallocpart(text, text, text, text DEFAULT NULL::text, text DEFAULT NULL::text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pItemNumber 		ALIAS FOR $1;

	pRevision 		ALIAS FOR $2;

	pSerialNumber 		ALIAS FOR $3;	

	pLine			ALIAS FOR $4;

	pStation		ALIAS FOR $5;

	_parentviewpart 	RECORD;

	_viewpart 		RECORD;

	_allocCheck 		RECORD;

	_locationId 		INTEGER;

	_partStateId 		INTEGER;

	_usrId 			INTEGER;

	_message 		TEXT;

	_partAllocHistId 	INTEGER;

	_stationId		INTEGER;

	_lineId			INTEGER;

BEGIN

	_usrID := (SELECT getusrid()); 

	PERFORM (SELECT checkpriv('deallocpart'));

	PERFORM (SELECT validatepart(pItemNumber, pRevision, pSerialNumber, 'Child', true));

	

	SELECT 	part_id, 

		item_id, 

		item_number, 

		part_rev,

		part_serialnumber, 

		part_sequencenumber,

		part_allocpos,

		parent_part_id,

		parent_item_number,

		parent_part_rev,

		parent_part_serialnumber

	INTO _viewpart

	FROM viewpart

	WHERE item_number = pItemNumber 

	AND part_serialnumber = pSerialNumber 

	AND part_rev = pRevision;



	IF _viewpart.parent_part_id IS NOT NULL THEN

		RETURN deallocpart(_viewpart.parent_item_number, _viewpart.parent_part_rev, _viewpart.parent_part_serialnumber, pItemNumber, pRevision, pSerialNumber, 'AMDD001', pLine, pStation);

	ELSE

		RAISE EXCEPTION 'Parent does not exists for Child Item Number % Revision % Serial Number % and cannot be deallocated.', 

			pItemNumber, 

			pRevision, 

			pSerialNumber;

	END IF;

END;$_$;


ALTER FUNCTION public.deallocpart(text, text, text, text, text) OWNER TO admin;

--
-- TOC entry 386 (class 1255 OID 36815)
-- Name: deallocpart(text, text, text, text, text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION deallocpart(text, text, text, text, text, text, text DEFAULT 'AMDD001'::text, text DEFAULT NULL::text, text DEFAULT NULL::text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pParentItemNumber 	ALIAS FOR $1;

	pParentRevision 	ALIAS FOR $2;

	pParentSerialNumber 	ALIAS FOR $3;

	pItemNumber 		ALIAS FOR $4;

	pRevision 		ALIAS FOR $5;

	pSerialNumber 		ALIAS FOR $6;	

	pDeallocCode 		ALIAS FOR $7;

	pLine			ALIAS FOR $8;

	pStation		ALIAS FOR $9;

	_parentviewpart 	RECORD;

	_viewpart 		RECORD;

	_allocCheck 		RECORD;

	_locationId 		INTEGER;

	_partStateId 		INTEGER;

	_usrId 			INTEGER;

	_message 		TEXT;

	_partAllocHistId 	INTEGER;

	_stationId		INTEGER;

	_lineId			INTEGER;

BEGIN

	_usrID := (SELECT getusrid()); 

	PERFORM (SELECT checkpriv('deallocpart'));

	PERFORM (SELECT validatepart(pItemNumber, pRevision, pSerialNumber, 'Child', true));

	PERFORM (SELECT validatepart(pParentItemNumber, pParentRevision, pParentSerialNumber, 'Parent', true));



	IF pStation IS NULL THEN

		_stationId := null;

	ELSE

		_stationId := (SELECT getstationid(pStation));

	END IF;



	IF pLine IS NULL THEN

		_lineId := null;

	ELSE

		_lineId := (SELECT getstationid(pStation));

	END IF;

	

	SELECT 	part_id, 

		item_id, 

		item_number, 

		part_rev,

		part_serialnumber, 

		part_sequencenumber,

		part_allocpos,

		parent_part_id,

		parent_item_number,

		parent_part_rev,

		parent_part_serialnumber

	INTO _viewpart

	FROM viewpart

	WHERE item_number = pItemNumber 

	AND part_serialnumber = pSerialNumber 

	AND part_rev = pRevision;



	SELECT 	part_id, 

		item_id, 

		item_number, 

		part_rev,

		part_serialnumber, 

		part_sequencenumber

		parent_part_id

	INTO _parentviewpart

	FROM viewpart

	WHERE item_number = pParentItemNumber 

	AND part_serialnumber = pParentSerialNumber 

	AND part_rev = pParentRevision;



	IF _viewpart.parent_part_id != _parentviewpart.part_id THEN

		RAISE EXCEPTION 'Child Item Number % Revision % Serial Number % is not allocated to Parent Item Number % Revision % Serial Number % and cannot be deallocated.', 

			pItemNumber, 

			pRevision, 

			pSerialNumber,

			pParentItemNumber,

			pParentRevision,

			pParentSerialNumber;

	END IF;



	UPDATE 	part

	SET 	(part_parent_part_id,

		 part_allocpos) =

		(null,

		 null)

	WHERE part_id = _viewpart.part_id;



	INSERT INTO partallochist

		(partallochist_parent_part_id,

		 partallochist_child_part_id,

		 partallochist_allocpos,

		 partallochist_alloctype,

		 partallochist_alloccode,

		 partallochist_usr_id,

		 partallochist_parent_orig_item_id,

		 partallochist_parent_orig_rev,

		 partallochist_parent_orig_serialnumber,

		 partallochist_child_orig_item_id,

		 partallochist_child_orig_rev,

		 partallochist_child_orig_serialnumber,

		 partallochist_line_id,

		 partallochist_station_id)

	VALUES	(_parentviewpart.part_id,

		 _viewpart.part_id,

		 _viewpart.part_allocpos,

		 'd',

		 pDeallocCode,

		 _usrId,

		 _parentviewpart.item_id,

		 _parentviewpart.part_rev,

		 _parentviewpart.part_serialnumber,

		 _viewpart.item_id,

		 _viewpart.part_rev,

		 _viewpart.part_serialnumber,

		 _lineId,

		 _stationId)

	RETURNING partallochist_id INTO _partAllocHistId;



	_message := 	pItemNumber || ' ' || 

			pRevision || ' ' || 

			pSerialNumber || ' deallocated from ' || 

			pParentItemNumber || ' ' || 

			pParentRevision || ' ' || 

			pParentSerialNumber || ' with deallocation code ' ||

			pDeallocCode || '.';



	PERFORM (SELECT enterpartlog(	'Manufacturing'::TEXT, 

					'Deallocated'::TEXT,

					pParentItemNumber,

					pParentRevision,

					pParentSerialNumber,

					'Allocation History'::TEXT,

					_partAllocHistId,

					_message,

					null,

					null,

					pLine,

					pStation));



	PERFORM (SELECT enterpartlog(	'Manufacturing'::TEXT, 

					'Deallocated'::TEXT,

					pItemNumber,

					pRevision,

					pSerialNumber,

					'Allocation History'::TEXT,

					_partAllocHistId,

					_message,

					null,

					null,

					pLine,

					pStation));

	

	RETURN true;

END;$_$;


ALTER FUNCTION public.deallocpart(text, text, text, text, text, text, text, text, text) OWNER TO admin;

--
-- TOC entry 387 (class 1255 OID 36816)
-- Name: enterbackflush(text, text, text, integer, text, text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION enterbackflush(text, text, text, integer, text, text, text, text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pItemNumber 	ALIAS FOR $1;

	pRevision 	ALIAS FOR $2;

	pSerialNumber 	ALIAS FOR $3;

	pQty 		ALIAS FOR $4;

	pDocType 	ALIAS FOR $5;

	pDocNumber 	ALIAS FOR $6;

	pLine		ALIAS FOR $7;

	pStation	ALIAS FOR $8;

	_itemId		INTEGER;

	_viewpart 	RECORD;

	_docTypeId	INTEGER;

	_usrId 		INTEGER;

	_backflushId 	INTEGER;

	_message 	TEXT;

	_stationId	INTEGER;

	_lineId		INTEGER;

  

BEGIN

	_usrId := (SELECT getusrid()); 

	PERFORM (SELECT checkpriv('enterbackflush'));



	IF pQty <= 0 THEN

		RAISE EXCEPTION 'enterbackflush: Backflush Qty cannot be equal to or less than 0.';

	END IF;



	_itemId := (SELECT getitemid(pItemNumber));

	_docTypeId := (SELECT getdoctypeid(pDocType));

	_lineId := (SELECT getlineid(pLine));

	_stationId := (SELECT getstationid(pStation));

	

	IF pSerialNumber IS NOT NULL THEN

		PERFORM (SELECT validatepart(pItemNumber, pRevision, pSerialNumber));

		pQty := 1;

	END IF;

	

	SELECT 	part_id, 

		item_id, 

		item_number, 

		part_serialnumber, 

		part_sequencenumber

	INTO _viewpart

	FROM viewpart

	WHERE item_number = pItemNumber 

	AND part_serialnumber = pSerialNumber 

	AND part_rev = pRevision;



	IF 	pSerialNumber IS NOT NULL 

		AND 	(SELECT backflush_id

			FROM backflush

			WHERE backflush_void_timestamp IS NULL

			AND backflush_part_id = _viewpart.part_id) IS NOT NULL THEN

		RAISE EXCEPTION 'enterbackflush: Serialized part % % % has already been backflushed.',

			pItemNumber,

			pRevision,

			pSerialNumber;

	END IF;

	

	INSERT INTO backflush

		(backflush_orig_item_id,

		 backflush_orig_rev,

		 backflush_orig_serialnumber,

		 backflush_part_id,

		 backflush_qty,

		 backflush_doctype_id,

		 backflush_docnumber,

		 backflush_create_usr_id,

		 backflush_line_id,

		 backflush_station_id)

	VALUES	(_itemId,

		 pRevision,

		 pSerialNumber,

		 _viewpart.part_id,

		 pQty,

		 _docTypeId,

		 pDocNumber,

		 _usrId,

		 _lineId,

		 _stationId)

	RETURNING backflush_id INTO _backflushId;



	UPDATE part

	SET (part_backflushed) = (true)

	WHERE part_id = _viewpart.part_id;

	

	_message := 	pItemNumber || ' ' || 

			pRevision || ' ' || 

			pSerialNumber || ' qty ' || 

			pQty || ' entered for backflush on ' || 

			pDocType || ' ' || 

			pDocNumber || '.';



	PERFORM (SELECT enterpartlog(	'Manufacturing'::TEXT, 

					'Enter Backflush'::TEXT,

					pItemNumber,

					pRevision,

					pSerialNumber,

					'Backflush ID'::TEXT,

					_backflushId,

					_message,

					pDocType,

					pDocNumber,

					pLine,

					pStation

					));



	RETURN true;

END;$_$;


ALTER FUNCTION public.enterbackflush(text, text, text, integer, text, text, text, text) OWNER TO postgres;

--
-- TOC entry 388 (class 1255 OID 36817)
-- Name: enterpart(text, text, text, text, text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION enterpart(text, text, text, text, text, text, text, text DEFAULT NULL::text, text DEFAULT NULL::text) RETURNS TABLE(_partnumber text, _revision text, _serialnumber text, _sequencenumber integer, _itemfreqcode text)
    LANGUAGE plpgsql
    AS $_$DECLARE

	pItemNumber ALIAS FOR $1;

	pRevision ALIAS FOR $2;

	pSerialNumber ALIAS FOR $3;

	pDocNumber ALIAS FOR $4;

	pDocType ALIAS FOR $5;

	pLocation ALIAS FOR $6;

	pPartState ALIAS FOR $7;

	pLine ALIAS FOR $8;

	pStation ALIAS FOR $9;

	_viewpart RECORD;

	_item RECORD;

	_docTypeId INTEGER;

	_locationId INTEGER;

	_partStateId INTEGER;

	_prefix TEXT;

	_serialPattern TEXT;

	_r RECORD;

	_partId INTEGER;

	_message TEXT;

	_usrId	INTEGER;

	_partActiveHistId INTEGER;

  

BEGIN

	PERFORM (SELECT checkpriv('enterpart'));

	_usrId := (SELECT getusrid());



	IF ((pSerialNumber = '') OR (pSerialNumber IS NULL)) THEN

		RAISE EXCEPTION 'enterpart: Serial Number cannot be blank or null.';

	END IF;



	SELECT item_number, part_rev

	INTO _viewpart

	FROM viewpart

	WHERE item_number = pItemNumber AND part_serialNumber = pSerialNumber;



	IF _viewpart.item_number IS NOT NULL THEN

		RAISE EXCEPTION 'enterpart: Item Number % and Serial Number % already exists in AeryonMES at Revision %', pItemNumber, pSerialNumber, _viewpart.part_rev;

	END IF;

	

	SELECT item_id, item_serialstream_id, serialprefix_prefix, serialpattern_pattern, itemfreqcode_freqcode

	INTO _item

	FROM item 

	LEFT OUTER JOIN serialstream ON item_serialstream_id = serialstream_id

	LEFT OUTER JOIN serialprefix ON item_serialprefix_id = serialprefix_id

	LEFT OUTER JOIN serialpattern ON serialprefix_serialpattern_id = serialpattern_id

	LEFT OUTER JOIN itemfreqcode ON item_itemfreqcode_id = itemfreqcode_id

	WHERE item_number = pItemNumber 

	AND item_active = true;



	IF _item.item_id IS NULL THEN

		RAISE EXCEPTION 'enterpart: Item Number % Not Found in AeryonMES', pItemNumber;

	END IF;



	IF (SELECT itemrev_id

	    FROM itemrev

	    WHERE itemrev_item_id = _item.item_id

	    AND itemrev_rev = pRevision) IS NULL THEN

		RAISE EXCEPTION 'enterpart: Revision % of Selected Item % Not Found in AeryonMES', pRevision, pItemNumber;

	END IF;



	_docTypeId := (SELECT getdoctypeid(pDocType));

	_locationId := (SELECT getlocid(pLocation));

	_partStateId := (SELECT getpartstateid(pPartState));



	IF _item.item_serialstream_id IS NULL THEN

		_sequenceNumber := (SELECT MAX(part_sequencenumber) + 1

			FROM part

			WHERE part_item_id = _item.item_id);

	ELSE

		_sequenceNumber := (SELECT MAX(part_sequencenumber) + 1

			FROM part

			WHERE part_item_id IN (SELECT item_id FROM item WHERE item_serialstream_id = _item.item_serialstream_id));	

	END IF;



	IF _sequenceNumber IS NULL THEN

		_sequenceNumber := 1;

	END IF;

	

	_serialNumber := pSerialNumber;



	INSERT INTO part (part_item_id,

			  part_rev,

			  part_sequencenumber,

			  part_serialnumber,

			  part_loc_id,

			  part_create_doctype_id,

			  part_create_docnumber,

			  part_partstate_id)

		VALUES	 (_item.item_id,

			  pRevision,

			  _sequenceNumber,

			  _serialNumber,

			  _locationId,

			  _docTypeId,

			  pDocNumber,

			  _partStateId)

		RETURNING part_id INTO _partId;



	_message := 	pItemNumber || ' ' || 

			pRevision || ' ' || 

			pSerialNumber || ' entered into location ' ||

			pLocation || ' with part state ' ||

			pPartState || ' on ' ||

			pDocType || ' ' ||

			pDocNumber || '.';



	PERFORM (SELECT enterpartlog(	'Manufacturing'::TEXT, 

					'Entered'::TEXT,

					pItemNumber,

					pRevision,

					pSerialNumber,

					'Part Record'::TEXT,

					_partId,

					_message,

					pDocType,

					pDocNumber,

					pLine,

					pStation));



	INSERT INTO partactivehist (	partactivehist_part_id, 

					partactivehist_new_activestate,

					partactivehist_usr_id,

					partactivehist_orig_item_id,

					partactivehist_orig_rev,

					partactivehist_orig_serialnumber)

		VALUES (		_partId, 

					true,

					_usrId,

					_item.item_id,

					pRevision,

					_serialNumber

					)

		RETURNING partactivehist_id INTO _partActiveHistId;



	_message := 	pItemNumber || ' ' ||  

			pRevision || ' ' || 

			_serialNumber || ' made Active.';



	PERFORM (SELECT enterpartlog(	'Manufacturing'::TEXT, 

					'Activated'::TEXT,

					pItemNumber,

					pRevision,

					_serialNumber,

					'Active History'::TEXT,

					_partActiveHistId,

					_message,

					pDocType,

					pDocNumber,

					pLine,

					pStation));

		  

	_partnumber := pItemNumber;

	_revision := pRevision;

	_itemfreqcode := _item.itemfreqcode_freqcode;

	RETURN NEXT;

	RETURN;

END;$_$;


ALTER FUNCTION public.enterpart(text, text, text, text, text, text, text, text, text) OWNER TO postgres;

--
-- TOC entry 389 (class 1255 OID 36818)
-- Name: enterpartlog(text, text, text, text, text, text, integer, text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION enterpartlog(text, text, text, text, text, text, integer, text, text DEFAULT NULL::text, text DEFAULT NULL::text, text DEFAULT NULL::text, text DEFAULT NULL::text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pModule 	ALIAS FOR $1;

	pAction 	ALIAS FOR $2;

	pItemNumber 	ALIAS FOR $3;

	pRevision 	ALIAS FOR $4;

	pSerialNumber 	ALIAS FOR $5;

	pRecordType 	ALIAS FOR $6;

	pRecordId 	ALIAS FOR $7;

	pMessage	ALIAS FOR $8;

	pDocType	ALIAS FOR $9;

	pDocNumber	ALIAS FOR $10;

	pLine		ALIAS FOR $11;

	pStation	ALIAS FOR $12;

	_viewpart	RECORD;

	_moduleId	INTEGER;

	_actionId	INTEGER;

	_usrId		INTEGER;

	_recordTypeId	INTEGER;

	_docTypeId	INTEGER;

	_stationId	INTEGER;

	_lineID		INTEGER;



BEGIN

	PERFORM (SELECT checkpriv('enterpartlog'));

	PERFORM (SELECT validatepart(pItemNumber, pRevision, pSerialNumber, null, true));



	SELECT 	part_id, 

		item_id, 

		item_number, 

		part_serialnumber, 

		part_sequencenumber,

		parent_part_id,

		parent_item_number,

		parent_part_rev,

		parent_part_serialnumber

	INTO _viewpart

	FROM viewpart

	WHERE item_number = pItemNumber 

	AND part_serialnumber = pSerialNumber 

	AND part_rev = pRevision;



	_moduleId := (SELECT getmoduleid(pModule));

	_actionId := (SELECT getpartlogactionid(pAction));

	_usrId := (SELECT getusrid());

	_recordTypeId := (SELECT getrecordtypeid(pRecordType));



	IF pDocType IS NOT NULL THEN

		_docTypeId := (SELECT getdoctypeid(pDocType));

	ELSIF pDocType IS NULL AND pDocNumber IS NOT NULL THEN

		RAISE EXCEPTION 'enterpartlog: DocType is null, but DocNumber is not null. Log could not be submitted.';

	ELSE

		_docTypeId := null;

	END IF;



	IF pStation IS NULL THEN

		_stationId := null;

	ELSE

		_stationId := (SELECT getstationid(pStation));

	END IF;



	IF pLine IS NULL THEN

		_lineId := null;

	ELSE

		_lineId := (SELECT getstationid(pStation));

	END IF;

	

	INSERT INTO partlog (	partlog_module_id,

				partlog_partlogaction_id,

				partlog_part_id,

				partlog_recordtype_id,

				partlog_record_id,

				partlog_doctype_id,

				partlog_docnumber,

				partlog_message,

				partlog_usr_id,

				partlog_orig_item_id,

				partlog_orig_rev,

				partlog_orig_serialnumber,

				partlog_line_id,

				partlog_station_id

				)

		VALUES (	_moduleId,

				_actionId,

				_viewpart.part_id,

				_recordTypeId,

				pRecordId,

				_docTypeId,

				pDocNumber,

				pMessage,

				_usrId,

				_viewpart.item_id,

				pRevision,

				pSerialNumber,

				_lineId,

				_stationId

				);

	

	RETURN true;

END;

$_$;


ALTER FUNCTION public.enterpartlog(text, text, text, text, text, text, integer, text, text, text, text, text) OWNER TO postgres;

--
-- TOC entry 376 (class 1255 OID 36819)
-- Name: enterrecordlog(text, text, text, integer, text, integer, text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION enterrecordlog(text, text, text, integer, text, integer, text, text DEFAULT NULL::text, text DEFAULT NULL::text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pModule 		ALIAS FOR $1;

	pAction 		ALIAS FOR $2;

	pRecordType 		ALIAS FOR $3;

	pRecordId 		ALIAS FOR $4;

	pSecRecordType		ALIAS FOR $5;

	pSecRecordId		ALIAS FOR $6;

	pMessage		ALIAS FOR $7;

	pDocType		ALIAS FOR $8;

	pDocNumber		ALIAS FOR $9;

	_moduleId		INTEGER;

	_actionId		INTEGER;

	_usrId			INTEGER;

	_recordTypeId		INTEGER;

	_secRecordTypeId	INTEGER;

	_docTypeId		INTEGER;



BEGIN

	PERFORM (SELECT checkpriv('enterrecordlog'));



	_moduleId := (SELECT getmoduleid(pModule));

	_actionId := (SELECT getrecordlogactionid(pAction));

	_usrId := (SELECT getusrid());

	_recordTypeId := (SELECT getrecordtypeid(pRecordType));

	_secRecordTypeId := (SELECT getrecordtypeid(pSecRecordType, true));



	IF _secRecordTypeId IS NULL THEN

		pSecRecordId := null;

	END IF;

	

	IF pDocType IS NOT NULL THEN

		_docTypeId := (SELECT getdoctypeid(pDocType));

	ELSIF pDocType IS NULL AND pDocNumber IS NOT NULL THEN

		RAISE EXCEPTION 'enterrecordlog: DocType is null, but DocNumber is not null. Log could not be submitted.';

	ELSE

		_docTypeId := null;

	END IF;



	INSERT INTO recordlog (	recordlog_module_id,

				recordlog_recordlogaction_id,

				recordlog_recordtype_id,

				recordlog_record_id,

				recordlog_doctype_id,

				recordlog_docnumber,

				recordlog_message,

				recordlog_usr_id,

				recordlog_secondary_recordtype_id,

				recordlog_secondary_record_id

				)

		VALUES (	_moduleId,

				_actionId,

				_recordTypeId,

				pRecordId,

				_docTypeId,

				pDocNumber,

				pMessage,

				_usrId,

				_secRecordTypeId,

				pSecRecordId

				);

	

	RETURN true;

END;

$_$;


ALTER FUNCTION public.enterrecordlog(text, text, text, integer, text, integer, text, text, text) OWNER TO postgres;

--
-- TOC entry 390 (class 1255 OID 36820)
-- Name: generatepart(text, text, text, text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION generatepart(text, text, text, text, text, text, text DEFAULT NULL::text, text DEFAULT NULL::text) RETURNS TABLE(_partnumber text, _revision text, _serialnumber text, _sequencenumber integer, _itemfreqcode text)
    LANGUAGE plpgsql
    AS $_$DECLARE

	pItemNumber ALIAS FOR $1;

	pRevision ALIAS FOR $2;

	pDocNumber ALIAS FOR $3;

	pDocType ALIAS FOR $4;

	pLocation ALIAS FOR $5;

	pPartState ALIAS FOR $6;

	pLine	ALIAS FOR $7;

	pStation ALIAS FOR $8;

	_item RECORD;

	_docTypeId INTEGER;

	_locationId INTEGER;

	_partStateId INTEGER;

	_prefix TEXT;

	_serialPattern TEXT;

	_r RECORD;

	_message TEXT;

	_partId INTEGER;

	_usrId	INTEGER;

	_partActiveHistId	INTEGER;

  

BEGIN

	PERFORM (SELECT checkpriv('generatepart'));	

	_usrId := (SELECT getusrid());

	

	SELECT item_id, item_serialstream_id, serialprefix_prefix, serialpattern_pattern, itemfreqcode_freqcode

	INTO _item

	FROM item 

	LEFT OUTER JOIN serialstream ON item_serialstream_id = serialstream_id

	LEFT OUTER JOIN serialprefix ON item_serialprefix_id = serialprefix_id

	LEFT OUTER JOIN serialpattern ON serialprefix_serialpattern_id = serialpattern_id

	LEFT OUTER JOIN itemfreqcode ON item_itemfreqcode_id = itemfreqcode_id

	WHERE item_number = pItemNumber 

	AND item_active = true;



	IF _item.item_id IS NULL THEN

		RAISE EXCEPTION 'generatepart: Item Number % Not Found in AeryonMES', pItemNumber;

	END IF;



	IF (SELECT itemrev_id

	    FROM itemrev

	    WHERE itemrev_item_id = _item.item_id

	    AND itemrev_rev = pRevision) IS NULL THEN

		RAISE EXCEPTION 'generatepart: Revision % of Selected Item % Not Found in AeryonMES', pRevision, pItemNumber;

	END IF;



	_docTypeId := (SELECT getdoctypeid(pDocType));

	_locationId := (SELECT getlocid(pLocation));

	_partStateId := (SELECT getpartstateid(pPartState));



	_prefix := COALESCE(_item.serialprefix_prefix, 'SN');

	_serialPattern := COALESCE(_item.serialpattern_pattern, 'XXXXXX');



	IF _item.item_serialstream_id IS NULL THEN

		_sequencenumber := (	SELECT MAX(part_sequencenumber) + 1

					FROM part

					WHERE part_item_id = _item.item_id);

	ELSE

		_sequencenumber := (	SELECT MAX(part_sequencenumber) + 1

					FROM part

					WHERE part_item_id IN (SELECT item_id FROM item WHERE item_serialstream_id = _item.item_serialstream_id));	

	END IF;



	IF _sequencenumber IS NULL THEN

		_sequencenumber := 1;

	END IF;

	

	_serialnumber := (SELECT generateserial(_prefix, _sequenceNumber, _serialPattern));



	INSERT INTO part (part_item_id,

			  part_rev,

			  part_sequencenumber,

			  part_serialnumber,

			  part_loc_id,

			  part_create_doctype_id,

			  part_create_docnumber,

			  part_partstate_id)

		VALUES	 (_item.item_id,

			  pRevision,

			  _sequenceNumber,

			  _serialNumber,

			  _locationId,

			  _docTypeId,

			  pDocNumber,

			  _partStateId)

		RETURNING part_id INTO _partId;



	_message := 	pItemNumber || ' ' || 

			pRevision || ' ' || 

			_serialnumber || ' generated into location ' ||

			pLocation || ' with part state ' ||

			pPartState || ' on ' ||

			pDocType || ' ' ||

			pDocNumber || '.';



	PERFORM (SELECT enterpartlog(	'Manufacturing'::TEXT, 

					'Generated'::TEXT,

					pItemNumber,

					pRevision,

					_serialnumber,

					'Part Record'::TEXT,

					_partId,

					_message,

					pDocType,

					pDocNumber,

					pLine,

					pStation));



	INSERT INTO partactivehist (	partactivehist_part_id, 

					partactivehist_new_activestate,

					partactivehist_usr_id,

					partactivehist_orig_item_id,

					partactivehist_orig_rev,

					partactivehist_orig_serialnumber)

		VALUES (		_partId, 

					true,

					_usrId,

					_item.item_id,

					pRevision,

					_serialNumber

					)

		RETURNING partactivehist_id INTO _partActiveHistId;



	_message := 	pItemNumber || ' ' ||  

			pRevision || ' ' || 

			_serialnumber || ' made Active.';



	PERFORM (SELECT enterpartlog(	'Manufacturing'::TEXT, 

					'Activated'::TEXT,

					pItemNumber,

					pRevision,

					_serialnumber,

					'Active History'::TEXT,

					_partActiveHistId,

					_message,

					pDocType,

					pDocNumber,

					pLine,

					pStation));

		  

	_partnumber := pItemNumber;

	_revision := pRevision;

	_itemfreqcode := _item.itemfreqcode_freqcode;

	RETURN NEXT;

	RETURN;

END;$_$;


ALTER FUNCTION public.generatepart(text, text, text, text, text, text, text, text) OWNER TO admin;

--
-- TOC entry 391 (class 1255 OID 36821)
-- Name: generateparts(text, text, text, text, text, text, integer, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION generateparts(text, text, text, text, text, text, integer, text DEFAULT NULL::text, text DEFAULT NULL::text) RETURNS TABLE(_partnumber text, _revision text, _serialnumber text, _sequencenumber integer, _itemfreqcode text)
    LANGUAGE plpgsql
    AS $_$DECLARE

	pItemNumber ALIAS FOR $1;

	pRevision ALIAS FOR $2;

	pDocNumber ALIAS FOR $3;

	pDocType ALIAS FOR $4;

	pLocation ALIAS FOR $5;

	pPartState ALIAS FOR $6;

	pQty ALIAS FOR $7;

	pLine ALIAS FOR $8;

	pStation ALIAS FOR $9;

	i INTEGER;

  

BEGIN

	PERFORM (SELECT checkpriv('generateparts'));

	

	FOR i IN 1..pQty LOOP

		RETURN QUERY (SELECT * FROM generatepart(pItemNumber, pRevision, pDocNumber, pDocType, pLocation, pPartState, pLine, pStation));

	END LOOP;

	

	RETURN;

END;$_$;


ALTER FUNCTION public.generateparts(text, text, text, text, text, text, integer, text, text) OWNER TO admin;

--
-- TOC entry 392 (class 1255 OID 36822)
-- Name: generateserial(text, integer, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION generateserial(text, integer, text) RETURNS text
    LANGUAGE plpgsql
    AS $_$DECLARE

	pPrefix ALIAS FOR $1;

	pSequenceNumber ALIAS FOR $2;

	pSerialPattern ALIAS FOR $3;

	_serialNumber TEXT;

	_serialPatternArray TEXT[];

	_sequenceLength INTEGER;

	_sequenceNumberPadded TEXT;

	_p TEXT;

	_i INTEGER;

	_c INTEGER;

	  

BEGIN

	PERFORM (SELECT checkpriv('generateserial'));

	

	SELECT string_to_array(pSerialPattern, '-') INTO _serialPatternArray;



	_serialNumber := pPrefix;

	

	_sequenceLength := (SELECT length(pSerialPattern) - length(regexp_replace(pSerialPattern, 'X', '', 'g')));

	_sequenceNumberPadded := (SELECT lpad(pSequenceNumber::TEXT, _sequenceLength, '0'));

	

	_c = 1;



	FOREACH _p IN ARRAY _serialPatternArray

	LOOP

		CASE 	WHEN _p LIKE 'Y%' THEN

				FOR _i IN 1..(SELECT length(_p)) 

				LOOP

					_serialNumber := _serialNumber || (SELECT FLOOR(RANDOM() * 10));

				END LOOP;

			WHEN _p LIKE 'X%' THEN

				_serialNumber := _serialNumber || (SELECT substr(_sequenceNumberPadded, _c, (SELECT length(_p))));

				_c := _c + length(_p);	

			ELSE

				_serialNumber := _serialNumber;

		END CASE;

	END LOOP;



	return _serialNumber;

END;$_$;


ALTER FUNCTION public.generateserial(text, integer, text) OWNER TO admin;

--
-- TOC entry 393 (class 1255 OID 36823)
-- Name: getcustfiletypeid(text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION getcustfiletypeid(text) RETURNS integer
    LANGUAGE plpgsql
    AS $_$DECLARE

	pcustFileType 	ALIAS FOR $1;

	_custFileTypeId 	INTEGER;

BEGIN

	PERFORM (SELECT checkpriv('getcustfiletypeid'));



	IF pcustFileType IS NULL THEN

		RETURN null;

	END IF;



	SELECT custfiletype_id

	INTO _custFileTypeId

	FROM custfiletype

	WHERE custfiletype_name = pcustFileType;



	IF _custFileTypeId IS NULL THEN

		RAISE EXCEPTION 'getcustfiletypeid: file Type % not found.', 

			pcustFileType;

	END IF;



	RETURN _custFileTypeId;

END;

$_$;


ALTER FUNCTION public.getcustfiletypeid(text) OWNER TO admin;

--
-- TOC entry 394 (class 1255 OID 36824)
-- Name: getcustid(text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION getcustid(text) RETURNS integer
    LANGUAGE plpgsql
    AS $_$

DECLARE

	pCust 	ALIAS FOR $1;

	_custId 	INTEGER;

BEGIN

	PERFORM (SELECT checkpriv('getcustid'));



	SELECT cust_id

	INTO _custId

	FROM cust

	WHERE cust_number = pCust;



	IF _custId IS NULL THEN

		RAISE EXCEPTION 'getcustid: Customer % Not Found in AeryonMES', 

			pCust;

	END IF;



	RETURN _custId;

END;

$_$;


ALTER FUNCTION public.getcustid(text) OWNER TO admin;

--
-- TOC entry 385 (class 1255 OID 36825)
-- Name: getcustparamid(text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION getcustparamid(text, text) RETURNS integer
    LANGUAGE plpgsql
    AS $_$DECLARE

	pType 			ALIAS FOR $1;

	pParam			ALIAS FOR $2;

	_custParam		RECORD;

BEGIN

	PERFORM (SELECT checkpriv('getcustparamid'));



	IF pParam IS NULL THEN

		RAISE EXCEPTION 'getcustparamid: Custom Parameter Name cannot be null.';

	END IF;



	IF pType != 'r' AND pType != 'p' THEN

		RAISE EXCEPTION 'getcustparamid: Custom Parameter Type must be r or p.';

	END IF;



	SELECT 	custparam_id

	INTO _custParam

	FROM custparam

	WHERE custparam_param = pParam

	AND custparam_type = pType

	AND custparam_void_timestamp IS NULL;



	IF _custParam.custparam_id IS NULL THEN

		RAISE EXCEPTION 'getcustparamid: Custom Parameter % of Type % not found or is inactive', 

			pParam,

			pType;

	END IF;



	RETURN _custParam.custparam_id;

END;

$_$;


ALTER FUNCTION public.getcustparamid(text, text) OWNER TO admin;

--
-- TOC entry 354 (class 1255 OID 36826)
-- Name: getcustparamvaluepart(text, text, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION getcustparamvaluepart(text, text, text, text) RETURNS text
    LANGUAGE plpgsql
    AS $_$DECLARE

	pParam	 		ALIAS FOR $1;

	pItemNumber		ALIAS FOR $2;

	pRevision		ALIAS FOR $3;

	pSerialNumber		ALIAS FOR $4;

	_custParamValue		TEXT;

	_partId 		INTEGER;

	_custParamId		INTEGER;

  

BEGIN

	PERFORM (SELECT getusrid());

	PERFORM (SELECT checkpriv('getcustparamvaluepart'));



	_custParamId := (SELECT getcustparamid('p', pParam));

		

	_partId = (SELECT getpartid(pItemNumber, pRevision, pSerialNumber));



	_custParamValue := (	SELECT 	partcustparamvalue_value

				FROM viewpartcustparamvalue

				WHERE custparam_id = _custParamId

				AND part_id = _partId

				AND partcustparamvalue_void_timestamp IS NULL

				ORDER BY partcustparamvalue_submit_timestamp DESC

				LIMIT 1);



	RETURN _custParamValue;

END;$_$;


ALTER FUNCTION public.getcustparamvaluepart(text, text, text, text) OWNER TO admin;

--
-- TOC entry 395 (class 1255 OID 36827)
-- Name: getcustparamvaluerecord(text, text, integer); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION getcustparamvaluerecord(text, text, integer) RETURNS text
    LANGUAGE plpgsql
    AS $_$DECLARE

	pParam	 		ALIAS FOR $1;

	pRecordType		ALIAS FOR $2;

	pRecordId		ALIAS FOR $3;

	_custParamValue		TEXT;

	_recordTypeId 		INTEGER;

	_custParamId		INTEGER;

  

BEGIN

	PERFORM (SELECT getusrid());

	PERFORM (SELECT checkpriv('getcustparamvaluerecord'));



	IF pRecordId IS NULL THEN

		RAISE EXCEPTION 'getcustparamvaluerecord: Record ID cannot be null.';

	END IF;	



	_custParamId := (SELECT getcustparamid('r', pParam));

		

	_recordTypeId := (SELECT getrecordtypeid(pRecordType));



	_custParamValue := (	SELECT 	recordcustparamvalue_value

				FROM viewrecordcustparamvalue

				WHERE custparam_id = _custParamId

				AND recordtype_id = _recordTypeId

				AND recordcustparamvalue_record_id = pRecordId

				AND recordcustparamvalue_void_timestamp IS NULL

				ORDER BY recordcustparamvalue_submit_timestamp DESC

				LIMIT 1);



	RETURN _custParamValue;

END;$_$;


ALTER FUNCTION public.getcustparamvaluerecord(text, text, integer) OWNER TO admin;

--
-- TOC entry 396 (class 1255 OID 36828)
-- Name: getdatatypeid(text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION getdatatypeid(text) RETURNS integer
    LANGUAGE plpgsql
    AS $_$DECLARE

	pDataType 		ALIAS FOR $1;

	_dataType		RECORD;

BEGIN

	PERFORM (SELECT checkpriv('getdatatypeid'));



	SELECT 	datatype_id,

		datatype_active

	INTO _dataType

	FROM datatype

	WHERE datatype_type = lower(pDataType);



	IF _dataType.datatype_id IS NULL THEN

		RAISE EXCEPTION 'getdatatypeid: Data Type % Not Found in AeryonMES', 

			pDataType;

	ELSIF _dataType.datatype_active = false THEN

		RAISE EXCEPTION 'getdatatypeid: Data Type % is inactive', 

			pDataType;

	END IF;



	RETURN _dataType.datatype_id;

END;

$_$;


ALTER FUNCTION public.getdatatypeid(text) OWNER TO admin;

--
-- TOC entry 397 (class 1255 OID 36829)
-- Name: getdoctypeid(text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION getdoctypeid(text) RETURNS integer
    LANGUAGE plpgsql
    AS $_$

DECLARE

	pDocType 	ALIAS FOR $1;

	_docTypeId 	INTEGER;

BEGIN

	PERFORM (SELECT checkpriv('getdoctypeid'));



	SELECT doctype_id

	INTO _docTypeId

	FROM doctype

	WHERE doctype_name = pDocType;



	IF _docTypeId IS NULL THEN

		RAISE EXCEPTION 'getdoctypeid:  Doc Type % Not Found in AeryonMES', 

			pDocType;

	END IF;



	RETURN _docTypeId;

END;

$_$;


ALTER FUNCTION public.getdoctypeid(text) OWNER TO admin;

--
-- TOC entry 398 (class 1255 OID 36830)
-- Name: getfilepart(text, text, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION getfilepart(text, text, text, text) RETURNS text
    LANGUAGE plpgsql
    AS $_$

DECLARE

  pItemNumber ALIAS FOR $1;

  pRevision ALIAS FOR $2;

  pSerialNumber ALIAS FOR $3;

  pFileName ALIAS FOR $4;

  _partId	INTEGER;

  _partFile RECORD;

  _hexData TEXT;

  

BEGIN

	PERFORM (SELECT getusrid());

	PERFORM (SELECT checkpriv('getfilepart'));

		

	_partId := (SELECT getpartid(pItemNumber, pRevision, pSerialNumber));



	SELECT 	partfile_id,

		partfile_partfiledata_id

	INTO _partFile

	FROM partfile

	WHERE partfile_filename = pFileName

	AND partfile_part_id = _partId

	AND partfile_void_timestamp IS NULL;



	IF _partFile.partfile_id IS NULL THEN

		RAISE EXCEPTION 'getfilepart: File with Name % does not exist for Item Number % Revision % Serial Number %.', 

			pFileName,

			pItemNumber,

			pRevision,

			pSerialNumber;

	END IF;



	SELECT encode(partfiledata_data, $$hex$$)

	INTO _hexData

	FROM partfiledata

	WHERE partfiledata_id = _partFile.partfile_partfiledata_id;



	RETURN _hexData;

END$_$;


ALTER FUNCTION public.getfilepart(text, text, text, text) OWNER TO admin;

--
-- TOC entry 399 (class 1255 OID 36831)
-- Name: getfilerecord(text, integer, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION getfilerecord(text, integer, text) RETURNS text
    LANGUAGE plpgsql
    AS $_$

DECLARE

  pRecordType ALIAS FOR $1;

  pRecordId ALIAS FOR $2;

  pFileName ALIAS FOR $3;

  _recordTypeId	INTEGER;

    _recordFile RECORD;

  _hexData	TEXT;



  

BEGIN

	PERFORM (SELECT getusrid());

	PERFORM (SELECT checkpriv('getfilerecord'));

		

	_recordTypeId := (SELECT getrecordtypeid(pRecordType));

	

	SELECT recordfile_id,

		recordfile_recordfiledata_id

	INTO _recordFile

	FROM recordfile

	WHERE recordfile_filename = pFileName

	AND recordfile_recordtype_id = _recordTypeId

	AND recordfile_record_id = pRecordId

	AND recordfile_void_timestamp IS NULL;



	IF _recordFile.recordfile_id IS NULL THEN

		RAISE EXCEPTION 'getfilerecord: File with Name % and File Type % does not exist for Record Type % with ID %.', 

			pFileName,

			pFileType,

			pRecordType,

			pRecordId;

	END IF;



	SELECT encode(recordfiledata_data, $$hex$$)

	INTO _hexData

	FROM recordfiledata

	WHERE recordfiledata_id = _recordFile.recordfile_recordfiledata_id;



	RETURN _hexData;

END$_$;


ALTER FUNCTION public.getfilerecord(text, integer, text) OWNER TO admin;

--
-- TOC entry 400 (class 1255 OID 36832)
-- Name: getfiletypeid(text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION getfiletypeid(text) RETURNS integer
    LANGUAGE plpgsql
    AS $_$DECLARE

	pFileType 	ALIAS FOR $1;

	_fileTypeId 	INTEGER;

BEGIN

	PERFORM (SELECT checkpriv('getfiletypeid'));



	IF pfileType IS NULL THEN

		RETURN null;

	END IF;



	SELECT filetype_id

	INTO _fileTypeId

	FROM filetype

	WHERE filetype_mediatypename = pFileType;



	IF _fileTypeId IS NULL THEN

		RAISE EXCEPTION 'getfiletypeid: file Type % not found.', 

			pfileType;

	END IF;



	RETURN _fileTypeId;

END;

$_$;


ALTER FUNCTION public.getfiletypeid(text) OWNER TO admin;

--
-- TOC entry 401 (class 1255 OID 36833)
-- Name: getitemid(text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION getitemid(text) RETURNS integer
    LANGUAGE plpgsql
    AS $_$DECLARE

	pItemNumber 	ALIAS FOR $1;

	_itemId 	INTEGER;

BEGIN

	PERFORM (SELECT checkpriv('getitemid'));



	SELECT item_id

	INTO _itemId

	FROM item

	WHERE item_number = pItemNumber;



	IF _itemId IS NULL THEN

		RAISE EXCEPTION 'getitemid: Item Number % Not Found in AeryonMES', 

			pItemNumber;

	END IF;



	RETURN _itemId;

END;



	$_$;


ALTER FUNCTION public.getitemid(text) OWNER TO admin;

--
-- TOC entry 402 (class 1255 OID 36834)
-- Name: getlineid(text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION getlineid(text) RETURNS integer
    LANGUAGE plpgsql
    AS $_$

DECLARE

	pLine 	ALIAS FOR $1;

	_lineId 	INTEGER;

BEGIN

	PERFORM (SELECT checkpriv('getlineid'));



	SELECT line_id

	INTO _lineId

	FROM line

	WHERE line_name = pLine;



	IF _lineId IS NULL THEN

		RAISE EXCEPTION 'getlineid: line % Not Found in AeryonMES.', 

			pLine;

	END IF;



	RETURN _lineId;

END;

$_$;


ALTER FUNCTION public.getlineid(text) OWNER TO admin;

--
-- TOC entry 403 (class 1255 OID 36835)
-- Name: getlocid(text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION getlocid(text) RETURNS integer
    LANGUAGE plpgsql
    AS $_$

DECLARE

	pLoc 	ALIAS FOR $1;

	_locId 	INTEGER;

BEGIN

	PERFORM (SELECT checkpriv('getlocid'));



	SELECT loc_id

	INTO _locId

	FROM loc

	WHERE loc_number = pLoc;



	IF _locId IS NULL THEN

		RAISE EXCEPTION 'getlocid: Location % Not Found in AeryonMES', 

			pLoc;

	END IF;



	RETURN _locId;

END;

$_$;


ALTER FUNCTION public.getlocid(text) OWNER TO admin;

--
-- TOC entry 404 (class 1255 OID 36836)
-- Name: getmoduleid(text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION getmoduleid(text) RETURNS integer
    LANGUAGE plpgsql
    AS $_$DECLARE

	pModule 	ALIAS FOR $1;

	_moduleId 	INTEGER;

BEGIN

	PERFORM (SELECT checkpriv('getmoduleid'));



	SELECT module_id

	INTO _moduleId

	FROM module

	WHERE module_name = pModule;



	IF _moduleId IS NULL THEN

		RAISE EXCEPTION 'getmoduleid: Module % Not Found in AeryonMES', 

			pModule;

	END IF;



	RETURN _moduleId;

END;

$_$;


ALTER FUNCTION public.getmoduleid(text) OWNER TO admin;

--
-- TOC entry 405 (class 1255 OID 36837)
-- Name: getpartid(text, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION getpartid(text, text, text) RETURNS integer
    LANGUAGE plpgsql
    AS $_$DECLARE

	pItemNumber 	ALIAS FOR $1;

	pRevision 	ALIAS FOR $2;

	pSerialNumber 	ALIAS FOR $3;

	_partid 	INTEGER;

BEGIN

	PERFORM (SELECT checkpriv('getpartid'));

	PERFORM (SELECT validatepart(pItemNumber, pRevision, pSerialNumber, null, true));



	SELECT part_id

	INTO _partid

	FROM part

	WHERE part_item_id = getitemid(pItemNumber) 

	AND part_rev = pRevision 

	AND part_serialnumber = pSerialNumber;



	RETURN _partid;

END;



	$_$;


ALTER FUNCTION public.getpartid(text, text, text) OWNER TO admin;

--
-- TOC entry 406 (class 1255 OID 36838)
-- Name: getpartlogactionid(text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION getpartlogactionid(text) RETURNS integer
    LANGUAGE plpgsql
    AS $_$

DECLARE

	pPartLogAction 		ALIAS FOR $1;

	_partLogActionId 	INTEGER;

BEGIN

	PERFORM (SELECT checkpriv('getpartlogactionid'));



	SELECT partlogaction_id

	INTO _partLogActionId

	FROM partlogaction

	WHERE partlogaction_name = pPartLogAction;



	IF _partLogActionId IS NULL THEN

		RAISE EXCEPTION 'getpartlogactionid: Part Log Action % Not Found in AeryonMES', 

			_partLogActionId;

	END IF;



	RETURN _partLogActionId;

END;

$_$;


ALTER FUNCTION public.getpartlogactionid(text) OWNER TO admin;

--
-- TOC entry 407 (class 1255 OID 36839)
-- Name: getpartscrapcodeid(text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION getpartscrapcodeid(text) RETURNS integer
    LANGUAGE plpgsql
    AS $_$

DECLARE

	pPartScrapCode 	ALIAS FOR $1;

	_partScrapCodeId 	INTEGER;

BEGIN

	PERFORM (SELECT checkpriv('getpartscrapcodeid'));



	SELECT partscrapcode_id

	INTO _partScrapCodeId

	FROM partscrapcode

	WHERE partscrapcode_code = pPartScrapCode;



	IF _partScrapCodeId IS NULL THEN

		RAISE EXCEPTION 'getpartscrapcodeid: Part Scrap Code % Not Found in AeryonMES', 

			pPartScrapCode;

	END IF;



	RETURN _partScrapCodeId;

END;

$_$;


ALTER FUNCTION public.getpartscrapcodeid(text) OWNER TO admin;

--
-- TOC entry 408 (class 1255 OID 36840)
-- Name: getpartstateid(text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION getpartstateid(text) RETURNS integer
    LANGUAGE plpgsql
    AS $_$

DECLARE

	pPartState	ALIAS FOR $1;

	_partStateId 	INTEGER;

BEGIN

	PERFORM (SELECT checkpriv('getpartstateid'));



	SELECT partstate_id 

	INTO _partStateId

	FROM partstate

	WHERE partstate_name = pPartState;



	IF _partStateId IS NULL THEN

		RAISE EXCEPTION 'getpartstateid: Part State % Not Found in AeryonMES', 

		pPartState;

	END IF;



	RETURN _partStateId;

END;

$_$;


ALTER FUNCTION public.getpartstateid(text) OWNER TO admin;

--
-- TOC entry 358 (class 1255 OID 36841)
-- Name: getprivid(text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION getprivid(text) RETURNS integer
    LANGUAGE plpgsql
    AS $_$DECLARE

	pPriv 		ALIAS FOR $1;

	_privId 	INTEGER;

BEGIN

	PERFORM (SELECT checkpriv('getprivid'));



	SELECT priv_id

	INTO _privId

	FROM priv

	WHERE priv_name = pPriv;



	IF _privId IS NULL THEN

		RAISE EXCEPTION 'getprivid: Privilege % Not Found in AeryonMES', 

			pPriv;

	END IF;



	RETURN _privId;

END;

$_$;


ALTER FUNCTION public.getprivid(text) OWNER TO admin;

--
-- TOC entry 359 (class 1255 OID 36842)
-- Name: getrecordlogactionid(text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION getrecordlogactionid(text) RETURNS integer
    LANGUAGE plpgsql
    AS $_$

DECLARE

	precordlogAction 		ALIAS FOR $1;

	_recordlogActionId 	INTEGER;

BEGIN

	PERFORM (SELECT checkpriv('getrecordlogactionid'));



	SELECT recordlogaction_id

	INTO _recordlogActionId

	FROM recordlogaction

	WHERE recordlogaction_name = precordlogAction;



	IF _recordlogActionId IS NULL THEN

		RAISE EXCEPTION 'getrecordlogactionid: Part Log Action % Not Found in AeryonMES', 

			_recordlogActionId;

	END IF;



	RETURN _recordlogActionId;

END;

$_$;


ALTER FUNCTION public.getrecordlogactionid(text) OWNER TO admin;

--
-- TOC entry 360 (class 1255 OID 36843)
-- Name: getrecordtypeid(text, boolean); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION getrecordtypeid(text, boolean DEFAULT false) RETURNS integer
    LANGUAGE plpgsql
    AS $_$DECLARE

	pRecordType 	ALIAS FOR $1;

	pAllowNull	ALIAS FOR $2;

	_recordTypeId 	INTEGER;

BEGIN

	PERFORM (SELECT checkpriv('getrecordtypeid'));



	IF pRecordType IS NULL AND pAllowNull = true THEN

		RETURN null;

	END IF;



	SELECT recordtype_id

	INTO _recordTypeId

	FROM recordtype

	WHERE recordtype_name = pRecordType;



	IF _recordTypeId IS NULL THEN

		RAISE EXCEPTION 'getrecordtypeid: Record Type % Not Found in AeryonMES', 

			pRecordType;

	END IF;



	RETURN _recordTypeId;

END;

$_$;


ALTER FUNCTION public.getrecordtypeid(text, boolean) OWNER TO admin;

--
-- TOC entry 361 (class 1255 OID 36844)
-- Name: getroleid(text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION getroleid(text) RETURNS integer
    LANGUAGE plpgsql
    AS $_$DECLARE

	pRole 		ALIAS FOR $1;

	_roleId 	INTEGER;

BEGIN

	PERFORM (SELECT checkpriv('getroleid'));



	SELECT role_id

	INTO _roleId

	FROM role

	WHERE role_name = pRole;



	IF _roleId IS NULL THEN

		RAISE EXCEPTION 'getroleid: Role % Not Found in AeryonMES', 

			pRole;

	END IF;



	RETURN _roleId;

END;

$_$;


ALTER FUNCTION public.getroleid(text) OWNER TO admin;

--
-- TOC entry 366 (class 1255 OID 36845)
-- Name: getstationid(text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION getstationid(text) RETURNS integer
    LANGUAGE plpgsql
    AS $_$

DECLARE

	pStation 	ALIAS FOR $1;

	_stationId 	INTEGER;

BEGIN

	PERFORM (SELECT checkpriv('getstationid'));



	SELECT station_id

	INTO _stationId

	FROM station

	WHERE station_name = pStation;



	IF _stationId IS NULL THEN

		RAISE EXCEPTION 'getstationid: Station % Not Found in AeryonMES.', 

			pStation;

	END IF;



	RETURN _stationId;

END;

$_$;


ALTER FUNCTION public.getstationid(text) OWNER TO admin;

--
-- TOC entry 367 (class 1255 OID 36846)
-- Name: getusrid(text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION getusrid(text DEFAULT "current_user"()) RETURNS integer
    LANGUAGE plpgsql
    AS $_$DECLARE

	pUserName 	ALIAS FOR $1;

	_usrInfo 	RECORD;

BEGIN

	PERFORM (SELECT checkpriv('getusrid'));

	SELECT usr_id, usr_active

	INTO _usrInfo

	FROM usr

	WHERE usr_username = pUserName;



	IF _usrInfo.usr_id IS NULL THEN

		RAISE EXCEPTION 'getusrid: User % does not exist.', 

			pUserName;

	ELSIF _usrInfo.usr_active = false THEN

		RAISE EXCEPTION 'getusrid: User % is inactive.', 

			pUserName;

	END IF;

	

	RETURN _usrInfo.usr_id;

END;

	$_$;


ALTER FUNCTION public.getusrid(text) OWNER TO admin;

--
-- TOC entry 377 (class 1255 OID 36847)
-- Name: postbackflush(integer); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION postbackflush(integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pBackflushId	ALIAS FOR $1;

	_backflushCheck	RECORD;

	_usrId 		INTEGER;

	_message 	TEXT;

  

BEGIN

	_usrId := (SELECT getusrid()); 

	PERFORM (SELECT checkpriv('postbackflush'));



	SELECT 	backflush_id, 

		backflush_part_id,

		item_number, 

		backflush_orig_item_id, 

		backflush_orig_rev, 

		backflush_orig_serialnumber, 

		backflush_qty, 

		doctype_name, 

		backflush_docnumber,

		backflush_void_timestamp, 

		backflush_complete_timestamp

	INTO _backflushCheck

	FROM backflush 

	LEFT OUTER JOIN item ON item_id = backflush_orig_item_id

	LEFT OUTER JOIN doctype ON doctype_id = backflush_doctype_id

	WHERE backflush_id = pBackflushId;

	

	IF _backflushCheck.backflush_id IS NULL THEN

		RAISE EXCEPTION 'postbackflush: Backflush ID % does not exist.',

			pBackflushId;

	ELSIF _backflushCheck.backflush_void_timestamp IS NOT NULL THEN

		RAISE EXCEPTION 'postbackflush: Backflush ID % is VOID and cannot be posted.',

			pBackflushId;

	ELSIF _backflushCheck.backflush_complete_timestamp IS NOT NULL THEN

		RAISE EXCEPTION 'postbackflush: Backflush ID % is COMPLETE and cannot be posted.',

			pBackflushId;

	END IF;



	

	UPDATE backflush

	SET	(backflush_complete_usr_id,

		 backflush_complete_timestamp)

	=	(_usrId,

		 now())

	WHERE backflush_id = pBackflushId;

	

	_message := 	'Backflush ID ' ||

			pBackflushID || ' posted: ' ||

			_backflushCheck.item_number || ' ' || 

			_backflushCheck.backflush_orig_rev || ' ' || 

			_backflushCheck.backflush_orig_serialnumber || ' qty ' || 

			_backflushCheck.backflush_qty || ' on ' || 

			_backflushCheck.doctype_name || ' ' || 

			_backflushCheck.backflush_docnumber || '.';



	PERFORM (SELECT enterpartlog(	'Manufacturing'::TEXT, 

					'Post Backflush'::TEXT,

					_backflushCheck.item_number,

					_backflushCheck.backflush_orig_rev,

					_backflushCheck.backflush_orig_serialnumber,

					'Backflush ID'::TEXT,

					pBackflushId,

					_message,

					_backflushCheck.doctype_name, 

					_backflushCheck.backflush_docnumber));



	RETURN true;

END;$_$;


ALTER FUNCTION public.postbackflush(integer) OWNER TO admin;

--
-- TOC entry 409 (class 1255 OID 36848)
-- Name: refurbpart(text, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION refurbpart(text, text, text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pItemNumber ALIAS FOR $1;

	pRevision ALIAS FOR $2;

	pSerialNumber ALIAS FOR $3;

	_viewpart RECORD;

	_usrId INTEGER;

	_partRefurbHistId INTEGER;

	_message TEXT;

  

BEGIN

	_usrID := (SELECT getusrid()); 

	PERFORM (SELECT checkpriv('refurbpart'));

	PERFORM (SELECT validatepart(pItemNumber, pRevision, pSerialNumber, null, true));

	

	SELECT 	part_id, 

		item_id,

		part_rev,

		item_number,

		part_active,

		part_refurb,

		part_serialnumber, 

		part_sequencenumber,

		part_cust_id,

		loc_number

	INTO _viewpart

	FROM viewpart

	WHERE item_number = pItemNumber 

	AND part_serialnumber = pSerialNumber 

	AND part_rev = pRevision;



	IF _viewpart.part_refurb THEN

		RETURN true;

	END IF;

	

	UPDATE part SET (part_refurb) =

			(true)

	WHERE part_id = _viewpart.part_id;



	INSERT INTO partrefurbhist (	partrefurbhist_part_id, 

					partrefurbhist_refurb,

					partrefurbhist_usr_id,

					partrefurbhist_orig_item_id,

					partrefurbhist_orig_rev,

					partrefurbhist_orig_serialnumber)

		VALUES (		_viewpart.part_id, 

					true,

					_usrId,

					_viewpart.item_id,

					_viewpart.part_rev,

					_viewpart.part_serialnumber)

		RETURNING partrefurbhist_id INTO _partRefurbHistId;



	_message := 	pItemNumber || ' ' ||  

			pRevision || ' ' || 

			pSerialNumber || ' Refurbed.';



	PERFORM (SELECT enterpartlog(	'Manufacturing'::TEXT, 

					'Refurbed'::TEXT,

					pItemNumber,

					pRevision,

					pSerialNumber,

					'Refurb History'::TEXT,

					_partRefurbHistId,

					_message));



	PERFORM (SELECT activatepart(pItemNumber, pRevision, pSerialNumber));



	RETURN true;

END;$_$;


ALTER FUNCTION public.refurbpart(text, text, text) OWNER TO admin;

--
-- TOC entry 410 (class 1255 OID 36849)
-- Name: refurbsummsubass(text, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION refurbsummsubass(text, text, text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pItemNumber ALIAS FOR $1;

	pRevision ALIAS FOR $2;

	pSerialNumber ALIAS FOR $3;

	_usrId INTEGER;

	_r RECORD;

  

BEGIN

	_usrID := (SELECT getusrid()); 

	PERFORM (SELECT checkpriv('refurbsummsubass'));

	PERFORM (SELECT validatepart(pItemNumber, pRevision, pSerialNumber, null, true));

	

	PERFORM (SELECT refurbpart(	pItemNumber,

					pRevision,

					pSerialNumber));

	

	FOR _r IN

		SELECT *

		FROM summsubass(	pItemNumber,

					pRevision,

					pSerialNumber)

	LOOP

		IF _r.c_item_number IS NOT NULL THEN

			PERFORM (SELECT refurbpart(	_r.c_item_number,

							_r.c_part_rev,

							_r.c_part_serialnumber));

		END IF;

	END LOOP;

		  

	RETURN true;

END;$_$;


ALTER FUNCTION public.refurbsummsubass(text, text, text) OWNER TO admin;

--
-- TOC entry 411 (class 1255 OID 36850)
-- Name: removecustparam(text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION removecustparam(text, text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pType 			ALIAS FOR $1;

	pParam	 		ALIAS FOR $2;

	_custParam 		RECORD;

  

BEGIN

	PERFORM (SELECT getusrid());

	PERFORM (SELECT checkpriv('removecustparam'));



	IF pParam IS NULL THEN

		RAISE EXCEPTION 'removecustparam: Custom Parameter Name cannot be null.';

	END IF;



	IF pType != 'r' AND pType != 'p' THEN

		RAISE EXCEPTION 'removecustparam: Custom Parameter must be of Type r or p.';

	END IF;

	

	SELECT 	custparam_id,

		custparam_type, 

		custparam_param,

		custparam_datatype_id,

		datatype_type 	

	INTO _custParam

	FROM custparam

	LEFT OUTER JOIN datatype

		ON datatype.datatype_id = custparam.custparam_datatype_id

	WHERE custparam_param = pParam 

	AND custparam_type = pType

	AND custparam_void_timestamp IS NULL;



	IF _custParam.custparam_id IS NULL THEN

		RETURN true;

	END IF;



	UPDATE 	custparam 

	SET 	(custparam_void_timestamp)

	= 	(now())

	WHERE 	custparam_param = pParam

	AND	custparam_type = pType

	AND	custparam_void_timestamp IS NULL;

				

	RETURN true;

END;$_$;


ALTER FUNCTION public.removecustparam(text, text) OWNER TO admin;

--
-- TOC entry 412 (class 1255 OID 36851)
-- Name: removecustparamcombo(text, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION removecustparamcombo(text, text, text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pType 			ALIAS FOR $1;

	pParam	 		ALIAS FOR $2;

	pValue			ALIAS FOR $3;

	_custParamCombo		RECORD;

	_custParamId		INTEGER;

  

BEGIN

	PERFORM (SELECT getusrid());

	PERFORM (SELECT checkpriv('removecustparamcombo'));



	IF pParam IS NULL THEN

		RAISE EXCEPTION 'removecustparamcombo: Custom Parameter Name cannot be null.';

	END IF;



	IF pType != 'r' AND pType != 'p' THEN

		RAISE EXCEPTION 'removecustparamcombo: Custom Parameter must be of Type r or p.';

	END IF;



	_custParamId := (SELECT getcustparamid(pType, pParam));

	

	SELECT 	custparamcombo_id,

		custparamcombo_custparam_id, 

		custparamcombo_value,

		custparamcombo_active

	INTO _custParamCombo

	FROM custparamcombo

	WHERE custparamcombo_custparam_id = _custParamId

	AND custparamcombo_value = pValue

	AND custparamcombo_active = true;



	IF _custParamCombo.custparamcombo_id IS NULL THEN

		RETURN true;

	END IF;



	UPDATE custparamcombo 

	SET custparamcombo_active = false 

	WHERE custparamcombo_custparam_id = _custParamId 

	AND custparamcombo_value = pValue;

				

	RETURN true;

END;$_$;


ALTER FUNCTION public.removecustparamcombo(text, text, text) OWNER TO admin;

--
-- TOC entry 413 (class 1255 OID 36852)
-- Name: removecustparamlinkitem(text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION removecustparamlinkitem(text, text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pParam	 		ALIAS FOR $1;

	pItemNumber			ALIAS FOR $2;

	_itemCustParamLink		RECORD;

	_custParamId		INTEGER;

	_itemId			INTEGER;



  

BEGIN

	PERFORM (SELECT getusrid());

	PERFORM (SELECT checkpriv('removecustparamlinkitem'));



	_custParamId := (SELECT getcustparamid('p', pParam));



	_itemId := (SELECT getitemid(pItemNumber));



	SELECT 	itemcustparamlink_id,

		itemcustparamlink_custparam_id, 

		itemcustparamlink_item_id,

		itemcustparamlink_active

	INTO _itemCustParamLink

	FROM itemcustparamlink

	WHERE itemcustparamlink_custparam_id = _custParamId

	AND itemcustparamlink_item_id = _itemId

	AND itemcustparamlink_active = true;



	IF _itemCustParamLink.itemcustparamlink_id IS NULL THEN

		RETURN true;

	ELSIF _itemCustParamLink.itemcustparamlink_id IS NOT NULL AND _itemCustParamLink.itemcustparamlink_active = true THEN

		UPDATE itemcustparamlink 

		SET itemcustparamlink_active = false

		WHERE itemcustparamlink_custparam_id = _custParamId 

		AND itemcustparamlink_item_id = _itemId;

	END IF;

					

	RETURN true;

END;$_$;


ALTER FUNCTION public.removecustparamlinkitem(text, text) OWNER TO admin;

--
-- TOC entry 414 (class 1255 OID 36853)
-- Name: removecustparamlinkrecord(text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION removecustparamlinkrecord(text, text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pParam	 		ALIAS FOR $1;

	pRecordType			ALIAS FOR $2;

	_recordCustParamLink		RECORD;

	_custParamId		INTEGER;

	_recordTypeid			INTEGER;



  

BEGIN

	PERFORM (SELECT getusrid());

	PERFORM (SELECT checkpriv('removecustparamlinkrecord'));



	_custParamId := (SELECT getcustparamid('r', pParam));



	_recordTypeid := (SELECT getrecordtypeid(pRecordType));



	SELECT 	recordcustparamlink_id,

		recordcustparamlink_custparam_id, 

		recordcustparamlink_recordtype_id,

		recordcustparamlink_active

	INTO _recordCustParamLink

	FROM recordcustparamlink

	WHERE recordcustparamlink_custparam_id = _custParamId

	AND recordcustparamlink_recordtype_id = _recordTypeid

	AND recordcustparamlink_active = true;



	IF _recordCustParamLink.recordcustparamlink_id IS NULL THEN

		RETURN true;

	ELSIF _recordCustParamLink.recordcustparamlink_id IS NOT NULL AND _recordCustParamLink.recordcustparamlink_active = true THEN

		UPDATE recordcustparamlink 

		SET recordcustparamlink_active = false 

		WHERE recordcustparamlink_custparam_id = _custParamId 

		AND recordcustparamlink_recordtype_id = _recordTypeid;

	END IF;

					

	RETURN true;

END;$_$;


ALTER FUNCTION public.removecustparamlinkrecord(text, text) OWNER TO admin;

--
-- TOC entry 415 (class 1255 OID 36854)
-- Name: removecustparamvaluepart(text, text, text, text, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION removecustparamvaluepart(text, text, text, text, boolean DEFAULT true) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pParam	 		ALIAS FOR $1;

	pItemNumber		ALIAS FOR $2;

	pRevision		ALIAS FOR $3;

	pSerialNumber		ALIAS FOR $4;

	pLog			ALIAS FOR $5;

	_partId 		INTEGER;

	_custParamId		INTEGER;

	_r			RECORD;

	_message		TEXT;

  

BEGIN

	PERFORM (SELECT getusrid());

	PERFORM (SELECT checkpriv('removecustparamvaluepart'));



	_custParamId := (SELECT getcustparamid('p', pParam));

		

	_partId := (SELECT getpartid(pItemNumber, pRevision, pSerialNumber));



	FOR _r IN

		SELECT custparam_id

		FROM custparam

		WHERE custparam_param = pParam

		AND custparam_type = 'p'

	LOOP

		IF _r.custparam_id IS NOT NULL THEN

			UPDATE partcustparamvalue

			SET partcustparamvalue_void_timestamp = now()

			WHERE partcustparamvalue_custparam_id = _r.custparam_id

			AND partcustparamvalue_part_id = _partId

			AND partcustparamvalue_void_timestamp IS NULL;

		END IF;

	END LOOP;



	IF pLog = true THEN

		_message := 'Custom Parameter ' ||

			pParam || ' removed for ' ||

			pItemNumber || ' ' ||  

			pRevision || ' ' || 

			pSerialNumber || '.';



		PERFORM (SELECT enterpartlog(	'Custom Parameter'::TEXT, 

						'Custom Parameter Removed',

						pItemNumber,

						pRevision,

						pSerialNumber,

						'Part Custom Parameter Value History'::TEXT,

						null,

						_message));

	END IF;

	

	RETURN true;

END;$_$;


ALTER FUNCTION public.removecustparamvaluepart(text, text, text, text, boolean) OWNER TO postgres;

--
-- TOC entry 416 (class 1255 OID 36855)
-- Name: removecustparamvaluerecord(text, text, integer, boolean); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION removecustparamvaluerecord(text, text, integer, boolean DEFAULT true) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pParam	 		ALIAS FOR $1;

	pRecordType		ALIAS FOR $2;

	pRecordId		ALIAS FOR $3;

	pLog			ALIAS FOR $4;

	_recordTypeId 		INTEGER;

	_custParamId		INTEGER;

	_r			RECORD;

	_message		TEXT;

  

BEGIN

	PERFORM (SELECT getusrid());

	PERFORM (SELECT checkpriv('removecustparamvaluerecord'));



	IF pRecordId IS NULL THEN

		RAISE EXCEPTION 'removecustparamvaluerecord: Record ID cannot be null.';

	END IF;	



	_custParamId := (SELECT getcustparamid('r', pParam));

		

	_recordTypeId := (SELECT getrecordtypeid(pRecordType));



	FOR _r IN

		SELECT custparam_id

		FROM custparam

		WHERE custparam_param = pParam

		AND custparam_type = 'r'

	LOOP

		IF _r.custparam_id IS NOT NULL THEN

			UPDATE recordcustparamvalue

			SET recordcustparamvalue_void_timestamp = now()

			WHERE recordcustparamvalue_custparam_id = _r.custparam_id

			AND recordcustparamvalue_recordtype_id = _recordTypeId

			AND recordcustparamvalue_record_id = pRecordId

			AND recordcustparamvalue_void_timestamp IS NULL;

		END IF;

	END LOOP;



	IF pLog = true THEN

		_message := 'Custom Parameter ' ||

			pParam || ' removed for ' ||

			pRecordType || ' with ID ' ||  

			pRecordId || '.';



		PERFORM (SELECT enterrecordlog(	'Custom Parameter'::TEXT, 

						'Custom Parameter Removed',

						pRecordType,

						pRecordId,

						'Record Custom Parameter Value History'::TEXT,

						null,

						_message));

	END IF;

	

	RETURN true;

END;$_$;


ALTER FUNCTION public.removecustparamvaluerecord(text, text, integer, boolean) OWNER TO admin;

--
-- TOC entry 417 (class 1255 OID 36856)
-- Name: removedoclinkpart(text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION removedoclinkpart(text, text, text, text, text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pDocType 		ALIAS FOR $1;

	pDocNumber		ALIAS FOR $2;

	pItemNumber		ALIAS FOR $3;

	pRevision		ALIAS FOR $4;

	pSerialNumber		ALIAS FOR $5;

	_partId 		INTEGER;

	_docTypeId		INTEGER;

	_message		TEXT;

	_checkPartDocLinkId	INTEGER;

  

BEGIN

	PERFORM (SELECT getusrid());

	PERFORM (SELECT checkpriv('removedoclinkpart'));



	_docTypeId := (SELECT getdoctypeid(pDocType));

		

	_partId := (SELECT getpartid(pItemNumber, pRevision, pSerialNumber));



	_checkPartDocLinkId := (SELECT partdoclink_id

				FROM viewpartdoclink

				WHERE 	doctype_name = pDocType

				AND	partdoclink_docnumber = pDocNumber

				AND 	part_id = _partId

				AND	partdoclink_void_timestamp IS NULL);



	IF _checkPartDocLinkId IS NULL THEN

		RETURN true;

	END IF;

	

	UPDATE partdoclink

	SET partdoclink_void_timestamp = now()

	WHERE partdoclink_doctype_id = _docTypeId

	AND partdoclink_part_id = _partId

	AND partdoclink_docnumber = pDocNumber

	AND partdoclink_void_timestamp IS NULL;



	_message := 'Document Link ' ||

		pDocType || ' removed with Document Number ' ||

		pDocNumber || ' from ' ||

		pItemNumber || ' ' ||  

		pRevision || ' ' || 

		pSerialNumber || '.';



	PERFORM (SELECT enterpartlog(	'Document Link'::TEXT, 

					'Document Link Removed'::TEXT,

					pItemNumber,

					pRevision,

					pSerialNumber,

					'Part Document Link History'::TEXT,

					_checkPartDocLinkId,

					_message));

						

	RETURN true;

END;$_$;


ALTER FUNCTION public.removedoclinkpart(text, text, text, text, text) OWNER TO admin;

--
-- TOC entry 418 (class 1255 OID 36857)
-- Name: removedoclinkrecord(text, text, text, integer); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION removedoclinkrecord(text, text, text, integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pDocType 		ALIAS FOR $1;

	pDocNumber		ALIAS FOR $2;

	pRecordType		ALIAS FOR $3;

	pRecordId		ALIAS FOR $4;

	_recordTypeId 		INTEGER;

	_docTypeId		INTEGER;

	_message		TEXT;

	_checkRecordDocLinkId	INTEGER;

	_recordDocLinkId	INTEGER;

  

BEGIN

	PERFORM (SELECT getusrid());

	PERFORM (SELECT checkpriv('adddoclinkpart'));



	_docTypeId := (SELECT getdoctypeid(pDocType));

		

	_recordTypeId := (SELECT getrecordtypeid(pRecordType));



	_checkRecordDocLinkId := (SELECT recorddoclink_id

				FROM viewrecorddoclink

				WHERE 	doctype_name = pDocType

				AND	recorddoclink_docnumber = pDocNumber

				AND 	recordtype_name = pRecordType

				AND 	recorddoclink_record_id = pRecordId

				AND	recorddoclink_void_timestamp IS NULL);



	IF _checkRecordDocLinkId IS NULL THEN

		RETURN true;

	END IF;

	

	UPDATE recorddoclink

	SET recorddoclink_void_timestamp = now()

	WHERE recorddoclink_doctype_id = _docTypeId

	AND recorddoclink_recordtype_id = _recordTypeId

	AND recorddoclink_record_id = pRecordId

	AND recorddoclink_docnumber = pDocNumber

	AND recorddoclink_void_timestamp IS NULL;

	

	_message := 'Document Link ' ||

		pDocType || ' removed with Document Number ' ||

		pDocNumber || ' from ' ||

		pRecordType || ' with ID ' ||  

		pRecordId || '.';



	PERFORM (SELECT enterrecordlog(	'Document Link'::TEXT, 

					'Document Link Removed'::TEXT,

					pRecordType,

					pRecordId,

					'Record Document Link History'::TEXT,

					_checkRecordDocLinkId,

					_message));

						

	RETURN true;

END;$_$;


ALTER FUNCTION public.removedoclinkrecord(text, text, text, integer) OWNER TO admin;

--
-- TOC entry 421 (class 1255 OID 36858)
-- Name: removefilepart(text, text, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION removefilepart(text, text, text, text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$

DECLARE

  pItemNumber ALIAS FOR $1;

  pRevision ALIAS FOR $2;

  pSerialNumber ALIAS FOR $3;

  pFileName ALIAS FOR $4;

  _partId	INTEGER;

  _partFileId INTEGER;

  _message TEXT;

  

BEGIN

	PERFORM (SELECT getusrid());

	PERFORM (SELECT checkpriv('removefilepart'));

		

	_partId := (SELECT getpartid(pItemNumber, pRevision, pSerialNumber));



	SELECT partfile_id

	INTO _partFileId

	FROM partfile

	WHERE partfile_filename = pFileName

	AND partfile_part_id = _partId

	AND partfile_void_timestamp IS NULL;



	IF _partFileId IS NULL THEN

		RETURN true;

	END IF;



	UPDATE partfile

	SET	partfile_void_timestamp = now()

	WHERE partfile_filename = pFileName

	AND partfile_part_id = _partId

	AND partfile_void_timestamp IS NULL;



	_message := 	'File ' || 

			pFileName || ' removed from Part ' || 

			pItemNumber || ' ' || 

			pRevision || ' ' || 

			pSerialNumber || '.';

	

	PERFORM (SELECT enterpartlog(	'File Attachement'::TEXT, 

					'File Removed'::TEXT,

					pItemNumber,

					pRevision,

					pSerialNumber,

					'Part File Attachement History'::TEXT,

					_partFileId,

					_message));



	RETURN true;

END$_$;


ALTER FUNCTION public.removefilepart(text, text, text, text) OWNER TO admin;

--
-- TOC entry 422 (class 1255 OID 36859)
-- Name: removefilerecord(text, integer, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION removefilerecord(text, integer, text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$

DECLARE

  pRecordType ALIAS FOR $1;

  pRecordId ALIAS FOR $2;

  pFileName ALIAS FOR $3;

  _recordTypeId	INTEGER;

  _recordFileId INTEGER;

  _message TEXT;

  

BEGIN

	PERFORM (SELECT getusrid());

	PERFORM (SELECT checkpriv('removefilerecord'));

		

	_recordTypeId := (SELECT getrecordtypeid(pRecordType));

	

	SELECT recordfile_id

	INTO _recordFileId

	FROM recordfile

	WHERE recordfile_filename = pFileName

	AND recordfile_recordtype_id = _recordTypeId

	AND recordfile_record_id = pRecordId

	AND recordfile_void_timestamp IS NULL;



	IF _recordFileId IS NULL THEN

		RETURN true;

	END IF;



	UPDATE recordfile

	SET recordfile_void_timestamp = now()

	WHERE recordfile_filename = pFileName

	AND recordfile_recordtype_id = _recordTypeId

	AND recordfile_record_id = pRecordId

	AND recordfile_void_timestamp IS NULL;



	_message := 	'File ' || 

			pFileName || ' removed fromo Record Type ' || 

			pRecordType || ' with ID ' || 

			pRecordId || '.';



	PERFORM (SELECT enterrecordlog(	'File Attachement'::TEXT, 

					'File Removed'::TEXT,

					pRecordType,

					pRecordId,

					'Record File Attachement History'::TEXT,

					_recordFileId,

					_message));



	RETURN true;

END$_$;


ALTER FUNCTION public.removefilerecord(text, integer, text) OWNER TO admin;

--
-- TOC entry 423 (class 1255 OID 36860)
-- Name: removerolepriv(text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION removerolepriv(text, text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pPriv 			ALIAS FOR $1;

	pRole 		ALIAS FOR $2;

	_rolePriv 		RECORD;

	_roleId 			INTEGER;

	_privId			INTEGER;

  

BEGIN

	PERFORM (SELECT getusrid());

	PERFORM (SELECT checkpriv('removerolepriv'));

	_roleId := (SELECT getroleid(pRole));

	_privId := (SELECT getprivid(pPriv));

	

	SELECT 	rolepriv_id,

		rolepriv_priv_id, 

		rolepriv_role_id 	

	INTO _rolePriv

	FROM rolepriv

	WHERE rolepriv_priv_id = _privId 

	AND rolepriv_role_id = _roleId;



	IF _rolePriv.rolepriv_id IS NULL THEN

		RETURN true;

	END IF;



	DELETE 

	FROM rolepriv

	WHERE rolepriv_priv_id = _privId

	AND rolepriv_role_id = _roleId;

				

	RETURN true;

END;$_$;


ALTER FUNCTION public.removerolepriv(text, text) OWNER TO admin;

--
-- TOC entry 424 (class 1255 OID 36861)
-- Name: removeroleprivmodule(text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION removeroleprivmodule(text, text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pModule			ALIAS FOR $1;

	pRole 		ALIAS FOR $2;

	_r			RECORD;

	_moduleId 		INTEGER;

	_roleId			INTEGER;

  

BEGIN

	PERFORM (SELECT getusrid());

	PERFORM (SELECT checkpriv('removeroleprivmodule'));

	_moduleId := (SELECT getmoduleid(pModule));

	_roleId := (SELECT getroleid(pRole));



	FOR _r IN

		SELECT priv_name

		FROM priv

		WHERE priv_module_id = _moduleId

	LOOP

		IF _r.priv_name IS NOT NULL THEN

			PERFORM (SELECT removerolepriv(	_r.priv_name,

							pRole));

		END IF;

	END LOOP;

	

	RETURN true;

END;$_$;


ALTER FUNCTION public.removeroleprivmodule(text, text) OWNER TO admin;

--
-- TOC entry 425 (class 1255 OID 36862)
-- Name: removeusrpriv(text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION removeusrpriv(text, text DEFAULT "current_user"()) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pPriv 			ALIAS FOR $1;

	pUserName 		ALIAS FOR $2;

	_usrPriv 		RECORD;

	_usrId 			INTEGER;

	_privId			INTEGER;

  

BEGIN

	PERFORM (SELECT getusrid());

	PERFORM (SELECT checkpriv('removeusrpriv'));

	_usrId := (SELECT getusrid(pUserName));

	_privId := (SELECT getprivid(pPriv));

	

	SELECT 	usrpriv_id,

		usrpriv_priv_id, 

		usrpriv_usr_id 	

	INTO _usrPriv

	FROM usrpriv

	WHERE usrpriv_priv_id = _privId 

	AND usrpriv_usr_id = _usrId;



	IF _usrPriv.usrpriv_id IS NULL THEN

		RETURN true;

	END IF;



	DELETE 

	FROM usrpriv 

	WHERE usrpriv_priv_id =	_privId

	AND usrpriv_usr_id = _usrId;

				

	RETURN true;

END;$_$;


ALTER FUNCTION public.removeusrpriv(text, text) OWNER TO admin;

--
-- TOC entry 419 (class 1255 OID 36863)
-- Name: removeusrprivmodule(text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION removeusrprivmodule(text, text DEFAULT "current_user"()) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pModule			ALIAS FOR $1;

	pUserName 		ALIAS FOR $2;

	_r			RECORD;

	_moduleId 		INTEGER;

	_usrId			INTEGER;

  

BEGIN

	PERFORM (SELECT getusrid());

	PERFORM (SELECT checkpriv('removeusrprivmodule'));

	_moduleId := (SELECT getmoduleid(pModule));

	_usrId := (SELECT getusrid(pUserName));



	FOR _r IN

		SELECT priv_name

		FROM priv

		WHERE priv_module_id = _moduleId

	LOOP

		IF _r.priv_name IS NOT NULL THEN

			PERFORM (SELECT removeusrpriv(	_r.priv_name,

							pUserName));

		END IF;

	END LOOP;

	

	RETURN true;

END;$_$;


ALTER FUNCTION public.removeusrprivmodule(text, text) OWNER TO admin;

--
-- TOC entry 420 (class 1255 OID 36864)
-- Name: removeusrrole(text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION removeusrrole(text, text DEFAULT "current_user"()) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pRole			ALIAS FOR $1;

	pUserName 		ALIAS FOR $2;

	_usrRole 		RECORD;

	_roleId 		INTEGER;

	_usrId			INTEGER;

  

BEGIN

	PERFORM (SELECT getusrid());

	PERFORM (SELECT checkpriv('removeusrrole'));

	_roleId := (SELECT getroleid(pRole));

	_usrId := (SELECT getusrid(pUserName));

	

	SELECT 	usrrole_id,

		usrrole_usr_id, 

		usrrole_role_id 	

	INTO _usrRole

	FROM usrrole

	WHERE usrrole_usr_id = _usrId 

	AND usrrole_role_id = _roleId;



	IF _usrRole.usrrole_id IS NULL THEN

		RETURN true;

	END IF;



	DELETE 

	FROM usrrole

	WHERE usrrole_usr_id = _usrId

	AND usrrole_role_id = _roleId;

		

	RETURN true;

END;$_$;


ALTER FUNCTION public.removeusrrole(text, text) OWNER TO admin;

--
-- TOC entry 426 (class 1255 OID 36865)
-- Name: removewatcherpart(text, text, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION removewatcherpart(text, text, text, text DEFAULT "current_user"()) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pItemNumber		ALIAS FOR $1;

	pRevision		ALIAS FOR $2;

	pSerialNumber		ALIAS FOR $3;

	pUser			ALIAS FOR $4;

	_partId 		INTEGER;

	_usrId			INTEGER;

	_partWatcherId		INTEGER;

  

BEGIN

	_usrId := (SELECT getusrid(pUser));

	

	PERFORM (SELECT checkpriv('removewatcherpart'));

		

	_partId := (SELECT getpartid(pItemNumber, pRevision, pSerialNumber));



	_partWatcherId := 	(SELECT partwatcher_id 

				 FROM partwatcher

				 WHERE partwatcher_part_id = _partId

				 AND partwatcher_usr_id = _usrId);



	IF _partWatcherId IS NULL THEN

		RETURN true;

	END IF;

	

	DELETE

	FROM partwatcher

	WHERE partwatcher_part_id = _partId

	AND partwatcher_usr_id = _usrId;

	

	RETURN true;

END;$_$;


ALTER FUNCTION public.removewatcherpart(text, text, text, text) OWNER TO admin;

--
-- TOC entry 427 (class 1255 OID 36866)
-- Name: removewatcherrecord(text, integer, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION removewatcherrecord(text, integer, text DEFAULT "current_user"()) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pRecordType		ALIAS FOR $1;

	pRecordId		ALIAS FOR $2;

	pUser			ALIAS FOR $3;

	_recordTypeId 		INTEGER;

	_usrId			INTEGER;

	_recordWatcherId		INTEGER;

  

BEGIN

	_usrId := (SELECT getusrid(pUser));

	

	PERFORM (SELECT checkpriv('removewatcherrecord'));

		

	_recordTypeId := (SELECT getrecordtypeid(pRecordType));



	_recordWatcherId := 	(SELECT recordwatcher_id 

				 FROM recordwatcher

				 WHERE recordwatcher_recordtype_id = _recordTypeId

				 AND recordwatcher_record_id = pRecordId

				 AND recordwatcher_usr_id = _usrId);



	IF _recordWatcherId IS NULL THEN

		RETURN true;

	END IF;

	

	DELETE

	FROM recordwatcher

	WHERE recordwatcher_recordtype_id = _recordTypeId

	AND recordwatcher_record_id = pRecordId

	AND recordwatcher_usr_id = _usrId;

	

	RETURN true;

END;$_$;


ALTER FUNCTION public.removewatcherrecord(text, integer, text) OWNER TO admin;

--
-- TOC entry 430 (class 1255 OID 36867)
-- Name: revdownpart(text, text, text, text, text, boolean, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION revdownpart(text, text, text, text, text, boolean DEFAULT false, text DEFAULT NULL::text, text DEFAULT NULL::text) RETURNS TABLE(_partnumber text, _revision text, _serialnumber text, _sequencenumber integer, _itemfreqcode text)
    LANGUAGE plpgsql
    AS $_$DECLARE

	pItemNumber 		ALIAS FOR $1;

	pCurrentRevision 	ALIAS FOR $2;

	pSerialNumber 		ALIAS FOR $3;

	pDocNumber 		ALIAS FOR $4;

	pDocType 		ALIAS FOR $5;

	pNpi 			ALIAS FOR $6;

	pLine			ALIAS FOR $7;

	pStation		ALIAS FOR $8;

	_viewpart 		RECORD;

	_item 			RECORD;

	_docTypeId 		INTEGER;

	_locationId 		INTEGER;

	_partStateId 		INTEGER;

	_prefix 		TEXT;

	_serialPattern 		TEXT;

	_targetRevision 	TEXT;

	_npiRevision 		BOOLEAN;

	_r 			RECORD;

	_message 		TEXT;

	_changeRevPart 		RECORD;

  

BEGIN

	PERFORM (SELECT checkpriv('revdownpart'));

	PERFORM (SELECT validatepart(pItemNumber, pCurrentRevision, pSerialNumber));



	SELECT item_number, part_serialnumber, part_sequencenumber

	INTO _viewpart

	FROM viewpart

	WHERE item_number = pItemNumber AND part_serialnumber = pSerialNumber AND part_rev = pCurrentRevision;

	

	SELECT item_id, item_serialstream_id, serialprefix_prefix, serialpattern_pattern, itemfreqcode_freqcode

	INTO _item

	FROM item 

	LEFT OUTER JOIN serialstream ON item_serialstream_id = serialstream_id

	LEFT OUTER JOIN serialprefix ON item_serialprefix_id = serialprefix_id

	LEFT OUTER JOIN serialpattern ON serialprefix_serialpattern_id = serialpattern_id

	LEFT OUTER JOIN itemfreqcode ON item_itemfreqcode_id = itemfreqcode_id

	WHERE item_number = pItemNumber 

	AND item_active = true;



	IF _item.item_id IS NULL THEN

		RAISE EXCEPTION 'revdownpart: Item Number % not found in AeryonMES', pItemNumber;

	END IF;



	_docTypeId := (SELECT getdoctypeid(pDocType));

	_npiRevision := pNpi;

	

	IF _npiRevision = false THEN

		SELECT itemrev_npi

		INTO _npiRevision

		FROM itemrev

		WHERE itemrev_item_id = _item.item_id

			AND itemrev_rev = pCurrentRevision;

	END IF;

		

	SELECT itemrevflow_start_rev

	INTO _targetRevision

	FROM itemrevflow

	WHERE itemrevflow_item_id = _item.item_id

		AND itemrevflow_end_rev = pCurrentRevision

		AND itemrevflow_npi = _npiRevision;



	IF pCurrentRevision = '00' THEN

		RAISE EXCEPTION 'revdownpart: Cannot RevDown Part at Revision 00';

	ElSIF _targetRevision IS NULL THEN

		_targetRevision := lpad((pCurrentRevision::INTEGER - 1)::TEXT, 2, '0');

	END IF;



	IF (SELECT itemrev_id

	    FROM itemrev

	    WHERE itemrev_item_id = _item.item_id

	    AND itemrev_rev = _targetRevision) IS NULL THEN

		RAISE EXCEPTION 'revdownpart: Target Revision % of Selected Item % Not Found in AeryonMES', _targetRevision, pItemNumber;

	END IF;



	SELECT * 

	INTO _changeRevPart

	FROM changerevpart(	pItemNumber, 

				pCurrentRevision, 

				pSerialNumber, 

				pDocNumber, 

				pDocType, 

				_targetRevision,

				pLine,

				pStation);



	_message := 	pItemNumber || ' down reved from ' ||  

			pCurrentRevision || ' to ' || 

			_targetRevision || ' for ' ||

			pSerialNumber || ' on ' ||

			pDocType || ' ' ||

			pDocNumber || '.';



	PERFORM (SELECT enterpartlog(	'Manufacturing'::TEXT, 

					'Down Reved'::TEXT,

					pItemNumber,

					_targetRevision,

					pSerialNumber,

					'Revision History'::TEXT,

					_changeRevPart._partrevhistid,

					_message,

					pDocType,

					pDocNumber));

		  

	_partnumber := pItemNumber;

	_serialnumber := pSerialNumber;

	_revision := _targetRevision;

	_itemfreqcode := _item.itemfreqcode_freqcode;

	_sequencenumber := _viewpart.part_sequencenumber;

	

	RETURN NEXT;

	RETURN;

END;$_$;


ALTER FUNCTION public.revdownpart(text, text, text, text, text, boolean, text, text) OWNER TO admin;

--
-- TOC entry 431 (class 1255 OID 36868)
-- Name: reversebackflush(integer); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION reversebackflush(integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pBackflushId	ALIAS FOR $1;

	_backflushCheck	RECORD;

	_usrId 		INTEGER;

	_message 	TEXT;

  

BEGIN

	_usrId := (SELECT getusrid()); 

	PERFORM (SELECT checkpriv('reversebackflush'));



	SELECT 	backflush_id, 

		backflush_part_id,

		item_number, 

		backflush_item_id, 

		backflush_rev, 

		backflush_serialnumber, 

		backflush_qty, 

		doctype_name, 

		backflush_docnumber,

		backflush_void_timestamp, 

		backflush_complete_timestamp

	INTO _backflushCheck

	FROM backflush 

	LEFT OUTER JOIN item ON item_id = backflush_item_id

	LEFT OUTER JOIN doctype ON doctype_id = backflush_doctype_id

	WHERE backflush_id = pBackflushId;

	

	IF _backflushCheck.backflush_id IS NULL THEN

		RAISE EXCEPTION 'reversebackflush: Backflush ID % does not exist.',

			pBackflushId;

	ELSIF _backflushCheck.backflush_void_timestamp IS NOT NULL THEN

		RAISE EXCEPTION 'reversebackflush: Backflush ID % is VOID and cannot be reversed.',

			pBackflushId;

	ELSIF _backflushCheck.backflush_complete_timestamp IS NULL THEN

		RAISE EXCEPTION 'reversebackflush: Backflush ID % is NOT COMPLETE and cannot be reversed.',

			pBackflushId;

	END IF;



	

	UPDATE backflush

	SET	(backflush_complete_usr_id,

		 backflush_complete_timestamp)

	=	(null,

		 null)

	WHERE backflush_id = pBackflushId;

	

	_message := 	'Backflush ID ' ||

			pBackflushID || ' reversed: ' ||

			_backflushCheck.item_number || ' ' || 

			_backflushCheck.backflush_rev || ' ' || 

			_backflushCheck.backflush_serialnumber || ' qty ' || 

			_backflushCheck.backflush_qty || ' on ' || 

			_backflushCheck.doctype_name || ' ' || 

			_backflushCheck.backflush_docnumber || '.';



	PERFORM (SELECT enterpartlog(	'Manufacturing'::TEXT, 

					'Reverse Backflush'::TEXT,

					_backflushCheck.item_number,

					_backflushCheck.backflush_rev,

					_backflushCheck.backflush_serialnumber,

					'Backflush ID'::TEXT,

					pBackflushId,

					_message, 

					_backflushCheck.doctype_name, 

					_backflushCheck.backflush_docnumber));



	RETURN true;

END;$_$;


ALTER FUNCTION public.reversebackflush(integer) OWNER TO admin;

--
-- TOC entry 432 (class 1255 OID 36869)
-- Name: revuppart(text, text, text, text, text, boolean, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION revuppart(text, text, text, text, text, boolean DEFAULT false, text DEFAULT NULL::text, text DEFAULT NULL::text) RETURNS TABLE(_partnumber text, _revision text, _serialnumber text, _sequencenumber integer, _itemfreqcode text)
    LANGUAGE plpgsql
    AS $_$DECLARE

	pItemNumber ALIAS FOR $1;

	pCurrentRevision ALIAS FOR $2;

	pSerialNumber ALIAS FOR $3;

	pDocNumber ALIAS FOR $4;

	pDocType ALIAS FOR $5;

	pNpi ALIAS FOR $6;

	pLine ALIAS FOR $7;

	pStation ALIAS FOR $8;

	_viewpart RECORD;

	_item RECORD;

	_docTypeId INTEGER;

	_locationId INTEGER;

	_partStateId INTEGER;

	_prefix TEXT;

	_serialPattern TEXT;

	_targetRevision TEXT;

	_npiRevision boolean;

	_changeRevPart RECORD;

	_message TEXT;

  

BEGIN

	PERFORM (SELECT checkpriv('revuppart'));

	PERFORM (SELECT validatepart(pItemNumber, pCurrentRevision, pSerialNumber));

	

	SELECT item_number, part_serialnumber, part_sequencenumber

	INTO _viewpart

	FROM viewpart

	WHERE item_number = pItemNumber AND part_serialnumber = pSerialNumber AND part_rev = pCurrentRevision;

	

	SELECT item_id, item_serialstream_id, serialprefix_prefix, serialpattern_pattern, itemfreqcode_freqcode

	INTO _item

	FROM item 

	LEFT OUTER JOIN serialstream ON item_serialstream_id = serialstream_id

	LEFT OUTER JOIN serialprefix ON item_serialprefix_id = serialprefix_id

	LEFT OUTER JOIN serialpattern ON serialprefix_serialpattern_id = serialpattern_id

	LEFT OUTER JOIN itemfreqcode ON item_itemfreqcode_id = itemfreqcode_id

	WHERE item_number = pItemNumber 

	AND item_active = true;



	IF _item.item_id IS NULL THEN

		RAISE EXCEPTION 'revuppart: Item Number % not found in AeryonMES', pItemNumber;

	END IF;



	_docTypeId := (SELECT getdoctypeid(pDocType));

	_npiRevision := pNpi;

	

	IF _npiRevision = false THEN

		SELECT itemrev_npi

		INTO _npiRevision

		FROM itemrev

		WHERE itemrev_item_id = _item.item_id

			AND itemrev_rev = pCurrentRevision;

	END IF;

		

	SELECT itemrevflow_end_rev

	INTO _targetRevision

	FROM itemrevflow

	WHERE itemrevflow_item_id = _item.item_id

		AND itemrevflow_start_rev = pCurrentRevision

		AND itemrevflow_npi = _npiRevision;



	IF _targetRevision IS NULL THEN

		_targetRevision := lpad((pCurrentRevision::INTEGER + 1)::TEXT, 2, '0');

	END IF;



	IF (SELECT itemrev_id

	    FROM itemrev

	    WHERE itemrev_item_id = _item.item_id

	    AND itemrev_rev = _targetRevision) IS NULL THEN

		RAISE EXCEPTION 'revuppart: Target Revision % of Selected Item % Not Found in AeryonMES', _targetRevision, pItemNumber;

	END IF;



	SELECT * 

	INTO _changeRevPart

	FROM changerevpart(	pItemNumber, 

				pCurrentRevision, 

				pSerialNumber, 

				pDocNumber, 

				pDocType, 

				_targetRevision,

				pLine,

				pStation);



	



	_message := 	pItemNumber || ' up reved from ' ||  

			pCurrentRevision || ' to ' || 

			_targetRevision || ' for ' ||

			pSerialNumber || ' on ' ||

			pDocType || ' ' ||

			pDocNumber || '.';



	PERFORM (SELECT enterpartlog(	'Manufacturing'::TEXT, 

					'Up Reved'::TEXT,

					pItemNumber,

					_targetRevision,

					pSerialNumber,

					'Revision History'::TEXT,

					_changeRevPart._partrevhistid,

					_message,

					pDocType,

					pDocNumber));

		  

	_partnumber := pItemNumber;

	_serialnumber := pSerialNumber;

	_revision := _targetRevision;

	_itemfreqcode := _item.itemfreqcode_freqcode;

	_sequencenumber := _viewpart.part_sequencenumber;

	

	RETURN NEXT;

	RETURN;

END;$_$;


ALTER FUNCTION public.revuppart(text, text, text, text, text, boolean, text, text) OWNER TO admin;

--
-- TOC entry 433 (class 1255 OID 36870)
-- Name: scrappart(text, text, text, text, text, boolean); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION scrappart(text, text, text, text, text, boolean DEFAULT true) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pItemNumber 		ALIAS FOR $1;

	pRevision 		ALIAS FOR $2;

	pSerialNumber 		ALIAS FOR $3;

	pPartScrapCode 		ALIAS FOR $4;

	pPartScrapDescription 	ALIAS FOR $5;

	pDeAllocFirst		ALIAS FOR $6;

	_viewpart 		RECORD;

	_usrId 			INTEGER;

	_partScrapCodeId	INTEGER;

	_partScrapHistId 	INTEGER;

	_message 		TEXT;

  

BEGIN

	_usrID := (SELECT getusrid()); 

	PERFORM (SELECT checkpriv('scrappart'));

	PERFORM (SELECT validatepart(pItemNumber, pRevision, pSerialNumber));



	SELECT 	part_id, 

		item_id, 

		item_number,

		part_rev,

		part_serialnumber, 

		part_sequencenumber,

		part_cust_id,

		loc_number,

		parent_item_number,

		parent_part_rev,

		parent_part_serialnumber

	INTO _viewpart

	FROM viewpart

	WHERE item_number = pItemNumber 

	AND part_serialnumber = pSerialNumber 

	AND part_rev = pRevision;



	IF pDeAllocFirst = true AND _viewpart.parent_item_number IS NOT NULL THEN

		PERFORM (SELECT deallocpart(	_viewpart.parent_item_number, 

						_viewpart.parent_part_rev, 

						_viewpart.parent_part_serialnumber, 

						pItemNumber, 

						pRevision, 

						pSerialNumber, 

						'AMDD003'));

	END IF;



	_partScrapCodeId := (SELECT getpartscrapcodeid(pPartScrapCode));



	PERFORM (SELECT deactivatepart(pItemNumber, pRevision, pSerialNumber));



	INSERT INTO partscraphist (	partscraphist_part_id, 

					partscraphist_partscrapcode_id,

					partscraphist_description,

					partscraphist_usr_id,

					partscraphist_orig_item_id,

					partscraphist_orig_rev,

					partscraphist_orig_serialnumber)

		VALUES (		_viewpart.part_id,

					_partScrapCodeId,

					pPartScrapDescription,

					_usrId,

					_viewpart.item_id,

					_viewpart.part_rev,

					_viewpart.part_serialnumber)

		RETURNING partscraphist_id INTO _partScrapHistId;



	_message := 	pItemNumber || ' ' ||  

			pRevision || ' ' || 

			pSerialNumber || ' scrapped with code ' ||

			pPartScrapcode || ' with description ' ||

			pPartScrapDescription || '.';



	PERFORM (SELECT enterpartlog(	'Manufacturing'::TEXT, 

					'Scrapped'::TEXT,

					pItemNumber,

					pRevision,

					pSerialNumber,

					'Scrap History'::TEXT,

					_partScrapHistId,

					_message));



	RETURN true;

END;$_$;


ALTER FUNCTION public.scrappart(text, text, text, text, text, boolean) OWNER TO admin;

--
-- TOC entry 434 (class 1255 OID 36871)
-- Name: scrapsummsubass(text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION scrapsummsubass(text, text, text, text, text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pItemNumber 		ALIAS FOR $1;

	pRevision 		ALIAS FOR $2;

	pSerialNumber 		ALIAS FOR $3;

	pPartScrapCode 		ALIAS FOR $4;

	pPartScrapDescription 	ALIAS FOR $5;

	_viewpart 		RECORD;

	_usrId 			INTEGER;

	_r			RECORD;

  

BEGIN

	_usrID := (SELECT getusrid());  

	PERFORM (SELECT checkpriv('scrapsummsubass'));

	PERFORM (SELECT validatepart(pItemNumber, pRevision, pSerialNumber));



	SELECT 	part_id, 

		item_id, 

		item_number, 

		part_serialnumber, 

		part_sequencenumber,

		part_cust_id,

		loc_number

	INTO _viewpart

	FROM viewpart

	WHERE item_number = pItemNumber 

	AND part_serialnumber = pSerialNumber 

	AND part_rev = pRevision;

	

	PERFORM (SELECT scrappart(	pItemNumber, 

					pRevision,

					pSerialNumber,

					pPartScrapCode,

					pPartScrapDescription));



	FOR _r IN

		SELECT *

		FROM summsubass(	pItemNumber,

					pRevision,

					pSerialNumber)

	LOOP

		IF _r.c_item_number IS NOT NULL THEN

			PERFORM (SELECT scrappart(	_r.c_item_number,

							_r.c_part_rev,

							_r.c_part_serialnumber,

							pPartScrapCode,

							pPartScrapDescription,

							false));

		END IF;

	END LOOP;

	

	RETURN true;

END;$_$;


ALTER FUNCTION public.scrapsummsubass(text, text, text, text, text) OWNER TO postgres;

--
-- TOC entry 436 (class 1255 OID 36872)
-- Name: serialbom(text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION serialbom(text, text) RETURNS TABLE(t_item_number text, t_bom_itemrev text, t_bom_qtyper numeric, p_item_number text, p_bom_itemrev text, p_bom_qtyper numeric, c_item_number text, c_bom_itemrev text, c_bom_qtyper numeric)
    LANGUAGE plpgsql
    AS $_$DECLARE

	pItemNumber ALIAS FOR $1;

	pRevision ALIAS FOR $2;

	_item RECORD;

  

BEGIN

	PERFORM (SELECT checkpriv('serialbom'));



	SELECT item_id, item_serialstream_id, serialprefix_prefix, serialpattern_pattern, itemfreqcode_freqcode

	INTO _item

	FROM item 

	LEFT OUTER JOIN serialstream ON item_serialstream_id = serialstream_id

	LEFT OUTER JOIN serialprefix ON item_serialprefix_id = serialprefix_id

	LEFT OUTER JOIN serialpattern ON serialprefix_serialpattern_id = serialpattern_id

	LEFT OUTER JOIN itemfreqcode ON item_itemfreqcode_id = itemfreqcode_id

	WHERE item_number = pItemNumber 

	AND item_active = true;



	IF _item.item_id IS NULL THEN

		RAISE EXCEPTION 'serialbom: Item Number % not found in AeryonMES', pItemNumber;

	END IF;



	IF (SELECT itemrev_id

	    FROM itemrev

	    WHERE itemrev_item_id = _item.item_id

	    AND itemrev_rev = pRevision) IS NULL THEN

		RAISE EXCEPTION 'serialbom: Revision % of Selected Item % Not Found in AeryonMES', pRevision, pItemNumber;

	END IF;



	RETURN QUERY (WITH RECURSIVE b(	t_bom_item_id, 

					t_bom_itemrev,

					t_bom_qtyper,

					p_bom_item_id, 

					p_bom_itemrev, 

					p_bom_qtyper,

					p_item_phantom,

					c_bom_item_id, 

					c_bom_itemrev,

					c_bom_qtyper,

					c_item_phantom) 

			AS(	SELECT	p.bom_parent_item_id 	AS t_bom_item_id,

					p.bom_parent_itemrev 	AS t_bom_itemrev,

					1::NUMERIC(20, 8)	AS t_bom_qtyper,

					p.bom_parent_item_id 	AS p_bom_item_id,

					p.bom_parent_itemrev 	AS p_bom_itemrev,

					1::NUMERIC(20, 8)	AS p_bom_qtyper,

					i2.item_phantom		AS p_item_phantom,

					p.bom_item_id		AS c_bom_item_id,

					p.bom_itemrev		AS c_bom_itemrev,

					p.bom_qtyper		AS c_bom_qtyper,

					i3.item_phantom		AS c_item_phantom

				FROM	bom p

				LEFT OUTER JOIN item i2

					ON i2.item_id = bom_parent_item_id

				LEFT OUTER JOIN item i3

					ON i3.item_id = p.bom_item_id

				WHERE 	p.bom_parent_item_id = _item.item_id

				AND 	p.bom_parent_itemrev = pRevision

				AND 	COALESCE(p.bom_effective, now()) <= now()

				AND 	COALESCE(p.bom_expires, now()) >= now()

			UNION ALL

				SELECT 	b.t_bom_item_id 	AS t_bom_item_id,

					b.t_bom_itemrev 	AS t_bom_itemrev,

					b.t_bom_qtyper		AS t_bom_qtyper,

					b.c_bom_item_id 	AS p_bom_item_id,

					b.c_bom_itemrev 	AS p_bom_itemrev,

					b.c_bom_qtyper 		AS p_bom_qtyper,

					b.c_item_phantom	AS p_item_phantom,

					c.bom_item_id		AS c_bom_item_id,

					c.bom_itemrev		AS c_bom_itemrev,

					(c.bom_qtyper * b.c_bom_qtyper)::NUMERIC(20, 8)

								AS c_bom_qtyper,

					i3.item_phantom		AS c_item_phantom

				FROM 	b

				LEFT OUTER JOIN bom c

					ON c.bom_parent_item_id = b.c_bom_item_id

				LEFT OUTER JOIN item i3

					ON i3.item_id = c.bom_item_id

				WHERE 	c.bom_parent_item_id = b.c_bom_item_id

				AND 	c.bom_parent_itemrev = b.c_bom_itemrev

				AND 	COALESCE(c.bom_effective, now()) <= now()

				AND 	COALESCE(c.bom_expires, now()) >= now()

				AND	b.c_item_phantom = true

			)

		SELECT 	i1.item_number AS t_item_number, 

			b.t_bom_itemrev, 

			b.t_bom_qtyper, 

			i2.item_number AS p_item_number, 

			b.p_bom_itemrev, 

			b.p_bom_qtyper, 

			i3.item_number AS c_item_number, 

			b.c_bom_itemrev, 

			b.c_bom_qtyper

		FROM 	b

		LEFT OUTER JOIN item i1

			ON b.t_bom_item_id = i1.item_id

		LEFT OUTER JOIN item i2

			ON b.p_bom_item_id = i2.item_id

		LEFT OUTER JOIN item i3

			ON b.c_bom_item_id = i3.item_id

		WHERE i3.item_serialized = true

		AND b.c_item_phantom = false);

		  

	RETURN;

END;$_$;


ALTER FUNCTION public.serialbom(text, text) OWNER TO admin;

--
-- TOC entry 437 (class 1255 OID 36873)
-- Name: serialsubass(text, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION serialsubass(text, text, text) RETURNS TABLE(t_item_number text, t_part_rev text, t_part_serialnumber text, t_part_sequencenumber integer, t_part_parent_allocorder integer, p_item_number text, p_part_rev text, p_part_serialnumber text, p_part_sequencenumber integer, p_part_parent_allocorder integer, c_item_number text, c_part_rev text, c_part_serialnumber text, c_part_sequencenumber integer, c_part_parent_allocorder integer)
    LANGUAGE plpgsql
    AS $_$DECLARE

	pItemNumber ALIAS FOR $1;

	pRevision ALIAS FOR $2;

	pSerialNumber ALIAS FOR $3;

	_viewpart RECORD;

  

BEGIN

	PERFORM (SELECT checkpriv('serialsubass'));

	PERFORM (SELECT validatepart(pItemNumber, pRevision, pSerialNumber));



	SELECT 	part_id, 

		item_id, 

		item_number, 

		part_serialnumber, 

		part_sequencenumber

	INTO _viewpart

	FROM viewpart

	WHERE item_number = pItemNumber 

	AND part_serialnumber = pSerialNumber 

	AND part_rev = pRevision;



	RETURN QUERY (WITH a(		t_part_id,

					t_part_item_id,

					t_part_rev,

					t_part_serialnumber,

					t_part_sequencenumber,

					t_part_parent_part_id,

					t_part_allocpos,

					p_part_id,

					p_part_item_id,

					p_part_rev,

					p_part_serialnumber,

					p_part_sequencenumber,

					p_part_parent_part_id,

					p_part_allocpos,

					p_item_phantom,

					c_part_id,

					c_part_item_id,

					c_part_rev,

					c_part_serialnumber,

					c_part_sequencenumber,

					c_part_parent_part_id,

					c_part_allocpos,

					c_item_phantom) 

			AS(	SELECT	p.part_id			AS t_part_id,

					p.part_item_id			AS t_part_item_id,

					p.part_rev			AS t_part_rev,

					p.part_serialnumber		AS t_part_serialnumber,

					p.part_sequencenumber		AS t_part_sequencenumber,

					p.part_parent_part_id		AS t_part_parent_part_id,

					p.part_allocpos			AS t_part_allocpos,

					p.part_id			AS p_part_id,

					p.part_item_id			AS p_part_item_id,

					p.part_rev			AS p_part_rev,

					p.part_serialnumber		AS p_part_serialnumber,

					p.part_sequencenumber		AS p_part_sequencenumber,

					p.part_parent_part_id		AS p_part_parent_part_id,

					p.part_allocpos			AS p_part_allocpos,

					i2.item_phantom			AS p_item_phantom,

					c.part_id			AS c_part_id,

					c.part_item_id			AS c_part_item_id,

					c.part_rev			AS c_part_rev,

					c.part_serialnumber		AS c_part_serialnumber,

					c.part_sequencenumber		AS c_part_sequencenumber,

					c.part_parent_part_id		AS c_part_parent_part_id,

					c.part_allocpos			AS c_part_allocpos,

					i3.item_phantom			AS c_item_phantom

				FROM	part p

				LEFT OUTER JOIN part c

					ON p.part_id = c.part_parent_part_id

				LEFT OUTER JOIN item i2

					ON i2.item_id = p.part_item_id

				LEFT OUTER JOIN item i3

					ON i3.item_id = c.part_item_id

				WHERE 	p.part_id = _viewpart.part_id

			-- UNION ALL

-- 				SELECT	p.part_id			AS t_part_id,

-- 					p.part_item_id			AS t_part_item_id,

-- 					p.part_rev			AS t_part_rev,

-- 					p.part_serialnumber		AS t_part_serialnumber,

-- 					p.part_sequencenumber		AS t_part_sequencenumber,

-- 					p.part_parent_part_id		AS t_part_parent_part_id,

-- 					p.part_allocpos			AS t_part_allocpos,

-- 					p.part_id			AS p_part_id,

-- 					p.part_item_id			AS p_part_item_id,

-- 					p.part_rev			AS p_part_rev,

-- 					p.part_serialnumber		AS p_part_serialnumber,

-- 					p.part_sequencenumber		AS p_part_sequencenumber,

-- 					p.part_parent_part_id		AS p_part_parent_part_id,

-- 					p.part_allocpos			AS p_part_allocpos,

-- 					i2.item_phantom			AS p_item_phantom,

-- 					c.part_id			AS c_part_id,

-- 					c.part_item_id			AS c_part_item_id,

-- 					c.part_rev			AS c_part_rev,

-- 					c.part_serialnumber		AS c_part_serialnumber,

-- 					c.part_sequencenumber		AS c_part_sequencenumber,

-- 					c.part_parent_part_id		AS c_part_parent_part_id,

-- 					c.part_allocpos			AS c_part_allocpos,

-- 					i3.item_phantom			AS c_item_phantom

-- 				FROM	part p

-- 				LEFT OUTER JOIN part c

-- 					ON p.part_id = c.part_parent_part_id

-- 				LEFT OUTER JOIN item i2

-- 					ON i2.item_id = a.p_part_item_id

-- 				LEFT OUTER JOIN item i3

-- 					ON i3.item_id = c.part_item_id

-- 				WHERE 	p.part_id = _viewpart.part_id

-- 				AND	a.c_item_phantom = true

			)

		SELECT 	i1.item_number AS t_item_number, 

			a.t_part_rev,

			a.t_part_serialnumber,

			a.t_part_sequencenumber,

			a.t_part_allocpos,

			i2.item_number AS p_item_number, 

			a.p_part_rev,

			a.p_part_serialnumber,

			a.p_part_sequencenumber,

			a.p_part_allocpos,

			i3.item_number AS c_item_number, 

			a.c_part_rev,

			a.c_part_serialnumber,

			a.c_part_sequencenumber,

			a.c_part_allocpos 

		FROM 	a

		LEFT OUTER JOIN item i1

			ON a.t_part_item_id = i1.item_id

		LEFT OUTER JOIN item i2

			ON a.p_part_item_id = i2.item_id

		LEFT OUTER JOIN item i3

			ON a.c_part_item_id = i3.item_id);

		  

	RETURN;

END;$_$;


ALTER FUNCTION public.serialsubass(text, text, text) OWNER TO admin;

--
-- TOC entry 438 (class 1255 OID 36874)
-- Name: summbom(text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION summbom(text, text) RETURNS TABLE(t_item_number text, t_bom_itemrev text, t_bom_qtyper numeric, p_item_number text, p_bom_itemrev text, p_bom_qtyper numeric, c_item_number text, c_bom_itemrev text, c_bom_qtyper numeric)
    LANGUAGE plpgsql
    AS $_$DECLARE

	pItemNumber ALIAS FOR $1;

	pRevision ALIAS FOR $2;

	_item RECORD;

  

BEGIN

	PERFORM (SELECT checkpriv('summbom'));



	SELECT item_id, item_serialstream_id, serialprefix_prefix, serialpattern_pattern, itemfreqcode_freqcode

	INTO _item

	FROM item 

	LEFT OUTER JOIN serialstream ON item_serialstream_id = serialstream_id

	LEFT OUTER JOIN serialprefix ON item_serialprefix_id = serialprefix_id

	LEFT OUTER JOIN serialpattern ON serialprefix_serialpattern_id = serialpattern_id

	LEFT OUTER JOIN itemfreqcode ON item_itemfreqcode_id = itemfreqcode_id

	WHERE item_number = pItemNumber 

	AND item_active = true;



	IF _item.item_id IS NULL THEN

		RAISE EXCEPTION 'summbom: Item Number % not found in AeryonMES', pItemNumber;

	END IF;



	IF (SELECT itemrev_id

	    FROM itemrev

	    WHERE itemrev_item_id = _item.item_id

	    AND itemrev_rev = pRevision) IS NULL THEN

		RAISE EXCEPTION 'summbom: Revision % of Selected Item % Not Found in AeryonMES', pRevision, pItemNumber;

	END IF;



	RETURN QUERY (WITH RECURSIVE b(	t_bom_item_id, 

					t_bom_itemrev,

					t_bom_qtyper,

					p_bom_item_id, 

					p_bom_itemrev, 

					p_bom_qtyper,

					c_bom_item_id, 

					c_bom_itemrev,

					c_bom_qtyper) 

			AS(	SELECT	p.bom_parent_item_id 	AS t_bom_item_id,

					p.bom_parent_itemrev 	AS t_bom_itemrev,

					1::NUMERIC(20, 8)	AS t_bom_qtyper,

					p.bom_parent_item_id 	AS p_bom_item_id,

					p.bom_parent_itemrev 	AS p_bom_itemrev,

					1::NUMERIC(20, 8)	AS p_bom_qtyper,

					p.bom_item_id		AS c_bom_item_id,

					p.bom_itemrev		AS c_bom_itemrev,

					p.bom_qtyper		AS c_bom_qtyper

				FROM	bom p

				WHERE 	p.bom_parent_item_id = _item.item_id

				AND 	p.bom_parent_itemrev = pRevision

				AND 	COALESCE(p.bom_effective, now()) <= now()

				AND 	COALESCE(p.bom_expires, now()) >= now()

			UNION ALL

				SELECT 	b.t_bom_item_id 	AS t_bom_item_id,

					b.t_bom_itemrev 	AS t_bom_itemrev,

					b.t_bom_qtyper		AS t_bom_qtyper,

					b.c_bom_item_id 	AS p_bom_item_id,

					b.c_bom_itemrev 	AS p_bom_itemrev,

					b.c_bom_qtyper 		AS p_bom_qtyper,

					c.bom_item_id		AS c_bom_item_id,

					c.bom_itemrev		AS c_bom_itemrev,

					(c.bom_qtyper * b.c_bom_qtyper)::NUMERIC(20, 8)

								AS c_bom_qtyper

				FROM 	b

				LEFT OUTER JOIN bom c

					ON c.bom_parent_item_id = b.c_bom_item_id

				WHERE 	c.bom_parent_item_id = b.c_bom_item_id

				AND 	c.bom_parent_itemrev = b.c_bom_itemrev

				AND 	COALESCE(c.bom_effective, now()) <= now()

				AND 	COALESCE(c.bom_expires, now()) >= now()

			)

		SELECT 	i1.item_number AS t_item_number, 

			b.t_bom_itemrev, 

			b.t_bom_qtyper, 

			i2.item_number AS p_item_number, 

			b.p_bom_itemrev, 

			b.p_bom_qtyper, 

			i3.item_number AS c_item_number, 

			b.c_bom_itemrev, 

			b.c_bom_qtyper

		FROM 	b

		LEFT OUTER JOIN item i1

			ON b.t_bom_item_id = i1.item_id

		LEFT OUTER JOIN item i2

			ON b.p_bom_item_id = i2.item_id

		LEFT OUTER JOIN item i3

			ON b.c_bom_item_id = i3.item_id);

		  

	RETURN;

END;$_$;


ALTER FUNCTION public.summbom(text, text) OWNER TO admin;

--
-- TOC entry 439 (class 1255 OID 36875)
-- Name: summsubass(text, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION summsubass(text, text, text) RETURNS TABLE(t_item_number text, t_part_rev text, t_part_serialnumber text, t_part_sequencenumber integer, t_part_parent_allocorder integer, p_item_number text, p_part_rev text, p_part_serialnumber text, p_part_sequencenumber integer, p_part_parent_allocorder integer, c_item_number text, c_part_rev text, c_part_serialnumber text, c_part_sequencenumber integer, c_part_parent_allocorder integer)
    LANGUAGE plpgsql
    AS $_$DECLARE

	pItemNumber ALIAS FOR $1;

	pRevision ALIAS FOR $2;

	pSerialNumber ALIAS FOR $3;

	_viewpart RECORD;

  

BEGIN

	PERFORM (SELECT checkpriv('summsubass'));

	PERFORM (SELECT validatepart(pItemNumber, pRevision, pSerialNumber, null, true));



	SELECT 	part_id, 

		item_id, 

		item_number, 

		part_serialnumber, 

		part_sequencenumber

	INTO _viewpart

	FROM viewpart

	WHERE item_number = pItemNumber 

	AND part_serialnumber = pSerialNumber 

	AND part_rev = pRevision;



	RETURN QUERY (WITH RECURSIVE a(	t_part_id,

					t_part_item_id,

					t_part_rev,

					t_part_serialnumber,

					t_part_sequencenumber,

					t_part_parent_part_id,

					t_part_allocpos,

					p_part_id,

					p_part_item_id,

					p_part_rev,

					p_part_serialnumber,

					p_part_sequencenumber,

					p_part_parent_part_id,

					p_part_allocpos,

					c_part_id,

					c_part_item_id,

					c_part_rev,

					c_part_serialnumber,

					c_part_sequencenumber,

					c_part_parent_part_id,

					c_part_allocpos) 

			AS(	SELECT	p.part_id			AS t_part_id,

					p.part_item_id			AS t_part_item_id,

					p.part_rev			AS t_part_rev,

					p.part_serialnumber		AS t_part_serialnumber,

					p.part_sequencenumber		AS t_part_sequencenumber,

					p.part_parent_part_id		AS t_part_parent_part_id,

					p.part_allocpos	AS t_part_allocpos,

					p.part_id			AS p_part_id,

					p.part_item_id			AS p_part_item_id,

					p.part_rev			AS p_part_rev,

					p.part_serialnumber		AS p_part_serialnumber,

					p.part_sequencenumber		AS p_part_sequencenumber,

					p.part_parent_part_id		AS p_part_parent_part_id,

					p.part_allocpos	AS p_part_allocpos,

					c.part_id			AS c_part_id,

					c.part_item_id			AS c_part_item_id,

					c.part_rev			AS c_part_rev,

					c.part_serialnumber		AS c_part_serialnumber,

					c.part_sequencenumber		AS c_part_sequencenumber,

					c.part_parent_part_id		AS c_part_parent_part_id,

					c.part_allocpos	AS c_part_allocpos

				FROM	part p

				LEFT OUTER JOIN part c

					ON p.part_id = c.part_parent_part_id

				WHERE 	p.part_id = _viewpart.part_id

			UNION ALL

				SELECT 	a.t_part_id			AS t_part_id,

					a.t_part_item_id		AS t_part_item_id,

					a.t_part_rev			AS t_part_rev,

					a.t_part_serialnumber		AS t_part_serialnumber,

					a.t_part_sequencenumber		AS t_part_sequencenumber,

					a.t_part_parent_part_id		AS t_part_parent_part_id,

					a.t_part_allocpos	AS t_part_allocpos,

					a.c_part_id			AS p_part_id,

					a.c_part_item_id		AS p_part_item_id,

					a.c_part_rev			AS p_part_rev,

					a.c_part_serialnumber		AS p_part_serialnumber,

					a.c_part_sequencenumber		AS p_part_sequencenumber,

					a.c_part_parent_part_id		AS p_part_parent_part_id,

					a.c_part_allocpos	AS p_part_allocpos,

					c.part_id			AS c_part_id,

					c.part_item_id			AS c_part_item_id,

					c.part_rev			AS c_part_rev,

					c.part_serialnumber		AS c_part_serialnumber,

					c.part_sequencenumber		AS c_part_sequencenumber,

					c.part_parent_part_id		AS c_part_parent_part_id,

					c.part_allocpos	AS c_part_allocpos

				FROM 	a

				LEFT OUTER JOIN part c

					ON a.c_part_id = c.part_parent_part_id

				WHERE 	a.c_part_id = c.part_parent_part_id

			)

		SELECT 	i1.item_number AS t_item_number, 

			a.t_part_rev,

			a.t_part_serialnumber,

			a.t_part_sequencenumber,

			a.t_part_allocpos,

			i2.item_number AS p_item_number, 

			a.p_part_rev,

			a.p_part_serialnumber,

			a.p_part_sequencenumber,

			a.p_part_allocpos,

			i3.item_number AS c_item_number, 

			a.c_part_rev,

			a.c_part_serialnumber,

			a.c_part_sequencenumber,

			a.c_part_allocpos 

		FROM 	a

		LEFT OUTER JOIN item i1

			ON a.t_part_item_id = i1.item_id

		LEFT OUTER JOIN item i2

			ON a.p_part_item_id = i2.item_id

		LEFT OUTER JOIN item i3

			ON a.c_part_item_id = i3.item_id);

		  

	RETURN;

END;$_$;


ALTER FUNCTION public.summsubass(text, text, text) OWNER TO admin;

--
-- TOC entry 440 (class 1255 OID 36876)
-- Name: transfercustparamcombo(integer, integer); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION transfercustparamcombo(integer, integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pOldParamId		ALIAS FOR $1;

	pNewParamId 		ALIAS FOR $2;

	_dataTypeId		INTEGER;

	_r			RECORD;

	_oldParamId		INTEGER;

	_newParamId		INTEGER;

  

BEGIN

	PERFORM (SELECT getusrid());

	PERFORM (SELECT checkpriv('transfercustparamcombo'));



	IF pOldParamId IS NULL THEN

		RAISE EXCEPTION 'transfercustparamcombo: Custom Parameter ID cannot be null.';

	END IF;



	IF pNewParamId IS NULL THEN

		RAISE EXCEPTION 'transfercustparamcombo: Custom Parameter ID cannot be null.';

	END IF;



	_oldParamId := (SELECT custparam_id FROM custparam WHERE custparam_id = pOldParamId);

	IF _oldParamId IS NULL THEN

		RAISE EXCEPTION 'transfercustparamcombo: Old Custom Parameter ID cannot be found on custparam table.';

	END IF;



	_oldParamId := (SELECT custparamcombo_id FROM custparamcombo WHERE custparamcombo_custparam_id = pOldParamId);

	IF _oldParamId IS NULL THEN

		RETURN true;

	END IF;

	

	_newParamId := (SELECT custparam_id FROM custparam WHERE custparam_id = pNewParamId);

	IF _newParamId IS NULL THEN

		RAISE EXCEPTION 'transfercustparamcombo: New Custom Parameter ID cannot be found on custparam table.';

	END IF;

	

	FOR _r IN

		SELECT 	custparamcombo_item_id, 

			custparamcombo_recordtype_id

		FROM custparamcombo

		WHERE custparamcombo_custparam_id = pOldParamId

	LOOP

		IF _r.custparamcombo_item_id IS NOT NULL THEN

			INSERT INTO custparamcombo

				(custparamcombo_custparam_id,

				 custparamcombo_value, 

				 custparamcombo_active)

			VALUES	(pNewParamId,

				 _r.custparamcombo_value,

				 _r.custparamcombo_active);

		END IF;

	END LOOP; 



	UPDATE custparamcombo

	SET custparamcombo_active = false

	WHERE custparamcombo_custparam_id = pOldParamId;

	

	RETURN true;

END;$_$;


ALTER FUNCTION public.transfercustparamcombo(integer, integer) OWNER TO admin;

--
-- TOC entry 441 (class 1255 OID 36877)
-- Name: transfercustparamlinkitem(integer, integer); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION transfercustparamlinkitem(integer, integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pOldParamId		ALIAS FOR $1;

	pNewParamId 		ALIAS FOR $2;

	_dataTypeId		INTEGER;

	_r			RECORD;

	_oldParamId		INTEGER;

	_newParamId		INTEGER;

  

BEGIN

	PERFORM (SELECT getusrid());

	PERFORM (SELECT checkpriv('transfercustparamlinkitem'));



	IF pOldParamId IS NULL THEN

		RAISE EXCEPTION 'transfercustparamlinkitem: Custom Parameter ID cannot be null.';

	END IF;



	IF pNewParamId IS NULL THEN

		RAISE EXCEPTION 'transfercustparamlinkitem: Custom Parameter ID cannot be null.';

	END IF;



	_oldParamId := (SELECT custparam_id FROM custparam WHERE custparam_id = pOldParamId);

	IF _oldParamId IS NULL THEN

		RAISE EXCEPTION 'transfercustparamlinkitem: Old Custom Parameter ID cannot be found on custparam table.';

	END IF;



	_oldParamId := (SELECT itemcustparamlink_id FROM itemcustparamlink WHERE itemcustparamlink_custparam_id = pOldParamId);

	IF _oldParamId IS NULL THEN

		RETURN true;

	END IF;

	

	_newParamId := (SELECT custparam_id FROM custparam WHERE custparam_id = pNewParamId);

	IF _newParamId IS NULL THEN

		RAISE EXCEPTION 'transfercustparamlinkitem: New Custom Parameter ID cannot be found on custparam table.';

	END IF;

	

	FOR _r IN

		SELECT 	itemcustparamlink_item_id,

			itemcustparamlink_active

		FROM itemcustparamlink

		WHERE itemcustparamlink_custparam_id = pOldParamId

	LOOP

		IF _r.itemcustparamlink_item_id IS NOT NULL THEN

			INSERT INTO itemcustparamlink

				(itemcustparamlink_custparam_id,

				 itemcustparamlink_item_id, 

				 itemcustparamlink_active)

			VALUES	(pNewParamId,

				 _r.itemcustparamlink_item_id,

				 _r.itemcustparamlink_active);

		END IF;

	END LOOP; 



	UPDATE itemcustparamlink

	SET itemcustparamlink_active = false

	WHERE itemcustparamlink_custparam_id = pOldParamId;

	

	RETURN true;

END;$_$;


ALTER FUNCTION public.transfercustparamlinkitem(integer, integer) OWNER TO admin;

--
-- TOC entry 442 (class 1255 OID 36878)
-- Name: transfercustparamlinkrecord(integer, integer); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION transfercustparamlinkrecord(integer, integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pOldParamId		ALIAS FOR $1;

	pNewParamId 		ALIAS FOR $2;

	_dataTypeId		INTEGER;

	_r			RECORD;

	_oldParamId		INTEGER;

	_newParamId		INTEGER;

  

BEGIN

	PERFORM (SELECT getusrid());

	PERFORM (SELECT checkpriv('transfercustparamlinkrecord'));



	IF pOldParamId IS NULL THEN

		RAISE EXCEPTION 'transfercustparamlinkrecord: Custom Parameter ID cannot be null.';

	END IF;



	IF pNewParamId IS NULL THEN

		RAISE EXCEPTION 'transfercustparamlinkrecord: Custom Parameter ID cannot be null.';

	END IF;



	_oldParamId := (SELECT custparam_id FROM custparam WHERE custparam_id = pOldParamId);

	IF _oldParamId IS NULL THEN

		RAISE EXCEPTION 'transfercustparamlinkrecord: Old Custom Parameter ID cannot be found on custparam table.';

	END IF;



	_oldParamId := (SELECT recordcustparamlink_id FROM recordcustparamlink WHERE recordcustparamlink_custparam_id = pOldParamId);

	IF _oldParamId IS NULL THEN

		RETURN true;

	END IF;

	

	_newParamId := (SELECT custparam_id FROM custparam WHERE custparam_id = pNewParamId);

	IF _newParamId IS NULL THEN

		RAISE EXCEPTION 'transfercustparamlinkrecord: New Custom Parameter ID cannot be found on custparam table.';

	END IF;

	

	FOR _r IN

		SELECT 	recordcustparamlink_recordtype_id,

			recordcustparamlink_active

		FROM recordcustparamlink

		WHERE recordcustparamlink_custparam_id = pOldParamId

	LOOP

		IF _r.recordcustparamlink_recordtype_id IS NOT NULL THEN

			INSERT INTO recordcustparamlink

				(recordcustparamlink_custparam_id,

				 recordcustparamlink_recordtype_id,

				 recordcustparamlink_active)

			VALUES	(pNewParamId,

				 _r.recordcustparamlink_recordtype_id,

				 _r.recordcustparamlink_active);

		END IF;

	END LOOP; 



	UPDATE recordcustparamlink

	SET recordcustparamlink_active = false

	WHERE recordcustparamlink_custparam_id = pOldParamId;

	

	RETURN true;

END;$_$;


ALTER FUNCTION public.transfercustparamlinkrecord(integer, integer) OWNER TO admin;

--
-- TOC entry 428 (class 1255 OID 36879)
-- Name: updatebackflush(integer, text, text, text, integer, text, text, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION updatebackflush(integer, text, text, text, integer, text, text, text, text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pBackflushId	ALIAS FOR $1;

	pItemNumber 	ALIAS FOR $2;

	pRevision 	ALIAS FOR $3;

	pSerialNumber 	ALIAS FOR $4;

	pQty 		ALIAS FOR $5;

	pDocType 	ALIAS FOR $6;

	pDocNumber 	ALIAS FOR $7;

	pLine		ALIAS FOR $8;

	pStation	ALIAS FOR $9;

	_itemId		INTEGER;

	_viewpart 	RECORD;

	_backflushCheck	RECORD;

	_backflushId	INTEGER;

	_docTypeId	INTEGER;

	_usrId 		INTEGER;

	_message 	TEXT;

  

BEGIN

	_usrId := (SELECT getusrid()); 

	PERFORM (SELECT checkpriv('updatebackflush'));





	IF pQty < 0 THEN

		RAISE EXCEPTION 'updatebackflush: Backflush Qty cannot be less than 0.';

	END IF;



	_itemId := (SELECT getitemid(pItemNumber));

	_docTypeId := (SELECT getdoctypeid(pDocType));

	

	IF pSerialNumber IS NOT NULL THEN

		PERFORM (SELECT validatepart(pItemNumber, pRevision, pSerialNumber));

	END IF;



	SELECT 	backflush_id, 

		backflush_part_id,

		item_number, 

		backflush_orig_item_id, 

		backflush_orig_rev, 

		backflush_orig_serialnumber, 

		backflush_qty, 

		doctype_name, 

		backflush_docnumber,

		backflush_void_timestamp, 

		backflush_complete_timestamp

	INTO _backflushCheck

	FROM backflush 

	LEFT OUTER JOIN item ON item_id = backflush_orig_item_id

	LEFT OUTER JOIN doctype ON doctype_id = backflush_doctype_id

	WHERE backflush_id = pBackflushId;

	

	IF _backflushCheck.backflush_id IS NULL THEN

		RAISE EXCEPTION 'updatebackflush: Backflush ID % does not exist.',

			pBackflushId;

	ELSIF _backflushCheck.backflush_void_timestamp IS NOT NULL THEN

		RAISE EXCEPTION 'updatebackflush: Backflush ID % is VOID and cannot be updated.',

			pBackflushId;

	ELSIF _backflushCheck.backflush_complete_timestamp IS NOT NULL THEN

		RAISE EXCEPTION 'updatebackflush: Backflush ID % is COMPLETE and cannot be updated.',

			pBackflushId;

	END IF;



	PERFORM (SELECT voidbackflush(pBackflushId, 'UPDATE', 'Void existing ID to insert updated backflush information.'));

	

	RETURN (SELECT enterbackflush(pItemNumber, pRevision, pSerialNumber, pQty, pDocType, pDocNumber, pLine, pStation));

END;$_$;


ALTER FUNCTION public.updatebackflush(integer, text, text, text, integer, text, text, text, text) OWNER TO admin;

--
-- TOC entry 429 (class 1255 OID 36880)
-- Name: validatepart(text, text, text, text, boolean); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION validatepart(text, text, text, text DEFAULT NULL::text, boolean DEFAULT false) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pItemNumber 	ALIAS FOR $1;

	pRevision 	ALIAS FOR $2;

	pSerialNumber 	ALIAS FOR $3;

	pCode		ALIAS FOR $4;

	pAllowInactive	ALIAS FOR $5;

	_viewpart	RECORD;

	_code		TEXT;

BEGIN

	PERFORM (SELECT checkpriv('validatepart'));



	SELECT 	part_id,

		part_active

	INTO _viewpart

	FROM viewpart

	WHERE item_number = pItemNumber 

	AND part_serialnumber = pSerialNumber 

	AND part_rev = pRevision;



	IF pCode IS NULL THEN

		_code := '';

	ELSE

		_code := ' ' || pCode;

	END IF;



	IF _viewpart.part_id IS NULL THEN

		RAISE EXCEPTION 'validatepart:% Item Number % Revision % Serial Number % Not Found in AeryonMES.', 

			_code,

			pItemNumber, 

			pRevision, 

			pSerialNumber;

	ELSIF _viewpart.part_active = false AND pAllowInactive = false THEN

		RAISE EXCEPTION 'validatepart:% Item Number % Revision % Serial Number % Is Inactive.', 

			_code,

			pItemNumber, 

			pRevision, 

			pSerialNumber;

	END IF;



	RETURN true;

END;



	$_$;


ALTER FUNCTION public.validatepart(text, text, text, text, boolean) OWNER TO admin;

--
-- TOC entry 435 (class 1255 OID 36881)
-- Name: voidbackflush(integer, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION voidbackflush(integer, text, text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$DECLARE

	pBackflushId	ALIAS FOR $1;

	pVoidType	ALIAS FOR $2;

	pVoidReason	ALIAS FOR $3;

	_backflushCheck	RECORD;

	_usrId 		INTEGER;

	_message 	TEXT;

  

BEGIN

	_usrId := (SELECT getusrid()); 

	PERFORM (SELECT checkpriv('voidbackflush'));



	SELECT 	backflush_id, 

		backflush_part_id,

		pitem.item_number AS part_item_number,

		part_rev,

		part_serialnumber,

		oitem.item_number AS orig_item_number, 

		backflush_orig_item_id, 

		backflush_orig_rev, 

		backflush_orig_serialnumber, 

		backflush_qty, 

		doctype_name, 

		backflush_docnumber,

		backflush_void_timestamp, 

		backflush_complete_timestamp

	INTO _backflushCheck

	FROM backflush 

	LEFT OUTER JOIN item AS oitem ON oitem.item_id = backflush_orig_item_id

	LEFT OUTER JOIN part ON part_id = backflush_part_id

	LEFT OUTER JOIN item AS pitem ON pitem.item_id = backflush_orig_item_id

	LEFT OUTER JOIN doctype ON doctype_id = backflush_doctype_id

	WHERE backflush_id = pBackflushId;

	

	IF _backflushCheck.backflush_id IS NULL THEN

		RAISE EXCEPTION 'voidbackflush: Backflush ID % does not exist.',

			pBackflushId;

	ELSIF _backflushCheck.backflush_void_timestamp IS NOT NULL THEN

		RAISE EXCEPTION 'voidbackflush: Backflush ID % is VOID and cannot be voided.',

			pBackflushId;

	ELSIF _backflushCheck.backflush_complete_timestamp IS NOT NULL THEN

		RAISE EXCEPTION 'voidbackflush: Backflush ID % is COMPLETE and cannot be voided.',

			pBackflushId;

	END IF;

	

	UPDATE backflush

	SET	(backflush_void_usr_id,

		 backflush_void_timestamp,

		 backflush_void_type,

		 backflush_void_reason)

	=	(_usrId,

		 now(),

		 pVoidType,

		 pVoidReason)

	WHERE backflush_id = pBackflushId;



	UPDATE part

	SET (part_backflushed) = (false)

	WHERE part_id = _backflushCheck.backflush_part_id;

	

	_message := 	'Backflush ID ' ||

			pBackflushID || ' voided: ' ||

			_backflushCheck.orig_item_number || ' ' || 

			_backflushCheck.backflush_orig_rev || ' ' || 

			_backflushCheck.backflush_orig_serialnumber || ' qty ' || 

			_backflushCheck.backflush_qty || ' on ' || 

			_backflushCheck.doctype_name || ' ' || 

			_backflushCheck.backflush_docnumber || ' - VoidType: ' ||

			pVoidType || ' - Reason: ' ||

			pVoidReason || '.';



	PERFORM (SELECT enterpartlog(	'Manufacturing'::TEXT, 

					'Void Backflush'::TEXT,

					_backflushCheck.part_item_number,

					_backflushCheck.part_rev,

					_backflushCheck.part_serialnumber,

					'Backflush ID'::TEXT,

					pBackflushId,

					_message,

					_backflushCheck.doctype_name, 

					_backflushCheck.backflush_docnumber));



	RETURN true;

END;$_$;


ALTER FUNCTION public.voidbackflush(integer, text, text) OWNER TO admin;

SET default_tablespace = '';

SET default_with_oids = true;


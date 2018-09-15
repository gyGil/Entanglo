-- View: public.viewbackflush

-- DROP VIEW public.viewbackflush;

CREATE OR REPLACE VIEW public.viewbackflush AS 
 SELECT backflush.backflush_id,
    backflush.backflush_orig_item_id,
    oitem.item_number AS orig_item_number,
    oitem.item_description AS orig_item_description,
    backflush.backflush_orig_rev,
    backflush.backflush_orig_serialnumber,
    backflush.backflush_part_id,
    part.part_item_id,
    pitem.item_number,
    pitem.item_description,
    part.part_rev,
    part.part_serialnumber,
    backflush.backflush_qty,
    backflush.backflush_doctype_id,
    doctype.doctype_name,
    backflush.backflush_docnumber,
    backflush.backflush_create_timestamp,
    backflush.backflush_create_usr_id,
    cusr.usr_username AS create_usr_username,
    backflush.backflush_complete_timestamp,
    backflush.backflush_complete_usr_id,
    busr.usr_username AS complete_usr_username,
    backflush.backflush_void_timestamp,
    backflush.backflush_void_usr_id,
    vusr.usr_username AS void_usr_username,
    backflush.backflush_void_type,
    backflush.backflush_void_reason,
    backflush.backflush_line_id,
    line.line_name,
    backflush.backflush_station_id,
    station.station_name
   FROM backflush
     LEFT JOIN part ON part.part_id = backflush.backflush_part_id
     LEFT JOIN item pitem ON pitem.item_id = part.part_item_id
     LEFT JOIN item oitem ON oitem.item_id = backflush.backflush_orig_item_id
     LEFT JOIN doctype ON doctype.doctype_id = backflush.backflush_doctype_id
     LEFT JOIN usr cusr ON cusr.usr_id = backflush.backflush_create_usr_id
     LEFT JOIN usr busr ON busr.usr_id = backflush.backflush_complete_usr_id
     LEFT JOIN usr vusr ON vusr.usr_id = backflush.backflush_void_usr_id
     LEFT JOIN line ON line.line_id = backflush.backflush_line_id
     LEFT JOIN station ON station.station_id = backflush.backflush_station_id;

ALTER TABLE public.viewbackflush
  OWNER TO admin;


-- View: public.viewitem

-- DROP VIEW public.viewitem;

CREATE OR REPLACE VIEW public.viewitem AS 
 SELECT item.item_id,
    item.item_number,
    item.item_description,
    item.item_active,
    serialstream.serialstream_name,
    serialprefix.serialprefix_prefix,
    serialpattern.serialpattern_pattern,
    itemfreqcode.itemfreqcode_freqcode
   FROM item
     LEFT JOIN serialstream ON serialstream.serialstream_id = item.item_serialstream_id
     LEFT JOIN serialprefix ON serialprefix.serialprefix_id = item.item_serialprefix_id
     LEFT JOIN serialpattern ON serialpattern.serialpattern_id = serialprefix.serialprefix_serialpattern_id
     LEFT JOIN itemfreqcode ON itemfreqcode.itemfreqcode_id = item.item_itemfreqcode_id;

ALTER TABLE public.viewitem
  OWNER TO admin;


-- View: public.viewitemcustparamlink

-- DROP VIEW public.viewitemcustparamlink;

CREATE OR REPLACE VIEW public.viewitemcustparamlink AS 
 SELECT custparam.custparam_id,
    custparam.custparam_param,
    custparam.custparam_active_timestamp,
    custparam.custparam_void_timestamp,
    datatype.datatype_id,
    datatype.datatype_type,
    itemcustparamlink.itemcustparamlink_id,
    item.item_id,
    item.item_number,
    itemcustparamlink.itemcustparamlink_active
   FROM itemcustparamlink
     LEFT JOIN custparam ON custparam.custparam_id = itemcustparamlink.itemcustparamlink_custparam_id
     LEFT JOIN datatype ON datatype.datatype_id = custparam.custparam_datatype_id
     LEFT JOIN item ON item.item_id = itemcustparamlink.itemcustparamlink_item_id;

ALTER TABLE public.viewitemcustparamlink
  OWNER TO admin;


-- View: public.viewitemrev

-- DROP VIEW public.viewitemrev;

CREATE OR REPLACE VIEW public.viewitemrev AS 
 SELECT itemrev.itemrev_id,
    itemrev.itemrev_rev,
    itemrev.itemrev_npi,
    itemrev.itemrev_item_id,
    item.item_number,
    item.item_description,
    item.item_active
   FROM itemrev
     LEFT JOIN item ON item.item_id = itemrev.itemrev_item_id;

ALTER TABLE public.viewitemrev
  OWNER TO admin;


-- View: public.viewpart

-- DROP VIEW public.viewpart;

CREATE OR REPLACE VIEW public.viewpart AS 
 SELECT item.item_number,
    item.item_description,
    part.part_rev,
    part.part_serialnumber,
    part.part_sequencenumber,
    part.part_active,
    part.part_refurb,
    partstate.partstate_name,
    part.part_createdate,
    doctype.doctype_name,
    part.part_create_docnumber,
    part.part_loc_id,
    loc.loc_number,
    loc.loc_name,
    part.part_cust_id,
    cust.cust_number,
    cust.cust_name,
    part.part_allocpos,
    part.part_id,
    item.item_id,
    part.part_partstate_id,
    part.part_backflushed,
    parentitem.item_number AS parent_item_number,
    parentpart.part_rev AS parent_part_rev,
    parentpart.part_serialnumber AS parent_part_serialnumber,
    parentpart.part_sequencenumber AS parent_part_sequencenumber,
    parentpart.part_active AS parent_part_active,
    part.part_parent_part_id AS parent_part_id,
    parentitem.item_id AS parent_item_id,
    parentpart.part_partstate_id AS parent_part_partstate_id,
    parentpart.part_loc_id AS parent_part_loc_id,
    parentpart.part_cust_id AS parent_part_cust_id
   FROM part
     LEFT JOIN item ON item.item_id = part.part_item_id
     LEFT JOIN partstate ON partstate.partstate_id = part.part_partstate_id
     LEFT JOIN loc ON loc.loc_id = part.part_loc_id
     LEFT JOIN cust ON cust.cust_id = part.part_cust_id
     LEFT JOIN doctype ON doctype.doctype_id = part.part_create_doctype_id
     LEFT JOIN part parentpart ON parentpart.part_id = part.part_parent_part_id
     LEFT JOIN item parentitem ON parentitem.item_id = parentpart.part_item_id
  ORDER BY item.item_number, part.part_sequencenumber, part.part_serialnumber;

ALTER TABLE public.viewpart
  OWNER TO admin;


  -- View: public.viewpartcustparamvalue

-- DROP VIEW public.viewpartcustparamvalue;

CREATE OR REPLACE VIEW public.viewpartcustparamvalue AS 
 SELECT custparam.custparam_id,
    custparam.custparam_param,
    custparam.custparam_active_timestamp,
    custparam.custparam_void_timestamp,
    partcustparamvalue.partcustparamvalue_value,
    datatype.datatype_id,
    datatype.datatype_type,
    part.part_id,
    item.item_id,
    item.item_number,
    part.part_rev,
    part.part_serialnumber,
    partcustparamvalue.partcustparamvalue_submit_timestamp,
    partcustparamvalue.partcustparamvalue_void_timestamp
   FROM partcustparamvalue
     LEFT JOIN custparam ON custparam.custparam_id = partcustparamvalue.partcustparamvalue_custparam_id
     LEFT JOIN datatype ON datatype.datatype_id = custparam.custparam_datatype_id
     LEFT JOIN part ON part.part_id = partcustparamvalue.partcustparamvalue_part_id
     LEFT JOIN item ON item.item_id = part.part_item_id;

ALTER TABLE public.viewpartcustparamvalue
  OWNER TO admin;


-- View: public.viewpartdoclink

-- DROP VIEW public.viewpartdoclink;

CREATE OR REPLACE VIEW public.viewpartdoclink AS 
 SELECT partdoclink.partdoclink_id,
    doctype.doctype_id,
    doctype.doctype_name,
    doctype.doctype_description,
    partdoclink.partdoclink_docnumber,
    part.part_id,
    item.item_id,
    item.item_number,
    part.part_rev,
    part.part_serialnumber,
    partdoclink.partdoclink_submit_timestamp,
    partdoclink.partdoclink_void_timestamp
   FROM partdoclink
     LEFT JOIN doctype ON doctype.doctype_id = partdoclink.partdoclink_doctype_id
     LEFT JOIN part ON part.part_id = partdoclink.partdoclink_part_id
     LEFT JOIN item ON item.item_id = part.part_item_id;

ALTER TABLE public.viewpartdoclink
  OWNER TO admin;


  -- View: public.viewpartlog

-- DROP VIEW public.viewpartlog;

CREATE OR REPLACE VIEW public.viewpartlog AS 
 SELECT partlog.partlog_id,
    part.part_id,
    part.part_item_id,
    pitem.item_number,
    part.part_rev,
    part.part_serialnumber,
    part.part_sequencenumber,
    partlog.partlog_orig_item_id,
    oitem.item_number AS partlog_orig_item_number,
    partlog.partlog_orig_rev,
    partlog.partlog_orig_serialnumber,
    module.module_name,
    partlogaction.partlogaction_name,
    partlogactiontype.partlogactiontype_name,
    partlog.partlog_message,
    recordtype.recordtype_name,
    partlog.partlog_record_id,
    doctype.doctype_name,
    partlog.partlog_docnumber,
    partlog.partlog_usr_id,
    usr.usr_username,
    partlog.partlog_timestamp
   FROM partlog
     LEFT JOIN part ON part.part_id = partlog.partlog_part_id
     LEFT JOIN item pitem ON pitem.item_id = part.part_item_id
     LEFT JOIN item oitem ON oitem.item_id = partlog.partlog_orig_item_id
     LEFT JOIN module ON module.module_id = partlog.partlog_module_id
     LEFT JOIN partlogaction ON partlogaction.partlogaction_id = partlog.partlog_partlogaction_id
     LEFT JOIN partlogactiontype ON partlogactiontype.partlogactiontype_id = partlogaction.partlogaction_partlogactiontype_id
     LEFT JOIN recordtype ON recordtype.recordtype_id = partlog.partlog_recordtype_id
     LEFT JOIN doctype ON doctype.doctype_id = partlog.partlog_doctype_id
     LEFT JOIN usr ON usr.usr_id = partlog.partlog_usr_id
  ORDER BY partlog.partlog_id;

ALTER TABLE public.viewpartlog
  OWNER TO admin;



-- View: public.viewpartstateflow

-- DROP VIEW public.viewpartstateflow;

CREATE OR REPLACE VIEW public.viewpartstateflow AS 
 SELECT sps.partstate_id AS start_partstate_id,
    sps.partstate_name AS start_partstate_name,
    sps.partstate_active AS start_partstate_active,
    eps.partstate_id AS end_partstate_id,
    eps.partstate_name AS end_partstate_name,
    eps.partstate_active AS end_partstate_active,
    partstateflow.partstateflow_id,
    partstateflow.partstateflow_active,
    partstateflow.partstateflow_overridereq
   FROM partstateflow
     LEFT JOIN partstate sps ON sps.partstate_id = partstateflow.partstateflow_start_partstate_id
     LEFT JOIN partstate eps ON eps.partstate_id = partstateflow.partstateflow_end_partstate_id;

ALTER TABLE public.viewpartstateflow
  OWNER TO admin;


  -- View: public.viewpartwatcher

-- DROP VIEW public.viewpartwatcher;

CREATE OR REPLACE VIEW public.viewpartwatcher AS 
 SELECT item.item_number,
    part.part_rev,
    part.part_serialnumber,
    part.part_sequencenumber,
    part.part_active,
    part.part_refurb,
    usr.usr_username,
    usr.usr_name,
    usr.usr_email,
    usr.usr_active
   FROM partwatcher
     LEFT JOIN part ON part.part_id = partwatcher.partwatcher_part_id
     LEFT JOIN item ON item.item_id = part.part_item_id
     LEFT JOIN usr ON usr.usr_id = partwatcher.partwatcher_usr_id
  ORDER BY item.item_number, part.part_sequencenumber, part.part_serialnumber, usr.usr_username;

ALTER TABLE public.viewpartwatcher
  OWNER TO admin;



-- View: public.viewprivgranted

-- DROP VIEW public.viewprivgranted;

CREATE OR REPLACE VIEW public.viewprivgranted AS 
 SELECT usr.usr_username,
    priv.priv_name,
    module.module_name,
    true AS priv_granted
   FROM usrpriv
     LEFT JOIN usr ON usr.usr_id = usrpriv.usrpriv_usr_id
     LEFT JOIN priv ON priv.priv_id = usrpriv.usrpriv_priv_id
     LEFT JOIN module ON module.module_id = priv.priv_module_id
UNION
 SELECT usr.usr_username,
    priv.priv_name,
    module.module_name,
    true AS priv_granted
   FROM rolepriv
     LEFT JOIN role ON role.role_id = rolepriv.rolepriv_role_id
     LEFT JOIN usrrole ON usrrole.usrrole_role_id = role.role_id
     LEFT JOIN usr ON usr.usr_id = usrrole.usrrole_usr_id
     LEFT JOIN priv ON priv.priv_id = rolepriv.rolepriv_priv_id
     LEFT JOIN module ON module.module_id = priv.priv_module_id;

ALTER TABLE public.viewprivgranted
  OWNER TO admin;


  -- View: public.viewrecordcustparamlink

-- DROP VIEW public.viewrecordcustparamlink;

CREATE OR REPLACE VIEW public.viewrecordcustparamlink AS 
 SELECT custparam.custparam_id,
    custparam.custparam_param,
    custparam.custparam_active_timestamp,
    custparam.custparam_void_timestamp,
    datatype.datatype_id,
    datatype.datatype_type,
    recordcustparamlink.recordcustparamlink_id,
    recordtype.recordtype_id,
    recordtype.recordtype_name,
    recordcustparamlink.recordcustparamlink_active
   FROM recordcustparamlink
     LEFT JOIN custparam ON custparam.custparam_id = recordcustparamlink.recordcustparamlink_custparam_id
     LEFT JOIN datatype ON datatype.datatype_id = custparam.custparam_datatype_id
     LEFT JOIN recordtype ON recordtype.recordtype_id = recordcustparamlink.recordcustparamlink_recordtype_id;

ALTER TABLE public.viewrecordcustparamlink
  OWNER TO admin;



  -- View: public.viewrecordcustparamvalue

-- DROP VIEW public.viewrecordcustparamvalue;

CREATE OR REPLACE VIEW public.viewrecordcustparamvalue AS 
 SELECT custparam.custparam_id,
    custparam.custparam_param,
    custparam.custparam_active_timestamp,
    custparam.custparam_void_timestamp,
    recordcustparamvalue.recordcustparamvalue_value,
    datatype.datatype_id,
    datatype.datatype_type,
    recordtype.recordtype_id,
    recordtype.recordtype_name,
    recordcustparamvalue.recordcustparamvalue_record_id,
    recordcustparamvalue.recordcustparamvalue_submit_timestamp,
    recordcustparamvalue.recordcustparamvalue_void_timestamp
   FROM recordcustparamvalue
     LEFT JOIN custparam ON custparam.custparam_id = recordcustparamvalue.recordcustparamvalue_custparam_id
     LEFT JOIN datatype ON datatype.datatype_id = custparam.custparam_datatype_id
     LEFT JOIN recordtype ON recordtype.recordtype_id = recordcustparamvalue.recordcustparamvalue_recordtype_id;

ALTER TABLE public.viewrecordcustparamvalue
  OWNER TO admin;



  -- View: public.viewrecorddoclink

-- DROP VIEW public.viewrecorddoclink;

CREATE OR REPLACE VIEW public.viewrecorddoclink AS 
 SELECT recorddoclink.recorddoclink_id,
    doctype.doctype_id,
    doctype.doctype_name,
    doctype.doctype_description,
    recorddoclink.recorddoclink_docnumber,
    recordtype.recordtype_name,
    recorddoclink.recorddoclink_record_id,
    recorddoclink.recorddoclink_submit_timestamp,
    recorddoclink.recorddoclink_void_timestamp
   FROM recorddoclink
     LEFT JOIN doctype ON doctype.doctype_id = recorddoclink.recorddoclink_doctype_id
     LEFT JOIN recordtype ON recordtype.recordtype_id = recorddoclink.recorddoclink_recordtype_id;

ALTER TABLE public.viewrecorddoclink
  OWNER TO admin;



-- View: public.viewrecordwatcher

-- DROP VIEW public.viewrecordwatcher;

CREATE OR REPLACE VIEW public.viewrecordwatcher AS 
 SELECT recordtype.recordtype_name,
    recordwatcher.recordwatcher_record_id,
    usr.usr_username,
    usr.usr_name,
    usr.usr_email,
    usr.usr_active
   FROM recordwatcher
     LEFT JOIN recordtype ON recordtype.recordtype_id = recordwatcher.recordwatcher_recordtype_id
     LEFT JOIN usr ON usr.usr_id = recordwatcher.recordwatcher_usr_id
  ORDER BY recordtype.recordtype_name, recordwatcher.recordwatcher_record_id, usr.usr_username;

ALTER TABLE public.viewrecordwatcher
  OWNER TO admin;






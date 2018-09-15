--
-- TOC entry 181 (class 1259 OID 36882)
-- Name: backflush; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE backflush (
    backflush_id integer NOT NULL,
    backflush_orig_item_id integer NOT NULL,
    backflush_orig_rev text NOT NULL,
    backflush_orig_serialnumber text,
    backflush_part_id integer,
    backflush_qty integer DEFAULT 1 NOT NULL,
    backflush_doctype_id integer NOT NULL,
    backflush_docnumber text NOT NULL,
    backflush_create_timestamp timestamp without time zone DEFAULT now() NOT NULL,
    backflush_create_usr_id integer NOT NULL,
    backflush_complete_timestamp timestamp without time zone,
    backflush_complete_usr_id integer,
    backflush_void_timestamp timestamp without time zone,
    backflush_void_usr_id integer,
    backflush_void_type text,
    backflush_void_reason text,
    backflush_line_id integer NOT NULL,
    backflush_station_id integer NOT NULL
);


ALTER TABLE backflush OWNER TO admin;

--
-- TOC entry 3234 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN backflush.backflush_orig_item_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN backflush.backflush_orig_item_id IS 'Original Item ID at time of Backflush Request';


--
-- TOC entry 3235 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN backflush.backflush_void_type; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN backflush.backflush_void_type IS 'UPDATE, MANUAL, REVERSE POST';


--
-- TOC entry 182 (class 1259 OID 36890)
-- Name: backflush_backflush_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE backflush_backflush_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE backflush_backflush_id_seq OWNER TO admin;

--
-- TOC entry 3237 (class 0 OID 0)
-- Dependencies: 182
-- Name: backflush_backflush_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE backflush_backflush_id_seq OWNED BY backflush.backflush_id;


--
-- TOC entry 183 (class 1259 OID 36892)
-- Name: bom; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE bom (
    bom_id integer NOT NULL,
    bom_parent_item_id integer,
    bom_parent_itemrev text,
    bom_item_id integer,
    bom_itemrev text,
    bom_qtyper numeric(20,8) NOT NULL,
    bom_effective date,
    bom_expires date,
    CONSTRAINT bom_check CHECK (((((bom_parent_item_id)::text || '-'::text) || bom_parent_itemrev) <> (((bom_item_id)::text || '-'::text) || bom_itemrev)))
);


ALTER TABLE bom OWNER TO admin;

--
-- TOC entry 184 (class 1259 OID 36899)
-- Name: bom_bom_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE bom_bom_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bom_bom_id_seq OWNER TO admin;

--
-- TOC entry 3238 (class 0 OID 0)
-- Dependencies: 184
-- Name: bom_bom_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE bom_bom_id_seq OWNED BY bom.bom_id;


--
-- TOC entry 185 (class 1259 OID 36901)
-- Name: cust; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE cust (
    cust_id integer NOT NULL,
    cust_number text NOT NULL,
    cust_name text NOT NULL,
    cust_description text,
    cust_active boolean DEFAULT true NOT NULL
);


ALTER TABLE cust OWNER TO admin;

--
-- TOC entry 186 (class 1259 OID 36908)
-- Name: cust_cust_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE cust_cust_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cust_cust_id_seq OWNER TO admin;

--
-- TOC entry 3239 (class 0 OID 0)
-- Dependencies: 186
-- Name: cust_cust_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE cust_cust_id_seq OWNED BY cust.cust_id;


--
-- TOC entry 187 (class 1259 OID 36910)
-- Name: custfiletype; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE custfiletype (
    custfiletype_id integer NOT NULL,
    custfiletype_type text,
    custfiletype_active boolean DEFAULT true NOT NULL
);


ALTER TABLE custfiletype OWNER TO admin;

--
-- TOC entry 188 (class 1259 OID 36917)
-- Name: custfiletype_custfiletype_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE custfiletype_custfiletype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE custfiletype_custfiletype_id_seq OWNER TO admin;

--
-- TOC entry 3240 (class 0 OID 0)
-- Dependencies: 188
-- Name: custfiletype_custfiletype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE custfiletype_custfiletype_id_seq OWNED BY custfiletype.custfiletype_id;


SET default_with_oids = false;

--
-- TOC entry 189 (class 1259 OID 36919)
-- Name: custhist; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE custhist (
    custhist_id integer NOT NULL,
    custhist_part_id integer NOT NULL,
    custhist_start_cust_id integer,
    custhist_end_cust_id integer,
    custhist_timestamp timestamp without time zone DEFAULT now() NOT NULL,
    custhist_usr_id integer NOT NULL,
    custhist_orig_item_id integer NOT NULL,
    custhist_orig_rev text NOT NULL,
    custhist_orig_serialnumber text NOT NULL
);


ALTER TABLE custhist OWNER TO admin;

--
-- TOC entry 190 (class 1259 OID 36926)
-- Name: custhist_custhist_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE custhist_custhist_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE custhist_custhist_id_seq OWNER TO admin;

--
-- TOC entry 3241 (class 0 OID 0)
-- Dependencies: 190
-- Name: custhist_custhist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE custhist_custhist_id_seq OWNED BY custhist.custhist_id;


SET default_with_oids = true;

--
-- TOC entry 191 (class 1259 OID 36928)
-- Name: custparam; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE custparam (
    custparam_id integer NOT NULL,
    custparam_type character(1) NOT NULL,
    custparam_param text NOT NULL,
    custparam_datatype_id integer NOT NULL,
    custparam_active_timestamp timestamp without time zone DEFAULT now() NOT NULL,
    custparam_void_timestamp timestamp without time zone,
    CONSTRAINT custparam_custparam_type_check CHECK (((custparam_type = 'r'::bpchar) OR (custparam_type = 'p'::bpchar)))
);


ALTER TABLE custparam OWNER TO admin;

--
-- TOC entry 192 (class 1259 OID 36936)
-- Name: custparam_custparam_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE custparam_custparam_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE custparam_custparam_id_seq OWNER TO admin;

--
-- TOC entry 3242 (class 0 OID 0)
-- Dependencies: 192
-- Name: custparam_custparam_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE custparam_custparam_id_seq OWNED BY custparam.custparam_id;


--
-- TOC entry 193 (class 1259 OID 36938)
-- Name: custparamcombo; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE custparamcombo (
    custparamcombo_id integer NOT NULL,
    custparamcombo_custparam_id integer NOT NULL,
    custparamcombo_value text NOT NULL,
    custparamcombo_active boolean DEFAULT true NOT NULL
);


ALTER TABLE custparamcombo OWNER TO admin;

--
-- TOC entry 194 (class 1259 OID 36945)
-- Name: custparamcombo_custparamcombo_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE custparamcombo_custparamcombo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE custparamcombo_custparamcombo_id_seq OWNER TO admin;

--
-- TOC entry 3243 (class 0 OID 0)
-- Dependencies: 194
-- Name: custparamcombo_custparamcombo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE custparamcombo_custparamcombo_id_seq OWNED BY custparamcombo.custparamcombo_id;


--
-- TOC entry 195 (class 1259 OID 36947)
-- Name: custparamlink; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE custparamlink (
    custparamlink_id integer NOT NULL,
    custparamlink_custparam_id integer NOT NULL,
    custparamlink_item_id integer,
    custparamlink_recordtype_id integer,
    custparamlink_active boolean DEFAULT true NOT NULL,
    CONSTRAINT custparamlink_check CHECK ((((custparamlink_item_id IS NULL) AND (custparamlink_recordtype_id IS NOT NULL)) OR ((custparamlink_item_id IS NOT NULL) AND (custparamlink_recordtype_id IS NULL))))
);


ALTER TABLE custparamlink OWNER TO admin;

--
-- TOC entry 196 (class 1259 OID 36952)
-- Name: custparamlink_custparamlink_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE custparamlink_custparamlink_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE custparamlink_custparamlink_id_seq OWNER TO admin;

--
-- TOC entry 3244 (class 0 OID 0)
-- Dependencies: 196
-- Name: custparamlink_custparamlink_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE custparamlink_custparamlink_id_seq OWNED BY custparamlink.custparamlink_id;


--
-- TOC entry 197 (class 1259 OID 36954)
-- Name: datatype; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE datatype (
    datatype_id integer NOT NULL,
    datatype_type text,
    datatype_active boolean DEFAULT true NOT NULL
);


ALTER TABLE datatype OWNER TO admin;

--
-- TOC entry 198 (class 1259 OID 36961)
-- Name: datatype_datatype_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE datatype_datatype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datatype_datatype_id_seq OWNER TO admin;

--
-- TOC entry 3245 (class 0 OID 0)
-- Dependencies: 198
-- Name: datatype_datatype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE datatype_datatype_id_seq OWNED BY datatype.datatype_id;


--
-- TOC entry 199 (class 1259 OID 36963)
-- Name: doctype; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE doctype (
    doctype_id integer NOT NULL,
    doctype_name text,
    doctype_description text
);


ALTER TABLE doctype OWNER TO admin;

--
-- TOC entry 200 (class 1259 OID 36969)
-- Name: doctype_doctype_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE doctype_doctype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE doctype_doctype_id_seq OWNER TO admin;

--
-- TOC entry 3246 (class 0 OID 0)
-- Dependencies: 200
-- Name: doctype_doctype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE doctype_doctype_id_seq OWNED BY doctype.doctype_id;


--
-- TOC entry 201 (class 1259 OID 36971)
-- Name: eco; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE eco (
    eco_id integer NOT NULL,
    eco_number text,
    eco_description text
);


ALTER TABLE eco OWNER TO admin;

--
-- TOC entry 202 (class 1259 OID 36977)
-- Name: eco_eco_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE eco_eco_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE eco_eco_id_seq OWNER TO admin;

--
-- TOC entry 3247 (class 0 OID 0)
-- Dependencies: 202
-- Name: eco_eco_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE eco_eco_id_seq OWNED BY eco.eco_id;


--
-- TOC entry 203 (class 1259 OID 36979)
-- Name: filetype; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE filetype (
    filetype_id integer NOT NULL,
    filetype_type text,
    filetype_mediatypename text,
    filetype_active boolean DEFAULT true NOT NULL
);


ALTER TABLE filetype OWNER TO admin;

--
-- TOC entry 204 (class 1259 OID 36986)
-- Name: filetype_filetype_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE filetype_filetype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE filetype_filetype_id_seq OWNER TO admin;

--
-- TOC entry 3248 (class 0 OID 0)
-- Dependencies: 204
-- Name: filetype_filetype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE filetype_filetype_id_seq OWNED BY filetype.filetype_id;


--
-- TOC entry 205 (class 1259 OID 36988)
-- Name: item; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE item (
    item_id integer NOT NULL,
    item_number text NOT NULL,
    item_description text,
    item_active boolean DEFAULT true NOT NULL,
    item_serialstream_id integer,
    item_serialprefix_id integer,
    item_itemfreqcode_id integer,
    item_printqty integer,
    item_serialized boolean DEFAULT true NOT NULL,
    item_phantom boolean DEFAULT false NOT NULL
);


ALTER TABLE item OWNER TO admin;

--
-- TOC entry 206 (class 1259 OID 36997)
-- Name: item_item_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE item_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE item_item_id_seq OWNER TO admin;

--
-- TOC entry 3249 (class 0 OID 0)
-- Dependencies: 206
-- Name: item_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE item_item_id_seq OWNED BY item.item_id;


--
-- TOC entry 207 (class 1259 OID 36999)
-- Name: itemcustparamlink; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE itemcustparamlink (
    itemcustparamlink_id integer NOT NULL,
    itemcustparamlink_custparam_id integer NOT NULL,
    itemcustparamlink_item_id integer NOT NULL,
    itemcustparamlink_active boolean DEFAULT true NOT NULL
);


ALTER TABLE itemcustparamlink OWNER TO admin;

--
-- TOC entry 208 (class 1259 OID 37003)
-- Name: itemcustparamlink_itemcustparamlink_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE itemcustparamlink_itemcustparamlink_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE itemcustparamlink_itemcustparamlink_id_seq OWNER TO admin;

--
-- TOC entry 3250 (class 0 OID 0)
-- Dependencies: 208
-- Name: itemcustparamlink_itemcustparamlink_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE itemcustparamlink_itemcustparamlink_id_seq OWNED BY itemcustparamlink.itemcustparamlink_id;


--
-- TOC entry 209 (class 1259 OID 37005)
-- Name: itemfreqcode; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE itemfreqcode (
    itemfreqcode_id integer NOT NULL,
    itemfreqcode_freqcode text NOT NULL,
    itemfreqcode_name text NOT NULL
);


ALTER TABLE itemfreqcode OWNER TO admin;

--
-- TOC entry 210 (class 1259 OID 37011)
-- Name: itemfreqcode_itemfreqcode_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE itemfreqcode_itemfreqcode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE itemfreqcode_itemfreqcode_id_seq OWNER TO admin;

--
-- TOC entry 3251 (class 0 OID 0)
-- Dependencies: 210
-- Name: itemfreqcode_itemfreqcode_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE itemfreqcode_itemfreqcode_id_seq OWNED BY itemfreqcode.itemfreqcode_id;


--
-- TOC entry 211 (class 1259 OID 37013)
-- Name: itemrev; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE itemrev (
    itemrev_id integer NOT NULL,
    itemrev_item_id integer NOT NULL,
    itemrev_rev text NOT NULL,
    itemrev_npi boolean DEFAULT false NOT NULL
);


ALTER TABLE itemrev OWNER TO admin;

--
-- TOC entry 212 (class 1259 OID 37020)
-- Name: itemrevflow; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE itemrevflow (
    itemrevflow_id integer NOT NULL,
    itemrevflow_item_id integer NOT NULL,
    itemrevflow_start_rev text,
    itemrevflow_end_rev text,
    itemrevflow_npi boolean DEFAULT false NOT NULL,
    itemrevflow_eco_id integer
);


ALTER TABLE itemrevflow OWNER TO admin;

--
-- TOC entry 213 (class 1259 OID 37027)
-- Name: itemrevision_itemrevision_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE itemrevision_itemrevision_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE itemrevision_itemrevision_id_seq OWNER TO admin;

--
-- TOC entry 3252 (class 0 OID 0)
-- Dependencies: 213
-- Name: itemrevision_itemrevision_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE itemrevision_itemrevision_id_seq OWNED BY itemrev.itemrev_id;


--
-- TOC entry 214 (class 1259 OID 37029)
-- Name: itemrevisionflow_itemrevisionflow_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE itemrevisionflow_itemrevisionflow_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE itemrevisionflow_itemrevisionflow_id_seq OWNER TO admin;

--
-- TOC entry 3253 (class 0 OID 0)
-- Dependencies: 214
-- Name: itemrevisionflow_itemrevisionflow_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE itemrevisionflow_itemrevisionflow_id_seq OWNED BY itemrevflow.itemrevflow_id;


SET default_with_oids = false;

--
-- TOC entry 215 (class 1259 OID 37031)
-- Name: line; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE line (
    line_id integer NOT NULL,
    line_name text NOT NULL,
    line_description text,
    line_active boolean DEFAULT true NOT NULL
);


ALTER TABLE line OWNER TO admin;

--
-- TOC entry 216 (class 1259 OID 37038)
-- Name: line_line_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE line_line_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE line_line_id_seq OWNER TO admin;

--
-- TOC entry 3254 (class 0 OID 0)
-- Dependencies: 216
-- Name: line_line_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE line_line_id_seq OWNED BY line.line_id;


--
-- TOC entry 217 (class 1259 OID 37040)
-- Name: loc; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE loc (
    loc_id integer NOT NULL,
    loc_number text NOT NULL,
    loc_name text NOT NULL,
    loc_description text,
    loc_active boolean DEFAULT true NOT NULL
);


ALTER TABLE loc OWNER TO admin;

--
-- TOC entry 218 (class 1259 OID 37047)
-- Name: loc_loc_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE loc_loc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE loc_loc_id_seq OWNER TO admin;

--
-- TOC entry 3255 (class 0 OID 0)
-- Dependencies: 218
-- Name: loc_loc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE loc_loc_id_seq OWNED BY loc.loc_id;


--
-- TOC entry 219 (class 1259 OID 37049)
-- Name: lochist; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE lochist (
    lochist_id integer NOT NULL,
    lochist_part_id integer NOT NULL,
    lochist_start_loc_id integer NOT NULL,
    lochist_end_loc_id integer NOT NULL,
    lochist_timestamp timestamp without time zone DEFAULT now() NOT NULL,
    lochist_usr_id integer NOT NULL,
    lochist_orig_item_id integer NOT NULL,
    lochist_orig_rev text NOT NULL,
    lochist_orig_serialnumber text NOT NULL
);


ALTER TABLE lochist OWNER TO admin;

--
-- TOC entry 220 (class 1259 OID 37056)
-- Name: lochist_lochist_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE lochist_lochist_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE lochist_lochist_id_seq OWNER TO admin;

--
-- TOC entry 3256 (class 0 OID 0)
-- Dependencies: 220
-- Name: lochist_lochist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE lochist_lochist_id_seq OWNED BY lochist.lochist_id;


--
-- TOC entry 221 (class 1259 OID 37058)
-- Name: module; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE module (
    module_id integer NOT NULL,
    module_name text NOT NULL,
    module_description text
);


ALTER TABLE module OWNER TO admin;

--
-- TOC entry 222 (class 1259 OID 37064)
-- Name: module_module_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE module_module_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE module_module_id_seq OWNER TO admin;

--
-- TOC entry 3257 (class 0 OID 0)
-- Dependencies: 222
-- Name: module_module_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE module_module_id_seq OWNED BY module.module_id;


SET default_with_oids = true;

--
-- TOC entry 223 (class 1259 OID 37066)
-- Name: part; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE part (
    part_id integer NOT NULL,
    part_item_id integer NOT NULL,
    part_rev text NOT NULL,
    part_sequencenumber integer NOT NULL,
    part_serialnumber text NOT NULL,
    part_active boolean DEFAULT true NOT NULL,
    part_createdate timestamp without time zone DEFAULT now() NOT NULL,
    part_loc_id integer NOT NULL,
    part_cust_id integer,
    part_create_doctype_id integer,
    part_create_docnumber text,
    part_parent_part_id integer,
    part_allocpos integer,
    part_partstate_id integer NOT NULL,
    part_refurb boolean DEFAULT false NOT NULL,
    part_backflushed boolean DEFAULT false NOT NULL
);


ALTER TABLE part OWNER TO admin;

--
-- TOC entry 224 (class 1259 OID 37076)
-- Name: part_part_key_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE part_part_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE part_part_key_seq OWNER TO admin;

--
-- TOC entry 3258 (class 0 OID 0)
-- Dependencies: 224
-- Name: part_part_key_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE part_part_key_seq OWNED BY part.part_id;


--
-- TOC entry 225 (class 1259 OID 37078)
-- Name: partactivehist; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE partactivehist (
    partactivehist_id integer NOT NULL,
    partactivehist_part_id integer NOT NULL,
    partactivehist_new_activestate boolean NOT NULL,
    partactivehist_usr_id integer NOT NULL,
    partactivehist_timestamp timestamp without time zone DEFAULT now() NOT NULL,
    partactivehist_orig_item_id integer NOT NULL,
    partactivehist_orig_rev text NOT NULL,
    partactivehist_orig_serialnumber text NOT NULL
);


ALTER TABLE partactivehist OWNER TO admin;

--
-- TOC entry 226 (class 1259 OID 37085)
-- Name: partactivehist_partactivehist_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE partactivehist_partactivehist_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE partactivehist_partactivehist_id_seq OWNER TO admin;

--
-- TOC entry 3259 (class 0 OID 0)
-- Dependencies: 226
-- Name: partactivehist_partactivehist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE partactivehist_partactivehist_id_seq OWNED BY partactivehist.partactivehist_id;


SET default_with_oids = false;

--
-- TOC entry 227 (class 1259 OID 37087)
-- Name: partalloccode; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE partalloccode (
    partalloccode_id integer NOT NULL,
    partalloccode_code text NOT NULL,
    partalloccode_description text,
    partalloccode_alloctype character(1)
);


ALTER TABLE partalloccode OWNER TO admin;

--
-- TOC entry 228 (class 1259 OID 37093)
-- Name: partalloccode_partalloccode_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE partalloccode_partalloccode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE partalloccode_partalloccode_id_seq OWNER TO admin;

--
-- TOC entry 3260 (class 0 OID 0)
-- Dependencies: 228
-- Name: partalloccode_partalloccode_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE partalloccode_partalloccode_id_seq OWNED BY partalloccode.partalloccode_id;


SET default_with_oids = true;

--
-- TOC entry 229 (class 1259 OID 37095)
-- Name: partallochist; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE partallochist (
    partallochist_id integer NOT NULL,
    partallochist_parent_part_id integer NOT NULL,
    partallochist_child_part_id integer NOT NULL,
    partallochist_allocpos integer DEFAULT 0 NOT NULL,
    partallochist_alloctype character(1) NOT NULL,
    partallochist_timestamp timestamp without time zone DEFAULT now() NOT NULL,
    partallochist_usr_id integer NOT NULL,
    partallochist_alloccode text NOT NULL,
    partallochist_parent_orig_item_id integer NOT NULL,
    partallochist_parent_orig_rev text NOT NULL,
    partallochist_parent_orig_serialnumber text NOT NULL,
    partallochist_child_orig_item_id integer NOT NULL,
    partallochist_child_orig_rev text NOT NULL,
    partallochist_child_orig_serialnumber text NOT NULL,
    partallochist_line_id integer,
    partallochist_station_id integer,
    CONSTRAINT partallochist_partallochist_alloctype_check CHECK (((partallochist_alloctype = 'a'::bpchar) OR (partallochist_alloctype = 'd'::bpchar)))
);


ALTER TABLE partallochist OWNER TO admin;

--
-- TOC entry 230 (class 1259 OID 37104)
-- Name: partallochist_partallochist_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE partallochist_partallochist_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE partallochist_partallochist_id_seq OWNER TO admin;

--
-- TOC entry 3261 (class 0 OID 0)
-- Dependencies: 230
-- Name: partallochist_partallochist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE partallochist_partallochist_id_seq OWNED BY partallochist.partallochist_id;


--
-- TOC entry 231 (class 1259 OID 37106)
-- Name: partcustparamvalue; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE partcustparamvalue (
    partcustparamvalue_id integer NOT NULL,
    partcustparamvalue_custparam_id integer NOT NULL,
    partcustparamvalue_part_id integer NOT NULL,
    partcustparamvalue_value text NOT NULL,
    partcustparamvalue_submit_timestamp timestamp without time zone DEFAULT now() NOT NULL,
    partcustparamvalue_void_timestamp timestamp without time zone
);


ALTER TABLE partcustparamvalue OWNER TO admin;

--
-- TOC entry 232 (class 1259 OID 37113)
-- Name: partcustparamvalue_partcustparamvalue_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE partcustparamvalue_partcustparamvalue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE partcustparamvalue_partcustparamvalue_id_seq OWNER TO admin;

--
-- TOC entry 3262 (class 0 OID 0)
-- Dependencies: 232
-- Name: partcustparamvalue_partcustparamvalue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE partcustparamvalue_partcustparamvalue_id_seq OWNED BY partcustparamvalue.partcustparamvalue_id;


--
-- TOC entry 233 (class 1259 OID 37115)
-- Name: partdoclink; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE partdoclink (
    partdoclink_id integer NOT NULL,
    partdoclink_doctype_id integer NOT NULL,
    partdoclink_part_id integer NOT NULL,
    partdoclink_docnumber text NOT NULL,
    partdoclink_submit_timestamp timestamp without time zone DEFAULT now() NOT NULL,
    partdoclink_void_timestamp timestamp without time zone
);


ALTER TABLE partdoclink OWNER TO admin;

--
-- TOC entry 234 (class 1259 OID 37122)
-- Name: partdoclink_partdoclink_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE partdoclink_partdoclink_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE partdoclink_partdoclink_id_seq OWNER TO admin;

--
-- TOC entry 3263 (class 0 OID 0)
-- Dependencies: 234
-- Name: partdoclink_partdoclink_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE partdoclink_partdoclink_id_seq OWNED BY partdoclink.partdoclink_id;


SET default_with_oids = false;

--
-- TOC entry 235 (class 1259 OID 37124)
-- Name: partfile; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE partfile (
    partfile_id integer NOT NULL,
    partfile_part_id integer NOT NULL,
    partfile_partfiledata_id integer NOT NULL,
    partfile_partfilethumbnail_id integer,
    partfile_filename text,
    partfile_filetype_id integer NOT NULL,
    partfile_submit_timestamp timestamp without time zone DEFAULT now() NOT NULL,
    partfile_void_timestamp timestamp without time zone,
    partfile_custfiletype_id integer
);


ALTER TABLE partfile OWNER TO admin;

--
-- TOC entry 236 (class 1259 OID 37131)
-- Name: partfile_partfile_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE partfile_partfile_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE partfile_partfile_id_seq OWNER TO admin;

--
-- TOC entry 3264 (class 0 OID 0)
-- Dependencies: 236
-- Name: partfile_partfile_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE partfile_partfile_id_seq OWNED BY partfile.partfile_id;


--
-- TOC entry 237 (class 1259 OID 37133)
-- Name: partfiledata; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE partfiledata (
    partfiledata_id integer NOT NULL,
    partfiledata_data bytea NOT NULL,
    partfiledata_submit_timestamp timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE partfiledata OWNER TO admin;

--
-- TOC entry 238 (class 1259 OID 37140)
-- Name: partfiledata_partfiledata_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE partfiledata_partfiledata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE partfiledata_partfiledata_id_seq OWNER TO admin;

--
-- TOC entry 3265 (class 0 OID 0)
-- Dependencies: 238
-- Name: partfiledata_partfiledata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE partfiledata_partfiledata_id_seq OWNED BY partfiledata.partfiledata_id;


--
-- TOC entry 239 (class 1259 OID 37142)
-- Name: partfilethumbnail; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE partfilethumbnail (
    partfilethumbnail_id integer NOT NULL,
    partfilethumbnail_data bytea,
    partfilethumnail_submit_timestamp timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE partfilethumbnail OWNER TO admin;

--
-- TOC entry 240 (class 1259 OID 37149)
-- Name: partfilethumbnail_partfilethumbnail_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE partfilethumbnail_partfilethumbnail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE partfilethumbnail_partfilethumbnail_id_seq OWNER TO admin;

--
-- TOC entry 3266 (class 0 OID 0)
-- Dependencies: 240
-- Name: partfilethumbnail_partfilethumbnail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE partfilethumbnail_partfilethumbnail_id_seq OWNED BY partfilethumbnail.partfilethumbnail_id;


--
-- TOC entry 241 (class 1259 OID 37151)
-- Name: partlog; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE partlog (
    partlog_id integer NOT NULL,
    partlog_module_id integer NOT NULL,
    partlog_partlogaction_id integer NOT NULL,
    partlog_part_id integer NOT NULL,
    partlog_recordtype_id integer,
    partlog_record_id integer,
    partlog_doctype_id integer,
    partlog_docnumber text,
    partlog_message text NOT NULL,
    partlog_usr_id integer NOT NULL,
    partlog_timestamp timestamp without time zone DEFAULT now() NOT NULL,
    partlog_orig_item_id integer NOT NULL,
    partlog_orig_rev text NOT NULL,
    partlog_orig_serialnumber text NOT NULL,
    partlog_line_id integer,
    partlog_station_id integer
);


ALTER TABLE partlog OWNER TO admin;

--
-- TOC entry 242 (class 1259 OID 37158)
-- Name: partlog_partlog_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE partlog_partlog_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE partlog_partlog_id_seq OWNER TO admin;

--
-- TOC entry 3267 (class 0 OID 0)
-- Dependencies: 242
-- Name: partlog_partlog_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE partlog_partlog_id_seq OWNED BY partlog.partlog_id;


SET default_with_oids = true;

--
-- TOC entry 243 (class 1259 OID 37160)
-- Name: partlogaction; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE partlogaction (
    partlogaction_id integer NOT NULL,
    partlogaction_name text,
    partlogaction_description text,
    partlogaction_partlogactiontype_id integer
);


ALTER TABLE partlogaction OWNER TO admin;

--
-- TOC entry 244 (class 1259 OID 37166)
-- Name: partlogaction_partlogaction_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE partlogaction_partlogaction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE partlogaction_partlogaction_id_seq OWNER TO admin;

--
-- TOC entry 3268 (class 0 OID 0)
-- Dependencies: 244
-- Name: partlogaction_partlogaction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE partlogaction_partlogaction_id_seq OWNED BY partlogaction.partlogaction_id;


--
-- TOC entry 245 (class 1259 OID 37168)
-- Name: partlogactiontype; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE partlogactiontype (
    partlogactiontype_id integer NOT NULL,
    partlogactiontype_name text,
    partlogactiontype_description text
);


ALTER TABLE partlogactiontype OWNER TO admin;

--
-- TOC entry 246 (class 1259 OID 37174)
-- Name: partlogactiontype_partlogactiontype_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE partlogactiontype_partlogactiontype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE partlogactiontype_partlogactiontype_id_seq OWNER TO admin;

--
-- TOC entry 3269 (class 0 OID 0)
-- Dependencies: 246
-- Name: partlogactiontype_partlogactiontype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE partlogactiontype_partlogactiontype_id_seq OWNED BY partlogactiontype.partlogactiontype_id;


--
-- TOC entry 247 (class 1259 OID 37176)
-- Name: partlogtype; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE partlogtype (
    partlogtype_id integer NOT NULL,
    partlogtype_name text,
    partlogtype_description text
);


ALTER TABLE partlogtype OWNER TO admin;

--
-- TOC entry 248 (class 1259 OID 37182)
-- Name: partlogtype_partlogtype_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE partlogtype_partlogtype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE partlogtype_partlogtype_id_seq OWNER TO admin;

--
-- TOC entry 3270 (class 0 OID 0)
-- Dependencies: 248
-- Name: partlogtype_partlogtype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE partlogtype_partlogtype_id_seq OWNED BY partlogtype.partlogtype_id;


--
-- TOC entry 249 (class 1259 OID 37184)
-- Name: partrefurbhist; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE partrefurbhist (
    partrefurbhist_id integer NOT NULL,
    partrefurbhist_part_id integer NOT NULL,
    partrefurbhist_refurb boolean NOT NULL,
    partrefurbhist_timestamp timestamp without time zone DEFAULT now() NOT NULL,
    partrefurbhist_usr_id integer NOT NULL,
    partrefurbhist_orig_item_id integer NOT NULL,
    partrefurbhist_orig_rev text NOT NULL,
    partrefurbhist_orig_serialnumber text NOT NULL
);


ALTER TABLE partrefurbhist OWNER TO admin;

--
-- TOC entry 250 (class 1259 OID 37191)
-- Name: partrefurbhist_partrefurbhist_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE partrefurbhist_partrefurbhist_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE partrefurbhist_partrefurbhist_id_seq OWNER TO admin;

--
-- TOC entry 3271 (class 0 OID 0)
-- Dependencies: 250
-- Name: partrefurbhist_partrefurbhist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE partrefurbhist_partrefurbhist_id_seq OWNED BY partrefurbhist.partrefurbhist_id;


--
-- TOC entry 251 (class 1259 OID 37193)
-- Name: partrevhist; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE partrevhist (
    partrevhist_id integer NOT NULL,
    partrevhist_part_id integer NOT NULL,
    partrevhist_start_rev text NOT NULL,
    partrevhist_end_rev text NOT NULL,
    partrevhist_timestamp timestamp without time zone DEFAULT now() NOT NULL,
    partrevhist_usr_id integer NOT NULL,
    partrevhist_orig_item_id integer NOT NULL,
    partrevhist_orig_rev text NOT NULL,
    partrevhist_orig_serialnumber text NOT NULL,
    partrevhist_line_id integer,
    partrevhist_station_id integer,
    partrevhist_doctype_id integer NOT NULL,
    partrevhist_docnumber text NOT NULL
);


ALTER TABLE partrevhist OWNER TO admin;

--
-- TOC entry 252 (class 1259 OID 37200)
-- Name: partrevisionhistory_partrevisionhistory_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE partrevisionhistory_partrevisionhistory_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE partrevisionhistory_partrevisionhistory_id_seq OWNER TO admin;

--
-- TOC entry 3272 (class 0 OID 0)
-- Dependencies: 252
-- Name: partrevisionhistory_partrevisionhistory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE partrevisionhistory_partrevisionhistory_id_seq OWNED BY partrevhist.partrevhist_id;


--
-- TOC entry 253 (class 1259 OID 37202)
-- Name: partscrapcode; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE partscrapcode (
    partscrapcode_id integer NOT NULL,
    partscrapcode_code text NOT NULL,
    partscrapcode_description text
);


ALTER TABLE partscrapcode OWNER TO admin;

--
-- TOC entry 254 (class 1259 OID 37208)
-- Name: partscrapcode_partscrapcode_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE partscrapcode_partscrapcode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE partscrapcode_partscrapcode_id_seq OWNER TO admin;

--
-- TOC entry 3273 (class 0 OID 0)
-- Dependencies: 254
-- Name: partscrapcode_partscrapcode_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE partscrapcode_partscrapcode_id_seq OWNED BY partscrapcode.partscrapcode_id;


--
-- TOC entry 255 (class 1259 OID 37210)
-- Name: partscraphist; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE partscraphist (
    partscraphist_id integer NOT NULL,
    partscraphist_part_id integer NOT NULL,
    partscraphist_partscrapcode_id integer NOT NULL,
    partscraphist_description text,
    partscraphist_usr_id integer NOT NULL,
    partscraphist_timestamp timestamp without time zone DEFAULT now() NOT NULL,
    partscraphist_orig_item_id integer NOT NULL,
    partscraphist_orig_rev text NOT NULL,
    partscraphist_orig_serialnumber text NOT NULL
);


ALTER TABLE partscraphist OWNER TO admin;

--
-- TOC entry 256 (class 1259 OID 37217)
-- Name: partscraphist_partscraphist_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE partscraphist_partscraphist_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE partscraphist_partscraphist_id_seq OWNER TO admin;

--
-- TOC entry 3274 (class 0 OID 0)
-- Dependencies: 256
-- Name: partscraphist_partscraphist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE partscraphist_partscraphist_id_seq OWNED BY partscraphist.partscraphist_id;


--
-- TOC entry 257 (class 1259 OID 37219)
-- Name: partstate; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE partstate (
    partstate_id integer NOT NULL,
    partstate_name text NOT NULL,
    partstate_description text,
    partstate_active boolean DEFAULT true NOT NULL
);


ALTER TABLE partstate OWNER TO admin;

--
-- TOC entry 258 (class 1259 OID 37226)
-- Name: partstate_partstate_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE partstate_partstate_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE partstate_partstate_id_seq OWNER TO admin;

--
-- TOC entry 3275 (class 0 OID 0)
-- Dependencies: 258
-- Name: partstate_partstate_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE partstate_partstate_id_seq OWNED BY partstate.partstate_id;


SET default_with_oids = false;

--
-- TOC entry 259 (class 1259 OID 37228)
-- Name: partstatecode; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE partstatecode (
    partstatecode_id integer NOT NULL,
    partstatecode_code text NOT NULL,
    partstatecode_description text
);


ALTER TABLE partstatecode OWNER TO admin;

--
-- TOC entry 260 (class 1259 OID 37234)
-- Name: partstatecode_partstatecode_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE partstatecode_partstatecode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE partstatecode_partstatecode_id_seq OWNER TO admin;

--
-- TOC entry 3276 (class 0 OID 0)
-- Dependencies: 260
-- Name: partstatecode_partstatecode_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE partstatecode_partstatecode_id_seq OWNED BY partstatecode.partstatecode_id;


SET default_with_oids = true;

--
-- TOC entry 261 (class 1259 OID 37236)
-- Name: partstateflow; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE partstateflow (
    partstateflow_id integer NOT NULL,
    partstateflow_start_partstate_id integer NOT NULL,
    partstateflow_end_partstate_id integer NOT NULL,
    partstateflow_active boolean DEFAULT true NOT NULL,
    partstateflow_overridereq boolean DEFAULT false NOT NULL
);


ALTER TABLE partstateflow OWNER TO admin;

--
-- TOC entry 262 (class 1259 OID 37241)
-- Name: partstateflow_partstateflow_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE partstateflow_partstateflow_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE partstateflow_partstateflow_id_seq OWNER TO admin;

--
-- TOC entry 3277 (class 0 OID 0)
-- Dependencies: 262
-- Name: partstateflow_partstateflow_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE partstateflow_partstateflow_id_seq OWNED BY partstateflow.partstateflow_id;


--
-- TOC entry 263 (class 1259 OID 37243)
-- Name: partstatehist; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE partstatehist (
    partstatehist_id integer NOT NULL,
    partstatehist_part_id integer NOT NULL,
    partstatehist_start_partstate_id integer NOT NULL,
    partstatehist_end_partstate_id integer NOT NULL,
    partstatehist_timestamp timestamp without time zone DEFAULT now() NOT NULL,
    partstatehist_usr_id integer NOT NULL,
    partstatehist_orig_item_id integer NOT NULL,
    partstatehist_orig_rev text NOT NULL,
    partstatehist_orig_serialnumber text NOT NULL,
    partstatehist_overridden boolean DEFAULT false NOT NULL
);


ALTER TABLE partstatehist OWNER TO admin;

--
-- TOC entry 264 (class 1259 OID 37251)
-- Name: partstatehist_partstatehist_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE partstatehist_partstatehist_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE partstatehist_partstatehist_id_seq OWNER TO admin;

--
-- TOC entry 3278 (class 0 OID 0)
-- Dependencies: 264
-- Name: partstatehist_partstatehist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE partstatehist_partstatehist_id_seq OWNED BY partstatehist.partstatehist_id;


--
-- TOC entry 265 (class 1259 OID 37253)
-- Name: partwatcher; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE partwatcher (
    partwatcher_id integer NOT NULL,
    partwatcher_part_id integer NOT NULL,
    partwatcher_usr_id integer NOT NULL
);


ALTER TABLE partwatcher OWNER TO admin;

--
-- TOC entry 266 (class 1259 OID 37256)
-- Name: partwatcher_partwatcher_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE partwatcher_partwatcher_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE partwatcher_partwatcher_id_seq OWNER TO admin;

--
-- TOC entry 3279 (class 0 OID 0)
-- Dependencies: 266
-- Name: partwatcher_partwatcher_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE partwatcher_partwatcher_id_seq OWNED BY partwatcher.partwatcher_id;


SET default_with_oids = false;

--
-- TOC entry 267 (class 1259 OID 37258)
-- Name: priv; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE priv (
    priv_id integer NOT NULL,
    priv_module_id integer NOT NULL,
    priv_name text NOT NULL,
    priv_description text,
    priv_sequence integer DEFAULT 0 NOT NULL,
    priv_privtype_id integer
);


ALTER TABLE priv OWNER TO admin;

--
-- TOC entry 268 (class 1259 OID 37265)
-- Name: priv_priv_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE priv_priv_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE priv_priv_id_seq OWNER TO admin;

--
-- TOC entry 3280 (class 0 OID 0)
-- Dependencies: 268
-- Name: priv_priv_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE priv_priv_id_seq OWNED BY priv.priv_id;


SET default_with_oids = true;

--
-- TOC entry 269 (class 1259 OID 37267)
-- Name: privtype; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE privtype (
    privtype_id integer NOT NULL,
    privtype_name text,
    privtype_description text
);


ALTER TABLE privtype OWNER TO admin;

--
-- TOC entry 270 (class 1259 OID 37273)
-- Name: privtype_privtype_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE privtype_privtype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE privtype_privtype_id_seq OWNER TO admin;

--
-- TOC entry 3281 (class 0 OID 0)
-- Dependencies: 270
-- Name: privtype_privtype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE privtype_privtype_id_seq OWNED BY privtype.privtype_id;


--
-- TOC entry 271 (class 1259 OID 37275)
-- Name: recordcustparamlink; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE recordcustparamlink (
    recordcustparamlink_id integer NOT NULL,
    recordcustparamlink_custparam_id integer NOT NULL,
    recordcustparamlink_recordtype_id integer NOT NULL,
    recordcustparamlink_active boolean DEFAULT true NOT NULL
);


ALTER TABLE recordcustparamlink OWNER TO admin;

--
-- TOC entry 272 (class 1259 OID 37279)
-- Name: recordcustparamlink_recordcustparamlink_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE recordcustparamlink_recordcustparamlink_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE recordcustparamlink_recordcustparamlink_id_seq OWNER TO admin;

--
-- TOC entry 3282 (class 0 OID 0)
-- Dependencies: 272
-- Name: recordcustparamlink_recordcustparamlink_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE recordcustparamlink_recordcustparamlink_id_seq OWNED BY recordcustparamlink.recordcustparamlink_id;


--
-- TOC entry 273 (class 1259 OID 37281)
-- Name: recordcustparamvalue; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE recordcustparamvalue (
    recordcustparamvalue_id integer NOT NULL,
    recordcustparamvalue_custparam_id integer NOT NULL,
    recordcustparamvalue_recordtype_id integer NOT NULL,
    recordcustparamvalue_record_id integer NOT NULL,
    recordcustparamvalue_value text NOT NULL,
    recordcustparamvalue_submit_timestamp timestamp without time zone DEFAULT now() NOT NULL,
    recordcustparamvalue_void_timestamp timestamp without time zone
);


ALTER TABLE recordcustparamvalue OWNER TO admin;

--
-- TOC entry 274 (class 1259 OID 37288)
-- Name: recordcustparamvalue_recordcustparamvalue_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE recordcustparamvalue_recordcustparamvalue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE recordcustparamvalue_recordcustparamvalue_id_seq OWNER TO admin;

--
-- TOC entry 3283 (class 0 OID 0)
-- Dependencies: 274
-- Name: recordcustparamvalue_recordcustparamvalue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE recordcustparamvalue_recordcustparamvalue_id_seq OWNED BY recordcustparamvalue.recordcustparamvalue_id;


--
-- TOC entry 275 (class 1259 OID 37290)
-- Name: recorddoclink; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE recorddoclink (
    recorddoclink_id integer NOT NULL,
    recorddoclink_doctype_id integer NOT NULL,
    recorddoclink_recordtype_id integer NOT NULL,
    recorddoclink_record_id integer NOT NULL,
    recorddoclink_docnumber text NOT NULL,
    recorddoclink_submit_timestamp timestamp without time zone DEFAULT now() NOT NULL,
    recorddoclink_void_timestamp timestamp without time zone
);


ALTER TABLE recorddoclink OWNER TO admin;

--
-- TOC entry 276 (class 1259 OID 37297)
-- Name: recorddoclink_recorddoclink_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE recorddoclink_recorddoclink_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE recorddoclink_recorddoclink_id_seq OWNER TO admin;

--
-- TOC entry 3284 (class 0 OID 0)
-- Dependencies: 276
-- Name: recorddoclink_recorddoclink_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE recorddoclink_recorddoclink_id_seq OWNED BY recorddoclink.recorddoclink_id;


SET default_with_oids = false;

--
-- TOC entry 277 (class 1259 OID 37299)
-- Name: recordfile; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE recordfile (
    recordfile_id integer NOT NULL,
    recordfile_recordtype_id integer NOT NULL,
    recordfile_record_id integer NOT NULL,
    recordfile_recordfiledata_id integer NOT NULL,
    recordfile_recordfilethumbnail_id integer,
    recordfile_filename text,
    recordfile_filetype_id integer NOT NULL,
    recordfile_submit_timestamp timestamp without time zone DEFAULT now() NOT NULL,
    recordfile_void_timestamp timestamp without time zone,
    recordfile_custfiletype_id integer
);


ALTER TABLE recordfile OWNER TO admin;

--
-- TOC entry 278 (class 1259 OID 37306)
-- Name: recordfile_recordfile_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE recordfile_recordfile_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE recordfile_recordfile_id_seq OWNER TO admin;

--
-- TOC entry 3285 (class 0 OID 0)
-- Dependencies: 278
-- Name: recordfile_recordfile_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE recordfile_recordfile_id_seq OWNED BY recordfile.recordfile_id;


--
-- TOC entry 279 (class 1259 OID 37308)
-- Name: recordfiledata; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE recordfiledata (
    recordfiledata_id integer NOT NULL,
    recordfiledata_data bytea NOT NULL
);


ALTER TABLE recordfiledata OWNER TO admin;

--
-- TOC entry 280 (class 1259 OID 37314)
-- Name: recordfiledata_recordfiledata_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE recordfiledata_recordfiledata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE recordfiledata_recordfiledata_id_seq OWNER TO admin;

--
-- TOC entry 3286 (class 0 OID 0)
-- Dependencies: 280
-- Name: recordfiledata_recordfiledata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE recordfiledata_recordfiledata_id_seq OWNED BY recordfiledata.recordfiledata_id;


--
-- TOC entry 281 (class 1259 OID 37316)
-- Name: recordfilethumbnail; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE recordfilethumbnail (
    recordfilethumbnail_id integer NOT NULL,
    recordfilethumbnail_data bytea
);


ALTER TABLE recordfilethumbnail OWNER TO admin;

--
-- TOC entry 282 (class 1259 OID 37322)
-- Name: recordfilethumbnail_recordfilethumbnail_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE recordfilethumbnail_recordfilethumbnail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE recordfilethumbnail_recordfilethumbnail_id_seq OWNER TO admin;

--
-- TOC entry 3287 (class 0 OID 0)
-- Dependencies: 282
-- Name: recordfilethumbnail_recordfilethumbnail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE recordfilethumbnail_recordfilethumbnail_id_seq OWNED BY recordfilethumbnail.recordfilethumbnail_id;


--
-- TOC entry 283 (class 1259 OID 37324)
-- Name: recordlog; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE recordlog (
    recordlog_id integer NOT NULL,
    recordlog_module_id integer NOT NULL,
    recordlog_recordlogaction_id integer NOT NULL,
    recordlog_recordtype_id integer NOT NULL,
    recordlog_record_id integer NOT NULL,
    recordlog_doctype_id integer,
    recordlog_docnumber text,
    recordlog_message text NOT NULL,
    recordlog_usr_id integer NOT NULL,
    recordlog_timestamp timestamp without time zone DEFAULT now() NOT NULL,
    recordlog_secondary_recordtype_id integer,
    recordlog_secondary_record_id integer
);


ALTER TABLE recordlog OWNER TO admin;

--
-- TOC entry 284 (class 1259 OID 37331)
-- Name: recordlog_recordlog_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE recordlog_recordlog_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE recordlog_recordlog_id_seq OWNER TO admin;

--
-- TOC entry 3288 (class 0 OID 0)
-- Dependencies: 284
-- Name: recordlog_recordlog_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE recordlog_recordlog_id_seq OWNED BY recordlog.recordlog_id;


SET default_with_oids = true;

--
-- TOC entry 285 (class 1259 OID 37333)
-- Name: recordlogaction; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE recordlogaction (
    recordlogaction_id integer NOT NULL,
    recordlogaction_name text,
    recordlogaction_description text,
    recordlogaction_recordlogactiontype_id integer
);


ALTER TABLE recordlogaction OWNER TO admin;

--
-- TOC entry 286 (class 1259 OID 37339)
-- Name: recordlogaction_recordlogaction_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE recordlogaction_recordlogaction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE recordlogaction_recordlogaction_id_seq OWNER TO admin;

--
-- TOC entry 3289 (class 0 OID 0)
-- Dependencies: 286
-- Name: recordlogaction_recordlogaction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE recordlogaction_recordlogaction_id_seq OWNED BY recordlogaction.recordlogaction_id;


--
-- TOC entry 287 (class 1259 OID 37341)
-- Name: recordlogactiontype; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE recordlogactiontype (
    recordlogactiontype_id integer NOT NULL,
    recordlogactiontype_name text,
    recordlogactiontype_description text
);


ALTER TABLE recordlogactiontype OWNER TO admin;

--
-- TOC entry 288 (class 1259 OID 37347)
-- Name: recordlogactiontype_recordlogactiontype_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE recordlogactiontype_recordlogactiontype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE recordlogactiontype_recordlogactiontype_id_seq OWNER TO admin;

--
-- TOC entry 3290 (class 0 OID 0)
-- Dependencies: 288
-- Name: recordlogactiontype_recordlogactiontype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE recordlogactiontype_recordlogactiontype_id_seq OWNED BY recordlogactiontype.recordlogactiontype_id;


--
-- TOC entry 289 (class 1259 OID 37349)
-- Name: recordtype; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE recordtype (
    recordtype_id integer NOT NULL,
    recordtype_name text NOT NULL,
    recordtype_description text,
    recordtype_prefix text NOT NULL,
    recordtype_padlen integer NOT NULL
);


ALTER TABLE recordtype OWNER TO admin;

--
-- TOC entry 290 (class 1259 OID 37355)
-- Name: recordtype_recordtype_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE recordtype_recordtype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE recordtype_recordtype_id_seq OWNER TO admin;

--
-- TOC entry 3291 (class 0 OID 0)
-- Dependencies: 290
-- Name: recordtype_recordtype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE recordtype_recordtype_id_seq OWNED BY recordtype.recordtype_id;


--
-- TOC entry 291 (class 1259 OID 37357)
-- Name: recordwatcher; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE recordwatcher (
    recordwatcher_id integer NOT NULL,
    recordwatcher_recordtype_id integer NOT NULL,
    recordwatcher_record_id integer NOT NULL,
    recordwatcher_usr_id integer NOT NULL
);


ALTER TABLE recordwatcher OWNER TO admin;

--
-- TOC entry 292 (class 1259 OID 37360)
-- Name: recordwatcher_recordwatcher_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE recordwatcher_recordwatcher_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE recordwatcher_recordwatcher_id_seq OWNER TO admin;

--
-- TOC entry 3292 (class 0 OID 0)
-- Dependencies: 292
-- Name: recordwatcher_recordwatcher_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE recordwatcher_recordwatcher_id_seq OWNED BY recordwatcher.recordwatcher_id;


SET default_with_oids = false;

--
-- TOC entry 293 (class 1259 OID 37362)
-- Name: role; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE role (
    role_id integer NOT NULL,
    role_name text,
    role_description text,
    role_active boolean DEFAULT true NOT NULL
);


ALTER TABLE role OWNER TO admin;

--
-- TOC entry 294 (class 1259 OID 37369)
-- Name: role_role_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE role_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE role_role_id_seq OWNER TO admin;

--
-- TOC entry 3293 (class 0 OID 0)
-- Dependencies: 294
-- Name: role_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE role_role_id_seq OWNED BY role.role_id;


SET default_with_oids = true;

--
-- TOC entry 295 (class 1259 OID 37371)
-- Name: rolepriv; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE rolepriv (
    rolepriv_id integer NOT NULL,
    rolepriv_role_id integer NOT NULL,
    rolepriv_priv_id integer NOT NULL
);


ALTER TABLE rolepriv OWNER TO admin;

--
-- TOC entry 296 (class 1259 OID 37374)
-- Name: rolepriv_rolepriv_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE rolepriv_rolepriv_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE rolepriv_rolepriv_id_seq OWNER TO admin;

--
-- TOC entry 3294 (class 0 OID 0)
-- Dependencies: 296
-- Name: rolepriv_rolepriv_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE rolepriv_rolepriv_id_seq OWNED BY rolepriv.rolepriv_id;


--
-- TOC entry 297 (class 1259 OID 37376)
-- Name: serialpattern; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE serialpattern (
    serialpattern_id integer NOT NULL,
    serialpattern_name text NOT NULL,
    serialpattern_pattern text NOT NULL
);


ALTER TABLE serialpattern OWNER TO admin;

--
-- TOC entry 298 (class 1259 OID 37382)
-- Name: serialpattern_serialpattern_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE serialpattern_serialpattern_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE serialpattern_serialpattern_id_seq OWNER TO admin;

--
-- TOC entry 3295 (class 0 OID 0)
-- Dependencies: 298
-- Name: serialpattern_serialpattern_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE serialpattern_serialpattern_id_seq OWNED BY serialpattern.serialpattern_id;


--
-- TOC entry 299 (class 1259 OID 37384)
-- Name: serialprefix; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE serialprefix (
    serialprefix_id integer NOT NULL,
    serialprefix_name text,
    serialprefix_prefix text,
    serialprefix_serialpattern_id integer
);


ALTER TABLE serialprefix OWNER TO admin;

--
-- TOC entry 300 (class 1259 OID 37390)
-- Name: serialprefix_serialprefix_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE serialprefix_serialprefix_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE serialprefix_serialprefix_id_seq OWNER TO admin;

--
-- TOC entry 3296 (class 0 OID 0)
-- Dependencies: 300
-- Name: serialprefix_serialprefix_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE serialprefix_serialprefix_id_seq OWNED BY serialprefix.serialprefix_id;


--
-- TOC entry 301 (class 1259 OID 37392)
-- Name: serialstream; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE serialstream (
    serialstream_id integer NOT NULL,
    serialstream_name text
);


ALTER TABLE serialstream OWNER TO admin;

--
-- TOC entry 302 (class 1259 OID 37398)
-- Name: serialstream_serialstream_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE serialstream_serialstream_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE serialstream_serialstream_id_seq OWNER TO admin;

--
-- TOC entry 3297 (class 0 OID 0)
-- Dependencies: 302
-- Name: serialstream_serialstream_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE serialstream_serialstream_id_seq OWNED BY serialstream.serialstream_id;


--
-- TOC entry 303 (class 1259 OID 37400)
-- Name: station; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE station (
    station_id integer NOT NULL,
    station_name text NOT NULL,
    station_description text,
    station_active boolean DEFAULT true NOT NULL,
    station_stationtype_id integer
);


ALTER TABLE station OWNER TO admin;

--
-- TOC entry 304 (class 1259 OID 37407)
-- Name: station_station_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE station_station_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE station_station_id_seq OWNER TO admin;

--
-- TOC entry 3298 (class 0 OID 0)
-- Dependencies: 304
-- Name: station_station_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE station_station_id_seq OWNED BY station.station_id;


--
-- TOC entry 305 (class 1259 OID 37409)
-- Name: stationtype; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE stationtype (
    stationtype_id integer NOT NULL,
    stationtype_name text NOT NULL,
    stationtype_description text,
    stationtype_active boolean DEFAULT true NOT NULL
);


ALTER TABLE stationtype OWNER TO admin;

--
-- TOC entry 306 (class 1259 OID 37416)
-- Name: stationtype_stationtype_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE stationtype_stationtype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE stationtype_stationtype_id_seq OWNER TO admin;

--
-- TOC entry 3299 (class 0 OID 0)
-- Dependencies: 306
-- Name: stationtype_stationtype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE stationtype_stationtype_id_seq OWNED BY stationtype.stationtype_id;


--
-- TOC entry 307 (class 1259 OID 37418)
-- Name: usr; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE usr (
    usr_id integer NOT NULL,
    usr_username text NOT NULL,
    usr_name text NOT NULL,
    usr_email text NOT NULL,
    usr_active boolean DEFAULT true NOT NULL
);


ALTER TABLE usr OWNER TO admin;

--
-- TOC entry 308 (class 1259 OID 37425)
-- Name: user_user_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE user_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE user_user_id_seq OWNER TO admin;

--
-- TOC entry 3300 (class 0 OID 0)
-- Dependencies: 308
-- Name: user_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE user_user_id_seq OWNED BY usr.usr_id;


--
-- TOC entry 309 (class 1259 OID 37427)
-- Name: usrpriv; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE usrpriv (
    usrpriv_id integer NOT NULL,
    usrpriv_usr_id integer NOT NULL,
    usrpriv_priv_id integer NOT NULL
);


ALTER TABLE usrpriv OWNER TO admin;

--
-- TOC entry 310 (class 1259 OID 37430)
-- Name: userpriv_userpriv_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE userpriv_userpriv_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE userpriv_userpriv_id_seq OWNER TO admin;

--
-- TOC entry 3301 (class 0 OID 0)
-- Dependencies: 310
-- Name: userpriv_userpriv_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE userpriv_userpriv_id_seq OWNED BY usrpriv.usrpriv_id;


--
-- TOC entry 311 (class 1259 OID 37432)
-- Name: usrrole; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE usrrole (
    usrrole_id integer NOT NULL,
    usrrole_usr_id integer NOT NULL,
    usrrole_role_id integer NOT NULL
);


ALTER TABLE usrrole OWNER TO admin;

--
-- TOC entry 312 (class 1259 OID 37435)
-- Name: userrole_userrole_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE userrole_userrole_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE userrole_userrole_id_seq OWNER TO admin;

--
-- TOC entry 3302 (class 0 OID 0)
-- Dependencies: 312
-- Name: userrole_userrole_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE userrole_userrole_id_seq OWNED BY usrrole.usrrole_id;


--
-- TOC entry 313 (class 1259 OID 37437)
-- Name: viewbackflush; Type: VIEW; Schema: public; Owner: admin
--

CREATE VIEW viewbackflush AS
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
   FROM (((((((((backflush
     LEFT JOIN part ON ((part.part_id = backflush.backflush_part_id)))
     LEFT JOIN item pitem ON ((pitem.item_id = part.part_item_id)))
     LEFT JOIN item oitem ON ((oitem.item_id = backflush.backflush_orig_item_id)))
     LEFT JOIN doctype ON ((doctype.doctype_id = backflush.backflush_doctype_id)))
     LEFT JOIN usr cusr ON ((cusr.usr_id = backflush.backflush_create_usr_id)))
     LEFT JOIN usr busr ON ((busr.usr_id = backflush.backflush_complete_usr_id)))
     LEFT JOIN usr vusr ON ((vusr.usr_id = backflush.backflush_void_usr_id)))
     LEFT JOIN line ON ((line.line_id = backflush.backflush_line_id)))
     LEFT JOIN station ON ((station.station_id = backflush.backflush_station_id)));


ALTER TABLE viewbackflush OWNER TO admin;

--
-- TOC entry 314 (class 1259 OID 37442)
-- Name: viewitem; Type: VIEW; Schema: public; Owner: admin
--

CREATE VIEW viewitem AS
 SELECT item.item_id,
    item.item_number,
    item.item_description,
    item.item_active,
    serialstream.serialstream_name,
    serialprefix.serialprefix_prefix,
    serialpattern.serialpattern_pattern,
    itemfreqcode.itemfreqcode_freqcode
   FROM ((((item
     LEFT JOIN serialstream ON ((serialstream.serialstream_id = item.item_serialstream_id)))
     LEFT JOIN serialprefix ON ((serialprefix.serialprefix_id = item.item_serialprefix_id)))
     LEFT JOIN serialpattern ON ((serialpattern.serialpattern_id = serialprefix.serialprefix_serialpattern_id)))
     LEFT JOIN itemfreqcode ON ((itemfreqcode.itemfreqcode_id = item.item_itemfreqcode_id)));


ALTER TABLE viewitem OWNER TO admin;

--
-- TOC entry 315 (class 1259 OID 37447)
-- Name: viewitemcustparamlink; Type: VIEW; Schema: public; Owner: admin
--

CREATE VIEW viewitemcustparamlink AS
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
   FROM (((itemcustparamlink
     LEFT JOIN custparam ON ((custparam.custparam_id = itemcustparamlink.itemcustparamlink_custparam_id)))
     LEFT JOIN datatype ON ((datatype.datatype_id = custparam.custparam_datatype_id)))
     LEFT JOIN item ON ((item.item_id = itemcustparamlink.itemcustparamlink_item_id)));


ALTER TABLE viewitemcustparamlink OWNER TO admin;

--
-- TOC entry 316 (class 1259 OID 37452)
-- Name: viewitemrev; Type: VIEW; Schema: public; Owner: admin
--

CREATE VIEW viewitemrev AS
 SELECT itemrev.itemrev_id,
    itemrev.itemrev_rev,
    itemrev.itemrev_npi,
    itemrev.itemrev_item_id,
    item.item_number,
    item.item_description,
    item.item_active
   FROM (itemrev
     LEFT JOIN item ON ((item.item_id = itemrev.itemrev_item_id)));


ALTER TABLE viewitemrev OWNER TO admin;

--
-- TOC entry 317 (class 1259 OID 37456)
-- Name: viewpart; Type: VIEW; Schema: public; Owner: admin
--

CREATE VIEW viewpart AS
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
   FROM (((((((part
     LEFT JOIN item ON ((item.item_id = part.part_item_id)))
     LEFT JOIN partstate ON ((partstate.partstate_id = part.part_partstate_id)))
     LEFT JOIN loc ON ((loc.loc_id = part.part_loc_id)))
     LEFT JOIN cust ON ((cust.cust_id = part.part_cust_id)))
     LEFT JOIN doctype ON ((doctype.doctype_id = part.part_create_doctype_id)))
     LEFT JOIN part parentpart ON ((parentpart.part_id = part.part_parent_part_id)))
     LEFT JOIN item parentitem ON ((parentitem.item_id = parentpart.part_item_id)))
  ORDER BY item.item_number, part.part_sequencenumber, part.part_serialnumber;


ALTER TABLE viewpart OWNER TO admin;

--
-- TOC entry 318 (class 1259 OID 37461)
-- Name: viewpartcustparamvalue; Type: VIEW; Schema: public; Owner: admin
--

CREATE VIEW viewpartcustparamvalue AS
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
   FROM ((((partcustparamvalue
     LEFT JOIN custparam ON ((custparam.custparam_id = partcustparamvalue.partcustparamvalue_custparam_id)))
     LEFT JOIN datatype ON ((datatype.datatype_id = custparam.custparam_datatype_id)))
     LEFT JOIN part ON ((part.part_id = partcustparamvalue.partcustparamvalue_part_id)))
     LEFT JOIN item ON ((item.item_id = part.part_item_id)));


ALTER TABLE viewpartcustparamvalue OWNER TO admin;

--
-- TOC entry 319 (class 1259 OID 37466)
-- Name: viewpartdoclink; Type: VIEW; Schema: public; Owner: admin
--

CREATE VIEW viewpartdoclink AS
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
   FROM (((partdoclink
     LEFT JOIN doctype ON ((doctype.doctype_id = partdoclink.partdoclink_doctype_id)))
     LEFT JOIN part ON ((part.part_id = partdoclink.partdoclink_part_id)))
     LEFT JOIN item ON ((item.item_id = part.part_item_id)));


ALTER TABLE viewpartdoclink OWNER TO admin;

--
-- TOC entry 320 (class 1259 OID 37471)
-- Name: viewpartlog; Type: VIEW; Schema: public; Owner: admin
--

CREATE VIEW viewpartlog AS
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
   FROM (((((((((partlog
     LEFT JOIN part ON ((part.part_id = partlog.partlog_part_id)))
     LEFT JOIN item pitem ON ((pitem.item_id = part.part_item_id)))
     LEFT JOIN item oitem ON ((oitem.item_id = partlog.partlog_orig_item_id)))
     LEFT JOIN module ON ((module.module_id = partlog.partlog_module_id)))
     LEFT JOIN partlogaction ON ((partlogaction.partlogaction_id = partlog.partlog_partlogaction_id)))
     LEFT JOIN partlogactiontype ON ((partlogactiontype.partlogactiontype_id = partlogaction.partlogaction_partlogactiontype_id)))
     LEFT JOIN recordtype ON ((recordtype.recordtype_id = partlog.partlog_recordtype_id)))
     LEFT JOIN doctype ON ((doctype.doctype_id = partlog.partlog_doctype_id)))
     LEFT JOIN usr ON ((usr.usr_id = partlog.partlog_usr_id)))
  ORDER BY partlog.partlog_id;


ALTER TABLE viewpartlog OWNER TO admin;

--
-- TOC entry 321 (class 1259 OID 37476)
-- Name: viewpartstateflow; Type: VIEW; Schema: public; Owner: admin
--

CREATE VIEW viewpartstateflow AS
 SELECT sps.partstate_id AS start_partstate_id,
    sps.partstate_name AS start_partstate_name,
    sps.partstate_active AS start_partstate_active,
    eps.partstate_id AS end_partstate_id,
    eps.partstate_name AS end_partstate_name,
    eps.partstate_active AS end_partstate_active,
    partstateflow.partstateflow_id,
    partstateflow.partstateflow_active,
    partstateflow.partstateflow_overridereq
   FROM ((partstateflow
     LEFT JOIN partstate sps ON ((sps.partstate_id = partstateflow.partstateflow_start_partstate_id)))
     LEFT JOIN partstate eps ON ((eps.partstate_id = partstateflow.partstateflow_end_partstate_id)));


ALTER TABLE viewpartstateflow OWNER TO admin;

--
-- TOC entry 322 (class 1259 OID 37480)
-- Name: viewpartwatcher; Type: VIEW; Schema: public; Owner: admin
--

CREATE VIEW viewpartwatcher AS
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
   FROM (((partwatcher
     LEFT JOIN part ON ((part.part_id = partwatcher.partwatcher_part_id)))
     LEFT JOIN item ON ((item.item_id = part.part_item_id)))
     LEFT JOIN usr ON ((usr.usr_id = partwatcher.partwatcher_usr_id)))
  ORDER BY item.item_number, part.part_sequencenumber, part.part_serialnumber, usr.usr_username;


ALTER TABLE viewpartwatcher OWNER TO admin;

--
-- TOC entry 323 (class 1259 OID 37485)
-- Name: viewprivgranted; Type: VIEW; Schema: public; Owner: admin
--

CREATE VIEW viewprivgranted AS
 SELECT usr.usr_username,
    priv.priv_name,
    module.module_name,
    true AS priv_granted
   FROM (((usrpriv
     LEFT JOIN usr ON ((usr.usr_id = usrpriv.usrpriv_usr_id)))
     LEFT JOIN priv ON ((priv.priv_id = usrpriv.usrpriv_priv_id)))
     LEFT JOIN module ON ((module.module_id = priv.priv_module_id)))
UNION
 SELECT usr.usr_username,
    priv.priv_name,
    module.module_name,
    true AS priv_granted
   FROM (((((rolepriv
     LEFT JOIN role ON ((role.role_id = rolepriv.rolepriv_role_id)))
     LEFT JOIN usrrole ON ((usrrole.usrrole_role_id = role.role_id)))
     LEFT JOIN usr ON ((usr.usr_id = usrrole.usrrole_usr_id)))
     LEFT JOIN priv ON ((priv.priv_id = rolepriv.rolepriv_priv_id)))
     LEFT JOIN module ON ((module.module_id = priv.priv_module_id)));


ALTER TABLE viewprivgranted OWNER TO admin;

--
-- TOC entry 324 (class 1259 OID 37490)
-- Name: viewrecordcustparamlink; Type: VIEW; Schema: public; Owner: admin
--

CREATE VIEW viewrecordcustparamlink AS
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
   FROM (((recordcustparamlink
     LEFT JOIN custparam ON ((custparam.custparam_id = recordcustparamlink.recordcustparamlink_custparam_id)))
     LEFT JOIN datatype ON ((datatype.datatype_id = custparam.custparam_datatype_id)))
     LEFT JOIN recordtype ON ((recordtype.recordtype_id = recordcustparamlink.recordcustparamlink_recordtype_id)));


ALTER TABLE viewrecordcustparamlink OWNER TO admin;

--
-- TOC entry 325 (class 1259 OID 37495)
-- Name: viewrecordcustparamvalue; Type: VIEW; Schema: public; Owner: admin
--

CREATE VIEW viewrecordcustparamvalue AS
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
   FROM (((recordcustparamvalue
     LEFT JOIN custparam ON ((custparam.custparam_id = recordcustparamvalue.recordcustparamvalue_custparam_id)))
     LEFT JOIN datatype ON ((datatype.datatype_id = custparam.custparam_datatype_id)))
     LEFT JOIN recordtype ON ((recordtype.recordtype_id = recordcustparamvalue.recordcustparamvalue_recordtype_id)));


ALTER TABLE viewrecordcustparamvalue OWNER TO admin;

--
-- TOC entry 326 (class 1259 OID 37500)
-- Name: viewrecorddoclink; Type: VIEW; Schema: public; Owner: admin
--

CREATE VIEW viewrecorddoclink AS
 SELECT recorddoclink.recorddoclink_id,
    doctype.doctype_id,
    doctype.doctype_name,
    doctype.doctype_description,
    recorddoclink.recorddoclink_docnumber,
    recordtype.recordtype_name,
    recorddoclink.recorddoclink_record_id,
    recorddoclink.recorddoclink_submit_timestamp,
    recorddoclink.recorddoclink_void_timestamp
   FROM ((recorddoclink
     LEFT JOIN doctype ON ((doctype.doctype_id = recorddoclink.recorddoclink_doctype_id)))
     LEFT JOIN recordtype ON ((recordtype.recordtype_id = recorddoclink.recorddoclink_recordtype_id)));


ALTER TABLE viewrecorddoclink OWNER TO admin;

--
-- TOC entry 327 (class 1259 OID 37504)
-- Name: viewrecordwatcher; Type: VIEW; Schema: public; Owner: admin
--

CREATE VIEW viewrecordwatcher AS
 SELECT recordtype.recordtype_name,
    recordwatcher.recordwatcher_record_id,
    usr.usr_username,
    usr.usr_name,
    usr.usr_email,
    usr.usr_active
   FROM ((recordwatcher
     LEFT JOIN recordtype ON ((recordtype.recordtype_id = recordwatcher.recordwatcher_recordtype_id)))
     LEFT JOIN usr ON ((usr.usr_id = recordwatcher.recordwatcher_usr_id)))
  ORDER BY recordtype.recordtype_name, recordwatcher.recordwatcher_record_id, usr.usr_username;


ALTER TABLE viewrecordwatcher OWNER TO admin;

--
-- TOC entry 2629 (class 2604 OID 37508)
-- Name: backflush_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY backflush ALTER COLUMN backflush_id SET DEFAULT nextval('backflush_backflush_id_seq'::regclass);


--
-- TOC entry 2630 (class 2604 OID 37509)
-- Name: bom_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY bom ALTER COLUMN bom_id SET DEFAULT nextval('bom_bom_id_seq'::regclass);


--
-- TOC entry 2633 (class 2604 OID 37510)
-- Name: cust_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cust ALTER COLUMN cust_id SET DEFAULT nextval('cust_cust_id_seq'::regclass);


--
-- TOC entry 2635 (class 2604 OID 37511)
-- Name: custfiletype_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY custfiletype ALTER COLUMN custfiletype_id SET DEFAULT nextval('custfiletype_custfiletype_id_seq'::regclass);


--
-- TOC entry 2637 (class 2604 OID 37512)
-- Name: custhist_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY custhist ALTER COLUMN custhist_id SET DEFAULT nextval('custhist_custhist_id_seq'::regclass);


--
-- TOC entry 2639 (class 2604 OID 37513)
-- Name: custparam_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY custparam ALTER COLUMN custparam_id SET DEFAULT nextval('custparam_custparam_id_seq'::regclass);


--
-- TOC entry 2642 (class 2604 OID 37514)
-- Name: custparamcombo_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY custparamcombo ALTER COLUMN custparamcombo_id SET DEFAULT nextval('custparamcombo_custparamcombo_id_seq'::regclass);


--
-- TOC entry 2644 (class 2604 OID 37515)
-- Name: custparamlink_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY custparamlink ALTER COLUMN custparamlink_id SET DEFAULT nextval('custparamlink_custparamlink_id_seq'::regclass);


--
-- TOC entry 2647 (class 2604 OID 37516)
-- Name: datatype_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY datatype ALTER COLUMN datatype_id SET DEFAULT nextval('datatype_datatype_id_seq'::regclass);


--
-- TOC entry 2648 (class 2604 OID 37517)
-- Name: doctype_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY doctype ALTER COLUMN doctype_id SET DEFAULT nextval('doctype_doctype_id_seq'::regclass);


--
-- TOC entry 2649 (class 2604 OID 37518)
-- Name: eco_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY eco ALTER COLUMN eco_id SET DEFAULT nextval('eco_eco_id_seq'::regclass);


--
-- TOC entry 2651 (class 2604 OID 37519)
-- Name: filetype_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY filetype ALTER COLUMN filetype_id SET DEFAULT nextval('filetype_filetype_id_seq'::regclass);


--
-- TOC entry 2655 (class 2604 OID 37520)
-- Name: item_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY item ALTER COLUMN item_id SET DEFAULT nextval('item_item_id_seq'::regclass);


--
-- TOC entry 2657 (class 2604 OID 37521)
-- Name: itemcustparamlink_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemcustparamlink ALTER COLUMN itemcustparamlink_id SET DEFAULT nextval('itemcustparamlink_itemcustparamlink_id_seq'::regclass);


--
-- TOC entry 2658 (class 2604 OID 37522)
-- Name: itemfreqcode_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemfreqcode ALTER COLUMN itemfreqcode_id SET DEFAULT nextval('itemfreqcode_itemfreqcode_id_seq'::regclass);


--
-- TOC entry 2660 (class 2604 OID 37523)
-- Name: itemrev_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemrev ALTER COLUMN itemrev_id SET DEFAULT nextval('itemrevision_itemrevision_id_seq'::regclass);


--
-- TOC entry 2662 (class 2604 OID 37524)
-- Name: itemrevflow_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemrevflow ALTER COLUMN itemrevflow_id SET DEFAULT nextval('itemrevisionflow_itemrevisionflow_id_seq'::regclass);


--
-- TOC entry 2664 (class 2604 OID 37525)
-- Name: line_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY line ALTER COLUMN line_id SET DEFAULT nextval('line_line_id_seq'::regclass);


--
-- TOC entry 2666 (class 2604 OID 37526)
-- Name: loc_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY loc ALTER COLUMN loc_id SET DEFAULT nextval('loc_loc_id_seq'::regclass);


--
-- TOC entry 2668 (class 2604 OID 37527)
-- Name: lochist_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY lochist ALTER COLUMN lochist_id SET DEFAULT nextval('lochist_lochist_id_seq'::regclass);


--
-- TOC entry 2669 (class 2604 OID 37528)
-- Name: module_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY module ALTER COLUMN module_id SET DEFAULT nextval('module_module_id_seq'::regclass);


--
-- TOC entry 2674 (class 2604 OID 37529)
-- Name: part_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY part ALTER COLUMN part_id SET DEFAULT nextval('part_part_key_seq'::regclass);


--
-- TOC entry 2676 (class 2604 OID 37530)
-- Name: partactivehist_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partactivehist ALTER COLUMN partactivehist_id SET DEFAULT nextval('partactivehist_partactivehist_id_seq'::regclass);


--
-- TOC entry 2677 (class 2604 OID 37531)
-- Name: partalloccode_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partalloccode ALTER COLUMN partalloccode_id SET DEFAULT nextval('partalloccode_partalloccode_id_seq'::regclass);


--
-- TOC entry 2680 (class 2604 OID 37532)
-- Name: partallochist_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partallochist ALTER COLUMN partallochist_id SET DEFAULT nextval('partallochist_partallochist_id_seq'::regclass);


--
-- TOC entry 2683 (class 2604 OID 37533)
-- Name: partcustparamvalue_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partcustparamvalue ALTER COLUMN partcustparamvalue_id SET DEFAULT nextval('partcustparamvalue_partcustparamvalue_id_seq'::regclass);


--
-- TOC entry 2685 (class 2604 OID 37534)
-- Name: partdoclink_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partdoclink ALTER COLUMN partdoclink_id SET DEFAULT nextval('partdoclink_partdoclink_id_seq'::regclass);


--
-- TOC entry 2687 (class 2604 OID 37535)
-- Name: partfile_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partfile ALTER COLUMN partfile_id SET DEFAULT nextval('partfile_partfile_id_seq'::regclass);


--
-- TOC entry 2689 (class 2604 OID 37536)
-- Name: partfiledata_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partfiledata ALTER COLUMN partfiledata_id SET DEFAULT nextval('partfiledata_partfiledata_id_seq'::regclass);


--
-- TOC entry 2691 (class 2604 OID 37537)
-- Name: partfilethumbnail_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partfilethumbnail ALTER COLUMN partfilethumbnail_id SET DEFAULT nextval('partfilethumbnail_partfilethumbnail_id_seq'::regclass);


--
-- TOC entry 2693 (class 2604 OID 37538)
-- Name: partlog_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partlog ALTER COLUMN partlog_id SET DEFAULT nextval('partlog_partlog_id_seq'::regclass);


--
-- TOC entry 2694 (class 2604 OID 37539)
-- Name: partlogaction_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partlogaction ALTER COLUMN partlogaction_id SET DEFAULT nextval('partlogaction_partlogaction_id_seq'::regclass);


--
-- TOC entry 2695 (class 2604 OID 37540)
-- Name: partlogactiontype_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partlogactiontype ALTER COLUMN partlogactiontype_id SET DEFAULT nextval('partlogactiontype_partlogactiontype_id_seq'::regclass);


--
-- TOC entry 2696 (class 2604 OID 37541)
-- Name: partlogtype_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partlogtype ALTER COLUMN partlogtype_id SET DEFAULT nextval('partlogtype_partlogtype_id_seq'::regclass);


--
-- TOC entry 2698 (class 2604 OID 37542)
-- Name: partrefurbhist_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partrefurbhist ALTER COLUMN partrefurbhist_id SET DEFAULT nextval('partrefurbhist_partrefurbhist_id_seq'::regclass);


--
-- TOC entry 2700 (class 2604 OID 37543)
-- Name: partrevhist_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partrevhist ALTER COLUMN partrevhist_id SET DEFAULT nextval('partrevisionhistory_partrevisionhistory_id_seq'::regclass);


--
-- TOC entry 2701 (class 2604 OID 37544)
-- Name: partscrapcode_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partscrapcode ALTER COLUMN partscrapcode_id SET DEFAULT nextval('partscrapcode_partscrapcode_id_seq'::regclass);


--
-- TOC entry 2703 (class 2604 OID 37545)
-- Name: partscraphist_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partscraphist ALTER COLUMN partscraphist_id SET DEFAULT nextval('partscraphist_partscraphist_id_seq'::regclass);


--
-- TOC entry 2705 (class 2604 OID 37546)
-- Name: partstate_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partstate ALTER COLUMN partstate_id SET DEFAULT nextval('partstate_partstate_id_seq'::regclass);


--
-- TOC entry 2706 (class 2604 OID 37547)
-- Name: partstatecode_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partstatecode ALTER COLUMN partstatecode_id SET DEFAULT nextval('partstatecode_partstatecode_id_seq'::regclass);


--
-- TOC entry 2709 (class 2604 OID 37548)
-- Name: partstateflow_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partstateflow ALTER COLUMN partstateflow_id SET DEFAULT nextval('partstateflow_partstateflow_id_seq'::regclass);


--
-- TOC entry 2712 (class 2604 OID 37549)
-- Name: partstatehist_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partstatehist ALTER COLUMN partstatehist_id SET DEFAULT nextval('partstatehist_partstatehist_id_seq'::regclass);


--
-- TOC entry 2713 (class 2604 OID 37550)
-- Name: partwatcher_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partwatcher ALTER COLUMN partwatcher_id SET DEFAULT nextval('partwatcher_partwatcher_id_seq'::regclass);


--
-- TOC entry 2715 (class 2604 OID 37551)
-- Name: priv_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY priv ALTER COLUMN priv_id SET DEFAULT nextval('priv_priv_id_seq'::regclass);


--
-- TOC entry 2716 (class 2604 OID 37552)
-- Name: privtype_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY privtype ALTER COLUMN privtype_id SET DEFAULT nextval('privtype_privtype_id_seq'::regclass);


--
-- TOC entry 2718 (class 2604 OID 37553)
-- Name: recordcustparamlink_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordcustparamlink ALTER COLUMN recordcustparamlink_id SET DEFAULT nextval('recordcustparamlink_recordcustparamlink_id_seq'::regclass);


--
-- TOC entry 2720 (class 2604 OID 37554)
-- Name: recordcustparamvalue_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordcustparamvalue ALTER COLUMN recordcustparamvalue_id SET DEFAULT nextval('recordcustparamvalue_recordcustparamvalue_id_seq'::regclass);


--
-- TOC entry 2722 (class 2604 OID 37555)
-- Name: recorddoclink_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recorddoclink ALTER COLUMN recorddoclink_id SET DEFAULT nextval('recorddoclink_recorddoclink_id_seq'::regclass);


--
-- TOC entry 2724 (class 2604 OID 37556)
-- Name: recordfile_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordfile ALTER COLUMN recordfile_id SET DEFAULT nextval('recordfile_recordfile_id_seq'::regclass);


--
-- TOC entry 2725 (class 2604 OID 37557)
-- Name: recordfiledata_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordfiledata ALTER COLUMN recordfiledata_id SET DEFAULT nextval('recordfiledata_recordfiledata_id_seq'::regclass);


--
-- TOC entry 2726 (class 2604 OID 37558)
-- Name: recordfilethumbnail_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordfilethumbnail ALTER COLUMN recordfilethumbnail_id SET DEFAULT nextval('recordfilethumbnail_recordfilethumbnail_id_seq'::regclass);


--
-- TOC entry 2728 (class 2604 OID 37559)
-- Name: recordlog_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordlog ALTER COLUMN recordlog_id SET DEFAULT nextval('recordlog_recordlog_id_seq'::regclass);


--
-- TOC entry 2729 (class 2604 OID 37560)
-- Name: recordlogaction_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordlogaction ALTER COLUMN recordlogaction_id SET DEFAULT nextval('recordlogaction_recordlogaction_id_seq'::regclass);


--
-- TOC entry 2730 (class 2604 OID 37561)
-- Name: recordlogactiontype_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordlogactiontype ALTER COLUMN recordlogactiontype_id SET DEFAULT nextval('recordlogactiontype_recordlogactiontype_id_seq'::regclass);


--
-- TOC entry 2731 (class 2604 OID 37562)
-- Name: recordtype_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordtype ALTER COLUMN recordtype_id SET DEFAULT nextval('recordtype_recordtype_id_seq'::regclass);


--
-- TOC entry 2732 (class 2604 OID 37563)
-- Name: recordwatcher_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordwatcher ALTER COLUMN recordwatcher_id SET DEFAULT nextval('recordwatcher_recordwatcher_id_seq'::regclass);


--
-- TOC entry 2734 (class 2604 OID 37564)
-- Name: role_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY role ALTER COLUMN role_id SET DEFAULT nextval('role_role_id_seq'::regclass);


--
-- TOC entry 2735 (class 2604 OID 37565)
-- Name: rolepriv_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY rolepriv ALTER COLUMN rolepriv_id SET DEFAULT nextval('rolepriv_rolepriv_id_seq'::regclass);


--
-- TOC entry 2736 (class 2604 OID 37566)
-- Name: serialpattern_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY serialpattern ALTER COLUMN serialpattern_id SET DEFAULT nextval('serialpattern_serialpattern_id_seq'::regclass);


--
-- TOC entry 2737 (class 2604 OID 37567)
-- Name: serialprefix_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY serialprefix ALTER COLUMN serialprefix_id SET DEFAULT nextval('serialprefix_serialprefix_id_seq'::regclass);


--
-- TOC entry 2738 (class 2604 OID 37568)
-- Name: serialstream_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY serialstream ALTER COLUMN serialstream_id SET DEFAULT nextval('serialstream_serialstream_id_seq'::regclass);


--
-- TOC entry 2740 (class 2604 OID 37569)
-- Name: station_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY station ALTER COLUMN station_id SET DEFAULT nextval('station_station_id_seq'::regclass);


--
-- TOC entry 2742 (class 2604 OID 37570)
-- Name: stationtype_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY stationtype ALTER COLUMN stationtype_id SET DEFAULT nextval('stationtype_stationtype_id_seq'::regclass);


--
-- TOC entry 2744 (class 2604 OID 37571)
-- Name: usr_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY usr ALTER COLUMN usr_id SET DEFAULT nextval('user_user_id_seq'::regclass);


--
-- TOC entry 2745 (class 2604 OID 37572)
-- Name: usrpriv_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY usrpriv ALTER COLUMN usrpriv_id SET DEFAULT nextval('userpriv_userpriv_id_seq'::regclass);


--
-- TOC entry 2746 (class 2604 OID 37573)
-- Name: usrrole_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY usrrole ALTER COLUMN usrrole_id SET DEFAULT nextval('userrole_userrole_id_seq'::regclass);


--
-- TOC entry 2748 (class 2606 OID 56307)
-- Name: backflush_id_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY backflush
    ADD CONSTRAINT backflush_id_pkey PRIMARY KEY (backflush_id);


--
-- TOC entry 2750 (class 2606 OID 56309)
-- Name: bom_id_pk; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY bom
    ADD CONSTRAINT bom_id_pk PRIMARY KEY (bom_id);


--
-- TOC entry 2752 (class 2606 OID 56311)
-- Name: cust_cust_number_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cust
    ADD CONSTRAINT cust_cust_number_key UNIQUE (cust_number);


--
-- TOC entry 2754 (class 2606 OID 56313)
-- Name: cust_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cust
    ADD CONSTRAINT cust_pkey PRIMARY KEY (cust_id);


--
-- TOC entry 2756 (class 2606 OID 56315)
-- Name: custfiletype_custfiletype_type_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY custfiletype
    ADD CONSTRAINT custfiletype_custfiletype_type_key UNIQUE (custfiletype_type);


--
-- TOC entry 2758 (class 2606 OID 56317)
-- Name: custfiletype_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY custfiletype
    ADD CONSTRAINT custfiletype_pkey PRIMARY KEY (custfiletype_id);


--
-- TOC entry 2760 (class 2606 OID 56319)
-- Name: custhist_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY custhist
    ADD CONSTRAINT custhist_pkey PRIMARY KEY (custhist_id);


--
-- TOC entry 2762 (class 2606 OID 56321)
-- Name: custparam_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY custparam
    ADD CONSTRAINT custparam_pkey PRIMARY KEY (custparam_id);


--
-- TOC entry 2764 (class 2606 OID 56323)
-- Name: custparamcombo_custparamcombo_custparam_id_custparamcombo_v_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY custparamcombo
    ADD CONSTRAINT custparamcombo_custparamcombo_custparam_id_custparamcombo_v_key UNIQUE (custparamcombo_custparam_id, custparamcombo_value);


--
-- TOC entry 2766 (class 2606 OID 56325)
-- Name: custparamcombo_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY custparamcombo
    ADD CONSTRAINT custparamcombo_pkey PRIMARY KEY (custparamcombo_id);


--
-- TOC entry 2768 (class 2606 OID 56327)
-- Name: custparamlink_custparamlink_custparam_id_custparamlink_item_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY custparamlink
    ADD CONSTRAINT custparamlink_custparamlink_custparam_id_custparamlink_item_key UNIQUE (custparamlink_custparam_id, custparamlink_item_id);


--
-- TOC entry 2770 (class 2606 OID 56329)
-- Name: custparamlink_custparamlink_custparam_id_custparamlink_reco_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY custparamlink
    ADD CONSTRAINT custparamlink_custparamlink_custparam_id_custparamlink_reco_key UNIQUE (custparamlink_custparam_id, custparamlink_recordtype_id);


--
-- TOC entry 2772 (class 2606 OID 56331)
-- Name: custparamlink_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY custparamlink
    ADD CONSTRAINT custparamlink_pkey PRIMARY KEY (custparamlink_id);


--
-- TOC entry 2774 (class 2606 OID 56333)
-- Name: datatype_datatype_type_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY datatype
    ADD CONSTRAINT datatype_datatype_type_key UNIQUE (datatype_type);


--
-- TOC entry 2776 (class 2606 OID 56335)
-- Name: datatype_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY datatype
    ADD CONSTRAINT datatype_pkey PRIMARY KEY (datatype_id);


--
-- TOC entry 2778 (class 2606 OID 56337)
-- Name: doctype_doctype_name_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY doctype
    ADD CONSTRAINT doctype_doctype_name_key UNIQUE (doctype_name);


--
-- TOC entry 2780 (class 2606 OID 56339)
-- Name: doctype_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY doctype
    ADD CONSTRAINT doctype_pkey PRIMARY KEY (doctype_id);


--
-- TOC entry 2782 (class 2606 OID 56341)
-- Name: eco_eco_number_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY eco
    ADD CONSTRAINT eco_eco_number_key UNIQUE (eco_number);


--
-- TOC entry 2784 (class 2606 OID 56343)
-- Name: eco_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY eco
    ADD CONSTRAINT eco_pkey PRIMARY KEY (eco_id);


--
-- TOC entry 2786 (class 2606 OID 56345)
-- Name: filetype_filetype_mediatypename_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY filetype
    ADD CONSTRAINT filetype_filetype_mediatypename_key UNIQUE (filetype_mediatypename);


--
-- TOC entry 2788 (class 2606 OID 56347)
-- Name: filetype_filetype_type_filetype_mediatypename_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY filetype
    ADD CONSTRAINT filetype_filetype_type_filetype_mediatypename_key UNIQUE (filetype_type, filetype_mediatypename);


--
-- TOC entry 2790 (class 2606 OID 56349)
-- Name: filetype_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY filetype
    ADD CONSTRAINT filetype_pkey PRIMARY KEY (filetype_id);


--
-- TOC entry 2792 (class 2606 OID 56351)
-- Name: item_id_pk; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY item
    ADD CONSTRAINT item_id_pk PRIMARY KEY (item_id);


--
-- TOC entry 2794 (class 2606 OID 56353)
-- Name: item_item_number_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY item
    ADD CONSTRAINT item_item_number_key UNIQUE (item_number);


--
-- TOC entry 2796 (class 2606 OID 56355)
-- Name: itemcustparamlink_itemcustparamlink_custparam_id_itemcustparaml; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemcustparamlink
    ADD CONSTRAINT itemcustparamlink_itemcustparamlink_custparam_id_itemcustparaml UNIQUE (itemcustparamlink_custparam_id, itemcustparamlink_item_id);


--
-- TOC entry 2798 (class 2606 OID 56357)
-- Name: itemcustparamlink_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemcustparamlink
    ADD CONSTRAINT itemcustparamlink_pkey PRIMARY KEY (itemcustparamlink_id);


--
-- TOC entry 2800 (class 2606 OID 56359)
-- Name: itemfreqcode_itemfreqcode_freqcode_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemfreqcode
    ADD CONSTRAINT itemfreqcode_itemfreqcode_freqcode_key UNIQUE (itemfreqcode_freqcode);


--
-- TOC entry 2802 (class 2606 OID 56361)
-- Name: itemfreqcode_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemfreqcode
    ADD CONSTRAINT itemfreqcode_pkey PRIMARY KEY (itemfreqcode_id);


--
-- TOC entry 2804 (class 2606 OID 56363)
-- Name: itemrevision_id_pk; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemrev
    ADD CONSTRAINT itemrevision_id_pk PRIMARY KEY (itemrev_id);


--
-- TOC entry 2806 (class 2606 OID 56365)
-- Name: itemrevision_item_id_itemrevision_revision_unique; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemrev
    ADD CONSTRAINT itemrevision_item_id_itemrevision_revision_unique UNIQUE (itemrev_item_id, itemrev_rev);


--
-- TOC entry 2808 (class 2606 OID 56367)
-- Name: itemrevisionflow_itemrevisionflow_item_id_itemrevisionflow__key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemrevflow
    ADD CONSTRAINT itemrevisionflow_itemrevisionflow_item_id_itemrevisionflow__key UNIQUE (itemrevflow_item_id, itemrevflow_start_rev, itemrevflow_npi);


--
-- TOC entry 2810 (class 2606 OID 56369)
-- Name: itemrevisionflow_itemrevisionflow_item_id_itemrevisionflow_key1; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemrevflow
    ADD CONSTRAINT itemrevisionflow_itemrevisionflow_item_id_itemrevisionflow_key1 UNIQUE (itemrevflow_item_id, itemrevflow_end_rev, itemrevflow_npi);


--
-- TOC entry 2812 (class 2606 OID 56371)
-- Name: itemrevisionflow_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemrevflow
    ADD CONSTRAINT itemrevisionflow_pkey PRIMARY KEY (itemrevflow_id);


--
-- TOC entry 2814 (class 2606 OID 56373)
-- Name: line_line_name_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY line
    ADD CONSTRAINT line_line_name_key UNIQUE (line_name);


--
-- TOC entry 2816 (class 2606 OID 56375)
-- Name: line_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY line
    ADD CONSTRAINT line_pkey PRIMARY KEY (line_id);


--
-- TOC entry 2818 (class 2606 OID 56377)
-- Name: loc_loc_number_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY loc
    ADD CONSTRAINT loc_loc_number_key UNIQUE (loc_number);


--
-- TOC entry 2820 (class 2606 OID 56379)
-- Name: loc_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY loc
    ADD CONSTRAINT loc_pkey PRIMARY KEY (loc_id);


--
-- TOC entry 2822 (class 2606 OID 56381)
-- Name: lochist_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY lochist
    ADD CONSTRAINT lochist_pkey PRIMARY KEY (lochist_id);


--
-- TOC entry 2824 (class 2606 OID 56383)
-- Name: module_module_name_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY module
    ADD CONSTRAINT module_module_name_key UNIQUE (module_name);


--
-- TOC entry 2826 (class 2606 OID 56385)
-- Name: module_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY module
    ADD CONSTRAINT module_pkey PRIMARY KEY (module_id);


--
-- TOC entry 2829 (class 2606 OID 56387)
-- Name: part_item_id_part_sequencenumber_unique; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY part
    ADD CONSTRAINT part_item_id_part_sequencenumber_unique UNIQUE (part_item_id, part_sequencenumber);


--
-- TOC entry 2831 (class 2606 OID 56389)
-- Name: part_item_id_part_serialnumber_unique; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY part
    ADD CONSTRAINT part_item_id_part_serialnumber_unique UNIQUE (part_item_id, part_serialnumber);


--
-- TOC entry 2833 (class 2606 OID 56391)
-- Name: part_key_pk; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY part
    ADD CONSTRAINT part_key_pk PRIMARY KEY (part_id);


--
-- TOC entry 2836 (class 2606 OID 56393)
-- Name: partactivehist_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partactivehist
    ADD CONSTRAINT partactivehist_pkey PRIMARY KEY (partactivehist_id);


--
-- TOC entry 2838 (class 2606 OID 56395)
-- Name: partalloccode_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partalloccode
    ADD CONSTRAINT partalloccode_pkey PRIMARY KEY (partalloccode_id);


--
-- TOC entry 2840 (class 2606 OID 56397)
-- Name: partallochist_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partallochist
    ADD CONSTRAINT partallochist_pkey PRIMARY KEY (partallochist_id);


--
-- TOC entry 2842 (class 2606 OID 56399)
-- Name: partcustparamvalue_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partcustparamvalue
    ADD CONSTRAINT partcustparamvalue_pkey PRIMARY KEY (partcustparamvalue_id);


--
-- TOC entry 2844 (class 2606 OID 56401)
-- Name: partdoclink_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partdoclink
    ADD CONSTRAINT partdoclink_pkey PRIMARY KEY (partdoclink_id);


--
-- TOC entry 2846 (class 2606 OID 56403)
-- Name: partfile_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partfile
    ADD CONSTRAINT partfile_pkey PRIMARY KEY (partfile_id);


--
-- TOC entry 2848 (class 2606 OID 56405)
-- Name: partfiledata_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partfiledata
    ADD CONSTRAINT partfiledata_pkey PRIMARY KEY (partfiledata_id);


--
-- TOC entry 2850 (class 2606 OID 56407)
-- Name: partfilethumbnail_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partfilethumbnail
    ADD CONSTRAINT partfilethumbnail_pkey PRIMARY KEY (partfilethumbnail_id);


--
-- TOC entry 2852 (class 2606 OID 56409)
-- Name: partlog_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partlog
    ADD CONSTRAINT partlog_pkey PRIMARY KEY (partlog_id);


--
-- TOC entry 2854 (class 2606 OID 56411)
-- Name: partlogaction_partlogaction_name_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partlogaction
    ADD CONSTRAINT partlogaction_partlogaction_name_key UNIQUE (partlogaction_name);


--
-- TOC entry 2856 (class 2606 OID 56413)
-- Name: partlogaction_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partlogaction
    ADD CONSTRAINT partlogaction_pkey PRIMARY KEY (partlogaction_id);


--
-- TOC entry 2858 (class 2606 OID 56415)
-- Name: partlogactiontype_partlogactiontype_name_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partlogactiontype
    ADD CONSTRAINT partlogactiontype_partlogactiontype_name_key UNIQUE (partlogactiontype_name);


--
-- TOC entry 2860 (class 2606 OID 56417)
-- Name: partlogactiontype_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partlogactiontype
    ADD CONSTRAINT partlogactiontype_pkey PRIMARY KEY (partlogactiontype_id);


--
-- TOC entry 2862 (class 2606 OID 56419)
-- Name: partlogtype_partlogtype_name_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partlogtype
    ADD CONSTRAINT partlogtype_partlogtype_name_key UNIQUE (partlogtype_name);


--
-- TOC entry 2864 (class 2606 OID 56421)
-- Name: partlogtype_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partlogtype
    ADD CONSTRAINT partlogtype_pkey PRIMARY KEY (partlogtype_id);


--
-- TOC entry 2866 (class 2606 OID 56423)
-- Name: partrefurbhist_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partrefurbhist
    ADD CONSTRAINT partrefurbhist_pkey PRIMARY KEY (partrefurbhist_id);


--
-- TOC entry 2868 (class 2606 OID 56425)
-- Name: partrevisionhistory_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partrevhist
    ADD CONSTRAINT partrevisionhistory_pkey PRIMARY KEY (partrevhist_id);


--
-- TOC entry 2870 (class 2606 OID 56427)
-- Name: partscrapcode_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partscrapcode
    ADD CONSTRAINT partscrapcode_pkey PRIMARY KEY (partscrapcode_id);


--
-- TOC entry 2872 (class 2606 OID 56429)
-- Name: partscraphist_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partscraphist
    ADD CONSTRAINT partscraphist_pkey PRIMARY KEY (partscraphist_id);


--
-- TOC entry 2874 (class 2606 OID 56431)
-- Name: partstate_id_pk; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partstate
    ADD CONSTRAINT partstate_id_pk PRIMARY KEY (partstate_id);


--
-- TOC entry 2876 (class 2606 OID 56433)
-- Name: partstate_partstate_name_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partstate
    ADD CONSTRAINT partstate_partstate_name_key UNIQUE (partstate_name);


--
-- TOC entry 2878 (class 2606 OID 56435)
-- Name: partstatecode_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partstatecode
    ADD CONSTRAINT partstatecode_pkey PRIMARY KEY (partstatecode_id);


--
-- TOC entry 2880 (class 2606 OID 56437)
-- Name: partstateflow_partstateflow_start_partstate_id_partstateflo_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partstateflow
    ADD CONSTRAINT partstateflow_partstateflow_start_partstate_id_partstateflo_key UNIQUE (partstateflow_start_partstate_id, partstateflow_end_partstate_id);


--
-- TOC entry 2882 (class 2606 OID 56439)
-- Name: partstateflow_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partstateflow
    ADD CONSTRAINT partstateflow_pkey PRIMARY KEY (partstateflow_id);


--
-- TOC entry 2884 (class 2606 OID 56441)
-- Name: partstatehist_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partstatehist
    ADD CONSTRAINT partstatehist_pkey PRIMARY KEY (partstatehist_id);


--
-- TOC entry 2886 (class 2606 OID 56443)
-- Name: partwatcher_partwatcher_part_id_partwatcher_usr_id_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partwatcher
    ADD CONSTRAINT partwatcher_partwatcher_part_id_partwatcher_usr_id_key UNIQUE (partwatcher_part_id, partwatcher_usr_id);


--
-- TOC entry 2888 (class 2606 OID 56445)
-- Name: partwatcher_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partwatcher
    ADD CONSTRAINT partwatcher_pkey PRIMARY KEY (partwatcher_id);


--
-- TOC entry 2890 (class 2606 OID 56447)
-- Name: priv_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY priv
    ADD CONSTRAINT priv_pkey PRIMARY KEY (priv_id);


--
-- TOC entry 2892 (class 2606 OID 56449)
-- Name: priv_priv_name_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY priv
    ADD CONSTRAINT priv_priv_name_key UNIQUE (priv_name);


--
-- TOC entry 2894 (class 2606 OID 56451)
-- Name: privtype_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY privtype
    ADD CONSTRAINT privtype_pkey PRIMARY KEY (privtype_id);


--
-- TOC entry 2896 (class 2606 OID 56453)
-- Name: recordcustparamlink_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordcustparamlink
    ADD CONSTRAINT recordcustparamlink_pkey PRIMARY KEY (recordcustparamlink_id);


--
-- TOC entry 2898 (class 2606 OID 56455)
-- Name: recordcustparamlink_recordcustparamlink_custparam_id_recordcust; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordcustparamlink
    ADD CONSTRAINT recordcustparamlink_recordcustparamlink_custparam_id_recordcust UNIQUE (recordcustparamlink_custparam_id, recordcustparamlink_recordtype_id);


--
-- TOC entry 2900 (class 2606 OID 56457)
-- Name: recordcustparamvalue_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordcustparamvalue
    ADD CONSTRAINT recordcustparamvalue_pkey PRIMARY KEY (recordcustparamvalue_id);


--
-- TOC entry 2902 (class 2606 OID 56459)
-- Name: recorddoclink_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recorddoclink
    ADD CONSTRAINT recorddoclink_pkey PRIMARY KEY (recorddoclink_id);


--
-- TOC entry 2904 (class 2606 OID 56461)
-- Name: recordfile_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordfile
    ADD CONSTRAINT recordfile_pkey PRIMARY KEY (recordfile_id);


--
-- TOC entry 2906 (class 2606 OID 56463)
-- Name: recordfiledata_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordfiledata
    ADD CONSTRAINT recordfiledata_pkey PRIMARY KEY (recordfiledata_id);


--
-- TOC entry 2908 (class 2606 OID 56465)
-- Name: recordfilethumbnail_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordfilethumbnail
    ADD CONSTRAINT recordfilethumbnail_pkey PRIMARY KEY (recordfilethumbnail_id);


--
-- TOC entry 2910 (class 2606 OID 56467)
-- Name: recordlog_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordlog
    ADD CONSTRAINT recordlog_pkey PRIMARY KEY (recordlog_id);


--
-- TOC entry 2912 (class 2606 OID 56469)
-- Name: recordlogaction_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordlogaction
    ADD CONSTRAINT recordlogaction_pkey PRIMARY KEY (recordlogaction_id);


--
-- TOC entry 2914 (class 2606 OID 56471)
-- Name: recordlogaction_recordlogaction_name_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordlogaction
    ADD CONSTRAINT recordlogaction_recordlogaction_name_key UNIQUE (recordlogaction_name);


--
-- TOC entry 2916 (class 2606 OID 56473)
-- Name: recordlogactiontype_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordlogactiontype
    ADD CONSTRAINT recordlogactiontype_pkey PRIMARY KEY (recordlogactiontype_id);


--
-- TOC entry 2918 (class 2606 OID 56475)
-- Name: recordlogactiontype_recordlogactiontype_name_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordlogactiontype
    ADD CONSTRAINT recordlogactiontype_recordlogactiontype_name_key UNIQUE (recordlogactiontype_name);


--
-- TOC entry 2920 (class 2606 OID 56477)
-- Name: recordtype_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordtype
    ADD CONSTRAINT recordtype_pkey PRIMARY KEY (recordtype_id);


--
-- TOC entry 2922 (class 2606 OID 56479)
-- Name: recordtype_recordtype_name_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordtype
    ADD CONSTRAINT recordtype_recordtype_name_key UNIQUE (recordtype_name);


--
-- TOC entry 2924 (class 2606 OID 56481)
-- Name: recordtype_recordtype_prefix_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordtype
    ADD CONSTRAINT recordtype_recordtype_prefix_key UNIQUE (recordtype_prefix);


--
-- TOC entry 2926 (class 2606 OID 56483)
-- Name: recordwatcher_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordwatcher
    ADD CONSTRAINT recordwatcher_pkey PRIMARY KEY (recordwatcher_id);


--
-- TOC entry 2928 (class 2606 OID 56485)
-- Name: recordwatcher_recordwatcher_recordtype_id_recordwatcher_rec_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordwatcher
    ADD CONSTRAINT recordwatcher_recordwatcher_recordtype_id_recordwatcher_rec_key UNIQUE (recordwatcher_recordtype_id, recordwatcher_record_id, recordwatcher_usr_id);


--
-- TOC entry 2930 (class 2606 OID 56487)
-- Name: role_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY role
    ADD CONSTRAINT role_pkey PRIMARY KEY (role_id);


--
-- TOC entry 2932 (class 2606 OID 56489)
-- Name: role_role_name_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY role
    ADD CONSTRAINT role_role_name_key UNIQUE (role_name);


--
-- TOC entry 2934 (class 2606 OID 56491)
-- Name: rolepriv_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY rolepriv
    ADD CONSTRAINT rolepriv_pkey PRIMARY KEY (rolepriv_id);


--
-- TOC entry 2936 (class 2606 OID 56493)
-- Name: rolepriv_rolepriv_role_id_rolepriv_priv_id_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY rolepriv
    ADD CONSTRAINT rolepriv_rolepriv_role_id_rolepriv_priv_id_key UNIQUE (rolepriv_role_id, rolepriv_priv_id);


--
-- TOC entry 2938 (class 2606 OID 56495)
-- Name: serialpattern_id_pk; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY serialpattern
    ADD CONSTRAINT serialpattern_id_pk PRIMARY KEY (serialpattern_id);


--
-- TOC entry 2940 (class 2606 OID 56497)
-- Name: serialpattern_serialpattern_pattern_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY serialpattern
    ADD CONSTRAINT serialpattern_serialpattern_pattern_key UNIQUE (serialpattern_pattern);


--
-- TOC entry 2942 (class 2606 OID 56499)
-- Name: serialprefix_id_pk; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY serialprefix
    ADD CONSTRAINT serialprefix_id_pk PRIMARY KEY (serialprefix_id);


--
-- TOC entry 2944 (class 2606 OID 56501)
-- Name: serialprefix_prefix_serialprefix_serialpattern_id_unique; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY serialprefix
    ADD CONSTRAINT serialprefix_prefix_serialprefix_serialpattern_id_unique UNIQUE (serialprefix_prefix, serialprefix_serialpattern_id);


--
-- TOC entry 2946 (class 2606 OID 56503)
-- Name: serialstream_id_pk; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY serialstream
    ADD CONSTRAINT serialstream_id_pk PRIMARY KEY (serialstream_id);


--
-- TOC entry 2948 (class 2606 OID 56505)
-- Name: serialstream_serialstream_name_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY serialstream
    ADD CONSTRAINT serialstream_serialstream_name_key UNIQUE (serialstream_name);


--
-- TOC entry 2950 (class 2606 OID 56507)
-- Name: station_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY station
    ADD CONSTRAINT station_pkey PRIMARY KEY (station_id);


--
-- TOC entry 2952 (class 2606 OID 56509)
-- Name: station_station_name_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY station
    ADD CONSTRAINT station_station_name_key UNIQUE (station_name);


--
-- TOC entry 2954 (class 2606 OID 56511)
-- Name: stationtype_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY stationtype
    ADD CONSTRAINT stationtype_pkey PRIMARY KEY (stationtype_id);


--
-- TOC entry 2956 (class 2606 OID 56513)
-- Name: stationtype_stationtype_name_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY stationtype
    ADD CONSTRAINT stationtype_stationtype_name_key UNIQUE (stationtype_name);


--
-- TOC entry 2958 (class 2606 OID 56515)
-- Name: user_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY usr
    ADD CONSTRAINT user_pkey PRIMARY KEY (usr_id);


--
-- TOC entry 2960 (class 2606 OID 56517)
-- Name: user_user_username_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY usr
    ADD CONSTRAINT user_user_username_key UNIQUE (usr_username);


--
-- TOC entry 2962 (class 2606 OID 56519)
-- Name: userpriv_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY usrpriv
    ADD CONSTRAINT userpriv_pkey PRIMARY KEY (usrpriv_id);


--
-- TOC entry 2964 (class 2606 OID 56521)
-- Name: userpriv_userpriv_user_id_userpriv_priv_id_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY usrpriv
    ADD CONSTRAINT userpriv_userpriv_user_id_userpriv_priv_id_key UNIQUE (usrpriv_usr_id, usrpriv_priv_id);


--
-- TOC entry 2966 (class 2606 OID 56523)
-- Name: userrole_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY usrrole
    ADD CONSTRAINT userrole_pkey PRIMARY KEY (usrrole_id);


--
-- TOC entry 2968 (class 2606 OID 56525)
-- Name: userrole_userrole_user_id_userrole_role_id_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY usrrole
    ADD CONSTRAINT userrole_userrole_user_id_userrole_role_id_key UNIQUE (usrrole_usr_id, usrrole_role_id);


--
-- TOC entry 2827 (class 1259 OID 56526)
-- Name: part_item_id_part_sequencenumber_index; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX part_item_id_part_sequencenumber_index ON part USING btree (part_item_id, part_sequencenumber);


--
-- TOC entry 2834 (class 1259 OID 56527)
-- Name: part_part_item_id_part_serialnumber_idx; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX part_part_item_id_part_serialnumber_idx ON part USING btree (part_item_id, part_serialnumber);


--
-- TOC entry 2969 (class 2606 OID 56528)
-- Name: backflush_backflush_complete_usr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY backflush
    ADD CONSTRAINT backflush_backflush_complete_usr_id_fkey FOREIGN KEY (backflush_complete_usr_id) REFERENCES usr(usr_id);


--
-- TOC entry 2970 (class 2606 OID 56533)
-- Name: backflush_backflush_create_usr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY backflush
    ADD CONSTRAINT backflush_backflush_create_usr_id_fkey FOREIGN KEY (backflush_create_usr_id) REFERENCES usr(usr_id);


--
-- TOC entry 2971 (class 2606 OID 56538)
-- Name: backflush_backflush_doctype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY backflush
    ADD CONSTRAINT backflush_backflush_doctype_id_fkey FOREIGN KEY (backflush_doctype_id) REFERENCES doctype(doctype_id);


--
-- TOC entry 2972 (class 2606 OID 56543)
-- Name: backflush_backflush_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY backflush
    ADD CONSTRAINT backflush_backflush_item_id_fkey FOREIGN KEY (backflush_orig_item_id) REFERENCES item(item_id);


--
-- TOC entry 2973 (class 2606 OID 56548)
-- Name: backflush_backflush_item_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY backflush
    ADD CONSTRAINT backflush_backflush_item_id_fkey1 FOREIGN KEY (backflush_orig_item_id, backflush_orig_rev) REFERENCES itemrev(itemrev_item_id, itemrev_rev);


--
-- TOC entry 2974 (class 2606 OID 56553)
-- Name: backflush_backflush_line_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY backflush
    ADD CONSTRAINT backflush_backflush_line_id_fkey FOREIGN KEY (backflush_line_id) REFERENCES line(line_id);


--
-- TOC entry 2975 (class 2606 OID 56558)
-- Name: backflush_backflush_part_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY backflush
    ADD CONSTRAINT backflush_backflush_part_id_fkey FOREIGN KEY (backflush_part_id) REFERENCES part(part_id);


--
-- TOC entry 2976 (class 2606 OID 56563)
-- Name: backflush_backflush_station_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY backflush
    ADD CONSTRAINT backflush_backflush_station_id_fkey FOREIGN KEY (backflush_station_id) REFERENCES station(station_id);


--
-- TOC entry 2977 (class 2606 OID 56568)
-- Name: backflush_backflush_void_usr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY backflush
    ADD CONSTRAINT backflush_backflush_void_usr_id_fkey FOREIGN KEY (backflush_void_usr_id) REFERENCES usr(usr_id);


--
-- TOC entry 2978 (class 2606 OID 56573)
-- Name: bom_item_id_bom_itemrevision_itemrevision_item_id_itemrevision_; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY bom
    ADD CONSTRAINT bom_item_id_bom_itemrevision_itemrevision_item_id_itemrevision_ FOREIGN KEY (bom_item_id, bom_itemrev) REFERENCES itemrev(itemrev_item_id, itemrev_rev);


--
-- TOC entry 2979 (class 2606 OID 56578)
-- Name: bom_item_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY bom
    ADD CONSTRAINT bom_item_id_fk FOREIGN KEY (bom_item_id) REFERENCES item(item_id);


--
-- TOC entry 2980 (class 2606 OID 56583)
-- Name: bom_parent_item_id_bom_parent_itemrevision_itemrevision_item_id; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY bom
    ADD CONSTRAINT bom_parent_item_id_bom_parent_itemrevision_itemrevision_item_id FOREIGN KEY (bom_parent_item_id, bom_parent_itemrev) REFERENCES itemrev(itemrev_item_id, itemrev_rev);


--
-- TOC entry 2981 (class 2606 OID 56588)
-- Name: bom_parent_item_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY bom
    ADD CONSTRAINT bom_parent_item_id_fk FOREIGN KEY (bom_parent_item_id) REFERENCES item(item_id);


--
-- TOC entry 2982 (class 2606 OID 56593)
-- Name: custhist_custhist_end_cust_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY custhist
    ADD CONSTRAINT custhist_custhist_end_cust_id_fkey FOREIGN KEY (custhist_end_cust_id) REFERENCES cust(cust_id);


--
-- TOC entry 2983 (class 2606 OID 56598)
-- Name: custhist_custhist_orig_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY custhist
    ADD CONSTRAINT custhist_custhist_orig_item_id_fkey FOREIGN KEY (custhist_orig_item_id) REFERENCES item(item_id);


--
-- TOC entry 2984 (class 2606 OID 56603)
-- Name: custhist_custhist_orig_item_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY custhist
    ADD CONSTRAINT custhist_custhist_orig_item_id_fkey1 FOREIGN KEY (custhist_orig_item_id, custhist_orig_rev) REFERENCES itemrev(itemrev_item_id, itemrev_rev);


--
-- TOC entry 2985 (class 2606 OID 56608)
-- Name: custhist_custhist_part_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY custhist
    ADD CONSTRAINT custhist_custhist_part_id_fkey FOREIGN KEY (custhist_part_id) REFERENCES part(part_id);


--
-- TOC entry 2986 (class 2606 OID 56613)
-- Name: custhist_custhist_start_cust_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY custhist
    ADD CONSTRAINT custhist_custhist_start_cust_id_fkey FOREIGN KEY (custhist_start_cust_id) REFERENCES cust(cust_id);


--
-- TOC entry 2987 (class 2606 OID 56618)
-- Name: custhist_custhist_usr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY custhist
    ADD CONSTRAINT custhist_custhist_usr_id_fkey FOREIGN KEY (custhist_usr_id) REFERENCES usr(usr_id);


--
-- TOC entry 2988 (class 2606 OID 56623)
-- Name: custparam_custparam_datatype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY custparam
    ADD CONSTRAINT custparam_custparam_datatype_id_fkey FOREIGN KEY (custparam_datatype_id) REFERENCES datatype(datatype_id);


--
-- TOC entry 2989 (class 2606 OID 56628)
-- Name: custparamcombo_custparamcombo_custparam_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY custparamcombo
    ADD CONSTRAINT custparamcombo_custparamcombo_custparam_id_fkey FOREIGN KEY (custparamcombo_custparam_id) REFERENCES custparam(custparam_id);


--
-- TOC entry 2990 (class 2606 OID 56633)
-- Name: custparamlink_custparamlink_custparam_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY custparamlink
    ADD CONSTRAINT custparamlink_custparamlink_custparam_id_fkey FOREIGN KEY (custparamlink_custparam_id) REFERENCES custparam(custparam_id);


--
-- TOC entry 2991 (class 2606 OID 56638)
-- Name: custparamlink_custparamlink_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY custparamlink
    ADD CONSTRAINT custparamlink_custparamlink_item_id_fkey FOREIGN KEY (custparamlink_item_id) REFERENCES item(item_id);


--
-- TOC entry 2992 (class 2606 OID 56643)
-- Name: custparamlink_custparamlink_recordtype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY custparamlink
    ADD CONSTRAINT custparamlink_custparamlink_recordtype_id_fkey FOREIGN KEY (custparamlink_recordtype_id) REFERENCES recordtype(recordtype_id);


--
-- TOC entry 2993 (class 2606 OID 57168)
-- Name: item_item_itemfreqcode_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY item
    ADD CONSTRAINT item_item_itemfreqcode_id_fkey FOREIGN KEY (item_itemfreqcode_id) REFERENCES itemfreqcode(itemfreqcode_id);


--
-- TOC entry 2994 (class 2606 OID 57163)
-- Name: item_item_serialprefix_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY item
    ADD CONSTRAINT item_item_serialprefix_id_fkey FOREIGN KEY (item_serialprefix_id) REFERENCES serialprefix(serialprefix_id);


--
-- TOC entry 2995 (class 2606 OID 57158)
-- Name: item_item_serialstream_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY item
    ADD CONSTRAINT item_item_serialstream_id_fkey FOREIGN KEY (item_serialstream_id) REFERENCES serialstream(serialstream_id);


--
-- TOC entry 2996 (class 2606 OID 56648)
-- Name: itemcustparamlink_itemcustparamlink_custparam_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemcustparamlink
    ADD CONSTRAINT itemcustparamlink_itemcustparamlink_custparam_id_fkey FOREIGN KEY (itemcustparamlink_custparam_id) REFERENCES custparam(custparam_id);


--
-- TOC entry 2997 (class 2606 OID 56653)
-- Name: itemcustparamlink_itemcustparamlink_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemcustparamlink
    ADD CONSTRAINT itemcustparamlink_itemcustparamlink_item_id_fkey FOREIGN KEY (itemcustparamlink_item_id) REFERENCES item(item_id);


--
-- TOC entry 2998 (class 2606 OID 56658)
-- Name: itemrevision_item_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemrev
    ADD CONSTRAINT itemrevision_item_id_fk FOREIGN KEY (itemrev_item_id) REFERENCES item(item_id);


--
-- TOC entry 2999 (class 2606 OID 56663)
-- Name: itemrevisionflow_itemrevisionflow_eco_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemrevflow
    ADD CONSTRAINT itemrevisionflow_itemrevisionflow_eco_id_fkey FOREIGN KEY (itemrevflow_eco_id) REFERENCES eco(eco_id);


--
-- TOC entry 3000 (class 2606 OID 56668)
-- Name: itemrevisionflow_itemrevisionflow_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemrevflow
    ADD CONSTRAINT itemrevisionflow_itemrevisionflow_item_id_fkey FOREIGN KEY (itemrevflow_item_id) REFERENCES item(item_id);


--
-- TOC entry 3001 (class 2606 OID 56673)
-- Name: itemrevisionflow_itemrevisionflow_item_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemrevflow
    ADD CONSTRAINT itemrevisionflow_itemrevisionflow_item_id_fkey1 FOREIGN KEY (itemrevflow_item_id, itemrevflow_start_rev) REFERENCES itemrev(itemrev_item_id, itemrev_rev);


--
-- TOC entry 3002 (class 2606 OID 56678)
-- Name: itemrevisionflow_itemrevisionflow_item_id_fkey2; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemrevflow
    ADD CONSTRAINT itemrevisionflow_itemrevisionflow_item_id_fkey2 FOREIGN KEY (itemrevflow_item_id, itemrevflow_end_rev) REFERENCES itemrev(itemrev_item_id, itemrev_rev);


--
-- TOC entry 3003 (class 2606 OID 56683)
-- Name: lochist_lochist_end_loc_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY lochist
    ADD CONSTRAINT lochist_lochist_end_loc_id_fkey FOREIGN KEY (lochist_end_loc_id) REFERENCES loc(loc_id);


--
-- TOC entry 3004 (class 2606 OID 56688)
-- Name: lochist_lochist_orig_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY lochist
    ADD CONSTRAINT lochist_lochist_orig_item_id_fkey FOREIGN KEY (lochist_orig_item_id) REFERENCES item(item_id);


--
-- TOC entry 3005 (class 2606 OID 56693)
-- Name: lochist_lochist_orig_item_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY lochist
    ADD CONSTRAINT lochist_lochist_orig_item_id_fkey1 FOREIGN KEY (lochist_orig_item_id, lochist_orig_rev) REFERENCES itemrev(itemrev_item_id, itemrev_rev);


--
-- TOC entry 3006 (class 2606 OID 56698)
-- Name: lochist_lochist_part_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY lochist
    ADD CONSTRAINT lochist_lochist_part_id_fkey FOREIGN KEY (lochist_part_id) REFERENCES part(part_id);


--
-- TOC entry 3007 (class 2606 OID 56703)
-- Name: lochist_lochist_start_loc_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY lochist
    ADD CONSTRAINT lochist_lochist_start_loc_id_fkey FOREIGN KEY (lochist_start_loc_id) REFERENCES loc(loc_id);


--
-- TOC entry 3008 (class 2606 OID 56708)
-- Name: lochist_lochist_usr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY lochist
    ADD CONSTRAINT lochist_lochist_usr_id_fkey FOREIGN KEY (lochist_usr_id) REFERENCES usr(usr_id);


--
-- TOC entry 3009 (class 2606 OID 56713)
-- Name: part_item_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY part
    ADD CONSTRAINT part_item_id_fk FOREIGN KEY (part_item_id) REFERENCES item(item_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3010 (class 2606 OID 56718)
-- Name: part_part_cust_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY part
    ADD CONSTRAINT part_part_cust_id_fkey FOREIGN KEY (part_cust_id) REFERENCES cust(cust_id);


--
-- TOC entry 3011 (class 2606 OID 56723)
-- Name: part_part_loc_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY part
    ADD CONSTRAINT part_part_loc_id_fkey FOREIGN KEY (part_loc_id) REFERENCES loc(loc_id);


--
-- TOC entry 3012 (class 2606 OID 56728)
-- Name: part_partstate_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY part
    ADD CONSTRAINT part_partstate_id_fk FOREIGN KEY (part_partstate_id) REFERENCES partstate(partstate_id);


--
-- TOC entry 3013 (class 2606 OID 56733)
-- Name: part_revision_part_item_id_itemrevision_revision_itemrevision_i; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY part
    ADD CONSTRAINT part_revision_part_item_id_itemrevision_revision_itemrevision_i FOREIGN KEY (part_item_id, part_rev) REFERENCES itemrev(itemrev_item_id, itemrev_rev);


--
-- TOC entry 3014 (class 2606 OID 56738)
-- Name: partactivehist_partactivehist_orig_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partactivehist
    ADD CONSTRAINT partactivehist_partactivehist_orig_item_id_fkey FOREIGN KEY (partactivehist_orig_item_id) REFERENCES item(item_id);


--
-- TOC entry 3015 (class 2606 OID 56743)
-- Name: partactivehist_partactivehist_orig_item_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partactivehist
    ADD CONSTRAINT partactivehist_partactivehist_orig_item_id_fkey1 FOREIGN KEY (partactivehist_orig_item_id, partactivehist_orig_rev) REFERENCES itemrev(itemrev_item_id, itemrev_rev);


--
-- TOC entry 3016 (class 2606 OID 56748)
-- Name: partactivehist_partactivehist_part_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partactivehist
    ADD CONSTRAINT partactivehist_partactivehist_part_id_fkey FOREIGN KEY (partactivehist_part_id) REFERENCES part(part_id);


--
-- TOC entry 3017 (class 2606 OID 56753)
-- Name: partactivehist_partactivehist_usr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partactivehist
    ADD CONSTRAINT partactivehist_partactivehist_usr_id_fkey FOREIGN KEY (partactivehist_usr_id) REFERENCES usr(usr_id);


--
-- TOC entry 3018 (class 2606 OID 56758)
-- Name: partallochist_partallochist_child_orig_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partallochist
    ADD CONSTRAINT partallochist_partallochist_child_orig_item_id_fkey FOREIGN KEY (partallochist_child_orig_item_id) REFERENCES item(item_id);


--
-- TOC entry 3019 (class 2606 OID 56763)
-- Name: partallochist_partallochist_child_orig_item_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partallochist
    ADD CONSTRAINT partallochist_partallochist_child_orig_item_id_fkey1 FOREIGN KEY (partallochist_child_orig_item_id, partallochist_child_orig_rev) REFERENCES itemrev(itemrev_item_id, itemrev_rev);


--
-- TOC entry 3020 (class 2606 OID 56768)
-- Name: partallochist_partallochist_child_part_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partallochist
    ADD CONSTRAINT partallochist_partallochist_child_part_id_fkey FOREIGN KEY (partallochist_child_part_id) REFERENCES part(part_id);


--
-- TOC entry 3021 (class 2606 OID 56773)
-- Name: partallochist_partallochist_line_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partallochist
    ADD CONSTRAINT partallochist_partallochist_line_id_fkey FOREIGN KEY (partallochist_line_id) REFERENCES line(line_id);


--
-- TOC entry 3022 (class 2606 OID 56778)
-- Name: partallochist_partallochist_parent_orig_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partallochist
    ADD CONSTRAINT partallochist_partallochist_parent_orig_item_id_fkey FOREIGN KEY (partallochist_parent_orig_item_id) REFERENCES item(item_id);


--
-- TOC entry 3023 (class 2606 OID 56783)
-- Name: partallochist_partallochist_parent_orig_item_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partallochist
    ADD CONSTRAINT partallochist_partallochist_parent_orig_item_id_fkey1 FOREIGN KEY (partallochist_parent_orig_item_id, partallochist_parent_orig_rev) REFERENCES itemrev(itemrev_item_id, itemrev_rev);


--
-- TOC entry 3024 (class 2606 OID 56788)
-- Name: partallochist_partallochist_parent_part_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partallochist
    ADD CONSTRAINT partallochist_partallochist_parent_part_id_fkey FOREIGN KEY (partallochist_parent_part_id) REFERENCES part(part_id);


--
-- TOC entry 3025 (class 2606 OID 56793)
-- Name: partallochist_partallochist_station_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partallochist
    ADD CONSTRAINT partallochist_partallochist_station_id_fkey FOREIGN KEY (partallochist_station_id) REFERENCES station(station_id);


--
-- TOC entry 3026 (class 2606 OID 56798)
-- Name: partallochist_partallochist_usr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partallochist
    ADD CONSTRAINT partallochist_partallochist_usr_id_fkey FOREIGN KEY (partallochist_usr_id) REFERENCES usr(usr_id);


--
-- TOC entry 3027 (class 2606 OID 56803)
-- Name: partcustparamvalue_partcustparamvalue_custparam_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partcustparamvalue
    ADD CONSTRAINT partcustparamvalue_partcustparamvalue_custparam_id_fkey FOREIGN KEY (partcustparamvalue_custparam_id) REFERENCES custparam(custparam_id);


--
-- TOC entry 3028 (class 2606 OID 56808)
-- Name: partcustparamvalue_partcustparamvalue_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partcustparamvalue
    ADD CONSTRAINT partcustparamvalue_partcustparamvalue_item_id_fkey FOREIGN KEY (partcustparamvalue_part_id) REFERENCES part(part_id);


--
-- TOC entry 3029 (class 2606 OID 56813)
-- Name: partdoclink_partdoclink_doctype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partdoclink
    ADD CONSTRAINT partdoclink_partdoclink_doctype_id_fkey FOREIGN KEY (partdoclink_doctype_id) REFERENCES doctype(doctype_id);


--
-- TOC entry 3030 (class 2606 OID 56818)
-- Name: partdoclink_partdoclink_part_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partdoclink
    ADD CONSTRAINT partdoclink_partdoclink_part_id_fkey FOREIGN KEY (partdoclink_part_id) REFERENCES part(part_id);


--
-- TOC entry 3031 (class 2606 OID 56823)
-- Name: partfile_partfile_custfiletype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partfile
    ADD CONSTRAINT partfile_partfile_custfiletype_id_fkey FOREIGN KEY (partfile_custfiletype_id) REFERENCES custfiletype(custfiletype_id);


--
-- TOC entry 3032 (class 2606 OID 56828)
-- Name: partfile_partfile_filetype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partfile
    ADD CONSTRAINT partfile_partfile_filetype_id_fkey FOREIGN KEY (partfile_filetype_id) REFERENCES filetype(filetype_id);


--
-- TOC entry 3033 (class 2606 OID 56833)
-- Name: partfile_partfile_part_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partfile
    ADD CONSTRAINT partfile_partfile_part_id_fkey FOREIGN KEY (partfile_part_id) REFERENCES part(part_id);


--
-- TOC entry 3034 (class 2606 OID 56838)
-- Name: partfile_partfile_partfiledata_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partfile
    ADD CONSTRAINT partfile_partfile_partfiledata_id_fkey FOREIGN KEY (partfile_partfiledata_id) REFERENCES partfiledata(partfiledata_id);


--
-- TOC entry 3035 (class 2606 OID 56843)
-- Name: partfile_partfile_partfilethumbnail_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partfile
    ADD CONSTRAINT partfile_partfile_partfilethumbnail_id_fkey FOREIGN KEY (partfile_partfilethumbnail_id) REFERENCES partfilethumbnail(partfilethumbnail_id);


--
-- TOC entry 3036 (class 2606 OID 56848)
-- Name: partlog_partlog_doctype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partlog
    ADD CONSTRAINT partlog_partlog_doctype_id_fkey FOREIGN KEY (partlog_doctype_id) REFERENCES doctype(doctype_id);


--
-- TOC entry 3037 (class 2606 OID 56853)
-- Name: partlog_partlog_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partlog
    ADD CONSTRAINT partlog_partlog_item_id_fkey FOREIGN KEY (partlog_orig_item_id) REFERENCES item(item_id);


--
-- TOC entry 3038 (class 2606 OID 56858)
-- Name: partlog_partlog_item_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partlog
    ADD CONSTRAINT partlog_partlog_item_id_fkey1 FOREIGN KEY (partlog_orig_item_id, partlog_orig_rev) REFERENCES itemrev(itemrev_item_id, itemrev_rev);


--
-- TOC entry 3039 (class 2606 OID 56863)
-- Name: partlog_partlog_line_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partlog
    ADD CONSTRAINT partlog_partlog_line_id_fkey FOREIGN KEY (partlog_line_id) REFERENCES line(line_id);


--
-- TOC entry 3040 (class 2606 OID 56868)
-- Name: partlog_partlog_part_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partlog
    ADD CONSTRAINT partlog_partlog_part_id_fkey FOREIGN KEY (partlog_part_id) REFERENCES part(part_id);


--
-- TOC entry 3041 (class 2606 OID 56873)
-- Name: partlog_partlog_partlogaction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partlog
    ADD CONSTRAINT partlog_partlog_partlogaction_id_fkey FOREIGN KEY (partlog_partlogaction_id) REFERENCES partlogaction(partlogaction_id);


--
-- TOC entry 3042 (class 2606 OID 56878)
-- Name: partlog_partlog_recordtype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partlog
    ADD CONSTRAINT partlog_partlog_recordtype_id_fkey FOREIGN KEY (partlog_recordtype_id) REFERENCES recordtype(recordtype_id);


--
-- TOC entry 3043 (class 2606 OID 56883)
-- Name: partlog_partlog_station_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partlog
    ADD CONSTRAINT partlog_partlog_station_id_fkey FOREIGN KEY (partlog_station_id) REFERENCES station(station_id);


--
-- TOC entry 3044 (class 2606 OID 56888)
-- Name: partlog_partlog_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partlog
    ADD CONSTRAINT partlog_partlog_user_id_fkey FOREIGN KEY (partlog_usr_id) REFERENCES usr(usr_id);


--
-- TOC entry 3045 (class 2606 OID 56893)
-- Name: partlogaction_partlogaction_partlogactiontype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partlogaction
    ADD CONSTRAINT partlogaction_partlogaction_partlogactiontype_id_fkey FOREIGN KEY (partlogaction_partlogactiontype_id) REFERENCES partlogactiontype(partlogactiontype_id);


--
-- TOC entry 3046 (class 2606 OID 56898)
-- Name: partrefurbhist_partrefurbhist_orig_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partrefurbhist
    ADD CONSTRAINT partrefurbhist_partrefurbhist_orig_item_id_fkey FOREIGN KEY (partrefurbhist_orig_item_id) REFERENCES item(item_id);


--
-- TOC entry 3047 (class 2606 OID 56903)
-- Name: partrefurbhist_partrefurbhist_part_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partrefurbhist
    ADD CONSTRAINT partrefurbhist_partrefurbhist_part_id_fkey FOREIGN KEY (partrefurbhist_part_id) REFERENCES part(part_id);


--
-- TOC entry 3048 (class 2606 OID 56908)
-- Name: partrefurbhist_partrefurbhist_usr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partrefurbhist
    ADD CONSTRAINT partrefurbhist_partrefurbhist_usr_id_fkey FOREIGN KEY (partrefurbhist_usr_id) REFERENCES usr(usr_id);


--
-- TOC entry 3049 (class 2606 OID 56913)
-- Name: partrevhist_partrevhist_doctype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partrevhist
    ADD CONSTRAINT partrevhist_partrevhist_doctype_id_fkey FOREIGN KEY (partrevhist_doctype_id) REFERENCES doctype(doctype_id);


--
-- TOC entry 3050 (class 2606 OID 56918)
-- Name: partrevhist_partrevhist_line_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partrevhist
    ADD CONSTRAINT partrevhist_partrevhist_line_id_fkey FOREIGN KEY (partrevhist_line_id) REFERENCES line(line_id);


--
-- TOC entry 3051 (class 2606 OID 56923)
-- Name: partrevhist_partrevhist_orig_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partrevhist
    ADD CONSTRAINT partrevhist_partrevhist_orig_item_id_fkey FOREIGN KEY (partrevhist_orig_item_id) REFERENCES item(item_id);


--
-- TOC entry 3052 (class 2606 OID 56928)
-- Name: partrevhist_partrevhist_orig_item_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partrevhist
    ADD CONSTRAINT partrevhist_partrevhist_orig_item_id_fkey1 FOREIGN KEY (partrevhist_orig_item_id, partrevhist_orig_rev) REFERENCES itemrev(itemrev_item_id, itemrev_rev);


--
-- TOC entry 3053 (class 2606 OID 56933)
-- Name: partrevhist_partrevhist_station_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partrevhist
    ADD CONSTRAINT partrevhist_partrevhist_station_id_fkey FOREIGN KEY (partrevhist_station_id) REFERENCES station(station_id);


--
-- TOC entry 3054 (class 2606 OID 56938)
-- Name: partrevhist_partrevhist_usr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partrevhist
    ADD CONSTRAINT partrevhist_partrevhist_usr_id_fkey FOREIGN KEY (partrevhist_usr_id) REFERENCES usr(usr_id);


--
-- TOC entry 3055 (class 2606 OID 56943)
-- Name: partrevisionhistory_partrevisionhistory_part_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partrevhist
    ADD CONSTRAINT partrevisionhistory_partrevisionhistory_part_id_fkey FOREIGN KEY (partrevhist_part_id) REFERENCES part(part_id);


--
-- TOC entry 3056 (class 2606 OID 56948)
-- Name: partscraphist_partscraphist_orig_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partscraphist
    ADD CONSTRAINT partscraphist_partscraphist_orig_item_id_fkey FOREIGN KEY (partscraphist_orig_item_id) REFERENCES item(item_id);


--
-- TOC entry 3057 (class 2606 OID 56953)
-- Name: partscraphist_partscraphist_orig_item_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partscraphist
    ADD CONSTRAINT partscraphist_partscraphist_orig_item_id_fkey1 FOREIGN KEY (partscraphist_orig_item_id, partscraphist_orig_rev) REFERENCES itemrev(itemrev_item_id, itemrev_rev);


--
-- TOC entry 3058 (class 2606 OID 56958)
-- Name: partscraphist_partscraphist_part_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partscraphist
    ADD CONSTRAINT partscraphist_partscraphist_part_id_fkey FOREIGN KEY (partscraphist_part_id) REFERENCES part(part_id);


--
-- TOC entry 3059 (class 2606 OID 56963)
-- Name: partscraphist_partscraphist_usr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partscraphist
    ADD CONSTRAINT partscraphist_partscraphist_usr_id_fkey FOREIGN KEY (partscraphist_usr_id) REFERENCES usr(usr_id);


--
-- TOC entry 3060 (class 2606 OID 56968)
-- Name: partstateflow_partstateflow_end_partstate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partstateflow
    ADD CONSTRAINT partstateflow_partstateflow_end_partstate_id_fkey FOREIGN KEY (partstateflow_end_partstate_id) REFERENCES partstate(partstate_id);


--
-- TOC entry 3061 (class 2606 OID 56973)
-- Name: partstateflow_partstateflow_start_partstate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partstateflow
    ADD CONSTRAINT partstateflow_partstateflow_start_partstate_id_fkey FOREIGN KEY (partstateflow_start_partstate_id) REFERENCES partstate(partstate_id);


--
-- TOC entry 3062 (class 2606 OID 56978)
-- Name: partstatehist_partstatehist_end_partstate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partstatehist
    ADD CONSTRAINT partstatehist_partstatehist_end_partstate_id_fkey FOREIGN KEY (partstatehist_end_partstate_id) REFERENCES partstate(partstate_id);


--
-- TOC entry 3063 (class 2606 OID 56983)
-- Name: partstatehist_partstatehist_orig_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partstatehist
    ADD CONSTRAINT partstatehist_partstatehist_orig_item_id_fkey FOREIGN KEY (partstatehist_orig_item_id) REFERENCES item(item_id);


--
-- TOC entry 3064 (class 2606 OID 56988)
-- Name: partstatehist_partstatehist_orig_item_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partstatehist
    ADD CONSTRAINT partstatehist_partstatehist_orig_item_id_fkey1 FOREIGN KEY (partstatehist_orig_item_id, partstatehist_orig_rev) REFERENCES itemrev(itemrev_item_id, itemrev_rev);


--
-- TOC entry 3065 (class 2606 OID 56993)
-- Name: partstatehist_partstatehist_start_partstate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partstatehist
    ADD CONSTRAINT partstatehist_partstatehist_start_partstate_id_fkey FOREIGN KEY (partstatehist_start_partstate_id) REFERENCES partstate(partstate_id);


--
-- TOC entry 3066 (class 2606 OID 56998)
-- Name: partstatehist_partstatehist_usr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partstatehist
    ADD CONSTRAINT partstatehist_partstatehist_usr_id_fkey FOREIGN KEY (partstatehist_usr_id) REFERENCES usr(usr_id);


--
-- TOC entry 3067 (class 2606 OID 57003)
-- Name: partwatcher_partwatcher_part_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partwatcher
    ADD CONSTRAINT partwatcher_partwatcher_part_id_fkey FOREIGN KEY (partwatcher_part_id) REFERENCES part(part_id);


--
-- TOC entry 3068 (class 2606 OID 57008)
-- Name: partwatcher_partwatcher_usr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY partwatcher
    ADD CONSTRAINT partwatcher_partwatcher_usr_id_fkey FOREIGN KEY (partwatcher_usr_id) REFERENCES usr(usr_id);


--
-- TOC entry 3069 (class 2606 OID 57013)
-- Name: priv_priv_module_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY priv
    ADD CONSTRAINT priv_priv_module_id_fkey FOREIGN KEY (priv_module_id) REFERENCES module(module_id);


--
-- TOC entry 3070 (class 2606 OID 57018)
-- Name: priv_priv_privtype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY priv
    ADD CONSTRAINT priv_priv_privtype_id_fkey FOREIGN KEY (priv_privtype_id) REFERENCES privtype(privtype_id);


--
-- TOC entry 3071 (class 2606 OID 57023)
-- Name: recordcustparamlink_recordcustparamlink_custparam_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordcustparamlink
    ADD CONSTRAINT recordcustparamlink_recordcustparamlink_custparam_id_fkey FOREIGN KEY (recordcustparamlink_custparam_id) REFERENCES custparam(custparam_id);


--
-- TOC entry 3072 (class 2606 OID 57028)
-- Name: recordcustparamlink_recordcustparamlink_recordtype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordcustparamlink
    ADD CONSTRAINT recordcustparamlink_recordcustparamlink_recordtype_id_fkey FOREIGN KEY (recordcustparamlink_recordtype_id) REFERENCES recordtype(recordtype_id);


--
-- TOC entry 3073 (class 2606 OID 57033)
-- Name: recordcustparamvalue_recordcustparamvalue_custparam_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordcustparamvalue
    ADD CONSTRAINT recordcustparamvalue_recordcustparamvalue_custparam_id_fkey FOREIGN KEY (recordcustparamvalue_custparam_id) REFERENCES custparam(custparam_id);


--
-- TOC entry 3074 (class 2606 OID 57038)
-- Name: recordcustparamvalue_recordcustparamvalue_recordtype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordcustparamvalue
    ADD CONSTRAINT recordcustparamvalue_recordcustparamvalue_recordtype_id_fkey FOREIGN KEY (recordcustparamvalue_recordtype_id) REFERENCES recordtype(recordtype_id);


--
-- TOC entry 3075 (class 2606 OID 57043)
-- Name: recorddoclink_recorddoclink_doctype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recorddoclink
    ADD CONSTRAINT recorddoclink_recorddoclink_doctype_id_fkey FOREIGN KEY (recorddoclink_doctype_id) REFERENCES doctype(doctype_id);


--
-- TOC entry 3076 (class 2606 OID 57048)
-- Name: recorddoclink_recorddoclink_recordtype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recorddoclink
    ADD CONSTRAINT recorddoclink_recorddoclink_recordtype_id_fkey FOREIGN KEY (recorddoclink_recordtype_id) REFERENCES recordtype(recordtype_id);


--
-- TOC entry 3077 (class 2606 OID 57053)
-- Name: recordfile_recordfile_custfiletype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordfile
    ADD CONSTRAINT recordfile_recordfile_custfiletype_id_fkey FOREIGN KEY (recordfile_custfiletype_id) REFERENCES custfiletype(custfiletype_id);


--
-- TOC entry 3078 (class 2606 OID 57058)
-- Name: recordfile_recordfile_filetype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordfile
    ADD CONSTRAINT recordfile_recordfile_filetype_id_fkey FOREIGN KEY (recordfile_filetype_id) REFERENCES filetype(filetype_id);


--
-- TOC entry 3079 (class 2606 OID 57063)
-- Name: recordfile_recordfile_recordfiledata_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordfile
    ADD CONSTRAINT recordfile_recordfile_recordfiledata_id_fkey FOREIGN KEY (recordfile_recordfiledata_id) REFERENCES recordfiledata(recordfiledata_id);


--
-- TOC entry 3080 (class 2606 OID 57068)
-- Name: recordfile_recordfile_recordfilethumbnail_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordfile
    ADD CONSTRAINT recordfile_recordfile_recordfilethumbnail_id_fkey FOREIGN KEY (recordfile_recordfilethumbnail_id) REFERENCES recordfilethumbnail(recordfilethumbnail_id);


--
-- TOC entry 3081 (class 2606 OID 57073)
-- Name: recordfile_recordfile_recordtype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordfile
    ADD CONSTRAINT recordfile_recordfile_recordtype_id_fkey FOREIGN KEY (recordfile_recordtype_id) REFERENCES recordtype(recordtype_id);


--
-- TOC entry 3082 (class 2606 OID 57078)
-- Name: recordlog_recordlog_doctype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordlog
    ADD CONSTRAINT recordlog_recordlog_doctype_id_fkey FOREIGN KEY (recordlog_doctype_id) REFERENCES doctype(doctype_id);


--
-- TOC entry 3083 (class 2606 OID 57083)
-- Name: recordlog_recordlog_recordlogaction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordlog
    ADD CONSTRAINT recordlog_recordlog_recordlogaction_id_fkey FOREIGN KEY (recordlog_recordlogaction_id) REFERENCES recordlogaction(recordlogaction_id);


--
-- TOC entry 3084 (class 2606 OID 57088)
-- Name: recordlog_recordlog_recordtype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordlog
    ADD CONSTRAINT recordlog_recordlog_recordtype_id_fkey FOREIGN KEY (recordlog_recordtype_id) REFERENCES recordtype(recordtype_id);


--
-- TOC entry 3085 (class 2606 OID 57093)
-- Name: recordlog_recordlog_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordlog
    ADD CONSTRAINT recordlog_recordlog_user_id_fkey FOREIGN KEY (recordlog_usr_id) REFERENCES usr(usr_id);


--
-- TOC entry 3086 (class 2606 OID 57098)
-- Name: recordlogaction_recordlogaction_recordlogactiontype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordlogaction
    ADD CONSTRAINT recordlogaction_recordlogaction_recordlogactiontype_id_fkey FOREIGN KEY (recordlogaction_recordlogactiontype_id) REFERENCES recordlogactiontype(recordlogactiontype_id);


--
-- TOC entry 3087 (class 2606 OID 57103)
-- Name: recordwatcher_recordwatcher_recordtype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordwatcher
    ADD CONSTRAINT recordwatcher_recordwatcher_recordtype_id_fkey FOREIGN KEY (recordwatcher_recordtype_id) REFERENCES recordtype(recordtype_id);


--
-- TOC entry 3088 (class 2606 OID 57108)
-- Name: recordwatcher_recordwatcher_usr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recordwatcher
    ADD CONSTRAINT recordwatcher_recordwatcher_usr_id_fkey FOREIGN KEY (recordwatcher_usr_id) REFERENCES usr(usr_id);


--
-- TOC entry 3089 (class 2606 OID 57113)
-- Name: rolepriv_rolepriv_priv_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY rolepriv
    ADD CONSTRAINT rolepriv_rolepriv_priv_id_fkey FOREIGN KEY (rolepriv_priv_id) REFERENCES priv(priv_id);


--
-- TOC entry 3090 (class 2606 OID 57118)
-- Name: rolepriv_rolepriv_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY rolepriv
    ADD CONSTRAINT rolepriv_rolepriv_role_id_fkey FOREIGN KEY (rolepriv_role_id) REFERENCES role(role_id);


--
-- TOC entry 3091 (class 2606 OID 57123)
-- Name: serialprefix_serialpattern_id_serialpattern_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY serialprefix
    ADD CONSTRAINT serialprefix_serialpattern_id_serialpattern_id_fk FOREIGN KEY (serialprefix_serialpattern_id) REFERENCES serialpattern(serialpattern_id);


--
-- TOC entry 3092 (class 2606 OID 57128)
-- Name: station_station_stationtype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY station
    ADD CONSTRAINT station_station_stationtype_id_fkey FOREIGN KEY (station_stationtype_id) REFERENCES stationtype(stationtype_id);


--
-- TOC entry 3093 (class 2606 OID 57133)
-- Name: userpriv_userpriv_priv_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY usrpriv
    ADD CONSTRAINT userpriv_userpriv_priv_id_fkey FOREIGN KEY (usrpriv_priv_id) REFERENCES priv(priv_id);


--
-- TOC entry 3094 (class 2606 OID 57138)
-- Name: userpriv_userpriv_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY usrpriv
    ADD CONSTRAINT userpriv_userpriv_user_id_fkey FOREIGN KEY (usrpriv_usr_id) REFERENCES usr(usr_id);


--
-- TOC entry 3095 (class 2606 OID 57143)
-- Name: userrole_userrole_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY usrrole
    ADD CONSTRAINT userrole_userrole_role_id_fkey FOREIGN KEY (usrrole_role_id) REFERENCES role(role_id);


--
-- TOC entry 3096 (class 2606 OID 57148)
-- Name: userrole_userrole_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY usrrole
    ADD CONSTRAINT userrole_userrole_user_id_fkey FOREIGN KEY (usrrole_usr_id) REFERENCES usr(usr_id);


--
-- TOC entry 3232 (class 0 OID 0)
-- Dependencies: 7
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- TOC entry 3236 (class 0 OID 0)
-- Dependencies: 181
-- Name: backflush; Type: ACL; Schema: public; Owner: admin
--

REVOKE ALL ON TABLE backflush FROM PUBLIC;
REVOKE ALL ON TABLE backflush FROM admin;
GRANT ALL ON TABLE backflush TO admin;


-- Completed on 2017-03-28 10:07:15

--
-- PostgreSQL database dump complete
--


-- Function: addflowitem(integer, integer, boolean)

-- DROP FUNCTION addflowitem(integer, integer, boolean);

CREATE OR REPLACE FUNCTION addflowitem(
    integer,
    integer,
    boolean
    )
  RETURNS boolean AS
  $BODY$
  DECLARE

	_flow_id   		ALIAS FOR $1;		-- Test Flow Definition flow ID (default 1) (not null)
	_item_id		ALIAS FOR $2;		-- Item ID (item id & type id combo unique) (not null)
	_override		ALIAS FOR $3;		-- Item override status

	_type_id		integer;		-- Type ID (populated from flow definition flow id)
	_flowitem_id		integer;		-- For checking successful test flow item addition
	_flowItemAdded		boolean := false;	-- Flow item addition status

  begin

	/* Check if flow ID is null */
	if _flow_id is null then
		raise exception 'addflowitem: ERROR ADDING FLOW ITEM AS ITEM FLOW ID IS NULL';
	end if;

	/* Check that the item ID is not null */
	if _item_id is null then
		raise exception 'addflowitem: ERROR ADDING FLOW ITEM AS THE ITEM ID IS NULL';
	end if;

	/* Check that override is not null */
	if _override is null then
		_override := false;
	end if;

	/* Check if the flow ID exists */
	if (select exists(select 1 from testflowdef where testflowdef_id = _flow_id)) is false then
		raise exception 'addflowitem: ERROR ADDING FLOW ITEM AS FLOW ID "%" DOESNT EXIST', _flow_id;
	end if;

	/* Check if the item ID exists */
	if (select exists(select 1 from item where item_id = _item_id and item_active is true)) is false then
		raise exception 'addflowitem: ERROR ADDING FLOW ITEM AS FLOW ITEM ID "%" DOESNT EXIST', _item_id;
	end if;

	/* Get type ID */
	select testflowdef_type_id from testflowdef where testflowdef_id = _flow_id into _type_id;

	/* Check that type ID was successfully saved */
	If _type_id is null then
		raise exception 'addflowitem: ERROR ADDING FLOW ITEM AS ITEM TYPE ID IS NULL';
	END IF;

	/* Check if type ID exists */
	if (select exists(Select 1 from testtype where testtype_id = _type_id)) is false then
		raise exception 'addflowitem: ERROR ADDING FLOW ITEM AS FLOW ITEM TYPE ID "%" DOES NOT EXIST', _type_id;
	end if;

	/* Check if the item ID and test type ID does not conflict with the unique constraint */
	if (select exists(select 1 from testflowitem where testflowitem_item_id = _item_id 
	and testflowitem_type_id = _type_id)) is true then
		raise exception 'addflowitem: ERROR ADDING FLOW ITEM AS FLOW ITEM ITEM ID "%" AND FLOW ITEM TEST TYPE ID "%" COMBINATION ALREADY EXISTS', _item_id, _type_id;
	end if;

	/* Add new item number */
	insert into testflowitem (testflowitem_flow_id,
				testflowitem_item_id,
				testflowitem_type_id,
				testflowitem_override,
				testflowitem_created_timestamp)
	values			(_flow_id,
				_item_id,
				_type_id,
				_override,
				now()::timestamp without time zone)
	returning testflowitem_id into _flowitem_id;

	/* Check that test flow item was added successfully */
	if _flowitem_id is null then
		raise exception 'addflowitem: ERROR ADDING FLOW ITEM AS FLOW ITEM ID IS NULL';
	ELSE 
		_flowItemAdded := true;		-- Set test flow creation status
	end if;

	return _flowItemAdded;			-- Return test flow creation status
  end;
  $BODY$
  language plpgsql volatile
  cost 100;
alter function addflowitem(integer, integer, boolean)
  owner to postgres;
COMMENT ON function addflowitem(integer, integer, boolean)
  IS '[*New* --mrankin--] Adds a new item to the test flow item table';
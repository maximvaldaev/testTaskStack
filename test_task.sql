CREATE OR REPLACE FUNCTION stack.select_count_pok_by_service(
	_number character varying,
	_date character varying)
    RETURNS TABLE(num integer, service integer, count bigint) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
 
	BEGIN
	RETURN QUERY
	SELECT stack.Accounts.number as number, stack.Counters.service as service, count (stack.Counters.service)
	FROM stack.meter_pok
	JOIN stack.Counters ON stack.meter_pok.counter_id = stack.Counters.row_id
	JOIN stack.Accounts ON stack.meter_pok.acc_id = stack.Accounts.row_id
	WHERE stack.Counters.service = CAST (_number AS INTEGER) AND stack.Meter_Pok.month = TO_DATE(_date,'YYYYMMDD') 
	GROUP BY stack.Counters.service,stack.Accounts.number
	ORDER BY stack.Accounts.number;
END
$BODY$;


CREATE OR REPLACE FUNCTION stack.select_value_by_house_and_month(
	_number integer,
	_date character varying)
    RETURNS TABLE(number integer, name text, value bigint) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
 
	BEGIN
	RETURN QUERY
	SELECT stack.Accounts.number, stack.counters.name, SUM(stack.meter_pok.value)
	FROM stack.meter_pok
	JOIN stack.counters on stack.meter_pok.counter_id = stack.counters.row_id
	JOIN stack.Accounts on stack.meter_pok.acc_id = stack.accounts.row_id
	WHERE stack.Meter_Pok.month = TO_DATE(_date,'YYYYMMDD')
	 AND stack.accounts.row_id IN 
	 	(SELECT stack.accounts.row_id
		FROM stack.accounts
		WHERE stack.accounts.parent_id in 
		(Select stack.accounts.row_id 
		FROM stack.accounts
		WHERE stack.accounts.parent_id = _number) 
		OR
		(stack.accounts.parent_id =_number AND stack.accounts.type = 3)) 
	GROUP BY stack.Accounts.number, stack.counters.name
	ORDER BY stack.Accounts.number, stack.counters.name;
	
END
$BODY$;
	

CREATE OR REPLACE FUNCTION stack.select_last_pok_by_acc(
	_number integer)
    RETURNS TABLE(number integer, service integer, payment_date date, tarif integer, value integer) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
 
	BEGIN
	RETURN QUERY
	WITH t AS (SELECT acc_id, counter_id, max(date) AS max_date
	FROM stack.meter_pok
		   JOIN stack.accounts ON stack.meter_pok.acc_id = stack.accounts.row_id 
WHERE stack.accounts.number =_number
GROUP BY  acc_id, counter_id
ORDER BY  acc_id, counter_id)

SELECT stack.accounts.number, stack.counters.service, ct.date, ct.tarif, ct.value
FROM stack.meter_pok ct
JOIN t ON t.acc_id = ct.acc_id AND t.counter_id = ct.counter_id
JOIN stack.accounts ON ct.acc_id = stack.accounts.row_id
JOIN stack.counters ON ct.counter_id = stack.counters.row_id
WHERE ct.date = t.max_date;
	
END
$BODY$;
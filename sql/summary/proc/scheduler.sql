drop function if exists summary.create_xfer(text, numeric, uuid, uuid);
drop function if exists summary.update_xfer(uuid, summary.xfer_state_t, text);
drop function if exists summary.get_pending(int);

create or replace function summary.get_pending(n int)
returns table (
	xfer_id uuid,
	create_time timestamp,
	update_time timestamp,
       	xfer_state_time timestamp,
	amount numeric,
	source_account_id uuid,
	source_adapter_url text,
	source_adapter_config jsonb,
	source_account_config jsonb,
	destination_account_id uuid,
	destination_adapter_url text,
	destination_adapter_config jsonb,
	destination_account_config jsonb
)
as $$
begin
	return query
	select x.bridge_id, x.create_time, x.update_time,
       	       x.xfer_state_time, x.amount,
	       sa.bridge_id, sb.internal_adapter_url,
	       sb.internal_adapter_config, sa.account_config,
	       da.bridge_id, db.internal_adapter_url,
	       db.internal_adapter_config, da.account_config
	from summary.xfer_action as x
	inner join summary.account as sa on sa.id = x.source_account_id
	inner join summary.bank as sb on sb.id = sa.bank_id
	inner join summary.account as da on da.id = x.destination_account_id
	inner join summary.bank as db on db.id = da.bank_id
	where x.xfer_state = 'new' and 
	/*
		This is to keep parallelization simple.
		We only want to be performing one transaction on a given
		account at a time because we don't trust the downstream
		record locking at the bank until we have proof to the
		contrary.  There are other ways to do this, but this is
		simple for now.
	*/
	x.source_account_id not in (
			    	select x2.source_account_id
				from summary.xfer_action as x2
				where x2.xfer_state = 'pending'
				union
				select x3.destination_account_id
				from summary.xfer_action as x3
				where x3.xfer_state = 'pending'
			    ) and 
	x.destination_account_id not in (
			    	select x2.source_account_id
				from summary.xfer_action as x2
				where x2.xfer_state = 'pending'
				union
				select x3.destination_account_id
				from summary.xfer_action as x3
				where x3.xfer_state = 'pending'
			    )
	order by x.xfer_state_time asc, x.create_time asc -- time priority
	limit n;
end;
$$ language plpgsql;

create or replace
function summary.create_xfer(c text, a numeric, said uuid, daid uuid)
returns int as $$
declare
	newid int := 0;
begin
	insert into summary.xfer_action (
	       bridge_id, comment, xfer_state_note,
	       source_account_id, destination_account_id, amount
	)
	select gen_random_uuid(), c, 'created', sa.id, da.id, a
	from summary.account as sa
	inner join summary.account da on da.bridge_id = daid
	where sa.bridge_id = said returning id into newid;

	return newid;
end;	
$$ language plpgsql;

create or replace
function summary.update_xfer(xid uuid, xs summary.xfer_state_t,
	 		r text)
returns void as $$
begin
	insert into summary.xfer_action_history (
	       action_id, note, from_state, to_state
	)
	select x.id, r, x.xfer_state, xs
	from summary.xfer_action as x
	where x.bridge_id = xid;

	update summary.xfer_action
	set xfer_state = xs, xfer_state_note = r, xfer_state_time = now()
	where x.bridge_id = xid;
end;
$$ language plpgsql;

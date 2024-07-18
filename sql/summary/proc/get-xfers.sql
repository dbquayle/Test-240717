drop function if exists summary.get_xfers(uuid);
drop function if exists summary.get_xfers(text);

/**
	We restrict getting transfers initially to those who are a party to it.

	Pagination could be an issue here as tables grow.
	It's left off for now.
*/
create or replace function summary.get_xfers(euuid uuid)
returns table (
       -- id bigint /* again we omit the integer identifier */
       bridge_id uuid, 
       create_time timestamp, 
       update_time timestamp, 
       comment text, 
       xfer_state summary.xfer_state_t, 
       xfer_state_time timestamp, 
       xfer_state_note text, 
       amount numeric,
       source_bridge_id uuid,
       destination_bridge_id uuid
)
as $$
begin
	return query
	select x.bridge_id,  x.create_time, x.update_time, x.comment, 
       	       x.xfer_state, x.xfer_state_time, x.xfer_state_note, 
       	       x.amount, sa.bridge_id, da.bridge_id
	from summary.xfer_action as x
	inner join summary.account as sa on x.source_account_id = sa.id
	inner join summary.account as da on x.destination_account_id = da.id
	inner join summary.entity as se on sa.owner_entity_id = se.id
	inner join summary.entity as de on da.owner_entity_id = de.id
	where ( se.bridge_id = euuid or de.bridge_id = euuid ); -- OR is bad
end;
$$ language plpgsql;

/**
	We restrict getting transfers initially to those who are a party to it.

	Pagination could be an issue here as tables grow.
	It's left off for now.
*/
create or replace function summary.get_xfers(elog text)
returns table (
       -- id bigint /* again we omit the integer identifier */
       bridge_id uuid, 
       create_time timestamp, 
       update_time timestamp, 
       comment text, 
       xfer_state summary.xfer_state_t, 
       xfer_state_time timestamp, 
       xfer_state_note text, 
       amount numeric,
       source_bridge_id uuid,
       destination_bridge_id uuid
)
as $$
begin
	return query
	select x.bridge_id,  x.create_time, x.update_time, x.comment, 
       	       x.xfer_state, x.xfer_state_time, x.xfer_state_note, 
       	       x.amount, sa.bridge_id, da.bridge_id
	from summary.xfer_action as x
	inner join summary.account as sa on x.source_account_id = sa.id
	inner join summary.account as da on x.destination_account_id = da.id
	inner join summary.entity as se on sa.owner_entity_id = se.id
	inner join summary.entity as de on da.owner_entity_id = de.id
	where ( se.login_user = elog or de.login_user = elog ); -- OR is bad
end;
$$ language plpgsql;

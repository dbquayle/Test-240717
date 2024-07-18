drop function if exists summary.get_accounts(uuid);

create or replace function summary.get_accounts(ouuid uuid)
returns table (
	-- we are not exposing the integer id here
       bridge_id uuid,
       bank_id bigint,
       external_id text,
       create_time timestamp,
       update_time timestamp,
       owner_bridge_id uuid,
       account_config jsonb
)
as $$
begin
	return query
	select a.bridge_id, a.bank_id, a.external_id, a.create_time,
       	       a.update_time, e.bridge_id, a.account_config 
	from summary.account as a
	inner join summary.entity as e on e.id = a.owner_entity_id
	where e.bridge_id = ouuid;
end;
$$ language plpgsql;

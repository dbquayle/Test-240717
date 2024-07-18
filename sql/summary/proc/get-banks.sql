drop function if exists summary.get_banks();

create or replace function summary.get_banks()
returns table (
       id bigint,
       description text,

       postal_address text,
       postal_city text,
       postal_state text,
       postal_zip text,
       postal_country text,

       telephone_contact text,
       support_email text,
       support_website text,

       create_time timestamp,
       update_time timestamp,

       internal_adapter_config jsonb,
       internal_adapter_url text
)
as $$
begin
	return query
	select b.id, b.description, b.postal_address, b.postal_city, 
       	       b.postal_state, b.postal_zip, b.postal_country, 
	       b.telephone_contact, b.support_email, b.support_website, 
	       b.create_time, b.update_time, 
       	       b.internal_adapter_config, 
       	       b.internal_adapter_url
	from summary.bank as b;
end;
$$ language plpgsql;

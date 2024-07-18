drop table if exists summary.bank;

/**
	This table contains the information for each bank that provides
	accounts used in the money transfer.
*/
create table if not exists summary.bank (
       id bigserial not null primary key,
       description text not null, -- descriptive text / name for bank

       postal_address text not null,
       postal_city text not null,
       postal_state text not null,
       postal_zip text not null,
       postal_country text not null,

       aba_routing_number text not null,

       telephone_contact text not null,
       support_email text,
       support_website text,

       create_time timestamp not null default now(),
       update_time timestamp not null default now(),

       internal_adapter_config jsonb not null, -- config params here for bank
       internal_adapter_url text not null /*
       			  adapter URL, either service URL or file path
			  for script / executable
			  */
			  	
);

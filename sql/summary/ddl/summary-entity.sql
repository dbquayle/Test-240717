drop table if exists summary.entity;

create table if not exists summary.entity (
       id bigserial not null primary key,

       bridge_id uuid not null unique, -- same logic here as for accounts

       legal_name text not null,
       postal_address text not null, -- street
       postal_city text not null,
       postal_state text not null,
       postal_zip text not null,
       postal_country text not null,

       email_address text not null,
       telephone_number text not null,

       login_user text not null -- Bridge user associated with the entity
);

create unique index on summary.entity(bridge_id);

/**
	For the purposes of this exercise, we will assume that the ACL
	is very simple and that entities can only see transfers to which they
	are a party.  This necessitates the login_user field in the database.

	Also, we will assume no cloning of entities, hence the unique index.
*/
create unique index on summary.entity(login_user);



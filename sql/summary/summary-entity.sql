drop table if exists summary.entity;

create table if not exists summary.entity (
       id bigersial not null primary key,

       bridge_id uuid not null unique, -- same logic here as for accounts

       legal_name text not null,
       postal_address text not null, -- street
       postal_city text not null,
       postal_state text not null,
       postal_zip text not null,
       postal_country text not null,

       email_address text,
       telephone_number text not null,
);

create unique index on summary.entity(bridge_id);


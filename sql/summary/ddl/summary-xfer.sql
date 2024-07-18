drop table if exists summary.xfer_action_history;
drop table if exists summary.xfer_action;
drop type if exists summary.xfer_state_t cascade;
drop type if exists summary.xter_state_t cascade;

/**
	State could also be represented as an integer and defined
	via constants in the state machine.  This has the benefit of not
	having to keep the database type definition in sync with the
	state machine but the disadvantage of readability.
*/
create type summary.xfer_state_t as enum (
       'new', -- no action taken
       'pending', -- in progress
       'success', -- completed successfully
       'failed', -- completed unsuccessfully
       'cancelled' -- cancelled before completion
);

create table if not exists summary.xfer_action (
       id bigserial not null primary key,

       bridge_id uuid not null unique, -- same logic as for account, entity

       create_time timestamp not null default now(),
       update_time timestamp not null default now(),

       comment text not null,
       xfer_state summary.xfer_state_t not null default 'new',
       xfer_state_time timestamp not null default now(),
       xfer_state_note text not null, 

       amount numeric not null check (amount > 0),
       source_account_id bigint not null references summary.account,
       destination_account_id bigint not null references summary.account
       			      check(source_account_id !=
			      			      destination_account_id)
						      /* seems stupid to allow
						      	 looping transfers
			*/
);

create unique index on summary.xfer_action(bridge_id);
create index on summary.xfer_action(source_account_id);
create index on summary.xfer_action(destination_account_id);

create table if not exists summary.xfer_action_history (
       id bigserial not null primary key,

       action_id bigint not null references summary.xfer_action,

       create_time timestamp not null default now(),
       update_time timestamp not null default now(),

       note text not null,
       from_state summary.xfer_state_t not null,
       to_state summary.xfer_state_t not null
);

create index on summary.xfer_action_history(from_state);
create index on summary.xfer_action_history(to_state);

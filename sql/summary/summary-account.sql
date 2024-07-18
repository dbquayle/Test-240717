drop table if exists summary.account;

create table if not exists summary.account (
       id bigserial not null primary key,

       bridge_id uuid not null unique, /**
       		 This is an identifier that can be used for reference.

		 I would rather not pass around integer ids;
		 if they get exposed internally, it is easier to spoof.

		 I do not make this the primary key of the table, because
		 then the ordering is effectively random.
	 */
	 bank_id bigint not null references summary.bank
	 	 on delete cascade,

	 external_id text not null, --- external account number

	 create_time timestamp not null default now(),
	 update_time timestamp not null default now(),

	 owner_entity_id bigint not null references summary.entity
	 		 on delete cascade,
	 account_config jsonb not null -- individual credentials go here
);

create unique index on summary.account(bridge_id);
create index on summary.account(bank_id);


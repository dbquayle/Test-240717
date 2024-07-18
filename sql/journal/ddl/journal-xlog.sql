drop table if exists journal.xlog;

create table if not exists journal.xlog (
       id bigserial not null primary key,
       log_time timestamp not null default now(),
       xfer_id uuid not null references summary.xfer_action(bridge_id)
       	       on delete cascade,
       account_id uuid not null references summary.account(bridge_id)
       		  on delete cascade,
       amount numeric not null,
       message text not null,
       success boolean not null default true
);

create index on journal.xlog(xfer_id);
create index on journal.xlog(account_id);
create index on journal.xlog(log_time);


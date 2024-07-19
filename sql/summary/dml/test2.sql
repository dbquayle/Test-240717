select summary.create_xfer(
       'test transfer', 100,
       '10000000-0000-0000-0000-000000000001',
       '20000000-0000-0000-0000-000000000002'
);

/*
select 'get_account()';
select * from summary.get_accounts('00000000-0000-0000-0000-000000000001');
select * from summary.get_accounts('00000000-0000-0000-0000-000000000002');

select 'get_banks()';
select * from summary.get_banks();

select 'get_xfers()';
select * from summary.get_xfers('00000000-0000-0000-0000-000000000001'::uuid);
select * from summary.get_xfers('dbquayle');

select 'Update the transfer';

select summary.update_xfer(
       (select bridge_id from summary.xfer_action limit 1),
       'pending', 'test move to pending by D. Quayle in test.sql');

select summary.update_xfer(
       (select bridge_id from summary.xfer_action limit 1),
       'success', 'test move to succeeded by D. Quayle in test.sql');

select 'get_xfers()';
select * from summary.get_xfers('00000000-0000-0000-0000-000000000001'::uuid);
select * from summary.get_xfers('dbquayle');

select 'Table dumps follow';

select * from summary.bank;
select * from summary.account;
select * from summary.xfer_action;
select * from summary.xfer_action_history;
*/

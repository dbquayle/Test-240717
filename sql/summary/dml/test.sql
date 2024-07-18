select summary.create_xfer(
       'test transfer', 100, 
       'b2d69d67-d71a-4def-9b16-ba282aeed75b',
       'd37d6e49-5d79-45eb-91cf-fec13fe00889'
);


select * from summary.bank;

select * from summary.account;

select * from summary.xfer_action;

select * from summary.xfer_action_history;

select * from summary.get_accounts('f7283fa3-943c-4beb-91a6-307dbfbac00b');
select * from summary.get_accounts('66d14ef8-2d44-4098-92aa-a06955671342');

select * from summary.get_banks();
select * from summary.get_xfers('66d14ef8-2d44-4098-92aa-a06955671342');
select * from summary.get_xfers('dbquayle');

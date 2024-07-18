begin transaction;

insert into summary.bank (
       description, 
       postal_address, 
       postal_city,
       postal_state,
       postal_zip,
       postal_country,

       aba_routing_number,

       telephone_contact,
       support_email,
       support_website,

       internal_adapter_config,
       internal_adapter_url
)
values (
       'Bank of America',
       '1200 Post Road',
       'Darien',
       'CT',
       '06820',
       'USA',

       '111111111',

       '203-555-1212',
       'support@bofa.com',
       'www.bofa.com',

       '{}',
       'file:///usr/local/bin/bofa-transaction'
), (
       'Darien Rowayton Bank',
       '999 Post Road',
       'Darien',
       'CT',
       '06820',
       'USA',

       '222222222',

       '203-555-1213',
       'support@drbank.com',
       'www.drbank.com',

       'null',
       'file:///usr/local/bin/drbank-transaction'
);

insert into summary.entity (
       bridge_id,

       legal_name,
       postal_address,
       postal_city,
       postal_state,
       postal_zip,
       postal_country,

       email_address,
       telephone_number,

       login_user

) values (
  '00000000-0000-0000-0000-000000000001',
  'Douglas Quayle',
  '77 Massachusetts Avenue',
  'Cambridge',
  'MA',
  '02139',
  'USA',

  'dbquayle@mit.edu',
  '617-555-0139',

  'dbquayle'
), (
  '00000000-0000-0000-0000-000000000002',
  'Bank of America',
  '1200 Post Road',
  'Darien',
  'CT',
  '06820',
  'USA',

  'support@bofa.com',
  '203-555-1212',

  'bofauser'
);

insert into summary.account (
       bridge_id,
        bank_id,
	external_id,
	owner_entity_id,
	account_config
) select '20000000-0000-0000-0000-000000000002', b.id, 'BOFA-43223-2222', e.id,
  	 '{ "account": "2222" }'
from summary.entity as e
cross join summary.bank as b
where b.id = 1 and e.login_user = 'bofauser';

insert into summary.account (
       bridge_id,
        bank_id,
	external_id,
	owner_entity_id,
	account_config
)
select '10000000-0000-0000-0000-000000000001', b.id, '199292-0444-D', e.id,
       '{ "account-number": "0444" }'
from summary.entity as e
cross join summary.bank as b
where b.id = 2 and e.login_user = 'dbquayle';



commit;

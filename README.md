# Test-240717

Thoughts on design

## Summary Description

This solution is divided into three separate layers.  Layer 1 is the
interface provided either to the internal Bridge population or to
clients to move money; this was not specified in the problem set.
This would most likely be implemented as a fairly shallow web service
running on a container.  The second layer to this is the central layer
consisting of the Postgres RDBMS and the orchestration manager to
queue transfers as they need to occur.  The third layer is a set of
adapters to various banks.  We are operating under the assumption that
each bank provides a slightly different REST interface to enact the
transactions.  The adapter layer could be implemented as web services
exporting a common API or as libraries in a language such as Python or
C++ provided different implementations of a common interface.

All communications for REST should be done over HTTPS to provide a
layer against packet sniffing.  User authentication should be done via
OAuth tokens.  A service such as Okta can provide session tokens to
establish identities.

## Setup instructions

### Postgres

The SQL code is set up in the sql directory.
Each database schema contains three directories:
 * ddl -- data definition language
 * dml -- data modification language
 * proc -- stored procedures

The ddl and proc directories contain Makefiles that will apply the
code to the database.  In the UNIX environment, set the PGHOST,
PGUSER, and PGDATABASE, (and PGPASSWORD if not using a .pgpass file or
a matching username to the Unix environment ) and then at the shell
prompt run the make command.

The dml directory contains a sample.sql SQL script to populate the
tables with sample accounts.  The test.sql -- which, because of the
use of UUIDs, requires some modification on each run -- contains a
call to create a transfer.

This can be run with
psql -f test.sql

Sample output is below:
```
 create_xfer 
-------------
           1
(1 row)

   ?column?    
---------------
 get_account()
(1 row)

              bridge_id               | bank_id |  external_id  |        create_time         |        update_time         |           owner_bridge_id            |       account_config       
--------------------------------------+---------+---------------+----------------------------+----------------------------+--------------------------------------+----------------------------
 10000000-0000-0000-0000-000000000001 |       2 | 199292-0444-D | 2024-07-18 18:04:47.918504 | 2024-07-18 18:04:47.918504 | 00000000-0000-0000-0000-000000000001 | {"account-number": "0444"}
(1 row)

              bridge_id               | bank_id |   external_id   |        create_time         |        update_time         |           owner_bridge_id            |   account_config    
--------------------------------------+---------+-----------------+----------------------------+----------------------------+--------------------------------------+---------------------
 20000000-0000-0000-0000-000000000002 |       1 | BOFA-43223-2222 | 2024-07-18 18:04:47.918504 | 2024-07-18 18:04:47.918504 | 00000000-0000-0000-0000-000000000002 | {"account": "2222"}
(1 row)

  ?column?   
-------------
 get_banks()
(1 row)

 id |     description      | postal_address | postal_city | postal_state | postal_zip | postal_country | telephone_contact |   support_email    | support_website |        create_time         |        update_time         | internal_adapter_config |           internal_adapter_url           
----+----------------------+----------------+-------------+--------------+------------+----------------+-------------------+--------------------+-----------------+----------------------------+----------------------------+-------------------------+------------------------------------------
  1 | Bank of America      | 1200 Post Road | Darien      | CT           | 06820      | USA            | 203-555-1212      | support@bofa.com   | www.bofa.com    | 2024-07-18 18:04:47.918504 | 2024-07-18 18:04:47.918504 | {}                      | file:///usr/local/bin/bofa-transaction
  2 | Darien Rowayton Bank | 999 Post Road  | Darien      | CT           | 06820      | USA            | 203-555-1213      | support@drbank.com | www.drbank.com  | 2024-07-18 18:04:47.918504 | 2024-07-18 18:04:47.918504 | null                    | file:///usr/local/bin/drbank-transaction
(2 rows)

  ?column?   
-------------
 get_xfers()
(1 row)

              bridge_id               |        create_time         |        update_time         |    comment    | xfer_state |      xfer_state_time       | xfer_state_note | amount |           source_bridge_id           |        destination_bridge_id         
--------------------------------------+----------------------------+----------------------------+---------------+------------+----------------------------+-----------------+--------+--------------------------------------+--------------------------------------
 7a9c397f-4ea6-4468-975a-6fc945a6e090 | 2024-07-18 18:06:10.918565 | 2024-07-18 18:06:10.918565 | test transfer | new        | 2024-07-18 18:06:10.918565 | created         |    100 | 10000000-0000-0000-0000-000000000001 | 20000000-0000-0000-0000-000000000002
(1 row)

              bridge_id               |        create_time         |        update_time         |    comment    | xfer_state |      xfer_state_time       | xfer_state_note | amount |           source_bridge_id           |        destination_bridge_id         
--------------------------------------+----------------------------+----------------------------+---------------+------------+----------------------------+-----------------+--------+--------------------------------------+--------------------------------------
 7a9c397f-4ea6-4468-975a-6fc945a6e090 | 2024-07-18 18:06:10.918565 | 2024-07-18 18:06:10.918565 | test transfer | new        | 2024-07-18 18:06:10.918565 | created         |    100 | 10000000-0000-0000-0000-000000000001 | 20000000-0000-0000-0000-000000000002
(1 row)

      ?column?       
---------------------
 Update the transfer
(1 row)

 update_xfer 
-------------
 
(1 row)

 update_xfer 
-------------
 
(1 row)

  ?column?   
-------------
 get_xfers()
(1 row)

              bridge_id               |        create_time         |        update_time         |    comment    | xfer_state |      xfer_state_time       |                 xfer_state_note                 | amount |           source_bridge_id           |        destination_bridge_id         
--------------------------------------+----------------------------+----------------------------+---------------+------------+----------------------------+-------------------------------------------------+--------+--------------------------------------+--------------------------------------
 7a9c397f-4ea6-4468-975a-6fc945a6e090 | 2024-07-18 18:06:10.918565 | 2024-07-18 18:06:10.918565 | test transfer | success    | 2024-07-18 18:06:10.942939 | test move to succeeded by D. Quayle in test.sql |    100 | 10000000-0000-0000-0000-000000000001 | 20000000-0000-0000-0000-000000000002
(1 row)

              bridge_id               |        create_time         |        update_time         |    comment    | xfer_state |      xfer_state_time       |                 xfer_state_note                 | amount |           source_bridge_id           |        destination_bridge_id         
--------------------------------------+----------------------------+----------------------------+---------------+------------+----------------------------+-------------------------------------------------+--------+--------------------------------------+--------------------------------------
 7a9c397f-4ea6-4468-975a-6fc945a6e090 | 2024-07-18 18:06:10.918565 | 2024-07-18 18:06:10.918565 | test transfer | success    | 2024-07-18 18:06:10.942939 | test move to succeeded by D. Quayle in test.sql |    100 | 10000000-0000-0000-0000-000000000001 | 20000000-0000-0000-0000-000000000002
(1 row)

      ?column?      
--------------------
 Table dumps follow
(1 row)

 id |     description      | postal_address | postal_city | postal_state | postal_zip | postal_country | aba_routing_number | telephone_contact |   support_email    | support_website |        create_time         |        update_time         | internal_adapter_config |           internal_adapter_url           
----+----------------------+----------------+-------------+--------------+------------+----------------+--------------------+-------------------+--------------------+-----------------+----------------------------+----------------------------+-------------------------+------------------------------------------
  1 | Bank of America      | 1200 Post Road | Darien      | CT           | 06820      | USA            | 111111111          | 203-555-1212      | support@bofa.com   | www.bofa.com    | 2024-07-18 18:04:47.918504 | 2024-07-18 18:04:47.918504 | {}                      | file:///usr/local/bin/bofa-transaction
  2 | Darien Rowayton Bank | 999 Post Road  | Darien      | CT           | 06820      | USA            | 222222222          | 203-555-1213      | support@drbank.com | www.drbank.com  | 2024-07-18 18:04:47.918504 | 2024-07-18 18:04:47.918504 | null                    | file:///usr/local/bin/drbank-transaction
(2 rows)

 id |              bridge_id               | bank_id |   external_id   |        create_time         |        update_time         | owner_entity_id |       account_config       
----+--------------------------------------+---------+-----------------+----------------------------+----------------------------+-----------------+----------------------------
  1 | 20000000-0000-0000-0000-000000000002 |       1 | BOFA-43223-2222 | 2024-07-18 18:04:47.918504 | 2024-07-18 18:04:47.918504 |               2 | {"account": "2222"}
  2 | 10000000-0000-0000-0000-000000000001 |       2 | 199292-0444-D   | 2024-07-18 18:04:47.918504 | 2024-07-18 18:04:47.918504 |               1 | {"account-number": "0444"}
(2 rows)

 id |              bridge_id               |        create_time         |        update_time         |    comment    | xfer_state |      xfer_state_time       |                 xfer_state_note                 | amount | source_account_id | destination_account_id 
----+--------------------------------------+----------------------------+----------------------------+---------------+------------+----------------------------+-------------------------------------------------+--------+-------------------+------------------------
  1 | 7a9c397f-4ea6-4468-975a-6fc945a6e090 | 2024-07-18 18:06:10.918565 | 2024-07-18 18:06:10.918565 | test transfer | success    | 2024-07-18 18:06:10.942939 | test move to succeeded by D. Quayle in test.sql |    100 |                 2 |                      1
(1 row)

 id | action_id |        create_time         |        update_time         |                      note                       | from_state | to_state 
----+-----------+----------------------------+----------------------------+-------------------------------------------------+------------+----------
  1 |         1 | 2024-07-18 18:06:10.938261 | 2024-07-18 18:06:10.938261 | test move to pending by D. Quayle in test.sql   | new        | pending
  2 |         1 | 2024-07-18 18:06:10.942939 | 2024-07-18 18:06:10.942939 | test move to succeeded by D. Quayle in test.sql | pending    | success
(2 rows)
```
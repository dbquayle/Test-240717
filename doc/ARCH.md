# Architecture

This describes the architecture in more detail

## User Interface (Internal / Client Facing) Service

This is essentially a stub web service that can provide access to
summary details from the database.  We want the database to be the
main driver here in that we are managing a substantial amount of
information that has to be maintained for significant duration.

I realize the exam states that the service should be assumed to be
Ruby on Rails.  I would tend to implement this via Python and Flask
running on an Elastic Beanstalk implementation because
  * I've implemented such a stub service with this before
  * EB can scale dynamically if necessary
I have not seen EB provide a pipeline with Ruby, but I am sure that if
this is important a solution could be determined.  As stated above,
this service should be very simple and basically act as a proxy to the
stored procedures required to manage this in the database.

### Scalabliity

If running on Elastic Beanstalk or Kubernetes, this can be scaled
accordingly.   Depending on the number of instances required, caching
some of the requests and responses may be required.

### Security

As stateed, the transport for this should be over TLS/SSL.  User
authentication shuold be done via OAuth.  If possible if the
authentication manager is an external service and can manage access
control lists, e.g., for specific users / bank account mappings, this
is more desireable than having to implement that within the service
and the database.  A simple and crude ACL can be implemented, but more
complicated ones require more thought and are more bug-prone.  Failure
with an ACL component is a high-risk proposition.

### Endpoints

The API service basically acts as a stub service to teh database.
We don't want much logic in the service, since it basically is
responsible for writing (initial) data for the run into the database
and retrieving it.  The orchestration daemon should contain more
business logic.

For POST and PUT methods, we want the body to only speak
application/json with a simple schema where possible.  JSONSchema
should be used to define these schemata.

#### /banks (GET, POST, PUT, DELETE)
This endpoint is responsible for CRUD with the banks.
For example the GET method would call the summary.get_banks()
procedure and return that output in JSON format.

#### /accounts (GET, POST, PUT, DELETE)
This endpoint maps to the summary.accounts table.

#### /

## Database, Orchestration, and Scheduler

This is in the second layer, and the second layer is the heart of the
application.  This layer requires the most security.  Generally speaking, when implementing a layer like this, I prefer to bar all inbound connections and only allow it to initialte connections to other components.

### Postgres

Assuming an AWS infrastructure, I would employ the RDS version of
Postgres.  Using AWS security groups, we should deny all and whitelist
only those IPs from the orchestration manager and the UI Service
beanstalks.

Furthermore, AWS RDS allows for the database to run on an encrypted
disk for security.  Additional per-column security measures can also
be taken and can be discussed elsewhere, with the caveat that some
encryption approaches come at a performance cost.

#### Summary schema

This schema in the database contains the high level summary
information visible through the Bridge UI.

Establishing the access control list for the information here, i.e.,
who can se what transaction, is a bit of an exercise and some care
needs to be taken in how much access is to be granted.  Generally,
Occam's Razor applies here in force, i.e., for the purpose of this
exercise we should limit 

### Orchestration Daemon

This requires a connection to the dadtabase.  I have tended to write
these from scratch because usually some business logic ends up
tailoring and / or influencing the operation of the process.

For relaying events, we can take two approaches from Postgres to
schedule tasks downstream.  We can either poll the database and query
a view periodically or we can employ an event bus within the database
via triggers.  For sake of simplicity, and because we wish to limit
certain intersections within our dataset for parallel processing, we
will poll a view on a periodic basis.

The scheduling view is implemented in the stored procedure
`summary.get_pending(int)` -- the argument taken in the procedure is
the number of items on the queue to return to avoid discarding vast
quantities of data.  The orchestration scheduler maintains a
persistent connection to the database and polls it by calling that
procedure on a periodic basis, like every 2-5 seconds as available
execution slots become available.

## External Adapter Layer

As stated before, this is implemented either as a library or a
service.  If implemented as a service, it would have to be on an
internal network that is restricted to be callable only from the IPs
of the Orchestration Layer.  Each component here provides a common
interface.  Bank and account-specific parameters can be stored in JSON
in the database tables for bank and accounts as necessary.  See the
table definitions in the ddl directory for the details.

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

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

## Database

This is in the second layer, and the second layer is the heart of the
application.  This layer requires the most security.

### Postgres

Assuming an AWS infrastructure, I would employ the RDS version of
Postgres.  Using AWS security groups, we should deny all and whitelist
only those IPs from the orchestration manager and the UI Service
beanstalks.

Furthermore, AWS RDS allows for the database to run on an encrypted
disk for security.  Additional per-column security measures can also
be taken and can be discussed elsewhere, with the caveat that some
encryption approaches come at a performance cost.

## Orchestration Daemon

This requires a connection to the dadtabase.  I have tended to write
these from scratch because usually some business logic ends up
tailoring and / or influencing the operation of the process.  
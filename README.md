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



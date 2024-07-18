The C++ code is not going to be as complete as the other code.

I want to touch on the state machine for this.  We have to implement
transactional processing for the calls to the web service and the
rollback is a little tricky.  In order for the transaction to succeed,
two (or three if we question the reliability of our database journal)
components must all succeed.  Otherwise, we have to engage in a
rollback.  If we cannot roll the transaction back, then we have a
catastrophe.



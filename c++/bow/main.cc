
#include <string>
#include <string_view>
#include <iostream>
#include <sstream>

#include <pqxx/connection>
#include <pqxx/transaction>
#include <pqxx/except>

extern "C"
{
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
}

namespace
{
  namespace local
  {
    enum index_t
      {
	Arg_Program,
	Arg_ActionId,
	Arg_Amount,
	Arg_SrcAcct,
	Arg_SrcUrl,
	Arg_SrcBankCfg,
	Arg_SrcAcctCfg,
	Arg_DstAcct,
	Arg_DstUrl,
	Arg_DstBankCfg,
	Arg_DstAcctCfg,

	ARG_COUNT
      };

    enum result_t { Success = 0, SafeFailure, UnsafeFailure };
  }

  namespace bow
  {
    static constexpr const char LOG_STATEMENT[] = "xlog_insert";
    
    /**
       @brief This should be defined as an interface, but for this purpose
       it's a simple class.
    */
    class bank
    {
      std::string m_url;
      std::string m_global_cfg; ///< bank config (should be a JSON object)
      
    public:
      /**
	 @brief This instantiates the bank.
	 @param u url
	 @param c configuration
      */
      bank(const std::string &u, const std::string &c) :
	m_url(u), m_global_cfg(c)
      {
      }

      /**
	 @brief This destroys the bank.
      */
      ~bank(void) noexcept { }

      /**
	 @brief This is responsible for performing the transaction.
	 @param id identifier for the transaction
	 @param acfg account configuration
	 @param aid account identifier
	 @param a transaction amount
	 @return success or failure
	 @retval true success
	 @retval false failure

	 In an actual implementation this should be a virtual function
	 implemented in the derived class.
      */
      bool transact(const std::string &id, const std::string &acfg,
		    const std::string &aid, const double a) noexcept
      try
	{
	  /*
	    This is a horrible random number implementation, but it should
	    hopefully do the trick.
	  */
	  const unsigned long r = random() % 200;

	  fprintf(stdout, "random: %lu\n", r);
	  
	  if(r >= 190) return false;
	  
	  /// @todo To test this use a randomizer and throw...
	  
	  return true;
	}
      catch(...)
	{
	  fprintf(stderr, "unknown exception\n");

	  return false;
	}
    };

    /**
       @brief This logs the transfer (financial) transaction.
       @param pg database connection
       @param xid transfer identifier
       @param aid account identifier
       @param amt amountn
       @param msg message (human readable)
       @param s success flag
    */
    void log_db(pqxx::connection &db, const std::string &xid,
		const std::string &aid,
		const double amt, const std::string &msg, const bool s)
      try
	{
	  pqxx::transaction<> tx(db);

	  tx.exec_prepared(LOG_STATEMENT, xid, aid, amt, msg, s);
	  tx.commit();
	}
      catch(const pqxx::failure &e)
	{
	  fprintf(stderr, "PG exception in %s: %s\n", __PRETTY_FUNCTION__,
		  e.what());
	}
      catch(const std::exception &e)
	{
	  fprintf(stderr, "exception in %s: %s\n", __PRETTY_FUNCTION__,
		  e.what());
	}
      catch(...)
	{
	  fprintf(stderr, "unknown exception in %s\n", __PRETTY_FUNCTION__);
	}
    
    /**
       @brief This performs the double transfer.
       @param pg Postgres connection
       @param xid transfer identifier
       @param said source account
       @param daid destination account
       @param sbcfg source config
       @param dbcfg destionation config
       @param surl source URL
       @param durl destination URL
       @param a amount
       @return result code
    */
    ::local::result_t perform(pqxx::connection &pg,
			      const std::string &xid,
			      const std::string &said,
			      const std::string &daid,
			      const std::string &sbcfg,
			      const std::string &dbcfg,
			      const std::string &surl,
			      const std::string &durl,
			      const double a)
    {
      bank b0(surl, sbcfg), b1(durl, dbcfg);
      ::local::result_t result = local::result_t::Success;
      
      if(b0.transact(xid, std::string(), said, -a)) // debit
	log_db(pg, xid, said, -a, "successful debit", true);
      else
	{
	  result = ::local::result_t::SafeFailure;
	  log_db(pg, xid, said, -a, "debit failed", false);
	}

      if(result == ::local::result_t::Success)
	if(b1.transact(xid, std::string(), daid, a)) // credit
	  {
	    log_db(pg, xid, daid, a, "successful credit", true);
	    result = ::local::result_t::Success;
	  }
	else
	  {
	    log_db(pg, xid, daid, a, "credit failed... rollback needed",
		   false);
	    if(b0.transact(xid, std::string(), said, a))
	      {
		log_db(pg, xid, said, a, "rollback credit to debit account",
		       true);
		result = ::local::result_t::SafeFailure;
	      }
	    else
	      {
		log_db(pg, xid, said, a, "FAILED rollback credit to debit "
		       "account", false);
		result = ::local::result_t::UnsafeFailure;
	      }
	  }
      return result;
    }
  }
}

/**
   @brief This runs the program.
   @param argc argument count
   @param argv argument vector
   @return exit code
   @retval 0 success
   @retval 1 rolled back error
   @retval 2 catastrophic error (not rolled back)

   This is going to be extremely simple because of time constraints.
   We expect:
   bow @a xid @a amount @a saccount @a surl @a sbcfg @a sacfg @a daccount
   @a surl @a dbcfg @a dacfg

*/
int main(int argc, const char *const *argv)
  try
    {
      using ::local::result_t;

      static constexpr const char LOG_INSERT[] =
	"insert into journal.xlog(xfer_id, account_id, amount, message, "
	"success) values ($1, $2, $3, $4, $5);";

      static constexpr const char XFER_STATEMENT[] = "summary_update";
      static constexpr const char XFER_UPDATE[] =
	"select summary.update_xfer($1, $2, $3);";
      
      pqxx::connection pg; /// Rely on environment variables

      pg.prepare(::bow::LOG_STATEMENT, LOG_INSERT);
      pg.prepare(XFER_STATEMENT, XFER_UPDATE);

      srandom(getpid() & time(0));
      
      if(argc != ::local::ARG_COUNT)
	{
	  fprintf(stderr, "argument count is wrong %d (%d) \n", argc,
		  ::local::ARG_COUNT);
	  return result_t::SafeFailure;
	}
      else
	{
	  using ::local::index_t;
	  
	  const double amt = atof(argv[index_t::Arg_Amount]);
	  result_t result = result_t::SafeFailure;
	  const std::string xid = argv[index_t::Arg_ActionId];

	  fprintf(stderr, "transfer id: %s\n", xid.c_str());
	  
	  if(amt < 0)
	    {
	      fprintf(stderr, "illegal amoount %s", argv[index_t::Arg_Amount]);
	      result = result_t::SafeFailure;
	    }
	  else
	    {
	      result = ::bow::perform(pg, xid,
				      argv[index_t::Arg_SrcAcct],
				      argv[index_t::Arg_DstAcct],
				      argv[index_t::Arg_SrcBankCfg],
				      argv[index_t::Arg_DstBankCfg],
				      argv[index_t::Arg_SrcUrl],
				      argv[index_t::Arg_DstUrl],
				      amt);
	      fprintf(stderr, "perform returns: %d\n", result);
	    }

	  do
	    {
	      pqxx::transaction<> tx(pg);
	      
	      switch(result)
		{
		case result_t::Success:
		  tx.exec_prepared(XFER_STATEMENT, xid, "success",
				   "transfer completed successfully");
		  break;
		case result_t::SafeFailure:
		  tx.exec_prepared(XFER_STATEMENT, xid, "aborted",
				   "transfer aborted and rolled back");
		  break;
		case result_t::UnsafeFailure:
		  tx.exec_prepared(XFER_STATEMENT, xid, "catastrophe",
				   "transfer failed and could NOT roll back");
		  break;
		}

	      tx.commit();
	    }
	  while(0);
	}
    }
  catch(const pqxx::failure &e)
    {
      fprintf(stderr, "PG failure: %s\n", e.what());
      return ::local::result_t::SafeFailure;
    }
  catch(...)
    {
      return ::local::result_t::UnsafeFailure;
    }

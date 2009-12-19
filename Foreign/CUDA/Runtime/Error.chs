{-# LANGUAGE ForeignFunctionInterface, DeriveDataTypeable #-}
--------------------------------------------------------------------------------
-- |
-- Module    : Foreign.CUDA.Runtime.Error
-- Copyright : (c) 2009 Trevor L. McDonell
-- License   : BSD
--
-- Error handling functions
--
--------------------------------------------------------------------------------

module Foreign.CUDA.Runtime.Error
  where


-- Friends
import Foreign.CUDA.Internal.C2HS

-- System
import Foreign
import Foreign.C
import Data.Typeable
import Control.Exception

#include <cuda_runtime_api.h>
{# context lib="cudart" #}


--------------------------------------------------------------------------------
-- Return Status
--------------------------------------------------------------------------------

--
-- Error Codes
--
{# enum cudaError as Status
    { cudaSuccess as Success }
    with prefix="cudaError" deriving (Eq, Show) #}

--------------------------------------------------------------------------------
-- Exceptions
--------------------------------------------------------------------------------

data CUDAException
  = ExitCode Status
  | UserError String
  deriving Typeable

instance Exception CUDAException

instance Show CUDAException where
  showsPrec _ (ExitCode  s) = showString ("CUDA Exception: " ++ describe s)
  showsPrec _ (UserError s) = showString ("CUDA Exception: " ++ s)


-- |
-- Raise a CUDAException in the IO Monad
--
cudaError :: String -> IO a
cudaError s = throwIO (UserError s)


--------------------------------------------------------------------------------
-- Helper Functions
--------------------------------------------------------------------------------

-- |
-- Return the descriptive string associated with a particular error code
--
{# fun pure unsafe cudaGetErrorString as describe
    { cFromEnum `Status' } -> `String' #}
--
-- Logically, this must be a pure function, returning a pointer to a statically
-- defined string constant.
--


-- |
-- Return the results of a function on successful execution, otherwise return
-- the error string associated with the return code
--
resultIfOk :: (Status, a) -> IO a
resultIfOk (status,result) =
    case status of
        Success -> return  result
        _       -> throwIO (ExitCode status)


-- |
-- Return the error string associated with an unsuccessful return code,
-- otherwise Nothing
--
nothingIfOk :: Status -> IO ()
nothingIfOk status =
    case status of
        Success -> return  ()
        _       -> throwIO (ExitCode status)


{-# OPTIONS_GHC -funbox-strict-fields #-}
{-# LANGUAGE DeriveDataTypeable #-}
module Control.Concurrent.Chan.Split.Internal (
   -- | Unsafe implementation details. This interface will not be stable across
   -- versions.
   Stack(..), W, R, InChan(..), OutChan(..)
   ) where

import Data.Typeable(Typeable)
import Control.Concurrent.MVar

data Stack a = Positive [a] 
             | Negative { firstWaiting :: !(MVar a) }
             | AWhistlingVoid

type W a = MVar (Stack a)
type R a = MVar [a]

-- | The \"write side\" of a channel.
newtype InChan a = InChan (W a)
    deriving (Eq, Typeable)

-- | The \"read side\" of a channel.
data OutChan a = OutChan { writerStack :: !(W a),  readerDeq :: !(R a) }
    deriving (Eq, Typeable)

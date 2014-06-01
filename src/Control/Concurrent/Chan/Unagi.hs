module Control.Concurrent.Chan.Unagi (
    -- * Creating channels
      newChan
    , InChan(), OutChan()
    -- * Channel operations
    -- ** Reading
    , readChan
    , readChanOnException
    , getChanContents
    -- ** Writing
    , writeChan
    , writeList2Chan
    -- ** Broadcasting
    , dupChan
    ) where
-- TODO additonal functions:
--   - write functions optimized for single-writer
--   - faster write/read-many that increments counter by N

import Control.Concurrent.Chan.Unagi.Internal
-- For 'writeList2Chan', as in vanilla Chan
import System.IO.Unsafe ( unsafeInterleaveIO ) 


newChan :: IO (InChan a, OutChan a)
newChan = newChanStarting (maxBound - 10) 
    -- lets us test counter overflow in tests and normal course of operation

-- | Return a lazy list representing the contents of the supplied OutChan, much
-- like System.IO.hGetContents.
getChanContents :: OutChan a -> IO [a]
getChanContents ch = unsafeInterleaveIO (do
                            x  <- readChan ch
                            xs <- getChanContents ch
                            return (x:xs)
                        )

-- | Write an entire list of items to a chan type. Writes here from multiple
-- threads may be interleaved, and infinite lists are supported.
writeList2Chan :: InChan a -> [a] -> IO ()
{-# INLINABLE writeList2Chan #-}
writeList2Chan ch = sequence_ . map (writeChan ch)

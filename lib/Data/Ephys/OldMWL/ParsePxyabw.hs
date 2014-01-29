{-# LANGUAGE RecordWildCards #-} 
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NoMonomorphismRestriction #-}

module Data.Ephys.OldMWL.ParsePxyabw where

import qualified Data.Ephys.Spike as Arte
import Data.Ephys.OldMWL.Parse -- We're using the old file organization.  b/c hasty
import Data.Ephys.OldMWL.FileInfo

import Control.Monad (forM_, replicateM, forever)
import Data.Maybe (listToMaybe)
import qualified Data.ByteString.Lazy as BSL hiding (map, any, zipWith)
import qualified Data.ByteString as BS
import qualified Data.Vector.Unboxed as U
import GHC.Int
import Pipes
import qualified Pipes.Prelude as PP
import Data.Binary
import Data.Binary.Put
import qualified Pipes.Binary as PBinary hiding (Get)
import Data.Binary.Get (getWord32le, getWord16le,getWord64le, getWord64be)
import qualified Pipes.ByteString as PBS 
import qualified Data.Text as T
import Data.Packed.Matrix
import qualified Data.List as List
import Data.Packed.Vector (Vector, toList)
import qualified Foreign.C.Types as C
import qualified Data.Typeable as Typeable
import Control.Applicative
import Data.Binary.IEEE754

data MWLSpikeParms = MWLSpikeParms { mwlSParmsID    :: Word32
                                   , mwlSParmsTpX   :: Word16
                                   , mwlSParmsTpY   :: Word16
                                   , mwlSParmsTpA   :: Word16
                                   , mwlSParmsTpB   :: Word16
                                   , mwlSParmsTMaxW :: Word16
                                   , mwlSParmsTMaxH :: Word16
                                   , mwlSParmsTime  :: Double
                                   , mwlSParmsPosX  :: Word16
                                   , mwlSParmsPosY  :: Word16
                                   , mwlSParmsVel   :: Word32
                                   } deriving (Eq, Show)


parsePxyabw :: Get MWLSpikeParms
parsePxyabw = MWLSpikeParms
              <$> getWord32le
              <*> getWord16le
              <*> getWord16le
              <*> getWord16le
              <*> getWord16le
              <*> getWord16le
              <*> getWord16le
              <*> (wordToDouble <$> getWord64le)
--              <*> get
              <*> getWord16le
              <*> getWord16le
              <*> getWord32le
              
writeSpikeParms :: MWLSpikeParms -> Put
writeSpikeParms MWLSpikeParms{..} = do
  putWord32le $ mwlSParmsID
  putWord16le $ mwlSParmsTpX
  putWord16le $ mwlSParmsTpY
  putWord16le $ mwlSParmsTpA
  putWord16le $ mwlSParmsTpB
  putWord16le $ mwlSParmsTMaxW
  putWord16le $ mwlSParmsTMaxH
  putWord64le $ doubleToWord mwlSParmsTime
--  put $ mwlSParmsTime
  putWord16le $ mwlSParmsPosX
  putWord16le $ mwlSParmsPosY
  putWord32le    $ mwlSParmsVel
              
              

{- Gonna try again, converting only the time field
-- This is specific to the way I typically unpack .tt data
-- It's also keeping everything in the original hyper-simple-to-decode form
-- because I'm only using it as a way of filtering down a .pxyabw file for now
data MWLSpikeParms = MWLSpikeParms { mwlSParmsID    :: Int32
                                   , mwlSParmsTpX   :: Int16 -- Voltage (TODO fixme)
                                   , mwlSParmsTpY   :: Int16
                                   , mwlSParmsTpA   :: Int16
                                   , mwlSParmsTpB   :: Int16
                                   , mwlSParmsTMaxW :: Int16
                                   , mwlSParmsTMaxH :: Int16
                                   , mwlSParmsTime  :: Double
                                   , mwlSParmsPosX  :: Int16
                                   , mwlSParmsPosY  :: Int16
                                   , mwlSParmsVel   :: Word8 --Should be Int8, letting it go through here
                                   } deriving (Eq, Show)


parsePxyabw :: Get MWLSpikeParms
parsePxyabw =
  do
    pid          <- getWord32le :: Get Word32
    tPx          <- getWord16le :: Get Word16
    tPy          <- getWord16le
    tPa          <- getWord16le
    tPb          <- getWord16le
    tMw          <- getWord16le
    tMh          <- getWord16le
    sTime <- getWord32le
    pX    <- getWord16le
    pY    <- getWord16le
    v     <- getWord8
    return $ MWLSpikeParms
      (word32ToInt32 pid)
      (word16ToInt16 tPx)
      (word16ToInt16 tPy)
      (word16ToInt16 tPa)
      (word16ToInt16 tPb)
      (word16ToInt16 tMw)
      (word16ToInt16 tMh)
      (decodeTime sTime)
      (word16ToInt16 pX)
      (word16ToInt16 pY)
      v

writeSpikeParms :: MWLSpikeParms -> Put
writeSpikeParms MWLSpikeParms{..} = do
  putWord32le $ int32toWord32 mwlSParmsID
  putWord16le $ int16toWord16 mwlSParmsTpX
  putWord16le $ int16toWord16 mwlSParmsTpY
  putWord16le $ int16toWord16 mwlSParmsTpA
  putWord16le $ int16toWord16 mwlSParmsTpB
  putWord16le $ int16toWord16 mwlSParmsTMaxW
  putWord16le $ int16toWord16 mwlSParmsTMaxH
  putWord32le $ encodeTime mwlSParmsTime
  putWord16le $ int16toWord16 mwlSParmsPosX
  putWord16le $ int16toWord16 mwlSParmsPosY
  putWord8    $ mwlSParmsVel
  -}
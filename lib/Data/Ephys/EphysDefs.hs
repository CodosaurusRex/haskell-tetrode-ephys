{-# LANGUAGE BangPatterns, TypeSynonymInstances, DeriveDataTypeable #-}

module Data.Ephys.EphysDefs where

-- import Data.Time 

type Voltage = Double

type ExperimentTime = Double -- TODO: How to record the wall clock time of "0 :: ExperimentTime"
-- Is 0 the time that the system was turned on?  Clock reset?
-- How to ensure that data that straddle a clock reset aren't combined?
-- Possibly ExperimentTime should be (StartUpUTCTime, ClockResetsSinceStartup, FloatTimeSinceReset)

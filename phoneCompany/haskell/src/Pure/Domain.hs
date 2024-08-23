{-# LANGUAGE DataKinds #-}

module Pure.Domain (
    CallLog (..),
    Call (..),
    CallDetail (..),
    call,
    number,
    overflowRate,
    standardRate,
    standardRateDuration,
    parseDuration,
    isWithinStandardRate,
) where

import Data.Hourglass
import Data.Int
import Data.List.Split
import Data.Text (Text, pack)
import qualified Money
import Text.Read
import Text.Regex

-- Types Declaration ---------------------------------------------------

data CallLog = CallLog
    { clCostumerId :: String
    , clCalled :: String
    , clDuration :: String
    }
    deriving (Show)

data Call = OverflowCall String Number Duration | StandardRateCall String Number Duration
    deriving (Show, Eq)

class CallDetail a where
    costumerId :: a -> String
    called :: a -> Number
    duration :: a -> Duration

instance CallDetail Call where
    costumerId (OverflowCall x _ _) = x
    costumerId (StandardRateCall x _ _) = x
    called (OverflowCall _ x _) = x
    called (StandardRateCall _ x _) = x
    duration (OverflowCall _ _ x) = x
    duration (StandardRateCall _ _ x) = x

type Number = Text

-- Standard Values ----------------------------------------------

standardRateDuration :: Duration
standardRateDuration =
    Duration
        { durationHours = Hours 0
        , durationMinutes = Minutes 3
        , durationSeconds = Seconds 0
        , durationNs = NanoSeconds 0
        }

standardRate :: Money.Discrete "GBP" "penny"
standardRate = Money.discrete 5
overflowRate :: Money.Discrete "GBP" "penny"
overflowRate = Money.discrete 3

isWithinStandardRate :: Duration -> Bool
isWithinStandardRate d = d <= standardRateDuration

-- Types Constructors --------------------------------

call :: String -> Number -> Duration -> Call
call cId called duration =
    if (isWithinStandardRate duration)
        then StandardRateCall cId called duration
        else OverflowCall cId called duration

number :: String -> Maybe Number
number s = fmap (pack . head) (matchRegex (mkRegex "([0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9])") s)

-- String in format hh:mm:ss
parseDuration :: String -> Maybe Duration
parseDuration s = do
    let sp = splitOn ":" s
    stringParsed <- if (Prelude.length sp == 3) then Just sp else Nothing
    resultList <- traverse (\x -> readMaybe x :: Maybe Int64) stringParsed
    return
        Duration
            { durationHours = Hours $ resultList !! 0
            , -- \^ number of hours
              durationMinutes = Minutes $ resultList !! 1
            , -- \^ number of minutes
              durationSeconds = Seconds $ resultList !! 2
            , -- \^ number of seconds
              durationNs = NanoSeconds 0
            }

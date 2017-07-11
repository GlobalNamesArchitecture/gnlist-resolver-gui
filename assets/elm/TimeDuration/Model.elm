module TimeDuration.Model
    exposing
        ( TimeDuration(..)
        , Hours(..)
        , Minutes(..)
        , Seconds(..)
        , secondsToTimeDuration
        , secondsToTime
        , timeToSeconds
        )

import Time exposing (Time)


type Hours
    = Hours Int


type Minutes
    = Minutes Int


type Seconds
    = Seconds Float


type TimeDuration
    = TimeDuration Hours Minutes Seconds


secondsToTime : Seconds -> Time
secondsToTime (Seconds s) =
    s


timeToSeconds : Time -> Seconds
timeToSeconds =
    Seconds << max 0


secondsToTimeDuration : Seconds -> TimeDuration
secondsToTimeDuration seconds =
    TimeDuration (hoursFromSeconds seconds) (minutesFromSeconds seconds) (secondsFromSeconds seconds)


hoursFromSeconds : Seconds -> Hours
hoursFromSeconds (Seconds s) =
    Hours <| (round s) // 3600


minutesFromSeconds : Seconds -> Minutes
minutesFromSeconds (Seconds s) =
    Minutes <| (round s % 3600) // 60


secondsFromSeconds : Seconds -> Seconds
secondsFromSeconds (Seconds s) =
    Seconds <| toFloat <| (round s % 3600) % 60

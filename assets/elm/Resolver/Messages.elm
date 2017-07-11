module Resolver.Messages exposing (Msg(..))

import Time
import Http
import Errors exposing (Errors)
import Resolver.Models exposing (Stats)


type Msg
    = LaunchResolution (Result Http.Error ())
    | QueryResolutionProgress Time.Time
    | ResolutionProgress (Result Http.Error ( Stats, Errors ))
    | SendStopResolution
    | StopResolution (Result Http.Error ())
    | EmptyErrors

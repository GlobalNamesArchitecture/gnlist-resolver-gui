module Resolver.Api
    exposing
        ( queryResolutionProgress
        , startResolution
        , sendStopResolution
        )

import Http
import Helper as H
import Json.Decode exposing (null)
import Resolver.Messages exposing (Msg(..))
import Resolver.Encoder as RE
import Resolver.Decoder exposing (statsAndErrorsDecoder)


queryResolutionProgress : String -> Cmd Msg
queryResolutionProgress token =
    let
        url =
            "/stats/" ++ token
    in
        Http.send ResolutionProgress
            (Http.get url statsAndErrorsDecoder)


startResolution : String -> Cmd Msg
startResolution token =
    let
        url =
            "/resolver/" ++ token
    in
        Http.send LaunchResolution
            (Http.get url (null ()))


sendStopResolution : String -> Cmd Msg
sendStopResolution token =
    let
        url =
            "/list_matchers"
    in
        Http.send StopResolution
            (H.put url <| RE.body token)

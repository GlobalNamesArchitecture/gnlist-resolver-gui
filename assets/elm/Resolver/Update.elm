module Resolver.Update exposing (update)

import Resolver.Models exposing (..)
import Resolver.Helper as RH
import Resolver.Messages exposing (Msg(..))


update : Msg -> Resolver -> String -> ( Resolver, Cmd Msg )
update msg resolver token =
    case msg of
        LaunchResolution (Ok _) ->
            ( resolver, Cmd.none )

        LaunchResolution (Err _) ->
            ( resolver, Cmd.none )

        QueryResolutionProgress _ ->
            ( resolver, RH.queryResolutionProgress token )

        ResolutionProgress (Ok ( stats, errors )) ->
            ( { resolver
                | stats = Just stats
                , errors = errors
              }
            , Cmd.none
            )

        ResolutionProgress (Err _) ->
            ( resolver, Cmd.none )

        SendStopResolution ->
            ( resolver, RH.sendStopResolution token )

        StopResolution (Ok _) ->
            ( { resolver | stopTrigger = True }, Cmd.none )

        StopResolution (Err _) ->
            ( resolver, Cmd.none )

        EmptyErrors ->
            ( { resolver | errors = Nothing }, Cmd.none )

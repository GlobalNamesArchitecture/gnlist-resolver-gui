module Resolver.Update exposing (subscriptions, update)

import Time exposing (millisecond)
import Resolver.Models exposing (..)
import Resolver.Messages exposing (Msg(..))
import Resolver.Api exposing (queryResolutionProgress, startResolution, sendStopResolution)
import Data.Token exposing (Token)


subscriptions : Resolver -> Sub Msg
subscriptions { stats } =
    case stats of
        Done _ _ _ _ ->
            Sub.none

        _ ->
            Time.every (millisecond * 1000) QueryResolutionProgress


update : Msg -> Resolver -> Token -> ( Resolver, Cmd Msg )
update msg resolver token =
    case msg of
        LaunchResolution (Ok _) ->
            ( resolver, Cmd.none )

        LaunchResolution (Err _) ->
            ( resolver, Cmd.none )

        QueryResolutionProgress _ ->
            ( resolver, queryResolutionProgress token )

        ResolutionProgress (Ok ( stats, errors )) ->
            ( { resolver
                | stats = stats
                , errors = errors
              }
            , resolutionProgressCmd token stats
            )

        ResolutionProgress (Err _) ->
            ( resolver, Cmd.none )

        SendStopResolution ->
            ( resolver, sendStopResolution token )

        StopResolution (Ok _) ->
            ( { resolver | stopTrigger = True }, Cmd.none )

        StopResolution (Err _) ->
            ( resolver, Cmd.none )

        EmptyErrors ->
            ( { resolver | errors = Nothing }, Cmd.none )


resolutionProgressCmd : Token -> Stats -> Cmd Msg
resolutionProgressCmd token stats =
    case stats of
        NotStarted ->
            startResolution token

        _ ->
            Cmd.none

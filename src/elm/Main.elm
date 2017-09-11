module Main exposing (..)

import Subscriptions exposing (subscriptions)
import Models exposing (Model, Flags)
import Messages exposing (Msg(..))
import Update exposing (init, update)
import View exposing (view)
import Navigation exposing (Location)


main : Program Flags Model Msg
main =
    Navigation.programWithFlags OnLocationChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

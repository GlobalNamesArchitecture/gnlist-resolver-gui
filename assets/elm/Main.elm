module Main exposing (..)

import Subscriptions exposing (subscriptions)
import Models exposing (Model, Flags, initModel)
import Messages exposing (Msg(..))
import Update exposing (update)
import View exposing (view)
import Navigation exposing (Location)
import Routing exposing (Route)
import FileUpload.Ports as FUP


init : Flags -> Location -> ( Model, Cmd Msg )
init flags location =
    let
        currentRoute =
            Routing.parseLocation location
    in
        ( initModel flags currentRoute, FUP.isUploadSupported () )


main : Program Flags Model Msg
main =
    Navigation.programWithFlags OnLocationChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

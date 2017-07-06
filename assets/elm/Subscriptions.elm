module Subscriptions exposing (subscriptions)

import Time exposing (Time, second)
import Messages exposing (Msg(..))
import Models exposing (Model)
import Routing exposing (Route(..))
import FileUpload.Update as FUU
import Resolver.Models exposing (Status(Done))
import Resolver.Messages as RM
import Resolver.Helper as RH


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.route of
        FileUpload ->
            Sub.map FileUploadMsg FUU.subscriptions

        Resolver _ ->
            case RH.status model.resolver of
                Done ->
                    Sub.none

                _ ->
                    Sub.map ResolverMsg <|
                        Time.every (second * 2) RM.QueryResolutionProgress

        _ ->
            Sub.none

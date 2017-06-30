module Subscriptions exposing (subscriptions)

import Time exposing (Time, second)
import Messages exposing (Msg(..))
import Models exposing (Model)
import Routing exposing (Route(..))
import FileUpload.Ports as FUP
import FileUpload.Messages as FUM
import Resolver.Models exposing (Status(Done))
import Resolver.Messages as RM
import Resolver.Helper as RH


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.route of
        FileUpload ->
            Sub.batch fileUploadSubs

        Resolver _ ->
            case RH.status model.resolver of
                Done ->
                    Sub.none

                _ ->
                    Sub.map ResolverMsg <|
                        Time.every (second * 2) RM.QueryResolutionProgress

        _ ->
            Sub.none


fileUploadSubs : List (Sub Msg)
fileUploadSubs =
    List.map (Sub.map FileUploadMsg)
        [ FUP.uploadIsSupported FUM.UploadSupported
        , FUP.fileSelectedData FUM.FileSelectedData
        , FUP.fileUploadResult FUM.FileUploadResult
        ]

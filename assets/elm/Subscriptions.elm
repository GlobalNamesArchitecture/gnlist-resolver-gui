module Subscriptions exposing (subscriptions)

import Messages exposing (Msg(..))
import Models exposing (Model)
import Routing exposing (Route(..))
import FileUpload.Update as FUU
import Resolver.Update as RU


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.route of
        FileUpload ->
            Sub.map FileUploadMsg FUU.subscriptions

        Resolver _ ->
            Sub.map ResolverMsg <| RU.subscriptions model.resolver

        _ ->
            Sub.none

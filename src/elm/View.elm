module View exposing (view)

import Html exposing (..)
import Models exposing (Model)
import Messages exposing (Msg(..))
import I18n exposing (Translation(..))
import Routing exposing (Route(..))
import View.Layout as Layout
import View.Error as Error
import FileUpload.View as FileUpload
import Terms.View as Terms
import Target.View as Target
import Target.Helper as Target
import Resolver.View as Resolver
import Data.Token exposing (Token)


view : Model -> Html Msg
view model =
    Layout.layout model
        [ div []
            [ Error.view model
            , findRoute model
            ]
        ]


findRoute : Model -> Html Msg
findRoute model =
    case model.route of
        FileUpload ->
            fileUploadView model

        Terms token ->
            termsView model token

        Target token ->
            dataSourceView model token

        Resolver _ ->
            resolverView model

        NotFoundRoute ->
            text <| I18n.t RouteNotFound


fileUploadView : Model -> Html Msg
fileUploadView model =
    Html.map FileUploadMsg <| FileUpload.view model.upload


termsView : Model -> Token -> Html Msg
termsView model token =
    Html.map TermsMsg <|
        Terms.view model.target.all model.terms token


dataSourceView : Model -> Token -> Html Msg
dataSourceView model token =
    Html.map TargetMsg <|
        Target.view model.target token


resolverView : Model -> Html Msg
resolverView model =
    Html.map ResolverMsg <|
        Resolver.view model.resolver
            (Target.currentTarget model.target)
            model.terms

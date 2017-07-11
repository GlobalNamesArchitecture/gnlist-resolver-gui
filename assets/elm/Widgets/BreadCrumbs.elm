module Widgets.BreadCrumbs exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class)
import I18n exposing (Translation(..))
import Routing exposing (Route(..))
import Models exposing (Model)


view : Model -> Html msg
view model =
    ul [ class "breadcrumb" ] <|
        List.map (row model) stages


stages : List ( Int, String )
stages =
    [ ( 0, I18n.t BreadcrumbUploadFile )
    , ( 1, I18n.t BreadcrumbMapHeaders )
    , ( 2, I18n.t BreadcrumbPickReferenceData )
    , ( 3, I18n.t BreadcrumbCrossmapNames )
    ]


step : Model -> Int
step model =
    case model.route of
        FileUpload ->
            0

        Terms _ ->
            1

        Target _ ->
            2

        Resolver _ ->
            3

        _ ->
            -1


row : Model -> ( Int, String ) -> Html msg
row model ( pos, txt ) =
    let
        cls =
            if step model < pos then
                "pending"
            else
                "done"
    in
        viewCrumb cls txt


viewCrumb : String -> String -> Html msg
viewCrumb cls txt =
    li [ class cls ] [ span [] [ text txt ] ]

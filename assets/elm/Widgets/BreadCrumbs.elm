module Widgets.BreadCrumbs exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class)
import Routing exposing (Route(..))
import Models exposing (Model)


view : Model -> Html msg
view model =
    ul [ class "breadcrumb" ] <|
        List.map (row model) stages


stages : List ( Int, String )
stages =
    [ ( 0, "Upload a File" )
    , ( 1, "Map Headers" )
    , ( 2, "Pick Referene Data" )
    , ( 3, "Crossmap Names" )
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

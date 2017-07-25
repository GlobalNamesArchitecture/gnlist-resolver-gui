module View.Error exposing (view)

import Html exposing (Html, div, h3, button, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import I18n exposing (Translation(..))
import Markdown
import Errors exposing (Errors, Error)
import Models exposing (Model)
import Messages exposing (Msg(..))


view : Model -> Html Msg
view model =
    case allErrors model of
        Nothing ->
            div [] []

        Just es ->
            viewErrors es


viewErrors : List Error -> Html Msg
viewErrors errors =
    let
        errorList =
            (List.map viewError errors) ++ [ errorButton ]
    in
        div [ class "errors" ] errorList


errorButton : Html Msg
errorButton =
    div [] [ button [ onClick EmptyErrors ] [ text <| I18n.t DismissErrors ] ]


allErrors : Model -> Errors
allErrors model =
    let
        errors =
            List.filter (\l -> l /= Nothing)
                [ model.upload.errors, model.resolver.errors ]
    in
        if List.isEmpty errors then
            Nothing
        else
            errors
                |> List.map (\l -> Maybe.withDefault [] l)
                |> List.concatMap identity
                |> Just


viewError : Error -> Html a
viewError er =
    div [ class "error" ]
        [ h3 [] [ text er.title ]
        , Markdown.toHtml [] er.body
        ]

module Target.View exposing (view)

import Html exposing (..)
import Html.Attributes
    exposing
        ( class
        , checked
        , type_
        , name
        , value
        , placeholder
        , autofocus
        )
import Html.Events exposing (onClick, on, targetValue)
import Json.Decode as J
import Maybe exposing (withDefault)
import I18n exposing (Translation(..))
import View.Layout exposing (contentWrapper, styledButton)
import Target.Models exposing (Target, DataSource)
import Target.Messages exposing (Msg(..))


view : Target -> String -> Html Msg
view target token =
    contentWrapper BreadcrumbPickReferenceData
        PickReferenceDataDescription
        [ div []
            [ div []
                [ continueButton token
                ]
            , div []
                [ input
                    [ type_ "text"
                    , class "target-search"
                    , autofocus True
                    , onInput FilterTarget
                    , placeholder <| I18n.t SearchPlaceholder
                    ]
                    []
                ]
            , selectTarget target token
            ]
        ]


continueButton : String -> Html Msg
continueButton token =
    styledButton [] (ToResolver token) Continue


normalize : String -> String
normalize str =
    str |> String.trim |> String.toLower


onInput : (String -> Msg) -> Attribute Msg
onInput msg =
    on "input" <| J.andThen (\t -> J.succeed <| msg (normalize t)) targetValue


selectTarget : Target -> String -> Html Msg
selectTarget target token =
    let
        match t =
            case t.title of
                Nothing ->
                    False

                Just title ->
                    String.contains target.filter <| normalize title

        sources =
            if target.filter == "" then
                target.all
            else
                List.filter match target.all
    in
        sources
            |> List.map (dataSourceRender token target.current)
            |> div []


dataSourceRender : String -> Int -> DataSource -> Html Msg
dataSourceRender token current dsi =
    div []
        [ input
            [ type_ "radio"
            , name "data_source"
            , value <| toString dsi.id
            , checked (checkedTarget dsi current)
            , onClick (CurrentTarget token dsi.id)
            ]
            []
        , text <| withDefault "" dsi.title
        ]


checkedTarget : DataSource -> Int -> Bool
checkedTarget dsi current =
    dsi.id == current

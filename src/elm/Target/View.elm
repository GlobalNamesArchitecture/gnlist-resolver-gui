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
import Target.Models exposing (Target)
import Target.Messages exposing (Msg(..))
import Data.Token exposing (Token)
import Data.DataSource as DataSource exposing (DataSource)


view : List DataSource -> Target -> Token -> Html Msg
view dataSources target token =
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
            , selectTarget dataSources target token
            ]
        ]


continueButton : Token -> Html Msg
continueButton token =
    styledButton [] (ToResolver token) Continue


normalize : String -> String
normalize str =
    str |> String.trim |> String.toLower


onInput : (String -> Msg) -> Attribute Msg
onInput msg =
    on "input" <| J.andThen (\t -> J.succeed <| msg (normalize t)) targetValue


selectTarget : List DataSource -> Target -> Token -> Html Msg
selectTarget dataSources target token =
    let
        match t =
            String.contains target.filter <| normalize t.title

        sources =
            if target.filter == "" then
                dataSources
            else
                List.filter match dataSources
    in
        sources
            |> List.map (dataSourceRender token target.current)
            |> div []


dataSourceRender : Token -> Maybe DataSource.Id -> DataSource -> Html Msg
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
        , text dsi.title
        ]


checkedTarget : DataSource -> Maybe DataSource.Id -> Bool
checkedTarget { id } current =
    case current of
        Nothing ->
            False

        Just current_ ->
            id == current_

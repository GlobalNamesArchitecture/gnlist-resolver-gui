module Terms.View exposing (view)

import Html exposing (..)
import Html.Events exposing (onClick, on, targetValue)
import Html.Attributes exposing (class, value, id, name, list, type_)
import Maybe exposing (withDefault)
import Json.Decode as J
import Terms.Models exposing (Terms, Header, Row, allFields)
import Terms.Messages exposing (Msg(..))
import Target.Models exposing (DataSources)


view : DataSources -> Terms -> String -> Html Msg
view ds terms token =
    div []
        [ button [ onClick (nextMsg ds token) ] [ text "Continue" ]
        , div [ (class "terms_table_container") ]
            [ table [ class "terms_table" ] <|
                (viewHeaders terms.headers)
                    :: ((viewSelectors token terms.headers)
                            :: (viewRows terms.rows)
                       )
            ]
        ]


nextMsg : DataSources -> String -> Msg
nextMsg ds token =
    if List.length ds > 1 then
        ToDataSources token
    else
        ToResolver token


viewSelectors : String -> List Header -> Html Msg
viewSelectors token headers =
    tr [] (List.map (viewSelector token) headers)


viewSelector : String -> Header -> Html Msg
viewSelector token header =
    td [ class "terms_selector" ]
        [ text <| "match with"
        , br [] []
        , input
            [ list "terms"
            , id <| "term_" ++ (toString header.id)
            , value <| withDefault "" header.term
            , onInput <| MapTerm token header.id
            , onChange <| MapTerm token header.id
            ]
            []
        , datalist [ id "terms" ] <| List.map dropDownEntry allFields
        , span
            [ class "delete-button"
            , onClick (MapTerm token header.id "")
            ]
            [ text "✖" ]
        ]


onInput : (String -> Msg) -> Attribute Msg
onInput msg =
    let
        isTerm term =
            if List.any (\t -> t == term || String.isEmpty term) allFields then
                J.succeed <| msg term
            else
                J.fail "Not known"
    in
        on "input" <| J.andThen isTerm targetValue


onChange : (String -> Msg) -> Attribute Msg
onChange msg =
    let
        isTerm term =
            if List.any (\t -> t == term || String.isEmpty term) allFields then
                J.succeed <| msg term
            else
                J.succeed <| msg ""
    in
        on "change" <| J.andThen isTerm targetValue


dropDownEntry : String -> Html Msg
dropDownEntry field =
    option [ value field ] []


viewHeaders : List Header -> Html Msg
viewHeaders headers =
    tr [] (List.map viewHeaderEntry headers)


viewHeaderEntry : Header -> Html Msg
viewHeaderEntry header =
    th [ headerClass header ]
        [ text <|
            case header.term of
                Nothing ->
                    header.value

                Just term ->
                    header.value ++ " → " ++ term
        ]


headerClass : Header -> Attribute msg
headerClass header =
    case header.term of
        Nothing ->
            class "no_dwca"

        _ ->
            class "dwca"


viewRows : List Row -> List (Html Msg)
viewRows rows =
    List.map viewRow rows


viewRow : Row -> Html Msg
viewRow row =
    tr [] (List.map viewRowEntry row)


viewRowEntry : Maybe String -> Html Msg
viewRowEntry re =
    let
        val =
            case re of
                Just entry ->
                    entry

                Nothing ->
                    ""
    in
        td [] [ text val ]

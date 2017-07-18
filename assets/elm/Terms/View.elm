module Terms.View exposing (view)

import Html exposing (..)
import Material.Table as Table
import Material.Options as Options
import Html.Events exposing (onClick, on, targetValue)
import Html.Attributes exposing (class, value, id, list)
import Json.Decode as J
import Terms.Models exposing (Terms, Term, Header, Row, allTermValues)
import View.Layout exposing (contentWrapper)
import I18n exposing (Translation(..))
import Terms.Messages exposing (Msg(..))
import Target.Models exposing (DataSources)


view : DataSources -> Terms -> String -> Html Msg
view ds terms token =
    contentWrapper BreadcrumbMapHeaders
        [ div []
            [ button [ onClick (nextMsg ds token) ] [ text <| I18n.t Continue ]
            , materialTable token terms
            ]
        ]


viewRows : List Row -> List (Html a)
viewRows =
    List.map viewRow


viewRow : Row -> Html a
viewRow row =
    Table.tr [] (List.map viewRowEntry row)


viewRowEntry : Maybe String -> Html a
viewRowEntry re =
    Table.td [] [ text <| Maybe.withDefault "" re ]


materialTable : String -> Terms -> Html Msg
materialTable token terms =
    div [ class "terms__table" ]
        [ Table.table []
            [ Table.thead [] [ viewHeaders terms.headers, viewSelectors token terms ]
            , Table.tbody [] <| viewRows terms.rows
            ]
        ]


nextMsg : DataSources -> String -> Msg
nextMsg ds token =
    if List.length ds > 1 then
        ToDataSources token
    else
        ToResolver token


viewSelectors : String -> Terms -> Html Msg
viewSelectors token terms =
    Table.tr [] (List.map (viewSelector token terms) terms.headers)


viewSelector : String -> Terms -> Header -> Html Msg
viewSelector token terms header =
    Table.th []
        [ text <| I18n.t TermMatchWithHeader
        , br [] []
        , input
            [ list "terms"
            , id <| "term_" ++ toString header.id
            , value <| Maybe.withDefault "" header.term
            , onInput <| MapTerm token header.id
            , onChange <| MapTerm token header.id
            ]
            []
        , datalist [ id "terms" ] <| List.map dropDownEntry <| termValues terms
        , span
            [ class "delete-button"
            , onClick (MapTerm token header.id "")
            ]
            [ text <| I18n.t CloseButton ]
        ]


termValues : Terms -> List String
termValues terms =
    List.map .value <| filterTerms terms


filterTerms : Terms -> List Term
filterTerms terms =
    let
        collectTerms header xs =
            case header.term of
                Nothing ->
                    xs

                Just x ->
                    x :: xs

        headersTerms =
            List.foldr collectTerms [] terms.headers
    in
        List.filter (unusedTerm headersTerms) terms.workflowTerms


unusedTerm : List String -> Term -> Bool
unusedTerm headersTerms term =
    case headersTerms of
        [] ->
            True

        x :: xs ->
            if x == term.value then
                False
            else
                unusedTerm xs term


onInput : (String -> Msg) -> Attribute Msg
onInput msg =
    let
        isTerm term =
            if List.any (\t -> t == term || String.isEmpty term) allTermValues then
                J.succeed <| msg term
            else
                J.fail "Not known"
    in
        on "input" <| J.andThen isTerm targetValue


onChange : (String -> Msg) -> Attribute Msg
onChange msg =
    let
        isTerm term =
            if List.any (\t -> t == term || String.isEmpty term) allTermValues then
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
    Table.tr [] (List.map viewHeaderEntry headers)


viewHeaderEntry : Header -> Html Msg
viewHeaderEntry header =
    Table.th [ headerClass header ]
        [ text <|
            case header.term of
                Nothing ->
                    header.value

                Just term ->
                    I18n.t <| TermTranslationHeader header.value term
        ]


headerClass : Header -> Options.Property c m
headerClass header =
    case header.term of
        Nothing ->
            Options.cs "no_dwca"

        _ ->
            Options.cs "dwca"

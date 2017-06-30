module Resolver.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (style, alt, href)
import Html.Events exposing (onClick)
import Maybe exposing (withDefault)
import Terms.Models exposing (Terms)
import Target.Models exposing (DataSource)
import Resolver.Models
    exposing
        ( Resolver
        , Status(..)
        , Stats
        , Ingestion
        , Resolution
        , Matches
        )
import Resolver.Messages exposing (Msg(..))
import Resolver.Helper as RH
import Widgets.Slider as Slider
import Widgets.Pie as Pie


view : Resolver -> DataSource -> Terms -> Html Msg
view resolver ds terms =
    div []
        [ viewTitle resolver ds
        , viewIngestionStage resolver
        , viewResolutinStage resolver
        , viewGraph resolver
        , viewDownload resolver terms
        ]


viewTitle : Resolver -> DataSource -> Html Msg
viewTitle model ds =
    h3 []
        [ text <|
            "Crossmapping your file against \""
                ++ (withDefault "Unknown" ds.title)
                ++ "\" data"
        ]


viewIngestionStage : Resolver -> Html Msg
viewIngestionStage resolver =
    let
        ingStatus =
            case (RH.status resolver) of
                Pending ->
                    "Pending"

                InIngestion ->
                    "In Progress " ++ (eta resolver True)

                _ ->
                    "Done " ++ (timeSummary resolver True)
    in
        div []
            [ div []
                [ text <| "Ingestion Status: " ++ ingStatus
                ]
            , Slider.slider (ingestedSliderData resolver)
            ]


timeSummary : Resolver -> Bool -> String
timeSummary resolver isResolution =
    case resolver.stats of
        Nothing ->
            ""

        Just s ->
            let
                input =
                    timeEstInput s isResolution
            in
                RH.summaryString input resolver.stopTrigger


eta : Resolver -> Bool -> String
eta resolver isResolution =
    case resolver.stats of
        Nothing ->
            ""

        Just s ->
            RH.etaString <| RH.estimate <| timeEstInput s isResolution


timeEstInput : Stats -> Bool -> RH.Input
timeEstInput stats isResolution =
    if isResolution then
        RH.ingestionInput stats
    else
        RH.resolutionInput stats


ingestedSliderData : Resolver -> Slider.Datum
ingestedSliderData resolver =
    let
        datum =
            case (RH.status resolver) of
                Pending ->
                    ( 0, 1 )

                InIngestion ->
                    sliderData resolver InIngestion

                _ ->
                    ( 1.0, 1 )
    in
        (\( x, y ) -> Slider.Datum x y) datum


sliderData : Resolver -> Status -> ( Float, Float )
sliderData model st =
    let
        norm =
            (\( x, y ) -> ( (toFloat x) / (toFloat y), 1.0 ))
    in
        case st of
            InIngestion ->
                Tuple.first <| normalizedStats model

            InResolution ->
                Tuple.second <| normalizedStats model

            _ ->
                ( 0, 1 )


normalizedStats : Resolver -> ( ( Float, Float ), ( Float, Float ) )
normalizedStats resolver =
    case resolver.stats of
        Nothing ->
            ( ( 0, 1 ), ( 0, 1 ) )

        Just x ->
            harvestStats x.ingestion x.resolution x.totalRecords


harvestStats :
    Ingestion
    -> Resolution
    -> Int
    -> ( ( Float, Float ), ( Float, Float ) )
harvestStats i r t =
    let
        iPart =
            toFloat i.ingestedRecords

        rPart =
            toFloat r.resolvedRecords

        total =
            toFloat t
    in
        ( ( iPart, total ), ( rPart, total ) )


viewResolutinStage : Resolver -> Html Msg
viewResolutinStage resolver =
    let
        resStatus =
            case (RH.status resolver) of
                Pending ->
                    "Pendig"

                InIngestion ->
                    "Pending"

                InResolution ->
                    "In Progress " ++ (eta resolver False)

                _ ->
                    "Done " ++ (timeSummary resolver False)
    in
        div []
            [ div []
                [ text <| "ResolutionStatus: " ++ resStatus
                ]
            , Slider.slider (resolutionSliderData resolver)
            ]


resolutionSliderData : Resolver -> Slider.Datum
resolutionSliderData resolver =
    let
        datum =
            case (RH.status resolver) of
                Pending ->
                    ( 0, 1 )

                InIngestion ->
                    ( 0, 1 )

                InResolution ->
                    sliderData resolver InResolution

                _ ->
                    ( 1.0, 1.0 )
    in
        (\( x, y ) -> Slider.Datum x y) datum


viewGraph : Resolver -> Html Msg
viewGraph resolver =
    case (chartData resolver) of
        Nothing ->
            div [] [ Html.text "" ]

        Just m ->
            Pie.pie 200 m


chartData : Resolver -> Maybe Pie.PieData
chartData resolver =
    case resolver.stats of
        Nothing ->
            Nothing

        Just s ->
            let
                res =
                    List.filter (\( _, x, _ ) -> x > 0.05) <|
                        matchesList
                            s.totalRecords
                            s.matches
                            s.fails

                cd =
                    List.map
                        (\( x, y, z ) ->
                            Pie.PieDatum x y z
                        )
                        res
            in
                if (List.isEmpty cd) then
                    Nothing
                else
                    (Just cd)


matchesList :
    Int
    -> Matches
    -> Float
    -> List ( String, Float, String )
matchesList total matches fails =
    let
        m =
            matches
    in
        [ ( "#080", m.exactString, "Identical" )
        , ( "#0f0", m.exactCanonical, "Canonical match" )
        , ( "#8f0", m.fuzzy, "Fuzzy match" )
        , ( "#8f8", m.partial, "Partial match" )
        , ( "#888", m.partialFuzzy, "Partial fuzzy match" )
        , ( "#daa", m.genusOnly, "Genus-only match" )
        , ( "#000", fails, "Resolver Errors" )
        , ( "#a00", m.noMatch, "No match" )
        ]


viewDownload : Resolver -> Terms -> Html Msg
viewDownload resolver terms =
    case (RH.status resolver) of
        Done ->
            showOutput terms resolver.stopTrigger

        InResolution ->
            div
                [ style
                    [ ( "clear", "left" )
                    , ( "padding", "2em" )
                    ]
                ]
                [ button
                    [ onClick SendStopResolution ]
                    [ text "Cancel" ]
                , text " (with download of a partial result)"
                ]

        _ ->
            div [] []


showOutput : Terms -> Bool -> Html Msg
showOutput terms stopped =
    let
        msg =
            if (stopped) then
                "Download partial crossmapping results: "
            else
                "Download crossmapping results: "

        excelOutput =
            (String.slice 0 -3 terms.output) ++ "xlsx"
    in
        div
            [ style
                [ ( "clear", "left" )
                , ( "padding", "1em" )
                , ( "background-color", "#afa" )
                ]
            ]
            [ text msg
            , a
                [ href <| terms.output
                , alt "CSV file"
                , style
                    [ ( "color", "#22c" ) ]
                ]
                [ text "CSV" ]
            , text " "
            , a
                [ href <| excelOutput
                , alt "XSLX"
                , style
                    [ ( "color", "#22c" ) ]
                ]
                [ text "XSLX" ]
            ]

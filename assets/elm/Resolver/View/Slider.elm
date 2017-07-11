module Resolver.View.Slider
    exposing
        ( buildSlider
        , viewGraph
        )

import Html exposing (Html, div, text)
import Widgets.Slider as Slider
import Widgets.Pie as Pie
import Resolver.Models exposing (Resolution, Ingestion, ProgressMetadata(..), Matches, Stats(..), FailureCount(..), TotalRecordCount(..), ProcessedRecordCount(..), Resolver, totalRecordCount, metadataFromStats)
import Resolver.Helper as RH exposing (ResolverProgress(..))


type HexColor
    = HexColor String


type PieChartLegend
    = PieChartLegend HexColor Float String


buildSlider : ResolverProgress a -> Html b
buildSlider =
    Slider.slider << datumFromProgress


datumFromProgress : ResolverProgress a -> Slider.Datum
datumFromProgress progress =
    uncurry Slider.Datum <|
        case progress of
            Pending ->
                ( 0, 1 )

            InProgress { total, processed } ->
                let
                    (ProcessedRecordCount processed_) =
                        processed

                    (TotalRecordCount total_) =
                        total
                in
                    ( toFloat processed_, toFloat total_ )

            Complete _ ->
                ( 1, 1 )


renderNothing : Html a
renderNothing =
    text ""


viewGraph : Resolver -> Html a
viewGraph { stats } =
    Maybe.withDefault renderNothing <| Maybe.map chartData <| metadataFromStats stats


legendToDatum : PieChartLegend -> Pie.PieDatum
legendToDatum (PieChartLegend (HexColor color) value legend) =
    Pie.PieDatum color value legend


legendValueAboveMinimumThreshold : PieChartLegend -> Bool
legendValueAboveMinimumThreshold (PieChartLegend _ value _) =
    value > 0.05


chartData : ProgressMetadata -> Html a
chartData (ProgressMetadata matches (FailureCount fails) _ _) =
    let
        results =
            List.filter legendValueAboveMinimumThreshold
                [ PieChartLegend (HexColor "#080") matches.exactString "Identical"
                , PieChartLegend (HexColor "#0f0") matches.exactCanonical "Canonical match"
                , PieChartLegend (HexColor "#8f0") matches.fuzzy "Fuzzy match"
                , PieChartLegend (HexColor "#8f8") matches.partial "Partial match"
                , PieChartLegend (HexColor "#888") matches.partialFuzzy "Partial fuzzy match"
                , PieChartLegend (HexColor "#daa") matches.genusOnly "Genus-only match"
                , PieChartLegend (HexColor "#000") (toFloat fails) "Resolver Errors"
                , PieChartLegend (HexColor "#a00") matches.noMatch "No match"
                ]
    in
        if List.isEmpty results then
            renderNothing
        else
            Pie.pie 200 <| List.map legendToDatum results

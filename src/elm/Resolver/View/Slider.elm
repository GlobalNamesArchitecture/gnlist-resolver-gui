module Resolver.View.Slider
    exposing
        ( buildSlider
        , viewGraph
        )

import Html exposing (Html, text, div)
import Html.Attributes exposing (style)
import I18n exposing (Translation(..))
import Material.Progress as Loading
import Widgets.Pie as Pie
import Resolver.Models exposing (..)
import Resolver.Helper exposing (ResolverProgress(..))


type HexColor
    = HexColor String


type PieChartLegend
    = PieChartLegend HexColor MatchType


buildSlider : ResolverProgress a -> Html b
buildSlider =
    uncurry Loading.buffered << floatFromProgress


floatFromProgress : ResolverProgress a -> ( Float, Float )
floatFromProgress progress =
    case progress of
        Pending ->
            ( 0, 100 )

        InProgress { total, processed } ->
            let
                (ProcessedRecordCount processed_) =
                    processed

                (TotalRecordCount total_) =
                    total
            in
                ( 100 * toFloat processed_ / toFloat total_, 100 )

        Complete _ ->
            ( 100, 100 )


renderNothing : Html a
renderNothing =
    text ""


viewGraph : Resolver -> Html a
viewGraph { stats } =
    Maybe.withDefault renderNothing <| Maybe.map chartData <| metadataFromStats stats


legendToDatum : PieChartLegend -> Pie.PieDatum
legendToDatum (PieChartLegend (HexColor color) value) =
    Pie.PieDatum color (matchTypeValueToFloat value) (I18n.t <| PieChartLegendText value)


legendValueAboveMinimumThreshold : PieChartLegend -> Bool
legendValueAboveMinimumThreshold (PieChartLegend _ value) =
    matchTypeValueToFloat value > 0.05


chartData : ProgressMetadata -> Html a
chartData (ProgressMetadata matches (FailureCount fails) _ _ _) =
    let
        results =
            List.filter legendValueAboveMinimumThreshold
                [ PieChartLegend (HexColor "#080") (ExactStringMatch matches.exactString)
                , PieChartLegend (HexColor "#0f0") (ExactCanonicalMatch matches.exactCanonical)
                , PieChartLegend (HexColor "#ee0") (FuzzyMatch matches.fuzzy)
                , PieChartLegend (HexColor "#8f8") (PartialMatch matches.partial)
                , PieChartLegend (HexColor "#bb0") (PartialFuzzyMatch matches.partialFuzzy)
                , PieChartLegend (HexColor "#daa") (GenusOnlyMatch matches.genusOnly)
                , PieChartLegend (HexColor "#000") (ResolverErrorsMatch <| toFloat fails)
                , PieChartLegend (HexColor "#a00") (NoMatchMatch matches.noMatch)
                ]
    in
        if List.isEmpty results then
            renderNothing
        else
            div [ style [ ( "margin", "20px 10px 20px 10px" ) ] ] [ Pie.pie 200 <| List.map legendToDatum results ]

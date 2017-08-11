module Resolver.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (alt, href, style)
import I18n exposing (Translation(..))
import Material.Card as Card
import Material.Elevation as Elevation
import Material.Options as Options
import Terms.Models exposing (Terms)
import Target.Models exposing (DataSource)
import View.Layout exposing (contentWrapper, styledButton)
import Resolver.Models
    exposing
        ( Resolver
        , Stats(..)
        , Ingestion
        , Resolution
        , ProgressMetadata(..)
        , TotalRecordCount(..)
        , ExcelRowsCount(..)
        )
import Resolver.Messages exposing (Msg(..))
import Resolver.Helper
    exposing
        ( ResolverProgress(..)
        , ingestionResolverProgress
        , resolutionResolverProgress
        )
import Resolver.View.Slider exposing (buildSlider, viewGraph)


view : Resolver -> DataSource -> Terms -> Html Msg
view resolver ds terms =
    contentWrapper (ListMatchingHeader ds)
        ResolverDescription
        [ viewProgressCard resolver
        , viewDownload resolver terms
        ]


viewProgressCard : Resolver -> Html a
viewProgressCard resolver =
    Card.view
        [ Options.css "width" "550px"
        , Options.css "margin" "10px 0px 10px 0px"
        , Elevation.e2
        ]
        [ Card.media
            [ Options.css "background" "#fbfbfb"
            , Options.css "padding" "8px"
            ]
            [ viewIngestionStage <| ingestionResolverProgress resolver
            , viewResolutionStage <| resolutionResolverProgress resolver
            , viewGraph resolver
            ]
        ]


viewIngestionStage : ResolverProgress Ingestion -> Html a
viewIngestionStage resolverProgress =
    div [ style [ ( "margin", "15px 0px 15px 0px" ) ] ]
        [ text <| I18n.t IngestionStatus ++ " " ++ I18n.t (ResolverStatus resolverProgress)
        , buildSlider resolverProgress
        ]


viewResolutionStage : ResolverProgress Resolution -> Html a
viewResolutionStage resolverProgress =
    div [ style [ ( "margin", "15px 0px 15px 0px" ) ] ]
        [ div [] [ text <| I18n.t ResolutionStatus ++ " " ++ I18n.t (ResolverStatus resolverProgress) ]
        , buildSlider resolverProgress
        ]


viewDownload : Resolver -> Terms -> Html Msg
viewDownload ({ stats } as resolver) terms =
    case stats of
        Resolving _ _ _ ->
            cancelResolution

        BuildingExcel _ _ _ _ ->
            downloadOutputLinks terms resolver

        Done _ _ _ _ ->
            downloadOutputLinks terms resolver

        _ ->
            div [] []


downloadOutputLinks : Terms -> Resolver -> Html Msg
downloadOutputLinks terms { stopTrigger, stats } =
    let
        msg =
            if stopTrigger then
                I18n.t DownloadPartialMatching
            else
                I18n.t DownloadCompletedMatching

        csvOutput =
            terms.output
    in
        Card.view
            [ Options.css "width" "550px"
            , Options.css "margin-top" "30px"
            , Elevation.e4
            ]
            [ Card.title [] [ Card.head [] [ text msg ] ]
            , Card.media [ Options.css "padding" "10px" ]
                [ a
                    [ href csvOutput
                    , alt <| I18n.t DownloadText ++ " " ++ I18n.t CSVDownloadLink
                    , style
                        [ ( "color", "white" )
                        , ( "font-size", "1.2em" )
                        , ( "padding-right", "2em" )
                        ]
                    ]
                    [ text <| I18n.t CSVDownloadLink ]
                , xlsxView terms stats
                ]
            ]


xlsxView : Terms -> Stats -> Html Msg
xlsxView terms stats =
    let
        excelOutput =
            String.dropRight 3 terms.output ++ "xlsx"
    in
        case stats of
            BuildingExcel m _ _ _ ->
                excelProgress m

            _ ->
                a
                    [ href excelOutput
                    , alt <| I18n.t DownloadText ++ " " ++ I18n.t XLSXDownloadLink
                    , style [ ( "color", "white" ), ( "font-size", "1.2em" ) ]
                    ]
                    [ text <| I18n.t XLSXDownloadLink ]


excelProgress : ProgressMetadata -> Html Msg
excelProgress (ProgressMetadata _ _ total rows _) =
    span
        [ style
            [ ( "color", "white" )
            , ( "font-size", "1.2em" )
            ]
        ]
        [ text <|
            "XLSX building... ("
                ++ (toString <| excelPercentage total rows)
                ++ "%)"
        ]


excelPercentage : TotalRecordCount -> ExcelRowsCount -> Int
excelPercentage (TotalRecordCount total) (ExcelRowsCount rows) =
    truncate <| toFloat rows / toFloat total * 100


cancelResolution : Html Msg
cancelResolution =
    div
        []
        [ styledButton [] SendStopResolution CancelResolution
        , text <| " (" ++ I18n.t CancelResolutionInformation ++ ")"
        ]

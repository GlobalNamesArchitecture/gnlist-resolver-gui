module Resolver.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (alt, href, style)
import Html.Events exposing (onClick)
import I18n exposing (Translation(..))
import Material.Card as Card
import Material.Elevation as Elevation
import Material.Options as Options
import Terms.Models exposing (Terms)
import Target.Models exposing (DataSource)
import View.Layout exposing (contentWrapper)
import Resolver.Models
    exposing
        ( Resolver
        , Stats(..)
        , Ingestion
        , Resolution
        , Matches
        )
import Resolver.Messages exposing (Msg(..))
import Resolver.Helper exposing (ResolverProgress(..), ingestionResolverProgress, resolutionResolverProgress)
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
    Card.view [Options.css "width" "550px"
              , Options.css "margin" "10px 0px 10px 0px"
              , Elevation.e2]
    [Card.media [Options.css "background" "#fbfbfb"

              , Options.css "padding" "8px"
    ]
        [viewIngestionStage <| ingestionResolverProgress resolver
        , viewResolutionStage <| resolutionResolverProgress resolver
        , viewGraph resolver]]

viewIngestionStage : ResolverProgress Ingestion -> Html a
viewIngestionStage resolverProgress =
          div [style [("margin", "15px 0px 15px 0px")]] [ text <| I18n.t IngestionStatus ++ " " ++ I18n.t (ResolverStatus resolverProgress) 
        , buildSlider resolverProgress
        ]


viewResolutionStage : ResolverProgress Resolution -> Html a
viewResolutionStage resolverProgress =
    div [style [("margin", "15px 0px 15px 0px")]]
        [ div [] [ text <| I18n.t ResolutionStatus ++ " " ++ I18n.t (ResolverStatus resolverProgress) ]
        , buildSlider resolverProgress
        ]


viewDownload : Resolver -> Terms -> Html Msg
viewDownload ({ stats } as resolver) terms =
    case stats of
        Done _ _ _ _ ->
            downloadOutputLinks terms resolver

        Resolving _ _ _ ->
            cancelResolution

        _ ->
            div [] []


downloadOutputLinks : Terms -> Resolver -> Html Msg
downloadOutputLinks terms { stopTrigger } =
    let
        msg =
            if stopTrigger then
                I18n.t DownloadPartialMatching
            else
                I18n.t DownloadCompletedMatching

        csvOutput =
            terms.output

        excelOutput =
            String.dropRight 3 terms.output ++ "xlsx"
    in
        div
            []
            [ text msg
            , a
                [ href csvOutput
                , alt <| I18n.t DownloadText ++ " " ++ I18n.t CSVDownloadLink
                ]
                [ text <| I18n.t CSVDownloadLink ]
            , text " "
            , a
                [ href excelOutput
                , alt <| I18n.t DownloadText ++ " " ++ I18n.t XLSXDownloadLink
                ]
                [ text <| I18n.t XLSXDownloadLink ]
            ]


cancelResolution : Html Msg
cancelResolution =
    div
        []
        [ button
            [ onClick SendStopResolution ]
            [ text <| I18n.t CancelResolution ]
        , text <| " (" ++ I18n.t CancelResolutionInformation ++ ")"
        ]
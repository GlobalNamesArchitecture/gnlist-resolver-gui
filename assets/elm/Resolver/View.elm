module Resolver.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (style, alt, href)
import Html.Events exposing (onClick)
import Terms.Models exposing (Terms)
import Target.Models exposing (DataSource)
import Resolver.Models
    exposing
        ( Resolver
        , Stats(..)
        , Ingestion
        , Resolution
        , Matches
        )
import Resolver.Messages exposing (Msg(..))
import Resolver.Helper as RH exposing (ResolverProgress(..), ingestionResolverProgress, resolutionResolverProgress)
import Resolver.View.Slider exposing (..)


view : Resolver -> DataSource -> Terms -> Html Msg
view resolver ds terms =
    div []
        [ viewTitle ds
        , viewIngestionStage <| ingestionResolverProgress resolver
        , viewResolutionStage <| resolutionResolverProgress resolver
        , viewGraph resolver
        , viewDownload resolver terms
        ]


viewTitle : DataSource -> Html a
viewTitle { title } =
    h3 []
        [ text <|
            "Crossmapping your file against \""
                ++ Maybe.withDefault "Unknown" title
                ++ "\" data"
        ]


viewIngestionStage : ResolverProgress Ingestion -> Html a
viewIngestionStage resolverProgress =
    div []
        [ div [] [ text <| "Ingestion Status: " ++ resolverStatus resolverProgress ]
        , buildSlider resolverProgress
        ]


viewResolutionStage : ResolverProgress Resolution -> Html a
viewResolutionStage resolverProgress =
    div []
        [ div [] [ text <| "Resolution Status: " ++ resolverStatus resolverProgress ]
        , buildSlider resolverProgress
        ]


resolverStatus : ResolverProgress a -> String
resolverStatus resolverProgress =
    case resolverProgress of
        Pending ->
            "Pending"

        InProgress input ->
            "In Progress " ++ RH.etaString input

        Complete input ->
            "Done " ++ RH.summaryString input


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
                "Download partial crossmapping results: "
            else
                "Download crossmapping results: "

        csvOutput =
            terms.output

        excelOutput =
            String.dropRight 3 terms.output ++ "xlsx"
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
                [ href csvOutput
                , alt "CSV file"
                , style
                    [ ( "color", "#22c" ) ]
                ]
                [ text "CSV" ]
            , text " "
            , a
                [ href excelOutput
                , alt "XSLX"
                , style
                    [ ( "color", "#22c" ) ]
                ]
                [ text "XSLX" ]
            ]


cancelResolution : Html Msg
cancelResolution =
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

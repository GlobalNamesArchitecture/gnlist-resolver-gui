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
        [ viewTitle resolver ds
        , viewIngestionStage resolver (ingestionResolverProgress resolver)
        , viewResolutionStage resolver (resolutionResolverProgress resolver)
        , viewGraph resolver
        , viewDownload resolver terms
        ]


viewTitle : Resolver -> DataSource -> Html a
viewTitle model { title } =
    h3 []
        [ text <|
            "Crossmapping your file against \""
                ++ (withDefault "Unknown" title)
                ++ "\" data"
        ]


viewResolverProgress : ResolverProgress a -> (RH.Input -> String) -> (RH.Input -> String) -> String
viewResolverProgress resolverProgress inProgressFormatter completeFormatter =
    case resolverProgress of
        Pending ->
            "Pending"

        InProgress input ->
            "In Progress " ++ (inProgressFormatter input)

        Complete input ->
            "Done " ++ (completeFormatter input)


viewIngestionStage : Resolver -> ResolverProgress Ingestion -> Html a
viewIngestionStage ({ stopTrigger } as resolver) resolverProgress =
    let
        ingestionStatus =
            resolverStatus resolver resolverProgress
    in
        div []
            [ div [] [ text <| "Ingestion Status: " ++ ingestionStatus ]
            , buildSlider resolverProgress
            ]


viewResolutionStage : Resolver -> ResolverProgress Resolution -> Html a
viewResolutionStage ({ stopTrigger } as resolver) resolverProgress =
    let
        resolutionStatus =
            resolverStatus resolver resolverProgress
    in
        div []
            [ div [] [ text <| "Resolution Status: " ++ resolutionStatus ]
            , buildSlider resolverProgress
            ]


resolverStatus : Resolver -> ResolverProgress a -> String
resolverStatus { stopTrigger } resolverProgress =
    viewResolverProgress resolverProgress RH.etaString (RH.summaryString stopTrigger)


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

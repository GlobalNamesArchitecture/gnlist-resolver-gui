module Resolver.Helper
    exposing
        ( Input
        , ResolverProgress(..)
        , resolutionResolverProgress
        , ingestionResolverProgress
        , resolutionInput
        , ingestionInput
        , etaString
        , summaryString
        )

import Maybe exposing (withDefault, andThen)
import Resolver.Models exposing (Resolver, Resolution, Ingestion, Stats(..), ProgressMetadata(..), TotalRecordCount(..), ProcessedRecordCount(..))
import TimeDuration.Model exposing (..)


type alias Input =
    { total : TotalRecordCount, processed : ProcessedRecordCount, timeSpan : Seconds, velocity : List Velocity }


type alias Velocity =
    { recordsNum : ProcessedRecordCount, timeSpan : Seconds }


type alias Estimate =
    { namesPerSec : Float, eta : TimeDuration }


estimate : Input -> Estimate
estimate ({ total, velocity, processed } as input) =
    let
        namesPerSec =
            normalizeVelocity velocity

        (TotalRecordCount total_) =
            total

        (ProcessedRecordCount processed_) =
            processed

        eta =
            timeToSeconds <|
                (toFloat (total_ - processed_))
                    / namesPerSec
    in
        Estimate namesPerSec (secondsToTimeDuration eta)


etaString : Input -> String
etaString input =
    let
        { namesPerSec, eta } =
            estimate input
    in
        "("
            ++ toString (floor namesPerSec)
            ++ " names/sec, Est. wait: "
            ++ waitTimeToString eta
            ++ ")"


hoursToString : Hours -> String
hoursToString (Hours h) =
    toString h ++ "h"


minutesToString : Minutes -> String
minutesToString (Minutes m) =
    toString m ++ "m"


secondsToString : Seconds -> String
secondsToString (Seconds s) =
    toString s ++ "s"


waitTimeToString : TimeDuration -> String
waitTimeToString (TimeDuration h m s) =
    String.join ", " [ hoursToString h, minutesToString m, secondsToString s ]


summaryString : Bool -> Input -> String
summaryString stopped { timeSpan, total, processed } =
    let
        hms =
            secondsToTimeDuration timeSpan

        (TotalRecordCount total_) =
            total

        (ProcessedRecordCount processed_) =
            processed

        processedCount =
            if stopped then
                processed_
            else
                total_
    in
        "("
            ++ "Processed "
            ++ toString processedCount
            ++ " names in "
            ++ waitTimeToString hms
            ++ ")"


ingestionInput : ProgressMetadata -> Ingestion -> Maybe Resolution -> Input
ingestionInput (ProgressMetadata _ _ totalRecords _) ingestion mresolution =
    let
        processed =
            ingestion.ingestedRecords

        timeSpent =
            case mresolution of
                Nothing ->
                    ingestion.ingestionSpan

                Just resolution ->
                    timeToSeconds <| resolution.resolutionStart - ingestion.ingestionStart

        vel =
            [ Velocity processed ingestion.ingestionSpan ]
    in
        Input totalRecords processed timeSpent vel


resolutionInput : ProgressMetadata -> Resolution -> Maybe Float -> Input
resolutionInput (ProgressMetadata _ _ totalRecords lastBatchesTime) resolution resolutionStop =
    let
        processed =
            resolution.resolvedRecords

        timeSpan =
            case resolutionStop of
                Nothing ->
                    resolution.resolutionSpan

                Just stop ->
                    timeToSeconds <| stop - resolution.resolutionStart

        expectedProcessCountPerSecond =
            ProcessedRecordCount 200

        vel =
            List.map (Velocity expectedProcessCountPerSecond) lastBatchesTime
    in
        Input totalRecords processed timeSpan vel


resSpan : Float -> List Float -> Maybe Float
resSpan resolutionStop lastBatchesTime =
    List.maximum <| resolutionStop :: lastBatchesTime


occurrencesPerSecond : ProcessedRecordCount -> Seconds -> Float
occurrencesPerSecond (ProcessedRecordCount occurrences) (Seconds s) =
    toFloat occurrences / s


velocityOccurrencesPerSecond : Velocity -> Float
velocityOccurrencesPerSecond { recordsNum, timeSpan } =
    occurrencesPerSecond recordsNum timeSpan


normalizeVelocity : List Velocity -> Float
normalizeVelocity vs =
    average <| List.map velocityOccurrencesPerSecond vs


average : List Float -> Float
average xs =
    List.sum xs / (toFloat <| List.length xs)


type ResolverProgress a
    = Pending
    | InProgress Input
    | Complete Input


ingestionResolverProgress : Resolver -> ResolverProgress Ingestion
ingestionResolverProgress { stats } =
    case stats of
        Unknown ->
            Pending

        NoStatsReceived ->
            Pending

        PendingResolution _ ->
            Pending

        Ingesting metadata ingestion ->
            InProgress <| ingestionInput metadata ingestion Nothing

        Resolving metadata ingestion resolution ->
            Complete <| ingestionInput metadata ingestion (Just resolution)

        BuildingExcel metadata ingestion resolution _ ->
            Complete <| ingestionInput metadata ingestion (Just resolution)

        Done metadata ingestion resolution _ ->
            Complete <| ingestionInput metadata ingestion (Just resolution)


resolutionResolverProgress : Resolver -> ResolverProgress Resolution
resolutionResolverProgress { stats } =
    case stats of
        Unknown ->
            Pending

        NoStatsReceived ->
            Pending

        PendingResolution _ ->
            Pending

        Ingesting _ _ ->
            Pending

        Resolving metadata _ resolution ->
            InProgress <| resolutionInput metadata resolution Nothing

        BuildingExcel metadata _ resolution stop ->
            Complete <| resolutionInput metadata resolution (Just stop)

        Done metadata _ resolution stop ->
            Complete <| resolutionInput metadata resolution (Just stop)

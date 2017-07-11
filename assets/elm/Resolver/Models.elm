module Resolver.Models exposing (..)

import Errors exposing (Errors)
import Time exposing (Time)
import TimeDuration.Model exposing (Seconds)


type alias Resolver =
    { stopTrigger : Bool
    , stats : Stats
    , errors : Errors
    }


type FailureCount
    = FailureCount Int


type TotalRecordCount
    = TotalRecordCount Int


type ProcessedRecordCount
    = ProcessedRecordCount Int


type ProgressMetadata
    = ProgressMetadata Matches FailureCount TotalRecordCount (List Seconds)


totalRecordCount : ProgressMetadata -> TotalRecordCount
totalRecordCount (ProgressMetadata _ _ i _) =
    i


metadataFromStats : Stats -> Maybe ProgressMetadata
metadataFromStats stats =
    case stats of
        Unknown ->
            Nothing

        NoStatsReceived ->
            Nothing

        PendingResolution m ->
            Just m

        Ingesting m _ ->
            Just m

        Resolving m _ _ ->
            Just m

        BuildingExcel m _ _ _ ->
            Just m

        Done m _ _ _ ->
            Just m


type Stats
    = Unknown
    | NoStatsReceived
    | PendingResolution ProgressMetadata
    | Ingesting ProgressMetadata Ingestion
    | Resolving ProgressMetadata Ingestion Resolution
    | BuildingExcel ProgressMetadata Ingestion Resolution Float
    | Done ProgressMetadata Ingestion Resolution Float


type alias Ingestion =
    { ingestedRecords : ProcessedRecordCount
    , ingestionStart : Time
    , ingestionSpan : Seconds
    }


type alias Resolution =
    { resolvedRecords : ProcessedRecordCount
    , resolutionStart : Time
    , resolutionSpan : Seconds
    }


type alias Matches =
    { noMatch : Float
    , exactString : Float
    , exactCanonical : Float
    , fuzzy : Float
    , partial : Float
    , partialFuzzy : Float
    , genusOnly : Float
    }


initResolver : Resolver
initResolver =
    Resolver False NoStatsReceived Nothing

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


type ExcelRowsCount
    = ExcelRowsCount Int


type ProgressMetadata
    = ProgressMetadata Matches FailureCount TotalRecordCount ExcelRowsCount (List Seconds)


totalRecordCount : ProgressMetadata -> TotalRecordCount
totalRecordCount (ProgressMetadata _ _ i _ _) =
    i


excelRowsCount : ProgressMetadata -> ExcelRowsCount
excelRowsCount (ProgressMetadata _ _ _ i _) =
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
            Just <| m

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
    { noMatch : NoMatch
    , exactString : ExactString
    , exactCanonical : ExactCanonical
    , fuzzy : Fuzzy
    , partial : Partial
    , partialFuzzy : PartialFuzzy
    , genusOnly : GenusOnly
    }


type MatchType
    = NoMatchMatch NoMatch
    | ExactStringMatch ExactString
    | ExactCanonicalMatch ExactCanonical
    | FuzzyMatch Fuzzy
    | PartialMatch Partial
    | PartialFuzzyMatch PartialFuzzy
    | GenusOnlyMatch GenusOnly
    | ResolverErrorsMatch Float


type NoMatch
    = NoMatch Float


type ExactString
    = ExactString Float


type ExactCanonical
    = ExactCanonical Float


type Fuzzy
    = Fuzzy Float


type Partial
    = Partial Float


type PartialFuzzy
    = PartialFuzzy Float


type GenusOnly
    = GenusOnly Float


initResolver : Resolver
initResolver =
    Resolver False NoStatsReceived Nothing


matchTypeValueToFloat : MatchType -> Float
matchTypeValueToFloat matchType =
    case matchType of
        NoMatchMatch (NoMatch v) ->
            v

        ExactStringMatch (ExactString v) ->
            v

        ExactCanonicalMatch (ExactCanonical v) ->
            v

        FuzzyMatch (Fuzzy v) ->
            v

        PartialMatch (Partial v) ->
            v

        PartialFuzzyMatch (PartialFuzzy v) ->
            v

        GenusOnlyMatch (GenusOnly v) ->
            v

        ResolverErrorsMatch v ->
            v

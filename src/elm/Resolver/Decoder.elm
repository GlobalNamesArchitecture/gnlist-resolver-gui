module Resolver.Decoder exposing (statsAndErrorsDecoder)

import Json.Decode exposing (..)
import Time exposing (Time)
import Errors exposing (Errors, Error)
import Resolver.Models exposing (..)
import TimeDuration.Model exposing (..)


statsAndErrorsDecoder : Decoder ( Stats, Errors )
statsAndErrorsDecoder =
    oneOf
        [ notStartedDecoder
        , existingStatsAndErrorsDecoder
        ]


existingStatsAndErrorsDecoder : Decoder ( Stats, Errors )
existingStatsAndErrorsDecoder =
    map2 (,) statsDecoder errors


notStartedDecoder : Decoder ( Stats, Errors )
notStartedDecoder =
    null ( NotStarted, Nothing )


statsDecoder : Decoder Stats
statsDecoder =
    field "status" string
        |> andThen statusToStatsDecoder


statusToStatsDecoder : String -> Decoder Stats
statusToStatsDecoder status =
    case (Debug.log "status" status) of
        "init" ->
            map PendingResolution progressMetadataDecoder

        "ingestion" ->
            map2 Ingesting progressMetadataDecoder ingestionDecoder

        "resolution" ->
            map3 Resolving progressMetadataDecoder ingestionDecoder resolutionDecoder

        "finish" ->
            map4 BuildingExcel progressMetadataDecoder ingestionDecoder resolutionDecoder resolutionStopDecoder

        "done" ->
            map4 Done progressMetadataDecoder ingestionDecoder resolutionDecoder resolutionStopDecoder

        _ ->
            succeed Unknown


progressMetadataDecoder : Decoder ProgressMetadata
progressMetadataDecoder =
    map4 ProgressMetadata
        matches
        failureCountDecoder
        totalRecordCountDecoder
        excelRowCountDecoder


failureCountDecoder : Decoder FailureCount
failureCountDecoder =
    map (FailureCount << round) (at [ "matches", "ErrorInMatch" ] float)


totalRecordCountDecoder : Decoder TotalRecordCount
totalRecordCountDecoder =
    map TotalRecordCount (at [ "total_records" ] int)


excelRowCountDecoder : Decoder ExcelRowsCount
excelRowCountDecoder =
    map ExcelRowsCount (at [ "excel_rows" ] int)


ingestionDecoder : Decoder Ingestion
ingestionDecoder =
    map3 Ingestion
        (at [ "ingested_records" ] processedRecordCountDecoder)
        (at [ "ingestion_start" ] timeDecoder)
        (at [ "ingestion_span" ] secondsDecoder)


resolutionDecoder : Decoder Resolution
resolutionDecoder =
    map5 Resolution
        (at [ "resolution", "completed_records" ] processedRecordCountDecoder)
        (at [ "resolution", "start_time" ] timeDecoder)
        (at [ "resolution", "time_span" ] secondsDecoder)
        (at [ "resolution", "speed" ] speedDecoder)
        (at [ "resolution", "eta" ] secondsDecoder)


processedRecordCountDecoder : Decoder ProcessedRecordCount
processedRecordCountDecoder =
    map ProcessedRecordCount int



--PRIVATE


errors : Decoder Errors
errors =
    map
        (\l ->
            if List.length l == 0 then
                Nothing
            else
                Just l
        )
    <|
        field "errors" <|
            list error


error : Decoder Error
error =
    map (Error "A problem with the CSV content") string


lastBatchesTimeDecoder : Decoder (List Seconds)
lastBatchesTimeDecoder =
    at [ "last_batches_time" ] (list secondsDecoder)


matches : Decoder Matches
matches =
    map7 Matches
        (at [ "matches", "EmptyMatch" ] <| map NoMatch float)
        (at [ "matches", "ExactNameMatchByUUID" ] <| map ExactString float)
        (at [ "matches", "ExactCanonicalNameMatchByUUID" ] <|
            map ExactCanonical float
        )
        (at [ "matches", "FuzzyCanonicalMatch" ] <| map Fuzzy float)
        (at [ "matches", "ExactPartialMatch" ] <| map Partial float)
        (at [ "matches", "FuzzyPartialMatch" ] <| map PartialFuzzy float)
        (at [ "matches", "ExactMatchPartialByGenus" ] <| map GenusOnly float)


resolutionStopDecoder : Decoder Float
resolutionStopDecoder =
    at [ "resolution", "stop_time" ] timeDecoder


timeDecoder : Decoder Time
timeDecoder =
    float


secondsDecoder : Decoder Seconds
secondsDecoder =
    map Seconds float


speedDecoder : Decoder NamesPerSecond
speedDecoder =
    map NamesPerSecond float

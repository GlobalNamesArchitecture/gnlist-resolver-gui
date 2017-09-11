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
    case status of
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
    map5 ProgressMetadata
        matches
        failureCountDecoder
        totalRecordCountDecoder
        excelRowCountDecoder
        lastBatchesTimeDecoder


failureCountDecoder : Decoder FailureCount
failureCountDecoder =
    map (FailureCount << round) (at [ "matches", "7" ] float)


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
    map3 Resolution
        (at [ "resolved_records" ] processedRecordCountDecoder)
        (at [ "resolution_start" ] timeDecoder)
        (at [ "resolution_span" ] secondsDecoder)


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
        (at [ "matches", "0" ] <| map NoMatch float)
        (at [ "matches", "1" ] <| map ExactString float)
        (at [ "matches", "2" ] <| map ExactCanonical float)
        (at [ "matches", "3" ] <| map Fuzzy float)
        (at [ "matches", "4" ] <| map Partial float)
        (at [ "matches", "5" ] <| map PartialFuzzy float)
        (at [ "matches", "6" ] <| map GenusOnly float)


resolutionStopDecoder : Decoder Float
resolutionStopDecoder =
    at [ "resolution_stop" ] float


timeDecoder : Decoder Time
timeDecoder =
    float


secondsDecoder : Decoder Seconds
secondsDecoder =
    map Seconds float

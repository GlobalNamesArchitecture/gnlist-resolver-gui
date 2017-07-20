module I18n exposing (Translation(..), t)

import Filesize
import TimeDuration.Model exposing (..)
import FileUpload.Models exposing (Bytes(..), FileName(..))
import Target.Models exposing (DataSource)
import Resolver.Helper exposing (ResolverProgress(..), Input)
import Resolver.Models exposing (ProcessedRecordCount(..), MatchType(..))


type Translation a
    = UploadFileSize Bytes
    | UploadFileName FileName
    | UploadSelection
    | UploadStarted
    | UploadFailed
    | UploadSuccessful
    | UploadContinue
    | UploadInProgress Int
    | UploadComplete
    | JavaScriptFileUploadUnsupported
    | Continue
    | BreadcrumbUploadFile
    | BreadcrumbMapHeaders
    | BreadcrumbPickReferenceData
    | BreadcrumbListMatcherNames
    | TermMatchWithHeader
    | CloseButton
    | TermTranslationHeader String String
    | ListMatchingHeader DataSource
    | IngestionStatus
    | ResolutionStatus
    | ResolverStatus (ResolverProgress a)
    | DownloadPartialMatching
    | DownloadCompletedMatching
    | CSVDownloadLink
    | XLSXDownloadLink
    | DownloadText
    | CancelResolution
    | CancelResolutionInformation
    | PieChartLegendText MatchType
    | SearchPlaceholder
    | NoErrors
    | DismissErrors
    | RouteNotFound
    | MITLicense
    | Version
    | ApplicationName
    | HomeLinkText
    | UnknownTranslation


t : Translation a -> String
t translation =
    case translation of
        UploadFileSize size ->
            "File size: " ++ formattedFileSize size

        UploadFileName (FileName fileName) ->
            fileName

        UploadSelection ->
            "Please select a CSV file to upload."

        UploadStarted ->
            "Upload started."

        UploadComplete ->
            "File uploaded; waiting for response."

        UploadFailed ->
            "Upload failed."

        UploadSuccessful ->
            "Upload successful."

        UploadContinue ->
            "Continue"

        UploadInProgress percentageComplete ->
            "Progress: " ++ toString percentageComplete ++ "%"

        JavaScriptFileUploadUnsupported ->
            "JavaScript-based file upload is not supported; please switch to a more modern browser."

        Continue ->
            "Continue"

        BreadcrumbUploadFile ->
            "Upload a File"

        BreadcrumbMapHeaders ->
            "Map Headers"

        BreadcrumbPickReferenceData ->
            "Pick Reference Data"

        BreadcrumbListMatcherNames ->
            "Match Names"

        TermMatchWithHeader ->
            "match with"

        CloseButton ->
            "✖"

        TermTranslationHeader from to ->
            from ++ " → " ++ to

        ListMatchingHeader { title } ->
            "Matching names from your file against \""
                ++ Maybe.withDefault "Unknown" title
                ++ "\" data"

        IngestionStatus ->
            "Ingestion Status:"

        ResolutionStatus ->
            "Resolution Status:"

        ResolverStatus resolverProgress ->
            case resolverProgress of
                Pending ->
                    "Pending"

                InProgress input ->
                    "In Progress " ++ etaString input

                Complete input ->
                    "Done " ++ summaryString input

        DownloadPartialMatching ->
            "Download partial name-matching results: "

        DownloadCompletedMatching ->
            "Download name-matching results: "

        CSVDownloadLink ->
            "CSV"

        XLSXDownloadLink ->
            "XLSX"

        DownloadText ->
            "Download"

        CancelResolution ->
            "Cancel"

        CancelResolutionInformation ->
            "with download of a partial result"

        PieChartLegendText matchType ->
            showMatchType matchType

        SearchPlaceholder ->
            "Search"

        NoErrors ->
            "No errors"

        DismissErrors ->
            "OK"

        RouteNotFound ->
            "404 Not found"

        MITLicense ->
            "MIT License"

        Version ->
            "Version"

        ApplicationName ->
            "Global Names List Resolver"

        HomeLinkText ->
            "Home"

        UnknownTranslation ->
            ""


formattedFileSize : Bytes -> String
formattedFileSize (Bytes size) =
    Filesize.format size


etaString : Input -> String
etaString { estimate } =
    let
        { namesPerSec, eta } =
            estimate
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


summaryString : Input -> String
summaryString { timeSpan, processed } =
    let
        hms =
            secondsToTimeDuration timeSpan

        (ProcessedRecordCount processed_) =
            processed
    in
        "("
            ++ "Processed "
            ++ toString processed_
            ++ " names in "
            ++ waitTimeToString hms
            ++ ")"


showMatchType : MatchType -> String
showMatchType matchType =
    case matchType of
        ExactStringMatch _ ->
            "Identical"

        ExactCanonicalMatch _ ->
            "Canonical match"

        FuzzyMatch _ ->
            "Fuzzy match"

        PartialMatch _ ->
            "Partial match"

        PartialFuzzyMatch _ ->
            "Partial fuzzy match"

        GenusOnlyMatch _ ->
            "Genus-only match"

        ResolverErrorsMatch _ ->
            "Resolver Errors"

        NoMatchMatch _ ->
            "No match"

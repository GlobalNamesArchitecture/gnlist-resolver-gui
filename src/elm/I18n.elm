module I18n exposing (Translation(..), t)

import Filesize
import TimeDuration.Model exposing (..)
import FileUpload.Models exposing (Bytes(..), FileName(..))
import Target.Models exposing (DataSource)
import Resolver.Helper
    exposing
        ( ResolverProgress(..)
        , ExcelProgress(..)
        , Input
        , ResolutionInput
        )
import Resolver.Models
    exposing
        ( ProcessedRecordCount(..)
        , MatchType(..)
        , NamesPerSecond(..)
        )


type Translation a
    = ApplicationName
    | BreadcrumbListMatcherNames
    | BreadcrumbMapHeaders
    | BreadcrumbPickReferenceData
    | BreadcrumbUploadFile
    | CSVDownloadLink
    | CancelResolution
    | CancelResolutionInformation
    | CloseButton
    | Continue
    | DismissErrors
    | DownloadCompletedMatching
    | DownloadPartialMatching
    | DownloadText
    | ExcelBuildingStatus (ExcelProgress a)
    | HelpLinkText
    | HomeLinkText
    | IngestionStatus
    | JavaScriptFileUploadUnsupported
    | ListMatchingHeader DataSource
    | MITLicense
    | MapDescription
    | NoErrors
    | PickReferenceDataDescription
    | PieChartLegendText MatchType
    | ResolutionStatus
    | ResolverDescription
    | ResolverStatus (ResolverProgress a)
    | RouteNotFound
    | SearchPlaceholder
    | TermMatchWithHeader
    | TermTranslationHeader String String
    | UnknownTranslation
    | UploadComplete
    | UploadContinue
    | UploadFailed
    | UploadFileDescription
    | UploadFileName FileName
    | UploadFileSize Bytes
    | UploadInProgress Int
    | UploadSelection
    | UploadStarted
    | UploadSuccessful
    | Version
    | XLSXDownloadLink


t : Translation a -> String
t translation =
    case translation of
        UploadFileSize size ->
            "File size: " ++ formattedFileSize size

        UploadFileName (FileName fileName) ->
            fileName

        UploadSelection ->
            "Upload CSV"

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
            "JavaScript-based file upload is not supported; "
                ++ "please switch to a more modern browser."

        Continue ->
            "Continue"

        BreadcrumbUploadFile ->
            "Upload a CSV File With Scientific Names"

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

        ResolverStatus Pending ->
            "Pending"

        ResolverStatus (InProgress input) ->
            "In Progress " ++ etaString input

        ResolverStatus (ResolutionComplete input) ->
            "Done " ++ resolutionSummaryString input

        ResolverStatus (ResolutionInProgress input) ->
            "In Progress " ++ resolutionEtaString input

        ResolverStatus (Complete input) ->
            "Done " ++ summaryString input

        DownloadPartialMatching ->
            "Download partial name-matching results: "

        DownloadCompletedMatching ->
            "Download name-matching results: "

        ExcelBuildingStatus _ ->
            "Excel Building"

        CSVDownloadLink ->
            "CSV file"

        XLSXDownloadLink ->
            "XLSX file"

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
            "Scientific Names List Resolver"

        HelpLinkText ->
            "Help"

        HomeLinkText ->
            "Home"

        UnknownTranslation ->
            ""

        UploadFileDescription ->
            """
This app compares your list of scientific names with other datasets.
For a successful matching of names make sure that your CSV file meets the
following requirements:

**CSV Headers Format:** Corresponds to one of the
[examples](https://github.com/GlobalNamesArchitecture/gnlist-resolver-gui/wiki/Help#input-file-format)

**Encoding:** UTF-8

**CSV field separator:** comma, semicolon, tab (, ; \\t)
"""

        ResolverDescription ->
            """
When the process is complete you will be able to download results of the
name matching.
            """

        MapDescription ->
            """
Green headers show terms that were recognized automatically. You can
manually change the mapping of terms by manual editing.

There are two mutually exlusive approches. In one scientific names are given
in one field and mapped to a **scientificName** term, or they can be
split into **genus**, **species**, **scientificNameAuthorship** etc.

Each term can happen only once and is removed from available terms list if
it is already used.  White-colored headers will be ignored during comparison.
            """

        PickReferenceDataDescription ->
            """
Choose a data source to match your names against
            """


formattedFileSize : Bytes -> String
formattedFileSize (Bytes size) =
    Filesize.format size


etaString : Input -> String
etaString { estimate } =
    let
        { namesPerSec, eta } =
            estimate

        (NamesPerSecond speed) =
            namesPerSec
    in
        "("
            ++ toString (floor speed)
            ++ " names/sec, Est. wait: "
            ++ waitTimeToString eta
            ++ ")"


resolutionEtaString : ResolutionInput -> String
resolutionEtaString { estimate } =
    let
        { namesPerSec, eta } =
            estimate

        (NamesPerSecond speed) =
            namesPerSec
    in
        "("
            ++ toString (floor speed)
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


resolutionSummaryString : ResolutionInput -> String
resolutionSummaryString { timeSpan, processed } =
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

        NoMatchMatch _ ->
            "No match"

        ResolverErrorsMatch _ ->
            "Resolver Errors"

module FileUpload.View exposing (view)

import Html exposing (..)
import Html.Attributes
    exposing
        ( action
        , method
        , enctype
        , type_
        , id
        , value
        , name
        , hidden
        , class
        , classList
        )
import Html.Events exposing (on, onClick)
import Material.Icon as Icon
import Material.Card as Card
import Material.Color as Color
import Json.Decode as JD
import Material.Progress as Loading
import View.Layout exposing (contentWrapper)
import I18n exposing (Translation(..))
import FileUpload.Models exposing (Upload, File, Token(..), Bytes(..), UploadProgress(..), progressToCompletionPercent)
import FileUpload.Messages exposing (Msg(..))


view : Upload -> Html Msg
view upload =
    contentWrapper BreadcrumbUploadFile [ formUpload upload ]


type UploadStatus
    = NoFileProvided
    | FileProvided File
    | FileUploadInProgress File
    | FileUploadSucceeded File Token


fileUploadStatus : Upload -> UploadStatus
fileUploadStatus upload =
    case upload.file of
        Nothing ->
            NoFileProvided

        Just file ->
            case upload.progress of
                NotStarted ->
                    FileProvided file

                Succeeded token ->
                    FileUploadSucceeded file token

                _ ->
                    FileUploadInProgress file


formUpload : Upload -> Html Msg
formUpload upload =
    form
        [ action "/upload"
        , method "post"
        , enctype "multipart/form-data"
        , id "form-upload"
        ]
        [ div [ classList [ ( "none", fileUploadStatus upload /= NoFileProvided ) ] ] [ fileInput upload.id ]
        , formContents upload
        ]


formContents : Upload -> Html Msg
formContents upload =
    let
        cardTitle file =
            Card.title [] [ Card.head [] [ text <| I18n.t (UploadFileName file.fileName) ] ]

        cardBody file =
            Card.text []
                [ text <| I18n.t (UploadFileSize file.size)
                ]

        cardStatus =
            Card.text []
                [ uploadStatus upload
                ]
    in
        case fileUploadStatus upload of
            NoFileProvided ->
                renderNothing

            FileProvided file ->
                Card.view [ Color.background (Color.color Color.Grey Color.S300) ]
                    [ cardTitle file
                    , cardBody file
                    , Card.actions
                        [ Card.border ]
                        [ uploadButton upload.isSupported upload.file ]
                    ]

            FileUploadInProgress file ->
                Card.view []
                    [ cardTitle file
                    , cardBody file
                    , cardStatus
                    ]

            FileUploadSucceeded _ _ ->
                renderNothing


uploadButton : Bool -> Maybe File -> Html Msg
uploadButton isWorking file =
    let
        disableUpload =
            case file of
                Nothing ->
                    hidden True

                Just _ ->
                    hidden False
    in
        if isWorking then
            input
                [ id "upload-button"
                , type_ "button"
                , value <| I18n.t UploadContinue
                , disableUpload
                , onClick FileUpload
                ]
                []
        else
            p []
                [ text <| I18n.t JavaScriptFileUploadUnsupported ]


fileInput : String -> Html Msg
fileInput nodeId =
    div []
        [ label []
            [ Icon.i "file_upload"
            , input
                [ id nodeId
                , name nodeId
                , class "none"
                , type_ "file"
                , on "change" (JD.succeed FileSelected)
                ]
                []
            ]
        , text <| I18n.t UploadSelection
        ]


renderNothing : Html a
renderNothing =
    text ""


uploadStatus : Upload -> Html a
uploadStatus model =
    case model.progress of
        Started ->
            div [] [ text <| I18n.t UploadStarted, Loading.progress 0 ]

        Complete ->
            div [] [ text <| I18n.t UploadComplete, Loading.indeterminate ]

        Loading _ _ ->
            uploadProgress model

        NotStarted ->
            renderNothing

        Failed _ ->
            p [] [ text <| I18n.t UploadFailed ]

        Succeeded _ ->
            p [] [ text <| I18n.t UploadSuccessful ]


uploadProgress : Upload -> Html a
uploadProgress model =
    case progressToCompletionPercent model.progress of
        Just percentage ->
            div [] [ text <| I18n.t (UploadInProgress percentage), Loading.progress <| toFloat percentage ]

        Nothing ->
            renderNothing

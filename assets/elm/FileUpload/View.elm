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
        )
import Html.Events exposing (on, onClick)
import I18n exposing (Translation(..))
import Json.Decode as JD
import FileUpload.Models exposing (Upload, File, Bytes(..), UploadProgress(..), progressToCompletionPercent)
import FileUpload.Messages exposing (Msg(..))


view : Upload -> Html Msg
view upload =
    formUpload upload


formUpload : Upload -> Html Msg
formUpload upload =
    form
        [ action "/upload"
        , method "post"
        , enctype "multipart/form-data"
        , id "form-upload"
        ]
        [ fileInput upload.id
        , uploadButton upload.isSupported upload.file
        , fileDetails upload.file
        , uploadStatus upload
        ]


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
                , value "Upload"
                , disableUpload
                , onClick FileUpload
                ]
                []
        else
            p []
                [ text <| I18n.t JavaScriptFileUploadUnsupported ]


fileInput : String -> Html Msg
fileInput nodeId =
    input
        [ id nodeId
        , name nodeId
        , type_ "file"
        , on "change" (JD.succeed FileSelected)
        ]
        []


fileDetails : Maybe File -> Html Msg
fileDetails file =
    case file of
        Nothing ->
            renderNothing

        Just f ->
            p [] [ text <| I18n.t (UploadFileSize f.size) ]


renderNothing : Html a
renderNothing =
    text ""


uploadStatus : Upload -> Html a
uploadStatus model =
    case model.progress of
        Started ->
            div [] [ text <| I18n.t UploadStarted ]

        Complete ->
            div [] [ text <| I18n.t UploadComplete ]

        Loading _ _ ->
            uploadProgress model

        NotStarted ->
            renderNothing

        Failed _ ->
            div [] [ text <| I18n.t UploadFailed ]

        Succeeded _ ->
            div [] [ text <| I18n.t UploadSuccessful ]


uploadProgress : Upload -> Html a
uploadProgress model =
    case progressToCompletionPercent model.progress of
        Just percentage ->
            div [] [ text <| I18n.t (UploadInProgress percentage) ]

        Nothing ->
            renderNothing

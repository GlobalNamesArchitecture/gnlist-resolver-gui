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
import Json.Decode as JD
import FileUpload.Models exposing (Upload, File)
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
        , uploadStats
        , uploadProgress
        , uploadResults
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
                [ text <|
                    "JavaScript-based file upload is not supported, "
                        ++ "please switch to a more modern browser."
                ]


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
            span [] []

        Just f ->
            p [] [ text <| "File size: " ++ (toString f.size) ++ " bytes" ]


uploadStats : Html Msg
uploadStats =
    div [ id "upload-status" ] []


uploadProgress : Html Msg
uploadProgress =
    div [ id "progress" ] []


uploadResults : Html Msg
uploadResults =
    div [ id "result" ] []

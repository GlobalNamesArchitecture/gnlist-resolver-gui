port module FileUpload.Ports exposing (..)

import FileUpload.Models exposing (JsonFile)


port isUploadSupported : () -> Cmd msg


port uploadIsSupported : (Bool -> msg) -> Sub msg


port fileSelected : String -> Cmd msg


port fileSelectedData : (Maybe JsonFile -> msg) -> Sub msg


port fileUpload : String -> Cmd msg


port fileUploadStarted : (() -> msg) -> Sub msg


port fileUploadProgress : (( Float, Float ) -> msg) -> Sub msg


port fileUploadComplete : (() -> msg) -> Sub msg


port fileUploadSuccess : (String -> msg) -> Sub msg


port fileUploadFailed : (String -> msg) -> Sub msg

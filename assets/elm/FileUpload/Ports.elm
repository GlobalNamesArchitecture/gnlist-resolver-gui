port module FileUpload.Ports exposing (..)

import FileUpload.Models exposing (File)


port isUploadSupported : () -> Cmd msg


port uploadIsSupported : (Bool -> msg) -> Sub msg


port fileSelected : String -> Cmd msg


port fileSelectedData : (Maybe File -> msg) -> Sub msg


port fileUpload : String -> Cmd msg


port fileUploadResult : (Maybe String -> msg) -> Sub msg

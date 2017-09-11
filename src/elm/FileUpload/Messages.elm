module FileUpload.Messages exposing (Msg(..))

import FileUpload.Models exposing (JsonFile)
import Data.Token exposing (Token)


type Msg
    = UploadSupported Bool
    | FileSelected
    | FileSelectedData (Maybe JsonFile)
    | FileUpload
    | EmptyErrors
    | FileUploadProgress ( Float, Float )
    | FileUploadStarted ()
    | FileUploadComplete ()
    | FileUploadFailed String
    | FileUploadSuccess Token

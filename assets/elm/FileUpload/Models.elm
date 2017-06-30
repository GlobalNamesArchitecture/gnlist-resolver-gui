module FileUpload.Models exposing (..)

import Errors exposing (Errors)


type alias Upload =
    { token : Maybe String
    , file : Maybe File
    , isSupported : Bool
    , id : String
    , errors : Errors
    }


initUpload =
    Upload Nothing Nothing False "file-upload" Nothing


type alias File =
    { filename : String
    , filetype : String
    , size : Float
    }

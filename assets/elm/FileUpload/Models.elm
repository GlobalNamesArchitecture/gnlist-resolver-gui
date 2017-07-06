module FileUpload.Models exposing (..)

import Errors exposing (Errors)


type Loaded
    = Loaded Float


type Total
    = Total Float


type Token
    = Token String


type Bytes
    = Bytes Int


type FileName
    = FileName String


type FileType
    = Csv
    | UnknownFileType String


type UploadFailure
    = UnknownFailure
    | PostFailure
    | XhrFailure
    | ServerFailure


type UploadProgress
    = NotStarted
    | Started
    | Loading Loaded Total
    | Complete
    | Failed UploadFailure
    | Succeeded Token


type alias Upload =
    { file : Maybe File
    , isSupported : Bool
    , id : String
    , errors : Errors
    , progress : UploadProgress
    }


initUpload : Upload
initUpload =
    Upload Nothing False "file-upload" Nothing NotStarted


type alias File =
    { fileName : FileName
    , fileType : FileType
    , size : Bytes
    }


type alias JsonFile =
    { filename : String
    , filetype : String
    , size : Float
    }


progressToCompletionPercent : UploadProgress -> Maybe Int
progressToCompletionPercent progress =
    case progress of
        Loading (Loaded loaded) (Total total) ->
            Just <| round <| (loaded / total) * 100

        _ ->
            Nothing


uploadToken : Upload -> Maybe String
uploadToken upload =
    case upload.progress of
        Succeeded (Token token) ->
            Just token

        _ ->
            Nothing


jsonFileToFile : JsonFile -> File
jsonFileToFile { filename, filetype, size } =
    File (FileName filename) (fileTypeToType filetype) (Bytes <| round size)


fileTypeToType : String -> FileType
fileTypeToType fileType =
    case fileType of
        "csv" ->
            Csv

        v ->
            UnknownFileType v

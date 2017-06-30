module FileUpload.Update exposing (update)

import Navigation exposing (newUrl)
import Errors exposing (Error, Errors)
import FileUpload.Models exposing (Upload, File)
import FileUpload.Messages exposing (Msg(..))
import FileUpload.Ports exposing (..)


update : Msg -> Upload -> ( Upload, Cmd Msg )
update msg upload =
    case msg of
        UploadSupported value ->
            ( { upload | isSupported = value }, Cmd.none )

        FileSelected ->
            ( upload, fileSelected upload.id )

        FileSelectedData file ->
            ( { upload | file = file }, Cmd.none )

        FileUpload ->
            ( upload, fileUpload upload.id )

        FileUploadResult token ->
            let
                errors =
                    case token of
                        Nothing ->
                            Just <|
                                (Error "File Upload Failed"
                                    errBody
                                )
                                    :: Maybe.withDefault [] upload.errors

                        Just _ ->
                            upload.errors
            in
                ( { upload
                    | token = token
                    , errors = errors
                  }
                , tokenCmd token
                )

        EmptyErrors ->
            ( { upload
                | errors = Nothing
                , file = Nothing
                , token = Nothing
              }
            , Cmd.none
            )


errBody : String
errBody =
    """Looks like the uploaded file is either not in a CSV format, or it
contains some errors.  Try to verify the file with a
[CSV checker](https://csvlint.io/). Also make sure that your encoding
is UTF-8."""


tokenCmd : Maybe String -> Cmd Msg
tokenCmd mbToken =
    case mbToken of
        Nothing ->
            Cmd.none

        Just token ->
            newUrl <|
                "/#terms/"
                    ++ token

module FileUpload.Update exposing (update, subscriptions)

import Routing exposing (Route(Terms), navigateTo)
import FileUpload.Models exposing (Upload, File, UploadProgress(..), Loaded(..), Total(..), UploadFailure(..), Token(..), jsonFileToFile)
import FileUpload.Messages exposing (Msg(..))
import FileUpload.Ports exposing (..)


subscriptions : Sub Msg
subscriptions =
    Sub.batch
        [ uploadIsSupported UploadSupported
        , fileSelectedData FileSelectedData
        , fileUploadProgress FileUploadProgress
        , fileUploadStarted FileUploadStarted
        , fileUploadComplete FileUploadComplete
        , fileUploadFailed FileUploadFailed
        , fileUploadSuccess FileUploadSuccess
        ]


update : Msg -> Upload -> ( Upload, Cmd Msg )
update msg upload =
    case msg of
        FileUploadProgress ( loaded, total ) ->
            ( { upload | progress = Loading (Loaded loaded) (Total total) }, Cmd.none )

        FileUploadStarted _ ->
            ( { upload | progress = Started }, Cmd.none )

        FileUploadComplete _ ->
            ( { upload | progress = Complete }, Cmd.none )

        UploadSupported value ->
            ( { upload | isSupported = value }, Cmd.none )

        FileSelected ->
            ( upload, fileSelected upload.id )

        FileSelectedData jsonFile ->
            ( { upload | file = Maybe.map jsonFileToFile jsonFile }, Cmd.none )

        FileUpload ->
            ( upload, fileUpload upload.id )

        FileUploadFailed failureType ->
            ( { upload | progress = Failed <| parseFailureType failureType }
            , Cmd.none
            )

        FileUploadSuccess token ->
            ( { upload | progress = Succeeded (Token token) }
            , navigateTo <| Terms token
            )

        EmptyErrors ->
            ( { upload
                | errors = Nothing
                , file = Nothing
              }
            , Cmd.none
            )


parseFailureType : String -> UploadFailure
parseFailureType failureType =
    case failureType of
        "post" ->
            PostFailure

        "xhr" ->
            XhrFailure

        "server" ->
            ServerFailure

        _ ->
            UnknownFailure

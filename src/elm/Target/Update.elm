module Target.Update exposing (update, retrieveDataSource)

import Routing exposing (Route(Resolver), navigateTo)
import Http
import Json.Decode as Decode exposing (Decoder)
import Helper as H
import Target.Models exposing (Target)
import Target.Messages exposing (Msg(..))
import Target.Encoder as TE
import Data.Token as Token exposing (Token)
import Data.DataSource as DataSource


update : Msg -> Target -> ( Target, Cmd Msg )
update msg target =
    case msg of
        ToResolver token ->
            ( target, navigateTo <| Resolver token )

        UpdateCurrentTarget (Ok current) ->
            ( updateTarget current target, Cmd.none )

        UpdateCurrentTarget (Err _) ->
            ( target, Cmd.none )

        CurrentTarget token current ->
            ( updateTarget current target, saveTarget token current )

        SaveTarget _ ->
            ( target, Cmd.none )

        FilterTarget f ->
            ( { target | filter = f }, Cmd.none )


updateTarget : DataSource.Id -> Target -> Target
updateTarget dataSourceId target =
    { target | current = Just dataSourceId }


saveTarget : Token -> DataSource.Id -> Cmd Msg
saveTarget token dataSourceId =
    let
        url =
            "/list_matchers"
    in
        Http.send SaveTarget
            (H.put url <| TE.body token dataSourceId)


retrieveDataSource : Token -> Cmd Msg
retrieveDataSource token =
    let
        url =
            "/list_matchers/" ++ Token.toString token
    in
        Http.send UpdateCurrentTarget
            (Http.get url currentTargetDecoder)


currentTargetDecoder : Decoder DataSource.Id
currentTargetDecoder =
    Decode.map DataSource.Id <| Decode.field "data_source_id" Decode.int

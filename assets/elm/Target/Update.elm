module Target.Update exposing (update)

import Routing exposing (Route(Resolver), navigateTo)
import Json.Encode as Encode
import Http
import Helper as H
import Target.Models exposing (Target)
import Target.Messages exposing (Msg(..))
import Target.Helper as HDS
import Target.Encoder as TE


update : Msg -> Target -> ( Target, Cmd Msg )
update msg ds =
    case msg of
        AllDataSources (Ok dss) ->
            ( { ds | all = HDS.prepareDataSources ds dss }
            , Cmd.none
            )

        AllDataSources (Err _) ->
            ( ds, Cmd.none )

        ToResolver token ->
            ( ds, navigateTo <| Resolver token )

        CurrentTarget token current ->
            ( { ds | current = current }, saveTarget token current )

        SaveTarget (Ok _) ->
            ( ds, Cmd.none )

        SaveTarget (Err _) ->
            ( ds, Cmd.none )

        FilterTarget f ->
            ( { ds | filter = f }, Cmd.none )


saveTarget : String -> Int -> Cmd Msg
saveTarget token targetId =
    let
        url =
            "/crossmaps"
    in
        Http.send SaveTarget
            (H.put url <| TE.body token targetId)


body : String -> Int -> Http.Body
body token targetId =
    Http.jsonBody <|
        Encode.object
            [ ( "token", Encode.string token )
            , ( "data_source_id", Encode.int targetId )
            ]

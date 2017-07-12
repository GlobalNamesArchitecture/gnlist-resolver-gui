module Target.Helper exposing (..)

import Http
import Dict
import Maybe exposing (withDefault)
import Target.Messages exposing (Msg(..))
import Target.Decoder exposing (..)
import Target.Models
    exposing
        ( Target
        , DataSources
        , DataSource
        )


abbreviation : Dict.Dict Int String
abbreviation =
    let
        abbr =
            [ ( 8, "IRMNG" )
            , ( 9, "WoRMS" )
            , ( 167, "IPNI" )
            , ( 172, "PaleoBioDb" )
            , ( 179, "OTT" )
            ]
    in
        Dict.fromList abbr


getDataSources : String -> Cmd Msg
getDataSources url =
    let
        datasourceUrl =
            url ++ "/data_sources.json"
    in
        Http.send AllDataSources (Http.get datasourceUrl dataSourceDecoder)


prepareDataSources : Target -> DataSources -> DataSources
prepareDataSources ds dss =
    dss
        |> List.filter (includeTarget (dataSourceIds ds.all))
        |> List.map appendDataSource


appendDataSource : DataSource -> DataSource
appendDataSource ds =
    case (Dict.get ds.id abbreviation) of
        Nothing ->
            ds

        Just a ->
            { ds | title = composeTitle a ds.title }


composeTitle : String -> Maybe String -> Maybe String
composeTitle abbr title =
    case title of
        Nothing ->
            Just abbr

        Just t ->
            Just <| abbr ++ " (" ++ t ++ ")"


dataSourceIds : DataSources -> List Int
dataSourceIds dss =
    List.map (\ds -> ds.id) dss


includeTarget : List Int -> DataSource -> Bool
includeTarget dsIds ds =
    List.member ds.id dsIds


currentTarget : Target -> DataSource
currentTarget ds =
    let
        default =
            DataSource 0 Nothing Nothing
    in
        withDefault default <|
            List.head <|
                List.filter (\dsi -> dsi.id == ds.current) ds.all

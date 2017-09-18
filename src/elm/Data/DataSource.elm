module Data.DataSource
    exposing
        ( Id(..)
        , DataSource
        , listDecoder
        , encodeId
        )

import Json.Decode as Decode exposing (Decoder)
import Json.Encode


type Id
    = Id Int


type Description
    = Description String


type alias DataSource =
    { id : Id
    , title : String
    , description : Maybe Description
    }


listDecoder : Decoder (List DataSource)
listDecoder =
    Decode.list decoder


decoder : Decoder DataSource
decoder =
    Decode.map processAbbreviation dataSourceDecoder


dataSourceDecoder : Decoder DataSource
dataSourceDecoder =
    Decode.map3 DataSource id title description


id : Decoder Id
id =
    Decode.map Id <| Decode.field "id" Decode.int


title : Decoder String
title =
    Decode.field "title" Decode.string


description : Decoder (Maybe Description)
description =
    Decode.map (Maybe.map Description) rawDescription


rawDescription : Decoder (Maybe String)
rawDescription =
    Decode.field "description" (Decode.nullable Decode.string)


encodeId : Id -> Json.Encode.Value
encodeId =
    Json.Encode.int << idToInt


idToInt : Id -> Int
idToInt (Id v) =
    v


processAbbreviation : DataSource -> DataSource
processAbbreviation ({ id, title } as dataSource) =
    let
        matchedAbbreviation =
            List.head <| List.filter (\( dsId, _ ) -> id == dsId) abbreviations
    in
        case matchedAbbreviation of
            Nothing ->
                dataSource

            Just ( _, abbreviation ) ->
                { dataSource | title = abbreviation ++ " (" ++ title ++ ")" }


abbreviations : List ( Id, String )
abbreviations =
    [ ( Id 8, "IRMNG" )
    , ( Id 9, "WoRMS" )
    , ( Id 167, "IPNI" )
    , ( Id 172, "PaleoBioDb" )
    , ( Id 179, "OTT" )
    ]

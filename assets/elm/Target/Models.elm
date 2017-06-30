module Target.Models exposing (..)

import Maybe exposing (withDefault)


type alias Target =
    { all : DataSources
    , current : Int
    , filter : String
    }


type alias DataSources =
    List DataSource


type alias DataSource =
    { id : Int, title : Maybe String, desc : Maybe String }


initTarget : List Int -> Target
initTarget dss =
    let
        current =
            withDefault 1 <| List.head dss

        infos =
            List.map (\id -> DataSource id Nothing Nothing) dss
    in
        Target infos current ""

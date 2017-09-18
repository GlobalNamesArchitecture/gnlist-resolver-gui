module Target.Models
    exposing
        ( Target
        , initial
        , currentDataSource
        )

import Data.DataSource as DataSource exposing (DataSource)


type alias Target =
    { current : Maybe DataSource.Id
    , filter : String
    }


initial : Target
initial =
    { current = Nothing, filter = "" }


currentDataSource : List DataSource -> Target -> Maybe DataSource
currentDataSource dataSources { current } =
    let
        currentDataSource current_ =
            List.head <|
                List.filter (\ds -> ds.id == current_) dataSources
    in
        current
            |> Maybe.andThen currentDataSource

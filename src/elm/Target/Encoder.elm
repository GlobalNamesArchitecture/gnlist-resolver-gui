module Target.Encoder exposing (body)

import Json.Encode exposing (..)
import Http
import Data.Token as Token exposing (Token)
import Data.DataSource as DataSource


body : Token -> DataSource.Id -> Http.Body
body token targetId =
    Http.jsonBody <|
        object
            [ ( "token", Token.encode token )
            , ( "data_source_id", DataSource.encodeId targetId )
            ]

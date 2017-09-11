module Target.Messages exposing (Msg(..))

import Http
import Target.Models exposing (DataSources)
import Data.Token exposing (Token)


type Msg
    = CurrentTarget Token Int
    | SaveTarget (Result Http.Error ())
    | AllDataSources (Result Http.Error DataSources)
    | ToResolver Token
    | FilterTarget String

module Target.Messages exposing (Msg(..))

import Http
import Data.Token exposing (Token)
import Data.DataSource as DataSource


type Msg
    = CurrentTarget Token DataSource.Id
    | UpdateCurrentTarget (Result Http.Error DataSource.Id)
    | SaveTarget (Result Http.Error ())
    | ToResolver Token
    | FilterTarget String

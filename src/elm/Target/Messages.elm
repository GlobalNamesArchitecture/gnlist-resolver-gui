module Target.Messages exposing (Msg(..))

import Http
import Target.Models exposing (DataSources)


type Msg
    = CurrentTarget String Int
    | SaveTarget (Result Http.Error ())
    | AllDataSources (Result Http.Error DataSources)
    | ToResolver String
    | FilterTarget String

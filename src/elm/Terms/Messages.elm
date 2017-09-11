module Terms.Messages exposing (Msg(..))

import Http
import Terms.Models exposing (Terms)
import Data.Token exposing (Token)


type Msg
    = ToDataSources Token
    | ToResolver Token
    | MapTerm Token Int String
    | GetTerms (Result Http.Error Terms)
    | SaveTerms (Result Http.Error ())

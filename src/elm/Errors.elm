module Errors exposing (Errors, Error)

import Html exposing (Html)


type alias Errors =
    Maybe (List Error)


type alias Error =
    { title : String
    , body : String
    }

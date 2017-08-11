module Errors exposing (Errors, Error)


type alias Errors =
    Maybe (List Error)


type alias Error =
    { title : String
    , body : String
    }

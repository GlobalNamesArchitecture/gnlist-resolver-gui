module Routing exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)


type alias Token =
    String


type Route
    = FileUpload
    | Terms Token
    | Target Token
    | Resolver Token
    | NotFoundRoute


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map FileUpload top
        , map Terms (s "terms" </> string)
        , map Target (s "target" </> string)
        , map Resolver (s "resolver" </> string)
        ]


parseLocation : Location -> Route
parseLocation location =
    case (parseHash matchers location) of
        Just route ->
            route

        Nothing ->
            NotFoundRoute

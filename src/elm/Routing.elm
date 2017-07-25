module Routing exposing (Token, Route(..), navigateTo, parseLocation)

import Navigation exposing (Location, newUrl)
import UrlParser exposing (..)


type alias Token =
    String


type Route
    = FileUpload
    | Terms Token
    | Target Token
    | Resolver Token
    | NotFoundRoute


navigateTo : Route -> Cmd a
navigateTo =
    newUrl << urlFor


urlFor : Route -> String
urlFor r =
    case r of
        FileUpload ->
            "/"

        Terms token ->
            "/#terms/" ++ token

        Target token ->
            "/#target/" ++ token

        Resolver token ->
            "/#resolver/" ++ token

        NotFoundRoute ->
            "/#404"


parseLocation : Location -> Route
parseLocation location =
    case parseHash matchers location of
        Just route ->
            route

        Nothing ->
            NotFoundRoute


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map FileUpload top
        , map Terms (s "terms" </> string)
        , map Target (s "target" </> string)
        , map Resolver (s "resolver" </> string)
        ]

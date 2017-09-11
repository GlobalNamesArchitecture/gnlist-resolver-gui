module Routing exposing (Route(..), navigateTo, parseLocation)

import Navigation exposing (Location, newUrl)
import UrlParser exposing (..)
import Data.Token as Token exposing (Token)


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
            "/#terms/" ++ Token.toString token

        Target token ->
            "/#target/" ++ Token.toString token

        Resolver token ->
            "/#resolver/" ++ Token.toString token

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
        , map (Terms << Token.fromString) (s "terms" </> string)
        , map (Target << Token.fromString) (s "target" </> string)
        , map (Resolver << Token.fromString) (s "resolver" </> string)
        ]

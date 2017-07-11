module Models exposing (Model, Flags, initModel, currentToken)

import Maybe exposing (withDefault)
import Routing exposing (Route(..))
import FileUpload.Models exposing (Upload, initUpload)
import Terms.Models exposing (Terms, initTerms)
import Target.Models exposing (Target, initTarget)
import Resolver.Models exposing (Resolver, initResolver)
import Errors exposing (Errors, Error)


type alias Model =
    { route : Routing.Route
    , resolverUrl : String
    , localDomain : String
    , token : Maybe String
    , upload : Upload
    , terms : Terms
    , target : Target
    , resolver : Resolver
    , errors : Errors
    }


type alias Flags =
    { resolverUrl : String
    , localDomain : String
    , dataSourcesIds : List Int
    }


initModel : Flags -> Routing.Route -> Model
initModel flags route =
    Model route
        flags.resolverUrl
        flags.localDomain
        Nothing
        initUpload
        initTerms
        (initTarget flags.dataSourcesIds)
        initResolver
        Nothing


currentToken : Model -> Maybe String
currentToken { route } =
    case route of
        FileUpload ->
            Nothing

        Terms t ->
            Just t

        Target t ->
            Just t

        Resolver t ->
            Just t

        NotFoundRoute ->
            Nothing

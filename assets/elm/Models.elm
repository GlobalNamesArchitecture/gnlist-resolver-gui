module Models exposing (Model, Flags, initModel)

import Maybe exposing (withDefault)
import Routing
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

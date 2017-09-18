module Models exposing (Model, Flags, initModel, currentToken, visibleDataSources)

import Material
import RemoteData exposing (WebData, RemoteData(..))
import Routing exposing (Route(..))
import FileUpload.Models exposing (Upload, initUpload)
import Terms.Models exposing (Terms, initTerms)
import Target.Models as Target exposing (Target)
import Resolver.Models exposing (Resolver, initResolver)
import Errors exposing (Errors)
import Data.Token exposing (Token)
import Data.DataSource as DataSource exposing (DataSource)


type alias Model =
    { route : Routing.Route
    , dataSources : WebData (List DataSource)
    , allowedDataSourceIds : List DataSource.Id
    , resolverUrl : String
    , localDomain : String
    , upload : Upload
    , terms : Terms
    , target : Target
    , resolver : Resolver
    , errors : Errors
    , softwareVersion : String
    , mdl : Material.Model
    }


type alias Flags =
    { resolverUrl : String
    , localDomain : String
    , dataSourcesIds : List Int
    , version : String
    }


initModel : Flags -> Routing.Route -> Model
initModel flags route =
    let
        dataSourceIds =
            List.map DataSource.Id flags.dataSourcesIds

        initialTarget =
            Target.initial
    in
        { route = route
        , dataSources = NotAsked
        , allowedDataSourceIds = dataSourceIds
        , resolverUrl = flags.resolverUrl
        , localDomain = flags.localDomain
        , upload = initUpload
        , terms = initTerms
        , target = { initialTarget | current = List.head dataSourceIds }
        , resolver = initResolver
        , errors = Nothing
        , softwareVersion = flags.version
        , mdl = Material.model
        }


currentToken : Model -> Maybe Token
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


visibleDataSources : Model -> WebData (List DataSource)
visibleDataSources { dataSources, allowedDataSourceIds } =
    let
        filterAllowedSource =
            List.filter (\item -> List.member item.id allowedDataSourceIds)
    in
        RemoteData.map filterAllowedSource dataSources

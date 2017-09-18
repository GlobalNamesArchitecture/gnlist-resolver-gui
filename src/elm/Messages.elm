module Messages exposing (Msg(..))

import Navigation exposing (Location)
import RemoteData exposing (WebData)
import Material
import FileUpload.Messages
import Terms.Messages
import Target.Messages
import Resolver.Messages
import Data.DataSource exposing (DataSource)


type Msg
    = OnLocationChange Location
    | FileUploadMsg FileUpload.Messages.Msg
    | TermsMsg Terms.Messages.Msg
    | TargetMsg Target.Messages.Msg
    | ResolverMsg Resolver.Messages.Msg
    | LoadDataSources (WebData (List DataSource))
    | EmptyErrors
    | Mdl (Material.Msg Msg)

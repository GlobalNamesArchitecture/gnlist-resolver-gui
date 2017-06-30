module Messages exposing (Msg(..))

import Navigation exposing (Location)
import FileUpload.Messages
import Terms.Messages
import Target.Messages
import Resolver.Messages


type Msg
    = OnLocationChange Location
    | FileUploadMsg FileUpload.Messages.Msg
    | TermsMsg Terms.Messages.Msg
    | TargetMsg Target.Messages.Msg
    | ResolverMsg Resolver.Messages.Msg
    | EmptyErrors

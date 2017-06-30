module Terms.Models exposing (..)


type alias Terms =
    { output : String
    , headers : List Header
    , rows : List Row
    }


type alias Header =
    { id : Int
    , value : String
    , term : Maybe String
    }


type alias Row =
    List (Maybe String)


initTerms : Terms
initTerms =
    Terms "Unknown" [] []


rankFields : List String
rankFields =
    [ "kingdom"
    , "subKingdom"
    , "phylum"
    , "subPhylum"
    , "superClass"
    , "class"
    , "subClass"
    , "cohort"
    , "superOrder"
    , "order"
    , "subOrder"
    , "infraOrder"
    , "superFamily"
    , "family"
    , "subFamily"
    , "tribe"
    , "subTribe"
    , "genus"
    , "subGenus"
    , "section"
    , "species"
    , "subSpecies"
    , "variety"
    , "form"
    ]


coreFields : List String
coreFields =
    [ "taxonId", "taxonrank", "scientificName", "scientificNameAuthorship" ]


allFields =
    coreFields ++ rankFields

module Terms.Models exposing (..)


type alias Terms =
    { output : String
    , headers : List Header
    , workflowTerms : List Term
    , rows : List Row
    }


type Uniqueness
    = MustBeUnique
    | AllowsDuplication


type alias Term =
    { value : String
    , unique : Uniqueness
    , desc : String
    , url : String
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
    Terms "Unknown" [] combinedTerms []


combinedTerms : List Term
combinedTerms =
    coreTerms ++ rankTerms


sientificNameTerms : List Term
sientificNameTerms =
    coreTerms


allTermValues : List String
allTermValues =
    List.map .value combinedTerms



-- PRIVATE


coreTerms : List Term
coreTerms =
    [ Term "taxonId" MustBeUnique "something" "http://example.org"
    , Term "scientificName" MustBeUnique "something" "http://example.org"
    , Term "scientificNameAuthorship" AllowsDuplication "something" "http://example.org"
    , Term "taxonrank" MustBeUnique "something" "http://example.org"
    ]


rankTerms : List Term
rankTerms =
    [ Term "kingdom" MustBeUnique "something" "http://example.org"
    , Term "subKingdom" MustBeUnique "something" "http://example.org"
    , Term "phylum" MustBeUnique "something" "http://example.org"
    , Term "subPhylum" MustBeUnique "something" "http://example.org"
    , Term "superClass" MustBeUnique "something" "http://example.org"
    , Term "class" MustBeUnique "something" "http://example.org"
    , Term "subClass" MustBeUnique "something" "http://example.org"
    , Term "cohort" MustBeUnique "something" "http://example.org"
    , Term "superOrder" MustBeUnique "something" "http://example.org"
    , Term "order" MustBeUnique "something" "http://example.org"
    , Term "subOrder" MustBeUnique "something" "http://example.org"
    , Term "infraOrder" MustBeUnique "something" "http://example.org"
    , Term "superFamily" MustBeUnique "something" "http://example.org"
    , Term "family" MustBeUnique "something" "http://example.org"
    , Term "subFamily" MustBeUnique "something" "http://example.org"
    , Term "tribe" MustBeUnique "something" "http://example.org"
    , Term "subTribe" MustBeUnique "something" "http://example.org"
    , Term "genus" MustBeUnique "something" "http://example.org"
    , Term "subGenus" MustBeUnique "something" "http://example.org"
    , Term "section" MustBeUnique "something" "http://example.org"
    , Term "species" MustBeUnique "something" "http://example.org"
    , Term "subSpecies" AllowsDuplication "something" "http://example.org"
    , Term "variety" MustBeUnique "something" "http://example.org"
    , Term "form" MustBeUnique "something" "http://example.org"
    ]

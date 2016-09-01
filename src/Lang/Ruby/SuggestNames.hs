--------------------------------------------------------------------------------
-- Author: CAU, 2015                                                          --
--------------------------------------------------------------------------------

module Lang.Ruby.SuggestNames (suggestName) where

import Data.List

import Lang.Ruby.IdTable
import Lang.Ruby.Symboltable

import Text.EditDistance

suggestName :: IdTable -> String -> [String]
suggestName t n
    | (length(n) <= 1)  = []
    | (length(n) > 1) = case sortedDistances of
                              [] -> []
                              xs -> testNext t xs
                      where distances = map (\x -> (x, levenshteinDistance defaultEditCosts n x)) (symbolIdentifiers t)
                            sortedDistances = sortBy sortTuples distances
                            sortTuples (_, a) (_, b) = if a > b then GT else LT
                            testNext t' ((x', d'):xs') = if d' > 2 then [] else x' : (testNext t' xs')
                            testNext _ [] = []

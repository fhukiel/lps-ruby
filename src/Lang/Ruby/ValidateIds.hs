--------------------------------------------------------------------------------
-- Author: CAU, 2015                                                          --
--------------------------------------------------------------------------------

module Lang.Ruby.ValidateIds where
{-Module for validating that no illegal chars are used for identifiers-}
import Data.Maybe
import Lang.Ruby.AST
import Lang.Ruby.Analysis
import Lang.Ruby.Errors
import Lang.Ruby.IdTable
import Lang.Ruby.Symboltable as S

import Data.List.Utils
import Data.Char

-- superior function which collects all errors
validateIds :: IdTable -> [Err]
validateIds idtable = checkIds idtable []

-- travels the IdTable with getNextId, collects all illegal identifiers as errors in a list
checkIds :: IdTable -> [Err] -> [Err]
checkIds idtable errs = case nextId of
 Just (s,info)          -> let v = (validateIdName s info) in
                                                             if v == Nothing then (checkIds restIdTable errs)
                                                             else (fromJust v) ++ (checkIds restIdTable errs)
 Nothing                -> []
 where (nextId, restIdTable) = S.getNextId idtable

-- decides whether a variable, class or methode name is validated, different rules for each
validateIdName :: String -> SymInfo -> Maybe [Err]
validateIdName s info = case info of
  VarInfo p    -> validateVarName s p
  ProcInfo p _ -> validateProcName s p
  ClassInfo p  -> validateClassName s p

-- validate identifiers of variables
validateVarName :: String -> Posn -> Maybe [Err]
validateVarName s@(y:ys) p = validateEnd --TODO
  where validateEnd = case (last s) of
                        '?' -> Just [Err p (IllegalSign (EndsWithOp '?'))]
                        '!' -> Just [Err p (IllegalSign (EndsWithOp '!'))]
                        _   -> Nothing

--validates identifiers of methods
validateProcName :: String -> Posn -> Maybe [Err]
validateProcName s@(y:ys) p = validateFirst >>-- validateAt -- >>-- validateKeyWords
  where validateFirst = if isUpper y then Just [Warning p (UpperCase s)] else Nothing
        validateAt    = if startswith ['@'] s then Just [Err p (IllegalSign (StartsWithAt '@'))] else Nothing

-- validates identifiers of classes
validateClassName :: String -> Posn -> Maybe [Err]
validateClassName s p = Nothing -- TODO

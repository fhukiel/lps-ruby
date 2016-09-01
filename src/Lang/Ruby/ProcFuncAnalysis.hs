--------------------------------------------------------------------------------
-- Author: CAU, 2015                                                          --
--------------------------------------------------------------------------------

module Lang.Ruby.ProcFuncAnalysis (procFuncCheck) where

import Data.Maybe

import Lang.Ruby.Analysis
import Lang.Ruby.AST
import Lang.Ruby.IdTable
import Lang.Ruby.Symboltable
import Lang.Ruby.Errors

procFuncCheck = Check checkStmt

checkStmt :: IdTable -> ScopeInfo -> Stmt -> [Err]
checkStmt t i (IfStmt _ c _ _)             = checkExpr t i c
checkStmt t i (WhileStmt _ c _ )           = checkExpr t i c
checkStmt t i (ForStmt _ _ c _)            = checkExpr t i c
checkStmt t i (AssignStmt _ _ e)           = checkExpr t i e
checkStmt t i (ReturnStmt _ (Just e))      = checkExpr t i e
checkStmt t i (CallStmt pc c@(Call _ n _)) =
  case (lookupTable n t) of
    Just (ProcInfo p Proc) -> []
    Just (ProcInfo p Func) -> [Err pc (FuncInsteadOfProc n)]
    Just (ProcInfo p ProcAndFunc) -> []
    _ -> []
checkStmt _ _ _ = []

checkExpr :: IdTable -> ScopeInfo -> Expr -> [Err]
checkExpr t i (CallExpr pc (Call _ n _)) =
  case ((lookupTable n t)) of
    Just (ProcInfo p Proc) -> [Err pc (ProcInsteadOfFunc n)]
    Just (ProcInfo p Func) -> []
    _ -> []
checkExpr t i (RangeExpr _ l r)  = checkExpr t i l >>- checkExpr t i r
checkExpr t i (ArrayExpr _ xs)   = concat $ map (checkExpr t i) xs
checkExpr t i (HashExpr _ xs)    = concat $ map (\x -> checkExpr t i (fst x) >>- checkExpr t i (snd x)) xs
checkExpr t i (OpExpr _ l _ r)   = checkExpr t i l >>- checkExpr t i r
checkExpr t i (UnopExpr _ _ e)   = checkExpr t i e
checkExpr t i (IfExpr _ c th e)  = checkExpr t i c >>- checkExpr t i th >>- checkExpr t i e
checkExpr t i (IndexExpr _ c xs) = checkExpr t i c >>- (concat $ map (checkExpr t i) xs)
checkExpr _ _ _                  = []

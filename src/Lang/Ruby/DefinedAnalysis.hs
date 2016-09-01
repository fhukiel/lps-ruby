--------------------------------------------------------------------------------
-- Author: CAU, 2015                                                          --
--------------------------------------------------------------------------------

module Lang.Ruby.DefinedAnalysis (definedCheck) where

import Data.List
import Data.Maybe
import Data.String.Utils

import Lang.Ruby.Analysis
import Lang.Ruby.AST
import Lang.Ruby.IdTable
import Lang.Ruby.Symboltable
import Lang.Ruby.SuggestNames
import Lang.Ruby.Errors

import Debug.Trace

definedCheck = Check checkDefinedStmt

checkDefinedStmt :: IdTable -> ScopeInfo -> Stmt -> [Err]
checkDefinedStmt t i (IfStmt _ c a b)            = checkDefinedExpr t i c
checkDefinedStmt t i (WhileStmt _ c _)           = checkDefinedExpr t i c
checkDefinedStmt t i (ForStmt _ _ c _)           = checkDefinedExpr t i c
checkDefinedStmt t i (CallStmt p c@(Call _ n _)) = checkDefinedCall p t i c
checkDefinedStmt t i (BlockCallStmt _ _ _ )      = []
checkDefinedStmt t i (AssignStmt _ _ e)          = checkDefinedExpr t i e
checkDefinedStmt t i (DefStmt _ _ _ b)       = []
checkDefinedStmt t i (ReturnStmt _ (Just e)) = checkDefinedExpr t i e
checkDefinedStmt t i (ReturnStmt p Nothing)  = [Warning p EmptyReturn]
checkDefinedStmt t i (ClassStmt _ _ b)       = []
checkDefinedStmt t i (PrivateStmt _ )        = []
checkDefinedStmt t i (PublicStmt _ )         = []
checkDefinedStmt t i (RescueStmt _)          = []
checkDefinedStmt t i (RaiseStmt _)           = []

checkDefinedCall :: Posn -> IdTable -> ScopeInfo -> Call -> [Err]
checkDefinedCall p t i (Call c f es)  = checkDefinedId p t i f >>- (concat $ map (checkDefinedExpr t i) es)
--checkDefinedCall p t i (Call Nothing f es)  = checkDefinedId p t i f >>- (concat $ map (checkDefinedExpr t i) es)
--checkDefinedCall p t i (Call (Just e) f es) = checkDefinedExpr t i e >>- checkDefinedId p t i f >>- (concat $ map (checkDefinedExpr t i) es)

checkDefinedId :: Posn -> IdTable -> ScopeInfo -> Id -> [Err]
checkDefinedId p t i s = case (lookupTable s t) of
  Just (VarInfo pv) -> if pv < p then [] else checkDefinedId p (makeSym(getScopes t)) i s
  Just pi@(ProcInfo _ _) -> checkDefinedProc p t i s pi
  Just _ -> []
  Nothing -> if startswith "@" s
    then []
    else [Err p (UndefinedSymbol s (suggestName t s))]

checkDefinedProc :: Posn -> IdTable -> ScopeInfo -> Id -> SymInfo -> [Err]
checkDefinedProc p t TopLevel s (ProcInfo pd _) = if pd < p
  then []
  else [Err p (UndefinedSymbol s [])]
checkDefinedProc _ _ _ _ _ = []

checkDefinedExpr :: IdTable -> ScopeInfo -> Expr -> [Err]
checkDefinedExpr t i (NumExpr _ _)     = []
checkDefinedExpr t i (StringExpr _ _)  = []
checkDefinedExpr t i (BoolExpr _ _)    = []
checkDefinedExpr t i (RangeExpr _ l u) = checkDefinedExpr t i l >>- checkDefinedExpr t i u
checkDefinedExpr t i (ArrayExpr _ xs)  = concat $ map (checkDefinedExpr t i) xs
checkDefinedExpr t i (HashExpr _ xs)   = concat $ map (checkDefinedExpr t i) (fst c ++ snd c)
  where c = unzip xs
checkDefinedExpr t i (IdExpr p "nil") = []
checkDefinedExpr t i (IdExpr p s) = case (lookupTable s t) of
  Just (VarInfo pv) -> if pv < p then [] else checkDefinedId p (makeSym (getScopes t)) i s
  Just _ -> []
  -- just ignore ivars for now
  Nothing -> if startswith "@" s
    then []
    else [Err p (UndefinedSymbol s [])]
checkDefinedExpr t i (RegexpExpr _ _)            = []
checkDefinedExpr t i (OpExpr _ e1 DivOp e2@(NumExpr p "0")) = [Warning p DivideByZero] >>- checkDefinedExpr t i e1 >>- checkDefinedExpr t i e2
checkDefinedExpr t i (OpExpr _ e1 _ e2) = checkDefinedExpr t i e1 >>- checkDefinedExpr t i e2
checkDefinedExpr t i (UnopExpr _ _ e)            = checkDefinedExpr t i e
checkDefinedExpr t i (IfExpr _ c e1 e2)          = checkDefinedExpr t i c >>- checkDefinedExpr t i e1 >>- checkDefinedExpr t i e2
checkDefinedExpr t i (CallExpr p c@(Call _ n _)) = checkDefinedCall p t i c
checkDefinedExpr t i (IndexExpr _ a is)          = checkDefinedExpr t i a >>-
  (concat $ map (checkDefinedExpr t i) is)

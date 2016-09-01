--------------------------------------------------------------------------------
-- Author: CAU, 2015                                                          --
--------------------------------------------------------------------------------

module Lang.Ruby.BoolAnalysis (boolCheck) where

import Data.Maybe

import Lang.Ruby.Analysis
import Lang.Ruby.AST
import Lang.Ruby.IdTable
import Lang.Ruby.Symboltable
import Lang.Ruby.Errors

boolCheck = Check checkStmt

-- Pruefe nur Bedingungen
checkStmt :: IdTable -> ScopeInfo -> Stmt -> [Err]
checkStmt t i (IfStmt _ c _ _)    = checkExpr t i c
checkStmt t i (WhileStmt _ c _ )  = checkExpr t i c
-- Stmts die moeglicherweise Bedingte Expressions enthalten
checkStmt t i (ForStmt _ _ e _ )       = findCondExpr t i e
checkStmt t i (AssignStmt _ _ e )      = findCondExpr t i e
checkStmt t i (ReturnStmt _ (Just e) ) = findCondExpr t i e
-- else
checkStmt _ _ _ = []

-- Absteigen in Expressions um Bedingte Expressions (if) zu finden und zu pruefen
findCondExpr :: IdTable -> ScopeInfo -> Expr -> [Err]
findCondExpr t i (IfExpr _ c e1 e2)  = checkExpr t i c >>- findCondExpr t i e1 >>- findCondExpr t i e2
findCondExpr t i (RangeExpr _ e1 e2) = findCondExpr t i e1 >>- findCondExpr t i e2
findCondExpr t i (ArrayExpr _ es)    = concat $ map (findCondExpr t i) es
findCondExpr t i (HashExpr _ es)     = concat $ map (findCondExpr t i) (fst c ++ snd c)
  where c = unzip es
findCondExpr t i (OpExpr _ e1 _ e2)  = findCondExpr t i e1 >>- findCondExpr t i e2
findCondExpr t i (IndexExpr _ e es)  = findCondExpr t i e >>- (concat $ map (findCondExpr t i) es)
findCondExpr t i (UnopExpr _ _ e)    = findCondExpr t i e
findCondExpr _ _ _                   = []

checkExpr :: IdTable -> ScopeInfo -> Expr -> [Err]
-- Nicht pruefbare Ausdruecke
checkExpr t i (CallExpr _ _)     = []
checkExpr t i (IdExpr _ _)       = []
checkExpr t i (IndexExpr _ _ _)  = []
-- IfExpr
checkExpr t i (IfExpr _ c e1 e2) = checkExpr t i c >>- checkExpr t i e1 >>- checkExpr t i e2
-- OpExpr
checkExpr t i (OpExpr _ e1 OrOp e2)  = checkExpr t i e1 >>- checkExpr t i e2
checkExpr t i (OpExpr _ e1 AndOp e2) = checkExpr t i e1 >>- checkExpr t i e2
checkExpr t i (OpExpr p _ PlusOp _)  = [Err p NonBoolInCondition]
checkExpr t i (OpExpr p _ MinusOp _) = [Err p NonBoolInCondition]
checkExpr t i (OpExpr p _ TimesOp _) = [Err p NonBoolInCondition]
checkExpr t i (OpExpr p _ ModOp _)   = [Err p NonBoolInCondition]
checkExpr t i (OpExpr p _ DivOp _)   = [Err p NonBoolInCondition]
checkExpr t i (OpExpr _ _ _ _)       = []
-- BoolExpr
checkExpr t i (BoolExpr _ _) = []
-- Fehler
checkExpr _ _ _ = [Err p0 NonBoolInCondition] -- TODO: Position

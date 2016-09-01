--------------------------------------------------------------------------------
-- Author: CAU, 2015                                                          --
--------------------------------------------------------------------------------

module Lang.Ruby.IdTable where

import Lang.Ruby.AST
import Lang.Ruby.Symboltable

type IdTable = Symboltable Id SymInfo

data SymInfo = VarInfo Posn | ProcInfo Posn ProcType | ClassInfo Posn
  deriving Show

data ProcType = Proc | Func | ProcAndFunc
  deriving (Eq, Show)

data Illegal = Illegal Posn Char

instance Ord ProcType where
  Proc <= Func = True
  Func <= Proc = False
  Proc <= Proc = True
  Func <= Func = True

-- Position ist negativ da es vor dem eigentlichen Programm definiert werden soll
whitelistTable :: IdTable
whitelistTable = foldl (\a i -> insertTable (fst i) (ProcInfo (Posn (-1) 0 0) (snd i)) a) emptyTable w
  where w = [ ("puts", Proc)
            , ("length", Func)
            , ("sqrt", Func)
            , ("gets",Func)
            , ("to_s", ProcAndFunc)
            , ("to_i", Func)
            , ("read", Func)
            , ("reverse", Func)
            , ("reverse!", Proc)
            , ("capitalize", Func)
            , ("capitalize!", Proc)
            , ("upcase", Func)
            , ("upcase!", Proc)
            , ("downcase", Func)
            , ("downcase!", Proc)
            , ("strip", Func)
            , ("strip!", Proc)
            , ("chop", Func)
            , ("chop!", Proc)
            , ("split", Func)
            , ("match", ProcAndFunc)
            , ("clone", Func)
            , ("p", Proc)
            , ("size", ProcAndFunc)
            , ("new", Func)
            , ("print", Proc)
            , ("post_match", Func)
            , ("sub", ProcAndFunc)
            , ("gsub", ProcAndFunc)
            , ("write", ProcAndFunc)
            , ("max", Func)
            ]

-- If there are illegal Identifiers an Illegal is returned, otherwise an IdTable
buildSymTableStmts :: IdTable -> [Stmt] -> IdTable
buildSymTableStmts t [] = t
buildSymTableStmts t (s:ss) = buildSymTableStmts t' ss
  where t' = buildSymTableStmt t s

buildSymTableStmt :: IdTable -> Stmt -> IdTable
buildSymTableStmt t (IfStmt _ _ _ _)      = t
buildSymTableStmt t (WhileStmt _ _ _)     = t
buildSymTableStmt t (ForStmt p i _ _)     = insertTable i (VarInfo p) t
buildSymTableStmt t (CallStmt _ _)        = t
buildSymTableStmt t (BlockCallStmt _ _ _) = t
buildSymTableStmt t (AssignStmt p (IdExpr _ i) _)    = insertTable i (VarInfo p) t
buildSymTableStmt t (AssignStmt p _ _)    = t
buildSymTableStmt t (DefStmt p n _ b)     = insertTable n (ProcInfo p (procType b)) t
buildSymTableStmt t (ClassStmt p n ss)    = buildSymTableStmts (insertTable n (ClassInfo p) t) ss
buildSymTableStmt t (ReturnStmt _ _)      = t
buildSymTableStmt t (PublicStmt _)        = t
buildSymTableStmt t (PrivateStmt _)       = t
buildSymTableStmt t (RescueStmt _)        = t
buildSymTableStmt t (RaiseStmt _)         = t

firstFunc :: ProcType -> ProcType -> ProcType
firstFunc a b = case a of
  Func -> Func
  Proc -> b

procType :: [Stmt] -> ProcType
procType []                     = Proc
procType ((IfStmt _ _ a b):xs)  = firstFunc (max (procType a) (procType b)) (procType xs)
procType ((WhileStmt _ _ b):xs) = firstFunc (procType b) (procType xs)
procType ((ForStmt _ _ _ b):xs) = firstFunc (procType b) (procType xs)
procType ((ReturnStmt _ _):_)   = Func
procType (_:xs)                 = procType xs

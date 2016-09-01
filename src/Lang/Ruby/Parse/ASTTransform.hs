--------------------------------------------------------------------------------
-- Author: CAU, 2015                                                          --
--------------------------------------------------------------------------------

module Lang.Ruby.Parse.ASTTransform (transformParseAST, ppa) where

import qualified Lang.Gen.AST as S
import qualified Lang.Ruby.AST as D

transformParseAST = tpa

tpa :: S.AST -> D.AST
tpa (S.CompStmt _ s1 ss) = map tpaStmt (s1:(extractStmt ss))
  where extractStmt l = map (\(S.CompStmtItem _ s) -> s) l

tpaStmts :: S.CompStmtEmpty -> [D.Stmt]
tpaStmts (S.CompStmtEmpty _ ss) = map tpaStmt (extractStmt ss)
  where extractStmt l = map (\(S.CompStmtEmptyItem _ s) -> s) l

tpaStmt :: S.Stmt -> D.Stmt
tpaStmt (S.IfStmt p e1 ss ec) = D.IfStmt (ppa p) (tpaExpr e1) (tpaStmts ss) (tpaElse ec)
  where tpaElse Nothing = []
        tpaElse (Just (S.ElseCase _ ss)) = tpaStmts ss
tpaStmt (S.WhileStmt p e ss)          = D.WhileStmt (ppa p) (tpaExpr e) (tpaStmts ss)
tpaStmt (S.ForStmt p i rf rt ss)      = D.ForStmt (ppa p) (tpaIdentifier i) (tpaRange p rf rt) (tpaStmts ss)
tpaStmt (S.CallStmt p c)              = D.CallStmt (ppa p) (tpaCall c)
tpaStmt (S.BlockCallStmt p Nothing)   = D.BlockCallStmt (ppa p) [] []
tpaStmt (S.BlockCallStmt p (Just bc)) = D.BlockCallStmt (ppa p) ids (tpaStmts ss)
  where (ids, ss) = tpaBlockCall bc
tpaStmt (S.AssignStmt p (p', i) e)           = D.AssignStmt (ppa p) (D.IdExpr (ppa p') i) (tpaExpr e)
tpaStmt (S.IndexAssignStmt p (S.Index p' s e es) e2) = D.AssignStmt (ppa p) indexExpr (tpaExpr e2)
  where tpaIndexExprs l = map (\(S.IndexExprItem _ e) -> tpaExpr e) l
        indexExpr = D.IndexExpr (ppa p) (tpaSimpleExpr s) ((tpaExpr e):(tpaIndexExprs es))
tpaStmt (S.ReturnStmt p Nothing)            = D.ReturnStmt (ppa p) Nothing
tpaStmt (S.ReturnStmt p (Just e))           = D.ReturnStmt (ppa p) $ Just (tpaExpr e)
tpaStmt (S.DefStmt p (S.Def _ i pl ss)) = D.DefStmt (ppa p) (tpaDefIdentifier i) (tpaParamList pl) (tpaMaybeCompStmt ss)
  where tpaParamList Nothing                             = []
        tpaParamList (Just (S.ParamList _ i params)) = (tpaIdentifier i):(extractIds params)
        tpaParamList (Just (S.ParamList_0 _)) = []
        tpaMaybeCompStmt (Just ss)                       = tpa ss
        tpaMaybeCompStmt Nothing                         = []
        extractIds l                                     = map (\(S.Param _ i) -> (tpaIdentifier i)) l
tpaStmt (S.ClassStmt p  i cb) = D.ClassStmt (ppa p) (tpaIdentifier i) (tpaClassBody cb)
tpaStmt (S.Rescue p _ _) = D.RescueStmt (ppa p)
tpaStmt (S.Raise p _)  = D.RaiseStmt (ppa p)

tpaClassBody :: [S.ClassBody] -> [D.Stmt]
tpaClassBody l = map tpaClassItems l
  where tpaClassItems (S.ClassBody p' df) = tpaStmt (S.DefStmt p' df)
        tpaClassItems (S.Public p1)       = D.PublicStmt (ppa p1)
        tpaClassItems (S.Private p2)      = D.PrivateStmt (ppa p2)

tpaRange :: S.Pos -> S.Expr -> S.Expr -> D.Expr
tpaRange p a b = D.RangeExpr (ppa p) (tpaExpr a) (tpaExpr b)

tpaExpr :: S.Expr -> D.Expr
tpaExpr (S.Plus p e1 e2)      = D.OpExpr (ppa p) (tpaExpr e1) D.PlusOp (tpaExpr e2)
tpaExpr (S.Minus p e1 e2)     = D.OpExpr (ppa p) (tpaExpr e1) D.MinusOp (tpaExpr e2)
tpaExpr (S.Exp p e1 e2)       = D.OpExpr (ppa p) (tpaExpr e1) D.ExpOp (tpaExpr e2)
tpaExpr (S.Mult p e1 e2)      = D.OpExpr (ppa p) (tpaExpr e1) D.TimesOp (tpaExpr e2)
tpaExpr (S.Div p e1 e2)       = D.OpExpr (ppa p) (tpaExpr e1) D.DivOp (tpaExpr e2)
tpaExpr (S.Mod p e1 e2)       = D.OpExpr (ppa p) (tpaExpr e1) D.ModOp (tpaExpr e2)
tpaExpr (S.Equ p e1 e2)       = D.OpExpr (ppa p) (tpaExpr e1) D.EqOp (tpaExpr e2)
tpaExpr (S.Neq p e1 e2)       = D.OpExpr (ppa p) (tpaExpr e1) D.NeqOp (tpaExpr e2)
tpaExpr (S.Let p e1 e2)       = D.OpExpr (ppa p) (tpaExpr e1) D.LtOp (tpaExpr e2)
tpaExpr (S.Get p e1 e2)       = D.OpExpr (ppa p) (tpaExpr e1) D.GtOp (tpaExpr e2)
tpaExpr (S.Leq p e1 e2)       = D.OpExpr (ppa p) (tpaExpr e1) D.LeOp (tpaExpr e2)
tpaExpr (S.Geq p e1 e2)       = D.OpExpr (ppa p) (tpaExpr e1) D.GeOp (tpaExpr e2)
tpaExpr (S.And p e1 e2)       = D.OpExpr (ppa p) (tpaExpr e1) D.AndOp (tpaExpr e2)
tpaExpr (S.Or p e1 e2)        = D.OpExpr (ppa p) (tpaExpr e1) D.OrOp (tpaExpr e2)
tpaExpr (S.Range p e1 e2)     = tpaRange p e1 e2
tpaExpr (S.IfExpr p e1 e2 e3) = D.IfExpr (ppa p) (tpaExpr e1) (tpaExpr e2) (tpaExpr e3)
tpaExpr (S.Expr p s)          = tpaSimpleExpr s

tpaSimpleExpr :: S.SimpleExpr -> D.Expr
tpaSimpleExpr (S.NumExpr p (_, i))               = D.NumExpr (ppa p) i
tpaSimpleExpr (S.StringExpr p (_, s))            = D.StringExpr (ppa p) s
tpaSimpleExpr (S.BoolExpr p (_, b))              = D.BoolExpr (ppa p) b
tpaSimpleExpr (S.SymbolExpr p (S.Symbol _ i))    = D.SymbolExpr (ppa p) (tpaIdentifier i)
tpaSimpleExpr (S.ArrayExpr p a)                  = D.ArrayExpr (ppa p) (tpaArray a)
tpaSimpleExpr (S.HashExpr p h)                   = D.HashExpr (ppa p) (tpaHash h)
tpaSimpleExpr (S.RegexpExpr _ (p, s))            = D.RegexpExpr (ppa p) s
tpaSimpleExpr (S.CallExpr p ac)                  = D.CallExpr (ppa p) (tpaArgCall ac)
tpaSimpleExpr (S.ParenExpr _ e)                  = tpaExpr e
tpaSimpleExpr (S.IndexExpr _ (S.Index p s e es)) = D.IndexExpr (ppa p) (tpaSimpleExpr s) ((tpaExpr e):(tpaIndexExprs es))
  where tpaIndexExprs l = map (\(S.IndexExprItem _ e) -> tpaExpr e) l
tpaSimpleExpr (S.UnopExpr p (S.UnOpPlus _) s)        = D.UnopExpr (ppa p) "+" (tpaSimpleExpr s)
tpaSimpleExpr (S.UnopExpr p (S.UnOpMinus _) s)       = D.UnopExpr (ppa p) "-" (tpaSimpleExpr s)
tpaSimpleExpr (S.SimpleExpr p (S.IdExpr _ i)) = D.IdExpr (ppa p) (tpaIdentifier i)

tpaHash :: S.Hash -> [(D.Expr, D.Expr)]
tpaHash (S.Hash _ (S.Assocs _ a as)) = map tpaAssoc (a:extractAssocs as)
  where extractAssocs               = map (\(S.AssocItem _ a) -> a)
        tpaAssoc (S.Assoc _ e1 e2)  = (tpaExpr e1, tpaExpr e2)
tpaHash (S.Hash _ (S.Assocs_0 _ a as)) = map tpaSymAssoc (a:extractAssocs as)
  where extractAssocs                       = map (\(S.SymAssocItem _ a) -> a)
        tpaSymAssoc (S.SymAssoc _ (p, s) e) = (D.SymbolExpr (ppa p) s, tpaExpr e)

tpaArray :: S.Array -> [D.Expr]
tpaArray (S.Array _ (S.ExprList _ Nothing))    = []
tpaArray (S.Array _ (S.ExprList _ (Just eis))) = tpaExprItems eis
  where tpaExprItems (S.ExprListActual _ e1 es) = map tpaExpr (e1:extractExprs es)
        extractExprs                            = map (\(S.ExprItem _ e) -> e)

tpaCall :: S.Call -> D.Call
tpaCall (S.Call _ ac) = tpaArgCall ac
tpaCall (S.Call_0 _ (S.IdExpr _ i)) = D.Call Nothing (tpaIdentifier i) []

tpaArgCall :: S.ArgCall -> D.Call
tpaArgCall (S.ArgCall _ e i al) = D.Call (Just $ tpaSimpleExpr e) (tpaIdentifier i) (tpaArgList al)
tpaArgCall (S.ArgCall_0 _ i al) = D.Call Nothing (tpaIdentifier i) (tpaArgList (Just al))

tpaBlockCall :: S.BlockCall -> ([D.Id], S.CompStmtEmpty)
tpaBlockCall (S.BlockCall _p c (Just bps) ss) = ((tpaBlockParams bps), ss)
tpaBlockCall (S.BlockCall _p c Nothing ss)    = ([], ss)

tpaBlockParams :: S.BlockParams -> [D.Id]
tpaBlockParams (S.BlockParams _ i bps) = (tpaIdentifier i):extractIds bps
  where extractIds l = map (\(S.BlockParam _ i) -> (tpaIdentifier i)) l

tpaArgList :: Maybe S.ArgList -> [D.Expr]
tpaArgList Nothing = []
tpaArgList (Just (S.ArgList _ e1 as)) = map tpaExpr $ (e1:extractExprs as)
  where extractExprs    = map (\(S.Arg _ e) -> e)
tpaArgList (Just (S.NoArgs _)) = []

tpaIdentifier :: S.Identifier -> D.Id
tpaIdentifier (S.Identifier _ (_, ib) (Just ie)) = ib ++ (tpaIdAddon ie)
tpaIdentifier (S.Identifier _ (_, ib) Nothing)   = ib

tpaIdAddon :: S.IdAddon -> String
tpaIdAddon (S.EMark _) = "!"
tpaIdAddon (S.QMark _) = "?"

tpaDefIdentifier :: S.DefIdentifier -> D.Id
tpaDefIdentifier (S.DefIdentifier _ (_, ib) (Just ie)) = ib ++ (tpaIdAddon2 ie)
tpaDefIdentifier (S.DefIdentifier _ (_, ib) Nothing)   = ib

tpaIdAddon2 :: S.IdAddon2 -> String
tpaIdAddon2 (S.EMark2 _) = "!"
tpaIdAddon2 (S.QMark2 _) = "?"

ppa :: S.Pos -> D.Posn
ppa (a, b, c) = D.Posn a b c

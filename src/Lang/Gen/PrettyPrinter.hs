module Lang.Gen.PrettyPrinter where

import Text.PrettyPrint
import Lang.Gen.AST
import Lang.PPDoc

import qualified Data.Char as DChar

ppAST :: CompStmt -> PPDoc
ppAST = ppCompStmt

ppCompStmt :: CompStmt -> PPDoc
ppCompStmt (CompStmt pos a0 a1) = (posToken pos)
       ~~  (ppStmt a0)
       ~+~ (ppList a1 ppCompStmtItem)

ppStmt :: Stmt -> PPDoc
ppStmt (IfStmt pos a0 a1 a2) = (posToken pos)
       ~~  (stringToken "if")
       ~+~ (ppExpr a0)
       ~+~ (stringToken "then")
       ~+~ (ppCompStmtEmpty a1)
       ~+~ (ppMaybe a2 ppElseCase)
       ~+~ (stringToken "end")
ppStmt (WhileStmt pos a0 a1) = (posToken pos)
       ~~  (stringToken "while")
       ~+~ (ppExpr a0)
       ~+~ (stringToken "do")
       ~+~ (ppCompStmtEmpty a1)
       ~+~ (stringToken "end")
ppStmt (ForStmt pos a0 a1 a2 a3) = (posToken pos)
       ~~  (stringToken "for")
       ~+~ (ppIdentifier a0)
       ~+~ (stringToken "in")
       ~+~ (ppExpr a1)
       ~+~ (stringToken "..")
       ~+~ (ppExpr a2)
       ~+~ (ppCompStmtEmpty a3)
       ~+~ (stringToken "end")
ppStmt (CallStmt pos a0) = (posToken pos)
       ~~  (ppCall a0)
ppStmt (BlockCallStmt pos a0) = (posToken pos)
       ~~  (ppMaybe a0 ppBlockCall)
ppStmt (AssignStmt pos a0 a1) = (posToken pos)
       ~~  (ppid a0)
       ~+~ (stringToken "=")
       ~+~ (ppExpr a1)
ppStmt (IndexAssignStmt pos a0 a1) = (posToken pos)
       ~~  (ppIndexExpr a0)
       ~+~ (stringToken "=")
       ~+~ (ppExpr a1)
ppStmt (ReturnStmt pos a0) = (posToken pos)
       ~~  (stringToken "return")
       ~+~ (ppMaybe a0 ppExpr)
ppStmt (DefStmt pos a0) = (posToken pos)
       ~~  (ppDef a0)
ppStmt (ClassStmt pos a0 a1) = (posToken pos)
       ~~  (stringToken "class")
       ~+~ (ppIdentifier a0)
       ~+~ (ppList a1 ppClassBody)
       ~+~ (stringToken "end")
ppStmt (Rescue pos a0 a1) = (posToken pos)
       ~~  (stringToken "begin")
       ~+~ (ppCompStmtEmpty a0)
       ~+~ (ppRescueBlock a1)
ppStmt (Raise pos a0) = (posToken pos)
       ~~  (stringToken "raise")
       ~+~ (ppRaiseArgument a0)

ppT :: T -> PPDoc
ppT (T pos ) = (posToken pos)
       ~~  (stringToken ";")
ppT (T_0 pos a0) = (posToken pos)
       ~~  (ppMaybe a0 ppnl)

ppCompStmtItem :: CompStmtItem -> PPDoc
ppCompStmtItem (CompStmtItem pos a0) = (posToken pos)
       ~~  (ppStmt a0)

ppCompStmtEmpty :: CompStmtEmpty -> PPDoc
ppCompStmtEmpty (CompStmtEmpty pos a0) = (posToken pos)
       ~~  (ppList a0 ppCompStmtEmptyItem)

ppCompStmtEmptyItem :: CompStmtEmptyItem -> PPDoc
ppCompStmtEmptyItem (CompStmtEmptyItem pos a0) = (posToken pos)
       ~~  (ppStmt a0)

ppT2 :: T2 -> PPDoc
ppT2 (T2 pos ) = (posToken pos)
       ~~  (stringToken ";")
ppT2 (T2_0 pos a0) = (posToken pos)
       ~~  (ppnl a0)

ppExpr :: Expr -> PPDoc
ppExpr (Plus pos a0 a1) = (posToken pos)
       ~~  (ppExpr a0)
       ~+~ (stringToken "+")
       ~+~ (ppExpr a1)
ppExpr (Minus pos a0 a1) = (posToken pos)
       ~~  (ppExpr a0)
       ~+~ (stringToken "-")
       ~+~ (ppExpr a1)
ppExpr (Exp pos a0 a1) = (posToken pos)
       ~~  (ppExpr a0)
       ~+~ (stringToken "**")
       ~+~ (ppExpr a1)
ppExpr (Mult pos a0 a1) = (posToken pos)
       ~~  (ppExpr a0)
       ~+~ (stringToken "*")
       ~+~ (ppExpr a1)
ppExpr (Div pos a0 a1) = (posToken pos)
       ~~  (ppExpr a0)
       ~+~ (stringToken "/")
       ~+~ (ppExpr a1)
ppExpr (Mod pos a0 a1) = (posToken pos)
       ~~  (ppExpr a0)
       ~+~ (stringToken "%")
       ~+~ (ppExpr a1)
ppExpr (Equ pos a0 a1) = (posToken pos)
       ~~  (ppExpr a0)
       ~+~ (stringToken "==")
       ~+~ (ppExpr a1)
ppExpr (Neq pos a0 a1) = (posToken pos)
       ~~  (ppExpr a0)
       ~+~ (stringToken "!=")
       ~+~ (ppExpr a1)
ppExpr (Let pos a0 a1) = (posToken pos)
       ~~  (ppExpr a0)
       ~+~ (stringToken "<")
       ~+~ (ppExpr a1)
ppExpr (Get pos a0 a1) = (posToken pos)
       ~~  (ppExpr a0)
       ~+~ (stringToken ">")
       ~+~ (ppExpr a1)
ppExpr (Leq pos a0 a1) = (posToken pos)
       ~~  (ppExpr a0)
       ~+~ (stringToken "<=")
       ~+~ (ppExpr a1)
ppExpr (Geq pos a0 a1) = (posToken pos)
       ~~  (ppExpr a0)
       ~+~ (stringToken ">=")
       ~+~ (ppExpr a1)
ppExpr (And pos a0 a1) = (posToken pos)
       ~~  (ppExpr a0)
       ~+~ (stringToken "&&")
       ~+~ (ppExpr a1)
ppExpr (Or pos a0 a1) = (posToken pos)
       ~~  (ppExpr a0)
       ~+~ (stringToken "||")
       ~+~ (ppExpr a1)
ppExpr (Range pos a0 a1) = (posToken pos)
       ~~  (ppExpr a0)
       ~+~ (stringToken "..")
       ~+~ (ppExpr a1)
ppExpr (IfExpr pos a0 a1 a2) = (posToken pos)
       ~~  (stringToken "if")
       ~+~ (ppExpr a0)
       ~+~ (stringToken "then")
       ~+~ (ppExpr a1)
       ~+~ (stringToken "else")
       ~+~ (ppExpr a2)
       ~+~ (stringToken "end")
ppExpr (Expr pos a0) = (posToken pos)
       ~~  (ppSimpleExpr a0)

ppElseCase :: ElseCase -> PPDoc
ppElseCase (ElseCase pos a0) = (posToken pos)
       ~~  (stringToken "else")
       ~+~ (ppCompStmtEmpty a0)

ppIdentifier :: Identifier -> PPDoc
ppIdentifier (Identifier pos a0 a1) = (posToken pos)
       ~~  (ppid a0)
       ~+~ (ppMaybe a1 ppIdAddon)

ppDoOpt :: DoOpt -> PPDoc
ppDoOpt (DoOpt pos ) = (posToken pos)
       ~~  (stringToken "do")
ppDoOpt (DoOpt_0 pos ) = (posToken pos)
ppCall :: Call -> PPDoc
ppCall (Call pos a0) = (posToken pos)
       ~~  (ppArgCall a0)
ppCall (Call_0 pos a0) = (posToken pos)
       ~~  (ppIdExpr a0)

ppBlockCall :: BlockCall -> PPDoc
ppBlockCall (BlockCall pos a0 a1 a2) = (posToken pos)
       ~~  (ppCall a0)
       ~+~ (stringToken "do")
       ~+~ (ppMaybe a1 ppBlockParams)
       ~+~ (ppCompStmtEmpty a2)
       ~+~ (stringToken "end")

ppIndexExpr :: IndexExpr -> PPDoc
ppIndexExpr (Index pos a0 a1 a2) = (posToken pos)
       ~~  (ppSimpleExpr a0)
       ~+~ (stringToken "[")
       ~+~ (ppExpr a1)
       ~+~ (ppList a2 ppIndexExprItem)
       ~+~ (stringToken "]")

ppDef :: Def -> PPDoc
ppDef (Def pos a0 a1 a2) = (posToken pos)
       ~~  (stringToken "/def/")
       ~+~ (ppDefIdentifier a0)
       ~+~ (ppMaybe a1 ppParamList)
       ~+~ (ppMaybe a2 ppCompStmt)
       ~+~ (stringToken "end")

ppClassBody :: ClassBody -> PPDoc
ppClassBody (ClassBody pos a0) = (posToken pos)
       ~~  (ppDef a0)
ppClassBody (Public pos ) = (posToken pos)
       ~~  (stringToken "public")
ppClassBody (Private pos ) = (posToken pos)
       ~~  (stringToken "private")

ppRescueBlock :: RescueBlock -> PPDoc
ppRescueBlock (RescueBlock pos a0 a1 a2) = (posToken pos)
       ~~  (stringToken "rescue")
       ~+~ (ppMaybe a0 ppExceptionClass)
       ~+~ (ppMaybe a1 ppExceptionAssignment)
       ~+~ (ppCompStmtEmpty a2)
       ~+~ (stringToken "end")

ppRaiseArgument :: RaiseArgument -> PPDoc
ppRaiseArgument (RaiseArgument pos a0) = (posToken pos)
       ~~  (ppIdentifier a0)
ppRaiseArgument (RaiseArgument_0 pos a0) = (posToken pos)
       ~~  (ppArgCall a0)

ppArgCall :: ArgCall -> PPDoc
ppArgCall (ArgCall pos a0 a1 a2) = (posToken pos)
       ~~  (ppSimpleExpr a0)
       ~+~ (stringToken ".")
       ~+~ (ppIdentifier a1)
       ~+~ (ppMaybe a2 ppArgList)
ppArgCall (ArgCall_0 pos a0 a1) = (posToken pos)
       ~~  (ppIdentifier a0)
       ~+~ (ppArgList a1)

ppIdAddon :: IdAddon -> PPDoc
ppIdAddon (QMark pos ) = (posToken pos)
       ~~  (stringToken "?")
ppIdAddon (EMark pos ) = (posToken pos)
       ~~  (stringToken "!")

ppDefIdentifier :: DefIdentifier -> PPDoc
ppDefIdentifier (DefIdentifier pos a0 a1) = (posToken pos)
       ~~  (ppdefId a0)
       ~+~ (ppMaybe a1 ppIdAddon2)

ppIdAddon2 :: IdAddon2 -> PPDoc
ppIdAddon2 (QMark2 pos ) = (posToken pos)
       ~~  (stringToken "?")
ppIdAddon2 (EMark2 pos ) = (posToken pos)
       ~~  (stringToken "!")

ppParamList :: ParamList -> PPDoc
ppParamList (ParamList pos a0 a1) = (posToken pos)
       ~~  (stringToken "(")
       ~+~ (ppIdentifier a0)
       ~+~ (ppList a1 ppParam)
       ~+~ (stringToken ")")
ppParamList (ParamList_0 pos ) = (posToken pos)
       ~~  (stringToken "()")

ppIdExpr :: IdExpr -> PPDoc
ppIdExpr (IdExpr pos a0) = (posToken pos)
       ~~  (ppIdentifier a0)

ppSimpleExpr :: SimpleExpr -> PPDoc
ppSimpleExpr (NumExpr pos a0) = (posToken pos)
       ~~  (ppnumber a0)
ppSimpleExpr (StringExpr pos a0) = (posToken pos)
       ~~  (ppstring a0)
ppSimpleExpr (BoolExpr pos a0) = (posToken pos)
       ~~  (ppbool a0)
ppSimpleExpr (SymbolExpr pos a0) = (posToken pos)
       ~~  (ppSymbol a0)
ppSimpleExpr (ArrayExpr pos a0) = (posToken pos)
       ~~  (ppArray a0)
ppSimpleExpr (HashExpr pos a0) = (posToken pos)
       ~~  (ppHash a0)
ppSimpleExpr (RegexpExpr pos a0) = (posToken pos)
       ~~  (ppregexp a0)
ppSimpleExpr (CallExpr pos a0) = (posToken pos)
       ~~  (ppArgCall a0)
ppSimpleExpr (ParenExpr pos a0) = (posToken pos)
       ~~  (stringToken "(")
       ~+~ (ppExpr a0)
       ~+~ (stringToken ")")
ppSimpleExpr (IndexExpr pos a0) = (posToken pos)
       ~~  (ppIndexExpr a0)
ppSimpleExpr (UnopExpr pos a0 a1) = (posToken pos)
       ~~  (ppUnop a0)
       ~+~ (ppSimpleExpr a1)
ppSimpleExpr (SimpleExpr pos a0) = (posToken pos)
       ~~  (ppIdExpr a0)

ppArgList :: ArgList -> PPDoc
ppArgList (ArgList pos a0 a1) = (posToken pos)
       ~~  (stringToken "(")
       ~+~ (ppExpr a0)
       ~+~ (ppList a1 ppArg)
       ~+~ (stringToken ")")
ppArgList (NoArgs pos ) = (posToken pos)
       ~~  (stringToken "()")

ppBlockParams :: BlockParams -> PPDoc
ppBlockParams (BlockParams pos a0 a1) = (posToken pos)
       ~~  (stringToken "|")
       ~+~ (ppIdentifier a0)
       ~+~ (ppList a1 ppBlockParam)
       ~+~ (stringToken "|")

ppBlockParam :: BlockParam -> PPDoc
ppBlockParam (BlockParam pos a0) = (posToken pos)
       ~~  (stringToken ",")
       ~+~ (ppIdentifier a0)

ppArg :: Arg -> PPDoc
ppArg (Arg pos a0) = (posToken pos)
       ~~  (stringToken ",")
       ~+~ (ppExpr a0)

ppParam :: Param -> PPDoc
ppParam (Param pos a0) = (posToken pos)
       ~~  (stringToken ",")
       ~+~ (ppIdentifier a0)

ppSymbol :: Symbol -> PPDoc
ppSymbol (Symbol pos a0) = (posToken pos)
       ~~  (stringToken ":")
       ~+~ (ppIdentifier a0)

ppArray :: Array -> PPDoc
ppArray (Array pos a0) = (posToken pos)
       ~~  (stringToken "[")
       ~+~ (ppExprList a0)
       ~+~ (stringToken "]")

ppHash :: Hash -> PPDoc
ppHash (Hash pos a0) = (posToken pos)
       ~~  (stringToken "{")
       ~+~ (ppAssocs a0)
       ~+~ (stringToken "}")

ppUnop :: Unop -> PPDoc
ppUnop (UnOpPlus pos ) = (posToken pos)
       ~~  (stringToken "+")
ppUnop (UnOpMinus pos ) = (posToken pos)
       ~~  (stringToken "-")

ppExprList :: ExprList -> PPDoc
ppExprList (ExprList pos a0) = (posToken pos)
       ~~  (ppMaybe a0 ppExprListActual)

ppExprListActual :: ExprListActual -> PPDoc
ppExprListActual (ExprListActual pos a0 a1) = (posToken pos)
       ~~  (ppExpr a0)
       ~+~ (ppList a1 ppExprItem)

ppExprItem :: ExprItem -> PPDoc
ppExprItem (ExprItem pos a0) = (posToken pos)
       ~~  (stringToken ",")
       ~+~ (ppExpr a0)

ppAssocs :: Assocs -> PPDoc
ppAssocs (Assocs pos a0 a1) = (posToken pos)
       ~~  (ppAssoc a0)
       ~+~ (ppList a1 ppAssocItem)
ppAssocs (Assocs_0 pos a0 a1) = (posToken pos)
       ~~  (ppSymAssoc a0)
       ~+~ (ppList a1 ppSymAssocItem)

ppAssoc :: Assoc -> PPDoc
ppAssoc (Assoc pos a0 a1) = (posToken pos)
       ~~  (ppExpr a0)
       ~+~ (stringToken "=>")
       ~+~ (ppExpr a1)

ppAssocItem :: AssocItem -> PPDoc
ppAssocItem (AssocItem pos a0) = (posToken pos)
       ~~  (stringToken ",")
       ~+~ (ppAssoc a0)

ppSymAssoc :: SymAssoc -> PPDoc
ppSymAssoc (SymAssoc pos a0 a1) = (posToken pos)
       ~~  (ppsymassocid a0)
       ~+~ (ppExpr a1)

ppSymAssocItem :: SymAssocItem -> PPDoc
ppSymAssocItem (SymAssocItem pos a0) = (posToken pos)
       ~~  (stringToken ",")
       ~+~ (ppSymAssoc a0)

ppIndexExprItem :: IndexExprItem -> PPDoc
ppIndexExprItem (IndexExprItem pos a0) = (posToken pos)
       ~~  (stringToken ",")
       ~+~ (ppExpr a0)

ppExceptionClass :: ExceptionClass -> PPDoc
ppExceptionClass (ExceptionClass pos a0) = (posToken pos)
       ~~  (ppIdentifier a0)

ppExceptionAssignment :: ExceptionAssignment -> PPDoc
ppExceptionAssignment (ExceptionAssignment pos a0) = (posToken pos)
       ~~  (stringToken "=>")
       ~+~ (ppIdentifier a0)

ppstring :: (Pos, String) -> PPDoc
ppstring (pos,a) = lexToken pos (((\s -> "\"" ++ s ++ "\"")) a)         
ppregexp :: (Pos, String) -> PPDoc
ppregexp (pos,a) = lexToken pos (a)         
ppbool :: (Pos, Bool) -> PPDoc
ppbool (pos,a) = lexToken pos (((\b -> (\(c:cs) -> (DChar.toLower c) : cs) $ show b)) a)         
ppid :: (Pos, String) -> PPDoc
ppid (pos,a) = lexToken pos (a)         
ppdefId :: (Pos, String) -> PPDoc
ppdefId (pos,a) = lexToken pos (a)         
ppnumber :: (Pos, String) -> PPDoc
ppnumber (pos,a) = lexToken pos (a)         
ppsymassocid :: (Pos, String) -> PPDoc
ppsymassocid (pos,a) = lexToken pos (a)         
ppcomment :: (Pos, String) -> PPDoc
ppcomment (pos,a) = lexToken pos (a)         
ppnl :: (Pos, String) -> PPDoc
ppnl (pos,a) = lexToken pos (a)         

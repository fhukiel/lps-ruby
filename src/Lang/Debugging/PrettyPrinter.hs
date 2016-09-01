--------------------------------------------------------------------------------
-- Author: Thomas Ulrich, 2016                                                --
--------------------------------------------------------------------------------

module Lang.Debugging.PrettyPrinter where

import Text.PrettyPrint
import Lang.Debugging.TAST
import Lang.PPDoc

import qualified Data.Char as DChar

ppAST :: TAST -> PPDoc
ppAST (TAST (RequiredImports imports) (RequiredHelpers helpers) compStmt) =         
        (stringToken imports)
    ~$~ (stringToken helpers)
    ~$~ (ppCompStmt  compStmt)

ppCompStmt :: TCompStmt -> PPDoc
ppCompStmt (TCompStmt pos stmt compStmtItems) = 
           (posToken pos)
       ~~  (ppStmt stmt)
       ~+~ (ppList compStmtItems $ ppCompStmtItem)

ppStmt :: TStmt -> PPDoc
ppStmt (TIfStmt pos maybePosUpdate expr compStmtEmpty maybeElse) = 
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (stringToken "if")
       ~+~ (ppExpr expr)
       ~+~ (stringToken "then")
       ~+~ (ppCompStmtEmpty compStmtEmpty)
       ~+~ (ppMaybe maybeElse $ ppElseCase)
       ~+~ (stringToken "end;")
ppStmt (TWhileStmt pos maybePosUpdate expr compStmtEmpty) = 
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (stringToken "while")
       ~+~ (ppExpr expr)
       ~+~ (stringToken "do")
       ~+~ (ppCompStmtEmpty compStmtEmpty)
       ~+~ (stringToken "end;")
ppStmt (TForStmt pos maybePosUpdate identifier expr1 expr2 tableUpdate compStmtEmpty) = 
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (stringToken "for")
       ~+~ (ppIdentifier identifier)
       ~+~ (stringToken "in")
       ~+~ (ppExpr expr1)
       ~+~ (stringToken "..")
       ~+~ (ppExpr expr2)
       ~+~ (ppTableUpdate tableUpdate)
       ~+~ (ppCompStmtEmpty compStmtEmpty)
       ~+~ (stringToken "end;")
ppStmt (TCallStmt pos maybePosUpdate call) = 
          (posToken pos)
       ~~ (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~ (ppCall call)
       ~~ (stringToken ";")
ppStmt (TBlockCallStmt pos maybePosUpdate maybeBlockCall) = 
           (posToken pos)
       ~~ (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~ (ppMaybe maybeBlockCall $ ppBlockCall)
ppStmt (TAssignStmt pos maybePosUpdate identifier expr tableUpdate) = 
           (posToken pos)
       ~~ (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (ppid identifier)
       ~+~ (stringToken "=")
       ~+~ (ppExpr expr)
       ~+~ (stringToken ";")
       ~+~ (ppTableUpdate tableUpdate)
ppStmt (TIndexAssignStmt pos maybePosUpdate indexExpr expr tableUpdate) = 
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (ppIndexExpr indexExpr)
       ~+~ (stringToken "=")
       ~+~ (ppExpr expr)
       ~+~ (ppTableUpdate tableUpdate)
ppStmt (TReturnStmt pos maybePosUpdate (maybeStmt, maybePop, verbatim)) = 
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (ppMaybe maybeStmt $ ppStmt)
       ~~  (ppMaybe maybePop $ ppPopStmt)
       ~~  (ppVerbatim verbatim)
ppStmt (TDefStmt pos maybePosUpdate def) = 
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (ppDef def)
ppStmt (TClassStmt pos maybePosUpdate identifier classBodies) = 
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (stringToken "class")
       ~+~ (ppIdentifier identifier)
       ~+~ (stringToken "\n")
       ~+~ (ppList classBodies $ ppClassBody)
       ~+~ (stringToken "end;")
ppStmt (TRescueStmt pos maybePosUpdate compStmtEmpty rescueBlock) = 
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (stringToken "begin")
       ~~  (ppCompStmtEmpty compStmtEmpty)
       ~~  (ppRescueBlock rescueBlock)
ppStmt (TRaiseStmt pos maybePosUpdate raiseArgument) = 
            (posToken pos)
       ~~   (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~   (stringToken "raise")
       ~+~  (ppRaiseArgument raiseArgument)
	   
ppT :: TT -> PPDoc
ppT (TT pos maybePosUpdate) = 
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (stringToken ";")
ppT (TT_0 pos maybePosUpdate maybeNewline) = 
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (ppMaybe maybeNewline $ ppnl)

ppCompStmtItem :: TCompStmtItem -> PPDoc
ppCompStmtItem (TCompStmtItem pos maybePosUpdate stmt) = 
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (ppStmt stmt)

ppCompStmtEmpty :: TCompStmtEmpty -> PPDoc
ppCompStmtEmpty (TCompStmtEmpty pos maybePosUpdate compStmtEmptyItems) = 
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (ppList compStmtEmptyItems $ ppCompStmtEmptyItem)

ppCompStmtEmptyItem ::TCompStmtEmptyItem -> PPDoc
ppCompStmtEmptyItem (TCompStmtEmptyItem pos maybePosUpdate stmt) = 
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (ppStmt stmt)

ppT2 :: TT2 -> PPDoc
ppT2 (TT2 pos maybePosUpdate) = 
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (stringToken ";")
ppT2 (TT2_0 pos maybePosUpdate newline) = 
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (ppnl newline)

ppExpr :: TExpr -> PPDoc
ppExpr (TPlus pos maybePosUpdate expr1 expr2) = 
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (ppExpr expr1)
       ~+~ (stringToken "+")
       ~+~ (ppExpr expr2)
ppExpr (TMinus pos maybePosUpdate expr1 expr2) = 
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (ppExpr expr1)
       ~+~ (stringToken "-")
       ~+~ (ppExpr expr2)
ppExpr (TExp pos maybePosUpdate expr1 expr2) =
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (ppExpr expr1)
       ~+~ (stringToken "**")
       ~+~ (ppExpr expr2)
ppExpr (TMult pos maybePosUpdate expr1 expr2) = 
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (ppExpr expr1)
       ~+~ (stringToken "*")
       ~+~ (ppExpr expr2)
ppExpr (TDiv pos maybePosUpdate expr1 expr2) =
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (ppExpr expr1)
       ~+~ (stringToken "/")
       ~+~ (ppExpr expr2)
ppExpr (TMod pos maybePosUpdate expr1 expr2) =
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (ppExpr expr1)
       ~+~ (stringToken "%")
       ~+~ (ppExpr expr2)
ppExpr (TEqu pos maybePosUpdate expr1 expr2) =
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (ppExpr expr1)
       ~+~ (stringToken "==")
       ~+~ (ppExpr expr2)
ppExpr (TNeq pos maybePosUpdate expr1 expr2) = 
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (ppExpr expr1)
       ~+~ (stringToken "!=")
       ~+~ (ppExpr expr2)
ppExpr (TLet pos maybePosUpdate expr1 expr2) = 
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (ppExpr expr1)
       ~+~ (stringToken "<")
       ~+~ (ppExpr expr2)
ppExpr (TGet pos maybePosUpdate expr1 expr2) = 
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (ppExpr expr1)
       ~+~ (stringToken ">")
       ~+~ (ppExpr expr2)
ppExpr (TLeq pos maybePosUpdate expr1 expr2) =
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (ppExpr expr1)
       ~+~ (stringToken "<=")
       ~+~ (ppExpr expr2)
ppExpr (TGeq pos maybePosUpdate expr1 expr2) =
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (ppExpr expr1)
       ~+~ (stringToken ">=")
       ~+~ (ppExpr expr2)
ppExpr (TAnd pos maybePosUpdate expr1 expr2) =
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (ppExpr expr1)
       ~+~ (stringToken "&&")
       ~+~ (ppExpr expr2)
ppExpr (TOr pos maybePosUpdate expr1 expr2) =
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (ppExpr expr1)
       ~+~ (stringToken "||")
       ~+~ (ppExpr expr2)
ppExpr (TRange pos maybePosUpdate expr1 expr2) =
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (ppExpr expr1)
       ~+~ (stringToken "..")
       ~+~ (ppExpr expr2)
ppExpr (TIfExpr pos maybePosUpdate expr1 expr2 expr3) =
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (stringToken "if")
       ~+~ (ppExpr expr1)
       ~+~ (stringToken "then")
       ~+~ (ppExpr expr2)
       ~+~ (stringToken "else")
       ~+~ (ppExpr expr3)
       ~+~ (stringToken "end;")
ppExpr (TExpr pos maybePosUpdate simpleExpr) =
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (ppSimpleExpr simpleExpr)

ppElseCase ::TElseCase -> PPDoc
ppElseCase (TElseCase pos maybePosUpdate compStmtEmpty) =
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (stringToken "else")
       ~+~ (ppCompStmtEmpty compStmtEmpty)

ppIdentifier :: TIdentifier -> PPDoc
ppIdentifier (TIdentifier pos maybePosUpdate identifier maybeIdAddon) = 
          (posToken pos)
       ~~ (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~ (ppid identifier)
       ~~ (ppMaybe maybeIdAddon $ ppIdAddon)

ppDoOpt :: TDoOpt -> PPDoc
ppDoOpt (TDoOpt pos maybePosUpdate) = 
          (posToken pos)
       ~~ (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~ (stringToken "do")
ppDoOpt (TDoOpt_0 pos maybePosUpdate) =
          (posToken pos)
       ~~ (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~ (stringToken "do")

ppCall :: TCall -> PPDoc
ppCall (TCall pos maybePosUpdate argCall) = 
          (posToken pos)
       ~~ (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~ (ppArgCall argCall)
ppCall (TCall_0 pos maybePosUpdate idExpr) =
          (posToken pos)
       ~~ (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~ (ppIdExpr idExpr)

ppBlockCall :: TBlockCall -> PPDoc
ppBlockCall (TBlockCall pos maybePosUpdate call maybeBlockParam begin push tableUpdateStmts compStmtEmpty pop rescueBlock) =
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (ppCall call)
       ~+~ (stringToken "do")
       ~+~ (ppMaybe maybeBlockParam $ ppBlockParams)
       ~~  (ppBegin begin)
       ~~  (ppPushStmt push)
       ~~  (ppList tableUpdateStmts $ ppTableUpdate)
       ~+~ (ppCompStmtEmpty compStmtEmpty)
       ~~  (ppPopStmt pop)
       ~~  (ppGeneratedRescueBlock rescueBlock)
       ~+~ (stringToken "end;")

ppIndexExpr :: TIndexExpr -> PPDoc
ppIndexExpr (TIndex pos maybePosUpdate simpleExpr expr indexExprItems) = 
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (ppSimpleExpr simpleExpr)
       ~+~ (stringToken "[")
       ~+~ (ppExpr expr)
       ~+~ (ppList indexExprItems $ ppIndexExprItem)
       ~+~ (stringToken "]")

ppDef :: TDef -> PPDoc
ppDef (TDef pos maybePosUpdate defIdentifier maybeParamList begin push maybeCompStmt pop rescueBlock) =
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (stringToken "def")
       ~+~ (ppDefIdentifier defIdentifier)
       ~~  (ppMaybe maybeParamList $ ppParamList)
       ~~  (stringToken "\n")
       ~~  (ppBegin begin)
       ~~  (ppPushStmt push)
       ~+~ (ppMaybe maybeCompStmt $ ppCompStmt)
       ~+~ (ppPopStmt pop)
       ~~  (ppGeneratedRescueBlock rescueBlock)
       ~+~ (stringToken "end;")

ppClassBody :: TClassBody -> PPDoc
ppClassBody (TClassBody pos maybePosUpdate def) =
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (ppDef def)
ppClassBody (TPublic pos maybePosUpdate) =
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (stringToken "public")
ppClassBody (TPrivate pos maybePosUpdate) =
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (stringToken "private")

ppIdAddon :: TIdAddon -> PPDoc
ppIdAddon (TQMark pos maybePosUpdate) =
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (stringToken "?")
ppIdAddon (TEMark pos maybePosUpdate) = 
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (stringToken "!")

ppDefIdentifier :: TDefIdentifier -> PPDoc
ppDefIdentifier (TDefIdentifier pos maybePosUpdate defIdentifier maybeIdAddon2) =
          (posToken pos)
       ~~ (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~ (ppdefId defIdentifier)
       ~~ (ppMaybe maybeIdAddon2 $ ppIdAddon2)

ppIdAddon2 :: TIdAddon2 -> PPDoc
ppIdAddon2 (TQMark2 pos maybePosUpdate) = 
          (posToken pos)
       ~~ (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~ (stringToken "?")
ppIdAddon2 (TEMark2 pos maybePosUpdate) =
          (posToken pos)
       ~~ (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~ (stringToken "!")

ppParamList :: TParamList -> PPDoc
ppParamList (TParamList pos maybePosUpdate identifier params) =
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (stringToken "(")
       ~+~ (ppIdentifier identifier)
       ~+~ (ppList params $ ppParam)
       ~+~ (stringToken ")")
ppParamList (TParamList_0 pos maybePosUpdate) = 
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (stringToken "()")

ppArgCall :: TArgCall -> PPDoc
ppArgCall (TArgCall pos maybePosUpdate simpleExpr identifier maybeArgList) = 
          (posToken pos)
       ~~ (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~ (ppSimpleExpr simpleExpr)
       ~~ (stringToken ".")
       ~~ (ppIdentifier identifier)
       ~~ (ppMaybe maybeArgList $ ppArgList)
ppArgCall (TArgCall_0 pos maybePosUpdate identifier argList) =
          (posToken pos)
       ~~ (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~ (ppIdentifier identifier)
       ~~ (ppArgList argList)

ppIdExpr :: TIdExpr -> PPDoc
ppIdExpr (TIdExpr pos maybePosUpdate identifier) =
          (posToken pos)
       ~~ (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~ (ppIdentifier identifier)

ppSimpleExpr :: TSimpleExpr -> PPDoc
ppSimpleExpr (TNumExpr pos maybePosUpdate number) =
          (posToken pos)
       ~~ (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~ (ppnumber number)
ppSimpleExpr (TStringExpr pos maybePosUpdate string) =
          (posToken pos)
       ~~ (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~ (ppstring string)
ppSimpleExpr (TBoolExpr pos maybePosUpdate bool) =
          (posToken pos)
       ~~ (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~ (ppbool bool)
ppSimpleExpr (TSymbolExpr pos maybePosUpdate symbol) =
          (posToken pos)
       ~~ (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~ (ppSymbol symbol)
ppSimpleExpr (TArrayExpr pos maybePosUpdate array) =
          (posToken pos)
       ~~ (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~ (ppArray array)
ppSimpleExpr (THashExpr pos maybePosUpdate hash) =
          (posToken pos)
       ~~ (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~ (ppHash hash)
ppSimpleExpr (TRegexpExpr pos maybePosUpdate regex) =
          (posToken pos)
       ~~ (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~ (ppregexp regex)
ppSimpleExpr (TCallExpr pos maybePosUpdate argCall) =
          (posToken pos)
       ~~ (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~ (ppArgCall argCall)
ppSimpleExpr (TParenExpr pos maybePosUpdate expr) =
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (stringToken "(")
       ~+~ (ppExpr expr)
       ~+~ (stringToken ")")
ppSimpleExpr (TIndexExpr pos maybePosUpdate indexExpr) =
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (ppIndexExpr indexExpr)
ppSimpleExpr (TUnopExpr pos maybePosUpdate unop simpleExpr) =
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (ppUnop unop)
       ~+~ (ppSimpleExpr simpleExpr)
ppSimpleExpr (TSimpleExpr pos maybePosUpdate idExpr) =
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (ppIdExpr idExpr)

ppArgList :: TArgList -> PPDoc
ppArgList (TArgList pos maybePosUpdate expr args) =
          (posToken pos)
       ~~ (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~ (stringToken "(")
       ~~ (ppExpr expr)
       ~~ (ppList args $ ppArg)
       ~~ (stringToken ")")
ppArgList (TNoArgs pos maybePosUpdate) = 
          (posToken pos)
       ~~ (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~ (stringToken "()")

ppBlockParams :: TBlockParams -> PPDoc
ppBlockParams (TBlockParams pos maybePosUpdate identifier blockParams) =
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (stringToken "|")
       ~+~ (ppIdentifier identifier)
       ~+~ (ppList blockParams $ ppBlockParam)
       ~+~ (stringToken "|")

ppBlockParam :: TBlockParam -> PPDoc
ppBlockParam (TBlockParam pos maybePosUpdate identifier) =
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (stringToken ",")
       ~+~ (ppIdentifier identifier)

ppArg :: TArg -> PPDoc
ppArg (TArg pos maybePosUpdate expr) = 
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (stringToken ",")
       ~+~ (ppExpr expr)

ppParam :: TParam -> PPDoc
ppParam (TParam pos maybePosUpdate identifier) =
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (stringToken ",")
       ~+~ (ppIdentifier identifier)

ppSymbol :: TSymbol -> PPDoc
ppSymbol (TSymbol pos maybePosUpdate identifier) =
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (stringToken ":")
       ~+~ (ppIdentifier identifier)

ppArray :: TArray -> PPDoc
ppArray (TArray pos maybePosUpdate exprList) =
          (posToken pos)
       ~~ (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~ (stringToken "[")
       ~~ (ppExprList exprList)
       ~~ (stringToken "]")

ppHash :: THash -> PPDoc
ppHash (THash pos maybePosUpdate assocs) =
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (stringToken "{")
       ~+~ (ppAssocs assocs)
       ~+~ (stringToken "}")

ppUnop :: TUnop -> PPDoc
ppUnop (TUnOpPlus pos maybePosUpdate) =
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (stringToken "+")
ppUnop (TUnOpMinus pos maybePosUpdate) =
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (stringToken "-")

ppExprList :: TExprList -> PPDoc
ppExprList (TExprList pos maybePosUpdate maybeExprListActual) =
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (ppMaybe maybeExprListActual $ ppExprListActual)

ppExprListActual :: TExprListActual -> PPDoc
ppExprListActual (TExprListActual pos maybePosUpdate expr exprItems) =
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (ppExpr expr)
       ~+~ (ppList exprItems $ ppExprItem)

ppExprItem :: TExprItem -> PPDoc
ppExprItem (TExprItem pos maybePosUpdate expr) =
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (stringToken ",")
       ~+~ (ppExpr expr)

ppAssocs :: TAssocs -> PPDoc
ppAssocs (TAssocs pos maybePosUpdate assoc assocItems) =
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (ppAssoc assoc)
       ~+~ (ppList assocItems $ ppAssocItem)
ppAssocs (TAssocs_0 pos maybePosUpdate symAssoc symAssocItems) =
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (ppSymAssoc symAssoc)
       ~+~ (ppList symAssocItems $ ppSymAssocItem)

ppAssoc :: TAssoc -> PPDoc
ppAssoc (TAssoc pos maybePosUpdate expr1 expr2) =
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (ppExpr expr1)
       ~+~ (stringToken "=>")
       ~+~ (ppExpr expr2)

ppAssocItem :: TAssocItem -> PPDoc
ppAssocItem (TAssocItem pos maybePosUpdate assoc) =
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (stringToken ",")
       ~+~ (ppAssoc assoc)

ppSymAssoc :: TSymAssoc -> PPDoc
ppSymAssoc (TSymAssoc pos maybePosUpdate symassoc expr) =
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (ppsymassocid symassoc)
       ~+~ (ppExpr expr)

ppSymAssocItem ::TSymAssocItem -> PPDoc
ppSymAssocItem (TSymAssocItem pos maybePosUpdate symAssoc) =
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (stringToken ",")
       ~+~ (ppSymAssoc symAssoc)

ppIndexExprItem :: TIndexExprItem -> PPDoc
ppIndexExprItem (TIndexExprItem pos maybePosUpdate expr) =
           (posToken pos)
       ~~  (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~  (stringToken ",")
       ~+~ (ppExpr expr)

ppRescueBlock :: TRescueBlock -> PPDoc
ppRescueBlock (TRescueBlock pos maybePosUpdate maybeExceptionClass maybeExceptionAssignment compStmtEmpty) = 
            (posToken pos)
       ~~   (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~   (stringToken "rescue")
       ~+~  (ppMaybe maybeExceptionClass $ ppExceptionClass)
       ~+~  (ppMaybe maybeExceptionAssignment $ ppExceptionAssignment)
       ~+~  (ppCompStmtEmpty compStmtEmpty)
       ~+~  (stringToken "end;")

ppExceptionClass :: TExceptionClass -> PPDoc
ppExceptionClass (TExceptionClass pos maybePosUpdate identifier) = 
            (posToken pos)
       ~~   (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~   (ppIdentifier identifier)

ppExceptionAssignment :: TExceptionAssignment -> PPDoc
ppExceptionAssignment (TExceptionAssignment pos maybePosUpdate identifier) = 
            (posToken pos)
       ~~   (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~   (stringToken "=>")
       ~~   (ppIdentifier identifier)

ppRaiseArgument :: TRaiseArgument -> PPDoc
ppRaiseArgument (TRaiseArgument pos maybePosUpdate identifier) = 
            (posToken pos)
       ~~   (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~   (ppIdentifier identifier)
ppRaiseArgument (TRaiseArgument_0 pos maybePosUpdate argCall) = 
            (posToken pos)
       ~~   (ppMaybe maybePosUpdate $ ppPosUpdate)
       ~~   (ppArgCall argCall)
	   
ppVerbatim :: Verbatim -> PPDoc
ppVerbatim (Verbatim str) = stringToken str

ppPosUpdate :: PositionUpdateStmt -> PPDoc
ppPosUpdate (PositionUpdateStmt str) = stringToken str

ppTableUpdate :: TableUpdateStmt -> PPDoc
ppTableUpdate (TableUpdateStmt str) = stringToken str

ppPopStmt :: PopFromCallStackStmt -> PPDoc
ppPopStmt (PopFromCallStackStmt str) = stringToken str

ppPushStmt :: PushOntoCallStackStmt -> PPDoc
ppPushStmt (PushOntoCallStackStmt str) = stringToken str

ppBegin :: Begin -> PPDoc
ppBegin _ = stringToken "begin"

ppGeneratedRescueBlock :: GeneratedRescueBlock -> PPDoc
ppGeneratedRescueBlock (GeneratedRescueBlock pop) = 
     (stringToken "rescue Exception => e")
  ~~ (ppPopStmt pop)
  ~~ (stringToken "raise e;")
  ~~ (stringToken "end;")

ppstring :: (TPos, String) -> PPDoc
ppstring (pos,a) = lexToken pos (((\s -> "\"" ++ s ++ "\"")) a)         
ppregexp :: (TPos, String) -> PPDoc
ppregexp (pos,a) = lexToken pos (a)         
ppbool :: (TPos, Bool) -> PPDoc
ppbool (pos,a) = lexToken pos (((\b -> (\(c:cs) -> (DChar.toLower c) : cs) $ show b)) a)         
ppid :: (TPos, String) -> PPDoc
ppid (pos,a) = lexToken pos (a)         
ppdefId :: (TPos, String) -> PPDoc
ppdefId (pos,a) = lexToken pos (a)         
ppnumber :: (TPos, String) -> PPDoc
ppnumber (pos,a) = lexToken pos (a)         
ppsymassocid :: (TPos, String) -> PPDoc
ppsymassocid (pos,a) = lexToken pos (a)         
ppcomment :: (TPos, String) -> PPDoc
ppcomment (pos,a) = lexToken pos (a)         
ppnl :: (TPos, String) -> PPDoc
ppnl (pos,a) = lexToken pos (a)
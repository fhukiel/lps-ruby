--------------------------------------------------------------------------------
-- Author: Thomas Ulrich, 2016                                                --
--------------------------------------------------------------------------------

module Lang.Debugging.ASTTransformator where

import Data.Maybe
import Lang.Gen.AST as OAST
import Lang.Debugging.TAST as TAST
import Lang.DebuggerInterface as DI

transform :: OAST.AST -> TAST.TAST
transform ast = TAST (generateRequiredImports) (generateRequiredHelpers) (transformCompStmt ast)

transformCompStmt :: OAST.CompStmt -> TAST.TCompStmt
transformCompStmt (CompStmt pos s stmts) = TCompStmt pos (transformStmt s) (map transformCompStmtItem stmts)

transformStmt :: OAST.Stmt -> TAST.TStmt
transformStmt (IfStmt pos expr compStmtEmpty maybeElse) = 
  TIfStmt pos (generatePosUpdate True $ transformPos pos) (transformExpr expr) (transformCompStmtEmpty compStmtEmpty) (maybe Nothing (Just . transformElseCase) maybeElse)
transformStmt (WhileStmt pos expr compStmtEmpty) = 
  TWhileStmt pos (generatePosUpdate True $ transformPos pos) (transformExpr expr) (transformCompStmtEmpty compStmtEmpty)
transformStmt (ForStmt pos var rFrom rTo compStmtEmpty) = 
  TForStmt pos (generatePosUpdate True $ transformPos pos) (transformIdentifier var) (transformExpr rFrom) (transformExpr rTo) (generateTableUpdateFromIdentifier var) (transformCompStmtEmpty compStmtEmpty)
transformStmt (CallStmt pos call) =
  TCallStmt pos Nothing (transformCall call)
transformStmt (BlockCallStmt pos maybeBlockCall) =
  TBlockCallStmt pos Nothing (maybe Nothing (Just . transformBlockCall) maybeBlockCall)
transformStmt (AssignStmt pos (innerPos, name) expr) = 
  TAssignStmt pos (generatePosUpdate True $ transformPos pos) (innerPos, name) (transformExpr expr) (generateTableUpdateFromString name)
transformStmt (IndexAssignStmt pos indexExpr expr) = 
  TIndexAssignStmt pos (generatePosUpdate True $ transformPos pos) (transformIndexExpr indexExpr) (transformExpr expr) (generateTableUpdateFromIndexExpr indexExpr)
transformStmt (ReturnStmt pos maybeExpr) = 
  TReturnStmt pos (generatePosUpdate True $ transformPos pos) (wrapInAssignstmt maybeExpr)
transformStmt (DefStmt pos definition) =
  TDefStmt pos Nothing (transformDef definition)
transformStmt (ClassStmt pos identifier classBody) =
  TClassStmt pos Nothing (transformIdentifier identifier) (map transformClassBody classBody)
transformStmt (Rescue pos compStmtEmpty rescue) = 
  TRescueStmt pos Nothing (transformCompStmtEmpty compStmtEmpty) (transformRescueBlock rescue)
transformStmt (Raise pos raiseArgument) = 
  TRaiseStmt pos (generatePosUpdate True $ transformPos pos) (transformRaiseArgument raiseArgument)
  
transformT :: OAST.T -> TAST.TT
transformT (T pos) = TT pos Nothing
transformT (T_0 pos maybePosString) = TT_0 pos Nothing maybePosString

transformCompStmtItem :: OAST.CompStmtItem -> TAST.TCompStmtItem
transformCompStmtItem (CompStmtItem pos stmt) = TCompStmtItem pos Nothing (transformStmt stmt)

transformCompStmtEmpty :: OAST.CompStmtEmpty -> TAST.TCompStmtEmpty
transformCompStmtEmpty (CompStmtEmpty pos compStmtEmptyItems) = TCompStmtEmpty pos Nothing $ map transformCompStmtEmptyItem compStmtEmptyItems

transformCompStmtEmptyItem :: OAST.CompStmtEmptyItem -> TAST.TCompStmtEmptyItem
transformCompStmtEmptyItem (CompStmtEmptyItem pos stmt) = TCompStmtEmptyItem pos Nothing (transformStmt stmt)

transformT2 :: OAST.T2 -> TAST.TT2
transformT2 (T2 pos) = TT2 pos Nothing
transformT2 (T2_0 pos posStringPair) = TT2_0 pos Nothing posStringPair

transformExpr :: OAST.Expr -> TAST.TExpr
transformExpr (Plus pos expr1 expr2)         = TPlus pos Nothing (transformExpr expr1) (transformExpr expr2)
transformExpr (Minus pos expr1 expr2)        = TMinus pos Nothing (transformExpr expr1) (transformExpr expr2)
transformExpr (Exp pos expr1 expr2)          = TExp pos Nothing (transformExpr expr1) (transformExpr expr2)
transformExpr (Mult pos expr1 expr2)         = TMult pos Nothing (transformExpr expr1) (transformExpr expr2)
transformExpr (Div pos expr1 expr2)          = TDiv pos Nothing (transformExpr expr1) (transformExpr expr2)
transformExpr (Mod pos expr1 expr2)          = TMod pos Nothing (transformExpr expr1) (transformExpr expr2)
transformExpr (Equ pos expr1 expr2)          = TEqu pos Nothing (transformExpr expr1) (transformExpr expr2)
transformExpr (Neq pos expr1 expr2)          = TNeq pos Nothing (transformExpr expr1) (transformExpr expr2)
transformExpr (Let pos expr1 expr2)          = TLet pos Nothing (transformExpr expr1) (transformExpr expr2)
transformExpr (Get pos expr1 expr2)          = TGet pos Nothing (transformExpr expr1) (transformExpr expr2)
transformExpr (Leq pos expr1 expr2)          = TLeq pos Nothing (transformExpr expr1) (transformExpr expr2)
transformExpr (Geq pos expr1 expr2)          = TGeq pos Nothing (transformExpr expr1) (transformExpr expr2)
transformExpr (And pos expr1 expr2)          = TAnd pos Nothing (transformExpr expr1) (transformExpr expr2)
transformExpr (Or pos expr1 expr2)           = TOr pos Nothing (transformExpr expr1) (transformExpr expr2)
transformExpr (Range pos expr1 expr2)        = TRange pos Nothing (transformExpr expr1) (transformExpr expr2)
transformExpr (IfExpr pos expr1 expr2 expr3) = TIfExpr pos Nothing (transformExpr expr1) (transformExpr expr2) (transformExpr expr3)
transformExpr (Expr pos simpleExpr)          = TExpr pos Nothing (transformSimpleExpr simpleExpr)

transformElseCase :: OAST.ElseCase -> TAST.TElseCase
transformElseCase (ElseCase pos compStmtEmpty) = TElseCase pos Nothing (transformCompStmtEmpty compStmtEmpty)

transformIdentifier :: OAST.Identifier -> TAST.TIdentifier
transformIdentifier (Identifier pos posStringPair maybeIdAddon) = TIdentifier pos Nothing posStringPair (maybe Nothing (Just . transformIdAddon) maybeIdAddon)

transformDoOpt :: OAST.DoOpt -> TAST.TDoOpt
transformDoOpt (DoOpt pos)   = TDoOpt pos Nothing
transformDoOpt (DoOpt_0 pos) = TDoOpt_0 pos Nothing

transformCall :: OAST.Call -> TAST.TCall
transformCall (Call pos argCall)  = TCall pos Nothing (transformArgCall True argCall)
transformCall (Call_0 pos idExpr) = TCall_0 pos Nothing (transformIdExpr idExpr)

transformBlockCall :: OAST.BlockCall -> TAST.TBlockCall
transformBlockCall (BlockCall pos call maybeBlockParams compStmtEmpty) = 
  TBlockCall pos Nothing (transformCall call) (maybe Nothing (Just . transformBlockParams) maybeBlockParams) (generateBegin) (generateBlockPushStmt call maybeBlockParams) (generateBlockParamTableUpdate maybeBlockParams) (transformCompStmtEmpty compStmtEmpty) (generatePopStatement) (generateGeneratedRescueBlock)

transformIndexExpr :: OAST.IndexExpr -> TAST.TIndexExpr
transformIndexExpr (Index pos simpleExpr expr indexExprItems) = 
  TIndex pos Nothing (transformSimpleExpr simpleExpr) (transformExpr expr) (map transformIndexExprItem indexExprItems)

transformDef :: OAST.Def -> TAST.TDef
transformDef (Def pos defIdentifier maybeParamList maybeCompStmt) = 
  TDef pos Nothing (transformDefIdentifier defIdentifier) (maybe Nothing (Just . transformParamList) maybeParamList) (generateBegin) (generatePushStmt defIdentifier maybeParamList) (maybe Nothing (Just . transformCompStmt) maybeCompStmt) (generatePopStatement)  (generateGeneratedRescueBlock)

transformClassBody :: OAST.ClassBody -> TAST.TClassBody
transformClassBody (ClassBody pos def) = TClassBody pos Nothing (transformDef def)
transformClassBody (Public pos) = TPublic pos Nothing
transformClassBody (Private pos) = TPrivate pos Nothing

transformIdAddon :: OAST.IdAddon -> TAST.TIdAddon
transformIdAddon (QMark pos) = TQMark pos Nothing 
transformIdAddon (EMark pos) = TEMark pos Nothing

transformDefIdentifier :: OAST.DefIdentifier -> TAST.TDefIdentifier
transformDefIdentifier (DefIdentifier pos posStringPair maybeIdAddon2) = TDefIdentifier pos Nothing posStringPair (maybe Nothing (Just . transformIdAddon2) maybeIdAddon2)
  
transformIdAddon2 :: OAST.IdAddon2 -> TAST.TIdAddon2
transformIdAddon2 (QMark2 pos) = TQMark2 pos Nothing 
transformIdAddon2 (EMark2 pos) = TEMark2 pos Nothing  

transformParamList :: OAST.ParamList -> TAST.TParamList
transformParamList (ParamList pos identifier params) = TParamList pos Nothing (transformIdentifier identifier) (map transformParam params) 
transformParamList (ParamList_0 pos) = TParamList_0 pos Nothing

transformArgCall :: Bool -> OAST.ArgCall -> TAST.TArgCall
transformArgCall doPosUpdate (ArgCall pos simpleExpr identifier maybeArgList) = 
  TArgCall pos (generatePosUpdate doPosUpdate $ transformPos pos) (transformSimpleExpr simpleExpr) (transformIdentifier identifier) (maybe Nothing (Just . transformArgList) maybeArgList)
transformArgCall doPosUpdate (ArgCall_0 pos identifier argList)               = 
  TArgCall_0 pos (generatePosUpdate doPosUpdate $ transformPos pos) (transformIdentifier identifier) (transformArgList argList)

transformIdExpr :: OAST.IdExpr -> TAST.TIdExpr
transformIdExpr (IdExpr pos identifier) = TIdExpr pos Nothing (transformIdentifier identifier) 
  
transformSimpleExpr :: OAST.SimpleExpr -> TAST.TSimpleExpr
transformSimpleExpr (NumExpr pos posStringPair)        = TNumExpr pos Nothing posStringPair
transformSimpleExpr (StringExpr pos posStringPair)     = TStringExpr pos Nothing posStringPair
transformSimpleExpr (BoolExpr pos posStringPair)       = TBoolExpr pos Nothing posStringPair
transformSimpleExpr (SymbolExpr pos symbol)            = TSymbolExpr pos Nothing (transformSymbol symbol)
transformSimpleExpr (ArrayExpr pos array)              = TArrayExpr pos Nothing (transformArray array)
transformSimpleExpr (HashExpr pos hash)                = THashExpr pos Nothing (transformHash hash)
transformSimpleExpr (CallExpr pos argCall)             = TCallExpr pos Nothing (transformArgCall False argCall)
transformSimpleExpr (ParenExpr pos expr)               = TParenExpr pos Nothing (transformExpr expr)
transformSimpleExpr (IndexExpr pos indexExpr)          = TIndexExpr pos Nothing (transformIndexExpr indexExpr)
transformSimpleExpr (UnopExpr pos unop simpleExpr)     = TUnopExpr pos Nothing (transformUnopExpr unop) (transformSimpleExpr simpleExpr)
transformSimpleExpr (SimpleExpr pos idExpr)            = TSimpleExpr pos Nothing (transformIdExpr idExpr)

transformArgList :: OAST.ArgList -> TAST.TArgList
transformArgList (ArgList pos expr args) = TArgList pos Nothing (transformExpr expr) (map transformArg args)
transformArgList (NoArgs pos) = TNoArgs pos Nothing

transformBlockParams :: OAST.BlockParams -> TAST.TBlockParams
transformBlockParams (BlockParams pos identifier blockParams) = TBlockParams pos Nothing (transformIdentifier identifier) (map transformBlockParam blockParams)

transformBlockParam :: OAST.BlockParam -> TAST.TBlockParam
transformBlockParam (BlockParam pos identifier) = TBlockParam pos Nothing (transformIdentifier identifier)

transformArg :: OAST.Arg -> TAST.TArg
transformArg (Arg pos expr) = TArg pos Nothing (transformExpr expr)

transformParam :: OAST.Param -> TAST.TParam
transformParam (Param pos identifier) = TParam pos Nothing (transformIdentifier identifier)

transformSymbol :: OAST.Symbol -> TAST.TSymbol
transformSymbol (Symbol pos identifier) = TSymbol pos Nothing (transformIdentifier identifier)

transformArray :: OAST.Array -> TAST.TArray
transformArray (Array pos exprList) = TArray pos Nothing (transformExprList exprList)

transformHash :: OAST.Hash -> TAST.THash
transformHash (Hash pos assocs) = THash pos Nothing (transformAssocs assocs)

transformUnopExpr :: OAST.Unop -> TAST.TUnop
transformUnopExpr (UnOpPlus pos)  = TUnOpPlus pos Nothing
transformUnopExpr (UnOpMinus pos) = TUnOpMinus pos Nothing

transformExprList :: OAST.ExprList -> TAST.TExprList
transformExprList (ExprList pos maybeExprListActual) = TExprList pos Nothing (maybe Nothing (Just . transformExprListActual) maybeExprListActual)

transformExprListActual :: OAST.ExprListActual -> TAST.TExprListActual
transformExprListActual (ExprListActual pos expr exprItems) = TExprListActual pos Nothing (transformExpr expr) (map transformExprItem exprItems)

transformExprItem :: OAST.ExprItem -> TAST.TExprItem
transformExprItem (ExprItem pos expr) = TExprItem pos Nothing (transformExpr expr)

transformAssocs :: OAST.Assocs -> TAST.TAssocs
transformAssocs (Assocs pos assoc assocItems) = TAssocs pos Nothing (transformAssoc assoc) (map transformAssocItem assocItems)
transformAssocs (Assocs_0 pos symAssoc symAssocItems) = TAssocs_0 pos Nothing (transformSymAssoc symAssoc) (map transformSymAssocItem symAssocItems)

transformAssoc :: OAST.Assoc -> TAST.TAssoc
transformAssoc (Assoc pos expr1 expr2) = TAssoc pos Nothing (transformExpr expr1) (transformExpr expr2)

transformAssocItem :: OAST.AssocItem -> TAST.TAssocItem
transformAssocItem (AssocItem pos assoc) = TAssocItem pos Nothing (transformAssoc assoc)
 
transformSymAssoc :: OAST.SymAssoc -> TAST.TSymAssoc
transformSymAssoc (SymAssoc pos posStringPair expr) = TSymAssoc pos Nothing posStringPair (transformExpr expr)

transformSymAssocItem :: OAST.SymAssocItem -> TAST.TSymAssocItem
transformSymAssocItem (SymAssocItem pos symAssoc) = TSymAssocItem pos Nothing (transformSymAssoc symAssoc)

transformIndexExprItem :: OAST.IndexExprItem -> TAST.TIndexExprItem
transformIndexExprItem (IndexExprItem pos expr) = TIndexExprItem pos Nothing (transformExpr expr)

transformRescueBlock :: OAST.RescueBlock -> TAST.TRescueBlock
transformRescueBlock (RescueBlock pos maybeExceptionClass maybeExceptionAssignment compStmtEmpty) = 
  TRescueBlock pos Nothing (maybe Nothing (Just . transformExceptionClass) maybeExceptionClass) (maybe Nothing (Just . transformExceptionAssignment) maybeExceptionAssignment) (transformCompStmtEmpty compStmtEmpty)

transformExceptionClass :: OAST.ExceptionClass -> TAST.TExceptionClass
transformExceptionClass (ExceptionClass pos id) = TExceptionClass pos Nothing (transformIdentifier id)

transformExceptionAssignment :: OAST.ExceptionAssignment -> TAST.TExceptionAssignment
transformExceptionAssignment (ExceptionAssignment pos id) = TExceptionAssignment pos Nothing (transformIdentifier id)

transformRaiseArgument :: OAST.RaiseArgument -> TAST.TRaiseArgument
transformRaiseArgument (RaiseArgument pos id)        = TRaiseArgument pos Nothing (transformIdentifier id)
transformRaiseArgument (RaiseArgument_0 pos argCall) = TRaiseArgument_0 pos Nothing (transformArgCall False argCall)

wrapInAssignstmt :: (Maybe OAST.Expr) -> ((Maybe TStmt), (Maybe PopFromCallStackStmt), Verbatim)
wrapInAssignstmt Nothing     = (Nothing, Nothing, (Verbatim "return;"))
wrapInAssignstmt (Just expr) = (Just assignStmt, Just popStmt, returnVerbatim)
  where
  dummyPos       = (0,0,0)
  dummyName      = "_5ff6831917164f5f8a386bbb7ca55b2d"
  assignStmt     = TAssignStmt dummyPos Nothing (dummyPos, dummyName) (transformExpr expr) (generateTableUpdateFromString dummyName)
  popStmt        = generatePopStatement
  identifier     = TIdentifier dummyPos Nothing (dummyPos, dummyName) Nothing
  returnVerbatim = Verbatim $ "return " ++ dummyName ++ ";"

generatePopStatement :: PopFromCallStackStmt
generatePopStatement = PopFromCallStackStmt DI.popFromCallStack

generatePushStmt :: OAST.DefIdentifier -> (Maybe OAST.ParamList) -> PushOntoCallStackStmt
generatePushStmt defIdentifier maybeParams = PushOntoCallStackStmt $ DI.pushOntoCallStack (extractMethodName defIdentifier) (extractParameters maybeParams) []

generateBlockPushStmt :: OAST.Call -> (Maybe OAST.BlockParams) -> PushOntoCallStackStmt
generateBlockPushStmt (Call _ (ArgCall _ _ a1 _)) maybeParam = PushOntoCallStackStmt $ DI.pushOntoCallStack (extractIdentifier a1) (extractBlockParameters maybeParam) []
generateBlockPushStmt (Call_0 _ (IdExpr _ a0)) maybeParam    = PushOntoCallStackStmt $ DI.pushOntoCallStack (extractIdentifier a0) (extractBlockParameters maybeParam) []

generateBlockParamTableUpdate :: (Maybe OAST.BlockParams) -> [TableUpdateStmt]
generateBlockParamTableUpdate maybeParam = map generateTableUpdateFromString (extractBlockParameters maybeParam)

generatePosUpdate :: Bool -> TPos -> Maybe PositionUpdateStmt
generatePosUpdate False _      = Nothing
generatePosUpdate True (x,y,z) = Just $ PositionUpdateStmt (DI.updatePosition (x,y,z))

generateTableUpdateFromIdentifier :: OAST.Identifier -> TableUpdateStmt
generateTableUpdateFromIdentifier identifier = let name = extractIdentifier identifier in 
  TableUpdateStmt $ DI.updateTable name name name []

generateTableUpdateFromString :: String -> TableUpdateStmt
generateTableUpdateFromString name = TableUpdateStmt $ DI.updateTable name name name []

generateTableUpdateFromIndexExpr :: OAST.IndexExpr -> TableUpdateStmt
generateTableUpdateFromIndexExpr indexExpr = case (extractIndexExpr indexExpr) of
  (Just str) -> generateTableUpdateFromString str
  _          -> TableUpdateStmt ""


generateBegin :: TAST.Begin
generateBegin = Begin

generateGeneratedRescueBlock :: TAST.GeneratedRescueBlock
generateGeneratedRescueBlock = GeneratedRescueBlock (generatePopStatement)
  
  
extractIndexExpr :: OAST.IndexExpr -> Maybe String
extractIndexExpr (Index _ (StringExpr _ a0) _ _)               = Just $ snd a0
extractIndexExpr (Index _ (CallExpr _ (ArgCall _ _ a1 _)) _ _) = Just $ extractIdentifier a1
extractIndexExpr (Index _ (SimpleExpr pos (IdExpr _ a0)) _ _)  = Just $ extractIdentifier a0
extractIndexExpr _                                             = Nothing

transformPos :: OAST.Pos -> TAST.TPos
transformPos (x,y,z) = (x,y,z)

extractIdentifier :: OAST.Identifier -> String
extractIdentifier (Identifier _ a0 a1) = snd a0 ++ (maybe "" extractIdAddon a1)

extractIdAddon :: OAST.IdAddon -> String
extractIdAddon (QMark _ ) = "?"
extractIdAddon (EMark _ ) = "!"

extractMethodName :: OAST.DefIdentifier -> String
extractMethodName (DefIdentifier pos a0 a1) = snd a0 ++ (maybe "" extractIdAddon2 a1)

extractIdAddon2 :: OAST.IdAddon2 -> String
extractIdAddon2 (QMark2 _ ) = "?"
extractIdAddon2 (EMark2 _ ) = "!"

extractParameters :: Maybe OAST.ParamList -> [String]
extractParameters (Just (ParamList pos a0 a1)) = (extractIdentifier a0) : extractParametersFromList a1
extractParameters _                            = []

extractParametersFromList :: [OAST.Param] -> [String]
extractParametersFromList [] = []
extractParametersFromList ((Param _ val):params) = (extractIdentifier val) : (extractParametersFromList params)

extractBlockParameters :: Maybe OAST.BlockParams -> [String]
extractBlockParameters Nothing = []
extractBlockParameters (Just (BlockParams _ identifier params)) = (extractIdentifier identifier) : (extractBlockParametersFromList params)

extractBlockParametersFromList :: [OAST.BlockParam] -> [String]
extractBlockParametersFromList [] = []
extractBlockParametersFromList ((BlockParam _ identifier):params) = (extractIdentifier identifier) : (extractBlockParametersFromList params)

generateRequiredImports :: RequiredImports
generateRequiredImports = RequiredImports $ DI.imports

generateRequiredHelpers :: RequiredHelpers
generateRequiredHelpers = RequiredHelpers $ DI.requiredHelperMethods
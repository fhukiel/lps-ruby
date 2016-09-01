--------------------------------------------------------------------------------
-- Author: Thomas Ulrich, 2016                                                --
--------------------------------------------------------------------------------

module Lang.Debugging.TAST where

type TPos = (Int,Int,Int)

data TAST = TAST RequiredImports RequiredHelpers TCompStmt

data TCompStmt = TCompStmt TPos TStmt [TCompStmtItem]
    deriving Show

data TStmt = TIfStmt TPos (Maybe PositionUpdateStmt) TExpr TCompStmtEmpty (Maybe TElseCase) 
    | TWhileStmt TPos (Maybe PositionUpdateStmt) TExpr TCompStmtEmpty 
    | TForStmt TPos (Maybe PositionUpdateStmt) TIdentifier TExpr TExpr TableUpdateStmt TCompStmtEmpty 
    | TCallStmt TPos (Maybe PositionUpdateStmt) TCall
    | TBlockCallStmt TPos (Maybe PositionUpdateStmt) (Maybe TBlockCall)
    | TAssignStmt TPos (Maybe PositionUpdateStmt) (TPos, String) TExpr TableUpdateStmt
    | TIndexAssignStmt TPos (Maybe PositionUpdateStmt) TIndexExpr TExpr TableUpdateStmt
    | TReturnStmt TPos (Maybe PositionUpdateStmt) ((Maybe TStmt), (Maybe PopFromCallStackStmt), Verbatim)
    | TDefStmt TPos (Maybe PositionUpdateStmt) TDef
    | TClassStmt TPos (Maybe PositionUpdateStmt) TIdentifier [TClassBody]
    | TRescueStmt TPos (Maybe PositionUpdateStmt) TCompStmtEmpty TRescueBlock
    | TRaiseStmt TPos (Maybe PositionUpdateStmt) TRaiseArgument
    deriving Show

data TT = TT TPos (Maybe PositionUpdateStmt) 
    | TT_0 TPos (Maybe PositionUpdateStmt) (Maybe (TPos, String))
    deriving Show

data TCompStmtItem = TCompStmtItem TPos (Maybe PositionUpdateStmt) TStmt
    deriving Show

data TCompStmtEmpty = TCompStmtEmpty TPos (Maybe PositionUpdateStmt) [TCompStmtEmptyItem]
    deriving Show

data TCompStmtEmptyItem = TCompStmtEmptyItem TPos (Maybe PositionUpdateStmt) TStmt
    deriving Show

data TT2 = TT2 TPos (Maybe PositionUpdateStmt) 
    | TT2_0 TPos (Maybe PositionUpdateStmt) (TPos, String)
    deriving Show

data TExpr = TPlus TPos (Maybe PositionUpdateStmt) TExpr TExpr
    | TMinus TPos (Maybe PositionUpdateStmt) TExpr TExpr
    | TExp TPos (Maybe PositionUpdateStmt) TExpr TExpr
    | TMult TPos (Maybe PositionUpdateStmt) TExpr TExpr
    | TDiv TPos (Maybe PositionUpdateStmt) TExpr  TExpr
    | TMod TPos (Maybe PositionUpdateStmt) TExpr  TExpr
    | TEqu TPos (Maybe PositionUpdateStmt) TExpr  TExpr
    | TNeq TPos (Maybe PositionUpdateStmt) TExpr  TExpr
    | TLet TPos (Maybe PositionUpdateStmt) TExpr  TExpr
    | TGet TPos (Maybe PositionUpdateStmt) TExpr  TExpr
    | TLeq TPos (Maybe PositionUpdateStmt) TExpr  TExpr
    | TGeq TPos (Maybe PositionUpdateStmt) TExpr  TExpr
    | TAnd TPos (Maybe PositionUpdateStmt) TExpr  TExpr
    | TOr TPos (Maybe PositionUpdateStmt) TExpr  TExpr
    | TRange TPos (Maybe PositionUpdateStmt) TExpr  TExpr
    | TIfExpr TPos (Maybe PositionUpdateStmt)  TExpr  TExpr TExpr
    | TExpr TPos (Maybe PositionUpdateStmt) TSimpleExpr
    deriving Show

data TElseCase = TElseCase TPos (Maybe PositionUpdateStmt) TCompStmtEmpty
    deriving Show

data TIdentifier = TIdentifier TPos (Maybe PositionUpdateStmt) (TPos, String) (Maybe TIdAddon)
    deriving Show

data TDoOpt = TDoOpt TPos (Maybe PositionUpdateStmt) 
    | TDoOpt_0 TPos (Maybe PositionUpdateStmt) 
    deriving Show

data TCall = TCall TPos (Maybe PositionUpdateStmt) TArgCall
    | TCall_0 TPos (Maybe PositionUpdateStmt) TIdExpr
    deriving Show

data TBlockCall = TBlockCall TPos (Maybe PositionUpdateStmt) TCall (Maybe TBlockParams) Begin PushOntoCallStackStmt [TableUpdateStmt] TCompStmtEmpty PopFromCallStackStmt GeneratedRescueBlock
    deriving Show

data TIndexExpr = TIndex TPos (Maybe PositionUpdateStmt) TSimpleExpr TExpr [TIndexExprItem]
    deriving Show

data TDef = TDef TPos (Maybe PositionUpdateStmt) TDefIdentifier (Maybe TParamList) Begin PushOntoCallStackStmt (Maybe TCompStmt) PopFromCallStackStmt GeneratedRescueBlock
    deriving Show

data TClassBody = TClassBody TPos (Maybe PositionUpdateStmt) TDef
    | TPublic TPos (Maybe PositionUpdateStmt) 
    | TPrivate TPos (Maybe PositionUpdateStmt) 
    deriving Show

data TIdAddon = TQMark TPos (Maybe PositionUpdateStmt) 
    | TEMark TPos (Maybe PositionUpdateStmt) 
    deriving Show

data TDefIdentifier = TDefIdentifier TPos (Maybe PositionUpdateStmt) (TPos, String) (Maybe TIdAddon2)
    deriving Show

data TIdAddon2 = TQMark2 TPos (Maybe PositionUpdateStmt) 
    | TEMark2 TPos (Maybe PositionUpdateStmt) 
    deriving Show

data TParamList = TParamList TPos (Maybe PositionUpdateStmt) TIdentifier [TParam] 
    | TParamList_0 TPos (Maybe PositionUpdateStmt) 
    deriving Show

data TArgCall = TArgCall TPos (Maybe PositionUpdateStmt) TSimpleExpr TIdentifier (Maybe TArgList)
    | TArgCall_0 TPos (Maybe PositionUpdateStmt) TIdentifier TArgList
    deriving Show

data TIdExpr = TIdExpr TPos (Maybe PositionUpdateStmt) TIdentifier
    deriving Show

data TSimpleExpr = TNumExpr TPos (Maybe PositionUpdateStmt) (TPos, String)
    | TStringExpr TPos (Maybe PositionUpdateStmt) (TPos, String)
    | TBoolExpr TPos (Maybe PositionUpdateStmt) (TPos, Bool)
    | TSymbolExpr TPos (Maybe PositionUpdateStmt) TSymbol
    | TArrayExpr TPos (Maybe PositionUpdateStmt) TArray
    | THashExpr TPos (Maybe PositionUpdateStmt) THash
    | TRegexpExpr TPos (Maybe PositionUpdateStmt) (TPos, String)
    | TCallExpr TPos (Maybe PositionUpdateStmt) TArgCall
    | TParenExpr TPos (Maybe PositionUpdateStmt)  TExpr 
    | TIndexExpr TPos (Maybe PositionUpdateStmt) TIndexExpr
    | TUnopExpr TPos (Maybe PositionUpdateStmt) TUnop TSimpleExpr
    | TSimpleExpr TPos (Maybe PositionUpdateStmt) TIdExpr
    deriving Show

data TArgList = TArgList TPos (Maybe PositionUpdateStmt)  TExpr [TArg] 
    | TNoArgs TPos (Maybe PositionUpdateStmt) 
    deriving Show

data TBlockParams = TBlockParams TPos (Maybe PositionUpdateStmt) TIdentifier [TBlockParam]
    deriving Show

data TBlockParam = TBlockParam TPos (Maybe PositionUpdateStmt) TIdentifier
    deriving Show

data TArg = TArg TPos (Maybe PositionUpdateStmt) TExpr
    deriving Show

data TParam = TParam TPos (Maybe PositionUpdateStmt) TIdentifier
    deriving Show

data TSymbol = TSymbol TPos (Maybe PositionUpdateStmt) TIdentifier
    deriving Show

data TArray = TArray TPos (Maybe PositionUpdateStmt) TExprList
    deriving Show

data THash = THash TPos (Maybe PositionUpdateStmt) TAssocs
    deriving Show

data TUnop = TUnOpPlus TPos (Maybe PositionUpdateStmt) 
    | TUnOpMinus TPos (Maybe PositionUpdateStmt) 
    deriving Show

data TExprList = TExprList TPos (Maybe PositionUpdateStmt) (Maybe TExprListActual)
    deriving Show

data TExprListActual = TExprListActual TPos (Maybe PositionUpdateStmt) TExpr [TExprItem]
    deriving Show

data TExprItem = TExprItem TPos (Maybe PositionUpdateStmt) TExpr
    deriving Show

data TAssocs = TAssocs TPos (Maybe PositionUpdateStmt) TAssoc [TAssocItem]
    | TAssocs_0 TPos (Maybe PositionUpdateStmt) TSymAssoc [TSymAssocItem]
    deriving Show

data TAssoc = TAssoc TPos (Maybe PositionUpdateStmt) TExpr TExpr
    deriving Show

data TAssocItem = TAssocItem TPos (Maybe PositionUpdateStmt) TAssoc
    deriving Show

data TSymAssoc = TSymAssoc TPos (Maybe PositionUpdateStmt) (TPos, String) TExpr
    deriving Show

data TSymAssocItem = TSymAssocItem TPos (Maybe PositionUpdateStmt) TSymAssoc
    deriving Show

data TIndexExprItem = TIndexExprItem TPos (Maybe PositionUpdateStmt) TExpr
    deriving Show

data TRescueBlock = TRescueBlock TPos (Maybe PositionUpdateStmt) (Maybe TExceptionClass) (Maybe TExceptionAssignment) TCompStmtEmpty
    deriving Show

data TExceptionClass = TExceptionClass TPos (Maybe PositionUpdateStmt) TIdentifier
    deriving Show

data TExceptionAssignment = TExceptionAssignment TPos (Maybe PositionUpdateStmt) TIdentifier
    deriving Show

data TRaiseArgument = TRaiseArgument TPos (Maybe PositionUpdateStmt) TIdentifier
     | TRaiseArgument_0 TPos (Maybe PositionUpdateStmt) TArgCall
    deriving Show

data Begin = Begin
    deriving Show

data GeneratedRescueBlock = GeneratedRescueBlock PopFromCallStackStmt
    deriving Show

{- Debug Stmts -}

data Verbatim = Verbatim String
    deriving Show

data PositionUpdateStmt = PositionUpdateStmt String
    deriving Show

data TableUpdateStmt = TableUpdateStmt String
    deriving Show

data PushOntoCallStackStmt = PushOntoCallStackStmt String
    deriving Show

data PopFromCallStackStmt = PopFromCallStackStmt String
    deriving Show

data RequiredImports = RequiredImports String
    deriving Show

data RequiredHelpers = RequiredHelpers String
    deriving Show
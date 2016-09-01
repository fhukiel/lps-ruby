module Lang.Gen.AST where

type Pos = (Int,Int,Int)

type AST = CompStmt

data CompStmt = CompStmt Pos Stmt [CompStmtItem]
    deriving Show

data Stmt = IfStmt Pos  Expr  CompStmtEmpty (Maybe ElseCase) 
    | WhileStmt Pos  Expr  CompStmtEmpty 
    | ForStmt Pos  Identifier  Expr  Expr CompStmtEmpty 
    | CallStmt Pos Call
    | BlockCallStmt Pos (Maybe BlockCall)
    | AssignStmt Pos (Pos, String)  Expr
    | IndexAssignStmt Pos IndexExpr  Expr
    | ReturnStmt Pos  (Maybe Expr)
    | DefStmt Pos Def
    | ClassStmt Pos  Identifier [ClassBody] 
    | Rescue Pos  CompStmtEmpty RescueBlock
    | Raise Pos  RaiseArgument
    deriving Show

data T = T Pos 
    | T_0 Pos (Maybe (Pos, String))
    deriving Show

data CompStmtItem = CompStmtItem Pos Stmt
    deriving Show

data CompStmtEmpty = CompStmtEmpty Pos [CompStmtEmptyItem]
    deriving Show

data CompStmtEmptyItem = CompStmtEmptyItem Pos Stmt
    deriving Show

data T2 = T2 Pos 
    | T2_0 Pos (Pos, String)
    deriving Show

data Expr = Plus Pos Expr  Expr
    | Minus Pos Expr  Expr
    | Exp Pos Expr  Expr
    | Mult Pos Expr  Expr
    | Div Pos Expr  Expr
    | Mod Pos Expr  Expr
    | Equ Pos Expr  Expr
    | Neq Pos Expr  Expr
    | Let Pos Expr  Expr
    | Get Pos Expr  Expr
    | Leq Pos Expr  Expr
    | Geq Pos Expr  Expr
    | And Pos Expr  Expr
    | Or Pos Expr  Expr
    | Range Pos Expr  Expr
    | IfExpr Pos  Expr  Expr  Expr 
    | Expr Pos SimpleExpr
    deriving Show

data ElseCase = ElseCase Pos  CompStmtEmpty
    deriving Show

data Identifier = Identifier Pos (Pos, String) (Maybe IdAddon)
    deriving Show

data DoOpt = DoOpt Pos 
    | DoOpt_0 Pos 
    deriving Show

data Call = Call Pos ArgCall
    | Call_0 Pos IdExpr
    deriving Show

data BlockCall = BlockCall Pos Call (Maybe BlockParams) CompStmtEmpty
    deriving Show

data IndexExpr = Index Pos SimpleExpr Expr [IndexExprItem]
    deriving Show

data Def = Def Pos  DefIdentifier (Maybe ParamList) (Maybe CompStmt)
    deriving Show

data ClassBody = ClassBody Pos Def
    | Public Pos 
    | Private Pos 
    deriving Show

data RescueBlock = RescueBlock Pos (Maybe ExceptionClass) (Maybe ExceptionAssignment) CompStmtEmpty
    deriving Show

data RaiseArgument = RaiseArgument Pos Identifier
    | RaiseArgument_0 Pos ArgCall
    deriving Show

data ArgCall = ArgCall Pos SimpleExpr  Identifier (Maybe ArgList)
    | ArgCall_0 Pos Identifier ArgList
    deriving Show

data IdAddon = QMark Pos 
    | EMark Pos 
    deriving Show

data DefIdentifier = DefIdentifier Pos (Pos, String) (Maybe IdAddon2)
    deriving Show

data IdAddon2 = QMark2 Pos 
    | EMark2 Pos 
    deriving Show

data ParamList = ParamList Pos  Identifier [Param] 
    | ParamList_0 Pos 
    deriving Show

data IdExpr = IdExpr Pos Identifier
    deriving Show

data SimpleExpr = NumExpr Pos (Pos, String)
    | StringExpr Pos (Pos, String)
    | BoolExpr Pos (Pos, Bool)
    | SymbolExpr Pos Symbol
    | ArrayExpr Pos Array
    | HashExpr Pos Hash
    | RegexpExpr Pos (Pos, String)
    | CallExpr Pos ArgCall
    | ParenExpr Pos  Expr 
    | IndexExpr Pos IndexExpr
    | UnopExpr Pos Unop SimpleExpr
    | SimpleExpr Pos IdExpr
    deriving Show

data ArgList = ArgList Pos  Expr [Arg] 
    | NoArgs Pos 
    deriving Show

data BlockParams = BlockParams Pos Identifier [BlockParam]
    deriving Show

data BlockParam = BlockParam Pos  Identifier
    deriving Show

data Arg = Arg Pos  Expr
    deriving Show

data Param = Param Pos  Identifier
    deriving Show

data Symbol = Symbol Pos Identifier
    deriving Show

data Array = Array Pos ExprList
    deriving Show

data Hash = Hash Pos Assocs
    deriving Show

data Unop = UnOpPlus Pos 
    | UnOpMinus Pos 
    deriving Show

data ExprList = ExprList Pos (Maybe ExprListActual)
    deriving Show

data ExprListActual = ExprListActual Pos Expr [ExprItem]
    deriving Show

data ExprItem = ExprItem Pos  Expr
    deriving Show

data Assocs = Assocs Pos Assoc [AssocItem]
    | Assocs_0 Pos SymAssoc [SymAssocItem]
    deriving Show

data Assoc = Assoc Pos Expr Expr
    deriving Show

data AssocItem = AssocItem Pos  Assoc
    deriving Show

data SymAssoc = SymAssoc Pos (Pos, String) Expr
    deriving Show

data SymAssocItem = SymAssocItem Pos  SymAssoc
    deriving Show

data IndexExprItem = IndexExprItem Pos  Expr
    deriving Show

data ExceptionClass = ExceptionClass Pos Identifier
    deriving Show

data ExceptionAssignment = ExceptionAssignment Pos  Identifier
    deriving Show


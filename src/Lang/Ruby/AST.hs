--------------------------------------------------------------------------------
-- Author: CAU, 2015                                                          --
--------------------------------------------------------------------------------

module Lang.Ruby.AST where

type Id = String

-- Absolute, Line, Column
data Posn = Posn Int Int Int
  deriving (Eq, Show)

instance Ord Posn where
  Posn a1 _ _ < Posn a2 _ _   =  a1 < a2
  Posn a1 _ _ <= Posn a2 _ _  =  a1 <= a2

p0 = Posn 0 0 0

type AST = [Stmt]

data Stmt = IfStmt Posn Expr [Stmt] [Stmt]
          | WhileStmt Posn Expr [Stmt]
          | ForStmt Posn Id Expr [Stmt]
          | CallStmt Posn Call
          | BlockCallStmt Posn [Id] [Stmt]       -- neu, pruefe Checks (z.B. definedCheck mit BlockParams)
          | AssignStmt Posn Expr Expr
          | ReturnStmt Posn (Maybe Expr)         -- neu, pruefe Checks
          | DefStmt Posn Id [Id] [Stmt]
          | ClassStmt Posn Id [Stmt]
          | PrivateStmt Posn
          | PublicStmt Posn
          | RescueStmt Posn
          | RaiseStmt Posn
        deriving Show

data Call = Call (Maybe Expr) Id [Expr]
  deriving Show

data Expr = NumExpr Posn String
          | IdExpr Posn String
          | StringExpr Posn String
          | BoolExpr Posn Bool
          | RangeExpr Posn Expr Expr
          | ArrayExpr Posn [Expr]
          | HashExpr Posn [(Expr, Expr)]
          | RegexpExpr Posn String
          | OpExpr Posn Expr BinOp Expr
          | IfExpr Posn Expr Expr Expr
          | CallExpr Posn Call
          | IndexExpr Posn Expr [Expr]
          | SymbolExpr Posn String
          | UnopExpr Posn String Expr
        deriving Show

data BinOp = PlusOp | MinusOp | TimesOp | DivOp | ModOp | EqOp | NeqOp | LtOp | GtOp | LeOp | GeOp | OrOp | AndOp | ExpOp
  deriving Show

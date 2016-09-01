--------------------------------------------------------------------------------
-- Author: CAU, 2015                                                          --
--------------------------------------------------------------------------------

module Lang.Ruby.Errors where

import Lang.Ruby.AST
import Lang.Ruby.IdTable
import Text.PrettyPrint
import Data.List
import Lang.ParserTypes
import Lang.Ruby.Parse.ASTTransform

data Err = Err Posn ErrInfo
         | Warning Posn WarnInfo
         | ParserErr Posn String
         | LexerErr Posn String
  deriving (Eq, Show)

data ErrInfo = UndefinedSymbol String [String] | ProcInsteadOfFunc String | FuncInsteadOfProc String | NonBoolInCondition | IllegalSign SignInfo -- new Error for illegal Identifiers
  deriving (Eq, Show)

data WarnInfo = EmptyReturn | DivideByZero | UpperCase String
  deriving (Eq, Show)

data ScopeInfo = TopLevel | ProcDef String | ClassDef String

data SignInfo = StartsWithAt Char | EndsWithOp Char
  deriving (Eq, Show)

showErrs :: [Err] -> [String]
showErrs errs = map showErr errs

showErr :: Err -> String
showErr err = case err of
                 Err p info     -> showError p info
                 Warning p info -> showWarning p info

showError :: Posn -> ErrInfo -> String
showError p info = case info of
                           (UndefinedSymbol s xs)       -> (printErrorPosn p) ++ s ++ " is undefined."
                                                            ++ (if (xs == []) then "" else " Maybe you meant: " ++ (intercalate ", " xs) ++ " ?")
                           ProcInsteadOfFunc s          -> (printErrorPosn p) ++ "The procedure '" ++ s ++"' can't be used in an expression!"
                           FuncInsteadOfProc s          -> (printErrorPosn p) ++ "The function '" ++ s ++ "' can't be used in a statement!"
                           NonBoolInCondition           -> (printErrorPosn p) ++ "You need to use a boolean condition in an if statement or expression."
                           IllegalSign (StartsWithAt c) -> (printErrorPosn p) ++ "Don't start methods with an @-sign. That's reserved for variables."
                           IllegalSign (EndsWithOp c)   -> (printErrorPosn p) ++ "Don't end the name of your variable with the operator" ++ [c] ++ "." ++ "That's only allowed for methods."

showWarning :: Posn -> WarnInfo -> String
showWarning p info = case info of
                        EmptyReturn -> (printWarnPosn p) ++ "Your return is empty."
                        DivideByZero-> (printWarnPosn p) ++ "Division by 0 is not allowed."
                        UpperCase s -> (printWarnPosn p) ++ "You defined your method '" ++ s ++ "' with an uppercase letter. That won't cause an error but it would be nicer to use a lowercase one. (Ruby naming convetion)"

showParseResult :: ParseResult a -> String
showParseResult (ParseError p xs) = (printErrorPosn (ppa p)) ++ "I couldn't parse your program. Things I couldn't read: " ++ (intercalate " " xs) ++ "\n. Common mistakes: Forgot a ';', 'end;'?'. Check the parentheses'."
showParseResult (LexerError p s) = (printErrorPosn (ppa p)) ++ "Lexer error. This shouldn't happen." ++ s

printErrorPosn :: Posn -> String
printErrorPosn p = "Error at (Line:" ++ (extractLine p) ++ ", Colum:" ++ (extractColumn p) ++ "): "

printWarnPosn :: Posn -> String
printWarnPosn p = "Warning at (Line:" ++ (extractLine p) ++ ", Colum:" ++ (extractColumn p) ++ "): "

extractColumn :: Posn -> String
extractColumn (Posn _ _ c) = show c

extractLine :: Posn -> String
extractLine (Posn _ l _) = show l

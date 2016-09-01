--------------------------------------------------------------------------------
-- Author: CAU, 2015                                                          --
--------------------------------------------------------------------------------

module Lang.Ruby.Analysis where

import Lang.Ruby.AST
import Lang.Ruby.IdTable
import Lang.Ruby.Errors

data Check = Check (IdTable -> ScopeInfo -> Stmt -> [Err])

(>>-) :: [a] -> [a] -> [a]
a >>- b = a ++ b

maybeFirst :: Eq e => [Maybe e] -> Maybe e
maybeFirst [] = Nothing
maybeFirst (Nothing:xs) = maybeFirst xs
maybeFirst ((Just x):_) = Just x

hasAny' :: String -> String -> String -> Maybe Char
hasAny' [] _ _= Nothing             -- An empty search list: always fal
hasAny' _ [] _= Nothing             -- An empty list to scan: always false
hasAny' search (x:xs) start = if x `elem` search then (Just x) else hasAny' search xs start

isAscii'                 :: Char -> (Bool, Maybe Char)
isAscii' c               =  if c <  '\x80' then (True, Just c) else (False, Nothing)

(>>--) :: Maybe [Err] -> Maybe [Err] -> Maybe [Err]
Just errsl >>-- Just errsr = Just (errsl++errsr)
Nothing >>-- Nothing = Nothing
Just errs >>-- Nothing = Just errs
Nothing >>-- Just errs = Just errs

removeDuplicates :: Eq a => [a] -> [a]
removeDuplicates = foldl (\seen x -> if x `elem` seen
                                      then seen
                                      else seen ++ [x]) []

-- data RunError
--   = ParserError      Posn String -- ^ level code parsing error
--   | AnalysisError    Posn String -- ^ semantic analysis error
--   | InterpreterError Int String -- ^ interpreter runtime error
--   | CompilerError    Int String -- ^ compiler error
--   | ExecutionEerror  Int String -- ^ runtime error
--
--
-- main = do
--   args <- getArgs -- level, path
--   (level,code) <- parseArgs
--   objectCode <- execute level code
--   xml <- toXML objecttCode
--   putStrlLn xml
--   `catchError` handle
--
-- --
-- execute :: Int -> String -> RunResult
--
-- handleExternalError :: String -> (Posn,String)

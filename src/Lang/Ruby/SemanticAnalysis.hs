--------------------------------------------------------------------------------
-- Author: CAU, 2015                                                          --
--------------------------------------------------------------------------------

module Lang.Ruby.SemanticAnalysis where

import Data.Maybe
--import Control.Monad.State

import Lang.Ruby.AST
import Lang.Ruby.Analysis
import Lang.Ruby.IdTable
import Lang.Ruby.Symboltable
import Lang.Ruby.DefinedAnalysis
import Lang.Ruby.ProcFuncAnalysis
import Lang.Ruby.BoolAnalysis
import Lang.Ruby.Parse.ASTTransform
import qualified Lang.Gen.Parser1 as Parser1
import qualified Lang.Gen.Parser2 as Parser2
import qualified Lang.Gen.Parser3 as Parser3
import qualified Lang.ParserTypes as ParserTypes
import qualified Lang.Gen.AST as ParseAST
import qualified Lang.Ruby.Parse.FilteredLexer as FL
import Lang.Ruby.Errors
import Lang.Ruby.ValidateIds
import Lang.PPDoc
import Lang.Gen.PrettyPrinter

type ParserFun = String -> ParserTypes.ParseResult ParseAST.AST

data Analysis = DefinedAnalysis | ProcFuncAnalysis | BoolAnalysis
---------------------------------
-- Levelunterschiede? Level1: Semikolom+ProcFuncCheck Level2: Semikolen optional und kein ProcFuncCheck Level: Blöcke kommen dazu
parseAndAnalyseLevel1 s = parseAndAnalyseLeveled parse1Fun [DefinedAnalysis, ProcFuncAnalysis, BoolAnalysis] s
parseAndAnalyseLevel2 s = parseAndAnalyseLeveled parse2Fun [DefinedAnalysis, BoolAnalysis] s
parseAndAnalyseLevel3 s = parseAndAnalyseLeveled parse3Fun [DefinedAnalysis, BoolAnalysis] s
--------------------------

parse1Fun = parseFiltered1
parse2Fun = parseFiltered2
parse3Fun = parseFiltered3

parseFiltered1 :: String -> ParserTypes.ParseResult ParseAST.AST
parseFiltered1 s = FL.lexwrapFiltered s >>= Parser1.parseTokens >>= return . ParserTypes.val

parseFiltered2 :: String -> ParserTypes.ParseResult ParseAST.AST
parseFiltered2 s = FL.lexwrapFiltered s >>= Parser2.parseTokens >>= return . ParserTypes.val

parseFiltered3 :: String -> ParserTypes.ParseResult ParseAST.AST
parseFiltered3 s = FL.lexwrapFiltered s >>= Parser3.parseTokens >>= return . ParserTypes.val

--prettyPrint :: Bool -> ParseAST.AST -> String
--prettyPrint = getPPString $ ppAST

parseAndAnalyseLeveled :: ParserFun -> [Analysis] -> String -> String -> (Maybe ParseAST.AST, [Err])
parseAndAnalyseLeveled parse as ia s = case (parse (s ++ "\n")) of
  ParserTypes.Ok a -> (Just a, removeDuplicates (analyseWithChecks checks augmentedTable TopLevel $ transformParseAST a))
  pe@(ParserTypes.ParseError p es) -> (Nothing, [ParserErr (transParserPos p) $ showParseResult pe])
  le@(ParserTypes.LexerError p em) -> (Nothing, [LexerErr (transParserPos p) $ showParseResult le])
  where checks = translateAnalyses as
        augmentedTable = addToWhitelist whitelistTable ia

addToWhitelist :: IdTable -> String -> IdTable
addToWhitelist t [] = t
addToWhitelist t s = foldl (\a i -> insertTable (fst i) (ProcInfo (Posn (-1) 0 0) (snd i)) a) t realPairs
  where realPairs = map (\(a, b) -> (a, stringToProcType b)) stringPairs
        stringPairs = map (\l -> (l !! 0, l !! 1)) (map words $ lines s)
        stringToProcType s = case s of
          "Proc" -> Proc
          "Func" -> Func
          "ProcAndFunc" -> ProcAndFunc
          _ -> error ("I don't know how to translate '" ++ s ++ "'")

translateAnalyses :: [Analysis] -> [Check]
translateAnalyses = map translateAnalysis
  where translateAnalysis DefinedAnalysis = definedCheck
        translateAnalysis ProcFuncAnalysis = procFuncCheck
        translateAnalysis BoolAnalysis = boolCheck

parseAndAnalyse :: String -> [Err]
parseAndAnalyse s = removeDuplicates (snd $ parseAndAnalyseLeveled parseFiltered3 [DefinedAnalysis, ProcFuncAnalysis, BoolAnalysis] "" s)

transParserPos :: ParseAST.Pos -> Posn
transParserPos (a, l, c) = Posn a l c

analyse :: IdTable -> ScopeInfo -> [Stmt] -> [Err]
analyse = analyseWithChecks [definedCheck, procFuncCheck, boolCheck]

analyseWithChecks :: [Check] -> IdTable -> ScopeInfo -> [Stmt] -> [Err]
analyseWithChecks cs t i ss = (check cs t' i ss) ++ (validateIds t')
 where t' = buildSymTableStmts (enterScope t) ss

analyseAndAddIds :: [Check] -> IdTable -> [Id] -> ScopeInfo -> [Stmt] -> [Err]
analyseAndAddIds cs t ids i ss = (check cs (addIds ids t') i ss) ++ (validateIds t')
  where addIds :: [Id] -> IdTable -> IdTable
        addIds [] r     = r
        addIds (i:is) r = addIds is $ insertTable i (VarInfo p0) r
        t' = buildSymTableStmts (enterScope t) ss

check :: [Check] -> IdTable -> ScopeInfo -> [Stmt] -> [Err]
check _ _ _ []     = []
check cs t i (s:ss) = r ++ check cs t i ss
  where r = checkStmt cs t i s

execStmtChecks :: [Check] -> IdTable -> ScopeInfo -> Stmt -> [Err]
execStmtChecks [] t i s = []
execStmtChecks ((Check f):cs) t i s = (f t i s) ++ execStmtChecks cs t i s

checkStmt :: [Check] -> IdTable -> ScopeInfo -> Stmt -> [Err]
checkStmt cs t i s@(IfStmt _ c a b)      = execStmtChecks cs t i s >>- analyseWithChecks cs t i a >>- analyseWithChecks cs t i b
checkStmt cs t i s@(WhileStmt _ _ b)     = execStmtChecks cs t i s >>- analyseWithChecks cs t i b
checkStmt cs t i s@(ForStmt _ _ _ b)     = execStmtChecks cs t i s >>- analyseWithChecks cs t i b
checkStmt cs t i s@(DefStmt _ _ a b)     = execStmtChecks cs t i s >>- analyseAndAddIds cs t a (ProcDef "") b
checkStmt cs t i s@(ClassStmt _ _ b)     = execStmtChecks cs t i s >>- analyseWithChecks cs t (ClassDef "") b
checkStmt cs t i s@(BlockCallStmt _ a b) = execStmtChecks cs t i s >>- analyseAndAddIds cs t a i b
checkStmt cs t i s                       = execStmtChecks cs t i s

--------------------------------------------------------------------------------
-- Author: CAU, 2015                                                          --
--------------------------------------------------------------------------------

module Lang.Interface (
  CompilationData,
  compileLevelCode,
  translateOutput
) where

import Control.Monad.Error (liftIO,throwError,when)

import Executable.Types
import Lang.Ruby.Lang2
import Data.Maybe
import System.Environment
import Lang.Debugging.PrettyPrinter as PP
import Lang.Debugging.ASTTransformator as ASTT
import Lang.PPDoc as PPDoc
--------------------------------------------------------------------------------
-- Compiling level code                                                       --
--------------------------------------------------------------------------------

type CompilationData = ()

-- Int: Level
-- String: Actual code to compile
-- Maybe String: Expression
-- Bool: True if output should include debug information
compileLevelCode
  :: Int
  -> String
  -> Maybe String
  -> Bool
  -> RunResult ([(String,String)],CompilationData)
compileLevelCode 3 levelCode _ _ =
  return ([("Main","$stdout.sync = true\n"++levelCode)],())
compileLevelCode level levelCode mExpr includeDebug = do
  -- get whitelist
  whitelistPath <- liftIO $ lookupEnv "LRB_WHITELIST_PATH"
  whitelist <- case whitelistPath of
    Just path -> liftIO $ readFile path
    Nothing -> return ""
  -- parse and analyse level code
  let (ast,allErrs) = parseAndAnalyseLeveled parser relAnals whitelist levelCode
      warnings      = filter isWarning allErrs
      errors        = filter isErr allErrs
      translated    = map translateError errors
  -- put warnings and errors
  addWarnings $ map (\w@(Warning p _) ->
    analyzerWarning (tPos p, showErr w)) warnings
  when (not $ null errors) $
    throwError $ map translateError errors
  -- return object code
  case ast of
    Just x  -> case includeDebug of
      True  -> return ([("Main","$stdout.sync = true\n"++(PPDoc.getPPString $ PP.ppAST $ ASTT.transform x))],())
      False -> return ([("Main","$stdout.sync = true\n"++levelCode)],())
    Nothing -> return ([],())
  where
    relAnals   = analyses ++ (if level < 3 then [ProcFuncAnalysis] else [])
    parser     = parserForLevel level

analyses = [DefinedAnalysis,BoolAnalysis]

parserForLevel :: Int -> ParserFun
parserForLevel 0 = parse1Fun
parserForLevel 1 = parse2Fun
parserForLevel 2 = parse3Fun

translateError :: Err -> RunError
translateError (ParserErr p m) = parserError (tPos p,m)
translateError (LexerErr  p m) = parserError (tPos p,m)
translateError e@(Err     p _) = analyzerError (tPos p,showErr e)

fOr :: (a -> Bool) -> (a -> Bool) -> (a -> Bool)
fOr a b = \x -> (a x) || (b x)

tPos :: Posn -> Pos
tPos (Posn a l c) = (a,l,c) :: Pos

isErr :: Err -> Bool
isErr (Err       _ _) = True
isErr (ParserErr _ _) = True
isErr (LexerErr  _ _) = True
isErr _               = False

isWarning :: Err -> Bool
isWarning (Warning _ _) = True
isWarning _             = False

--------------------------------------------------------------------------------
-- Translating execution output                                               --
--------------------------------------------------------------------------------

translateOutput
  :: CompilationData
  -> ExecutionContext
  -> String
  -> [OutputFragment]
translateOutput _ _ ""  = []
translateOutput _ _ out = [TextFragment out]


transErr :: Fragment -> OutputFragment
transErr (EFragment (a,r,c) s) = ErrorFragment$runtimeError$Right ((-1,r,-1),s)
transErr (TFragment s)         = TextFragment s

--------------------------------------------------------------------------------

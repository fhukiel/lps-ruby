--------------------------------------------------------------------------------
-- Author: CAU, 2015                                                          --
--------------------------------------------------------------------------------

module Lang.Ruby.Parse.FilteredLexer where

import Control.Monad.State
import Debug.Trace
import Data.String.Utils
import Data.Map.Strict
import Data.Maybe
import Data.Tuple

import Lang.Gen.Lexer
import Lang.Gen.AST
import Lang.ParserTypes

-- Ruby is very liberal in its use of newlines. A grammar that covers all the
-- places where newlines are allowed but not needed would be complex and hard
-- to maintain. This module implements a filter on top of the token stream that
-- only leaves the newlines that are neccessary.
--
-- To this end it toggles between two very simple states: ExprBeg and ExprEnd.
-- While we're in the ExprBeg state we discard all newline tokens. When in
-- ExprEnd, we leave them alone.
--
-- The rules for switching between ExprBeg and ExprEnd while processing the
-- token stream are as follows:
-- 1. Every token not mentioned below means a switch to ExprEnd, as long as
--    everything is balanced (see below).
-- 2. There are tokens that simply mean a switch to ExprBeg and can then be
--    forgot about, e.g. + oder /.
-- 3. Some tokens come in pairs. Seeing the first one means entering ExprBeg
--    and increasing the balance value for that pair. Seeing the second one
--    means decreasing the balance value and entering ExprEnd if all balance
--    values are 0 (including the special 'expression if' balance).
--    --> e.g. everything inside parentheses is one expression
-- 4. Seeing an 'if' while in ExprEnd means increasing the 'statement if'
--    balance and entering ExprBeg. We stay in ExprBeg until we encounter a
--    'then' while the 'expression if' balance is zero.
--    --> the condition of an if statement is one expression
-- 5. When we encounter an 'if' while already inside an expression (ExprBeg)
--    we increase the 'expression if' balance. When we reach an 'end' token
--    and all balances except 'expression if' are zero, we enter ExprEnd.
--    --> all of an 'expression if' is an expression
-- 6. We do not enter ExprBeg when we encounter a simple switch token and just
--    encountered a 'def' before. For example: 'def *(other)' is valid Ruby,
--    defining a method with name '*'. Switching to ExprBeg means omitting the
--    newline that might follow the 'def'.

lexwrapFiltered :: String -> ParseResult [(AlexPosn,Token)]
lexwrapFiltered str = case (scanFiltered str) of
    LexSuccess list -> Ok list
    LexFail p err -> LexerError p err

scanFiltered :: String -> LexerResult
scanFiltered s = case r of
  LexSuccess e -> LexSuccess $ filterTokens e
  x -> x
  where r = scan s

filterTokens :: [(AlexPosn, Token)] -> [(AlexPosn, Token)]
filterTokens ts = fst $ runState (filterTokens' ts) emptyState

-- Tokens that mean we are likely to be inside or at the start of an expression.
beginTokens = [
  "+", "-", "=", "*", "%", "/",
  "<", ">", "!", "&", "|", ".", ":", ",",
  "return"
  ]

-- Token pairs that usually contain expressions between them and must be
-- balanced. These are handled 'automatically' by filterTokens'.
balancedTokens = [("(", ")"),
                  ("[", "]")]

-- Other tokens that must be balanced. The ones in this list need some special
-- treatment and are not handled automatically.
countTokens = [ "if" ]

filterTokens' :: [(AlexPosn, Token)] -> Filter [(AlexPosn, Token)]
filterTokens' (x@(_, t):ts) = do
  s <- getState
  b <- allBalanced
  bExceptIf <- allBalancedExceptIf
  ib <- getIfBalance
  ad <- getAfterDef
  if ad
    then do setAfterDef False
    else return ()
  if s == ExprBeg && str == "if" then do
    incrIfBalance
    setState ExprBeg
    ts' <- filterTokens' ts
    return (x:ts')
  else if s == ExprEnd && str == "if" then do
    incrBalance "if"
    setState ExprBeg
    ts' <- filterTokens' ts
    return (x:ts')
  else if s == ExprBeg && str == "then" && ib == 0 then do
    decrBalance' "if"
    setState ExprBeg
    ts' <- filterTokens' ts
    return (x:ts')
  else if s == ExprBeg && str == "end" then do
    decrIfBalance
    b <- allBalanced
    if b
      then setState ExprEnd
      else return ()
    ts' <- filterTokens' ts
    return (x:ts')
  else if str == "def" then do
    setAfterDef True
    setState ExprEnd
    ts' <- filterTokens' ts
    return (x:ts')
  else
    if startswith "\n" str then do
      s <- getState
      ts' <- filterTokens' ts
      if s == ExprBeg
        then return ts'
        else return (x:ts')
    else if str `elem` beginTokens && not ad then do
      setState ExprBeg
      ts' <- filterTokens' ts
      return (x:ts')
    else if str `elem` incrTokens then do
      incrBalance str
      setState ExprBeg
      ts' <- filterTokens' ts
      return (x:ts')
    else if str `elem` decrTokens then do
      decrBalance str
      b <- allBalanced
      if b
        then setState ExprEnd
        else return ()
      ts' <- filterTokens' ts
      return (x:ts')
    else do
      b <- allBalanced
      if b
        then setState ExprEnd
        else return ()
      ts' <- filterTokens' ts
      return (x:ts')
  where str = tokenToString t
        incrTokens = Prelude.map fst balancedTokens
        decrTokens = Prelude.map snd balancedTokens
filterTokens' [] = return []

data FilterState = FS
  { st :: St
  -- token pair balances
  , balances :: Map String Int
  -- 'expression if' balance
  , ifBalance :: Int
  -- are we just behind a 'def' token?
  , afterDefToken :: Bool
  }
  deriving (Show)

data St = ExprBeg | ExprEnd
  deriving (Eq, Show)

type Filter a = State FilterState a

emptyState :: FilterState
emptyState = FS ExprEnd empty 0 False

setState :: St -> Filter ()
setState x = modify $ \s -> s { st = x }

getState :: Filter St
getState = state $ \s -> (st s, s)

setAfterDef :: Bool -> Filter ()
setAfterDef x = modify $ \s -> s { afterDefToken = x }

getAfterDef :: Filter Bool
getAfterDef = state $ \s -> (afterDefToken s, s)

incrIfBalance :: Filter ()
incrIfBalance = modify $ \s -> s { ifBalance = max ((ifBalance s) + 1) 1 }

decrIfBalance :: Filter ()
decrIfBalance = modify $ \s -> s { ifBalance = (ifBalance s) - 1 }

getIfBalance :: Filter Int
getIfBalance = state $ \s -> (ifBalance s, s)

incrBalance :: String -> Filter ()
incrBalance x = modify $ \s -> s { balances = newBalances (balances s) }
  where newBalances bs = insertWithKey (\_ n o -> max (n + o) 1) x 1 bs

decrBalance :: String -> Filter ()
decrBalance x = modify $ \s -> s { balances = newBalances (balances s) }
  where newBalances bs = insertWithKey (\_ n o -> o - n) revKey 1 bs
        revKey = fromJust $ Prelude.lookup x $ Prelude.map swap balancedTokens

decrBalance' :: String -> Filter ()
decrBalance' x = modify $ \s -> s { balances = newBalances (balances s) }
  where newBalances bs = insertWithKey (\_ n o -> o - n) x 1 bs

getBalance :: String -> Filter Int
getBalance x = state $ \s -> if member x (balances s)
  then ((balances s) ! x, s)
  else (findWithDefault 0 x' (balances s), s)
    where x' = fromJust $ Prelude.lookup x balancedTokens

-- Are all token balances at 0, including the expression if balance?
allBalanced :: Filter Bool
allBalanced = state $ \s -> (((ifBalance s) == 0) && (all ((==) 0) $ allBalances s), s)
  where allTokens = (Prelude.map fst balancedTokens) ++ countTokens
        allBalances s = Prelude.map (\k -> findWithDefault 0 k (balances s)) allTokens

-- Are all token balances at 0, ignoring the expression if balance?
allBalancedExceptIf :: Filter Bool
allBalancedExceptIf = state $ \s -> (all ((==) 0) $ allBalances s, s)
  where allTokens = (Prelude.map fst balancedTokens) ++ countTokens
        allBalances s = Prelude.map (\k -> findWithDefault 0 k (balances s)) allTokens

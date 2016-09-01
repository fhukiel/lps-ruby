--------------------------------------------------------------------------------
-- Author: CAU, 2015                                                          --
--------------------------------------------------------------------------------

module Lang.Ruby.ParseRubyError
(
  parseOutput,
  Fragment(..)
) where

import Text.Regex.Posix
import Data.List.Split

data Fragment
  = TFragment    String
  | EFragment   (Int,Int,Int) String
  deriving (Show)

parseOutput :: String -> [Fragment]
parseOutput s = parse lines []
  where lines = splitOn "\n" s

-- read TFragment State
parse :: [String] -> String -> [Fragment]
parse [] b       = (TFragment b):[]
parse (l:ls) b = if isRubyErrorBegin l 
                   then 
                     let ((_:p:s:[]):_) = l =~ regExRubyErrorBegin :: [[String]]
                     in  (TFragment (b ++ "\n")):(parseRubyError ls (-1, (read p) :: Int ,-1) s)
                   else parse ls (b ++ "\n" ++ l)

-- read RubyError State
parseRubyError :: [String] -> (Int,Int,Int) -> String -> [Fragment]
parseRubyError [] p b     = (EFragment p b):[]
parseRubyError (l:ls) p b = if isRubyErrorEnd l 
                            then (EFragment p b):(parse ls l)
                            else parseRubyError ls p b -- (b ++ "\n" ++ l)

isRubyErrorBegin :: String -> Bool
isRubyErrorBegin s = s =~ regExRubyErrorBegin

isRubyErrorEnd :: String -> Bool
isRubyErrorEnd l@(f:_) = (f /= '\t')
isRubyErrorEnd _       = True

regExRubyErrorBegin :: String
regExRubyErrorBegin = "[^:]+:([0-9]+):[^:]+:(.*)$"

---- wenn es sich um einen undefined Fehler handelt dann erneut Vorschlaege machen
--reSuggest :: String -> String
--reSuggest s = case nameOfUndefined s of
--  "" -> s
--  u  -> "`" ++ u ++ "\' nicht definiert meintest du ... : " ++ s -- TODO: levenstein

---- gibt den namen der undefinierten Methode oder Variable zurueck falls existent, sonst ""
--nameOfUndefined :: String -> String
--nameOfUndefined s = case concat $ regExUndefined s of
--  (f:s:_)  -> s
--  _        -> ""

---- Jede Subliste enthaelt den kompletten Match und die Gruppen als Elemente
--regExUndefined :: String -> [[String]]
--regExUndefined s = s =~ "undefined\\s[a-z ]*\\smethod\\s`([^\']+)\'"

--------------------------------------------------------------------------------
-- Author: CAU, 2015                                                          --
--------------------------------------------------------------------------------

module Lang.Ruby.Symboltable (emptyTable, lookupTable, insertTable, enterScope,
  exitScope, Symboltable, symbolIdentifiers, getNextId, Scope, makeSym, getScopes) where

type Scope s a = [(s, a)]

data Symboltable s a = Symboltable [Scope s a]
  deriving Show

emptyTable :: Symboltable s a
emptyTable = Symboltable [[]]

getScopes :: Symboltable s a -> [Scope s a]
getScopes (Symboltable []) = []
getScopes (Symboltable (s:ss)) = ss

makeSym :: [Scope s a] -> Symboltable s a
makeSym ss = Symboltable ss

lookupTable :: Eq s => s -> Symboltable s a -> Maybe a
lookupTable x (Symboltable ss) = lookupTable' x ss

lookupTable' :: Eq s => s -> [Scope s a] -> Maybe a
lookupTable' x []     = Nothing
lookupTable' x (s:ss) = case (lookup x s) of
  Just y  -> Just y
  Nothing -> lookupTable' x ss

insertTable :: Eq s => s -> a -> Symboltable s a -> Symboltable s a
insertTable s a (Symboltable [])      = error "No scope!"
-- Hier absichtlich Element an's Ende haengen um Shadowing-Bug nicht an dieser
-- Stelle "zufaellig" aus zu hebeln.
insertTable s a (Symboltable (s1:ss)) = Symboltable ((s1 ++ [(s, a)]):ss)

enterScope :: Symboltable s a -> Symboltable s a
enterScope (Symboltable ss) = Symboltable ([]:ss)

exitScope :: Symboltable s a -> Symboltable s a
exitScope (Symboltable [])     = error "No scope!"
exitScope (Symboltable (_:ss)) = Symboltable ss

symbolIdentifiers :: Symboltable s a -> [s]
symbolIdentifiers (Symboltable ss) = map fst (concat ss)

-- superior function for extracting the next Identfier in the IdTable, returns the rest of the IdTable as well
getNextId :: Symboltable s a -> (Maybe (s,a), Symboltable s a)
getNextId (Symboltable ss) = getNextId' ss

-- helper function for travelling through the IdTable
getNextId' :: [Scope s a] -> (Maybe (s,a) , Symboltable s a)
getNextId' [] = (Nothing, emptyTable)
getNextId' [[]] = (Nothing, emptyTable)
getNextId' (s:ss) = case (getNextInScope s) of
 (Just (x,y), Just sc) -> (Just (x,y), (Symboltable (sc:ss)))
 (Nothing, Nothing) -> getNextId' ss

-- helper function for travelling through different scopes
getNextInScope :: Scope s a -> (Maybe (s,a), Maybe (Scope s a))
getNextInScope [] = (Nothing,Nothing)
getNextInScope ((s,a):ss) = ((Just (s,a)),Just ss)

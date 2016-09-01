--------------------------------------------------------------------------------
-- Author: Thomas Ulrich, 2016                                                --
--------------------------------------------------------------------------------

module Lang.DebuggerInterface where

{-
The imports section should contain all the instructions needed to load
libraries required by your implementation of the debug functions.
For instance, you might want to load a library that allows your language
to work with TCP sockets etc. You must place the imports at the proper place within the PrettyPrinter yourself, as this is language specific.
-}
imports :: String
imports = "require 'socket'\n"

{-
The requiredHelperMethods section contains all the methods you define to 
implement the following functions, such as sending a message to the debugger via
a TCP channel. You must place the imports at the proper place within the PrettyPrinter yourself, as this is language specific.
-}
requiredHelperMethods :: String
requiredHelperMethods = "class DebuggerImpl\n\
   \def initialize()\n\
      \@socket = TCPSocket.new 'localhost', 59598;\n\
   \end\n\
   \def sendMessage(message, wait)\n\
      \@socket.puts(message);\n\
	  \if wait\n\
		\@socket.gets()\n\
	  \end\n\
   \end\n\
   \def updatePosition(line, column)\n\
		\sendMessage(\"UPDATEPOSITION;\" + line.to_s + \";\" + column.to_s, true);\n\
   \end\n\
   \def updateTable(variableName, variableValue, variableAddress, variableScope, variableClassId, variableInstanceId)\n\
		\sendMessage(\"UPDATETABLE;\" + variableName + \";\" + variableValue.to_s.strip + \";\" + variableAddress.object_id.to_s + \";\" + \"ScopeType=*=\" + toScope(variableScope) + \";\" + \"DefiningClassId=*=\" + variableClassId + \";\" + \"DefiningInstanceId=*=\" + variableInstanceId, false)\n\
   \end\n\
   \def pushOntoCallStack(methodName, params, classId, instanceId)\n\
        \paramString = \"\";\n\
		\for param in params;\n\
		  \paramString += param[1].to_s.strip + \";\";\n\
		\end\n\
		\sendMessage(\"PUSHONTOCALLSTACK;\" + methodName.to_s + \";\" + paramString + \"DefiningClassId=*=\" + classId + \";\" + \"DefiningInstanceId=*=\" + instanceId, false);\n\
        \for param in params;\n\
			\sendMessage(\"UPDATETABLE;\" + param[0].to_s.strip + \";\" + param[1].to_s.strip + \";\" + param[2].to_s.strip + \";\" + \"ScopeType=*=\" + toScope(param[3].to_s.strip) + \";\" + \"DefiningClassId=*=\" + param[4].to_s.strip + \";\" + \"DefiningInstanceId=*=\" + param[5].to_s.strip, false)\n\
		\end\n\
   \end\n\
   \def popFromCallStack()\n\
		\sendMessage(\"POPFROMCALLSTACK\", false);\n\
   \end\n\
  \def toScope(scopeName)\n\
        \return \"LOCAL\" if scopeName == \"local-variable\"\n\
		\return \"GLOBAL\" if scopeName == \"global-variable\"\n\
		\return \"CLASS\" if scopeName == \"class variable\"\n\
		\return \"INSTANCE\" if scopeName == \"instance-variable\"\n\
   \end\n\
\end\n\
\$Debugger841653486 = DebuggerImpl.new"

-- ##############################################
-- The following functions should all return Strings representing method implementations in your language
-- ##############################################

{-
The updatePosition method is called whenever a (Int, Int, Int) object is found in the AST, 
i.e. before any source code instruction that has a position attached to it.

Your implementation has to take this (Int, Int, Int) object, extract the line and column number,
package it into a UPDATEPOSITION message and send it to the debugger. Then your implementation
has to block until it receives a STEP message. Your implementation must not continue under any
circumstances without receiving a STEP message.
-}
updatePosition :: (Int, Int, Int) -> String
updatePosition (o, l, c) = ";$Debugger841653486.updatePosition(" ++ show l ++ "," ++ show c ++");"

{-
The updateTable method is called whenever a variable is changed. 

-- variableName: Name of the updated variable
-- variableValue: Value of the updated variable
-- variableAddress: Address of the updated variable
-- options: List of Strings. Strings must be Key/Value pairs, with =*= serving as the assign symbol, i.e. key=*=value

No acknowledgement from the debugger is required, i.e. your implementation should not block waiting for a reply.
-}
updateTable :: String -> String -> String -> [String] -> String
updateTable variableName variableValue variableAddress options = 
  ";$Debugger841653486.updateTable('" ++ variableName ++ "'," ++ variableValue ++ "," ++ variableAddress ++ "," ++ "(defined? " ++ variableName ++ ").to_s, " ++ "self.class.name.split('::').last, " ++ "self.object_id.to_s" ++ ");"

{-
The pushOntoCallStack method is called whenever a method call is encountered.

-- methodName: Name of the called method
-- params: A list of Strings containing the parameters
-- options: List of Strings. Strings must be Key/Value pairs, with =*= serving as the assign symbol, i.e. key=*=value

 
No acknowledgement from the debugger is required, i.e. your implementation should not block waiting for a reply.
-}
pushOntoCallStack :: String -> [String] -> [String] -> String
pushOntoCallStack methodName params options = ";$Debugger841653486.pushOntoCallStack(\"" ++ methodName ++ "\"," ++ (evalParams params) ++ ", self.class.name.split('::').last, " ++ "self.object_id.to_s);"

{-
The popFromCallStack method is called whenever a method call ends.

Your implementation has to send a POPFROMCALLSTACK message to the debugger. No acknowledgement from the debugger is
required, i.e. your implementation should not block waiting for a reply.
-}
popFromCallStack :: String
popFromCallStack =  ";$Debugger841653486.popFromCallStack();"

evalParams :: [String] -> String
evalParams []     = "[]"
evalParams params = "[" ++ (init (foldr (\x col -> "[\"" ++ x ++ "\"," ++ x ++ ".to_s.strip" ++ "," ++ x ++ ".object_id.to_s" ++ "," ++ "(defined? " ++ x ++ ").to_s, " ++ "self.class.name.split('::').last, " ++ "self.object_id.to_s]," ++ col) "" params)) ++ "]"

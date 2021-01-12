module Workspaces ( workspaceNames ) where

-- worspace names are just the numbers from 1 to 9 and zero
workspaceNames =  [[c]| c <- ['1'..'9'] ++ ['0', 'a', 'b']] 

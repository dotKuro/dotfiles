module Keybindings (keybindings) where


import qualified Data.Map

import Keybindings.Applications (applicationKeybindings)
import Keybindings.Media (mediaKeybindings)
import Keybindings.Navigation (navigationKeybindings)
import Keybindings.Workspaces (workspaceKeybindings)


keybindings _ =
    Data.Map.fromList $
      applicationKeybindings
      ++ mediaKeybindings
      ++ navigationKeybindings
      ++ workspaceKeybindings
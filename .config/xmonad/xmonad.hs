import Autostart (autostart)
import Keybindings (keybindings, keymod)
import Layouts (layouts, manageHooks)
import Workspaces (workspaceNames)
import XMonad (xmonad)
import XMonad.Config (def)
import XMonad.Hooks.EwmhDesktops (ewmh)
import XMonad.Hooks.ManageDocks (docks)

import qualified XMonad as XM

main = do
  xmonad $ docks $ ewmh $ def
    { XM.keys = keybindings 
    , XM.layoutHook = layouts
    , XM.modMask = keymod
    , XM.workspaces = workspaceNames
    , XM.manageHook = manageHooks
    , XM.borderWidth = 5
    , XM.startupHook = autostart
    , XM.focusedBorderColor = "#331177"
    , XM.normalBorderColor = "#000000"
    }
  

  

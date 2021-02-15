import qualified Keybindings.Shared as KS

import Autostart (autostart)
import Keybindings (keybindings)
import Layouts (layouts, manageHooks)
import Polybar (polybarLogging)
import Workspaces (initialWorkspaceNames)
import XMonad (xmonad)
import XMonad.Config (def)
import XMonad.Hooks.EwmhDesktops (ewmh)
import XMonad.Hooks.ManageDocks (docks)

import qualified XMonad as XM


main = do
  xmonad $ docks $ ewmh $ def
    { XM.keys = keybindings 
    , XM.layoutHook = layouts
    , XM.modMask = KS.modKey
    , XM.workspaces = initialWorkspaceNames
    , XM.manageHook = manageHooks
    , XM.borderWidth = 5
    , XM.startupHook = autostart
    , XM.logHook = polybarLogging
    , XM.focusedBorderColor = "#5E81AC"
    , XM.normalBorderColor = "#000000"
    }
  

  

module Keybindings.Applications (applicationKeybindings) where

import qualified Keybindings.Shared as KS

import qualified XMonad as XM

applicationKeybindings :: [KS.Keybinding]
applicationKeybindings = 
  [ ((KS.modKey, XM.xK_w), XM.spawn "termite") -- terminal
  , ((KS.modKey, XM.xK_e), XM.spawn "rofi -show drun") -- application launcher
  , ((KS.modKey, XM.xK_s), XM.spawn "loginctl lock-session") -- screen locker
  , ((KS.modKey, XM.xK_a), XM.spawn "qutebrowser") -- browser
  , ((KS.modkey, XM.xK_p), XM.spawn "passmenu") -- password manager
  ]



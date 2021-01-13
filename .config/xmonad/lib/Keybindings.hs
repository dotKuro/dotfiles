module Keybindings (keybindings, keymod) where

import Data.Map (fromList)
import Graphics.X11.ExtraTypes.XF86 
  ( xF86XK_AudioLowerVolume
  , xF86XK_AudioMute
  , xF86XK_AudioRaiseVolume
  , xF86XK_MonBrightnessDown
  , xF86XK_MonBrightnessUp
  )
import XMonad
  ( io
  , kill
  , noModMask
  , sendMessage
  , shiftMask
  , spawn
  , windows
  , withFocused
  , XConfig(..)
  , (.|.)
  )
import XMonad.Actions.CycleWS (nextScreen, shiftNextScreen)
import XMonad.Layout.Maximize (maximizeRestore)
import XMonad.StackSet
  ( focusDown
  , focusMaster
  , focusUp
  , greedyView
  , shift
  , shiftMaster
  , sink
  , swapDown
  , swapUp
  )

import qualified XMonad as XM

-- main modifier for most shortcuts
-- mod4Mask is the super key, mod1Mask is the alt key
keymod = XM.mod4Mask

-- shortcuts and key bindings
keybindings conf@(XConfig {XM.modMask = modMask}) =
    fromList $
      applicationKeyBindings
      ++ navigationKeyBindings
      ++ workspaceKeyBindings
      ++ layoutKeyBindings
      ++ fnKeyBindings
      ++ musicPlayerKeyBindings
    where
      -- spawn applications
      applicationKeyBindings =
        [ ((modMask, XM.xK_w), spawn "termite")
        , ((modMask, XM.xK_e), spawn "rofi -show drun")
        , ((modMask, XM.xK_s), spawn "loginctl lock-session")
        ]

      -- navigate the window manager 
      navigationKeyBindings =
        [ -- cycle through the window stack
          ((modMask, XM.xK_j), windows focusDown)
        , ((modMask, XM.xK_k), windows focusUp)
          -- Focus the master window
        , ((modMask, XM.xK_space), windows focusMaster)  
          -- move the windows thorugh the window stack
        , ((modMask .|. shiftMask, XM.xK_j), windows swapDown)
        , ((modMask .|. shiftMask, XM.xK_k), windows swapUp)
          -- Shift the current Window to the master are while keeping the other windows in order
        , ((modMask .|. shiftMask, XM.xK_space), windows shiftMaster)
          -- change the size of the Master and Slave area
        , ((modMask, XM.xK_h), sendMessage XM.Shrink)
        , ((modMask, XM.xK_l), sendMessage XM.Expand)
          -- close the current window
        , ((modMask, XM.xK_q), kill)
          -- put a floating window to tilling mode
        , ((modMask, XM.xK_i), withFocused $ windows . sink)
        ]

      -- organize workspaces
      workspaceKeyBindings =
        -- switch between workspaces
        [ ((modMask, key), windows $ greedyView workspace) |
          (workspace, key) <- zip (XM.workspaces conf) ([XM.xK_1..XM.xK_9] ++ [XM.xK_0, XM.xK_minus, XM.xK_equal])
        ] ++
        -- move windows to another workspace
        [
          ((modMask .|. shiftMask, key), windows $ shift workspace) | 


          (workspace, key) <- zip (XM.workspaces conf) ([XM.xK_1..XM.xK_9] ++ [XM.xK_0, XM.xK_minus, XM.xK_equal])
        ] ++
        -- switch and shift to next monitor
        [ ((modMask, XM.xK_semicolon), nextScreen),
          ((modMask .|. shiftMask, XM.xK_semicolon), shiftNextScreen)
        ]

      -- organize layouts
      layoutKeyBindings =
        [ -- cycle through the layouts
          ((modMask, XM.xK_g), sendMessage XM.NextLayout)
          -- toggle maximize a window
        , ((modMask, XM.xK_f), withFocused $ sendMessage . maximizeRestore)
        ]

      -- fn utils
      fnKeyBindings = 
        [ -- volume control
          ((noModMask, xF86XK_AudioRaiseVolume), spawn "pamixer -i 10 --allow-boost")
        , ((noModMask, xF86XK_AudioLowerVolume), spawn "pamixer -d 10 --allow-boost")
        , ((noModMask, xF86XK_AudioMute), spawn "pamixer -t ")
        ]
        
      musicPlayerKeyBindings =
        [ ((modMask, XM.xK_period), spawn "playerctl play-pause")
        , ((modMask, XM.xK_comma), spawn "playerctl previous")
        , ((modMask, XM.xK_slash), spawn "playerctl next")
        ]

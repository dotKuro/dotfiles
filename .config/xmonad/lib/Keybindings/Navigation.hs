module Keybindings.Navigation (navigationKeybindings) where

import qualified Keybindings.Shared as KS

import qualified XMonad.Actions.CycleWS as CycleWS
import qualified XMonad.Layout.Maximize as Maximize

import qualified XMonad.StackSet as XW

import XMonad((.|.))
import qualified XMonad as XM

navigationKeybindings =
  [ ((KS.modKey, XM.xK_j), XM.windows XW.focusDown) -- focus next window on the stack
  , ((KS.modKey, XM.xK_k), XM.windows XW.focusUp) -- focus previous window on the stack
  , ((KS.modKey, XM.xK_space), XM.windows XW.focusMaster)  -- focus main window
  , ((KS.modKey .|. XM.shiftMask, XM.xK_j), XM.windows XW.swapDown) -- swap with next window on the stack
  , ((KS.modKey .|. XM.shiftMask, XM.xK_k), XM.windows XW.swapUp) -- swap with previous window on the stack
  , ((KS.modKey .|. XM.shiftMask, XM.xK_space), XM.windows XW.shiftMaster) -- promote current window to main window while keeping the other windows in order
  , ((KS.modKey, XM.xK_h), XM.sendMessage XM.Shrink) -- shrink the main window
  , ((KS.modKey, XM.xK_l), XM.sendMessage XM.Expand) -- grow the main window
  , ((KS.modKey, XM.xK_q), XM.kill) -- close the current window
  , ((KS.modKey, XM.xK_i), XM.withFocused $ XM.windows . XW.sink) -- tile a focused floating window
  , ((KS.modKey, XM.xK_g), XM.sendMessage XM.NextLayout) -- change layout
  , ((KS.modKey, XM.xK_f), XM.withFocused $ XM.sendMessage . Maximize.maximizeRestore) -- toggle fullscreen for focused window
  , ((KS.modKey, XM.xK_semicolon), CycleWS.nextScreen) -- focus the next screen
  , ((KS.modKey .|. XM.shiftMask, XM.xK_semicolon), CycleWS.shiftNextScreen) -- move window to next screen
  ]

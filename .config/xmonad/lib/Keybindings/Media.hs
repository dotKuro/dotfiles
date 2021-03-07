module Keybindings.Media (mediaKeybindings) where

import qualified Keybindings.Shared as KS

import qualified Graphics.X11.ExtraTypes.XF86 as XF86

import qualified XMonad as XM

mediaKeybindings :: [KS.Keybinding]
mediaKeybindings = 
  [ ((XM.noModMask, XF86.xF86XK_AudioRaiseVolume), XM.spawn "pamixer -i 5")
  , ((XM.noModMask, XF86.xF86XK_AudioLowerVolume), XM.spawn "pamixer -d 5")
  , ((XM.noModMask, XF86.xF86XK_AudioMute), XM.spawn "pamixer -t ")
  , ((KS.modKey, XM.xK_period), XM.spawn "playerctl play-pause")
  , ((KS.modKey, XM.xK_comma), XM.spawn "playerctl previous")
  , ((KS.modKey, XM.xK_slash), XM.spawn "playerctl next")
  ]
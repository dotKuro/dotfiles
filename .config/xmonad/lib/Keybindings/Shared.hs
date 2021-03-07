module Keybindings.Shared (modKey, Keybinding) where

import qualified XMonad as XM

type Keybinding = ((XM.KeyMask, XM.KeySym), XM.X ())

modKey = XM.mod4Mask -- super key as main modifier

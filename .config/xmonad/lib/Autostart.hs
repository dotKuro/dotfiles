module Autostart (autostart) where

import XMonad(X)
import XMonad.Util.SpawnOnce (spawnOnce)

autostart :: X()
autostart = do
  spawnOnce "xcompmgr -n -C"
  spawnOnce "udiskie --tray"

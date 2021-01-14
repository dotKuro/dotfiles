module Autostart (autostart) where

import XMonad(X, spawn)
import XMonad.Util.SpawnOnce (spawnOnce)

autostart :: X()
autostart = do
  spawnOnce "xcompmgr -n -C"
  spawnOnce "udiskie --tray"
  spawnOnce "polybar primary"
  spawnOnce "xss-lock -- betterlockscreen -l blur"


module Autostart (autostart) where

import XMonad(X, spawn)
import XMonad.Util.SpawnOnce (spawnOnce)

autostart :: X()
autostart = do
  spawn "feh --bg-scale ~/Pictures/gengar-wallpaper-2x.png ~/Pictures/snorlax-wallpaper.jpg"
  spawnOnce "xcompmgr -n -C"
  spawnOnce "udiskie --tray"
  spawnOnce "polybar primary"
  spawnOnce "xss-lock -- betterlockscreen -l blur"


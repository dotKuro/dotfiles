module Autostart (autostart) where

import XMonad.Util.SpawnOnce (spawnOnce)

import qualified XMonad as XM

autostart :: XM.X()
autostart = do
  spawnOnce "xcompmgr -n -C" -- compositor
  spawnOnce "udiskie --tray" -- auto mounter
  spawnOnce "polybar primary" -- taskbar
  spawnOnce "xss-lock -- betterlockscreen -l blur" -- lock-screen daemon
  spawnOnce "nextcloud" -- nextcloud client


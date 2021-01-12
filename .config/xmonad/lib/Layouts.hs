module Layouts (layouts, manageHooks) where

import XMonad (className, composeAll, (|||), (-->))
import XMonad.Hooks.ManageDocks (avoidStruts)
import XMonad.Hooks.ManageHelpers (doFullFloat, isFullscreen)
import XMonad.Layout.Maximize (maximize, maximizeWithPadding)
import XMonad.Layout.NoBorders (Ambiguity(OnlyScreenFloat), lessBorders)


import qualified XMonad as XM

layouts =
  avoidStruts $ maximizeWithPadding 0 $ lessBorders OnlyScreenFloat $ tall ||| XM.Mirror tall
  where
    tall = XM.Tall 1 (3/100) (1/2)

manageHooks =
  composeAll 
    [ -- make windows that request fullscreen actually real fullscreen
      isFullscreen --> doFullFloat
    ]

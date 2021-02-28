module Layouts (layouts, manageHooks) where

import qualified XMonad.Hooks.ManageDocks as ManageDocks
import qualified XMonad.Hooks.ManageHelpers as ManageHelpers
import qualified XMonad.Layout.Maximize as Maximize
import qualified XMonad.Layout.NoBorders as NoBorders
import qualified XMonad.StackSet as XW

import qualified Data.Map

import XMonad ((|||), (-->))
import qualified XMonad as XM 


data AllFloats = AllFloats deriving (Read, Show)

instance NoBorders.SetsAmbiguous AllFloats where
    hiddens _ wset _ _ _ = Data.Map.keys $ XW.floating wset

layouts =
  ManageDocks.avoidStruts -- windows won't collide with external taskbar
  $ Maximize.maximizeWithPadding 0 -- avoid padding for fullscreen windows
  $ NoBorders.lessBorders AllFloats -- avoid borders for floating windows
  $ tall ||| wide -- vertical or horizontal split layout
  where
    tall = XM.Tall 1 (3/100) (1/2)
    wide = XM.Mirror tall

manageHooks =
  XM.composeAll 
    [ ManageHelpers.isFullscreen --> ManageHelpers.doFullFloat -- correctly show fullscreen windows
    ]

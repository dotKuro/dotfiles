module Polybar (polybarLogging) where

import Workspaces (MetaWorkspaces(..), ActiveMetaWorkspace(..))

import qualified Data.List.Extra
import qualified System.Process

import qualified XMonad as XM
import qualified XMonad.StackSet as XW
import qualified XMonad.Util.ExtensibleState as XS
import qualified XMonad.Hooks.DynamicLog as XD



polybarLogging :: XM.X ()
polybarLogging = do
  MetaWorkspaces { active = _active } <- XS.get
  case _active of
    Named name -> logMetaWorkspace name
    Scratch -> logMetaWorkspace "scratch"
  where
    logMetaWorkspace name = do
      currentWorkspace <- getCurrentlyActiveWorkspace
      XM.io $ writeFile "/tmp/xmonad-polybar"
        $ metaWorkspaceString name `space` workspaceString currentWorkspace
      XM.io $ System.Process.callCommand "polybar-msg hook workspaces 1"
      
    getCurrentlyActiveWorkspace = do
      currentTag <- XM.withWindowSet (return . XW.currentTag)
      return $ last currentTag

    metaWorkspaceString name = withBackground $ Data.List.Extra.upper $ XD.pad name
    workspaceString currentWorkspace = do
      concatMap (\ws ->
           if ws == currentWorkspace
             then withBackground $ XD.pad [ws]
             else XD.pad [ws]
        ) ['1'..'3']
        
    withBackground text =
      "%{B#5E81AC}" ++ text ++ "%{B-}"
    space a b = a ++ " " ++ b
  

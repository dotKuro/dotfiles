module Polybar (polybarLogging) where

import Workspaces (MetaWorkspaces(..), ActiveMetaWorkspace(..))

import qualified System.Directory
import System.FilePath ((</>))
import qualified System.Process

import qualified XMonad as XM
import qualified XMonad.StackSet as XW
import qualified XMonad.Util.ExtensibleState as XS

polybarLogging :: XM.X ()
polybarLogging = do
  MetaWorkspaces { active = _active } <- XS.get
  case _active of
    Named name -> logMetaWorkspace name
    Scratch -> logMetaWorkspace "scratch"
  where
    logMetaWorkspace name = do
      tempDir <- XM.io System.Directory.getTemporaryDirectory
      workspaceString <- getWorkspaceString
      XM.io $ writeFile (tempDir </> "xmonad-polybar" ) $
        withPaddedBackground name ++ " " ++ workspaceString
      XM.io $ System.Process.callCommand "polybar-msg hook workspaces 1"
    getCurrentlyActiveWorkspace = do
      currentTag <- XM.withWindowSet (return . XW.currentTag)
      return $ last currentTag
    getWorkspaceString = do
      currentWorkspace <- getCurrentlyActiveWorkspace
      return $ concatMap (\ws ->
             if ws == currentWorkspace
               then withPaddedBackground [ws]
               else padded [ws]
          ) ['1'..'3']
    padded text = " " ++ text ++ " "
    withPaddedBackground text =
      "%{B#5E81AC}" ++ padded text ++ "%{B-}"
  

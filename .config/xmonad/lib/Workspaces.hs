module Workspaces
  ( initialWorkspaceNames
  , workspaceCount
  , MetaWorkspaces(..)
  , ActiveMetaWorkspace(..)
  , switchOrCreateMetaWorkSpaceFromMenu
  , toggleScratchMetaWorkspace
  , shiftToMetaWorkspaceFromMenu
  ) where

import qualified Control.Monad
import qualified Data.List

import qualified XMonad.Actions.DynamicWorkspaces as DynamicWorkspaces
import qualified XMonad.Util.Dmenu as Dmenu
import qualified XMonad.Actions.OnScreen as OnScreen

import qualified XMonad.Util.ExtensibleState as XS
import qualified XMonad.StackSet as XW
import qualified XMonad as XM


data ActiveMetaWorkspace = Scratch | Named String

data MetaWorkspaces = MetaWorkspaces {
  active :: ActiveMetaWorkspace,
  last :: ActiveMetaWorkspace,
  allNames :: [String]
  }

workspaceCount :: Int
workspaceCount = 3 -- number of workspaces for each meta workspace

instance XM.ExtensionClass MetaWorkspaces where
  initialValue = MetaWorkspaces Scratch Nothing []

initialWorkspaceNames :: [String]
initialWorkspaceNames =  createWorkspaceNames Scratch

createWorkspaceNames :: ActiveMetaWorkspace -> [String]
createWorkspaceNames metaWorkspace =
  case metaWorkspace of
    Scratch -> go "" -- i.e.: ["1", "2", "3"]
    Named metaWorkspaceName -> go metaWorkspaceName -- i.e.: ["work1", "work2", "work3"]
  where
    go metaWorkspaceName = [metaWorkspaceName ++ show c | c <- [1..workspaceCount]]


switchOrCreateMetaWorkSpace :: ActiveMetaWorkspace -> XM.X()
switchOrCreateMetaWorkSpace Scratch = switchMetaWorkspace Scratch
switchOrCreateMetaWorkSpace (Named name) = do
  MetaWorkspaces { allNames = allNames_ } <- XS.get
  Control.Monad.when
    (name `notElem` allNames_)
    $ createMetaWorkspace name
  switchMetaWorkspace name
    

switchMetaWorkspace :: ActiveMetaWorkspace -> XM.X()
switchMetaWorkspace metwaWorkspace = do
  XS.modify (\metas -> metas { active = metaWorkspace, lastNamed = active metas })
  mapM_ (\number -> viewOnScreen (number-1) number) $ reverse [1..XM.S workspaceCount]
  where
    name =
      case metaWorkspace of
        Scratch -> ""
        Named name_ -> name_
    viewOnScreen screen workspaceNumber =
      XM.windows $ OnScreen.viewOnScreen screen $ name ++ show (fromIntegral workspaceNumber)


createMetaWorkspace :: String -> XM.X()
createMetaWorkspace name = do
  mapM_ DynamicWorkspaces.addHiddenWorkspace $ createWorkspaceNames $ Named name
  XS.modify (\metas@MetaWorkspaces { allNames = allNames_ } -> metas { allNames = name:allNames_ })


switchOrCreateMetaWorkSpaceFromMenu :: XM.X()
switchOrCreateMetaWorkSpaceFromMenu = do
  metWorkspace <- getMetWorkspaceFromMenu "switch metaworkspace"
  switchOrCreateMetaWorkSpace metaWorkspace


shiftWindowToMetaWorkspace :: ActiveMetaWorkspace -> XM.X()
shiftWindowToMetaWorkspace Scratch = shift "1"
shiftWindowToMetaWorkspace name = shift (name ++ "1")
  where
    shift = XM.windows . XW.shift 


shiftToMetaWorkspaceFromMenu :: XM.X()
shiftToMetaWorkspaceFromMenu = do
  metWorkspace <- getMetWorkspaceFromMenu "shift window to metaworkspace"
  shiftWindowToMetaWorkspace metaWorkspace


toggleScratchMetaWorkspace :: XM.X()
toggleScratchMetaWorkspace = do
  MetaWorkspaces { active = active_, lastNamed = lastNamed_ } <- XS.get
  case (active_, lastNamed_) of
    (Named mws, _) -> switchMetaWorkspace Scratch
    (Scratch, Just mws) -> switchMetaWorkspace mws
    (Scratch, Nothing) -> return ()


getMetWorkspaceFromMenu :: String -> XM.X Maybe ActiveMetaWorkspace
getMetWorkspaceFromMenu prompt =
  MetaWorkspaces { allNames = allNames_ } <- XS.get
  name <- DMenu.menuArgs "rofi" ["-dmenu", "-p", prompt ] ("scratch":allNames_)
  case name of
    "" -> Nothing
    "scratch" -> Just Scratch
    _ -> Just $ Named name
    
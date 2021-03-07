module Keybindings.Workspaces (workspaceKeybindings) where

import qualified Workspaces

import qualified Keybindings.Shared as KS

import qualified XMonad.Util.ExtensibleState as XS
import qualified XMonad.StackSet as XW

import XMonad ((.|.))
import qualified XMonad as XM


workspaceKeybindings = 
  forAllWorkspaces KS.modKey XW.greedyView
  ++ forAllWorkspaces (KS.modKey .|. XM.shiftMask) XW.shift
  ++
    [ ((KS.modKey, XM.xK_m), Workspaces.switchOrCreateMetaWorkSpaceFromMenu)
    , ((KS.modKey .|. XM.shiftMask, XM.xK_m), Workspaces.shiftToMetaWorkspaceFromMenu)
    , ((KS.modKey, XM.xK_n), Workspaces.toggleScratchMetaWorkspace)
    ]


forAllWorkspaces mod operation =
  [ (
      (mod, key),
      do
        Workspaces.MetaWorkspaces { Workspaces.active = active } <- XS.get
        case active of
          Workspaces.Scratch -> applyOperation "" number
          Workspaces.Named name -> applyOperation name number
    ) | (key, number) <- zip [XM.xK_1..] [1..Workspaces.workspaceCount]
  ]
  where
    applyOperation metaWorkspaceName number =
        XM.windows $ operation $ metaWorkspaceName ++ show number


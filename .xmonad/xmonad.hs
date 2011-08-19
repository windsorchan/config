--
-- xmonad example config file for xmonad-0.9
--
-- A template showing all available configuration hooks,
-- and how to override the defaults in your own xmonad.hs conf file.
--
-- Normally, you'd only override those defaults you care about.
--
-- NOTE: Those updating from earlier xmonad versions, who use
-- EwmhDesktops, safeSpawn, WindowGo, or the simple-status-bar
-- setup functions (dzen, xmobar) probably need to change
-- xmonad.hs, please see the notes below, or the following
-- link for more details:
--
-- http://www.haskell.org/haskellwiki/Xmonad/Notable_changes_since_0.8
--
 
import XMonad hiding ((|||))
import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import Data.Monoid
import System.IO (hPutStrLn)
import System.Exit

import XMonad.Actions.CycleWS
import XMonad.Actions.FindEmptyWorkspace (tagToEmptyWorkspace, viewEmptyWorkspace)
import XMonad.Actions.Warp               (Corner(..), banishScreen)
import XMonad.Actions.WithAll            (killAll)
import XMonad.Actions.SwapWorkspaces

import XMonad.Layout.NoBorders
import XMonad.Layout.ResizableTile (ResizableTall(..), MirrorResize(..))
import XMonad.Layout.LayoutHints
import XMonad.Layout.LayoutCombinators   ((|||), JumpToLayout(..))

import XMonad.ManageHook
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.SetWMName

import XMonad.Util.Run (spawnPipe)
import XMonad.Util.EZConfig (additionalKeysP)
 
main = do
    d <- spawnPipe myLeft
    spawn myRight
    xmonad $ withUrgencyHook NoUrgencyHook $ defaultConfig {
        terminal           = myTerminal,
        startupHook        = setWMName "LG3D",
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        logHook            = myLogHook d
    } `additionalKeysP` myKeys
 
-- Basic Settings
myTerminal      = "urxvtc"
myWorkspaces    = ["1:vim","2:term","3:web","4:media","5:dev","6:pdf"] ++ map show [7..9]
myNormalBorderColor  = "#1d1d1d"
myFocusedBorderColor = "#535d6c"

-- Font and Color Settings
myFont = "-*-Droid Sans-medium-r-normal-*-14-*-*-*-*-*-*-*"
myDzenFGColor = "#e1e0e5"
myDzenBGColor = "#2a2b2f"
myColBgNormal = "#2a2b2f"
myColFgFocus  = "#62acce"
myColFgNormal = "#e1e0e5"
myColFgUnimp  = "#67686b"
myColFgUrgent = "#e6ac32"

myLauncher = "exe=`dmenu_path | dmenu -b -nb '"++ myColBgNormal ++ "' -nf '" ++ myColFgNormal ++ "' -fn 'Droid Serif-12' -p '$'` && eval \"exec $exe\""
myLeft = "dzen2 -x 0 -y 0 -w 1000 -ta l -fn '" ++ myFont ++ "' -bg " ++ myDzenBGColor ++ " -fg " ++ myDzenFGColor
myRight = "conky -c ~/.dzen_conkyrc | dzen2 -ta r -fn '" ++ myFont ++ "' -x 1000 -y 0 -w 920"
 
myLayout = avoidStruts $ smartBorders $ standardLayouts

    where
        standardLayouts = tiled ||| Mirror tiled ||| layoutHintsToCenter Full
        tiled = Tall 1 (3/100) (1/2)

myManageHook = mainManageHook <+> manageDocks

    where
        -- the main managehook
        mainManageHook = composeAll . concat $
            [ [ classOrName v --> a | (v,a) <- myFloats ]
            , [ classOrTitle v --> doShift ws | (v,ws) <- myShifts ]
            , [ isDialog --> doCenterFloat ]
            , [ isFullscreen --> doF W.focusDown <+> doFullFloat ]
            ]

        classOrName x = className =? x <||> stringProperty "WM_NAME" =? x
        classOrTitle x = className =? x <||> title =? x

        myFloats = [ ("MPlayer" , doFloat )
                    , ("Xmessage" , doCenterFloat)
                    , ("XFontSel" , doCenterFloat)
                    , ("Eclipse" , doCenterFloat)
                    , ("jclient-LoginFrame" , doCenterFloat)
                    , ("IB Gateway" , doCenterFloat)
                    ]

        myShifts = [ ("Zathura" , "6:pdf" )
                    , ("Evince" , "6:pdf" )
                    , ("Eclipse" , "5:dev" )
                    ]

 
myLogHook h = dynamicLogWithPP $ defaultPP
    -- display current workspace as darkgrey on light grey (opposite of default colors)
    { ppCurrent         = dzenColor myColFgFocus "" . pad 

    -- display other workspaces which contain windows as a brighter grey
    , ppHidden          = dzenColor myColFgNormal "" . pad 

    -- display other workspaces with no windows as a normal grey
    , ppHiddenNoWindows = dzenColor myColFgUnimp "" . pad 

    -- display the current layout as a brighter grey
    , ppLayout          = dzenColor myColFgNormal "" . pad 

    -- if a window on a hidden workspace needs my attention, color it so
    , ppUrgent          = dzenColor myColFgUrgent "" . pad . dzenStrip

    -- shorten if it goes over 100 characters
    , ppTitle           = shorten 100  

    -- no separator between workspaces
    , ppWsSep           = ""

    -- put a few spaces between each object
    , ppSep             = "  "

    , ppOutput          = hPutStrLn h
    }

myKeys :: [(String, X())]
myKeys = [ ("M-p"                   , spawn myLauncher               ) -- dmenu app launcher
         , ("M4-b"                  , spawn "jumanji"                ) -- open web client

         -- extended workspace navigations
         , ("M-<Esc>"               , toggleWS                       ) -- switch to the most recently viewed ws
         , ("M-<Backspace>"         , focusUrgent                    ) -- focus most recently urgent window
         , ("M-S-<Backspace>"       , clearUrgents                   ) -- make urgents go away
         , ("M-0"                   , viewEmptyWorkspace             ) -- go to next empty workspace
         , ("M-S-0"                 , tagToEmptyWorkspace            ) -- send window to empty workspace and view it

         -- extended window movements
         , ("M-o"                   , mirrorShrink                   ) -- shink slave panes vertically
         , ("M-i"                   , mirrorExpand                   ) -- expand slave panes vertically
         , ("M-f"                   , jumpToFull                     ) -- jump to full layout
         , ("M-b"                   , banishScreen LowerRight        ) -- banish the mouse

         -- non-standard screen navigation
         , ("M-h"                   , focusScreen 0                  ) -- focus left screen
         , ("M-l"                   , focusScreen 1                  ) -- focus rght screen
         , ("M-S-h"                 , shrink                         ) -- shrink master (was M-h)
         , ("M-S-l"                 , expand                         ) -- expand master (was M-l)

         -- kill, reconfigure, exit
         , ("M4-w"                  , kill                           ) -- close all windows on this ws
         , ("M4-S-c"                , killAll                        ) -- close all windows on this ws
         , ("M-q"                   , myRestart                      ) -- restart xmonad

         -- CycleWS
         , ("M-<L>"                 , prevWS                         )
         , ("M-<R>"                 , nextWS                         )

         -- Swap Workspaces
         , ("M-S-<L>"               , swapTo Prev                    )
         , ("M-S-<R>"               , swapTo Next                    )
         ]

         ++

         [ (otherModMasks ++ "M-" ++ [key], action tag)
              | (tag, key)  <- zip myWorkspaces "123456789"
              , (otherModMasks, action) <- [ ("", windows . W.view)
                                           , ("S-", windows . W.shift)]
         ]

     where

        shrink = sendMessage Shrink
        expand = sendMessage Expand

        mirrorShrink = sendMessage MirrorShrink
        mirrorExpand = sendMessage MirrorExpand

        focusScreen n = screenWorkspace n >>= flip whenJust (windows . W.view)
        jumpToFull    = sendMessage $ JumpToLayout "Full"

        myRestart = spawn $ "for pid in `pgrep conky`; do kill -9 $pid; done && " ++
                            "for pid in `pgrep dzen2`; do kill -9 $pid; done && " ++
                            "xmonad --recompile && xmonad --restart"

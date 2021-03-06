{-
 - File: xmonad.hs
 - Author: Clement Trosa <me@trosa.io>
 - Date: 19/06/2017 08:59:27 AM
 - Last Modified: 19/06/2017 08:59:27 AM
 -}

import           XMonad
import           XMonad.Config.Azerty
import qualified XMonad.StackSet as W
import           System.IO
import           System.Exit (exitSuccess)
import           Data.Maybe (isJust)
import           Data.List
import qualified Data.Map as M
import           Data.Bits ((.|.))
import           XMonad.Util.EZConfig (additionalKeysP, additionalMouseBindings)
import           XMonad.Util.NamedScratchpad (NamedScratchpad(NS), namedScratchpadManageHook, namedScratchpadAction, customFloating)
import           XMonad.Util.Run (safeSpawn, unsafeSpawn, runInTerm, spawnPipe)
import           XMonad.Util.SpawnOnce
import qualified XMonad.Util.Dzen as Dzen
import           XMonad.Hooks.DynamicLog (dynamicLogWithPP, defaultPP, dzenColor, pad, shorten, wrap, PP(..))
import           XMonad.Hooks.ManageDocks (avoidStruts, ToggleStruts(..))
import           XMonad.Hooks.Place (placeHook, withGaps, smart)
import           XMonad.Hooks.InsertPosition
import           XMonad.Hooks.FloatNext (floatNextHook, toggleFloatNext, toggleFloatAllNew)
import		 XMonad.Hooks.DynamicLog
import		 XMonad.Hooks.SetWMName
import 		 XMonad.Hooks.ManageHelpers
import 		 XMonad.Hooks.EwmhDesktops (ewmhDesktopsStartup)
import		 XMonad.Hooks.DynamicLog
import		 XMonad.Hooks.UrgencyHook
import           XMonad.Actions.Promote
import           XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import           XMonad.Actions.CopyWindow (kill1, copyToAll, killAllOtherCopies, runOrCopy)
import           XMonad.Actions.WindowGo (runOrRaise, raiseMaybe)
import           XMonad.Actions.WithAll (sinkAll, killAll)
import           XMonad.Actions.CycleWS (prevWS, nextWS, moveTo, shiftTo, WSType(..))
import           XMonad.Actions.GridSelect (GSConfig(..), goToSelected, bringSelected, colorRangeFromClassName, buildDefaultGSConfig)
import           XMonad.Actions.DynamicWorkspaces (addWorkspacePrompt, removeEmptyWorkspace)
import           XMonad.Actions.UpdatePointer
import           XMonad.Actions.MouseResize
import qualified XMonad.Actions.ConstrainedResize as Sqr
import           XMonad.Layout.PerWorkspace (onWorkspace)
import           XMonad.Layout.Renamed (renamed, Rename(CutWordsLeft, Replace))
import           XMonad.Layout.WorkspaceDir
import           XMonad.Layout.Spacing (spacing)
import           XMonad.Layout.Minimize
import           XMonad.Layout.Maximize
import           XMonad.Layout.BoringWindows (boringWindows)
import           XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import           XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import           XMonad.Layout.Reflect (reflectVert, reflectHoriz, REFLECTX(..), REFLECTY(..))
import           XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), Toggle(..), (??))
import           XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import           XMonad.Layout.GridVariants (Grid(Grid))
import           XMonad.Layout.OneBig
import           XMonad.Layout.ZoomRow (zoomRow, zoomIn, zoomOut, zoomReset, ZoomMessage(ZoomFullToggle))
import           XMonad.Layout.IM (withIM, Property(Role))
import           XMonad.Layout.NoBorders
import           XMonad.Layout.Gaps
import           XMonad.Layout.Fullscreen
import           XMonad.Layout.SimplestFloat
import           XMonad.Layout.Tabbed
import           XMonad.Layout.ResizableTile
import           XMonad.Layout.Circle
import           XMonad.Layout.ThreeColumns
import           XMonad.Prompt (defaultXPConfig, XPConfig(..), XPPosition(Top), Direction1D(..))

sFont    = "-*-lemon-*-*-*-*-*-*-*-*-*-*-*-*"
barFont    = "-*-lemon-*-*-*-*-*-*-*-*-*-*-*-*"
sBordW   =  2 -- Set width border size
sColorsB = "#1F1F1F" -- Unselected terminal
sColorsF = "#683e3e" -- Selected Terminal
sColorsW = "#6D6B6E" -- Colors when activity or warning
sGap = 0 -- Gap between windowns
sSpace = 0 -- space between windows

myModMask = mod4Mask -- Set as "SUPER" key akka w1nd0w$
myTerminal = "urxvtc" -- The terminal to use.
-- Prompt Colors
myPromptConfig = defaultXPConfig { font                  = sFont
                                 , bgColor               = sColorsB
                                 , fgColor               = sColorsF
                                 , bgHLight              = sColorsB
                                 , fgHLight              = sColorsF
                                 , borderColor           = sColorsW
                                 , promptBorderWidth     = sBordW
                                 , height                = 20
                                 , position              = Top
                                 , historySize           = 0
                                 }
-- Grid selector colors
myGridConfig = colorRangeFromClassName
    (0x00,0x00,0x00) -- lowest inactive bg
    (0xBB,0xAA,0xFF) -- highest inactive bg
    (0x88,0x66,0xAA) -- active bg
    (0xBB,0xBB,0xBB) -- inactive fg
    (0x00,0x00,0x00) -- active fg
myGSConfig colorizer  = (buildDefaultGSConfig myGridConfig)
    { gs_cellheight   = 65
    , gs_cellwidth    = 120
    , gs_cellpadding  = 10
    , gs_font         = sFont
    }
-- [/SETTINGS]}}}

colorBlack          = "#000000"
colorBlackAlt       = "#040404"
colorGray           = "#444444"
colorGrayAlt        = "#282828"
colorDarkGray       = "#161616"
colorWhite          = "#cfbfad"
colorWhiteAlt       = "#8c8b8e"
colorDarkWhite      = "#606060"
colorCream          = "#a9a6af"
colorDarkCream      = "#5f656b"
colorMagenta        = "#a488d9"
colorMagentaAlt     = "#7965ac"
colorDarkMagenta    = "#8e82a2"
colorBlue           = "#98a7b6"
colorBlueAlt        = "#598691"
colorDarkBlue       = "#464a4a"
colorNormalBorder   = colorDarkWhite
colorFocusedBorder  = colorMagenta

-- [SCRATCHPADS] {{{
-- Very handy hotkey-launched floating terminal window.
-- Pressing it will spawn the terminal, or bring it to the
-- current workspace if it already exists.
myScratchpads =
              [ NS "terminal" "urxvtc -name terminal -e tmux attach"     (resource =? "terminal") myPosition
              , NS "music" "urxvtc -name music -e tmux -c ncmpcpp"       (resource =? "music")    myPosition
              , NS "rtorrent" "urxvtc -name rtorrent -e rtorrent"        (resource =? "rtorrent") myPosition
              , NS "ide" "emacs"          			         (resource =? "ide")      myPosition
              ] where myPosition = customFloating $ W.RationalRect (1/3) (1/3) (1/3) (1/3)


-- [KeyBindings] {{{
myKeys =  -- The Workspace switcher.
    {- Keybindings methodologies:
     - Meta -> Only for for first action
     - Shift -> Secondaries
     - Alt -> Special -}
    -- Xmonad
        [ ("M-C-r",             spawn "xmonad --recompile") -- Recompile source code
        , ("M-M1-r",            spawn "xmonad --restart") -- Restart fresh binary
        , ("M-S-Esc",           io exitSuccess) -- Exit XMonad

    -- Windows
        -- Core
        , ("M-*",               refresh) -- Refresh layout
        , ("M-q",               kill1) -- Kill current props
        , ("M-C-q",             killAll) -- Full cleanup. Kill all props on the layout.
        -- Utils
        , ("M-<Delete>",        withFocused $ windows . W.sink) -- Rotate windows
        , ("M-S-<Delete>",      sinkAll) -- Toggle border selection
        -- Windows selection (ALT - M1 based)
        , ("M1-z",              windows W.focusMaster) -- Select master
        , ("M1-<F9>",           windows W.focusDown) -- Select using mouse hovering
        , ("M1-<Tab>",          windows W.focusDown) -- Select using simple term selection switcher.
        , ("M1-a",              windows W.swapDown) -- It say: swap down
        , ("M1-e",              windows W.swapUp) -- Same for up, no ?
        , ("M1-S-<Tab>",        rotSlavesDown) -- Select using rotation tree 1
        , ("M1-C-<Tab>",        rotAllDown) -- Select using rotation tree O
        , ("M1-<Backspace>",    promote) --  Promote to replace master layout (terminal)
        -- Maximisation
        , ("M-$",               withFocused minimizeWindow) -- Minimize windows to trails
        , ("M-S-$",             sendMessage RestoreNextMinimizedWin) -- Restore last minimized windows
        -- Windows manipulation ( Shift to increase, Control to decrease and None to move)
        , ("M-<Up>",            sendMessage (MoveUp 10)) -- Simple move to upper
        , ("M-<Down>",          sendMessage (MoveDown 10)) -- Simple move to down
        , ("M-<Right>",         sendMessage (MoveRight 10)) -- Simple move to right
        , ("M-<Left>",          sendMessage (MoveLeft 10)) -- Simple Move to left
        , ("M-S-<Up>",          sendMessage (IncreaseUp 10)) -- Increase size to up
        , ("M-S-<Down>",        sendMessage (IncreaseDown 10)) -- Increase size to down
        , ("M-S-<Right>",       sendMessage (IncreaseRight 10)) -- Increase size to right
        , ("M-S-<Left>",        sendMessage (IncreaseLeft 10)) -- Increase size to left
        , ("M-C-<Up>",          sendMessage (DecreaseUp 10)) -- Descrease size to up
        , ("M-C-<Down>",        sendMessage (DecreaseDown 10)) -- Descrease size to down
        , ("M-C-<Right>",       sendMessage (DecreaseRight 10)) -- Decrease size to right
        , ("M-C-<Left>",        sendMessage (DecreaseLeft 10)) -- Descrease size to left
    -- Layouts
        , ("M-!",               asks (XMonad.layoutHook . config) >>= setLayout) -- Reset all layout modifications.
        , ("M-r",               sendMessage NextLayout) -- Rotate between different layouts.
        , ("M-S-f",             sendMessage (T.Toggle "float")) -- Toggle float layou mode
        , ("M-S-b",             sendMessage $ Toggle NOBORDERS) -- Toggle border display
        , ("M-f",             sendMessage (Toggle NBFULL) >> sendMessage ToggleStruts) -- Toogle FullScreen
    -- Shrinks
        , ("M-h",               sendMessage Shrink) -- Shrink size of current terminal to left
        , ("M-l",               sendMessage Expand) --  Expand size of current terminal to right
    -- Workspace
        , ("M-M1-<Tab>",        nextWS) -- Switch to next workspace
        , ("M-M1-*",            prevWS) -- Switch to last workspace
        , ("M-S-<KP_Add>",      shiftTo Next nonNSP >> moveTo Next nonNSP) -- Move and follow prop to next workspace
        , ("M-S-<KP_Subtract>", shiftTo Prev nonNSP >> moveTo Prev nonNSP) -- Move and follow prop to last workspace
    -- Prompts Popup
        --   , ("M-,",               goToSelected $ myGSConfig myGridConfig) -- Prompt the popup, and when selected go to the prop
        , ("M-S-,",             bringSelected $ myGSConfig myGridConfig) -- Prompt the popup, and when selected move prop to current workspace
    -- Scratchpads
        --, ("M-<Tab>",         namedScratchpadAction myScratchpads "terminal") -- Pop a terminal as scratchpads ^ useless
        , ("M-c",               namedScratchpadAction myScratchpads "ide") -- Start a terminal with emacs for dev
        , ("M-b",               namedScratchpadAction myScratchpads "rtorrent")
        , ("M-m",               namedScratchpadAction myScratchpads "music")
    -- Medias
        , ("M-S-n",             spawn "mpc next")
        , ("M-S-p",             spawn "mpc prev")
        , ("M-S-k",             spawn "mpc stop")
        , ("M-S-s",             spawn "mpc shuffle")
        , ("M-S-j",             spawn "mpc pause")
        , ("M-S-k",             spawn "mpv play")
    -- Apps
       , ("M-<Space>",          spawn " rofi -show run -config /home/iomonad/.config/rofi/rofi-config")
        , ("M-<Return>",        spawn "urxvtc -name urxvt") -- New terminal Instance
        , ("M-w",               spawn "firefox") -- Start firefox
        , ("M-p",               spawn "ck-launch-session dbus-launch pcmanfm")
        ] where nonNSP          = WSIs (return (\ws -> W.tag ws /= "NSP"))
                nonEmptyNonNSP  = WSIs (return (\ws -> isJust (W.stack ws) && W.tag ws /= "NSP"))
myMouseKeys = [ ((mod4Mask .|. shiftMask, button3), \w -> focus w >> Sqr.mouseResizeWindow w True) ] -- Custom extra keys.
-- [/KEYBINDINGS] }}}

-- [WORKSPACE] {{{

myWorkspaces :: [[Char]]
myWorkspaces = ["term", "web", "media", "pirate","pr0n"]

myManageHook :: ManageHook
myManageHook = placeHook ( smart(1,1)) <+> insertPosition End Newer <+> floatNextHook <+> namedScratchpadManageHook myScratchpads <+>
        (composeAll . concat $
        [ [ resource  =? r --> doF (W.view "term" . W.shift "term")   	| r <- myTermApps    ]
        , [ resource  =? r --> doF (W.view "web" . W.shift "web")   	| r <- myWebApps     ]
        , [ resource  =? r --> doF (W.view "media" . W.shift "media") 	| r <- myMediaApps   ]
        , [ resource  =? r --> doF (W.view "pirate" . W.shift "pirate") | r <- mySystApps    ]
        , [ resource  =? r --> doF (W.view "pr0n" . W.shift "pr0n")   	| r <- mySystApps    ]
        , [ resource  =? r --> doFloat                            	| r <- myFloatApps   ]
        , [ className =? c --> ask >>= doF . W.sink               	| c <- myUnfloatApps ]
        ]) <+> manageHook defaultConfig
        where
            myTermApps    = [""]
            myWebApps     = ["firefox", "firefox-bin", "chromium", "Firefox"]
            myMediaApps   = ["zathura","mplayer","mpv"]
            mySystApps    = []
            myFloatApps   = ["Dialog","lxappearance", "Xmessage"]
            myUnfloatApps = []

myLayoutHook = gaps [(U, sGap), (R, sGap), (L, sGap), (D, sGap)] $
                                         avoidStruts $
                                         spacing sSpace
                                         commonLayouts
     where commonLayouts = tiled ||| grid ||| oneBig ||| lined ||| space ||| monocle
           monocle = limitWindows 20 Full -- Fullpaged
           tiled   = Tall nmaster delta ratio
           oneBig  = limitWindows 6  $ Mirror $ mkToggle (single MIRROR) $
                            mkToggle (single REFLECTX) $ mkToggle (single REFLECTY) $
                                  OneBig (2/3) (2/3) -- 2 on 3 ratio.
           space   = limitWindows 4  $ spacing 36 $ Mirror $
                            mkToggle (single MIRROR) $ mkToggle (single REFLECTX) $
                                    mkToggle (single REFLECTY) $ OneBig (2/3) (2/3) -- Adjust to big gap
           grid    = limitWindows 12 $ mkToggle (single MIRROR) $ Grid (16/10)
           lined   = limitWindows 3  $ Mirror $ mkToggle (single MIRROR) zoomRow
           nmaster = 1
           ratio   = 1/2
           delta   = 3/100

myStatusBar = "dzen2 -x '0' -y '0' -h '14' -w '260' -ta 'l' -bg '" ++ colorDarkGray ++ "' -fg '" ++ colorCream ++ "' -fn '" ++ sFont ++ "'"
myLogHook :: Handle -> X ()
myLogHook h = dynamicLogWithPP $ defaultPP
    {
        ppCurrent           =   dzenColor colorBlueAlt    colorDarkGray . hideScratchpad
      , ppVisible           =   dzenColor colorCream      colorDarkGray . hideScratchpad
      , ppHidden            =   dzenColor colorDarkCream  colorDarkGray . hideScratchpad
      , ppHiddenNoWindows   =   dzenColor colorGray       colorDarkGray . hideScratchpad
      , ppUrgent            =   dzenColor colorMagenta    colorDarkGray . pad
      , ppWsSep             =   ""
      , ppSep               =   " | "
      , ppLayout            =   dzenColor colorMagentaAlt colorDarkGray .
                                (\x -> case x of
                                    "Full" -> "*"
                                    "ReflectX *" -> "*"
                                    "ReflectX -" -> "-"
                                    "ReflectX =" -> "="
                                    "ReflectX +" -> "+"
                                    "ReflectX %" -> "%"
                                    "ReflectX @" -> "@"
                                    "ReflectX #" -> "#"
                                    "ReflectY *" -> "*"
                                    "ReflectY -" -> "-"
                                    "ReflectY =" -> "="
                                    "ReflectY +" -> "+"
                                    "ReflectY %" -> "%"
                                    "ReflectY @" -> "@"
                                    "ReflectY #" -> "#"
                                    "ReflectX ReflectY *" -> "*"
                                    "ReflectX ReflectY -" -> "-"
                                    "ReflectX ReflectY =" -> "="
                                    "ReflectX ReflectY +" -> "+"
                                    "ReflectX ReflectY %" -> "%"
                                    "ReflectX ReflectY @" -> "@"
                                    "ReflectX ReflectY #" -> "#"
                                    "Minimize *" -> "*"
                                    "Minimize -" -> "-"
                                    "Minimize =" -> "="
                                    "Minimize +" -> "+"
                                    "Minimize %" -> "%"
                                    "Minimize @" -> "@"
                                    "Minimize #" -> "#"
                                    _      -> x
                                )
      , ppTitle             =   (" " ++) . dzenColor colorWhiteAlt colorDarkGray . dzenEscape
      , ppOutput            =   hPutStrLn h
    }
    where
      hideScratchpad ws = if ws == "NSP" then "" else pad ws -- hide sp in ws list (thanks to p.brisbin)

myStartupHook :: X ()
myStartupHook = do
	ewmhDesktopsStartup >> setWMName "LG3D"

main :: IO ()
main = do
   dzenStatusBar <- spawnPipe myStatusBar
   xmonad $ withUrgencyHook dzenUrgencyHook { args = ["-fn", barFont, "-bg", colorDarkCream, "-fg", colorBlue]} $ defaultConfig
       { modMask            = myModMask
       , terminal           = myTerminal
       , manageHook         = myManageHook
       , layoutHook         = myLayoutHook
       , startupHook        = myStartupHook
       , workspaces         = myWorkspaces
       , borderWidth        = sBordW
       , logHook 	    = myLogHook dzenStatusBar >> setWMName "LG3D"
       , normalBorderColor  = sColorsB
       , focusedBorderColor = sColorsW
       } `additionalKeysP`         myKeys
         `additionalMouseBindings` myMouseKeys

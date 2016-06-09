// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************
//
//		File:		main.agc
//		Purpose:	Main Program
//		Date:		5th July 2016
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************

#include "src/constants.agc"																		// Constant items
#include "src/resources.agc"																		// Resource loader									
#include "src/chorddisplay.agc"																		// Chord Display Object
#include "src/song.agc" 																			// Song manager
#include "src/chordbucket.agc"																		// Chord bucket object
#include "src/barrender.agc" 																		// Bar Renderer
#include "src/renderManager.agc"																	// Render Manager
#include "src/fretboard.agc" 																		// Fretboard
#include "src/metronome.agc" 																		// Metronome
#include "src/player.agc" 																			// Sound player object
#include "src/chordhelper.agc" 																		// Chord Helper
#include "src/positioner.agc" 																		// Positioner
#include "src/tempometer.agc" 																		// Tempo meter/controller

InitialiseConstants()																				// Set up constants etc.
LoadResources()																						// Load in resources

SetWindowTitle("MusicTrainer")																		// Set up the display
SetWindowSize(ctrl.scWidth,ctrl.scHeight,0)
SetVirtualResolution(ctrl.scWidth,ctrl.scHeight)
SetOrientationAllowed(0,0,1,1)																		// Landscape only
CreateSprite(IDBACKGROUND,IDBACKGROUND)																// Create the background
SetSpriteSize(IDBACKGROUND,ctrl.scWidth,ctrl.scHeight)												
SetSpriteDepth(IDBACKGROUND,DEPTHBACKGROUND)

sng as Song
rMgr as RenderManager
frBrd as FretBoard
mtNm as Metronome
plyr as Player
cHelp as ChordHelper
posn as Positioner
tmtr as TempoMeter

a$ = "music/When I'm Cleaning Windows.music"

//a$ = "music/Dont Worry Be Happy.music"
//a$ = "music/Ukulele Buddy/20 Hokey Pokey WarMgr Up.music"

Song_New(sng)
Song_Load(sng,a$)
SBarRender_ProcessSongLyrics(sng)

for i = 1 to sng.barCount
		for j = 1 to sng.bars[i].strumCount
			sng.bars[i].strums[j].displayChord = 1
		next j
next i

type ClickInfo
	x,y as integer
	key$ as string
endtype

Player_New(plyr,"20,13,17,22",10,0,64,80,IDB_PLAYER)
Player_Move(plyr,ctrl.scWidth-32-4,ctrl.scHeight-32-4)

ChordHelper_New(cHelp,sng,110,220,95,IDB_CHORDHELPER)
ChordHelper_Move(cHelp,340,16)

Positioner_New(posn,sng,888,50,50,IDB_POSITIONER)
Positioner_Move(posn,32,730)

RenderManager_New(rMgr, 824,350, 60,32, 70, 400,8,IDB_RMANAGER)
RenderManager_Move(rMgr,sng,190,350)

Fretboard_New(frBrd,350,80,sng.strings,IDB_FRETBRD)
Fretboard_Move(frBrd,350)

Metronome_New(mtNm,190,60,IDB_METRONOME)
Metronome_Move(mtNm,780,180)

TempoMeter_New(tmtr,230,80,IDB_METER)
TempoMeter_Move(tmtr,120,105)

CreateSprite(IDB_AGK,IDTGF)
SetSpritePosition(IDB_AGK,ctrl.scWidth-128-16,105)
SetSpriteDepth(IDB_AGK,98)

CreateSprite(IDB_EXIT,IDEXIT)
SetSpriteSize(IDB_EXIT,64,64)
SetSpritePosition(IDB_EXIT,ctrl.scWidth-GetSpriteWidth(IDB_EXIT)-4,4)
SetPrintSize(16)

pos# = 0.0
endPlay = 0
while endPlay = 0
    Print(ScreenFPS())
    Print(pos#)
    if GetRawKeyPressed(27) <> 0 then endPlay = 1

	for i = 1 to len(CMDKEYS)
		if GetRawKeyPressed(asc(mid(CMDKEYS,i,1))) <> 0
			ci.x = -1000
			ci.y = -1000
			ci.key$ = mid(CMDKEYS,i,1)
			Metronome_ClickHandler(mtNm,ci)
			Position_ClickHandler(posn,rMgr,sng,ci)
			Player_ClickHandler(plyr,ci)
			TempoMeter_ClickHandler(tmtr,ci)
		endif
	next i
	
    if GetPointerPressed() 
		ci as ClickInfo
		ci.x = GetPointerX()
		ci.y = GetPointerY()
		Metronome_ClickHandler(mtNm,ci)
		Position_ClickHandler(posn,rMgr,sng,ci)
		Player_ClickHandler(plyr,ci)
		TempoMeter_ClickHandler(tmtr,ci)
		if GetSpriteHitTest(IDB_EXIT,ci.x,ci.y) <> 0 
			endPlay = 1
			PlaySound(ISPING)
		endif
    endif
    
    if GetRawKeyPressed(asc("X")) <> 0
		endPlay = 1
		PlaySound(ISPING)
	endif
	
	for i = 1 to CountStringTokens(debug,";")
		print(GetStringToken(debug,";",i))
	next i
		
	RenderManager_MoveScroll(rMgr,sng,pos#)
	Player_Update(plyr,sng,pos#)
	Metronome_Update(mtNm,pos#,sng.beats)
	ChordHelper_Update(cHelp,sng,pos#)
	pos# = pos# + TempoMeter_ScalePositionAdjustment(tmtr,0.01)
	pos# = Positioner_Update(posn,pos#)
    Sync()
endwhile

RenderManager_Delete(rMgr)
Fretboard_Delete(frBrd)
Metronome_Delete(mtNm)
ChordHelper_Delete(cHelp)
Positioner_Delete(posn)
Player_Delete(plyr)
TempoMeter_Delete(tmtr)

DeleteSprite(IDB_AGK)
DeleteSprite(IDB_EXIT)

while GetRawKeyState(27) <> 0
	Sync()
endwhile

//	TODO: Main object

//	X exit
//	M metronome
//	Q quiet

//	FSRP Fast/Slow/Reset tempo Pause

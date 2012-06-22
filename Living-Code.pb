;-*****Important**************************
;-*Windows: Create threadsafe executable.*
;-*Linux: Don´t use this option.         *
;-****************************************
; Version: 1.5
;
;Author:
;-------
;  (c) 2008 RocketRider
;  http://www.RocketRider.eu
;  http://Living-Code.RRSoftware.de
;
;
;Important:
;----------
;  You use the software at your own risk.
;  The software has been tested much,
;  however, errors can Not be excluded.
;  The author is Not liable For any damages
;  of hardware, software Or other.
;  This software may be freely copied And presented.
;
;
;Licence:
;--------
;  The licence of this project is Zlib.
;
;
;Description:
;------------
;  Living code is a life simulation,
;  where you can even make your own creatures, Or simply watch the evolution.
; 
;  It is possible To control the evolution of your creatures:
;  In Living code you have the opportunity To play With the creautres like you want.
;  You can give them food, infect them With viruses, change the DNA, change the look, Or just delete them.
; 
;  Your changes will affect the evolution of the creatures.
;  The fate of your creatures lies in your hands.
;
;  It was primarly build for the PureBasic-Lounge Sommer-Contest 2008 (http://purebasic-lounge.com/viewtopic.php?t=5423)
;  The program gets the first place.
;  Thanks for your voting.


CompilerIf #PB_Compiler_OS = #PB_OS_Linux
  #Use3DView = #False
CompilerElse
  #Use3DView = #True ;S3DR, If you have no S3DR Lib, so you must disable that.
  ;#Use3DView = #False
CompilerEndIf
#View3D_Scale = 100
#Use_Linux_OpenGL = #False


Global exePath.s

CompilerIf #PB_Compiler_OS = #PB_OS_Linux
  CompilerIf #Use_Linux_OpenGL=#False
  #DrawCreature_Sprite=#False
  CompilerElse
  #DrawCreature_Sprite=#True
  CompilerEndIf
  
  #TrackBar_TOOLTIPS=0;256
  CompilerIf #PB_editor_createexecutable
    Global Datapath.s = GetPathPart(ProgramFilename())+"Data/"
    exePath=GetPathPart(ProgramFilename())
    SetCurrentDirectory(exePath)
  CompilerElse
    Global Datapath.s = "Data/"
  CompilerEndIf
  
  IncludeFile "Data/generator.pbi"
  IncludeFile "Data/zpac.pbi"
  IncludeFile "Data/Pref.pbi"
CompilerElse
  #DrawCreature_Sprite=#True
  #TrackBar_TOOLTIPS=256
  CompilerIf #PB_editor_createexecutable
    Global Datapath.s = GetPathPart(ProgramFilename())+"Data\"
    exePath=GetPathPart(ProgramFilename())
    SetCurrentDirectory(exePath)
  CompilerElse
    Global Datapath.s = "Data\"
  CompilerEndIf
  
  IncludeFile "Data\generator.pbi"
  IncludeFile "Data\ZPAC.pbi"
  IncludeFile "Data\Pref.pbi"
CompilerEndIf


Global languagefile.s
Global WORKER_COUNT.l ;= 8
Global WORKER_COUNT_TEMP
Global UseMultiCore.l
ReadFile(1,Datapath+"Options.txt")
UseMultiCore = Val(ReadString(1))
WORKER_COUNT = Val(ReadString(1))
languagefile.s = ReadString(1)
CloseFile(1)
If WORKER_COUNT<1:WORKER_COUNT=1:EndIf
WORKER_COUNT_TEMP = WORKER_COUNT

;languagefile.s = "Data/english.txt"
OpenPreferences_(languagefile)



Structure EXEC_CREATURE_WORKER
  Mutex.l
  Done.l
  StartIndex.l
  EndIndex.l
  Thread.l
EndStructure

Global Dim Workers.EXEC_CREATURE_WORKER(WORKER_COUNT - 1)
Global GlobalSound.l = #True
Global GlobalSoundOn.l = #True 







Declare CreateCreature_Window(CellCount.l)
Declare CloseCreateCreature()
Declare _PlaySound(Sound.l)
Declare Events_Splashscreen()
Declare DisableToolBar(state)
Declare SetCodeProbability(code,Probability)
Declare.s GetCreatureAuthor_FromFile(File.s)
Declare HighlightAll(Numcells)
Enumeration
  #CMD_MOVE_FORWARD
  #CMD_MOVE_BACKWARD
  
  #CMD_EATING_YES
  #CMD_EATING_NO
  #CMD_EATING_EMIT
  
  #CMD_POISON_EMIT
  #CMD_POISON_IMMUN1
  #CMD_POISON_IMMUN2
  #CMD_POISON_IMMUN3
  #CMD_POISON_YES
  #CMD_POISON_NO
  #CMD_POISON_VIRUS_MIN_ENERGY
  #CMD_POISON_EMIT_VIRUS
  #CMD_POISON_DNA_CODE  ; Code für CMD_POISON_EMIT_DNA, Parameter: Befehl z.B 1 für MOVE_BACKWARD
  #CMD_POISON_EMIT_DNA  ; DNA Ausgeben, Parameter: Position im Code
  
  #CMD_POISON_EMIT_DNABLOCK   
  #CMD_POISON_DNABLOCK_SIZE  
  
  #CMD_MSG_EMIT
  
  #CMD_ROTATE_LEFT
  #CMD_ROTATE_RIGHT
  
  #CMD_ROTATE_MSG
  #CMD_ROTATE_DNA
  #CMD_ROTATE_POISON
  #CMD_ROTATE_FOOD
  
  #CMD_ROTATE_ANTI_MSG
  #CMD_ROTATE_ANTI_DNA
  #CMD_ROTATE_ANTI_POISON
  #CMD_ROTATE_ANTI_FOOD
  
  #CMD_IF_ENERGY_GREATER
  #CMD_IF_ENERGY_LESS
  #CMD_IF_ENERGY_EQUAL
  
  #CMD_IF_ENERGYINC_GREATER
  #CMD_IF_ENERGYDEC_GREATER
  
  #CMD_IF_MSG_GREATER
  #CMD_IF_MSG_LESS
  #CMD_IF_MSG_EQUAL
  
  #CMD_IF_FOOD_GREATER
  #CMD_IF_FOOD_LESS
  #CMD_IF_FOOD_EQUAL
  
  
  #CMD_IF_POISON_GREATER
  #CMD_IF_POISON_LESS
  #CMD_IF_POISON_EQUAL
  
  #CMD_IF_POISONID_GREATER
  #CMD_IF_POISONID_LESS
  #CMD_IF_POISONID_EQUAL
  
  #CMD_IF_DNA_GREATER
  #CMD_IF_DNA_LESS
  #CMD_IF_DNA_EQUAL
  
  #CMD_IF_VARIABLE_GREATER
  #CMD_IF_VARIABLE_LESS
  #CMD_IF_VARIABLE_EQUAL
  
  #CMD_IF_CELL_RAD_GREATER
  #CMD_IF_CELL_RAD_LESS
  #CMD_IF_CELL_RAD_EQUAL
  
  #CMD_ENDIF
  #CMD_CLONE
  #CMD_COPY_MIN_ENERGY
  #CMD_COPY50_50 ; Verteilung
  #CMD_COPY25_75
  #CMD_COPY5_95
  #CMD_RETURN
  #CMD_GOTO
  #CMD_GOTO50 ; Wahrscheinlichkeit
  #CMD_GOTO25
  #CMD_GOTO5
  
  #CMD_RNDGOTO
  #CMD_VARIABLE
  #CMD_VARIABLE_ZERO
  #CMD_VARIABLE_DEC
  #CMD_VARIABLE_INC
  #CMD_VARIABLE_SET
  
  #CMD_INC_CELL_RAD
  #CMD_DEC_CELL_RAD
  
  #CMD_SIN_CELL_RAD
  #CMD_SIN_CELL_AMPRAD
  #CMD_SIN_CELL_MIDRAD
  
  
  #CMD_VARIABLE_ADD
  #CMD_VARIABLE_SUB
  #CMD_VARIABLE_MUL
  #CMD_VARIABLE_DIV
  #CMD_VARIABLE_XOR
  #CMD_VARIABLE_OR
  #CMD_VARIABLE_AND
  #CMD_VARIABLE_MOD
  
  #CMD_TIMER_SET
  #CMD_TIMER_GOTO
  #CMD_TIMER_YES
  #CMD_TIMER_NO 
  
  
  #CMD_IF_X_GREATER
  #CMD_IF_X_LESS
  #CMD_IF_X_EQUAL
  
  #CMD_IF_Y_GREATER
  #CMD_IF_Y_LESS
  #CMD_IF_Y_EQUAL  
  
  #CMD_IF_ENEMYABS_GREATER
  #CMD_IF_ENEMYABS_LESS
  #CMD_IF_ENEMYABS_EQUAL    
  
  #CMD_ROTATE_ENEMY
  #CMD_ROTATE_ANTI_ENEMY  
  
  #CMD_SEARCH_NEAREST_ENEMY
  
  
  #CMD_IF_CMP_ENEMY_GREATER
  #CMD_IF_CMP_ENEMY_LESS
  #CMD_IF_CMP_ENEMY_EQUAL
  
  #CMD_DEST_POINT_X
  #CMD_DEST_POINT_Y
  #CMD_ROTATE_DEST_POINT
  #CMD_ROTATE_ANTI_DEST_POINT
  
  #CMD_VARIABLE_COPY
  
  #CMD_PAUSE
  #CMD_ANTIVIRUS
  
  #CMD_PROTECTVIRUS
  #CMD_COMBINECOPY
  
  #CMD_IF_GENERATION_GREATER
  #CMD_IF_GENERATION_LESS
  #CMD_IF_GENERATION_EQUAL
  
  #CMD_IF_NUMOFCELLS_GREATER
  #CMD_IF_NUMOFCELLS_LESS
  #CMD_IF_NUMOFCELLS_EQUAL
  
  #CMD_IF_CELLNUMER_GREATER
  #CMD_IF_CELLNUMER_LESS
  #CMD_IF_CELLNUMER_EQUAL  
  
  #CMD_IF_MALE
  #CMD_IF_FEMALE
  
  #CMD_IF_AGE_GREATER
  #CMD_IF_AGE_LESS
  #CMD_IF_AGE_EQUAL    
  
  #CMD_VARIABLE_RND
  
  #CMD_MOVE_FORWARD2X
  
  #CMD_MUTATE
  
  #CMD_MUTATE_LINE
  #CMD_BLOCKEXEC
  #CMD_EMITTOENEMY_FOOD
  #CMD_EMITTOENEMY_MSG

  #CMD_REPLACEMENT_CMD
  #CMD_REPLACE_CMD 
  #CMD_VARIABLE_GETGLOBAL
  #CMD_VARIABLE_SETGLOBAL  

  
  #CMD_ABSORBABLE_YES
  #CMD_ABSORBABLE_NO
  #CMD_ABSORB_ENEMY
  #CMD_IF_ABSORBABLE
 
  #CMD_EMITTOENEMY_POISON
  #CMD_EMITTOENEMY_DNA  
  #CMD_EMITTOENEMY_DNABLOCK 
  
  #CMD_PROTECTDNA
  
  #CMD_NOP
EndEnumeration




Enumeration
  #OBJECT_FOOD
  #OBJECT_VIRUS
  #OBJECT_DNA
  #OBJECT_POISON
  #OBJECT_MSG
  #OBJECT_REST
EndEnumeration


Enumeration
  #Window_Main
  #Window_CreateCreature
  #Window_About
  #Window_Options
  #Window_Screen
  #Window_Splashscreen
  #Window_CC_Move
  #Window_CC_Rotate
  #Window_CC_IF
  #Window_CC_Attack
  #Window_CC_Clone
  #Window_Upload
  #Window_ManualDownload
  #Window_UploadPerWebGadGet
  #Window_InsertCreates
  #Window_Creature_Generator
  #Window_Report
EndEnumeration


#DEBUG_EXEC = #False

#AREA_WIDTH = 640
#AREA_HEIGHT = 480

#CODE_SIZE = 512
#MAX_DNAMAXBLOCKSIZE = 5

#MAX_CELLS = 32
#COMPRESS_LEVEL= 9

#VERSION = "1.5"



Structure GlobalVar
  OBJECT_FOOD_DEFAULT_SIZE.l
  OBJECT_FOOD_MAXSPEED.f
  OBJECT_CATCH_RADIUS_FACTOR.f
  OBJECT_CATCH_PROPABILITY.l ;  (0-100%)
  OBJECT_POISON_ENERGY_DECREASE.l
  OBJECT_POISON_ENERGY_ENEMY_DECREASE .l 
  OBJECT_POISON_MAXSPEED.f
  OBJECT_POISON_LIFETIME.l
  OBJECT_POISON_PARALYSE_PAUSE.l ; NEU 17.08.2008
  
  OBJECT_VIRUS_ENERGY_DECREASE.l 
  OBJECT_VIRUS_MAXSPEED.f
  OBJECT_VIRUS_LIFETIME.l 
  OBJECT_VIRUS_PROPABILITY.l 
  OBJECT_DNA_ENERGY_DECREASE.l 
  OBJECT_DNA_MAXSPEED.f
  OBJECT_DNA_LIFETIME.l 
  
  OBJECT_DNA_BLOCK_ENERGY_DECREASE.l ;NEU 11.08.08
  
  OBJECT_MSG_ENERGY_DECREASE.l 
  OBJECT_MSG_MAXSPEED.f
  OBJECT_MSG_LIFETIME.l 
  OBJECT_REST_MAXLIFETIME.l 
  CREATURE_MOVESPEED.f
  CREATURE_ROTATIONSPEED.f
  CREATURE_GROWTH.f ; NEU, Wachtumsfaktor
  CREATURE_MAXRADIUS.l
  CREATURE_MINRADIUS.l 
  CREATURE_MOVE_ENERGY_DECREASE.l 
  CREATURE_ROTATION_ENERGY_DECREASE.l
  CREATURE_CLONE_ENERGY_DECREASE.l 
  
  CREATURE_COMBINECOPY_MINABS.l  ; NEU 19.08.2008
  
  CREATURE_SEARCH_ENEMY_ENERGY_DECREASE.l ; NEU 13.08.2008
  
  CREATURE_RANDOMMOVE.f
  CREATURE_RANDOMROTATION.f
  CREATURE_ROUNDENERGYFACTOR1.f
  CREATURE_ROUNDENERGYFACTOR2.f
  CREATURE_PROBABLE_CLONE_CHANGECELLNUMBER .l  ;(0-100%)
  CREATURE_PROBABLE_CLONE_COPYDNA .l  ; (0-100%)
  CREATURE_PROBABLE_CLONE_CHANGESIZE.l  ;(0-100%)
  CREATURE_PROBABLE_CLONE_MIN_CLONE_COUNT.l ; Muss größer als 32 sein!
  
  CREATURE_ANTIVIRUS_ENERGY_DECREASE.l ; NEU 17.08.2008
  CREATURE_PROTECTVIRUS_COUNT.l ; NEU 19.08.2008
  CREATURE_CELLBONUS.f ; NEU 19.08.08 
  
  CREATURE_METABOLISM_RATE.l ; 1000
  
  
  MUTATION_PROBABILITY.l ; (0-100%)
  MUTATION_PROBABILITY_CHAOS.l ; (0-100%)
  MUTATION_PROBABILITY_RADIUS.l  ;(0-100%)
  MUTATION_RADIUS_CHANGE.l   
  
  Object_Trans.l
  MinimalCreatures.l
  ExecuteCount.l
  Reducecpuusage.l
  StartTimer.l
  
  CREATURE_REPLACE_ENERGY_DECREASE.l ; NEU 28.09.2008  
  
  GlobalVarType.l
  
  CREATURE_PROTECT_DNA_ENERGY_DECREASE.l ; NEU 29.11.2008
  CREATURE_PROTECT_DNA_COUNT.l ; NEU 10.12.2008

  Reserved.l[97]
EndStructure
Global GlobalVar.GlobalVar

Global GlobalVarChanged = #False
Global GlobalVarMode.s = ""
Procedure SetGlobalVar_GamingMode()
  GlobalVarChanged = #False
  GlobalVarMode = ReadPreferenceString_(languagefile, "text", "gaming-mode")
  If IsWindow(#Window_Main)
  SetWindowTitle(#Window_Main,"Living Code V" + #VERSION + "  - " + GlobalVarMode)
  EndIf
  GlobalVar\GlobalVarType = 0
  
  
  GlobalVar\OBJECT_FOOD_DEFAULT_SIZE = 600
  GlobalVar\OBJECT_FOOD_MAXSPEED = 0.07
  
  GlobalVar\OBJECT_CATCH_RADIUS_FACTOR = 0.5
  GlobalVar\OBJECT_CATCH_PROPABILITY = 15 ;  (0-100%)
  
  GlobalVar\OBJECT_POISON_ENERGY_DECREASE = 3
  GlobalVar\OBJECT_POISON_ENERGY_ENEMY_DECREASE  = 40;20 Viel zu wenig
  GlobalVar\OBJECT_POISON_MAXSPEED = 0.2
  GlobalVar\OBJECT_POISON_LIFETIME = 1300
  GlobalVar\OBJECT_POISON_PARALYSE_PAUSE = 75 ; NEU 
  
  GlobalVar\OBJECT_VIRUS_ENERGY_DECREASE = 25
  GlobalVar\OBJECT_VIRUS_MAXSPEED = 0.2
  GlobalVar\OBJECT_VIRUS_LIFETIME = 750
  GlobalVar\OBJECT_VIRUS_PROPABILITY = 50 
  
  GlobalVar\OBJECT_DNA_ENERGY_DECREASE = 5
  GlobalVar\OBJECT_DNA_MAXSPEED = 0.2
  GlobalVar\OBJECT_DNA_LIFETIME = 700
  
  GlobalVar\OBJECT_DNA_BLOCK_ENERGY_DECREASE = 8
  
  GlobalVar\OBJECT_MSG_ENERGY_DECREASE = 1
  GlobalVar\OBJECT_MSG_MAXSPEED = 0.2
  GlobalVar\OBJECT_MSG_LIFETIME = 1800
  
  GlobalVar\OBJECT_REST_MAXLIFETIME = 1200
  
  GlobalVar\CREATURE_MOVESPEED = 0.15
  GlobalVar\CREATURE_ROTATIONSPEED = 1.0/360.0 * 2 * #PI
  GlobalVar\CREATURE_GROWTH.f = 0.002 
  
  GlobalVar\CREATURE_MAXRADIUS = 50
  GlobalVar\CREATURE_MINRADIUS = 1 
  
  GlobalVar\CREATURE_MOVE_ENERGY_DECREASE = 1
  GlobalVar\CREATURE_ROTATION_ENERGY_DECREASE = 1
  
  GlobalVar\CREATURE_CLONE_ENERGY_DECREASE = 100
  
  GlobalVar\CREATURE_COMBINECOPY_MINABS.l = 65
  
  GlobalVar\CREATURE_SEARCH_ENEMY_ENERGY_DECREASE = 5
  
  GlobalVar\CREATURE_RANDOMMOVE = 0.08
  GlobalVar\CREATURE_RANDOMROTATION = 0.02
  
  GlobalVar\CREATURE_ROUNDENERGYFACTOR1 = 0.9
  GlobalVar\CREATURE_ROUNDENERGYFACTOR2 = 0.005
  
  GlobalVar\CREATURE_PROBABLE_CLONE_CHANGECELLNUMBER  = 5 ;(0-100%)
  GlobalVar\CREATURE_PROBABLE_CLONE_COPYDNA  = 5 ; (0-100%)
  GlobalVar\CREATURE_PROBABLE_CLONE_CHANGESIZE = 8 ;(0-100%)
  GlobalVar\CREATURE_PROBABLE_CLONE_MIN_CLONE_COUNT = 200 ; Muss größer als 32 sein!
  
  GlobalVar\CREATURE_ANTIVIRUS_ENERGY_DECREASE = 5
  GlobalVar\CREATURE_PROTECTVIRUS_COUNT = 5
  
  GlobalVar\CREATURE_CELLBONUS = 0.95
  
  GlobalVar\MUTATION_PROBABILITY = 10 ; (0-10000)
  GlobalVar\MUTATION_PROBABILITY_CHAOS = 3;5 ; (0-100%)
  
  GlobalVar\MUTATION_PROBABILITY_RADIUS = 2 ;(0-100%)
  GlobalVar\MUTATION_RADIUS_CHANGE = 2 
  
  GlobalVar\CREATURE_METABOLISM_RATE = 4000
  
  GlobalVar\Object_Trans = 200
  GlobalVar\MinimalCreatures = 1
  GlobalVar\ExecuteCount=5
  GlobalVar\Reducecpuusage=0
  
  GlobalVar\CREATURE_REPLACE_ENERGY_DECREASE = 10
  
  GlobalVar\CREATURE_PROTECT_DNA_ENERGY_DECREASE = 15
  
  GlobalVar\CREATURE_PROTECT_DNA_COUNT = 2
  
  SetCodeProbability(#CMD_MOVE_FORWARD, 580)
  
  SetCodeProbability(#CMD_MOVE_BACKWARD, 80)
  
  SetCodeProbability(#CMD_EATING_YES, 35)
  SetCodeProbability(#CMD_EATING_NO, 5)
  SetCodeProbability(#CMD_EATING_EMIT, 5)
  
  SetCodeProbability(#CMD_POISON_EMIT, 25)
  SetCodeProbability(#CMD_POISON_IMMUN1, 25)
  SetCodeProbability(#CMD_POISON_IMMUN2, 25)
  SetCodeProbability(#CMD_POISON_IMMUN3, 25)
  SetCodeProbability(#CMD_POISON_YES, 25)
  SetCodeProbability(#CMD_POISON_NO,  25)
  SetCodeProbability(#CMD_POISON_VIRUS_MIN_ENERGY, 15)
  SetCodeProbability(#CMD_POISON_EMIT_VIRUS, 5)
  SetCodeProbability(#CMD_POISON_DNA_CODE, 25)
  SetCodeProbability(#CMD_POISON_EMIT_DNA, 20)
  
  SetCodeProbability(#CMD_POISON_EMIT_DNABLOCK, 25)
  SetCodeProbability(#CMD_POISON_DNABLOCK_SIZE, 20)
  
  SetCodeProbability(#CMD_MSG_EMIT, 30)
  
  SetCodeProbability(#CMD_ROTATE_LEFT, 55)
  SetCodeProbability(#CMD_ROTATE_RIGHT, 55)
  
  SetCodeProbability(#CMD_ROTATE_MSG, 90)
  SetCodeProbability(#CMD_ROTATE_DNA, 50)
  SetCodeProbability(#CMD_ROTATE_POISON, 50)
  SetCodeProbability(#CMD_ROTATE_FOOD, 250)
  
  SetCodeProbability(#CMD_ROTATE_ANTI_MSG, 20)
  SetCodeProbability(#CMD_ROTATE_ANTI_DNA, 65)
  SetCodeProbability(#CMD_ROTATE_ANTI_POISON, 65)
  SetCodeProbability(#CMD_ROTATE_ANTI_FOOD, 10)
  
  SetCodeProbability(#CMD_IF_ENERGY_GREATER, 45)
  SetCodeProbability(#CMD_IF_ENERGY_LESS, 45)
  SetCodeProbability(#CMD_IF_ENERGY_EQUAL, 5)
  
  SetCodeProbability(#CMD_IF_ENERGYINC_GREATER, 15)
  SetCodeProbability(#CMD_IF_ENERGYDEC_GREATER, 15)
  
  SetCodeProbability(#CMD_IF_MSG_GREATER, 10)
  SetCodeProbability(#CMD_IF_MSG_LESS, 10)
  SetCodeProbability(#CMD_IF_MSG_EQUAL, 10)
  
  SetCodeProbability(#CMD_IF_FOOD_GREATER, 10)
  SetCodeProbability(#CMD_IF_FOOD_LESS, 10)
  SetCodeProbability(#CMD_IF_FOOD_EQUAL, 5)
  
  SetCodeProbability(#CMD_IF_POISON_GREATER, 10)
  SetCodeProbability(#CMD_IF_POISON_LESS, 10)
  SetCodeProbability(#CMD_IF_POISON_EQUAL, 5)
  
  SetCodeProbability(#CMD_IF_POISONID_GREATER, 10)
  SetCodeProbability(#CMD_IF_POISONID_LESS, 10)
  SetCodeProbability(#CMD_IF_POISONID_EQUAL, 5)
  
  SetCodeProbability(#CMD_IF_DNA_GREATER, 10)
  SetCodeProbability(#CMD_IF_DNA_LESS, 10)
  SetCodeProbability(#CMD_IF_DNA_EQUAL, 5)
  
  SetCodeProbability(#CMD_IF_VARIABLE_GREATER, 10)
  SetCodeProbability(#CMD_IF_VARIABLE_LESS, 10)
  SetCodeProbability(#CMD_IF_VARIABLE_EQUAL, 5)
  
  SetCodeProbability(#CMD_IF_CELL_RAD_GREATER, 20)
  SetCodeProbability(#CMD_IF_CELL_RAD_LESS, 20)
  SetCodeProbability(#CMD_IF_CELL_RAD_EQUAL, 5)
  
  SetCodeProbability(#CMD_ENDIF, 580)
  SetCodeProbability(#CMD_CLONE, 65)
  SetCodeProbability(#CMD_COPY_MIN_ENERGY, 80)
  SetCodeProbability(#CMD_COPY50_50, 25)
  SetCodeProbability(#CMD_COPY25_75, 15)
  SetCodeProbability(#CMD_COPY5_95, 5)
  SetCodeProbability(#CMD_RETURN, 30)
  SetCodeProbability(#CMD_GOTO, 205)
  SetCodeProbability(#CMD_GOTO50, 125)
  SetCodeProbability(#CMD_GOTO25, 75)
  SetCodeProbability(#CMD_GOTO5, 50)
  
  SetCodeProbability(#CMD_RNDGOTO, 70)
  SetCodeProbability(#CMD_VARIABLE, 200)
  SetCodeProbability(#CMD_VARIABLE_ZERO, 20)
  SetCodeProbability(#CMD_VARIABLE_DEC, 20)
  SetCodeProbability(#CMD_VARIABLE_INC, 20)
  SetCodeProbability(#CMD_VARIABLE_SET, 20)
  
  SetCodeProbability(#CMD_VARIABLE_ADD,15)
  SetCodeProbability(#CMD_VARIABLE_SUB,15)
  SetCodeProbability(#CMD_VARIABLE_MUL,15)
  SetCodeProbability(#CMD_VARIABLE_DIV,15)
  SetCodeProbability(#CMD_VARIABLE_XOR,15)
  SetCodeProbability(#CMD_VARIABLE_OR,15)
  SetCodeProbability(#CMD_VARIABLE_AND,15)
  SetCodeProbability(#CMD_VARIABLE_MOD,15)  
  
  SetCodeProbability(#CMD_INC_CELL_RAD, 10)
  SetCodeProbability(#CMD_DEC_CELL_RAD, 10)
  
  SetCodeProbability(#CMD_SIN_CELL_RAD, 10)
  SetCodeProbability(#CMD_SIN_CELL_AMPRAD, 10)
  SetCodeProbability(#CMD_SIN_CELL_MIDRAD, 10)
  
  SetCodeProbability(#CMD_TIMER_SET,110)
  SetCodeProbability(#CMD_TIMER_GOTO,110)
  SetCodeProbability(#CMD_TIMER_YES,5)
  SetCodeProbability(#CMD_TIMER_NO,5)
  
  SetCodeProbability(#CMD_IF_X_GREATER, 5)
  SetCodeProbability(#CMD_IF_X_LESS, 5)
  SetCodeProbability(#CMD_IF_X_EQUAL, 2)
  SetCodeProbability(#CMD_IF_Y_GREATER, 5)
  SetCodeProbability(#CMD_IF_Y_LESS, 5)
  SetCodeProbability(#CMD_IF_Y_EQUAL, 2)
  
  SetCodeProbability(#CMD_IF_ENEMYABS_GREATER, 55)
  SetCodeProbability(#CMD_IF_ENEMYABS_LESS, 55)
  SetCodeProbability(#CMD_IF_ENEMYABS_EQUAL, 5)
  SetCodeProbability(#CMD_ROTATE_ENEMY, 70)
  SetCodeProbability(#CMD_ROTATE_ANTI_ENEMY, 25)
  
  SetCodeProbability(#CMD_SEARCH_NEAREST_ENEMY, 35)
  
  SetCodeProbability(#CMD_IF_CMP_ENEMY_GREATER, 35)
  SetCodeProbability(#CMD_IF_CMP_ENEMY_LESS, 35)
  SetCodeProbability(#CMD_IF_CMP_ENEMY_EQUAL, 5)
  
  SetCodeProbability(#CMD_DEST_POINT_X, 5)
  SetCodeProbability(#CMD_DEST_POINT_Y, 5)
  SetCodeProbability(#CMD_ROTATE_DEST_POINT, 5)
  SetCodeProbability(#CMD_ROTATE_ANTI_DEST_POINT, 5)
  
  SetCodeProbability(#CMD_VARIABLE_COPY, 25)
  
  SetCodeProbability(#CMD_PAUSE, 10)
  SetCodeProbability(#CMD_ANTIVIRUS, 30)
  
  SetCodeProbability(#CMD_PROTECTVIRUS, 35)
  SetCodeProbability(#CMD_COMBINECOPY, 75)
  
  SetCodeProbability(#CMD_IF_GENERATION_GREATER,20)
  SetCodeProbability(#CMD_IF_GENERATION_LESS,20)
  SetCodeProbability(#CMD_IF_GENERATION_EQUAL,5)
  
  SetCodeProbability(#CMD_IF_NUMOFCELLS_GREATER,15)
  SetCodeProbability(#CMD_IF_NUMOFCELLS_LESS,15)
  SetCodeProbability(#CMD_IF_NUMOFCELLS_EQUAL,10)
  
  SetCodeProbability(#CMD_IF_CELLNUMER_GREATER,20)
  SetCodeProbability(#CMD_IF_CELLNUMER_LESS,20)
  SetCodeProbability(#CMD_IF_CELLNUMER_EQUAL,20)  
  
  SetCodeProbability(#CMD_IF_MALE,45)
  SetCodeProbability(#CMD_IF_FEMALE,45)
  
  SetCodeProbability(#CMD_IF_AGE_GREATER,20)
  SetCodeProbability(#CMD_IF_AGE_LESS,20)
  SetCodeProbability(#CMD_IF_AGE_EQUAL,5)    
  
  SetCodeProbability(#CMD_VARIABLE_RND,25)
  
  SetCodeProbability(#CMD_MOVE_FORWARD2X,120)
  
  SetCodeProbability(#CMD_MUTATE,25)
  
  SetCodeProbability(#CMD_MUTATE_LINE,40)  
  SetCodeProbability(#CMD_BLOCKEXEC,40)
  SetCodeProbability(#CMD_EMITTOENEMY_FOOD,10)    
  SetCodeProbability(#CMD_EMITTOENEMY_MSG,10)
  SetCodeProbability(#CMD_REPLACEMENT_CMD,10)
  SetCodeProbability(#CMD_REPLACE_CMD,5)  
  
  SetCodeProbability(#CMD_VARIABLE_GETGLOBAL,10)
  SetCodeProbability(#CMD_VARIABLE_SETGLOBAL,10)  

  SetCodeProbability(#CMD_ABSORBABLE_NO,15)  
  SetCodeProbability(#CMD_ABSORBABLE_YES,5) 
  SetCodeProbability(#CMD_IF_ABSORBABLE,5)   
  SetCodeProbability(#CMD_ABSORB_ENEMY,5)      

  SetCodeProbability(#CMD_EMITTOENEMY_POISON,10)   
  SetCodeProbability(#CMD_EMITTOENEMY_DNA,10)   
  SetCodeProbability(#CMD_EMITTOENEMY_DNABLOCK,10)  

  SetCodeProbability(#CMD_PROTECTDNA,25)   
  
  SetCodeProbability(#CMD_NOP, 0)
  
EndProcedure


Procedure SetGlobalVar_EvolutionMode()
  GlobalVarChanged = #False
  GlobalVarMode = ReadPreferenceString_(languagefile, "text", "evolution-mode")
  If IsWindow(#Window_Main)
  SetWindowTitle(#Window_Main,"Living Code V" + #VERSION + "  - " + GlobalVarMode)
  EndIf
  GlobalVar\GlobalVarType = 1
  

  GlobalVar\OBJECT_FOOD_DEFAULT_SIZE = 30000
  GlobalVar\OBJECT_FOOD_MAXSPEED = 0.02
  
  GlobalVar\OBJECT_CATCH_RADIUS_FACTOR = 0.5
  GlobalVar\OBJECT_CATCH_PROPABILITY = 15 ;  (0-100%)
  
  GlobalVar\OBJECT_POISON_ENERGY_DECREASE = 240
  GlobalVar\OBJECT_POISON_ENERGY_ENEMY_DECREASE  = 2000;20 Viel zu wenig
  GlobalVar\OBJECT_POISON_MAXSPEED = 0.3
  GlobalVar\OBJECT_POISON_LIFETIME = 55
  GlobalVar\OBJECT_POISON_PARALYSE_PAUSE = 95 ; NEU 
  
  GlobalVar\OBJECT_VIRUS_ENERGY_DECREASE = 280
  GlobalVar\OBJECT_VIRUS_MAXSPEED = 0.4
  GlobalVar\OBJECT_VIRUS_LIFETIME = 35
  GlobalVar\OBJECT_VIRUS_PROPABILITY = 50 
  
  GlobalVar\OBJECT_DNA_ENERGY_DECREASE = 270
  GlobalVar\OBJECT_DNA_MAXSPEED = 0.3
  GlobalVar\OBJECT_DNA_LIFETIME = 45
  
  GlobalVar\OBJECT_DNA_BLOCK_ENERGY_DECREASE = 300
  
  GlobalVar\OBJECT_MSG_ENERGY_DECREASE = 90
  GlobalVar\OBJECT_MSG_MAXSPEED = 0.65
  GlobalVar\OBJECT_MSG_LIFETIME = 65
  
  GlobalVar\OBJECT_REST_MAXLIFETIME = 500
  
  GlobalVar\CREATURE_MOVESPEED = 0.15
  GlobalVar\CREATURE_ROTATIONSPEED = 1.0/360.0 * 2 * #PI
  GlobalVar\CREATURE_GROWTH.f = 0.002 
  
  GlobalVar\CREATURE_MAXRADIUS = 35
  GlobalVar\CREATURE_MINRADIUS = 1 
  
  GlobalVar\CREATURE_MOVE_ENERGY_DECREASE = 5
  GlobalVar\CREATURE_ROTATION_ENERGY_DECREASE = 5
  
  GlobalVar\CREATURE_CLONE_ENERGY_DECREASE = 800
  
  GlobalVar\CREATURE_COMBINECOPY_MINABS.l = 70
  
  GlobalVar\CREATURE_SEARCH_ENEMY_ENERGY_DECREASE = 90
  
  GlobalVar\CREATURE_RANDOMMOVE = 0.08
  GlobalVar\CREATURE_RANDOMROTATION = 0.02
  
  GlobalVar\CREATURE_ROUNDENERGYFACTOR1 = 0.9
  GlobalVar\CREATURE_ROUNDENERGYFACTOR2 = 0.005
  
  GlobalVar\CREATURE_PROBABLE_CLONE_CHANGECELLNUMBER  = 5 ;(0-100%)
  GlobalVar\CREATURE_PROBABLE_CLONE_COPYDNA  = 5 ; (0-100%)
  GlobalVar\CREATURE_PROBABLE_CLONE_CHANGESIZE = 8 ;(0-100%)
  GlobalVar\CREATURE_PROBABLE_CLONE_MIN_CLONE_COUNT = 200 ; Muss größer als 32 sein!
  
  GlobalVar\CREATURE_ANTIVIRUS_ENERGY_DECREASE = 30
  GlobalVar\CREATURE_PROTECTVIRUS_COUNT = 5
  
  GlobalVar\CREATURE_CELLBONUS = 0.95
  
  GlobalVar\MUTATION_PROBABILITY = 10 ; (0-10000)
  GlobalVar\MUTATION_PROBABILITY_CHAOS = 3;5 ; (0-100%)
  
  GlobalVar\MUTATION_PROBABILITY_RADIUS = 2 ;(0-100%)
  GlobalVar\MUTATION_RADIUS_CHANGE = 2 
  
  GlobalVar\CREATURE_METABOLISM_RATE = 16000
  
  GlobalVar\Object_Trans = 200
  GlobalVar\MinimalCreatures = 1
  GlobalVar\ExecuteCount=5
  GlobalVar\Reducecpuusage=0
  
  GlobalVar\CREATURE_REPLACE_ENERGY_DECREASE = 30

  GlobalVar\CREATURE_PROTECT_DNA_ENERGY_DECREASE = 35  
  GlobalVar\CREATURE_PROTECT_DNA_COUNT = 5
  
  SetCodeProbability(#CMD_MOVE_FORWARD, 450)
  
  SetCodeProbability(#CMD_MOVE_BACKWARD, 60)
  
  SetCodeProbability(#CMD_EATING_YES, 35)
  SetCodeProbability(#CMD_EATING_NO, 5)
  SetCodeProbability(#CMD_EATING_EMIT, 5)
  
  SetCodeProbability(#CMD_POISON_EMIT, 5)
  SetCodeProbability(#CMD_POISON_IMMUN1, 25)
  SetCodeProbability(#CMD_POISON_IMMUN2, 25)
  SetCodeProbability(#CMD_POISON_IMMUN3, 25)
  SetCodeProbability(#CMD_POISON_YES, 25)
  SetCodeProbability(#CMD_POISON_NO,  25)
  SetCodeProbability(#CMD_POISON_VIRUS_MIN_ENERGY, 15)
  SetCodeProbability(#CMD_POISON_EMIT_VIRUS, 5)
  SetCodeProbability(#CMD_POISON_DNA_CODE, 25)
  SetCodeProbability(#CMD_POISON_EMIT_DNA, 5)
  
  SetCodeProbability(#CMD_POISON_EMIT_DNABLOCK, 10)
  SetCodeProbability(#CMD_POISON_DNABLOCK_SIZE, 20)
  
  SetCodeProbability(#CMD_MSG_EMIT, 10)
  
  SetCodeProbability(#CMD_ROTATE_LEFT, 55)
  SetCodeProbability(#CMD_ROTATE_RIGHT, 55)
  
  SetCodeProbability(#CMD_ROTATE_MSG, 90)
  SetCodeProbability(#CMD_ROTATE_DNA, 50)
  SetCodeProbability(#CMD_ROTATE_POISON, 50)
  SetCodeProbability(#CMD_ROTATE_FOOD, 250)
  
  SetCodeProbability(#CMD_ROTATE_ANTI_MSG, 20)
  SetCodeProbability(#CMD_ROTATE_ANTI_DNA, 65)
  SetCodeProbability(#CMD_ROTATE_ANTI_POISON, 65)
  SetCodeProbability(#CMD_ROTATE_ANTI_FOOD, 10)
  
  SetCodeProbability(#CMD_IF_ENERGY_GREATER, 45)
  SetCodeProbability(#CMD_IF_ENERGY_LESS, 45)
  SetCodeProbability(#CMD_IF_ENERGY_EQUAL, 5)
  
  SetCodeProbability(#CMD_IF_ENERGYINC_GREATER, 15)
  SetCodeProbability(#CMD_IF_ENERGYDEC_GREATER, 15)
  
  SetCodeProbability(#CMD_IF_MSG_GREATER, 10)
  SetCodeProbability(#CMD_IF_MSG_LESS, 10)
  SetCodeProbability(#CMD_IF_MSG_EQUAL, 10)
  
  SetCodeProbability(#CMD_IF_FOOD_GREATER, 10)
  SetCodeProbability(#CMD_IF_FOOD_LESS, 10)
  SetCodeProbability(#CMD_IF_FOOD_EQUAL, 5)
  
  SetCodeProbability(#CMD_IF_POISON_GREATER, 10)
  SetCodeProbability(#CMD_IF_POISON_LESS, 10)
  SetCodeProbability(#CMD_IF_POISON_EQUAL, 5)
  
  SetCodeProbability(#CMD_IF_POISONID_GREATER, 10)
  SetCodeProbability(#CMD_IF_POISONID_LESS, 10)
  SetCodeProbability(#CMD_IF_POISONID_EQUAL, 5)
  
  SetCodeProbability(#CMD_IF_DNA_GREATER, 10)
  SetCodeProbability(#CMD_IF_DNA_LESS, 10)
  SetCodeProbability(#CMD_IF_DNA_EQUAL, 5)
  
  SetCodeProbability(#CMD_IF_VARIABLE_GREATER, 10)
  SetCodeProbability(#CMD_IF_VARIABLE_LESS, 10)
  SetCodeProbability(#CMD_IF_VARIABLE_EQUAL, 5)
  
  SetCodeProbability(#CMD_IF_CELL_RAD_GREATER, 20)
  SetCodeProbability(#CMD_IF_CELL_RAD_LESS, 20)
  SetCodeProbability(#CMD_IF_CELL_RAD_EQUAL, 5)
  
  SetCodeProbability(#CMD_ENDIF, 580)
  SetCodeProbability(#CMD_CLONE, 65)
  SetCodeProbability(#CMD_COPY_MIN_ENERGY, 80)
  SetCodeProbability(#CMD_COPY50_50, 25)
  SetCodeProbability(#CMD_COPY25_75, 15)
  SetCodeProbability(#CMD_COPY5_95, 5)
  SetCodeProbability(#CMD_RETURN, 30)
  SetCodeProbability(#CMD_GOTO, 205)
  SetCodeProbability(#CMD_GOTO50, 125)
  SetCodeProbability(#CMD_GOTO25, 75)
  SetCodeProbability(#CMD_GOTO5, 50)
  
  SetCodeProbability(#CMD_RNDGOTO, 70)
  SetCodeProbability(#CMD_VARIABLE, 200)
  SetCodeProbability(#CMD_VARIABLE_ZERO, 20)
  SetCodeProbability(#CMD_VARIABLE_DEC, 20)
  SetCodeProbability(#CMD_VARIABLE_INC, 20)
  SetCodeProbability(#CMD_VARIABLE_SET, 20)
  
  SetCodeProbability(#CMD_VARIABLE_ADD,15)
  SetCodeProbability(#CMD_VARIABLE_SUB,15)
  SetCodeProbability(#CMD_VARIABLE_MUL,15)
  SetCodeProbability(#CMD_VARIABLE_DIV,15)
  SetCodeProbability(#CMD_VARIABLE_XOR,15)
  SetCodeProbability(#CMD_VARIABLE_OR,15)
  SetCodeProbability(#CMD_VARIABLE_AND,15)
  SetCodeProbability(#CMD_VARIABLE_MOD,15)  
  
  SetCodeProbability(#CMD_INC_CELL_RAD, 5)
  SetCodeProbability(#CMD_DEC_CELL_RAD, 5)
  
  SetCodeProbability(#CMD_SIN_CELL_RAD, 10)
  SetCodeProbability(#CMD_SIN_CELL_AMPRAD, 10)
  SetCodeProbability(#CMD_SIN_CELL_MIDRAD, 10)
  
  SetCodeProbability(#CMD_TIMER_SET,150)
  SetCodeProbability(#CMD_TIMER_GOTO,150)
  SetCodeProbability(#CMD_TIMER_YES,15)
  SetCodeProbability(#CMD_TIMER_NO,5)
  
  SetCodeProbability(#CMD_IF_X_GREATER, 5)
  SetCodeProbability(#CMD_IF_X_LESS, 5)
  SetCodeProbability(#CMD_IF_X_EQUAL, 2)
  SetCodeProbability(#CMD_IF_Y_GREATER, 5)
  SetCodeProbability(#CMD_IF_Y_LESS, 5)
  SetCodeProbability(#CMD_IF_Y_EQUAL, 2)
  
  SetCodeProbability(#CMD_IF_ENEMYABS_GREATER, 55)
  SetCodeProbability(#CMD_IF_ENEMYABS_LESS, 55)
  SetCodeProbability(#CMD_IF_ENEMYABS_EQUAL, 5)
  SetCodeProbability(#CMD_ROTATE_ENEMY, 120)
  SetCodeProbability(#CMD_ROTATE_ANTI_ENEMY, 25)
  
  SetCodeProbability(#CMD_SEARCH_NEAREST_ENEMY, 20)
  
  SetCodeProbability(#CMD_IF_CMP_ENEMY_GREATER, 35)
  SetCodeProbability(#CMD_IF_CMP_ENEMY_LESS, 35)
  SetCodeProbability(#CMD_IF_CMP_ENEMY_EQUAL, 5)
  
  SetCodeProbability(#CMD_DEST_POINT_X, 5)
  SetCodeProbability(#CMD_DEST_POINT_Y, 5)
  SetCodeProbability(#CMD_ROTATE_DEST_POINT, 5)
  SetCodeProbability(#CMD_ROTATE_ANTI_DEST_POINT, 5)
  
  SetCodeProbability(#CMD_VARIABLE_COPY, 25)
  
  SetCodeProbability(#CMD_PAUSE, 10)
  SetCodeProbability(#CMD_ANTIVIRUS, 35)
  
  SetCodeProbability(#CMD_PROTECTVIRUS, 45)
  SetCodeProbability(#CMD_COMBINECOPY, 85)
  
  SetCodeProbability(#CMD_IF_GENERATION_GREATER,20)
  SetCodeProbability(#CMD_IF_GENERATION_LESS,20)
  SetCodeProbability(#CMD_IF_GENERATION_EQUAL,5)
  
  SetCodeProbability(#CMD_IF_NUMOFCELLS_GREATER,15)
  SetCodeProbability(#CMD_IF_NUMOFCELLS_LESS,15)
  SetCodeProbability(#CMD_IF_NUMOFCELLS_EQUAL,10)
  
  SetCodeProbability(#CMD_IF_CELLNUMER_GREATER,20)
  SetCodeProbability(#CMD_IF_CELLNUMER_LESS,20)
  SetCodeProbability(#CMD_IF_CELLNUMER_EQUAL,20)  
  
  SetCodeProbability(#CMD_IF_MALE,45)
  SetCodeProbability(#CMD_IF_FEMALE,45)
  
  SetCodeProbability(#CMD_IF_AGE_GREATER,20)
  SetCodeProbability(#CMD_IF_AGE_LESS,20)
  SetCodeProbability(#CMD_IF_AGE_EQUAL,5)    
  
  SetCodeProbability(#CMD_VARIABLE_RND,30)
  
  SetCodeProbability(#CMD_MOVE_FORWARD2X,270)
  
  SetCodeProbability(#CMD_MUTATE,5)
  
  SetCodeProbability(#CMD_MUTATE_LINE,45)  
  SetCodeProbability(#CMD_BLOCKEXEC,45)
  SetCodeProbability(#CMD_EMITTOENEMY_FOOD,10)    
  SetCodeProbability(#CMD_EMITTOENEMY_MSG,10)
  SetCodeProbability(#CMD_REPLACEMENT_CMD,20)
  SetCodeProbability(#CMD_REPLACE_CMD,15)  
  
  SetCodeProbability(#CMD_VARIABLE_GETGLOBAL,10)
  SetCodeProbability(#CMD_VARIABLE_SETGLOBAL,10)  
          
  SetCodeProbability(#CMD_ABSORBABLE_NO,15)  
  SetCodeProbability(#CMD_ABSORBABLE_YES,5) 
  SetCodeProbability(#CMD_IF_ABSORBABLE,5)   
  SetCodeProbability(#CMD_ABSORB_ENEMY,5)           
 
  SetCodeProbability(#CMD_EMITTOENEMY_POISON,10)   
  SetCodeProbability(#CMD_EMITTOENEMY_DNA,10)   
  SetCodeProbability(#CMD_EMITTOENEMY_DNABLOCK,10)  
  
  SetCodeProbability(#CMD_PROTECTDNA,25) 
            
  SetCodeProbability(#CMD_NOP, 0)
  
EndProcedure

Procedure ChangeGlobalVar()
result=#False
If GlobalVarChanged = #True
  If MessageRequester(ReadPreferenceString_(languagefile, "text", "change-options"),ReadPreferenceString_(languagefile, "text", "change-options-text"),#PB_MessageRequester_YesNo)=#PB_MessageRequester_Yes
    result=#True
  EndIf
Else
  result=#True
EndIf
ProcedureReturn result
EndProcedure





Global UPLOAD_URL.s = ""
Global UPLOAD_TEST_URL.s = ""
Global UPLOAD_AGENT.s = ""
Global UPLOAD_KEY.s = ""
Global UPLOAD_FILE_KEY.s = ""
Global UPLOAD_UPLOADPAGE.s = ""
Global UPLOAD_PAGEVIEW.s = ""
Global UPLOAD_PAGEUPLOAD.s = ""
Global UPLOAD_VERSION.s = ""




If UPLOAD_TEST_URL.s=""
MessageRequester(ReadPreferenceString_(languagefile, "text", "info"),ReadPreferenceString_(languagefile, "text", "none-download-creatures"))
EndIf



Structure CELL
  CellID.l
  
  LastEnergy.l
  
  TimerStarted.l
  TimerCount.l
  TimerGoto.l
  
  OrgRadius.f 
  Radius.f
  DoEating.l
  FoodCount.l
  FoodDirection.f
  
  DoPoison.l
  Poision.l
  PoisonCount.l
  PoisonImmun.l[3]
  PoisonDirection.f
  
  VirusMinEnergy.l
  
  DNACount.l
  DNADirection.f
  DNACode.l
  
  msg.l
  MsgDirection.f
  
  CopyMinEnergy.l
  
  InCondition.l
  Condition.l
  CodePosition.l
  CodeVariable.l
  DNA.l[#CODE_SIZE]
  SinRadius.l
  SinRadiusAmp.l   
  SinRadiusMid.l
  ;Runtime_BlockedPoison.l
  ;Runtime_VirusExecution.l
  ;Runtime_FoodFound.l
  EnergyFootprint.l
  
  DNABlockSize.l
  
  EnemyX.l
  EnemyY.l
  
  PointX.l
  PointY.l
  
  EnemyIncCreatureID.l  
  EnemyFound.l
  
  DoNotExecCount.l
  ProtectVirusCount.l
  
  MutateCodePos.l
  BlockCodePos.l
  Replacement_CMD.l

  ProtectDNACount.l 

  Reseved.l[36]   
EndStructure

Structure CREATURE
  Used.l
  IncCreatureID.l
  CreatureID.l
  CreatureName.s{16}
  Author.s{16}
  Description.s{512}
  CreateDate.l
  Color.l
  X.f
  Y.f
  Angle.f
  Energy.l
  OrgEnergy.l
  NumCells.l
  Cells.CELL[#MAX_CELLS]
  CopyMinCount.l
  DisableMutation.l
  
  Age.l
  IsMale.l
  MagicCreature.l
  GlobalVar.l
  
  Absorbable.l
  HideMode.l
  EncryptionKey.l
  
  Reseved.l[20]
EndStructure

Structure JMP_Point
  Name.s
  Position.l
EndStructure


Structure OBJECT
  Used.l
  CreatureID.l
  CellID.l
  Type.l
  Angle.f
  Speed.f
  Rotation.l
  X.f
  Y.f
  LifeTime.l
  StructureUnion
  Energy.l    ; Energy für OBJECT_FOOD
  MessageID.l ; OBJECT_MSG
  PoisonID.l  ; OBJECT_POISON
  DNACode.l   ; Befehl für OBJECT_DNA
  MinEnergy.l ; Mindestenergie für OBJECT_VIRUS
  EndStructureUnion
  DNAPosition.l ; Position für OBJECT_DNA/OBJECT_VIRUS
  IsDNABlock.l
  DNABlock.l[#MAX_DNAMAXBLOCKSIZE]
  DNABlockSize.l
  Mutex.l
EndStructure

Structure PROBABILITY
  Pos.l
  Size.l
EndStructure

Global Dim CodeProbability.PROBABILITY(#CMD_NOP)
Global CompleteCodeProbability.l

Global Dim Creatures.CREATURE(1000)
Global Creatures_Count = 1000
Global Creatures_MaxCount = 1000
Global Creatures_Mutex = CreateMutex()
Global Real_Creatures = 0

Global Dim Objects.OBJECT(1000)
Objects(0)\Mutex = CreateMutex()
Objects(1)\Mutex = CreateMutex()
Global Objects_Count = 1000
Global Objects_MaxCount = 1000
Global Objects_Mutex = CreateMutex()

Global GlobalDrawing = #True

Structure GadGet_State
  FOOD.l
  VIRUS.l
  DNA.l
  POISON.l
  msg.l
  REST.l
  Creature.l
  Break_Game.l
EndStructure

Structure GadGet_Creature
  CodeLine.l
  CodeText.l
  CodeEditor.l
  CellIDText.l
  CellIDStr.l
  CellRandiusText.l
  CellRandiusStr.l
  CellCodePositionText.l
  CellCodePositionStr.l
  CellOrgRandiusStr.l
  CellOrgRandiusText.l
  ImportCode.l
  ExportCode.l
  SetCode.l
EndStructure

Structure InsertCreatures
  Text.l
  File.l
  SetFile.l
  Ok.l
EndStructure

Structure GadGet
  state.GadGet_State
  Creature.GadGet_Creature[#MAX_CELLS]
  InsertCreatures.InsertCreatures[20]
EndStructure
Global GadGet.GadGet

Structure Sprite
  FOOD.l
  VIRUS.l
  DNA.l
  POISON.l
  msg.l
  REST.l
  FOOD3D.l
  VIRUS3D.l
  DNA3D.l
  POISON3D.l
  MSG3D.l
  REST3D.l
  Game_Logo.l
  BK.l
  MOUSE.l
  Texture_Ground.l
  Texture_Crature.l
  Texture_Sky.l
  Texture_Virus.l
  Texture_DNA.l
  Texture_Food.l
  Texture_Poison.l
  Texture_Rest.l
  Img_Ok.l
  Img_Cheater.l
  Img_empty.l
  Texture_Crature2.l
  Texture_Crature23D.l
  Texture_CratureHover.l
  Texture_Crature3DHover.l
EndStructure

Global Sprite.Sprite

Global CreaturePattern.s = "Text (*.txt)|*.txt|"+ReadPreferenceString_(languagefile, "text", "Creature-Fragment")+" (*.CRF)|*.CRF|"+ReadPreferenceString_(languagefile, "text", "All-files")+" (*.*)|*.*"
Global CellPattern.s = "Text (*.txt)|*.txt|"+ReadPreferenceString_(languagefile, "text", "Cell-Fragment")+" (*.CEF)|*.CEF|"+ReadPreferenceString_(languagefile, "text", "All-files")+" (*.*)|*.*"
Global ScenePattern.s = "Text (*.txt)|*.txt|"+ReadPreferenceString_(languagefile, "text", "Living-Code-Fragment")+" (*.LCF)|*.LCF|"+ReadPreferenceString_(languagefile, "text", "All-files")+" (*.*)|*.*"
Global MousePosX.l
Global MousePosY.l


Procedure SetCodeProbability(code,Probability)
  CodeProbability(code)\Size = Probability
  
  For i = 0 To #CMD_NOP
    CodeProbability(i)\Pos = Pos
    Pos + CodeProbability(i)\Size
  Next
  CompleteCodeProbability = Pos
EndProcedure

Procedure GetCodeProbability(code)
  ProcedureReturn CodeProbability(code)\Size
EndProcedure

Procedure GetCodeByProbability()
  Result = Random($FFFFFF) + Random($FFFFFF)
  Result % CompleteCodeProbability
  ;Random(CompleteCodeProbability)
  For i = 0 To #CMD_NOP
    If Result => CodeProbability(i)\Pos And Result < CodeProbability(i)\Pos + CodeProbability(i)\Size
      ProcedureReturn i 
    EndIf
  Next
EndProcedure




Procedure CalcLastCreature()
  For i = 0 To Creatures_MaxCount-1
    If Creatures(i)\Used = #True
      Creatures_Count = i + 1
    EndIf
  Next
EndProcedure

Procedure ResetCreaturesCount()
  If Creatures_MaxCount <= Creatures_Count * 2
    Creatures_MaxCount = Creatures_Count * 2 + 1
    ReDim Creatures.CREATURE(Creatures_MaxCount)
  EndIf
EndProcedure



Procedure.l AddCreature()
  _PlaySound(1)  
  LockMutex(Creatures_Mutex)
  
  For i = 0 To Creatures_MaxCount-1
    If Creatures(i)\Used = #False
      CompilerIf #PB_Compiler_OS = #PB_OS_Linux
        Creatures(i)\OrgEnergy = 0
      CompilerElse
        ZeroMemory_(@Creatures(i), SizeOf(CREATURE))
      CompilerEndIf
      
      Creatures(i)\Used = #True
      If i + 1 > Creatures_Count
        Creatures_Count = i + 1
      EndIf          
      UnlockMutex(Creatures_Mutex)
      ProcedureReturn @Creatures(i)
    EndIf
  Next
  
  ReDim Creatures.CREATURE(Creatures_MaxCount + 1)
  Result = @Creatures(Creatures_MaxCount)
  CompilerIf #PB_Compiler_OS = #PB_OS_Linux
    Creatures(i)\OrgEnergy = 0
  CompilerElse
    ZeroMemory_(@Creatures(i), SizeOf(CREATURE))
  CompilerEndIf
  Creatures(Creatures_MaxCount)\Used = #True
  Creatures_MaxCount + 1
  Creatures_Count = Creatures_MaxCount
  UnlockMutex(Creatures_Mutex)
  ProcedureReturn Result
EndProcedure




Procedure CalcLastObject()
  For i = 0 To Objects_MaxCount-1
    If Objects(i)\Used = #True
      Objects_Count = i + 1
    EndIf
  Next
EndProcedure

Procedure.l AddObject()
  LockMutex(Objects_Mutex)
  
  For i = 0 To Objects_MaxCount-1
    If Objects(i)\Used = #False
      Objects(i)\Used = #True
      If i + 1 > Objects_Count
        Objects_Count = i + 1
      EndIf
      UnlockMutex(Objects_Mutex)
      ProcedureReturn @Objects(i)
    EndIf
  Next
  
  ReDim Objects.OBJECT(Objects_MaxCount + 1)
  Result = @Objects(Objects_MaxCount)
  Objects(Objects_MaxCount)\Used = #True
  Objects(Objects_MaxCount)\Mutex = CreateMutex()
  Objects_MaxCount + 1
  Objects_Count = Objects_MaxCount
  UnlockMutex(Objects_Mutex)
  ProcedureReturn Result
EndProcedure


Procedure.f ModRad(Angle.f)
  orgAngle.l = (Angle * 36000)/ (2*#PI)
  orgAngle % 36000
  If orgAngle < 0 :orgAngle = 36000 + orgAngle:EndIf
  ProcedureReturn (orgAngle * 2 * #PI)/ 36000
EndProcedure


Procedure.f Rotate(fromRot.f, toRot.f, maxSpeed.f) 
  fromRot = ModRad(fromRot)
  toRot = ModRad(toRot)
  
  dist.f = toRot - fromRot 
  
  
  If Abs(dist) > maxSpeed
    
    If dist > #PI: dist = -dist:EndIf
    
    If dist > 0 
      ProcedureReturn maxSpeed
    EndIf
    If dist < 0 
      ProcedureReturn -maxSpeed
    EndIf
    
  EndIf
  ProcedureReturn 0.0
EndProcedure


Procedure.f Angle(x1.f,y1.f,x2.f,y2.f)
  vx.f=x2-x1
  vy.f=y2-y1
  w.f=vx/Sqr(vx*vx+vy*vy)
  Angle.f=ACos(w)
  If y1<y2:Angle=-Angle:EndIf 
  ProcedureReturn Angle
EndProcedure




Procedure CMDStringToCode(cmd.s)
  res.l = -1
  Select cmd
    Case "MOVE_FORWARD"
      res = #CMD_MOVE_FORWARD
    Case "MOVE_BACKWARD"
      res = #CMD_MOVE_BACKWARD
    Case "EATING_YES"
      res = #CMD_EATING_YES
    Case "EATING_NO"
      res = #CMD_EATING_NO
    Case "EATING_EMIT"
      res = #CMD_EATING_EMIT
    Case "POISON_EMIT"
      res = #CMD_POISON_EMIT
    Case "POISON_IMMUN1"
      res = #CMD_POISON_IMMUN1
    Case "POISON_IMMUN2"
      res = #CMD_POISON_IMMUN2
    Case "POISON_IMMUN3"
      res = #CMD_POISON_IMMUN3
    Case "POISON_YES"
      res = #CMD_POISON_YES
    Case "POISON_NO"
      res = #CMD_POISON_NO
    Case "POISON_VIRUS_MIN_ENERGY"
      res = #CMD_POISON_VIRUS_MIN_ENERGY
    Case "POISON_EMIT_VIRUS"
      res = #CMD_POISON_EMIT_VIRUS
    Case "POISON_DNA_CODE"
      res = #CMD_POISON_DNA_CODE
    Case "POISON_EMIT_DNA"
      res = #CMD_POISON_EMIT_DNA
      
    Case "POISON_EMIT_DNABLOCK"
      res = #CMD_POISON_EMIT_DNABLOCK
    Case "POISON_DNABLOCK_SIZE"
      res = #CMD_POISON_DNABLOCK_SIZE      
      
    Case "MSG_EMIT"
      res = #CMD_MSG_EMIT
    Case "ROTATE_LEFT"
      res = #CMD_ROTATE_LEFT
    Case "ROTATE_RIGHT"
      res = #CMD_ROTATE_RIGHT
    Case "ROTATE_MSG"
      res = #CMD_ROTATE_MSG
    Case "ROTATE_DNA"
      res = #CMD_ROTATE_DNA
    Case "ROTATE_POISON"
      res = #CMD_ROTATE_POISON
    Case "ROTATE_FOOD"
      res = #CMD_ROTATE_FOOD
    Case "ROTATE_ANTI_MSG"
      res = #CMD_ROTATE_ANTI_MSG
    Case "ROTATE_ANTI_DNA"
      res = #CMD_ROTATE_ANTI_DNA
    Case "ROTATE_ANTI_POISON"
      res = #CMD_ROTATE_ANTI_POISON
    Case "ROTATE_ANTI_FOOD"
      res = #CMD_ROTATE_ANTI_FOOD
    Case "IF_ENERGY_GREATER"
      res = #CMD_IF_ENERGY_GREATER
    Case "IF_ENERGY_LESS"
      res = #CMD_IF_ENERGY_LESS
    Case "IF_ENERGY_EQUAL"
      res = #CMD_IF_ENERGY_EQUAL
    Case "IF_ENERGYINC_GREATER"
      res = #CMD_IF_ENERGYINC_GREATER
    Case "IF_ENERGYDEC_GREATER"
      res = #CMD_IF_ENERGYDEC_GREATER
    Case "IF_MSG_GREATER"
      res = #CMD_IF_MSG_GREATER
    Case "IF_MSG_LESS"
      res = #CMD_IF_MSG_LESS
    Case "IF_MSG_EQUAL"
      res = #CMD_IF_MSG_EQUAL
    Case "IF_FOOD_GREATER"
      res = #CMD_IF_FOOD_GREATER
    Case "IF_FOOD_LESS"
      res = #CMD_IF_FOOD_LESS
    Case "IF_FOOD_EQUAL"
      res = #CMD_IF_FOOD_EQUAL
    Case "IF_POISON_GREATER"
      res = #CMD_IF_POISON_GREATER
    Case "IF_POISON_LESS"
      res = #CMD_IF_POISON_LESS
    Case "IF_POISON_EQUAL"
      res = #CMD_IF_POISON_EQUAL
    Case "IF_POISONID_GREATER"
      res = #CMD_IF_POISONID_GREATER
    Case "IF_POISONID_LESS"
      res = #CMD_IF_POISONID_LESS
    Case "IF_POISONID_EQUAL"
      res = #CMD_IF_POISONID_EQUAL
    Case "IF_DNA_GREATER"
      res = #CMD_IF_DNA_GREATER
    Case "IF_DNA_LESS"
      res = #CMD_IF_DNA_LESS
    Case "IF_DNA_EQUAL"
      res = #CMD_IF_DNA_EQUAL
    Case "IF_VARIABLE_GREATER"
      res = #CMD_IF_VARIABLE_GREATER
    Case "IF_VARIABLE_LESS"
      res = #CMD_IF_VARIABLE_LESS
    Case "IF_VARIABLE_EQUAL"
      res = #CMD_IF_VARIABLE_EQUAL
    Case "IF_CELL_RAD_GREATER"
      res = #CMD_IF_CELL_RAD_GREATER
    Case "IF_CELL_RAD_LESS"
      res = #CMD_IF_CELL_RAD_LESS
    Case "IF_CELL_RAD_EQUAL"
      res = #CMD_IF_CELL_RAD_EQUAL
    Case "ENDIF"
      res = #CMD_ENDIF
    Case "CLONE"
      res = #CMD_CLONE
    Case "COPY_MIN_ENERGY"
      res = #CMD_COPY_MIN_ENERGY
    Case "COPY50_50"
      res = #CMD_COPY50_50
    Case "COPY25_75"
      res = #CMD_COPY25_75
    Case "COPY5_95"
      res = #CMD_COPY5_95
    Case "RETURN"
      res = #CMD_RETURN
    Case "GOTO"
      res = #CMD_GOTO
    Case "GOTO50"
      res = #CMD_GOTO50
    Case "GOTO25"
      res = #CMD_GOTO25
    Case "GOTO5"
      res = #CMD_GOTO5
    Case "RNDGOTO"
      res = #CMD_RNDGOTO
    Case "VARIABLE"
      res = #CMD_VARIABLE
    Case "VARIABLE_ZERO"
      res = #CMD_VARIABLE_ZERO
    Case "VARIABLE_DEC"
      res = #CMD_VARIABLE_DEC
    Case "VARIABLE_INC"
      res = #CMD_VARIABLE_INC
    Case "VARIABLE_SET"
      res = #CMD_VARIABLE_SET
      
    Case "VARIABLE_ADD"
      res = #CMD_VARIABLE_ADD 
    Case "VARIABLE_SUB"
      res = #CMD_VARIABLE_SUB 
    Case "VARIABLE_MUL"
      res = #CMD_VARIABLE_MUL 
    Case "VARIABLE_DIV"
      res = #CMD_VARIABLE_DIV 
    Case "VARIABLE_XOR"
      res = #CMD_VARIABLE_XOR               
    Case "VARIABLE_OR"
      res = #CMD_VARIABLE_OR 
    Case "VARIABLE_AND"
      res = #CMD_VARIABLE_AND 
    Case "VARIABLE_MOD"
      res = #CMD_VARIABLE_MOD 
      
    Case "INC_CELL_RAD"
      res = #CMD_INC_CELL_RAD
    Case "DEC_CELL_RAD"
      res = #CMD_DEC_CELL_RAD
      
    Case "SIN_CELL_RAD"
      res = #CMD_SIN_CELL_RAD
    Case "SIN_CELL_AMPRAD"
      res = #CMD_SIN_CELL_AMPRAD
    Case "SIN_CELL_MIDRAD"
      res = #CMD_SIN_CELL_MIDRAD
      
      
    Case "TIMER_SET"
      res = #CMD_TIMER_SET
    Case "TIMER_GOTO"
      res = #CMD_TIMER_GOTO
    Case "TIMER_YES"
      res = #CMD_TIMER_YES
    Case "TIMER_NO"
      res = #CMD_TIMER_NO  
      
      
    Case "IF_X_GREATER"
      res = #CMD_IF_X_GREATER
    Case "IF_X_LESS"
      res = #CMD_IF_X_LESS
    Case "IF_X_EQUAL"
      res = #CMD_IF_X_EQUAL
      
    Case "IF_Y_GREATER"
      res = #CMD_IF_Y_GREATER
    Case "IF_Y_LESS"
      res = #CMD_IF_Y_LESS
    Case "IF_Y_EQUAL"
      res = #CMD_IF_Y_EQUAL      
      
    Case "IF_ENEMYABS_GREATER"
      res = #CMD_IF_ENEMYABS_GREATER
    Case "IF_ENEMYABS_LESS"
      res = #CMD_IF_ENEMYABS_LESS
    Case "IF_ENEMYABS_EQUAL"
      res = #CMD_IF_ENEMYABS_EQUAL
      
    Case "ROTATE_ENEMY"
      res = #CMD_ROTATE_ENEMY
    Case "ROTATE_ANTI_ENEMY"
      res = #CMD_ROTATE_ANTI_ENEMY
      
    Case "SEARCH_NEAREST_ENEMY"
      res = #CMD_SEARCH_NEAREST_ENEMY
      
    Case "IF_CMP_ENEMY_GREATER"
      res = #CMD_IF_CMP_ENEMY_GREATER
    Case "IF_CMP_ENEMY_LESS"
      res = #CMD_IF_CMP_ENEMY_LESS
    Case "IF_CMP_ENEMY_EQUAL"
      res = #CMD_IF_CMP_ENEMY_EQUAL
      
    Case "DEST_POINT_X"
      res = #CMD_DEST_POINT_X
    Case "DEST_POINT_Y"
      res = #CMD_DEST_POINT_Y
    Case "ROTATE_DEST_POINT"
      res = #CMD_ROTATE_DEST_POINT
    Case "ROTATE_ANTI_DEST_POINT"
      res = #CMD_ROTATE_ANTI_DEST_POINT     
      
    Case "VARIABLE_COPY"       
      res = #CMD_VARIABLE_COPY
      
    Case "PAUSE"
      res = #CMD_PAUSE
      
    Case "ANTIVIRUS"
      res = #CMD_ANTIVIRUS
      
    Case "PROTECTVIRUS" 
      res = #CMD_PROTECTVIRUS
    Case "COMBINECOPY"
      res = #CMD_COMBINECOPY
      
    Case "IF_GENERATION_GREATER"
      res = #CMD_IF_GENERATION_GREATER
    Case "IF_GENERATION_LESS"
      res = #CMD_IF_GENERATION_LESS
    Case "IF_GENERATION_EQUAL"
      res = #CMD_IF_GENERATION_EQUAL
      
    Case "IF_NUMOFCELLS_GREATER"
      res = #CMD_IF_NUMOFCELLS_GREATER      
    Case "IF_NUMOFCELLS_LESS"
      res = #CMD_IF_NUMOFCELLS_LESS
    Case "IF_NUMOFCELLS_EQUAL"
      res = #CMD_IF_NUMOFCELLS_EQUAL
      
    Case "IF_CELLNUMER_GREATER"
      res = #CMD_IF_CELLNUMER_GREATER
    Case "IF_CELLNUMER_LESS"
      res = #CMD_IF_CELLNUMER_LESS
    Case "IF_CELLNUMER_EQUAL"
      res = #CMD_IF_CELLNUMER_EQUAL 
    Case "IF_MALE"
      res = #CMD_IF_MALE
    Case "IF_FEMALE"
      res = #CMD_IF_FEMALE
    Case "IF_AGE_GREATER"
      res = #CMD_IF_AGE_GREATER
    Case "IF_AGE_LESS"
      res = #CMD_IF_AGE_LESS
    Case "IF_AGE_EQUAL"
      res = #CMD_IF_AGE_EQUAL 
    Case "VARIABLE_RND"
      res = #CMD_VARIABLE_RND         
      
    Case "MOVE_FORWARD2X"
      res= #CMD_MOVE_FORWARD2X
      
    Case "MUTATE"
      res = #CMD_MUTATE
      
    Case "MUTATE_LINE"  
      res = #CMD_MUTATE_LINE
      
    Case "BLOCKEXEC"
      res = #CMD_BLOCKEXEC
      
    Case "EMITTOENEMY_FOOD"
      res = #CMD_EMITTOENEMY_FOOD

    Case "EMITTOENEMY_MSG"
      res = #CMD_EMITTOENEMY_MSG
      
    Case "REPLACEMENT_CMD"
      res = #CMD_REPLACEMENT_CMD
      
    Case "REPLACE_CMD"
      res = #CMD_REPLACE_CMD
      
    Case "VARIABLE_GETGLOBAL"
      res = #CMD_VARIABLE_GETGLOBAL  

    Case "VARIABLE_SETGLOBAL"
      res = #CMD_VARIABLE_SETGLOBAL  
      
    Case "ABSORBABLE_YES"      
      res = #CMD_ABSORBABLE_YES
    Case "ABSORBABLE_NO"      
      res = #CMD_ABSORBABLE_NO
    Case "ABSORB_ENEMY"
      res = #CMD_ABSORB_ENEMY
    Case "IF_ABSORBABLE"
      res = #CMD_IF_ABSORBABLE
      
    Case "EMITTOENEMY_POISON"
      res = #CMD_EMITTOENEMY_POISON     
    Case "EMITTOENEMY_DNA"  
      res = #CMD_EMITTOENEMY_DNA     
    Case "EMITTOENEMY_DNABLOCK"
      res = #CMD_EMITTOENEMY_DNABLOCK  
    
    Case "PROTECTDNA"
      res = #CMD_PROTECTDNA  
      
    Case "NOP"
      res = #CMD_NOP
  EndSelect
  
  ProcedureReturn res
EndProcedure

Procedure.s CodeToCMDString(code.l)
  res.s =""
  Select code
    Case #CMD_MOVE_FORWARD
      res = "MOVE_FORWARD"
    Case #CMD_MOVE_BACKWARD
      res = "MOVE_BACKWARD"
    Case #CMD_EATING_YES
      res = "EATING_YES"
    Case #CMD_EATING_NO
      res = "EATING_NO"
    Case #CMD_EATING_EMIT
      res = "EATING_EMIT"
    Case #CMD_POISON_EMIT
      res = "POISON_EMIT"
    Case #CMD_POISON_IMMUN1
      res = "POISON_IMMUN1"
    Case #CMD_POISON_IMMUN2
      res = "POISON_IMMUN2"
    Case #CMD_POISON_IMMUN3
      res = "POISON_IMMUN3"
    Case #CMD_POISON_YES
      res = "POISON_YES"
    Case #CMD_POISON_NO
      res = "POISON_NO"
    Case #CMD_POISON_VIRUS_MIN_ENERGY
      res = "POISON_VIRUS_MIN_ENERGY"
    Case #CMD_POISON_EMIT_VIRUS
      res = "POISON_EMIT_VIRUS"
    Case #CMD_POISON_DNA_CODE
      res = "POISON_DNA_CODE"
    Case #CMD_POISON_EMIT_DNA
      res = "POISON_EMIT_DNA"
      
    Case #CMD_POISON_EMIT_DNABLOCK
      res = "POISON_EMIT_DNABLOCK"
    Case #CMD_POISON_DNABLOCK_SIZE
      res = "POISON_DNABLOCK_SIZE"
      
    Case #CMD_MSG_EMIT
      res = "MSG_EMIT"
    Case #CMD_ROTATE_LEFT
      res = "ROTATE_LEFT"
    Case #CMD_ROTATE_RIGHT
      res = "ROTATE_RIGHT"
    Case #CMD_ROTATE_MSG
      res = "ROTATE_MSG"
    Case #CMD_ROTATE_DNA
      res = "ROTATE_DNA"
    Case #CMD_ROTATE_POISON
      res = "ROTATE_POISON"
    Case #CMD_ROTATE_FOOD
      res = "ROTATE_FOOD"
    Case #CMD_ROTATE_ANTI_MSG
      res = "ROTATE_ANTI_MSG"
    Case #CMD_ROTATE_ANTI_DNA
      res = "ROTATE_ANTI_DNA"
    Case #CMD_ROTATE_ANTI_POISON
      res = "ROTATE_ANTI_POISON"
    Case #CMD_ROTATE_ANTI_FOOD
      res = "ROTATE_ANTI_FOOD"
    Case #CMD_IF_ENERGY_GREATER
      res = "IF_ENERGY_GREATER"
    Case #CMD_IF_ENERGY_LESS
      res = "IF_ENERGY_LESS"
    Case #CMD_IF_ENERGY_EQUAL
      res = "IF_ENERGY_EQUAL"
    Case #CMD_IF_ENERGYINC_GREATER
      res = "IF_ENERGYINC_GREATER"
    Case #CMD_IF_ENERGYDEC_GREATER
      res = "IF_ENERGYDEC_GREATER"
    Case #CMD_IF_MSG_GREATER
      res = "IF_MSG_GREATER"
    Case #CMD_IF_MSG_LESS
      res = "IF_MSG_LESS"
    Case #CMD_IF_MSG_EQUAL
      res = "IF_MSG_EQUAL"
    Case #CMD_IF_FOOD_GREATER
      res = "IF_FOOD_GREATER"
    Case #CMD_IF_FOOD_LESS
      res = "IF_FOOD_LESS"
    Case #CMD_IF_FOOD_EQUAL
      res = "IF_FOOD_EQUAL"
    Case #CMD_IF_POISON_GREATER
      res = "IF_POISON_GREATER"
    Case #CMD_IF_POISON_LESS
      res = "IF_POISON_LESS"
    Case #CMD_IF_POISON_EQUAL
      res = "IF_POISON_EQUAL"
    Case #CMD_IF_POISONID_GREATER
      res = "IF_POISONID_GREATER"
    Case #CMD_IF_POISONID_LESS
      res = "IF_POISONID_LESS"
    Case #CMD_IF_POISONID_EQUAL
      res = "IF_POISONID_EQUAL"
    Case #CMD_IF_DNA_GREATER
      res = "IF_DNA_GREATER"
    Case #CMD_IF_DNA_LESS
      res = "IF_DNA_LESS"
    Case #CMD_IF_DNA_EQUAL
      res = "IF_DNA_EQUAL"
    Case #CMD_IF_VARIABLE_GREATER
      res = "IF_VARIABLE_GREATER"
    Case #CMD_IF_VARIABLE_LESS
      res = "IF_VARIABLE_LESS"
    Case #CMD_IF_VARIABLE_EQUAL
      res = "IF_VARIABLE_EQUAL"
    Case #CMD_IF_CELL_RAD_GREATER
      res = "IF_CELL_RAD_GREATER"
    Case #CMD_IF_CELL_RAD_LESS
      res = "IF_CELL_RAD_LESS"
    Case #CMD_IF_CELL_RAD_EQUAL
      res = "IF_CELL_RAD_EQUAL"
    Case #CMD_ENDIF
      res = "ENDIF"
    Case #CMD_CLONE
      res = "CLONE"
    Case #CMD_COPY_MIN_ENERGY
      res = "COPY_MIN_ENERGY"
    Case #CMD_COPY50_50
      res = "COPY50_50"
    Case #CMD_COPY25_75
      res = "COPY25_75"
    Case #CMD_COPY5_95
      res = "COPY5_95"
    Case #CMD_RETURN
      res = "RETURN"
    Case #CMD_GOTO
      res = "GOTO"
    Case #CMD_GOTO50
      res = "GOTO50"
    Case #CMD_GOTO25
      res = "GOTO25"
    Case #CMD_GOTO5
      res = "GOTO5"
    Case #CMD_RNDGOTO
      res = "RNDGOTO"
    Case #CMD_VARIABLE
      res = "VARIABLE"
    Case #CMD_VARIABLE_ZERO
      res = "VARIABLE_ZERO"
    Case #CMD_VARIABLE_DEC
      res = "VARIABLE_DEC"
    Case #CMD_VARIABLE_INC
      res = "VARIABLE_INC"
    Case #CMD_VARIABLE_SET
      res = "VARIABLE_SET"
    Case #CMD_INC_CELL_RAD
      res = "INC_CELL_RAD"
    Case #CMD_DEC_CELL_RAD
      res = "DEC_CELL_RAD"
      
      
    Case #CMD_VARIABLE_ADD 
      res = "VARIABLE_ADD"
    Case #CMD_VARIABLE_SUB
      res = "VARIABLE_SUB" 
    Case #CMD_VARIABLE_MUL 
      res = "VARIABLE_MUL"
    Case #CMD_VARIABLE_DIV
      res = "VARIABLE_DIV"
    Case #CMD_VARIABLE_XOR
      res = "VARIABLE_XOR"               
    Case #CMD_VARIABLE_OR 
      res = "VARIABLE_OR"
    Case #CMD_VARIABLE_AND
      res = "VARIABLE_AND"
    Case #CMD_VARIABLE_MOD
      res = "VARIABLE_MOD"
      
    Case #CMD_SIN_CELL_RAD
      res = "SIN_CELL_RAD"
    Case #CMD_SIN_CELL_AMPRAD
      res = "SIN_CELL_AMPRAD"
    Case #CMD_SIN_CELL_MIDRAD 
      res = "SIN_CELL_MIDRAD"
      
      
    Case #CMD_TIMER_SET
      res = "TIMER_SET"     
    Case #CMD_TIMER_GOTO
      res = "TIMER_GOTO"
    Case #CMD_TIMER_YES
      res = "TIMER_YES"
    Case #CMD_TIMER_NO  
      res = "TIMER_NO"      
      
      
      
    Case #CMD_IF_X_GREATER
      res = "IF_X_GREATER"
    Case #CMD_IF_X_LESS
      res = "IF_X_LESS"
    Case #CMD_IF_X_EQUAL
      res = "IF_X_EQUAL"
      
    Case #CMD_IF_Y_GREATER
      res = "IF_Y_GREATER"
    Case #CMD_IF_Y_LESS
      res = "IF_Y_LESS" 
    Case #CMD_IF_Y_EQUAL
      res = "IF_Y_EQUAL"      
      
    Case #CMD_IF_ENEMYABS_GREATER
      res = "IF_ENEMYABS_GREATER"
    Case #CMD_IF_ENEMYABS_LESS
      res = "IF_ENEMYABS_LESS"
    Case #CMD_IF_ENEMYABS_EQUAL
      res = "IF_ENEMYABS_EQUAL"
      
    Case #CMD_ROTATE_ENEMY
      res = "ROTATE_ENEMY"
    Case #CMD_ROTATE_ANTI_ENEMY
      res = "ROTATE_ANTI_ENEMY"      
      
    Case #CMD_SEARCH_NEAREST_ENEMY
      res = "SEARCH_NEAREST_ENEMY"
      
    Case #CMD_IF_CMP_ENEMY_GREATER
      res = "IF_CMP_ENEMY_GREATER"
    Case #CMD_IF_CMP_ENEMY_LESS
      res = "IF_CMP_ENEMY_LESS"
    Case #CMD_IF_CMP_ENEMY_EQUAL
      res = "IF_CMP_ENEMY_EQUAL"
      
    Case #CMD_DEST_POINT_X
      res = "DEST_POINT_X"
    Case #CMD_DEST_POINT_Y
      res = "DEST_POINT_Y"
    Case #CMD_ROTATE_DEST_POINT
      res = "ROTATE_DEST_POINT"
    Case #CMD_ROTATE_ANTI_DEST_POINT
      res = "ROTATE_ANTI_DEST_POINT"
      
    Case #CMD_VARIABLE_COPY      
      res = "VARIABLE_COPY" 
      
    Case #CMD_PAUSE
      res = "PAUSE"
      
    Case #CMD_ANTIVIRUS
      res = "ANTIVIRUS"
      
      
    Case #CMD_PROTECTVIRUS 
      res = "PROTECTVIRUS"
    Case #CMD_COMBINECOPY
      res = "COMBINECOPY"
      
      
      
    Case #CMD_IF_GENERATION_GREATER
      res = "IF_GENERATION_GREATER"
    Case #CMD_IF_GENERATION_LESS
      res = "IF_GENERATION_LESS"
    Case #CMD_IF_GENERATION_EQUAL
      res = "IF_GENERATION_EQUAL"
      
    Case #CMD_IF_NUMOFCELLS_GREATER
      res = "IF_NUMOFCELLS_GREATER"      
    Case #CMD_IF_NUMOFCELLS_LESS
      res = "IF_NUMOFCELLS_LESS"
    Case #CMD_IF_NUMOFCELLS_EQUAL
      res = "IF_NUMOFCELLS_EQUAL"
      
    Case #CMD_IF_CELLNUMER_GREATER
      res = "IF_CELLNUMER_GREATER"
    Case #CMD_IF_CELLNUMER_LESS
      res = "IF_CELLNUMER_LESS"
    Case #CMD_IF_CELLNUMER_EQUAL
      res = "IF_CELLNUMER_EQUAL" 
    Case #CMD_IF_MALE
      res = "IF_MALE"
    Case #CMD_IF_FEMALE
      res = "IF_FEMALE"
    Case #CMD_IF_AGE_GREATER
      res = "IF_AGE_GREATER"
    Case #CMD_IF_AGE_LESS
      res = "IF_AGE_LESS"
    Case #CMD_IF_AGE_EQUAL
      res = "IF_AGE_EQUAL" 
    Case #CMD_VARIABLE_RND 
      res = "VARIABLE_RND"         
      
    Case #CMD_MOVE_FORWARD2X
      res = "MOVE_FORWARD2X"
      
    Case #CMD_MUTATE
      res = "MUTATE"


    Case #CMD_MUTATE_LINE
      res = "MUTATE_LINE" 
      
    Case #CMD_BLOCKEXEC
      res = "BLOCKEXEC"
      
    Case #CMD_EMITTOENEMY_FOOD
      res = "EMITTOENEMY_FOOD"

    Case #CMD_EMITTOENEMY_MSG
      res = "EMITTOENEMY_MSG"
      
    Case #CMD_REPLACEMENT_CMD
      res = "REPLACEMENT_CMD"
      
    Case #CMD_REPLACE_CMD
      res = "REPLACE_CMD"

    Case #CMD_VARIABLE_GETGLOBAL
      res = "VARIABLE_GETGLOBAL"  

    Case #CMD_VARIABLE_SETGLOBAL 
      res = "VARIABLE_SETGLOBAL"
      
      
    Case #CMD_ABSORBABLE_YES     
      res = "ABSORBABLE_YES" 
      
    Case #CMD_ABSORBABLE_NO     
      res = "ABSORBABLE_NO" 
      
    Case #CMD_ABSORB_ENEMY
      res = "ABSORB_ENEMY"
      
    Case #CMD_IF_ABSORBABLE 
      res = "IF_ABSORBABLE"

    Case #CMD_EMITTOENEMY_POISON
      res = "EMITTOENEMY_POISON"     
    Case #CMD_EMITTOENEMY_DNA  
      res = "EMITTOENEMY_DNA"     
    Case #CMD_EMITTOENEMY_DNABLOCK
      res = "EMITTOENEMY_DNABLOCK"  

    Case #CMD_PROTECTDNA 
      res = "PROTECTDNA"      
             
    Case #CMD_NOP
      res = "NOP"
  EndSelect
  
  ProcedureReturn res
EndProcedure

Procedure CMDHasParameter(cmd.s)
  
  If cmd = "IF_ABSORBABLE"
    ProcedureReturn #False
  EndIf
  
  If cmd = "IF_MALE" Or cmd = "IF_FEMALE"
    ProcedureReturn #False
  EndIf
  
  If Left(cmd,3) = "IF_"
    ProcedureReturn #True
  EndIf
  
  Select cmd
    Case "POISON_EMIT", "POISON_IMMUN1","POISON_IMMUN2","POISON_IMMUN3"
      ProcedureReturn #True
    Case "POISON_VIRUS_MIN_ENERGY","POISON_EMIT_VIRUS","POISON_DNA_CODE","POISON_EMIT_DNA"
      ProcedureReturn #True
    Case "MSG_EMIT"
      ProcedureReturn #True
    Case "COPY_MIN_ENERGY"
      ProcedureReturn #True
      ;Case "GOTO","GOTO50","GOTO25","GOTO5"
      ;ProcedureReturn #True
    Case "VARIABLE_SET"  ;"VARIABLE",
      ProcedureReturn #True
    Case "SIN_CELL_RAD", "SIN_CELL_AMPRAD", "SIN_CELL_MIDRAD"
      ProcedureReturn #True      
    Case "VARIABLE_ADD","VARIABLE_SUB","VARIABLE_MUL","VARIABLE_DIV","VARIABLE_XOR", "VARIABLE_OR","VARIABLE_AND", "VARIABLE_MOD"  
      ProcedureReturn #True  
    Case "TIMER_SET"
      ProcedureReturn #True  
    Case "POISON_DNABLOCK_SIZE"
      ProcedureReturn #True      
    Case "DEST_POINT_X", "DEST_POINT_Y"
      ProcedureReturn #True
    Case "EMITTOENEMY_MSG"
      ProcedureReturn #True      
    Case "REPLACEMENT_CMD", "REPLACE_CMD"
      ProcedureReturn #True    
    Case "EMITTOENEMY_POISON", "EMITTOENEMY_DNA"
      ProcedureReturn #True
  EndSelect
  ProcedureReturn #False
EndProcedure

Procedure CMDResolveLater(cmd.s)
  Select cmd
    Case "GOTO","GOTO50","GOTO25","GOTO5"
      ProcedureReturn #True
    Case "VARIABLE"
      ProcedureReturn #True
    Case "TIMER_GOTO"
      ProcedureReturn #True
    Case "POISON_EMIT_DNABLOCK"
      ProcedureReturn #True    
    Case "VARIABLE_COPY"
      ProcedureReturn #True  
    Case "MUTATE_LINE"
      ProcedureReturn #True
    Case "BLOCKEXEC"
      ProcedureReturn #True  
    Case "EMITTOENEMY_DNABLOCK"  
      ProcedureReturn #True        
  EndSelect
  ProcedureReturn #False
EndProcedure

Procedure CodeIsExtended(code.l)
  Select code.l
    Case #CMD_IF_ENERGY_GREATER, #CMD_IF_ENERGY_LESS, #CMD_IF_ENERGY_EQUAL
      ProcedureReturn #True
    Case #CMD_IF_ENERGYINC_GREATER, #CMD_IF_ENERGYDEC_GREATER
      ProcedureReturn #True
    Case #CMD_IF_MSG_GREATER,#CMD_IF_MSG_LESS,#CMD_IF_MSG_EQUAL
      ProcedureReturn #True
      
    Case #CMD_IF_FOOD_GREATER,#CMD_IF_FOOD_LESS,#CMD_IF_FOOD_EQUAL
      ProcedureReturn #True
      
    Case #CMD_IF_POISON_GREATER,#CMD_IF_POISON_LESS,#CMD_IF_POISON_EQUAL
      ProcedureReturn #True
      
    Case #CMD_IF_POISONID_GREATER,#CMD_IF_POISONID_LESS,#CMD_IF_POISONID_EQUAL
      ProcedureReturn #True
      
    Case #CMD_IF_DNA_GREATER,#CMD_IF_DNA_LESS,#CMD_IF_DNA_EQUAL
      ProcedureReturn #True
      
    Case #CMD_IF_VARIABLE_GREATER,#CMD_IF_VARIABLE_LESS,#CMD_IF_VARIABLE_EQUAL
      ProcedureReturn #True
      
    Case #CMD_IF_CELL_RAD_GREATER, #CMD_IF_CELL_RAD_LESS,#CMD_IF_CELL_RAD_EQUAL
      ProcedureReturn #True
      
    Case #CMD_POISON_EMIT, #CMD_POISON_IMMUN1,#CMD_POISON_IMMUN2,#CMD_POISON_IMMUN3
      ProcedureReturn #True
    Case #CMD_POISON_VIRUS_MIN_ENERGY,#CMD_POISON_EMIT_VIRUS,#CMD_POISON_DNA_CODE,#CMD_POISON_EMIT_DNA
      ProcedureReturn #True
    Case #CMD_MSG_EMIT
      ProcedureReturn #True
    Case #CMD_COPY_MIN_ENERGY
      ProcedureReturn #True 
    Case #CMD_VARIABLE_SET, #CMD_VARIABLE
      ProcedureReturn #True  
      
    Case #CMD_VARIABLE_ADD,#CMD_VARIABLE_SUB,#CMD_VARIABLE_MUL,#CMD_VARIABLE_DIV,#CMD_VARIABLE_XOR, #CMD_VARIABLE_OR,#CMD_VARIABLE_AND, #CMD_VARIABLE_MOD  
      ProcedureReturn #True  
      
      ProcedureReturn #True
    Case #CMD_GOTO,#CMD_GOTO50,#CMD_GOTO25,#CMD_GOTO5
      ProcedureReturn #True
    Case #CMD_SIN_CELL_MIDRAD, #CMD_SIN_CELL_AMPRAD, #CMD_SIN_CELL_RAD
      ProcedureReturn #True  
    Case #CMD_TIMER_SET, #CMD_TIMER_GOTO
      ProcedureReturn #True
    Case #CMD_POISON_EMIT_DNABLOCK, #CMD_POISON_DNABLOCK_SIZE
      ProcedureReturn #True      
    Case #CMD_IF_X_GREATER, #CMD_IF_X_LESS, #CMD_IF_X_EQUAL
      ProcedureReturn #True 
    Case #CMD_IF_Y_GREATER, #CMD_IF_Y_LESS, #CMD_IF_Y_EQUAL
      ProcedureReturn #True 
    Case #CMD_IF_ENEMYABS_GREATER, #CMD_IF_ENEMYABS_LESS, #CMD_IF_ENEMYABS_EQUAL
      ProcedureReturn #True 
;    Case #CMD_ROTATE_ENEMY, #CMD_ROTATE_ANTI_ENEMY
;      ProcedureReturn #True     
    Case #CMD_IF_CMP_ENEMY_GREATER, #CMD_IF_CMP_ENEMY_LESS ,#CMD_IF_CMP_ENEMY_EQUAL, #CMD_DEST_POINT_X, #CMD_DEST_POINT_Y   
      ProcedureReturn #True 
      
    Case #CMD_IF_GENERATION_GREATER, #CMD_IF_GENERATION_LESS, #CMD_IF_GENERATION_EQUAL 
      ProcedureReturn #True     
    Case #CMD_IF_NUMOFCELLS_GREATER, #CMD_IF_NUMOFCELLS_LESS, #CMD_IF_NUMOFCELLS_EQUAL
      ProcedureReturn #True 
    Case #CMD_IF_CELLNUMER_GREATER, #CMD_IF_CELLNUMER_LESS, #CMD_IF_CELLNUMER_EQUAL 
      ProcedureReturn #True 
    Case #CMD_IF_AGE_GREATER, #CMD_IF_AGE_LESS, #CMD_IF_AGE_EQUAL
      ProcedureReturn #True 
    Case #CMD_MUTATE_LINE
      ProcedureReturn #True
    Case #CMD_BLOCKEXEC
      ProcedureReturn #True
    Case #CMD_EMITTOENEMY_MSG
      ProcedureReturn #True
    Case #CMD_REPLACEMENT_CMD, #CMD_REPLACE_CMD
      ProcedureReturn #True
    Case #CMD_EMITTOENEMY_POISON, #CMD_EMITTOENEMY_DNA, #CMD_EMITTOENEMY_DNABLOCK                          
            
  EndSelect
  
EndProcedure


Procedure.s RemoveComment(cmd.s)
  commentPos = FindString(cmd, ";", 1)
  If commentPos:cmd = Left(cmd, commentPos - 1):EndIf
  
  commentPos = FindString(cmd, "//", 1)
  If commentPos:cmd = Left(cmd, commentPos - 1):EndIf
  
  commentPos = FindString(cmd, "'", 1)
  If commentPos:cmd = Left(cmd, commentPos - 1):EndIf
  ProcedureReturn Trim(cmd)
EndProcedure

Procedure Compile_Creature(code.s, *CodePtr)
  Count_JMPPoints=0
  Count_JMPCommands=0
  
  Dim JMPPoints.JMP_Point($FFFF)
  Dim JMPCommands.JMP_Point($FFFF)
  
  ;Debug "Start Compiling Code"
  
  Dim PCode.l(#CODE_SIZE)
  
  For i = 0 To #CODE_SIZE-1
    PCode(i) = #CMD_PAUSE
  Next
  
  code.s = ReplaceString(code, #LF$, #CR$)
  code.s = ReplaceString(code, #CR$ + #CR$, #CR$) 
  
  code.s + #CR$ + "RETURN" + #CR$
  
  For Lines = 1 To CountString(code, #CR$)
    Line.s = RemoveComment(Trim(UCase(StringField(code, Lines, #CR$))))
    ;Debug "Line: "+Line
    Repeat
      Line = ReplaceString(Line,"  "," ")
    Until FindString(Line, "  ",1) = 0
    
    If CodePos < #CODE_SIZE
      
      cmd.s = Line.s
     
        
      Param.s = ""
      Pos = FindString(cmd.s, " ", 1)
      If Pos
        cmd = UCase(Left(cmd, Pos - 1))
        Param = Right(Line, Len(Line) - Pos) 
      EndIf
      
      ;Debug "Input Command:"+CMD + " Paramter: "+ Param
      
      If Left(cmd,1) = "@"
        JMPPoints(Count_JMPPoints)\Name = cmd
        JMPPoints(Count_JMPPoints)\Position = CodePos
        Count_JMPPoints +1
      EndIf
      
      PCode.l = CMDStringToCode(cmd)
      
      If PCode <> -1
        
        If CMDResolveLater(cmd)
          ;Debug "Add Code:" + CMD + " Parm:" + Param   
          JMPCommands(Count_JMPCommands)\Name = Param
          JMPCommands(Count_JMPCommands)\Position = CodePos
          Count_JMPCommands + 1
          PCode(CodePos) = PCode
          
        Else
          
          If CMDHasParameter(cmd)   
            ;Debug "Add Code:" + CMD + " Parm:" + Param
            PCode(CodePos) = PCode  + Val(Param)<<8
            
          Else
            ;Debug "Add Code:" + CMD + " Parm: None" 
            PCode(CodePos) = PCode
          EndIf
          
        EndIf
        CodePos +1  
        
      Else
        If cmd = "DL"
          PCode(CodePos) = Val(Param)
          CodePos +1 
        EndIf     
        
      EndIf
      
    EndIf
    
  Next
  
  For i = 0 To Count_JMPCommands-1
    
    For j = 0 To Count_JMPPoints-1
      
      If JMPPoints(j)\Name = JMPCommands(i)\Name
        
        Pos = JMPPoints(j)\Position
        
        PCode(JMPCommands(i)\Position) | (Pos<<8)
        
      EndIf
      
    Next
    
  Next
  
  CopyMemory(@PCode(0),*CodePtr, #CODE_SIZE * 4)
  ;Debug "End Compiling Code"
  
EndProcedure



Procedure.s DeCompile_Creature(*CodePtr)
  Dim HasLabel(#CODE_SIZE)
  Dim code.s(#CODE_SIZE)
  
  code.s = ""
  For i = 0 To #CODE_SIZE -1
    Value.l = PeekL(*CodePtr + i * 4)
    Param = Value >> 8
    PCode = Value & 255
    
    ;Code.s + "@LINE_"+Str(i) + #LF$ 
    cmd.s = CodeToCMDString(PCode)
    If cmd = ""
      Code(i) = "DL " + Str(Value) + #LF$ 
    Else
      
      If CMDResolveLater(cmd)
        
        If Param >=0 And Param <= #CODE_SIZE-1     
          If Param >= 0 And Param < #CODE_SIZE
            HasLabel(Param) = 1
          EndIf
          Code(i) = cmd + " " + "@LINE_"+Str(Param) + #LF$ 
        Else
          Code(i) = "DL "+ Str(Value) + #LF$
        EndIf
        
      Else
        If CMDHasParameter(cmd)
          Code(i) = cmd + " " + Str(Param) + #LF$ 
        Else
          If Value & $FFFFFF00
            Code(i) = "DL " + Str(Value) + #LF$  
          Else
            Code(i) = cmd + #LF$
          EndIf 
        EndIf
      EndIf
      
    EndIf
    
  Next
  
  For i = 0 To  #CODE_SIZE -1
    
    If HasLabel(i)
      code.s + "@LINE_"+Str(i) + #LF$
    EndIf
    code.s + Code(i)
    
  Next
  
  ProcedureReturn code.s
EndProcedure






Procedure CopyCreature(CreatureIndex, Clone)
  
  *Creature2.CREATURE = AddCreature()
  If *Creature2<>0
    CopyMemory(@Creatures(CreatureIndex), *Creature2, SizeOf(CREATURE))
    
    *Creature2\CreatureID = Random($FFFF) + Random($FFFF) << 16
    
    *Creature2\X + Random(4) - Random(4)
    *Creature2\Y + Random(4) - Random(4)    
    *Creature2\Angle = (Random(36000) * 2 * #PI) /36000 
    
    *Creature2\Age = 0
    
    If *Creature2\DisableMutation = #False
      
      CRed.l = Red(*Creature2\Color) + Random(2) - Random(2)
      CGreen.l = Green(*Creature2\Color) + Random(2) - Random(2)
      CBlue.l = Blue(*Creature2\Color) + Random(2) - Random(2)      
      *Creature2\Color = RGB(CRed, CGreen, CBlue) & $FFFFFF
      
      *Creature2\IncCreatureID +1
      
      If Random(100) <= GlobalVar\CREATURE_PROBABLE_CLONE_CHANGECELLNUMBER
        
        If Clone
          minFootprint = 999999999
          minFootprintIndex = 0
          For i=0 To *Creature2\NumCells-1
            If *Creature2\Cells[i]\EnergyFootprint < minFootprint
              minFootprint = *Creature2\Cells[i]\EnergyFootprint
              minFootprintIndex = i
            EndIf
          Next
        Else
          minFootprintIndex = Random(*Creature2\NumCells)
        EndIf
        
        If Random(100)<= 50
          *Creature2\NumCells + Random(2)
        Else
          *Creature2\NumCells - Random(2)    
        EndIf
      EndIf
      
      If *Creature2\NumCells < 2: *Creature2\NumCells = 2:EndIf
      If *Creature2\NumCells > #MAX_CELLS:*Creature2\NumCells = #MAX_CELLS:EndIf 
      
      For i=0 To *Creature2\NumCells-1
        ; ACHTUNG: KÖNNTE SICH ANDERST VERHALTEN, WENN ES DIE ZELLE BEREITS GAB!!!
        If *Creature2\Cells[i]\CellID = 0
          CopyMemory(*Creature2\Cells[minFootprintIndex], *Creature2\Cells[i], SizeOf(CELL))
        EndIf
        
        If Random(100) <= GlobalVar\CREATURE_PROBABLE_CLONE_COPYDNA
          CopyMemory(*Creature2\Cells[minFootprintIndex], *Creature2\Cells[i], SizeOf(CELL))
        EndIf
        
        *Creature2\Cells[i]\CellID = Random($FFFF) + Random($FFFF) << 16
        *Creature2\Cells[i]\EnergyFootprint = 0
        
        If Random(100) <= GlobalVar\CREATURE_PROBABLE_CLONE_CHANGESIZE
          *Creature2\Cells[i]\OrgRadius + (Random(5000)-2500)/1000
          If Random(100) <= GlobalVar\CREATURE_PROBABLE_CLONE_CHANGESIZE
            *Creature2\Cells[i]\OrgRadius + (Random(50000)-25000)/1000
          EndIf
          If *Creature2\Cells[i]\OrgRadius > GlobalVar\CREATURE_MAXRADIUS
            *Creature2\Cells[i]\OrgRadius = GlobalVar\CREATURE_MAXRADIUS
          EndIf
          If *Creature2\Cells[i]\OrgRadius < GlobalVar\CREATURE_MINRADIUS
            *Creature2\Cells[i]\OrgRadius = GlobalVar\CREATURE_MINRADIUS
          EndIf        
          
        EndIf
        
      Next 
      
    Else
      
      For i=0 To *Creature2\NumCells-1
        *Creature2\Cells[i]\CellID = Random($FFFF) + Random($FFFF) << 16
        *Creature2\Cells[i]\EnergyFootprint = 0
      Next
      
    EndIf   
    
  EndIf 
  ProcedureReturn *Creature2
EndProcedure


Procedure Combine_And_Clone_Creature(CreatureIndex1.l, CreatureIndex2.l)
  
  If Random(100)>50
    *NewCreature.CREATURE = CopyCreature(CreatureIndex1, #True)
  Else
    If Random(100)>50
      *NewCreature.CREATURE = CopyCreature(CreatureIndex1, #True)
    Else
      *NewCreature.CREATURE = CopyCreature(CreatureIndex2, #True)
    EndIf
  EndIf
  
  
  If Random(100) > 50
    *NewCreature\IsMale = #True
  Else
    *NewCreature\IsMale = #False
  EndIf
  
  
  *Creature1.CREATURE = Creatures(CreatureIndex1)
  *Creature2.CREATURE = Creatures(CreatureIndex2)
  
  minFootprint1 = 999999999
  minFootprintIndex1 = 0
  For i=0 To *Creature1\NumCells-1
    If *Creature1\Cells[i]\EnergyFootprint < minFootprint1
      minFootprint1 = *Creature1\Cells[i]\EnergyFootprint
      minFootprintIndex1 = i
    EndIf
  Next
  
  minFootprint2 = 999999999
  minFootprintIndex2 = 0
  For i=0 To *Creature2\NumCells-1
    If *Creature2\Cells[i]\EnergyFootprint < minFootprint2
      minFootprint2 = *Creature2\Cells[i]\EnergyFootprint
      minFootprintIndex2 = i
    EndIf
  Next
  
  If Random(100)> 50
    minFootprintIndex1 = Random(*Creature1\NumCells-1)
  EndIf
  
  If Random(100)> 50
    minFootprintIndex2 = Random(*Creature2\NumCells-1)
  EndIf
  
  CRed.l = (Red(*Creature1\Color) + Red(*Creature2\Color) + Red(*NewCreature\Color)) / 3
  CGreen.l = (Green(*Creature1\Color) + Green(*Creature2\Color) + Green(*NewCreature\Color)) / 3
  CBlue.l = (Blue(*Creature1\Color) + Blue(*Creature2\Color) + Blue(*NewCreature\Color)) / 3
  
  *NewCreature\Color = RGB(CRed, CGreen, CBlue)     
  *NewCreature\X = (*NewCreature\X + *Creature2\X + *Creature1\X) / 3
  *NewCreature\Y = (*NewCreature\Y + *Creature2\Y + *Creature1\Y) / 3 
  
  *NewCreature\IncCreatureID = ( *NewCreature\IncCreatureID + *Creature2\IncCreatureID + *Creature1\IncCreatureID) / 3
  
  For i=0 To *NewCreature\NumCells-1
    
    If Random(100) > 50
      
      index = i
      If Random(100) > 50
        If Random(100) <= GlobalVar\CREATURE_PROBABLE_CLONE_COPYDNA
          index = minFootprintIndex1
        EndIf
      EndIf
      
      If index < *Creature1\NumCells
        
        If Random(100) > 50
          CopyMemory(*Creature1\Cells[index], *NewCreature\Cells[i], SizeOf(CELL))   
        Else
          Pos = Random(#CODE_SIZE-1)/2
          len = Random(#CODE_SIZE-1)/2
          CopyMemory(@*Creature1\Cells[index]\DNA[Pos], @*NewCreature\Cells[i]\DNA[Pos], len * 4)
        EndIf     
        
      EndIf
      
      
    Else
      If Random(100) > 50  
        If Random(100) <= GlobalVar\CREATURE_PROBABLE_CLONE_COPYDNA
          index = minFootprintIndex2
        EndIf
      EndIf
      
      If index < *Creature2\NumCells
        
        If Random(100) > 50
          CopyMemory(*Creature2\Cells[index], *NewCreature\Cells[i], SizeOf(CELL))   
        Else
          Pos = Random(#CODE_SIZE-1)/2
          len = Random(#CODE_SIZE-1)/2
          CopyMemory(@*Creature2\Cells[index]\DNA[Pos], @*NewCreature\Cells[i]\DNA[Pos], len * 4)
        EndIf   
        
      EndIf  
      
    EndIf
    
    *NewCreature\Cells[i]\CellID = Random($FFFF) + Random($FFFF) << 16
    *NewCreature\Cells[i]\EnergyFootprint = 0  
    
  Next
  
  ProcedureReturn *NewCreature
EndProcedure


Procedure AddFood(X.f,Y.f, Value.l)
  *obj.OBJECT = AddObject()
  If *obj<>0
    *obj\Type = #OBJECT_FOOD
    *obj\CreatureID = 0
    *obj\CellID = 0
    
    *obj\Angle = Random(3600)/3600 * 2 * #PI
    *obj\Speed = Random(1000)/1000 * GlobalVar\OBJECT_FOOD_MAXSPEED
    *obj\X = X
    *obj\Y = Y
    *obj\Energy = Value
    *obj\LifeTime = -1    
  EndIf  
EndProcedure

Procedure AddRest(X.f,Y.f,LifeTime.l, Value.l)
  *obj.OBJECT = AddObject()
  If *obj<>0
    *obj\Type = #OBJECT_REST
    *obj\CreatureID = 0
    *obj\CellID = 0
    
    *obj\Angle = Random(3600)/3600 * 2 * #PI
    *obj\Speed = Random(1000)/1000 * GlobalVar\OBJECT_FOOD_MAXSPEED
    *obj\X = X
    *obj\Y = Y
    *obj\Energy = Value
    *obj\LifeTime = LifeTime
  EndIf  
EndProcedure


Procedure DrawCreature(*Creature.CREATURE, Texture = #False)
If Texture=0:Texture = Sprite\Texture_Crature23D:EndIf

  If GlobalDrawing = #True  
    If *Creature
      If GadGet\state\Creature
        CompilerIf #DrawCreature_Sprite=#False
          num.l = *Creature\NumCells
          Angle.f = *Creature\Angle
          X.f = *Creature\X
          Y.f = *Creature\Y
          
          If *Creature\NumCells > 1
            rad.f = *Creature\Cells[num-1]\Radius
            OldX.f =  X  + Cos(Angle + 2 * #PI * (num-1)/num ) * rad
            OldY.f =  Y  + Sin(Angle + 2 * #PI * (num-1)/num ) * rad
            
            For i = 0 To num-1
              v.f = 2 * #PI * (i)/(num)
              rad.f = *Creature\Cells[i]\Radius
              Px = X + Cos(v + Angle) * rad
              Py = Y + Sin(v + Angle) * rad
              
              LineXY( OldX, OldY, Px, Py, *Creature\Color)
              OldX =  Px
              OldY =  Py  
              ;Circle(px,py,rad * GlobalVar\OBJECT_CATCH_RADIUS_FACTOR, *Creature\Color)
            Next
          EndIf
          ;LineXY( OldX, OldY, X  + Sin(Angle) * rad, Y + Cos(Angle) * rad, *Creature\Color)
        CompilerElse
        
        ;Sprite3DQuality(1)
        
          num.l = *Creature\NumCells
          Angle.f = *Creature\Angle
          X.f = *Creature\X
          Y.f = *Creature\Y
          
          If *Creature\NumCells > 1
            rad.f = *Creature\Cells[num-1]\Radius
            OldX.f =  X  + Cos(Angle + 2 * #PI * (num-1)/num ) * rad
            OldY.f =  Y  + Sin(Angle + 2 * #PI * (num-1)/num ) * rad
            
            For i = 0 To num-1
              v.f = 2 * #PI * (i)/(num)
              rad.f = *Creature\Cells[i]\Radius
              Px = X + Cos(v + Angle) * rad
              Py = Y + Sin(v + Angle) * rad
              
              ;LineXY( OldX, OldY, Px, Py, *Creature\Color)
              
              Zoom = *Creature\Cells[i]\Radius
              
              ;TransformSprite3D(Sprite\Texture_Crature23D, X * facX, Y * facY   , OldX * facX, OldY * facY, Px * facX, Py * facY  , Px * facX, Py * facY)  
          
               TransformSprite3D(Texture,X, Y  , OldX, OldY, Px, Py, Px, Py)  
               DisplaySprite3D(Texture,0,0,128)  

               TransformSprite3D(Texture,X + 1, Y  , OldX, OldY, Px, Py, Px, Py)
               DisplaySprite3D(Texture,0,-1,128)  

               TransformSprite3D(Texture,X, Y - 1  , OldX, OldY, Px, Py, Px, Py)
               DisplaySprite3D(Texture,1,0,128) 
 
               TransformSprite3D(Texture,X, Y + 1  , OldX, OldY, Px, Py, Px, Py)
               DisplaySprite3D(Texture,-1,0,128) 
       
               TransformSprite3D(Texture,X - 1, Y  , OldX, OldY, Px, Py, Px, Py)         
               DisplaySprite3D(Texture,0,1,128) 
  
               ;TransformSprite3D(Sprite\Texture_Crature23D, X, Y   , OldX  , Px , Px, Py , Py, OldY)  
                     
              ;ZoomSprite3D(Sprite\Texture_Crature23D,Zoom,Zoom)
              
              ;DisplaySprite3D(Sprite\Texture_Crature23D,0,0,128)   
              ;DisplaySprite3D(Sprite\Texture_Crature23D,0,1,128)
              ;DisplaySprite3D(Sprite\Texture_Crature23D,1,0,128)
              ;DisplaySprite3D(Sprite\Texture_Crature23D,0,-1,128)
              ;DisplaySprite3D(Sprite\Texture_Crature23D,-1,0,128)
                         
              ;DisplaySprite3D(Sprite\Texture_Crature23D,-1,0,200)
              ;DisplaySprite3D(Sprite\Texture_Crature23D,0,-1,200)
              
              OldX =  Px
              OldY =  Py  
              ;Circle(px,py,rad * GlobalVar\OBJECT_CATCH_RADIUS_FACTOR, *Creature\Color)
            Next
          EndIf
          
          
          
          
        CompilerEndIf
        
        
      EndIf   
    EndIf
  EndIf  
EndProcedure

Structure Pre_Radius
  Radius.f[#MAX_CELLS]
EndStructure


Procedure DrawCreature_Preview(X,Y,Angle,num,*pre_rad.Pre_Radius,Color)
  If num>0
    rad.f = *pre_rad\Radius[num-1]
    OldX.f =  X  + Cos(Angle + 2 * #PI * (num-1)/num ) * rad
    OldY.f =  Y  + Sin(Angle + 2 * #PI * (num-1)/num ) * rad
    
    For i = 0 To num-1
      v.f = 2 * #PI * (i)/(num)
      rad.f = *pre_rad\Radius[i]
      Px = X + Cos(v + Angle) * rad
      Py = Y + Sin(v + Angle) * rad
      
      LineXY( OldX, OldY, Px, Py, Color)
      OldX =  Px
      OldY =  Py  
      
    Next
  EndIf
EndProcedure


Procedure OptimizeMutation(code.l)  
  PCode.l = code.l & 255
  
  Param = 0
  Select PCode
    
    Case #CMD_MSG_EMIT
      Param = Random(64)
    
    Case #CMD_POISON_EMIT, #CMD_POISON_IMMUN1, #CMD_POISON_IMMUN2,#CMD_POISON_IMMUN3
      Param = Random($FF)
      
    Case #CMD_POISON_VIRUS_MIN_ENERGY, #CMD_COPY_MIN_ENERGY, #CMD_IF_ENERGY_GREATER, #CMD_IF_ENERGY_LESS, #CMD_IF_ENERGY_EQUAL
      Param = Random(100000)
      
    Case #CMD_POISON_DNA_CODE
      Param = Random(#CMD_NOP) + Random(50000)<<8
      
    Case #CMD_POISON_EMIT_VIRUS, #CMD_POISON_EMIT_DNA, #CMD_POISON_EMIT_DNABLOCK 
      Param = Random(#CODE_SIZE)
      
    Case #CMD_GOTO, #CMD_GOTO50, #CMD_GOTO25, #CMD_GOTO5
      Param = Random(#CODE_SIZE)  
      
    Case #CMD_POISON_DNABLOCK_SIZE  
      Param = Random(5)
      
    Case #CMD_SIN_CELL_AMPRAD,#CMD_SIN_CELL_MIDRAD, #CMD_SIN_CELL_RAD
      Param = Random(40)
      
      
    Case #CMD_IF_ENERGYINC_GREATER, #CMD_IF_ENERGYDEC_GREATER
      Param = Random(5000)
      
    Case #CMD_IF_MSG_GREATER, #CMD_IF_MSG_LESS, #CMD_IF_MSG_EQUAL
      Param = Random($FF)
      
    Case #CMD_IF_FOOD_GREATER, #CMD_IF_FOOD_LESS, #CMD_IF_FOOD_EQUAL
      Param = Random(100)
      
    Case #CMD_IF_POISON_GREATER, #CMD_IF_POISON_LESS, #CMD_IF_POISON_EQUAL
      Param = Random(100)
      
    Case #CMD_IF_POISONID_GREATER, #CMD_IF_POISONID_LESS, #CMD_IF_POISONID_EQUAL
      Param = Random($FF)
      
    Case #CMD_IF_DNA_GREATER, #CMD_IF_DNA_LESS, #CMD_IF_DNA_EQUAL
      Param = Random(100)
      
    Case #CMD_IF_VARIABLE_GREATER, #CMD_IF_VARIABLE_LESS, #CMD_IF_VARIABLE_EQUAL, #CMD_VARIABLE_SET, #CMD_VARIABLE_ADD, #CMD_VARIABLE_SUB, #CMD_VARIABLE_MUL, #CMD_VARIABLE_DIV, #CMD_VARIABLE_XOR,#CMD_VARIABLE_OR, #CMD_VARIABLE_AND, #CMD_VARIABLE_MOD
      If Random(100) > 50
        Param = Random($FFFFFF)
      Else
        Param = Random(1000)
      EndIf
      
    Case #CMD_IF_CELL_RAD_GREATER, #CMD_IF_CELL_RAD_LESS, #CMD_IF_CELL_RAD_EQUAL
      Param = Random(60)
      
    Case #CMD_VARIABLE, #CMD_TIMER_SET, #CMD_TIMER_GOTO
      Param = Random(#CODE_SIZE)
      
    Case #CMD_IF_X_GREATER, #CMD_IF_X_LESS, #CMD_IF_X_EQUAL
      Param = Random(#AREA_WIDTH)
      
    Case #CMD_IF_Y_GREATER, #CMD_IF_Y_LESS, #CMD_IF_Y_EQUAL
      Param = Random(#AREA_HEIGHT)
      
    Case #CMD_IF_ENEMYABS_GREATER, #CMD_IF_ENEMYABS_LESS, #CMD_IF_ENEMYABS_EQUAL     
      Param = Random(Sqr(#AREA_WIDTH * #AREA_WIDTH + #AREA_HEIGHT * #AREA_HEIGHT))
      
    Case #CMD_IF_CMP_ENEMY_GREATER, #CMD_IF_CMP_ENEMY_LESS, #CMD_IF_CMP_ENEMY_EQUAL
      Param = Random(100000)
      
    Case #CMD_DEST_POINT_X
      Param = Random(#AREA_WIDTH)
      
    Case #CMD_DEST_POINT_Y
      Param = Random(#AREA_HEIGHT)
      
      
    Case #CMD_VARIABLE_COPY
      Param = Random(#CODE_SIZE)
      
    Case #CMD_IF_GENERATION_GREATER, #CMD_IF_GENERATION_LESS, #CMD_IF_GENERATION_EQUAL
      Param = Random($FFFFFF)
      
    Case #CMD_IF_NUMOFCELLS_GREATER, #CMD_IF_NUMOFCELLS_LESS, #CMD_IF_NUMOFCELLS_EQUAL, #CMD_IF_CELLNUMER_GREATER,  #CMD_IF_CELLNUMER_LESS, #CMD_IF_CELLNUMER_EQUAL  
      Param = Random(#MAX_CELLS)
      
    Case #CMD_IF_AGE_GREATER, #CMD_IF_AGE_LESS, #CMD_IF_AGE_EQUAL  
      Param = Random(100000)
         
    Case #CMD_MUTATE_LINE
      Param = Random(#CODE_SIZE)   
      
    Case #CMD_BLOCKEXEC
      Param = Random(#CODE_SIZE)   
    
    Case #CMD_EMITTOENEMY_MSG
      Param = Random(64)
    
    Case #CMD_REPLACEMENT_CMD
      If Random(100) > 50
        Param = Random(#CMD_NOP)
      Else
        Param = Random(#CMD_NOP) + Random(10000) << 8      
      EndIf
    
    Case #CMD_REPLACE_CMD
      Param = Random(#CMD_NOP)     
      
    Case #CMD_EMITTOENEMY_POISON
      Param = Random($FF)

    Case #CMD_EMITTOENEMY_DNA
      Param = Random(#CMD_NOP) + Random(50000)<<8
     
    Case #CMD_EMITTOENEMY_DNABLOCK
      Param = Random(#CODE_SIZE)
                 
  EndSelect
  
  ProcedureReturn PCode + Param <<8
EndProcedure



Macro ExecDebug(Str)
  CompilerIf #DEBUG_EXEC
    ;Debug Str
  CompilerEndIf
EndMacro

Procedure ExecuteCell(CreatureIndex.l, CellIndex.l)
  
  *Creature.CREATURE = Creatures(CreatureIndex) 
  
  *Cell.CELL = *Creature\Cells[CellIndex]
  
  If *Cell\Radius < *Cell\OrgRadius
    *Cell\Radius + GlobalVar\CREATURE_GROWTH
  EndIf
  
  
  num.l = *Creature\NumCells
  Angle.f = *Creature\Angle
  rad.f = *Creature\Cells[CellIndex]\Radius
  
  CreatureID.l = *Creature\CreatureID
  CellID.l = *Creature\Cells[CellIndex]\CellID
  
  v.f = 2 * #PI * CellIndex/(num)
  X.f = *Creature\X + Cos(v + Angle) * rad
  Y.f = *Creature\Y + Sin(v + Angle) * rad
  
  ;Area.f = #PI * rad * rad
  If Random(100) <= GlobalVar\OBJECT_CATCH_PROPABILITY
    ; Object einfangen  
    
    For i =0 To Objects_Count-1
      
      *Object.OBJECT = Objects(i)
      
      If *Object\Used
        
        If *Object\CreatureID <> CreatureID ; Das Objekt darf nicht von dieser Kreatur erstellt worden sein
          If *Object\CellID <> CellID ; Das Objekt darf nicht von dieser Zelle erstellt worden sein
            
            ObjX.f = *Object\X
            ObjY.f = *Object\Y   
            Abs.f = Sqr( (X - ObjX) * (X - ObjX) + (Y - ObjY) * (Y - ObjY))
            If Abs <= rad * GlobalVar\OBJECT_CATCH_RADIUS_FACTOR
              
              
              
              Type = *Object\Type
              If Type = #OBJECT_FOOD ; Futter
                
                
                If *Creature\Cells[CellIndex]\DoEating 
                  ;;Debug "EAT..."
                  *Creature\OrgEnergy + *Object\Energy
                  
                  *Cell\EnergyFootprint + *Object\Energy
                  
                  *Creature\Energy + *Object\Energy
                  *Creature\Cells[CellIndex]\FoodDirection = *Object\Angle + #PI
                  *Creature\Cells[CellIndex]\FoodCount +1 
                  ;*Creature\Cells[CellIndex]\Runtime_FoodFound +1                    
                  *Object\Used= #False     
                EndIf
              EndIf                
              
              If Type = #OBJECT_VIRUS ; Virus Injektion
                
                If *Creature\Cells[CellIndex]\ProtectVirusCount <= 0              
                  If *Object\DNAPosition < #CODE_SIZE - 2 And *Object\DNAPosition >= 0
                    *Creature\Cells[CellIndex]\DNA[*Object\DNAPosition +0] = #CMD_POISON_VIRUS_MIN_ENERGY + *Object\MinEnergy << 8
                    *Creature\Cells[CellIndex]\DNA[*Object\DNAPosition +1] = #CMD_POISON_EMIT_VIRUS + *Object\DNAPosition << 8
                    *Creature\Cells[CellIndex]\DNADirection = *Object\Angle + #PI
                    *Creature\Cells[CellIndex]\DNACount +1 
                  EndIf
                Else
                  *Creature\Cells[CellIndex]\ProtectVirusCount -1
                  If *Creature\Cells[CellIndex]\ProtectVirusCount > GlobalVar\CREATURE_PROTECTVIRUS_COUNT:*Creature\Cells[CellIndex]\ProtectVirusCount = GlobalVar\CREATURE_PROTECTVIRUS_COUNT:EndIf                            
                EndIf
                
                *Object\Used= #False    
              EndIf    
              
              
              If Type = #OBJECT_DNA ; DNA Injektion
                
                If *Creature\MagicCreature <> 'XDNA' ; 2008-11-22
                
                  If *Cell\ProtectDNACount < 0 :*Cell\ProtectDNACount = 0:EndIf                 
                  If *Cell\ProtectDNACount = 0
                    If *Object\IsDNABlock
                      If *Object\DNAPosition < #CODE_SIZE - 1 And *Object\DNAPosition >= 0
                        If *Object\DNAPosition + *Object\DNABlockSize < #CODE_SIZE - 1
                          CopyMemory(@*Object\DNABlock[0], @*Creature\Cells[CellIndex]\DNA[*Object\DNAPosition +0], 4 * *Object\DNABlockSize)
                          *Creature\Cells[CellIndex]\DNADirection = *Object\Angle + #PI
                        EndIf
                      EndIf                 
                      
                    Else
                      
                      If *Object\DNAPosition < #CODE_SIZE - 1 And *Object\DNAPosition >= 0
                        *Creature\Cells[CellIndex]\DNA[*Object\DNAPosition +0] = *Object\DNACode
                        *Creature\Cells[CellIndex]\DNADirection = *Object\Angle + #PI
                      EndIf 
                    EndIf
                  
                  Else
                    *Cell\ProtectDNACount - 1
                  EndIf          
                  

                  
                EndIf
                
                *Object\Used= #False      
              EndIf  
              
              
              If Type = #OBJECT_POISON ; Gift
                
                PoisonID = *Object\PoisonID & 255
                If PoisonID = *Creature\Cells[CellIndex]\PoisonImmun[0] & 255 Or PoisonID = *Creature\Cells[CellIndex]\PoisonImmun[1] & 255 Or PoisonID = *Creature\Cells[CellIndex]\PoisonImmun[2] & 255
                  ; Is Immun
                  ;*Creature\Cells[CellIndex]\Runtime_BlockedPoison +1
                Else
                  ; Gift wirkt
                  
                  If *Object\PoisonID & 1
                    *Creature\Energy - GlobalVar\OBJECT_POISON_ENERGY_ENEMY_DECREASE 
                    *Cell\EnergyFootprint - GlobalVar\OBJECT_POISON_ENERGY_ENEMY_DECREASE 
                    
                  Else
                    If *Cell\DoNotExecCount < 0 : *Cell\DoNotExecCount = 0:EndIf 
                    *Cell\DoNotExecCount + GlobalVar\OBJECT_POISON_PARALYSE_PAUSE
                  EndIf
                  
                  *Creature\Cells[CellIndex]\Poision = *Object\PoisonID
                  *Creature\Cells[CellIndex]\PoisonDirection = *Object\Angle + #PI
                  *Creature\Cells[CellIndex]\PoisonCount +1                      
                  
                EndIf                                  
                *Object\Used = #False   
              EndIf  
              
              
              If Type = #OBJECT_MSG ; DNA Injektion    
                *Creature\Cells[CellIndex]\msg = *Object\MessageID
                *Creature\Cells[CellIndex]\MsgDirection = *Object\Angle + #PI         
                *Object\Used = #False      
              EndIf  
              
              
              
              
            EndIf
          EndIf
        EndIf
        
      EndIf
    Next
    
  EndIf
  
  *Cell.CELL = *Creature\Cells[CellIndex]   
  
  If *Cell\DoNotExecCount <= 0
    
    If *Cell\CodePosition <0:*Cell\CodePosition = 0:EndIf
    If *Cell\CodePosition>= #CODE_SIZE:*Cell\CodePosition = 0:EndIf
    
    
    MutPos.l = ~*Cell\MutateCodePos
    If *Cell\CodePosition = MutPos.l
      If MutPos.l >= 0 And MutPos.l<= #CODE_SIZE - 1
        *Cell\DNA[MutPos] = OptimizeMutation(Random(#CMD_NOP))
      EndIf
    EndIf
    
    
    Value = *Cell\DNA[*Cell\CodePosition]
       
    BlockExecPos.l = ~*Cell\BlockCodePos
    If *Cell\CodePosition = BlockExecPos.l
      If BlockExecPos.l >= 0 And BlockExecPos.l<= #CODE_SIZE - 1
        Value = *Cell\Replacement_CMD
      EndIf
    EndIf
    
    
    Param = Value >> 8
    PCode = Value & 255
    
    If PCode = #CMD_ENDIF
      ExecDebug("Exec: ENDIF")
      *Cell\Condition = #False
      *Cell\InCondition = #False
    EndIf
    
    If *Cell\TimerStarted
      *Cell\TimerCount-1
      If *Cell\TimerCount <= 0
        *Cell\TimerStarted = #False
        *Cell\TimerCount = 0
        If *Cell\TimerGoto >=0 And *Cell\TimerGoto < #CODE_SIZE
          *Cell\CodePosition = *Cell\TimerGoto
          PCode = #CMD_NOP
        EndIf       
      EndIf 
    EndIf
    
    If *Cell\InCondition = #False Or (*Cell\Condition = #True And *Cell\InCondition = #True)
      
      Select PCode
          
        Case #CMD_IF_ENERGY_GREATER
          *Cell\Condition = #False
          If *Creature\Energy > Param:*Cell\Condition = #True: EndIf
          *Cell\InCondition = #True
        Case #CMD_IF_ENERGY_LESS
          *Cell\Condition = #False
          If *Creature\Energy < Param:*Cell\Condition = #True: EndIf
          *Cell\InCondition = #True
        Case #CMD_IF_ENERGY_EQUAL
          *Cell\Condition = #False
          If *Creature\Energy = Param:*Cell\Condition = #True: EndIf
          *Cell\InCondition = #True
          
        Case #CMD_IF_ENERGYINC_GREATER
          *Cell\Condition = #False
          If *Creature\Energy - *Cell\LastEnergy > Param:*Cell\Condition = #True: EndIf
          *Cell\LastEnergy = *Creature\Energy
          *Cell\InCondition = #True
        Case #CMD_IF_ENERGYDEC_GREATER
          *Cell\Condition = #False
          If -(*Creature\Energy - *Cell\LastEnergy) > Param:*Cell\Condition = #True: EndIf
          *Cell\LastEnergy = *Creature\Energy
          *Cell\InCondition = #True
          
        Case #CMD_IF_MSG_GREATER
          *Cell\Condition = #False
          If *Cell\msg > Param:*Cell\Condition = #True: EndIf
          *Cell\InCondition = #True
          *Cell\msg = 0
        Case #CMD_IF_MSG_LESS
          *Cell\Condition = #False
          If *Cell\msg < Param:*Cell\Condition = #True: EndIf
          *Cell\InCondition = #True
          *Cell\msg = 0
        Case #CMD_IF_MSG_EQUAL
          *Cell\Condition = #False
          If *Cell\msg = Param:*Cell\Condition = #True: EndIf
          *Cell\InCondition = #True
          *Cell\msg = 0
          
        Case #CMD_IF_FOOD_GREATER
          *Cell\Condition = #False
          If *Cell\FoodCount > Param:*Cell\Condition = #True: EndIf
          *Cell\FoodCount = 0
          *Cell\InCondition = #True
        Case #CMD_IF_FOOD_LESS
          *Cell\Condition = #False
          If *Cell\FoodCount < Param:*Cell\Condition = #True: EndIf
          *Cell\FoodCount = 0
          *Cell\InCondition = #True
        Case #CMD_IF_FOOD_EQUAL
          *Cell\Condition = #False
          If *Cell\FoodCount = Param:*Cell\Condition = #True: EndIf
          *Cell\FoodCount = 0
          *Cell\InCondition = #True
          
        Case #CMD_IF_POISON_GREATER
          *Cell\Condition = #False
          If *Cell\PoisonCount > Param:*Cell\Condition = #True: EndIf
          *Cell\PoisonCount = 0
          *Cell\InCondition = #True
        Case #CMD_IF_POISON_LESS
          *Cell\Condition = #False
          If *Cell\PoisonCount < Param:*Cell\Condition = #True: EndIf
          *Cell\PoisonCount = 0
          *Cell\InCondition = #True
        Case #CMD_IF_POISON_EQUAL
          *Cell\Condition = #False
          If *Cell\PoisonCount = Param:*Cell\Condition = #True: EndIf
          *Cell\PoisonCount = 0
          *Cell\InCondition = #True
          
        Case #CMD_IF_POISONID_GREATER
          *Cell\Condition = #False
          If *Cell\Poision > Param:*Cell\Condition = #True: EndIf
          *Cell\InCondition = #True
          *Cell\Poision = 0
        Case #CMD_IF_POISONID_LESS
          *Cell\Condition = #False
          If *Cell\Poision < Param:*Cell\Condition = #True: EndIf
          *Cell\InCondition = #True
          *Cell\Poision = 0
        Case #CMD_IF_POISONID_EQUAL
          *Cell\Condition = #False
          If *Cell\Poision = Param:*Cell\Condition = #True: EndIf
          *Cell\InCondition = #True
          *Cell\Poision = 0
          
        Case #CMD_IF_DNA_GREATER
          *Cell\Condition = #False
          If *Cell\DNACount > Param:*Cell\Condition = #True: EndIf
          *Cell\DNACount = 0
          *Cell\InCondition = #True      
        Case #CMD_IF_DNA_LESS
          *Cell\Condition = #False
          If *Cell\DNACount < Param:*Cell\Condition = #True: EndIf
          *Cell\DNACount = 0
          *Cell\InCondition = #True
        Case #CMD_IF_DNA_EQUAL
          *Cell\Condition = #False
          If *Cell\DNACount = Param:*Cell\Condition = #True: EndIf
          *Cell\DNACount = 0
          *Cell\InCondition = #True
          
        Case #CMD_IF_VARIABLE_GREATER
          *Cell\Condition = #False
          If *Cell\CodeVariable >= 0 And *Cell\CodeVariable <=#CODE_SIZE-1
            If *Cell\DNA[*Cell\CodeVariable] > Param:*Cell\Condition = #True: EndIf
          EndIf
          *Cell\InCondition = #True
        Case #CMD_IF_VARIABLE_LESS
          *Cell\Condition = #False
          If *Cell\CodeVariable >= 0 And *Cell\CodeVariable <=#CODE_SIZE-1
            If *Cell\DNA[*Cell\CodeVariable] < Param:*Cell\Condition = #True: EndIf
          EndIf
          *Cell\InCondition = #True
        Case #CMD_IF_VARIABLE_EQUAL
          *Cell\Condition = #False
          If *Cell\CodeVariable >= 0 And *Cell\CodeVariable <=#CODE_SIZE-1
            If *Cell\DNA[*Cell\CodeVariable] = Param:*Cell\Condition = #True: EndIf
          EndIf
          *Cell\InCondition = #True
          
        Case #CMD_IF_CELL_RAD_GREATER
          *Cell\Condition = #False
          If *Cell\Radius > Param:*Cell\Condition = #True: EndIf
          *Cell\InCondition = #True
        Case #CMD_IF_CELL_RAD_LESS
          *Cell\Condition = #False
          If *Cell\Radius < Param:*Cell\Condition = #True: EndIf
          *Cell\InCondition = #True
        Case #CMD_IF_CELL_RAD_EQUAL
          *Cell\Condition = #False
          If *Cell\Radius = Param:*Cell\Condition = #True: EndIf
          *Cell\InCondition = #True
          
        Case #CMD_MOVE_FORWARD
          ExecDebug("Exec:MOVE_FORWARD")
          *Creature\X + Sin(*Creature\Angle) * GlobalVar\CREATURE_MOVESPEED + (Random(1000)-500)/500 * GlobalVar\CREATURE_RANDOMMOVE
          *Creature\Y + Cos(*Creature\Angle) * GlobalVar\CREATURE_MOVESPEED + (Random(1000)-500)/500 * GlobalVar\CREATURE_RANDOMMOVE
          *Creature\Energy - GlobalVar\CREATURE_MOVE_ENERGY_DECREASE
          *Cell\EnergyFootprint - GlobalVar\CREATURE_MOVE_ENERGY_DECREASE
          
        Case #CMD_MOVE_BACKWARD
          ExecDebug("Exec:MOVE_BACKWARD")
          *Creature\X - Sin(*Creature\Angle) * GlobalVar\CREATURE_MOVESPEED + (Random(1000)-500)/500 * GlobalVar\CREATURE_RANDOMMOVE
          *Creature\Y - Cos(*Creature\Angle) * GlobalVar\CREATURE_MOVESPEED + (Random(1000)-500)/500 * GlobalVar\CREATURE_RANDOMMOVE
          *Creature\Energy - GlobalVar\CREATURE_MOVE_ENERGY_DECREASE
          *Cell\EnergyFootprint - GlobalVar\CREATURE_MOVE_ENERGY_DECREASE
          
        Case #CMD_MOVE_FORWARD2X
          ExecDebug("Exec:MOVE_FORWARD2X")
          *Creature\X + Sin(*Creature\Angle) * GlobalVar\CREATURE_MOVESPEED * 2+ (Random(1000)-500)/500 * GlobalVar\CREATURE_RANDOMMOVE
          *Creature\Y + Cos(*Creature\Angle) * GlobalVar\CREATURE_MOVESPEED * 2+ (Random(1000)-500)/500 * GlobalVar\CREATURE_RANDOMMOVE
          *Creature\Energy - GlobalVar\CREATURE_MOVE_ENERGY_DECREASE * 2
          *Cell\EnergyFootprint - GlobalVar\CREATURE_MOVE_ENERGY_DECREASE * 2         
          
        Case #CMD_EATING_YES
          *Cell\DoEating = #True
          
        Case #CMD_EATING_NO
          *Cell\DoEating = #False
          
        Case #CMD_EATING_EMIT
          If *Creature\Energy > GlobalVar\OBJECT_FOOD_DEFAULT_SIZE And *Creature\OrgEnergy > GlobalVar\OBJECT_FOOD_DEFAULT_SIZE
            *obj.OBJECT = AddObject()
            If *obj<>0
              *Creature\Energy - GlobalVar\OBJECT_FOOD_DEFAULT_SIZE
              *Creature\OrgEnergy - GlobalVar\OBJECT_FOOD_DEFAULT_SIZE
              *Cell\EnergyFootprint - GlobalVar\OBJECT_FOOD_DEFAULT_SIZE
              *obj\Type = #OBJECT_REST ;FOOD
              *obj\CreatureID = 0
              *obj\CellID = 0
              *obj\Angle = Random(3600)/3600 * 2 * #PI
              *obj\Speed = Random(1000)/1000 * GlobalVar\OBJECT_FOOD_MAXSPEED
              *obj\X = X
              *obj\Y = Y
              *obj\Energy = GlobalVar\OBJECT_FOOD_DEFAULT_SIZE
              *obj\LifeTime = Random(GlobalVar\OBJECT_REST_MAXLIFETIME)    
            EndIf  
          EndIf
          
          
        Case #CMD_POISON_EMIT
          
          If *Cell\DoPoison
            If *Creature\Energy > GlobalVar\OBJECT_POISON_ENERGY_DECREASE
              *obj.OBJECT = AddObject()
              If *obj<>0
                *Creature\Energy - GlobalVar\OBJECT_POISON_ENERGY_DECREASE
                *Cell\EnergyFootprint - GlobalVar\OBJECT_POISON_ENERGY_DECREASE
                *obj\Type = #OBJECT_POISON
                *obj\CreatureID = *Creature\CreatureID
                *obj\CellID = *Cell\CellID
                *obj\Angle = Random(3600)/3600 * 2 * #PI
                *obj\Speed = Random(1000)/1000 * GlobalVar\OBJECT_POISON_MAXSPEED
                *obj\X = X
                *obj\Y = Y
                *obj\PoisonID = Param 
                *obj\LifeTime = GlobalVar\OBJECT_POISON_LIFETIME    
              EndIf  
            EndIf
          EndIf
          
        Case #CMD_POISON_IMMUN1
          *Cell\PoisonImmun[0] = Param
        Case #CMD_POISON_IMMUN2
          *Cell\PoisonImmun[1] = Param
        Case #CMD_POISON_IMMUN3
          *Cell\PoisonImmun[2] = Param
        Case #CMD_POISON_YES
          *Cell\DoPoison = #True
        Case #CMD_POISON_NO
          *Cell\DoPoison = #False
          
        Case #CMD_POISON_VIRUS_MIN_ENERGY
          *Cell\VirusMinEnergy = Param
        Case #CMD_POISON_EMIT_VIRUS
          
          If Random(100) < GlobalVar\OBJECT_VIRUS_PROPABILITY
            If *Creature\Energy > GlobalVar\OBJECT_VIRUS_ENERGY_DECREASE
              *obj.OBJECT = AddObject()
              If *obj<>0
                *Creature\Energy - GlobalVar\OBJECT_VIRUS_ENERGY_DECREASE
                *Cell\EnergyFootprint - GlobalVar\OBJECT_VIRUS_ENERGY_DECREASE
                *obj\Type = #OBJECT_VIRUS
                *obj\CreatureID = 0
                *obj\CellID = *Cell\CellID
                *obj\Angle = Random(3600)/3600 * 2 * #PI
                *obj\Speed = Random(1000)/1000 * GlobalVar\OBJECT_VIRUS_MAXSPEED
                *obj\X = X
                *obj\Y = Y
                *obj\MinEnergy = *Cell\VirusMinEnergy
                *obj\DNAPosition = Param
                *obj\LifeTime = GlobalVar\OBJECT_VIRUS_LIFETIME  
              EndIf  
            EndIf
          EndIf
          
        Case #CMD_POISON_DNA_CODE
          *Cell\DNACode = Param
        Case #CMD_POISON_EMIT_DNA
          
          If *Creature\Energy > GlobalVar\OBJECT_DNA_ENERGY_DECREASE
            *obj.OBJECT = AddObject()
            If *obj<>0
              *Creature\Energy - GlobalVar\OBJECT_DNA_ENERGY_DECREASE
              *Cell\EnergyFootprint - GlobalVar\OBJECT_DNA_ENERGY_DECREASE
              *obj\Type = #OBJECT_DNA
              *obj\IsDNABlock = #False
              *obj\CreatureID = 0
              *obj\CellID = *Cell\CellID
              *obj\Angle = Random(3600)/3600 * 2 * #PI
              *obj\Speed = Random(1000)/1000 * GlobalVar\OBJECT_DNA_MAXSPEED
              *obj\X = X
              *obj\Y = Y
              *obj\DNACode = *Cell\DNACode
              *obj\DNAPosition = Param 
              *obj\LifeTime = GlobalVar\OBJECT_DNA_LIFETIME  
              *obj\Rotation = Random(360)
            EndIf  
          EndIf
          
          
        Case #CMD_POISON_DNABLOCK_SIZE
          *Cell\DNABlockSize = Param
          
        Case #CMD_POISON_EMIT_DNABLOCK
          Lines = *Cell\DNABlockSize
          If Lines < 1 : Lines = 1:EndIf
          If Lines > #MAX_DNAMAXBLOCKSIZE : Lines = #MAX_DNAMAXBLOCKSIZE:EndIf
          
          If Param >= 0 And Param < #CODE_SIZE - Lines - 1            
            If *Creature\Energy > GlobalVar\OBJECT_DNA_BLOCK_ENERGY_DECREASE * Lines
              *obj.OBJECT = AddObject()
              If *obj<>0
                *Creature\Energy - GlobalVar\OBJECT_DNA_BLOCK_ENERGY_DECREASE * Lines
                *Cell\EnergyFootprint - GlobalVar\OBJECT_DNA_BLOCK_ENERGY_DECREASE * Lines
                *obj\Type = #OBJECT_DNA
                *obj\IsDNABlock = #True
                *obj\CreatureID = 0
                *obj\CellID = *Cell\CellID
                *obj\Angle = Random(3600)/3600 * 2 * #PI
                *obj\Speed = Random(1000)/1000 * GlobalVar\OBJECT_DNA_MAXSPEED
                *obj\X = X
                *obj\Y = Y
                CopyMemory(@*Cell\DNA[Param],@*obj\DNABlock[0], 4 * Lines) 
                *obj\DNABlockSize = Lines
                ;Debug "LINES "+Str(Lines)
                ;Debug "POS "+Str(param)
                *obj\DNAPosition = Param 
                *obj\LifeTime = GlobalVar\OBJECT_DNA_LIFETIME  
                *obj\Rotation = Random(360)
              EndIf  
            EndIf
          EndIf
          
        Case #CMD_MSG_EMIT
          
          If *Creature\Energy > GlobalVar\OBJECT_MSG_ENERGY_DECREASE
            *obj.OBJECT = AddObject()
            If *obj<>0
              *Creature\Energy - GlobalVar\OBJECT_MSG_ENERGY_DECREASE
              *Cell\EnergyFootprint - GlobalVar\OBJECT_MSG_ENERGY_DECREASE
              *obj\Type = #OBJECT_MSG
              *obj\CreatureID = 0
              *obj\CellID = *Cell\CellID
              *obj\Angle = Random(3600)/3600 * 2 * #PI
              *obj\Speed = Random(1000)/1000 * GlobalVar\OBJECT_MSG_MAXSPEED
              *obj\X = X
              *obj\Y = Y
              *obj\MessageID = Param
              *obj\LifeTime = GlobalVar\OBJECT_MSG_LIFETIME  
            EndIf  
          EndIf
          
          
          
        Case #CMD_ROTATE_LEFT
          ExecDebug("Exec:ROTATE_LEFT")
          *Creature\Angle + GlobalVar\CREATURE_ROTATIONSPEED + (Random(1000)-500)/500 * GlobalVar\CREATURE_RANDOMROTATION
          *Creature\Energy - GlobalVar\CREATURE_ROTATION_ENERGY_DECREASE
          *Cell\EnergyFootprint - GlobalVar\CREATURE_ROTATION_ENERGY_DECREASE
        Case #CMD_ROTATE_RIGHT
          ExecDebug("Eexc:ROTATE_RIGHT")
          *Creature\Angle - GlobalVar\CREATURE_ROTATIONSPEED + (Random(1000)-500)/500 * GlobalVar\CREATURE_RANDOMROTATION
          *Creature\Energy - GlobalVar\CREATURE_ROTATION_ENERGY_DECREASE
          *Cell\EnergyFootprint - GlobalVar\CREATURE_ROTATION_ENERGY_DECREASE
        Case #CMD_ROTATE_MSG
          *Creature\Angle + Rotate(*Creature\Angle, *Cell\MsgDirection, GlobalVar\CREATURE_ROTATIONSPEED) + (Random(1000)-500)/500 * GlobalVar\CREATURE_RANDOMROTATION
          *Creature\Energy - GlobalVar\CREATURE_ROTATION_ENERGY_DECREASE
          *Cell\EnergyFootprint - GlobalVar\CREATURE_ROTATION_ENERGY_DECREASE
        Case #CMD_ROTATE_DNA
          *Creature\Angle + Rotate(*Creature\Angle, *Cell\DNADirection, GlobalVar\CREATURE_ROTATIONSPEED) + (Random(1000)-500)/500 * GlobalVar\CREATURE_RANDOMROTATION
          *Creature\Energy - GlobalVar\CREATURE_ROTATION_ENERGY_DECREASE
          *Cell\EnergyFootprint - GlobalVar\CREATURE_ROTATION_ENERGY_DECREASE
        Case #CMD_ROTATE_POISON
          *Creature\Angle + Rotate(*Creature\Angle, *Cell\PoisonDirection, GlobalVar\CREATURE_ROTATIONSPEED)+ (Random(1000)-500)/500 * GlobalVar\CREATURE_RANDOMROTATION 
          *Creature\Energy - GlobalVar\CREATURE_ROTATION_ENERGY_DECREASE
          *Cell\EnergyFootprint - GlobalVar\CREATURE_ROTATION_ENERGY_DECREASE
        Case #CMD_ROTATE_FOOD
          *Creature\Angle + Rotate(*Creature\Angle, *Cell\FoodDirection, GlobalVar\CREATURE_ROTATIONSPEED)+ (Random(1000)-500)/500 * GlobalVar\CREATURE_RANDOMROTATION
          *Creature\Energy - GlobalVar\CREATURE_ROTATION_ENERGY_DECREASE
          *Cell\EnergyFootprint - GlobalVar\CREATURE_ROTATION_ENERGY_DECREASE
        Case #CMD_ROTATE_ANTI_MSG
          *Creature\Angle + Rotate(*Creature\Angle, *Cell\MsgDirection + #PI, GlobalVar\CREATURE_ROTATIONSPEED) + (Random(1000)-500)/500 * GlobalVar\CREATURE_RANDOMROTATION
          *Creature\Energy - GlobalVar\CREATURE_ROTATION_ENERGY_DECREASE
          *Cell\EnergyFootprint - GlobalVar\CREATURE_ROTATION_ENERGY_DECREASE
        Case #CMD_ROTATE_ANTI_DNA
          *Creature\Angle + Rotate(*Creature\Angle, *Cell\DNADirection + #PI, GlobalVar\CREATURE_ROTATIONSPEED) + (Random(1000)-500)/500 * GlobalVar\CREATURE_RANDOMROTATION
          *Creature\Energy - GlobalVar\CREATURE_ROTATION_ENERGY_DECREASE
          *Cell\EnergyFootprint - GlobalVar\CREATURE_ROTATION_ENERGY_DECREASE
        Case #CMD_ROTATE_ANTI_POISON
          *Creature\Angle + Rotate(*Creature\Angle, *Cell\PoisonDirection + #PI, GlobalVar\CREATURE_ROTATIONSPEED)+ (Random(1000)-500)/500 * GlobalVar\CREATURE_RANDOMROTATION
          *Creature\Energy - GlobalVar\CREATURE_ROTATION_ENERGY_DECREASE
          *Cell\EnergyFootprint - GlobalVar\CREATURE_ROTATION_ENERGY_DECREASE
        Case #CMD_ROTATE_ANTI_FOOD
          *Creature\Angle + Rotate(*Creature\Angle, *Cell\FoodDirection + #PI, GlobalVar\CREATURE_ROTATIONSPEED) + (Random(1000)-500)/500 * GlobalVar\CREATURE_RANDOMROTATION
          *Creature\Energy - GlobalVar\CREATURE_ROTATION_ENERGY_DECREASE
          *Cell\EnergyFootprint - GlobalVar\CREATURE_ROTATION_ENERGY_DECREASE
          
        Case #CMD_COPY_MIN_ENERGY
          *Cell\CopyMinEnergy = Param
          
        Case #CMD_CLONE
          
          *Creature\CopyMinCount + 1
          If *Creature\CopyMinCount > GlobalVar\CREATURE_PROBABLE_CLONE_MIN_CLONE_COUNT 
            *Creature\CopyMinCount = 0
            
            If *Creature\Energy > *Cell\CopyMinEnergy
              If *Creature\Energy > GlobalVar\CREATURE_CLONE_ENERGY_DECREASE
                
                *Creature\Energy - GlobalVar\CREATURE_CLONE_ENERGY_DECREASE
                *Creature2.CREATURE = CopyCreature(CreatureIndex, #True)
                *Creature.CREATURE = Creatures(CreatureIndex)
                *Cell = *Creature\Cells[CellIndex]
                
                If *Creature2
                  
                  *Creature\Energy * 0.5
                  *Creature2\Energy  * 0.5
                  *Creature\OrgEnergy  * 0.5
                  *Creature2\OrgEnergy * 0.5
                  
                  For i = 0 To *Creature\NumCells -1
                    *Creature\Cells[i]\Radius * 0.5
                  Next
                  For i = 0 To *Creature2\NumCells -1
                    *Creature2\Cells[i]\Radius * 0.5
                  Next                
                  
                Else
                  *Creature\Energy + GlobalVar\CREATURE_CLONE_ENERGY_DECREASE
                  ;;->Edit war wol nix
                  ;*Creature\OrgEnergy + GlobalVar\CREATURE_CLONE_ENERGY_DECREASE
                EndIf
                
              EndIf 
            EndIf
          EndIf
          
          
        Case #CMD_COPY50_50 ; Verteilung
          
          
          *Creature\CopyMinCount + 1
          If *Creature\CopyMinCount > GlobalVar\CREATURE_PROBABLE_CLONE_MIN_CLONE_COUNT 
            *Creature\CopyMinCount = 0
            
            If *Creature\Energy > *Cell\CopyMinEnergy
              If *Creature\Energy > GlobalVar\CREATURE_CLONE_ENERGY_DECREASE
                
                *Creature\Energy - GlobalVar\CREATURE_CLONE_ENERGY_DECREASE
                *Creature2.CREATURE = CopyCreature(CreatureIndex, #False)
                *Creature.CREATURE = Creatures(CreatureIndex)
                *Cell = *Creature\Cells[CellIndex]
                
                If *Creature2
                  
                  *Creature\Energy * 0.5
                  *Creature2\Energy  * 0.5
                  *Creature\OrgEnergy  * 0.5
                  *Creature2\OrgEnergy * 0.5
                  
                  For i = 0 To *Creature\NumCells -1
                    *Creature\Cells[i]\Radius * 0.5
                  Next
                  For i = 0 To *Creature2\NumCells -1
                    *Creature2\Cells[i]\Radius * 0.5
                  Next   
                  
                Else
                  *Creature\Energy + GlobalVar\CREATURE_CLONE_ENERGY_DECREASE
                EndIf
                
              EndIf 
            EndIf
          EndIf
          
          
        Case #CMD_COPY25_75
          
          *Creature\CopyMinCount + 1
          If *Creature\CopyMinCount > GlobalVar\CREATURE_PROBABLE_CLONE_MIN_CLONE_COUNT 
            *Creature\CopyMinCount = 0
            
            If *Creature\Energy > *Cell\CopyMinEnergy
              If *Creature\Energy > GlobalVar\CREATURE_CLONE_ENERGY_DECREASE
                
                *Creature\Energy - GlobalVar\CREATURE_CLONE_ENERGY_DECREASE
                *Creature2.CREATURE = CopyCreature(CreatureIndex, #False)
                *Creature.CREATURE = Creatures(CreatureIndex)
                *Cell = *Creature\Cells[CellIndex]
                
                If *Creature2
                  
                  *Creature\Energy * 0.75
                  *Creature2\Energy  * 0.25
                  *Creature\OrgEnergy  * 0.75
                  *Creature2\OrgEnergy * 0.25
                  
                  For i = 0 To *Creature\NumCells -1
                    *Creature\Cells[i]\Radius * 0.75
                  Next
                  For i = 0 To *Creature2\NumCells -1
                    *Creature2\Cells[i]\Radius * 0.25
                  Next   
                  
                Else
                  *Creature\Energy + GlobalVar\CREATURE_CLONE_ENERGY_DECREASE
                EndIf
                
              EndIf 
            EndIf
          EndIf        
          
          
        Case #CMD_COPY5_95
          
          *Creature\CopyMinCount + 1
          If *Creature\CopyMinCount > GlobalVar\CREATURE_PROBABLE_CLONE_MIN_CLONE_COUNT 
            *Creature\CopyMinCount = 0
            
            If *Creature\Energy > *Cell\CopyMinEnergy
              If *Creature\Energy > GlobalVar\CREATURE_CLONE_ENERGY_DECREASE
                
                *Creature\Energy - GlobalVar\CREATURE_CLONE_ENERGY_DECREASE
                *Creature2.CREATURE = CopyCreature(CreatureIndex, #False)
                *Creature.CREATURE = Creatures(CreatureIndex)
                *Cell = *Creature\Cells[CellIndex]
                
                If *Creature2
                  
                  *Creature\Energy * 0.95
                  *Creature2\Energy  * 0.05
                  *Creature\OrgEnergy  * 0.95
                  *Creature2\OrgEnergy * 0.05
                  
                  For i = 0 To *Creature\NumCells -1
                    *Creature\Cells[i]\Radius * 0.90 ; 5% wäre zu klein 
                  Next
                  For i = 0 To *Creature2\NumCells -1
                    *Creature2\Cells[i]\Radius * 0.10 ; 5% wäre zu klein 
                  Next   
                Else
                  *Creature\Energy + GlobalVar\CREATURE_CLONE_ENERGY_DECREASE
                EndIf
                
              EndIf 
            EndIf
          EndIf
          
          
        Case #CMD_RETURN
          *Cell\CodePosition = -1
          
        Case #CMD_GOTO
          If Param >= 0 And Param <= #CODE_SIZE - 1
            *Cell\CodePosition = Param -1
          EndIf
        Case #CMD_GOTO50 ; Wahrscheinlichkeit
          If Param >= 0 And Param <= #CODE_SIZE - 1
            If Random(100) <= 50
              *Cell\CodePosition = Param -1
            EndIf
          EndIf
          
        Case #CMD_GOTO25
          If Param >= 0 And Param <= #CODE_SIZE - 1
            If Random(100) <= 25
              *Cell\CodePosition = Param -1
            EndIf
          EndIf
          
        Case #CMD_GOTO5
          If Param >= 0 And Param <= #CODE_SIZE - 1
            If Random(100) <= 5
              *Cell\CodePosition = Param -1
            EndIf
          EndIf
          
        Case #CMD_RNDGOTO
          *Cell\CodePosition = Random(#CODE_SIZE)-1
          
        Case #CMD_VARIABLE
          If Param >= 0 And Param <= #CODE_SIZE - 1
            *Cell\CodeVariable = Param
          Else
            *Cell\CodeVariable = #CODE_SIZE - 1
          EndIf
          
        Case #CMD_VARIABLE_ZERO
          If *Cell\CodeVariable >= 0 And *Cell\CodeVariable <= #CODE_SIZE - 1
            *Cell\DNA[*Cell\CodeVariable] = 0
          EndIf
        Case #CMD_VARIABLE_DEC
          If *Cell\CodeVariable >= 0 And *Cell\CodeVariable <= #CODE_SIZE - 1
            *Cell\DNA[*Cell\CodeVariable] -1
          EndIf 
        Case #CMD_VARIABLE_INC
          If *Cell\CodeVariable >= 0 And *Cell\CodeVariable <= #CODE_SIZE - 1
            *Cell\DNA[*Cell\CodeVariable] +1
          EndIf 
        Case #CMD_VARIABLE_SET
          If *Cell\CodeVariable >= 0 And *Cell\CodeVariable <= #CODE_SIZE - 1
            *Cell\DNA[*Cell\CodeVariable] = Param
          EndIf 
        Case #CMD_VARIABLE_ADD
          If *Cell\CodeVariable >= 0 And *Cell\CodeVariable <= #CODE_SIZE - 1
            *Cell\DNA[*Cell\CodeVariable] + Param
          EndIf
        Case #CMD_VARIABLE_SUB
          If *Cell\CodeVariable >= 0 And *Cell\CodeVariable <= #CODE_SIZE - 1
            *Cell\DNA[*Cell\CodeVariable] - Param
          EndIf
        Case #CMD_VARIABLE_MUL
          If *Cell\CodeVariable >= 0 And *Cell\CodeVariable <= #CODE_SIZE - 1
            *Cell\DNA[*Cell\CodeVariable] * Param
          EndIf
        Case #CMD_VARIABLE_DIV
          If Param <> 0
            If *Cell\CodeVariable >= 0 And *Cell\CodeVariable <= #CODE_SIZE - 1
              *Cell\DNA[*Cell\CodeVariable] / Param
            EndIf
          EndIf
        Case #CMD_VARIABLE_XOR
          If *Cell\CodeVariable >= 0 And *Cell\CodeVariable <= #CODE_SIZE - 1
            *Cell\DNA[*Cell\CodeVariable] ! Param
          EndIf
        Case #CMD_VARIABLE_OR
          If *Cell\CodeVariable >= 0 And *Cell\CodeVariable <= #CODE_SIZE - 1
            *Cell\DNA[*Cell\CodeVariable] | Param
          EndIf
        Case #CMD_VARIABLE_AND
          If *Cell\CodeVariable >= 0 And *Cell\CodeVariable <= #CODE_SIZE - 1        
            *Cell\DNA[*Cell\CodeVariable] & Param
          EndIf
        Case #CMD_VARIABLE_MOD
          If *Cell\CodeVariable >= 0 And *Cell\CodeVariable <= #CODE_SIZE - 1       
            If Param <> 0
              *Cell\DNA[*Cell\CodeVariable] % Param
            EndIf
          EndIf        
          
        Case #CMD_INC_CELL_RAD
          If *Cell\Radius < GlobalVar\CREATURE_MAXRADIUS
            *Cell\Radius +1
            *Creature\Energy - GlobalVar\CREATURE_MOVE_ENERGY_DECREASE
            *Cell\EnergyFootprint - GlobalVar\CREATURE_MOVE_ENERGY_DECREASE
          EndIf
          
        Case #CMD_DEC_CELL_RAD
          If *Cell\Radius > GlobalVar\CREATURE_MINRADIUS
            *Cell\Radius -1
            *Creature\Energy - GlobalVar\CREATURE_MOVE_ENERGY_DECREASE
            *Cell\EnergyFootprint - GlobalVar\CREATURE_MOVE_ENERGY_DECREASE
          EndIf
          
        Case #CMD_SIN_CELL_RAD   
          *Cell\SinRadius + Param   
          NewRad.l = *Cell\SinRadiusMid + Sin( *Cell\SinRadius / 256) * *Cell\SinRadiusAmp
          If *Cell\Radius > NewRad
            *Cell\Radius -1
            *Creature\Energy - GlobalVar\CREATURE_MOVE_ENERGY_DECREASE
            *Cell\EnergyFootprint - GlobalVar\CREATURE_MOVE_ENERGY_DECREASE
          EndIf
          If *Cell\Radius < NewRad
            *Cell\Radius +1
            *Creature\Energy - GlobalVar\CREATURE_MOVE_ENERGY_DECREASE
            *Cell\EnergyFootprint - GlobalVar\CREATURE_MOVE_ENERGY_DECREASE
          EndIf
          
        Case #CMD_SIN_CELL_AMPRAD
          *Cell\SinRadiusAmp = Param
          
        Case #CMD_SIN_CELL_MIDRAD
          *Cell\SinRadiusMid = Param
          
        Case #CMD_TIMER_SET
          *Cell\TimerStarted = #True
          *Cell\TimerCount = Param
        Case #CMD_TIMER_GOTO
          *Cell\TimerGoto = Param     
        Case #CMD_TIMER_YES
          *Cell\TimerStarted = #True
        Case #CMD_TIMER_NO 
          *Cell\TimerStarted = #False    
          
        Case #CMD_IF_X_GREATER  
          *Cell\Condition = #False
          If *Creature\X > Param:*Cell\Condition = #True: EndIf
          *Cell\InCondition = #True
          
        Case #CMD_IF_X_LESS  
          *Cell\Condition = #False
          If *Creature\X < Param:*Cell\Condition = #True: EndIf
          *Cell\InCondition = #True        
          
        Case #CMD_IF_X_EQUAL 
          *Cell\Condition = #False
          If *Creature\X = Param:*Cell\Condition = #True: EndIf
          *Cell\InCondition = #True  
          
        Case #CMD_IF_Y_GREATER  
          *Cell\Condition = #False
          If *Creature\Y > Param:*Cell\Condition = #True: EndIf
          *Cell\InCondition = #True
          
        Case #CMD_IF_Y_LESS  
          *Cell\Condition = #False
          If *Creature\Y < Param:*Cell\Condition = #True: EndIf
          *Cell\InCondition = #True        
          
        Case #CMD_IF_Y_EQUAL 
          *Cell\Condition = #False
          If *Creature\Y = Param:*Cell\Condition = #True: EndIf
          *Cell\InCondition = #True  
          
        Case #CMD_SEARCH_NEAREST_ENEMY
          
          
          If *Creature\Energy > GlobalVar\CREATURE_SEARCH_ENEMY_ENERGY_DECREASE
            *Cell\EnemyX = #AREA_WIDTH / 2
            *Cell\EnemyY = #AREA_HEIGHT / 2               
            *Cell\EnemyFound = #False
            *Cell\EnemyIncCreatureID = *Creature\IncCreatureID
            
            *Creature\Energy - GlobalVar\CREATURE_SEARCH_ENEMY_ENERGY_DECREASE
            *Cell\EnergyFootprint - GlobalVar\CREATURE_SEARCH_ENEMY_ENERGY_DECREASE 
            
            MinAbs.f = 1000000
            For c = 0 To Creatures_Count - 1
              If Creatures(c)\Used
                If CreatureIndex <> c 
                  AbsM.f = Sqr( Pow(*Creature\X - Creatures(c)\X, 2) + Pow(*Creature\Y - Creatures(c)\Y, 2))
                  If AbsM < MinAbs
                    *Cell\EnemyX = Creatures(c)\X
                    *Cell\EnemyY = Creatures(c)\Y
                    *Cell\EnemyIncCreatureID = Creatures(c)\IncCreatureID 
                    *Cell\EnemyFound = #True
                    MinAbs = AbsM
                    ;Debug c
                  EndIf
                EndIf
              EndIf          
            Next
          EndIf
          
          
        Case #CMD_IF_ENEMYABS_GREATER
          *Cell\Condition = #False
          AbsE.l = Sqr( Pow(*Creature\X - *Cell\EnemyX, 2) + Pow(*Creature\Y - *Cell\EnemyY, 2))
          If *Cell\EnemyFound = #False
            AbsE.l = 1000000
          EndIf       
          If AbsE > Param:*Cell\Condition = #True: EndIf
          *Cell\InCondition = #True      
          
        Case #CMD_IF_ENEMYABS_LESS
          *Cell\Condition = #False
          AbsE.l = Sqr( Pow(*Creature\X - *Cell\EnemyX, 2) + Pow(*Creature\Y - *Cell\EnemyY, 2))
          If *Cell\EnemyFound = #False
            AbsE.l = 1000000
          EndIf   
          If AbsE < Param:*Cell\Condition = #True: EndIf
          *Cell\InCondition = #True  
          
        Case #CMD_IF_ENEMYABS_EQUAL    
          *Cell\Condition = #False
          AbsE.l = Sqr( Pow(*Creature\X - *Cell\EnemyX, 2) + Pow(*Creature\Y - *Cell\EnemyY, 2))
          If *Cell\EnemyFound = #False
            AbsE.l = 1000000
          EndIf   
          If AbsE = Param:*Cell\Condition = #True: EndIf
          *Cell\InCondition = #True          
          
        Case #CMD_ROTATE_ENEMY
          Target.f = Angle( *Creature\X, *Creature\Y, *Cell\EnemyX,*Cell\EnemyY )
          *Creature\Angle + Rotate(*Creature\Angle, Target + #PI/2, GlobalVar\CREATURE_ROTATIONSPEED) + (Random(1000)-500)/500 * GlobalVar\CREATURE_RANDOMROTATION
          *Creature\Energy - GlobalVar\CREATURE_ROTATION_ENERGY_DECREASE
          *Cell\EnergyFootprint - GlobalVar\CREATURE_ROTATION_ENERGY_DECREASE      
        Case #CMD_ROTATE_ANTI_ENEMY 
          Target.f = Angle( *Creature\X, *Creature\Y, *Cell\EnemyX,*Cell\EnemyY )
          *Creature\Angle + Rotate(*Creature\Angle, Target + #PI/2 + #PI, GlobalVar\CREATURE_ROTATIONSPEED) + (Random(1000)-500)/500 * GlobalVar\CREATURE_RANDOMROTATION
          *Creature\Energy - GlobalVar\CREATURE_ROTATION_ENERGY_DECREASE
          *Cell\EnergyFootprint - GlobalVar\CREATURE_ROTATION_ENERGY_DECREASE   
          
        Case #CMD_IF_CMP_ENEMY_GREATER      
          *Cell\Condition = #False
          Dif.l = *Cell\EnemyIncCreatureID - *Creature\IncCreatureID
          If Dif < 0 :Dif = - Dif:EndIf
          If Dif > Param:*Cell\Condition = #True: EndIf
          *Cell\InCondition = #True   
        Case #CMD_IF_CMP_ENEMY_LESS
          *Cell\Condition = #False
          Dif.l = *Cell\EnemyIncCreatureID - *Creature\IncCreatureID
          If Dif < 0 :Dif = - Dif:EndIf
          If Dif < Param:*Cell\Condition = #True: EndIf
          *Cell\InCondition = #True   
          
        Case #CMD_IF_CMP_ENEMY_EQUAL
          *Cell\Condition = #False
          Dif.l = *Cell\EnemyIncCreatureID - *Creature\IncCreatureID
          If Dif < 0 :Dif = - Dif:EndIf
          If Dif = Param:*Cell\Condition = #True: EndIf
          *Cell\InCondition = #True   
          
        Case #CMD_DEST_POINT_X
          *Cell\PointX = Param
        Case #CMD_DEST_POINT_Y
          *Cell\PointY = Param
          
        Case #CMD_ROTATE_DEST_POINT
          Target.f = Angle( *Creature\X, *Creature\Y, *Cell\PointX,*Cell\PointY )
          *Creature\Angle + Rotate(*Creature\Angle, Target + #PI/2, GlobalVar\CREATURE_ROTATIONSPEED) + (Random(1000)-500)/500 * GlobalVar\CREATURE_RANDOMROTATION
          *Creature\Energy - GlobalVar\CREATURE_ROTATION_ENERGY_DECREASE
          *Cell\EnergyFootprint - GlobalVar\CREATURE_ROTATION_ENERGY_DECREASE 
          
        Case #CMD_ROTATE_ANTI_DEST_POINT
          Target.f = Angle( *Creature\X, *Creature\Y, *Cell\PointX,*Cell\PointY )
          *Creature\Angle + Rotate(*Creature\Angle, Target + #PI/2 + #PI, GlobalVar\CREATURE_ROTATIONSPEED) + (Random(1000)-500)/500 * GlobalVar\CREATURE_RANDOMROTATION
          *Creature\Energy - GlobalVar\CREATURE_ROTATION_ENERGY_DECREASE
          *Cell\EnergyFootprint - GlobalVar\CREATURE_ROTATION_ENERGY_DECREASE 
          
          
        Case #CMD_VARIABLE_COPY      
          If Param >= 0 And Param <= #CODE_SIZE - 1
            If *Cell\CodeVariable >= 0 And *Cell\CodeVariable <= #CODE_SIZE - 1
              *Cell\DNA[Param] = *Cell\DNA[*Cell\CodeVariable]
            EndIf
          EndIf
          
        Case #CMD_PAUSE
          *Cell\DoNotExecCount = 1
          
        Case #CMD_ANTIVIRUS
          If *Creature\Energy > GlobalVar\CREATURE_ANTIVIRUS_ENERGY_DECREASE
            *Creature\Energy - GlobalVar\CREATURE_ANTIVIRUS_ENERGY_DECREASE
            *Cell\EnergyFootprint - GlobalVar\CREATURE_ANTIVIRUS_ENERGY_DECREASE 
            
            Pos =Random(#CODE_SIZE - 1)
            If *Cell\DNA[Pos] & 255 = #CMD_POISON_EMIT_VIRUS
              *Cell\DNA[Pos] = #CMD_PAUSE
            EndIf
          EndIf
          
          
        Case #CMD_PROTECTVIRUS
          If *Creature\Energy > GlobalVar\CREATURE_ANTIVIRUS_ENERGY_DECREASE
            *Creature\Energy - GlobalVar\CREATURE_ANTIVIRUS_ENERGY_DECREASE
            *Cell\EnergyFootprint - GlobalVar\CREATURE_ANTIVIRUS_ENERGY_DECREASE 
            
            *Cell\ProtectVirusCount = GlobalVar\CREATURE_PROTECTVIRUS_COUNT
          EndIf
          
        Case #CMD_COMBINECOPY
          
          *Creature\CopyMinCount + 1
          If *Creature\CopyMinCount > GlobalVar\CREATURE_PROBABLE_CLONE_MIN_CLONE_COUNT 
            *Creature\CopyMinCount = 0
            
            If *Creature\Energy > *Cell\CopyMinEnergy
              If *Creature\Energy > GlobalVar\CREATURE_CLONE_ENERGY_DECREASE * 2
                
                
                MinAbs.f = 100000000
                MinCreatureIndex = 0
                For c = 0 To Creatures_Count - 1
                  If Creatures(c)\Used
                    If CreatureIndex <> c 
                      AbsM.f = Sqr( Pow(*Creature\X - Creatures(c)\X, 2) + Pow(*Creature\Y - Creatures(c)\Y, 2))
                      If AbsM < MinAbs
                        MinCreatureIndex = c
                        MinAbs = AbsM
                      EndIf
                    EndIf
                  EndIf          
                Next                
                
                
                If MinAbs < GlobalVar\CREATURE_COMBINECOPY_MINABS
                  *Creature\Energy - GlobalVar\CREATURE_CLONE_ENERGY_DECREASE * 2
                  *Creature2.CREATURE = Combine_And_Clone_Creature(CreatureIndex, MinCreatureIndex)
                  ;*Creature.CREATURE = Creatures(CreatureIndex)
                  ;*Cell = *Creature\Cells[CellIndex]
                  
                  If *Creature2
                    *Creature2\Energy = *Creature\Energy 
                    *Creature2\OrgEnergy = *Creature\OrgEnergy  
                    
                    *Creature\Energy * 0.5
                    *Creature2\Energy  * 0.5
                    *Creature\OrgEnergy  * 0.5
                    *Creature2\OrgEnergy * 0.5
                    
                    For i = 0 To *Creature\NumCells -1
                      *Creature\Cells[i]\Radius * 0.5
                    Next
                    For i = 0 To *Creature2\NumCells -1
                      *Creature2\Cells[i]\Radius * 0.5
                    Next                
                    
                  Else
                    *Creature\Energy + GlobalVar\CREATURE_CLONE_ENERGY_DECREASE * 2
                    ;;->Edit war wol nix
                    ;*Creature\OrgEnergy + GlobalVar\CREATURE_CLONE_ENERGY_DECREASE
                  EndIf
                EndIf
                
              EndIf 
            EndIf
          EndIf
          
          
        Case #CMD_IF_GENERATION_GREATER
          *Cell\Condition = #False  
          If *Creature\IncCreatureID > Param:*Cell\Condition = #True: EndIf
          *Cell\InCondition = #True         
          
        Case #CMD_IF_GENERATION_LESS
          *Cell\Condition = #False  
          If *Creature\IncCreatureID < Param:*Cell\Condition = #True: EndIf
          *Cell\InCondition = #True    
          
        Case #CMD_IF_GENERATION_EQUAL
          *Cell\Condition = #False  
          If *Creature\IncCreatureID = Param:*Cell\Condition = #True: EndIf
          *Cell\InCondition = #True      
          
        Case #CMD_IF_NUMOFCELLS_GREATER
          *Cell\Condition = #False  
          If *Creature\NumCells > Param:*Cell\Condition = #True: EndIf
          *Cell\InCondition = #True             
          
        Case #CMD_IF_NUMOFCELLS_LESS
          *Cell\Condition = #False  
          If *Creature\NumCells < Param:*Cell\Condition = #True: EndIf
          *Cell\InCondition = #True 
          
        Case #CMD_IF_NUMOFCELLS_EQUAL
          *Cell\Condition = #False  
          If *Creature\NumCells = Param:*Cell\Condition = #True: EndIf
          *Cell\InCondition = #True 
          
        Case #CMD_IF_CELLNUMER_GREATER
          *Cell\Condition = #False  
          If CellIndex > Param:*Cell\Condition = #True: EndIf
          *Cell\InCondition = #True                         
          
        Case #CMD_IF_CELLNUMER_LESS
          *Cell\Condition = #False  
          If CellIndex < Param:*Cell\Condition = #True: EndIf
          *Cell\InCondition = #True 
          
        Case #CMD_IF_CELLNUMER_EQUAL
          *Cell\Condition = #False  
          If CellIndex = Param:*Cell\Condition = #True: EndIf
          *Cell\InCondition = #True     
          
        Case #CMD_IF_MALE
          *Cell\Condition = #False  
          If *Creature\IsMale:*Cell\Condition = #True: EndIf
          *Cell\InCondition = #True 
          
        Case #CMD_IF_FEMALE
          *Cell\Condition = #False  
          If *Creature\IsMale = #False:*Cell\Condition = #True: EndIf
          *Cell\InCondition = #True 
          
        Case #CMD_IF_AGE_GREATER
          *Cell\Condition = #False  
          If *Creature\Age > Param:*Cell\Condition = #True: EndIf
          *Cell\InCondition = #True 
          
        Case #CMD_IF_AGE_LESS
          *Cell\Condition = #False  
          If *Creature\Age < Param:*Cell\Condition = #True: EndIf
          *Cell\InCondition = #True
          
        Case #CMD_IF_AGE_EQUAL
          *Cell\Condition = #False  
          If *Creature\Age = Param:*Cell\Condition = #True: EndIf
          *Cell\InCondition = #True 
          
        Case #CMD_VARIABLE_RND
          *Cell\DNA[*Cell\CodeVariable] = Random($FFFF) + Random($FFFF)<<16 
          
        Case #CMD_MUTATE
          Pos.i = Random(#CODE_SIZE -1)
          If Pos >= 0 And Pos <= #CODE_SIZE -1
            *Cell\DNA[Pos] = OptimizeMutation(Random(#CMD_NOP))
          EndIf

        Case #CMD_EMITTOENEMY_FOOD
          If Random(100) > 75
            If *Creature\Energy > GlobalVar\OBJECT_FOOD_DEFAULT_SIZE * 2 And *Creature\OrgEnergy > GlobalVar\OBJECT_FOOD_DEFAULT_SIZE
              *obj.OBJECT = AddObject()
              If *obj<>0
                *Creature\Energy - GlobalVar\OBJECT_FOOD_DEFAULT_SIZE * 2
                *Creature\OrgEnergy - GlobalVar\OBJECT_FOOD_DEFAULT_SIZE
                *Cell\EnergyFootprint - GlobalVar\OBJECT_FOOD_DEFAULT_SIZE * 2
                *obj\Type = #OBJECT_REST ;FOOD
                *obj\CreatureID = 0
                *obj\CellID = 0
                
                Target.f = Angle( X, Y, *Cell\EnemyX, *Cell\EnemyY )

                *obj\Angle =   ( Target + (Random(10)-Random(10))/100 * #PI) + #PI / 2
                *obj\Speed = Random(1000)/1000 * GlobalVar\OBJECT_FOOD_MAXSPEED
                *obj\X = X
                *obj\Y = Y
                *obj\Energy = GlobalVar\OBJECT_FOOD_DEFAULT_SIZE
                *obj\LifeTime = Random(GlobalVar\OBJECT_REST_MAXLIFETIME)    
              EndIf  
            EndIf
          EndIf

        
        Case #CMD_EMITTOENEMY_MSG
           
           If Random(100) > 75
            If *Creature\Energy > GlobalVar\OBJECT_MSG_ENERGY_DECREASE * 2
              *obj.OBJECT = AddObject()
              If *obj<>0
                *Creature\Energy - GlobalVar\OBJECT_MSG_ENERGY_DECREASE * 2
                *Cell\EnergyFootprint - GlobalVar\OBJECT_MSG_ENERGY_DECREASE * 2
                *obj\Type = #OBJECT_MSG
                *obj\CreatureID = *Creature\CreatureID ; Eigene Zellen nehmen nichts auf
                *obj\CellID = *Cell\CellID
                
                Target.f = Angle( X, Y, *Cell\EnemyX, *Cell\EnemyY )

                *obj\Angle =  ( Target + (Random(10)-Random(10))/100 * #PI) + #PI / 2

                *obj\Speed = Random(1000)/1000 * GlobalVar\OBJECT_MSG_MAXSPEED
                *obj\X = X
                *obj\Y = Y
                *obj\MessageID = Param
                *obj\LifeTime = Random(GlobalVar\OBJECT_MSG_LIFETIME)     
              EndIf  
            EndIf
          EndIf
        
        Case #CMD_MUTATE_LINE          
          *Cell\MutateCodePos = ~ Param
           
        Case #CMD_BLOCKEXEC  
          If *Creature\Energy > GlobalVar\CREATURE_REPLACE_ENERGY_DECREASE
            *Creature\Energy - GlobalVar\CREATURE_REPLACE_ENERGY_DECREASE
            *Cell\EnergyFootprint - GlobalVar\CREATURE_REPLACE_ENERGY_DECREASE
            
            *Cell\BlockCodePos = ~ Param
          EndIf  
          
        Case #CMD_REPLACEMENT_CMD
          *Cell\Replacement_CMD = Param
          
        Case #CMD_REPLACE_CMD
          If *Creature\Energy > GlobalVar\CREATURE_REPLACE_ENERGY_DECREASE
            *Creature\Energy - GlobalVar\CREATURE_REPLACE_ENERGY_DECREASE
            *Cell\EnergyFootprint - GlobalVar\CREATURE_REPLACE_ENERGY_DECREASE
            
            Pos =Random(#CODE_SIZE - 1)
            If *Cell\DNA[Pos] & 255 = Param
              *Cell\DNA[Pos] = *Cell\Replacement_CMD
            EndIf
          EndIf        
        
        
        Case #CMD_VARIABLE_GETGLOBAL
          *Cell\DNA[*Cell\CodeVariable] = *Creature\GlobalVar       
        
        
        Case #CMD_VARIABLE_SETGLOBAL  
          *Creature\GlobalVar = *Cell\DNA[*Cell\CodeVariable]
          
        Case #CMD_ABSORBABLE_YES
          *Creature\Absorbable = #True
          
        Case #CMD_ABSORBABLE_NO
          *Creature\Absorbable = #False
        
        Case #CMD_IF_ABSORBABLE 
          *Cell\Condition = #False  
          If *Creature\Absorbable:*Cell\Condition = #True: EndIf
          *Cell\InCondition = #True
        
        Case #CMD_ABSORB_ENEMY        
              If *Creature\Energy > GlobalVar\CREATURE_CLONE_ENERGY_DECREASE * 4 And Random(100) < 25
                
                bOk = #False
                MinAbs.f = 100000000
                MinCreatureIndex = 0
                For c = 0 To Creatures_Count - 1
                  If Creatures(c)\Used And Creatures(c)\Absorbable
                    If CreatureIndex <> c 
                      AbsM.f = Sqr( Pow(*Creature\X - Creatures(c)\X, 2) + Pow(*Creature\Y - Creatures(c)\Y, 2))
                      If AbsM < MinAbs
                        MinCreatureIndex = c
                        MinAbs = AbsM
                        bOk = #True
                      EndIf
                    EndIf
                  EndIf          
                Next                
                
                
                If bOk
                  dRad1.f = 0
                  For c= 0 To *Creature\NumCells - 1
                    dRad1.f + *Creature\Cells[c]\radius
                  Next
                  dRad1.f / *Creature\NumCells

                  dRad2.f = 0
                  For c= 0 To Creatures(MinCreatureIndex)\NumCells - 1
                    dRad2.f + Creatures(MinCreatureIndex)\Cells[c]\radius
                  Next
                  dRad2.f / Creatures(MinCreatureIndex)\NumCells                  
                  
                
                  If MinAbs < dRad1 + dRad2
                    *Creature\Energy - GlobalVar\CREATURE_CLONE_ENERGY_DECREASE * 4
  
                    *Creature\Energy + Creatures(MinCreatureIndex)\Energy * 0.2
                    *Creature\OrgEnergy + Creatures(MinCreatureIndex)\OrgEnergy * 0.2
                    For c= 0 To #MAX_CELLS - 1
                      *Creature\Cells[c]\radius + Sqr(dRad2) * 0.2;Sqr(Creatures(MinCreatureIndex)\Cells[c]\radius) * 0.3
                      ;*Creature\Cells[c]\orgradius + Sqr(Creatures(MinCreatureIndex)\Cells[c]\orgradius) * 0.3
                      Creatures(MinCreatureIndex)\Cells[c]\radius - Sqr(Creatures(MinCreatureIndex)\Cells[c]\radius) * 0.2
                      ;Creatures(MinCreatureIndex)\Cells[c]\orgradius - Sqr(Creatures(MinCreatureIndex)\Cells[c]\orgradius) * 0.3
                    Next
                    
                    Creatures(MinCreatureIndex)\Energy * 0.8
                    Creatures(MinCreatureIndex)\OrgEnergy * 0.8
                  EndIf
                EndIf
                
              EndIf 



        Case #CMD_EMITTOENEMY_POISON
           
         If Random(100) > 75
          If *Cell\DoPoison
            If *Creature\Energy > GlobalVar\OBJECT_POISON_ENERGY_DECREASE * 2
              *obj.OBJECT = AddObject()
              If *obj<>0
                *Creature\Energy - GlobalVar\OBJECT_POISON_ENERGY_DECREASE * 2
                *Cell\EnergyFootprint - GlobalVar\OBJECT_POISON_ENERGY_DECREASE * 2
                *obj\Type = #OBJECT_POISON
                *obj\CreatureID = *Creature\CreatureID
                *obj\CellID = *Cell\CellID
                
                Target.f = Angle( X, Y, *Cell\EnemyX, *Cell\EnemyY )

                *obj\Angle =  ( Target + (Random(10)-Random(10))/100 * #PI) + #PI / 2

                *obj\Speed = Random(1000)/1000 * GlobalVar\OBJECT_POISON_MAXSPEED
                *obj\X = X
                *obj\Y = Y
                *obj\PoisonID = Param 
                *obj\LifeTime = GlobalVar\OBJECT_POISON_LIFETIME    
              EndIf  
            EndIf
          EndIf
        EndIf
 
        Case #CMD_EMITTOENEMY_DNA
           
           If Random(100) > 75
            If *Creature\Energy > GlobalVar\OBJECT_DNA_ENERGY_DECREASE * 2
              *obj.OBJECT = AddObject()
              If *obj<>0
                *Creature\Energy - GlobalVar\OBJECT_DNA_ENERGY_DECREASE * 2
                *Cell\EnergyFootprint - GlobalVar\OBJECT_DNA_ENERGY_DECREASE * 2
                *obj\Type = #OBJECT_DNA
                *obj\IsDNABlock = #False
                *obj\CreatureID = 0
                *obj\CellID = *Cell\CellID
                
                Target.f = Angle( X, Y, *Cell\EnemyX, *Cell\EnemyY )

                *obj\Angle =  ( Target + (Random(10)-Random(10))/100 * #PI) + #PI / 2

                *obj\Speed = Random(1000)/1000 * GlobalVar\OBJECT_DNA_MAXSPEED
                *obj\X = X
                *obj\Y = Y
                *obj\DNACode = *Cell\DNACode
                *obj\DNAPosition = Param 
                *obj\LifeTime = GlobalVar\OBJECT_DNA_LIFETIME  
                *obj\Rotation = Random(360)    
              EndIf  
            EndIf
          EndIf




        Case #CMD_EMITTOENEMY_DNABLOCK      
           If Random(100) > 75         
            If Param >= 0 And Param < #CODE_SIZE - Lines - 1 
              Lines = *Cell\DNABlockSize
              If Lines < 1 : Lines = 1:EndIf
              If Lines > #MAX_DNAMAXBLOCKSIZE : Lines = #MAX_DNAMAXBLOCKSIZE:EndIf
            
              If *Creature\Energy > GlobalVar\OBJECT_DNA_BLOCK_ENERGY_DECREASE * Lines
                *obj.OBJECT = AddObject()
                If *obj<>0
                  *Creature\Energy - GlobalVar\OBJECT_DNA_BLOCK_ENERGY_DECREASE * Lines
                  *Cell\EnergyFootprint - GlobalVar\OBJECT_DNA_BLOCK_ENERGY_DECREASE * Lines
                  *obj\Type = #OBJECT_DNA
                  *obj\IsDNABlock = #True
                  *obj\CreatureID = 0
                  *obj\CellID = *Cell\CellID
                 
                  Target.f = Angle( X, Y, *Cell\EnemyX, *Cell\EnemyY )

                  *obj\Angle =  ( Target + (Random(10)-Random(10))/100 * #PI) + #PI / 2

                  *obj\Speed = Random(1000)/1000 * GlobalVar\OBJECT_DNA_MAXSPEED
                  *obj\X = X
                  *obj\Y = Y
                  CopyMemory(@*Cell\DNA[Param],@*obj\DNABlock[0], 4 * Lines) 
                  *obj\DNABlockSize = Lines
                  ;Debug "LINES "+Str(Lines)
                  ;Debug "POS "+Str(param)
                  *obj\DNAPosition = Param 
                  *obj\LifeTime = GlobalVar\OBJECT_DNA_LIFETIME  
                  *obj\Rotation = Random(360)    
                EndIf  
              EndIf
            EndIf
          EndIf
 
 
        Case #CMD_PROTECTDNA
          If *Creature\Energy > GlobalVar\CREATURE_PROTECT_DNA_ENERGY_DECREASE
            *Creature\Energy - GlobalVar\CREATURE_PROTECT_DNA_ENERGY_DECREASE
            *Cell\EnergyFootprint - GlobalVar\CREATURE_PROTECT_DNA_ENERGY_DECREASE 
            
            *Cell\ProtectDNACount = GlobalVar\CREATURE_PROTECT_DNA_COUNT
          EndIf          
                                               
          ;A FEW CHEATING FUNCTION
          
        Case 233, 234 ; GET_CREATUREREGISTER offset / SET_CREATUREREGISTER offset
          If *Creature\MagicCreature = 'XGAM'
            If Param >= 0 And Param < SizeOf(CREATURE) / 4
              If *Cell\CodeVariable >= 0 And *Cell\CodeVariable <= #CODE_SIZE - 1
                If PCode = 233
                  *Cell\DNA[*Cell\CodeVariable] = PeekL(*Creature + Param * 4)
                Else
                  PokeL(*Creature + Param * 4, *Cell\DNA[*Cell\CodeVariable])
                  ;Debug *Creature\NumCells
                  ;Debug "ROTAT"
                EndIf      
              EndIf            
            EndIf
          EndIf      
          
        Case 235, 236 ; GET_CELLREGISTER offset / SET_CELLREGISTER offset
          If *Creature\MagicCreature = 'XGAM'
            If Param >= 0 And Param < SizeOf(CELL) / 4
              If *Cell\CodeVariable >= 0 And *Cell\CodeVariable <= #CODE_SIZE - 1
                If PCode = 235
                  *Cell\DNA[*Cell\CodeVariable] = PeekL(*Cell + Param * 4)
                Else
                  PokeL(*Cell + Param * 4, *Cell\DNA[*Cell\CodeVariable])
                EndIf      
              EndIf            
            EndIf
          EndIf            
        Case 237 ;OUTOBJ TYP,ANGLE,MESSAGE
          If *Creature\MagicCreature = 'XGAM'
            *obj.OBJECT = AddObject()
            If *obj<>0
              *obj\Type = Param & 255
              *obj\CreatureID = 0
              *obj\CellID = 0     
              CAngle.l =  (Param>>8) & 255      
              *obj\Angle = CAngle* 2 * #PI/255
              *obj\Speed = Random(1000)/1000 * GlobalVar\OBJECT_MSG_MAXSPEED
              *obj\X = X
              *obj\Y = Y
              *obj\MessageID = (Param >> 16)
              *obj\DNAPosition.l = Random(#CODE_SIZE - 1)
              *obj\IsDNABlock = Random(1)
              *obj\DNABlockSize = Random(5)
              *obj\LifeTime = GlobalVar\OBJECT_MSG_LIFETIME  
            EndIf          
          EndIf
        Case 238 ; SET_GLOBAL_SETTINGS
          If *Creature\MagicCreature = 'XGAM'  
            If *Cell\CodeVariable >= 0 And *Cell\CodeVariable <= #CODE_SIZE - 1
              If Param >= 0 And Param < SizeOf(GlobalVar) / 4
                PokeL(GlobalVar + Param * 4, *Cell\DNA[*Cell\CodeVariable]) 
              EndIf
            EndIf
          EndIf            
          
      EndSelect
      
    EndIf
    
    *Cell\CodePosition + 1
    
    If *Cell\CodePosition >= #CODE_SIZE - 1
      *Cell\CodePosition = 0
    EndIf
  EndIf  
  
  If *Cell\DoNotExecCount > 0
    *Cell\DoNotExecCount - 1
  EndIf
  
EndProcedure

Procedure MutateCreature(index)
  
  *Creature.CREATURE = Creatures(index)
  
  If *Creature\DisableMutation = #False
    
    For cell = 0 To *Creature\NumCells -1
      
      If Random(10000) <= GlobalVar\MUTATION_PROBABILITY    
        
        If Random(100) <= GlobalVar\MUTATION_PROBABILITY_RADIUS
          *Creature\Cells[cell]\Radius + Random(GlobalVar\MUTATION_RADIUS_CHANGE) - Random(GlobalVar\MUTATION_RADIUS_CHANGE)
        EndIf
        
        
        
        Pos = Random(#CODE_SIZE-1)
        If Random(100) <= GlobalVar\MUTATION_PROBABILITY_CHAOS
          
          If Random(1)=1
            *Creature\Cells[cell]\DNA[Pos] ! (Random($FFFF) << 16 + Random($FFFF))
          Else
            *Creature\Cells[cell]\DNA[Pos] + Random(4)-2
          EndIf
          
        Else
          code = GetCodeByProbability()
          If CodeIsExtended(code)
            
            
            If Random(100) > 25
              
              *Creature\Cells[cell]\DNA[Pos] = OptimizeMutation(code)
              
            Else
              
              If Random(100) > 50
                ;->Crash Structured array index out of bounds
                *Creature\Cells[cell]\DNA[Pos] = code + (Random(#CODE_SIZE-1))<<8
              Else
                *Creature\Cells[cell]\DNA[Pos] = code + (Random(20000) - 1000)<<8
              EndIf
              
            EndIf
            
          Else
            *Creature\Cells[cell]\DNA[Pos] = code
          EndIf
          
        EndIf
        
      EndIf
    Next
  EndIf
  
  
EndProcedure


Procedure DrawCreatures()
CompilerIf #DrawCreature_Sprite=#False
  StartDrawing(ScreenOutput())
CompilerElse
  Start3D()
CompilerEndIf
  For i=0 To Creatures_Count -1
    
    If Creatures(i)\Used
      DrawCreature(@Creatures(i))
    EndIf
    
  Next
    

CompilerIf #DrawCreature_Sprite=#False
  StopDrawing()
CompilerElse
  Stop3D()
CompilerEndIf
EndProcedure



Procedure __ExecuteCreatures_Async(StartIndex.l, EndIndex.l)
  
  
  For i=StartIndex To EndIndex
    
    If Creatures(i)\Used
      
      ;If Creatures(i)\X<0                :Creatures(i)\X = 0:EndIf
      ;If Creatures(i)\X=>#AREA_WIDTH     :Creatures(i)\X = #AREA_WIDTH:EndIf  
      ;If Creatures(i)\Y<0                :Creatures(i)\Y = 0:EndIf
      ;If Creatures(i)\Y=>#AREA_HEIGHT    :Creatures(i)\Y = #AREA_HEIGHT:EndIf
      
      If Creatures(i)\X < -1
        newX = Creatures(i)\X
        newX = #AREA_WIDTH + newX % #AREA_WIDTH      
        newX % #AREA_WIDTH
        Creatures(i)\X = newX
      EndIf
      If Creatures(i)\X > #AREA_WIDTH
        newX = Creatures(i)\X    
        newX % #AREA_WIDTH
        Creatures(i)\X = newX
      EndIf
      
      If Creatures(i)\Y < -1
        newY = Creatures(i)\Y
        newY = #AREA_HEIGHT + newY % #AREA_HEIGHT    
        newY % #AREA_HEIGHT
        Creatures(i)\Y = newY
      EndIf
      If Creatures(i)\Y > #AREA_HEIGHT
        newY = Creatures(i)\Y    
        newY % #AREA_HEIGHT
        Creatures(i)\Y = newY
      EndIf 
      
      If Real_Creatures<=GlobalVar\MinimalCreatures
        If Creatures(i)\Energy < 0:Creatures(i)\Energy=0:EndIf
      EndIf
      
      If Creatures(i)\MagicCreature = 'XRIP' ; 2008-11-23
        Creatures(i)\Energy = 1
      EndIf
      
      
      If Creatures(i)\Energy >= 0 
        ;;Debug "Draw Creature "+ StrF(*Creature\y)
        
        MutateCreature(i)
        
        CReduceEnergy.f = 0
        
        Area.f = 0
        For n = 0 To Creatures(i)\NumCells -1
          
          rad.f = Abs(Creatures(i)\Cells[n]\Radius) * GlobalVar\OBJECT_CATCH_RADIUS_FACTOR
          Area.f = #PI * rad * rad
          
          ReduceEnergy.l = Round(Pow(Area, GlobalVar\CREATURE_ROUNDENERGYFACTOR1) * GlobalVar\CREATURE_ROUNDENERGYFACTOR2, #PB_Round_Up) 
          CReduceEnergy + ReduceEnergy
          Creatures(i)\Cells[n]\EnergyFootprint - ReduceEnergy
          
          ExecuteCell(i, n)          
          
          If Creatures(i)\Cells[n]\Radius > GlobalVar\CREATURE_MAXRADIUS 
            Creatures(i)\Cells[n]\Radius = GlobalVar\CREATURE_MAXRADIUS 
          EndIf
          If Creatures(i)\Cells[n]\Radius < GlobalVar\CREATURE_MINRADIUS  
            Creatures(i)\Cells[n]\Radius = GlobalVar\CREATURE_MINRADIUS
          EndIf                
          
          
        Next
        
        CReduceEnergy * Pow(GlobalVar\CREATURE_CELLBONUS, Sqr(Creatures(i)\NumCells-1))
        If CReduceEnergy < 0 :CReduceEnergy = 0:EndIf
        
        
        ;Debug "Eng: "+Str(Creatures(i)\Energy)
        CRed.l = CReduceEnergy  * 2
        Creatures(i)\Energy - Random(CRed) ;uceEnergy   
        ;Debug "Engaa: "+Str(Creatures(i)\Energy)
        ; Debug "RED: "+Str(CReduceEnergy   )
        
        
        Creatures(i)\Age + 1
        
        If Creatures(i)\NumCells > 0
          If  Creatures(i)\Age % ((GlobalVar\CREATURE_METABOLISM_RATE / Creatures(i)\NumCells) + 1) = 1 And Random(100) > 50 
            If Creatures(i)\OrgEnergy > GlobalVar\OBJECT_FOOD_DEFAULT_SIZE
              X.f = Creatures(i)\X
              Y.f = Creatures(i)\Y  
              AddRest(X.f,Y.f,Random(GlobalVar\OBJECT_REST_MAXLIFETIME * 5), GlobalVar\OBJECT_FOOD_DEFAULT_SIZE)
              Creatures(i)\OrgEnergy - GlobalVar\OBJECT_FOOD_DEFAULT_SIZE
            EndIf
          EndIf  
        EndIf
        
        
        
      Else
        
        Real_Creatures - 1
        
        X.f = Creatures(i)\X
        Y.f = Creatures(i)\Y    
        _PlaySound(2)
        Repeat
          If Creatures(i)\OrgEnergy > GlobalVar\OBJECT_FOOD_DEFAULT_SIZE
            
            AddRest(X.f,Y.f,Random(GlobalVar\OBJECT_REST_MAXLIFETIME), GlobalVar\OBJECT_FOOD_DEFAULT_SIZE)
            Creatures(i)\OrgEnergy - GlobalVar\OBJECT_FOOD_DEFAULT_SIZE
          Else
            ;Debug Creatures(i)\orgEnergy
            AddRest(X.f,Y.f,Random(GlobalVar\OBJECT_REST_MAXLIFETIME), Creatures(i)\OrgEnergy)
            Creatures(i)\OrgEnergy = 0
          EndIf
          
        Until Creatures(i)\OrgEnergy <= 0
        Creatures(i)\Used = #False   
        
        
        
      EndIf
      
      
    EndIf
    
    
  Next
  
  
EndProcedure




Procedure __Worker_Thread(index.l)
  Repeat
    
    If TryLockMutex(Workers(index)\Mutex)
      Done.l = Workers(index)\Done
      StartIndex.l = Workers(index)\StartIndex
      EndIndex.l = Workers(index)\EndIndex
      UnlockMutex(Workers(index)\Mutex)
      
      If Done = #False
        __ExecuteCreatures_Async(StartIndex, EndIndex)
        LockMutex(Workers(index)\Mutex)
        Workers(index)\Done = #True
        UnlockMutex(Workers(index)\Mutex)  
      EndIf
      
    EndIf
    Delay(0); schneller
  ForEver
  
EndProcedure


Procedure Worker_Create()
  For nr = 0 To WORKER_COUNT - 1
    Workers(nr)\Mutex = CreateMutex()
    Workers(nr)\Thread=CreateThread(@__Worker_Thread(), nr)
  Next
EndProcedure

Procedure Worker_Wait()
  For index = 0 To WORKER_COUNT - 1
    Done = #False
    Repeat
      If TryLockMutex(Workers(index)\Mutex)       
        If Workers(index)\Done = #True:Done = #True:EndIf
        UnlockMutex(Workers(index)\Mutex)  
      EndIf
      
      If Done = #False
        Delay(0)
      EndIf
      
    Until Done
  Next
EndProcedure


Procedure Worker_Pause(Status)
  If UseMultiCore
    For index = 0 To WORKER_COUNT - 1
      If Status = #True
        PauseThread(Workers(index)\Thread)
      Else
        ResumeThread(Workers(index)\Thread)
      EndIf
    Next
  EndIf
EndProcedure


Procedure Worker_Set(WorkerIndex.l, StartIndex.l, EndIndex.l)
  LockMutex(Workers(WorkerIndex)\Mutex)
  Workers(WorkerIndex)\Done = #False
  Workers(WorkerIndex)\StartIndex = StartIndex
  Workers(WorkerIndex)\EndIndex = EndIndex
  UnlockMutex(Workers(WorkerIndex)\Mutex)  
EndProcedure


Procedure ExecuteCreatures_Async()
  Size = (Creatures_Count-1) / WORKER_COUNT
  Start = 0
  For i=0 To WORKER_COUNT -2
    Worker_Set(i, Start, Start + Size)
    Start + Size + 1
  Next
  
  If Start <=  Creatures_Count - 1
    Worker_Set(WORKER_COUNT -1, Start, Creatures_Count - 1)
  EndIf
  
EndProcedure




Procedure ExecuteCreatures()
  
  For i=0 To Creatures_Count -1
    
    If Creatures(i)\Used
      
      
      ;If Creatures(i)\X<0                :Creatures(i)\X = 0:EndIf
      ;If Creatures(i)\X=>#AREA_WIDTH     :Creatures(i)\X = #AREA_WIDTH:EndIf  
      ;If Creatures(i)\Y<0                :Creatures(i)\Y = 0:EndIf
      ;If Creatures(i)\Y=>#AREA_HEIGHT    :Creatures(i)\Y = #AREA_HEIGHT:EndIf 
      
      If Creatures(i)\X < -1
        newX = Creatures(i)\X
        newX = #AREA_WIDTH + newX % #AREA_WIDTH      
        newX % #AREA_WIDTH
        Creatures(i)\X = newX
      EndIf
      If Creatures(i)\X > #AREA_WIDTH
        newX = Creatures(i)\X    
        newX % #AREA_WIDTH
        Creatures(i)\X = newX
      EndIf
      
      If Creatures(i)\Y < -1
        newY = Creatures(i)\Y
        newY = #AREA_HEIGHT + newY % #AREA_HEIGHT    
        newY % #AREA_HEIGHT
        Creatures(i)\Y = newY
      EndIf
      If Creatures(i)\Y > #AREA_HEIGHT
        newY = Creatures(i)\Y    
        newY % #AREA_HEIGHT
        Creatures(i)\Y = newY
      EndIf 
      
      ;Debug "R"+Str(Real_Creatures)
      ;Debug "M"+Str(GlobalVar\MinimalCreatures)
      
      If Real_Creatures<=GlobalVar\MinimalCreatures
        If Creatures(i)\Energy < 0:Creatures(i)\Energy=0:EndIf
      EndIf
      
      If Creatures(i)\MagicCreature = 'XRIP' ; 2008-11-23
        Creatures(i)\Energy = 1
      EndIf
      
      
      If Creatures(i)\Energy >= 0
        
        
        ;;Debug "Draw Creature "+ StrF(*Creature\y)
        
        MutateCreature(i)
        
        CReduceEnergy.f = 0
        
        Area.f = 0
        For n = 0 To Creatures(i)\NumCells -1
          
          rad.f = Abs(Creatures(i)\Cells[n]\Radius) * GlobalVar\OBJECT_CATCH_RADIUS_FACTOR
          Area.f = #PI * rad * rad
          ReduceEnergy.l = Round(Pow(Area, GlobalVar\CREATURE_ROUNDENERGYFACTOR1) * GlobalVar\CREATURE_ROUNDENERGYFACTOR2, #PB_Round_Up) 
          CReduceEnergy + ReduceEnergy
          Creatures(i)\Cells[n]\EnergyFootprint - ReduceEnergy
          
          ExecuteCell(i, n)          
          
          If Creatures(i)\Cells[n]\Radius > GlobalVar\CREATURE_MAXRADIUS 
            Creatures(i)\Cells[n]\Radius = GlobalVar\CREATURE_MAXRADIUS 
          EndIf
          If Creatures(i)\Cells[n]\Radius < GlobalVar\CREATURE_MINRADIUS  
            Creatures(i)\Cells[n]\Radius = GlobalVar\CREATURE_MINRADIUS
          EndIf                
          
          
        Next
        CReduceEnergy * Pow(GlobalVar\CREATURE_CELLBONUS, Sqr(Creatures(i)\NumCells-1))
        If CReduceEnergy < 0 :CReduceEnergy = 0:EndIf
        
        
        ;Debug "Eng: "+Str(Creatures(i)\Energy)
        CRed.l = CReduceEnergy  * 2
        Creatures(i)\Energy - Random(CRed) ;uceEnergy   
        ;Debug "Engaa: "+Str(Creatures(i)\Energy)
        ; Debug "RED: "+Str(CReduceEnergy   )
        
        Creatures(i)\Age + 1
        
        If Creatures(i)\NumCells > 0
          If  Creatures(i)\Age % ((GlobalVar\CREATURE_METABOLISM_RATE / Creatures(i)\NumCells) + 1) = 1 And Random(100) > 50 
            If Creatures(i)\OrgEnergy > GlobalVar\OBJECT_FOOD_DEFAULT_SIZE
              X.f = Creatures(i)\X
              Y.f = Creatures(i)\Y  
              AddRest(X.f,Y.f,Random(GlobalVar\OBJECT_REST_MAXLIFETIME * 5), GlobalVar\OBJECT_FOOD_DEFAULT_SIZE)
              Creatures(i)\OrgEnergy - GlobalVar\OBJECT_FOOD_DEFAULT_SIZE
            EndIf
          EndIf  
        EndIf
        
        
      Else
        Real_Creatures - 1
        
        X.f = Creatures(i)\X
        Y.f = Creatures(i)\Y    
        _PlaySound(2)
        Repeat
          If Creatures(i)\OrgEnergy > GlobalVar\OBJECT_FOOD_DEFAULT_SIZE
            
            AddRest(X.f,Y.f,Random(GlobalVar\OBJECT_REST_MAXLIFETIME), GlobalVar\OBJECT_FOOD_DEFAULT_SIZE)
            Creatures(i)\OrgEnergy - GlobalVar\OBJECT_FOOD_DEFAULT_SIZE
          Else
            AddRest(X.f,Y.f,Random(GlobalVar\OBJECT_REST_MAXLIFETIME), Creatures(i)\OrgEnergy)
            Creatures(i)\OrgEnergy = 0
          EndIf
          
        Until Creatures(i)\OrgEnergy <= 0
        Creatures(i)\Used = #False      
        
      EndIf
      
      
    EndIf
    
    
  Next
EndProcedure



Procedure ExecuteObjects()
  CompilerIf #PB_Compiler_OS = #PB_OS_Linux
  CompilerElse
    If GlobalDrawing = #True
      Start3D()
    EndIf  
      
      ;Sprite3DQuality(1)
      
      ;Sprite3DBlendingMode(9, 9) cool
    CompilerEndIf
    
    ;StartDrawing(ScreenOutput())
    For i = 0 To Objects_Count -1
      
      *Object.OBJECT= Objects(i)
      
      If  *Object\Used
        
        Type =  *Object\Type       
        
        *Object\X + Sin( *Object\Angle) *  *Object\Speed
        *Object\Y + Cos( *Object\Angle) *  *Object\Speed  
        
        
        ;If X<0                :*Object\X = 0:*Object\Angle = Random(3600)/3600 * 2 * #PI:EndIf
        ;If X=>#AREA_WIDTH     :*Object\X = #AREA_WIDTH:*Object\Angle = Random(3600)/3600 * 2 * #PI:EndIf  
        ;If Y<0                :*Object\Y = 0:*Object\Angle = Random(3600)/3600 * 2 * #PI:EndIf
        ;If Y=>#AREA_HEIGHT    :*Object\Y = #AREA_HEIGHT:*Object\Angle = Random(3600)/3600 * 2 * #PI:EndIf 
        
        If *Object\X < -1
          newX = *Object\X
          newX = #AREA_WIDTH + newX % #AREA_WIDTH      
          *Object\X = newX
        EndIf
        If *Object\X > #AREA_WIDTH
          newX = *Object\X    
          newX % #AREA_WIDTH
          *Object\X = newX
        EndIf
        
        If *Object\Y < -1
          newY = *Object\Y
          newY = #AREA_HEIGHT + newY % #AREA_HEIGHT    
          *Object\Y = newY
        EndIf
        If *Object\Y > #AREA_HEIGHT
          newY = *Object\Y    
          newY % #AREA_HEIGHT
          *Object\Y = newY
        EndIf 
        
        X.f =  *Object\X
        Y.f =  *Object\Y     
        
        If GlobalDrawing = #True  
          Select Type
            Case #OBJECT_FOOD
              If GadGet\state\FOOD
                ;Circle(X,Y, 3, #Green)
                ;
                
                CompilerIf #PB_Compiler_OS = #PB_OS_Linux
                  DisplayTransparentSprite(Sprite\FOOD,X,Y)
                CompilerElse
                  DisplaySprite3D(Sprite\FOOD3D,X,Y,GlobalVar\Object_Trans)
                CompilerEndIf
              EndIf
            Case #OBJECT_VIRUS
              If GadGet\state\VIRUS
                ;Circle(X,Y, 2, #Black)
                
                
                CompilerIf #PB_Compiler_OS = #PB_OS_Linux
                  DisplayTransparentSprite(Sprite\VIRUS,X,Y)
                CompilerElse
                  DisplaySprite3D(Sprite\VIRUS3D,X,Y,GlobalVar\Object_Trans)
                CompilerEndIf
              EndIf
            Case #OBJECT_DNA
              If GadGet\state\DNA
                ;Circle(X,Y, 3, #Red)
                
                
                CompilerIf #PB_Compiler_OS = #PB_OS_Linux
                  DisplayTransparentSprite(Sprite\DNA,X,Y)
                CompilerElse
                  *Object\Rotation+1+Random(1)
                  RotateSprite3D(Sprite\DNA3D,*Object\Rotation,0)
                  DisplaySprite3D(Sprite\DNA3D,X,Y,GlobalVar\Object_Trans)
                CompilerEndIf
              EndIf
            Case #OBJECT_POISON
              If GadGet\state\POISON
                ;Circle(X,Y, 3, #Magenta)
                ;
                
                CompilerIf #PB_Compiler_OS = #PB_OS_Linux
                  DisplayTransparentSprite(Sprite\POISON,X,Y)
                CompilerElse
                  DisplaySprite3D(Sprite\POISON3D,X,Y,GlobalVar\Object_Trans)
                CompilerEndIf
              EndIf
            Case #OBJECT_MSG
              If GadGet\state\msg
                ;Circle(X,Y, 3, #White)
                ;
                
                CompilerIf #PB_Compiler_OS = #PB_OS_Linux
                  DisplayTransparentSprite(Sprite\msg,X,Y)
                CompilerElse
                  DisplaySprite3D(Sprite\MSG3D,X,Y,GlobalVar\Object_Trans)
                CompilerEndIf
              EndIf
            Case #OBJECT_REST
              If GadGet\state\REST
                ;Circle(X,Y ,3, RGB(192,128,0))
                ;
                
                CompilerIf #PB_Compiler_OS = #PB_OS_Linux
                  DisplayTransparentSprite(Sprite\REST,X,Y)
                CompilerElse
                  DisplaySprite3D(Sprite\REST3D,X,Y,GlobalVar\Object_Trans)
                CompilerEndIf
              EndIf
          EndSelect   
        EndIf
        If Type <> #OBJECT_FOOD
          *Object\LifeTime -1
          If *Object\LifeTime <= 0
            
            If *Object\Type = #OBJECT_REST
              *Object\Type = #OBJECT_FOOD
            Else
              *Object\Used = #False
            EndIf
            
          EndIf
        EndIf      
      EndIf
      
    Next
    CompilerIf #PB_Compiler_OS = #PB_OS_Linux
    CompilerElse
      If GlobalDrawing = #True
      Stop3D()
    EndIf
  CompilerEndIf
  
  ;;Debug pp
  ;StopDrawing()
EndProcedure

Enumeration
  #Pannel
  ;Drawing
  #CheckBox_FOOD
  #CheckBox_VIRUS
  #CheckBox_DNA
  #CheckBox_POISON
  #CheckBox_MSG
  #CheckBox_REST
  #CheckBox_Creature
  ;Statistic
  #TEXT_FPS
  #CheckBox_Break
  #TEXT_Timer
  #TEXT_Creatures
  #TEXT_FOOD
  #TEXT_VIRUS
  #TEXT_DNA
  #TEXT_POISON
  #TEXT_MSG
  #TEXT_REST
  #TEXT_ObjTrans
  #TEXT_IMG_Creatures
  #TEXT_IMG_FOOD
  #TEXT_IMG_VIRUS
  #TEXT_IMG_DNA
  #TEXT_IMG_POISON
  #TEXT_IMG_MSG
  #TEXT_IMG_REST
  #TEXT_CreatureDebug
  #TEXT_CreatureDName
  #TEXT_CreatureDAuthor
  #TEXT_CreatureDEnergy
  #TEXT_CreatureDOrgEnergy
  #TEXT_MostCreatures1
  #TEXT_MostCreatures2
  #TEXT_MostCreatures3
  #RR_Logo
  #RR_Logo_HP
  #Option_SingleCore
  #Option_MultiCore
  #Track_Mutation
  #Text_Track_Mutation
  #CheckBox_Sounds
  #Text_Threads
  #Threads
  #Track_ObjTrans
  #Background
  #Text_MinimalCreatures
  #MinimalCreatures
  #CreateCreature_Load
  #CreateCreature_Save
  #CreateCreature_Cancel
  #CreateCreature_Compile
  #CreateCreature_Change
  #CreateCreature_Tab
  #CreateCreature_EnergyText
  #CreateCreature_EnergyStr
  #CreateCreature_CellsText
  #CreateCreature_CellsStr
  #CreateCreature_XText
  #CreateCreature_XStr
  #CreateCreature_YText
  #CreateCreature_YStr
  #CreateCreature_ColorText
  #CreateCreature_ColorShow
  #CreateCreature_ColorEdit
  #CreateCreature_CreatureIDText
  #CreateCreature_CreatureIDStr
  #CreateCreature_CreatureNameStr
  #CreateCreature_CreatureName
  #CreateCreature_CreatureAuthorStr
  #CreateCreature_CreatureAuthor
  #CreateCreature_CreatureDescriptionStr
  #CreateCreature_CreatureDescription
  #CreateCreature_CheckMutation
  #CreateCreature_Info
  #CreateCreature_Upload
  #CreateCreature_IncCreatureIDText
  #CreateCreature_IncCreatureIDStr
  #About_Image
  #About_Editor
  #About_OK
  #Options_Panel
  #Options_OK
  #Options_Cancel
  #Options_Creature_Area
  #Options_Object_Area
  #Options_Mutation_Area
  #Options_CodeProbability_Area
  #Options_Standard
  #Splashscreen_Image
  #Text_Option_RightM
  #Option_RightM_FOOD
  #Option_RightM_VIRUSES
  #Option_RightM_DNA 
  #Option_RightM_POISON
  #Option_RightM_Delete
  #CC_MOVE_FORWARD
  #CC_MOVE_BACKWARD
  #CC_MOVE_CANCEL
  #CC_MOVE_INSERT
  #CC_ROTATE_LEFT
  #CC_ROTATE_RIGHT
  #CC_ROTATE_MSG
  #CC_ROTATE_POISON
  #CC_ROTATE_DNA
  #CC_ROTATE_FOOD
  #CC_ROTATE_ANTI_MSG
  #CC_ROTATE_ANTI_DNA
  #CC_ROTATE_ANTI_POISON
  #CC_ROTATE_ANTI_FOOD
  #CC_ROTATE_CANCEL
  #CC_ROTATE_INSERT
  #CC_ROTATE_ENEMY
  #CC_ROTATE_ANTI_ENEMY
  #CC_ROTATE_DEST_POINT
  #CC_ROTATE_ANTI_DEST_POINT
  #CC_IF_CANCEL
  #CC_IF_INSERT
  #CC_IF_ENERGY_GREATER
  #CC_IF_ENERGY_LESS
  #CC_IF_ENERGY_EQUAL
  #CC_IF_ENERGYINC_GREATER
  #CC_IF_ENERGYDEC_GREATER
  #CC_IF_MSG_GREATER
  #CC_IF_MSG_LESS
  #CC_IF_MSG_EQUAL
  #CC_IF_FOOD_GREATER
  #CC_IF_FOOD_LESS
  #CC_IF_FOOD_EQUAL
  #CC_IF_POISON_GREATER
  #CC_IF_POISON_LESS
  #CC_IF_POISON_EQUAL
  #CC_IF_POISONID_GREATER
  #CC_IF_POISONID_LESS
  #CC_IF_POISONID_EQUAL
  #CC_IF_DNA_GREATER
  
  #CC_IF_DNA_LESS
  #CC_IF_DNA_EQUAL
  #CC_IF_VARIABLE_GREATER
  #CC_IF_VARIABLE_LESS
  #CC_IF_VARIABLE_EQUAL
  #CC_IF_CELL_RAD_GREATER
  #CC_IF_CELL_RAD_LESS
  #CC_IF_CELL_RAD_EQUAL
  #CC_IF_X_GREATER
  #CC_IF_X_LESS
  #CC_IF_X_EQUAL
  #CC_IF_Y_GREATER
  #CC_IF_Y_LESS
  #CC_IF_Y_EQUAL
  #CC_IF_ENEMYABS_GREATER
  #CC_IF_ENEMYABS_LESS
  #CC_IF_ENEMYABS_EQUAL
  #CC_IF_CMP_ENEMY_GREATER
  #CC_IF_CMP_ENEMY_LESS
  #CC_IF_CMP_ENEMY_EQUAL
  #CC_IF_GENERATION_GREATER
  #CC_IF_GENERATION_LESS
  #CC_IF_GENERATION_EQUAL
  #CC_IF_NUMOFCELLS_GREATER
  #CC_IF_NUMOFCELLS_LESS
  #CC_IF_NUMOFCELLS_EQUAL
  #CC_IF_CELLNUMER_GREATER
  #CC_IF_CELLNUMER_LESS
  #CC_IF_CELLNUMER_EQUAL
  #CC_IF_MALE
  #CC_IF_FEMALE
  #CC_IF_AGE_GREATER
  #CC_IF_AGE_LESS
  #CC_IF_AGE_EQUAL
  #CC_IF_ABSORBABLE
  
  #CC_IF_Str_ENERGY_GREATER
  #CC_IF_Str_ENERGY_LESS
  #CC_IF_Str_ENERGY_EQUAL
  #CC_IF_Str_ENERGYINC_GREATER
  #CC_IF_Str_ENERGYDEC_GREATER
  #CC_IF_Str_MSG_GREATER
  #CC_IF_Str_MSG_LESS
  #CC_IF_Str_MSG_EQUAL
  #CC_IF_Str_FOOD_GREATER
  #CC_IF_Str_FOOD_LESS
  #CC_IF_Str_FOOD_EQUAL
  #CC_IF_Str_POISON_GREATER
  #CC_IF_Str_POISON_LESS
  #CC_IF_Str_POISON_EQUAL
  #CC_IF_Str_POISONID_GREATER
  #CC_IF_Str_POISONID_LESS
  #CC_IF_Str_POISONID_EQUAL
  #CC_IF_Str_DNA_GREATER
  #CC_IF_Str_DNA_LESS
  #CC_IF_Str_DNA_EQUAL
  #CC_IF_Str_VARIABLE_GREATER
  #CC_IF_Str_VARIABLE_LESS
  #CC_IF_Str_VARIABLE_EQUAL
  #CC_IF_Str_CELL_RAD_GREATER
  #CC_IF_Str_CELL_RAD_LESS
  #CC_IF_Str_CELL_RAD_EQUAL
  #CC_IF_Str_X_GREATER
  #CC_IF_Str_X_LESS
  #CC_IF_Str_X_EQUAL
  #CC_IF_Str_Y_GREATER
  #CC_IF_Str_Y_LESS
  #CC_IF_Str_Y_EQUAL
  #CC_IF_Str_ENEMYABS_GREATER
  #CC_IF_Str_ENEMYABS_LESS
  #CC_IF_Str_ENEMYABS_EQUAL
  #CC_IF_Str_CMP_ENEMY_GREATER
  #CC_IF_Str_CMP_ENEMY_LESS
  #CC_IF_Str_CMP_ENEMY_EQUAL
  #CC_IF_Str_GENERATION_GREATER
  #CC_IF_Str_GENERATION_LESS
  #CC_IF_Str_GENERATION_EQUAL
  #CC_IF_Str_NUMOFCELLS_GREATER
  #CC_IF_Str_NUMOFCELLS_LESS
  #CC_IF_Str_NUMOFCELLS_EQUAL
  #CC_IF_Str_CELLNUMER_GREATER
  #CC_IF_Str_CELLNUMER_LESS
  #CC_IF_Str_CELLNUMER_EQUAL
  #CC_IF_Str_MALE
  #CC_IF_Str_FEMALE
  #CC_IF_Str_AGE_GREATER
  #CC_IF_Str_AGE_LESS
  #CC_IF_Str_AGE_EQUAL
  #CC_IF_Str_ABSORBABLE
  #CC_IF_AreaGadget
  #CC_ATTACK_CANCEL
  #CC_ATTACK_INSERT
  #CC_ATTACK_POISON
  #CC_ATTACK_VIRUS
  #CC_ATTACK_VIRUS_POS
  #CC_ATTACK_POISON_STR
  #CC_ATTACK_VIRUS_STR
  #CC_ATTACK_VIRUS_POS_STR
  #CC_ATTACK_DNA
  #CC_ATTACK_DNA_STR
  #CC_ATTACK_DNA_POS
  #CC_ATTACK_DNA_POS_STR
  #CreateCreature_Preview_Image
  #CreateCreature_Preview_Scale_Text
  #CreateCreature_Preview_Scale_Str
  #CreateCreature_Preview_Scale_Button
  #CreateCreature_Preview_Area
  #CreateCreature_Preview_Preview_Text
  #CreateCreature_Preview_Preview_Text_2
  #CreateCreature_Preview_Image_2
  #CreateCreature_Preview_OrgRadius_Button
  #CreateCreature_Preview_RndRadius_Button
  #CC_CLONE_MIN_ENERGY
  #CC_CLONE_MIN_ENERGY_STR
  #CC_CLONE_CLONE
  #CC_CLONE_COPY50_50
  #CC_CLONE_COPY25_75
  #CC_CLONE_COPY5_95
  #CC_CLONE_COMBINECOPY
  #CC_CLONE_CANCEL
  #CC_CLONE_INSERT
  #UPLOAD_UPLOAD
  #UPLOAD_CANCEL
  #UPLOAD_NAME
  #UPLOAD_NAME_STR
  #UPLOAD_AUTHOR
  #UPLOAD_AUTHOR_STR
  #UPLOAD_DESC
  #UPLOAD_DESC_STR
  #UPLOAD_IP
  #UPLOAD_CHECKBOX
  #CreateCreature_Male
  #CreateCreature_FeMale
  #MDL_WebGadget
  #Text_Ticks
  #Ticks
  #CheckBox_Reducecpuusage
  #View3D
  #View3D_Help
  #Screen
  #CC_MOVE_FORWARD2X
  #InsertCreates_Area
  #InsertCreates_Ok
  #InsertCreates_Cancel
  #InsertCreates_Energy_Text
  #InsertCreates_Energy_Str
  #InsertCreates_CellAdd_Energy_Text
  #InsertCreates_CellAdd_Energy_Str
  #InsertCreates_Opt_DisableMutation
  #InsertCreates_Opt_EnableMutation
  #InsertCreates_Opt_OrginalMutation
  #Creature_Generator_Random
  #Creature_Generator_Random_Text
  #Creature_Generator_CopyMinEnergy
  #Creature_Generator_CopyMinEnergy_Text
  #Creature_Generator_ProtectionLevel
  #Creature_Generator_ProtectionLevel_Text
  #Creature_Generator_CopyMode
  #Creature_Generator_CopyMode_Text
  #Creature_Generator_AggressiveLevel
  #Creature_Generator_AggressiveLevel_Text
  #Creature_Generator_AttackMode
  #Creature_Generator_AttackMode_Text
  #Creature_Generator_DNAAttackMode
  #Creature_Generator_DNAAttackMode_Text
  #Creature_Generator_Speed
  #Creature_Generator_Speed_Text
  #Creature_Generator_RotateEnemyFast
  #Creature_Generator_OnlyBigCellsCanEmitPoison
  #Creature_Generator_EmitPoisonToEnemy
  #Creature_Generator_NumCells
  #Creature_Generator_NumCells_Text
  #Creature_Generator_Cancel
  #Creature_Generator_Generate
  #CreateCreature_Setting_Container
  #Report_Mail_Text
  #Report_Mail_Str
  #Report_Mail_to_Text
  #Report_Subject_Text
  #Report_Subject_Str
  #Report_Text_Str
  #Report_Text_Text
  #Report_Send
  
EndEnumeration

Enumeration
  #Menu_Load
  #Menu_SaveAs
  #Menu_Quit
  #Menu_About
  #Menu_Help
  #Menu_Report
  #Menu_GermanHelp
  #Menu_New
  #Menu_ADDFOOD
  #Menu_ADDVIEREN
  #Menu_Download_Insert
  #Menu_InsertCreatures
  #Menu_Random_Creature
  #Menu_Creature_Generator
  #Menu_Options
  #Menu_Creature_Edit
  #Menu_Creature_Kill  
  #Menu_Creature_Delete
  #Menu_Creature_KillAll
  #Menu_Creature_DeleteAll
  #Menu_Modus_GamingMode
  #Menu_Modus_EvolutionMode
  #Menu_Homepage
  #Menu_Forum
  #Menu_MakeScreenshot
  #Menu_SearchUpdate
  #Menu_Language_English
  #Menu_Language_German
  #Menu_Language_Franz
  ;letztes
  #Menu_OwnCreature
EndEnumeration

Enumeration
  #ToolBar_Move
  #ToolBar_IF
  #ToolBar_Attack
  #ToolBar_Clone
  
  #Menu_Cut  
  #Menu_Copy
  #Menu_Paste
  #Menu_SelectAll
  #Menu_Undo      
  #Menu_Redo 
  ;Last
  #ToolBar_Rotate
EndEnumeration

Structure Insert
  File.s
  id.l
EndStructure

Global Dim InsertCreature.Insert(10000)
Global MaxInsert = 0
Global Menu_Image_Insert

Global FPS_Start
Global FPS_Count
Global fps
Global StartTimer
Global oldabs=-1
Global SchowCreatureIndex
Global RightMButton
Global Splashscreen_Start.l

Declare LoadCreateCreatureSettings_fromCreature(*Creature.CREATURE)
Global TempCreature.CREATURE
Global *OrgCreature.CREATURE
Global CreatureCellCount.l

Global Dim Statistic(#OBJECT_REST)
Global FPS_Count
Structure ADDOptions
  Sid.l
  TID.l
  ADD.l
  Type.l
EndStructure
Global ADDOptionsBoxCount
Global ADDOptionsBoxMaxCount
Global Dim ADDOptionsBoxArr.ADDOptions(1000)
Global ADDOptionsBoxCount_Pr
Global ADDOptionsBoxMaxCount_Pr
Global Dim ADDOptionsBoxArr_Pr.ADDOptions(1000)
Global ID_Count
Global CreateCreature_Preview_Image = 0
Global CreateCreature_Preview_Image_2 = 0
Global NoPreview = 1
Global OldPreColor
Global MakeScreenshot = #False
Global View3D = #False
Global oldView3D = #False
Global oldGlobalDrawing = #True
Global HideWindow=#False

Structure Preview
  cell.l
  Radius.l
  Radius_Str.l
  OrgRadius.l
  OrgRadius_Str.l
EndStructure
Global Dim CC_Preview.Preview(50)

Global *CreatureW.CREATURE

Global LastUploadError.s
Global LastDownloadError.s




IncludeFile "Data/gui.pbi"
CompilerIf #PB_Compiler_OS = #PB_OS_Linux
CompilerElse
  Procedure ErrorHandler() 
    msg.s=ErrorMessage()+Chr(13)+Chr(10)
    msg.s+ReadPreferenceString_(languagefile, "text", "Line")+": "+Str(ErrorLine())+Chr(13)+Chr(10)
    msg+ReadPreferenceString_(languagefile, "text", "Kill-Program")

    erg = MessageRequester(ReadPreferenceString_(languagefile, "text", "Error"), msg,#PB_MessageRequester_YesNo|#MB_ICONERROR) 
    If erg = #PB_MessageRequester_Yes
    _SaveScene("Autosave.LCF")    
      End 
    Else
      Restart()
    EndIf 
  EndProcedure
;  OnErrorCall(@ErrorHandler())
CompilerEndIf







SetGlobalVar_GamingMode()
GlobalVar\StartTimer=ElapsedMilliseconds()

InitKeyboard()
InitSprite()
UsePNGImageDecoder()
UsePNGImageEncoder()
ZPAC_Init(#True)
InitNetwork()
InitMouse()
If InitSound()=#False:GlobalSound.l = #False:GlobalSoundOn = #False:EndIf


;UseOGGSoundDecoder()
_LoadSound(1,Datapath+"1.wav");_CreateSpotFX(202,200,1,1)
_LoadSound(2,Datapath+"2.wav");_CreateSpotFX(291,190,1,2)


CompilerIf #PB_Compiler_OS = #PB_OS_Linux
  CompilerIf #Use_Linux_OpenGL=#False
  OpenWindow(#Window_Main, 100, 0, 213, 500, "Living Code V"+#VERSION, #PB_Window_SystemMenu|#PB_Window_MinimizeGadget)
  OpenWindowedScreen(#Window_Screen, 260, 0, 640, 480, 0, 0, 0)
  
  ;OpenWindow(#Window_Main, 100, 0, 880, 500, "Living Code V"+#VERSION, #PB_Window_SystemMenu|#PB_Window_MinimizeGadget)
  ;OpenWindowedScreen(WindowID(#Window_Main), 230, 0, 640, 480, 0, 0, 0)
  CompilerElse
  InitSprite3D()
  OpenWindow(#Window_Main, 100, 0, 880, 500, "Living Code V"+#VERSION, #PB_Window_SystemMenu|#PB_Window_MinimizeGadget)
  OpenWindowedScreen(WindowID(#Window_Main), 230, 0, 640, 480, 0, 0, 0)
  CompilerEndIf
  UseMultiCore=#False
CompilerElse
  If UseMultiCore=#True
    Worker_Create()
  EndIf
  InitScintilla("Data\SciLexer.dll")
  InitSprite3D()
  
  
  OpenWindow(#Window_Main, 0, 0, 850, 500, "Living Code V" + #VERSION + "  - " + GlobalVarMode, #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_MinimizeGadget)
  
  ;ContainerGadget(#Screen,0,0,#area_width,#area_width)
  ;CloseGadgetList()
  ;UseGadgetList(WindowID(#Window_Main))
  ;OpenWindowedScreen(GadgetID(#Screen), 0, 0, #area_width, #area_width, 0, 0, 0)
  OpenWindowedScreen(WindowID(#Window_Main), 0, 0, 640, 480, 0, 0, 0)
  Sprite3DQuality(#PB_Sprite3D_BilinearFiltering)
  SetFileType(ProgramFilename(),".LCF")
  SetFileType(ProgramFilename(),".CRF")
CompilerEndIf
OpenSplashscreen()


Sprite\BK = LoadSprite(#PB_Any,Datapath+"bk2.png")
DisplaySprite(Sprite\BK, 0, 0)
CreateGUI()
SetFrameRate(10000)

Sprite\Game_Logo = LoadImage(#PB_Any,Datapath+"Logo.png")

Sprite\Img_Ok = LoadImage(#PB_Any,Datapath+"ok.png")
Sprite\Img_Cheater = LoadImage(#PB_Any,Datapath+"cheater.png")
Sprite\Img_empty = LoadImage(#PB_Any,Datapath+"empty.png")


CompilerIf #PB_Compiler_OS = #PB_OS_Linux
  Sprite\DNA   = LoadSprite(#PB_Any,Datapath+"DNA.bmp")
  Sprite\msg   = LoadSprite(#PB_Any,Datapath+"MSG.bmp")
  Sprite\VIRUS = LoadSprite(#PB_Any,Datapath+"Virus.bmp")
  Sprite\FOOD   = LoadSprite(#PB_Any,Datapath+"Food.bmp")
  Sprite\POISON  = LoadSprite(#PB_Any,Datapath+"Poison.bmp")
  Sprite\REST = LoadSprite(#PB_Any,Datapath+"Rest.bmp")
  Sprite\MOUSE = LoadSprite(#PB_Any,Datapath+"Mouse.png")
CompilerElse
  Sprite\DNA   = LoadSprite(#PB_Any,Datapath+"texture_dna16x16.png",#PB_Sprite_Texture|#PB_Sprite_AlphaBlending)
  Sprite\msg   = LoadSprite(#PB_Any,Datapath+"texture_msg16x16.png",#PB_Sprite_Texture|#PB_Sprite_AlphaBlending)
  Sprite\VIRUS = LoadSprite(#PB_Any,Datapath+"texture_virus16x16.png",#PB_Sprite_Texture|#PB_Sprite_AlphaBlending)
  Sprite\FOOD   = LoadSprite(#PB_Any,Datapath+"texture_food16x16.png",#PB_Sprite_Texture|#PB_Sprite_AlphaBlending)
  Sprite\POISON  = LoadSprite(#PB_Any,Datapath+"texture_poison16x16.png",#PB_Sprite_Texture|#PB_Sprite_AlphaBlending)
  Sprite\REST = LoadSprite(#PB_Any,Datapath+"texture_rest16x16.png",#PB_Sprite_Texture|#PB_Sprite_AlphaBlending)
  
  Sprite\DNA3D   = CreateSprite3D(#PB_Any,Sprite\DNA)
  Sprite\MSG3D   = CreateSprite3D(#PB_Any,Sprite\msg)
  Sprite\VIRUS3D = CreateSprite3D(#PB_Any,Sprite\VIRUS)
  Sprite\FOOD3D   = CreateSprite3D(#PB_Any,Sprite\FOOD)
  Sprite\POISON3D  = CreateSprite3D(#PB_Any,Sprite\POISON)
  Sprite\REST3D = CreateSprite3D(#PB_Any,Sprite\REST)
  
  Sprite\Texture_Crature2 = LoadSprite(#PB_Any,"Data\Texture_Creature2.png",#PB_Sprite_Texture|#PB_Sprite_AlphaBlending)
  Sprite\Texture_Crature23D = CreateSprite3D(#PB_Any,Sprite\Texture_Crature2)
  Sprite\Texture_CratureHover = LoadSprite(#PB_Any,"Data\Texture_CreatureHover.png",#PB_Sprite_Texture|#PB_Sprite_AlphaBlending)
  Sprite\Texture_Crature3DHover = CreateSprite3D(#PB_Any,Sprite\Texture_CratureHover)
      
  CompilerIf #Use3DView = #True
    Sprite\Texture_Ground = LoadSprite(#PB_Any,"Data\Ground.png",#PB_Sprite_Texture)
    Sprite\Texture_Crature = LoadSprite(#PB_Any,"Data\Texture_Creature.png",#PB_Sprite_Texture)
    
    

    Sprite\Texture_Sky = LoadSprite(#PB_Any,"Data\Sky.png",#PB_Sprite_Texture)
    TransparentSpriteColor(-1, RGB(255,0,255))
    Sprite\Texture_Virus = LoadSprite(#PB_Any,"Data\Texture_Virus.png",#PB_Sprite_Texture)
    Sprite\Texture_DNA = LoadSprite(#PB_Any,"Data\Texture_DNA.png",#PB_Sprite_Texture)
    Sprite\Texture_Food = LoadSprite(#PB_Any,"Data\Texture_Food.png",#PB_Sprite_Texture)
    Sprite\Texture_Poison = LoadSprite(#PB_Any,"Data\Texture_Poison.png",#PB_Sprite_Texture)
    Sprite\Texture_Rest = LoadSprite(#PB_Any,"Data\Texture_Rest.png",#PB_Sprite_Texture)
;     Sprite\Texture_Virus = Sprite\VIRUS
;     Sprite\Texture_DNA = Sprite\DNA
;     Sprite\Texture_Food = Sprite\FOOD
;     Sprite\Texture_Poison = Sprite\POISON
;     Sprite\Texture_Rest = Sprite\REST

    TransparentSpriteColor(-1, 0)
    
    S3DR_CreateZBuffer() 
    Start3D()
      Sprite3DQuality(1)
      S3DR_BeginReal3D()
      S3DR_SetCameraPos(0,50,0) 
      S3DR_SetCameraAngles(#PI/4,#PI/4,0)
      S3DR_MoveCamera(0,0,-12) 
      S3DR_SetCameraRangeAndFOV(1, 1000.0,90)
      S3DR_UseFog(1,100.1,1000,RGB(200,200,255))
      S3DR_EndReal3D()
    Stop3D() 
    
    
    
    
  CompilerEndIf
CompilerEndIf


For X=0 To 640 Step 20
  For Y=0 To 480 Step 20
    AddFood(X,Y,GlobalVar\OBJECT_FOOD_DEFAULT_SIZE * 4)
  Next
Next



oldabs = -1
SelectedCreatureColor=0


Parameter.s = ProgramParameter(0)
If Parameter<>""
  If FindString(UCase(Parameter),".LCF",1)
    _loadscene(Parameter)
  EndIf
  If FindString(UCase(Parameter),".CRF",1)
    LoadCreateCreatureSettings_FromFile(Parameter)
  EndIf
  
EndIf

Repeat

  Delay(0)
  
  If GlobalVar\Reducecpuusage=#True
    Delay(GlobalVar\ExecuteCount/2)
  EndIf

  Counter +1
  SetStatistics()

  ExamineKeyboard()

  Events_Splashscreen()

  ;CompilerIf #PB_Compiler_OS = #PB_OS_Linux
  ;  SDL_GetMouseState_(@MousePosX,@MousePosY)
  ;CompilerElse
    MousePosX = WindowMouseX(#Window_Main)
    MousePosY = WindowMouseY(#Window_Main)
  ;CompilerEndIf
  
  If GadGet\state\Break_Game = #False

    If View3D = #False
      EventsRightMButton()
    EndIf
    
    If GlobalDrawing = #True
      ClearScreen(RGB(0,0,0))
      DisplaySprite(Sprite\BK, 0, 0)
      CompilerIf #PB_Compiler_OS = #PB_OS_Linux
      CompilerElse
        RotateSprite3D(Sprite\VIRUS3D,2,1)
      CompilerEndIf
    EndIf 
 
    state = GlobalDrawing
    If GlobalVar\ExecuteCount>=1
      GlobalDrawing = #False
      For i=2 To GlobalVar\ExecuteCount
        ExecuteObjects() 
      Next
      GlobalDrawing = state
    EndIf
    If GlobalVar\ExecuteCount>0
    ExecuteObjects() 
    EndIf

    CompilerIf #PB_Compiler_OS = #PB_OS_Linux
      
      ResetCreaturesCount()
      If Counter % 25 = 0  ; Optimieren
        CalcLastCreature()
        CalcLastObject()
      EndIf
      For i=1 To GlobalVar\ExecuteCount
        ExecuteCreatures()
      Next
    CompilerElse
      
      If UseMultiCore=#True
        Worker_Wait()    
      EndIf
      ResetCreaturesCount()
      If Counter % 25 = 0  ; Optimieren
        CalcLastCreature()
        CalcLastObject()
      EndIf
      
      For i=1 To GlobalVar\ExecuteCount
        If UseMultiCore=#True
          ExecuteCreatures_Async()
        Else
          ExecuteCreatures()
        EndIf
      Next
    CompilerEndIf
    
    If GlobalDrawing = #True
      DrawCreatures()
    EndIf

    If View3D = #False And GlobalDrawing = #True
      CompilerIf #PB_Compiler_OS = #PB_OS_Linux
        If SDL_GetMouseState_(@X11,@Y11)
          x2=X11
          y2=Y11
        CompilerElse
        If GetAsyncKeyState_(#VK_LBUTTON)
          x2 = MousePosX
          y2 = MousePosY   
        CompilerEndIf
        
        If x2>-1 And y2>-1 And x2<640 And y2<480
          oldabs = -1
          For i=0 To Creatures_Count -1
            
            *Creature.CREATURE = Creatures(i)
            
            If *Creature\Used
              
              x1 = *Creature\X
              y1 = *Creature\Y
              
              
              Abs = Sqr(Pow(x1-x2,2)+Pow(y1-y2,2))

              If Abs < oldabs Or oldabs = -1
                oldabs = Abs
                SchowCreatureIndex = i
                SetGadgetText(#TEXT_CreatureDName, ReadPreferenceString_(languagefile, "text", "Name")+": " + Creatures(SchowCreatureIndex)\CreatureName)
                SetGadgetText(#TEXT_CreatureDAuthor, ReadPreferenceString_(languagefile, "text", "Author")+": " + Creatures(SchowCreatureIndex)\Author)
                SetGadgetText(#TEXT_CreatureDEnergy, ReadPreferenceString_(languagefile, "text", "Energy")+": " + Str(Creatures(SchowCreatureIndex)\Energy))
                
              EndIf
            EndIf
          Next
        EndIf
      EndIf
    EndIf

    If  oldabs <> -1
      If Creatures(SchowCreatureIndex)\Used  
        CompilerIf #DrawCreature_Sprite=#False
        Color = Creatures(SchowCreatureIndex)\Color 
        SelectedCreatureColor+1
        Creatures(SchowCreatureIndex)\Color  = RGB(255,255,255) - Creatures(SchowCreatureIndex)\Color 
        Creatures(SchowCreatureIndex)\Color  = RGB(Red(Creatures(SchowCreatureIndex)\Color)*Sin(SelectedCreatureColor/10),Green(Creatures(SchowCreatureIndex)\Color),Blue(Creatures(SchowCreatureIndex)\Color)*Cos(SelectedCreatureColor/10))
        StartDrawing(ScreenOutput())
          DrawCreature(Creatures(SchowCreatureIndex))
        StopDrawing()
        Creatures(SchowCreatureIndex)\Color = Color
        CompilerElse
        Start3D()
          DrawCreature(Creatures(SchowCreatureIndex),Sprite\Texture_Crature3DHover)
        Stop3D()
        CompilerEndIf
      Else  
        oldabs = -1
      EndIf
      
    EndIf
    
    
  Else
    Delay(10)
  EndIf
  If GlobalDrawing = #True
    CompilerIf #PB_Compiler_OS = #PB_OS_Linux
      If GadGet\state\Break_Game = #False
        SDL_GetMouseState_(@X11,@Y11)
        ;ExamineMouse()
        ;X11=MouseX();#Window_Main)
        ;Y11=MouseY();#Window_Main)
        ;Debug MouseButton(#PB_MouseButton_Left)
        DisplayTransparentSprite(Sprite\MOUSE, X11, Y11)
      EndIf
    CompilerEndIf
    
    If MakeScreenshot = #True
      MakeScreenshot()
      MakeScreenshot = #False
    EndIf
    
    FlipBuffers(0)
  EndIf
  
  erg = IsScreenActive()
  If IsScreenActive <> erg
    If erg=0
      oldView3D = View3D
      oldGlobalDrawing = GlobalDrawing
      GlobalDrawing = erg
      View3D = erg
    Else
      View3D = oldView3D 
      GlobalDrawing = oldGlobalDrawing
    EndIf
    
    IsScreenActive = erg
    If GlobalDrawing = #True And View3D = #True:View3D = #False:EndIf
    If erg=1 And HideWindow=#False
      If GlobalDrawing = #False And View3D = #False:GlobalDrawing = #True:EndIf
    EndIf
    
  EndIf
  If GlobalDrawing = #False  And HideWindow=#False
    Delay(1)
  Else
    If GlobalDrawing = #False  And HideWindow=#True
      Delay(0)
    EndIf       
  EndIf
  

  
  CompilerIf #Use3DView = #True  
    If IsDX7BackBufferLost()
      MessageRequester(ReadPreferenceString_(languagefile, "text", "Error-backbuffer-lost"),ReadPreferenceString_(languagefile, "text", "The-program-must-restart"))
      Restart()
    EndIf
  CompilerEndIf
  
  If GadGet\state\Break_Game = #False
    If View3D = #True
      Events_3DView()
    EndIf
  Else
    Delay(10)
  EndIf
  
  Repeat
    Event = WindowEvent()
    Quit = EventManager(Event)
  Until Event = #False Or Quit = #True
  

   
  
  
Until Quit = #True

CreateFile(1,Datapath+"Options.txt")
WriteStringN(1,Str(GetGadgetState(#Option_MultiCore)))
WriteStringN(1,Str(WORKER_COUNT_TEMP))
WriteStringN(1,languagefile)
CloseFile(1)

CompilerIf #PB_Compiler_OS = #PB_OS_Linux
CompilerElse
  FreeTreeGadgetBkImage()
CompilerEndIf
ZPAC_Free()
; IDE Options = PureBasic 4.30 (Windows - x86)
; Folding = AAAAEEA+
; EnableThread
; EnableXP
; EnableOnError
; UseIcon = Data\Alien_48x48.ico
; Executable = Living-Code.exe
; EnableCompileCount = 5225
; EnableBuildCount = 559
; EnableExeConstant
; Watchlist = Objects_Count;Creatures_Count;Creatures_MaxCount
; IncludeVersionInfo
; VersionField0 = 1,5,0,0
; VersionField1 = 1,5,0,0
; VersionField2 = RRSoftware
; VersionField3 = Living Code
; VersionField4 = 1.50
; VersionField5 = 1.50
; VersionField6 = Living Code - The Evolution for the PB-Lounge Contest
; VersionField7 = Living Code
; VersionField8 = Living Code
; VersionField9 = (c) 2008 RocketRider
; VersionField14 = http://living-code.RRSoftware.de
; VersionField15 = VOS_NT_WINDOWS32
; VersionField16 = VFT_APP
; VersionField18 = Autor
; VersionField19 = Forum
; VersionField21 = RocketRider
; VersionField22 = http://www.RocketRider.eu
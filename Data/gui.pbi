


Procedure SetPreview(Status)
  
  For cell=0 To CreatureCellCount-1
    If Status = 0
      If GetGadgetText(CC_Preview(cell)\Radius_Str) <> GetGadgetText(GadGet\Creature[cell]\CellRandiusStr)
        SetGadgetText(CC_Preview(cell)\Radius_Str,GetGadgetText(GadGet\Creature[cell]\CellRandiusStr))
      EndIf
      
      If GetGadgetText(CC_Preview(cell)\OrgRadius_Str) <> GetGadgetText(GadGet\Creature[cell]\CellOrgRandiusStr)
        SetGadgetText(CC_Preview(cell)\OrgRadius_Str,GetGadgetText(GadGet\Creature[cell]\CellOrgRandiusStr))
      EndIf
      
    Else
      
      If GetGadgetText(GadGet\Creature[cell]\CellRandiusStr) <> GetGadgetText(CC_Preview(cell)\Radius_Str)
        
        SetGadgetText(GadGet\Creature[cell]\CellRandiusStr,GetGadgetText(CC_Preview(cell)\Radius_Str))
      EndIf
      
      If GetGadgetText(GadGet\Creature[cell]\CellOrgRandiusStr) <> GetGadgetText(CC_Preview(cell)\OrgRadius_Str)
        SetGadgetText(GadGet\Creature[cell]\CellOrgRandiusStr,GetGadgetText(CC_Preview(cell)\OrgRadius_Str))
      EndIf
    EndIf
  Next
  
EndProcedure
Procedure CheckPreviewStatus(GadgetID)
  If IsGadget(#CreateCreature_ColorShow) And IsGadget(#CreateCreature_Preview_Image)
  
  For cell=0 To CreatureCellCount-1
    
    If GadgetID = CC_Preview(cell)\Radius_Str Or GadgetID = CC_Preview(cell)\OrgRadius_Str:SetPreview(1):erg=1:EndIf
    If GadgetID = GadGet\Creature[cell]\CellRandiusStr Or GadgetID = GadGet\Creature[cell]\CellOrgRandiusStr:SetPreview(0):erg=1:EndIf
    
  Next
  
  Color =  GetGadgetColor(#CreateCreature_ColorShow,#PB_Gadget_BackColor)
  If Color <> OldPreColor
    erg=1
  EndIf
  
  If erg=1 Or NoPreview = 1
    NoPreview = 0
    StartDrawing(ImageOutput(CreateCreature_Preview_Image))
      rad.Pre_Radius
      
      For cell=0 To CreatureCellCount-1
        rad\Radius[cell]=Val(GetGadgetText(CC_Preview(cell)\Radius_Str))
        
        If rad\Radius[cell]>GlobalVar\CREATURE_MAXRADIUS
          rad\Radius[cell]=GlobalVar\CREATURE_MAXRADIUS
        EndIf
        If rad\Radius[cell]<GlobalVar\CREATURE_MINRADIUS
          rad\Radius[cell]=GlobalVar\CREATURE_MINRADIUS
        EndIf
        
      Next
      
      
      Box(0,0,105,105,RGB(80,80,250))
      DrawCreature_Preview(52,52,0,CreatureCellCount,@rad.Pre_Radius,Color)
    StopDrawing()
    SetGadgetState(#CreateCreature_Preview_Image,ImageID(CreateCreature_Preview_Image))
    
    
    
    StartDrawing(ImageOutput(CreateCreature_Preview_Image_2))
      rad.Pre_Radius
      
      For cell=0 To CreatureCellCount-1
        rad\Radius[cell]=Val(GetGadgetText(CC_Preview(cell)\OrgRadius_Str))
        
        If rad\Radius[cell]>GlobalVar\CREATURE_MAXRADIUS
          rad\Radius[cell]=GlobalVar\CREATURE_MAXRADIUS
        EndIf
        If rad\Radius[cell]<GlobalVar\CREATURE_MINRADIUS
          rad\Radius[cell]=GlobalVar\CREATURE_MINRADIUS
        EndIf
        
      Next
      
      
      Box(0,0,105,105,RGB(80,80,250))
      DrawCreature_Preview(52,52,0,CreatureCellCount,@rad.Pre_Radius,Color)
    StopDrawing()
    SetGadgetState(#CreateCreature_Preview_Image_2,ImageID(CreateCreature_Preview_Image_2))
    
    
  EndIf
  
  EndIf
EndProcedure

Procedure ExamineInsert(Path.s,id)
  Dir.l = ExamineDirectory(#PB_Any, Path, "*.*")
  If Dir
    CompilerIf #PB_Compiler_OS = #PB_OS_Linux
      ;OpenSubMenu(RemoveString(Path,"Insert/"))
      OpenSubMenu(StringField(Path,CountString(Path,"/")+1,"/"))
    CompilerElse
      ;OpenSubMenu(RemoveString(Path,"Insert\"))
      OpenSubMenu(StringField(Path,CountString(Path,"\")+1,"\"))
    CompilerEndIf
    
    While NextDirectoryEntry(Dir)
      
      FileName$ = DirectoryEntryName(Dir)
      If DirectoryEntryType(Dir) = #PB_DirectoryEntry_File 
        If FindString(UCase(FileName$),".CRF",1) And FileName$<>"." And FileName$<>".." And FileName$<>"..."
          id+1
          ;Debug FileName$ +"--"+GetCreatureAuthor_FromFile(Path + "/" + FileName$)
 
 
          CompilerIf #PB_Compiler_OS = #PB_OS_Linux
            InsertCreature(ID_Count)\File = Path + "/" + FileName$
          CompilerElse
            InsertCreature(ID_Count)\File = Path + "\" + FileName$
          CompilerEndIf       
          
          
          InsertCreature(ID_Count)\id = id
          FileName$ = RemoveString(FileName$,".CRF",#PB_String_NoCase)
          CompilerIf #PB_Compiler_OS = #PB_OS_Linux
            MenuItem( id, FileName$)
          CompilerElse
            MenuItem( id, FileName$, ImageID(Menu_Image_Insert))
          CompilerEndIf
          ID_Count+1
          
        EndIf  
      EndIf
      
      If DirectoryEntryType(Dir) = #PB_DirectoryEntry_Directory 
        If FileName$<>"." And FileName$<>".." And FileName$<>"..." And FileName$<>".svn"
          CompilerIf #PB_Compiler_OS = #PB_OS_Linux
            id = ExamineInsert(Path+"/"+FileName$,id)
          CompilerElse
            id = ExamineInsert(Path+"\"+FileName$,id)
          CompilerEndIf
        EndIf
      EndIf 
      
    Wend
    
    
    CloseSubMenu()
    FinishDirectory(Dir)
  EndIf
  
  ProcedureReturn id
EndProcedure
Procedure ADDInsert(id)
  ID_Count=0
  CompilerIf #PB_Compiler_OS = #PB_OS_Linux
    Path.s= exePath+"Insert/"
  CompilerElse
    Path.s= "Insert\"
  CompilerEndIf
  
  
  If ExamineDirectory(0, Path, "*.*")
    
    While NextDirectoryEntry(0)
      
      FileName$ = DirectoryEntryName(0)
      If DirectoryEntryType(0) = #PB_DirectoryEntry_File 
        If FindString(UCase(FileName$),".CRF",1) And FileName$<>"." And FileName$<>".." And FileName$<>"..."
          id+1
          InsertCreature(ID_Count)\File = Path + FileName$
          InsertCreature(ID_Count)\id = id
          FileName$ = RemoveString(FileName$,".CRF",#PB_String_NoCase)
          CompilerIf #PB_Compiler_OS = #PB_OS_Linux
            MenuItem( id, FileName$)
          CompilerElse
            MenuItem( id, FileName$, ImageID(Menu_Image_Insert))
          CompilerEndIf
          ID_Count+1
        EndIf  
      EndIf
      If DirectoryEntryType(0) = #PB_DirectoryEntry_Directory 
        If FileName$<>"." And FileName$<>".." And FileName$<>"..." And FileName$<>".svn"
          id = ExamineInsert(Path+FileName$,id)
        EndIf
      EndIf
    Wend
    FinishDirectory(0)
  EndIf
  MaxInsert = ID_Count-1
EndProcedure
Procedure ADDOptionsBox(Text.s,ADD.l,Type.l)
  ADDOptionsBoxArr(ADDOptionsBoxMaxCount)\Type = Type
  ADDOptionsBoxArr(ADDOptionsBoxMaxCount)\ADD = ADD
  If Type = #PB_Long
    ADDOptionsBoxArr(ADDOptionsBoxMaxCount)\Sid = StringGadget(#PB_Any,5,5+ADDOptionsBoxCount*25,70,20,Str(PeekL(ADD)),#PB_String_Numeric)
  EndIf
  If Type = #PB_Float
    ADDOptionsBoxArr(ADDOptionsBoxMaxCount)\Sid = StringGadget(#PB_Any,5,5+ADDOptionsBoxCount*25,70,20,StrF(PeekF(ADD)))
  EndIf
  
  ;ADDOptionsBoxArr(ADDOptionsBoxMaxCount)\SID = SpinGadget(#PB_Any,5,5+ADDOptionsBoxCount*25,70,20,Min,Max,#PB_Spin_Numeric)
  ADDOptionsBoxArr(ADDOptionsBoxMaxCount)\TID = TextGadget(#PB_Any,80,8+ADDOptionsBoxCount*25,320,20,Text)
  
  ADDOptionsBoxMaxCount+1
  ADDOptionsBoxCount+1
EndProcedure
Procedure ADDOptionsBox_probability()
  For code=0 To #CMD_NOP
    Text.s = CodeToCMDString(code)
    If Text<>""
    ADDOptionsBoxArr_Pr(ADDOptionsBoxMaxCount_Pr)\ADD = code
    ADDOptionsBoxArr_Pr(ADDOptionsBoxMaxCount_Pr)\Sid = StringGadget(#PB_Any,5,5+ADDOptionsBoxCount_Pr*25,70,20,Str(GetCodeProbability(code)),#PB_String_Numeric)
    ADDOptionsBoxArr_Pr(ADDOptionsBoxMaxCount_Pr)\TID = TextGadget(#PB_Any,80,8+ADDOptionsBoxCount_Pr*25,320,20,Text)
    ADDOptionsBoxMaxCount_Pr+1
    ADDOptionsBoxCount_Pr+1
    EndIf
  Next
EndProcedure
Procedure SetADDOptionsBoxSettings_Pr()
  For i=0 To ADDOptionsBoxMaxCount_Pr-1
    SetCodeProbability(ADDOptionsBoxArr_Pr(i)\ADD,Val(GetGadgetText(ADDOptionsBoxArr_Pr(i)\Sid)))
  Next
EndProcedure
Procedure SetADDOptionsBoxSettings()
  For i=0 To ADDOptionsBoxMaxCount-1
    If ADDOptionsBoxArr(i)\Type = #PB_Long
      PokeL(ADDOptionsBoxArr(i)\ADD,Val(GetGadgetText(ADDOptionsBoxArr(i)\Sid)))
    EndIf
    If ADDOptionsBoxArr(i)\Type = #PB_Float
      PokeF(ADDOptionsBoxArr(i)\ADD,ValF(GetGadgetText(ADDOptionsBoxArr(i)\Sid)))
    EndIf
  Next
  
  SetADDOptionsBoxSettings_Pr()
  SetGadgetState(#Track_Mutation,GlobalVar\MUTATION_PROBABILITY)
EndProcedure

CompilerIf #PB_Compiler_OS = #PB_OS_Linux
CompilerElse
  Global TreeWindowID, TreeGadgetProcedure, TreehDC, TreemDC, Treem2DC, Treewidth, Treeheight, TreePainting
  Procedure TreeGadgetProcedure(TreehWnd, TreeuMsg, TreewParam, TreelParam)
    erg = 0
    Select TreeuMsg
      Case #WM_PAINT
        If TreePainting=0
          TreePainting = 1
          BeginPaint_(TreehWnd, ps.PAINTSTRUCT)
          erg = CallWindowProc_(TreeGadgetProcedure, TreehWnd, TreeuMsg, Treem2DC, 0)
          BitBlt_(Treem2DC, ps\rcPaint\left, ps\rcPaint\top, ps\rcPaint\right-ps\rcPaint\left, ps\rcPaint\bottom-ps\rcPaint\top, TreemDC, ps\rcPaint\left, ps\rcPaint\top, #SRCAND)
          BitBlt_(Treem2DC, 0, 0, Treewidth, Treeheight, TreemDC, 0, 0, #SRCAND)
          TreehDC = GetDC_(TreehWnd)
          BitBlt_(TreehDC, ps\rcPaint\left, ps\rcPaint\top, ps\rcPaint\right-ps\rcPaint\left, ps\rcPaint\bottom-ps\rcPaint\top, Treem2DC, ps\rcPaint\left, ps\rcPaint\top, #SRCCOPY)
          BitBlt_(TreehDC, 0, 0, Treewidth, Treeheight, Treem2DC, 0, 0, #SRCCOPY)
          ReleaseDC_(TreehWnd, TreehDC)
          EndPaint_(TreehWnd, ps)
          TreePainting = 0
        EndIf
      Case #WM_ERASEBKGND
        erg = 1      
      Default
        erg = CallWindowProc_(TreeGadgetProcedure, TreehWnd, TreeuMsg, TreewParam, TreelParam)
    EndSelect
    ProcedureReturn erg
  EndProcedure
  Procedure SetTreeGadgetBkImage(GadGet,WindowID.l,Image)
    Treewidth=ImageWidth(Image)
    Treeheight=ImageHeight(Image)
    TreeWindowID = WindowID
    
    TreehDC = GetDC_(TreeWindowID)
    TreemDC = CreateCompatibleDC_(TreehDC)
    TreemOldObject = SelectObject_(TreemDC, ImageID(Image))
    Treem2DC = CreateCompatibleDC_(TreehDC)
    TreehmBitmap = CreateCompatibleBitmap_(TreehDC,Treewidth , Treeheight)
    Treem2OldObject = SelectObject_(Treem2DC, TreehmBitmap)
    ReleaseDC_(TreeWindowID, TreehDC)
    TreeGadgetProcedure = SetWindowLong_(GadGet, #GWL_WNDPROC, @TreeGadgetProcedure())
    
  EndProcedure
  Procedure FreeTreeGadgetBkImage()
    SelectObject_(TreemDC, TreemOldObject)
    DeleteDC_(TreemDC)
    SelectObject_(Treem2DC, Treem2OldObject)
    DeleteObject_(TreehmBitmap)
    DeleteDC_(Treem2DC)
  EndProcedure
CompilerEndIf



Procedure ClearScene()
  ;SetGlobalVar()
  
  For i=0 To Creatures_MaxCount
    Creatures(i)\Used = #False
  Next
  
  For i=0 To Objects_MaxCount
    Objects(i)\Used = #False
  Next
  GlobalVar\StartTimer=ElapsedMilliseconds()
  
EndProcedure
Procedure _SaveScene(File.s)
  oldStartTimer = GlobalVar\StartTimer
  GlobalVar\StartTimer = ElapsedMilliseconds()-GlobalVar\StartTimer
  
  If File And File <> ".LCF"
    ;     If CreatePack(File)
    ;       
    ;       
    ;       
    ;       
    ;       len = SizeOf(Long)
    ;       AddPackMemory(@Creatures_Count, len, #Compress_Level)    
    ;       
    ;       If Real_Creatures = 0
    ;         len=1
    ;       Else
    ;         len = Creatures_Count
    ;       EndIf  
    ;       len = SizeOf(CREATURE)*len
    ;       AddPackMemory(@Creatures(0), len, #Compress_Level)
    ;       
    ;       len = SizeOf(Long)
    ;       AddPackMemory(@Objects_Count, len, #Compress_Level)            
    ;       len = SizeOf(OBJECT)*Objects_Count
    ;       AddPackMemory(@Objects(0), len, #Compress_Level)
    ;       
    ;       len = SizeOf(GlobalVar)   
    ;       AddPackMemory(@GlobalVar, len, #Compress_Level)
    ;       
    ;       len = SizeOf(PROBABILITY)*#CMD_NOP
    ;       AddPackMemory(@CodeProbability(0), len, #Compress_Level)
    ;       
    ;       ClosePack()
    ;     Else
    ;       MessageRequester("Error","Can not save the File!")
    ;     EndIf
    If ZPAC_CreatePack(File)
      
      
      
      
      len = SizeOf(Long)
      ZPAC_AddMemoryPack(@Creatures_Count, len, #COMPRESS_LEVEL)    
      
      If Real_Creatures = 0
        len=1
      Else
        len = Creatures_Count
      EndIf  
      len = SizeOf(CREATURE)*len
      ZPAC_AddMemoryPack(@Creatures(0), len, #COMPRESS_LEVEL)
      
      len = SizeOf(Long)
      ZPAC_AddMemoryPack(@Objects_Count, len, #COMPRESS_LEVEL)            
      len = SizeOf(OBJECT)*Objects_Count
      ZPAC_AddMemoryPack(@Objects(0), len, #COMPRESS_LEVEL)
      
      len = SizeOf(GlobalVar)   
      ZPAC_AddMemoryPack(@GlobalVar, len, #COMPRESS_LEVEL)
      
      len = SizeOf(PROBABILITY)*#CMD_NOP
      ZPAC_AddMemoryPack(@CodeProbability(0), len, #COMPRESS_LEVEL)
      
      ZPAC_CloseCreatePack()
    Else
      MessageRequester(ReadPreferenceString_(languagefile, "text", "Error"),ReadPreferenceString_(languagefile, "text", "Can-not-save-File"))
    EndIf
    
    
    
  EndIf
  
  GlobalVar\StartTimer = oldStartTimer
EndProcedure
Procedure SaveScene()
  File.s = SaveFileRequester(ReadPreferenceString_(languagefile, "text", "Save-Scene"),"",ScenePattern,1)
  
  If FindString(GetFilePart(File),".",1) = #False
    File + ".LCF"
  EndIf
  _SaveScene(File)
  
EndProcedure
Procedure _loadscene(File.s)
  
  If File
    
    
    ;     If OpenPack(File)
    ;       ClearScene()
    ;       
    ;       *Pointeur=NextPackFile()
    ;       Taille=PackFileSize()   
    ;       CopyMemory(*Pointeur, @Creatures_Count, Taille)    
    ;       If Creatures_Count > Creatures_MaxCount
    ;         Creatures_MaxCount = Creatures_Count
    ;         ReDim Creatures.CREATURE(Creatures_MaxCount)
    ;       EndIf
    ;       
    ;       *Pointeur=NextPackFile()
    ;       Taille=PackFileSize()   
    ;       CopyMemory(*Pointeur, @Creatures(0), Taille)
    ;       
    ;       *Pointeur=NextPackFile()
    ;       Taille=PackFileSize()   
    ;       CopyMemory(*Pointeur, @Objects_Count, Taille)    
    ;       If Objects_Count > Objects_MaxCount
    ;         Objects_MaxCount = Objects_Count
    ;         ReDim Objects.OBJECT(Objects_MaxCount)
    ;       EndIf
    ;       
    ;       *Pointeur=NextPackFile()
    ;       Taille=PackFileSize()   
    ;       CopyMemory(*Pointeur, @Objects(0), Taille)
    ;       
    ;       *Pointeur=NextPackFile()
    ;       Taille=PackFileSize()   
    ;       CopyMemory(*Pointeur, @GlobalVar, Taille)    
    ;       
    ;       *Pointeur=NextPackFile()
    ;       Taille=PackFileSize()   
    ;       CopyMemory(*Pointeur, @CodeProbability(0), Taille)   
    ;       
    ;       For i = 0 To #CMD_NOP
    ;         CodeProbability(i)\Pos = Pos
    ;         Pos + CodeProbability(i)\Size
    ;       Next
    ;       CompleteCodeProbability = Pos
    ;       
    ;       If IsGadget(#MinimalCreatures)
    ;       SetGadgetState(#MinimalCreatures, GlobalVar\MinimalCreatures)
    ;       EndIf
    ;       
    ;       ClosePack()
    If ZPAC_ReadPack(File)
      ClearScene()
      
      *Pointer=ZPAC_NextPackFile()
      Size=ZPAC_NextPackFileSize() 
      CopyMemory(*Pointer, @Creatures_Count, Size)    
      If Creatures_Count => Creatures_MaxCount
        Creatures_MaxCount = Creatures_Count+1
        ReDim Creatures.CREATURE(Creatures_MaxCount)
      EndIf
      
      *Pointer=ZPAC_NextPackFile()
      Size=ZPAC_NextPackFileSize() 
      CopyMemory(*Pointer, @Creatures(0), Size)
      
      *Pointer=ZPAC_NextPackFile()
      Size=ZPAC_NextPackFileSize() 
      CopyMemory(*Pointer, @Objects_Count, Size)    
      If Objects_Count => Objects_MaxCount
        Objects_MaxCount = Objects_Count+1
        ReDim Objects.OBJECT(Objects_MaxCount)
      EndIf
      
      *Pointer=ZPAC_NextPackFile()
      Size=ZPAC_NextPackFileSize()   
      CopyMemory(*Pointer, @Objects(0), Size)
      
      *Pointer=ZPAC_NextPackFile()
      Size=ZPAC_NextPackFileSize() 
      CopyMemory(*Pointer, @GlobalVar, Size)    
      
      If GlobalVar\GlobalVarType = 0
      GlobalVarMode = ReadPreferenceString_(languagefile, "text", "gaming-mode")
      If IsWindow(#Window_Main)
      SetWindowTitle(#Window_Main,"Living Code V" + #VERSION + "  - " + GlobalVarMode)
      EndIf
      EndIf
      
      If GlobalVar\GlobalVarType = 1
      GlobalVarMode = ReadPreferenceString_(languagefile, "text", "evolution-mode")
      If IsWindow(#Window_Main)
      SetWindowTitle(#Window_Main,"Living Code V" + #VERSION + "  - " + GlobalVarMode)
      EndIf
      EndIf
      
      
      *Pointer=ZPAC_NextPackFile()
      Size=ZPAC_NextPackFileSize()  
      CopyMemory(*Pointer, @CodeProbability(0), Size)   
      
      For i = 0 To #CMD_NOP
        CodeProbability(i)\Pos = Pos
        Pos + CodeProbability(i)\Size
      Next
      CompleteCodeProbability = Pos
      
      If IsGadget(#MinimalCreatures)
        SetGadgetState(#MinimalCreatures, GlobalVar\MinimalCreatures)
      EndIf
      If IsGadget(#Ticks)
        SetGadgetText(#Ticks,Str(GlobalVar\ExecuteCount))
      EndIf
      If IsGadget(#CheckBox_Reducecpuusage)
        SetGadgetState(#CheckBox_Reducecpuusage,GlobalVar\Reducecpuusage)  
      EndIf
      GlobalVar\StartTimer = ElapsedMilliseconds()-GlobalVar\StartTimer
      If IsGadget(#Track_Mutation)
      SetGadgetState(#Track_Mutation,GlobalVar\MUTATION_PROBABILITY)
      EndIf
      ZPAC_CloseReadPack()
      
      
    EndIf
    
    
  EndIf
EndProcedure
Procedure LoadScene()
  File.s = OpenFileRequester(ReadPreferenceString_(languagefile, "text", "Load-Scene"),"",ScenePattern,1)
  _loadscene(File.s)
EndProcedure



Procedure Crypt_Creature_DNA(*Creature.CREATURE)
 If *Creature\EncryptionKey
   RandomSeed(*Creature\EncryptionKey & $FFFFFF)
    For cell = 0 To *Creature\NumCells-1
      For i = 0 To #CODE_SIZE - 1
        Value = Random($FFFF) + Random($FFFF) << 16
        *Creature\Cells[cell]\DNA[i] ! Value
      Next
    Next
    RandomSeed(ElapsedMilliseconds() & $FFFFFF)
  EndIf
  Code.l = *Creature\HideMode
  If Code = 'HIDE'
    *Creature\HideMode = 'ENCR'
  EndIf
  If Code = 'ENCR'
    *Creature\HideMode = 'HIDE'
  EndIf  

EndProcedure



Procedure CloseCreateCreature()
  If IsWindow(#Window_CreateCreature)
    GadGet\state\Break_Game = #False
    SetGadgetState(#CheckBox_Break,#False)
    CloseWindow(#Window_CreateCreature)
    DisableGadget(#CheckBox_Break,#False)
    If IsWindow(#Window_CC_Move):CloseWindow(#Window_CC_Move):EndIf
    If IsWindow(#Window_CC_Rotate):CloseWindow(#Window_CC_Rotate):EndIf
    If IsWindow(#Window_CC_IF):CloseWindow(#Window_CC_IF):EndIf
  EndIf
EndProcedure
Procedure.s GetCreatureFeatures(code.s)
  code=UCase(code)
  
  Speed.f=CountString(code,"MOVE_")
  Speed+CountString(code,"ROTATE_")/4
  
  Attack.f=CountString(code,"POISON_EMIT")
  Attack+CountString(code,"POISON_EMIT_DNA")/2
  Attack+CountString(code,"POISON_EMIT_VIRUS")
  
  defence.f=CountString(code,"POISON_IMMUN")
  defence+CountString(code,"TIMER_")/2
  
  reproduction.f=CountString(code,"COPY")
  reproduction+CountString(code,"CLONE")  
  
  intelligence.f=CountString(code,"IF_")/4
  intelligence+CountString(code,"GOTO")/4
  intelligence+CountString(code,"VARIABLE_")
  intelligence+CountString(code,"MSG_EMIT")/2
  
  
  
  ges.f =(Speed+Attack+defence+reproduction+intelligence);*1.005
  If ges=0:ges=1:EndIf
  msg.s = "Speed: "+StrF(Speed/ges*100,1)+"%"+#LF$
  msg.s + "Attack: "+StrF(Attack/ges*100,1)+"%"+#LF$
  msg.s + "defence: "+StrF(defence/ges*100,1)+"%"+#LF$
  msg.s + "reproduction: "+StrF(reproduction/ges*100,1)+"%"+#LF$
  msg.s + "intelligence: "+StrF(intelligence/ges*100,1)+"%"+#LF$
  
  MessageRequester(ReadPreferenceString_(languagefile, "text", "info"),msg)
  ProcedureReturn msg.s
EndProcedure
Procedure MakeCreature(*Creature.CREATURE)
  *Creature\Used = #True 
  *Creature\Energy = Val(GetGadgetText(#CreateCreature_EnergyStr))
  If *Creature\Energy<0:*Creature\Energy=0:EndIf
  
  If *Creature\OrgEnergy = 0
    *Creature\OrgEnergy = Val(GetGadgetText(#CreateCreature_EnergyStr))
  EndIf
  Cells=Val(GetGadgetText(#CreateCreature_CellsStr))
  If Cells<2:Cells=2:EndIf
  *Creature\NumCells = Cells
  *Creature\X = Val(GetGadgetText(#CreateCreature_XStr))
  *Creature\Y = Val(GetGadgetText(#CreateCreature_YStr))
  *Creature\Color  = GetGadgetColor(#CreateCreature_ColorShow,#PB_Gadget_BackColor)
  
  *Creature\CreatureID = Val(GetGadgetText(#CreateCreature_CreatureIDStr))
  *Creature\CreatureName = GetGadgetText(#CreateCreature_CreatureNameStr)
  *Creature\Author = GetGadgetText(#CreateCreature_CreatureAuthorStr)
  *Creature\Description = GetGadgetText(#CreateCreature_CreatureDescriptionStr)
  
  *Creature\DisableMutation = GetGadgetState(#CreateCreature_CheckMutation)
  
  *Creature\IncCreatureID = Val(GetGadgetText(#CreateCreature_IncCreatureIDStr));Random($FFFFFF);
  
  *Creature\IsMale = GetGadgetState(#CreateCreature_Male)
  
  ;Debug "vvvvvv"
  ;Debug *Creature\Cells[0]\CodeVariable
  ;Delay(1000)
  If *Creature\HideMode<>'HIDE'
    For cell=0 To Cells-1
      len=ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_GETLENGTH)+1
      Text.s=Space(len)
      ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_GETTEXT,len,@Text)
      
      Compile_Creature(Text, @*Creature\Cells[cell]\DNA)
      *Creature\Cells[cell]\CellID = Val(GetGadgetText(GadGet\Creature[cell]\CellIDStr))  
      *Creature\Cells[cell]\Radius = Val(GetGadgetText(GadGet\Creature[cell]\CellRandiusStr)) 
      If *Creature\Cells[cell]\Radius<CREATURE_MINRADIUS:*Creature\Cells[cell]\Radius=CREATURE_MINRADIUS:EndIf
      
      *Creature\Cells[cell]\CodePosition = Val(GetGadgetText(GadGet\Creature[cell]\CellCodePositionStr)) 
      *Creature\Cells[cell]\DoEating = #True
      *Creature\Cells[cell]\OrgRadius = Val(GetGadgetText(GadGet\Creature[cell]\CellOrgRandiusStr))
    Next
  EndIf
  
  
EndProcedure

Procedure _SaveCreateCreatureSettings(File.s)
  If FindString(GetFilePart(File),".",1) = #False
    File + ".CRF"
  EndIf
  If File And File <> ".CRF"
    
    If ZPAC_CreatePack(File)
      MakeCreature(*CreatureW)
      If *CreatureW\HideMode='HIDE'
        Crypt_Creature_DNA(*CreatureW)
      EndIf
      ;AddPackMemory(TempCreature.CREATURE, SizeOf(CREATURE), #Compress_Level)
      ZPAC_AddMemoryPack(*CreatureW, SizeOf(CREATURE), #COMPRESS_LEVEL)
      ZPAC_CloseCreatePack()
    Else
      MessageRequester(ReadPreferenceString_(languagefile, "text", "error"),ReadPreferenceString_(languagefile, "text", "Can-not-save-File"))
      ProcedureReturn #False
    EndIf
    
  Else
    ;MessageRequester("Error","Can not save the File!")
    ProcedureReturn #False
  EndIf
  
  ProcedureReturn #True
EndProcedure
Procedure SaveCreateCreatureSettings()
  File.s = SaveFileRequester(ReadPreferenceString_(languagefile, "text", "Save-Creature"),"",CreaturePattern,1)
  If FindString(GetFilePart(File),".",1) = #False
    File + ".CRF"
  EndIf
  If File And File <> ".CRF"
    _SaveCreateCreatureSettings(File.s)
    
  Else
    ;MessageRequester("Error","Can not save the File!")
  EndIf
  
  
EndProcedure
Procedure LoadCreateCreatureSettings_FromFile(File.s)
  *OrgCreature = #False
  If File
    If ZPAC_ReadPack(File)   
      
      *Pointer=ZPAC_NextPackFile()
      Size=ZPAC_NextPackFileSize() 
      CopyMemory(*Pointer, TempCreature, Size)  
      
      
      CloseCreateCreature()
      LoadCreateCreatureSettings_fromCreature(TempCreature)
      DisableGadget(#CreateCreature_Change, #True)
    EndIf 
    ZPAC_CloseReadPack()
  EndIf   
  
  
EndProcedure
Procedure InsertCreateCreature_FromFile(File.s, x.l = #PB_Ignore, y.l = #PB_Ignore, Energy.l = #PB_Ignore, OrgEnergy.l = #PB_Ignore, EnergyPerCell.l = #PB_Ignore, DisableMutation.l = #PB_Ignore)
  ;*OrgCreature = #False
  If File
    If ZPAC_ReadPack(File)   
      *Pointer=ZPAC_NextPackFile()
      Size=ZPAC_NextPackFileSize() 
      *Creature.CREATURE = AddCreature()
      CopyMemory(*Pointer,*Creature,SizeOf(CREATURE))
      If *Creature\HideMode='ENCR'
        Crypt_Creature_DNA(*Creature)
      EndIf
      *Creature\Used=#True
      If X<>#PB_Ignore:*Creature\X=X:EndIf
      If Y<>#PB_Ignore:*Creature\Y=Y:EndIf
      If EnergyPerCell=#PB_Ignore:EnergyPerCell=0:EndIf
      AddEnergy=(EnergyPerCell**Creature\NumCells)
      If Energy<>#PB_Ignore:*Creature\Energy=Energy+AddEnergy:EndIf
      If OrgEnergy<>#PB_Ignore:*Creature\OrgEnergy=OrgEnergy+AddEnergy:EndIf
      If DisableMutation<>#PB_Ignore:*Creature\DisableMutation=DisableMutation:EndIf
    EndIf 
    ZPAC_CloseReadPack()
  EndIf   
  
  
EndProcedure
Procedure.s GetCreatureAuthor_FromFile(File.s)
  *OrgCreature = #False
  If File
    
    If ZPAC_ReadPack(File)   
      *Pointer=ZPAC_NextPackFile()
      Size=ZPAC_NextPackFileSize() 
      CopyMemory(*Pointer, TempCreature, Size)  
      ZPAC_CloseReadPack()
      ProcedureReturn TempCreature\Author
    Else
      ZPAC_CloseReadPack()
      DeleteFile(File)
    EndIf 
    
  EndIf   
  
  
EndProcedure
Procedure GetCreatureOk_FromFile(File.s)
  *OrgCreature = #False
  If File
    
    If ZPAC_ReadPack(File)   
      *Pointer=ZPAC_NextPackFile()
      Size=ZPAC_NextPackFileSize() 
      CopyMemory(*Pointer, TempCreature, Size)  
      ZPAC_CloseReadPack()
      If TempCreature\MagicCreature
        ProcedureReturn Sprite\Img_Cheater
      Else
       ProcedureReturn Sprite\Img_Ok
      EndIf
    Else
      ZPAC_CloseReadPack()
      ProcedureReturn Sprite\Img_Empty
    EndIf 
    
  EndIf   
  
  
EndProcedure
Procedure LoadCreateCreatureSettings()
  *OrgCreature = #False
  
  File.s = OpenFileRequester(ReadPreferenceString_(languagefile, "text", "Open-Creature"),"",CreaturePattern,1)
  If File
    LoadCreateCreatureSettings_FromFile(File.s)
  EndIf   
  
  
EndProcedure
Procedure LoadCreateCreatureSettings_fromCreature(*Creature.CREATURE)

; 22.11.2008 Abfrage ob *Creature\HideMode = 'ENCR' / 'HIDE'
  If *Creature\HideMode='ENCR'
    Crypt_Creature_DNA(*Creature)
  EndIf

  If *Creature\HideMode='HIDE'
    CreateCreature_Window(0)
  Else
    CreateCreature_Window(*Creature\NumCells)
  EndIf
  
  SetGadgetText(#CreateCreature_EnergyStr,Str(*Creature\Energy))
  SetGadgetText(#CreateCreature_CellsStr,Str(*Creature\NumCells))
  SetGadgetText(#CreateCreature_XStr,Str(*Creature\X))
  SetGadgetText(#CreateCreature_YStr,Str(*Creature\Y))
  SetGadgetColor(#CreateCreature_ColorShow,#PB_Gadget_BackColor,*Creature\Color)
  SetGadgetText(#CreateCreature_CreatureIDStr,Str(*Creature\CreatureID))
  SetGadgetText(#CreateCreature_IncCreatureIDStr,Str(*Creature\IncCreatureID))
  
  
  If *Creature\IsMale
    SetGadgetState(#CreateCreature_Male,#True)
    SetGadgetState(#CreateCreature_FeMale,#False)
  Else
    SetGadgetState(#CreateCreature_Male,#False)
    SetGadgetState(#CreateCreature_FeMale,#True)
  EndIf
  
  
  
  SetGadgetText(#CreateCreature_CreatureNameStr,*Creature\CreatureName)
  SetGadgetText(#CreateCreature_CreatureAuthorStr,*Creature\Author)
  SetGadgetText(#CreateCreature_CreatureDescriptionStr,*Creature\Description)
  
  SetGadgetState(#CreateCreature_CheckMutation,*Creature\DisableMutation)
  
  
  If *Creature\HideMode<>'HIDE'
    For cell = 0 To *Creature\NumCells-1
      SetGadgetText(GadGet\Creature[cell]\CellIDStr,Str(*Creature\Cells[cell]\CellID))
      SetGadgetText(GadGet\Creature[cell]\CellRandiusStr,Str(*Creature\Cells[cell]\Radius))
      SetGadgetText(GadGet\Creature[cell]\CellOrgRandiusStr,Str(*Creature\Cells[cell]\OrgRadius))
      SetGadgetText(GadGet\Creature[cell]\CellCodePositionStr,Str(*Creature\Cells[cell]\CodePosition))
      
      Text.s = DeCompile_Creature(@*Creature\Cells[cell]\DNA[0])
      ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_SETTEXT,0,@Text)
    Next
  EndIf
  
  ;CopyMemory(*Creature,TempCreature, SizeOf(CREATURE))
  
  
  *OrgCreature = *Creature
  CopyMemory(*Creature,*CreatureW, SizeOf(CREATURE))
  DisableGadget(#CreateCreature_Change, #False)
  SetPreview(0)
  DisableGadget(#CreateCreature_Compile,#False)
  ;*CreatureW = *Creature
  
  ;StyleAll(*Creature\NumCells)
EndProcedure

Procedure SetRandomCreature(cells)

  SetGadgetText(#CreateCreature_EnergyStr,Str(9000 + Random(8500) + Random(8500) * (cells / 2)))
  SetGadgetText(#CreateCreature_XStr,Str(Random(#AREA_WIDTH)))
  SetGadgetText(#CreateCreature_YStr,Str(Random(#AREA_HEIGHT)))
  SetGadgetColor(#CreateCreature_ColorShow, #PB_Gadget_BackColor,RGB(Random(255), Random(255), Random(255)))

  IsMale=Random(1)
  If IsMale
    SetGadgetState(#CreateCreature_Male, #True)
    SetGadgetState(#CreateCreature_FeMale, #False)
  Else
    SetGadgetState(#CreateCreature_Male, #False)
    SetGadgetState(#CreateCreature_FeMale, #True)
  EndIf
  
  
  SetGadgetText(#CreateCreature_CreatureNameStr, "RND:" + Hex(Random(15))  + Hex(Random(15))  + Hex(Random(15))  + Hex(Random(15)) + Hex(Random(15))  + Hex(Random(15)))
  SetGadgetText(#CreateCreature_CreatureAuthorStr, ReadPreferenceString_(languagefile, "text", "Rnd-Generator"))
  SetGadgetText(#CreateCreature_CreatureDescriptionStr, ReadPreferenceString_(languagefile, "text", "random-generated-creature"))
  
  
  For cell = 0 To cells-1
    SetGadgetText(GadGet\Creature[cell]\CellRandiusStr,Str(Random(GlobalVar\CREATURE_MAXRADIUS)))
    SetGadgetText(GadGet\Creature[cell]\CellOrgRandiusStr,Str(Random(GlobalVar\CREATURE_MAXRADIUS)))
    SetGadgetText(GadGet\Creature[cell]\CellCodePositionStr,Str(Random(#CODE_SIZE)))

    Dim TmpCode.l(#CODE_SIZE - 1)
    For i = 0 To #CODE_SIZE - 1
      TmpCode(i) = OptimizeMutation(GetCodeByProbability())
    Next
  
    Text.s = DeCompile_Creature(@TmpCode(0))
   
    Count.l = CountString(Text, #LF$)
    
    Code.s = "@BEGIN" + #LF$
    
    If Random(100) > 50
      numPause = Random(12)
      For num = 0 To numPause
        If Random(100) > 50
        
          If Random(100) > 50
            Code.s + "GOTO @BEGIN_LINE" + #LF$
          Else
            Code.s + "GOTO25 @BEGIN_LINE" + #LF$
          EndIf
          
        Else
          Code.s + "GOTO50 @BEGIN_LINE" + #LF$
        EndIf
        
      Next
    EndIf
    
    Code.s + "@BEGIN_LINE" + #LF$
    
    For c = 0 To Count -1
    Code.s = Code + StringField(Text, c + 1, #LF$)+ #LF$

      If Random(100) < 5
        Code.s + "DL "+Str(Random($FFFFFF)) + #LF$     
      EndIf      
      
      If Random(100) < 2
        Code.s + "GOTO @BEGIN_LINE" + #LF$     
      EndIf

      If Random(100) < 8
        Code.s + "MUTATE @BEGIN" + #LF$     
      EndIf
    
      If Random(100) < 2
        Code.s + "MOVE_FORWARD2X" + #LF$
        Code.s + "EATING_YES" + #LF$        
      EndIf
    
      If Random(100) < 2
        Code.s + "COPY_MIN_ENERGY "+Str(50000 + Random(50000)) + #LF$
        Code.s + "COMBINECOPY" + #LF$        
      EndIf        
    
      If Random(100) < 5
        Code.s + "IF_CELL_RAD_LESS "+Str(Random(25)+25) + #LF$
        Code.s + "INC_CELL_RAD" + #LF$    
        Code.s + "ENDIF" + #LF$    
      EndIf
      
      If Random(100) < 5 And Security = #False
        Security = #True
        Code.s + "TIMER_SET "+Str(Random(400) + 100) + #LF$
        Code.s + "TIMER_GOTO @SEC" + #LF$ 
        Code.s + "GOTO @ENDSEC" + #LF$           
        Code.s + "@SEC" + #LF$
        Code.s + "MOVE_FORWARD2X" + #LF$
        Code.s + "EATING_YES" + #LF$  
        Code.s + "ROTATE_FOOD" + #LF$          
        Code.s + "GOTO @SEC" + #LF$  
        Code.s + "@ENDSEC" + #LF$    
      EndIf

      If Random(100) < 5 And Security2 = #False
        Security2 = #True
        Code.s + "TIMER_SET "+Str(Random(400) + 100) + #LF$
        Code.s + "TIMER_GOTO @SEC2" + #LF$          
        Code.s + "@SEC2" + #LF$ 
      EndIf
 
      If Random(100) < 2     
        Nr = Random(500)
        Code.s + "POISON_IMMUN2 "+Str(Nr) + #LF$ 
        Code.s + "POISON_YES" + #LF$         
        Code.s + "POISON_EMIT "+Str(Nr) + #LF$  
      EndIf

      If Random(100) < 2     
        Nr = Random(500)
        Code.s + "POISON_IMMUN3 "+Str(Nr) + #LF$ 
        Code.s + "POISON_YES" + #LF$         
        Code.s + "POISON_EMIT "+Str(Nr) + #LF$  
      EndIf

      If Random(100) < 5    
        Nr = Random(500)
        Code.s + "MSG_EMIT "+ Str(Nr) + #LF$ 
         
        Code.s + "IF_MSG_EQUAL "+ Str(Nr) + #LF$
        If Random(100) > 50
          Code.s + "ROTATE_MSG" + #LF$
          Code.s + "MOVE_FORWARD2X" + #LF$  
          Code.s + "MOVE_FORWARD2X" + #LF$
        Else         
          Code.s + "COMBINECOPY" + #LF$ 
        EndIf
        Code.s + "ENDIF" + #LF$ 
      EndIf      
    
      If Random(100) < 8 And Attack = #False
        Attack = #True
        Code.s + "SEARCH_NEAREST_ENEMY" + #LF$
        Code.s + "IF_ENEMYABS_LESS " + Str(Random(300) + 300) + #LF$
 
        If Random(100) > 50
          Code.s + "IF_CMP_ENEMY_GREATER " + Str(Random(30000) + 500) + #LF$
        EndIf
        
        Code.s + "ROTATE_ENEMY" + #LF$   
        Code.s + "MOVE_FORWARD2X" + #LF$  
        If Random(100) > 50
          Code.s + "MOVE_FORWARD2X" + #LF$  
          Code.s + "MOVE_FORWARD2X" + #LF$  
        EndIf
           
        Select Random(5) 
                    
        Case 1
          Nr = Random(500)
          Code.s + "@POISON" + #LF$  
          Code.s + "POISON_IMMUN1 "+Str(Nr) + #LF$ 
          Code.s + "POISON_YES" + #LF$         
          Code.s + "POISON_EMIT "+Str(Nr) + #LF$  
          If Random(100) > 50
          Code.s + "GOTO50 @POISON" + #LF$  
          EndIf
                            
        Case 2
 
          Code.s + "@ATTACK_BEGIN" + #LF$  
          Code.s + "POISON_DNABLOCK_SIZE 4" + #LF$            
          Code.s + "POISON_EMIT_DNABLOCK @ATTACK" + #LF$  
                              
          Code.s + "GOTO @ATTACK2" + #LF$             
          Code.s + "@ATTACK" + #LF$  
             
          Code.s + "MUTATE @BEGIN" + #LF$  
          If Random(100) > 50
            Code.s + "MUTATE @BEGIN" + #LF$
          EndIf 
          Code.s + "GOTO @ATTACK" + #LF$  
          Code.s + "@ATTACK2" + #LF$      
          
          If Random(100) > 50
            Code.s + "GOTO50 @ATTACK_BEGIN" + #LF$             
          EndIf
        
        Case 3
        
          Code.s + "@ATTACK_BEGIN" + #LF$  
          Code.s + "POISON_DNABLOCK_SIZE 4" + #LF$            
          Code.s + "POISON_EMIT_DNABLOCK @ATTACK" + #LF$  
                              
          Code.s + "GOTO @ATTACK2" + #LF$             
          Code.s + "@ATTACK" + #LF$  
             
          Code.s + "EATING_EMIT" + #LF$  
          If Random(100) > 50
            Code.s + "POISON_DNABLOCK_SIZE 4" + #LF$
            Code.s + "POISON_EMIT_DNABLOCK @ATTACK" + #LF$
          EndIf 
          Code.s + "GOTO @ATTACK" + #LF$  
          Code.s + "@ATTACK2" + #LF$      
          
          If Random(100) > 50
            Code.s + "GOTO50 @ATTACK_BEGIN" + #LF$             
          EndIf        
        
        Default            
   
          Code.s + "@ATTACK_BEGIN" + #LF$  
          Code.s + "POISON_DNABLOCK_SIZE 4" + #LF$            
          Code.s + "POISON_EMIT_DNABLOCK @ATTACK" + #LF$  
                              
          Code.s + "GOTO @ATTACK2" + #LF$             
          Code.s + "@ATTACK" + #LF$  
             
          Code.s + "EATING_EMIT" + #LF$  
          If Random(100) > 50
            Code.s + "DEC_CELL_RAD" + #LF$
          EndIf 
          Code.s + "GOTO @ATTACK" + #LF$  
          Code.s + "@ATTACK2" + #LF$      
          
          If Random(100) > 50
            Code.s + "GOTO50 @ATTACK_BEGIN" + #LF$             
          EndIf    
                      
        EndSelect

              
        Code.s + "ENDIF" + #LF$    
      EndIf      
      
    Next
    
    ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_SETTEXT, 0, @Code)
  Next

SetPreview(0)
EndProcedure

Procedure MakeScreenshot()
  Pattern$ = "PNG (*.png)|*.png"
  
  File.s = SaveFileRequester(ReadPreferenceString_(languagefile, "text", "save-screenshot"), "C:\", Pattern$, 0)
  If File
    If FindString(UCase(File),".PNG",1)=#False:File+".png":EndIf
    
    
    ScreenShot=GrabSprite(#PB_Any, 0, 0, #AREA_WIDTH, #AREA_HEIGHT)
    If SaveSprite(ScreenShot,File,#PB_ImagePlugin_PNG)=#False
      MessageRequester(ReadPreferenceString_(languagefile, "text", "error"),ReadPreferenceString_(languagefile, "text", "Can-not-save-File"))
    EndIf
    
    FreeSprite(ScreenShot)
    
  EndIf
  
  
EndProcedure



Procedure _LoadSound(Sound,File.s)
  If GlobalSound=#True
    LoadSound(Sound,File.s)
  EndIf
EndProcedure
Procedure _PlaySound(Sound.l)
  If GlobalSound=#True And GlobalSoundOn=#True; And GlobalDrawing = #True
    PlaySound(Sound.l)
    SoundVolume(Sound, 15)
  EndIf
EndProcedure


Global BKGlobalSoundOn
Procedure DisableToolBar(state)
  
  For i=0 To #ToolBar_Rotate
    DisableToolBarButton(1,i,state)
  Next
  
  
EndProcedure
Procedure HideAllwindows(state)
  If state = #True
    GlobalDrawing = #False
    BKGlobalSoundOn=GlobalSoundOn
    GlobalSoundOn = #False
    View3D = #False
    oldView3D = #False
    oldGlobalDrawing = #False
    HideWindow=#True
  Else
    GlobalDrawing = #True
    GlobalSoundOn = BKGlobalSoundOn
    View3D = #False
    oldView3D = #False
    oldGlobalDrawing = #True
    HideWindow=#False
  EndIf
  
  HideWindow(#Window_Main,state)
  If IsWindow(#Window_CreateCreature)
    HideWindow(#Window_CreateCreature,state)
  EndIf      
  If IsWindow(#Window_About)
    HideWindow(#Window_About,state)
  EndIf      
  If IsWindow(#Window_Options)
    HideWindow(#Window_Options,state)
  EndIf     
EndProcedure
Procedure Restart()
  
  CreateFile(1,Datapath+"Options.txt")
  WriteStringN(1,Str(GetGadgetState(#Option_MultiCore)))
  WriteStringN(1,Str(WORKER_COUNT_TEMP))
  WriteStringN(1,languagefile)
  CloseFile(1)
  
  
  _SaveScene("Autosave.LCF")
  CloseWindow(#Window_Main)
  RunProgram(ProgramFilename(),"Autosave.LCF",GetCurrentDirectory())
  
  End
EndProcedure


CompilerIf #PB_Compiler_OS = #PB_OS_Linux
CompilerElse
  Procedure.s GetUserName() 
    User$=Space(1024) 
    MaxSize=1024 
    GetUserName_(@User$,@MaxSize) 
    ProcedureReturn User$ 
  EndProcedure 
CompilerEndIf


Structure NumCreatures
Name.s
Count.l
EndStructure

Global Dim NumCreatures.NumCreatures(1000)

#SYNTAX_Error=1
Procedure ScintillaCallBack(Editor.l, *scinotify.SCNotification) 
  txtr.TEXTRANGE
  If *scinotify\nmhdr\code = #SCN_STYLENEEDED 
    line_number = ScintillaSendMessage(Editor, #SCI_LINEFROMPOSITION, ScintillaSendMessage(Editor, #SCI_GETENDSTYLED)) 
    start_pos = ScintillaSendMessage(Editor, #SCI_POSITIONFROMLINE, line_number) 
    
    end_pos     = *scinotify\Position       
    
    End_line = ScintillaSendMessage(Editor, #SCI_LINEFROMPOSITION,  end_pos )+1
    
    txtr\chrg\cpMin = start_pos 
    txtr\chrg\cpMax = end_pos 
    
    
    txtr\lpstrText  = AllocateMemory(end_pos - start_pos + 1) 
    Buffer          = txtr\lpstrText 
    
    
    FreeMemory(Buffer) 
    
  EndIf 
  
  
  
  If *scinotify\nmhdr\code =2007
    ;Debug *scinotify\text
  EndIf
  
  If *scinotify\nmhdr\code = #SCN_MODIFIED And 1=2
    ; 
    Line=ScintillaSendMessage(Editor, #SCI_LINEFROMPOSITION, *scinotify\Position)
    start_pos =ScintillaSendMessage(Editor, #SCI_POSITIONFROMLINE, Line)
    end_pos = start_pos + ScintillaSendMessage(Editor, #SCI_LINELENGTH, Line)
    
    txtr\chrg\cpMin = start_pos 
    txtr\chrg\cpMax = end_pos 
    txtr\lpstrText  = AllocateMemory(end_pos - start_pos + 1) 
    Buffer          = txtr\lpstrText 
    
    ScintillaSendMessage(Editor, #SCI_GETTEXTRANGE, 0, txtr) 
    
    ;res = SyntaxHilighting(start_pos, Editor, Buffer,#True)
    FreeMemory(Buffer) 
  EndIf
  
  
  
  If *scinotify\nmhdr\code = #SCN_CHARADDED
    
    If *scinotify\ch = 13
      ; UpdateFolding(Editor, #True, 250)
    EndIf
    If *scinotify\ch = '%'
      ;ScintillaSendMessage(Editor, #SCI_AUTOCSETCANCELATSTART, 1)
    EndIf  
    
  EndIf
  
  
  If *scinotify\nmhdr\code = #SCN_MARGINCLICK 
    modifiers = *scinotify\modifiers 
    Position = *scinotify\Position 
    margin = *scinotify\margin 
    linenumber = ScintillaSendMessage(Editor, #SCI_LINEFROMPOSITION, Position) 
    Select margin 
      Case 2 
        ScintillaSendMessage(Editor, #SCI_TOGGLEFOLD, linenumber) 
    EndSelect 
  EndIf 
  
  
  
EndProcedure 


; Procedure SetCurrentPos(GadGet,Line)
; ScintillaSendMessage(GadGet, #SCI_MARKERDELETEALL,0)
; ScintillaSendMessage(GadGet, #SCI_MARKERADD,line,0)
; EndProcedure

Procedure SetSciColor(GadGet)




;   ScintillaSendMessage(GadGet, #SCI_MARKERDEFINE,0,#SC_MARK_SHORTARROW)
;   ScintillaSendMessage(GadGet, #SCI_MARKERSETBACK,0,RGB(245,245,166))
;   line=0
;   ScintillaSendMessage(GadGet, #SCI_MARKERADD,line,0)




  ;ScintillaSendMessage(GadGet, #SCI_SETSELBACK,#STYLE_DEFAULT, RGB(80,80,200)) 
  ;ScintillaSendMessage(GadGet, #SCI_SETSELFORE,#STYLE_DEFAULT, RGB(255,255,255)) 
  
  ScintillaSendMessage(GadGet, #SCI_STYLESETFORE,#STYLE_DEFAULT, $000000) 
  ScintillaSendMessage(GadGet, #SCI_STYLESETBACK, #STYLE_DEFAULT, 13434877) 
  
  ScintillaSendMessage(GadGet, #SCI_STYLESETFONT, #STYLE_DEFAULT, @"Courier New") 
  ScintillaSendMessage(GadGet, #SCI_STYLESETSIZE, #STYLE_DEFAULT, 10) 
  ScintillaSendMessage(GadGet, #SCI_STYLECLEARALL) 
  
  
   ;ScintillaSendMessage(GadGet, #SCI_USEPOPUP, 0) 
  
  
  
  ; Set caret line color 
  ScintillaSendMessage(GadGet, #SCI_SETCARETLINEBACK, 11403260) 
  ScintillaSendMessage(GadGet, #SCI_SETCARETLINEVISIBLE, #True) 
  
  ScintillaSendMessage(GadGet, #SCI_STYLESETFORE,#SCI_SETCURSOR,RGB(255,0,0))
  
  
  ScintillaSendMessage(GadGet, #SCI_SETTABWIDTH,2)
  
  
  
  
  ScintillaSendMessage(GadGet, #SCI_STYLESETSIZE, #STYLE_DEFAULT, 10) 
  ScintillaSendMessage(GadGet, #SCI_SETMARGINTYPEN, 0, #SC_MARGIN_NUMBER) 
  ScintillaSendMessage(GadGet, #SCI_SETMARGINMASKN, 0, #SC_MASK_FOLDERS) 
  ScintillaSendMessage(GadGet, #SCI_SETMARGINWIDTHN, 0, 0) 
  ScintillaSendMessage(GadGet, #SCI_SETMARGINWIDTHN, 1, 0) 
  ScintillaSendMessage(GadGet, #SCI_SETMARGINWIDTHN, 2, 0) 
  ScintillaSendMessage(GadGet, #SCI_SETMARGINSENSITIVEN, 2, #True)
  
  ScintillaSendMessage(GadGet, #SCI_STYLESETITALIC, #SYNTAX_Error, #True) 
  ScintillaSendMessage(GadGet, #SCI_STYLESETFORE, #SYNTAX_Error, RGB(128,128,128)) 
EndProcedure
Procedure SetStatistics()
  FPS_Count+1
  If ElapsedMilliseconds()-FPS_Start=>1000
    
    FPS_Start=ElapsedMilliseconds()
    fps=FPS_Count
    FPS_Count=0
    SetGadgetText(#TEXT_FPS,Str(fps)+" FPS")
    
    
    sec = (ElapsedMilliseconds()-GlobalVar\StartTimer)/1000
    min = sec/60
    hour = min/60
    
    sec-min*60
    min-hour*60
    
    str_sec.s = Str(sec)
    If Len(str_sec) = 1 :str_sec.s = "0" + str_sec.s:EndIf
    
    str_min.s = Str(min)
    If Len(str_min) = 1 :str_min.s = "0" + str_min.s:EndIf
    
    str_hour.s = Str(hour)
    If Len(str_hour) = 1 :str_hour.s = "0" + str_hour.s:EndIf
    
    SetGadgetText(#TEXT_Timer,str_hour+":"+str_min+":"+str_sec)
    
    For x=0 To 999
      NumCreatures(x)\Name=""
      NumCreatures(x)\Count=0
    Next
    
    Real_Creatures = 0
    For i=0 To Creatures_Count -1
      If Creatures(i)\Used
        Real_Creatures + 1
        debugInfo + Creatures(i)\OrgEnergy
        
        found=0
        Name.s=Creatures(i)\CreatureName
        For x=0 To 999
          If NumCreatures(x)\Name=Name
            NumCreatures(x)\Count+1
            found=1
            Break
          EndIf
        Next
        If found=0
          For x=0 To 999
            If NumCreatures(x)\Name=""
              NumCreatures(x)\Name=Name
              NumCreatures(x)\Count=1
              Break
            EndIf
          Next
        EndIf
        
      EndIf
    Next
    SortStructuredArray(NumCreatures(), #PB_Sort_Descending, OffsetOf(NumCreatures\Count), #PB_Sort_Long)
    
    If NumCreatures(0)\Count>0
      SetGadgetText(#TEXT_MostCreatures1,Str(NumCreatures(0)\Count)+"x "+NumCreatures(0)\Name)
    Else
      SetGadgetText(#TEXT_MostCreatures1,"")
    EndIf
    If NumCreatures(1)\Count>0
      SetGadgetText(#TEXT_MostCreatures2,Str(NumCreatures(1)\Count)+"x "+NumCreatures(1)\Name)
    Else
      SetGadgetText(#TEXT_MostCreatures2,"")
    EndIf
    If NumCreatures(2)\Count>0
      SetGadgetText(#TEXT_MostCreatures3,Str(NumCreatures(2)\Count)+"x "+NumCreatures(2)\Name)
    Else
      SetGadgetText(#TEXT_MostCreatures3,"")
    EndIf

    
    SetGadgetText( #TEXT_Creatures, ReadPreferenceString_(languagefile, "text", "Creatures")+": " + Str(Real_Creatures))
    
    For i=0 To #OBJECT_REST
      Statistic(i) = 0
    Next    
    For i = 0 To Objects_Count -1
      If  Objects(i)\Used 
        Statistic(Objects(i)\Type) + 1;Objects(i)\Energy  
        If Objects(i)\Type = #OBJECT_FOOD
          debugInfo + Objects(i)\Energy  
        EndIf
        If Objects(i)\Type = #OBJECT_REST
          debugInfo + Objects(i)\Energy  
        EndIf
      EndIf 
    Next
    
    
    
    SetGadgetText(#TEXT_FOOD, ReadPreferenceString_(languagefile, "text", "food")+": " + Str(Statistic(#OBJECT_FOOD))+"("+Str(debugInfo)+")")
    SetGadgetText(#TEXT_VIRUS, ReadPreferenceString_(languagefile, "text", "virus")+": " + Str(Statistic(#OBJECT_VIRUS)))
    SetGadgetText(#TEXT_DNA, ReadPreferenceString_(languagefile, "text", "dna")+": " + Str(Statistic(#OBJECT_DNA)))
    SetGadgetText(#TEXT_POISON, ReadPreferenceString_(languagefile, "text", "poison")+": " + Str(Statistic(#OBJECT_POISON)))
    SetGadgetText(#TEXT_MSG, ReadPreferenceString_(languagefile, "text", "msg")+": " + Str(Statistic(#OBJECT_MSG)))
    SetGadgetText(#TEXT_REST, ReadPreferenceString_(languagefile, "text", "rest")+": " + Str(Statistic(#OBJECT_REST)))
    
    If  oldabs <> -1
      If Creatures(SchowCreatureIndex)\Used
        SetGadgetText(#TEXT_CreatureDName, ReadPreferenceString_(languagefile, "text", "Name")+": " + Creatures(SchowCreatureIndex)\CreatureName)
        SetGadgetText(#TEXT_CreatureDAuthor, ReadPreferenceString_(languagefile, "text", "Author")+": " + Creatures(SchowCreatureIndex)\Author)
        SetGadgetText(#TEXT_CreatureDEnergy, ReadPreferenceString_(languagefile, "text", "Energy")+": " + Str(Creatures(SchowCreatureIndex)\Energy))
        SetGadgetText(#TEXT_CreatureDOrgEnergy, ReadPreferenceString_(languagefile, "text", "Orginal")+" "+ReadPreferenceString_(languagefile, "text", "Energy")+": " + Str(Creatures(SchowCreatureIndex)\OrgEnergy))
      EndIf
    EndIf
    
    GadGet\state\FOOD = GetGadgetState(#CheckBox_FOOD)
    GadGet\state\VIRUS = GetGadgetState(#CheckBox_VIRUS)
    GadGet\state\DNA = GetGadgetState(#CheckBox_DNA)
    GadGet\state\POISON = GetGadgetState(#CheckBox_POISON)
    GadGet\state\msg = GetGadgetState(#CheckBox_MSG)
    GadGet\state\REST = GetGadgetState(#CheckBox_REST)
    GadGet\state\Creature = GetGadgetState(#CheckBox_Creature)
    GlobalVar\Object_Trans = GetGadgetState(#Track_ObjTrans)
    GlobalVar\ExecuteCount=Val(GetGadgetText(#Ticks))
    GlobalVar\Reducecpuusage=GetGadgetState(#CheckBox_Reducecpuusage) 
    GlobalVar\MinimalCreatures = GetGadgetState(#MinimalCreatures)
    ;GlobalSoundOn = GetGadgetState(#CheckBox_Sounds)
    erg = GetGadgetState(#Track_Mutation)   
    If GlobalVar\MUTATION_PROBABILITY<2000
      GlobalVar\MUTATION_PROBABILITY = erg 
    EndIf
    
    
    
  EndIf
EndProcedure




Procedure.s TestUploadString(Text.s,Type=0) 
  
  
  
  
  
  Text=ReplaceString(Text,",","",#PB_String_NoCase)
  Text=ReplaceString(Text,"?","",#PB_String_NoCase)
  Text=ReplaceString(Text,"&","",#PB_String_NoCase)
  Text=ReplaceString(Text,#LF$,"",#PB_String_NoCase)
  Text=ReplaceString(Text,#CR$,"",#PB_String_NoCase)
  Text=ReplaceString(Text,Chr(34),"",#PB_String_NoCase)
  Text=ReplaceString(Text,"%","",#PB_String_NoCase)
  Text=ReplaceString(Text,"§","",#PB_String_NoCase)
  Text=ReplaceString(Text,"/","",#PB_String_NoCase)
  Text=ReplaceString(Text,"\","",#PB_String_NoCase)
  Text=ReplaceString(Text,"=","",#PB_String_NoCase)
  
  
  
  Text=ReplaceString(Text,"Arschloch","*********",#PB_String_NoCase)
  Text=ReplaceString(Text,"Arsch","*****",#PB_String_NoCase)
  Text=ReplaceString(Text,"Sau","***",#PB_String_NoCase)
  Text=ReplaceString(Text,"Schwein","*******",#PB_String_NoCase)
  Text=ReplaceString(Text,"dumm","****",#PB_String_NoCase)
  Text=ReplaceString(Text,"fett","****",#PB_String_NoCase)
  Text=ReplaceString(Text,"Scheiß","******",#PB_String_NoCase)
  Text=ReplaceString(Text,"penner","******",#PB_String_NoCase)
  
  If Type<>0 
    For i=1 To 31
      Text=ReplaceString(Text,Chr(i),"",#PB_String_NoCase)
    Next
    For i=33 To 47
      Text=ReplaceString(Text,Chr(i),"",#PB_String_NoCase)
    Next
    For i=58 To 64
      Text=ReplaceString(Text,Chr(i),"",#PB_String_NoCase)
    Next
    For i=91 To 96
      Text=ReplaceString(Text,Chr(i),"",#PB_String_NoCase)
    Next
    For i=123 To 255
      Text=ReplaceString(Text,Chr(i),"",#PB_String_NoCase)
    Next
    
  EndIf
  
  
  
  ProcedureReturn Text.s
EndProcedure
Procedure.s GetLastUploadError()
  ProcedureReturn LastUploadError
EndProcedure
Procedure UploadFile(sFile.s, sURL.s, sAction.s)
  lSuccess = #False
  ReadFile.l = ReadFile(#PB_Any, sFile)
  
  If ReadFile
    
    FileSize = Lof(ReadFile)
    *Mem = AllocateMemory(FileSize)
    
    If *Mem
      
      ReadData(ReadFile, *Mem, FileSize)
      
      connection.l = OpenNetworkConnection(GetURLPart(sURL.s, #PB_URL_Site), 80)  
      
      If connection
        
        File.s = "-----BoBoX73" + #CRLF$
        File.s + "content-disposition: form-data; name='" + sAction.s + "'; filename='" + sFile + "'"+#CRLF$
        ;FILE.s + "Content-Type: image/jpeg" + #CRLF$
        File.s + #CRLF$  
        FILE_END.s= #CRLF$ + "-----BoBoX73"               
        
        
        POST.s = "POST " + sURL + " HTTP/1.1" + #CRLF$
        POST.s + "Content-Type: multipart/form-data, boundary=---BoBoX73" + #CRLF$
        POST.s + "User-Agent: UploadFile Function"+#CRLF$
        POST.s + "Host: localhost" + #CRLF$
        POST.s + "Content-Length: " + Str(Len(File) + FileSize + Len(FILE_END)) + #CRLF$
        POST.s + "Cache-Control: no-cache" + #CRLF$
        POST.s + #CRLF$
        POST.s + File.s
        
        SendNetworkData(connection, @POST, Len(POST))
        
        SendNetworkData(connection,*Mem, FileSize)      
        
        SendNetworkData(connection, @FILE_END.s, Len(FILE_END.s))
        
        Output.s = ""
        Buffer.s = Space(256)
        Repeat
          Result.l = ReceiveNetworkData(connection, @Buffer.s, 256) 
          Output.s + PeekS(@Buffer, Result)
        Until Result <> 256
        
        
        If FindString(Output.s, "[RESULT: UPLOAD OK]", 1)
          lSuccess = #True
        Else
          LastUploadError = "Upload failed: " + Output
          lSuccess = #False                        
        EndIf
        
        If FindString(Output.s, "[RESULT: UPLOAD FAILED]", 1)
          LastUploadError = "Upload failed, no temp file available: " + Output
          lSuccess = #False           
        EndIf
        
        CloseNetworkConnection(connection)
        
      Else
        LastUploadError = "OpenNetworkConnection("+GetURLPart(sURL.s, #PB_URL_Site)+", 80) failed"
        lSuccess = #False         
      EndIf
      
      FreeMemory(*Mem)
    Else
      LastUploadError = "Upload failed, can't allocate memory of size " + Str(FileSize)
      lSuccess = #False  
    EndIf
    
    CloseFile(ReadFile)
  Else
    LastUploadError = "Upload failed, can't open file " + Chr(34) + sFile.s + Chr(34)
    lSuccess = #False
  EndIf
  ProcedureReturn lSuccess
EndProcedure




CompilerIf #PB_Compiler_OS = #PB_OS_Linux
CompilerElse
  Procedure.l DownloadToMem(AgentName.s, URL$, ptr.l, Size.l ) 
    net = InternetOpen_(AgentName, 0, 0, 0, 0) 
    Result = InternetOpenUrl_(net, URL$, "", 0, $84000000, 0) 
    If Result > 0 
      InternetReadFile_ ( Result, ptr, Size, @readsize) 
    EndIf 
    InternetCloseHandle_ (net) 
    InternetCloseHandle_ (Result) 
    ProcedureReturn Result
  EndProcedure 
  
  #HEAP_ZERO_MEMORY=8
  #CLSCTX_INPROC_SERVER=1
  Prototype.l ShowHTMLDialog(hWndParent.l,*pMk.IMoniker,*pvarArgIn.VARIANT,*pchOptions.l,*pvarArgOut.VARIANT)
  Structure _ShowHTMLDialogResult
    string.b[$FFFF]
  EndStructure
  Global g_nDlg_ShowHTMLDialogResult._ShowHTMLDialogResult
  
  ProcedureDLL.l ShowHtmlDialogURL(hWndParent.l,sURL.s,lWidth.l,lHeight.l)
    Protected sOptions.s,lResult.l
    Protected *Url.l,*Options.l,*mshtml.l,*Moniker.IMoniker,ShowHTMLDialog.ShowHTMLDialog
    Protected vShowHTMLDialogResult.VARIANT
    
    sOptions = ";dialogHeight:" + Str(lHeight) + "px;dialogWidth:" + Str(lWidth) + "px;help:0;"
    
    *Url=HeapAlloc_(GetProcessHeap_(),#HEAP_ZERO_MEMORY,#MAX_PATH*2)
    If *Url
      *Options=HeapAlloc_(GetProcessHeap_(),#HEAP_ZERO_MEMORY,#MAX_PATH*2)
      If *Options
        
        MultiByteToWideChar_(#CP_ACP,0,sURL,lstrlen_(sURL),*Url,#MAX_PATH*2) ; p-unicode could be used instead...
        MultiByteToWideChar_(#CP_ACP,0,sOptions,lstrlen_(sOptions),*Options,#MAX_PATH*2)
        
        *mshtml = LoadLibrary_("mshtml.dll")
        If *mshtml
          
          ShowHTMLDialog=GetProcAddress_(*mshtml,"ShowHTMLDialog")
          If ShowHTMLDialog
            
            CreateURLMoniker_(0,*Url,@*Moniker) ; should maybe also called dynamically ?
            If *Moniker
              
              VariantClear_(vShowHTMLDialogResult)
              If ShowHTMLDialog(hWndParent,*Moniker,0,*Options,@vShowHTMLDialogResult)=#S_OK
                VariantChangeType_(vShowHTMLDialogResult,vShowHTMLDialogResult,0,#VT_BSTR)         
                PokeS(g_nDlg_ShowHTMLDialogResult,PeekS(vShowHTMLDialogResult\bstrVal,-1,#PB_Unicode),$FFFF-1)
                VariantClear_(vShowHTMLDialogResult)
                lResult=#True
              EndIf
              
              *Moniker\Release()
            EndIf
          EndIf
          FreeLibrary_(*mshtml)
        EndIf
        HeapFree_(GetProcessHeap_(),0,*Options)
      EndIf
      HeapFree_(GetProcessHeap_(),0,*Url)
    EndIf
    
    ProcedureReturn lResult
  EndProcedure
  
  Procedure.s GetHtmlDialogResult()
    ;VariantChangeType_(g_nDlg_ShowHTMLDialogResult,g_nDlg_ShowHTMLDialogResult,0,#VT_BSTR)
    ;ProcedureReturn PeekS(g_nDlg_ShowHTMLDialogResult\bstrVal,-1,#PB_Unicode)
    ProcedureReturn PeekS(g_nDlg_ShowHTMLDialogResult);,$FFFF-1)
  EndProcedure
CompilerEndIf


Procedure TestInternet()
  
  TestConection = OpenNetworkConnection(UPLOAD_TEST_URL.s,80)
  If TestConection
    CloseNetworkConnection(TestConection)
    ProcedureReturn #True
  Else
    MessageRequester(ReadPreferenceString_(languagefile, "text", "error"),ReadPreferenceString_(languagefile, "text", "Conection-to-Server-failed"))
    ProcedureReturn #False
  EndIf
  
EndProcedure



Global WebGadgetLibPath.s, WebGadgetMozillaPath.s
Procedure.l __WebGadgetPath(LibPath.s, MozillaPath.s)
  WebGadgetLibPath.s = LibPath.s
  WebGadgetMozillaPath.s = MozillaPath.s
  ProcedureReturn WebGadgetPath(LibPath.s, MozillaPath.s)
EndProcedure
Procedure __SearchWebPath(searchpath.s, folder.s, libfile.s) 
  search=ExamineDirectory(#PB_Any,searchpath.s,"*.*") 
  If search 
    While NextDirectoryEntry(search) 
      
      If folder <> ""
        If DirectoryEntryType(search) = #PB_DirectoryEntry_Directory
          Path.s = DirectoryEntryName(search)
          If UCase(Left(Path, Len(folder))) = UCase(folder) ; "xulrunner"
            
            If FileSize(searchpath.s + "/" + Path.s +"/" + libfile) > 0
              ProcedureReturn __WebGadgetPath(searchpath.s + "/" + Path.s +"/" + libfile, searchpath.s + "/" + Path.s)
            EndIf
          EndIf        
        EndIf        
      Else
        
        If DirectoryEntryType(search) = #PB_DirectoryEntry_File
          If DirectoryEntryName(search) = libfile
            ProcedureReturn __WebGadgetPath(searchpath.s + "/" + libfile, searchpath.s)
          EndIf
          If Left(DirectoryEntryName(search), Len(libfile)) = libfile
            ProcedureReturn __WebGadgetPath(searchpath.s + "/" + DirectoryEntryName(search), searchpath.s)
          EndIf 
        EndIf    
        
      EndIf
      
    Wend 
    FinishDirectory(search) 
  EndIf 
  ProcedureReturn #False 
EndProcedure
Procedure __CheckWebGadgetPath(Path.s, folder.s)
  lResult.l = __SearchWebPath(Path.s, folder.s, "libgtkembedmoz.so")
  If lResult = #False
    lResult.l = __SearchWebPath(Path.s, "", "libgtkembedmoz.so")
  EndIf
  If lResult = #False
    lResult.l = __SearchWebPath(Path.s, folder.s, "libgtkembedmoz.so.0d")
  EndIf
  If lResult = #False
    lResult.l = __SearchWebPath(Path.s, "", "libgtkembedmoz.so.0d")
  EndIf
  ProcedureReturn lResult
EndProcedure
Procedure.l DefineWebGadgetPath()
  WebGadgetLibPath.s = ""
  WebGadgetMozillaPath.s = ""
  
  If WebGadgetPath("") = #False
    
    Result = __CheckWebGadgetPath("/usr/lib", "xulrunner")
    If Result = #False
      Result = __CheckWebGadgetPath("/usr/lib", "firefox")  
    EndIf
    If Result = #False
      Result = __CheckWebGadgetPath("/usr/lib", "thunderbird")  
    EndIf
    
    If Result = #False
      Result = __CheckWebGadgetPath("/lib", "xulrunner")
    EndIf
    If Result = #False
      Result = __CheckWebGadgetPath("/lib", "firefox")  
    EndIf
    If Result = #False
      Result = __CheckWebGadgetPath("/lib", "thunderbird")  
    EndIf
  Else
    Result = #True 
  EndIf
  
  If Result = #False
    MessageRequester("ERROR:","Can't find correct webgadget path!")
  EndIf
  ProcedureReturn Result
EndProcedure
Procedure DownloadPerWebGadGet(Url.s)
  
  
  
  If OpenWindow(#Window_UploadPerWebGadGet, 0, 0,500, 550, "",0 ,WindowID(#Window_Main)) 
    UseGadgetList(WindowID(#Window_UploadPerWebGadGet)) 
    
    DefineWebGadgetPath()
    ;Debug "Lib-Pfad: " + WebGadgetLibPath.s
    ;Debug "Mozilla Pfad: " + WebGadgetMozillaPath.s
    
    WebGadget = WebGadget(#PB_Any, 0, 0, 500, 500, "");Url)
    SetGadgetText(WebGadget, Url) 
    Repeat 
      ; Debug GetGadgetItemText(WebGadget, #PB_Web_StatusMessage)
      If GetGadgetItemText(WebGadget, #PB_Web_PageTitle)<>""
        Finish = #True
        ReturnValue = #False   
        If FindString(GetGadgetItemText(WebGadget, #PB_Web_PageTitle),"ERROR,",1)
          ReturnValue = #False   
        EndIf
        If FindString(GetGadgetItemText(WebGadget, #PB_Web_PageTitle),"DATA SUCCESSFULLY SAVED!",1)
          ReturnValue = #True 
        EndIf   
      EndIf
      
      
      
      
      
      Delay(10)
      WindowEvent()
    Until Finish = #True
    Delay(2000)
    CloseWindow(#Window_UploadPerWebGadGet)
  EndIf
  
  
  ProcedureReturn ReturnValue
EndProcedure



Procedure DrawCreature3D(CreatureIndex.l)
  CompilerIf #Use3DView = #True
    
    *Creature.CREATURE = @Creatures(CreatureIndex)
    
    If *Creature
      ;S3DR_SetDiffuseColors(*Creature\Color + 255<<24, *Creature\Color + 255<<24, *Creature\Color + 255<<24, *Creature\Color + 255<<24)
           
      num.l = *Creature\NumCells
      
      If num > 0
        Angle.f = *Creature\Angle
        X.f = *Creature\X
        Y.f = *Creature\Y
        
        facX.f  = #View3D_Scale /#AREA_WIDTH
        facY.f  = #View3D_Scale /#AREA_HEIGHT
        
        rad.f = *Creature\Cells[num-1]\Radius
        OldX.f =  X  + Cos(Angle + 2 * #PI * (num-1)/num ) * rad
        OldY.f =  Y  + Sin(Angle + 2 * #PI * (num-1)/num ) * rad
        
        mrad.f = 0
        For i = 0 To num-1
          mrad.f + *Creature\Cells[i]\Radius
        Next
        mrad /(num) + 1.0
        mrad * ((facX + facY) / 2)
        
        For i = 0 To num-1
          v.f = 2 * #PI * (i)/(num)
          rad.f = *Creature\Cells[i]\Radius
          Px.f = X + Cos(v + Angle) * rad
          Py.f = Y + Sin(v + Angle) * rad
          
          S3DR_Draw3D(X * facX   , mrad , Y * facY   , OldX * facX, 0.8, OldY * facY, Px * facX  , 0.8, Py * facY  , Px * facX, 0.8, Py * facY)  
          
          
          S3DR_Draw3D(OldX * facX, 0.8  , OldY * facY, Px * facX  , 0.8, Py * facY  , OldX * facX, 0.0, OldY * facY, Px * facX, 0.0, Py * facY)  
          
          OldX =  Px
          OldY =  Py  
        Next
      EndIf
      
    EndIf   
    
  CompilerEndIf
EndProcedure



Procedure.s GetLastDownloadError() 
  ProcedureReturn LastDownloadError 
EndProcedure
Procedure.s RowDownloadToString(sURL.s, Agent.s, TimeOutSec.l)     
  TimeOutSec * 1000
  
  Start = ElapsedMilliseconds()     
  connection.l = OpenNetworkConnection(UPLOAD_TEST_URL.s,80);GetURLPart(sURL.s, #PB_URL_Site), 80)  
  
  If connection 
    
    POST.s = "GET " + sURL + " HTTP/1.1" + #CRLF$ 
    POST.s + "User-Agent: "+Agent.s+#CRLF$ 
    POST.s + "Host: localhost" + #CRLF$ 
    POST.s + #CRLF$      
    SendNetworkData(connection, @POST, Len(POST))         
    
    ResultFound = #False                      
    Output.s = ""        
    Buffer.s = Space(256) 
    Repeat 
      Delay(1)
      Result.l = ReceiveNetworkData(connection, @Buffer.s, 256) 
      Output.s + PeekS(@Buffer, Result) 
      
      If FindString(Output, "ERROR, PROJECT KEY NOT CORRECT!", 1):ResultFound = #True:EndIf
      If FindString(Output, "ERROR, BAD AGENT!", 1):ResultFound = #True:EndIf
      If FindString(Output, "DATA SUCCESSFULLY SAVED!", 1):ResultFound = #True:EndIf
      
    Until (Result <> 256 And ElapsedMilliseconds() - Start > TimeOutSec) Or ResultFound
    
    CloseNetworkConnection(connection) 
    
  Else 
    LastDownloadError = "OpenNetworkConnection("+GetURLPart(sURL.s, #PB_URL_Site)+", 80) failed"          
  EndIf 
  
  ProcedureReturn Output 
EndProcedure 
Procedure.s UploadError(Str.s)
  
  
  If Str = ""
    Result.s = "NO CONNECTION!" 
  EndIf
  
  If FindString(Str,"DATA SUCCESSFULLY SAVED!",1)
    Str.s = ""
    Result.s = "DATA SUCCESSFULLY SAVED!"
  EndIf
  
  If FindString(Str,"ERROR, PROJECT KEY NOT CORRECT!",1)
    Str.s = ""
    Result.s = "ERROR, CODE 1!"
  EndIf 
  
  If FindString(Str,"ERROR, BAD AGENT!",1)
    Str.s = ""
    Result.s = "ERROR, CODE 2!"
  EndIf 
  
  If Str <> ""
    Result.s = "UNKNOWN ERROR!"
  EndIf
  
  
  ProcedureReturn Result
EndProcedure



CompilerIf #Use3DView = #True
  Procedure IsDX7BackBufferLost()
    !EXTRN _PB_DirectX_BackBuffer
    Buffer.IDirectDrawSurface7 = 0
    !MOV Eax,[_PB_DirectX_BackBuffer]
    !MOV [p.v_Buffer],Eax
    If Buffer
      If Buffer\IsLost():ProcedureReturn #True:EndIf
    EndIf
  EndProcedure
CompilerEndIf
CompilerIf #PB_Compiler_OS = #PB_OS_Linux
CompilerElse
  Procedure SetFileType(File.s,Type.s);Type = ".LCF"
    CompilerIf #PB_editor_createexecutable
      FileName.s = GetFilePart(File)
      
      
      If RegCreateKeyEx_(#HKEY_CLASSES_ROOT, "Applications\"+FileName+"\shell\open\command", 0, 0, #REG_OPTION_NON_VOLATILE, #KEY_ALL_ACCESS, 0, @NewKey, @KeyInfo) = #ERROR_SUCCESS
        StringBuffer$ = Chr(34)+File+Chr(34)+" "+Chr(34)+"%1"+Chr(34)
        RegSetValueEx_(NewKey, "", 0, #REG_SZ,  StringBuffer$, Len(StringBuffer$)+1)
        RegCloseKey_(NewKey)
      EndIf
      
      If RegCreateKeyEx_(#HKEY_CURRENT_USER, "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\"+Type, 0, 0, #REG_OPTION_NON_VOLATILE, #KEY_ALL_ACCESS, 0, @NewKey, @KeyInfo) = #ERROR_SUCCESS
        RegSetValueEx_(NewKey, "Application", 0, #REG_SZ,  FileName, Len(FileName)+1)
        RegCloseKey_(NewKey)
      EndIf
      
      
    CompilerEndIf
  EndProcedure
CompilerEndIf


Procedure TestNewVersion(MSG=#False)
If TestInternet()

CompilerIf #PB_Compiler_OS = #PB_OS_Linux
  Str.s = RowDownloadToString(URLEncoder(UPLOAD_URL.s+UPLOAD_VERSION), "LC_VersionsCheck_Linux", 10)
  ServerVersion.s = LCase(Trim(Str))
CompilerElse
  Buffer.s=Space(256)
  DownloadToMem("LC_VersionsCheck_Win" , URLEncoder(UPLOAD_URL.s+UPLOAD_VERSION), @Buffer, 255)
  ServerVersion.s = LCase(Trim(Buffer))
CompilerEndIf

If ServerVersion <> #Version
MessageRequester(ReadPreferenceString_(languagefile, "text", "old-Version"),ReadPreferenceString_(languagefile, "text", "old-Version")+Chr(10)+Chr(10)+ReadPreferenceString_(languagefile, "text", "Your-version")+" V"+#Version+Chr(10)+ReadPreferenceString_(languagefile, "text", "newst-version")+" V"+ServerVersion)
ProcedureReturn #False
EndIf

If ServerVersion = #Version And MSG=#True
MessageRequester(ReadPreferenceString_(languagefile, "text", "You-have-newest-version"),ReadPreferenceString_(languagefile, "text", "You-have-newest-version"))
ProcedureReturn #True
EndIf
Else
ProcedureReturn #True
EndIf
EndProcedure


Global Dim CalcLines(#MAX_CELLS+1,#CODE_SIZE*4)
Global OldClacLine
Global OldClacLineResult
Global OldClacLineCell
Global OldClacLineCounter
Procedure ClearCalcLine()

For c=0 To #MAX_CELLS
For p=0 To #CODE_SIZE
CalcLines(c,p)=-1
Next
Next
OldClacLine = 0
OldClacLineResult = 0
OldClacLineCell = 0
EndProcedure
Procedure HighlightCell(Cell, HighlightAll=#False)
  If GadGet\Creature[cell]\CodeEditor>0 And IsGadget(GadGet\Creature[cell]\CodeEditor)
  line=ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_GETLINECOUNT,i)
  For i=0 To line
    If CalcLines(cell,i)=-1 Or HighlightAll
      linelen=ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_LINELENGTH,i)
      Str.s=Space(linelen)
      ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_GETLINE,i,@Str)
      Str=Trim(UCase(Str))
      found=0
      For c=0 To #CMD_NOP
       Str2.s=CodeToCMDString(c)
       If Mid(Str,1,Len(Str2))=Str2
         lines+1
         CalcLines(cell,i)=1
         found=1
         pos=ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_POSITIONFROMLINE,i)
         ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_STARTSTYLING,pos,-1)
         ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_SETSTYLING,linelen,0)
         Break
       EndIf
      Next
      If found=0
        If Mid(Str,1,2)="DL"
           lines+1
           CalcLines(cell,i)=1
           found=1
           pos=ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_POSITIONFROMLINE,i)
           ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_STARTSTYLING,pos,-1)
           ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_SETSTYLING,linelen,0)
        EndIf
      EndIf
      
      If found=0
        CalcLines(cell,i)=0
        linelen=ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_LINELENGTH,i)
        pos=ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_POSITIONFROMLINE,i)
        ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_STARTSTYLING,pos,-1)
        ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_SETSTYLING,linelen,#SYNTAX_Error)
      EndIf
      
    EndIf
  Next
  
EndIf
EndProcedure
Procedure HighlightAll(Numcells)
For cell=0 To Numcells
  HighlightCell(Cell)
Next
EndProcedure
Procedure CalcLine(cell)

If IsGadget(GadGet\Creature[cell]\CodeEditor) And GadGet\Creature[cell]\CodeEditor<>0

pos = ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_GETCURRENTPOS)  
line = ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_LINEFROMPOSITION,pos)
CalcLines(cell,line)=-1

If OldClacLine = line And OldClacLineCell=cell
  lines-1;=OldClacLineResult
  ;lines=OldClacLineResult
Else
  If line<#CODE_SIZE*4
  ;Debug "Line "+Str(line)
  
  linelen=ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_LINELENGTH,OldClacLine)
  Str.s=Space(linelen)
  ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_GETLINE,OldClacLine,@Str)
  Str=UCase(Trim(Str))
  found=0
  For c=0 To #CMD_NOP
   Str2.s=CodeToCMDString(c)
   If Mid(Str,1,Len(Str2))=Str2
     ;Debug Str(OldClacLine)+" Found"
     CalcLines(cell,OldClacLine)=1
     found=1
     pos=ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_POSITIONFROMLINE,OldClacLine)
     ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_STARTSTYLING,pos,-1)
     ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_SETSTYLING,linelen,0)
     Break
   EndIf
  Next
  If found=0
    If Mid(Str,1,2)="DL"
       CalcLines(cell,OldClacLine)=1
       found=1
       pos=ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_POSITIONFROMLINE,OldClacLine)
       ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_STARTSTYLING,pos,-1)
       ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_SETSTYLING,linelen,0)
    EndIf
  EndIf
  
  If found=0
    ;Debug Str(OldClacLine)+" not Found"
    CalcLines(cell,OldClacLine)=0
    linelen=ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_LINELENGTH,OldClacLine)
    pos=ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_POSITIONFROMLINE,OldClacLine)
    ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_STARTSTYLING,pos,-1)
    ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_SETSTYLING,linelen,#SYNTAX_Error)
  EndIf
  
  
  
  
  For i=line To #CODE_SIZE*4
    CalcLines(cell,i)=-1
  Next
  
  For i=0 To line-1
    If CalcLines(cell,i)=1
      lines+1
    Else
      If CalcLines(cell,i)=-1
        linelen=ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_LINELENGTH,i)
        Str.s=Space(linelen)
        ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_GETLINE,i,@Str)
        Str=Trim(UCase(Str))
        found=0
        For c=0 To #CMD_NOP
         Str2.s=CodeToCMDString(c)
         If Mid(Str,1,Len(Str2))=Str2
           ;Debug Str(i)+" Found"
           lines+1
           CalcLines(cell,i)=1
           found=1
           pos=ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_POSITIONFROMLINE,i)
           ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_STARTSTYLING,pos,-1)
           ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_SETSTYLING,linelen,0)
           Break
         EndIf
        Next
        If found=0
          If Mid(Str,1,2)="DL"
             lines+1
             CalcLines(cell,i)=1
             found=1
             pos=ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_POSITIONFROMLINE,i)
             ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_STARTSTYLING,pos,-1)
             ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_SETSTYLING,linelen,0)
          EndIf
        EndIf
        
        If found=0
          ;Debug Str(i)+" not Found"
          CalcLines(cell,i)=0
          linelen=ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_LINELENGTH,i)
          pos=ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_POSITIONFROMLINE,i)
          ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_STARTSTYLING,pos,-1)
          ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_SETSTYLING,linelen,#SYNTAX_Error)
        EndIf
      
      EndIf
      
    EndIf
   
  ;Debug Str(i)+"  "+Str(CalcLines(cell,i))
  Next
  ;Debug "--------------------"
 
  EndIf
  
OldClacLine = line
OldClacLineResult = lines
OldClacLineCell = cell
EndIf

EndIf

ProcedureReturn lines
EndProcedure

CompilerIf #PB_Compiler_OS = #PB_OS_Linux
Procedure ToolTip(Gadget, Text$ , Title$="Living-Code", Icon=0)
GadgetToolTip(Gadget, Text$) 
EndProcedure
CompilerElse
Procedure ToolTip(Gadget, Text$ , Title$="Living-Code", Icon=#TOOLTIP_INFO_ICON)
  WindowID=GadgetID(Gadget)
  ToolTip=CreateWindowEx_(0,"ToolTips_Class32","",#WS_POPUP | #TTS_NOPREFIX | #TTS_BALLOON,0,0,0,0,WindowID,0,GetModuleHandle_(0),0)
  SendMessage_(ToolTip,#TTM_SETTIPTEXTCOLOR,GetSysColor_(#COLOR_INFOTEXT),0)
  SendMessage_(ToolTip,#TTM_SETTIPBKCOLOR,GetSysColor_(#COLOR_INFOBK),0)
  SendMessage_(ToolTip,#TTM_SETMAXTIPWIDTH,0,180)
  Balloon.TOOLINFO\cbSize=SizeOf(TOOLINFO)
  Balloon\uFlags=#TTF_IDISHWND | #TTF_SUBCLASS
  Balloon\hWnd=GadgetID(Gadget)
  Balloon\uId=GadgetID(Gadget)
  Balloon\lpszText=@Text$
  SendMessage_(ToolTip, #TTM_ADDTOOL, 0, Balloon)
  If Title$ > ""
    SendMessage_(ToolTip, #TTM_SETTITLE, Icon, @Title$)
  EndIf

EndProcedure
CompilerEndIf

Procedure GenerateCForm()
  rndcells=(CreatureCellCount/2)-1
  For cell=0 To rndcells
    rad=Random(GlobalVar\CREATURE_MAXRADIUS-GlobalVar\CREATURE_MINRADIUS)+GlobalVar\CREATURE_MINRADIUS
    SetGadgetText(CC_Preview(cell)\Radius_Str,Str(rad))
    SetGadgetText(CC_Preview(cell+rndcells+1)\Radius_Str,Str(rad))
    SetGadgetText(CC_Preview(cell)\OrgRadius_Str,Str(rad))
    SetGadgetText(CC_Preview(cell+rndcells+1)\OrgRadius_Str,Str(rad))
    
    SetGadgetText(GadGet\Creature[cell]\CellRandiusStr,Str(rad))
    SetGadgetText(GadGet\Creature[cell]\CellOrgRandiusStr,Str(rad))

    SetGadgetText(GadGet\Creature[cell+rndcells+1]\CellRandiusStr,Str(rad))
    SetGadgetText(GadGet\Creature[cell+rndcells+1]\CellOrgRandiusStr,Str(rad))

    
  Next
  If CreatureCellCount-(rndcells+1)*2>0
    rad=Random(GlobalVar\CREATURE_MAXRADIUS-GlobalVar\CREATURE_MINRADIUS)+GlobalVar\CREATURE_MINRADIUS
    SetGadgetText(CC_Preview(CreatureCellCount-1)\Radius_Str,Str(rad))
    SetGadgetText(CC_Preview(CreatureCellCount-1)\OrgRadius_Str,Str(rad))
    
    SetGadgetText(GadGet\Creature[CreatureCellCount-1]\CellRandiusStr,Str(rad))
    SetGadgetText(GadGet\Creature[CreatureCellCount-1]\CellOrgRandiusStr,Str(rad))

  EndIf
EndProcedure






Procedure CreateGUI()
  CompilerIf #PB_Compiler_OS = #PB_OS_Linux
    If CreateMenu(0, WindowID(0))
      
      Menu_Image_Logo = LoadImage(#PB_Any,Datapath+"RRSoftware.png")
      Menu_Image_Logo_HP = LoadImage(#PB_Any,Datapath+"RR-Website.png")
      
      MenuTitle(ReadPreferenceString_(languagefile, "text", "File"))
      MenuItem( #Menu_New, ReadPreferenceString_(languagefile, "text", "New")+Chr(9)+"Ctrl+N" )
      MenuItem( #Menu_Options, ReadPreferenceString_(languagefile, "text", "Options"))
      MenuBar()
      MenuItem( #Menu_Load, ReadPreferenceString_(languagefile, "text", "Load")+"..."+Chr(9)+"Ctrl+O")
      MenuItem( #Menu_SaveAs, ReadPreferenceString_(languagefile, "text", "Save-As")+"..."+Chr(9)+"Ctrl+S")
      MenuBar()
      MenuItem(#Menu_MakeScreenshot,ReadPreferenceString_(languagefile, "text", "Screenshot")+Chr(9)+"F5")
      MenuBar()
      MenuItem( #Menu_Quit, ReadPreferenceString_(languagefile, "text", "Quit"))
      
      MenuTitle(ReadPreferenceString_(languagefile, "text", "Insert"))
      MenuItem(#Menu_OwnCreature, ReadPreferenceString_(languagefile, "text", "Own-Creature"))
      MenuItem(#Menu_InsertCreatures, ReadPreferenceString_(languagefile, "text", "More-Creatures"))
      MenuItem(#Menu_Download_Insert, ReadPreferenceString_(languagefile, "text", "Download-Creature"))
      MenuItem(#Menu_Random_Creature, ReadPreferenceString_(languagefile, "text", "Random-creature"))
      MenuItem(#Menu_Creature_Generator, ReadPreferenceString_(languagefile, "text", "Creature-Generator"))
      MenuBar()
      MenuItem( #Menu_ADDFOOD, ReadPreferenceString_(languagefile, "text", "ADD-Food"))
      MenuItem( #Menu_ADDVIEREN, ReadPreferenceString_(languagefile, "text", "ADD-Viruses"))
      MenuBar()
      ADDInsert(#Menu_OwnCreature);Letztes element
      
      MenuTitle(ReadPreferenceString_(languagefile, "text", "Creature"))
      MenuItem(#Menu_Creature_Edit, ReadPreferenceString_(languagefile, "text", "Edit")+Chr(9)+"Ctrl+E")
      MenuItem(#Menu_Creature_Kill, ReadPreferenceString_(languagefile, "text", "Kill")+Chr(9)+"Ctrl+K")
      MenuItem(#Menu_Creature_Delete, ReadPreferenceString_(languagefile, "text", "Delete")+Chr(9)+"Ctrl+D")
      MenuBar()
      MenuItem(#Menu_Creature_KillAll, ReadPreferenceString_(languagefile, "text", "Kill")+" "+ReadPreferenceString_(languagefile, "text", "All"))
      MenuItem(#Menu_Creature_DeleteAll, ReadPreferenceString_(languagefile, "text", "Delete")+" "+ReadPreferenceString_(languagefile, "text", "All"))
      
      MenuTitle(ReadPreferenceString_(languagefile, "text", "Mode"))
      MenuItem(#Menu_Modus_GamingMode, ReadPreferenceString_(languagefile, "text", "Gaming-mode"))
      MenuItem(#Menu_Modus_EvolutionMode, ReadPreferenceString_(languagefile, "text", "Evolution-mode"))
            
      MenuTitle("?")
      MenuItem( #Menu_Help, ReadPreferenceString_(languagefile, "text", "Help")+Chr(9)+"F1")
      MenuItem( #Menu_GermanHelp, ReadPreferenceString_(languagefile, "text", "German-help")+Chr(9)+"F2")
      MenuItem( #Menu_Homepage, ReadPreferenceString_(languagefile, "text", "Homepage")+Chr(9)+"F3")
      MenuItem( #Menu_Forum, ReadPreferenceString_(languagefile, "text", "Forum")+Chr(9)+"F6")
      MenuItem( #Menu_SearchUpdate, ReadPreferenceString_(languagefile, "text", "Search-update"))
      MenuItem( #Menu_Report, ReadPreferenceString_(languagefile, "text", "Send-Report"))
      MenuItem( #Menu_About, ReadPreferenceString_(languagefile, "text", "About")+Chr(9)+"F4")
      
      MenuBar()
      MenuItem(#Menu_Language_English, "English")
      MenuItem(#Menu_Language_German, "German")
      MenuItem(#Menu_Language_Franz, "Französisch")
      
      
    EndIf
    
  CompilerElse
    If CreateImageMenu(0, WindowID(0),#PB_Menu_ModernLook)
      
      Menu_Image_Load = LoadImage(#PB_Any,Datapath+"Open.ico")
      Menu_Image_Save = LoadImage(#PB_Any,Datapath+"Save.ico")
      Menu_Image_Quit = LoadImage(#PB_Any,Datapath+"Quit.ico")
      Menu_Image_OwnCr = LoadImage(#PB_Any,Datapath+"20.ico")
      Menu_Image_Help = LoadImage(#PB_Any,Datapath+"Help.ico")
      Menu_Image_About = LoadImage(#PB_Any,Datapath+"16.ico")
      Menu_Image_Insert = LoadImage(#PB_Any,Datapath+"14.ico")
      Menu_Image_New = LoadImage(#PB_Any,Datapath+"2.ico")
      Menu_Image_Options = LoadImage(#PB_Any,Datapath+"11.ico")
      Menu_Image_Kill = LoadImage(#PB_Any,Datapath+"6.ico")
      Menu_Image_Logo = LoadImage(#PB_Any,Datapath+"RRSoftware.ico")
      Menu_Image_Logo_HP = LoadImage(#PB_Any,Datapath+"RR-Website.ico")
      Menu_Image_Homepage = LoadImage(#PB_Any,Datapath+"Alien_16x16.ico")
      Menu_Image_Forum = LoadImage(#PB_Any,Datapath+"ICO_RR.ico")
      
      Menu_Image_Language = LoadImage(#PB_Any,Datapath+"13.ico")
      
      MenuTitle(ReadPreferenceString_(languagefile, "text", "File"))
      MenuItem(#Menu_New, ReadPreferenceString_(languagefile, "text", "New")+Chr(9)+"Ctrl+N", ImageID(Menu_Image_New))
      MenuItem(#Menu_Options, ReadPreferenceString_(languagefile, "text", "Options"), ImageID(Menu_Image_Options))
      MenuBar()
      MenuItem(#Menu_Load, ReadPreferenceString_(languagefile, "text", "Load")+"..."+Chr(9)+"Ctrl+O", ImageID(Menu_Image_Load))
      MenuItem(#Menu_SaveAs, ReadPreferenceString_(languagefile, "text", "Save-As")+"..."+Chr(9)+"Ctrl+S", ImageID(Menu_Image_Save))
      MenuBar()
      MenuItem(#Menu_MakeScreenshot,ReadPreferenceString_(languagefile, "text", "ScreenShot")+Chr(9)+"F5")
      MenuBar()
      MenuItem(#Menu_Quit, ReadPreferenceString_(languagefile, "text", "Quit"), ImageID(Menu_Image_Quit))
      
      MenuTitle(ReadPreferenceString_(languagefile, "text", "Insert"))
      MenuItem(#Menu_OwnCreature, ReadPreferenceString_(languagefile, "text", "Own-Creature"), ImageID(Menu_Image_OwnCr))
      MenuItem(#Menu_InsertCreatures, ReadPreferenceString_(languagefile, "text", "More-Creatures"), ImageID(Menu_Image_OwnCr))
      MenuItem(#Menu_Download_Insert, ReadPreferenceString_(languagefile, "text", "Download-Creature"), ImageID(Menu_Image_OwnCr))      
      MenuItem(#Menu_Random_Creature, ReadPreferenceString_(languagefile, "text", "Random-Creature"), ImageID(Menu_Image_OwnCr))
      MenuItem(#Menu_Creature_Generator, ReadPreferenceString_(languagefile, "text", "Creature-Generator"), ImageID(Menu_Image_OwnCr))
      MenuBar()
      MenuItem(#Menu_ADDFOOD, ReadPreferenceString_(languagefile, "text", "ADD-Food"), ImageID(Menu_Image_OwnCr))
      MenuItem(#Menu_ADDVIEREN, ReadPreferenceString_(languagefile, "text", "ADD-Viruses"), ImageID(Menu_Image_OwnCr))
      
      MenuBar()
      ADDInsert(#Menu_OwnCreature);Letztes element
      
      MenuTitle(ReadPreferenceString_(languagefile, "text", "Creature"))
      MenuItem(#Menu_Creature_Edit, ReadPreferenceString_(languagefile, "text", "Edit")+Chr(9)+"Ctrl+E", ImageID(Menu_Image_Options))
      MenuItem(#Menu_Creature_Kill, ReadPreferenceString_(languagefile, "text", "Kill")+Chr(9)+"Ctrl+K",ImageID(Menu_Image_Kill))
      MenuItem(#Menu_Creature_Delete, ReadPreferenceString_(languagefile, "text", "Delete")+Chr(9)+"Ctrl+D", ImageID(Menu_Image_Quit))
      MenuBar()
      MenuItem(#Menu_Creature_KillAll, ReadPreferenceString_(languagefile, "text", "Kill")+" "+ReadPreferenceString_(languagefile, "text", "All"),ImageID(Menu_Image_Kill))
      MenuItem(#Menu_Creature_DeleteAll, ReadPreferenceString_(languagefile, "text", "Delete")+" "+ReadPreferenceString_(languagefile, "text", "All"), ImageID(Menu_Image_Quit))
      
      MenuTitle("Mode")
      MenuItem(#Menu_Modus_GamingMode, ReadPreferenceString_(languagefile, "text", "Gaming-mode"), ImageID(Menu_Image_OwnCr))
      MenuItem(#Menu_Modus_EvolutionMode, ReadPreferenceString_(languagefile, "text", "Evolution-mode"), ImageID(Menu_Image_OwnCr))
      
      MenuTitle("?")
      MenuItem( #Menu_Help, ReadPreferenceString_(languagefile, "text", "Help")+Chr(9)+"F1", ImageID(Menu_Image_Help))
      MenuItem( #Menu_GermanHelp, ReadPreferenceString_(languagefile, "text", "German-help")+Chr(9)+"F2", ImageID(Menu_Image_Help))
      MenuItem( #Menu_Homepage, ReadPreferenceString_(languagefile, "text", "Homepage")+Chr(9)+"F3", ImageID(Menu_Image_Homepage))
      MenuItem( #Menu_Forum, ReadPreferenceString_(languagefile, "text", "Forum")+Chr(9)+"F6", ImageID(Menu_Image_Forum))
      MenuItem( #Menu_SearchUpdate, ReadPreferenceString_(languagefile, "text", "Search-update"), ImageID(Menu_Image_Homepage))
      MenuItem( #Menu_Report, ReadPreferenceString_(languagefile, "text", "Send-Report"), ImageID(Menu_Image_Help))
      MenuItem( #Menu_About, ReadPreferenceString_(languagefile, "text", "About")+Chr(9)+"F4", ImageID(Menu_Image_About))
      
      MenuBar()
      MenuItem(#Menu_Language_English, "English",ImageID(Menu_Image_Language))
      MenuItem(#Menu_Language_German, "German",ImageID(Menu_Image_Language))
      MenuItem(#Menu_Language_Franz, "Französisch",ImageID(Menu_Image_Language))
      
    EndIf
    LoadFont(0, "Comic Sans MS", 10,#PB_Font_Bold)
  CompilerEndIf
  
  
  
  AddKeyboardShortcut(#Window_Main,#PB_Shortcut_Control|#PB_Shortcut_E,#Menu_Creature_Edit)
  AddKeyboardShortcut(#Window_Main,#PB_Shortcut_Control|#PB_Shortcut_K,#Menu_Creature_Kill)
  AddKeyboardShortcut(#Window_Main,#PB_Shortcut_Control|#PB_Shortcut_D,#Menu_Creature_Delete)
  
  
  AddKeyboardShortcut(#Window_Main,#PB_Shortcut_F1,#Menu_Help)
  AddKeyboardShortcut(#Window_Main,#PB_Shortcut_F2,#Menu_GermanHelp)
  AddKeyboardShortcut(#Window_Main,#PB_Shortcut_F3,#Menu_Homepage)
  AddKeyboardShortcut(#Window_Main,#PB_Shortcut_F4,#Menu_About)
  AddKeyboardShortcut(#Window_Main,#PB_Shortcut_Control|#PB_Shortcut_N,#Menu_New)
  AddKeyboardShortcut(#Window_Main,#PB_Shortcut_Control|#PB_Shortcut_O,#Menu_Load)
  AddKeyboardShortcut(#Window_Main,#PB_Shortcut_Control|#PB_Shortcut_S,#Menu_SaveAs)
  AddKeyboardShortcut(#Window_Main,#PB_Shortcut_F5,#Menu_MakeScreenshot)
  AddKeyboardShortcut(#Window_Main,#PB_Shortcut_F6,#Menu_Forum)
  

  UseGadgetList(WindowID(#Window_Main))
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Linux
    PanelGadget(#Pannel,0,0,210,481)
  CompilerElse
    PanelGadget(#Pannel,641,0,210,481)
  CompilerEndIf
  EnableGadgetDrop(#Pannel,    #PB_Drop_Files,   #PB_Drag_Copy)
  
  AddGadgetItem(#Pannel, -1, ReadPreferenceString_(languagefile, "text", "Main"))
  ;************
  ;****MAIN****
  ;************
  
  TextGadget(#Text_MinimalCreatures, 5, 5, 150, 15, ReadPreferenceString_(languagefile, "text", "Minimal-Creatures")+":")
  SpinGadget(#MinimalCreatures,5, 20,50,20,0,50, #PB_Spin_Numeric)
  SetGadgetState(#MinimalCreatures, GlobalVar\MinimalCreatures)
  ;CompilerIf #PB_Compiler_OS = #PB_OS_Linux
  ;CompilerElse
  G=ImageGadget(#PB_Any,77,399,128,128,ImageID(Menu_Image_Logo))
  ToolTip(G, "RocketRider HP"+#LF$+"http://www.RRSoftware.de")
  G=ImageGadget(#PB_Any,135,280,128,128,ImageID(Menu_Image_Logo_HP))
  ToolTip(G, "RocketRider Forum"+#LF$+"http://www.RocketRider.eu")
  ;CompilerEndIf
  
  
  
  TextGadget(#Text_Option_RightM      ,5,55, 150, 15, ReadPreferenceString_(languagefile, "text", "Right-Mousebutton")+":")
  OptionGadget(#Option_RightM_FOOD    ,5,75,100,15,ReadPreferenceString_(languagefile, "text", "Food"))
  OptionGadget(#Option_RightM_VIRUSES ,5,95,100,15,ReadPreferenceString_(languagefile, "text", "Viruses"))
  OptionGadget(#Option_RightM_DNA     ,5,115,100,15,ReadPreferenceString_(languagefile, "text", "DNA"))
  OptionGadget(#Option_RightM_POISON  ,5,135,100,15,ReadPreferenceString_(languagefile, "text", "Poison"))
  OptionGadget(#Option_RightM_Delete  ,5,155,100,15,ReadPreferenceString_(languagefile, "text", "Delete-Objects"))
  SetGadgetState(#Option_RightM_FOOD ,#True)
  
  TextGadget(#Text_Track_Mutation,5,180, 120, 15, ReadPreferenceString_(languagefile, "text", "Mutation-probability")+":")
  CompilerIf #PB_Compiler_OS = #PB_OS_Linux
    TrackBarGadget(#Track_Mutation,5, 200,200,20,0,2000)
  CompilerElse
    TrackBarGadget(#Track_Mutation,5, 200,200,20,0,2000,256);#TBS_TOOLTIPS
  CompilerEndIf
  SetGadgetState(#Track_Mutation,GlobalVar\MUTATION_PROBABILITY)
  
  
  AddGadgetItem(#Pannel, -1, ReadPreferenceString_(languagefile, "text", "Settings"))
  ;****************
  ;****SETTINGS****
  ;****************
  G=ImageGadget(#PB_Any,77,399,128,128,ImageID(Menu_Image_Logo))
  ToolTip(G, "RocketRider HP"+#LF$+"http://www.RRSoftware.de")
  G=ImageGadget(#PB_Any,135,280,128,128,ImageID(Menu_Image_Logo_HP))
  ToolTip(G, "RocketRider Forum"+#LF$+"http://www.RocketRider.eu")
  
  
  
  CheckBoxGadget(#CheckBox_Break, 5, 30, 70, 20, ReadPreferenceString_(languagefile, "text", "Break"))
  ButtonGadget(#Background,5, 5, 70, 20, ReadPreferenceString_(languagefile, "text", "Background"))
  
  ButtonGadget(#View3D,80, 5, 90, 20, ReadPreferenceString_(languagefile, "text", "3D-View"))
  
  CompilerIf #Use3DView = #False
    DisableGadget(#View3D,#True)
  CompilerElse
    ImageGadget(#View3D_Help,5,250,170,170,ImageID(LoadImage(#PB_Any,"Data\3DView.png")))
    HideGadget(#View3D_Help,#True)
  CompilerEndIf
  
  OptionGadget(#Option_SingleCore,5,55,150,20,ReadPreferenceString_(languagefile, "text", "Singlecore"))
  OptionGadget(#Option_MultiCore,5,75,150,20,ReadPreferenceString_(languagefile, "text", "Multicore"))
  
  TextGadget(#Text_Threads, 5, 100, 150, 15, ReadPreferenceString_(languagefile, "text", "Threads")+":")
  SpinGadget(#Threads,5, 120,50,20,1,100, #PB_Spin_Numeric)
  SetGadgetState(#Threads, WORKER_COUNT)
  
  If UseMultiCore=#True
    SetGadgetState(#Option_MultiCore,#True)
  Else
    SetGadgetState(#Option_SingleCore,#True)
  EndIf
  CheckBoxGadget(#CheckBox_Sounds, 5, 150, 150, 20, ReadPreferenceString_(languagefile, "text", "Enable-Sounds"))
  SetGadgetState(#CheckBox_Sounds,GlobalSoundOn)
  If GlobalSound.l = #False
    DisableGadget(#CheckBox_Sounds, #True)
  EndIf
  
  TextGadget(#Text_Ticks, 5, 180, 150, 15, ReadPreferenceString_(languagefile, "text", "Ticks-per-frame")+":")
  SpinGadget(#Ticks,5, 200,50,20,1,100, #PB_Spin_Numeric)
  SetGadgetText(#Ticks,Str(GlobalVar\ExecuteCount))
  
  
  CheckBoxGadget(#CheckBox_Reducecpuusage, 5, 225, 150, 20, ReadPreferenceString_(languagefile, "text", "reduce-CPU-usage"))
  SetGadgetState(#CheckBox_Reducecpuusage,GlobalVar\Reducecpuusage)  
  
  
  
  
  AddGadgetItem(#Pannel, -1, ReadPreferenceString_(languagefile, "text", "Drawing"))
  ;***************
  ;****DRAWING****
  ;***************
  G=ImageGadget(#PB_Any,77,399,128,128,ImageID(Menu_Image_Logo))
  ToolTip(G, "RocketRider HP"+#LF$+"http://www.RRSoftware.de")
  G=ImageGadget(#PB_Any,135,280,128,128,ImageID(Menu_Image_Logo_HP))
  ToolTip(G, "RocketRider Forum"+#LF$+"http://www.RocketRider.eu")
  
  CheckBoxGadget(#CheckBox_FOOD,     5, 5,   150, 20, ReadPreferenceString_(languagefile, "text", "Draw") +" "+ ReadPreferenceString_(languagefile, "text", "Food"))
  CheckBoxGadget(#CheckBox_VIRUS,    5, 30,  150, 20, ReadPreferenceString_(languagefile, "text", "Draw") +" "+ ReadPreferenceString_(languagefile, "text", "Virus"))
  CheckBoxGadget(#CheckBox_DNA,      5, 55,  150, 20, ReadPreferenceString_(languagefile, "text", "Draw") +" "+ ReadPreferenceString_(languagefile, "text", "DNA"))
  CheckBoxGadget(#CheckBox_POISON,   5, 80,  150, 20, ReadPreferenceString_(languagefile, "text", "Draw") +" "+ ReadPreferenceString_(languagefile, "text", "Poison"))
  CheckBoxGadget(#CheckBox_MSG,      5, 105, 150, 20, ReadPreferenceString_(languagefile, "text", "Draw") +" "+ ReadPreferenceString_(languagefile, "text", "MSG"))
  CheckBoxGadget(#CheckBox_REST,     5, 130, 150, 20, ReadPreferenceString_(languagefile, "text", "Draw") +" "+ ReadPreferenceString_(languagefile, "text", "Rest"))
  CheckBoxGadget(#CheckBox_Creature, 5, 155, 150, 20, ReadPreferenceString_(languagefile, "text", "Draw") +" "+ ReadPreferenceString_(languagefile, "text", "Creature"))
  
  SetGadgetState(#CheckBox_FOOD,     #True) : GadGet\state\FOOD = #True
  SetGadgetState(#CheckBox_VIRUS,    #True) : GadGet\state\VIRUS = #True
  SetGadgetState(#CheckBox_DNA,      #True) : GadGet\state\DNA = #True
  SetGadgetState(#CheckBox_POISON,   #True) : GadGet\state\POISON = #True
  SetGadgetState(#CheckBox_MSG,      #True) : GadGet\state\msg = #True
  SetGadgetState(#CheckBox_REST,     #True) : GadGet\state\REST = #True
  SetGadgetState(#CheckBox_Creature, #True) : GadGet\state\Creature = #True
  
  TextGadget(#TEXT_ObjTrans, 5, 185, 150, 20, ReadPreferenceString_(languagefile, "text", "Object-transparecy"))
  TrackBarGadget(#Track_ObjTrans, 5, 200, 145, 20, 0, 255) 
  SetGadgetState(#Track_ObjTrans, GlobalVar\Object_Trans)
  
  AddGadgetItem(#Pannel, -1, ReadPreferenceString_(languagefile, "text", "Statistic")+":")
  ;*****************
  ;****STATISTIC****
  ;*****************
  G=ImageGadget(#PB_Any,77,399,128,128,ImageID(Menu_Image_Logo))
  ToolTip(G, "RocketRider HP"+#LF$+"http://www.RRSoftware.de")
  G=ImageGadget(#PB_Any,135,280,128,128,ImageID(Menu_Image_Logo_HP))
  ToolTip(G, "RocketRider Forum"+#LF$+"http://www.RocketRider.eu")
  
  TextGadget(#TEXT_FPS,5,5,150,20,"0 FPS")
  
  TextGadget(#TEXT_Timer,5,25,150,20,"")
  
  TextGadget(#TEXT_Creatures,20,60,150,20,ReadPreferenceString_(languagefile, "text", "Creatures")+": 0")
  TextGadget(#TEXT_FOOD     ,20,80,150,20,ReadPreferenceString_(languagefile, "text", "Food")+": 0")
  TextGadget(#TEXT_VIRUS    ,20,100,150,20,ReadPreferenceString_(languagefile, "text", "Virus")+": 0")
  TextGadget(#TEXT_DNA      ,20,120,150,20,ReadPreferenceString_(languagefile, "text", "DNA")+": 0")
  TextGadget(#TEXT_POISON   ,20,140,150,20,ReadPreferenceString_(languagefile, "text", "Poison")+": 0")
  TextGadget(#TEXT_MSG      ,20,160,150,20,ReadPreferenceString_(languagefile, "text", "MSG")+": 0")
  TextGadget(#TEXT_REST     ,20,180,150,20,ReadPreferenceString_(languagefile, "text", "Rest")+": 0")
  
  TextGadget(#TEXT_CreatureDebug  ,5,205,150,20,ReadPreferenceString_(languagefile, "text", "Creature-info")+":")
  TextGadget(#TEXT_CreatureDName  ,20,225,150,20,ReadPreferenceString_(languagefile, "text", "Name")+": ")
  TextGadget(#TEXT_CreatureDAuthor,20,245,150,20,ReadPreferenceString_(languagefile, "text", "Author")+": ")
  TextGadget(#TEXT_CreatureDEnergy,20,265,150,20,ReadPreferenceString_(languagefile, "text", "Energy")+": 0")
  TextGadget(#TEXT_CreatureDOrgEnergy,20,285,150,20,ReadPreferenceString_(languagefile, "text", "Orginal")+" "+ReadPreferenceString_(languagefile, "text", "Energy")+": 0")
  
  TextGadget(#TEXT_MostCreatures1,5,310,150,20,"")
  TextGadget(#TEXT_MostCreatures2,5,330,150,20,"")
  TextGadget(#TEXT_MostCreatures3,5,350,150,20,"")
  

  
  CompilerIf #PB_Compiler_OS = #PB_OS_Linux
    DisableGadget(#Option_SingleCore,#True)
    DisableGadget(#Option_MultiCore,#True)
    DisableGadget(#Threads,#True)
    DisableGadget(#Track_ObjTrans,#True)
    DisableGadget(#Background,#True)
    
    
    
    
    ImageGadget(#TEXT_IMG_Creatures, 3, 59, 20, 20,ImageID(LoadImage(#PB_Any,Datapath+"Creature.png")))
    ImageGadget(#TEXT_IMG_FOOD     , 5, 82, 20, 20,ImageID(LoadImage(#PB_Any,Datapath+"Food.png")))
    ImageGadget(#TEXT_IMG_VIRUS    , 5, 102, 20, 20,ImageID(LoadImage(#PB_Any,Datapath+"Virus.png")))
    ImageGadget(#TEXT_IMG_DNA      , 5, 122, 20, 20,ImageID(LoadImage(#PB_Any,Datapath+"DNA.png")))
    ImageGadget(#TEXT_IMG_POISON   , 5, 142, 20, 20,ImageID(LoadImage(#PB_Any,Datapath+"Poison.png")))
    ImageGadget(#TEXT_IMG_MSG      , 5, 164, 20, 20,ImageID(LoadImage(#PB_Any,Datapath+"MSG.png")))
    ImageGadget(#TEXT_IMG_REST     , 5, 182, 20, 20,ImageID(LoadImage(#PB_Any,Datapath+"Rest.png")))
    
    
  CompilerElse
    
    
    ImageGadget(#TEXT_IMG_Creatures, 3, 59, 20, 20,ImageID(LoadImage(#PB_Any,Datapath+"Creature.ico")))
    ImageGadget(#TEXT_IMG_FOOD     , 5, 82, 20, 20,ImageID(LoadImage(#PB_Any,Datapath+"Food.ico")))
    ImageGadget(#TEXT_IMG_VIRUS    , 5, 102, 20, 20,ImageID(LoadImage(#PB_Any,Datapath+"Virus.ico")))
    ImageGadget(#TEXT_IMG_DNA      , 5, 122, 20, 20,ImageID(LoadImage(#PB_Any,Datapath+"DNA.ico")))
    ImageGadget(#TEXT_IMG_POISON   , 5, 142, 20, 20,ImageID(LoadImage(#PB_Any,Datapath+"Poison.ico")))
    ImageGadget(#TEXT_IMG_MSG      , 5, 164, 20, 20,ImageID(LoadImage(#PB_Any,Datapath+"MSG.ico")))
    ImageGadget(#TEXT_IMG_REST     , 5, 182, 20, 20,ImageID(LoadImage(#PB_Any,Datapath+"Rest.ico")))
    
    
    AddSysTrayIcon(0, WindowID(#Window_Main), LoadImage(1, Datapath+"Alien_16x16.ico"))
    SysTrayIconToolTip(0, "Living Code") 
  CompilerEndIf
  
  CloseGadgetList() 
  
EndProcedure
Procedure OpenAbout()
  CompilerIf #PB_Compiler_OS = #PB_OS_Linux
    OpenWindow(#Window_About, 0, 0, 400, 500, "Living Code", #PB_Window_SystemMenu|#PB_Window_ScreenCentered,WindowID(#Window_Main))
  CompilerElse
    OpenWindow(#Window_About, 0, 0, 400, 500, "Living Code", #PB_Window_SystemMenu|#PB_Window_ScreenCentered,WindowID(#Window_Main))
    SetWindowLong_(WindowID(#Window_About),#GWL_EXSTYLE,$00080000)
    SetLayeredWindowAttributes_(WindowID(#Window_About),0,240,2) 
  CompilerEndIf
  UseGadgetList(WindowID(#Window_About))

  CompilerIf #PB_Compiler_OS = #PB_OS_Linux
    ImageGadget(#About_Image,5,5,390,250,ImageID(Sprite\Game_Logo))
    EditorGadget(#About_Editor,5,260,390,210,#PB_Editor_ReadOnly|#PB_Text_Center)
    ButtonGadget(#About_OK,150,475,100,20,"OK")
    
    AboutText.s = ""
    AboutText + "==="+ReadPreferenceString_(languagefile, "text", "Important")+"===" + #LF$
    AboutText + ReadPreferenceString_(languagefile, "text", "You-use-the-software-at-your-own-risk") + #LF$ 
    AboutText + ReadPreferenceString_(languagefile, "text", "The-software-has-been-tested-much") + #LF$ 
    AboutText + ReadPreferenceString_(languagefile, "text", "however-errors-can-not-be-excluded") + #LF$ 
    AboutText + ReadPreferenceString_(languagefile, "text", "The-author-is-not-liable-for-any-damages") + #LF$ 
    AboutText + ReadPreferenceString_(languagefile, "text", "of-hardware-software-or-other") + #LF$
    AboutText + ReadPreferenceString_(languagefile, "text", "This-software-may-be-freely-copied-and-presented") + #LF$
    AboutText + "" + #LF$
    AboutText + ReadPreferenceString_(languagefile, "text", "Licence")+":" + #LF$
    AboutText + "Zlib" + #LF$
    AboutText + "" + #LF$
    AboutText + "==="+ReadPreferenceString_(languagefile, "text", "Special-thanks")+"===" + #LF$
    AboutText + "Hroudtwolf, hellhound66, Kaeru Gaman, bembulak, HB," + #LF$
    AboutText + "SvenF, Green Snake, Stefan, FireStorm, Leo, AndyX," + #LF$  
    AboutText + "dadido3, inc,night, Nusso, inte, PMTheQuick, Criss," + #LF$
    AboutText + "Dasix, Weiser Mann,Blitz Cheacker, Robin," + #LF$
    AboutText + "DarkDragon, Reifl, XCorE" + #LF$
    AboutText + "" + #LF$
    AboutText + "Team:" + #LF$
    AboutText + "BodomBeachTerror" + #LF$
    AboutText + "cxAlex, Ractur" + #LF$
    AboutText + "RocketRider" + #LF$
    AboutText + "" + #LF$
    AboutText + "(c) 2008 RocketRider" + #LF$;©
    AboutText + "www.RocketRider.eu" + #LF$
    AboutText + "Scintilla is Copyright 1998-2003 by" + #LF$
    AboutText + "Neil Hodgson <neilh@scintilla.org>" + #LF$
    AboutText + "" + #LF$
    AboutText + "" + #LF$
    AboutText + "Version: "+#VERSION + #LF$
    AboutText + "Build count: "+Str(#PB_Editor_BuildCount) + #LF$
    AboutText + "Editor Compile count: "+Str(#PB_Editor_CompileCount) + #LF$
    
    
    SetGadgetText(#About_Editor,AboutText)
    
    
    
    
  CompilerElse
    ImageGadget(#About_Image,5,5,390,250,ImageID(LoadImage(#PB_Any,"Data\Logo2.png")))
    ButtonGadget(#About_OK,150,475,100,20,"OK")
    
    TreeGadget(#About_Editor,5,260,390,210,#PB_Tree_NoButtons) 
    SetTreeGadgetBkImage(GadgetID(#About_Editor),WindowID(#Window_About),LoadImage(#PB_Any,"Data\About_BK.png"))
    LoadFont(1,"Comic Sans MS",9,#PB_Font_Bold)
    SetGadgetFont(#About_Editor,FontID(1))
    AddGadgetItem(#About_Editor, -1,"==="+ReadPreferenceString_(languagefile, "text", "Important")+"===")
    AddGadgetItem(#About_Editor, -1,ReadPreferenceString_(languagefile, "text", "You-use-the-software-at-your-own-risk")) 
    AddGadgetItem(#About_Editor, -1,ReadPreferenceString_(languagefile, "text", "The-software-has-been-tested-much")) 
    AddGadgetItem(#About_Editor, -1,ReadPreferenceString_(languagefile, "text", "however-errors-can-not-be-excluded")) 
    AddGadgetItem(#About_Editor, -1,ReadPreferenceString_(languagefile, "text", "The-author-is-not-liable-for-any-damages")) 
    AddGadgetItem(#About_Editor, -1,ReadPreferenceString_(languagefile, "text", "of-hardware-software-or-other"))
    AddGadgetItem(#About_Editor, -1,ReadPreferenceString_(languagefile, "text", "This-software-may-be-freely-copied-and-presented"))
    AddGadgetItem(#About_Editor, -1,"")
    AddGadgetItem(#About_Editor, -1,ReadPreferenceString_(languagefile, "text", "Licence")+":")
    AddGadgetItem(#About_Editor, -1,"Zlib")
    AddGadgetItem(#About_Editor, -1,"")
    AddGadgetItem(#About_Editor, -1,"==="+ReadPreferenceString_(languagefile, "text", "Special-thanks")+"===")
    AddGadgetItem(#About_Editor, -1,"Hroudtwolf, hellhound66, Kaeru Gaman, bembulak, HB,")
    AddGadgetItem(#About_Editor, -1,"SvenF, Green Snake, Stefan, FireStorm, Leo, AndyX,")  
    AddGadgetItem(#About_Editor, -1,"dadido3, inc,night, Nusso, inte, PMTheQuick, Criss,")
    AddGadgetItem(#About_Editor, -1,"Dasix, Weiser Mann,Blitz Cheacker, Robin,")
    AddGadgetItem(#About_Editor, -1,"DarkDragon, Reifl, XCorE")
    AddGadgetItem(#About_Editor, -1,"")
    AddGadgetItem(#About_Editor, -1,"Team:")
    AddGadgetItem(#About_Editor, -1,"BodomBeachTerror")
    AddGadgetItem(#About_Editor, -1,"cxAlex, Ractur")
    AddGadgetItem(#About_Editor, -1,"RocketRider")
    AddGadgetItem(#About_Editor, -1,"")
    AddGadgetItem(#About_Editor, -1,"(c) 2008 RocketRider");©
    AddGadgetItem(#About_Editor, -1,"www.RocketRider.eu")
    AddGadgetItem(#About_Editor, -1,"Scintilla is Copyright 1998-2003 by")
    AddGadgetItem(#About_Editor, -1,"Neil Hodgson <neilh@scintilla.org>")
    AddGadgetItem(#About_Editor, -1,"")
    AddGadgetItem(#About_Editor, -1,"")
    AddGadgetItem(#About_Editor, -1,"Version: "+#VERSION)
    AddGadgetItem(#About_Editor, -1,"Build count: "+Str(#PB_Editor_BuildCount))
    AddGadgetItem(#About_Editor, -1,"Editor Compile count: "+Str(#PB_Editor_CompileCount))
  CompilerEndIf
  
  
  
  
  
EndProcedure
Procedure OpenOptions()
  OpenWindow(#Window_Options, 0, 0, 400, 430, "Living Code", #PB_Window_SystemMenu|#PB_Window_ScreenCentered,WindowID(#Window_Main))
  UseGadgetList(WindowID(#Window_Options))
  ButtonGadget(#Options_OK,205,405,70,20,ReadPreferenceString_(languagefile, "text", "OK"))
  ButtonGadget(#Options_Cancel,125,405,70,20,ReadPreferenceString_(languagefile, "text", "Cancel"))
  ButtonGadget(#Options_Standard,5,405,70,20,ReadPreferenceString_(languagefile, "text", "Set-default"))
  
  PanelGadget(#Options_Panel,0,0,400,400)
  AddGadgetItem(#Options_Panel, -1, ReadPreferenceString_(languagefile, "text", "Creature"))
  ScrollAreaGadget(#Options_Creature_Area, 0, 0, 395, 375, 370, 700, 20) 
  
  ADDOptionsBoxCount = 0
  ADDOptionsBoxMaxCount = 0
  ADDOptionsBox("MOVESPEED",@GlobalVar\CREATURE_MOVESPEED,#PB_Float)
  ADDOptionsBox("ROTATIONSPEED",@GlobalVar\CREATURE_ROTATIONSPEED,#PB_Float)
  ADDOptionsBox("MAXRADIUS",@GlobalVar\CREATURE_MAXRADIUS,#PB_Long)
  ADDOptionsBox("MINRADIUS",@GlobalVar\CREATURE_MINRADIUS,#PB_Long) 
  ADDOptionsBox("MOVE_ENERGY_DECREASE",@GlobalVar\CREATURE_MOVE_ENERGY_DECREASE,#PB_Long) 
  ADDOptionsBox("ROTATION_ENERGY_DECREASE",@GlobalVar\CREATURE_ROTATION_ENERGY_DECREASE,#PB_Long)
  ADDOptionsBox("CLONE_ENERGY_DECREASE",@GlobalVar\CREATURE_CLONE_ENERGY_DECREASE,#PB_Long) 
  ADDOptionsBox("SEARCH_ENEMY_ENERGY_DECREASE",@GlobalVar\CREATURE_SEARCH_ENEMY_ENERGY_DECREASE,#PB_Long) 
  ADDOptionsBox("ANTIVIRUS_ENERGY_DECREASE",@GlobalVar\CREATURE_ANTIVIRUS_ENERGY_DECREASE,#PB_Long) 
  ADDOptionsBox("REPLACE_ENERGY_DECREASE",@GlobalVar\CREATURE_REPLACE_ENERGY_DECREASE,#PB_Long) 
  ADDOptionsBox("PROTECT_DNA_ENERGY_DECREASE ",@GlobalVar\CREATURE_PROTECT_DNA_ENERGY_DECREASE,#PB_Long)
  ADDOptionsBox("PROTECT_DNA_COUNT ",@GlobalVar\CREATURE_PROTECT_DNA_COUNT,#PB_Long)
  
  
  ADDOptionsBox("RANDOMMOVE",@GlobalVar\CREATURE_RANDOMMOVE,#PB_Float)
  ADDOptionsBox("RANDOMROTATION",@GlobalVar\CREATURE_RANDOMROTATION,#PB_Float)
  ADDOptionsBox("ROUNDENERGYFACTOR1",@GlobalVar\CREATURE_ROUNDENERGYFACTOR1,#PB_Float)
  ADDOptionsBox("ROUNDENERGYFACTOR2",@GlobalVar\CREATURE_ROUNDENERGYFACTOR2,#PB_Float)
  ADDOptionsBox("CREATURE_GROWTH",@GlobalVar\CREATURE_GROWTH,#PB_Float)
  ADDOptionsBox("PROBABLE_CLONE_CHANGECELLNUMBER (0-100%)",@GlobalVar\CREATURE_PROBABLE_CLONE_CHANGECELLNUMBER ,#PB_Long) 
  ADDOptionsBox("PROBABLE_CLONE_COPYDNA (0-100%)",@GlobalVar\CREATURE_PROBABLE_CLONE_COPYDNA ,#PB_Long) 
  ADDOptionsBox("PROBABLE_CLONE_CHANGESIZE (0-100%)",@GlobalVar\CREATURE_PROBABLE_CLONE_CHANGESIZE,#PB_Long)  
  ADDOptionsBox("PROBABLE_CLONE_MIN_CLONE_COUNT (bigger 32)",@GlobalVar\CREATURE_PROBABLE_CLONE_MIN_CLONE_COUNT,#PB_Long)
  
  ADDOptionsBox("CREATURE_CELLBONUS",@GlobalVar\CREATURE_CELLBONUS,#PB_Float)  
  ADDOptionsBox("CREATURE_PROTECTVIRUS_COUNT",@GlobalVar\CREATURE_PROTECTVIRUS_COUNT,#PB_Long)  
  ADDOptionsBox("CREATURE_COMBINECOPY_MINABS",@GlobalVar\CREATURE_COMBINECOPY_MINABS,#PB_Long)
  ADDOptionsBox("CREATURE_METABOLISM_RATE ",@GlobalVar\CREATURE_METABOLISM_RATE,#PB_Long)
  

  
  
  
  AddGadgetItem(#Options_Panel, -1, ReadPreferenceString_(languagefile, "text", "Object"))
  ScrollAreaGadget(#Options_Object_Area, 0, 0, 395, 375, 370, 600, 20) 
  ADDOptionsBoxCount = 0
  ADDOptionsBox("FOOD_DEFAULT_SIZE",@GlobalVar\OBJECT_FOOD_DEFAULT_SIZE,#PB_Long)
  ADDOptionsBox("FOOD_MAXSPEED",@GlobalVar\OBJECT_FOOD_MAXSPEED,#PB_Float)
  ADDOptionsBox("CATCH_RADIUS_FACTOR",@GlobalVar\OBJECT_CATCH_RADIUS_FACTOR,#PB_Float)
  ADDOptionsBox("CATCH_PROPABILITY (0-100%)",@GlobalVar\OBJECT_CATCH_PROPABILITY,#PB_Long) ;  
  ADDOptionsBox("POISON_ENERGY_DECREASE",@GlobalVar\OBJECT_POISON_ENERGY_DECREASE,#PB_Long)
  ADDOptionsBox("POISON_ENERGY_ENEMY_DECREASE",@GlobalVar\OBJECT_POISON_ENERGY_ENEMY_DECREASE ,#PB_Long) 
  ADDOptionsBox("POISON_PARALYSE_PAUSE",@GlobalVar\OBJECT_POISON_PARALYSE_PAUSE ,#PB_Long) 
  
  ADDOptionsBox("POISON_MAXSPEED",@GlobalVar\OBJECT_POISON_MAXSPEED,#PB_Float)
  ADDOptionsBox("POISON_LIFETIME",@GlobalVar\OBJECT_POISON_LIFETIME,#PB_Long)
  ADDOptionsBox("VIRUS_ENERGY_DECREASE",@GlobalVar\OBJECT_VIRUS_ENERGY_DECREASE,#PB_Long) 
  ADDOptionsBox("VIRUS_MAXSPEED",@GlobalVar\OBJECT_VIRUS_MAXSPEED,#PB_Float)
  ADDOptionsBox("VIRUS_LIFETIME",@GlobalVar\OBJECT_VIRUS_LIFETIME,#PB_Long) 
  ADDOptionsBox("VIRUS_PROPABILITY",@GlobalVar\OBJECT_VIRUS_PROPABILITY,#PB_Long) 
  ADDOptionsBox("DNA_ENERGY_DECREASE",@GlobalVar\OBJECT_DNA_ENERGY_DECREASE,#PB_Long) 
  ADDOptionsBox("DNA_BLOCK_ENERGY_DECREASE",@GlobalVar\OBJECT_DNA_BLOCK_ENERGY_DECREASE,#PB_Long) 
  ADDOptionsBox("DNA_MAXSPEED",@GlobalVar\OBJECT_DNA_MAXSPEED,#PB_Float)
  ADDOptionsBox("DNA_LIFETIME",@GlobalVar\OBJECT_DNA_LIFETIME,#PB_Long) 
  ADDOptionsBox("MSG_ENERGY_DECREASE",@GlobalVar\OBJECT_MSG_ENERGY_DECREASE,#PB_Long) 
  ADDOptionsBox("MSG_MAXSPEED",@GlobalVar\OBJECT_MSG_MAXSPEED,#PB_Float)
  ADDOptionsBox("MSG_LIFETIME",@GlobalVar\OBJECT_MSG_LIFETIME,#PB_Long) 
  ADDOptionsBox("REST_MAXLIFETIME",@GlobalVar\OBJECT_REST_MAXLIFETIME,#PB_Long) 
  
  
  AddGadgetItem(#Options_Panel, -1, ReadPreferenceString_(languagefile, "text", "Mutation"))
  ScrollAreaGadget(#Options_Mutation_Area, 0, 0, 395, 375, 370, 500, 20) 
  ADDOptionsBoxCount = 0  
  ADDOptionsBox("PROBABILITY (0-10000)",@GlobalVar\MUTATION_PROBABILITY,#PB_Long) ; 
  ADDOptionsBox("PROBABILITY_CHAOS (0-100%)",@GlobalVar\MUTATION_PROBABILITY_CHAOS,#PB_Long) ; 
  ADDOptionsBox("PROBABILITY_RADIUS (0-100%)",@GlobalVar\MUTATION_PROBABILITY_RADIUS,#PB_Long)  ;
  ADDOptionsBox("RADIUS_CHANGE",@GlobalVar\MUTATION_RADIUS_CHANGE,#PB_Long)  
  
  
  AddGadgetItem(#Options_Panel, -1, ReadPreferenceString_(languagefile, "text", "CodeProbability"))
  ScrollAreaGadget(#Options_CodeProbability_Area, 0, 0, 395, 375, 370, 4000, 20)   
  ADDOptionsBoxCount_Pr = 0
  ADDOptionsBoxMaxCount_Pr = 0
  ADDOptionsBox_probability()
  
EndProcedure
Procedure OpenSplashscreen()
  CompilerIf #PB_Compiler_OS = #PB_OS_Linux
    OpenWindow(#Window_Splashscreen,0,0,390,250,"Living Code",#PB_Window_BorderLess|#PB_Window_ScreenCentered,WindowID(#Window_Main))
  CompilerElse
    OpenWindow(#Window_Splashscreen,0,0,390,250,"Living Code",#PB_Window_BorderLess|#PB_Window_WindowCentered,WindowID(#Window_Main))
  CompilerEndIf
  ;StickyWindow(#Window_Splashscreen, 1)   
  SetActiveWindow(#Window_Splashscreen)
  
  UseGadgetList(WindowID(#Window_Splashscreen))
  
  Splashscreen_Start = ElapsedMilliseconds()
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Linux
    ImageGadget(#Splashscreen_Image,0,0,WindowWidth(#Window_Splashscreen),WindowHeight(#Window_Splashscreen),ImageID(LoadImage(#PB_Any,Datapath+"Logo2.png")))
  CompilerElse
    SetClassLong_(WindowID(#Window_Splashscreen),#GCL_HBRBACKGROUND,CreatePatternBrush_(ImageID(LoadImage(#PB_Any,Datapath+"Logo2.png"))));"Data\Back.bmp")))
    Elliptic.l=CreateRoundRectRgn_(1, 1,WindowWidth(#Window_Splashscreen)-2,WindowHeight(#Window_Splashscreen)-2,30,30)
    SetWindowRgn_(WindowID(#Window_Splashscreen),Elliptic,1)
    SetWindowLong_(WindowID(#Window_Splashscreen),#GWL_EXSTYLE,$00080000)
    SetLayeredWindowAttributes_(WindowID(#Window_Splashscreen),0,200,2) 
  CompilerEndIf
 
EndProcedure
Procedure CreateCreature_Window(CellCount.l)
  ClearCalcLine()
  
  *CreatureW.CREATURE = AllocateMemory(SizeOf(CREATURE))
  
  
  
  
  NoPreview = 1
  GadGet\state\Break_Game = #True
  SetGadgetState(#CheckBox_Break,#True)
  DisableGadget(#CheckBox_Break,#True)
  CompilerIf #PB_Compiler_OS = #PB_OS_Linux
    TB_IMAGE_FORWARD = LoadImage(#PB_Any,Datapath+"Pfeil.png")
    TB_IMAGE_ROTATE = LoadImage(#PB_Any,Datapath+"Rotate.png")
    TB_IMAGE_IF = LoadImage(#PB_Any,Datapath+"if.png")
    TB_IMAGE_ATTACK = LoadImage(#PB_Any,Datapath+"Poison.png")
    TB_IMAGE_CLONE = LoadImage(#PB_Any,Datapath+"zelle.png")
  CompilerElse
    TB_IMAGE_FORWARD = LoadImage(#PB_Any,Datapath+"Pfeil.ico")
    TB_IMAGE_ROTATE = LoadImage(#PB_Any,Datapath+"Rotate.ico")
    TB_IMAGE_IF = LoadImage(#PB_Any,Datapath+"IF.ico")
    TB_IMAGE_ATTACK = LoadImage(#PB_Any,Datapath+"Poison_.ico")
    TB_IMAGE_CLONE = LoadImage(#PB_Any,Datapath+"zelle.ico")
  CompilerEndIf
  
  ;OpenWindow(#Window_CreateCreature, 0, 0, 400, 420, "Living Code", #PB_Window_SystemMenu|#PB_Window_ScreenCentered,WindowID(#Window_Main))
  OpenWindow(#Window_CreateCreature, 0, 0, 400, 420, "Living Code", #PB_Window_MaximizeGadget|#PB_Window_SizeGadget|#PB_Window_SystemMenu|#PB_Window_ScreenCentered,WindowID(#Window_Main))
  WindowBounds(#Window_CreateCreature,420,460,#PB_Ignore,#PB_Ignore)
  CreateToolBar(1, WindowID(#Window_CreateCreature))
  ToolBarImageButton(#ToolBar_Move, ImageID(TB_IMAGE_FORWARD))
  ToolBarToolTip(1,#ToolBar_Move,ReadPreferenceString_(languagefile, "text", "Move"))
  ToolBarImageButton(#ToolBar_Rotate, ImageID(TB_IMAGE_ROTATE))
  ToolBarToolTip(1,#ToolBar_Rotate,ReadPreferenceString_(languagefile, "text", "Rotate"))
  ToolBarImageButton(#ToolBar_Attack, ImageID(TB_IMAGE_ATTACK))
  ToolBarToolTip(1,#ToolBar_Attack,ReadPreferenceString_(languagefile, "text", "Attack"))
  ToolBarImageButton(#ToolBar_Clone, ImageID(TB_IMAGE_CLONE))
  ToolBarToolTip(1,#ToolBar_Clone,ReadPreferenceString_(languagefile, "text", "Clone"))
  ToolBarImageButton(#ToolBar_IF, ImageID(TB_IMAGE_IF))
  ToolBarToolTip(1,#ToolBar_IF,ReadPreferenceString_(languagefile, "text", "IF"))
  DisableToolBar(#True)
  
  UseGadgetList(WindowID(#Window_CreateCreature))
  CompilerIf #PB_Compiler_OS = #PB_OS_Linux
    ButtonGadget(#CreateCreature_Load,5,370,70,20,ReadPreferenceString_(languagefile, "text", "Load"))
    ButtonGadget(#CreateCreature_Save,80,370,70,20,ReadPreferenceString_(languagefile, "text", "Save"))
    ButtonGadget(#CreateCreature_Cancel,220,370,70,20,ReadPreferenceString_(languagefile, "text", "Cancel"))
    ButtonGadget(#CreateCreature_Compile,300,370,40,20,ReadPreferenceString_(languagefile, "text", "New"))
    ButtonGadget(#CreateCreature_Change,345,370,50,20,ReadPreferenceString_(languagefile, "text", "Change"))
    PanelGadget(#CreateCreature_Tab,5,0,390,365)
  CompilerElse
    ButtonGadget(#CreateCreature_Load,5,395,70,20,ReadPreferenceString_(languagefile, "text", "Load"))
    ButtonGadget(#CreateCreature_Save,80,395,70,20,ReadPreferenceString_(languagefile, "text", "Save"))
    ButtonGadget(#CreateCreature_Cancel,220,395,70,20,ReadPreferenceString_(languagefile, "text", "Cancel"))
    ButtonGadget(#CreateCreature_Compile,300,395,40,20,ReadPreferenceString_(languagefile, "text", "New"))
    ButtonGadget(#CreateCreature_Change,345,395,50,20,ReadPreferenceString_(languagefile, "text", "Change"))
    PanelGadget(#CreateCreature_Tab,5,25,390,365)
  CompilerEndIf
  
  DisableGadget(#CreateCreature_Compile,#True)
  DisableGadget(#CreateCreature_Change,#True)
  
  
  AddGadgetItem(#CreateCreature_Tab,-1,ReadPreferenceString_(languagefile, "text", "Settings"))
  ContainerGadget(#CreateCreature_Setting_Container,0,0,385,340, #PB_Container_Raised)
  
  TextGadget(#CreateCreature_EnergyText,5,5,100,20,ReadPreferenceString_(languagefile, "text", "Energy")+":")
  StringGadget(#CreateCreature_EnergyStr,5,25,100,20,"8000",#PB_String_Numeric)   
  
  TextGadget(#CreateCreature_CellsText,5,60,100,20,ReadPreferenceString_(languagefile, "text", "Num-Cells")+":")
  StringGadget(#CreateCreature_CellsStr,5,80,100,20,Str(CellCount),#PB_String_Numeric|#PB_String_ReadOnly)  
  
  

  TextGadget(#CreateCreature_XText,5,115,100,20,"X:")
  StringGadget(#CreateCreature_XStr,5,135,100,20,"320",#PB_String_Numeric)  
  
  TextGadget(#CreateCreature_YText,5,170,100,20,"Y:")
  StringGadget(#CreateCreature_YStr,5,190,100,20,"240",#PB_String_Numeric)  
  
  TextGadget(#CreateCreature_ColorText,5,225,100,20,ReadPreferenceString_(languagefile, "text", "Color")+":")
  TextGadget(#CreateCreature_ColorShow,5,245,40,20,"",#PB_Text_Border)  
  SetGadgetColor(#CreateCreature_ColorShow,#PB_Gadget_BackColor,RGB(Random(255),Random(255),Random(255)))
  ButtonGadget(#CreateCreature_ColorEdit,50,245,40,20,"...")
  
  TextGadget(#CreateCreature_CreatureIDText,5,280,100,20,ReadPreferenceString_(languagefile, "text", "Creature")+" ID:")
  StringGadget(#CreateCreature_CreatureIDStr,5,300,100,20,Str(Random($FFFFFF)),#PB_String_Numeric)  
  
  TextGadget(#CreateCreature_IncCreatureIDText,150,280,130,20,ReadPreferenceString_(languagefile, "text", "Creature-generation")+" ID:")
  StringGadget(#CreateCreature_IncCreatureIDStr,150,300,100,20,Str(Random($FFFFFF)),#PB_String_Numeric)  
  
  
  TextGadget(#CreateCreature_CreatureName,150,5,100,20,ReadPreferenceString_(languagefile, "text", "Creature")+" "+ReadPreferenceString_(languagefile, "text", "Name")+":")
  StringGadget(#CreateCreature_CreatureNameStr,150,25,220,20,ReadPreferenceString_(languagefile, "text", "NoName"))
  
  TextGadget(#CreateCreature_CreatureAuthor,150,60,100,20,ReadPreferenceString_(languagefile, "text", "Creature") + " " + ReadPreferenceString_(languagefile, "text", "Author")+":")
  StringGadget(#CreateCreature_CreatureAuthorStr,150,80,220,20,ReadPreferenceString_(languagefile, "text", "NoName")) 
  CompilerIf #PB_Compiler_OS = #PB_OS_Linux
  CompilerElse
    SetGadgetText(#CreateCreature_CreatureAuthorStr,GetUserName())
  CompilerEndIf
  
  TextGadget(#CreateCreature_CreatureDescription,150,115,100,20,ReadPreferenceString_(languagefile, "text", "Description")+":")
  ;StringGadget(#CreateCreature_CreatureDescriptionStr,150,135,100,20,"")    
  EditorGadget(#CreateCreature_CreatureDescriptionStr,150,135,220,75)  
  
  CheckBoxGadget(#CreateCreature_CheckMutation,150,220,150,20,ReadPreferenceString_(languagefile, "text", "Disable-Mutation"))
  
  
  ButtonGadget(#CreateCreature_Info,320,220,50,20,ReadPreferenceString_(languagefile, "text", "Info"))
  
  
  ButtonGadget(#CreateCreature_Upload,300,300,70,20,ReadPreferenceString_(languagefile, "text", "Upload"))
  
  OptionGadget(#CreateCreature_Male,150,240,70,20,ReadPreferenceString_(languagefile, "text", "Male"))
  OptionGadget(#CreateCreature_FeMale,150,260,70,20,ReadPreferenceString_(languagefile, "text", "Female"))
  
  SetGadgetState(#CreateCreature_Male,#True)
  
  
  
  CloseGadgetList()
  CreatureCellCount = CellCount
  For cell = 0 To CellCount-1
    AddGadgetItem(#CreateCreature_Tab,-1,ReadPreferenceString_(languagefile, "text", "Cell")+" "+Str(cell))
    
    GadGet\Creature[cell]\CodeText=TextGadget(#PB_Any,5,5,100,20,ReadPreferenceString_(languagefile, "text", "Code")+":")
    ;GadGet\Creature[cell]\CodeEditor=EditorGadget(#PB_Any,5,25,270,310)
    ;GadGet\Creature[Cell]\CodeEditor=StringGadget(#PB_Any,5,25,270,310,"",4)
    GadGet\Creature[cell]\CodeEditor=ScintillaGadget(#PB_Any,5,25,270,310, @ScintillaCallBack())
    SetSciColor(GadGet\Creature[cell]\CodeEditor)
    
    GadGet\Creature[cell]\CodeLine=StringGadget(#PB_Any,314,0,70,18,ReadPreferenceString_(languagefile, "text", "Line")+": 0",#PB_String_ReadOnly)
    
    
    GadGet\Creature[cell]\CellIDText=TextGadget(#PB_Any,280,25,100,20,ReadPreferenceString_(languagefile, "text", "Cell")+" ID:")
    GadGet\Creature[cell]\CellIDStr=StringGadget(#PB_Any,280,40,100,20,Str(Random($FFFFFF)),#PB_String_Numeric)
    
    GadGet\Creature[cell]\CellRandiusText=TextGadget(#PB_Any,280,80,100,20,ReadPreferenceString_(languagefile, "text", "Cell-Radius")+":")
    GadGet\Creature[cell]\CellRandiusStr=StringGadget(#PB_Any,280,95,100,20,"8",#PB_String_Numeric)   
    
    GadGet\Creature[cell]\CellOrgRandiusText=TextGadget(#PB_Any,280,125,100,20,ReadPreferenceString_(languagefile, "text", "Org-Cell-Radius")+":")
    GadGet\Creature[cell]\CellOrgRandiusStr=StringGadget(#PB_Any,280,140,100,20,"10",#PB_String_Numeric)   
    
    GadGet\Creature[cell]\CellCodePositionText=TextGadget(#PB_Any,280,180,100,20,ReadPreferenceString_(languagefile, "text", "Cell-Code-Position")+":")
    GadGet\Creature[cell]\CellCodePositionStr=StringGadget(#PB_Any,280,195,100,20,"0",#PB_String_Numeric)   
    
    GadGet\Creature[cell]\ExportCode=ButtonGadget(#PB_Any,280,290,100,20,ReadPreferenceString_(languagefile, "text", "Export-Code")) 
    GadGet\Creature[cell]\ImportCode=ButtonGadget(#PB_Any,280,315,100,20,ReadPreferenceString_(languagefile, "text", "Import-Code"))   
    
    CompilerIf #PB_Compiler_OS = #PB_OS_Linux
      GadGet\Creature[cell]\SetCode=ButtonGadget(#PB_Any,280,245,100,40,ReadPreferenceString_(languagefile, "text", "Set-this-Code-for-all-Cells"),#PB_Button_MultiLine)   
    CompilerElse
      GadGet\Creature[cell]\SetCode=ButtonGadget(#PB_Any,280,255,100,30,ReadPreferenceString_(languagefile, "text", "Set-this-Code-for-all-Cells"),#PB_Button_MultiLine)   
    CompilerEndIf
  Next      
  
  For cell=0 To 31
    TempCreature\Cells[cell]\DoEating = #True
  Next
  
  If CellCount>0
    AddGadgetItem(#CreateCreature_Tab,-1,ReadPreferenceString_(languagefile, "text", "Preview"))
    CreateCreature_Preview_Image = CreateImage(#PB_Any, 105,105)
    ImageGadget(#CreateCreature_Preview_Image, 5,100,105,105,ImageID(CreateCreature_Preview_Image))
    TextGadget(#CreateCreature_Preview_Scale_Text,5,5,100,20,ReadPreferenceString_(languagefile, "text", "Scale-Creature")+":")
    StringGadget(#CreateCreature_Preview_Scale_Str,5,25,100,20,"1")
    ButtonGadget(#CreateCreature_Preview_Scale_Button,5,50,50,20,ReadPreferenceString_(languagefile, "text", "Scale"))
    ButtonGadget(#CreateCreature_Preview_OrgRadius_Button,60,50,80,20,ReadPreferenceString_(languagefile, "text", "Set-Org-Radius"))
    ButtonGadget(#CreateCreature_Preview_RndRadius_Button,60,75,80,20,ReadPreferenceString_(languagefile, "text", "Set-Rnd-Radius"))
    
    
    TextGadget(#CreateCreature_Preview_Preview_Text,5,80,55,20,ReadPreferenceString_(languagefile, "text", "Actual")+":")
    TextGadget(#CreateCreature_Preview_Preview_Text_2,5,210,100,20,ReadPreferenceString_(languagefile, "text", "Orginal")+":")
    
    CreateCreature_Preview_Image_2 = CreateImage(#PB_Any, 105,105)
    ImageGadget(#CreateCreature_Preview_Image_2, 5,230,105,105,ImageID(CreateCreature_Preview_Image_2))
    
    
    ScrollAreaGadget(#CreateCreature_Preview_Area,150,5,230,330,180,3200,50)
    For cell = 0 To CellCount-1
      CC_Preview(cell)\cell=TextGadget(#PB_Any,10,5+cell*100,100,20,ReadPreferenceString_(languagefile, "text", "Cell")+" "+Str(cell)+":")
      SetGadgetColor(CC_Preview(cell)\cell,#PB_Gadget_FrontColor,RGB(0,0,128))
      
      CompilerIf #PB_Compiler_OS = #PB_OS_Linux
      CompilerElse
        SetGadgetFont(CC_Preview(cell)\cell,FontID(0))
      CompilerEndIf
      
      CC_Preview(cell)\Radius=TextGadget(#PB_Any,25,25+cell*100,100,20,ReadPreferenceString_(languagefile, "text", "Radius")+":")
      CC_Preview(cell)\Radius_Str=StringGadget(#PB_Any,25,40+cell*100,100,20,"1",#PB_String_Numeric)
      
      CC_Preview(cell)\OrgRadius=TextGadget(#PB_Any,25,60+cell*100,100,20,ReadPreferenceString_(languagefile, "text", "Org-Radius")+":")
      CC_Preview(cell)\OrgRadius_Str=StringGadget(#PB_Any,25,75+cell*100,100,20,"1",#PB_String_Numeric)
      
      
    Next
    SetPreview(0)
  EndIf
  
  If CreatePopupMenu(2)     
    MenuItem(#Menu_Cut,ReadPreferenceString_(languagefile, "text",  "Cut"))
    MenuItem(#Menu_Copy, ReadPreferenceString_(languagefile, "text", "Copy"))      
    MenuItem(#Menu_Paste, ReadPreferenceString_(languagefile, "text", "Paste"))
    MenuBar()
    MenuItem(#Menu_SelectAll, ReadPreferenceString_(languagefile, "text", "Select-All"))
    MenuBar()
    MenuItem(#Menu_Undo, ReadPreferenceString_(languagefile, "text", "Undo"))
    MenuItem(#Menu_Redo, ReadPreferenceString_(languagefile, "text", "Redo"))
    MenuBar()
    OpenSubMenu(ReadPreferenceString_(languagefile, "text", "Insert"))
    
    
    Count=#ToolBar_Rotate+1
    
    
    OpenSubMenu(ReadPreferenceString_(languagefile, "text", "Move"))
      MenuItem(Count,CodeToCMDString(#CMD_MOVE_FORWARD)+""):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_MOVE_FORWARD2X)+""):Count+1
      MenuBar()
      MenuItem(Count,CodeToCMDString(#CMD_MOVE_BACKWARD)+""):Count+1
    CloseSubMenu()
    
    
    OpenSubMenu(ReadPreferenceString_(languagefile, "text", "Eating"))
      MenuItem(Count,CodeToCMDString(#CMD_EATING_YES)+""):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_EATING_NO)+""):Count+1
      MenuBar()
      MenuItem(Count,CodeToCMDString(#CMD_EATING_EMIT)+""):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_EMITTOENEMY_FOOD)+""):Count+1
    CloseSubMenu()
    
    
    OpenSubMenu(ReadPreferenceString_(languagefile, "text", "Attack"))
      MenuItem(Count,CodeToCMDString(#CMD_POISON_EMIT)+" 500"):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_EMITTOENEMY_POISON)+" 500"):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_POISON_IMMUN1)+" 500"):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_POISON_IMMUN2)+" 600"):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_POISON_IMMUN3)+" 700"):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_POISON_YES)+""):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_POISON_NO)+""):Count+1
      MenuBar() 
      MenuItem(Count,CodeToCMDString(#CMD_POISON_VIRUS_MIN_ENERGY)+" 1000"):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_POISON_EMIT_VIRUS)+" 0"):Count+1
      MenuBar() 
      MenuItem(Count,CodeToCMDString(#CMD_POISON_DNA_CODE)+" 4"):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_POISON_EMIT_DNA)+" 0"):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_EMITTOENEMY_DNA)+" 0"):Count+1    
      MenuItem(Count,CodeToCMDString(#CMD_POISON_EMIT_DNABLOCK)+" @Test"):Count+1 
      MenuItem(Count,CodeToCMDString(#CMD_EMITTOENEMY_DNABLOCK)+" @Test"):Count+1      
      MenuItem(Count,CodeToCMDString(#CMD_POISON_DNABLOCK_SIZE)+" 5"):Count+1
      MenuBar() 
      MenuItem(Count,CodeToCMDString(#CMD_MSG_EMIT)+" 500"):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_EMITTOENEMY_MSG)+" 500"):Count+1
      MenuBar() 
      MenuItem(Count,CodeToCMDString(#CMD_ABSORBABLE_YES)+""):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_ABSORBABLE_NO)+""):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_ABSORB_ENEMY)+""):Count+1
      MenuBar()
      MenuItem(Count,CodeToCMDString(#CMD_SEARCH_NEAREST_ENEMY)+""):Count+1
    CloseSubMenu()
    
    
    OpenSubMenu(ReadPreferenceString_(languagefile, "text", "Rotate"))
      MenuItem(Count,CodeToCMDString(#CMD_ROTATE_LEFT)+""):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_ROTATE_RIGHT)+""):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_ROTATE_MSG)+""):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_ROTATE_DNA)+""):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_ROTATE_POISON)+""):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_ROTATE_FOOD)+""):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_ROTATE_ENEMY)+""):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_ROTATE_DEST_POINT)+""):Count+1
      MenuBar() 
      MenuItem(Count,CodeToCMDString(#CMD_ROTATE_ANTI_MSG)+""):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_ROTATE_ANTI_DNA)+""):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_ROTATE_ANTI_POISON)+""):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_ROTATE_ANTI_FOOD)+""):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_ROTATE_ANTI_ENEMY)+""):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_ROTATE_ANTI_DEST_POINT)+""):Count+1
    CloseSubMenu()
    
    
    OpenSubMenu("If")
    
      OpenSubMenu(ReadPreferenceString_(languagefile, "text", "ENERGY"))
        MenuItem(Count,CodeToCMDString(#CMD_IF_ENERGY_GREATER)+" 5000"):Count+1
        MenuItem(Count,CodeToCMDString(#CMD_IF_ENERGY_LESS)+" 5000"):Count+1
        MenuItem(Count,CodeToCMDString(#CMD_IF_ENERGY_EQUAL)+" 5000"):Count+1
        MenuItem(Count,CodeToCMDString(#CMD_IF_ENERGYINC_GREATER)+" 5000"):Count+1
        MenuItem(Count,CodeToCMDString(#CMD_IF_ENERGYDEC_GREATER)+" 5000"):Count+1
      CloseSubMenu()
      
      OpenSubMenu(ReadPreferenceString_(languagefile, "text", "MSG"))
        MenuItem(Count,CodeToCMDString(#CMD_IF_MSG_GREATER)+" 5000"):Count+1
        MenuItem(Count,CodeToCMDString(#CMD_IF_MSG_LESS)+" 5000"):Count+1
        MenuItem(Count,CodeToCMDString(#CMD_IF_MSG_EQUAL)+" 5000"):Count+1
      CloseSubMenu()
      
      OpenSubMenu(ReadPreferenceString_(languagefile, "text", "FOOD"))
        MenuItem(Count,CodeToCMDString(#CMD_IF_FOOD_GREATER)+" 5000"):Count+1
        MenuItem(Count,CodeToCMDString(#CMD_IF_FOOD_LESS)+" 5000"):Count+1
        MenuItem(Count,CodeToCMDString(#CMD_IF_FOOD_EQUAL)+" 5000"):Count+1
      CloseSubMenu()
      
      
      OpenSubMenu(ReadPreferenceString_(languagefile, "text", "POISON"))
        MenuItem(Count,CodeToCMDString(#CMD_IF_POISON_GREATER)+" 5000"):Count+1
        MenuItem(Count,CodeToCMDString(#CMD_IF_POISON_LESS)+" 5000"):Count+1
        MenuItem(Count,CodeToCMDString(#CMD_IF_POISON_EQUAL)+" 5000"):Count+1
        MenuItem(Count,CodeToCMDString(#CMD_IF_POISONID_GREATER)+" 5000"):Count+1
        MenuItem(Count,CodeToCMDString(#CMD_IF_POISONID_LESS)+" 5000"):Count+1
        MenuItem(Count,CodeToCMDString(#CMD_IF_POISONID_EQUAL)+" 5000"):Count+1
      CloseSubMenu()
      
      OpenSubMenu(ReadPreferenceString_(languagefile, "text", "DNA"))
        MenuItem(Count,CodeToCMDString(#CMD_IF_DNA_GREATER)+" 5000"):Count+1
        MenuItem(Count,CodeToCMDString(#CMD_IF_DNA_LESS)+" 5000"):Count+1
        MenuItem(Count,CodeToCMDString(#CMD_IF_DNA_EQUAL)+" 5000"):Count+1
      CloseSubMenu()
      
      OpenSubMenu(ReadPreferenceString_(languagefile, "text", "VARIABLE"))
        MenuItem(Count,CodeToCMDString(#CMD_IF_VARIABLE_GREATER)+" 5000"):Count+1
        MenuItem(Count,CodeToCMDString(#CMD_IF_VARIABLE_LESS)+" 5000"):Count+1
        MenuItem(Count,CodeToCMDString(#CMD_IF_VARIABLE_EQUAL)+" 5000"):Count+1
      CloseSubMenu()
      
      OpenSubMenu(ReadPreferenceString_(languagefile, "text", "CELL"))
        MenuItem(Count,CodeToCMDString(#CMD_IF_CELL_RAD_GREATER)+" 5000"):Count+1
        MenuItem(Count,CodeToCMDString(#CMD_IF_CELL_RAD_LESS)+" 5000"):Count+1
        MenuItem(Count,CodeToCMDString(#CMD_IF_CELL_RAD_EQUAL)+" 5000"):Count+1
        MenuItem(Count,CodeToCMDString(#CMD_IF_NUMOFCELLS_GREATER)+" 5000"):Count+1
        MenuItem(Count,CodeToCMDString(#CMD_IF_NUMOFCELLS_LESS)+" 5000"):Count+1
        MenuItem(Count,CodeToCMDString(#CMD_IF_NUMOFCELLS_EQUAL)+" 5000"):Count+1
        MenuItem(Count,CodeToCMDString(#CMD_IF_CELLNUMER_GREATER)+" 5000"):Count+1
        MenuItem(Count,CodeToCMDString(#CMD_IF_CELLNUMER_LESS)+" 5000"):Count+1
        MenuItem(Count,CodeToCMDString(#CMD_IF_CELLNUMER_EQUAL)+" 5000"):Count+1
      CloseSubMenu()
      
      OpenSubMenu("XY")
        MenuItem(Count,CodeToCMDString(#CMD_IF_X_GREATER)+" 200"):Count+1
        MenuItem(Count,CodeToCMDString(#CMD_IF_X_LESS)+" 200"):Count+1
        MenuItem(Count,CodeToCMDString(#CMD_IF_X_EQUAL)+" 200"):Count+1
        MenuItem(Count,CodeToCMDString(#CMD_IF_Y_GREATER)+" 200"):Count+1
        MenuItem(Count,CodeToCMDString(#CMD_IF_Y_LESS)+" 200"):Count+1
        MenuItem(Count,CodeToCMDString(#CMD_IF_Y_EQUAL)+" 200"):Count+1
      CloseSubMenu()
      
      OpenSubMenu(ReadPreferenceString_(languagefile, "text", "ENEMY"))
        MenuItem(Count,CodeToCMDString(#CMD_IF_ENEMYABS_GREATER)+" 5000"):Count+1
        MenuItem(Count,CodeToCMDString(#CMD_IF_ENEMYABS_LESS)+" 5000"):Count+1
        MenuItem(Count,CodeToCMDString(#CMD_IF_ENEMYABS_EQUAL)+" 5000"):Count+1
        MenuItem(Count,CodeToCMDString(#CMD_IF_CMP_ENEMY_GREATER)+" 5000"):Count+1
        MenuItem(Count,CodeToCMDString(#CMD_IF_CMP_ENEMY_LESS)+" 5000"):Count+1
        MenuItem(Count,CodeToCMDString(#CMD_IF_CMP_ENEMY_EQUAL)+" 5000"):Count+1
      CloseSubMenu()
      
      OpenSubMenu(ReadPreferenceString_(languagefile, "text", "GENERATION"))
        MenuItem(Count,CodeToCMDString(#CMD_IF_GENERATION_GREATER)+" 5000"):Count+1
        MenuItem(Count,CodeToCMDString(#CMD_IF_GENERATION_LESS)+" 5000"):Count+1
        MenuItem(Count,CodeToCMDString(#CMD_IF_GENERATION_EQUAL)+" 5000"):Count+1
      CloseSubMenu()
  
      OpenSubMenu(ReadPreferenceString_(languagefile, "text", "MALE-FEMALE"))
        MenuItem(Count,CodeToCMDString(#CMD_IF_MALE)+""):Count+1
        MenuItem(Count,CodeToCMDString(#CMD_IF_FEMALE)+""):Count+1
      CloseSubMenu()
      
      OpenSubMenu(ReadPreferenceString_(languagefile, "text", "AGE"))
        MenuItem(Count,CodeToCMDString(#CMD_IF_AGE_GREATER)+" 5000"):Count+1
        MenuItem(Count,CodeToCMDString(#CMD_IF_AGE_LESS)+" 5000"):Count+1
        MenuItem(Count,CodeToCMDString(#CMD_IF_AGE_EQUAL)+" 5000"):Count+1
      CloseSubMenu()
      
      OpenSubMenu(ReadPreferenceString_(languagefile, "text", "ABSORB"))
        MenuItem(Count,CodeToCMDString(#CMD_IF_ABSORBABLE)+""):Count+1
      CloseSubMenu()
      
      MenuItem(Count,CodeToCMDString(#CMD_ENDIF)+""):Count+1
    CloseSubMenu()
    
    
    OpenSubMenu(ReadPreferenceString_(languagefile, "text", "Clone"))
      MenuItem(Count,CodeToCMDString(#CMD_COPY_MIN_ENERGY)+" 10000"):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_CLONE)+""):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_COPY50_50)+""):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_COPY25_75)+""):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_COPY5_95)+""):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_COMBINECOPY)+""):Count+1
    CloseSubMenu()
    
    OpenSubMenu(ReadPreferenceString_(languagefile, "text", "Goto"))
      MenuItem(Count,CodeToCMDString(#CMD_RETURN)+""):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_GOTO)+" @Test"):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_GOTO50)+" @Test"):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_GOTO25)+" @Test"):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_GOTO5)+" @Test"):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_RNDGOTO)+""):Count+1
      MenuBar()
      MenuItem(Count,CodeToCMDString(#CMD_TIMER_SET)+" 500"):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_TIMER_GOTO)+" @Test"):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_TIMER_YES)+""):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_TIMER_NO)+""):Count+1
    CloseSubMenu()
    
    OpenSubMenu(ReadPreferenceString_(languagefile, "text", "Variable"))
      MenuItem(Count,CodeToCMDString(#CMD_VARIABLE)+" @Test"):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_VARIABLE_ZERO)+""):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_VARIABLE_DEC)+""):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_VARIABLE_INC)+""):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_VARIABLE_SET)+" 10"):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_VARIABLE_ADD)+" 5"):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_VARIABLE_SUB)+" 5"):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_VARIABLE_MUL)+" 5"):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_VARIABLE_DIV)+" 5"):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_VARIABLE_XOR)+" 5"):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_VARIABLE_OR)+" 5"):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_VARIABLE_AND)+" 5"):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_VARIABLE_MOD)+" 5"):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_VARIABLE_COPY)+" @Test"):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_VARIABLE_RND)+""):Count+1
      MenuBar() 
      MenuItem(Count,CodeToCMDString(#CMD_VARIABLE_GETGLOBAL)+""):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_VARIABLE_SETGLOBAL)+""):Count+1
    CloseSubMenu()
    
    
    OpenSubMenu(ReadPreferenceString_(languagefile, "text", "Other"))
      MenuItem(Count,CodeToCMDString(#CMD_INC_CELL_RAD)+""):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_DEC_CELL_RAD)+""):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_SIN_CELL_RAD)+" 20"):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_SIN_CELL_AMPRAD)+" 20"):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_SIN_CELL_MIDRAD)+" 30"):Count+1 
      MenuBar() 
      MenuItem(Count,CodeToCMDString(#CMD_DEST_POINT_X)+" 320"):Count+1  
      MenuItem(Count,CodeToCMDString(#CMD_DEST_POINT_Y)+" 240"):Count+1  
      MenuBar() 
      MenuItem(Count,CodeToCMDString(#CMD_PAUSE)+""):Count+1  
      MenuItem(Count,CodeToCMDString(#CMD_NOP)+""):Count+1
      MenuBar() 
      MenuItem(Count,CodeToCMDString(#CMD_ANTIVIRUS)+""):Count+1  
      MenuItem(Count,CodeToCMDString(#CMD_PROTECTVIRUS)+""):Count+1  
      MenuItem(Count,CodeToCMDString(#CMD_PROTECTDNA)+""):Count+1 
      MenuItem(Count,CodeToCMDString(#CMD_BLOCKEXEC)+" @Line_0"):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_REPLACEMENT_CMD)+" 4"):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_REPLACE_CMD )+" 4"):Count+1      
      MenuItem(Count,CodeToCMDString(#CMD_MUTATE)+""):Count+1
      MenuItem(Count,CodeToCMDString(#CMD_MUTATE_LINE)+" @Line_0"):Count+1
    CloseSubMenu()
    

  

    
    CloseSubMenu()
  EndIf
  
  
  
  
  DisableGadget(#CreateCreature_Compile,#False)
EndProcedure
Procedure OpenCCMoveWindow()
  OpenWindow(#Window_CC_Move,0,0,180,110,"Living Code - MOVE",#PB_Window_SystemMenu|#PB_Window_WindowCentered,WindowID(#Window_CreateCreature))
  UseGadgetList(WindowID(#Window_CC_Move))
  
  OptionGadget(#CC_MOVE_FORWARD,5,5,150,20,"MOVE_FORWARD")
  OptionGadget(#CC_MOVE_FORWARD2X,5,30,150,20,"MOVE_FORWARD2X")
  SetGadgetState(#CC_MOVE_FORWARD, #True)
  OptionGadget(#CC_MOVE_BACKWARD,5,55,150,20,"MOVE_BACKWARD")
  
  ButtonGadget(#CC_MOVE_CANCEL,5,85,70,20,ReadPreferenceString_(languagefile, "text", "Cancel"))
  ButtonGadget(#CC_MOVE_INSERT,105,85,70,20,ReadPreferenceString_(languagefile, "text", "Insert"))
  
EndProcedure
Procedure OpenCCRotateWindow()
  OpenWindow(#Window_CC_Rotate,0,0,180,310,"Living Code - ROTATE",#PB_Window_SystemMenu|#PB_Window_WindowCentered,WindowID(#Window_CreateCreature))
  UseGadgetList(WindowID(#Window_CC_Rotate))
  
  OptionGadget(#CC_ROTATE_LEFT,5,5,150,20,"ROTATE_LEFT")
  OptionGadget(#CC_ROTATE_RIGHT,5,25,150,20,"ROTATE_RIGHT")
  OptionGadget(#CC_ROTATE_MSG        ,5,45,150,20,"ROTATE_MSG")
  OptionGadget(#CC_ROTATE_POISON     ,5,65,150,20,"ROTATE_POISON")
  OptionGadget(#CC_ROTATE_DNA        ,5,85,150,20,"ROTATE_DNA")
  OptionGadget(#CC_ROTATE_FOOD       ,5,105,150,20,"ROTATE_FOOD")
  OptionGadget(#CC_ROTATE_ANTI_MSG   ,5,125,150,20,"ROTATE_ANTI_MSG")
  OptionGadget(#CC_ROTATE_ANTI_DNA   ,5,145,150,20,"ROTATE_ANTI_DNA")
  OptionGadget(#CC_ROTATE_ANTI_POISON,5,165,150,20,"ROTATE_ANTI_POISON")
  OptionGadget(#CC_ROTATE_ANTI_FOOD  ,5,185,185,20,"ROTATE_ANTI_FOOD")
  OptionGadget(#CC_ROTATE_ENEMY      ,5,205,150,20,"ROTATE_ENEMY")
  OptionGadget(#CC_ROTATE_ANTI_ENEMY ,5,225,185,20,"ROTATE_ANTI_ENEMY")
  OptionGadget(#CC_ROTATE_DEST_POINT ,5,245,150,20,"ROTATE_DEST_POINT")
  OptionGadget(#CC_ROTATE_ANTI_DEST_POINT,5,265,185,20,"ROTATE_ANTI_DEST_POINT")
  
  
  SetGadgetState(#CC_ROTATE_FOOD, #True)
  
  
  ButtonGadget(#CC_ROTATE_CANCEL,5,285,70,20,ReadPreferenceString_(languagefile, "text", "Cancel"))
  ButtonGadget(#CC_ROTATE_INSERT,105,285,70,20,ReadPreferenceString_(languagefile, "text", "Insert"))
  
  
  
EndProcedure
Procedure OpenCCIFWindow()
  OpenWindow(#Window_CC_IF,0,0,280,400,"Living Code - IF",#PB_Window_SystemMenu|#PB_Window_WindowCentered,WindowID(#Window_CreateCreature))
  UseGadgetList(WindowID(#Window_CC_IF))
  Count=0
  
  ButtonGadget(#CC_IF_CANCEL,5,375,70,20,ReadPreferenceString_(languagefile, "text", "Cancel"))
  ButtonGadget(#CC_IF_INSERT,175,375,70,20,ReadPreferenceString_(languagefile, "text", "Insert"))
  
  ScrollAreaGadget(#CC_IF_AreaGadget,0,0,280,370,255,1100,50)
  
  CheckBoxGadget(#CC_IF_ENERGY_GREATER,5,5+Count*18,170,18,"IF_ENERGY_GREATER"):Count+1
  CheckBoxGadget(#CC_IF_ENERGY_LESS,5,5+Count*18,170,18,"IF_ENERGY_LESS"):Count+1
  CheckBoxGadget(#CC_IF_ENERGY_EQUAL,5,5+Count*18,170,18,"IF_ENERGY_EQUAL"):Count+1
  CheckBoxGadget(#CC_IF_ENERGYINC_GREATER,5,5+Count*18,170,18,"IF_ENERGYINC_GREATER"):Count+1
  CheckBoxGadget(#CC_IF_ENERGYDEC_GREATER,5,5+Count*18,170,18,"IF_ENERGYDEC_GREATER"):Count+1
  CheckBoxGadget(#CC_IF_MSG_GREATER,5,5+Count*18,170,18,"IF_MSG_GREATER"):Count+1
  CheckBoxGadget(#CC_IF_MSG_LESS,5,5+Count*18,170,18,"IF_MSG_LESS"):Count+1
  CheckBoxGadget(#CC_IF_MSG_EQUAL,5,5+Count*18,170,18,"IF_MSG_EQUAL"):Count+1
  CheckBoxGadget(#CC_IF_FOOD_GREATER,5,5+Count*18,170,18,"IF_FOOD_GREATER"):Count+1
  CheckBoxGadget(#CC_IF_FOOD_LESS,5,5+Count*18,170,18,"IF_FOOD_LESS"):Count+1
  CheckBoxGadget(#CC_IF_FOOD_EQUAL,5,5+Count*18,170,18,"IF_FOOD_EQUAL"):Count+1
  CheckBoxGadget(#CC_IF_POISON_GREATER,5,5+Count*18,170,18,"IF_POISON_GREATER"):Count+1
  CheckBoxGadget(#CC_IF_POISON_LESS,5,5+Count*18,170,18,"IF_POISON_LESS"):Count+1
  CheckBoxGadget(#CC_IF_POISON_EQUAL,5,5+Count*18,170,18,"IF_POISON_EQUAL"):Count+1
  CheckBoxGadget(#CC_IF_POISONID_GREATER,5,5+Count*18,170,18,"IF_POISONID_GREATER"):Count+1
  CheckBoxGadget(#CC_IF_POISONID_LESS,5,5+Count*18,170,18,"IF_POISONID_LESS"):Count+1
  CheckBoxGadget(#CC_IF_POISONID_EQUAL,5,5+Count*18,170,18,"IF_POISONID_EQUAL"):Count+1
  CheckBoxGadget(#CC_IF_DNA_GREATER,5,5+Count*18,170,18,"IF_DNA_GREATER"):Count+1
  CheckBoxGadget(#CC_IF_DNA_LESS,5,5+Count*18,170,18,"IF_DNA_LESS"):Count+1
  CheckBoxGadget(#CC_IF_DNA_EQUAL,5,5+Count*18,170,18,"IF_DNA_EQUAL"):Count+1
  CheckBoxGadget(#CC_IF_VARIABLE_GREATER,5,5+Count*18,170,18,"IF_VARIABLE_GREATER"):Count+1
  CheckBoxGadget(#CC_IF_VARIABLE_LESS,5,5+Count*18,170,18,"IF_VARIABLE_LESS"):Count+1
  CheckBoxGadget(#CC_IF_VARIABLE_EQUAL,5,5+Count*18,170,18,"IF_VARIABLE_EQUAL"):Count+1
  CheckBoxGadget(#CC_IF_CELL_RAD_GREATER,5,5+Count*18,170,18,"IF_CELL_RAD_GREATER"):Count+1
  CheckBoxGadget(#CC_IF_CELL_RAD_LESS,5,5+Count*18,170,18,"IF_CELL_RAD_LESS"):Count+1
  CheckBoxGadget(#CC_IF_CELL_RAD_EQUAL,5,5+Count*18,170,18,"IF_CELL_RAD_EQUAL"):Count+1
  CheckBoxGadget(#CC_IF_X_GREATER,5,5+Count*18,170,18,"IF_X_GREATER"):Count+1
  CheckBoxGadget(#CC_IF_X_LESS,5,5+Count*18,170,18,"IF_X_LESS"):Count+1
  CheckBoxGadget(#CC_IF_X_EQUAL,5,5+Count*18,170,18,"IF_X_EQUAL"):Count+1
  CheckBoxGadget(#CC_IF_Y_GREATER,5,5+Count*18,170,18,"IF_Y_GREATER"):Count+1
  CheckBoxGadget(#CC_IF_Y_LESS,5,5+Count*18,170,18,"IF_Y_LESS"):Count+1
  CheckBoxGadget(#CC_IF_Y_EQUAL,5,5+Count*18,170,18,"IF_Y_EQUAL"):Count+1
  CheckBoxGadget(#CC_IF_ENEMYABS_GREATER,5,5+Count*18,170,18,"IF_ENEMYABS_GREATER"):Count+1
  CheckBoxGadget(#CC_IF_ENEMYABS_LESS,5,5+Count*18,170,18,"IF_ENEMYABS_LESS"):Count+1
  CheckBoxGadget(#CC_IF_ENEMYABS_EQUAL,5,5+Count*18,170,18,"IF_ENEMYABS_EQUAL"):Count+1
  CheckBoxGadget(#CC_IF_CMP_ENEMY_GREATER,5,5+Count*18,170,18,"IF_CMP_ENEMY_GREATER"):Count+1
  CheckBoxGadget(#CC_IF_CMP_ENEMY_LESS,5,5+Count*18,170,18,"IF_CMP_ENEMY_LESS"):Count+1
  CheckBoxGadget(#CC_IF_CMP_ENEMY_EQUAL,5,5+Count*18,170,18,"IF_CMP_ENEMY_EQUAL"):Count+1  
  
  CheckBoxGadget(#CC_IF_GENERATION_GREATER,5,5+Count*18,170,18,"IF_GENERATION_GREATER"):Count+1  
  CheckBoxGadget(#CC_IF_GENERATION_LESS,5,5+Count*18,170,18,"IF_GENERATION_LESS"):Count+1  
  CheckBoxGadget(#CC_IF_GENERATION_EQUAL,5,5+Count*18,170,18,"IF_GENERATION_EQUAL"):Count+1  
  CheckBoxGadget(#CC_IF_NUMOFCELLS_GREATER,5,5+Count*18,170,18,"IF_NUMOFCELLS_GREATER"):Count+1  
  CheckBoxGadget(#CC_IF_NUMOFCELLS_LESS,5,5+Count*18,170,18,"IF_NUMOFCELLS_LESS"):Count+1  
  CheckBoxGadget(#CC_IF_NUMOFCELLS_EQUAL,5,5+Count*18,170,18,"IF_NUMOFCELLS_EQUAL"):Count+1  
  CheckBoxGadget(#CC_IF_CELLNUMER_GREATER,5,5+Count*18,170,18,"IF_CELLNUMER_GREATER"):Count+1  
  CheckBoxGadget(#CC_IF_CELLNUMER_LESS,5,5+Count*18,170,18,"IF_CELLNUMER_LESS"):Count+1  
  CheckBoxGadget(#CC_IF_CELLNUMER_EQUAL,5,5+Count*18,170,18,"IF_CELLNUMER_EQUAL"):Count+1  
  CheckBoxGadget(#CC_IF_MALE,5,5+Count*18,170,18,"IF_MALE"):Count+1  
  CheckBoxGadget(#CC_IF_FEMALE,5,5+Count*18,170,18,"IF_FEMALE"):Count+1  
  CheckBoxGadget(#CC_IF_AGE_GREATER,5,5+Count*18,170,18,"IF_AGE_GREATER"):Count+1  
  CheckBoxGadget(#CC_IF_AGE_LESS,5,5+Count*18,170,18,"IF_AGE_LESS"):Count+1  
  CheckBoxGadget(#CC_IF_AGE_EQUAL,5,5+Count*18,170,18,"IF_AGE_EQUAL"):Count+1  
  
  CheckBoxGadget(#CC_IF_ABSORBABLE,5,5+Count*18,170,18,"IF_ABSORBABLE"):Count+1  

  
  Count=0
  StringGadget(#CC_IF_Str_ENERGY_GREATER,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  StringGadget(#CC_IF_Str_ENERGY_LESS,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  StringGadget(#CC_IF_Str_ENERGY_EQUAL,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  StringGadget(#CC_IF_Str_ENERGYINC_GREATER,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  StringGadget(#CC_IF_Str_ENERGYDEC_GREATER,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  StringGadget(#CC_IF_Str_MSG_GREATER,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  StringGadget(#CC_IF_Str_MSG_LESS,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  StringGadget(#CC_IF_Str_MSG_EQUAL,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  StringGadget(#CC_IF_Str_FOOD_GREATER,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  StringGadget(#CC_IF_Str_FOOD_LESS,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  StringGadget(#CC_IF_Str_FOOD_EQUAL,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  StringGadget(#CC_IF_Str_POISON_GREATER,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  StringGadget(#CC_IF_Str_POISON_LESS,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  StringGadget(#CC_IF_Str_POISON_EQUAL,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  StringGadget(#CC_IF_Str_POISONID_GREATER,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  StringGadget(#CC_IF_Str_POISONID_LESS,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  StringGadget(#CC_IF_Str_POISONID_EQUAL,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  StringGadget(#CC_IF_Str_DNA_GREATER,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  StringGadget(#CC_IF_Str_DNA_LESS,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  StringGadget(#CC_IF_Str_DNA_EQUAL,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  StringGadget(#CC_IF_Str_VARIABLE_GREATER,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  StringGadget(#CC_IF_Str_VARIABLE_LESS,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  StringGadget(#CC_IF_Str_VARIABLE_EQUAL,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  StringGadget(#CC_IF_Str_CELL_RAD_GREATER,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  StringGadget(#CC_IF_Str_CELL_RAD_LESS,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  StringGadget(#CC_IF_Str_CELL_RAD_EQUAL,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  
  StringGadget(#CC_IF_Str_X_GREATER,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  StringGadget(#CC_IF_Str_X_LESS,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  StringGadget(#CC_IF_Str_X_EQUAL,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  StringGadget(#CC_IF_Str_Y_GREATER,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  StringGadget(#CC_IF_Str_Y_LESS,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  StringGadget(#CC_IF_Str_Y_EQUAL,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  StringGadget(#CC_IF_Str_ENEMYABS_GREATER,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  StringGadget(#CC_IF_Str_ENEMYABS_LESS,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  StringGadget(#CC_IF_Str_ENEMYABS_EQUAL,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  
  StringGadget(#CC_IF_Str_CMP_ENEMY_GREATER,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  StringGadget(#CC_IF_Str_CMP_ENEMY_LESS,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  StringGadget(#CC_IF_Str_CMP_ENEMY_EQUAL,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  
  
  StringGadget(#CC_IF_Str_GENERATION_GREATER,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1 
  StringGadget(#CC_IF_Str_GENERATION_LESS,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  StringGadget(#CC_IF_Str_GENERATION_EQUAL,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  
  StringGadget(#CC_IF_Str_NUMOFCELLS_GREATER,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1 
  StringGadget(#CC_IF_Str_NUMOFCELLS_LESS,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  StringGadget(#CC_IF_Str_NUMOFCELLS_EQUAL,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1 
  
  StringGadget(#CC_IF_Str_CELLNUMER_GREATER,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1 
  StringGadget(#CC_IF_Str_CELLNUMER_LESS,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1 
  StringGadget(#CC_IF_Str_CELLNUMER_EQUAL,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  
  StringGadget(#CC_IF_Str_MALE,175,5+Count*18,70,18,"",#PB_String_Numeric):Count+1
  StringGadget(#CC_IF_Str_FEMALE,175,5+Count*18,70,18,"",#PB_String_Numeric):Count+1
  StringGadget(#CC_IF_Str_AGE_GREATER,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  StringGadget(#CC_IF_Str_AGE_LESS,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1
  StringGadget(#CC_IF_Str_AGE_EQUAL,175,5+Count*18,70,18,"500",#PB_String_Numeric):Count+1 
  
  StringGadget(#CC_IF_Str_ABSORBABLE,175,5+Count*18,70,18,"",#PB_String_Numeric):Count+1 
    
  
  
EndProcedure
Procedure OpenCCAttackWindow()
  OpenWindow(#Window_CC_Attack,0,0,355,155,"Living Code - Attack",#PB_Window_SystemMenu|#PB_Window_WindowCentered,WindowID(#Window_CreateCreature))
  UseGadgetList(WindowID(#Window_CC_Attack))
  
  OptionGadget(#CC_ATTACK_POISON,5,5,145,20,"POISON_EMIT ID")
  OptionGadget(#CC_ATTACK_VIRUS,5,30,145,20,"EMIT_VIRUS " + ReadPreferenceString_(languagefile, "text", "min-energy"))
  OptionGadget(#CC_ATTACK_DNA,5,85,145,20,"EMIT_DNA " + ReadPreferenceString_(languagefile, "text", "code"))
  
  
  
  StringGadget(#CC_ATTACK_POISON_STR,150,5,200,20,"500",#PB_String_Numeric)
  StringGadget(#CC_ATTACK_VIRUS_STR,150,30,200,20,"0",#PB_String_Numeric)
  TextGadget(#CC_ATTACK_VIRUS_POS,5,52,150,20,ReadPreferenceString_(languagefile, "text", "Code-position"))
  StringGadget(#CC_ATTACK_VIRUS_POS_STR,150,50,200,20,"0",#PB_String_Numeric)
  ComboBoxGadget(#CC_ATTACK_DNA_STR,150,85,200,20)
  For i=0 To #CMD_NOP
    AddGadgetItem(#CC_ATTACK_DNA_STR, -1, CodeToCMDString(i))
  Next
  
  TextGadget(#CC_ATTACK_DNA_POS,5,107,150,20,ReadPreferenceString_(languagefile, "text", "Code-position"))
  StringGadget(#CC_ATTACK_DNA_POS_STR,150,105,200,20,"0",#PB_String_Numeric)
  
  SetGadgetState(#CC_ATTACK_DNA, #True)
  SetGadgetState(#CC_ATTACK_DNA_STR, 4)
  
  
  
  ButtonGadget(#CC_ATTACK_CANCEL,5,130,70,20,ReadPreferenceString_(languagefile, "text", "Cancel"))
  ButtonGadget(#CC_ATTACK_INSERT,280,130,70,20,ReadPreferenceString_(languagefile, "text", "Insert"))
  
  
  
EndProcedure
Procedure OpenCCCloneWindow()
  OpenWindow(#Window_CC_Clone,0,0,160,205,"Living Code - Clone",#PB_Window_SystemMenu|#PB_Window_WindowCentered,WindowID(#Window_CreateCreature))
  UseGadgetList(WindowID(#Window_CC_Clone))
  
  TextGadget(#CC_CLONE_MIN_ENERGY,5,5,150,20,ReadPreferenceString_(languagefile, "text", "Copy-min-energy")+":")
  StringGadget(#CC_CLONE_MIN_ENERGY_STR,5,25,150,20,"50000",#PB_String_Numeric)
  
  
  OptionGadget(#CC_CLONE_CLONE,5,55,145,20,"CLONE")
  OptionGadget(#CC_CLONE_COPY50_50,5,80,145,20,"COPY50_50")
  OptionGadget(#CC_CLONE_COPY25_75,5,105,145,20,"COPY25_75")
  OptionGadget(#CC_CLONE_COPY5_95,5,130,145,20,"COPY5_95")
  OptionGadget(#CC_CLONE_COMBINECOPY,5,155,145,20,"COMBINECOPY")
  SetGadgetState(#CC_CLONE_CLONE, #True)
  
  
  ButtonGadget(#CC_CLONE_CANCEL,5,180,70,20,ReadPreferenceString_(languagefile, "text", "Cancel"))
  ButtonGadget(#CC_CLONE_INSERT,85,180,70,20,ReadPreferenceString_(languagefile, "text", "Insert"))
  
  
  
  
EndProcedure
Procedure OpenUploadWindow()
  OpenWindow(#Window_Upload,0,0,210,200,"Living Code - Upload",#PB_Window_SystemMenu|#PB_Window_WindowCentered,WindowID(#Window_CreateCreature))
  UseGadgetList(WindowID(#Window_Upload))
  TestNewVersion(#False)
  
  Name.s = TestUploadString(GetGadgetText(#CreateCreature_CreatureNameStr),1)
  Author.s = TestUploadString(GetGadgetText(#CreateCreature_CreatureAuthorStr),1)
  Description.s = TestUploadString(GetGadgetText(#CreateCreature_CreatureDescriptionStr))
  If Name="":Name=Str(Random(10000)):EndIf
  If Author="":Author=ReadPreferenceString_(languagefile, "text", "NoName"):EndIf
  If Description="":Description="-":EndIf
  
  TextGadget(#UPLOAD_NAME,5,5,200,15,ReadPreferenceString_(languagefile, "text", "Name")+":")
  StringGadget(#UPLOAD_NAME_STR,5,20,200,20,Name)
  
  TextGadget(#UPLOAD_AUTHOR,5,55,200,15,ReadPreferenceString_(languagefile, "text", "Author")+":")
  StringGadget(#UPLOAD_AUTHOR_STR,5,70,200,20,Author)
  
  TextGadget(#UPLOAD_DESC,5,95,200,15,ReadPreferenceString_(languagefile, "text", "Description")+":")
  StringGadget(#UPLOAD_DESC_STR,5,110,200,20,Description)
  
  
  TextGadget(#UPLOAD_IP,5,135,200,15,ReadPreferenceString_(languagefile, "text", "Your-IP-will-be-saved"))
  CheckBoxGadget(#UPLOAD_CHECKBOX,5,150,200,20,ReadPreferenceString_(languagefile, "text", "I-agree"))
  
  
  
  ButtonGadget(#UPLOAD_CANCEL,5,175,70,20,ReadPreferenceString_(languagefile, "text", "Cancel"))
  ButtonGadget(#UPLOAD_UPLOAD,135,175,70,20,ReadPreferenceString_(languagefile, "text", "Upload"))
  DisableGadget(#UPLOAD_UPLOAD,#True)
  
  
EndProcedure
Procedure OpenManualDownloadWindow()
  
  OpenWindow(#Window_ManualDownload,0,0,640,480,"Living Code - Linux Manual Download",#PB_Window_SystemMenu|#PB_Window_WindowCentered,WindowID(#Window_Main))
  UseGadgetList(WindowID(#Window_ManualDownload))
  
  WebGadget(#MDL_WebGadget,0,0,640,480,UPLOAD_URL.s+UPLOAD_PAGEVIEW.s)
  
  
EndProcedure
Procedure Open3DView()
  CompilerIf #Use3DView = #True
    GlobalDrawing = #False
    View3D = #True
    
    
    
    
    DisableGadget(#Text_Option_RightM,#True)
    DisableGadget(#Option_RightM_FOOD,#True)
    DisableGadget(#Option_RightM_VIRUSES,#True)
    DisableGadget(#Option_RightM_DNA,#True)
    DisableGadget(#Option_RightM_POISON,#True)
    DisableGadget(#Option_RightM_Delete,#True)
    
    DisableGadget(#Track_ObjTrans,#True)
    
    
    DisableGadget(#TEXT_CreatureDebug,#True)
    DisableGadget(#TEXT_CreatureDName,#True)
    DisableGadget(#TEXT_CreatureDAuthor,#True)
    DisableGadget(#TEXT_CreatureDEnergy,#True)
    DisableGadget(#TEXT_CreatureDOrgEnergy,#True)
    
    DisableMenuItem(0,#Menu_Creature_Edit,#True)
    DisableMenuItem(0,#Menu_Creature_Kill,#True)
    DisableMenuItem(0,#Menu_Creature_Delete,#True)
    
    HideGadget(#View3D_Help,#False)
    
    
  CompilerEndIf
EndProcedure
Procedure Close3DView()
  CompilerIf #Use3DView = #True
    GlobalDrawing = #True
    View3D = #False
    
    
    DisableGadget(#Text_Option_RightM,#False)
    DisableGadget(#Option_RightM_FOOD,#False)
    DisableGadget(#Option_RightM_VIRUSES,#False)
    DisableGadget(#Option_RightM_DNA,#False)
    DisableGadget(#Option_RightM_POISON,#False)
    DisableGadget(#Option_RightM_Delete,#False)
    
    DisableGadget(#Track_ObjTrans,#False)
    
    DisableGadget(#TEXT_CreatureDebug,#False)
    DisableGadget(#TEXT_CreatureDName,#False)
    DisableGadget(#TEXT_CreatureDAuthor,#False)
    DisableGadget(#TEXT_CreatureDEnergy,#False)
    DisableGadget(#TEXT_CreatureDOrgEnergy,#False)
    
    HideGadget(#View3D_Help,#True)
    
    DisableMenuItem(0,#Menu_Creature_Edit,#False)
    DisableMenuItem(0,#Menu_Creature_Kill,#False)
    DisableMenuItem(0,#Menu_Creature_Delete,#False)
    
    
  CompilerEndIf
EndProcedure
Procedure OpenInsertCreates()
OpenWindow(#Window_InsertCreates,0,0,400,300,"Living Code - Insert Creatures",#PB_Window_SystemMenu|#PB_Window_WindowCentered,WindowID(#Window_Main))
ScrollAreaGadget(#InsertCreates_Area,180,0,220,300,198,1250,50)
Creatures.s=ReadPreferenceString_(languagefile, "text", "Creature")
For i=0 To 19
  GadGet\InsertCreatures[i]\Text=TextGadget(#PB_Any,5,i*60+5,70,15,Creatures+" "+Str(i+1))
  GadGet\InsertCreatures[i]\Ok=ImageGadget(#PB_Any,115,i*60+5,75,15,ImageID(Sprite\Img_Empty))
  GadGet\InsertCreatures[i]\File=StringGadget(#PB_Any,5,i*60+25,150,18,"",#PB_String_ReadOnly)
  GadGet\InsertCreatures[i]\SetFile=ButtonGadget(#PB_Any,160,i*60+25,30,18,"...")
Next
CloseGadgetList()

ButtonGadget(#InsertCreates_Cancel,5,275,70,20,ReadPreferenceString_(languagefile, "text", "Cancel"))
ButtonGadget(#InsertCreates_Ok,105,275,70,20,ReadPreferenceString_(languagefile, "text", "Insert"))
  
TextGadget(#InsertCreates_Energy_Text,5,5,165,15,ReadPreferenceString_(languagefile, "text", "Energy")+":")  
StringGadget(#InsertCreates_Energy_Str,5,22,165,20,"80000",#PB_String_Numeric)
  
TextGadget(#InsertCreates_CellAdd_Energy_Text,5,55,165,15,ReadPreferenceString_(languagefile, "text", "Energy-per-cell")+":")  
StringGadget(#InsertCreates_CellAdd_Energy_Str,5,72,165,20,"100",#PB_String_Numeric)

  
OptionGadget(#InsertCreates_Opt_DisableMutation,5,100,150,18,ReadPreferenceString_(languagefile, "text", "Disable-Mutation"))
OptionGadget(#InsertCreates_Opt_EnableMutation,5,118,150,18,ReadPreferenceString_(languagefile, "text", "Enable-Mutation"))
OptionGadget(#InsertCreates_Opt_OrginalMutation,5,136,150,18,ReadPreferenceString_(languagefile, "text", "Orginal"))
SetGadgetState(#InsertCreates_Opt_OrginalMutation,#True)


EndProcedure
Procedure OpenCreatureGenerator()
OpenWindow(#Window_Creature_Generator,0,0,360,310,"Living Code - "+ReadPreferenceString_(languagefile, "text", "Creature-Generator"),#PB_Window_SystemMenu|#PB_Window_WindowCentered,WindowID(#Window_Main))

TextGadget(#Creature_Generator_Random_Text,5,5,150,15,ReadPreferenceString_(languagefile, "text", "Random-Value")+":")
StringGadget(#Creature_Generator_Random,5,20,150,18,Str(Random($FFF)))
ToolTip(#Creature_Generator_Random,ReadPreferenceString_(languagefile, "text", "Random-Tooltip"))


TextGadget(#Creature_Generator_NumCells_Text,5,45,150,15,ReadPreferenceString_(languagefile, "text", "Num-Cells")+":")
TrackBarGadget(#Creature_Generator_NumCells,5,60,150,18,2,#MAX_CELLS,#TrackBar_TOOLTIPS)
SetGadgetState(#Creature_Generator_NumCells,8)
ToolTip(#Creature_Generator_NumCells,ReadPreferenceString_(languagefile, "text", "Num-Cells-Tooltip"))


TextGadget(#Creature_Generator_CopyMinEnergy_Text,5,85,150,15,ReadPreferenceString_(languagefile, "text", "Copy-min-energy")+":")
TrackBarGadget(#Creature_Generator_CopyMinEnergy,5,100,150,18,1000,150000,#TrackBar_TOOLTIPS)
SetGadgetState(#Creature_Generator_CopyMinEnergy,60000)
ToolTip(#Creature_Generator_CopyMinEnergy,ReadPreferenceString_(languagefile, "text", "Copy-min-energy-Tooltip"))


TextGadget(#Creature_Generator_ProtectionLevel_Text,5,125,150,15,ReadPreferenceString_(languagefile, "text", "Protection-Level")+":")
TrackBarGadget(#Creature_Generator_ProtectionLevel,5,140,150,18,0,9,#TrackBar_TOOLTIPS)
SetGadgetState(#Creature_Generator_ProtectionLevel,2)
ToolTip(#Creature_Generator_ProtectionLevel,ReadPreferenceString_(languagefile, "text", "Protection-Level-Tooltip"))


TextGadget(#Creature_Generator_AggressiveLevel_Text,5,165,150,15,ReadPreferenceString_(languagefile, "text", "Aggressive-Level")+":")
TrackBarGadget(#Creature_Generator_AggressiveLevel,5,180,150,18,0,9,#TrackBar_TOOLTIPS)
SetGadgetState(#Creature_Generator_AggressiveLevel,5)
ToolTip(#Creature_Generator_AggressiveLevel,ReadPreferenceString_(languagefile, "text", "Aggressive-Level-Tooltip"))


TextGadget(#Creature_Generator_Speed_Text,5,205,150,15,ReadPreferenceString_(languagefile, "text", "Speed")+":")
TrackBarGadget(#Creature_Generator_Speed,5,220,150,18,0,9,#TrackBar_TOOLTIPS)
SetGadgetState(#Creature_Generator_Speed,6)
ToolTip(#Creature_Generator_Speed,ReadPreferenceString_(languagefile, "text", "Speed-Tooltip"))


CheckBoxGadget(#Creature_Generator_RotateEnemyFast,5,250,150,18,ReadPreferenceString_(languagefile, "text", "RotateEnemyFast"))
SetGadgetState(#Creature_Generator_RotateEnemyFast,#True)
CheckBoxGadget(#Creature_Generator_OnlyBigCellsCanEmitPoison,5,270,150,18,ReadPreferenceString_(languagefile, "text", "Only-Big-Cells-Emit-Poison"))
CheckBoxGadget(#Creature_Generator_EmitPoisonToEnemy,5,290,150,18,ReadPreferenceString_(languagefile, "text", "Emit-Poison-To-Enemy"))


TextGadget(#Creature_Generator_CopyMode_Text,170,5,180,15,ReadPreferenceString_(languagefile, "text", "CopyMode")+":")
ComboBoxGadget(#Creature_Generator_CopyMode,170,20,180,20)
For i=0 To 5
  AddGadgetItem(#Creature_Generator_CopyMode,-1,Generator_GetCopyModeStr(i))
Next
SetGadgetState(#Creature_Generator_CopyMode,2)
ToolTip(#Creature_Generator_CopyMode,ReadPreferenceString_(languagefile, "text", "CopyMode-Tooltip"))


TextGadget(#Creature_Generator_AttackMode_Text,170,45,180,15,ReadPreferenceString_(languagefile, "text", "AttackMode")+":")
ComboBoxGadget(#Creature_Generator_AttackMode,170,60,180,20)
For i=0 To 9
  AddGadgetItem(#Creature_Generator_AttackMode,-1,Generator_GetAttackModeStr(i))
Next
SetGadgetState(#Creature_Generator_AttackMode,1)
ToolTip(#Creature_Generator_AttackMode,ReadPreferenceString_(languagefile, "text", "AttackMode-Tooltip"))


TextGadget(#Creature_Generator_DNAAttackMode_Text,170,85,180,15,"DNA " + ReadPreferenceString_(languagefile, "text", "AttackMode")+":")
ComboBoxGadget(#Creature_Generator_DNAAttackMode,170,100,180,20)
For i=0 To 6
  AddGadgetItem(#Creature_Generator_DNAAttackMode,-1,Generator_GetDNAAttackModeStr(i))
Next
SetGadgetState(#Creature_Generator_DNAAttackMode,5)
ToolTip(#Creature_Generator_DNAAttackMode,ReadPreferenceString_(languagefile, "text", "DNA-AttackMode-Tooltip"))

ButtonGadget(#Creature_Generator_Cancel,170,285,70,20,ReadPreferenceString_(languagefile, "text", "Cancel"))
ButtonGadget(#Creature_Generator_Generate,285,285,70,20,ReadPreferenceString_(languagefile, "text", "Generate"))


EndProcedure
Procedure OpenSendReport()
OpenWindow(#Window_Report,0,0,310,370,"Living Code - "+ReadPreferenceString_(languagefile, "text", "Send-Report"),#PB_Window_SystemMenu|#PB_Window_WindowCentered,WindowID(#Window_Main))
CompilerIf #PB_Compiler_OS = #PB_OS_Linux
TextGadget(#Report_Mail_to_Text,5,5,300,20,ReadPreferenceString_(languagefile, "text", "Mail-to-support"),#PB_Text_Center)
CompilerElse
ButtonGadget(#Report_Mail_to_Text,0,0,310,25,ReadPreferenceString_(languagefile, "text", "Mail-to-support"))
CompilerEndIf


TextGadget(#Report_Mail_Text,5,30,250,15,ReadPreferenceString_(languagefile, "text", "E-Mail")+":")
StringGadget(#Report_Mail_Str,5,45,250,20,"")

TextGadget(#Report_Subject_Text,5,75,250,15,ReadPreferenceString_(languagefile, "text", "E-Mail-subject")+":")
StringGadget(#Report_Subject_Str,5,90,250,20,"")

TextGadget(#Report_Text_Text,5,120,250,15,ReadPreferenceString_(languagefile, "text", "E-Mail-text")+":")

EditorGadget(#Report_Text_Str,5,135,300,200)
  
ButtonGadget(#Report_Send, 235, 340,70, 25, ReadPreferenceString_(languagefile, "text", "Send-Report"))


EndProcedure



Procedure Events_Report(Event)
  If Event = #PB_Event_Gadget
    GadgetID = EventGadget()
    Select GadgetID
    Case #Report_Mail_to_Text
    RunProgram("mailto:support@living-code.de")
    
    Case #Report_Send
      If TestInternet()
        Text.s=GetGadgetText(#Report_Text_Str)
        Sender.s=GetGadgetText(#Report_Mail_Str)
        Subject.s=GetGadgetText(#Report_Subject_Str)
        If Text<>"" And Subject<>"" And Sender<>""
          Url.s = URLEncoder(UPLOAD_URL.s+"sendmail.php?text="+Text.s+"&subject="+Subject.s+"&sender="+Sender)
           CompilerIf #PB_Compiler_OS = #PB_OS_Linux
              Str.s = RowDownloadToString(Url, "LC-MAIL-AGENT", 10)
              Buffer.s = UploadError(Str.s)
            CompilerElse
              Buffer.s=Space(31)
              DownloadToMem("LC-MAIL-AGENT" , Url, @Buffer, 31)
            CompilerEndIf
            CloseWindow(#Window_Report)
          EndIf
      EndIf
    EndSelect
  EndIf

If Event = #PB_Event_CloseWindow
  CloseWindow(#Window_Report)
EndIf    
EndProcedure
Procedure Events_CreatureGenerator(Event)
  If Event = #PB_Event_Gadget
    GadgetID = EventGadget()
    Select GadgetID
      Case #Creature_Generator_AttackMode
        state=GetGadgetState(#Creature_Generator_AttackMode)
        If state=1 Or  state=2 Or  state=6 Or  state=7
          DisableGadget(#Creature_Generator_DNAAttackMode,#False)
        Else
          DisableGadget(#Creature_Generator_DNAAttackMode,#True)
        EndIf
      
      Case #Creature_Generator_Cancel
        CloseWindow(#Window_Creature_Generator)

      Case #Creature_Generator_Generate
        CellCount=GetGadgetState(#Creature_Generator_NumCells)
        gp.GENERATOR_PARAMETER
        gp\iCopyMinEnergy =   GetGadgetState(#Creature_Generator_CopyMinEnergy)
        gp\iProtectionLevel = GetGadgetState(#Creature_Generator_ProtectionLevel)
        gp\iCopyMode =        GetGadgetState(#Creature_Generator_CopyMode)
        gp\iAggressiveLevel = GetGadgetState(#Creature_Generator_AggressiveLevel)
        gp\iAttackMode =      GetGadgetState(#Creature_Generator_AttackMode)
        gp\iDNAAttackMode =   GetGadgetState(#Creature_Generator_DNAAttackMode)
        gp\iSpeed =           GetGadgetState(#Creature_Generator_Speed)
        gp\bRotateEnemyFast = GetGadgetState(#Creature_Generator_RotateEnemyFast)
        gp\bOnlyBigCellsCanEmitPoison = GetGadgetState(#Creature_Generator_OnlyBigCellsCanEmitPoison)
        gp\bEmitPoisonToEnemy=GetGadgetState(#Creature_Generator_EmitPoisonToEnemy)
        gp\iRandom =          Val(GetGadgetText(#Creature_Generator_Random))
        Code.s=GenerateCodeFromGenerator(gp.GENERATOR_PARAMETER)
        CloseWindow(#Window_Creature_Generator)  
        CreateCreature_Window(CellCount)
        GenerateCForm()
        For i=0 To CellCount-1
          ScintillaSendMessage(GadGet\Creature[i]\CodeEditor, #SCI_SETTEXT,0,@Code)
        Next
        SetGadgetState(#CreateCreature_CheckMutation,#True)
        SetGadgetText(#CreateCreature_CreatureAuthorStr,"Creature Generator")
        SetGadgetText(#CreateCreature_CreatureNameStr,"Creature "+Hex(gp\iRandom))
        Description.s="This is a generated Creature!"+#LF$
        Description+"It is a "
        If gp\iAggressiveLevel>4:Description+"agressive":Agressive=#True:Add=#True:EndIf
        If gp\iProtectionLevel>4 And Agressive=#True:Description+" and protection":Add=#True:EndIf
        If gp\iProtectionLevel>4 And Agressive=#False:Description+"protection":Add=#True:EndIf
        If Add=#False:Description+"harmless":EndIf
        Description+" Creature."+#LF$
        If gp\iSpeed>5:Description+"The Creature is also very fast."+#LF$:EndIf
        
        SetGadgetText(#CreateCreature_CreatureDescriptionStr,Description)
        SetGadgetText(#CreateCreature_EnergyStr,"80000")
      
    EndSelect
  EndIf

If Event = #PB_Event_CloseWindow
  CloseWindow(#Window_Creature_Generator)
EndIf    
EndProcedure
Procedure Events_InsertCreates(Event)
  If Event = #PB_Event_Gadget
    GadgetID = EventGadget()
    For i=0 To 19
      If GadGet\InsertCreatures[i]\SetFile = GadgetID
        File.s = OpenFileRequester(ReadPreferenceString_(languagefile, "text", "Open-Creature"),"",CreaturePattern,1)
        If File
          SetGadgetText(GadGet\InsertCreatures[i]\File,File)
          Img=GetCreatureOk_FromFile(File)
          If Img=Sprite\Img_Empty:SetGadgetText(GadGet\InsertCreatures[i]\File,""):EndIf
          SetGadgetState(GadGet\InsertCreatures[i]\Ok,ImageID(img))
        EndIf
      EndIf
    Next
    Select GadgetID
      Case #InsertCreates_Cancel
        CloseWindow(#Window_InsertCreates)
      
      Case #InsertCreates_Ok
        energy=Val(GetGadgetText(#InsertCreates_Energy_Str))
        EnergyAdd=Val(GetGadgetText(#InsertCreates_CellAdd_Energy_Str))
        If GetGadgetState(#InsertCreates_Opt_DisableMutation):DisableMutation=#True:EndIf
        If GetGadgetState(#InsertCreates_Opt_EnableMutation):DisableMutation=#False:EndIf
        If GetGadgetState(#InsertCreates_Opt_OrginalMutation):DisableMutation=#PB_Ignore:EndIf
        ;Zuerst alle Eintäge Zählen
        For i=0 To 19
          T.s=GetGadgetText(GadGet\InsertCreatures[i]\File)
          If T<>"":Count+1:EndIf
        Next
        ;Nun die Creaturen einfügen
        For i=0 To 19
          T.s=GetGadgetText(GadGet\InsertCreatures[i]\File)
          If T<>""
            Lebewesen+1
            x=Sin((2*#PI/Count)*Lebewesen)*220+#AREA_WIDTH/2
            y=Cos((2*#PI/Count)*Lebewesen)*160+#AREA_HEIGHT/2
            ;Debug Str(Lebewesen)+", "+Str(x)+", "+Str(y)+", "+Str(360/Count)
            InsertCreateCreature_FromFile(T, x, y, energy, energy, EnergyAdd, DisableMutation)
          EndIf
        Next        
        
        
        
        CloseWindow(#Window_InsertCreates)
      
    EndSelect
    
  EndIf

If Event = #PB_Event_CloseWindow
  CloseWindow(#Window_InsertCreates)
EndIf    
EndProcedure
Procedure Events_3DView()
  CompilerIf #Use3DView = #True
    
    Start3D() 
      Sprite3DQuality(1)
      S3DR_BeginReal3D()
      
      S3DR_ClearScreenAndZBuffer(RGB(200,200,255))
      
      
      cx.f=S3DR_GetCameraX()
      cy.f=S3DR_GetCameraY()
      CZ.f=S3DR_GetCameraZ()
      S3DR_SelectTexture(Sprite\Texture_Sky)
      ;S3DR_SetTextureCoordinates(0,0,3,0,0,3,3,3)
      S3DR_SetCullMode(#S3DR_CW) 
      S3DR_Draw3D( 600+cx,-600+cy, 600+CZ,-600+cx,-600+cy, 600+CZ, 600+cx,-600+cy,-600+CZ,-600+cx,-600+cy,-600+CZ)
      S3DR_Draw3D( 600+cx, 600+cy, 600+CZ,-600+cx, 600+cy, 600+CZ, 600+cx,-600+cy, 600+CZ,-600+cx,-600+cy, 600+CZ)
      S3DR_Draw3D(-600+cx, 600+cy, 600+CZ, 600+cx, 600+cy, 600+CZ,-600+cx, 600+cy,-600+CZ, 600+cx, 600+cy,-600+CZ)
      S3DR_Draw3D(-600+cx, 600+cy, 600+CZ,-600+cx, 600+cy,-600+CZ,-600+cx,-600+cy, 600+CZ,-600+cx,-600+cy,-600+CZ)
      S3DR_Draw3D(-600+cx, 600+cy,-600+CZ, 600+cx, 600+cy,-600+CZ,-600+cx,-600+cy,-600+CZ, 600+cx,-600+cy,-600+CZ)
      S3DR_Draw3D( 600+cx, 600+cy,-600+CZ, 600+cx, 600+cy, 600+CZ, 600+cx,-600+cy,-600+CZ, 600+cx,-600+cy, 600+CZ)
      S3DR_SetCullMode(#S3DR_CCW)
      ;S3DR_SetTextureCoordinates(0,0,1,0,0,1,1,1)
      
      
      S3DR_UseTransparency(#S3DR_FALSE)
      S3DR_SetDiffuseColors(#White, #White, #White, #White)
      S3DR_SelectTexture(Sprite\Texture_Ground)
      
      Size.f = #View3D_Scale/80
      S3DR_Draw3D(0,0,#View3D_Scale, #View3D_Scale,0,#View3D_Scale, 0,0,0, #View3D_Scale,0,0)
      S3DR_UseTransparency(#S3DR_TRUE)
      
      
      For i = 0 To Objects_Count -1    
        *Object.OBJECT= Objects(i)    
        If  *Object\Used
          X.f = *Object\X / #AREA_WIDTH * #View3D_Scale
          Z.f = *Object\Y / #AREA_HEIGHT * #View3D_Scale
          Draw = #False
          Select *Object\Type
            Case #OBJECT_DNA
              If GadGet\state\DNA
                S3DR_SelectTexture(Sprite\Texture_DNA)
                Draw = #True
              EndIf
            Case #OBJECT_MSG
              If GadGet\state\msg
                S3DR_SelectTexture(Sprite\msg)
                Draw = #True
              EndIf
            Case #OBJECT_VIRUS
              If GadGet\state\VIRUS
                S3DR_SelectTexture(Sprite\Texture_Virus)
                Draw = #True
              EndIf
            Case #OBJECT_FOOD
              If GadGet\state\FOOD
                S3DR_SelectTexture(Sprite\Texture_Food)
                Draw = #True
              EndIf
            Case #OBJECT_POISON
              If GadGet\state\POISON
                S3DR_SelectTexture(Sprite\Texture_Poison)
                Draw = #True
              EndIf
            Case #OBJECT_REST
              If GadGet\state\REST
                S3DR_SelectTexture(Sprite\Texture_Rest)
                Draw = #True
              EndIf
          EndSelect
          If Draw
            ;S3DR_Draw3D(X -Size/2,0.25,Z+Size/2, X+Size/2,0.25,Z+Size/2, X-Size/2,0,Z-Size/2, X+Size/2,0.25,Z-Size/2)
            S3DR_DrawBillboard(X, Size/2, Z, Size, Size)
          EndIf
        EndIf
      Next   
      
      S3DR_SetCullMode(#S3DR_NONE)
      S3DR_SelectTexture(Sprite\Texture_Crature)  
      For i=0 To Creatures_Count -1
        
        If Creatures(i)\Used
          DrawCreature3D(i)
        EndIf
        
      Next
      
      
      S3DR_EndReal3D()
    Stop3D()
    
    If MakeScreenshot = #True
      MakeScreenshot()
      MakeScreenshot = #False
    EndIf
    FlipBuffers(0)
    
    fac.f = 60/(fps+1)
    If GetAsyncKeyState_(#VK_UP)
      S3DR_MoveCamera(0,0,3.5*fac) 
    EndIf
    If GetAsyncKeyState_(#VK_DOWN)
      S3DR_MoveCamera(0,0,-3.5*fac) 
    EndIf
    If GetAsyncKeyState_(#VK_RIGHT)
      S3DR_RotateCamera(0,0.02*fac,0) 
    EndIf
    If GetAsyncKeyState_(#VK_LEFT)
      S3DR_RotateCamera(0,-0.02*fac,0) 
    EndIf
    If GetAsyncKeyState_(#VK_Q)
      S3DR_RotateCamera(-0.02*fac,0,0) 
    EndIf
    If GetAsyncKeyState_(#VK_A)
      S3DR_RotateCamera(0.02*fac,0,0) 
    EndIf
    
    
    
  CompilerEndIf
EndProcedure
Procedure Events_ManualDownload(Event)
  If Event = #PB_Event_Gadget
    GadgetID = EventGadget()
    Select GadgetID
    EndSelect
  EndIf
  
  If Event = #PB_Event_CloseWindow
    CloseWindow(#Window_ManualDownload)
  EndIf    
EndProcedure
Procedure Events_UploadWindow(Event)
  If Event = #PB_Event_Gadget
    GadgetID = EventGadget()
    Select GadgetID
      Case #UPLOAD_CANCEL
        CloseWindow(#Window_Upload)
        
      Case #UPLOAD_CHECKBOX
        If GetGadgetState(#UPLOAD_CHECKBOX)=#True
          DisableGadget(#UPLOAD_UPLOAD,#False) 
        Else
          DisableGadget(#UPLOAD_UPLOAD,#True) 
        EndIf 
      Case #UPLOAD_UPLOAD
        If GetGadgetState(#UPLOAD_CHECKBOX)=#True
          SetGadgetText(#CreateCreature_CreatureNameStr,GetGadgetText(#UPLOAD_NAME_STR))
          SetGadgetText(#CreateCreature_CreatureAuthorStr,GetGadgetText(#UPLOAD_AUTHOR_STR))
          SetGadgetText(#CreateCreature_CreatureDescriptionStr,GetGadgetText(#UPLOAD_DESC_STR))
          If TestInternet()
            Name.s = TestUploadString(GetGadgetText(#CreateCreature_CreatureNameStr),1)
            Author.s = TestUploadString(GetGadgetText(#CreateCreature_CreatureAuthorStr),1)
            Description.s = TestUploadString(GetGadgetText(#CreateCreature_CreatureDescriptionStr))
            If Name="":Name=Str(Random(10000)):EndIf
            If Author="":Author="NoName":EndIf
            If Description="":Description="-":EndIf
            File.s = GetTemporaryDirectory()+Name+".CRF"
            
            
            ;MessageRequester("Info", Buffer.s)
            If _SaveCreateCreatureSettings(File.s)
              Size = FileSize(File)
              If Size<50000
              
                If UploadFile(File, UPLOAD_URL.s + UPLOAD_PAGEUPLOAD.s, UPLOAD_FILE_KEY)
                  CompilerIf #PB_Compiler_OS = #PB_OS_Linux
                    
                    Url.s = URLEncoder(UPLOAD_URL.s+UPLOAD_UPLOADPAGE+"?KEY="+UPLOAD_KEY.s+"&NAME="+Name+"&AUTHOR="+Author+"&DESC="+Description+"&DATE="+FormatDate("%dd:%mm:%yy %hh:%ii:%ss",Date())+"&SIZE="+Str(Size)+"&FILE=Files/"+Name+".CRF")
                    Str.s = RowDownloadToString(Url, UPLOAD_AGENT.s, 10)
                    
                    Buffer.s = UploadError(Str.s)
                    
                    
                  CompilerElse
                    Buffer.s=Space(31)
                    DownloadToMem(UPLOAD_AGENT.s , URLEncoder(UPLOAD_URL.s+UPLOAD_UPLOADPAGE+"?KEY="+UPLOAD_KEY.s+"&NAME="+Name+"&AUTHOR="+Author+"&DESC="+Description+"&DATE="+FormatDate("%dd:%mm:%yy %hh:%ii:%ss",Date())+"&SIZE="+Str(Size)+"&FILE=Files/"+Name+".CRF"), @Buffer, 31)
                  CompilerEndIf
                  
                  Buffer.s = UploadError(Buffer.s)
                  MessageRequester("Info", Buffer.s)
                Else
                  MessageRequester("ERROR:", ReadPreferenceString_(languagefile, "text", "File-Can-not-uploaded"))
                EndIf
                
              Else
                MessageRequester("Error", ReadPreferenceString_(languagefile, "text", "That-File-is-to-big"))
              EndIf
              
            EndIf
            DeleteFile(File)
            
          EndIf
          CloseWindow(#Window_Upload)
        EndIf
    EndSelect
  EndIf
  
  If Event = #PB_Event_CloseWindow
    CloseWindow(#Window_Upload)
  EndIf    
EndProcedure
Procedure Events_CC_Clone(Event)
  If Event = #PB_Event_Gadget
    GadgetID = EventGadget()
    Select GadgetID
      Case #CC_CLONE_CANCEL
        CloseWindow(#Window_CC_Clone)
      Case #CC_CLONE_INSERT
        Text.s = ""
        Text.s = "COPY_MIN_ENERGY " + GetGadgetText(#CC_CLONE_MIN_ENERGY_STR)+#LF$
        
        
        If GetGadgetState(#CC_CLONE_CLONE)=#True
          Text.s + "CLONE"
        EndIf
        If GetGadgetState(#CC_CLONE_COPY50_50)=#True
          Text.s + "COPY50_50"
        EndIf
        If GetGadgetState(#CC_CLONE_COPY25_75)=#True
          Text.s + "COPY25_75"
        EndIf      
        If GetGadgetState(#CC_CLONE_COPY5_95)=#True
          Text.s + "COPY5_95"
        EndIf           
        If GetGadgetState(#CC_CLONE_COMBINECOPY)=#True
          Text.s + "COMBINECOPY"
        EndIf         
        
        
        Pannel=GetGadgetState(#CreateCreature_Tab)
        If Pannel>0
          Pos = ScintillaSendMessage(GadGet\Creature[Pannel-1]\CodeEditor, #SCI_GETCURRENTPOS)  
          ScintillaSendMessage(GadGet\Creature[Pannel-1]\CodeEditor, #SCI_INSERTTEXT,Pos,@Text)
          ScintillaSendMessage(GadGet\Creature[Pannel-1]\CodeEditor, #SCI_SETSEL,Pos+Len(Text),Pos+Len(Text))
          SetActiveGadget(GadGet\Creature[Pannel-1]\CodeEditor)
        EndIf
        CloseWindow(#Window_CC_Clone)
    EndSelect
  EndIf
  
  If Event = #PB_Event_CloseWindow
    CloseWindow(#Window_CC_Clone)
  EndIf    
EndProcedure
Procedure Events_CC_Attack(Event)
  If Event = #PB_Event_Gadget
    GadgetID = EventGadget()
    Select GadgetID
      Case #CC_ATTACK_CANCEL
        CloseWindow(#Window_CC_Attack)
      Case #CC_ATTACK_INSERT
        Text.s = ""
        If GetGadgetState(#CC_ATTACK_POISON)=#True
          Text.s = "POISON_EMIT "+GetGadgetText(#CC_ATTACK_POISON_STR)
        EndIf
        If GetGadgetState(#CC_ATTACK_VIRUS)=#True
          Text.s = "POISON_VIRUS_MIN_ENERGY "+GetGadgetText(#CC_ATTACK_VIRUS_STR)+#LF$
          Text.s + "POISON_EMIT_VIRUS "+GetGadgetText(#CC_ATTACK_VIRUS_POS_STR)
        EndIf
        If GetGadgetState(#CC_ATTACK_DNA)=#True
          Text.s = "POISON_DNA_CODE "+Str(CMDStringToCode(GetGadgetText(#CC_ATTACK_DNA_STR)))+#LF$
          Text.s + "POISON_EMIT_DNA "+GetGadgetText(#CC_ATTACK_DNA_POS_STR)
        EndIf
        
        Pannel=GetGadgetState(#CreateCreature_Tab)
        If Pannel>0
          Pos = ScintillaSendMessage(GadGet\Creature[Pannel-1]\CodeEditor, #SCI_GETCURRENTPOS)  
          ScintillaSendMessage(GadGet\Creature[Pannel-1]\CodeEditor, #SCI_INSERTTEXT,Pos,@Text)
          ScintillaSendMessage(GadGet\Creature[Pannel-1]\CodeEditor, #SCI_SETSEL,Pos+Len(Text),Pos+Len(Text))
          SetActiveGadget(GadGet\Creature[Pannel-1]\CodeEditor)
        EndIf
        CloseWindow(#Window_CC_Attack)
    EndSelect
  EndIf
  
  If Event = #PB_Event_CloseWindow
    CloseWindow(#Window_CC_Attack)
  EndIf    
EndProcedure
Procedure Events_CC_IF(Event)
  If Event = #PB_Event_Gadget
    GadgetID = EventGadget()
    Select GadgetID
      Case #CC_IF_CANCEL
        CloseWindow(#Window_CC_IF)
      Case #CC_IF_INSERT
        Bedingung.s = ""
        For i=#CC_IF_ENERGY_GREATER To #CC_IF_Str_AGE_EQUAL
          
          If GetGadgetState(i)
            Bedingung.s + GetGadgetText(i) + " " + GetGadgetText(i+53) + #LF$
          EndIf
          
        Next
        
        
        Pannel=GetGadgetState(#CreateCreature_Tab)
        If Pannel>0
          Text.s=Space(1000)
          ScintillaSendMessage(GadGet\Creature[Pannel-1]\CodeEditor, #SCI_GETSELTEXT,0,@Text.s)
          ;Debug Text.s
          If Text <>""
            posS = ScintillaSendMessage(GadGet\Creature[Pannel-1]\CodeEditor, #SCI_GETSELECTIONSTART)
            posE = ScintillaSendMessage(GadGet\Creature[Pannel-1]\CodeEditor, #SCI_GETSELECTIONEND)+Len(Bedingung)
            ScintillaSendMessage(GadGet\Creature[Pannel-1]\CodeEditor, #SCI_INSERTTEXT,posS,@Bedingung)
            Text.s=#LF$+"ENDIF"
            ScintillaSendMessage(GadGet\Creature[Pannel-1]\CodeEditor, #SCI_INSERTTEXT,posE,@Text)
            ScintillaSendMessage(GadGet\Creature[Pannel-1]\CodeEditor, #SCI_SETSEL,posE+Len(Text),posE+Len(Text))
          Else
            Pos = ScintillaSendMessage(GadGet\Creature[Pannel-1]\CodeEditor, #SCI_GETCURRENTPOS) 
            ScintillaSendMessage(GadGet\Creature[Pannel-1]\CodeEditor, #SCI_INSERTTEXT,Pos,@Bedingung)
            ScintillaSendMessage(GadGet\Creature[Pannel-1]\CodeEditor, #SCI_SETSEL,Pos+Len(Bedingung),Pos+Len(Bedingung))
          EndIf
          SetActiveGadget(GadGet\Creature[Pannel-1]\CodeEditor)
        EndIf
        
        
        CloseWindow(#Window_CC_IF)
    EndSelect
  EndIf
  
  If Event = #PB_Event_CloseWindow
    CloseWindow(#Window_CC_IF)
  EndIf    
EndProcedure
Procedure Events_CC_Rotate(Event)
  If Event = #PB_Event_Gadget
    GadgetID = EventGadget()
    Select GadgetID
      Case #CC_ROTATE_CANCEL
        CloseWindow(#Window_CC_Rotate)
      Case #CC_ROTATE_INSERT
        If GetGadgetState(#CC_ROTATE_LEFT)=#True:Text.s = "ROTATE_LEFT":EndIf
        If GetGadgetState(#CC_ROTATE_RIGHT)=#True:Text.s = "ROTATE_RIGHT":EndIf
        If GetGadgetState(#CC_ROTATE_MSG)=#True:Text.s = "ROTATE_MSG":EndIf
        If GetGadgetState(#CC_ROTATE_POISON)=#True:Text.s = "ROTATE_POISON":EndIf
        If GetGadgetState(#CC_ROTATE_DNA)=#True:Text.s = "ROTATE_DNA":EndIf
        If GetGadgetState(#CC_ROTATE_FOOD)=#True:Text.s = "ROTATE_FOOD":EndIf
        If GetGadgetState(#CC_ROTATE_ANTI_MSG)=#True:Text.s = "ROTATE_ANTI_MSG":EndIf
        If GetGadgetState(#CC_ROTATE_ANTI_DNA)=#True:Text.s = "ROTATE_ANTI_DNA":EndIf
        If GetGadgetState(#CC_ROTATE_ANTI_POISON)=#True:Text.s = "ROTATE_ANTI_POISON":EndIf
        If GetGadgetState(#CC_ROTATE_ANTI_FOOD)=#True:Text.s = "ROTATE_ANTI_FOOD":EndIf
        If GetGadgetState(#CC_ROTATE_ENEMY)=#True:Text.s = "ROTATE_ENEMY":EndIf
        If GetGadgetState(#CC_ROTATE_ANTI_ENEMY)=#True:Text.s = "ROTATE_ANTI_ENEMY":EndIf
        If GetGadgetState(#CC_ROTATE_DEST_POINT)=#True:Text.s = "ROTATE_DEST_POINT":EndIf
        If GetGadgetState(#CC_ROTATE_ANTI_DEST_POINT)=#True:Text.s = "ROTATE_ANTI_DEST_POINT":EndIf
        
        
        Pannel=GetGadgetState(#CreateCreature_Tab)
        If Pannel>0
          Pos = ScintillaSendMessage(GadGet\Creature[Pannel-1]\CodeEditor, #SCI_GETCURRENTPOS)  
          ScintillaSendMessage(GadGet\Creature[Pannel-1]\CodeEditor, #SCI_INSERTTEXT,Pos,@Text)
          ScintillaSendMessage(GadGet\Creature[Pannel-1]\CodeEditor, #SCI_SETSEL,Pos+Len(Text),Pos+Len(Text))
          SetActiveGadget(GadGet\Creature[Pannel-1]\CodeEditor)
        EndIf
        CloseWindow(#Window_CC_Rotate)
    EndSelect
  EndIf
  
  If Event = #PB_Event_CloseWindow
    CloseWindow(#Window_CC_Rotate)
  EndIf    
EndProcedure
Procedure Events_CC_Move(Event)
  If Event = #PB_Event_Gadget
    GadgetID = EventGadget()
    Select GadgetID
      Case #CC_MOVE_CANCEL
        CloseWindow(#Window_CC_Move)
      Case #CC_MOVE_INSERT
        If GetGadgetState(#CC_MOVE_FORWARD)=#True
          Text.s = "MOVE_FORWARD"
        EndIf
        If GetGadgetState(#CC_MOVE_BACKWARD)=#True
          Text.s = "MOVE_BACKWARD"
        EndIf
        If GetGadgetState(#CC_MOVE_FORWARD2X)=#True
          Text.s = "MOVE_FORWARD2X"
        EndIf
        
        Pannel=GetGadgetState(#CreateCreature_Tab)
        If Pannel>0
          Pos = ScintillaSendMessage(GadGet\Creature[Pannel-1]\CodeEditor, #SCI_GETCURRENTPOS)  
          ScintillaSendMessage(GadGet\Creature[Pannel-1]\CodeEditor, #SCI_INSERTTEXT,Pos,@Text)
          ScintillaSendMessage(GadGet\Creature[Pannel-1]\CodeEditor, #SCI_SETSEL,Pos+Len(Text),Pos+Len(Text))
          SetActiveGadget(GadGet\Creature[Pannel-1]\CodeEditor)
        EndIf
        CloseWindow(#Window_CC_Move)
    EndSelect
  EndIf
  
  If Event = #PB_Event_CloseWindow
    CloseWindow(#Window_CC_Move)
  EndIf    
EndProcedure
Procedure Events_Splashscreen()
  If IsWindow(#Window_Splashscreen)
    time.l = 1800-(ElapsedMilliseconds() - Splashscreen_Start)
    
    
    If time<0
      CloseWindow(#Window_Splashscreen)
    EndIf
    
    
    
  EndIf
EndProcedure
Procedure EventsRightMButton()
  CompilerIf #PB_Compiler_OS = #PB_OS_Linux
    If SDL_GetMouseState_(@MouseX,@MouseY)=4
  CompilerElse
    If GetAsyncKeyState_(#VK_RBUTTON) & %1000000000000000; Event = #WM_RBUTTONDOWN ;#WM_RBUTTONDBLCLK;GetAsyncKeyState_(#VK_RBUTTON)
      MouseX = WindowMouseX(#Window_Main)
      MouseY = WindowMouseY(#Window_Main)
    CompilerEndIf
    If MouseX>0 And MouseY>0 And MouseX<#AREA_WIDTH And MouseY<#AREA_WIDTH
      
      
      Select RightMButton
        Case #OBJECT_FOOD
          AddFood(MouseX,MouseY,GlobalVar\OBJECT_FOOD_DEFAULT_SIZE)
        Case #OBJECT_VIRUS
          *obj.OBJECT = AddObject()
          If *obj<>0
            *obj\Type = #OBJECT_VIRUS
            *obj\CreatureID = 0
            *obj\CellID = 0
            *obj\Angle = Random(3600)/3600 * 2 * #PI
            *obj\Speed = Random(1000)/1000 * GlobalVar\OBJECT_VIRUS_MAXSPEED
            *obj\X = MouseX
            *obj\Y = MouseY
            *obj\MinEnergy = Random(3000)
            *obj\DNAPosition = Random(#CODE_SIZE-1)
            *obj\LifeTime = Random(GlobalVar\OBJECT_VIRUS_LIFETIME)  
          EndIf  
        Case #OBJECT_DNA
          *obj.OBJECT = AddObject()
          If *obj<>0
            *obj\Type = #OBJECT_DNA
            *obj\CreatureID = 0
            *obj\CellID = 0
            *obj\Angle = Random(3600)/3600 * 2 * #PI
            *obj\Speed = Random(1000)/1000 * GlobalVar\OBJECT_VIRUS_MAXSPEED
            *obj\IsDNABlock = #False
            *obj\X = MouseX
            *obj\Y = MouseY
            *obj\DNACode = Random(#CMD_NOP) + Random(64000)<<8
            *obj\DNAPosition = Random(#CODE_SIZE-1)
            *obj\LifeTime = Random(GlobalVar\OBJECT_DNA_LIFETIME)  
            *obj\Rotation = Random(360)
          EndIf  
        Case #OBJECT_POISON
          *obj.OBJECT = AddObject()
          If *obj<>0
            *obj\Type = #OBJECT_POISON
            *obj\CreatureID = 0
            *obj\CellID = 0
            *obj\Angle = Random(3600)/3600 * 2 * #PI
            *obj\Speed = Random(1000)/1000 * GlobalVar\OBJECT_POISON_MAXSPEED
            *obj\PoisonID = Random(255)
            *obj\X = MouseX
            *obj\Y = MouseY
            *obj\LifeTime = Random(GlobalVar\OBJECT_POISON_LIFETIME)  
          EndIf  
        Case #OBJECT_MSG;Delete
          For i = 0 To Objects_Count -1
            If  Objects(i)\Used 
              Abs = Sqr(Pow(MouseX-Objects(i)\X,2)+Pow(MouseY-Objects(i)\Y,2))
              If Abs <20
                Objects(i)\Used = #False
              EndIf
            EndIf 
          Next
          
      EndSelect
      
    EndIf
    
  EndIf
EndProcedure
Procedure Events_Main(Event)
  If Event = #PB_Event_CloseWindow
    ProcedureReturn #True
  EndIf
  
  If Event = #PB_Event_Menu
    Menu = EventMenu() 
    Select Menu
      Case #Menu_New
        ClearScene()
        
      Case #Menu_Options
        OpenOptions()
        
      Case #Menu_Load
        LoadScene()
        
      Case #Menu_MakeScreenshot  
        MakeScreenshot = #True
        
      Case #Menu_SaveAs
        SaveScene()
        
      Case #Menu_Quit
        ProcedureReturn #True
        
      Case #Menu_Help
        CompilerIf #PB_Compiler_OS = #PB_OS_Linux
          ;If RunProgram("okular",GetCurrentDirectory() + exePath+"Help/Help.pdf","")=#False
          RunProgram("firefox",GetCurrentDirectory() + exePath+"Help/Help.html","")
          ;EndIf
        CompilerElse
          ;If RunProgram(GetCurrentDirectory() + "Help\Help.pdf")=#False
          RunProgram(GetCurrentDirectory() + "Help\Help.html")
          ;EndIf
        CompilerEndIf
        
      Case #Menu_GermanHelp  
        CompilerIf #PB_Compiler_OS = #PB_OS_Linux
          ;If RunProgram("okular",GetCurrentDirectory() + exePath+"Help/Hilfe.pdf","")=#False
          RunProgram("firefox",GetCurrentDirectory() + exePath+"Help/Hilfe.html","")
          ;EndIf
        CompilerElse
          ;If RunProgram(GetCurrentDirectory() + "Help\Hilfe.pdf")=#False
          RunProgram(GetCurrentDirectory() + "Help\Hilfe.html")
          ;EndIf
        CompilerEndIf
      
      Case #Menu_Report
        OpenSendReport()
        
      Case #Menu_Forum 
        CompilerIf #PB_Compiler_OS = #PB_OS_Linux
          RunProgram("firefox","http://www.RocketRider.eu","")
        CompilerElse
          RunProgram("http://www.RocketRider.eu")
        CompilerEndIf     
          
      Case #Menu_Homepage  
        CompilerIf #PB_Compiler_OS = #PB_OS_Linux
          RunProgram("firefox","http://living-code.RRSoftware.de","")
        CompilerElse
          RunProgram("http://living-code.RRSoftware.de")
        CompilerEndIf
        
      Case #Menu_SearchUpdate
        TestNewVersion(#True)
        
      Case #Menu_About
        OpenAbout()
        
      Case #Menu_OwnCreature
        Cells = Val(InputRequester(ReadPreferenceString_(languagefile, "text", "Own-Creature"),ReadPreferenceString_(languagefile, "text", "How-many-Cells-du-you-want"),"5"))
        If Cells<2
          Cells = 2
        EndIf       
        If Cells>#MAX_CELLS
          Cells = #MAX_CELLS
        EndIf
        CreateCreature_Window(Cells)
        
      Case #Menu_InsertCreatures
        OpenInsertCreates()
        
      Case #Menu_Random_Creature
        Cells = Val(InputRequester(ReadPreferenceString_(languagefile, "text", "Random-Creature"),ReadPreferenceString_(languagefile, "text", "How-many-Cells-du-you-want"),Str(Random(#MAX_CELLS-2)+2)))
        If Cells<2
          Cells = 2
        EndIf       
        If Cells>#MAX_CELLS
          Cells = #MAX_CELLS
        EndIf
        CreateCreature_Window(Cells)
        SetRandomCreature(Cells)
      
      Case #Menu_Creature_Generator
        OpenCreatureGenerator()
      
      Case #Menu_Download_Insert
        If TestInternet()
          TestNewVersion(#False)
          CompilerIf #PB_Compiler_OS = #PB_OS_Linux

            RunProgram("firefox",UPLOAD_URL.s + UPLOAD_PAGEVIEW.s,"")
          CompilerElse
            
            If ShowHtmlDialogURL(0,UPLOAD_URL.s + "Viewpage.php?DialogForm=YES",640,480)
              Erg$=GetHtmlDialogResult()
              If Erg$

                
                File.s=GetURLPart(Erg$, "File")

                If ReceiveHTTPFile(URLEncoder(UPLOAD_URL.s + File), GetTemporaryDirectory()+GetFilePart(File))
                  File.s = GetFilePart(File)

                  Author.s = TestUploadString(GetCreatureAuthor_FromFile(GetTemporaryDirectory()+File),1)
                  If Author="":Author="NoName":EndIf
                  If Author
                    CompilerIf #PB_Compiler_OS = #PB_OS_Linux
                      If FileSize("Insert/Downloaded/"+Author)<>-2
                        CreateDirectory("Insert/Downloaded/"+Author)
                      EndIf
                      RenameFile(GetTemporaryDirectory()+File, "Insert/Downloaded/"+Author+"/"+File)
                    CompilerElse
                      If FileSize("Insert\Downloaded\"+Author)<>-2
                        CreateDirectory("Insert\Downloaded\"+Author)
                      EndIf
                      RenameFile(GetTemporaryDirectory()+File, "Insert\Downloaded\"+Author+"\"+File)
                    CompilerEndIf
                    Buffer.s = Space(32)
                    DownloadToMem("Counter",URLEncoder(UPLOAD_URL.s + Erg$),@Buffer,32)
                
                    MessageRequester(ReadPreferenceString_(languagefile, "text", "Download Successful"),ReadPreferenceString_(languagefile, "text", "find-downloaded-creature")+" Insert\Downloaded.")
                  Else
                    MessageRequester(ReadPreferenceString_(languagefile, "text", "Error"),ReadPreferenceString_(languagefile, "text", "File-is-corrupt")+#LF$+ReadPreferenceString_(languagefile, "text", "Please-tell-this-the-Author")+"(E-Mail@RocketRider.eu)")
                  EndIf
                Else
                  MessageRequester(ReadPreferenceString_(languagefile, "text", "Error"),ReadPreferenceString_(languagefile, "text", "File-not-found")+#LF$+ReadPreferenceString_(languagefile, "text", "Please-tell-this-the-Author")+"(E-Mail@RocketRider.eu)")
                EndIf
              EndIf
            EndIf
          CompilerEndIf
        EndIf
        
      Case #Menu_ADDFOOD
        NumFood=Val(InputRequester(ReadPreferenceString_(languagefile, "text", "ADD-Food"),ReadPreferenceString_(languagefile, "text", "How-many-Food-do-you-want"),"1500"))
        If NumFood>10000:NumFood=10000:EndIf
        For i=1 To NumFood
          AddFood(Random(#AREA_WIDTH),Random(#AREA_HEIGHT),GlobalVar\OBJECT_FOOD_DEFAULT_SIZE)
        Next
        
      Case #Menu_ADDVIEREN
        NumVieren=Val(InputRequester(ReadPreferenceString_(languagefile, "text", "ADD-Viruses"),ReadPreferenceString_(languagefile, "text", "How-many-Viruses-do-you-want"),"750"))
        If NumVieren>10000:NumVieren=10000:EndIf
        For i=1 To NumVieren  
          *obj.OBJECT = AddObject()
          If *obj<>0
            *obj\Type = #OBJECT_VIRUS
            *obj\CreatureID = 0
            *obj\CellID = 0
            *obj\Angle = Random(3600)/3600 * 2 * #PI
            *obj\Speed = Random(1000)/1000 * GlobalVar\OBJECT_VIRUS_MAXSPEED
            *obj\X = Random(#AREA_WIDTH)
            *obj\Y = Random(#AREA_HEIGHT)
            *obj\MinEnergy = Random(3000)
            *obj\DNAPosition = Random(#CODE_SIZE-1)
            *obj\LifeTime = Random(GlobalVar\OBJECT_VIRUS_LIFETIME)  
          EndIf  
        Next
        
      Case #Menu_Creature_Edit
        If  oldabs <> -1
          If Creatures(SchowCreatureIndex)\Used  
            LoadCreateCreatureSettings_fromCreature(Creatures(SchowCreatureIndex))
          EndIf
        EndIf
        
      Case #Menu_Creature_Delete
        If  oldabs <> -1
          If Creatures(SchowCreatureIndex)\Used And Creatures(SchowCreatureIndex)\MagicCreature <> 'XRIP'
            Creatures(SchowCreatureIndex)\Used = #False
          EndIf
        Else  
          oldabs = -1
        EndIf  
        
      Case #Menu_Creature_Kill
        If  oldabs <> -1
          If Creatures(SchowCreatureIndex)\Used And Creatures(SchowCreatureIndex)\MagicCreature <> 'XRIP'
            i=SchowCreatureIndex
            X.f = Creatures(i)\X
            Y.f = Creatures(i)\Y    
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
        Else  
          oldabs = -1
        EndIf  
      
      Case #Menu_Creature_KillAll
        For i=0 To Creatures_MaxCount
          If Creatures(i)\Used And Creatures(i)\MagicCreature <> 'XRIP'
            X.f = Creatures(i)\X
            Y.f = Creatures(i)\Y    
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
        Next
      
      Case #Menu_Creature_DeleteAll
        For i=0 To Creatures_MaxCount
          If Creatures(i)\MagicCreature <> 'XRIP'
            Creatures(i)\Used = #False
          EndIf
        Next  
        
      Case #Menu_Modus_EvolutionMode
        If ChangeGlobalVar()
          SetGlobalVar_EvolutionMode()
        EndIf
        
      Case #Menu_Modus_GamingMode
        If ChangeGlobalVar()
          SetGlobalVar_GamingMode()
        EndIf
          
      Case #Menu_Language_English  
        If languagefile.s <> "Data/english.txt"
          languagefile.s = "Data/english.txt"
          Restart()
        EndIf

      Case #Menu_Language_German 
        If languagefile.s <> "Data/german.txt"
          languagefile.s = "Data/german.txt"
          Restart()
        EndIf
      Case #Menu_Language_Franz
        If languagefile.s <> "Data/franz.txt"
          languagefile.s = "Data/franz.txt"
          Restart()
        EndIf
        
                  
    EndSelect
    For i=0 To MaxInsert
      If Menu = InsertCreature(i)\id
        LoadCreateCreatureSettings_FromFile(InsertCreature(i)\File)
      EndIf
    Next
  EndIf
  
  If Event = #PB_Event_Gadget
    GadgetID = EventGadget()
    Select GadgetID
      Case #View3D
        If View3D = #False
          Open3DView()
          SetGadgetText(#View3D,ReadPreferenceString_(languagefile, "text", "Stop-3D-View"))
        Else
          Close3DView()
          SetGadgetText(#View3D,ReadPreferenceString_(languagefile, "text", "3D-View"))
        EndIf
        
      Case #CheckBox_FOOD
        GadGet\state\FOOD = GetGadgetState(#CheckBox_FOOD)
      Case #CheckBox_VIRUS
        GadGet\state\VIRUS = GetGadgetState(#CheckBox_VIRUS)
      Case #CheckBox_DNA
        GadGet\state\DNA = GetGadgetState(#CheckBox_DNA)
      Case #CheckBox_POISON
        GadGet\state\POISON = GetGadgetState(#CheckBox_POISON)
      Case #CheckBox_MSG
        GadGet\state\msg = GetGadgetState(#CheckBox_MSG)
      Case #CheckBox_REST
        GadGet\state\REST = GetGadgetState(#CheckBox_REST)
      Case #CheckBox_Creature
        GadGet\state\Creature = GetGadgetState(#CheckBox_Creature)
      Case #CheckBox_Break
        GadGet\state\Break_Game = GetGadgetState(#CheckBox_Break)
        Worker_Pause(GadGet\state\Break_Game)
      Case #Track_ObjTrans
        GlobalVar\Object_Trans = GetGadgetState(#Track_ObjTrans)
      Case #Ticks  
        GlobalVar\ExecuteCount=Val(GetGadgetText(#Ticks))
      Case #CheckBox_Reducecpuusage
        GlobalVar\Reducecpuusage=GetGadgetState(#CheckBox_Reducecpuusage)        
      Case #Background
        HideAllwindows(#True)
      Case #MinimalCreatures
        GlobalVar\MinimalCreatures = GetGadgetState(#MinimalCreatures)
      Case #Option_MultiCore
        If UseMultiCore=#False
          SingelCore=0
          If GetGadgetState(#Option_MultiCore)=#True
            msg.s =ReadPreferenceString_(languagefile, "text", "Multicore-slower-Singelcore")+#LF$
            msg + ReadPreferenceString_(languagefile, "text", "It-can-induce-crashes")+#LF$
            msg + ReadPreferenceString_(languagefile, "text", "Do-you-want-to-enable-it")+#LF$
            If MessageRequester(ReadPreferenceString_(languagefile, "text", "Do-you-want-to-use-Multicore"),msg,#PB_MessageRequester_YesNo)=#PB_MessageRequester_Yes 
              Restart()
            Else 
              SetGadgetState(#Option_MultiCore,#False)
              SetGadgetState(#Option_SingleCore,#True)
            EndIf
          EndIf
        EndIf  
      Case #Option_SingleCore  
        If UseMultiCore=#True
          Restart()   
        EndIf  
      Case #Threads
        
        If GetGadgetState(#Option_MultiCore)=#True
          If MessageRequester(ReadPreferenceString_(languagefile, "text", "This-option-needs-a-restart"), ReadPreferenceString_(languagefile, "text", "This-option-needs-a-restart")+", "+ReadPreferenceString_(languagefile, "text", "do-you-want-To-restart"),#PB_MessageRequester_YesNo)=#PB_MessageRequester_Yes 
            WORKER_COUNT = GetGadgetState(#Threads)
            WORKER_COUNT_TEMP = WORKER_COUNT
            Restart()
          Else
            WORKER_COUNT_TEMP = GetGadgetState(#Threads)
          EndIf
        Else  
          WORKER_COUNT = GetGadgetState(#Threads)
          WORKER_COUNT_TEMP = WORKER_COUNT
        EndIf  
      Case #CheckBox_Sounds
        GlobalSoundOn = GetGadgetState(#CheckBox_Sounds)
      Case #Option_RightM_FOOD
        If GetGadgetState(#Option_RightM_FOOD) = #True:RightMButton=#OBJECT_FOOD:EndIf
        If GetGadgetState(#Option_RightM_VIRUSES) = #True:RightMButton=#OBJECT_VIRUS:EndIf
        If GetGadgetState(#Option_RightM_DNA) = #True:RightMButton=#OBJECT_DNA:EndIf
        If GetGadgetState(#Option_RightM_POISON) = #True:RightMButton=#OBJECT_POISON:EndIf
        If GetGadgetState(#Option_RightM_Delete) = #True:RightMButton=#OBJECT_MSG:EndIf
      Case #Option_RightM_VIRUSES
        If GetGadgetState(#Option_RightM_FOOD) = #True:RightMButton=#OBJECT_FOOD:EndIf
        If GetGadgetState(#Option_RightM_VIRUSES) = #True:RightMButton=#OBJECT_VIRUS:EndIf
        If GetGadgetState(#Option_RightM_DNA) = #True:RightMButton=#OBJECT_DNA:EndIf
        If GetGadgetState(#Option_RightM_POISON) = #True:RightMButton=#OBJECT_POISON:EndIf
        If GetGadgetState(#Option_RightM_Delete) = #True:RightMButton=#OBJECT_MSG:EndIf
      Case #Option_RightM_DNA 
        If GetGadgetState(#Option_RightM_FOOD) = #True:RightMButton=#OBJECT_FOOD:EndIf
        If GetGadgetState(#Option_RightM_VIRUSES) = #True:RightMButton=#OBJECT_VIRUS:EndIf
        If GetGadgetState(#Option_RightM_DNA) = #True:RightMButton=#OBJECT_DNA:EndIf
        If GetGadgetState(#Option_RightM_POISON) = #True:RightMButton=#OBJECT_POISON:EndIf
        If GetGadgetState(#Option_RightM_Delete) = #True:RightMButton=#OBJECT_MSG:EndIf
      Case #Option_RightM_POISON
        If GetGadgetState(#Option_RightM_FOOD) = #True:RightMButton=#OBJECT_FOOD:EndIf
        If GetGadgetState(#Option_RightM_VIRUSES) = #True:RightMButton=#OBJECT_VIRUS:EndIf
        If GetGadgetState(#Option_RightM_DNA) = #True:RightMButton=#OBJECT_DNA:EndIf
        If GetGadgetState(#Option_RightM_POISON) = #True:RightMButton=#OBJECT_POISON:EndIf
        If GetGadgetState(#Option_RightM_Delete) = #True:RightMButton=#OBJECT_MSG:EndIf
      Case #Option_RightM_Delete
        If GetGadgetState(#Option_RightM_FOOD) = #True:RightMButton=#OBJECT_FOOD:EndIf
        If GetGadgetState(#Option_RightM_VIRUSES) = #True:RightMButton=#OBJECT_VIRUS:EndIf
        If GetGadgetState(#Option_RightM_DNA) = #True:RightMButton=#OBJECT_DNA:EndIf
        If GetGadgetState(#Option_RightM_POISON) = #True:RightMButton=#OBJECT_POISON:EndIf
        If GetGadgetState(#Option_RightM_Delete) = #True:RightMButton=#OBJECT_MSG:EndIf
      Case #Track_Mutation
        GlobalVar\MUTATION_PROBABILITY = GetGadgetState(#Track_Mutation)
    EndSelect    
  EndIf
  
  
  If Event = #PB_Event_SysTray
    If EventType() = #PB_EventType_LeftDoubleClick
      If EventGadget()=0
        HideAllwindows(#False)
      EndIf
    EndIf
  EndIf
  
  If Event = #PB_Event_GadgetDrop
      Select EventGadget()

        Case #Pannel
          File$ = EventDropFiles()
           If File$<>""
            If FindString(UCase(File$),".LCF",1)
              _loadscene(File$)
            EndIf
            If FindString(UCase(File$),".CRF",1)
              LoadCreateCreatureSettings_FromFile(File$)
            EndIf
            
          EndIf
          
      EndSelect
    
    EndIf
  
  
  
EndProcedure
Procedure Events_CreateCreature(Event)
  If Event=#PB_Event_SizeWindow
    WW=WindowWidth(#Window_CreateCreature)
    WH=WindowHeight(#Window_CreateCreature)

    CompilerIf #PB_Compiler_OS = #PB_OS_Linux
      SubGadgets=20
      WH-5
    CompilerElse
      SubGadgets=0
    CompilerEndIf
    ResizeGadget(#CreateCreature_Load,5,WH-25-SubGadgets,70,20)
    ResizeGadget(#CreateCreature_Save,80,WH-25-SubGadgets,70,20)
    ResizeGadget(#CreateCreature_Cancel,WW-180,WH-25-SubGadgets,70,20)
    ResizeGadget(#CreateCreature_Compile,WW-100,WH-25-SubGadgets,40,20)
    ResizeGadget(#CreateCreature_Change,WW-55,WH-25-SubGadgets,50,20)
    ResizeGadget(#CreateCreature_Tab,5,25-SubGadgets,WW-10,WH-55)  
    ResizeGadget(#CreateCreature_Preview_Area,150,5,WW-170,WH-90)
    
    ResizeGadget(#CreateCreature_Setting_Container,(WW-400)/2,(WH-420)/2,#PB_Ignore,#PB_Ignore)
    
    For cell=0 To CountGadgetItems(#CreateCreature_Tab)-3
      ResizeGadget(GadGet\Creature[cell]\CodeEditor,#PB_Ignore,#PB_Ignore,WW-130,WH-110)
      ResizeGadget(GadGet\Creature[cell]\CodeLine,WW-86,#PB_Ignore,#PB_Ignore,#PB_Ignore)
      ResizeGadget(GadGet\Creature[cell]\CellIDText,WW-120,#PB_Ignore,#PB_Ignore,#PB_Ignore)
      ResizeGadget(GadGet\Creature[cell]\CellIDStr,WW-120,#PB_Ignore,#PB_Ignore,#PB_Ignore)
      ResizeGadget(GadGet\Creature[cell]\CellRandiusText,WW-120,#PB_Ignore,#PB_Ignore,#PB_Ignore)
      ResizeGadget(GadGet\Creature[cell]\CellRandiusStr,WW-120,#PB_Ignore,#PB_Ignore,#PB_Ignore)
      ResizeGadget(GadGet\Creature[cell]\CellOrgRandiusText,WW-120,#PB_Ignore,#PB_Ignore,#PB_Ignore)
      ResizeGadget(GadGet\Creature[cell]\CellOrgRandiusStr,WW-120,#PB_Ignore,#PB_Ignore,#PB_Ignore)
      ResizeGadget(GadGet\Creature[cell]\CellCodePositionText,WW-120,#PB_Ignore,#PB_Ignore,#PB_Ignore)
      ResizeGadget(GadGet\Creature[cell]\CellCodePositionStr,WW-120,#PB_Ignore,#PB_Ignore,#PB_Ignore)
      ResizeGadget(GadGet\Creature[cell]\ExportCode,WW-120,#PB_Ignore,#PB_Ignore,#PB_Ignore)
      ResizeGadget(GadGet\Creature[cell]\ImportCode,WW-120,#PB_Ignore,#PB_Ignore,#PB_Ignore)
      ResizeGadget(GadGet\Creature[cell]\SetCode,WW-120,#PB_Ignore,#PB_Ignore,#PB_Ignore)
    Next
  EndIf



  If Event = #PB_Event_CloseWindow
    CloseCreateCreature()
  EndIf
    
   If OldClacLineCounter>5
     OldClacLineCounter=0
     If IsWindow(#Window_CreateCreature)
       CodeTab=GetGadgetState(#CreateCreature_Tab)-1
       If CodeTab>=0 And CodeTab<CountGadgetItems(#CreateCreature_Tab)-2
         ;Debug "111"+Str(Random(322))
         line=CalcLine(CodeTab)
         If line>=0
          SetGadgetText(GadGet\Creature[CodeTab]\CodeLine,ReadPreferenceString_(languagefile, "text", "Line")+": "+Str(line))
         EndIf
       EndIf
     EndIf
   Else
    OldClacLineCounter+1
   EndIf


  CompilerIf #PB_Compiler_OS = #PB_OS_Linux
    If Event=8
      Pannel = GetGadgetState(#CreateCreature_Tab)
      If Pannel<>0 And Pannel<CountGadgetItems(#CreateCreature_Tab)-1
       DisplayPopupMenu(2, WindowID(#Window_CreateCreature))
      EndIf
  EndIf
  CompilerElse
  If Event=516;#WM_RBUTTONDOWN 
    Pannel = GetGadgetState(#CreateCreature_Tab)
    ;If GetActiveGadget() = GadGet\Creature[Pannel-1]\CodeEditor
      If Pannel<>0 And Pannel<CountGadgetItems(#CreateCreature_Tab)-1
       DisplayPopupMenu(2, WindowID(#Window_CreateCreature))
      EndIf
    ;EndIf
  EndIf
  
 CompilerEndIf
  
  If Event=513
      For cell = 0 To CreatureCellCount-1
        ;pos = ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_GETCURRENTPOS)  
        ;line = ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_LINEFROMPOSITION,pos) 
        line = CalcLine(cell)
        If line>=0
        SetGadgetText(GadGet\Creature[cell]\CodeLine,ReadPreferenceString_(languagefile, "text", "Line")+": "+Str(line))
        EndIf
      Next
      
  EndIf
  
  
  If Event = #PB_Event_Menu
    EventMenu = EventMenu()
    Select EventMenu
      Case #ToolBar_Move
        OpenCCMoveWindow()
      Case #ToolBar_Rotate
        OpenCCRotateWindow()
      Case #ToolBar_IF
        OpenCCIFWindow() 
      Case #ToolBar_Attack
        OpenCCAttackWindow() 
      Case #ToolBar_Clone 
        OpenCCCloneWindow()
      Case #Menu_Cut  
        ScintillaSendMessage(GadGet\Creature[GetGadgetState(#CreateCreature_Tab)-1]\CodeEditor, #SCI_CUT)
      Case #Menu_Copy
        ScintillaSendMessage(GadGet\Creature[GetGadgetState(#CreateCreature_Tab)-1]\CodeEditor, #SCI_COPY)
      Case #Menu_Paste
        ScintillaSendMessage(GadGet\Creature[GetGadgetState(#CreateCreature_Tab)-1]\CodeEditor, #SCI_PASTE)
      Case #Menu_SelectAll
        ScintillaSendMessage(GadGet\Creature[GetGadgetState(#CreateCreature_Tab)-1]\CodeEditor, #SCI_SELECTALL)
      Case #Menu_Undo      
        ScintillaSendMessage(GadGet\Creature[GetGadgetState(#CreateCreature_Tab)-1]\CodeEditor, #SCI_UNDO)
      Case #Menu_Redo 
        ScintillaSendMessage(GadGet\Creature[GetGadgetState(#CreateCreature_Tab)-1]\CodeEditor, #SCI_REDO)
        
    EndSelect
    
    If EventMenu>#ToolBar_Rotate
      InsText.s = GetMenuItemText(2, EventMenu)
      Pannel=GetGadgetState(#CreateCreature_Tab)
      If Pannel>0
        Pos = ScintillaSendMessage(GadGet\Creature[Pannel-1]\CodeEditor, #SCI_GETCURRENTPOS)  
        ScintillaSendMessage(GadGet\Creature[Pannel-1]\CodeEditor, #SCI_INSERTTEXT,Pos,@InsText)
        ScintillaSendMessage(GadGet\Creature[Pannel-1]\CodeEditor, #SCI_SETSEL,Pos+Len(InsText),Pos+Len(InsText))  
      EndIf
    EndIf
    
    
  EndIf
  
  
  If Event = #PB_Event_Gadget
    GadgetID = EventGadget()
    CheckPreviewStatus(GadgetID)
    Select GadgetID
      Case #CreateCreature_ColorEdit
        SetGadgetColor(#CreateCreature_ColorShow,#PB_Gadget_BackColor,ColorRequester(GetGadgetColor(#CreateCreature_ColorShow,#PB_Gadget_BackColor)))
      Case #CreateCreature_Load   
        LoadCreateCreatureSettings()
      Case #CreateCreature_Save
        SaveCreateCreatureSettings()
      Case #CreateCreature_Cancel
        CloseCreateCreature()
      Case #CreateCreature_Compile
        *Creature.CREATURE = AddCreature()
        CopyMemory(*CreatureW,*Creature,SizeOf(CREATURE))
        MakeCreature(*Creature)
        CloseCreateCreature()
      Case #CreateCreature_Change
        MakeCreature(*OrgCreature)
        CloseCreateCreature()
      Case #CreateCreature_Tab
        State=GetGadgetState(#CreateCreature_Tab)
        If State=0 Or GetGadgetState(#CreateCreature_Tab)=CountGadgetItems(#CreateCreature_Tab)-1
          DisableToolBar(#True)  
        Else
          HighlightCell(State-1)
          DisableToolBar(#False)
        EndIf
      Case #CreateCreature_Info
        Text.s = ""
        For cell = 0 To CreatureCellCount-1
          ;Text.s + GetGadgetText(GadGet\Creature[cell]\CodeEditor)
          len=ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_GETLENGTH)+1
          Text2.s=Space(len)
          ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_GETTEXT,len,@Text2)
          Text+Text2
        Next
        GetCreatureFeatures(Text)
      Case #CreateCreature_Upload
        If GetGadgetText(#CreateCreature_CreatureAuthorStr)="RocketRider" Or GetGadgetText(#CreateCreature_CreatureAuthorStr)="Mr. X"
          MessageRequester(ReadPreferenceString_(languagefile, "text", "Error"),ReadPreferenceString_(languagefile, "text", "File-Can-not-uploaded"))
        Else
          OpenUploadWindow()
        EndIf
      Case #CreateCreature_Preview_Scale_Button
        
        For cell=0 To CreatureCellCount-1
          multi.f = ValF(GetGadgetText(#CreateCreature_Preview_Scale_Str))         
          
          
          rad = Val(GetGadgetText(CC_Preview(cell)\Radius_Str))
          rad *  multi   
          If rad>GlobalVar\CREATURE_MAXRADIUS
            rad=GlobalVar\CREATURE_MAXRADIUS
          EndIf
          If rad<GlobalVar\CREATURE_MINRADIUS
            rad=GlobalVar\CREATURE_MINRADIUS
          EndIf
          SetGadgetText(CC_Preview(cell)\Radius_Str,Str(rad)) 
          
          rad = Val(GetGadgetText(CC_Preview(cell)\OrgRadius_Str))
          rad *  multi   
          If rad>GlobalVar\CREATURE_MAXRADIUS
            rad=GlobalVar\CREATURE_MAXRADIUS
          EndIf
          If rad<GlobalVar\CREATURE_MINRADIUS
            rad=GlobalVar\CREATURE_MINRADIUS
          EndIf
          SetGadgetText(CC_Preview(cell)\OrgRadius_Str,Str(rad)) 
          
        Next
        
        
      Case #CreateCreature_Preview_OrgRadius_Button
        For cell=0 To CreatureCellCount-1
          SetGadgetText(CC_Preview(cell)\OrgRadius_Str,Str(Val(GetGadgetText(CC_Preview(cell)\Radius_Str))))
        Next
        
      Case #CreateCreature_Preview_RndRadius_Button
        GenerateCForm()
        
    EndSelect
    For cell = 0 To CreatureCellCount-1
      
      If GadgetID = GadGet\Creature[cell]\CodeEditor
        ;pos = ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_GETCURRENTPOS)  
        ;line = ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_LINEFROMPOSITION,pos) 
        line =CalcLine(cell)
        If line>=0
        SetGadgetText(GadGet\Creature[cell]\CodeLine,ReadPreferenceString_(languagefile, "text", "Line")+": "+Str(line))
        EndIf
      EndIf
      
      If GadgetID = GadGet\Creature[cell]\ExportCode
        
        File.s = SaveFileRequester(ReadPreferenceString_(languagefile, "text", "Save-Cell-Fragment"),"",CellPattern,1)
        If FindString(GetFilePart(File),".",1) = #False
          File + ".CEF"
        EndIf
        If File And File <> ".CEF"
          If CreateFile(1,File)
            len=ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_GETLENGTH)+1
            Text.s=Space(len)
            ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_GETTEXT,len,@Text)
            WriteString(1,Text)
            CloseFile(1)
          Else
            MessageRequester(ReadPreferenceString_(languagefile, "text", "Error"),ReadPreferenceString_(languagefile, "text", "Can-not-save-File"))
          EndIf
        EndIf
        
        
      EndIf
      
      If GadgetID = GadGet\Creature[cell]\ImportCode
        
        File.s = OpenFileRequester("Open Cell Fragment","",CellPattern,1)
        If File
          If ReadFile(1,File)
            Text.s = ""
            While Eof(1) = 0         
              Text.s + ReadString(1) + #CRLF$   
            Wend
            ;SetGadgetText(GadGet\Creature[cell]\CodeEditor,Text)
            ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_SETTEXT,0,@Text)
            CloseFile(1)
            
          Else
            MessageRequester(ReadPreferenceString_(languagefile, "text", "Error"),ReadPreferenceString_(languagefile, "text", "Can-not-save-File"))
          EndIf
        EndIf
        
        
      EndIf
      
      If GadgetID = GadGet\Creature[cell]\SetCode
        len=ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_GETLENGTH)+1
        Text.s=Space(len)
        ScintillaSendMessage(GadGet\Creature[cell]\CodeEditor, #SCI_GETTEXT,len,@Text)
        
        ;Debug Text
        num = Val(GetGadgetText(#CreateCreature_CellsStr))-1
        For i=0 To num
          ScintillaSendMessage(GadGet\Creature[i]\CodeEditor, #SCI_SETTEXT,0,@Text)
        Next
      EndIf
      
    Next
    
  EndIf
  
EndProcedure
Procedure Events_About(Event)
  If Event = #PB_Event_CloseWindow
    CloseWindow(#Window_About)
  EndIf   
  
  
  If Event = #PB_Event_Gadget
    GadgetID = EventGadget()
    Select GadgetID
      Case #About_OK
        CloseWindow(#Window_About)
    EndSelect
    
  EndIf
  
EndProcedure
Procedure Events_Options(Event)
  If Event = #PB_Event_CloseWindow
    CloseWindow(#Window_Options)
  EndIf    
  
  
  If Event = #PB_Event_Gadget
    GadgetID = EventGadget()
    Select GadgetID
      Case #Options_OK  
        GlobalVarChanged = #True
        SetADDOptionsBoxSettings()
        CloseWindow(#Window_Options)
      Case #Options_Cancel 
        CloseWindow(#Window_Options)
      Case #Options_Standard 
        CloseWindow(#Window_Options)
        SetGlobalVar_GamingMode()
        ;OpenOptions()
    EndSelect
  EndIf
  
EndProcedure
Procedure EventManager(Event)
  Select EventWindow() 
    Case #Window_Main
      ProcedureReturn Events_Main(Event)
    Case #Window_CreateCreature
      Events_CreateCreature(Event)
    Case #Window_About
      Events_About(Event)
    Case #Window_Options
      Events_Options(Event)
    Case #Window_CC_Move
      Events_CC_Move(Event)
    Case #Window_CC_Rotate
      Events_CC_Rotate(Event)
    Case #Window_CC_IF  
      Events_CC_IF(Event)
    Case #Window_CC_Attack 
      Events_CC_Attack(Event)
    Case #Window_CC_Clone  
      Events_CC_Clone(Event)
    Case #Window_Upload  
      Events_UploadWindow(Event)
    Case #Window_ManualDownload   
      Events_ManualDownload(Event)
    Case #Window_InsertCreates
      Events_InsertCreates(Event)
    Case #Window_Creature_Generator
      Events_CreatureGenerator(Event)
    Case #Window_Report
      Events_Report(Event)
    
  EndSelect
  ProcedureReturn #False  
EndProcedure


; IDE Options = PureBasic 4.30 Beta 4 (Linux - x86)
; Folding = AAAAAAAAAAAAAIAAw
; EnableXP
; SubSystem = Open GL
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant
Structure Prefs
Group.s
KeyName.s
Value.s
NewValue.s
File.s
EndStructure
Global NewList Pref.Prefs()


Procedure OpenPreferences_(File.s)
  ForEach Pref()
  If Pref()\File=UCase(File)
  ProcedureReturn 0
  EndIf
  Next
  
  If OpenPreferences(File)
  
  ExaminePreferenceGroups()
  While NextPreferenceGroup()<>0
    ExaminePreferenceKeys()
    While NextPreferenceKey()<>0
    
      ForEach Pref()     
        If Pref()\File=UCase(File)
          If Pref()\Group=UCase(PreferenceGroupName())
            If Pref()\KeyName=UCase(PreferenceKeyName())
              Debug File+"["+UCase(PreferenceGroupName())+"\"+UCase(PreferenceKeyName())+"] 2x"
            EndIf
          EndIf
        EndIf
      Next
    
    
    
      AddElement(Pref())
      Pref()\File = UCase(File)
      Pref()\Group = UCase(PreferenceGroupName())
      Pref()\KeyName = UCase(PreferenceKeyName())
      Pref()\Value = PreferenceKeyValue()
      Pref()\Value = ReplaceString(Pref()\Value,"{%NEWLINE%}",#CRLF$)
      ;Debug Pref()\KeyName
    Wend
    
  Wend
  ClosePreferences()
  Else
  Debug File +" can not opened"
  EndIf
  
EndProcedure
Procedure.f ReadPreferenceFloat_(File.s,Group.s,Keyword.s)
  ForEach Pref()     
    
    If Pref()\File=UCase(File)
      If Pref()\Group=UCase(Group)
        If Pref()\KeyName=UCase(Keyword)
          
          ProcedureReturn ValF(Pref()\Value)
          
        EndIf
      EndIf
    EndIf
    
  Next
  Debug File+"["+Group+"\"+Keyword+"] not found"
EndProcedure
Procedure.l ReadPreferenceLong_(File.s,Group.s,Keyword.s)
  ForEach Pref()     
    
    If Pref()\File=UCase(File)
      If Pref()\Group=UCase(Group)
        If Pref()\KeyName=UCase(Keyword)
          
          ProcedureReturn Val(Pref()\Value)
          
        EndIf
      EndIf
    EndIf
    
  Next
  Debug File+"["+Group+"\"+Keyword+"] not found"
EndProcedure
Procedure.s ReadPreferenceString_(File.s,Group.s,Keyword.s)
  ForEach Pref()     
    
    If Pref()\File=UCase(File)
      If Pref()\Group=UCase(Group)
        If Pref()\KeyName=UCase(Keyword)
          
          ProcedureReturn Pref()\Value
          
        EndIf
      EndIf
    EndIf
    
  Next
Debug File+"["+Group+"\"+Keyword+"] not found"
EndProcedure
Procedure.f WritePreferenceFloat_(File.s,Group.s,Keyword.s,Value.f)
  ForEach Pref()     
    
    If Pref()\File=UCase(File)
      If Pref()\Group=UCase(Group)
        If Pref()\KeyName=UCase(Keyword)
          
          Pref()\NewValue=StrF(Value)
          ProcedureReturn Value
        EndIf
      EndIf
    EndIf
    
  Next
Debug File+"["+Group+"\"+Keyword+"] not found"
EndProcedure
Procedure.l WritePreferenceLong_(File.s,Group.s,Keyword.s,Value.l)
  ForEach Pref()     
    
    If Pref()\File=UCase(File)
      If Pref()\Group=UCase(Group)
        If Pref()\KeyName=UCase(Keyword)
          
          Pref()\NewValue=Str(Value)
          ProcedureReturn Value
        EndIf
      EndIf
    EndIf
    
  Next
Debug File+"["+Group+"\"+Keyword+"] not found"
EndProcedure
Procedure.s WritePreferenceString_(File.s,Group.s,Keyword.s,Value.s)
  ForEach Pref()     
    
    If Pref()\File=UCase(File)
      If Pref()\Group=UCase(Group)
        If Pref()\KeyName=UCase(Keyword)
          Value = ReplaceString(Value,#CRLF$,"{%NEWLINE%}")
          Value = ReplaceString(Value,#LFCR$,"{%NEWLINE%}")
          Value = ReplaceString(Value,#LF$,"{%NEWLINE%}")
          Value = ReplaceString(Value,#CR$,"{%NEWLINE%}")          
          Pref()\NewValue=Value
          ProcedureReturn Value
        EndIf
      EndIf
    EndIf
    
  Next
Debug File+"["+Group+"\"+Keyword+"] not found"
EndProcedure
Procedure ClosePreferences_()
  ForEach Pref()     
    If Pref()\NewValue<>""
      OpenPreferences(Pref()\File)
      PreferenceGroup(Pref()\Group)
      WritePreferenceString(Pref()\KeyName,Pref()\NewValue)
      ClosePreferences()
    EndIf
  Next
  ClearList(Pref())
EndProcedure

; IDE Options = PureBasic 4.30 Beta 4 (Windows - x86)
; CursorPosition = 28
; FirstLine = 6
; Folding = J9
; EnableXP
; EnableCompileCount = 1
; EnableBuildCount = 0
; EnableExeConstant
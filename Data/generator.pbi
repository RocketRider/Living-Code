

#CODE_SIZE = 512


Procedure.s StrTrueFalse(bValue.i)
If bValue
  ProcedureReturn "TRUE"
Else
  ProcedureReturn "FALSE"
EndIf
EndProcedure

Procedure.s Generator_GetCopyModeStr(iCopyMode.i)
Select iCopyMode
Case 0
ProcedureReturn "none"
Case 1
ProcedureReturn "secure combine"
Case 2
ProcedureReturn "50:50"
Case 3
ProcedureReturn "75:25"
Case 4
ProcedureReturn "95:5"
Case 5
ProcedureReturn "combine"
EndSelect
EndProcedure

Procedure.s Generator_GetAttackModeStr(iAttackMode.i)
Select iAttackMode
Case 0
ProcedureReturn "none"
Case 1
ProcedureReturn "DNA"
Case 2
ProcedureReturn "absorb"
Case 3
ProcedureReturn "virus"
Case 4
ProcedureReturn "poison"
Case 5
ProcedureReturn "paralyse"
Case 6
ProcedureReturn "DNA + paralyse"
Case 7
ProcedureReturn "absorb + paralyse"
Case 8
ProcedureReturn "virus + paralyse"
Case 9
ProcedureReturn "poison + paralyse"
EndSelect
EndProcedure

Procedure.s Generator_GetDNAAttackModeStr(iDNAAttackMode.i)
Select iDNAAttackMode
Case 0
ProcedureReturn "absorb"
Case 1
ProcedureReturn "absorb + increase cell size"
Case 2
ProcedureReturn "emit food"
Case 3
ProcedureReturn "decrease cell size"
Case 4
ProcedureReturn "mutate"
Case 5
ProcedureReturn "emit food + decrease cell size"
Case 6
ProcedureReturn "emit food + stop timer"
EndSelect
EndProcedure

Structure GENERATOR_PARAMETER
  iRandom.i
  iCopyMinEnergy.i
  ;bUseSecurityZone.i
  ;bBlockFirstLineExecution.i
  iProtectionLevel.i ; 0 - 9  0 = no protection,  9 = very much protection
  iCopyMode.i ; 0=NONE, 1=SECURE COMBINE, 2=50:50, 3=75:25, 4=95:5, 5=COMBINE
  iAggressiveLevel.i ; 0 - 9 0 = Not aggressive, 9 = very aggressive
  iAttackMode.i ;0=None, 1=DNA, 2=Absorb, 3=Virus, 4=Poision, 5=Paralyse, 6=DNA + Paralyse, 7=Absorb + Paralyse, 8=Virus + Paralyse, 9=Poision + Paralyse
  iDNAAttackMode.i ; 0=Absorb, 1=Absorb + Inc cell size, 2=Emit Food, 3=Reduce cell size, 4=Mutate, 5=Emit Food + Reduce cell size, 6=Emit Food + Stop timer 
  iSpeed.i ; 0 - 9
  bRotateEnemyFast.i
  bOnlyBigCellsCanEmitPoison.i
  bEmitPoisonToEnemy.i
  Intern_iParalyse.i
  Intern_iPoison.i
  Intern_bUseParalyse.i
  Intern_bUsePoison.i
EndStructure
  
  
Global iGenerator_Line.i, sGenerator_Code.s, iGenerator_NrOfDNABlocks.i, iGenerator_DNABlockSize.i 
Procedure AddGeneratorCode(sLine.s = "", bNoCode.i = #False)
  sGenerator_Code + sLine + #LF$
  If bNoCode = #False And sLine <> ""
    iGenerator_Line + 1
  EndIf
  ProcedureReturn iGenerator_Line
EndProcedure

Procedure AddGeneratorCode_InsertDNA(*gp.GENERATOR_PARAMETER)
  If *gp\iAttackMode = 1 Or *gp\iAttackMode = 6 Or *gp\iAttackMode = 2 Or *gp\iAttackMode = 7
    
    AddGeneratorCode("@DNA_ATTACK_BLOCK" + Str(iGenerator_NrOfDNABlocks),#True)
    iGenerator_DNABlockSize = 1
    Select *gp\iDNAAttackMode
      Case 0
        AddGeneratorCode("ABSORBABLE_YES")
        iGenerator_DNABlockSize + 1 
      Case 1
        AddGeneratorCode("ABSORBABLE_YES")
        AddGeneratorCode("INC_CELL_RAD")
        iGenerator_DNABlockSize + 2 
      Case 2
        AddGeneratorCode("EATING_NO")
        AddGeneratorCode("EATING_EMIT")
        iGenerator_DNABlockSize + 2 
      Case 3
        AddGeneratorCode("DEC_CELL_RAD")
        iGenerator_DNABlockSize + 1
      Case 4
        AddGeneratorCode("MUTATE")
        iGenerator_DNABlockSize + 1
      Case 5
        AddGeneratorCode("DEC_CELL_RAD")
        AddGeneratorCode("EATING_EMIT")
        iGenerator_DNABlockSize + 2
      Case 6
        AddGeneratorCode("TIMER_NO")
        AddGeneratorCode("EATING_EMIT")
        iGenerator_DNABlockSize + 2
    EndSelect
    
    If *gp\iAggressiveLevel > 5
      iGenerator_DNABlockSize + 2
      AddGeneratorCode("POISON_DNABLOCK_SIZE "+Str(iGenerator_DNABlockSize))
      AddGeneratorCode("POISON_EMIT_DNABLOCK @DNA_ATTACK_BLOCK" + Str(iGenerator_NrOfDNABlocks))
    EndIf
    AddGeneratorCode("GOTO @DNA_ATTACK_BLOCK" + Str(iGenerator_NrOfDNABlocks))
    iGenerator_NrOfDNABlocks + 1
    
  EndIf
  
EndProcedure


Procedure.s GenerateCodeFromGenerator(*gp.GENERATOR_PARAMETER)
  iGenerator_Line.i = 0
  sGenerator_Code.s = ""
  iGenerator_NrOfDNABlocks.i = 0
  iGenerator_DNABlockSize.i = 0
  RandomSeed(*gp\iRandom) ; always generate the same creature
  
  *gp\Intern_iParalyse.i = Random(254)
  If *gp\Intern_iParalyse & 1
    *gp\Intern_iParalyse + 1
  EndIf
  
  *gp\Intern_iPoison.i = Random(254)
  If *gp\Intern_iPoison.i & 1 = 0
    *gp\Intern_iPoison + 1
  EndIf
  
  *gp\Intern_bUseParalyse.i = #False
  If *gp\iAttackMode >= 5
    *gp\Intern_bUseParalyse.i = #True
  EndIf
  
  *gp\Intern_bUsePoison.i = #False
  If *gp\iAttackMode =4 Or *gp\iAttackMode =9
    *gp\Intern_bUsePoison.i = #True
  EndIf
    
  AddGeneratorCode("; CREATED WITH CREATURE GENERATOR", #True)
  AddGeneratorCode("; ===============================", #True)
  AddGeneratorCode("; Random: "+Str(*gp\iRandom), #True)
  AddGeneratorCode("; CopyMinEnergy: "+Str(*gp\iCopyMinEnergy) , #True)
  AddGeneratorCode("; ProtectionLevel: "+Str(*gp\iProtectionLevel) + " / 9", #True)
  
  AddGeneratorCode("; CopyMode: "+Generator_GetCopyModeStr(*gp\iCopyMode), #True)
  AddGeneratorCode("; AggressiveLevel: "+Str(*gp\iAggressiveLevel) + " / 9", #True)
  
  AddGeneratorCode("; AttackMode: "+Generator_GetDNAAttackModeStr(*gp\iAttackMode), #True)
  AddGeneratorCode("; Speed: "+Str(*gp\iSpeed) + " / 9", #True)
  AddGeneratorCode("; Rotate Enemy fast: "+StrTrueFalse(*gp\bRotateEnemyFast), #True)
  AddGeneratorCode("; Only big cells can emit poison: "+StrTrueFalse(*gp\bOnlyBigCellsCanEmitPoison), #True)
  AddGeneratorCode("; Emit poison to direction of enemy: "+StrTrueFalse(*gp\bEmitPoisonToEnemy), #True)   
    
  
  AddGeneratorCode()
  AddGeneratorCode("@LINE_0", #True)
  If *gp\iProtectionLevel > 0
    Repeat
      AddGeneratorCode("GOTO @LINE_INITPROGRAM")
      If Random(10000) % 100 < *gp\iAggressiveLevel
        AddGeneratorCode_InsertDNA(*gp)
      EndIf
    Until iGenerator_Line > 25 + Random(250)
  EndIf
  
  AddGeneratorCode()  
  iInitLineNr = AddGeneratorCode("@LINE_INITPROGRAM", #True)
  AddGeneratorCode("EATING_YES")
  AddGeneratorCode("COPY_MIN_ENERGY " + Str(*gp\iCopyMinEnergy))
  
  If *gp\Intern_bUsePoison
    AddGeneratorCode("POISON_IMMUN1 " + Str(*gp\Intern_iPoison) + " ; Protect against our poison (for poison an odd number must be used number)")
  Else
    AddGeneratorCode("POISON_IMMUN1 " + Str(*gp\Intern_iPoison) + " ; Protect against our poison (NOT used for this creature) (for poison an odd number must be used number)")
  EndIf
  
  If *gp\Intern_bUseParalyse
    AddGeneratorCode("POISON_IMMUN2 " + Str(*gp\Intern_iParalyse) + " ; Protect against our paralyse (for paralyse an even number must be used number)")
  Else
    AddGeneratorCode("POISON_IMMUN2 " + Str(*gp\Intern_iParalyse) + " ; Protect against our paralyse (NOT used for this creature) (for paralyse an even number must be used number)")
  EndIf
  
  If *gp\iProtectionLevel > 0
    iVal.i = 61 + iInitLineNr << 8
    AddGeneratorCode("REPLACEMENT_CMD " + Str(61 + iInitLineNr << 8) + " ; "+Str( iVal ) + " means Goto @LINE_INITPROGRAM")
    AddGeneratorCode("BLOCKEXEC @LINE_0")
  EndIf
  
  If *gp\iProtectionLevel > 1
    
    If *gp\iProtectionLevel > 5
      AddGeneratorCode("TIMER_SET " +Str((#CODE_SIZE * 3) / 4))
    Else
      AddGeneratorCode("TIMER_SET " + Str(#CODE_SIZE))  
    EndIf
    AddGeneratorCode("TIMER_GOTO @LINE_SECURITYZONE")
    AddGeneratorCode()
    AddGeneratorCode("GOTO @LINE_SECURITYZONE_END ; jump over security zone")
    AddGeneratorCode("@LINE_SECURITYZONE",#True)
    AddGeneratorCode("; cell was manipulated with DNA, so we do only some simple things...", #True)  
    AddGeneratorCode("EATING_YES")
    If *gp\iAggressiveLevel > 7
      AddGeneratorCode("; As we are very aggressive, we now even try to destroy our enemy more than ever!", #True) 
      
      AddGeneratorCode("SEARCH_NEAREST_ENEMY")
      AddGeneratorCode("IF_CMP_ENEMY_GREATER 10000 ; Make sure it is not one of our own")
      AddGeneratorCode("IF_ENEMYABS_LESS "+Str(200))
      AddGeneratorCode("@LINE_REPEAT_MOVE_SECURITY",#True)
      AddGeneratorCode("ROTATE_ENEMY")  
      AddGeneratorCode("ROTATE_ENEMY")  
      AddGeneratorCode("MOVE_FORWARD2X")   
      AddGeneratorCode("MOVE_FORWARD2X")
      AddGeneratorCode("GOTO50 @LINE_REPEAT_MOVE_SECURITY")   
      AddGeneratorCode("GOTO50 @LINE_REPEAT_MOVE_SECURITY")      
      AddGeneratorCode("{REPLACE_ATTACK2}", #True)  
      AddGeneratorCode("ENDIF") 
      AddGeneratorCode("MOVE_FORWARD2X")   
      AddGeneratorCode("MOVE_FORWARD2X")  
      AddGeneratorCode("MOVE_FORWARD2X")
      AddGeneratorCode("MOVE_FORWARD2X") 
      AddGeneratorCode("ROTATE_FOOD")  
    Else
      AddGeneratorCode("ROTATE_FOOD")
      AddGeneratorCode("MOVE_FORWARD2X")
      AddGeneratorCode("MOVE_FORWARD2X")    
    EndIf
    
    AddGeneratorCode("GOTO @LINE_SECURITYZONE")  
    AddGeneratorCode("@LINE_SECURITYZONE_END", #True)  
    AddGeneratorCode()
  EndIf
  
  If *gp\iProtectionLevel > 2
    AddGeneratorCode("POISON_VIRUS_MIN_ENERGY 999999")
    AddGeneratorCode("POISON_NO")
  EndIf
  
  AddGeneratorCode()
  AddGeneratorCode("@LINE_BEGIN", #True)
  
  If *gp\iProtectionLevel = 9
    AddGeneratorCode("@LINE_SECURITY_BLOCK1", #True)
  EndIf
  
  If *gp\iProtectionLevel > 2
    AddGeneratorCode("ANTIVIRUS")
    AddGeneratorCode("PROTECTVIRUS")
    AddGeneratorCode("EATING_YES")
  EndIf
  
  If *gp\iSpeed < 4:AddGeneratorCode("MOVE_FORWARD"):Else:AddGeneratorCode("MOVE_FORWARD2X"):EndIf
  AddGeneratorCode("ROTATE_FOOD")
  
  If *gp\iProtectionLevel > 1
    If *gp\iProtectionLevel > 5
      AddGeneratorCode("TIMER_SET " +Str((#CODE_SIZE * 3) / 4))
    Else
      AddGeneratorCode("TIMER_SET " + Str(#CODE_SIZE))  
    EndIf
  EndIf  
  If *gp\iProtectionLevel = 9
    AddGeneratorCode("@LINE_SECURITY_BLOCK2", #True)
  EndIf
  
  For i = 1 To Random(*gp\iSpeed / 2)
    If *gp\iSpeed < 4:AddGeneratorCode("MOVE_FORWARD"):Else:AddGeneratorCode("MOVE_FORWARD2X"):EndIf
  Next
  
  If *gp\iProtectionLevel > 7
    AddGeneratorCode("ANTIVIRUS")
    AddGeneratorCode("PROTECTVIRUS")
  EndIf
  
  bSearchAlreadyDone.i = #False
  
  If *gp\iProtectionLevel = 9
    AddGeneratorCode("@LINE_SECURITY_BLOCK3", #True)
  EndIf
  
  Select *gp\iCopyMode
    Case 0 ;NONE
    Case 1 ;SECURE COMBINE
      bSearchAlreadyDone.i = #True
      AddGeneratorCode("SEARCH_NEAREST_ENEMY")
      AddGeneratorCode("COPY_MIN_ENERGY " + Str(*gp\iCopyMinEnergy))
      AddGeneratorCode("IF_CMP_ENEMY_LESS 10000 ; Make sure that the nearest creature is no enemy")
      AddGeneratorCode("  COMBINECOPY")
      AddGeneratorCode("ENDIF")
      AddGeneratorCode("COPY_MIN_ENERGY " + Str(*gp\iCopyMinEnergy * 2))
      AddGeneratorCode("CLONE ; If there is no creature to combine, we will clone us")
      
    Case 2 ;50:50
      If *gp\iProtectionLevel => 8
        AddGeneratorCode("COPY_MIN_ENERGY " + Str(*gp\iCopyMinEnergy * 2))
      EndIf
      AddGeneratorCode("COPY50_50 ; nearly the same as CLONE")
      
    Case 3 ;75:25
      If *gp\iProtectionLevel => 8
        AddGeneratorCode("COPY_MIN_ENERGY " + Str(*gp\iCopyMinEnergy * 2))
      EndIf
      AddGeneratorCode("COPY25_75 ; the new creature only gets 25 % of the energy")
    Case 4 ;95:5
      If *gp\iProtectionLevel => 8
        AddGeneratorCode("COPY_MIN_ENERGY " + Str(*gp\iCopyMinEnergy * 2))
      EndIf
      AddGeneratorCode("COPY5_95 ; the new creature only gets 5 % of the energy")
    Case 5 ;COMBINE
      If *gp\iProtectionLevel => 8
        AddGeneratorCode("COPY_MIN_ENERGY " + Str(*gp\iCopyMinEnergy * 2))
      EndIf
      AddGeneratorCode("COMBINECOPY")
  EndSelect
  
  If *gp\iProtectionLevel = 9
    AddGeneratorCode("@LINE_SECURITY_BLOCK4", #True)
  EndIf
  
  For i = 1 To Random(*gp\iSpeed / 2)
    If *gp\iSpeed < 4:AddGeneratorCode("MOVE_FORWARD"):Else:AddGeneratorCode("MOVE_FORWARD2X"):EndIf
  Next
  
  If *gp\iProtectionLevel > 6 And *gp\iProtectionLevel<> 9
    AddGeneratorCode("ANTIVIRUS")
    AddGeneratorCode("PROTECTVIRUS")
  EndIf
  
  If *gp\iProtectionLevel = 9
    AddGeneratorCode("@LINE_SECURITY_BLOCK5", #True)
  EndIf
  
  For i = 1 To Random(*gp\iSpeed / 2)
    If *gp\iSpeed < 4:AddGeneratorCode("MOVE_FORWARD"):Else:AddGeneratorCode("MOVE_FORWARD2X"):EndIf
  Next
  
  
  If *gp\iAggressiveLevel > 0
    
    AddGeneratorCode("IF_ENERGY_GREATER " +Str(100000 -  *gp\iAggressiveLevel * 11000))
    If bSearchAlreadyDone = #False  
      AddGeneratorCode("SEARCH_NEAREST_ENEMY")
      bSearchAlreadyDone = #True
    EndIf  
    AddGeneratorCode("IF_CMP_ENEMY_GREATER 10000 ; Make sure it is not one of our own")
    AddGeneratorCode("IF_ENEMYABS_LESS "+Str(70 + *gp\iAggressiveLevel * 20))
    If *gp\bOnlyBigCellsCanEmitPoison
      AddGeneratorCode("IF_CELL_RAD_GREATER 25")    
    EndIf
    
    AddGeneratorCode("GOTO @LINE_DO_ATTACK") 
    AddGeneratorCode("ENDIF")
    
    AddGeneratorCode("GOTO @LINE_NO_ATTACK")  
    AddGeneratorCode("@LINE_DO_ATTACK",#True)    
    If *gp\iProtectionLevel = 9
      AddGeneratorCode("@LINE_SECURITY_BLOCK6", #True)
    EndIf
    
    If *gp\iSpeed >4:AddGeneratorCode("MOVE_FORWARD"):Else:AddGeneratorCode("MOVE_FORWARD2X"):EndIf
    
    AddGeneratorCode("ROTATE_ENEMY")  
    If *gp\iAggressiveLevel > 6
      AddGeneratorCode("ROTATE_ENEMY")  
    EndIf  
    
    AddGeneratorCode("@REPEAT_MOVE", #True) 
    
    If *gp\bRotateEnemyFast:AddGeneratorCode("ROTATE_ENEMY"):EndIf
    AddGeneratorCode("MOVE_FORWARD2X")   
    AddGeneratorCode("MOVE_FORWARD2X")  
    For i = 0 To *gp\iAggressiveLevel / 3
      AddGeneratorCode("GOTO50 @REPEAT_MOVE")
    Next
    AddGeneratorCode("ROTATE_ENEMY")
    
    If *gp\iProtectionLevel = 9
      AddGeneratorCode("@LINE_SECURITY_BLOCK7", #True)
    EndIf
    
    If *gp\iSpeed >4:AddGeneratorCode("MOVE_FORWARD"):Else:AddGeneratorCode("MOVE_FORWARD2X"):EndIf    
    
    AddGeneratorCode("{REPLACE_ATTACK1}", #True)   
    AddGeneratorCode("@LINE_NO_ATTACK", #True)   
  EndIf
  
  
  If *gp\iProtectionLevel = 9
    AddGeneratorCode("@LINE_SECURITY_BLOCK8", #True)
  EndIf
  
  If *gp\iAggressiveLevel > 0
    
    AddGeneratorCode("IF_ENERGY_GREATER " +Str(100000 -  *gp\iAggressiveLevel * 11000))
    AddGeneratorCode("IF_CMP_ENEMY_LESS 10000 ; go away if it is one of us")
    AddGeneratorCode("ROTATE_ANTI_ENEMY")
    AddGeneratorCode("ROTATE_ANTI_ENEMY")
    AddGeneratorCode("ENDIF")
    
  Else
    
    If bSearchAlreadyDone = #False  
      AddGeneratorCode("SEARCH_NEAREST_ENEMY")
      bSearchAlreadyDone = #True
    EndIf
    AddGeneratorCode("IF_ENERGY_GREATER " +Str(15000))
    AddGeneratorCode("IF_CMP_ENEMY_LESS 10000 ; go away if it is one of us")
    AddGeneratorCode("ROTATE_ANTI_ENEMY")
    AddGeneratorCode("MOVE_FORWARD2X")
    AddGeneratorCode("ROTATE_ANTI_ENEMY")
    AddGeneratorCode("MOVE_FORWARD2X")
    AddGeneratorCode("ROTATE_ANTI_ENEMY")
    AddGeneratorCode("ENDIF")
    
  EndIf
  
  
  
  For i = 1 To Random(*gp\iSpeed / 2)
    If *gp\iSpeed < 4:AddGeneratorCode("MOVE_FORWARD"):Else:AddGeneratorCode("MOVE_FORWARD2X"):EndIf
  Next
  
  
  If *gp\iProtectionLevel = 9
    AddGeneratorCode("IF_CELLNUMER_GREATER 0 ; use the first cell to send out DNA, so that the code of infected cells will be overwritten")
    AddGeneratorCode("GOTO @LINE_SKIP_SECURITY")
    AddGeneratorCode("ENDIF")
    AddGeneratorCode("GOTO50 @LINE_SKIP_SECURITY")
    AddGeneratorCode("GOTO50 @LINE_SKIP_SECURITY")  
    AddGeneratorCode("DEC_CELL_RAD ; the cell radius should be small, so that it is hard to inject DNA into the cell")
    AddGeneratorCode("POISON_DNABLOCK_SIZE 5")
    AddGeneratorCode("POISON_EMIT_DNABLOCK @LINE_SECURITY_BLOCK1")
    AddGeneratorCode("POISON_EMIT_DNABLOCK @LINE_SECURITY_BLOCK2")
    AddGeneratorCode("POISON_EMIT_DNABLOCK @LINE_SECURITY_BLOCK3")  
    AddGeneratorCode("POISON_EMIT_DNABLOCK @LINE_SECURITY_BLOCK4")
    AddGeneratorCode("POISON_EMIT_DNABLOCK @LINE_SECURITY_BLOCK5")
    If *gp\iAggressiveLevel > 0
      AddGeneratorCode("POISON_EMIT_DNABLOCK @LINE_SECURITY_BLOCK6")
      AddGeneratorCode("POISON_EMIT_DNABLOCK @LINE_SECURITY_BLOCK7")
    EndIf
    AddGeneratorCode("POISON_EMIT_DNABLOCK @LINE_SECURITY_BLOCK8")
    AddGeneratorCode("@LINE_SKIP_SECURITY", #True)
    AddGeneratorCode("ENDIF")
  EndIf
  
  AddGeneratorCode("@LINE_REPEAT_MOVE2",#True)
  For i = 1 To Random(*gp\iSpeed / 2)
    If *gp\iSpeed < 4:AddGeneratorCode("MOVE_FORWARD"):Else:AddGeneratorCode("MOVE_FORWARD2X"):EndIf
  Next
  AddGeneratorCode("MOVE_FORWARD2X")
  AddGeneratorCode("GOTO50 @LINE_REPEAT_MOVE2")
  
  AddGeneratorCode("GOTO @LINE_BEGIN")
  AddGeneratorCode("GOTO @LINE_BEGIN")
  AddGeneratorCode("GOTO @LINE_BEGIN")    
  AddGeneratorCode()  
  
  ;iAdditionalLines = countstring(sAttack, #LF$)
  Repeat
    AddGeneratorCode("GOTO @LINE_INITPROGRAM")
    If Random(10000) % 100 < *gp\iAggressiveLevel
      AddGeneratorCode_InsertDNA(*gp)
    EndIf
  Until iGenerator_Line >= #CODE_SIZE - 100;(iAdditionalLines * 2 + 10)
  
  
  
  If *gp\iAttackMode = 1 Or *gp\iAttackMode = 6 Or *gp\iAttackMode = 2 Or *gp\iAttackMode = 7
    sAttack.s = "POISON_DNABLOCK_SIZE " + Str(iGenerator_DNABlockSize) + #LF$
    ;sAttack.s + "GOTO50 @ATTACK_SECOND_HALF{ATTACKID}" + #LF$
    For i = 0 To  iGenerator_NrOfDNABlocks - 1
      
      ;If i = iGenerator_NrOfDNABlocks/2
      ;  sAttack.s + "GOTO @ATTACK_END{ATTACKID}" + #LF$
      ;  sAttack.s + "@ATTACK_SECOND_HALF{ATTACKID}" + #LF$
      ;EndIf
      
      If *gp\bEmitPoisonToEnemy
        sAttack.s + "EMITTOENEMY_DNABLOCK @DNA_ATTACK_BLOCK"+Str(i) + #LF$
      Else
        sAttack.s + "POISON_EMIT_DNABLOCK @DNA_ATTACK_BLOCK"+Str(i) + #LF$
      EndIf
      
    Next
    ;sAttack.s + "@ATTACK_END{ATTACKID}" + #LF$
  EndIf
  
  bEnablePoistion.i = #False
  
  If *gp\iAttackMode > 4 
    
    If bEnablePoistion = #False
      bEnablePoistion.i = #True
      sAttack.s + "POISON_YES" + #LF$
    EndIf
    iAdditional = 0
    If *gp\iAttackMode = 4:iAdditional = 2:EndIf   
    For i=1 To *gp\iAggressiveLevel + iAdditional
      If *gp\bEmitPoisonToEnemy
        sAttack.s + "EMITTOENEMY_POISON " + Str(*gp\Intern_iParalyse) + #LF$
      Else
        sAttack.s + "POISON_EMIT " + Str(*gp\Intern_iParalyse) + #LF$
      EndIf
    Next
  EndIf
  
  
  If *gp\iAttackMode = 4 Or  *gp\iAttackMode = 9
    
    If bEnablePoistion = #False
      bEnablePoistion.i = #True
      sAttack.s + "POISON_YES" + #LF$
    EndIf
    iAdditional = 0
    If *gp\iAttackMode = 4:iAdditional = 2:EndIf
    For i=1 To *gp\iAggressiveLevel + iAdditional
      If *gp\bEmitPoisonToEnemy
        sAttack.s + "EMITTOENEMY_POISON " + Str(*gp\Intern_iPoison) + #LF$
      Else
        sAttack.s + "POISON_EMIT " + Str(*gp\Intern_iPoison) + #LF$
      EndIf
    Next
  EndIf
  
  If bEnablePoistion = #True
    sAttack.s + "POISON_NO" + #LF$
  EndIf
  
  
  If *gp\iAttackMode = 3  Or *gp\iAttackMode = 8; VIRUS
    sAttack.s + "POISON_VIRUS_MIN_ENERGY 0" + #LF$
    sAttack.s + "PROTECTVIRUS" + #LF$
    sAttack.s + "VARIABLE @VIRUS_CODE{ATTACKID}" + #LF$
    sAttack.s + "VARIABLE_RND" + #LF$
    sAttack.s + "VARIABLE_AND 511" + #LF$
    sAttack.s + "VARIABLE_MUL 256" + #LF$
    sAttack.s + "VARIABLE_ADD 12 ; create a random POISON_EMIT_VIRUS command" + #LF$  
    sAttack.s + "@VIRUS_CODE{ATTACKID}" + #LF$
    sAttack.s + "POISON_EMIT_VIRUS 0" + #LF$
    sAttack.s + "GOTO50 @VIRUS_CODE{ATTACKID}" + #LF$
    For i=1 To *gp\iAggressiveLevel
      sAttack.s + "GOTO50 @VIRUS_CODE{ATTACKID}" + #LF$
    Next
  EndIf
  
  If *gp\iAttackMode = 2  Or  *gp\iAttackMode = 7; ABSORB
  
    sAttack.s + "IF_ENEMYABS_LESS 100" + #LF$  
    sAttack.s + "@ABSORB_CODE{ATTACKID}" + #LF$
    sAttack.s + "ABSORB_ENEMY" + #LF$
    For i=1 To *gp\iAggressiveLevel/3
      sAttack.s + "GOTO50 @ABSORB_CODE{ATTACKID}" + #LF$
    Next
  EndIf
  
  
  sGenerator_Code = ReplaceString(sGenerator_Code, "{REPLACE_ATTACK1}", ReplaceString(sAttack, "{ATTACKID}", "1"))
  sGenerator_Code = ReplaceString(sGenerator_Code, "{REPLACE_ATTACK2}", ReplaceString(sAttack, "{ATTACKID}", "2"))
  
  RandomSeed(ElapsedMilliseconds())
  
  ProcedureReturn sGenerator_Code
EndProcedure



; 
; gp.GENERATOR_PARAMETER
; gp\iCopyMinEnergy = 50000
; gp\iProtectionLevel = 1
; gp\iCopyMode = 1
; gp\iAggressiveLevel = 9
; gp\iAttackMode = 5
; gp\iDNAAttackMode = 1
; gp\iSpeed = 9
; gp\bRotateEnemyFast = #True
; gp\iRandom = 777
; CreateFile(1,"C:\testxx.txt")
; WriteString(1,GenerateCodeFromGenerator(gp.GENERATOR_PARAMETER))
; CloseFile(1)


; IDE Options = PureBasic 4.30 Beta 5 (Windows - x86)
; CursorPosition = 575
; FirstLine = 456
; Folding = C-
; EnableXP
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant
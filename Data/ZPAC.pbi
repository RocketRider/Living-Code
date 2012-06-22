
;PACKER FUNCTIONS FOR WINDOWS AND LINUX
;======================================
;I wrote these packer functions because there seems to be issues when loading compressed packages from windows on linux or vice versa.
;These functions use same compression algorithm for linux and windows.
;It is very similar to the packer functions of PureBasic.
;The compression is much faster as with PureBasic commands.
;For windows the zlib1.dll is needed.
;
;Feel free to do whatever you want with this code, but note that the author is not liable for any damages which are caused by this software.

Global ZPAC_Library.l, ZPAC_createpack_file.l, ZPAC_createpack_filecount.l , ZPAC_createpack_encryption, ZPAC_lasterror.s, ZPAC_showerror.l
Global ZPAC_readpack_file.l, ZPAC_readpack_filecount.l, ZPAC_readpack_count.l, ZPAC_readpack_encryption, ZPAC_readpack_filesize.l,*ZPAC_CompressedBuffer.l, ZPAC_CompressedBufferSize.l, *ZPAC_DeCompressedBuffer.l, ZPAC_DeCompressedBufferSize.l


CompilerIf #PB_Compiler_OS = #PB_OS_Windows

;CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
  ZPAC_Library = OpenLibrary(#PB_Any, "Data\zlib1.dll") 
;CompilerElse
;  ZPAC_Library = OpenLibrary(#PB_Any, "Data\zlib1x64.dll") 
;CompilerEndIf  
  
CompilerElse 
  ZPAC_Library = OpenLibrary(#PB_Any, "libz.so")
  If ZPAC_Library=0
  ZPAC_Library = OpenLibrary(#PB_Any, "libz.so.1")
  EndIf
  If ZPAC_Library=0
  ZPAC_Library = OpenLibrary(#PB_Any, "libz.so.1.2.3.3")
  EndIf  
  
CompilerEndIf
  
  

PrototypeC.l  __ZPAC_uncompress( DeCompressedBuffer.l, OrgSize.l, *CompressedBuffer, PackedSize.l)
PrototypeC.l  __ZPAC_compress2( *TmpBuffer, DestSize.l, *MemoryPtr, lSize, lCompressionLevel)

Global _ZPAC_uncompress.__ZPAC_uncompress=GetFunction(ZPAC_Library, "uncompress")
Global _ZPAC_compress2.__ZPAC_compress2=GetFunction(ZPAC_Library, "compress2")







Macro __ZPAC_SetError(error)
ZPAC_lasterror = error
If ZPAC_showerror
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    MessageRequester("ZPAC Error:", "There was an error in the ZPAC library:" + #CRLF$ + ZPAC_lasterror, #MB_ICONERROR)     
  CompilerElse 
    MessageRequester("ZPAC Error:", "There was an error in the ZPAC library:" + #CRLF$ + ZPAC_lasterror, #PB_MessageRequester_Ok)
  CompilerEndIf 
EndIf
EndMacro

;Initalizes and loads the zlib library. This command must be called before all other ZLIB commands.
ProcedureDLL.l ZPAC_Init(lShowError.l = #False)
  CompilerIf #PB_Compiler_OS = #PB_OS_AmigaOS
    CompilerError "Operating System not supported!"
  CompilerEndIf
  CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
    CompilerError "Operating System not supported!"
  CompilerEndIf
    
  
  ZPAC_showerror = lShowError
  ZPAC_lasterror = ""
  ZPAC_createpack_file = #Null
  ZPAC_createpack_filecount = 0
  ZPAC_createpack_encryption = 0
  
  ZPAC_readpack_file = #Null
  ZPAC_readpack_filecount = 0
  ZPAC_readpack_count = 0   
  ZPAC_readpack_encryption = 0
  ZPAC_readpack_filesize = 0
  
  *ZPAC_CompressedBuffer = #Null
  ZPAC_CompressedBufferSize = 0
   
  *ZPAC_DeCompressedBuffer = #Null
  ZPAC_DeCompressedBufferSize = 0
      
  If ZPAC_Library = #Null
    __ZPAC_SetError("ZPAC_Init: can't find zlib library")    
  EndIf
  ProcedureReturn ZPAC_Library
EndProcedure

; Frees the zlib library. This command must be called after all ZLIB commands.
ProcedureDLL.l ZPAC_Free()
  If ZPAC_Library  
    If *ZPAC_CompressedBuffer
      FreeMemory(*ZPAC_CompressedBuffer)
    EndIf
    *ZPAC_CompressedBuffer = #Null
       
    If *ZPAC_DeCompressedBuffer
      FreeMemory(*ZPAC_DeCompressedBuffer)
    EndIf
    *ZPAC_DeCompressedBuffer = #Null
    
    If ZPAC_createpack_file
      CloseFile(ZPAC_createpack_file)
    EndIf
    
    If ZPAC_readpack_file
      CloseFile(ZPAC_readpack_file)
    EndIf    
    CloseLibrary(Library_zlib)
  EndIf
EndProcedure

;Returns an description of the last error of the zlib library.
;This command is very useful to find the reason for an error.
ProcedureDLL.s ZPAC_GetLastError()
  ProcedureReturn ZPAC_lasterror
EndProcedure


;Creates a pack archive. If the parameter lEncryption is 0 then there is no encryption.
;Otherwise a simple XOR encryption based on the lEncryption parameter is used.
;A pack file created with ZPAC_CreatePack must be closed with ZPAC_CloseCreatePack.
Procedure ZPAC_CreatePack(sFile.s, lEncryption.l = 0)
  If ZPAC_Library
    If ZPAC_createpack_file
      __ZPAC_SetError("ZPAC_CreatePack: there is already a pack file opened")   
      ProcedureReturn #False      
    EndIf
  
    ZPAC_createpack_filecount = 0
    ZPAC_createpack_file = CreateFile(#PB_Any, sFile.s)
    ZPAC_createpack_encryption = lEncryption
    If ZPAC_createpack_file
      WriteLong(ZPAC_createpack_file, 'CAPZ')
      WriteLong(ZPAC_createpack_file, 0) ; Write numer of files in pack
    Else
      __ZPAC_SetError("ZPAC_CreatePack: Can't create pack file " + sFile) 
    EndIf
    ProcedureReturn #True
  Else
    __ZPAC_SetError("ZPAC_CreatePack: zlib library was not opened")   
    ProcedureReturn #False
  EndIf
EndProcedure

;Opens a packed file previously created with ZPAC_CreatePack().
;A pack file opened with ZPAC_ReadPack must be closed with ZPAC_CloseReadPack.
ProcedureDLL.l ZPAC_ReadPack(sFile.s, lEncryption.l = 0)
lSuccess = #True
  If ZPAC_Library
    
    If ZPAC_readpack_file
      __ZPAC_SetError("ZPAC_CreatePack: there is already a pack file opened")     
      ProcedureReturn #False
    EndIf   
    
    ZPAC_readpack_file = ReadFile(#PB_Any, sFile.s)
    ZPAC_readpack_encryption = lEncryption
    ZPAC_readpack_filesize = 0
    If ZPAC_readpack_file
    
      FileBuffersSize(ZPAC_readpack_file, 16384)

      lSign = ReadLong(ZPAC_readpack_file) 
      
      If lSign = 'CAPZ'
      
        ZPAC_readpack_filecount = ReadLong(ZPAC_readpack_file)
        ZPAC_readpack_count = 0
        If ZPAC_readpack_filecount > 0
          ; Pack file is ok
          
        Else
          __ZPAC_SetError("ZPAC_ReadPack: pack file contains nothing")
          lSuccess = #False          
        EndIf
      
      Else
        __ZPAC_SetError("ZPAC_ReadPack: File " + Chr(34) + sFile + Chr(34) + " is not a valid pack file")
        lSuccess = #False      
      EndIf
      
    Else
      __ZPAC_SetError("ZPAC_CreatePack: Can't read pack file " + sFile)
      lSuccess = #False
    EndIf

  Else
    __ZPAC_SetError("ZPAC_ReadPack: zlib library was not opened")   
    lSuccess = #False
  EndIf
  ProcedureReturn lSuccess
EndProcedure

;Returns the number of files in the package.
;The command works only if a package is opened with ZPAC_ReadPack(). 
ProcedureDLL.l ZPAC_ReadPackFiles()
  ProcedureReturn ZPAC_readpack_filecount
EndProcedure

;Returns the pointer to the next file in the package.
;The command works only if a package is opened with ZPAC_ReadPack(). 
ProcedureDLL.l ZPAC_NextPackFile()
  *lResultPtr.l = #Null
  ZPAC_readpack_filesize = 0
  If ZPAC_Library
    
    If ZPAC_readpack_file
    
      If ZPAC_readpack_count < ZPAC_readpack_filecount
      
        ZPAC_readpack_count + 1
        
        lOrgSize = ReadLong(ZPAC_readpack_file)
        lPackedSize = ReadLong(ZPAC_readpack_file)
        
        If *ZPAC_CompressedBuffer = #Null Or ZPAC_CompressedBufferSize < lPackedSize
          If *ZPAC_CompressedBuffer
            FreeMemory(*ZPAC_CompressedBuffer)
          EndIf
          *ZPAC_CompressedBuffer = AllocateMemory(lPackedSize)
          ZPAC_CompressedBufferSize = lPackedSize
        EndIf
                
        If *ZPAC_DeCompressedBuffer = #Null Or ZPAC_DeCompressedBufferSize < lOrgSize
          If *ZPAC_DeCompressedBuffer
            FreeMemory(*ZPAC_DeCompressedBuffer)
          EndIf
          *ZPAC_DeCompressedBuffer = AllocateMemory(lOrgSize)
          ZPAC_DeCompressedBufferSize = lOrgSize
        EndIf      
     
          
        If *ZPAC_CompressedBuffer And *ZPAC_DeCompressedBuffer
        
          ReadData(ZPAC_readpack_file, *ZPAC_CompressedBuffer, lPackedSize)
          
          If ZPAC_readpack_encryption
            
              RandomSeed(ZPAC_readpack_encryption)
              *Tmp.BYTE = *ZPAC_CompressedBuffer
              For c = 0 To lPackedSize - 1
               *Tmp\b - c
               *Tmp\b ! Random($FF)
               *Tmp +1
              Next
            
          EndIf
        
          ZPAC_readpack_filesize = lOrgSize
          
          ;lResult.l = CallCFunction(ZPAC_Library, "uncompress", *ZPAC_DeCompressedBuffer, @lOrgSize, *ZPAC_CompressedBuffer, lPackedSize) 
          lResult.l = _ZPAC_uncompress( *ZPAC_DeCompressedBuffer, @lOrgSize, *ZPAC_CompressedBuffer, lPackedSize) 
          If lResult = 0
            *lResultPtr = *ZPAC_DeCompressedBuffer
          Else
            ZPAC_readpack_filesize = 0
            __ZPAC_SetError("ZPAC_NextPackFile: zlib uncompress failed with errorcode "+Str(lResult))            
          EndIf
          
        Else
          __ZPAC_SetError("ZPAC_NextPackFile: can't allocate needed memory")    
        EndIf  
        
      Else
        __ZPAC_SetError("ZPAC_NextPackFile: There are no further files in this package")
      EndIf 
           
    Else
      __ZPAC_SetError("ZPAC_NextPackFile: No pack file was opened")
    EndIf

  Else
    __ZPAC_SetError("ZPAC_NextPackFile: zlib library was not opened")   
  EndIf
  ProcedureReturn *lResultPtr
EndProcedure

;Returns the size of the last package file in the package.
;The command must be called after ZPAC_NextPackFile.
ProcedureDLL.l ZPAC_NextPackFileSize()
  ProcedureReturn ZPAC_readpack_filesize 
EndProcedure

;Closes a package opened with ZPAC_CreatePack().
ProcedureDLL.l ZPAC_CloseCreatePack()
  If ZPAC_Library
    If ZPAC_createpack_file
      FileSeek(ZPAC_createpack_file, 4)
      WriteLong(ZPAC_createpack_file, ZPAC_createpack_filecount) ; Write numer of files in pack
      CloseFile(ZPAC_createpack_file)
      ZPAC_createpack_file = #Null
      ZPAC_createpack_filecount = 0
      ProcedureReturn #True
    Else
    __ZPAC_SetError("ZPAC_ClosePack: No pack file opened") 
    ProcedureReturn #False
    EndIf
  Else
    __ZPAC_SetError("ZPAC_CreatePack: zlib library was not opened")   
    ProcedureReturn #False
  EndIf 
EndProcedure

;Closes a package opened with ZPAC_ReadPack().
ProcedureDLL.l ZPAC_CloseReadPack()
  If ZPAC_Library
    If ZPAC_readpack_file
      CloseFile(ZPAC_readpack_file)
      ZPAC_readpack_file = #Null
      ZPAC_readpack_filecount = 0
      ZPAC_readpack_count = 0   
      ZPAC_readpack_filesize = 0
      
      If *ZPAC_CompressedBuffer
        FreeMemory(*ZPAC_CompressedBuffer)
      EndIf
      *ZPAC_CompressedBuffer = #Null
      ZPAC_CompressedBufferSize = 0
       
      If *ZPAC_DeCompressedBuffer
        FreeMemory(*ZPAC_DeCompressedBuffer)
      EndIf
      *ZPAC_DeCompressedBuffer = #Null
      ZPAC_DeCompressedBufferSize = 0
        
      ProcedureReturn #True
    Else
    __ZPAC_SetError("ZPAC_CloseReadPack: No pack file opened") 
    ProcedureReturn #False
    EndIf
  Else
    __ZPAC_SetError("ZPAC_CloseReadPack: zlib library was not opened")   
    ProcedureReturn #False
  EndIf 
EndProcedure

;Adds a memory area to the pack file opened with ZPAC_CreatePack().
;The parameter lCompressionLevel can be form 0 to 9 (default is 5).
ProcedureDLL.l ZPAC_AddMemoryPack(*MemoryPtr, lSize.l, lCompressionLevel.l = 9)
  If ZPAC_Library
    lSuccess = #True
   
    If ZPAC_createpack_file And *MemoryPtr And lSize > 0
      ZPAC_createpack_filecount + 1
      
      DestSize = lSize * 2 + 32
      *TmpBuffer.l = AllocateMemory(DestSize)
      
      If *TmpBuffer
                 
        If lCompressionLevel < 0 :lCompressionLevel = 0:EndIf
        If lCompressionLevel > 9 :lCompressionLevel = 9:EndIf
          
        ;lResult.l = CallCFunction(ZPAC_Library, "compress2", *TmpBuffer, @DestSize, *MemoryPtr, lSize, lCompressionLevel)  
        lResult.l = _ZPAC_compress2( *TmpBuffer, @DestSize, *MemoryPtr, lSize, lCompressionLevel)  
       
        If lResult = 0
        
          If ZPAC_createpack_encryption
          
            RandomSeed(ZPAC_createpack_encryption)
            *Tmp.BYTE = *TmpBuffer
            For c = 0 To DestSize - 1
             *Tmp\b ! Random($FF)
             *Tmp\b + c
             *Tmp +1
            Next
          
          EndIf
                 
          WriteLong(ZPAC_createpack_file, lSize)
          WriteLong(ZPAC_createpack_file, DestSize)
          WriteData(ZPAC_createpack_file, *TmpBuffer, DestSize)
        
        Else
          lSuccess = #False
          __ZPAC_SetError("ZPAC_AddMemoryPack: zlib compress failed with errorcode: "+Str(lResult))  
        EndIf
        
        FreeMemory(*TmpBuffer)
      
      Else
        lSuccess = #False
        __ZPAC_SetError("ZPAC_AddMemoryPack: Can't create temporary buffer with size "+Str(DestSize))
      EndIf
      
    Else
      lSuccess = #False
      If ZPAC_createpack_file = #Null
        __ZPAC_SetError("ZPAC_AddMemoryPack: No pack file was opened")
      EndIf
      If *MemoryPtr = #Null
        __ZPAC_SetError("ZPAC_AddMemoryPack: declared memory pointer is null")
      EndIf    
      If lSize = #Null
        __ZPAC_SetError("ZPAC_AddMemoryPack: declared memory size is <= 0")
      EndIf            
    EndIf
  Else
    __ZPAC_SetError("ZPAC_AddMemoryPack: zlib library was not opened")   
    lSuccess = #False
  EndIf   
  ProcedureReturn lSuccess
EndProcedure


;Adds a file to the pack file opened with ZPAC_CreatePack().
;The parameter lCompressionLevel can be form 0 to 9. The default is 9 (best compression).
ProcedureDLL.l ZPAC_AddFile(sFile.s, lCompressionLevel.l = 5)
  lSuccess = #False
  If ZPAC_Library
    lSuccess = #True

      tmpFile = ReadFile(#PB_Any, sFile)
      If tmpFile
      
        lFileSize.l = Lof(tmpFile)
        If lFileSize > 0
          *TmpBuffer.l = AllocateMemory(lFileSize)
          
          If *TmpBuffer.l
          
            ReadData(tmpFile, *TmpBuffer, lFileSize)

            If ZPAC_AddMemoryPack(*TmpBuffer, lFileSize, lCompressionLevel) = #False
              lSuccess = #False 
            EndIf 
          
          Else
            lSuccess = #False
            __ZPAC_SetError("ZPAC_AddFile: Can't create temporary buffer with size "+Chr(34) + Str(lFileSize) + Chr(34))                    
          EndIf  
          
          FreeMemory(*TmpBuffer)                 
        Else
          lSuccess = #False
          __ZPAC_SetError("ZPAC_AddFile: File size is incorrect "+Chr(34) + Str(lFileSize) + Chr(34))                   
        EndIf
        
        CloseFile(tmpFile)
      Else
        lSuccess = #False
        __ZPAC_SetError("ZPAC_AddFile: Can't open file "+Chr(34)+sFile+Chr(34))        
      EndIf

  Else
    lSuccess = #False
    __ZPAC_SetError("ZPAC_AddFile: zlib library was not opened")   
  EndIf 
  
  ProcedureReturn lSuccess
EndProcedure

; ;Example:
; 
; ZPAC_Init(#False) ; Use true for debugging
; 
; ZPAC_CreatePack("Test.pak", 48729193)
; 
; test1.s = "1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 " 
; test2.s = "ABCDEFGHIJKLMNOPQRSTUVWXYZ ABCDEFGHIJKLMNOPQRSTUVWXYZ ABCDEFGHIJKLMNOPQRSTUVWXYZ " 
; test3.s = "aaa bbb ccc ddd eee fff ggg hhh iii jjj kkk lll mmm nnn ooo ppp qqq rrr sss ttt uuu vvv www xxx yyy zzz" 
; ZPAC_AddMemoryPack(@test1.s,Len(test1), 9)
; ZPAC_AddMemoryPack(@test2.s,Len(test2), 9)
; ZPAC_AddMemoryPack(@test3.s,Len(test3), 9)
; ZPAC_CloseCreatePack()
; 
; ZPAC_ReadPack("Test.pak", 48729193)
; 
; Repeat
; ptr = ZPAC_NextPackFile()
;   If ptr
;     Debug PeekS(ptr)
;   EndIf
; Until ptr = #Null
; 
; ZPAC_CloseReadPack()
; 
; ZPAC_Free()

; IDE Options = PureBasic 4.30 Beta 3 (Windows - x86)
; ExecutableFormat = Shared Dll
; CursorPosition = 31
; FirstLine = 6
; Folding = AA+
; EnableXP
; Executable = ZPC_DLL.dll
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant
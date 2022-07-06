STSEG SEGMENT PARA STACK "STACK"
  DB 64 DUP ("STACK")
STSEG ENDS

DTSEG SEGMENT PARA PUBLIC "DATA"
    BUF DB 7, ?, 7 DUP ('?')        ; 6 CHARS + NEWLINE (ENTER), ? IS FOR REAL NUMBER OF INPUTTED CHARS
                                    ; RESERVE 7 BYTES FOR THE  BUFFER ITSELF
    
    
    
    NUM DW -32768                   ; DEFINE WORD (16 BIT = 2 BYTES)
    ZERONUM DB 0                    ; IS OUR NUMBER NEGATIVE. IF SO =1 OR 0 OTHERWISE
    ERRORTXT DB ("WRONG INPUT! $")
    INPUTTEXT DB ("NUMBER: $")
    ANSWERTEXT DB (" - 78 = $")
DTSEG ENDS

CDSEG SEGMENT PARA PUBLIC "CODE"        
    MAIN PROC FAR
    ASSUME DS:DTSEG, SS:STSEG, CS:CDSEG    
    
    PUSH DS         ; SAVING RETRUN ADDRESS
    SUB AX, AX      ; AX - AX  = 0 SUBTRACT
    PUSH AX
    
    
    MOV AX, DTSEG   ; PUT ADDRESS OF DATA SEGMENT IN DS  
    MOV DS, AX
    
    
    LEA DX, INPUTTEXT ; LEA = LOAD EFFECTIVE ADDRESS (LOADS ADDRESS OF INPUTTEXT INTO DX)
    MOV AH, 9 
    INT 21H             ; 9TH FUNCTION OF 21ST INTERRUPT = PRINT STRING TO CONSOLE

    FSTART:
        CALL NUMSCAN
        CALL NEWLINE
        CALL NUMOUTPUT
        LEA DX, ANSWERTEXT  
        MOV AH, 9  
        INT 21H    
        MOV AX, NUM
        SUB AX, 78    
        JNO ER    
        LEA DX, ERRORTXT    
        MOV AH, 9
        INT 21H    
        CALL ERROR
        MOV ZERONUM, 0
        SUB AX, AX   
        SUB BX, BX
        SUB CX, CX
        SUB DX, DX
        JMP FSTART     
        ER:    
            MOV NUM, AX
            CALL NUMOUTPUT
    RET
    
    NUMSCAN PROC    
        START:
            MOV AH, 10      ; 
            LEA DX, BUF     ; ADDRESS OF BUFFER GETS LOADED INTO DX 
            INT 21H         ; 10TH FUNCTION OF 21TH INTERRUPT = READS CHARS FROM CONSOLE TO BUFFER
            
            SUB AX, AX      ; AX=0   
            SUB BX, BX      ; BX=0
            SUB CX, CX      ; CX=0
            MOV CL, BUF + 1 ; CL = NUMBER OF CHARS INPUTTED
            LEA DI, BUF + 2 ; DI = ADDRESS OF THE START OF INPUTTED CHRS THEMSELVES
        S1:
            MOV BL, [DI]    ; BL = FIRST CHAR THAT WAS INPUTTED (ADRESS TRANSFER)   
            SUB BL, '0'     ; CONVERT ASCII SYMBOL INTO REAL NUMBER    
            
            CMP BL, 9       ; COMPARE BL TO 9
            JA ERRNOTNUM    ; (JUMP-IF-ABOVE) IF BL BIGGER THAN 9, JUMP 
            CMP BL, 0       ; COMPARE BL TO 0
            JB ERRNOTNUM    ; (JUMP-IF-BELOW) IF BL IS LOWER THAN 0, JUMP
            MOV DX, 10      ; 
            IMUL DX
            JO ERRRESTART   ; (JUMP-IF-OVERFLOW) 
            ADD AX, BX
            JO ERRRESTART   ; (JUMP-IF-OVERFLOW)
            
            SUB BX, BX
            JMP END5
            ERRNOTNUM:   
                ADD BL, '0'
                MOV DL, BUF + 1
                CMP CL, DL    
                JNE ERRRESTART
                CMP BL, '-'   
                JE ISNEG 
            ERRRESTART:
                CALL ERROR
                MOV ZERONUM, 0    
                JMP START    
            ISNEG:
                MOV ZERONUM, 1    
            END5:
                INC DI       ; INCREMENT DI
            LOOP S1
        
        CMP ZERONUM, 1        ; IF MINUS WAS INPUTTED
        JNE ISNOTNEG    ; JUMP-NOT-EQUAL
        NEG AX   
        ISNOTNEG:    
            MOV NUM, AX
            RET
        NUMSCAN ENDP
    
    NEWLINE PROC   
        PUSH AX    
        SUB AX, AX 
        MOV AL, 10 ; LINE FEED CHARACTER
        INT 29H ;   OUTPUT CHARACTER FROM AL
        POP AX    
        RET
    NEWLINE ENDP
    
    ERROR PROC             
        CALL NEWLINE       
        MOV AH, 9          
        LEA DX, ERRORTXT   
        INT 21H            
        
        CALL NEWLINE       
        LEA DX, INPUTTEXT  
        MOV AH, 9          
        INT 21H            
        RET
    ERROR ENDP
    
    NUMOUTPUT PROC        
        MOV BX, NUM       
        OR  BX, BX    ;DIDN'T CHANGE BX, BUT SET FLAGS    
        JNS M1        ; (JUMP-IF-NOT-SIGN-FLAG)
        MOV AL, '-'   ; PRINT MINUS    
        INT 29H
        NEG BX            
        M1:
            MOV AX, BX    
            SUB CX, CX    
            MOV BX, 10    
        M2:
            SUB DX, DX    
            DIV BX    ; DIVIDE AX BY BX(10), STORE RESULT IN AX AND REMAINDER IN DX    
            ADD DL, '0'; CONVERTS DECIMAL TO CHAR   
            PUSH DX       
            INC CX        
            TEST AX, AX ; TO SET FLAGS  
            JNZ M2        ; JUMP-IF-NOT-0
        M3:
            POP AX        
            INT 29H       
            LOOP M3 
        RET
    NUMOUTPUT ENDP
    
MAIN ENDP
CDSEG ENDS
END MAIN

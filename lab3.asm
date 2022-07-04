STSEG SEGMENT PARA STACK "STACK"
DB 64 DUP ("STACK")
STSEG ENDS

DSEG SEGMENT PARA PUBLIC "DATA"
    ERMESSAGE DB 'WRONG DATA$'
    ERDIGITMSG DB 'NOT A NUMBER DATA, PLEASE RETRY$'
    OVERFLOWMSG DB 'INTEGER OVERFLOW, PLEASE RETRY$'
    DIVBYZEROMSG DB 'DIVISION BY ZERO$'
    INPUTX DB 'ENTER X: $'
    INPUTY DB 'ENTER Y: $'
    BUFFER DB 7, ?, 7 DUP("?")
    NUMBERS DW 0, 0
    DILNYK DW 0
    OSTACHA DW 0
    PRECISION DW 6
DSEG ENDS



CSEG SEGMENT PARA PUBLIC "CODE"
ASSUME CS: CSEG, DS: DSEG, SS: STSEG

READNUM PROC NEAR

    START:
        LEA DX, BUFFER ; READ MESSAGE
        MOV AH, 10
        INT 21H
    
        XOR AX, AX ; NUMBER
        XOR DI, DI ; NEGATIVE FLAG
        XOR CX, CX ; CONVERT CHAR TO NUMBER
        MOV BX, 10 ; BASE 10
    
        MOV SI, OFFSET BUFFER+2 ; INDEX STARTS FROM 3RD ELEMENT
    
        MOV CL, [SI]
        CMP CL, '-'
        JNE READONE
        INC SI
        MOV DI, 1 ; NEGATIVE FLAG
    
    READONE:
        MOV CL, [SI]
        CMP CL, 0DH
        JE FINAL
        CMP CL, '0'
        JL NAN
        CMP CL, '9'
        JG NAN
        SUB CL, '0' ; CONVERT TO NUMBER
    
        TEST BX, BX
        MUL BX
        JS EROVERFLOW
        ADD AX, CX
        JS EROVERFLOW
        INC SI
        JMP READONE
    
    NAN:
        LEA DX, ERDIGITMSG
        MOV AH,9
        INT 21H
        MOV AL, 10 ; LF
        INT 29H
        MOV AL, 13 ; CR
        INT 29H
        MOV NUMBERS, 0000
        MOV NUMBERS + 2, 0000
        
        
        JMP START
    
    EROVERFLOW:
        LEA DX, OVERFLOWMSG
        MOV AH, 9
        INT 21H
        MOV AL, 10 ; LF
        INT 29H
        MOV AL, 13 ; CR
        INT 29H
        MOV NUMBERS, 0000
        MOV NUMBERS + 2, 0000
        
        JMP START
    
    FINAL:
        TEST DI, DI
        JZ POSITIVE
        NEG AX
        
    POSITIVE:
        RET
        
READNUM ENDP


CALCULATE PROC NEAR
    XOR DI, DI
    MOV AX, NUMBERS
    MOV BX, NUMBERS + 2
    ADD AX, BX
    JO OVERFLOW
    CMP AX, 10
    JL M1
    MOV AX, NUMBERS
    IMUL BX
    JO OVERFLOW
    CMP AX, 25
    JG M2
    JMP M3
    
    OVERFLOW:
        MOV AL, 10 ; LF
        INT 29H
        MOV AL, 13 ; CR
        INT 29H
        LEA DX, OVERFLOWMSG
        MOV AH, 9
        INT 21H
        XOR AX, AX
        RET
    
    ; y^2/(10-x+y) if x+y < 10
    ; 35x^2/y xy > 25 xy < 100
    ; 1 else
    M1:
        MOV AX, NUMBERS + 2
        TEST AX, AX
        JNS M1POS
        NEG AX
    M1POS:
        MUL AX
        JO OVERFLOW
        MOV BX, 10
        SUB BX, NUMBERS
        JO OVERFLOW
        ADD BX, NUMBERS + 2
        JO OVERFLOW
        TEST BX, BX
        JZ DIVBYZERO
        JNS M1DIVPOS
        MOV DI, 1
        NEG BX
    M1DIVPOS:
        DIV BX
        RET
    M2:
        CMP AX, 100
        JG M3
        MOV AX, NUMBERS
        TEST AX, AX
        JNS M2POS
        NEG AX
    M2POS:
        MUL AX
        JO OVERFLOW
        MOV BX, 35
        MUL BX
        JO OVERFLOW
        MOV BX, NUMBERS + 2
        TEST BX, BX
        JZ DIVBYZERO
        JNS M2DIVPOS
        MOV DI, 1
        NEG BX
    M2DIVPOS:
        DIV BX
        RET
    M3:
        XOR DX, DX
        MOV AX, 1
        RET
    
    DIVBYZERO:
        MOV AL, 10 ; LF
        INT 29H
        MOV AL, 13 ; CR
        INT 29H
        LEA DX, DIVBYZEROMSG
        MOV AH, 9
        INT 21H
        XOR AX, AX
        mov ax, "z"
        RET
    
CALCULATE ENDP



; RESULT MUST BE IN AX
WRITENUM PROC NEAR
    MOV DILNYK, BX
    MOV OSTACHA, DX
    MOV BX, AX
    MOV AL, 10 ; LF
    INT 29H
    MOV AL, 13 ; CR
    INT 29H
    
    TEST DI, DI
    JZ W1
    MOV AL, '-'
    INT 29H
    W1:
        MOV AX, BX
        XOR CX, CX ; INIT COUNTER
        MOV BX, 10 ; BASE IS 10, SO DIVIDE BY 10
    W2:
        XOR DX, DX
        DIV BX
        ADD DL, '0' 
        PUSH DX
        INC CX
        TEST AX, AX
        JNZ W2
    W3:
        POP AX
        INT 29H
        LOOP W3
    
        MOV DX, OSTACHA
        TEST DX, DX
        JZ .END
    
        MOV AL, '.'
        INT 29H
        MOV CX, PRECISION   
    AFTERCOMMA:
        MOV BX, 10
        MOV AX, DX
        MUL BX
        MOV BX, DILNYK
        DIV BX
        TEST AX, AX
        JZ OSTACHACHECK
    OSTACHANOTZERO:
        ADD AL, '0'
        INT 29H
        LOOP AFTERCOMMA
    .END:
        RET
    
    OSTACHACHECK:
        TEST DX, DX
        JZ .END
        JNZ OSTACHANOTZERO
WRITENUM ENDP

MAIN PROC FAR
    ; return adress
    PUSH DS
    XOR AX, AX
    PUSH AX
    MOV AX, DSEG
    MOV DS, AX
    ; CALL PROCEDURES
        XOR AX, AX ; CLEAR REGISTERS
        XOR DX, DX
        XOR CX, CX
        MOV AH,9 ; WRITE MESSAGE
        LEA DX, INPUTX
        INT 21H
    
        MOV AL, 10 ; LF
        INT 29H
    
        MOV AL, 13 ; CR
        INT 29H
    
    CALL READNUM
    MOV NUMBERS, AX
    MOV AL, 10 ; LF
        INT 29H
    
        MOV AL, 13 ; CR
        INT 29H
        MOV AH,9 ; WRITE MESSAGE
        LEA DX, INPUTY
        INT 21H
    
        MOV AL, 10 ; LF
        INT 29H
    
        MOV AL, 13 ; CR
        INT 29H
    CALL READNUM
    MOV NUMBERS+2, AX
    CALL CALCULATE
    cmp ax, "z"
    JE return
    CALL WRITENUM
    return:
        RET
MAIN ENDP
CSEG ENDS
END MAIN

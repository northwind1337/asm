STSEG SEGMENT PARA STACK "STACK";creates stack segment
DB 64 DUP ( "STACK" );
STSEG ENDS

DSEG SEGMENT PARA PUBLIC "DATA"
SOURCE DB 10, 20, 30, 40
DEST DB 4 DUP ( "?" );? - we allocate memory, but we didn't fill
DSEG ENDS
CSEG SEGMENT PARA PUBLIC "CODE"
MAIN PROC FAR
ASSUME CS: CSEG, DS: DSEG, SS: STSEG

PUSH DS ; saving return address
MOV AX, 0 
PUSH AX

MOV AX, DSEG   ; put address of data segment in DS
MOV DS, AX

MOV DEST, 0 ;fill [0 0 0 0]
MOV DEST+1, 0
MOV DEST+2, 0
MOV DEST+3, 0

MOV AL, SOURCE ;sends data from SOURCE to DEST in reverse order
MOV DEST+3, AL
MOV AL, SOURCE+1
MOV DEST+2, AL
MOV AL, SOURCE+2
MOV DEST+1, AL
MOV AL, SOURCE+3
MOV DEST, AL ; = [40 30 20 10]
RET
MAIN ENDP
CSEG ENDS
END MAIN

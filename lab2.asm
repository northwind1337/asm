stseg SEGMENT PARA STACK "STACK"
  db 64 dup ("STACK")
stseg ENDS

dtseg SEGMENT PARA PUBLIC "DATA"
    buf db 7, ?, 7 dup ('?')        ; 6 chars + newline (enter), ? is for real number of inputted chars
                                    ; reserve 7 bytes for the  buffer itself
    
    
    
    num dw -32768                   ; define word (16 bit = 2 bytes)
    zeronum db 0                    ; is our number negative. If so =1 or 0 otherwise
    errortxt db ("wrong input! $")
    inputtext db ("number: $")
    answertext db (" - 78 = $")
dtseg ENDS

cdseg SEGMENT PARA PUBLIC "CODE"        
    main proc far
    assume ds:dtseg, ss:stseg, cs:cdseg    
    
    push ds         ; saving retrun address
    sub ax, ax      ; AX - AX  = 0 subtract
    push ax
    
    
    mov ax, dtseg   ; put address of data segment in DS  
    mov ds, ax
    
    
    lea dx, inputtext ; lea = load effective address (loads address of inputtext into DX)
    mov ah, 9 
    int 21h             ; 9th function of 21st interrupt = print string to console

    fstart:
        call numscan
        call newline
        call numoutput
        lea dx, answertext  
        mov ah, 9  
        int 21h    
        mov ax, num
        sub ax, 78    
        jno er    
        lea dx, errortxt    
        mov ah, 9
        int 21h    
        call error
        mov zeronum, 0
        sub ax, ax   
        sub bx, bx
        sub cx, cx
        sub dx, dx
        jmp fstart     
        er:    
            mov num, ax
            call numoutput
    ret
    
    numscan proc    
        start:
            mov ah, 10      ; 
            lea dx, buf     ; address of buffer gets loaded into DX 
            int 21h         ; 10th function of 21th interrupt = reads chars from console to buffer
            
            sub ax, ax      ; AX=0   
            sub bx, bx      ; BX=0
            sub cx, cx      ; CX=0
            mov cl, buf + 1 ; CL = number of chars inputted
            lea di, buf + 2 ; DI = address of the start of inputted chrs themselves
        s1:
            mov bl, [di]    ; BL = first char that was inputted (adress transfer)   
            sub bl, '0'     ; convert ASCII symbol into real number    
            
            cmp bl, 9       ; COMPARE BL to 9
            ja errnotnum    ; (jump-if-above) if BL bigger than 9, jump 
            cmp bl, 0       ; COMPARE BL to 0
            jb errnotnum    ; (jump-if-below) if BL is lower than 0, jump
            mov dx, 10      ; 
            imul dx
            jo errrestart   ; (jump-if-overflow) 
            add ax, bx
            jo errrestart   ; (jump-if-overflow)
            
            sub bx, bx
            jmp end5
            errnotnum:   
                add bl, '0'
                mov dl, buf + 1
                cmp cl, dl    
                jne errrestart
                cmp bl, '-'   
                je isneg 
            errrestart:
                call error
                mov zeronum, 0    
                jmp start    
            isneg:
                mov zeronum, 1    
            end5:
                inc di       ; increment DI
            loop s1
        
        cmp zeronum, 1        ; if minus was inputted
        jne isnotneg    ; jump-not-equal
        neg ax   
        isnotneg:    
            mov num, ax
            ret
        numscan ENDP
    
    newline proc   
        push ax    
        sub ax, ax 
        mov al, 10 ; line feed character
        int 29h ;   output character from AL
        pop ax    
        ret
    newline ENDP
    
    error proc             
        call newline       
        mov ah, 9          
        lea dx, errortxt   
        int 21h            
        
        call newline       
        lea dx, inputtext  
        mov ah, 9          
        int 21h            
        ret
    error ENDP
    
    numoutput proc        
        mov bx, num       
        or  bx, bx    ;didn't change BX, but set flags    
        jns m1        ; (jump-if-not-sign-flag)
        mov al, '-'   ; print minus    
        int 29h
        neg bx            
        m1:
            mov ax, bx    
            sub cx, cx    
            mov bx, 10    
        m2:
            sub dx, dx    
            div bx    ; divide AX by BX(10), store result in AX and remainder in DX    
            add dl, '0'; converts decimal to char   
            push dx       
            inc cx        
            test ax, ax ; to set flags  
            jnz m2        ; jump-if-not-0
        m3:
            pop ax        
            int 29h       
            loop m3 
        ret
    numoutput ENDP
    
main ENDP
cdseg ENDS
end main
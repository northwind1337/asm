stseg SEGMENT PARA STACK "STACK"
  db 64 dup ("STACK")
stseg ENDS

dtseg SEGMENT PARA PUBLIC "DATA"
    buf db 7, ?, 7 dup ('?')
    num dw -32768
    zeronum db 0
    errortxt db ("Incorrect input! $")
    inputtext db ("Enter the number: $")
    answertext db (" - 78 = $")
dtseg ENDS

cdseg SEGMENT PARA PUBLIC "CODE"        
    main proc far
    assume ds:dtseg, ss:stseg, cs:cdseg    
    
    push ds         
    sub ax, ax
    push ax
    mov ax, dtseg    
    mov ds, ax
    lea dx, inputtext
    mov ah, 9 
    int 21h   

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
            mov ah, 10    
            lea dx, buf   
            int 21h
            sub ax, ax    
            sub bx, bx
            sub cx, cx
            mov cl, buf + 1 
            lea di, buf + 2 
        s1:
            mov bl, [di]    
            sub bl, '0'     
            
            cmp bl, 9
            ja errnotnum    
            cmp bl, 0
            jb errnotnum    
            mov dx, 10
            imul dx
            jo errrestart   
            add ax, bx
            jo errrestart   
            
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
                inc di   
            loop s1
        
        cmp zeronum, 1   
        jne isnotneg    
        neg ax   
        isnotneg:    
            mov num, ax
            ret
        numscan ENDP
    
    newline proc   
        push ax    
        sub ax, ax 
        mov al, 10 
        int 29h    
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
        or  bx, bx        
        jns m1            
        mov al, '-'       
        int 29h
        neg bx            
        m1:
            mov ax, bx    
            sub cx, cx    
            mov bx, 10    
        m2:
            sub dx, dx    
            div bx        
            add dl, '0'   
            push dx       
            inc cx        
            test ax, ax   
            jnz m2        
        m3:
            pop ax        
            int 29h       
            loop m3 
        ret
    numoutput ENDP
    
main ENDP
cdseg ENDS
end main

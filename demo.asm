
code segment para
assume cs:code
org 100h                ;prog seg prefix addrss
jmp initze              ;hex no of 256
savint dd ?             ;for saving address of es:bx
count dw 0000h          ;count of 17 tics
hours db ?
mins db ?
sec db ?
curX1 db 0
curY1 db 0
curX2 db 0
curY2 db 0
temp1 db ?
temp2 db ?
;-----------------------------------



testnum:
        push ax         ;store all the contents of register
        push bx         ;(not to change original values of register)
        push cx
        push dx
        push cs
        push es
        push si
        push di
        mov ax,0b800h   ;starting address of display
        mov es,ax
        mov cx,count
        inc cx
        mov count,cx
        cmp cx,011h
        jne exit
        mov cx,0000h
        mov count,cx
        call time
	call mouse
	
exit:
        pop di
        pop si
        pop es
        pop ds
        pop dx
        pop cx
        pop bx
        pop ax
        jmp cs:savint   ;jump to normal isr

;------------------convert time procedure--------------------
convert proc
        and al,0f0h
        ror al,4
        add al,30h
        call disp
        mov al,dh
        and al,0fh
        add al,30h
        call disp
        ret
endp

;------------------------time procedure----------------
time proc
        mov ah,02h      ;getting current time system clk
        int 1ah
        mov hours,ch
        mov mins,cl
        mov sec,dh
        mov bx,0f90h    ;location for displaying clk
        mov al,hours
        mov dh,hours
        call convert
        mov al,':'
        call disp
        mov al,mins
        mov dh,mins
        call convert
        mov al,':'
        call disp
        mov al,sec
        mov dh,sec
        call convert



        ret
endp



;-----------------------display procedue----------------
disp proc
        mov ah,0ffh      ;for setting attribute
        mov es:bx,ax    ;write into video buffer
        inc bx
        inc bx
	mov temp1, bh
	mov temp2, bl
        ret
endp
;---------------mouse position ----------------
mouse proc
	; reset mouse and get its status:
	

	mov ax, 1
	int 33h	
		
check_mouse:
	mov ax, 3h
	int 33h
	
	mov bx, 0f00h
	;--show x--
	mov al, 'x'
	call disp
	mov al, '='
	call disp
	mov ax, cx
	
	call print_ax

	
	;--show y--
	mov bh, temp1
	mov bl, temp2
	mov al, ' '
	call disp
	mov al, 'y'
	call disp
	mov al, '='
	call disp
	mov ax, dx
	call print_ax
	ret



endp
;------------------print mouse procedure--------------------


print_ax proc
cmp ax, 0
jne print_ax_r
    push ax
    mov al, '0'
    call disp
    pop ax
    ret 
print_ax_r:
	
	push ax                
        push cx
        push dx
        push cs
        push es
        push si
        push di
	
    	
    mov dx, 0
    cmp ax, 0
    je pn_done
	
    mov bx, 10
    div bx   
	
    call print_ax_r
    mov ax, dx
    add al, 30h
    mov bh, temp1
    mov bl, temp2
    call disp 
    jmp pn_done
pn_done:
	
     	pop di
        pop si
        pop es
        pop ds
        pop dx
        pop cx
        pop ax
	  
    ret  
endp
;------------------initialization------------------------
initze:
        push cs
        pop ds
        cli             ;clear int flag
        mov ah,35h      ;get orignal add
        mov al,08h      ;intrrupt no
        int 21h
        mov word ptr savint,bx
        mov word ptr savint+2,es
        mov ah,25h      ;set int add
        mov al,08h
        mov dx,offset testnum   ;new add for intrrupt
        int 21h
        mov ah,31h              ;make prog resident(request tsr)
        mov dx,offset initze    ;size of program
        sti
        int 21h                 ;set intrrupt flag
code ends
end



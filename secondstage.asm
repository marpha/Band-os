;Second stage bootloader for band-os

 
org		0x1000				; We are loaded by BIOS at 0x7C00
 
bits	16					; We are still in 16 bit Real Mode
jmp Start

Data:
msg_loaded db			0dh,0ah,"Second stage bootloader loaded",0
msg_kernel_loaded db	0dh,0ah,"kernel loaded to memory",0
msg_protected_entered db	0dh,0ah,"Protected mode entered",0
msg_a20_gate_enabled db 0dh,0ah,"A20 gate is now enabled",0
msg_interrupt_disabled db 0dh,0ah,"Interrupt is now disabled",0
msg_gdt_loaded db 0dh,0ah,"Global description table is loaded",0




print:		;Teletype printing
lodsb 		;load DS:(E)SI into Al and increment or decrement according to flag
or al,al	;check if al is zero to stop printing
jz endprint
mov ah, 0eh	;print character
int 10h
jmp print

endprint:
ret

Start:
xor ax,ax
mov ds,ax
mov es,ax
mov ah,0eh
mov si,msg_loaded
call print

;Query BIOS for upper and lower memory limit

;load kernel from disk to memory
disk_reset:
mov ah,0	;reset floppy controller
mov dl,0	;floppy drive no.
int 0x13	;interrupt for floppy functions
jc disk_reset	;interrupt sets carry if error occurs

mov ax,0xa00	;load kernel to memory 0xa000	
mov es,ax
xor bx,bx	;clear register bx

disk_load:
mov ah,0x02	;BIOS read sector function
mov al,36	;no. of sectors from start
mov ch,0	;select cylinder no.
mov dh,0	;select head no.
mov cl,5	;select sector no. on track(note sector no. starts from 1)
mov dl,0	;read drive 0

int 0x13	;BIOS interrupt and jc disk_error jump if error occurs

;check if all sectors are loaded
cmp al,36
jne disk_load

mov si,msg_kernel_loaded
call print

;Enable A20 gate
mov ah,0x24
int 15h		;interrupt for enabling a20 gate
;print that a20 gate is enabled
mov si,msg_a20_gate_enabled
call print 

;disable interrupt	
cli 				;leave this if you want interrupts to have fun 
;print that interrupt is disabled
mov si,msg_interrupt_disabled
call print


;load global description table
gdt_start:
gdt_null:	;it is mandatory to have first table null
dd 0x0
dd 0x0

gdt_code:
dw 0xffff
dw 0x0
db 10011010b
db 11001111b
db 0x0

gdt_data:
dw 0xffff
dw 0x0
db 0x0
db 10010010b
db 11001111b
db 0x0

gdt_end:

;GDT descriptor
gdt_descriptor:
dw gdt_end -gdt_start -1
dd gdt_start

code_segment equ gdt_code -gdt_start
data_segment equ gdt_data - gdt_start
;now tell the cup about the gdt we prepared
lgdt [gdt_descriptor]


;switch protected mode
;set the first bit of control register cr0
;we can use or to keep other bits intact
mov eax,cr0
or eax,0x1
mov cr0,eax		;now we are in 32 bit mode

;load kernel into high address


;jump to kernel( that's it :) )


hlt					; halt the system
;just add some more size to disk
times 256 dw 0xf0f0
times 256 dw 0xf0f0
times 256 dw 0xf0f0
times 256 dw 0xf0f0
times 256 dw 0xf0f0
times 256 dw 0xf0f0
times 256 dw 0xf0f0
times 256 dw 0xf0f0
times 256 dw 0xf0f0
times 256 dw 0xf0f0
times 256 dw 0xf0f0
times 256 dw 0xf0f0
times 256 dw 0xf0f0
times 256 dw 0xf0f0
times 256 dw 0xf0f0
times 256 dw 0xf0f0
times 256 dw 0xf0f0
times 256 dw 0xf0f0
times 256 dw 0xf0f0
times 256 dw 0xf0f0
times 256 dw 0xf0f0
times 256 dw 0xf0f0
times 256 dw 0xf0f0
times 256 dw 0xf0f0
times 256 dw 0xf0f0
times 256 dw 0xf0f0
times 256 dw 0xf0f0
times 256 dw 0xf0f0
times 256 dw 0xf0f0
times 256 dw 0xf0f0
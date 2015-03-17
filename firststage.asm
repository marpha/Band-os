;first stage bootloader for band-os


bits 16
org 0x7c00

jmp code

Data:
osname db "Band-os",0
msg_loading db 0dh,0ah,"loading first stage bootloader", 0	;0dh,0ah for printing in new line
msg_disk_reset db 0dh,0ah,"Disk succesfully reset", 0
msg_disk_error db 0dh,0ah,"Disk read error ----Exiting-----", 0
msg_disk_load db 0dh,0ah,"jumping to  second stage bootloader", 0

print:		;Teletype printing
lodsb 		;load DS:(E)SI into Al and increment or decrement according to flag
or al,al	;check if al is zero to stop printing
jz endprint
mov ah, 0eh	;print character
int 10h
jmp print

endprint:
ret


disk_loaded:
mov bx,msg_disk_load
jmp print

code:
mov ax,0x00 ;we have org 0x7c00
mov ds,ax   ;so no need to set segment registers (can't set ds directly)
mov es,ax   ;as assembler automatically adjust it
mov bx,msg_loading
call print


;now load the second stage bootloader from floopy
;to address 0x1000 in memory


disk_reset:
mov ah,0	;reset floppy controller
mov dl,0	;floppy drive no.
int 0x13	;interrupt for floppy functions
jc disk_reset	;interrupt sets carry if error occurs

mov bx,msg_disk_reset
;call print

;Now read the second stage bootloader from sector 2 and load to
;address 0x1000 in memory

mov ax,100	
mov es,ax
xor bx,bx	;clear register bx

disk_load:
push dx
mov ah,0x02	;BIOS read sector function
mov al,1	;no. of sectors from start
mov ch,0	;select cylinder no.
mov dh,0	;select head no.
mov cl,2	;select sector no. on track(note sector no. starts from 1)
mov dl,0	;read drive 0

int 0x13	;BIOS interrupt and jc disk_error jump if error occurs

;check if all sectors are loaded
;pop dx
;cmp dh,al	;and jump if not equal and show error

;if successful print this message
;mov bx,msg_disk_load
;call print

;Now jump to the 2nd stage bootloader code
jmp 0x100:0x00

times 510-($-$$) db 0x00
dw 0xAA55
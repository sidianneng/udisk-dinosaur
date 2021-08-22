; 
; Registers used: R19, R21, R22, R20 (Tx)


#include <avr/io.h>

sprite_obstacle:
.byte 0x08,0x0c,0x08,0x3f,0x1e,0x0c

#define col_cnt     R19
#define x_pos       R21
#define sprite_w    R22
#define tmp         R18

; .section .data
; enemy_pos: .space 3

.section .text
.global print_fly_enemies

print_fly_enemies:
; TWI Start
    rcall   start
    ldi     R24, 0x78
    rcall   Tx
    ldi     R24, 0x40
    rcall   Tx
    
; Init print enemies
    ldi     col_cnt, 0x00       ; Start from column 0
    ldi     YL, lo8(enemy_pos)  ; Pointer to enemies position 
    ldi     YH, hi8(enemy_pos)
    ld      x_pos, Y+           ; Load 1st enemy position
	mov		tmp, x_pos
	andi    x_pos, 0x7f

loop_comlumns:
    cp      col_cnt, x_pos      ; Compare enemy position with current column drawn
    brne    blank_col           
    ldi     ZL, lo8(sprite_obstacle+0x4000) ; Load sprite position pointer
    ldi     ZH, hi8(sprite_obstacle+0x4000)
    ldi     sprite_w, 5         ; Sprite width -1
print_sprite:
	andi	tmp, 0x80
	cpi		tmp, 0x80
	brsh	test1
	ldi		R24, 0x00
	rjmp	test2
test1:
    ld      R24, Z+             ; Load sprite byte
test2:
    rcall   Tx                  ; Send sprite byte
    inc     col_cnt             ; Increase column count 
    dec     sprite_w            ; Increase sprite byte count 
    brpl    print_sprite        ; Check if the entire sprite is printed
    ld      x_pos, Y+           ; Next Obstacle position
	mov		tmp, x_pos
	andi    x_pos, 0x7f
blank_col:
    ldi     R24, 0x00           ; Lower bit is set to draw the ground
    rcall   Tx                  ; Send data to display RAM
    inc     col_cnt             ; Increase column count 
    cpi     col_cnt, 128        ; Check if the whole display width is printed
    brne    loop_comlumns        
    
; TWI Stop
    rcall   stop

ret
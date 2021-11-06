; 
; Registers used: R18, R19, R20

#define pos1 R18
#define pos2 R19
#define pos3 R20
#define tmp1 R24

#define flag1 R21
#define flag2 R22
#define flag3 R23

#define STEP 3

.section .data
rand: .byte 103     // RNG Seed
.global rand


.section .text
.global update_enemy_pos

update_enemy_pos:	
    lds     pos1, enemy_pos
    lds     pos2, enemy_pos +1
    lds     pos3, enemy_pos +2
	mov		flag1, pos1
	mov		flag2, pos2
	mov		flag3, pos3
	andi	flag1, 0x80
	andi	flag2, 0x80
	andi	flag3, 0x80
	andi	pos1, 0x7f
	andi	pos2, 0x7f
	andi	pos3, 0x7f
    
; Update position Enemy 3
    subi    pos3, STEP         ; Move enemy position by STEP
    brpl    enemy_generated    ; If position is <=0 then generate the enemy
    
; Generate enemy  
    ldi     pos3, 0x00
    cpi     pos2, 80       ; If enemy 2 position>80 no new enemy(min distance between two enemies is 40)
    brpl    enemy_generated
    cpi     pos2, 60        ; Generate enemy 3 if enemy 2 is in x<60 (max distance between two enemies is 60)
    brmi    new_enemy
; Xorshift RNG (kind of...)
    lds     tmp1, rand      ; Load previous random number
	inc		tmp1
    mov     pos3, tmp1      ; Copy it in a variable
    lsl     pos3            ; Shift left by 1 position
    eor     tmp1, pos3      ; XOR the two numbers
    eor     tmp1, R16       ; XOR with player height that is quite random
    sts     rand, tmp1      ; Store the new random number
    ldi     pos3, 0x00      
    cpi     tmp1, 190       ; If the random number is greater than 190 generate a new one
    brlo    enemy_generated
new_enemy:    
    ldi     pos3, 120       ; A new enemy is generated
	ldi		flag3, 0x00
	lds     tmp1, rand
	andi    tmp1, 0x01
	cpi		tmp1, 0x01 
	brlo    enemy_generated
	ori		pos3, 0x80
	ldi		flag3, 0x80

enemy_generated:
; Update position Enemy 2
    subi    pos2, STEP         ; Move enemy position by STEP
    brpl    .+6                ; If the position is negative than swap it with Enemy 3 
    mov     pos2, pos3
	mov		flag2,flag3
    ldi     pos3, 0x00
    
; Update position Enemy 1
    subi    pos1, STEP         ; Move enemy position by STEP
    brpl    .+10
    mov     pos1, pos2
	mov		flag1,flag2
    mov     pos2, pos3
	mov		flag2,flag3
    ldi     pos3, 0x00

    ; store variables in SRAM
	or		pos1, flag1
	or		pos2, flag2
	or		pos3, flag3
    sts     enemy_pos, pos1
    sts     enemy_pos +1, pos2
    sts     enemy_pos +2, pos3
ret


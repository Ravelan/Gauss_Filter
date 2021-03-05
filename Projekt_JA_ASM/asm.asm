.data
	Gauss SDWORD	 1, 2, 1, 2, 4, 2, 1, 2, 1
.code
filter proc EXPORT
	local sumRed: SDWORD
    local sumGreen: SDWORD 
    local sumBlue: SDWORD 
	local iterator_x: QWORD
	local iterator_y: QWORD
	local x_max: QWORD
	local y_max: QWORD
	local imageInput_width: QWORD
	local imageInput_height: QWORD
	local imageOutput: QWORD
	local imageInput: QWORD
	
	;Zapisanie rejestrow RBP,RDI,RSP
	push RBP      
    push RDI                
    push RSP

	xor rax, rax

	
	mov sumRed, eax
	mov sumGreen, eax
	mov sumBlue, eax
	mov iterator_x, rax
	mov iterator_y, rax
	mov rax, rcx
	mov imageInput, rax

	;zapisanie imageInput_width i imageInput_height w zmiennych
	mov rax, rdx
	mov rbx, 3
	mul rbx
	mov imageInput_width, rax
	mov rax, r8
	mov imageInput_height, rax

	mov imageOutput, r9

	;ustawienie x_max i y_max
	mov rax, imageInput_width
	sub rax, 6
	mov x_max, rax
	mov rax, imageInput_height
	sub rax, 2
	mov y_max, rax

	;iteracja przez tablice
PETLAY:
	mov ecx, 0
	mov edi, 0
	inc iterator_y
	mov iterator_x, 0

PETLAX:
	add iterator_x, 3
	xor rax, rax
	mov sumRed, eax;
	mov sumGreen, eax;
	mov sumBlue, eax;


	; #################### TOP LEFT ############################
	; ####################    RED   ############################
	mov rax, iterator_y		
	dec rax					; decrease iterator_y value
	mul imageInput_width		; multiply  it by imageInput_width
	add rax, iterator_x		; add iterator_x to rax
	sub rax, 3				; move 3 positions back (1 pixel)
	add rax, 0				; move to RED pixel (1=GREEN, 2=BLUE)
	add rax, imageInput
	xor rbx, rbx			; zero on rbx
	mov bl, [rax]			
	xor rax, rax			; zero on rax
	mov eax, ebx			; move ebx to eax
	imul [Gauss + 0]		; multiply by mask
	add sumRed, eax			; add eax to sumRed

	; ####################    GREEN   ############################
	mov rax, iterator_y		
	dec rax
	mul imageInput_width
	add rax, iterator_x
	sub rax, 3				
	add rax, 1				
	add rax, imageInput
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [Gauss + 0]		
	add sumGreen, eax

	; ####################    BLUE   ############################
	mov rax, iterator_y		
	dec rax
	mul imageInput_width
	add rax, iterator_x
	sub rax, 3				
	add rax, 2				
	add rax, imageInput
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [Gauss + 0]		
	add sumBlue, eax


	; #################### TOP MIDDLE ##########################
	; ####################    RED   ############################
	mov rax, iterator_y		
	dec rax
	mul imageInput_width
	add rax, iterator_x
	add rax, 0				
	add rax, 0				
	add rax, imageInput
	xor rbx, rbx
	mov bl, [rax]				
	xor rax, rax
	mov al, bl
	imul [Gauss + 4]		
	add sumRed, eax

	; ####################    GREEN   ############################
	mov rax, iterator_y		
	dec rax
	mul imageInput_width
	add rax, iterator_x
	add rax, 0				
	add rax, 1				
	add rax, imageInput
	xor rbx, rbx
	mov rbx, [rax]
	xor rax, rax
	mov al, bl
	imul [Gauss + 4]		
	add sumGreen, eax

	; ####################    BLUE    ############################
	mov rax, iterator_y		
	dec rax
	mul imageInput_width
	add rax, iterator_x
	add rax, 0				
	add rax, 2				
	add rax, imageInput
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [Gauss + 4]		
	add sumBlue, eax


	; #################### TOP RIGHT ###########################
	; ####################    RED   ############################
	mov rax, iterator_y		
	dec rax
	mul imageInput_width
	add rax, iterator_x
	add rax, 3				
	add rax, 0				
	add rax, imageInput
	xor rbx, rbx
	mov bl, [rax]				
	xor rax, rax
	mov al, bl
	imul [Gauss + 8]		
	add sumRed, eax

	; ####################    GREEN   ############################
	mov rax, iterator_y		
	dec rax
	mul imageInput_width
	add rax, iterator_x
	add rax, 3				
	add rax, 1				
	add rax, imageInput
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [Gauss + 8]		
	add sumGreen, eax

	; ####################    BLUE   ############################
	mov rax, iterator_y		
	dec rax
	mul imageInput_width
	add rax, iterator_x
	add rax, 3				
	add rax, 2				
	add rax, imageInput
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [Gauss + 8]		
	add sumBlue, eax


	; #################### MIDDLE LEFT ############################
	; ####################     RED     ############################

	mov rax, iterator_y		
	mul imageInput_width
	add rax, iterator_x
	sub rax, 3				
	add rax, 0				
	add rax, imageInput
	xor rbx, rbx
	mov bl, [rax]			
	xor rax, rax
	mov al, bl					
	imul [Gauss + 12]		
	add sumRed, eax

	; ####################    GREEN   ############################
	mov rax, iterator_y	
	mul imageInput_width
	add rax, iterator_x
	sub rax, 3				
	add rax, 1				
	add rax, imageInput
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [Gauss + 12]		
	add sumGreen, eax

	; ####################    BLUE   ############################
	mov rax, iterator_y	
	mul imageInput_width
	add rax, iterator_x
	sub rax, 3				
	add rax, 2				
	add rax, imageInput
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [Gauss + 12]		
	add sumBlue, eax


	; #################### MIDDLE MIDDLE ############################
	; ####################      RED      ############################
	mov rax, iterator_y		
	mul imageInput_width
	add rax, iterator_x
	sub rax, 0				
	add rax, 0				
	add rax, imageInput
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl					
	imul [Gauss + 16]		
	add sumRed, eax
	

	; ####################    GREEN   ############################
	mov rax, iterator_y	
	mul imageInput_width
	add rax, iterator_x
	sub rax, 0				
	add rax, 1				
	add rax, imageInput
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [Gauss + 16]		
	add sumGreen, eax

	; ####################    BLUE   ############################
	mov rax, iterator_y	
	mul imageInput_width
	add rax, iterator_x
	sub rax, 0				
	add rax, 2				
	add rax, imageInput
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [Gauss + 16]		
	add sumBlue, eax


	; #################### MIDDLE RIGHT ############################
	; ####################     RED     #############################
	mov rax, iterator_y		
	mul imageInput_width
	add rax, iterator_x
	add rax, 3				
	add rax, 0				
	add rax, imageInput
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl				
	imul [Gauss + 20]		
	add sumRed, eax

	; ####################    GREEN   ############################
	mov rax, iterator_y	
	mul imageInput_width
	add rax, iterator_x
	add rax, 3				
	add rax, 1				
	add rax, imageInput
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [Gauss + 20]		
	add sumGreen, eax

	; ####################    BLUE   ############################
	mov rax, iterator_y		
	mul imageInput_width
	add rax, iterator_x
	add rax, 3				
	add rax, 2				
	add rax, imageInput
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl 
	imul [Gauss + 20]		
	add sumBlue, eax


	; #################### BOTTOM LEFT ############################
	; ####################     RED     ############################
	mov rax, iterator_y	
	inc rax					
	mul imageInput_width
	add rax, iterator_x
	sub rax, 3				
	add rax, 0				
	add rax, imageInput
	xor rbx, rbx
	mov bl, [rax]			
	xor rax, rax
	mov al, bl	
	imul [Gauss + 24]		
	add sumRed, eax																			
																							
	; ####################    GREEN   ############################
	mov rax, iterator_y	
	inc rax					
	mul imageInput_width
	add rax, iterator_x
	sub rax, 3				
	add rax, 1				
	add rax, imageInput
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [Gauss + 24]		
	add sumGreen, eax

	; ####################    BLUE   ############################
	mov rax, iterator_y		
	inc rax					
	mul imageInput_width
	add rax, iterator_x
	sub rax, 3				
	add rax, 2				
	add rax, imageInput
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [Gauss + 24]		
	add sumBlue, eax


	; #################### BOTTOM MIDDLE ############################
	; ####################      RED      ############################
	mov rax, iterator_y	
	inc rax				
	mul imageInput_width
	add rax, iterator_x
	sub rax, 0				
	add rax, 0				
	add rax, imageInput
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [Gauss + 28]		
	add sumRed, eax

	; ####################    GREEN   ############################
	mov rax, iterator_y	
	inc rax				
	mul imageInput_width
	add rax, iterator_x
	sub rax, 0				
	add rax, 1				
	add rax, imageInput
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [Gauss + 28]		
	add sumGreen, eax

	; ####################    BLUE   ############################
	mov rax, iterator_y		
	inc rax				
	mul imageInput_width
	add rax, iterator_x
	sub rax, 0				
	add rax, 2				
	add rax, imageInput
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [Gauss + 28]		
	add sumBlue, eax


	; #################### BOTTOM RIGHT ############################
	; ####################      RED     ############################
	mov rax, iterator_y	
	inc rax				
	mul imageInput_width
	add rax, iterator_x
	add rax, 3				
	add rax, 0				
	add rax, imageInput
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [Gauss + 32]		
	add sumRed, eax

	; ####################    GREEN   ############################
	mov rax, iterator_y	
	inc rax				
	mul imageInput_width
	add rax, iterator_x
	add rax, 3				
	add rax, 1				
	add rax, imageInput
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [Gauss + 32]		
	add sumGreen, eax

	; ####################    BLUE   ############################
	mov rax, iterator_y	
	inc rax				
	mul imageInput_width
	add rax, iterator_x
	add rax, 3				
	add rax, 2				
	add rax, imageInput
	xor rbx, rbx
	mov bl, [rax]
	xor rax, rax
	mov al, bl
	imul [Gauss + 32]		
	add sumBlue, eax


	; ####################    NORMALIZE   ############################
	xor rax, rax
	xor rbx, rbx

	;xor rcx, rcx
	;mov eax,sumRed
	;mov rcx,16			;Divide by 16
	;div rcx
	;mov sumRed,eax

	sar sumRed,4			;Right rotation by 4 (equals division by 16)
	mov eax, sumRed
	cmp sumRed, 255		;if over 255 set 255, if less than 0 set 0
	JL LESS_RED
	mov eax, 255
	mov sumRed, eax
	JMP GREEN
LESS_RED:
	cmp eax, 0
	JG GREEN
	mov eax, 0
	mov sumRed, eax

GREEN:
	xor rax, rax
	xor rbx, rbx

	;xor rcx, rcx
	;mov eax,sumGreen
	;mov rcx,16			;Divide by 16
	;div rcx
	;mov sumGreen,eax

	sar sumGreen,4			;Right rotation by 4 (equals division by 16)

	mov eax, sumGreen
	cmp sumGreen, 255		;if over 255 set 255, if less than 0 set 0
	JL LESS_GREEN
	mov eax, 255
	mov sumGreen, eax
	JMP BLUE
LESS_GREEN:
	cmp eax, 0
	JG BLUE
	mov eax, 0
	mov sumGreen, eax

BLUE:
	xor rax, rax
	xor rbx, rbx

	;xor rcx, rcx
	;mov eax,sumBlue
	;mov rcx,16			;Divide by 16
	;div rcx
	;mov sumBlue,eax

	sar sumBlue,4			;Right rotation by 4 (equals division by 16)
	mov eax, sumBlue
	cmp sumBlue, 255		;if over 255 set 255, if less than 0 set 0
	JL LESS_BLUE
	mov eax, 255
	mov sumBlue, eax
	JMP SAVE
LESS_BLUE:
	cmp eax, 0
	JG SAVE
	mov eax, 0
	mov sumBlue, eax

SAVE:					; saving new pixel in imageOutput array

	;mov rcx, 3
; ####################    SAVE RED   ############################

	xor rax, rax
	mov rax, iterator_y		
	mul imageInput_width
	add rax, iterator_x
	add rax, 0				; move to RED value
	add rax, imageOutput
	xor rbx, rbx
	mov ebx, sumRed
	mov [rax], bl

; ####################    SAVE GREEN  ############################
	xor rax, rax
	mov rax, iterator_y		
	mul imageInput_width
	add rax, iterator_x
	add rax, 1				; move to GREEN value
	add rax, imageOutput
	xor rbx, rbx
	mov ebx, sumGreen
	mov [rax], bl

; ####################    SAVE BLUE  ############################
	xor rax, rax
	mov rax, iterator_y		
	mul imageInput_width
	add rax, iterator_x
	add rax, 2				; move to BLUE value
	add rax, imageOutput
	xor rbx, rbx
	mov ebx, sumBlue
	mov [rax], bl

	mov rax, iterator_x		;koniec petli x
	cmp rax, x_max
	JB PETLAX

	mov rax, iterator_y		;koniec petli y
	cmp rax, y_max
	JB PETLAY

					; przywrócenie wartoœci rejestrow ze stosu
	pop rsp        
    pop rdi                        
    pop rbp
	
	xor rax, rax
	ret

filter endp

end
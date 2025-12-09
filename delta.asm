.model small

linieNoua macro
	mov ah, 02h
	mov dl, 0ah
	int 21h
	mov dl, 0dh
	int 21h
endm
afisMesaj macro mesaj
	mov dx, offset mesaj
	mov ah, 09h
	int 21h
endm

.stack 200h
.data
	mesajInt db "Considerand ecuatia de gradul 2 ax^2+bx+c=0 introduceti valori intregi pentru$"
	mesajA db "a=$"
	mesajB db "b=$"
	mesajC db "c=$"
	mesajD db "Delta este negativ, solutii complexe$"
	mesajx0 db "Solutia unica este x = $"
	mesajx1 db "Solutiile sunt x1 = $"
	mesajx2 db " si x2 = $"
	mesajinf db "Sunt o infinitate de solutii$"
	mesajab0 db "Nu exista solutii$"
	mesajax2 db "x^2$"
	mesajbx  db "x$"
	cta dw 0;a
	ctb dw 0;b
	ctc dw 0;c
	ct  dw 0;variabila de calcule generale
	
	ctd dw 0 ;delta
	csq dw 0 ;rad delta
	cbb dw 0 ;b^2
	cac dw 0 ;4ac
	x   dw 0;x square root
	y   dw 0;y square root
	
	semn  dw 0;semn de calcule generale
	semna dw 0;semn a
	semnb dw 0;semn b
	semnc dw 0;semn c
	
	cdi   dw 0; constanta de impartit
	cim   dw 0; constanta impartitor
	sdi   dw 0; semn di
	sim   dw 0; semn im
	steag dw 0; steagul pentru afisare cu virgula
.code
afisCifre1 macro cx
	afiseazaCifre1:
	pop dx
	add dl, 48
	mov ah, 02h
	int 21h
	loop afiseazaCifre1
endm
afisareVirgula macro cx
	cmp cx, 1
	jne skipZero
		mov dx, 30h
		mov ah, 02h
		int 21h
		;scrie zero
		mov dx, 2ch
		mov ah, 02h
		int 21h
		;scrie virgula
		pop dx
		add dl, 48
		mov ah, 02h
		int 21h
		;scrie cifra
		jmp faraVirgula1
	skipZero:
	
	sub cx, 1
	afisCifre1 cx
	pop cx
	mov ax, cx
	cmp ax, 0
		je faraVirgula1
		mov dx, 2ch
		mov ah, 02h
		int 21h
		;scrie virgula
		mov dx, cx
		add dx, 48
		mov ah, 02h
		int 21h
		;scrie cifra
	faraVirgula1:
endm
citireNumar proc

	mov ax, @data
	mov ds, ax
	mov dx, 0
	mov cx, 10
	mov bh, 0
	
	skipSemn:
	cmp al, 2dh
	jne schimbaSemn
	mov ax, 1
	mov semn, ax
	schimbaSemn:
	
	citireCifra1:
	
		mov ah, 01h
		int 21h
		;citesc cifra
		cmp al, 13
		je gataNumarul
		;verific daca este enter
		cmp al, 2dh
		je skipSemn
		;verific daca este minus
		sub al, 48
		mov bl, al
		;schimb codul ascii in cifra
		mov ax, dx
		mul cx
		add ax, bx
		mov dx, ax
		;adaug cifra la numar
	jmp citireCifra1
	gataNumarul:
	;am format numarul in dx
ret
endp
afisareNumar proc
	mov ax, @data
	mov ds, ax
	cmp semn, 1
	jne afisMinus
	mov ah, 02h
	mov dl, 2dh
	int 21h
	afisMinus:
	;am afisat semnul
	mov dx, ct
	mov ax, ct
	mov bx, 10
	mov cx, 0
	descompune:
		mov dx, 0
		div bx
		push dx
		inc cx
		cmp ax, 0
		je gataNr
	jmp descompune
	gataNr:
	;am stocat cifrele in stiva in ordine inversa
	mov ax, steag
	cmp ax, 0
	jne scrieCuVirgula
		afiseazaCifre:
		pop dx
		add dl, 48
		mov ah, 02h
		int 21h
		loop afiseazaCifre
		jmp amScrisNumarul
	scrieCuVirgula:
		afisareVirgula cx
	amScrisNumarul:
	;am afisat cifrele
ret
endp
catImpartire proc
	mov ax, @data
	mov ds, ax
	mov dx, 0
	mov ax, 0
	add ax, sdi
	add ax, sim
	mov bx, 2
	div bx
	mov semn, dx
	;calculez semnul solutiei
	mov dx, 0
	mov ax, cdi
	mov bx, cim
	div bx
	;calculez di/im
	mov dx, 0
	mov bx, 2
	mov dx, 0
	div bx
	;impart la 2
	mov ct, ax
ret
endp
	main:
	
	mov ax, @data
	mov ds, ax
	linieNoua
	afisMesaj mesajInt
	;scrie pe ecran
	linieNoua
	linieNoua
	mov semna, 0
	mov semnb, 0
	mov semnc, 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	mov semn , 0
	afisMesaj mesajA
	call citireNumar
	mov ct, dx
	mov cta, dx
	push semn
	
	pop dx
	mov semna, dx
	;call afisareNumar
	linieNoua
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov semn , 0
	afisMesaj mesajB
	call citireNumar
	mov ct, dx
	mov ctb, dx
	push semn
	
	pop dx
	mov semnb, dx
	;call afisareNumar
	linieNoua
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov semn , 0
	afisMesaj mesajC
	call citireNumar
	mov ct, dx
	mov ctc, dx
	push semn
	
	pop dx
	mov semnc, dx
	;call afisareNumar
	linieNoua
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov ax, cta
	cmp ax, 0;daca a=0
	;jne cazParticular
	je continuare
	jmp cazParticular;clucth
	continuare:
		mov ax, ctb
		cmp ax, 0;daca b=0
			je contCazParticular
			
				mov ax, ctc
				cmp ax, 0
				jne contCalcule
					mov semn, 0
					mov ct, 0
					afisMesaj mesajx0
					call afisareNumar
					jmp finishProgram
				contCalcule:
			
			mov ax, ctc
			mov bx, 10
			mul bx
			mov ctc, ax
	
			mov steag, 1
			
			mov dx, 0
			mov ax, 1
			add ax, semna
			add ax, semnc
			mov bx, 2
			div bx
			mov semn, dx
			mov dx, 0
			mov ax, ctc
			mov bx, ctb
			div bx
			mov ct, ax
			afisMesaj mesajx0
			call afisareNumar
			linieNoua
			;calculez semnul
			jmp finishProgram
		contCazParticular:
		mov ax, ctc
		cmp ax, 0;daca c=0
		jne nuSuntSolutii
		afisMesaj mesajinf
		jmp finishProgram
		nuSuntSolutii:
		afisMesaj mesajab0
		jmp finishProgram
	cazParticular:
	;cazuri particulare pentru a=0 sau a=b=0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov ax, 0
	mov bx, 0
	mov cx, 0
	mov dx, 0
	mov ax, ctb
	mov bx, ctb
	mul bx
	mov ct, ax
	mov cbb, ax
	mov semn, 0
	;call afisareNumar
	;linieNoua
	;afisare b^2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov ax, 0
	mov bx, 0
	mov cx, 0
	mov dx, 0
	mov ax, cta
	mov bx, ctc
	mul bx
	mov bx, 4
	mul bx
	mov ct, ax
	mov cac, ax
	mov ax, 1
	add ax, semna
	add ax, semnc
	mov bx, 2
	div bx
	mov semn, dx
	;calculez semnul
	;call afisareNumar
	;linieNoua
	;afisare 4ac
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov ax, cbb
	mov bx, cbb
	mov cx, cac
	mov dx, 0
	
	cmp semn, 1 ;4ac se scade
	jne adunare
	
	cmp bx, cx;
		jge scadere
		afisMesaj mesajD
		jmp finishProgram
	scadere:
		sub ax, cac
		jmp finCalc
	adunare:
		add ax, cac
	finCalc:
	mov ct, ax
	mov ctd, ax
	mov semn, 0
	;call afisareNumar
	;linieNoua
	;calcul delta
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov ax, ctd
	mov csq, ax
	cmp ctd, 0
	je skipSqrt
	mov ax, 0
	mov bx, 2
	mov cx, ctd
	mov dx, 0
	mov x, cx
	mov y, 1
	squareRoot:
		mov ax, x
		add ax, y
		mov x, ax
		;(x+y)
		mov dx, 0
		mov bx, 2
		div bx
		mov x, ax	
		;(x+y)/2
		mov dx, 0
		mov ax, cx
		mov bx, x
		div bx
		mov y, ax
		;n/x
		mov ax, y
		inc ax
		mov bx, x
		cmp bx, ax
	jg squareRoot
	mov ax, x
	mov ct, ax
	mov csq, ax
	mov semn, 0
	;stegulet pentru debbuging
	skipSqrt:
	
	mov ax, csq
	mov bx, 10
	mul bx
	mov csq, ax
	;inmultesc radacina patrata cu 10
	mov ax, ctb
	mov bx, 10
	mul bx
	mov ctb, ax
	;inmultesc b cu 10
	mov steag, 1
	;steagul care indica printare fancy cu virgula
	;call afisareNumar
	;linieNoua
	;linieNoua
	;calculez radical din delta
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov ax, csq
	cmp ax, 0
	jne douaSolutii
		mov ax, ctb
		mov cdi, ax
		mov ax, semnb
		mov sdi, ax
		inc sdi
		mov ax, cta
		mov cim, ax
		mov ax, semna
		mov sim, ax
	call catImpartire
	afisMesaj mesajx0
	call afisareNumar
	linieNoua
	jmp finishProgram
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	douaSolutii:
	mov ax, semnb
	cmp ax, 1
	jne steag1;caz 1 vezi pe caiet
		mov ax, ctb
		mov bx, csq
		add ax, bx
		
		mov cdi, ax
		mov sdi, 0
		jmp steag3
	steag1:
	mov ax, csq
	mov bx, ctb
	cmp ax, bx
	jl steag2;caz 2 vezi pe caiet
		sub ax, bx
		
		mov cdi, ax
		mov sdi, 0
		jmp steag3
	steag2:;caz 3 vezi pe caiet
		sub bx, ax
		
		mov cdi, bx
		mov sdi, 1
		jmp steag3
	steag3:
		mov ax, cta
		mov cim, ax
		mov ax, semna
		mov sim, ax
		call catImpartire
		afisMesaj mesajx1
		call afisareNumar
	;prima solutie
	mov ax, semnb
	cmp ax, 0
	jne steag4;caz 6 vezi pe caiet
		mov ax, ctb
		mov bx, csq
		add ax, bx
		
		mov cdi, ax
		mov sdi, 1
		jmp steag6
	steag4:
	mov ax, csq
	mov bx, ctb
	cmp ax, bx
	jg steag5;caz 5 vezi pe caiet
		sub bx, ax
		
		mov cdi, bx
		mov sdi, 0
		jmp steag6
	steag5:;caz 4 vezi pe caiet
		sub ax, bx
		
		mov cdi, ax
		mov sdi, 1
		jmp steag6
	steag6:
		mov ax, cta
		mov cim, ax
		mov ax, semna
		mov sim, ax
		call catImpartire
		afisMesaj mesajx2
		call afisareNumar
		linieNoua
	;a doua solutie
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	finishProgram:
	mov ah, 4ch
	int 21h
	end main
	;exit program
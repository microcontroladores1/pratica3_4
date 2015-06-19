; Praticas 3 e 4: Contador de segundos e de pulsos
; Programador: Francisco Edno
;
; A partir de uma chave alavanca o contexto de execucao do microcontrolador
; e selecionado. No contexto 0, e realizada a contagem de segundos. No contexto
; 1 uma contagem de pulsos. Para cada contexto e utilizado um banco de
; registradores diferentes, de modo que o estado do contexto anterior
; seja salvo na memoria. A ideia de mudanca de contexto foi obtida a partir
; do livro do Scott Mackenzie. O objetivo desse projeto e puramente 
; educacional.

; Push button: p2.0, Shift Register: p2.1, p2.2 e p2.3, chave de contexto: p2.4
;
; ----------------------------------------------------------
; Mapa de registradores
; ----------------------------------------------------------
; R0: Contagem binaria
; R1: Parte decimal
; R2: Unidade
;
; Banco 0: Contador de segundos
; Banco 1: Contador de pulsos
; ----------------------------------------------------------


; **********************************************************
; Equates
; **********************************************************

BTN			equ		p2.0												

SHD			equ		p2.1				; Fluxo de dados no registrador	
SHCK		equ		p2.2				; Clock do registrador
SHLTCH		equ		p2.3				; Latch do registrador

CONTSW		equ		p2.4				; Chave seletora de contexto

; **********************************************************
; Configuracoes iniciais
; ********************************************************** 

; O 8052 divide os enderecos do SFRs com 128 bytes extras de memoria ram.
; Essa memoria extra so pode ser acessada por enderecamento indireto,
; por isso a pilha pode ser inicializada nessa regiao

			mov			sp, #80h					; Inicializa a pilha na regiao de memoria extra do 8052

; Inicializa os registradores r0, r1 e r2 dos bancos 0 e 1 com #0

			; Banco 0
			mov		00h, #0
			mov		01h, #0
			mov		02h, #0

			; Banco 1
			mov		08h, #0
			mov		09h, #0
			mov		10h, #0

; ********************************************************** 
; Main
; ********************************************************** 
			acall		DcdCount
			acall		Display
Main:
			jb		CONTSW, Sec		
Pulse:		
			setb	rs0

			acall	DcdCount
			acall	Display

			acall	PulseCT
			ajmp	Exit
Sec:		
			clr		rs0
			acall	SecCT

Exit:		ajmp	Main

; ********************************************************** 
; Sub-Rotinas
; ********************************************************** 

; ----------------------------------------------------------
; PulseCT
; ----------------------------------------------------------
; Contexto de contagem de pulsos
; ----------------------------------------------------------
PulseCT:
			jb		CONTSW, ExitP
			jnb		BTN, PulseCT		; Verifico se o botao foi apertado
CheckSW:
			jb		CONTSW, ExitP
			jb		BTN, CheckSW		; Verifico se o botao foi liberado para contar um pulso

			mov		a, r0       		; Limite da contagem de pulsos
			add		a, #(not 98)		; se r0 conter um numero > 99, a carry vai ser setada

			jnc		Inrement			; Se !(r>98), incremente. Else, pule
			mov		r0, #0
			ajmp	Decode
Inrement:	inc		r0
Decode:		
			acall	DcdCount 
			acall	Display
ExitP:
			ret

; ----------------------------------------------------------
; SecCT
; ----------------------------------------------------------
; Contexto de contagem de segundos
; ----------------------------------------------------------
SecCT:		
			acall	DcdCount
			acall	Display

			mov		a, r0 
			add		a, #(not 58)

			jc		Zero
			inc		r0
			jmp		Ext
Zero:		mov		r0, #0

Ext:		acall	Time

			ret

; ----------------------------------------------------------
; Display
; ----------------------------------------------------------
; Imprime os valores dos registradores r1 e r2 nos displays
; Basicamente, envio bit a bit do acumulador pelo SHD. A cada
; envio dou um pulso de clock.
; ----------------------------------------------------------
Display:
			clr		SHLTCH					; Desabilito a saida do shift

			mov		a, r2					; Envio primeiro a unidade
			acall	SHSend

			mov		a, r1					; Envio depois a dezena
			acall	SHSend

			setb	SHLTCH					; travo a saida do shift

			ret

; ----------------------------------------------------------
; SHSend
; ----------------------------------------------------------
; Envio serial do acumulador para shift register
; ----------------------------------------------------------
SHSend:
			mov		r3, #8					; Contador
Again:		mov		c, acc.7
			mov		SHD, c					; envia a carry para o shift

			acall	CKPulse					; Pulso de clock

			rl		a
			djnz	r3, Again

			ret

; ----------------------------------------------------------
; DcdCount
; ----------------------------------------------------------
; Decodifica o valor do registrador r0 em BCD e joga os
; decimal e a unidade nos registradores r1 e r2
; ----------------------------------------------------------
DcdCount:
			mov		a, r0
			mov		b, #10

			div		ab

			acall	LKDisp					; Decodifca binario para o display e bota no acumulador
			mov		r1, a					; joga a dezena no r1

			mov		a, b
			acall	LKDisp					; Decodifca binario para o display e bota no acumulador
			mov		r2, a					; joga a unidade no r2

			ret

; ----------------------------------------------------------
; LKDisp
; ----------------------------------------------------------
; Look-up table para decodificacao binario -> display
; ----------------------------------------------------------
LKDisp:
			mov		dptr, #DECODING
			movc	a, @a+dptr 

			ret

DECODING:	db	not 81h, not 0cfh, not 92h, not 86h, not 0cch, not 0a4h, not 0a0h, not 8fh, not 80h, not 8ch

; ----------------------------------------------------------
; Delay
; ----------------------------------------------------------
; Faz um delay de modo que a rotina de contagem de segundos
; Feche em aproximadamente 1 segundo
; ----------------------------------------------------------
Delay:
			mov		r4, #200
Here:		mov		r5, #249
			djnz	r5, $
			djnz	r4, Here

			ret

; ----------------------------------------------------------
; Time
; ----------------------------------------------------------
; Chama um tempo de um segundo
; ----------------------------------------------------------
Time:
			mov		r6, #10
While:		acall	Delay
			djnz	r6, While

			ret

; ----------------------------------------------------------
; CKPulse
; ----------------------------------------------------------
; Pulso de clock no registardor de deslocamento
; ----------------------------------------------------------
CKPulse:
			setb	SHCK
			clr		SHCK

			ret

; ********************************************************** 
			end
; ********************************************************** 

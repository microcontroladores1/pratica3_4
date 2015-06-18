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

BUTN		equ		p2.0												

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

			mov			sp, #7fh					; Inicializa a pilha na regiao de memoria extra do 8052

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

Main:
			jb		CONTSW, Sec		
Pulse:		acall	PulseCT
			jmp		Exit
Sec:		acall	SecCT

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
			ret

; ----------------------------------------------------------
; SecCT
; ----------------------------------------------------------
; Contexto de contagem de segundos
; ----------------------------------------------------------
SecCT:		
			ret


; ********************************************************** 
			end
; ********************************************************** 

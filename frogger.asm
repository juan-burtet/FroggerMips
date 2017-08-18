#########################################################################################################
#	NOME: JUAN BURTET	ARQUITETURA E ORGANIZAÇÃO DE COMPUTADORES 1
#				TPFINAL = FROGGER
#	# ATENÇÃO! TESTAR A VELOCIDADE
#########################################################################################################
#########################################################################################################
#	UNIT WIDTH IN PIXELS = 4	UNIT HEIGHT IN PIXELS = 4
#	DISPLAY WIDTH IN PIXELS = 512	DISPLAY HEIGHT IN PIXELS = 512
#	BASE ADDRESS FOR DISPLAY = 0X10040000 (HEAP)
#
#	CASO ESTEJA MUITO LENTO OU MUITO RÁPIDO -> MODIFICAR LINHA 92 , que inicializa $t2
#	QUANTO MAIOR O VALOR DE $T2, MAIS LENTO FICA!
##########################################################################################################

.data
	mensagem1: 	.asciiz "\tBEM VINDO A FROGGER!\n\nJOGUE COM AS TECLAS W,A,S,D!\n\n\tBOM JOGO!"
	ganhou:		.asciiz "VOCÊ GANHOU!\n"
	morreu:		.asciiz "VOCÊ MORREU!\n"

################ MACROS #####################################################################
.macro	PUSH(%REG)
	addi $sp, $sp, -4
	sw   %REG, 0($sp)
.end_macro

.macro	POP(%REG)
	lw   %REG, 0($sp)
	addi $sp, $sp, 4	
.end_macro

.macro 	SOM
	li $v0, 31
	PUSH($a0)
	li $a0, 20
	li $a1, 150
	li $a2, 7
	li $a3, 100
	POP($a0)
	syscall
.end_macro

.macro 	MENSAGEM(%reg)
	PUSH($a0)
	li $v0, 55
	la $a0, %reg
	li $a1, 1
	syscall
.end_macro

################ FIM MACROS ####################################################################

################################################################################################
## 							POSIÇÃO INICIAL DO SAPO COLUNA 4, LINHA 1
# 							LINHA MINIMA: 1, LINHA MÁXIMA = 8, 
# 							COLUNA MINIMA: 1; COLUNA MÁXIMA = 8
#
#
#	REGISTRADORES $S:
#	$s1 = LINHA DO SAPO
#	$S2 = COLUNA DO SAPO
#
#
############### MAIN ##########################################################################
#	ONDE RODA A PARTE PRINCIPAL DO PROGRAMA
#	REGISTRADORES $s são usados APENAS na MAIN	
#	$s0 = LINHA
#	$s1 = COLUNA/ALTURA
#	$s3 = ($a0) dos primeiros carros que vão pra direita
#	$s4 = ($a0) dos primeiros carros que vão pra esquerda
#	$s5 = ($a0) dos segundos carros que vão pra direita
#	$s6 = ($a0) dos segundos carros que vão pra esquerda
#       $s7 = CONTADOR DE VELOCIDADE DOS CARROS. QUANTO MAIOR, MAIS LENTO OS CARROS
#
#	CARROS QUE VÃO PRA ESQUERDA COMPARAR COM ESSE NÚMERO (20.484)
#	CARROS QUE VÃO PRA DIREITA  COMPARAR COM ESSE NÚMERO (13.260)
###############################################################################################
.text
	
	MENSAGEM(mensagem1)
	
# INICIA O MAPA E OS "PERSONAGENS"
inicializa:	
	
	# POSIÇÃO INICIAL DO SAPO
	lui  $a0, 0x1004
	addi $a0, $a0, 58880
	addi $a0, $a0, 204
	li   $s0, 1 
	li   $s1, 4
	
	# VELOCIDADE DOS CARROS (CONFERE SE TÁ RÁPIDO E MUDA AQUI
	li   $t2, 2000
	move $s7, $t2
	
	# CRIA O MAPA
	jal desenhaMapa
	nop
	
	# CRIA O SAPO
	jal desenhaSapoCima
	nop
	
	# GUARDA O $a0 do sapo, ele é o mais importante <3
	PUSH($a0)
	
	# CRIA OS CARROS DOS CANTOS
	lui  $s3, 0x1004
	addi $s4, $s3, 20940 # POSIÇÃO INICIAL DO CARRO QUE VAI PRA ESQUERDA
	move $a0, $s4
	jal  desenhaCarroEsquerda
	nop
	lui  $a0, 0x1004
	addi $s3, $s3, 12804 # POSIÇÃO INICIAL DO CARRO QUE VAI PRA DIREITA
	move $a0, $s3
	jal  desenhaCarroDireita
	nop
	
	# CRIA OS CARROS DO MEIO
	addi $s6, $s4, -240
	move $a0, $s6
	jal  desenhaCarroEsquerda
	nop
	addi $s5, $s3, 240
	move $a0, $s5
	jal  desenhaCarroDireita
	nop
	
	
# FIM INICIALIZA

# INICIA O JOGO
jogar:
	# Compara se chegou a 0, para movimentar os carros
	beq  $s7, $0, movimentaCarros
	nop
	# Diminui um pra chegar ao momento de movimentar os carros
	addi $s7, $s7, -1
	
	
	lui  $t0, 0xFFFF	
	addi $t0, $t0, 4	
	lb   $t1, 0($t0)
	beq  $t1, 0, nenhumaLetraDigitada
	
W:	bne  $t1, 119, A # SE DIGITOU W
	nop
	sb   $0, 0($t0)
	POP($a0)
	jal  desenhaOndeSapoPassou
	nop
	addi $a0, $a0, -7680
	PUSH($a0)
	jal  desenhaSapoCima
	nop
	SOM
	addi $s0, $s0, 1
	beq  $s0, 8, venceu # VENCEU
	nop
	j    jogar
	nop
	
	# AJEITADO
A:	bne $t1, 97, S # SE DIGITOU A
	nop
	sb   $0, 0($t0)
	# CONFERIR SE TÁ NO LIMITE
	beq  $s1, 1, jogar
	nop
	POP($a0)
	jal  desenhaOndeSapoPassou
	nop
	addi $a0, $a0, -48
	PUSH($a0)
	jal  desenhaSapoEsquerda
	nop
	SOM
	addi $s1, $s1, -1
	j    jogar
	nop
	
	# AJEITADO
S:	bne  $t1, 115, D # SE DIGITOU S
	nop
	sb   $0, 0($t0)
	# CONFERIR SE TÁ NO LIMITE
	beq  $s0, 1, jogar
	nop
	POP($a0)
	jal  desenhaOndeSapoPassou
	nop
	addi $a0, $a0, 7680
	PUSH($a0)
	jal  desenhaSapoBaixo
	nop
	SOM
	addi $s0, $s0, -1
	j    jogar
	nop
	
	
D:	bne  $t1, 100, nenhumaLetraDigitada # SE DIGITOU D
	nop
	sb   $0, 0($t0)
	beq  $s1, 8, jogar
	nop
	POP($a0)
	jal  desenhaOndeSapoPassou
	nop
	addi $a0, $a0, 48
	PUSH($a0)
	jal  desenhaSapoDireita
	nop
	SOM
	addi $s1, $s1, 1
	
nenhumaLetraDigitada:

	j    jogar
	nop
	
# FAZ O MOVIMENTO DOS CARROS	
movimentaCarros:	
	PUSH($t0)
		
	# APAGA OS CARROS DA TELA
	move $a0, $s3
	jal  desenhaOndeCarroPassou
	nop
	move $a0, $s4
	jal  desenhaOndeCarroPassou
	nop
	move $a0, $s5
	jal  desenhaOndeCarroPassou
	nop
	move $a0, $s6
	jal  desenhaOndeCarroPassou
	nop
	
	# CALCULO PRO NOVO TRAJETO
	addi $s3, $s3, 4
	addi $s4, $s4, -4
	addi $s5, $s5, 4
	addi $s6, $s6, -4
	
	# Imprime os carros
	move $a0, $s3
	jal  desenhaCarroDireita
	nop
	move $a0, $s4
	jal  desenhaCarroEsquerda
	nop
	move $a0, $s5
	jal  desenhaCarroDireita
	nop
	move $a0, $s6
	jal  desenhaCarroEsquerda
	nop
	# 13260
	# Confere se os carros chegaram no limite
carro1:	lui  $t0, 0x1004
	addi $t0, $t0, 13260
	bne  $s3, $t0, carro2
	nop
	move $a0, $s3
	jal  desenhaOndeCarroPassou
	nop
	lui  $s3, 0x1004
	addi $s3, $s3, 12804
	
carro2:	lui  $t0, 0x1004
	addi $t0, $t0, 20484
	bne  $s4, $t0, carro3
	nop
	move $a0, $s4
	jal  desenhaOndeCarroPassou
	nop
	lui  $s4, 0x1004
	addi $s4, $s4, 20940
	
carro3:	lui  $t0, 0x1004
	addi $t0, $t0, 13260
	bne  $s5, $t0, carro4
	nop
	move $a0, $s5
	jal  desenhaOndeCarroPassou
	nop
	lui  $s5, 0x1004
	addi $s5, $s5, 12804
	
carro4:	lui  $t0, 0x1004
	addi $t0, $t0, 20484
	bne  $s6, $t0, fimMovimentaCarros
	nop
	move $a0, $s6
	jal  desenhaOndeCarroPassou
	nop
	lui  $s6, 0x1004
	addi $s6, $s6, 20940
	
fimMovimentaCarros:
	
# DESEMPILHA $T0
	POP($t0)
	
	
	
	POP($a0)
	move $t3, $a0	# POSIÇÃO DO SAPO
	PUSH($a0)
	
	# Checa se o sapo tá na Linha 2  
linha2:	bne  $s0, 2, linha3
	nop
	# CARROS QUE VÃO PRA ESQUERDA (SOMAR 30720)
	addi $t4, $s4, 30720
	beq  $t4, $t3, morto # MORREU
	nop
	addi $t4, $s6, 30720
	beq  $t4, $t3, morto # MORREU
	nop
	addi $t4, $t4, 11
	beq  $t4, $t3, morto # MORREU
	nop
	addi $t4, $s4, 30731
	beq  $t4, $t3, morto # MORREU
	nop
	
	j    renova
	nop
	
	# Checa se o sapo tá na Linha 3
linha3:	bne  $s0, 3, linha4
	nop 
	# CARROS QUE VÃO PRA DIREITA ( SOMAR 30720)
	addi $t4, $s3, 30720
	beq  $t4, $t3, morto # MORREU
	nop
	addi $t4, $s5, 30720
	beq  $t4, $t3, morto # MORREU
	nop
	addi $t4, $t4, 11
	beq  $t4, $t3, morto # MORREU
	nop
	addi $t4, $s3, 30731
	beq  $t4, $t3, morto # MORREU
	nop
	
	j    renova
	nop
	
	# Checa se o sapo tá na Linha 4
linha4:	bne  $s0, 4, linha5
	nop
	# CARROS QUE VÃO PRA ESQUERDA (SOMAR 15360)
	addi $t4, $s4, 15360
	beq  $t4, $t3, morto # MORREU
	nop
	addi $t4, $s6, 15360
	beq  $t4, $t3, morto # MORREU
	nop
	addi $t4, $t4, 11
	beq  $t4, $t3, morto # MORREU
	nop
	addi $t4, $s4, 15371
	beq  $t4, $t3, morto # MORREU
	nop
	
	j    renova
	nop
	
	# Checa se o sapo tá na Linha 5
linha5:	bne  $s0, 5, linha6
	nop
	# CARROS QUE VÃO PRA DIREITA (SOMAR 15360)
	addi $t4, $s3, 15360
	beq  $t4, $t3, morto # MORREU
	nop
	addi $t4, $s5, 15360
	beq  $t4, $t3, morto # MORREU
	nop
	addi $t4, $t4, 11
	beq  $t4, $t3, morto # MORREU
	nop
	addi $t4, $s3, 15371
	beq  $t4, $t3, morto # MORREU
	nop
	
	j    renova
	nop
	
	# Checa se o sapo tá na Linha 6
linha6:	bne  $s0, 6, linha7
	nop
	# CARROS QUE VÃO PRA ESQUERDA (NÃO PRECISA SOMAR)
	beq  $s4, $t3, morto # MORREU
	nop
	beq  $s6, $t3, morto # MORREU
	nop
	addi $t4, $s4, 11
	beq  $t4, $t3, morto
	nop
	addi $t4, $s6, 11
	beq  $t4, $t3, morto
	nop
	
	j    renova
	nop
	
	# Checa se o sapo tá na Linha 7
linha7:	bne  $s0, 7, renova
	nop
	# CARROS QUE VÃO PRA DIREITA (NÃO PRECISA SOMAR)
	beq  $s3, $t3, morto # MORREU
	nop
	beq  $s5, $t3, morto # MORREU
	nop
	addi $t4, $s3, 11
	beq  $t4, $t3, morto
	nop
	addi $t4, $s5, 11
	beq  $t4, $t3, morto
	nop
	
	# RENOVA O CONTADOR DE VELOCIDADE
renova:	move $s7, $t2
	nop
	
	j    jogar
	nop
# FIM MOVIMENTA CARROS	
	
morto:	MENSAGEM(morreu)
	j   inicializa
	nop
	
venceu:	MENSAGEM(ganhou)
	j   inicializa
	nop
	
	
fimJogar:
	
	
	li $v0, 10
	syscall
	
################ FIM DA MAIN ######################################################################### FIM DA MAIN


################ SUBROTINAS ##########################################################################

######################################################################################################

###############	SUBROTINA QUE DESENHA O MAPA ##########################################################
#												      #
#												      #
#######################################################################################################
# DESENHA O MAPA ( REGISTRADORES UTILIZADOS $T0, $T1, $T8, $T9
#	SUBROTINA QUE DESENHA O MAPA DO JOGO
#	UTILIZAR ESSA SUBROTINA QUANDO O MAPA PRECISAR SER PINTADO
######################################################################################################
desenhaMapa:	

# EMPILHAMENTO DE REGISTRADORES
	PUSH($t0)
	PUSH($t1)
	PUSH($t8)
	PUSH($t9)
	
# Pinta o fundo do maapa
	# Primeiro endereço do bitmap
	lui  $t0, 0x1004
	# CINZA ESCURO
	li   $t1, 0x222222
	# contador pra pintar o fundo inteiro de cinza escuro
	li   $t8, 16384
	
pintaFundo:
	beq  $t8, $0, fimPintaFundo
	nop
	sw   $t1, 0($t0)
	addi $t0, $t0, 4
	addi $t8, $t8, -1
	j    pintaFundo
	nop
	
fimPintaFundo:
# FIM DE PINTAR O FUNDO
		
# GRAMA DO TOPO DA TELA
	
	# Primeiro endereço do bitmap
	lui  $t0, 0x1004
	
	# COR DA GRAMA
	li   $t1, 0x003300
	
	# Contador de linhas da grama
	li   $t8, 22
gramaTopo:
	beq  $t8, $0, fimGramaTopo
	nop
	
	li   $t9, 127
gramaTopo2:
	beq  $t9, $0, fimGramaTopo2
	nop
	sw   $t1, 0($t0)
	addi $t9, $t9, -1
	addi $t0, $t0, 4
	j    gramaTopo2
	nop
	
fimGramaTopo2:
	addi $t8, $t8, -1
	addi $t0, $t0, 4
	j    gramaTopo
	nop
	
fimGramaTopo:
# FIM TOPO TELA
####

# Pintura da faixa em baixo da grama
	
	# Desce uma linha
	lui  $t0, 0x1004
	addi $t0, $t0, 11776
	# Contador em 128 para uma linha reta
	li   $t8, 128
	# COR AMARELO PRA FAIXA
	li   $t1, 0xFFFF33
	
FaixaSuperiorAmarela:
	beq  $t8, $0, fimFaixaSuperiorAmarela
	nop
	sw   $t1, 0($t0)
	addi $t8, $t8, -1
	addi $t0, $t0, 4
	j    FaixaSuperiorAmarela
	nop
	
fimFaixaSuperiorAmarela:
# Fim da pintura da faixa em baixo da grama
#####

# Pintar as faixas da Estrada
	li   $t8, 5
pintaEstrada:	
	beq  $t8, $0, fimPintaEstrada
	
	# 14 linhas de distancia entre as faixas
	addi $t0, $t0, 7168
	li   $t9, 8
pintaFaixa:
	beq  $t9, $0, fimPintaFaixa
	nop
	sw   $t1, 0($t0)
	sw   $t1, 4($t0)
	sw   $t1, 8($t0)
	sw   $t1, 12($t0)
	sw   $t1, 16($t0)
	sw   $t1, 20($t0)
	sw   $t1, 24($t0)
	sw   $t1, 28($t0)
	addi $t0, $t0, 64
	addi $t9, $t9, -1
	j    pintaFaixa
	nop
	
fimPintaFaixa:
	addi $t8, $t8, -1
	j    pintaEstrada
	nop
	
fimPintaEstrada:
##### FIM DE PINTAR AS FAIXAS DA ESTRADA
	
	# Quantidade de linhas da grama
	li   $t8, 14
	# COR VERDE ESCURO
	li   $t1, 0x003300
pintaGramaInferior:
	beq  $t8, $0, fimPintaGramaInferior
	nop
	
	li   $t9, 128
pintaLinhaGramaInferior:
	beq  $t9, $0, fimPintaLinhaGramaInferior
	nop
	sw   $t1, 0($t0)
	addi $t9, $t9, -1
	addi $t0, $t0, 4
	j    pintaLinhaGramaInferior
	nop
	
fimPintaLinhaGramaInferior:
	addi $t8, $t8, -1
	j    pintaGramaInferior
	nop
	
fimPintaGramaInferior:
# FIM DE PINTAR GRAMA INFERIOR

# LIMITES DA GRAMA INFERIOR
	
	# COR DA GRAMA LIMITE
	li   $t1, 0x53A800
	# LOCALIZAÇÃO DA GRAMA
	lui  $t0, 0x1004
	addi $t0, $t0, 58368
	# 13 LINHAS
	li   $t8, 13
pintaLimiteGrama:
	beq  $t8, $0, fimPintaLimiteGrama
	nop
	
	# Quantidade de colunas
	li   $t9, 15
pintaLimiteGrama2:
	beq  $t9, $0, fimPintaLimiteGrama2
	nop
	sw   $t1, 0($t0)
	sw   $t1, 448($t0)
	addi $t0, $t0, 4
	addi $t9, $t9, -1
	j    pintaLimiteGrama2
	nop
	
fimPintaLimiteGrama2:
	addi $t8, $t8, -1
	addi $t0, $t0, 452
	j    pintaLimiteGrama
	nop
	
fimPintaLimiteGrama:
# FIM DA PINTURA DOS LIMITES DA GRAMA	
	  
# PINTA AS BORDAS DA TELA
	
	# COR PRETO TREVOSO
	li    $t1, 0x000000
	# TOPO DA TELA
	lui   $t0, 0x1004
	# Inicializa o contador em 128 pra desenhar a borda
	li   $t8, 128
topoTela:	
	beq  $t8, $0, fimTopoTela
	nop
	sw   $t1, 0($t0)
	addi $t0, $t0, 4
	addi $t8, $t8, -1
	j    topoTela
	nop
	
fimTopoTela:
	li   $t8, 126
	
cantoTela:
	beq  $t8, $0, fimCantoTela
	nop
	sw   $t1, 0($t0)
	sw   $t1, 508($t0)
	addi $t0, $t0, 512
	addi $t8, $t8, -1
	j    cantoTela
	nop
	
fimCantoTela:
	li   $t8, 128
	
pisoTela:
	beq  $t8, $0, fimPisoTela
	nop
	sw   $t1, 0($t0)
	addi $t0, $t0, 4
	addi $t8, $t8, -1
	j    pisoTela
	nop
	
fimPisoTela:
# FIM DE PINTAR AS BORDAS

# RETORNA DA SUBROTINA					
fimDesenhaMapa:
	POP($t9)
	POP($t8)
	POP($t1)
	POP($t0)
	jr   $ra
	nop
	
################################################################################################################### FIM SUBROTINA	
	

##################### SUBROTINAS QUE DESENHAM O SAPO ##############################################################	
#														  #
#														  #
###################################################################################################################
# DESENHA O SAPO de FRENTE (USA OS REGISTRADORES $A0, $T0, $T1, $T2, $T3)
#	SUBROTINA QUE DESENHA UM SAPO OLHANDO PRA CIMA
#	UTLIZAR ESSA SUBROTINA QUANDO SE MOVIMENTAR PARA CIMA ($a0 passa a localizaão onde vai ser desenhado)
###################################################################################################################
desenhaSapoCima:
	
# EMPILHA REGISTRADORES QUE VÃO SER USADOS
	PUSH($a0)
	PUSH($t0)
	PUSH($t1)
	PUSH($t2)
	PUSH($t3)
	
	
	move $t0, $a0
	
	# COR VERDE
	li   $t1, 0x00FF00
	# COR AMARELA
	li   $t2, 0xFFFF00
	# COR ROSA
	li   $t3, 0xFF0066
	
	
	# primeira linha 0 - 1
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	addi $a0, $a0, 12
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	
	addi $a0, $a0, 12
	sw   $t1, 0($a0)
	
	# Próxima linha 128 - 2
	move $a0, $t0
	addi $t0, $t0, 512
	
	addi $a0, $a0, 512
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	addi $a0, $a0, 8
	sw   $t3, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	
	addi $a0, $a0, 8
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	# próxima linha começa em 256 - 3
	move $a0, $t0
	addi $t0, $t0, 512
	
	addi $a0, $a0, 512
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	addi $a0, $a0, 8
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	addi $a0, $a0, 8
	sw   $t1, 0($a0)
	
	# próxima linha começa em 384 - 4
	move $a0, $t0
	addi $t0, $t0, 512
	
	addi $a0, $a0, 512
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	# próxima linha começa em 512 - 5
	move $a0, $t0
	addi $t0, $t0, 512
	
	addi $a0, $a0, 512
	addi $a0, $a0, 12
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	
	# próxima linha começa em 640 - 6
	move $a0, $t0
	addi $t0, $t0, 512
	
	addi $a0, $a0, 512
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	# próxima linha começa em 768 - 7
	move $a0, $t0
	addi $t0, $t0, 512
	
	addi $a0, $a0, 512
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	addi $a0, $a0, 8
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	addi $a0, $a0, 8
	sw   $t1, 0($a0)
	
	# próxima linha começa em 896 - 8
	move $a0, $t0
	addi $t0, $t0, 512
	
	addi $a0, $a0, 512
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	addi $a0, $a0, 12
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	addi $a0, $a0, 12
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	# próxima linha começa em 1024 - 9
	move $a0, $t0
	addi $t0, $t0, 512
	
	addi $a0, $a0, 512
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	addi $a0, $a0, 36
	sw   $t1, 0($a0)
	
	
fimDesenhoSapoCima:

# DESEMPILHA REGISTRADORES	
	POP($t3)
	POP($t2)
	POP($t1)
	POP($t0)
	POP($a0)
	
# RETORNA DA SUBFUNÇÃO
	jr $ra
	nop
	
############################################################################################################## FIM SUBROTINA

###############################################################################################################
# DESENHA O SAPO OLHANDO pra direita (REGISTRADORES USADOS $A0, $T0, $T1, $T2, $T3)
#	SUBROTINA QUE DESENHA UM SAPO OLHANDO PARA DIREITA
#	UTLIZAR ESSA SUBROTINA QUANDO SE MOVIMENTAR PARA A DIREITA ($a0 passa a localizaão onde vai ser desenhado)
###############################################################################################################
desenhaSapoDireita:

# EMPILHA REGISTRADORES
	PUSH($a0)
	PUSH($t0)
	PUSH($t1)
	PUSH($t2)
	PUSH($t3)
	
	move $t0, $a0
	move $t4, $a0
	# COR VERDE
	li   $t1, 0x00FF00
	# COR AMARELA
	li   $t2, 0xFFFF00
	# COR ROSA
	li   $t3, 0xFF0066
	
	
	# LINHA 1 - COMEÇA EM 0
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	addi $a0, $a0, 24
	sw   $t1, 0($a0)
	
	# Linha 2 - começa em 512
	addi $t0, $t0, 512
	move $a0, $t0
	
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	addi $a0, $a0, 8
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	# Linha 3 - começa em 1024
	addi $t0, $t0, 512
	move $a0, $t0
	
	addi $a0, $a0, 12
	sw   $t1, 0($a0)
	
	addi $a0, $a0, 8
	sw   $t1, 0($a0)
	
	# Linha 4 - começa em 1536
	addi $t0, $t0, 512
	move $a0, $t0
	
	addi $a0, $a0, 8
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	
	# Linha 5 - começa em 2048
	addi $t0, $t0, 512
	move $a0, $t0
	
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	
	# Linha 6 - começa em 2560
	addi $t0, $t0, 512
	move $a0, $t0
	
	addi $a0, $a0, 4
	sw   $t2, 0($a0) # pixel 1
	addi $a0, $a0, 4
	sw   $t1, 0($a0) # pixel 2
	addi $a0, $a0, 4
	sw   $t2, 0($a0) # pixel 3
	addi $a0, $a0, 4
	sw   $t2, 0($a0) # pixel 4
	addi $a0, $a0, 4
	sw   $t2, 0($a0) # pixel 5
	addi $a0, $a0, 4
	sw   $t2, 0($a0) # pixel 6
	addi $a0, $a0, 4
	sw   $t2, 0($a0) # pixel 7
	addi $a0, $a0, 4
	sw   $t1, 0($a0) # pixel 8
	
	# Linha 7 - começa em 3072
	addi $t0, $t0, 512
	move $a0, $t0
	
	addi $a0, $a0, 4
	sw   $t2, 0($a0) # pixel 1
	addi $a0, $a0, 4
	sw   $t2, 0($a0) # pixel 2
	addi $a0, $a0, 4
	sw   $t2, 0($a0) # pixel 3
	addi $a0, $a0, 4
	sw   $t2, 0($a0) # pixel 4
	addi $a0, $a0, 4
	sw   $t2, 0($a0) # pixel 5
	addi $a0, $a0, 4
	sw   $t2, 0($a0) # pixel 6
	addi $a0, $a0, 4
	sw   $t2, 0($a0) # pixel 7
	addi $a0, $a0, 4
	sw   $t2, 0($a0) # pixel 8
	
	# Linha 8 - começa em 3584
	addi $t0, $t0, 512
	move $a0, $t0
	
	addi $a0, $a0, 4
	sw   $t1, 0($a0) # pixel 1
	addi $a0, $a0, 4
	sw   $t2, 0($a0) # pixel 2
	addi $a0, $a0, 4
	sw   $t2, 0($a0) # pixel 3
	addi $a0, $a0, 4
	sw   $t2, 0($a0) # pixel 4
	addi $a0, $a0, 4
	sw   $t2, 0($a0) # pixel 5
	addi $a0, $a0, 4
	sw   $t1, 0($a0) # pixel 6
	addi $a0, $a0, 4
	sw   $t1, 0($a0) # pixel 7
	addi $a0, $a0, 4
	sw   $t2, 0($a0) # pixel 8
	
	# Linha 9 - começa em 4096
	addi $t0, $t0, 512
	move $a0, $t0
	
	addi $a0, $a0, 8
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	
	# Linha 10 - começa em 4608
	addi $t0, $t0, 512
	move $a0, $t0
	
	addi $a0, $a0, 12
	sw   $t1, 0($a0)
	
	addi $a0, $a0, 8
	sw   $t1, 0($a0)
	
	# Linha 11 - começa em 5120
	addi $t0, $t0, 512
	move $a0, $t0
	
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	addi $a0, $a0, 8
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	# Linha 12 - começa em 5632
	addi $t0, $t0, 512
	move $a0, $t0
	
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	addi $a0, $a0, 24
	sw   $t1, 0($a0)
	
fimDesenhaSapoDireita:
	
# DESEMPILHA REGISTRADORES	
	POP($t3)
	POP($t2)
	POP($t1)
	POP($t0)
	POP($a0)

# retorna da subrotina
	jr $ra
	nop
	
##################################################################################################### FIM SUBROTINA


#####################################################################################################
# DESENHA O SAPO OLHANDO PRA BAIXO (REGISTRADORES USADOS $a0, $t0, $t1, $t2, $t3)
#	SUBROTINA QUE DESENHA UM SAPO OLHANDO PRA BAIXO
#	UTILIZAR ESSA SUBROTINA QUANDO SE MOVIMENTAR PRA BAIXO ($a0 passa a localizaão onde vai ser desenhado)
#####################################################################################################
desenhaSapoBaixo:
	
# EMPILHA REGISTRADORES
	PUSH($a0)
	PUSH($t0)
	PUSH($t1)
	PUSH($t2)
	PUSH($t3)
	
	
	move $t0, $a0
	li   $t1, 0x00FF00
	li   $t2, 0xFFFF00
	li   $t3, 0xFF0066
	
	
	# primeira linha 0 - 1
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	addi $a0, $a0, 36
	sw   $t1, 0($a0)
	
	# Próxima linha 128 - 2
	addi $t0, $t0, 512
	move $a0, $t0
	
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	addi $a0, $a0, 12
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	
	addi $a0, $a0, 12
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	# próxima linha começa em 256 - 3
	addi $t0, $t0, 512
	move $a0, $t0
	
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	addi $a0, $a0, 8
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	addi $a0, $a0, 8
	sw   $t1, 0($a0)
	
	# próxima linha começa em 384 - 4
	addi $t0, $t0, 512
	move $a0, $t0
	
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	# próxima linha começa em 512 - 5
	addi $t0, $t0, 512
	move $a0, $t0
	
	addi $a0, $a0, 12
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	
	# próxima linha começa em 640 - 6
	addi $t0, $t0, 512
	move $a0, $t0
	
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	# próxima linha começa em 768 - 7
	addi $t0, $t0, 512
	move $a0, $t0
	
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	addi $a0, $a0, 8
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	addi $a0, $a0, 8
	sw   $t1, 0($a0)
	
	# próxima linha começa em 896 - 8
	addi $t0, $t0, 512
	move $a0, $t0
	
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	addi $a0, $a0, 8
	sw   $t3, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	
	addi $a0, $a0, 8
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	# próxima linha começa em 1024 - 9
	addi $t0, $t0, 512
	move $a0, $t0
	
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	addi $a0, $a0, 12
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	
	addi $a0, $a0, 12
	sw   $t1, 0($a0)
	
FimDesenhaSapoBaixo:
	
# DESEMPILHA REGISTRADORES	
	POP($t3)
	POP($t2)
	POP($t1)
	POP($t0)
	POP($a0)
	
# RETORNA DA SUBROTINA
	jr $ra
	nop
	
#################################################################################################### FIM SUBROTINA


####################################################################################################
# DESENHA O SAPO OLHANDO PRA ESQUERDA (USA OS REGISTRADORES $a0, $t0, $t1, $t2, $t3)
#	SUBROTINA QUE DESENHA O SAPO OLHANDO PARA ESQUERDA
#	UTILIZAR AO APERTAR O MOVIMENTO PRA ESQUERDA ($a0 passa a localizaão onde vai ser desenhado)
###################################################################################################
desenhaSapoEsquerda:

# EMPILHA REGISTRADORES
	PUSH($a0)
	PUSH($t0)
	PUSH($t1)
	PUSH($t2)
	PUSH($t3)	
	
	move $t0, $a0
	# COR VERDE
	li   $t1, 0x00FF00
	# COR AMARELA
	li   $t2, 0xFFFF00
	# COR ROSA
	li   $t3, 0xFF0066
	
	
	# LINHA 1 - COMEÇA EM 0
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	addi $a0, $a0, 24
	sw   $t1, 0($a0)
	
	# Linha 2 - começa em 512
	addi $t0, $t0, 512
	move $a0, $t0
	
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	addi $a0, $a0, 8
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	# Linha 3 - começa em 1024
	addi $t0, $t0, 512
	move $a0, $t0
	
	addi $a0, $a0, 12
	sw   $t1, 0($a0)
	
	addi $a0, $a0, 8
	sw   $t1, 0($a0)
	
	# Linha 4 - começa em 1536
	addi $t0, $t0, 512
	move $a0, $t0
	
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	# Linha 5 - começa em 2048
	addi $t0, $t0, 512
	move $a0, $t0
	
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	# Linha 6 - começa em 2560
	addi $t0, $t0, 512
	move $a0, $t0
	
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	
	# Linha 7 - começa em 3072
	addi $t0, $t0, 512
	move $a0, $t0
	
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	
	# Linha 8 - começa em 3584
	addi $t0, $t0, 512
	move $a0, $t0
	
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	# Linha 9 - começa em 4096
	addi $t0, $t0, 512
	move $a0, $t0
	
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	# Linha 10 - começa em 4608
	addi $t0, $t0, 512
	move $a0, $t0
	
	addi $a0, $a0, 12
	sw   $t1, 0($a0)
	
	addi $a0, $a0, 8
	sw   $t1, 0($a0)
	
	# Linha 11 - começa em 5120
	addi $t0, $t0, 512
	move $a0, $t0
	
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	addi $a0, $a0, 8
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	# Linha 12 - começa em 5632
	addi $t0, $t0, 512
	move $a0, $t0
	
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	
	addi $a0, $a0, 24
	sw   $t1, 0($a0)
	
fimDesenhaSapoEsquerda:
	
# DESEMPILHA REGISTRADORES	
	POP($t3)
	POP($t2)
	POP($t1)
	POP($t0)
	POP($a0)
	
# RETORNA DA SUBROTINA
	jr $ra
	nop
	
########################################################################################### FIM SUBROTINA

############################ SUBROTINA QUE DESENHA ONDE O SAPO PASSOU ###########################################################
#
#
#################################################################################################################################
# PINTA A PARTE DO MAPA ONDE O SAPO ESTAVA (UTILIZA OS REGISTRADORES $a0, $T0, $T1)
#	SUBROTINA QUE PINTA O PONTO ONDE O SAPO ESTAVA ANTES DE ANDAR
#	UTILIZAR ESSA SUBROTINA SEMPRE QUE O SAPO ANDAR
#################################################################################################################################

desenhaOndeSapoPassou:
	
# EMPILHA REGISTRADORES
	PUSH($a0)
	PUSH($t0)
	PUSH($t1)
	
# INICIA
	li   $t0, 12
	beq  $s0, 1, pintaVerdeOndePassou
	nop

PintaCinzaOndePassou:
	# COR CINZA ESCURO
	li   $t1, 0x222222
	j    pintaOndePassou
	nop

pintaVerdeOndePassou:
	# COR VERDE
	li   $t1, 0x003300
	
pintaOndePassou:
	beq  $t0, $0, fimDesenhaOndeSapoPassou
	sw   $t1, 0($a0)
	sw   $t1, 4($a0)
	sw   $t1, 8($a0)
	sw   $t1, 12($a0)
	sw   $t1, 16($a0)
	sw   $t1, 20($a0)
	sw   $t1, 24($a0)
	sw   $t1, 28($a0)
	sw   $t1, 32($a0)
	sw   $t1, 36($a0)
	sw   $t1, 40($a0)
	sw   $t1, 44($a0)
	addi $a0, $a0, 512
	addi $t0, $t0, -1
	j    pintaOndePassou
	nop
	
fimDesenhaOndeSapoPassou:

# DESEMPILHA REGISTRADORES
	POP($t1)
	POP($t0)
	POP($a0)
	
# RETORNA DA SUBROTINA
	jr  $ra
	nop
	
################################################################################# FIM SUBROTINA

############################### SUBROTINAS QUE DESENHAM OS CARROS #################################
#												  #
#												  #
###################################################################################################
# DESENHA CARRO INDO PRA ESQUERDA (UTILIZA OS REGISTRADORES $a0, $t0, $t1, $t2, $t3)
#	SUBROTINA QUE DESENHA O CARRO EM DIREÇÃO PARA ESQUERDA
#	UTLIZAR ESSA SUBROTINA PROS CARROS INDO PRA ESQUERDA ($a0 indica a posição onde ele será pintado)
###################################################################################################
desenhaCarroEsquerda:
	
# EMPILHA REGISTRADORES
	PUSH($a0)
	PUSH($t0)
	PUSH($t1)
	PUSH($t2)
	PUSH($t3)
	
# Desenha o carro
	move $t0, $a0
	# COR VERMELHA
	li   $t1, 0XFF0000
	# COR AMARELA
	li   $t2, 0xFFFF11
	# COR ROXA
	li  $t3, 0x9933A9
	
	# linha 1 - FEITO
	addi $a0, $a0, 8
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	
	addi $a0, $a0, 8
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	
	# linha 2 - FEITO
	addi $t0, $t0, 512
	move $a0, $t0
	
	addi $a0, $a0, 8
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	
	addi $a0, $a0, 8
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	
	# Linha 3 - FEITO
	addi $t0, $t0, 512
	move $a0, $t0
	
	addi $a0, $a0, 8
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	
	# Linha 4 - FEITO
	addi $t0, $t0, 512
	move $a0, $t0
	
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	
	# Linha 5 - FEITO
	addi $t0, $t0, 512
	move $a0, $t0
	
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	
	# Linha 6
	addi $t0, $t0, 512
	move $a0, $t0
	
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	
	# Linha 7 - FEITO
	addi $t0, $t0, 512
	move $a0, $t0
	
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	
	# Linha 8 - FEITO
	addi $t0, $t0, 512
	move $a0, $t0
	
	addi $a0, $a0, 8
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	
	# Linha 9 - FEITO
	addi $t0, $t0, 512
	move $a0, $t0
	
	addi $a0, $a0, 8
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	
	addi $a0, $a0, 8
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	
	# Linha 10 - FEITO
	addi $t0, $t0, 512
	move $a0, $t0
	
	addi $a0, $a0, 8
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	
	addi $a0, $a0, 8
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	
	
fimDesenhaCarroEsquerda:
	
# DESEMPILHA OS REGISTRADORES
	POP($t3)
	POP($t2)
	POP($t1)
	POP($t0)
	POP($a0)
	
# RETORNA A SUBROTINA
	jr   $ra
	nop
	
############################################################################### FIM SUBROTINA


############################################################################################
# DESENHA O CARRO INDO PRA DIREITA (UTILIZA OS REGISTRADORES $a0, $t0, $t1, $t2, $t3)
#	SUBROTINA QUE DESENHA UM CARRO INDO PARA DIREÇÃO DIREITA
#	UTILIZAR ESSA SUBROTINA QUANDO O CARRO FOR PRA DIREÇÃO DIREITA ($a0 é o local onde ele vai ser desenhado
############################################################################################

desenhaCarroDireita:

# EMPILHA REGISTRADORES
	PUSH($a0)
	PUSH($t0)
	PUSH($t1)
	PUSH($t2)
	PUSH($t3)

# DESENHA O CARRO
	move $t0, $a0
	# COR VERMELHA
	li   $t1, 0XFF0000
	# COR AMARELA
	li   $t2, 0xFFFF11
	# COR ROXA
	li   $t3, 0x9933A9
	
	# Linha 1
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	
	addi $a0, $a0, 8
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	
	# Linha 2
	addi $t0, $t0, 512
	move $a0, $t0
	
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	
	addi $a0, $a0, 8
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	
	# Linha 3
	addi $t0, $t0, 512
	move $a0, $t0
	
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	
	# Linha 4
	addi $t0, $t0, 512
	move $a0, $t0
	
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	
	# Linha 5
	addi $t0, $t0, 512
	move $a0, $t0
	
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	
	# Linha 6
	addi $t0, $t0, 512
	move $a0, $t0
	
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	
	# Linha 7
	addi $t0, $t0, 512
	move $a0, $t0
	
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t3, 0($a0)
	sw   $t3, 15360($a0)
	sw   $t3, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	
	# Linha 8
	addi $t0, $t0, 512
	move $a0, $t0
	
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	addi $a0, $a0, 4
	sw   $t2, 0($a0)
	sw   $t2, 15360($a0)
	sw   $t2, 30720($a0)
	
	# Linha 9
	addi $t0, $t0, 512
	move $a0, $t0
	
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	
	addi $a0, $a0, 8
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	
	# Linha 10
	addi $t0, $t0, 512
	move $a0, $t0
	
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	
	addi $a0, $a0, 8
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	addi $a0, $a0, 4
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	
fimDesenhaCarroDireita:

# DESEMPILHA OS REGISTRADORES
	POP($t3)
	POP($t2)
	POP($t1)
	POP($t0)
	POP($a0)
	
# RETORNA DA SUBROTINA
	jr   $ra
	nop
	
################################################################################################################# FIM SUBROTINA

##################################### SUBROTINA QUE DESENHA ONDE O CARRO ESTAVA #################################################
#
#
##################################################################################################################################
# DESENHA ONDE O CARRO ESTAVA (UTILIZA OS REGISTRADORES $a0, $t0, $t1)
#	SUBROTINA QUE PINTA DE CINZA ONDE O CARRO TAVA
#	UTILIZAR ESSA SUBROTINA DEPOIS QUE O CARRO ANDAR ($ao é localização pra pintar)
##################################################################################################################################

desenhaOndeCarroPassou:
	
# EMPILHA OS REGISTRADORES
	PUSH($a0)
	PUSH($t0)
	PUSH($t1)

# INICIA
	li   $t0, 10
	li   $t1, 0x222222
	
pintaOndeCarroPassou:
	beq  $t0, $0, fimDesenhaOndeCarroPassou
	sw   $t1, 0($a0)
	sw   $t1, 15360($a0)
	sw   $t1, 30720($a0)
	sw   $t1, 4($a0)
	sw   $t1, 15364($a0)
	sw   $t1, 30724($a0)
	sw   $t1, 8($a0)
	sw   $t1, 15368($a0)
	sw   $t1, 30728($a0)
	sw   $t1, 12($a0)
	sw   $t1, 15372($a0)
	sw   $t1, 30732($a0)
	sw   $t1, 16($a0)
	sw   $t1, 15376($a0)
	sw   $t1, 30736($a0)						
	sw   $t1, 20($a0)
	sw   $t1, 15380($a0)
	sw   $t1, 30740($a0)
	sw   $t1, 24($a0)
	sw   $t1, 15384($a0)
	sw   $t1, 30744($a0)
	sw   $t1, 28($a0)
	sw   $t1, 15388($a0)
	sw   $t1, 30748($a0)
	sw   $t1, 32($a0)
	sw   $t1, 15392($a0)
	sw   $t1, 30752($a0)
	sw   $t1, 36($a0)
	sw   $t1, 15396($a0)
	sw   $t1, 30756($a0)
	sw   $t1, 40($a0)
	sw   $t1, 15400($a0)
	sw   $t1, 30760($a0)
	sw   $t1, 44($a0)
	sw   $t1, 15404($a0)
	sw   $t1, 30764($a0)
	addi $a0, $a0, 512
	addi $t0, $t0, -1
	j    pintaOndeCarroPassou
	nop
	
fimDesenhaOndeCarroPassou:

# DESEMPILHA REGISTRADORES
	POP($t1)
	POP($t0)
	POP($a0)
	
# RETORNO DA SUBROTINA
	jr  $ra
	nop
	
############################################################################################# FIM SUBROTINA

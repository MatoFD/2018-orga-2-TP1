;ya se que se esta rompiendo, tengo que reescribir list_destroy para que no llame a delete_node_in_list. que directo lo borre con node_destroy pero se acuerde quien es el proximo para repetir el ciclo.

;--------resueltos

;OJOOOOOOOOOOOO EN DESTROY LIST COMO SE QUE VOY A VER UN NULL?? CUANDO DESTRUYO NODO NO SE SI LE PONGO NULL AL ANTERIOR, O ASEGURARME DE HACERLO EN DESTRUCT NODO. PORQUE EL ULTIMO NODO NO APUNTA AL 1ERO


;OJOOOOOOOOOOOOOOOOO, XQ EN LA VERSION DE C AL FINAL LE PONEN FIRST Y LAST EN NULL??? PARA QUE?? es lo que hace un destructor, aca es redundante

;creo que hay que acordarse al destruir nodo de freeear f y g. NOOOOO, PORQUE PUEDE HABER MULTIPLES NODOS CON LA MISMA f, SOLO BORRAR LO QUE ES PROPIEDAD DE LO QUE BORRAS

;QUE PUEDO PUSHEAR Y POPEAR A LA PILE SOLO PARA ALINEAR? ALGO MAS PROLIJO QUE REPETIR RDI? LE RESTAS Y SUMAS A RBP Y RSP

;en destroy que es "devuelve los atributos a su valor inicial"?? es lo que haria el destructor, poner todo en null antes de liberar memoria.

%define offset_list_name 0
%define offset_list_first 8
%define offset_list_last 16

%define offset_node_next 0
%define offset_node_previous 8
%define offset_node_f 16
%define offset_node_g 24
%define offset_node_type 32

%define offset_key_length 0
%define offset_key_value 4 ;un uint32 ocupa 4bytes y la struct es packed

; FUNCIONES de C
	extern malloc
	extern free
	extern fopen
	extern fclose
	extern fprintf
	extern str_len
	extern str_copy
	extern string_proc_list_remove_node_at

; /** defines bool y puntero **/
	%define NULL 0
	%define TRUE 1
	%define FALSE 0


section .data


section .text



global string_proc_list_create
string_proc_list_create:
	
	;R12 = name_copy

	push rbp   ;Alineado
	mov rbp,rsp
	sub rsp,8       ;Desalineado
	push r12  ;Alineado, pusheo rdi nombre de la lista porque si no malloc me la modifica

	;en rdi todavia tengo el *name que me pasan
	call str_copy 	;en rax me va a devolver puntero a copia del nombre, para despues tirarle free del nombre. Si no hago esta copia despues no puedo hacer free del nombre.
	mov r12, rax

	mov rdi,24   ;la struct lista ocupa 24 bytes.
	call malloc       ;ahora en rax tengo dirección de memoria de mi struct lista

	mov [rax+offset_list_name],r12
	mov qword [rax+offset_list_first],NULL ;si quiero que guarde puntero a NULL tengo 					      ;que guardar cero creo 
	mov qword [rax+offset_list_last],NULL


	pop r12
	add rsp,8
	
	pop rbp

	ret



global string_proc_node_create
string_proc_node_create:

	;RDI => R12 = f
	;RSI => R13 = g
	;RDX  => R14= type

	push rbp ;Alineada
	mov rbp,rsp
	push r12 	;Desalineada
	push r13	;Alineada
	push r14	;Desalineada
	sub rsp,8	;Alineada
	
	mov r12,rdi
	mov r13,rsi
	mov r14,rdx

	mov rdi, 33 	;la struct nodo ocupa 33 bytes porque type ocupa 1 byte. y la struct es packed
	call malloc		;ahora RAX tiene la direccion de la struct

	mov qword [rax+offset_node_next],NULL
	mov qword [rax+offset_node_previous],NULL
	mov [rax+offset_node_f],r12
	mov [rax+offset_node_g],r13
	mov [rax+offset_node_type],r14b	;hay que mover solo el ultimo byte de r14

	add rsp,8
	pop r14
	pop r13
	pop r12
	pop rbp
	ret



global string_proc_key_create
string_proc_key_create:

	;RDI = *value
	%define offset_local_var -8

	push rbp	;Alineada
	mov rbp,rsp
	sub rsp,8	;Desalineada

	push rdi	;Alineada
	

	call str_len
	mov [rbp+offset_local_var],eax	;guardo la longitud del string que habia en RDI en la var local en pila

	mov rdi,12
	call malloc

	mov esi, [rbp+offset_local_var]	;recupero length del value
	mov [rax+offset_key_length], ESI 	;guardo value length


	pop RDI 		;Desalineada
	sub rsp,8		;Alineada

	mov [rbp+offset_local_var],RAX 	;guardo puntero a la struct
	call str_copy

	mov rdi,[rbp+offset_local_var]	;aca habia guardado la direccion de la estructura que me dio malloc
	mov [rdi+offset_key_value], rax 	;guardo la copia del value

	mov rax,[rbp+offset_local_var]

	add rsp,8
	add rsp,8

	pop rbp
	ret



global string_proc_list_destroy
string_proc_list_destroy:

	;R12 = puntero a la lista
	;RDI = puntero a lo que libero en este momento, en repeat es el nodo actual
	;R13 = puntero al prox nodo

	push rbp ;A
	mov rbp,rsp
	push R12    ;D, tengo que guardar su valor por convencion
	push R13 	;A

	mov R12,rdi	;paso puntero a lista a R12 para poder llamar funciones con rdi

	;libero memoria del nombre
	mov rdi, [R12 + offset_list_name]	;pongo la direcc del name en rdi para liberarla
	call free
	
	cmp qword [r12+offset_list_first],NULL

	je .listo
	

	mov r13, [r12 + offset_list_first] 	;pongo en r13 puntero al 1er nodo de la lista
	.repeat: ;lo necesario para borrar un nodo y pasar al prox
		
		mov rdi,r13

		mov r13, [rdi + offset_node_next] ;ya pongo en r13 el siguiente nodo, antes de borrar el actual

		call string_proc_node_destroy 	;libero el nodo anterior (rdi)

		cmp qword r13,NULL
		jne .repeat

	.listo: ;libero la memoria de la lista en si
	mov rdi,r12
	mov qword [RDI + offset_list_first], NULL;
	mov qword [RDI + offset_list_last], NULL;

	call free

	pop R13
	pop R12
	pop rbp

	ret



global string_proc_node_destroy
string_proc_node_destroy:

	push rbp ;ALineado
	mov rbp,rsp

	mov qword [RDI + offset_node_next], NULL
	mov qword [RDI + offset_node_previous], NULL
	mov qword [RDI + offset_node_f], NULL
	mov qword [RDI + offset_node_g], NULL

	call free

	pop rbp
	ret



global string_proc_key_destroy
string_proc_key_destroy:

	; R12 = key

	push RBP 	;Alineado
	mov rbp,rsp
	push R12 	;Desalineado
	sub rsp,8	;Alineado

	mov r12,rdi
	mov rdi,[r12+offset_key_value]
	call free 	;libero el value

	mov qword [r12+offset_key_value],NULL
	mov qword [r12+offset_key_length],NULL

	mov rdi,r12
	call free

	add rsp,8
	pop r12
	pop rbp
	ret



global string_proc_list_add_node
string_proc_list_add_node:

	;RDI => R12 = *-lista
	;RSI = f
	;RDX = g
	;RCX = type

	push RBP 	;Alineada
	mov rbp,rsp
	push r12 	;Desalineada
	push r13 	;Alinear

	mov r12,rdi
	mov rdi,rsi
	mov rsi,rdx
	mov rdx,RCX 	;pongo todo en los registres que quiere crear_nodo

	call string_proc_node_create 	;RAX = *nodoNuevo

	cmp qword [r12 + offset_list_first],NULL
	je .vacia

	mov r13,[r12 + offset_list_last] 	;R13 = *ultimo
	mov [r12 + offset_list_last], rax
	mov [r13 + offset_node_next], rax 	;que el ultimo nodo piense que el nuevo es el siguiente
	mov [rax + offset_node_previous],r13
	jmp .listo

	.vacia:
	mov [r12 + offset_list_first], rax
	mov [r12 + offset_list_last],rax

	.listo:
	pop r13
	pop r12
	pop rbp
	ret



global string_proc_list_apply
string_proc_list_apply:
	
	;RDI->R12 = *lista
	;RSI->R13 = *key
	;RDX = bool encode
	;r14 = current node

	push rbp	;Alineada
	mov rbp,rsp
	sub rsp,8	;Desalineada
	push r12	;Alineada
	push r13	;Desalineada
	push r14	;Alineada

	mov r12,rdi
	mov r13,rsi
	cmp RDX, FALSE
	je .decode

	.encode:
	mov r14,[r12 + offset_list_first]	;el nodo actual es el primer nodo de la lista		
	
		.encodeCicle:
		cmp r14,NULL
		je .end
			
		mov rdi,r13	;para aplicarle f(key)
		call [r14+offset_node_f]

		mov r14,[r14+offset_node_next]
		jmp .encodeCicle

	.decode:
	mov r14,[r12 + offset_list_last]	
	
		.decodeCicle:	
		cmp r14,NULL
		je .end

		mov rdi,r13
		call [r14+offset_node_g]

		mov r14,[r14+offset_node_previous]
		jmp .decodeCicle

	.end:	;no hay que hacer nada mas, solo teniamos que modificar key (r13)

	pop r14
	pop r13
	pop r12
	add rsp,8
	pop rbp
	ret

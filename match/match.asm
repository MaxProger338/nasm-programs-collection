%include "stud_io.inc"
global _start

match:	
		push 	ebp				; организуем стековый фрейм
		mov		ebp, esp
		sub		esp, 4			; локальная переменная I
		push	esi				; сохраняем ESI и EDI
		push	edi				;	согласно CDECL 
		mov		esi, [ebp+8]	; сопоставляемая строка
		mov		edi, [ebp+12]	; строка-образец
.again:							; сюда вернёмся когда сопоставим очередной
								;	символ и сдвинемся
		cmp		byte [edi], 0   ; это конец образца?
		jne		.not_end
		cmp		byte [esi], 0	; а сопоставляемая строка кончилась?
		jne		.false			; если нет, возвращаем ЛОЖЬ
		je		.true			; если да, возвращаем ИСТИНУ, ведь 
								;	действительно с пустой строкой можно
								; 	сопоставить только пустую строку
.not_end:						; сюда попадём, если образец не пустой
		cmp		byte [edi], '*' ; не звёздочка ли это?
		jne		.not_star		; если нет, прыгаем отсюда
								; звёздочка! инициируем цикл
		mov		byte [ebp-4], 0	; I := 0
.star_loop:						; сюда попадём если наткнулись на '*'
								;	будем пытаться сопоставить строку с
								;	остатоком образеца после '*',
								;	отбрасываю от неё по I-символов
		mov		eax, edi			; ПОДГОТОВКА К РЕКУРС. ВЫЗОВУ
		inc		eax					; след. символ после '*'
		push	eax					; 2-й аргумент
		mov		eax, esi
		add		eax, [ebp-4]		; добавляем смещение строки (I),
									;	начиная с нуля, ведь цепочка
									;	может быть и пустой
		push	eax					; 1-й аргумент
		call	match				; пытаемся сопоставить альтернативу
		test	eax, eax			; что же нам вернули? 
		jnz		.true				; если сопостовление альтернативы 
									;	прошло успешно - возвращаем ИСТИНУ
		mov		eax, [ebp-4]		; EAX := I
		cmp		byte [esi+eax], 0	; но, быть может, строка 
									;	уже закончилась?
		je		.false
		inc		dword [ebp-4]		; I := I + 1
		jmp		.star_loop
.not_star:
		mov		al, [edi]
		cmp		al, '?'			; не '?' ли очередной символ образца?
		je		.quest			; если да, прыгаем

		cmp		al, [esi]		; если это не '?' и не '*' значит
								;	и мы должны просто сравнить их;
								;	если образце кончился - мы до сюда
								;	не дойдём, а если строка кончилась,
								;	то проверка не пройдёт 
		jne		.false			; возвращаем ЛОЖЬ они не равны
		jmp		.goon			; символы успешно сопоставелись,
								;	переходим к след.
.quest:							; сюда прыгнем если очередной символ
								;	образца '?' и не '*'
		cmp		byte [esi], 0	; здесь нам нужно только лишь бы
								;	строка не кончилась
		je		.false
.goon:							; до сюда дойдём если очередное 
								;	сопостовление успешно
		inc		esi				; переходим к след. символу строки
		inc		edi				; переходим к следю символу образца
		jmp		.again
.true:							; сюда мы попадём если сопостовление строк
								;	прошло успешно
		mov		eax, 1			; ИСТИНА
		jmp		.quit
.false:							; сюда же, если сопоставить не удалось
		xor		eax, eax		; ЛОЖЬ
.quit:
		pop		edi				; приводим всё в порядок
		pop		esi
		mov		esp, ebp		; чистим все локальные переменный
		pop		ebp				; восстанавливаем EBP согласно CDECL
		ret 8					; чистим стек от переданных аргументов 

_start:	
		mov		esi, [esp+8]	; сопоставляемая строка
		mov		edi, [esp+12]	; строка-образец
		push 	edi
		push 	esi
		call 	match

		test	eax, eax
		jz		not_matched
		PRINT "Yes"
		PUTCHAR 10
		jmp		done
not_matched:
		PRINT "No"
		PUTCHAR 10
done:	FINISH

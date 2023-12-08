format PE Console

entry start

include 'INCLUDE\WIN32Ax.INC'

macro shells matrix, off, shell; поиск крайних битов в строках
{
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	
	
	mov ecx, [off]; количество строк

	@@:
		dec ecx
		mov eax, [matrix + 4*ecx]
		bsf ebx, eax ; поиск в строке от меньшего по индексу бита к большему

		btc dword[shell+4*ecx], ebx ; дополняем и записывает бит по индексу из ebx
		bsr ebx, eax ; от большего к меньшему
		btc dword[shell+4*ecx], ebx ;test and complement bit in memory
		
		cmp ecx, 0 ; цикл по строкам
			je @F
		
		cmp ecx, 0
			jne @B
	
	
	@@:

}


macro shellr matrix, off, rows, shell; ищет по столбцам крайние точки
{ local rowscycle
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx
	mov ecx, [rows]; столбцы

	mov edx, [off] ; строки

	rowscycle:
		dec ecx ; уменьшаем, потому что нужны индексы от 0
		mov edx, [off]
		
		@@:; по строкам
			dec edx
			shl ebx, 1 ; сдвиг влево для формирования столбца
			mov eax, [matrix + 4*edx]
			bt eax, ecx ; проверяем бит, и через флаги сравниваем CF

			lahf ; выгружаем регистры в ah
			and ah, 00000001b ; умножаем CF на 1 и проверяем, является ли бит с индексом из ecx единицей
			.if ah <> 0 ; если при умножении единица, то формируем строку из столбца
				add ebx, 1
			.endif
			  
			
			.if edx <> 0 ; цикл для нуля тоже выполнится
				jmp @B
			.endif
			
		@@:
		xor eax, eax
		.if ebx <> 0 ; если столбец не нулевой
			bsf eax, ebx; ищет бит слева
			
			bts dword[shell+4*eax], ecx ; проверяет и устанавливает бит
			bsr eax, ebx ; ищет в строке правый бит
			bts dword[shell+4*eax], ecx
			
			
			xor ebx, ebx
		.endif
		cmp ecx, 0 ; цикл по столбцам

			jne rowscycle
	
	
}

macro masscopy ms, cop, off
{
	xor eax, eax
	xor ecx, ecx
	mov ecx, [off] ; количество строк
	@@:
		
		dec ecx
		mov eax, [ms + 4*ecx]
		mov [cop + 4*ecx], eax ; копируем массив
			
		.if ecx <> 0
			jmp @B
		.endif
	
	@@:

}
macro findfirst x, y, shell, off, row ; находит индексы первой единицы в матрице
{
	xor eax,eax
	xor ecx, ecx
	xor edx, edx
	xor ebx, ebx
	mov ecx, 0 	
	mov ebx, [row]
	
	@@:
		mov eax, [shell+ 4*ecx]
		bsf ebx, eax
	    .if eax <> 0 ; если строка не нулевая
			mov [x],ecx 
			mov [y], ebx
			mov ecx, [off]
			
		.endif
		
		.if ecx <> [off]
			inc ecx
			jmp @B
		.endif
		.if eax <> 0
		
			xor eax, eax
			xor ebx, ebx
			mov eax, [x]
			mov ebx, [y]
		.endif
		
}		

macro bypas x, y, off, row, copy, targetx, targety, answer, posl; проходит по матрице в 8 направлениях
{
	@@:
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx
	mov ecx, 3 ; индикатор выхода из цикла; если ни в одном из 8 направлений нет единицы
	mov ebx, [y]
	inc ebx
	mov edx, [row]
	
	.if ebx < edx ; y+1 < столбцы (inc ebx выше), влево

		dec ebx
		xor edx, edx
		mov edx, [x]
		mov eax, [copy+4*edx]
		inc ebx
		bt eax, ebx ; проверка y+1 бита матрицы оболочки

		lahf ; выгружаем флаги для проверки бита через CF
		and ah, 00000001b
		.if ah <> 0
			btc dword [copy+4*edx], ebx ; если мы заходим в точку, то она обнуляется, чтобы алгоритм прошел одним путем
			bts dword [posl + 4* edx], ebx ; заносим точку в матрицу прохода по соответствующему индексу
			mov [y], ebx
			mov ecx, 1 ; индикатор для того, чтобы не заходило в последующие направления
		.endif
	
	.endif
	.if ecx <> 1
		mov eax, [x]
		inc eax
		mov ebx, [off]
		.if eax < ebx ; x+1 < строки
			mov eax, [y]
			inc eax
			mov ebx, [row]
			
			.if eax < ebx ;y + 1 < столбцы, по диагонали вниз и  влево
				

				xor edx, edx
				mov edx, [x]
				inc edx
				xor ebx, ebx
				mov ebx, [y]
				inc ebx
				mov eax, [copy+4*edx]

				bt eax, ebx ; проверка y+1 бита
			
				lahf
				and ah, 00000001b
				.if ah <> 0
					btr dword [copy+4*edx], ebx
					bts dword [posl + 4* edx], ebx
					mov [x], edx
					mov [y], ebx
					
					mov ecx, 1
				.endif
			.endif
		.endif
	
	.endif

	.if ecx <> 1
		mov eax, [x]
		inc eax
		mov ebx, [off]
		.if eax < ebx ; x+1 < строки, вниз
	
			xor edx, edx
			xor ebx, ebx
			mov edx, [x]
			inc edx
			mov ebx, [y]	
			mov eax, [copy+4*edx]

			bt eax, ebx ; проверка y бита
		
			lahf
			and ah, 00000001b
			.if ah <> 0
				btr dword [copy+4*edx], ebx
				bts dword [posl + 4* edx], ebx
				mov [x], edx
				mov ecx, 1
			.endif
				
			
		.endif
	
	.endif
	
	.if ecx <> 1
		mov eax, [x]
		inc eax
		mov ebx, [off]
		.if eax < ebx ; x+1 < строки
			mov eax, [y]
			dec eax
			mov ebx, [row]
			
			.if eax >= 0 ;y + 1 < столбцы, по диагонали вниз и вправо
				

				xor edx, edx
				mov edx, [x]
				inc edx
				xor ebx, ebx
				mov ebx, [y]
				dec ebx
				mov eax, [copy+4*edx]

				bt eax, ebx ; проверка y+1 бита
			
				lahf
				and ah, 00000001b
				.if ah <> 0
					btr dword [copy+4*edx], ebx
					bts dword [posl + 4* edx], ebx
					mov [x], edx
					mov [y], ebx
					
					mov ecx, 1
				.endif
			.endif
		.endif
	
	.endif
	
	.if ecx <> 1
		mov eax, [y]
		dec eax
		mov ebx, [row]
			
		.if eax >=0 ; y-1 >=0, вправо

	
			xor edx, edx
			mov edx, [x]

			xor ebx, ebx
			mov ebx, [y]
			dec ebx
			mov eax, [copy+4*edx]

			bt eax, ebx ; проверка y-1 бита
		
			lahf
			and ah, 00000001b
			.if ah <> 0
				btr dword [copy+4*edx], ebx
				bts dword [posl + 4* edx], ebx
				mov [x], edx
				mov [y], ebx
				
				mov ecx, 1
			.endif
			
		.endif
	
	.endif
	
	
	.if ecx <> 1
		mov eax, [x]
		dec eax
		mov ebx, [off]
		.if eax >= 0 ; x-1 >=0
			mov eax, [y]
			dec eax
			mov ebx, [row]
			
			.if eax >= 0 ;y - 1 >=0, по диагонали вверх и вправо
				

				xor edx, edx
				mov edx, [x]
				dec edx
				xor ebx, ebx
				mov ebx, [y]
				dec ebx
				mov eax, [copy+4*edx]

				bt eax, ebx ; 
			
				lahf
				and ah, 00000001b
				.if ah <> 0
					btr dword [copy+4*edx], ebx
					bts dword [posl + 4* edx], ebx
					mov [x], edx
					mov [y], ebx
					
					mov ecx, 1
				.endif
			.endif
		.endif
	
	.endif
	
	.if ecx <> 1
		mov eax, [x]
		dec eax
		mov ebx, [off]
		.if eax >= 0 ; x-1 >= 0 ; вверх

			xor edx, edx
			mov edx, [x]
			dec edx
			xor ebx, ebx
			mov ebx, [y]
		
			mov eax, [copy+4*edx]

			bt eax, ebx ; проверка y бита
		
			lahf
			and ah, 00000001b
			.if ah <> 0
				btr dword [copy+4*edx], ebx
				bts dword [posl + 4* edx], ebx
				mov [x], edx
				mov [y], ebx
				
				mov ecx, 1
			.endif	
			
		.endif
	
	.endif
	
	
	.if ecx <> 1
		mov eax, [x]
		dec eax
		mov ebx, [off]
		.if eax >= 0 ; x-1 >= 0
			mov eax, [y]
			inc eax
			mov ebx, [row]
			
			.if eax < ebx ; по диагонали вверх и влево
				

				xor edx, edx
				mov edx, [x]
				dec edx
				xor ebx, ebx
				mov ebx, [y]
				inc ebx
				mov eax, [copy+4*edx]

				bt eax, ebx ; проверка y+1 бита
				
				lahf
				and ah, 00000001b
				.if ah <> 0
					btr dword [copy+4*edx], ebx
					bts dword [posl + 4* edx], ebx
					mov [x], edx
					mov [y], ebx
					
					mov ecx, 1
				.endif
			.endif
		.endif
	
	.endif
	
	.if ecx = 3 ; else если все варианты не привели ни в одно из 8 направлений т.е. не замкнутая 
		mov [answer], 0
		jmp @F
	.endif
	
	mov eax, [x]
	mov ebx, [targetx]
	mov ecx, [y]
	mov edx, [targety]
	
	.if eax <> ebx | ecx <> edx ; цикл, пока не дойдем до исходной точки
		jmp @B
	.endif
	.if eax = ebx | ecx = edx ; если дошли до начала, то оболочка замкнутая
		mov [answer], 1
	.endif
	@@:
}

macro showinverse counter, targetcounter, row, data
{
	mov edx, [row]
	
	mov ecx, 0
	
	mov [targetcounter], edx
	mov [counter], 0 
	
	@@:
		mov ecx, [counter]
		mov edx, [data]
		bt edx, ecx
		lahf
		and ah, 00000001b
		add ah, 30h
		mov [input], ah
		

		inc ecx
		mov [counter], ecx
		

		ccall	[printf], input
		
		mov edx, [targetcounter]
		mov ecx, [counter]
		
		.if ecx < edx
			jmp @B
		.endif
		
}

macro show counter, targetcounter, row, data
{	
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx
	mov ebx, [row]
	dec ebx
	mov ecx, 0
	
	mov [targetcounter], ecx
	mov [counter], ebx 
	
	@@:
		mov eax, [temp_offset]
		mov edx, [data]
		
		bt edx, ebx
		lahf
		and ah, 00000001b
		add ah, 30h
		mov [input], ah
		

		mov [targetcounter], ecx
		mov [counter], ebx
		

		xor eax, eax
		ccall	[printf], input
		mov eax, [temp_offset]
		
		mov ecx, [targetcounter]
		mov ebx, [counter]
		dec ebx
		.if ebx > 0

			
			jmp @B
		.endif
		
		
		mov eax, [temp_offset]
		mov edx, [data]
		bt edx, 0
		lahf
		and ah, 00000001b
		add ah, 30h
		mov [input], ah
		
		xor eax, eax
		ccall	[printf], input
		mov eax, [temp_offset]
	
}

macro showseveral counter, targetcounter, row, data, off
{ ; макрос выводит биты с помощью printf, занося их в переменную
	local labe
	xor eax, eax
	mov eax, 0
	mov [temp_offset], eax ; сохраняем eax, потому что printf меняет регистры 
	

	labe:; цикл по строкам
		mov eax, [temp_offset]
		mov [temp_offset], eax

		xor ebx, ebx
		xor ecx, ecx
		xor edx, edx
		mov ebx, [row]
		dec ebx
		mov ecx, 0
		mov [targetcounter], ecx
		mov [counter], ebx 
		
		@@: ; цикл, который проходит по всем битам
			mov eax, [temp_offset]
			mov edx, [data+eax*4]
			
			bt edx, ebx
			lahf
			and ah, 00000001b
			add ah, 30h
			mov [input], ah ; заносим бит в переменную


			mov [targetcounter], ecx ; перед printf сохраняем счетчики
			mov [counter], ebx
			
			
			xor eax, eax
			ccall	[printf], input
			mov eax, [temp_offset]
			
			mov ecx, [targetcounter]; восстанавливаем счетчики
			mov ebx, [counter]
			dec ebx
			.if ebx > 0
				jmp @B
			.endif
			
			
			mov eax, [temp_offset]
			mov edx, [data+eax*4]
			bt edx, 0
			lahf
			and ah, 00000001b
			add ah, 30h
			mov [input], ah
			
			xor eax, eax
			ccall	[printf], input
			mov eax, [temp_offset]
		

		show_empty ; выводит пустую строку
		mov eax, [temp_offset]
		mov ebx, [off]
		dec ebx
		.if eax <> ebx 
			inc eax
			mov [temp_offset], eax
			xor ebx, ebx
			jmp labe
		.endif
	
}

macro show_empty
{	
	push emptystring
	call [printf]
}


section '.data' data readable writeable
	x dd 0 ; для прохода по матрице
	y dd 0
	targetx dd 0 ; переменные для сравнения в цикле, статичные
	targety dd 0 ; 
	answer dd 0 ; для результата
	
	
	emptystring db '', 13, 10, 0
	counter dd 0
	targetcounter dd 0
	temp_offset dd 0
	
	
	string db 'prohod: = %X,%X,%X', 13, 10 ,0
	shellf db 'shell: = %X,%X,%X', 13, 10, 0; для вывода
	stringf db 'Result = %d (1-YES, 0-NO)', 13, 10, 0

	
	mass dd 011111b,\
		    010001b,\; исходная матрица
		    111111b,\
			011111b
		
			
	len = $ - mass
	ccl = len/4

	
	
	row dd 6 ; количество столбцов
	;row = mass.pole
	offset dd ccl ; количество строк
	
	copy dd offset dup (0) ; копия оболочки, при заходе в каждую точку она обнуляется
	posl dd offset dup (0) ; сюда добавляются биты, по которым проходит алгоритм
	shell dd offset dup (0) ; оболочка
	input db 0 ; для вывода бита в консоль, каждый бит имеет размер db
		

section '.code' code readable writeable executable
start:
	; invoke	SetConsoleOutputCP,1251
	; invoke	SetConsoleCP,1251
	invoke  WriteConsole,<invoke GetStdHandle,STD_OUTPUT_HANDLE>,"Array",5,0
	show_empty
	
	showseveral counter, targetcounter, row, mass, offset ; выводим весь mass
	show_empty
	
	
	shells mass, offset, shell ; находим крайние точки строк
	

	invoke  WriteConsole,<invoke GetStdHandle,STD_OUTPUT_HANDLE>,"Shell Left",10,0
	show_empty

	showseveral counter, targetcounter, row, shell, offset
	show_empty
	
	invoke  WriteConsole,<invoke GetStdHandle,STD_OUTPUT_HANDLE>,"Shell Left and Right",20,0
	show_empty
	
	
	shellr mass, offset, row, shell ; находим крайние точки столбцов
	
	
	showseveral counter, targetcounter, row, shell, offset ; выводим всю оболочку
	show_empty

	masscopy shell, copy, offset ; копируем оболочку, макрос копирует массив
	findfirst x, y, mass, offset, row ; находим первую встречную точку в оболочке
	findfirst targetx, targety, mass, offset, row ; также находим первую встречную точку(для сравнения в проходе)
	bypas x, y, offset, row, copy, targetx, targety, answer, posl ; проход по матрице

	push [answer] 
	push stringf
	call [printf] ; выводим ответ (1 или 0)
	
	show_empty
	invoke  WriteConsole,<invoke GetStdHandle,STD_OUTPUT_HANDLE>,"Matrix pass",11,0
	show_empty

	showseveral counter, targetcounter, row, posl, offset ; выводим проход
	show_empty

	
finish:
 invoke ExitProcess,0
	
section '.idata' data import readable
        library kernel32, 'kernel32.dll',\
                msvcrt, 'msvcrt.dll'
 
    import kernel32,\
               ExitProcess,'ExitProcess',\
               GetStdHandle,'GetStdHandle',\
               WriteConsole,'WriteConsoleA',\
               ReadConsole,'ReadConsoleA'     
  import msvcrt,\
                         printf, 'printf'
						 
						 
;konwertuje duza litere na mala
.model small
.stack 100h
CR	equ	13d
LF	equ	10d
.data
	newline db CR,Lf,'$'
	fail db 'blad', '$'
.code
	prints:
		mov ah, 9h
		int 21h
	nextline: ;definiuje podprogram
		push dx
		push ax
		mov dx, offset newline
		mov ah, 9h
		int 21h
		pop ax
		pop dx
		ret
	start:
		mov	ax, @data
		mov ds, ax
		
		mov ah, 1h;wczytanie znaku
		int 21h
		mov bl,al	
		
		cmp bl,'A';porownanie z graniczna wartoscia ASCII(dolna)
		jl blad
		cmp bl, 'Z';porownanie z graniczna wartoscia ASCII(gorna)
		jg blad
		add bl,32d;jesli nalezy do przedzialu to konwertujemy przy pomocy ASCII na mala litere
		
		call nextline
		mov dl, bl; wrzuc zawartosc bl do dl i wypisz
		mov ah,2h
		int 21h
		jmp koniec
		
		
		blad:
			call nextline
			mov dx, offset fail; skopiuj adres napisu i wyrzuc go na ekran
			call prints
			jmp koniec
	
		koniec:
			mov ax,04c00h ; koniec
			int 21h
	end start

 

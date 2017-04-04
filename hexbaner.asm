
.model small
.stack 
CR	equ	13d;carriage return
LF	equ	10d;line feed
.data
	newline db CR,Lf,'$'
	erro db 'podales bledna cyfre', '$'
	baner1 db '   #   $', '  ##   $', ' # #   $', '   #   $', '   #   $', '   #   $', ' ##### $'
	baner0 db '  ###  $', ' #   # $', '#     #$', '#     #$', '#     #$', ' #   # $', '  ###  $'
.code
	nextline:
		mov dx, offset newline
		mov ah, 9h
		int 21h
		ret
	prints:
        mov ah, 9h
        int 21h
        ret
	start:
			
		mov	ax, @data;wczytanie danych
		mov ds, ax
		
		mov ah, 1h;wczytanie znaku
		int 21h	
		
		call nextline
		
		;sprawdzenie znaku
		cmp al,'0';jesli mniejsze od 0 to blad
        jb err 
                
        cmp al,'9';jesli z zakresu 0-9 przekonwertuj
        jbe convertdigit 
                
        cmp al,'A' ;jesli mniejsza od A to blad
        jb err 
                
        cmp al,'F' ;jest z zakresu A-F to przekonwertuj duza
        jbe convertbig 
                
        cmp al, 'a' ; jesli mniejsze od a t o blad
        jb err
                
        cmp al, 'f' ;jesli a-f przekonwertuj mala
        jbe convertsmall
        jmp err; reszta to blad
		
		
		convertdigit:
			sub al,'0';odejmuje graniczna wartosc ASCII
			jmp next1
		convertbig:
		    sub al,'A';odejmuje graniczna wartosc ASCII i zwiekszam o 10(bo A=10 itd)
			add al,10
			jmp next1
		convertsmall:
			sub al,'a';odejmuje graniczna wartosc ASCII i zwiekszam o 10(bo a=10 itd)
			add al,10
			jmp next1
		
		
		
		;dwie petle, jedna odpowiedzialna za wypisanie baneru, jedna za pobieranie bitow liczby
		next1:
			mov cx,7;licznik petly zewnetrznej
			mov bx,0;tu bede zapisywal przesuniecie baner1 i baner0
			push cx
			mov cl,4
			shl al,cl;przesuwam pierwsze 4 bity naszej liczby poniewaz ich nie potrzebujemy
			pop cx
		printall:
			push cx
			push ax
			mov cx,4;licznik petli wewnetrznej
		
		printbit:
			shl al,1;przesuwam o 1 bit w lewo
			jnc print0;porownuje bit ktory przesunalem (jesli cf=0 drukuje 0, jesli nie to drukuje 1)
			mov dx, offset baner1
			add dx,bx;przeskok
			mov ah, 9h
			int 21h
			jmp next2
		
		print0:
			mov dx, offset baner0
			add dx,bx;przeskok
			call prints
		next2:
			loop printbit
			call nextline
			add bx,8;przeskakuje do nowej lini banera
			pop ax
			pop cx
			loop printall
			jmp endd
		
		err:
			mov dx, offset erro;wyswietlam komunikat
			call prints
			jmp endd
		
		endd:
			mov ax,04c00h ; koniec programu
			int 21h
			
			
		
	end start

 

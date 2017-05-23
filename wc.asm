;Uproszczony odpowiednik polecenia wc. Wywołanie: wc nazwa-pliku. Wynik: 3 liczby odpowiednio dla znaków, słów i wierszy.
.model	small					
.stack	100h					
.data
	char	db "$"
	bool	db 0				; pamietamy czy ostatnio byla litera 0 - nie, 1 - tak
	znaki		db "znaki:"
	ile_z	db 0h, "   ",10
	slowa		db "slowa:"
	ile_s	db 0h, "   ",10
	linie	db "linie:"
	ile_l	db 01h, "   ", "$"
	
	
.code
start:
	xor	ax, ax
	mov	bx, 80h					; argument - nazwa pliku z linii komend
	mov	al, [bx]				; bierzemy dlugosc nazwy
	add	bx, ax				
	inc	bx
	mov	byte ptr ds:[bx], 0
	mov	dx, 82h					; bierzezmy pierwszy znak z pliku
	mov	al, 0h					; opcja 0 tylko do odczytu
	mov	ah, 03dh				; opcja 03dh otwiera plik
	int	21h
	jb	zakoncz					; jesli CF jest 1 to plik sie nie otworzyl
	mov	bx, ax					; jesli jest ok, to plik mamy w bx
	mov	ax, @data			
	mov	ds, ax					; data do ds
	jmp	czytaj


czytaj:

	;czytamy plik po jednym znaku do zmiennej znak
	mov	cx, 1h		
	mov	dx, offset char			; adres bufora
	mov	ah, 03fh				; funkcja 03fh czyta z uchwytu
	int	21h
	cmp	al, 0h					; al = 0h, gdy koniec pliku
	je	na_koniec
	inc	[ile_z]
	; czy spacja?
	cmp	[char], 20h
	je spacja
	jne	czylinia
spacja:
	; czy spacja jest po slowie?
	cmp	[bool], 0h	
	je	czytaj
	inc	[ile_s]		
	mov	[bool], 0h				
	jmp	czytaj					
czylinia:
	; czy new line?
	cmp	[char], 0ah	
	je	newline
	; czy koniec linii
	cmp	[char], 20h             ;skocz jesli mniejsze, bo to nie znak
	jb	czytaj
	; tu jest znak				
	mov	[bool], 1h				; 1 bo byl znak
	jmp	czytaj					; czytamy kolejny znak

	
newline:
	inc	[ile_l]
	; czy ostatnio byl znak?
	cmp	[bool], 0h
	je	czytaj
	inc	[ile_s]	
	mov	[bool], 0h				; ustawiamy ostatni znak - newline
	jmp	czytaj
	
	
na_koniec:			
	; czy ostatnio byl znak?
	cmp	[bool], 0h	
	je	zamien
	inc	[ile_s]
	jmp	zamien					; zamien wyniki na dziesietne
	
wypisz:
	mov	dx, offset znaki			; wypisujemy wyniki
	mov	ah, 09h					; opcja 09h wypisuje na ekran
	int 21h	
	
zakoncz:
	mov	ah, 03eh				; opcja 03eh zamyka plik
	int	21h
	mov	ax, 4c00h				; opcja zamykania programu
	int	21h	
; zamieniamy wyniki na liczby do wyswietlenia na ekran:
zamien:
	push bx
	
	mov	al, [ile_z]				
	mov	cx, 03h					; wynik ma 3 cyfry
	mov	bl, 0ah					; do zamieniania na dziesietne 10 do bl
	mov	si, offset ile_z		; source index
	add	si, 03h
	
; znaki - zamiana systemu na dziesietny:
licz_z:
	xor	ah, ah
	div	bl						; dzielenie al/bl: ah -> reszta, w al -> wynik
	mov	byte ptr ds: [si], ah
	add	byte ptr ds:[si], 30h	; dodajemy zera 
	dec	si						
loop licz_z
; slowa tak samo:
	mov	al, [ile_s]
	mov	cx, 03h
	mov	bl, 0ah
	mov	si, offset ile_s
	add	si, 03h
licz_s:
	xor	ah, ah
	div	bl
	mov	byte ptr ds:[si], ah
	add	byte ptr ds:[si], 30h
	dec	si
loop licz_s
; i linie:
	mov	al, [ile_l]
	mov	cx, 03h
	mov	bl, 0ah
	mov	si, offset ile_l
	add	si, 03h
licz_l:
	xor	ah, ah
	div	bl
	mov	byte ptr ds:[si], ah
	add	byte ptr ds:[si], 30h
	dec	si
loop licz_l
; dodoajemy spacje przed wyniki
	mov	[ile_z], 20h
	mov	[ile_s], 20h
	mov	[ile_l], 20h
	jmp	wypisz
	pop	bx	
end start  

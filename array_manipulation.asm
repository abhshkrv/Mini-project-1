; ABHISHEK RAVI 
; A0074613J


.MODEL small
.STACK 64   
;stack not used
;########## DATA SEGMENT ###############################################


data_area segment    ; Definition of the data segement begins here
master          db  20  dup(0)
test1 			dw ?
array1          DB   0001,00010,00011,00016,0018,00012,0006,00014,0004
array2 	        db   0005,0000,0002,0011,0016,0015,0006,00010,0008,0013,001,000Ch,00017,0009,0018,0019    ; reserves 24 bytes of space
                                ; without any inititalization    
word1           db  10 dup(?) 
word2           db  10 dup(?)                                                      
word1_odd_message	    db	"Word 1 is odd " , "$"
word1_even_message    db  "Word 1 is even " , "$"  
word2_odd_message db "Word 2 is odd " , "$"
word2_even_message db "Word 2 is even "   , "$"
master_array_msg db "Master Array : " , "$"
word1_msg db "Word 1 : " , "$"
word2_msg db "Word 2 : " , "$"  
hammel_msg db "Square of the HD is : ", "$"
 
d0 dw 0					;contains ones digit
d1 dw 0					; tens digit
d2 dw 0					;100s digit
d3 dw 0 				;1000s digit
                                           
data_area ends       ; data segment ends here
;******************************************
;*****************************************    

;#####################CODE SEGMENT ########################################
code    segment     ; code segment begins here
assume cs:code,ds:data_area,es:data_area



offset_address MACRO 				;macro prints the offset address contained in ax 
	mov cx, 10					; move 10 to cx
	xor dx,dx
	div cx
	mov d0,dx				; value of mod (ie remainder) is stored in dx after division   
	xor dx,dx
	div cx
	mov d1, dx				; remainder in d1
	xor dx,dx
	div cx
	mov d2, dx				; remainder stored in d2
	mov d3, ax				;1000s place is what is left of the number ax
	
	
	add d0, '0'				;to print as a number
	add d1, '0'
	add d2, '0'
	add d3, '0'
	
	
	mov ah,2					;print each digit using int21
	mov dx,d3
	int 21h
	mov dx,d2
	int 21h
	mov dx,d1
	int 21h
	mov dx,d0
	int 21h
ENDM
                                 ; //entry point
start:
 
 
 
        mov     ax,data_area   ; loading ds, es segments indirectly using a GPR (ax)
		mov		ds,ax
		mov     es,ax
	
	 mov dx , offset master_array_msg         ;print "master array : " using int 21 
			    mov ah , 0009h
			    int 21h 
	   mov dx , 0000h                         ;clear dx
	
		MOV 	CX,9h                         ;loop 9 times (for each element in array1
		mov 	SI,offset array1; address of array1
		mov		DI,offset master; address of master
		
		AGAIN: 	
		        MOV AX,0000h ; clear ax
		        MOV AL,[SI] ; contents of current SI
				CMP  AX,000Ah   ; is AX < 10 ? 
				JB putone       ; if yes , go to putone
				
		NEXTITER:INC SI
				
				DEC CX
				JNZ AGAIN
		                     
		      jmp end_of_putone        ; putone is not executed strayly      
		     putone: 
		        mov di , offset master
				add di , ax 
				;add di , 0001h
				MOV [di], 0001h
				;mov AX[BX],01h
				JMP NEXTITER	
		                     
		    end_of_putone:   
		                                ; prevent putone execution
			
	
	
	  MOV SI,offset master              ; load SI with master array
			mov cx,14h                  ; load cx with 20 (loop 20 times)
	
	
	print:	
			mov dl,[SI]
			add dl,'0'                 ; to print ascii
			mov ah,02h                 ; to print a char stored in dl
			int 21h   
								
			inc SI
			DEC CX
			JNZ print  
;############### OFFSET ADDRESS #############################
			         
            mov dl,10d                 ; this code chunk goes to a new line 
			int 21h;                   ; ie, line feed + carriage return
			mov dl,13d
			int 21h

		    mov cx , 16h
		    	
		
			mov si , offset master    
			
			offset_add:
			cmp [si] , 0001h               ; is the value at master array = 1?
			JE print_offset                ; if yes, print offset
		 
		   ret_print_offset:               ; if no, come here without printing offset
		            inc si                 ; continue loop
		            dec cx
		            jnz offset_add 
			               
			jmp end_of_print_offset         ; prevents print_offset being executed after this loop ends
			               
			print_offset:
			            mov ax , si         ; load ax with offset address
			            offset_address      ; macro to print the hex number at ax
			            jmp ret_print_offset ; return 
			            
			 end_of_print_offset:          ; control reaches here
			               
			mov dl,10d                     ; new line + carriage return
			int 21h;
			mov dl,13d
			int 21h
                                
; ################WORD1############     
                
                
                
                mov dx , offset word1_msg         ;print "word 1 : "  using int21
			    mov ah , 0009h
			    int 21h    
                mov ax , 0000h 
                mov dx , 0000h
       	        mov cx , 000Ah                  ; load cx with 10 (10 elements)
                mov si , offset master  
                mov di , offset word1
                         
 create_word1:  mov al, [si]
       	        mov [di] , al                   ; mov content of master[si] to di(destination, ie word1)
       	        mov dl,[di]
    			add dl,'0'                     ;mov to dl and add '0' to print digit
    			
    			mov ah,02h
    			int 21h   
    					
    			add SI , 2                   ; increment by 2 to use alternate elements
    			inc di
    			DEC CX
    			JNZ create_word1     
    			
    			
    		mov dl,10d                       ; new line
			int 21h;
			mov dl,13d
			int 21h
    			
;#############find parity##############
               
                mov cx , 000Ah
                mov si , offset word1
                mov bx , 0000h
 findparity:  mov al , [si]                ; load element from master array
                cmp al , 01h               ; is it = 1?
                je is_one                  ; yes? then go to is_one
                
                
                
                
                
                 
  is_not_one:  inc si                       ; if not one, continue with loop
                dec cx 
                JNZ findparity
                
             
             jmp end_of_is_one             ; same logic as previous loops with conditions
          
              	is_one: 
		        inc bx                     
		        jmp is_not_one      
		        
		        end_of_is_one:
                
                
                
                add bx , 0000h            ; add 0 so that parity flag is set at the end of this instruction
                JPO is_even               ; is it even?                               
                mov dx , offset word1_odd_message         ;if no, print "word is odd"  
			    mov ah , 0009h                            ; int21 to print string
			    int 21h                  
			    jmp retrn
			    
			    is_even:
		        mov dx , offset word1_even_message           
			    mov ah , 0009h
			    int 21h 
			    
			    
		
		retrn:	                  
		        
;################################		EXPERIMENT 2 ########################3
             
             
             
             
   ;#######CLEAR MASTER ARRAY ################
                                              ; this is to start fresh for experiment 2
                    mov SI , offset master 
                    mov cx , 14H
       clearmaster: mov [si] , 0
                    inc si
                    dec cx
                    jnz clearmaster
        
      ;######################################     
      
      
      
      ; NOTE : the SAME logic has been used for array 2. CX is loaded with 16 instead of 9
       
       
        mov dx , offset master_array_msg           
			    mov ah , 0009h
			    int 21h 
       
       ; creates master array
		mov 	SI,offset array2; address of array2
		mov		DI,offset master; address of master
		mov     cx , 000fh
		AGAIN2: 	
		        MOV AX,0000h
		        MOV AL,[SI] ; contents of current SI
				CMP  AX,000Ah
				JB putone2  
				
							
		NEXTITER2:INC SI
				
				DEC CX
				JNZ AGAIN2
		                    
		        jmp end_of_putone2
		                    
		       putone2: 
		        mov di , offset master
				add di , ax 
				;add di , 0001h
				MOV [di], 0001h
				;mov AX[BX],01h
				JMP NEXTITER2	
		                     
		    end_of_putone2:                 
		                    
		                 ;yay
			MOV SI,offset master
			mov cx,14h
	print2:	
			mov dl,[SI]
			add dl,'0'
			mov ah,02h
			int 21h   
								
			inc SI
			DEC CX
			JNZ print2                 
			
;############### OFFSET ADDRESS #############################
			         
            mov dl,10d
			int 21h;
			mov dl,13d
			int 21h

		    mov cx , 16h
		    	
		
			mov si , offset master   
			
			offset_add1:
			cmp [si] , 0001h
			JE print_offset1
		 
		   ret_print_offset1:
		            inc si
		            dec cx
		            jnz offset_add1 
			               
			jmp end_of_print_offset1
			               
			print_offset1:
			            mov ax , si
			            offset_address
			            jmp ret_print_offset1  
			            
			 end_of_print_offset1:        
			               
			mov dl,10d
			int 21h;
			mov dl,13d
			int 21h
                                
; ################WORD2############     
               
                mov dx , offset word2_msg           
			    mov ah , 0009h
			    int 21h 
               
               
               
                mov di , offset word2
       	        mov cx , 000Ah 
                mov si , offset master 
                         
 create_word2:  mov ax, [si]
       	        mov [di] , ax 
       	        mov dl,[di]
    			add dl,'0'
    			
    			mov ah,02h
    			int 21h   
    					
    			add SI , 2
    			inc di
    			DEC CX
    			JNZ create_word2     
    			
    			
    		mov dl,10d
			int 21h;
			mov dl,13d
			int 21h
    			
;#############find parity##############
               
                mov cx , 000Ah
                mov si , offset word2
                mov bx , 0000h
 findparity2:  mov al , [si]
                cmp al , 01h
                je is_one2 
                
  is_not_one2:  inc si
                dec cx 
                JNZ findparity2       
                
                jmp end_of_is_one2
                
                is_one2: 
		        inc bx
		        jmp is_not_one2   
		        
		        end_of_is_one2:
                
                add bx , 0000h
                JPO is_even2
                mov dx , offset word2_odd_message         ;print "odd"  
			    mov ah , 0009h
			    int 21h 
			    jmp retrn2 

               is_even2:
		        mov dx , offset word2_even_message           
			    mov ah , 0009h
			    int 21h 
			    

        retrn2:






;############################### EXPT3 #####################################					
		
		   ; finding the hammel distance    
		       
			mov dx , 0000h
		       
		         mov dx , offset hammel_msg       ;print "hammel distance is : "  
			    mov ah , 0009h
			    int 21h 
		
		
		mov si , offset word1
		mov di , offset word2
		mov ax , 0000h    
		mov cx , 000Ah   
		mov bx ,000h
		mov dx , 000h         ; clear registers
		
		find_hammel:
		            mov dl , [di]       ;load word2[i]
		            mov bl , [si]       ;load word1[i]
		            xor dl , bl         ; xor them
		            jnz add_one_hammel  ; if either is 1 but not both add one to count (Ax)
    ret_hammel:     inc si
		            inc di         
		            dec cx
		            jnz find_hammel   ; loop
		           
		   
		
		            mov dl,al         ; move to dl for printing
    		    	add dl,'0'        ; ascii
    			
    			    mov ah,02h        ; print
    		    	int 21h   
		
				
		
		
		exit:	                      ; yay!
        mov	ah, 4ch	    ; return to DOS. Normally
		 int     21h 
                                    
                                    
                                    
  ; ############## initially, i put ALL my else statements here, after the program eneded ie. I got an error message saying 
  ;                 jump is too far and hat to change everything. Lesson learnt!                                
                                    
                                    
                                    
	;	is_one: 
		;        inc bx
		 ;       jmp is_not_one        
		        
		;is_even:
		 ;           ; print "even"
		  ;      mov dx , offset even_message           
			  ;  mov ah , 0009h
			   ; int 21h 
			    ;jmp retrn
		
		;putone: 
		 ;       mov di , offset master
				;add di , ax 
				;add di , 0001h
			;	MOV [di], 0001h
				;mov AX[BX],01h
			;	JMP NEXTITER		 
				
				
				
		;is_one2: 
		 ;       inc bx
		  ;      jmp is_not_one2        
		        
		;is_even2:
		 ;           ; print "even"
		  ;      mov dx , offset even_message           
			  ;  mov ah , 0009h
			   ; int 21h 
			    ;jmp retrn2
		
		;putone2: 
		 ;       mov di , offset master
				;add di , ax 
				;add di , 0001h
				;MOV [di], 0001h
				;mov AX[BX],01h
				;JMP NEXTITER2	
				
		add_one_hammel:
		                add ax , 0001h
		                jmp ret_hammel	 
code ends		    ; code segment ends here
end start		    ; the whold program ends here
;===============================================



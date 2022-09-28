#Author:Zhong Ooi, Chanrady Ho, Catherine Johnskn, Sunjay Guttikonda 
#Date: 6/30/2021
#Description: Vigenere cipher for the project: has both decryption and encryption
              #ignores spaces, punctuation, number, and if characters are upper or lowercase.
.data
ask: .asciiz "\nType 0 to decrypt your string | Type 1 encrypt your string: "
key: .asciiz "enter the key for the string (First character must be alphabet)(Maximum 222 characters): \n" 
encryptmsg: .asciiz "enter your string you want to be encrypted(Maximum 222 characters). \n"
decryptmsg: .asciiz "enter your string you want to be decrypted(Maximum 222 characters). \n" 
encryptresultmsg: .asciiz "\nHere is your encrypted string.\n" 
decryptresultmsg: .asciiz "\nHere is your decrypted string.\n"
errormsg: .asciiz "\nUnknown input try again.\n"
loopcheck: .asciiz "\nEnter 0 to exit loop: " 

.text 
main: 

#address we can load the message into 
	li $v0,9 	#load dynamic memory allocation
	li $a0,224 	#give it 224 bytes to store data
	syscall 	
	
	move $s0,$v0	#static message address
	
#address to load the key into	
	li $v0,9	#load dynamic memory allocation
	li $a0,224	#give it 224 bytes to store the key 
	syscall 
	
	move $s2,$v0	#static key address
#address for while loop checking to be stored in 
	li $v0,9		#load dynamic memory allocation
	li $a0,10	#give it 10 bytes to store 
	syscall 	
	move $s4,$v0	#static loop checking address
	

while_input: 		#loop until user enters a valid input of 0 for decryption or 1 for encryption
#ask the user if they want to decrypt or encrypt 
	li $v0,4		#print the string ask
	la $a0,ask	#load address of ask to $a0
	syscall		

#take user input as a string 
	move $a0,$s4	#move address of loop checking storage
	li $a1,10	#allow 10 characters 
	li $v0,8	#syscall for string 
	syscall			
	lh $t9,0($s4)	#load half a word or two characters value to $t9
	
	beq $t9,2608,while_input_exit	#if $t9=0 exit loop
	beq $t9,2609,while_input_exit	#if $t9=1 exit loop 
	#error message
	li $v0,4	#print the string errormsg
	la $a0,errormsg	#load address of errormsg to $a0
	syscall
	
	j while_input	#j back to the while_input label
	
	while_input_exit:#a label to jump out of the while_input loop
#create registers for manipulation
	move $s3,$s2	#$s3 is key address that is allowed to be manipulated
	move $s1,$s0	#$s1 is string address that is allowed to be manipulated
	beq $t9,2608,decryptinput  #if user selected decryption (0) jump to decryptinput
				   #else user selected encryption (1) 
	#ask for encrypt string input
	li $v0,4		#print the string encryptmsg
	la $a0,encryptmsg	#load the address of encryptmsg to $a0
	syscall
	
	li $v0,8		#read the userinputed string 
	move $a0,$s0	#load the dynamic memory address we will store this data in
	li $a1,222	#give them 222 bytes to work with
	syscall
	j keyinput	#skip decryptinput and go to key input 

decryptinput:		#ask for decrypt string input
	li $v0,4		#load the dynamic memory we will store this data in
	la $a0,decryptmsg	#give user 222 character to work with allowing new line 
	syscall
	
	li $v0,8		#read the userinputed string
	move $a0,$s0	#load the dynamic memory address we will store this data in
	li $a1,222	#give user 222 bytes to work with
	syscall

keyinput:		#ask for key input
	li $v0,4	#print the string to ask for key
	la $a0,key	#load the address of key into $a0
	syscall
	
	li $v0,8	#read the userinputed key
	move $a0,$s2	#load the dynamic memory we will store this data in
	li $a1,222	#give user 222 bytes to work with?
	syscall
	
	li $t8,1		#set register $t8 to allow for skip return to know that keycheck is calling it 
	jal key_check		#while loops that will change the key to lowercase if user inputed the key as uppercase
	li $t8,0		#set register $t8 back to 0 so the code know we are not in keychecking mode  
	beq $t9,2608,while_decryption	#if user selected decryption (0) jump to decryptinput					

while_encryption: 		#else user selected encryption
 	lb $t1,($s1)		#load a character from the message string into $t1
 	
 	jal isPunctuation	#check if it is a alphabet character 
 	
 	j encrypt_char		#send the word into the encryption formula 
 	
 	encryption_return:	# a way for the procedure encrypt formulas to return 
 	addi $s3,$s3,1		#increase the non static key address register by 1 
 	lb $t2,($s3)		#load a character from the key string into $t2
 	beq $t2,36,encryption_return	#if we read a punctuation load the next character
 	blt $t2,33,reset_key	#reset key address when we get to the end of it
 	
 	encryption_skip_return:	#a way for isPunctuation to skip encryption formula and key address incrementation
 	sb $t1,0($s1) 		#store the new character into the array 
 	addi $s1,$s1,1		#increment the msg address by 1 
 	
 	blt $t1,31,exit		#exit when finish aka when new line or a null terminated bit is loaded to $t1

	j while_encryption	#jump to while_encryption so we can loop

while_decryption:		#portion of code dedicated for decryption
	lb $t1,($s1)		#load a character from the message string
 	
 	jal isPunctuation	#check if it is a alphabet character  	
 	j decrypt_char		#send the word into the decryption formula 

 	
 	decryption_return:	# a way for the procedure decrypt_char to return 
 	addi $s3,$s3,1		#increase the non static key address register by 1  
 	lb $t2,($s3)		#load a character from the key string into $t2
 	beq $t2,36,decryption_return #if we read a punctuation load the next character
 	blt $t2,33,reset_key	#reset key address when we get to the end of it
 	
 	decryption_skip_return:	#a way for isPunctuation to skip decryption formula and key address increase
 	sb $t1,0($s1) 		#store the new character into the array 
 	addi $s1,$s1,1		#increment the msg address by 1 
 	
 	blt $t1,31,exit		#exit when finish aka when new line or a null terminated bit is loaded to $t1

	j while_decryption	#jump to while_decryption so we can loop

exit: 				#exit
	beq $t9,2608, decryptoutput	#check if we did encryption or decryption
	#print out encryptionresultmsg 
	li $v0,4		#print the string encryptresultmsg
	la $a0,encryptresultmsg	#load the address of encryptresultmsg into $a0
	syscall
	j printresult		#jump to print result in order to skip decrypt output portion of code
	
	decryptoutput:		#print out decryptresultmsg
	li $v0,4		#print the string decryptresultmsg
	la $a0,decryptresultmsg	#load the address of decryptresultmsg into $a0
	syscall
	
	printresult:#print out the result
	#print out updated string 
      	move $a0,$s0	#move the static address of msg into $a0
      	li $v0,4	#print the result 
      	syscall
	
	#while loop fuction for whole code
	la $a0,loopcheck	#load address of loopcheck into $a0
      	li $v0,4		#print the string loopcheck
      	syscall
      	
	move $a0,$s4		#load the address of loop checking 
	li $a1,10
	li $v0,8		#read userinput to see if they want to continue
	syscall			
	lh $t9,0($s4)
	bne $t9,2608,while_input	#check user input | if not 0 loop back to main | else close
	
	li $v0,10		#close the program
 	syscall

key_check:			#function to check if all characters in the key are lowercase
	addi $sp,$sp,-4		#push stack storage
	sw $ra,($sp)		#load our return address into stack storage 
	lb $t1,($s3)		#load the character in the key 
	addi $s3,$s3,1		#increase the non-static key address by 1 
	
	jal isPunctuation	#check if our character is a punctuation character 
	
	key_return:		#a way for change punctuation to return so we dont change all the heap memory to $
	lw $ra,($sp)		#return original address
	addi $sp,$sp,4		#pop the stack
	
	bgt $t1,64,change_case	#if the character is a Uppercase jump to change case
	#else			# we only get here if we have a value under ascii value A
	lb $t2,($s2)		#load the first character from the key string for encryption or decryption
	move $s3,$s2		#reset the non-static address for key 
	jr $ra			#return back to the main program

change_case:			#called by key_check to change a uppercase to a lowercase
	bgt $t1,96,key_check	#make sure the number is indeed a uppercase by eliminating all lowercase ascii values
	addi $t1,$t1,32		#add 32 which will make the ascii code into lowercase
	sb $t1,-1($s3)		#store it into the heap memory (offset is -1 since we added one earlier)
	j key_check		#return to key_check 

change_punctuation:		#called by key_check to change punctuation
	blt $t1,30,key_return	#if we get a null bit or newline return back to key_check
	li $t1,36		#set all puctuation to $
	sb $t1,-1($s3)		#store it into the heap memory (offset is -1 since we added one earlier)
	j key_check		#return to key_check

isPunctuation:
	blt $t1,65, skip_return	#skip anything less than ascii A
	bgt $t1,122, skip_return#skip anything greater than ascii z
	beq $t1,91, skip_return	#skip the [ character
	beq $t1,92, skip_return	#skip the \ character
	beq $t1,93, skip_return	#skip the ] character
	beq $t1,94, skip_return	#skip the ^ character
	beq $t1,95, skip_return	#skip the - character
	beq $t1,96, skip_return	#skip the ` character
 	jr $ra 	 		#return back

skip_return:				#called by isPunctuation so we can return to the correct loop
	beq $t8,1,change_punctuation	#go to change_punctuation to change the punctuation to $
	beq $t9,2608,decryption_skip_return	#if user selected decryption enter decrypt loop at label encryption_skip_return
	j encryption_skip_return	#if user chose encrypt enter encrypt loop at label encryption_skip_return
	
encrypt_char:				#called by while_encryption to encrypt the character
	
	# if condition for uppercase or lowercase 
	slti $a0,$t1,96 		#check if the alpha is lowercase | if true set $a0 to 1
	beq $a0,1,uppercase_encrypt 	#if $a0 is 1 jump to the uppercase_encryption formula 
	#lowercase			else continue to lowercase formula
	add $t1,$t1,$t2			#add the ascii value of key and string 
	sub $t1,$t1,123			#subtract by 123 
	bgt $t1,96, encryption_return	#if $t1 greater than 96 return back to the while_encryption loop
	addi $t1,$t1,26			#else add 26 
	j encryption_return		#return back to the while_encryption loop

uppercase_encrypt:			#called by encrypt_char
	addi $t2,$t2,-32		#make the key uppercase  
	add $t1,$t1,$t2			#add the ascii value of key and string 
	sub $t1,$t1,91			#subtract by 91
	bgt $t1,64, encryption_return	#if greater than 64 return back to the while_encryption loop
	addi $t1,$t1,26			#else add 26 
	j encryption_return		#return back to the while_encryption loop 
	
decrypt_char:				#called by while_decryption to decrypt the character
	# if condition for uppercase or lowercase 
	slti $a0,$t1,96 		#check if the alpha is lowercase | if true set $a0 to 1
	beq $a0,1,uppercase_decrypt 	#if $a0 is 1 send to the uppercase_decrypt formula 
	#lowercase			else continue to lowercase formula
	sub $t1,$t1,$t2			#subtract the ascii value of key and string 
	add $t1,$t1,97			#add 97
	bgt $t1,96, decryption_return	#if greater than 96 return back to the while_decryption loop
	addi $t1,$t1,26			#else add 26 
	j decryption_return		#return back to the while_decryption loop

uppercase_decrypt:			#called by decrypt_char
	addi $t2,$t2,-32		#make the key uppercase  
	sub $t1,$t1,$t2			#add the ascii value of key and string 
	add $t1,$t1,65			#add by 65 
	bgt $t1,64, decryption_return	#if greater than 64 return back to the while loop
	addi $t1,$t1,26			#else add 26 
	j decryption_return		#return back to the while loop after finish uppercase

reset_key:				#called in order to reset key address
	move $s3,$s2			#copy the static key address value into the non static key address
	addi $s3,$s3,-1			#decrement by 1 because when we return we will increment by 1 
	beq $t9,2608,decryption_return	#if user chose decryption go back to decryption loop
	j encryption_return		#else user chose encryption go back to encryption loop

INCLUDE	Irvine32.inc
INCLUDE Macros.inc

.386
.model flat, stdcall

.stack 4096

ExitProcess PROTO, dwExitCode:DWORD

convertBin PROTO,
number: BYTE

bitTitle PROTO,
message: PTR BYTE

.data
ZERO REAL4 0.0				; For FCOMP use (compare with 0)
TENTHOUSANDS REAL4 10000.0	; For displaying floating number in 4.d.p (more details in floatCalc PROC)
userSelect BYTE ?			; Store user input selection (refer to inputSelection PROC)

COMMENT #
- A bunch of text declared for later use
- '9H' = \tab, '0AH' = \n, '0' = NULL-TERMINATOR
#
titleMsg BYTE "===========================================================", 0AH,
				9H, "WONG YAN ZHI'S CALCULATOR MODULE (RST1S3G1)", 0AH,
				"===========================================================", 0AH, 0
instructionMsg BYTE "**Note: There are a total of 8 calculation available**", 0AH,
					"-----------------------------------------------------------", 0AH,
					"Instructions:", 0AH,
					"1. Choose and Enter your number of choice (1 to 9).", 0AH,
					"2. Enter the value of First Term.", 0AH,
					"3. Enter the value of Second Term.", 0AH,
					"4. The result of calculation will be shown on the console.", 0AH, 0
endTitleMsg BYTE "===========================================================", 0AH, 0AH, 0
selectionListMsg BYTE "1. Addition", 9H, 9H, "(DEC)", 0AH,
					  "2. Subtraction", 9H, 9H, "(DEC)", 0AH,
					  "3. Multiplication", 9H, "(DEC)", 0AH,
					  "4. Division", 9H, 9H, "(DEC)", 0AH,
					  "5. Logical AND", 9H, 9H, "(BIN)", 0AH,
					  "6. Logical OR", 9H, 9H, "(BIN)", 0AH,
					  "7. Logical XOR", 9H, 9H, "(BIN)", 0AH,
					  "8. Logical NOT", 9H, 9H, "(BIN)", 0AH, 
					  "9. Exit", 0AH, 0
invalidInputSelection BYTE "Invalid input. Please enter only POSITIVE INTEGER between 1 to 9!!", 0AH, 0AH, 0
invalidFloatInput BYTE "Invalid input. Please enter only FLOATING NUMBER (ZERO is also not allowed)!!", 0AH, 0AH, 0
invalidNumInput BYTE "Invalid input. Please enter only POSITIVE INTEGER between 0 to 255!!", 0AH, 0AH, 0
invalidCharInput BYTE "Invalid input. Please enter only 'Y' or 'N'!!", 0AH, 0AH, 0

.code
main PROC
	CALL mainMenu			; CALL 'mainMenu' Procedure
	CALL inputSelection		; CALL 'inputSelection' Procedure
	CALL selectOperation	; CALL 'selectOperation' Procedure
	INVOKE ExitProcess, 0	; End and Exit the program
main ENDP

bigTitle PROC,
	message: PTR BYTE
	MOV EDX, OFFSET titleMsg		; Print Title
	CALL WriteString
	MOV EDX, message				; Print received parameter
	CALL WriteString
	MOV EDX, OFFSET endTitleMsg		; Print End Title - (=) Line
	CALL WriteString
	RET
bigTitle ENDP

mainMenu PROC
	INVOKE bigTitle, OFFSET instructionMsg
	CALL WaitMsg	; Halt the program until user press any key
	CALL Clrscr		; Clear the console screen
	RET				; Return to the Procedure where it is called
mainMenu ENDP

inputSelection PROC
	readInteger:
		INVOKE bigTitle, OFFSET selectionListMsg
		mWrite "Please enter your number of choice (1 to 9): "
		CALL ReadInt	; Read an integer number from user
		JNO validType	; Jump to 'validType' label if not overflow (input is valid numeric)

	invalidInteger:
		CALL Clrscr		; Clear the console screen
		MOV EDX, OFFSET invalidInputSelection	; Print Invalid Input Selection Message
		CALL WriteString
		JMP readInteger	; Jump back to 'readInteger' label (loop) to get new input

	validType:
		CMP AL, 1			; Compare the value entered by the user (stored in AL) with 1
		JL invalidInteger	; Jump to 'invalidInteger' label if the value is smaller than 1
		CMP AL, 9			; Compare the value entered by the user (stored in AL) with 9
		JG invalidInteger	; Jump to 'invalidInteger' label if the value is larger than 9
		MOV userSelect, AL	; Store the value inside AL into 'userSelect' if all condition are passed
	CALL Crlf	; Print a new line '\n
	RET			; Return to the Procedure where it is called
inputSelection ENDP

selectOperation PROC
	CMP userSelect, 9	; Compare the value of 'userSelect' with 9
	JE endFunction		; Jump to 'endFunction' label if the value == 9
	CMP userSelect, 4	; Compare the value of 'userSelect' with 4
	JLE	floatOperation	; Jump to 'floatOperation' label if the value <= 4
	CMP userSelect, 5	; Compare the value of 'userSelect' with 5
	JGE binaryOperation	; Jump to 'binaryOperation' label if the value >= 5

	floatOperation:
		CALL floatCalc	; CALL 'floatCalc' Procedure
		RET				; Return to the Procedure where it is called
	binaryOperation:
		CALL binaryCalc	; CALL 'binaryCalc' Procedure
		RET				; Return to the Procedure where it is called
	endFunction:
		mWrite "You have chose to EXIT the program."
		CALL Crlf	; Print a new line '\n'
		RET			; Return to the Procedure where it is called
selectOperation ENDP

compareZero PROC
	FCOM ZERO		; Compare the value entered by the user [stored in FPU stack - ST(0)] with 0.0
	FNSTSW AX		; Store the FPU Status into AX Register
	SAHF			; Store AH into Flags
	RET
compareZero ENDP

inputFloat PROC
	CALL ReadFloat	; Read a floating number from user
	CALL compareZero	
	RET
inputFloat ENDP

floatCalc PROC
	LOCAL floatResult: DWORD	; Declare local variable

	readFloatNum:
		MOV EDX, OFFSET titleMsg	; Print Title
		CALL WriteString
		mWrite "Please enter the 1st Term (Floating Number): "
		CALL inputFloat	
		JE invalidFloat	; Jump to 'invalidFloat' label if the value is equal to 0.0	
		mWrite "Please enter the 2nd Term (Floating Number): "
		CALL inputFloat
		JE invalidFloat	; Jump to 'invalidFloat' label if the value is equal to 0.0
		CALL Crlf	; Print a new line '\n'

	floatFunc:
		CMP userSelect, 1	; Compare the value of 'userSelect' with 1
		JE SUM				; Jump to 'SUM' label if the value is equal to 1
		CMP userSelect, 2	; Compare the value of 'userSelect' with 2
		JE MINUS			; Jump to 'MINUS' label if the value is equal to 2
		CMP userSelect, 3	; Compare the value of 'userSelect' with 3
		JE MULTIPLY			; Jump to 'MULTIPLY' label if the value is equal to 3
		CMP userSelect, 4	; Compare the value of 'userSelect' with 4
		JE DIVIDE			; Jump to 'DIVIDE' label if the value is equal to 4
	invalidFloat:
		FSTP ST(0)			; @@@@
		CALL Clrscr			; Clear the console screen
		MOV EDX, OFFSET invalidFloatInput	; Print Invalid Float Input Message
		CALL WriteString
		JMP readFloatNum	; Jump back to 'readFloatNum' label (loop) to get new input
	SUM:
		FADDP		; Add
		mWrite "Result of 'ADDITION' Calculation (4.d.p): "
		JMP checkSign	; Jump to 'checkSign' label
	MINUS:
		FSUBP		; Subtract
		mWrite "Result of 'SUBTRACTION' Calculation (4.d.p): "
		JMP checkSign	; Jump to 'checkSign' label
	MULTIPLY:
		FMULP		; Multiply
		mWrite "Result of 'MULTIPLICATION' Calculation (4.d.p): "
		JMP checkSign	; Jump to 'checkSign' label
	DIVIDE:
		FDIVP		; Divide
		mWrite "Result of 'DIVISION' Calculation (4.d.p): "
	checkSign:
		CALL compareZero
		JA printFloatResult	; Jump to 'printFloatResult' label if the value is larger than 0.0
		mWrite "-"			; Print '-' if the value is found negative

	COMMENT #
	- The purpose of printFloatResult is to print the result output in more understandable way
	- It is easier for people to look at the number with 4 decimal places
	- For example, it is easier to understand by just looking at '0.2476' rather than '+2.4760000E-001'
	#
	printFloatResult:
		partOne:
			FMUL TENTHOUSANDS		; Multiply TENTHOUSANDS
			FISTP floatResult		; Store the integer into 'floatResult'
			XOR EDX, EDX			; CLEAN the EDX register (make sure it is 0)
			MOV EAX, floatResult	; COPIES the value of 'floatResult' into EAX register
			CDQ						; Extends the sign bit of EAX register into EDX register
			MOV EBX, 10000			; COPIES 10000 into EBX register (Divisor store in EBX)
			IDIV EBX				; Signed Integer Division (Quotient store in EAX, Remainder store in EDX)
			CMP EAX, 0				; Compare the value stored in EAX register with 0
			JG partTwo				; Jump to 'partTwo' label if the value is larger than 0
			NEG EAX					; Multiply the value stored in EAX register with -1 if the value is found negative
		partTwo:
			CALL WriteDec	; Print the value in EAX register as unsigned integer
			MOV EAX, EDX	; COPIES the value of EDX register into EAX register
			CMP EAX, 0		; Compare the value stored in EAX register with 0
			JG checkZero	; Jump to 'checkZero' label if the value is larger than 0
			NEG EAX			; Multiply the value stored in EAX register with -1 if the value is found negative		
		checkZero:
			CMP EAX, 10		; Compare the value stored in EAX register with 10
			JL threeZero	; Jump to 'threeZero' label if the value is less than 10
			CMP EAX, 100	; Compare the value stored in EAX register with 100
			JL twoZero		; Jump to 'twoZero' label if the value is less than 100
			CMP EAX, 1000	; Compare the value stored in EAX register with 1000
			JL oneZero		; Jump to 'oneZero' label if the value is less than 1000
			mWrite "."		; Print '.' ONLY (without 0), if none of the condition is met
			JMP askContinue	; Jump to 'askContinue' label
		oneZero:
			mWrite ".0"		; Print '.' with one 0
			JMP askContinue ; Jump to 'askContinue' label
		twoZero:
			mWrite ".00"	; Print '.' with two 0
			JMP askContinue	; Jump to 'askContinue' label
		threeZero:
			mWrite ".000"	; Print '.' with three 0			
		askContinue:
			CALL WriteDec	; Print the value in EAX register as unsigned integer
			CALL Crlf		; Print a new line '\n'
			MOV EDX, OFFSET endTitleMsg	; Print End Title - (=) Line
			CALL WriteString
			CALL continueProgram	; CALL 'continueProgram' Procedure
	RET		; Return to the Procedure where it is called
floatCalc ENDP

inputDec PROC
	readNum:
		CALL ReadInt		; Read an integer number from user
		JO invalidNum		; Jump to 'invalidNum' label if overflow (input is invalid numeric)
		CMP EAX, 0			; Compare the value stored in EAX register with 0
		JL invalidNum		; Jump to 'invalidNum' label if the value is less than 0
		CMP EAX, 255		; Compare the value stored in EAX register with 255
		JG invalidNum		; Jump to 'invalidNum' label if the value is more than 255
		RET
	invalidNum:
		CALL Clrscr		; Clear the console screen
		MOV EDX, OFFSET invalidNumInput	; Print Invalid Number Input Message
		CALL WriteString
		JMP readNum		; Jump back to 'readNum' label (loop) to get new input
inputDec ENDP

convertBin PROC,
	number: BYTE		; Declare local variable
	mWrite "Number "
	MOV AL, number		; COPIES the value of 'binaryTwo' into AL register
	CALL WriteDec		; Print the value in EAX register as unsigned integer 
	mWrite " converted into BINARY: "
	MOV EBX, TYPE BYTE	; COPIES the size of BYTE (data structure) into EBX register
	CALL WriteBinB		; Print the value in EAX register as BINARY Number [0 & 1]
	CALL Crlf			; Print a new line '\n'
	RET
convertBin ENDP

resultPrint PROC
	MOV EBX, TYPE BYTE	; COPIES the size of BYTE (data structure) into EBX register
	CALL WriteBinB		; Print the value in EAX register as BINARY Number [0 & 1]
	CALL Crlf			; Print a new line '\n'
	RET
resultPrint ENDP

binaryCalc PROC
	LOCAL binaryOne: BYTE, binaryTwo: BYTE	; Declare local variables

	MOV EDX, OFFSET titleMsg	; Print Title
	CALL WriteString
	mWrite "Please enter the 1st Term (Positive Integer): "
	CALL inputDec
	MOV binaryOne, AL	; COPIES the value of AL register into 'binaryOne'
	mWrite "Please enter the 2nd Term (Positive Integer): "
	CALL inputDec
	MOV binaryTwo, AL	; COPIES the value of AL register into 'binaryTwo'
	CALL Crlf		; Print a new line '\n'
	BinaryFunc:
		INVOKE convertBin, binaryOne
		INVOKE convertBin, binaryTwo
		CALL Crlf			; Print a new line '\n'
		CMP userSelect, 5	; Compare the value of 'userSelect' with 5
		JE BinAND			; Jump to 'BinAND' label if the value is equal to 5
		CMP userSelect, 6	; Compare the value of 'userSelect' with 6
		JE BinOR			; Jump to 'BinOR' label if the value is equal to 6
		CMP userSelect, 7	; Compare the value of 'userSelect' with 7
		JE BinXOR			; Jump to 'BinXOR' label if the value is equal to 7
		CMP userSelect, 8	; Compare the value of 'userSelect' with 8
		JE BinNOT			; Jump to 'BinNOT' label if the value is equal to 8	
	BinAND:
		MOV AL, binaryOne	; COPIES the value of 'binaryOne' into AL register
		AND AL, binaryTwo	; Compute: binaryOne&binaryTwo, value stored in AL register
		mWrite "Result of Logical 'AND' Calculation: "
		JMP printBinResult	; Jump to 'printBinResult' label
	BinOR:
		MOV AL, binaryOne	; COPIES the value of 'term11' into AL register
		OR AL, binaryTwo	; Compute: binaryOne|binaryTwo, value stored in AL register
		mWrite "Result of Logical 'OR' Calculation: "
		JMP printBinResult	; Jump to 'printBinResult' label	
	BinXOR:
		MOV AL, binaryOne	; COPIES the value of 'binaryOne' into AL register
		XOR AL, binaryTwo	; Compute: binaryOne^binaryTwo, value stored in AL register
		mWrite "Result of Logical 'XOR' Calculation: "
		JMP printBinResult	; Jump to 'printBinResult' label	
	BinNOT:
		MOV AL, binaryOne	; COPIES the value of 'binaryOne' into AL register
		NOT AL			; Compute: ~binaryOne, value stored in AL register
		mWrite "Result of Logical 'NOT' CALCULATION - 1st Term: "
		CALL resultPrint
		MOV AL, binaryTwo	; COPIES the value of 'binaryTwo' into AL register
		NOT AL			; Compute: ~binaryTwo, value stored in AL register
		mWrite "Result of Logical 'NOT' CALCULATION - 2nd Term: "	
	printBinResult:
		CALL resultPrint
		MOV EDX, OFFSET endTitleMsg	; Print End Title - (=) Line
		CALL WriteString
		CALL continueProgram	; CALL 'continueProgram' Procedure
	RET		; Return to the Procedure where it is called
binaryCalc ENDP

continueProgram PROC
	readCharacter:
		mWrite "Do you want to continue?"
		CALL Crlf		; Print a new line '\n'
		mWrite "(Y = Continue Module / N = Return to Main Menu): "
		CALL ReadChar	; Read a character from user
		CALL WriteChar	; Print the value in AL register [ASCII Value]
		CALL Crlf		; Print a new line '\n'
		CMP AL, 'Y'	; Compare the value stored in AL register with ASCII Value 'Y'
		JE YES		; Jump to 'YES' label if the value is equal to ASCII Value 'Y'
		CMP AL, 'y'	; Compare the value stored in AL register with ASCII Value 'y'
		JE YES		; Jump to 'YES' label if the value is equal to ASCII Value 'y'
		CMP AL, 'N'	; Compare the value stored in AL register with ASCII Value 'N'
		JE NO		; Jump to 'YES' label if the value is equal to ASCII Value 'N'
		CMP AL, 'n'	; Compare the value stored in AL register with ASCII Value 'n'
		JE NO		; Jump to 'YES' label if the value is equal to ASCII Value 'n'
		MOV EDX, OFFSET invalidCharInput	; Print Invalid Character Input Message
		CALL WriteString
		JMP readCharacter	; Jump back to 'readCharacter' label (loop) to get new input
	YES:
		CALL Clrscr				; Clear the console screen
		CALL selectOperation	; CALL 'selectOperation' Procedure
		RET		; Return to the Procedure where it is called
	NO:
		CALL Clrscr		; Clear the console screen
		CALL main		; CALL 'main' Procedure
		RET		; Return to the Procedure where it is called	
continueProgram ENDP

END main		;specify the program's entry point
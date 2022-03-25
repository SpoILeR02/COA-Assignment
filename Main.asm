INCLUDE	Irvine32.inc
INCLUDE Macros.inc

.386
.model flat, stdcall

.stack 4096

ExitProcess PROTO, dwExitCode:DWORD

COMMENT #
- Declare PROTOTYPES for Calculation PROCEDURES
- All of them have two parameters
- Addition, Subtraction, Multiplication & Division = receives REAL4 type
- LogicalAND, LogicalOR, LogicalXOR & LogicalNOT = receives BYTE type
#
Addition PROTO,
	term1:REAL4,
	term2:REAL4

Subtraction PROTO,
	term3:REAL4,
	term4:REAL4

Multiplication PROTO,
	term5:REAL4,
	term6:REAL4

Division PROTO,
	term7:REAL4,
	term8:REAL4

LogicalAND PROTO,
	term9:BYTE,
	term10:BYTE

LogicalOR PROTO,
	term11:BYTE,
	term12:BYTE

LogicalXOR PROTO,
	term13:BYTE,
	term14:BYTE

LogicalNOT PROTO,
	term15:BYTE,
	term16:BYTE

.data
ZERO REAL4 0.0				; For FCOMP use (compare with 0)
TENTHOUSANDS REAL4 10000.0	; For displaying floating number in 3.d.p (more details in floatCalc PROC)
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
invalidFloatInput BYTE "Invalid input. Please enter only FLOATING NUMBER (ZERO is not allowed)!!", 0AH, 0AH, 0
invalidNumInput BYTE "Invalid input. Please enter only POSITIVE INTEGER between 0 to 255!!", 0AH, 0AH, 0
invalidCharInput BYTE "Invalid input. Please enter only 'Y' or 'N'!!", 0AH, 0AH, 0

.code
main PROC
	CALL mainMenu			; CALL 'mainMenu' Procedure
	CALL inputSelection		; CALL 'inputSelection' Procedure
	CALL selectOperation	; CALL 'selectOperation' Procedure

	INVOKE ExitProcess, 0	; End and Exit the program
main ENDP

mainMenu PROC
	MOV EDX, OFFSET titleMsg		; Print Title
	CALL WriteString
	MOV EDX, OFFSET instructionMsg	; Print Instruction
	CALL WriteString
	MOV EDX, OFFSET endTitleMsg		; Print End Title - (=) Line
	CALL WriteString

	CALL WaitMsg	; Halt the program until user press any key
	CALL Clrscr		; Clear the console screen

	RET		; Return to the Procedure where it is called
mainMenu ENDP

inputSelection PROC
	readInteger:
		MOV EDX, OFFSET titleMsg			; Print Title
		CALL WriteString
		MOV EDX, OFFSET selectionListMsg	; Print Instruction
		CALL WriteString
		MOV EDX, OFFSET endTitleMsg			; Print End Title - (=) Line
		CALL WriteString

		mWrite "Please enter your number of choice (1 to 9): "
		CALL ReadInt	; Read an integer number from user (using Irvine32 library)
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

	CALL Crlf	; Print a new line '\n' (using Irvine32 library)
	RET			; Return to the Procedure where it is called
inputSelection ENDP

selectOperation PROC
	CMP userSelect, 9	; Compare the value of 'userSelect' with 9
	JE endFunction		; Jump to 'endFunction' label if the value is equal to 9
	CMP userSelect, 4	; Compare the value of 'userSelect' with 4
	JLE	floatOperation	; Jump to 'floatOperation' label if the value is less than or equal to 4
	CMP userSelect, 5	; Compare the value of 'userSelect' with 5
	JGE binaryOperation	; Jump to 'binaryOperation' label if the value is more than or equal to 5

	floatOperation:
		CALL floatCalc	; CALL 'floatCalc' Procedure
		RET				; Return to the Procedure where it is called

	binaryOperation:
		CALL binaryCalc	; CALL 'binaryCalc' Procedure
		RET				; Return to the Procedure where it is called

	endFunction:
		mWrite "You have chose to EXIT the program."
		CALL Crlf	; Print a new line '\n' (using Irvine32 library)
		RET			; Return to the Procedure where it is called
selectOperation ENDP

floatCalc PROC
	COMMENT #
	- Declare local variables using 'LOCAL' keyword
	- The local variables, floatOne & floatTwo are declared as REAL4 type
	- The local variable, floatResult is declared as DWORD type
	#
	LOCAL floatOne: REAL4, floatTwo: REAL4, floatResult: DWORD

	readFloatNum:
		MOV EDX, OFFSET titleMsg	; Print Title
		CALL WriteString
		mWrite "Please enter the 1st Term (Floating Number): "
		CALL ReadFloat	; Read a floating number from user (using Irvine32 library)
		FCOM ZERO		; Compare the value entered by the user [stored in FPU stack - ST(0)] with 0.0
		FNSTSW AX		; Store the FPU Status into AX Register
		SAHF			; Store AH into Flags
		JE invalidFloat	; Jump to 'invalidFloat' label if the value is equal to 0.0
		FSTP floatOne	; Store the floating number [ST(0)] into 'floatOne' and remove (pop) it out from FPU Stack
			
		mWrite "Please enter the 2nd Term (Floating Number): "
		CALL ReadFloat	; Read a floating number from user (using Irvine32 library)
		FCOM ZERO		; Compare the value entered by the user [stored in FPU stack - ST(0)] with 0.0
		FNSTSW AX		; Store the FPU Status into AX Register
		SAHF			; Store AH into Flags
		JE invalidFloat	; Jump to 'invalidFloat' label if the value is equal to 0.0
		FSTP floatTwo	; Store the floating number [ST(0)] into 'floatOne' and remove (pop) it out from FPU Stack

		CALL Crlf	; Print a new line '\n' (using Irvine32 library)

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
		CALL Clrscr			; Clear the console screen
		MOV EDX, OFFSET invalidFloatInput	; Print Invalid Float Input Message
		CALL WriteString
		JMP readFloatNum	; Jump back to 'readFloatNum' label (loop) to get new input

	SUM:
		; Pass 'floatOne' & 'floatTwo' as parameters into 'Addition' Procedure
		INVOKE Addition, floatOne, floatTwo
		mWrite "Result of 'ADDITION' Calculation (3.d.p): "
		JMP checkSign	; Jump to 'checkSign' label

	MINUS:
		; Pass 'floatOne' & 'floatTwo' as parameters into 'Subtraction' Procedure
		INVOKE Subtraction, floatOne, floatTwo
		mWrite "Result of 'SUBTRACTION' Calculation (3.d.p): "
		JMP checkSign	; Jump to 'checkSign' label

	MULTIPLY:
		; Pass 'floatOne' & 'floatTwo' as parameters into 'Multiplication' Procedure
		INVOKE Multiplication, floatOne, floatTwo
		mWrite "Result of 'MULTIPLICATION' Calculation (3.d.p): "
		JMP checkSign	; Jump to 'checkSign' label

	DIVIDE:
		; Pass 'floatOne' & 'floatTwo' as parameters into 'Division' Procedure
		INVOKE Division, floatOne, floatTwo
		mWrite "Result of 'DIVISION' Calculation (3.d.p): "

	checkSign:
		FCOM ZERO			; Compare the value (result) calculated [stored in FPU stack - ST(0)] with 0.0
		FNSTSW AX			; Store the FPU Status into AX Register
		SAHF				; Store AH into Flags
		JA printFloatResult	; Jump to 'printFloatResult' label if the value is larger than 0.0
		mWrite "-"			; Print '-' if the value is found negative

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
			CALL WriteDec	; Print the value in EAX register as unsigned integer (using Irvine32 library)
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
			CALL WriteDec	; Print the value in EAX register as unsigned integer (using Irvine32 library)
			CALL Crlf		; Print a new line '\n' (using Irvine32 library)
			JMP askContinue	; Jump to 'askContinue' label

		oneZero:
			mWrite ".0"		; Print '.' with one 0
			CALL WriteDec	; Print the value in EAX register as unsigned integer (using Irvine32 library)
			CALL Crlf		; Print a new line '\n' (using Irvine32 library)
			JMP askContinue ; Jump to 'askContinue' label

		twoZero:
			mWrite ".00"	; Print '.' with two 0
			CALL WriteDec	; Print the value in EAX register as unsigned integer (using Irvine32 library)
			CALL Crlf		; Print a new line '\n' (using Irvine32 library)
			JMP askContinue	; Jump to 'askContinue' label

		threeZero:
			mWrite ".000"	; Print '.' with three 0
			CALL WriteDec	; Print the value in EAX register as unsigned integer (using Irvine32 library)
			CALL Crlf		; Print a new line '\n' (using Irvine32 library)
			
		askContinue:
			MOV EDX, OFFSET endTitleMsg	; Print End Title - (=) Line
			CALL WriteString

			CALL continueProgram		; CALL 'continueProgram' Procedure

	RET		; Return to the Procedure where it is called
floatCalc ENDP

binaryCalc PROC
	COMMENT #
	- Declare local variables using 'LOCAL' keyword
	- The local variables, binaryOne & binaryTwo are declared as BYTE type
	#
	LOCAL binaryOne: BYTE, binaryTwo: BYTE

	readNum:
		MOV EDX, OFFSET titleMsg	; Print Title
		CALL WriteString
		mWrite "Please enter the 1st Term (Positive Integer): "
		CALL ReadInt		; Read an integer number from user (using Irvine32 library)
		JO invalidNum		; Jump to 'invalidNum' label if overflow (input is invalid numeric)
		CMP EAX, 0			; Compare the value stored in EAX register with 0
		JL invalidNum		; Jump to 'invalidNum' label if the value is less than 0
		CMP EAX, 255		; Compare the value stored in EAX register with 255
		JG invalidNum		; Jump to 'invalidNum' label if the value is more than 255
		MOV binaryOne, AL	; COPIES the value of AL register into 'binaryOne'

		mWrite "Please enter the 2nd Term (Positive Integer): "
		CALL ReadInt		; Read an integer number from user (using Irvine32 library)
		JO invalidNum		; Jump to 'invalidNum' label if overflow (input is invalid numeric)
		CMP EAX, 0			; Compare the value stored in EAX register with 0
		JL invalidNum		; Jump to 'invalidNum' label if the value is less than 0
		CMP EAX, 255		; Compare the value stored in EAX register with 255
		JG invalidNum		; Jump to 'invalidNum' label if the value is more than 255
		MOV binaryTwo, AL	; COPIES the value of AL register into 'binaryTwo'

		CALL Crlf		; Print a new line '\n' (using Irvine32 library)

	BinaryFunc:
		mWrite "Number "
		MOV AL, binaryOne	; COPIES the value of 'binaryOne' into AL register
		CALL WriteDec		; Print the value in EAX register as unsigned integer (using Irvine32 library)
		mWrite " converted into BINARY: "
		MOV EBX, TYPE BYTE	; COPIES the size of BYTE (data structure) into EBX register
		CALL WriteBinB		; Print the value in EAX register as BINARY Number [0 & 1] (using Irvine32 library)
		CALL Crlf			; Print a new line '\n' (using Irvine32 library)

		mWrite "Number "
		MOV AL, binaryTwo	; COPIES the value of 'binaryTwo' into AL register
		CALL WriteDec		; Print the value in EAX register as unsigned integer (using Irvine32 library)
		mWrite " converted into BINARY: "
		MOV EBX, TYPE BYTE	; COPIES the size of BYTE (data structure) into EBX register
		CALL WriteBinB		; Print the value in EAX register as BINARY Number [0 & 1] (using Irvine32 library)
		CALL Crlf			; Print a new line '\n' (using Irvine32 library)

		CALL Crlf			; Print a new line '\n' (using Irvine32 library)
		CMP userSelect, 5	; Compare the value of 'userSelect' with 5
		JE BinAND			; Jump to 'BinAND' label if the value is equal to 5
		CMP userSelect, 6	; Compare the value of 'userSelect' with 6
		JE BinOR			; Jump to 'BinOR' label if the value is equal to 6
		CMP userSelect, 7	; Compare the value of 'userSelect' with 7
		JE BinXOR			; Jump to 'BinXOR' label if the value is equal to 7
		CMP userSelect, 8	; Compare the value of 'userSelect' with 8
		JE BinNOT			; Jump to 'BinNOT' label if the value is equal to 8

	invalidNum:
		CALL Clrscr		; Clear the console screen
		MOV EDX, OFFSET invalidNumInput	; Print Invalid Number Input Message
		CALL WriteString
		JMP readNum		; Jump back to 'readNum' label (loop) to get new input

	BinAND:
		; Pass 'binaryOne' & 'binaryTwo' as parameters into 'LogicalAND' Procedure
		INVOKE LogicalAND, binaryOne, binaryTwo
		mWrite "Result of Logical 'AND' Calculation: "
		JMP printBinResult	; Jump to 'printBinResult' label

	BinOR:
		; Pass 'binaryOne' & 'binaryTwo' as parameters into 'LogicalOR' Procedure
		INVOKE LogicalOR, binaryOne, binaryTwo
		mWrite "Result of Logical 'OR' Calculation: "
		JMP printBinResult	; Jump to 'printBinResult' label
		
	BinXOR:
		; Pass 'binaryOne' & 'binaryTwo' as parameters into 'LogicalXOR' Procedure
		INVOKE LogicalXOR, binaryOne, binaryTwo
		mWrite "Result of Logical 'XOR' Calculation: "
		JMP printBinResult	; Jump to 'printBinResult' label
			
	BinNOT:
		; Pass 'binaryOne' & 'binaryTwo' as parameters into 'LogicalNOT' Procedure
		INVOKE LogicalNOT, binaryOne, binaryTwo
		mWrite "Result of Logical 'NOT' CALCULATION - 2nd Term: "

	printBinResult:
		MOV EBX, TYPE BYTE		; COPIES the size of BYTE (data structure) into EBX register
		CALL WriteBinB			; Print the value in EAX register as BINARY Number [0 & 1] (using Irvine32 library)
		CALL Crlf				; Print a new line '\n' (using Irvine32 library)
		
		MOV EDX, OFFSET endTitleMsg	; Print End Title - (=) Line
		CALL WriteString		
		CALL continueProgram		; CALL 'continueProgram' Procedure

	RET					; Return to the Procedure where it is called
binaryCalc ENDP

continueProgram PROC
	readCharacter:
		mWrite "Do you want to continue?"
		CALL Crlf		; Print a new line '\n' (using Irvine32 library)
		mWrite "(Y = Continue Module / N = Return to Main Menu): "
		CALL ReadChar	; Read a character from user (using Irvine32 library)
		CALL WriteChar	; Print the value in AL register [ASCII Value] (using Irvine32 library)
		CALL Crlf		; Print a new line '\n' (using Irvine32 library)

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

Addition PROC,
	term1:REAL4,
	term2:REAL4

	FLD term1	; Load the floating number stored in 'term1' into FPU Stack
	FLD term2	; Load the floating number stored in 'term2' into FPU Stack
	FADDP		; Add 'term1' and 'term2' and remove (pop) it out from FPU Stack

	RET		; Return to the Procedure where it is called
Addition ENDP

Subtraction PROC,
	term3:REAL4,
	term4:REAL4

	FLD term3	; Load the floating number stored in 'term3' into FPU Stack
	FLD term4	; Load the floating number stored in 'term4' into FPU Stack
	FSUBP		; Subtract 'term3' and 'term4' and remove (pop) it out from FPU Stack

	RET		; Return to the Procedure where it is called
Subtraction ENDP

Multiplication PROC,
	term5:REAL4,
	term6:REAL4

	FLD term5	; Load the floating number stored in 'term5' into FPU Stack
	FLD term6	; Load the floating number stored in 'term6' into FPU Stack
	FMULP		; Multiply 'term5' and 'term6' and remove (pop) it out from FPU Stack

	RET		; Return to the Procedure where it is called
Multiplication ENDP

Division PROC,
	term7:REAL4,
	term8:REAL4

	FLD term7	; Load the floating number stored in 'term7' into FPU Stack
	fld term8	; Load the floating number stored in 'term8' into FPU Stack
	FDIVP		; Divide 'term7' and 'term8' and remove (pop) it out from FPU Stack

	RET		; Return to the Procedure where it is called
Division ENDP

LogicalAND PROC,
	term9:BYTE,
	term10:BYTE

	MOV AL, term9	; COPIES the value of 'term9' into AL register
	AND AL, term10	

	RET		; Return to the Procedure where it is called
LogicalAND ENDP

LogicalOR PROC,
	term11:BYTE,
	term12:BYTE

	MOV AL, term11	; COPIES the value of 'term11' into AL register
	OR AL, term12

	RET		; Return to the Procedure where it is called
LogicalOR ENDP

LogicalXOR PROC,
	term13:BYTE,
	term14:BYTE

	MOV AL, term13	; COPIES the value of 'term13' into AL register
	XOR AL, term14

	RET		; Return to the Procedure where it is called
LogicalXOR ENDP

LogicalNOT PROC,
	term15:BYTE,
	term16:BYTE

	MOV AL, term15	; COPIES the value of 'term15' into AL register
	NOT AL
	mWrite "Result of Logical 'NOT' CALCULATION - 1st Term: "
	MOV EBX, TYPE BYTE	; COPIES the size of BYTE (data structure) into EBX register
	CALL WriteBinB		; Print the value in EAX register as BINARY Number [0 & 1] (using Irvine32 library)
	CALL Crlf			; Print a new line '\n' (using Irvine32 library)

	MOV AL, term16	; COPIES the value of 'term16' into AL register
	NOT AL

	RET		; Return to the Procedure where it is called
LogicalNOT ENDP

END main		;specify the program's entry point
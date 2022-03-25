INCLUDE	Irvine32.inc
INCLUDE Macros.inc

.386
.model flat, stdcall

.stack 4096

ExitProcess PROTO, dwExitCode:DWORD

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
ZERO REAL4 0.0
TENTHOUSANDS REAL4 10000.0
userSelect BYTE ?
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
invalidFloatInput BYTE "Invalid input. Please enter only FLOATING NUMBER bigger than 0!!", 0AH, 0AH, 0
invalidFloatNum BYTE "Invalid input. The SECOND TERM must be LARGER than the FIRST TERM!!", 0AH, 0AH, 0
invalidNumInput BYTE "Invalid input. Please enter only POSITIVE INTEGER!!", 0AH, 0AH, 0
invalidCharInput BYTE "Invalid input. Please enter only 'Y' or 'N'!!", 0AH, 0AH, 0

.code
main PROC
	CALL mainMenu
	CALL inputSelection
	CALL selectOperation

	INVOKE ExitProcess, 0
main ENDP

mainMenu PROC
	MOV EDX, OFFSET titleMsg		; Print Title
	CALL WriteString
	MOV EDX, OFFSET instructionMsg	; Print Instruction
	CALL WriteString
	MOV EDX, OFFSET endTitleMsg		; Print End Title
	CALL WriteString

	CALL WaitMsg
	CALL Clrscr

	RET								; Return to MAIN Procedure
mainMenu ENDP

inputSelection PROC
	readInteger:
		MOV EDX, OFFSET titleMsg
		CALL WriteString
		MOV EDX, OFFSET selectionListMsg
		CALL WriteString
		MOV EDX, OFFSET endTitleMsg
		CALL WriteString

		mWrite "Please enter your number of choice (1 to 9): "
		CALL ReadInt
		JNO validType

	invalidInteger:
		CALL Clrscr
		MOV EDX, OFFSET invalidInputSelection
		CALL WriteString
		JMP readInteger

	validType:
		CMP AL, 1
		JL invalidInteger
		CMP AL, 9
		JG invalidInteger
		MOV userSelect, AL

	CALL Crlf
	RET
inputSelection ENDP

selectOperation PROC
	CMP userSelect, 9
	JE endFunction
	CMP userSelect, 4
	JLE	floatOperation
	CMP userSelect, 5
	JGE binaryOperation

	floatOperation:
		CALL floatCalc
		RET

	binaryOperation:
		CALL binaryCalc
		RET

	endFunction:
		mWrite "You have chose to EXIT the program."
		CALL Crlf
		RET
selectOperation ENDP

floatCalc PROC
	LOCAL floatOne: REAL4, floatTwo: REAL4, floatResult: REAL4

	readFloatNum:
		MOV EDX, OFFSET titleMsg
		CALL WriteString
		mWrite "Please enter the 1st Term (Floating Number): "
		CALL ReadFloat
		FCOM ZERO
		FNSTSW AX
		SAHF
		JE invalidFloat
		FSTP floatOne
			
		mWrite "Please enter the 2nd Term (Floating Number): "
		CALL ReadFloat
		FCOM ZERO
		FNSTSW AX
		SAHF
		JE invalidFloat

		FSTP floatTwo

		CALL Crlf

	floatFunc:
		CMP userSelect, 1
		JE SUM
		CMP userSelect, 2
		JE MINUS
		CMP userSelect, 3
		JE MULTIPLY
		CMP userSelect, 4
		JE DIVIDE

	invalidFloat:
		CALL Clrscr
		MOV EDX, OFFSET invalidFloatInput
		CALL WriteString
		JMP readFloatNum

	invalidTermTwo:
		CALL Clrscr
		MOV EDX, OFFSET invalidFloatNum
		CALL WriteString
		JMP readFloatNum

	SUM:
		INVOKE Addition, floatOne, floatTwo
		mWrite "Result of 'ADDITION' Calculation (3.d.p): "
		JMP checkSign

	MINUS:
		INVOKE Subtraction, floatOne, floatTwo
		mWrite "Result of 'SUBTRACTION' Calculation (3.d.p): "
		JMP checkSign

	MULTIPLY:
		INVOKE Multiplication, floatOne, floatTwo
		mWrite "Result of 'MULTIPLICATION' Calculation (3.d.p): "
		JMP checkSign

	DIVIDE:
		INVOKE Division, floatOne, floatTwo
		mWrite "Result of 'DIVISION' Calculation (3.d.p): "

	checkSign:
		FCOM ZERO
		FNSTSW AX
		SAHF
		JA printFloatResult
		mWrite "-"

	printFloatResult:
		partOne:
			FMUL TENTHOUSANDS
			FISTP floatResult
			XOR EDX, EDX				; CLEAN the EDX registry (make sure it is 0)
			MOV EAX, floatResult
			CDQ
			MOV EBX, 10000
			IDIV EBX
			CMP EAX, 0
			JG partTwo
			NEG EAX

		partTwo:
			CALL WriteDec
			MOV EAX, EDX
			NEG EAX
			CMP EAX, 10
			JL threeZero
			CMP EAX, 100
			JL twoZero
			CMP EAX, 1000
			JL oneZero
			mWrite "."
			CALL WriteDec
			CALL Crlf
			JMP askContinue

		oneZero:
			mWrite ".0"
			CALL WriteDec
			CALL Crlf
			JMP askContinue

		twoZero:
			mWrite ".00"
			CALL WriteDec
			CALL Crlf
			JMP askContinue

		threeZero:
			mWrite ".000"
			CALL WriteDec
			CALL Crlf

		askContinue:
			MOV EDX, OFFSET endTitleMsg
			CALL WriteString

			CALL continueProgram

	RET
floatCalc ENDP

binaryCalc PROC
	LOCAL binaryOne: BYTE, binaryTwo: BYTE

	readNum:
		MOV EDX, OFFSET titleMsg
		CALL WriteString
		mWrite "Please enter the 1st Term (Positive Integer): "
		CALL ReadInt
		JO invalidNum
		CMP EAX, 0
		JL invalidNum
		CMP EAX, 255
		JG invalidNum
		MOV binaryOne, AL

		mWrite "Please enter the 2nd Term (Positive Integer): "
		CALL ReadInt
		JO invalidNum
		CMP EAX, 0
		JL invalidNum
		CMP EAX, 255
		JG invalidNum
		MOV binaryTwo, AL

		CALL Crlf
		JMP BinaryFunc

	BinaryFunc:
		mWrite "Number "
		MOV AL, binaryOne
		CALL WriteDec
		mWrite " converted into BINARY: "
		MOV EBX, TYPE BYTE
		CALL WriteBinB
		CALL Crlf

		mWrite "Number "
		MOV AL, binaryTwo
		CALL WriteDec
		mWrite " converted into BINARY: "
		MOV EBX, TYPE BYTE
		CALL WriteBinB
		CALL Crlf

		CALL Crlf
		CMP userSelect, 5
		JE BinAND
		CMP userSelect, 6
		JE BinOR
		CMP userSelect, 7
		JE BinXOR
		CMP userSelect, 8
		JE BinNOT

	invalidNum:
		CALL Clrscr
		MOV EDX, OFFSET invalidNumInput
		CALL WriteString
		JMP readNum

	BinAND:
		INVOKE LogicalAND, binaryOne, binaryTwo
		mWrite "Result of Logical 'AND' Calculation: "
		JMP printBinResult

	BinOR:
		INVOKE LogicalOR, binaryOne, binaryTwo
		mWrite "Result of Logical 'OR' Calculation: "
		JMP printBinResult
		
	BinXOR:
		INVOKE LogicalXOR, binaryOne, binaryTwo
		mWrite "Result of Logical 'XOR' Calculation: "
		JMP printBinResult
			
	BinNOT:
		INVOKE LogicalNOT, binaryOne, binaryTwo
		mWrite "Result of Logical 'NOT' CALCULATION - 2nd Term: "
		JMP printBinResult

	printBinResult:
		MOV EBX, TYPE BYTE
		CALL WriteBinB
		CALL Crlf
		MOV EDX, OFFSET endTitleMsg
		CALL WriteString
		CALL continueProgram	

	RET
binaryCalc ENDP

continueProgram PROC
	readCharacter:
		mWrite "Do you want to continue?"
		CALL Crlf
		mWrite "(Y = Continue Module / N = Return to Main Menu): "
		CALL ReadChar
		CALL WriteChar
		CALL Crlf

		CMP AL, 'Y'
		JE YES
		CMP AL, 'y'
		JE YES

		CMP AL, 'N'
		JE NO
		CMP AL, 'n'
		JE NO

		MOV EDX, OFFSET invalidCharInput
		CALL WriteString

		JMP readCharacter

	YES:
		CALL Clrscr
		CALL selectOperation
		RET

	NO:
		CALL Clrscr
		CALL main
		RET
	
continueProgram ENDP

Addition PROC,
	term1:REAL4,
	term2:REAL4

	FLD term1
	FLD term2
	FADDP

	RET
Addition ENDP

Subtraction PROC,
	term3:REAL4,
	term4:REAL4

	FLD term3
	FLD term4
	FSUBP

	RET
Subtraction ENDP

Multiplication PROC,
	term5:REAL4,
	term6:REAL4

	FLD term5
	FLD term6
	FMULP

	RET
Multiplication ENDP

Division PROC,
	term7:REAL4,
	term8:REAL4

	FLD term7
	fld term8
	FDIVP

	RET
Division ENDP

LogicalAND PROC,
	term9:BYTE,
	term10:BYTE

	MOV AL, term9
	AND AL, term10

	RET
LogicalAND ENDP

LogicalOR PROC,
	term11:BYTE,
	term12:BYTE

	MOV AL, term11
	OR AL, term12

	RET
LogicalOR ENDP

LogicalXOR PROC,
	term13:BYTE,
	term14:BYTE

	MOV AL, term13
	XOR AL, term14

	RET
LogicalXOR ENDP

LogicalNOT PROC,
	term15:BYTE,
	term16:BYTE

	MOV AL, term15
	NOT AL
	mWrite "Result of Logical 'NOT' CALCULATION - 1st Term: "
	MOV EBX, TYPE BYTE
	CALL WriteBinB
	CALL Crlf

	MOV AL, term16
	NOT AL

	RET
LogicalNOT ENDP

END main		;specify the program's entry point
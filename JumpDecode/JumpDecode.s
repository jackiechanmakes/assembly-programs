@ Program 4
@ JumpDecode.s
@ Jackie Chan
@ 09-2024
@ CIST 039
.PSIZE 50, 100
.TITLE		"ARM Jump Decoding"
.SBTTL		"Data Section"	

.DATA

courseSTR:		.ASCIZ	"Jackie Chan\t\t\tCIST 039\n"
pgmSTR:			.ASCIZ	"This program will decode a subset of ARM instructions\n"
titleSTR:		.ASCIZ	"Address\t\tM Language\tInstruction"

printSTR:		.ASCIZ	"0x%08X\t%08X\t"
printBranchOff:	.STRING	"\t<%+d>"
printSTRing:	.STRING	"%s"

/* STRINGS for Opcode		*/
unknownIns:		.STRING "UNKNOWN INSTRUCTION"

/*
	Opcode Strings for Branch / Branch and Link instructions...4 bytes each
*/

branchMnemonics:
//			Null Terminate Label with Space (4 Bytes...HINT!)			
			.STRING	"EQ "	// 0000		- Bit vales in CC field
			.STRING	"NE "	// 0001
			.STRING	"CS "	// 0010
			.STRING	"CC "	// 0011
			.STRING	"MI "	// 0100
			.STRING	"PL "	// 0101
			.STRING	"VS "	// 0110
			.STRING	"VC " 	// 0111
			.STRING	"HI "	// 1000
			.STRING	"LS "	// 1001
			.STRING	"GE "	// 1010
			.STRING	"LT "	// 1011
			.STRING	"GT "	// 1100
			.STRING	"LE "	// 1101
			.STRING	" "	// 1110		// Just a Branch B / BL
			.STRING	"xx "	// 1111		// Reserved, never use

/*
shiftInSTRuctionCC	=28
maskInSTRuctionCC	=0b1111

shiftLinkFlag		=24

shiftMajorOpcode	= 25
maskMajorOpcode		= 0b0000111
*/
							
.EJECT			// Form feed / New Page
.SBTTL		"The Code for the Program"
.TEXT
.GLOBAL	main

main:
	SUB		SP, SP, #20		// Save registers
	STR		R7, [SP, #16]
	STR		R6, [SP, #12]
	STR		R5, [SP, #8]
	STR		R4, [SP, #4]
	STR		LR, [SP, #0]

	LDR		R0, =courseSTR		/*Class Title*/ 
	BL		puts
	
	LDR		R0, =pgmSTR		/*The Program Title*/ 
	BL		puts
	
	LDR		R0, =titleSTR	// Column header
	BL		puts
	
	LDR		R5, =TestCodeToDecode
	LDR		R7, =branchMnemonics	
	
	MOV		R4, #0			     // Loop Counter and Index
LOOP:
	LDR		R0, =printSTR
	ADD		R1, R5, R4, LSL#2    // Instruction address
	LDR		R6, [R5, R4, LSL#2]  // Load instruction
	MOV		R2, R6
	BL		printf	
		
	AND		R12, R6, #0b111<<25	 // Branch opcode logic
	TEQ		R12, #0b101<<25
	BNE		notBranchInstruction
	MOV		R0, #'B'
	BL		putchar
	
	ANDS	R12, R6, #0b1<<24    // Link logic
	BEQ		getConditionCode
	MOV		R0, #'L'
	BL		putchar
	B		getConditionCode	
	
notBranchInstruction:
	LDR		R0, =unknownIns
	BL		printf
	B		LoopNext
	
getConditionCode:
	AND		R0, R6, #0b1111<<28  // Condition code logic
	LSR		R0, R0, #28			
	ADD		R0, R7, R0, LSL#2
	BL		printf
	
	LSL		R1, R6, #8         // Offset logic
	ASR		R1, R1, #(8-2)     // Combine align bits with encoding num instructions not bytes which needs LSL#2 
	ADD		R1, R1, #8         // Prefetch instruction
	LDR		R0, =printBranchOff
	BL		printf		

LoopNext:	
	MOV		R0, #'\n'
	BL		putchar

	ADD		R4, R4, #1
	CMP		R4, #20		// Read 20 Instructions
	BLT		LOOP

ProgramExit:	
	LDR		LR, [SP, #0]	// Restore registers
	LDR		R4, [SP, #4]
	LDR		R5, [SP, #8]
	LDR		R6, [SP, #12]
	LDR		R7, [SP, #16]
	ADD		SP, SP, #20
	
	MOV		R0,#0			// Return Code of 0	
	BX		LR


/*
This is random test code.  It has no functional meaning.  It is here
to create bits in memory for us to decode!
*/	
TestCodeToDecode:
	BEQ		T2
	BLNE	TestCodeToDecode
	.WORD	0xFFFFFFFF
	.WORD	0X00000000
	BMI		T2
	MOV		R1, R2
	BLPL	T2
	BCS		T2
	BLHI	TestCodeToDecode
	BLS		T2
	BLGT	T2
	BGE		T2
	.ASCII	"ABCD"
	BLCC	T2
	BVS		T2
	BLVC	T2
	BLE		T2
	B		T2
	BL		TestCodeToDecode
T2:
	ANDS	R3, R5, R9, ASR	#7
	CMP		R5, r7
	CMP		R6, #25

	CMN		R11, R13
	ADD		R0,R7,R2
	ORR		R11,R12,R10

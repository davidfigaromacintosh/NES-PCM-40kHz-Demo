;; NES 2.0
db $4E, $45, $53, $1A, $00, $00, $20, $08, $00, $01, $00, $07, $00, $00, $00, $00



;;; PRG

;;; PRGAudio

incbin "audio.bin"

;;; PRGLast

org $c000
base $c000

;; RESET routine
RESET:
	sei
	cld
	
	ldx #$40
	stx $4017
	
	;; Set the stack pointer @ $01ff
	ldx #$ff
	txs
	inx
	stx $2000
	stx $2001
	jsr VBlank
	
	@ClearRAM:
		lda #$ff
		sta $0200,x
		lda #$00
		sta $0000,x
		sta $0100,x
		sta $0300,x
		sta $0400,x
		sta $0500,x
		sta $0600,x
		sta $0700,x
		inx
		bne @ClearRAM
	
	jsr VBlank
	
	;; Load CHRRAM
	jsr LoadCHRRAM
	jsr VBlank
	
	;; Load palette
	jsr LoadPalette
	jsr VBlank
	
	;; Load background
	jsr LoadBackground
	jsr VBlank
	lda $2002
	lda #%00011110
	sta $2001
	lda #$00
	sta $2006
	sta $2006
	lda #$02
	sta $2005
	lda #$08
	sta $2005
	lda #$80
	sta $01

	jsr VBlank
	
	lda #$00
	sta $ff
	ldy #$00
	ldx #$40
	jmp DMCDirectLoad



;; Nametable data (for background)
NameTable:
incbin "nametable.bin"
dsb 64,0

;; CHR Data
CHRData:
incbin "chr.bin"



;;; Subroutines

;; Wait for the VBlank
VBlank:
	lda $2002
	bpl VBlank
	rts
	
;; Quick load the palette
LoadPalette:
	lda $2002
	lda #$3f
	sta $2006
	lda #$00
	sta $2006
	lda #$ff
	sta $2007
	sta $2007
	lda #$2b
	sta $2007
	lda #$2c
	sta $2007
	rts

;;Load the CHR data into CHRRAM
LoadCHRRAM:
	lda #<CHRData
	sta $03
	lda #>CHRData
	sta $04
	
	ldy $2002
	ldy #$00
	sty $2001
	sty $2006
	sty $2006
	ldx #$32
	
	@loop
		lda ($03),y
		sta $2007
		iny
		bne @loop
		inc $04
		dex
		bne @loop
		rts
	
;; Load background
LoadBackground:
	ldx #$04
	ldy #$00
	lda #<NameTable
	sta $03
	lda #>NameTable
	sta $04
	lda $2002
	lda #$20
	sta $2006
	lda #$00
	sta $2006
	@loop
	lda ($03),y
	sta $2007
	iny
	bne @loop
	inc $04
	dex
	bne @loop
	rts
	
;; Here's where the whole magic happens (PCM streaming)
DMCDirectLoad:
	ldy #$00
	ldx #$40
	
	lda $ff
	cmp #$fa
	bne @res
	lda #$00
	sta $ff
	
	@res	
	sta $8000
	lda #$80
	sta $01
	@LoopXY
		
		lda ($00),y
		sta $4011

		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		
		iny
		bne @LoopXY
		inc $01
		dex
		bne @LoopXY
		inc $ff
	jmp DMCDirectLoad



;; Interrupt vectors
pad $fffa
dw 0, RESET, 0

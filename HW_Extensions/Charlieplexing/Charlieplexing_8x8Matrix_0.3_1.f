fl                                                              
{
Drived on 8-wires for 8x8DotMatrix by Charlieplexing
2014/11/10 17:11:46

}

\ =========================================================================== 
\ 8X8 Font Characters 
\ =========================================================================== 
wvariable Font -2 allot
h01 c, h03 c, h07 c, h0F c, h1F c, h3F c, h7F c, hFF c, 
h00 c, h06 c, h5F c, h5F c, h06 c, h00 c, h00 c, h00 c,
h00 c, h03 c, h07 c, h00 c, h07 c, h03 c, h00 c, h00 c,
h14 c, h7F c, h7F c, h14 c, h7F c, h7F c, h14 c, h00 c,
h24 c, h2E c, h2A c, h6B c, h6B c, h3A c, h12 c, h00 c,
h46 c, h66 c, h30 c, h18 c, h0C c, h66 c, h62 c, h00 c,
h30 c, h7A c, h4F c, h5D c, h37 c, h7A c, h48 c, h00 c,
h00 c, h04 c, h07 c, h03 c, h00 c, h00 c, h00 c, h00 c,
h00 c, h1C c, h3E c, h63 c, h41 c, h00 c, h00 c, h00 c,
h00 c, h41 c, h63 c, h3E c, h1C c, h00 c, h00 c, h00 c,
h08 c, h2A c, h3E c, h1C c, h1C c, h3E c, h2A c, h08 c,
h08 c, h08 c, h3E c, h3E c, h08 c, h08 c, h00 c, h00 c,
h00 c, h80 c, hE0 c, h60 c, h00 c, h00 c, h00 c, h00 c,
h08 c, h08 c, h08 c, h08 c, h08 c, h08 c, h00 c, h00 c,
h00 c, h00 c, h60 c, h60 c, h00 c, h00 c, h00 c, h00 c,
h60 c, h30 c, h18 c, h0C c, h06 c, h03 c, h01 c, h00 c,
h3E c, h7F c, h41 c, h49 c, h41 c, h7F c, h3E c, h00 c,
h40 c, h42 c, h7F c, h7F c, h40 c, h40 c, h00 c, h00 c,
h62 c, h73 c, h59 c, h49 c, h6F c, h66 c, h00 c, h00 c,
h22 c, h63 c, h49 c, h49 c, h7F c, h36 c, h00 c, h00 c,
h18 c, h1C c, h16 c, h53 c, h7F c, h7F c, h50 c, h00 c,
h27 c, h67 c, h45 c, h45 c, h7D c, h39 c, h00 c, h00 c,
h3C c, h7E c, h4B c, h49 c, h79 c, h30 c, h00 c, h00 c,
h03 c, h03 c, h71 c, h79 c, h0F c, h07 c, h00 c, h00 c,
h36 c, h7F c, h49 c, h49 c, h7F c, h36 c, h00 c, h00 c,
h06 c, h4F c, h49 c, h69 c, h3F c, h1E c, h00 c, h00 c,
h00 c, h00 c, h66 c, h66 c, h00 c, h00 c, h00 c, h00 c,
h00 c, h80 c, hE6 c, h66 c, h00 c, h00 c, h00 c, h00 c,
h08 c, h1C c, h36 c, h63 c, h41 c, h00 c, h00 c, h00 c,
h24 c, h24 c, h24 c, h24 c, h24 c, h24 c, h00 c, h00 c,
h00 c, h41 c, h63 c, h36 c, h1C c, h08 c, h00 c, h00 c,
h02 c, h03 c, h51 c, h59 c, h0F c, h06 c, h00 c, h00 c,
h3E c, h7F c, h41 c, h5D c, h5D c, h1F c, h0E c, h00 c,
h7C c, h7E c, h13 c, h13 c, h7E c, h7C c, h00 c, h00 c,
h41 c, h7F c, h7F c, h49 c, h49 c, h7F c, h36 c, h00 c,
h1C c, h3E c, h63 c, h41 c, h41 c, h63 c, h22 c, h00 c,
h41 c, h7F c, h7F c, h41 c, h63 c, h3E c, h1C c, h00 c,
h41 c, h7F c, h7F c, h49 c, h5D c, h41 c, h63 c, h00 c,
h41 c, h7F c, h7F c, h49 c, h1D c, h01 c, h03 c, h00 c,
h1C c, h3E c, h63 c, h41 c, h51 c, h73 c, h72 c, h00 c,
h7F c, h7F c, h08 c, h08 c, h7F c, h7F c, h00 c, h00 c,
h00 c, h41 c, h7F c, h7F c, h41 c, h00 c, h00 c, h00 c,
h30 c, h70 c, h40 c, h41 c, h7F c, h3F c, h01 c, h00 c,
h41 c, h7F c, h7F c, h08 c, h1C c, h77 c, h63 c, h00 c,
h41 c, h7F c, h7F c, h41 c, h40 c, h60 c, h70 c, h00 c,
h7F c, h7F c, h0E c, h1C c, h0E c, h7F c, h7F c, h00 c,
h7F c, h7F c, h06 c, h0C c, h18 c, h7F c, h7F c, h00 c,
h1C c, h3E c, h63 c, h41 c, h63 c, h3E c, h1C c, h00 c,
h41 c, h7F c, h7F c, h49 c, h09 c, h0F c, h06 c, h00 c,
h1E c, h3F c, h21 c, h71 c, h7F c, h5E c, h00 c, h00 c,
h41 c, h7F c, h7F c, h09 c, h19 c, h7F c, h66 c, h00 c,
h26 c, h6F c, h49 c, h49 c, h7B c, h32 c, h00 c, h00 c,
h03 c, h41 c, h7F c, h7F c, h41 c, h03 c, h00 c, h00 c,
h7F c, h7F c, h40 c, h40 c, h7F c, h7F c, h00 c, h00 c,
h1F c, h3F c, h60 c, h60 c, h3F c, h1F c, h00 c, h00 c,
h7F c, h7F c, h30 c, h18 c, h30 c, h7F c, h7F c, h00 c,
h61 c, h73 c, h1E c, h0C c, h1E c, h73 c, h61 c, h00 c,
h07 c, h4F c, h78 c, h78 c, h4F c, h07 c, h00 c, h00 c,
h47 c, h63 c, h71 c, h59 c, h4D c, h67 c, h73 c, h00 c,
h00 c, h7F c, h7F c, h41 c, h41 c, h00 c, h00 c, h00 c,
h01 c, h03 c, h06 c, h0C c, h18 c, h30 c, h60 c, h00 c,
h00 c, h41 c, h41 c, h7F c, h7F c, h00 c, h00 c, h00 c,
h08 c, h0C c, h06 c, h03 c, h06 c, h0C c, h08 c, h00 c,
h80 c, h80 c, h80 c, h80 c, h80 c, h80 c, h80 c, h80 c,
h00 c, h00 c, h01 c, h03 c, h06 c, h04 c, h00 c, h00 c,
h20 c, h74 c, h54 c, h54 c, h3C c, h78 c, h40 c, h00 c,
h41 c, h7F c, h3F c, h48 c, h48 c, h78 c, h30 c, h00 c,
h38 c, h7C c, h44 c, h44 c, h6C c, h28 c, h00 c, h00 c,
h30 c, h78 c, h48 c, h49 c, h3F c, h7F c, h40 c, h00 c,
h38 c, h7C c, h54 c, h54 c, h5C c, h18 c, h00 c, h00 c,
h48 c, h7E c, h7F c, h49 c, h03 c, h02 c, h00 c, h00 c,
h98 c, hBC c, hA4 c, hA4 c, hF8 c, h7C c, h04 c, h00 c,
h41 c, h7F c, h7F c, h08 c, h04 c, h7C c, h78 c, h00 c,
h00 c, h44 c, h7D c, h7D c, h40 c, h00 c, h00 c, h00 c,
h60 c, hE0 c, h80 c, h80 c, hFD c, h7D c, h00 c, h00 c,
h41 c, h7F c, h7F c, h10 c, h38 c, h6C c, h44 c, h00 c,
h00 c, h41 c, h7F c, h7F c, h40 c, h00 c, h00 c, h00 c,
h7C c, h7C c, h08 c, h38 c, h0C c, h7C c, h78 c, h00 c,
h7C c, h7C c, h04 c, h04 c, h7C c, h78 c, h00 c, h00 c,
h38 c, h7C c, h44 c, h44 c, h7C c, h38 c, h00 c, h00 c,
h84 c, hFC c, hF8 c, hA4 c, h24 c, h3C c, h18 c, h00 c,
h18 c, h3C c, h24 c, hA4 c, hF8 c, hFC c, h84 c, h00 c,
h44 c, h7C c, h78 c, h4C c, h04 c, h1C c, h18 c, h00 c,
h48 c, h5C c, h54 c, h54 c, h74 c, h24 c, h00 c, h00 c,
h00 c, h04 c, h3E c, h7F c, h44 c, h24 c, h00 c, h00 c,
h3C c, h7C c, h40 c, h40 c, h3C c, h7C c, h40 c, h00 c,
h1C c, h3C c, h60 c, h60 c, h3C c, h1C c, h00 c, h00 c,
h3C c, h7C c, h60 c, h38 c, h60 c, h7C c, h3C c, h00 c,
h44 c, h6C c, h38 c, h10 c, h38 c, h6C c, h44 c, h00 c,
h9C c, hBC c, hA0 c, hA0 c, hFC c, h7C c, h00 c, h00 c,
h4C c, h64 c, h74 c, h5C c, h4C c, h64 c, h00 c, h00 c,
h08 c, h08 c, h3E c, h77 c, h41 c, h41 c, h00 c, h00 c,
h00 c, h00 c, h7F c, h7F c, h00 c, h00 c, h00 c, h00 c,
h41 c, h41 c, h77 c, h3E c, h08 c, h08 c, h00 c, h00 c,
h02 c, h03 c, h01 c, h03 c, h02 c, h03 c, h01 c, h00 c,
h4C c, h5E c, h73 c, h01 c, h73 c, h5E c, h4C c, h00 c,

\ =========================================================================== 
\ Variables 
\ =========================================================================== 
\ Buffer for 8x8 LED-Matrix
variable matrix 4 allot 

\ =========================================================================== 
\ Main 
\ =========================================================================== 

\ Drive 8x8-LED-Matrix curcuit for Charlieplexing by assembler-word
\ It takes about 16msec displaying 8-lines.
\ ( n1 -- )  n1:address of 8x8-Matrix buffer
lockdict create _matrix_Charlie_asm forthentry
$C_a_lxasm w, h12E  h113  1- tuck - h9 lshift or here W@ alignl h10 lshift or l,
z2WyPW8 l, z2WiPfg l, z2WiPmB l, z2Wyxj0 l, z2WyxW0 l, z1Sy\Ka l, z2WixZD l, z2Wyxmy l,
z2WiPve l, z20iPyk l, z3ryPr0 l, ziPuE l, z2[iQ3F l, z24yQ01 l, z2WixZG l, z1Sy\Ka l,
zfyPb1 l, z20yPj1 l, z3[yP[M l, z1SV04J l, z2WiPvf l, z20iPyk l, z3ryPr0 l, z1SV000 l,
z38 l, zJY0 l, z1 l,
freedict


\ Drive 8x8-LED-Matrix curcuit for Charlieplexing by forth-word
\ It takes about 11msec displaying 8-lines.
\ ( -- )   
: matrix_Charlie_fth
begin
     1                                  \ Set initial data for SCR-on
     8 0 do
          0 dira COG!                   \ Set P0 to P7 to Hi-Z (LED off)
          0 outa COG!                   \ Clear P0-P7
          dup
          \ Activate each SCR 
          i lshift outa COG!
          hFF dira COG!
          \ Set data (L-active)
          matrix i + C@ invert outa COG!
          1 delms                      \ Display data 
     loop
     drop
0 until
; 
              
\ Clear matrix buffer
\ ( -- )
: clr_matrix 0 matrix L! 0 matrix 4+ L! ;

\ Activate LED by one by
\ ( -- )
: matrix_LED
matrix
8 0 do
     8 0 do
          dup
          1 i lshift swap C!  
          d100 delms        
     loop
     dup 0 swap C!
     1+
loop
drop
;
 
\ H/W check by Forth-word
\ ( -- )
: test_fth
clr_matrix
c" matrix_Charlie_fth" 0 cogx

matrix_LED
0 cogreset
;

\ H/W test by Assembler-word
\ ( -- )
: test_asm
clr_matrix
c" matrix _matrix_Charlie_asm" 0 cogx

matrix_LED
0 cogreset
;

\ Shift Font-data from right to left inside buffer
\ matrix+7 <- matrix+6 <- matrix+5 <- matrix+4 <- matrix+3 <- matrix+2 <- matrix+1 <- matrix
\ ( -- )
: shift_data
matrix 7 +
7 0 do
     dup 1-              \ ( matrix+7 matrix+6 )
     C@ over C!          \  Shift data 
     1-     
loop
drop
;

\ Display 96character by Forth-word and Asembler-word
\ ( -- )
: demo_fth
\ Clear buffer 
clr_matrix
c" matrix_Charlie_fth" 0 cogx

Font
d768 0 do
     dup
     shift_data
     C@ matrix C!
     1+
     d100 delms
loop
drop
0 cogreset
;

: demo_asm
\ Clear buffer 
clr_matrix
c" matrix _matrix_Charlie_asm" 0 cogx

Font
d768 0 do
     dup
     shift_data
     C@ matrix C!
     1+
     d100 delms
loop
drop
0 cogreset
;


{
\ Driver for 8x8-Matrix-LED by Charlieplexing
\ Using P0 - P7
\ Top pin for drive is P0
\ $C_treg1:loop counter
\ $C_treg2:SCR drive data
\ $C_treg3:buffer address
\ ( n1 -- )  n1:address of 8x8-Matrix buffer 
fl
build_BootOpt :rasm
__1
     mov       $C_treg1 , # 8
     mov       $C_treg2 , __scr
     mov       $C_treg3 , $C_stTOS
     
__2     
     \ Set from P0 to P7 to Hi-Z (All LEDs off)
     mov       dira , # 0
     \ Set data to 0
     mov       outa , # 0
     \ Wait to drive next SCR
     jmpret  __delayret , # __delay
     
     \ each SCR on
     mov       outa , $C_treg2
     mov       dira , # hFF
     mov       $C_treg4 , __2.5usec
	add       $C_treg4 , cnt
     waitcnt   $C_treg4 , # 0                               
     
     \ Set data
     rdbyte    $C_treg4 , $C_treg3
     neg       $C_treg5 , $C_treg4
     sub       $C_treg5 , # 1
     mov       outa , $C_treg5
     
     \ Delay 1msec
     jmpret  __delayret , # __delay
     
     shl       $C_treg2 , # 1
     add       $C_treg3 , # 1
     
     djnz      $C_treg1 , # __2
     jmp       # __1

          
__delay
          mov       $C_treg4 , __1msec
		add       $C_treg4 , cnt
          waitcnt   $C_treg4 , # 0                               
__delayret
		ret
		
\ This value must be adjust when changing SCR     
__2.5usec
     d200      
__1msec
     d80000
     
__scr
     1     
;asm _matrix_Charlie_asm

}

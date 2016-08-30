fl
{                       
PropForth 5.5(DevKernel)

RAMDISK(using Low8bit:256kbyte High8bit:256kbyte) by using SRAM(CY7C1041DV33:4Mbits)
2016/08/30 20:49:34

SRAM:CY7C1041DV33 1pc  [h0 - h3FFFF]     Low Byte
                       [h40000 - h7FFFF] High Byte
BinaryCounter:74HC163 5pcs
ShiftRegister:74HC164 3pcs
}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ P0-P7 Data bit
8 wconstant srClk
9 wconstant srData
d10 wconstant cntClk
d11 wconstant cntLoad
d12 wconstant CE
d13 wconstant WE
d14 wconstant OE

\ =========================================================================== 
\ Variables 
\ =========================================================================== 
variable flRAM_in
variable flRAM_out

\ =========================================================================== 
\ Main 
\ =========================================================================== 
\ --- ShiftRegister-------------------------- 
\ Clockout for shiftregister
\ ( -- )
: srClkOut srClk pinhi srClk pinlo ;

\ Set Data to Hi 
\ ( -- )
: srData-H srData pinhi ;

\ Set Data to Lo
\ ( -- )
: srData-L srData pinlo ;

\ Set address to ShiftRegister
\ ( n1 -- ) n1:address[0-h7FFFF]
: srSet
h40000
d19 0 do
     2dup and
     if srData-H else srData-L then
     srClkOut
     1 rshift
loop
2drop
;

\ Reset ShiftRegister
\ ( -- )
: resetSR 0 srSet ;
          
\ --- Binary Counter -------------------------
\ Clockout for BinaryCounter
\ ( -- )
: cntClkOut cntClk pinhi cntClk pinlo ;

\ Preset value
\ ( -- )
: cntPreset cntLoad pinlo cntClkOut cntLoad pinhi ;

\ Clear BinaryCounter
\ ( -- )
: cntClr resetSR cntPreset ;

\ Set address
\ ( n1 -- ) n1:address[0-h7FFFF]
: setAddr srSet cntPreset ;

\ Set address as assembler Word
\ ( n1 n2 -- ) n1:address[0-h7FFFF] n2:srClk
lockdict create a_setAddr forthentry
$C_a_lxasm w, h134  h113  1- tuck - h9 lshift or here W@ alignl h10 lshift or l,
z2Wy]01 l, zfi]3B l, z20yPO1 l, z2Wy]81 l, zfi]BB l, z20yPO1 l, z2Wy]G1 l, zfi]JB l,
z20yPO1 l, z2Wy]O1 l, zfi]RB l, z1SyLI[ l, z2WyPWJ l, zfyPOD l, zgyPO1 l, z1jix[k l,
z1bix[j l, 0 l, 0 l, z1[ix[j l, z3[yP[X l, z1[ix[m l, z1bix[l l, 0 l,
0 l, z1[ix[l l, z1bix[m l, z1SyLI[ l, z1SV01X l, 0 l, 0 l, 0 l,
0 l,
freedict

\ --- SRAM -----------------------------------
\ Set CE to Lo[Active]
\ ( -- )
: CE-L CE pinlo ;

\ Set CE to Hi
\ ( -- )
: CE-H CE pinhi ;

\ Set SRAM to output
\ ( -- )
: outputSRAM dira COG@ hFF or dira COG! ;

\ Set SRAM to input
\ ( -- )
: inputSRAM dira COG@ hFFFF_FF00 and dira COG! ;

\ Write data to SRAM
\ ( n1 -- ) n1:writing data[1byte]
: wrSRAM outputSRAM WE pinlo outa COG@ hFFFF_FF00 and or outa COG! WE pinhi ;

\ Read data from SRAM
\ ( -- n1 ) n1:read data[1byte]
: rdSRAM inputSRAM OE pinlo ina COG@ hFF and OE pinhi ;


\ Initialize RAMDISK curcuit
\ ( -- )
: initRAM
srClk 7 0 do dup pinout 1+ loop drop    \ Set P8-P14 to output
resetSR                                 \ Reset ShiftRegister
cntLoad pinhi                           \ Deactive LOAD for BinaryCounter
CE-H WE pinhi OE pinhi                  \ Deactive CE/WE/OE for SRAM
cntClr                                  \ Reset BinaryCounter (address=h0)
;

\ Read data and store data in buffer and count up address
\ ( n1 n2 -- )  n1:buffer address n2:count[byte]
: readSRAM
bounds do
     rdSRAM i C!
     cntClkOut
loop
;


\ dump RANDISK
\ ( n1 n2 -- )  n1:startAddr[0-f7FFEF] n2:count[byte] 
: dumpDISK
initRAM
hex
over setAddr                       \ Set startAddr
CE-L
\ Print startAddr and count
over dup d16 rshift h30 + emit .word space dup .word _ecs cr
bounds
do
     i dup 
     d16 rshift h30 + emit .word _ecs   \ Print address
	tbuf d16 readSRAM
	(dumpe) cr                          
d16 +loop
CE-H
cr
decimal
;

\ Writing test values[0 to d255] in RAMDISK
\ ( n1 -- )  n1:block[1block=256byte]
: test
initRAM
cntClr
CE-L
0 do
     d256 0 do i wrSRAM cntClkOut loop
     ." ."
loop
CE-H
;

\ Write n1 in address0
\ ( n1 n2 -- n1 ) n1:data n2:address[0 - h7FFFF]
: test1
\ initRAM
setAddr
CE-L
\ outputSRAM 
wrSRAM
\ inputSRAM 
rdSRAM .
CE-H
;

\ Read data from RAMDISK
\ ( n1 -- n2 ) n1:address  n2:data[1byte]
: rdDISK
srClk a_setAddr
inputSRAM OE pinlo ina COG@ hFF and OE pinhi
;

\ Write data to RAMDISK
\ ( n1 n2 -- ) n1:data[1byte] n2:address
: wrDISK
srClk a_setAddr
outputSRAM WE pinlo outa COG@ hFFFF_FF00 and or outa COG! WE pinhi
;

\ attempt to output a character
\ ( -- ) 
: (flRAMout)
io 2+ W@ dup W@ h100 and flRAM_out L@ flRAM_in L@ < and
if
	flRAM_out L@ dup 1+ flRAM_out L! rdDISK swap W! 
else
	drop
then
;
						
\ Skip characters until character find out hD
\ ( -- )
: skip_\ begin key hD = until ;

\ Skip characters until character find out "}"[h7D]
\ ( -- )
: skip_{} begin key h7D = until ;

\ Skip TAB and space
\ ( cnt old_key -- cnt key )
: skip_tab_space
begin
     drop                          \ [ cnt ]
     key                           \ [ cnt new_key ]
     dup h9 = over h20 = or 0=     \ [ cnt new key 1/0 ]
until
;

\ Update flRAM_in and write key to RAMDISK and check if key is hD
\ ( cnt key -- cnt 1/0 )
: update_flRAM_in dup flRAM_in L@ dup 1+ flRAM_in L! wrDISK hD = ;


\ buffer input to RAMDISK and emit n1 is the number of characters overflowed
\ ( -- n1 ) 
\ t1 - the number of characters overflowed
\ flRAM_in - pointer to next character for input
\ flRAM_out - pointer to the next character for output
: (flRAM)
CE-L
0 flRAM_in L! 0 flRAM_out L!

0 t1 W! 
cnt COG@ 1                                                  \ [ timeoutcount beginning_of_line_flag ]
\ process the input stream
begin                                                       \ [ cnt -1 ]
	fkey?                                                  \ [ cnt -1 key 1/0 ]
	if
          \ valid key
          begin                                             \ [ cnt 1 key ]
   			\ Check to see if RAMDISK is overflowed?
			flRAM_in L@ h7FFFF >=
			if                                           \ [ cnt 1 ]
				drop
				1 t1 W+!
			else                                         
				swap                                    \ [ cnt key 1 ]
				if
                    \ 1st character of line
                         \ Check if character is "\"[h5C]
					dup h5C =                          \ [ cnt key 1/0 ]
					if
						drop                          \ [ cnt ]
						skip_\
                              1                             \ [ cnt 1 ]                                                                
					else
						\ Check if character is "{"[h7B]
                              dup h7B =                     \ [ cnt key 1/0 ]                    
						if
                                   drop                     \ [ cnt ] 
                                   skip_{}
					          0                        \ [ cnt 0 ]
						else                                   
                                   \ Check if characters is tab or space?							   
                                   dup h9 = over h20 = or   \ [ cnt key 1/0 ]      
                                   if
                                        skip_tab_space      \ [ cnt key ]
							then 
                                   update_flRAM_in          \ [ cnt 1/0 ]        
						then
					then
				else
				\ Not 1st character of line				
                         update_flRAM_in                    \ [ cnt 1/0 ] 
				then
			then
               \ Break out loop if no key
               (flRAMout) fkey? 0=                          \ [ cnt 1/0 key 1/0 ]                            
		until
  		\ reset the timeout counter
          drop nip cnt COG@ swap                            \ [ cnt 1/0 ]                               
	else
          \ no key
          drop (flRAMout)                                   \ [ cnt 1 ]
	then
 	\ Break out loop if it takes more than 1second under no key
     cnt COG@ 2 ST@ - clkfreq >                             \ [ cnt 1 1/0 ]                            
until 
2drop
                                                            \ [ -- ]
\ output any remain chars
flRAM_out L@ flRAM_in L@ <
if
	flRAM_in L@ flRAM_out L@
	do
		i dup rdDISK emit flRAM_out L! 
	loop
then
\	make sure we terminate any line
cr cr
t1 W@
CE-H
;

\ buffer the input to RAMDISK and route to a free cog
\ ( -- ) 
: flRAM
0 setAddr
lockdict fl_lock W@
if
	freedict
else
	-1 fl_lock W! cogid nfcog dup >r iolink freedict
	(flRAM)
	cogid iounlink
	0 fl_lock W!
	r> over
	if
		cogreset
		cr . ." characters overflowed" cr
	else
		2drop
thens
;





{
Set address
( n1 n2 -- ) n1:address n2:srClr pin-number

fl
build_BootOpt :rasm
     \ Mask each pin
          mov  __srClk , # 1
          shl  __srClk , $C_stTOS
          add  $C_stTOS , # 1
          mov  __srData , # 1
          shl  __srData , $C_stTOS
          add  $C_stTOS , # 1
          mov  __cntClk , # 1
          shl  __cntClk , $C_stTOS
          add  $C_stTOS , # 1
          mov  __cntLoad , # 1
          shl  __cntLoad , $C_stTOS
          spop
     
     \ Set address to shiftregister
          mov  $C_treg1 , # d19
          shl  $C_stTOS , # d13
__1
          shl  $C_stTOS , # 1 wc
          muxc outa , __srData
     \ Clockout
          or outa , __srClk
          nop
          nop
          andn outa , __srClk                
          djnz $C_treg1 , # __1 
     
     \ Preset address to counter
          andn outa , __cntLoad          
          or   outa , __cntClk
          nop
          nop
          andn outa , __cntClk
          or   outa , __cntLoad
           
          spop
          jexit
     
__srClk
     0
__srData
     0
__cntClk
     0     
__cntLoad
     0
     
;asm a_setAddr
}

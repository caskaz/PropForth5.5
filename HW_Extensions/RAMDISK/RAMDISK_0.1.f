fl
{                       
PropForth 5.5(DevKernel)

RAMDISK(using Low8bit:256kbyte) by using SRAM(CY7C1041DV33:4Mbits)
2016/07/19 15:19:31

SRAM:CY7C1041DV33 1pc  [h0 - h3FFFF]
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

\ Set value to ShiftRegister
\ ( n1 -- )
: srSet
h20000
d18 0 do
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
\ ( n1 -- )
: setAddr srSet cntPreset ;

\ --- SRAM -----------------------------------
\ Set CE to Lo[Active]
\ ( -- )
: CE-L CE pinlo ;

\ Set CE to Hi
\ ( -- )
: CE-H CE pinhi ;

\ Write data to SRAM
\ ( n1 -- ) n1:writing data
: wrSRAM WE pinlo outa COG@ hFFFF_FF00 and or outa COG! WE pinhi ;

\ Read data from SRAM
\ ( -- n1 ) n1:read data
: rdSRAM OE pinlo ina COG@ hFF and OE pinhi ;


\ Initialize RAMDISK curcuit
\ ( -- )
: initRAM
srClk 7 0 do dup pinout 1+ loop drop    \ Set P8-P14 to output
resetSR                                 \ Reset ShiftRegister
cntLoad pinhi                           \ Deactive LOAD for BinaryCounter
CE-H WE pinhi OE pinhi                  \ Deactive CE/WE/OE for SRAM
cntClr                                  \ Reset BinaryCounter
;

\ Set SRAM to output
\ ( -- )
: outputSRAM dira COG@ hFF or dira COG! ;

\ Set SRAM to input
\ ( -- )
: inputSRAM dira COG@ hFFFF_FF00 and dira COG! ;

\ Read 16byte
\ ( n1 n2 -- )  n1:buffer address n2:count
: readSRAMpage
bounds do
     rdSRAM i C!
     cntClkOut
loop
;

\ dump RANDISK
\ ( n1 n2 -- )  n1:startAddr n2:count 
: dumpDISK
inputSRAM
over setAddr                       \ Set startAddr
CE-L
\ Print startAddr and count
over dup d16 rshift h30 + emit .word space dup .word _ecs cr
bounds
do
     i dup 
     d16 rshift h30 + emit .word _ecs   \ Print address
	tbuf d16 readSRAMpage
	(dumpe) cr                          
d16 +loop
CE-H
cr
;

\ Write values in whole RAMDISK
\ ( -- )
: test
cntClr
outputSRAM 
CE-L
d1024 0 do
     d256 0 do i wrSRAM cntClkOut loop
     ." ."
loop
CE-H
;




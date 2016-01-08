fl

{
Serial Communication between PropForth and Processing

PropForth 5.5
2015/04/14 18:20:49


                 Prop plug
                -------------
P26(Tx) -------|RX           |
P27(Rx) -------|TX           |-----------------------PC COM5 (Processing)
               |RES          | USB
GND -----------|Vss          |
                -------------

}

\ Re-defined Word"seral" because it has bugs.
: serial
	4*
	clkfreq swap u/ dup 2/ 2/
\
\ serial structure
\
\
\ init 1st 4 members to hFF
\
	hFF h1C2 
	2dup COG!
	1+ 2dup COG!
	1+ 2dup COG!
	1+ tuck COG!
\
\ next 2 members to h100
\
	1+ h100 swap 2dup COG!
	1+ tuck COG!
\
\ bittick/4, bitticks
\
	1+ tuck COG!
	1+ tuck COG!
\
\ rxmask txmask
\
	1+ swap >m over COG!
	1+ swap >m over COG!
\ rest of structure to 0
	1+ h1F0 swap
	do
		0 i COG!
	loop
\
	c" SERIAL" numpad ccopy numpad cds W!
	4 state andnC!
\	0 io hC4 + L!    <-- always 0 cogn sersetbreak
\	0 io hC8 + L!    <-- always 0 cogn sersetflags
	_serial
;

\ =========================================================================== 
\ Variables 
\ =========================================================================== 
wvariable inchar h100 inchar W!

\ =========================================================================== 
\ Main 
\ =========================================================================== 

\ Pretreatment for communication
\ ( -- )
: pre
\ Initialize serial
\    if this bit is 0, CR is transmitted as CR LF
\    if this bit is 1, CR is transmitted as CR
1 5 sersetflags
\ pin 26 tx, pin 27 rx  d9600/4 = d2400
c" 26 27 d2400 serial" 5 cogx
d10 delms
5 cogio 2+ W@                           \ Put output ptr of cog5 on stack
inchar 5 cogio 2+ W!                    \ Set output ptr of cog5 to inchar
io 2+ W@                                \ Put output ptr of current cog on stack
5 cogio io 2+ W!                        \ Set output ptr of current cog to input ptr of cog 5
;

\ Post-processing for communication
\ ( -- )
: post
\ Restore output ptr for current cog 
io 2+ W!
\ Restore output ptr for cog 5
5 cogio 2+ W!   
\ Read out until read-buffer is empty
begin 
     inchar W@ h100 =
     if
          1
     else
          h100 inchar W! 0
     then
until     
5 cogreset
;

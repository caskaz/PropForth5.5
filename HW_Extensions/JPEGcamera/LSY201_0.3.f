fl

{
PropForth5.5(DevKernel)

JPEGcamera LS-Y201 Module
2017/01/08 17:39:08
    
                                                   ---------------------
                 USB-serial Module(38400baud)     |                     |
                  ----------                      |----------           |
Propeller        |          |                     |          |          |
Cog4 P0  --------|Tx        |=====================|Processing|     PC   |
     P1  --------|Rx        |    USB cable        |          |          |
                 |    Gnd   |                     |----------           |
                  ----------                      |                     |
                       |                           ---------------------
                      GND
          
                 LS-Y201 Module (default:38400baud)   
                 ------------
Propeller        |       Vcc|--- 3.3V
Cog5 P2  --------|Tx        |
     P3  --------|Rx        |    
                 |    Gnd   |
                 ------------
                       |
                      GND 
             
serial 38400bps  Noparity Startbit1 Databit8 Stopbit1
time ------------------------------------------------------------>>
-------       ---------                               ------------
       |     |         |                             |
       |     |         |                             | 
        -----           -----------------------------
 idle   start bit0 bit1 bit2 bit3 bit4 bit5 bit6 bit7  stop  idle
         bit                                            bit
       (always "0")                                    (always "1")
                                                      
                                                      
}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ serial for PropForth-Processing
0 wconstant RxD
1 wconstant TxD
\ serial for PropForth-LS-Y201 Module
2 wconstant Rx
3 wconstant Tx
d9600 constant baud/4    \ 38400/4
d12288 wconstant chunk

\ command
wvariable RST -2 allot 2 c, h26 c, h00 c,                                            \ Reset
wvariable START -2 allot 3 c, h36 c, h01 c, h00 c,                                   \ Take picture
wvariable SIZE -2 allot 3 c, h34 c, h01 c, h00 c,                                    \ Read JPEG file size
wvariable JPEG -2 allot d14 c, h32 c, h0C c, h00 c, h0A c, h00 c, h00 c, h00 c, h00 c, h00 c, h00 c, h00 c, h00 c, h00 c, h0A c, 
\ Read JPEG file content 
wvariable STOP -2 allot 3 c, h36 c, h01 c, h03 c,                                    \ Stop picture
wvariable COMP -2 allot 7 c, h31 c, h05 c, h01 c, h01 c, h12 c, h04 c, h00 c,        \ Compression Ratio
wvariable POWER -2 allot 5 c, h3E c, h03 c, h00 c, h01 c, h01 c,                     \ Power saving
wvariable JPEGSIZE -2 allot 3 c, h54 c, h01 c, h22 c,                                \ JPEG size

\ =========================================================================== 
\ Variables 
\ =========================================================================== 
wvariable inport
wvariable inchar
wvariable filesize
wvariable turn
wvariable remainder
wvariable startFlag
wvariable jpgSize

\ =========================================================================== 
\ Main 
\ =========================================================================== 

\ Communication between PropForth and Processing
\ ( -- )
: init_I/F
c" TxD RxD baud/4 serial" 4 cogx   \ Start serial on cog4
d100 delms
inport 4 cogio 2+ W!               \ Set output of cog5 to inchar
h100 inport W!                     \ Clear inchar
1 4 sersetflags
;

\ Stop Communication between PropForth and Processing
\ ( -- )
: stop_I/F 0 4 cogio 2+ W! 4 cogreset ;

\ Transmit data to Processing
\ ( n1 n2 -- ) n1:end addr n2:start addr
: Prop_Tx 
do i C@ 
begin 4 cogio W@ h100 and until    \ Wait until input for serial-cog is under ready-state
4 cogio W!                         \ Write data to cog5's input
loop 
;

\ =============================================================================

\ Start up LS-Y201
\ ( -- )
: init_LS-Y201
c" Tx Rx baud/4 serial" 5 cogx     \ Start serial on cog5
d100 delms
inchar 5 cogio 2+ W!               \ Set output of cog5 to inchar
h100 inchar W!                     \ Clear inchar
1 4 sersetflags
;

\ Stop LS-Y201
\ ( -- )
: stop_LS-Y201 0 5 cogio 2+ W! 5 cogreset ;

\ Tx_common
\ ( -- )
: Transmit
begin 5 cogio W@ h100 and until    \ Wait until input for serial-cog is under ready-state
5 cogio W!                         \ Write data to cog5's input
;

\ Transmit command and data
\ ( n1 -- ) n1:address of command line
: LS-Y201_Tx
0 h56 2 0 do Transmit loop
C@++ bounds do i C@ Transmit loop
;

\ Check if available
\ ( -- n1 ) n1:false if there is data from LS-Y201
: available inchar W@ h100 and ;

\ Receive data and save them in buffer
\ ( n1 -- n2 ) n1:repeat number  n2:last addres+1 of free area 
: LS-Y201_Rx
here W@ swap
0 do
     begin inchar W@ h100 and 0= until       \ Wait until output for serial-cog is under ready-state
     inchar W@ over C!                       \ Save output-data of cog5 to free area
     h100 inchar W!                          \ Clear inchar
     1+                                      \ Increment free space address
loop
;

\ Receive message 
\ ( -- n1 ) n1:last addres+1 of free area 
: MSG_Rx
here W@ 
begin
     begin inchar W@ h100 and 0= until       \ Wait until output for serial-cog is under ready-state
     inchar W@ over C!                       \ Save output-data of cog5 to free area
     h100 inchar W!                          \ Clear inchar
     1+                                      \ Increment free space address
     5 delms available                       
until
here W@ do i C@ emit loop
;

\ =============================================================================
\ Print return code
\ ( n1 -- ) n1:last address 
: retCode here W@ - here W@ swap bounds do i C@ . loop cr ;

\ Reset
\ ( -- )
: resetLS-Y201 
RST LS-Y201_Tx      
5 LS-Y201_Rx 
\ retCode
here W@ - 5 =
if                 
     d3000 delms 
     MSG_Rx                             \ Skip initialization code     
else
     ." Reset fault"
then
cr
;

\ Set chunk size to initial 
\ ( n1 -- )  n1:size
: setChunk
dup
8 rshift JPEG d11 + C!        \ Copy start length(Hi) to JPEG command line 
hFF and JPEG d12 + C!         \ Copy start length(Lo) to JPEG command line
;

\ Start JPGcamera
\ ( -- )
: startJPG
startFlag W@ 0=
if
     init_I/F  
     init_LS-Y201
     resetLS-Y201 
     1 jpgSize W!
     1 startFlag W! 
     chunk setChunk
     d5000 delms 
then
;

\ Stop JPGcamera
\ ( -- )
: stopJPG
stop_I/F
stop_LS-Y201
0 startFlag W! 
." Reset finished!!"
cr
;

\ Change JPEGSIZE
\ Do not disconnect or reset after sending the command, or it will turn back to 320x240
\ ( -- ) jpgSize:0[640x480] 1[320x240] 2[160x120]
: changeSize
jpgSize W@
0 over =
if
     0 JPEGSIZE 3 + C!
else
     1 over =
     if
          h11 JPEGSIZE 3 + C!
thens
drop    
JPEGSIZE LS-Y201_Tx cr
5 LS-Y201_Rx
\ retCode
drop
;

\ Get file size , loop-counter and last chunksize 
\ ( -- )
: getFileSize
\ Get file size
here W@ 7 + dup C@ 8 lshift swap 1+ C@ or filesize W!  
." Read jpeg size" decimal   filesize W@ .
\ Get chunksize and repeat number
filesize W@ chunk u/mod swap remainder W! 
remainder W@ if 1+ then dup . cr  turn W!    \ Set quotient+1 when remainder is not 0
;

\ Set start-address inside LS-Y201-memory to download
\ ( n1 -- )  n1:address 
: setAddr
dup dup                                 \ ( address address address )
8 rshift JPEG 7 + C!                    \ Copy start addr(Hi) to JPEG command line
swap hFF and JPEG 8 + C!                \ Copy start addr(Lo) to JPEG command line
;

\ Change chunk-size if last loop
\ ( n1 -- ) n1:True if last loop
: changeChunkSize
if                     
     ." lastsize" remainder W@ . cr
     remainder W@ dup                   \ Check if remainder is not 0
     if setChunk
\          8 rshift JPEG d11 + C!        \ Copy start length(Hi) to JPEG command line 
\          hFF and JPEG d12 + C!         \ Copy start length(Lo) to JPEG command line
thens
;

\ Set loop conter because reading data from LS-Y201
\ ( n1 -- n2 ) n1:True if last loop   n2:loop counter
: setCounter
if 
     \ Set loop-counter to read data from LS-Y201 on last loop
     remainder W@ dup 
     if d10 + else drop chunk d10 + then
else
     \ Set loop-counter to read data from LS-Y201 
     chunk d10 +   
then                                              
;

\ Send JPEG data to Processing
\ ( n1 -- n2 ) n1:True if last loop  n2:loop counter
: sendToProcessing
if 
     \ Set loop-counter to send data to Processing on last loop
     remainder W@ dup if 5 + else drop chunk 5 + then 
else
     \ Set loop-counter to send data to Processing 
     chunk 5 +
then
;

\ Take a picture
\ ( n1 -- )  n1:last loop if true
: takePicture
\ Start 
START LS-Y201_Tx cr
5 LS-Y201_Rx here W@ - 5 =  
if
     d20 delms                                      
     \ Issue [Read JPEG file size]
     SIZE LS-Y201_Tx 
     9 LS-Y201_Rx here W@ - 9 =
     if
          getFileSize          
          \ Get JPEG file to separate small chunk
          0                                            \ ( address )          
          turn W@ 0 do
               setAddr
               \ Set chunk-size on last loop
               lasti? changeChunkSize                              
               \ Issue [Read JPEG file content]
               JPEG LS-Y201_Tx                               
               here W@                                 \ Set address to save reading data                                                       
               lasti? setCounter 0 do                                      
                    begin inchar W@ h100 and 0= until  \ Wait until output for serial-cog is under ready-state
                    inchar W@ over C!                  \ Save output-data of cog5 to free area
                    h100 inchar W!                     \ Clear inchar
                    1+                                 \ Increment free space address
               loop                   
               drop                                
               \ Send JPEG data to Processing                                                
               lasti? sendToProcessing here W@ + here W@ 5 + Prop_Tx               
               chunk +                                 \ ( address+chunk )
          loop
          drop                                         \ ( -- )              
          d20 delms
          \ Issue [Stop taking picture]
          STOP LS-Y201_Tx 
          5 LS-Y201_Rx here W@ - 5 <>
          if ." Stop error" then
     else
     ." Get file size error"     
     then
else
     ." Take picture error" 
then
chunk setChunk
\ 8 rshift JPEG d11 + C!        \ Copy start length(Hi) to JPEG command line 
\ hFF and JPEG d12 + C!         \ Copy start length(Lo) to JPEG command line
;

\ Send JPEG data to Processing after receiving data from LS-Y201
\ ( -- ) 
: sendPicture
startJPG
changeSize       
d100 delms 
." start" cr
begin
     begin inport W@ h100 and 0= until  \ Wait until any key pressed[Processing]
     inport W@                                                                      
     d65 =                                 
     if
          \ Start [take picture] by JPEG camera
          takePicture
          ." next picture"
          0
     else
          inport W@
          d66 =
          if 1 ." Finished!" else 0 then
     then
     h100 inport W!                     \ Clear inport
     cr
until               
;

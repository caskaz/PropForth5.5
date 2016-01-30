fl

{
12-KeyPad
PropForth 5.5(DevKernel) 

 12-KeyPad     Propeller
    Row1  ----- P8
    Row2  ----- P9
    Row3  ----- P10
  Column1 ----- P11  
  Column2 ----- P12  
  Column3 ----- P13  
  Column4 ----- P14  
    GND   ----- GND
    
2016/01/30 22:52:35
}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Top pin for KeyPad(7 continued pins)
\ from P8 to 14     [Raws from P8 to P10]  [Columns from P11 to P14]
8 wconstant KeyPad
d4000000 constant 50msec

wvariable key_table -2 allot 
d10 c, 0 c, d12 c, 1 c, 2 c, 3 c, 4 c, 5 c, 6 c, 7 c, 8 c, 9 c, 

\ =========================================================================== 
\ Variables 
\ =========================================================================== 
variable lastDebounceTime
wvariable swState
wvariable lastswState
wvariable debounce
wvariable char     
variable buffer 
wvariable pointer  

\ =========================================================================== 
\ Main 
\ =========================================================================== 
\ Set initial
\ ( -- )
: init_sw
\ Set initial values
0 swState W!             
0 lastDebounceTime L!
0 lastswState W!         \ Switch state when no pushing switch
0 debounce W!
;

\ Read current sw-state for 1column
\ ( n1 -- n2 ) n1:top pin number for Row  n2:3bit data
: rd_sw 
7 KeyPad lshift
ina COG@ and KeyPad rshift             
;

\ Read Row1/Row2/Row3 to drive each column
\ ( -- ) 
: swScan
init_sw
begin
     \ Read current sw and check if pushed or released
     rd_sw dup lastswState W@ <>                      
     if
          \ If sw is under debouncong
          debounce W@ 0=
          if
               cnt COG@ lastDebounceTime L!           
               1 debounce W!
          then
     else
          0 debounce W!
     then
     
     debounce W@
     if
          cnt COG@ lastDebounceTime L@ - 50msec >    
          if
               \ Update current swState and lastswState
               dup
               swState W! lastswState W!
               \ Break loop 
               1   
          else
               drop
               \ Continue loop
               0
          then
     else
          drop
          \ Break loop
          1
     then
until
;
 
\ Get 1 character
\ ( -- )
: get1char
\ Set mask for column port to output
hF KeyPad 3 + lshift dira COG!

begin
     \ Scan 3columns 
     KeyPad 3 +
     4 0 do
          dup i + pinhi            \ Activate column port
          \ Read Row-data 
          swScan           
          swState W@ dup            
          if                    
               1 rshift i 3 * + key_table + C@ char W!
               begin swScan swState W@ 0= until
          else
               drop                          
          then 
          dup i + pinlo           \ Deactivate column port
     loop 
     drop                   
\     fkey? swap drop
0 until
;

\ Clear charcter buffer
: charClr d255 char W! ;

\ Print 1 character from 12-KeyPad to TeraTerm
\ ( -- )
: demo1
charClr                                 \ Clear char buffer
c" get1char" 0 cogx

begin                                                    
     char W@ dup d255 <>                \ Check if there is key-input
     if                                                                 
          . cr                          \ Print 1 character
          charClr                       \ Clear char buffer
     else
          drop
     then
     fkey? swap drop
until
0 cogreset
;

\ Print number to enter charcters from 12-KeyPad
\ ( -- )
: demo2
0 buffer L!
0 pointer W!
charClr
c" get1char" 0 cogx

begin
     char W@ dup d255 <>                          \ Key input?
     if
          dup d10 <>                              \ Ignore "Cancel" key
          if
               dup d12 =                          \ Check "Enter"key
               if
                    drop
                    cr buffer L@ . cr
                    0 buffer L!
                    0 pointer W!
                    charClr 
               else
                    dup h30 + emit                \ Print key input
                    pointer W@ 0=
                    if
                         buffer L!
                         1 pointer W!
                    else
                         \ Calculate number
                         buffer L@  d10 *                         
                         + buffer L!
                         pointer W@ 1+ pointer W!     
                    then
                    charClr
               then
          else
               drop
          then
     else
          drop
     then
     fkey? swap drop
until
0 cogreset
;

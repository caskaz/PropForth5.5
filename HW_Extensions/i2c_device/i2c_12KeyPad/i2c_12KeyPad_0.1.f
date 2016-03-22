fl

{                       
PropForth 5.5(DevKernel)

i2c_12-KeyPad by using 8bit I/O ExpanderPCAL9554BPW)
Using i2c_utility_0.4.1.f 
2016/03/21 23:27:26

Propeller        PCAL9554BPW       
SDA     ------     SDA     
SCL     ------     SCL                    -------------------
                    P0 ------------------| Row1              |
                    P1 ------------------| Row2    12-KeyPad |
                    P2 ------------------| Row3              |
                    P3 ------------------| Column1           |
                    P4 ------------------| Column2           |
                    P5 ------------------| Column3           |
                    P6 ------------------| Column4           |
                    A0 --- GND            -------------------
                    A1 --- GND            Row[1..3]:output
                    A2 --- GND            column[1..4]:input
}
\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Slave addres h20 for PCAL9554BPW      
h40 wconstant PCAL9554BPW

\ Top pin for 12KeyPad
0 wconstant KeyPad
hF KeyPad 3 + lshift constant mKeyPad
d4000000 constant 50msec

\ register  
0 wconstant InPort
1 wconstant OutPort
3 wconstant Config
h43 wconstant Pull_u/d_enb
h44 wconstant Pull_u/d_sel

wvariable key_table -2 allot 
d10 c, 1 c, 4 c, 7 c, 0 c, 2 c, 5 c, 8 c, d12 c, 3 c, 6 c, 9 c, 

\ =========================================================================== 
\ Variables 
\ =========================================================================== 
wvariable swState        \ current sw-code
wvariable lastswState    \ last sw-code
wvariable debounce
variable lastDebounceTime
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

\ Read [Column1..Column4] to drive each Row
\ ( -- ) 
: swScan
init_sw
begin
     \ Read current sw and check if pushed or released
     mKeyPad InPort PCAL9554BPW i2c_rd and 3 rshift   \ 4bit-data(Column[1..4])
     dup lastswState W@ <>                      
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
\ [P6 P5 P4 P3]=Intput  [P2 P1 P0]=output
h78 Config PCAL9554BPW i2c_wr
\ Set pulldn resistor [P6..P3]
0 Pull_u/d_sel PCAL9554BPW i2c_wr
h78 Pull_u/d_enb PCAL9554BPW i2c_wr

begin
     \ Scan 3Rows 
     1 KeyPad lshift
     3 0 do
          dup 
          OutPort PCAL9554BPW i2c_wr    \ Activate each Row-pin
          \ Read Column-data 
          swScan           
          swState W@ dup            
          if                                
               1 rshift 
               dup 4 = if drop 3 then   \ [1 2 4 8] -> [0 1 2 3] 
               i 4 * +                  
               key_table + C@ char W!   \ Get key-code
               \ Wait until releasing sw
               begin swScan swState W@ 0= until
          else
               drop                          
          then 
          1 lshift                      \ Next Row pin
     loop 
     drop                   
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


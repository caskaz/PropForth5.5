fl

{
USB Current Monitor 
     
PropForth 5.5

USB-device's current flow throgh resistor(0.1ohm) on USB-Current-monitor board.
Voltage for resister is converted by MCP3204.


USB Current Monitor      Propeller
VDD                 ----  3.3V
GND                 ----  GND

mA/total-ma switch  ----  P1
7SEG-LED a          ----  P2
7SEG-LED b          ----  P3
7SEG-LED c          ----  P4
7SEG-LED d          ----  P5
7SEG-LED e          ----  P6
7SEG-LED f          ----  P7
7SEG-LED g          ----  P8
7SEG-LED dp         ----  P9
7SEG dig1 COM       ----  P10
7SEG dig2 COM       ----  P11
7SEG dig3 COM       ----  P12
current-LED         ----  P13
total-current-LED   ----  P14
MCD3204 CS          ----  P15
MCD3204 Din         ----  P16
MCD3204 CLK         ----  P17
MCD3204 Dout        ----  P18

2013/12/21 12:56:41
}

: USB_Current_Monitor ;
\ =========================================================================== 
\ Constants 
\ =========================================================================== 
1 wconstant sw
1 sw lshift constant _swm
2 wconstant LED_data
d10 wconstant 7SEG_com
d13 wconstant current
d14 wconstant total_current
\ MCP3204
d15 wconstant _cs         
d16 wconstant _do             \ connect to MCP3204's Din         
d17 wconstant _clk          
d18 wconstant _di             \ connect to MCP3204's Dout
1 _di lshift constant _dim
\ 7SEG-LED drive frequency[400Hz]
clkfreq d400 u/ constant 2.5msec
{
7 Segment Font
      P2(a)
      -----
P7(f)|     |P3(b)
     |  P8 |
     |-----|
P6(e)| (g) |P4(c)
     |     |
      -----   * P9(dp)
      P5(d)
}
\ Hex data for 7-Segment Data   (0-9, blank, -)
wvariable SegData -2 allot 
h3F c, h06 c, h5B c, h4F c, h66 c, h6D c, h7D c, h27 c, h7F c, h6F c, h00 c, h40 c,

\ =========================================================================== 
\ Variables
\ =========================================================================== 
\ USB current(bcd)
wvariable value
\ Flag for zero-suppless
wvariable z_supless
\ Temporary when displaying decimal number
wvariable tmp
\ Initial for op-amp
wvariable a/d_initial
\ current mode=1
wvariable mode
\ total current accumlator
variable Ah_sum
wvariable mAsec_sum
\ dot point
wvariable dp

wvariable A/D
wvariable conv_data

\ =========================================================================== 
\ Main 
\ =========================================================================== 
\ MCP3204
: _cs_l _cs pinlo ;
: _cs_h _cs pinhi ;
: _do_l _do pinlo ;
: _do_h _do pinhi ;
: _clk_l _clk pinlo ;
: _clk_h _clk pinhi ;

\ 7-Segment Drive(400Hz)
\ ( -- )
: 7SEG_drive
LED_data d11 0 do dup pinout 1+ loop drop
4 state andnC! c" RUNNING 7SEG_drive" cds W!
begin
     mode W@
     \ current mode [unit:mA]  
     if
          1 z_supless W!     
          cnt COG@ 2.5msec +                                \ ( cnt+2.5msec )
          value W@ hF00                                     \ ( cnt+2.5msec value hF00 )
                                        
          3 0 do                     
               1 i lshift 7SEG_com lshift                   \ LED-digit-common siganal
                                                            \ ( cnt+2.5msec value hF00 digit-common )
               rot2                                         \ ( cnt+2.5msec digit-common value hF00 )
               2dup and 8 i 4 u* - rshift dup               \ ( cnt+2.5msec digit-common value hF00 digitdata digitdata )
               if
                    0 z_supless W!               
               else
                    z_supless W@ 
                    if lasti? 0= if drop d10 then then      \ Replace to blank if not last number
               then
                                                            \ ( cnt+2.5msec digit-common value hF00 digitdata )
               SegData + C@                                 \ Get 7-Segment data 
                                                            \ ( cnt+2.5msec digit-common value hF00 7SEG_data )
               LED_data lshift
               >r rot r> or                                 \ ( cnt+2.5msec value hF00 outa_data )
               0 outa COG! outa COG!                        \ ( cnt+2.5msec value hF00 )
            
               4 rshift                                     \ 4bit shift-mask to right
               rot 2.5msec waitcnt
               rot2
          loop 
          3drop
     \ total-current mode [unit:Ahour]
     else
          cnt COG@ 2.5msec +                                \ ( cnt+2.5msec )
          value W@ hF00                                     \ ( cnt+2.5msec value hF00 )
                                        
          3 0 do                     
               1 i lshift 7SEG_com lshift                   \ LED-digit-common siganal
                                                            \ ( cnt+2.5msec value hF00 digit-common )
               rot2                                         \ ( cnt+2.5msec digit-common value hF00 )
               2dup and 8 i 4 u* - rshift                   \ ( cnt+2.5msec digit-common value hF00 digitdata )
               SegData + C@                                 \ Get 7-Segment data 
               dp W@ i =
               if h80 or then                               \ Add dp
                                                            \ ( cnt+2.5msec digit-common value hF00 7SEG_data )
               LED_data lshift
               >r rot r> or                                 \ ( cnt+2.5msec value hF00 outa_data )               
               0 outa COG! outa COG!                        \ ( cnt+2.5msec value hF00 )            
               4 rshift                                     \ 4bit shift-mask to right
               rot 2.5msec waitcnt
               rot2
          loop 
          3drop          
     then
0 until
;

\ Convert binary to BCD and save bcd in value 
\ ( n1 -- )   n1:binary                                       
: bin_to_bcd
dup 0 >                                           \ Check if n1 is 0
if
     dup d1000 <
     if
          0                                       \ ( n1 bcd )
          d100 tmp W! 
          3 0 do
               4 lshift                           \ ( n1 bcd )  Shift bcd for 4bit to left
               swap                               \ ( bcd n1 )
               dup tmp W@ >=                                
               if                                 \ Check if tmp >= value
                    tmp W@                        \ ( bcd n1 tmp )
                    u/mod                         \ ( bcd remainder quotient )
                    rot or                        \ ( remainder bcd )
               else
                    swap                          \ ( n1 bcd)
               then
               tmp W@ d10 u/ tmp W!               \ Divide tmp by d10
          loop
          nip
          value W!
     else
          drop
          hBBB value W!                           \ Display "---" on 7SEG-LED more than 1000      
     then
else
     value W!
then
;               

\ Convert analog[0-3.3V] to digital[0-4095] 
\ single-end input for MCP3204
\ ( n1 -- n2 )   n1:channel [0 - 3]  n2:data
: get_a/d    
_cs_l  
\ Output control-bits       
h18 or                        \ Add start-bit and single-bit
h10
5 0 do 
     2dup                     \ ( n1+h18 h10 n1+h18 h10 )      
     and 0> 
     if _do_h then
     _clk_h _clk_l 
     1 rshift 
     _do_l           
loop
2drop                                  
_clk_h _clk_l                  \ dummy clock

\ Read conversion-data   
0                              \ initial value
d13 0 do 
     1 lshift
     _clk_h  _clk_l
     ina COG@ _dim and 0> 
     if 1+ then       
loop     
1 rshift
_cs_h
;

\ Read sw
\ When sw is pushed, LED(current & total-current) toggle and value of mode change to 0 or 1.
\ ( -- )
: read_sw
\ Set LED-ports to output
current pinout 
total_current pinout
4 state andnC! c" RUNNING read_sw" cds W!
\ Set current mode
1 mode W!
current pinhi total_current pinlo
begin
     \ sw is high at sw-on
     ina COG@ _swm and
     if   
          begin d10 delms ina COG@ _swm and 0= until
          mode W@ if 0 else 1 then mode W!
          mode W@ 
          if 
               current pinhi total_current pinlo       \ current mode 
          else 
               current pinlo total_current pinhi       \ total-current mode
          then 
     then
\     fkey? swap drop until
0 until
;

\ Monitoring USB-current
\ ( -- )
: USB_current
4 state andnC! c" RUNNING USB-current" cds W!
1 mode W!                               \ current mode
0 Ah_sum L!
0 mAsec_sum W!
hBBB value W!                           \ Display "---" on 7SEG-LED during zero-adjustment
\ Start 7SEG-drive
 c" 7SEG_drive" 0 cogx

\ Setup output-ports [MCP3204]
_cs 3 0 do dup pinout 1+ loop drop
\ Adjustment zero for op-amp
0
d10 0 do
     0 get_a/d + 
     d100 delms
loop
d10 u/ a/d_initial W!
\ Start switch-input
 c" read_sw" 1 cogx

cnt COG@ clkfreq +                     
begin     
     0 
     d10 0 do                           \ average
          0 get_a/d + d10 delms
     loop d10 u/
     a/d_initial W@ - dup 0< 
     if drop 0 then                     \ If a/d-init is <0, replace to 0
     dup A/D W!                         \ Save A/D value
     d1000 u* d4096 u/
     dup conv_data W!                   \ Save conversion data
     dup dup 0> 
     if 
          mAsec_sum W@ + mAsec_sum W!   \ Accumulate current
     else 
          drop 
          0 mAsec_sum W! 0 Ah_sum L!    \ Clear mAh_sum and Ah_sum 
     then                 
     mode W@
     if                                
          bin_to_bcd
     else
          drop
          \ If mAsec_sum is more than d36000[10mA X 3600sec], add 1 to Ah_sum             
          mAsec_sum W@ d36000 >=
          if 
               Ah_sum L@ 1+ Ah_sum L! 
               mAsec_sum W@ d36000 - mAsec_sum W!
          then
          Ah_sum L@
          d99900 over <=
          if drop d1000 3 dp W!         \ more than 1000Ah 
          else d10000 over <= 
          if d100 u/ 3 dp W!            \ more than 100Ah
          else d1000 over <=
          if d10 u/ 1 dp W!             \ more than 10.0Ah
          else d100 over <=
          if 0 dp W!                    \ more than 1.00Ah
          else d10 over <= 
          if 0 dp W!                    \ more than 0.10Ah 
          else 0 dp W! 
          then then then then then
          bin_to_bcd               
     then                
     clkfreq waitcnt                                  
0 until
;

\ Monitor each value
\ ( -- )
: monitor
cnt COG@ clkfreq +
." A/D" 9 emit ." Current[mA]" 9 emit ." Total Current[mAsec]" 9 emit ." Total Current[d100 X Ahour]" cr
0
begin     
     A/D W@ . 9 emit conv_data W@ . 9 emit 9 emit mAsec_sum W@ . 9 emit 9 emit 9 emit Ah_sum L@ . cr
     1+ dup d20 = 
     if
          cr
          ." A/D" 9 emit ." Current[mA]" 9 emit ." Total Current[mA*sec]" cr
          drop 0
     then
     swap
     clkfreq waitcnt
     swap     
     fkey? swap drop
until
2drop
;

\ Automatic operating at power-on
: onreset2 onreset USB_current ;


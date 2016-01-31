fl

{
   2-wire Driver for an HD44780 based LCD Character based display   (Using 4bit control mode)
   Used Shift-register(74HC164)
   
    PropForth 5.5(DevKernel) 
    

     2-wire charLCD curcuit   Propeller
     data                     P4   0x4
     clk                      P5   0x5

 Character-LCD      74HC164                Propeller
                       Vcc  ---5V
                       GND  -------------  GND
                       CLK  -------------  P5 (_clk)
                       A,B  -------------  P4 (_data)
     DB4  ---------    QB          |
     DB5  ---------    QC          |  
     DB6  ---------    QD          | 
     DB7  ---------    QE          |  
     RS   ---------    QF          |
     R/W  ---------    GND         |
     LED+ ------5V              Resistor
                                10k ohm 
              5V                   | 
              |                    |
             10k                   |
              |                    |
LED- ---- C   |                    |                   
            B---C B--- QG          |
          E      E                 |
          |      |                 |
         GND    GND                | 
                       QH---------NP (Silicon diode)
                                   |
      E ----------------------------                        


     2016/01/30 23:55:40
}

\ Serial out data(6bit) to shift-register
\ ( n1 n2 -- )  n1:shift-data n2:_data 
{
lockdict create a_shift_data forthentry
$C_a_lxasm w, h128  h113  1- tuck - h9 lshift or here W@ alignl h10 lshift or l,
z2WyPW1 l, zfiPZB l, z20yPO1 l, z2WyPb1 l, zfiPeB l, z1SyLI[ l, zfyPOP l, z2WyPj8 l,
zgyPO1 l, z1jixZC l, z1[ixZD l, z2WyPrS l, z20iPyk l, z3ryPr0 l, z1bixZD l, z3[yPnR l,
0 l, 0 l, z1[ixZD l, z1SyLI[ l, z1SV01X l,
freedict
}
lockdict create a_shift_data forthentry
$C_a_lxasm w, h128  h113  1- tuck - h9 lshift or here W@ alignl h10 lshift or l,
z2WyPW1 l, zfiPZB l, z20yPO1 l, z2WyPb1 l, zfiPeB l, z1SyLI[ l, zfyPOP l, z2WyPj8 l,
zgyPO1 l, z1jixZC l, z1[ixZD l, z2WyPrS l, z20iPyk l, z3ryPr0 l, z1bixZD l, z3[yPnR l,
0 l, 0 l, z1[ixZD l, z1SyLI[ l, z1SV01X l,
freedict

\ Set shift-register output to zero(7bit)
\ ( n1 -- ) n1:_clk
lockdict create a_clk_out forthentry
$C_a_lxasm w, h11E  h113  1- tuck - h9 lshift or here W@ alignl h10 lshift or l,
z2WyPW1 l, zfiPZB l, z1SyLI[ l, z2WyPb7 l, z1bixZC l, 0 l, 0 l, z1[ixZC l,
0 l, z3[yPfN l, z1SV01X l,
freedict

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ User-defined
4 wconstant _data
5 wconstant _clk

\ CharacterLCD
h10 wconstant RS
h20 wconstant LED-       \ LED off
h40 wconstant E

\ =========================================================================== 
\ Variables 
\ =========================================================================== 
wvariable char           \ character number for using LCD           
wvariable line           \ line number for using LCD
wvariable cur_line       \ current line number

\ Used on word'lcd_dec'
variable tmp
wvariable result     
\ sleep_on flag
wvariable sleep_on

\ =========================================================================== 
\ Command for 74HC164
\ =========================================================================== 
: _data_out_l _data pinlo ;
: _data_out_h _data pinhi ;

\ Send hi-pulse to Enable-pin (Hi-pulse:650nsec)
: lcd_enable _data_out_h _data_out_l ;

\ Send data to shift-register
\ ( n -- )   n:E(bit6) + LED_on(bit5) + RS(bit4) + lcd4bit(bit3-0)
: shift_out _data a_shift_data ;

\ reset shift-register
: reset_sr _clk a_clk_out ;

\ =========================================================================== 
\ Command for LCD 
\ =========================================================================== 
\ Send command to HD44780   
\ (n -- )  n:bit4=RS-bit  bit3-0=LCD-data
: lcd_com
reset_sr                                                      
dup h100 and if RS else 0 then                         \ RS bit
swap 2dup                                              \ ( 10/0 n 10/0 n )
\ upper 4bit
4 rshift hF and or E or                                \ Add RS-bit and Enable-bit
shift_out
lcd_enable                                            
reset_sr    
                                                       
\ lower 4bit                                           \ ( 10/0 n )
hF and or E or                                         \ Add RS-bit and Enable-bit
shift_out 
lcd_enable                                          
reset_sr   

\ Set RS and DB4-DB7 to Hi, and Set LED_on to hi if sleep is inactive
h1F
sleep_on W@ 
if LED- or then                                      \ Add LED_on
shift_out   
;

\ Setup propeller pins and initialize HD44780
\ ( -- )
: lcd_init
\ Set port to output
_data pinout
_clk pinout 
0 sleep_on W!                    
\ Clear shift-register output
reset_sr 

\ 8bit mode
d100 delms                         \ wait 100msec
h43 shift_out
lcd_enable                         \ FunctionSet 
5 delms 
lcd_enable                         \ FunctionSet
1 delms
lcd_enable                         \ FunctionSet 
5 delms
reset_sr                           \ Clear shift-register
 
\ 4bit mode
2 lcd_com
h28 lcd_com                        \ FunctionSet DL=0 N=1 F=0
hC lcd_com                         \ DisplaySwitch D=1 C=B=0
1 lcd_com                          \ ScreenClear
6 lcd_com                          \ InputSet I/D=1 S=0
reset_sr                           \ Clear shift-register
d100 delms
d16 char W! 2 line W!              \ defsult setting is 16Charcters & 2Lines
;

\ Display character  
\ ( c -- )   c:character code     'A'=h41
: lcd_char
h100 or                            \ Add RS=1 to character-code                                
lcd_com
;                                                                           

\ Set position to (x,y)
\ x -- horizontal pos  : 0x1 to 0x28 (decimal: 1 to 40Characters)
\ y -- line number     : 0x1 to 0x4  (decimal: 1 to 4Lines)
\ DDRAM addres of 16X4 CHaracter-LCD
\ 1Line [h00 ------ h0F]
\ 2Line [h40 ------ h4F]
\ 3Line [h10 ------ h1F]
\ 4Line [h50 ------ h5F]
\ ( x y -- )
: lcd_pos
2 u/mod swap 0= 
if 1 =     \ line is even?
     if h40 else char W@ h10 = if h50 else h54 then then
else 0=
     if 0 else char W@ h10 = if h10 else  h14 then then 
then
1- +            
h80 or lcd_com                     \ Add DDRAM Addr command 
;

\ Clear LCD-screen
\ ( -- )
: lcd_clr 1 lcd_com 2 delms ;

\ Setup of display construction  
\ (x y -- )
: lcd_setup line W! char W! ;

\ Display string  
\ ( cstr -- )   cstr:string addr
: lcd_str 
C@++                               \ ( c-addr+1 c1 )  c-addr+1: string's first char addr  c1:string length
dup 
if 
     bounds do i C@ lcd_char loop  \ Print string 
else 
     2drop 
then 
;

\ Print cr
\ ( -- )
: lcd_cr 
cur_line W@ 1+ dup line W@ >            \ Check if current_line+1 is bigger than using LCD-line 
if 
     drop 1 1 lcd_pos 1 cur_line W!     \ Move to lcd's up-left
else 
     dup 1 swap lcd_pos cur_line W!     \ Move to lower line
then 
;

\ Display decimal-number from Left
\ d987654321 lcd_dec --> [987654321]
\ d4321 lcd_dec -------> [4321]
\ (n -- )  n:number
: lcd_dec
0 result W! d1000000000 tmp L!
dup h80000000 and if negate h2D lcd_char then          \ Check if minus and print "-"  
d10 0 do 
     dup tmp L@ >=                                     \ Check if n is bigger than tmp
     if 
          tmp L@ u/mod h30 + lcd_char 1 result W!      \ Print number-char
     else 
          result W@ tmp L@ 1 = or 
          if h30 lcd_char then                         \ Print "0"
     then
     tmp L@ d10 u/ tmp L!                              \ Divide tmp by d10 
loop
drop
;


\ Display decimal-number from Left
\ d1234567890 lcd_dec --> [1234567890]
\ d4321 lcd_dec --------> [4321]
\ Value on LCD is max d2147483647[h7FFFF_FFFF] and min d-2147483647[h8000_0001].
: lcd_hex
dup rot2 8 swap - 2 lshift lshift swap
0 do 
     dup hF0000000 and d28 rshift dup d10 < 
     if 
          h30 +                              \ 0,1,2,3,4,5,6,7,8,9 
     else 
          h37 +                              \ A,B,C,D,E,F
     then 
     lcd_char 
     4 lshift 
loop
drop
;

\ Display binary number 
\ (n1 n2 -- ) n1:number  n2:digits(1 to d32) [32bits is 32-digits(binary)] Digits is limit by using LCD's char
: lcd_bin
dup rot2 h20 swap - lshift swap  
0 do 
     dup h80000000 and 
     if h31 else h30 then      
     lcd_char                 \ Print "1" or "0"
     1 lshift 
loop 
drop
;

\ Print spaces  
\ ( n -- ) n:space's number printing on LCD 
: lcd_bl dup if 0 do bl lcd_char loop else drop then ;

\ LCD Off (not erase display-data)
\ ( -- )
: sleep
1 sleep_on W!        
8 lcd_com                \ display OFF
;
                                                              
\ Wake up LCD
\ ( -- )
: wakeup                 
0 sleep_on W!
hC lcd_com               \ display ON
;

\ =========================================================================== 
\ demo
\ =========================================================================== 
\ Set bar_graph_font(horizontal) to CG-RAM
\ ( -- )
: set_bar_graph
h20 h40
6 0 do                                  \ set 6 charcters
     8 0 do                             \ set 8 lines for 1 character
          dup lcd_com                   \ command for character to CG-RAM
          swap dup lcd_char swap        \ write data
          1+    
     loop
     hF8 and   
     swap dup 1 rshift or swap
loop
2drop
;

: demo1
lcd_init    
\ d16 4 lcd_setup                         \ 16characters 4line
                               
\ display char-code [0x20 - 0x7f] & [0xa0 - 0xff]
h20
line W@ 2 = if 7 0 else 3 0 then
do
     line W@ 2 = 
     if 
          i 3 = 
          if 
               4 seti drop hA0 
          then 
          2 0 
     else 
          4 0 
     then
     do line W@ 4 = 
          if j 1 = 
               if i 2 = 
                    if h20 + 
          thens 
          1 i 1+ lcd_pos d16 0 do dup d100 delms lcd_char 1+ loop                                                         
     loop                                           
loop  
drop

lcd_clr
                                             
\ display binary, hex, decimal
c" 0x1+0x6 = b" lcd_str 1 6 + 4 lcd_bin

1 2 lcd_pos       
c" 0xACE+0xF=0x" lcd_str hACE hF + 4 lcd_hex
5 0 do d1000 delms loop

lcd_clr  1 cur_line W!                               
c" 0x12+0xe0=" lcd_str
h12 hE0 + lcd_dec c" (D)" lcd_str
lcd_cr

c" 0x0-0x12=" lcd_str
0 h12 - lcd_dec c" (D)" lcd_str
5 0 do d1000 delms loop

lcd_clr 1 cur_line W!
d-987654321 lcd_dec
lcd_cr

3 0 do d1000 delms loop

set_bar_graph
lcd_clr  1 cur_line W!                                            
c" Bar Graph" lcd_str 
1    \ x-position 
char W@ 0
do 
     0 
     6 0 do 
          dup lcd_char                  \ Print bar_graph character
           1+ d100 delms  
           swap dup 2 lcd_pos swap      \ Set same x-position                 
     loop 
     drop
     1+ dup 2 lcd_pos                   \ Increment x-position 
loop
drop

char W@ 2 lcd_pos
char W@
char W@ 0
do
     5
     6 0 do 
          dup lcd_char                  \ Print bar_graph character 
          1- d100 delms  
          swap dup 2 lcd_pos swap       \ Set same x-positionap 
     loop 
     drop
     1- dup 2 lcd_pos                   \ Decrement x-position
loop
drop

lcd_clr                                                        
c" Demo Finished" lcd_str
1 2 lcd_pos
hB3 hC4 hDE hB6 hD8 hB1 h20 hC6 hB7 hB5 hB5 d11 0 do lcd_char loop

;


\ Set bar_graph_font(vertical) to CG-RAM
\ ( -- )
: set_bar_graph2
h40
8 0 do                                       \ Set 8 charcters
      8 0 do                                 \ Set 8 lines for 1 character
            dup lcd_com                      \ command for character to CG-RAM 
            \ j:Outer loop index(CG RAM addr)  
            \ i:inner(current) loop index (each line for character)
            7 j - i <
            if h1F else 0 then lcd_char      \ Write data
            1+ 
          loop
          hF8 and
    loop
drop
;


\ Display wave-I         
variable tmp1
: demo2   
lcd_init
\ d16 4 lcd_setup      \ 16characters 4line
 1 delms               
 set_bar_graph2
lcd_clr                                                        
c" Wave" lcd_str
1 2 lcd_pos  

\ tmp:adding value to wave-character-addr(addr 0x0 - addr 0x7 addr 0xFF) for LCD's horizontal derection 
\ tmp1:adding value to wave-character-addr(addr 0x0 - addr 0x7 addr 0xFF) for start-position(1,2)                                                 
1 tmp L! 1 tmp1 L!
cnt COG@
\ Set character on start-position(1,2)
0
d256 0 do
     dup 
     \ Display wave-character for LCD's horizontal derection
     char W@ 0 do 
          dup lcd_char dup 7 = tmp L@ 1 = and 
          if 
               drop hFF
          else 
               dup hFF = 
               if 
                    drop 7 -1 tmp L!    
               else 
                    dup 0 = 
                    if 
                         1+ 1 tmp L!
                    else 
                         tmp L@ + 
          thens                    
     loop
     drop
     
     \ Set next character on start-position(1,2)
     1 2 lcd_pos                                             
     dup 7 = tmp1 L@ 1 = and 
     if 
          drop hFF
     else 
          dup hFF = 
          if 
               drop 7 -1 tmp1 L!                            
          else 
               dup 0 = 
               if 
                    1+ 1 tmp1 L!
               else 
                    tmp1 L@ +
     thens                             
loop
drop 

cnt COG@  
6 1 lcd_pos                                        
swap -    
d80000 u/ lcd_dec c" msec" lcd_str      \ Calculate time[msec]                     
; 


{
\ Send 6bits to shift-register
\ ( n1 n2 -- ) n1:7bits-data  n2:_data 
\ $C_treg1 -- _datam
\ $C_treg2 -- _clkm  
\ $C_treg3 -- loop counter

fl
build_BootOpt :rasm
          \ get _datam
     mov       $C_treg1 , # 1         
     shl       $C_treg1 , $C_stTOS
          \ get _clkm
     add       $C_stTOS , # 1     
     mov       $C_treg2 , # 1     
     shl       $C_treg2 , $C_stTOS
     spop
          \ shift data to left
     shl       $C_stTOS , # d25
          \ set loop-count 4-bit mode
          \ E(1bit) + LED_on(1bit) + RS(1bit) + 4bit + "0"(1bit)
     mov       $C_treg3 , # 8
__1
     shl       $C_stTOS , # 1 wc
          \ set data to Hi/Lo
     muxc      outa , $C_treg1 
          \ clock pulse Lo:500nsec  Hi:200nsec
     andn      outa , $C_treg2
     mov       $C_treg4 , # d28
     add       $C_treg4 , cnt
     waitcnt   $C_treg4 , # 0
     or       outa , $C_treg2
     
     djnz      $C_treg3 , # __1
     nop
     nop
     andn      outa , $C_treg2
         
     spop
     jexit
;asm a_shift_data

\ Send D-FF all output to low
\ ( n1 -- ) n1:_clk
\ $C_treg1 -- _clkm
\ $C_treg2 -- loop counter
fl
build_BootOpt :rasm
     mov  $C_treg1 , # 1
     shl  $C_treg1 , $C_stTOS
     spop
          \ set loop-count  4bit-mode
     mov       $C_treg2 , # 7
__1
          \ pulse width Hi:150nsec  Lo:150nsec
     or        outa , $C_treg1
     nop
     nop
     andn      outa , $C_treg1
     nop
     djnz      $C_treg2 , # __1
     
     jexit     
;asm a_clk_out_4bit

}

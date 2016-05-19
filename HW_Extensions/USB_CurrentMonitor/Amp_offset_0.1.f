fl

{
Get offset(Amp1 and Amp2) for USB-Current-Monitor-II
PropForth5.5

MCD3204
           Din    ----  P0    
           CS     ----  P1
           CLK    ----  P2
           Dout   ----  P3    
         
2014/02/23 21:23:19
}

\ ==================================================================
\ ADC
\ ================================================================== 
\ MCP3204
0 wconstant _do               \ connect to MCP3204's Din         
1 wconstant _cs         
2 wconstant _clk          
3 wconstant _di               \ connect to MCP3204's Dout
1 _di lshift constant _dim

: _cs_l _cs pinlo ;
: _cs_h _cs pinhi ;
: _do_l _do pinlo ;
: _do_h _do pinhi ;
: _clk_l _clk pinlo ;
: _clk_h _clk pinhi ;

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
_clk_h _clk_l                 \ dummy clock

\ Read conversion-data   
0                             \ initial value
d13 0 do 
     1 lshift
     _clk_h  _clk_l
     ina COG@ _dim and 0> 
     if 1+ then       
loop     
1 rshift
_cs_h
;

\ Get offset for ch0/ch1
\ Set 10mV befor executing this word
\ Amp1 10mV X 33 = 0.33V(410digits)
\ Amp2 10mV x 16 = 0.16V(199digits)
\ ( -- )
: get_offset
\ Set pins for ADC to output
_do pinout _cs pinout _clk pinout

\ ch0
0 d100 0 do 0 get_a/d + d50 delms loop 
d100 u/                      
d410 - negate                                      
." ch0_offset:" . cr
\ ch1
0 d100 0 do 1 get_a/d + d50 delms loop  
d100 u/                       
d199 - negate 
." ch1_offset:" . cr
;


fl                                                              
{
Charlieplexing LEDs
Drived 12pcs LEDs by 4-wires
2014/11/01 21:48:06

}

\ =========================================================================== 
\ Constants
\ =========================================================================== 
wvariable dir -2 allot
3 c, 3 c, 6 c, 6 c, hC c, hC c, 5 c, 5 c, hA c, hA c, 9 c, 9 c, 
wvariable out -2 allot
1 c, 2 c, 2 c, 4 c, 4 c, 8 c, 1 c, 4 c, 2 c, 8 c, 1 c, 8 c, 

\ Drived 12pcs LEDs by 4-wires
\ ( -- )
: charlie_LEDs
begin
     dir out
     d12 0 do
          2dup
          C@ outa COG!
          C@ dira COG!
          1+ swap 1+ swap
          d100 delms
     loop
     2drop
     fkey? swap drop
until
0 dira COG!
;





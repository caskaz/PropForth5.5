fl

{
PropForth5.5(DevKernel)

Switch Input
2015/10/06 15:47:58

                       
                3V3
                 |
                10kohm
                 |
      P14 -------|
                 |
                sw
                 |
                GND
                
              |\|
      P15 ----| | ----220ohm---GND  
              |/| 
              LED           
}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
d14 wconstant swpin
d15 wconstant ledpin
d4000000 constant 50msec
swpin >m constant swMask
ledpin >m constant ledMask

\ =========================================================================== 
\ Variables 
\ =========================================================================== 
wvariable swState
wvariable debounce
wvariable lastswState
variable lastDebounceTime
wvariable alternate

\ =========================================================================== 
\ Main
\ =========================================================================== 

\ read current sw-state
\ ( -- n1 ) n1:1[sw:off] 0[sw:on]
: rd_sw ina COG@ swMask and if 1 else 0 then ;


: init
\ Set initial values
1 swState W!
0 lastDebounceTime L!
1 lastswState W!
0 debounce W!
    
ledMask dira COG@ or dira COG!     \ Set led to uutput
;

\ On/Off switch
\ LED on when pushed sw, LED off when release sw
\ ( -- )
: sw1
init
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
          else
               drop
          then
     else
          drop
     then
                        
     \ Activate LED when sw-on
     outa COG@ ledMask 
     swState W@                    
     if invert and else or then              
     outa COG!     
          
     fkey? swap drop
until
;     

\ Alternative switch
\ Switching LED on/off when pushed sw
\ ( -- )
: sw2
init
1 alternate W!   
ledMask dira COG@ or dira COG!     \ Set led to uutput

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
               \ Treat only when pushed switch
               lastswState W@ 
               if                    
                    lastswState W!                               \ Update current lastswState
                    alternate W@ if 0 else 1 then swState W!     \ Set swState  
                    alternate W@ if 0 else 1 then alternate W!   \ set alternate
               else
                    lastswState W!                               \ Update current lastswState
               then
          else
               drop
          then
     else
          drop
     then
                        
     \ Activate LED when sw-on
     outa COG@ ledMask 
     swState W@                 
     if invert and else or then              
     outa COG!     
          
     fkey? swap drop
until
;     

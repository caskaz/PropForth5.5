fl

{
PropForth5.5(DevKernel)

Switch Input
2017/07/30 21:21:44

                       
                3V3
                 |
                10kohm
                 |
       P0 -------|
                 |
                sw
                 |
                GND
                
              |\|
       P1 ----| | ----220ohm---GND  
              |/| 
              LED           
}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
0 wconstant swpin
1 wconstant ledpin
d800000 constant 10msec
swpin >m constant swMask
ledpin >m constant ledMask

\ =========================================================================== 
\ Variables 
\ =========================================================================== 
variable DebounceTime
wvariable swState
wvariable debounce
wvariable alternate

\ =========================================================================== 
\ Main
\ =========================================================================== 

\ read current sw-state
\ ( -- n1 ) n1:true[sw:off] false[sw:on]
: rdSw ina COG@ swMask and ;

\ Initialize sw and led
\ ( -- )
: init
\ Set initial values
swMask swState W!
0 debounce W!
\ Set led to output   
ledMask dira COG@ or dira COG!                    
;

\ On/Off switch
\ LED on when pushed sw, LED off when release sw
\ ( -- )
: sw1
init
begin
     \ Check if during debounce
     debounce W@                        
     if
          \ Check if exceeding 10msec
          cnt COG@ DebounceTime L@ - 10msec >
          if               
               rdSw dup swState W@ <> 
               if 
                    swState W!               \ Update swState if sw-status change
               else 
                    drop                     
               then  
               0 debounce W!                 \ Clear debounce
          then
     else
          rdSw swState W@ <>               
          if
               1 debounce W!                 \ Set debounce
               cnt COG@ DebounceTime L!      \ Set DebounceTime    
          then
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

begin
     \ Check if during debounce
     debounce W@                        
     if
          \ Check if exceeding 10msec
          cnt COG@ DebounceTime L@ - 10msec >
          if               
               rdSw dup swState W@ <> 
               if 
                    dup 0=
                    if
                         \ Invert alternate when sw change from Hi(sw-off) to Lo(sw-on)
                         alternate W@ if 0 else 1 then 
                         alternate W! 
                    then
                    \ Update swState when sw-status change
                    swState W!
               else
                    drop
                    0 debounce W!            \ Clear debounce
               then
          then
     else
          rdSw swState W@ <>               
          if
               1 debounce W!                 \ Set debounce
               cnt COG@ DebounceTime L!      \ Set DebounceTime    
          then
     then
                             
     \ Activate LED when sw-on
     outa COG@ ledMask 
     alternate W@                 
     if invert and else or then              
     outa COG!     
          
     fkey? swap drop
until
;     

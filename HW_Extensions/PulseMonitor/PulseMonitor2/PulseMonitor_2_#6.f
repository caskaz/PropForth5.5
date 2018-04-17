fl

{
PropForth 5.5(DevKernel)
PulseMonitor

2018/04/17 20:22:14

}                                                

\ ==================================================================
\ Main
\ ================================================================== 
\ Start PulseMonitor(ADC,LCD,pulse,printer)
\ ( -- )
: PulseMonitor
initSW                                  \ Initilaze SW
\ Initialize printer                                                                                                       
initSerial
init_prt
setup                                  

1 lcdActive W!
0 secondDeriva W!
0 stopPulse W!
c" lcd" 5 cogx
c" GetPulse" 3 cogx
d100 delms

begin     
     mode?                              \ Mode sw?
     pulseValue W@ 0<> and              \ pulse is not 0
     if 
          1 stopPulse W!                \ Save pulseValue to currentPulse  (Using on only 'GetPulse')
          0 lcdActive W!                \ Stop drawing LCD on Cog5
          noSensedSW                                                       
          \ Print pulse wave if print-sw is pushed
          begin
               prtSW?
               if
                    printTime printPulse printWave d1000 delms 1 
               else
                    mode? if 1 else 0 then   \ Break if mode sw is pushed
               then
          until
          noSensedSW
          \ Caluculate SDPPG(second derivative of photoplethysmogram) and print SDPPG
          detectRange 0=                                                   
          if                                                                  
               convA/D                                              
               \ Calculate derivative
               Derivative                              \ First derivative
               Derivative                              \ Second derivative
               searchMaxMin
               2dup                                    \ ( n1 n2 n1 n2 )
               convF>I                                 \ ( n1 n2 )
               \ Erase screen on LCD                
               0 fullScrn 0 fullScrn                                       
               \ Display derivative wave on LCD
               calcAge
               if
                    1 secondDeriva W!                  \ Allow second dispaying derivative graph and age
                    begin
                         prtSW?
                         if
                              d16 font_size c" SDPPG" prt_str linefeed 
                              8 font_size c" Age of Man:" prt_str manAge W@ printNum linefeed
                              c" Age of Woman:" prt_str womanAge W@ printNum linefeed
                              small_char
                              c" a:" prt_str a L@ printCoef 
                              c" b:" prt_str b L@ printCoef 
                              c" c:" prt_str c L@ printCoef 
                              c" d:" prt_str d L@ printCoef 
                              c" e:" prt_str e L@ printCoef linefeed linefeed
                              printWave d1000 delms 
                              linefeed linefeed
                              1 
                         else
                              mode? if 1 else 0 then   \ Break if mode sw is pushed
                         then
                    until
                    noSensedSW
                    0 secondDeriva W!                  \ Inhibit second dispaying derivative graph and age   
               then                       
          else
               2drop
          then    
          1 lcdActive W!                               \ Restart updating lcd
     then
0 until     
{
     fkey? swap drop
until            
3 cogreset   
5 cogreset  
stopSerial
}
;

\ Boot after Power-on
: onreset2 onreset PulseMonitor ;


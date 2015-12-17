fl

{
WS2822
      
PropForth 5.5
2015/07/22 22:14:54

     P0 ----------------------------------
                    |                     |
                    |  WS2822(L)          |  WS2822(R)
                   -----------           -----------
                  |DAI        |         |DAI        |
                  |           |         |           |
     P1 ----------|ADRI   ADRO|-------- |ADRI   ADRO|
                  |           |         |           |
                  |VCC VDD GND|         |VCC VDD GND|
                   ------------          ------------
                    |   |   |             |   |   |
                    5V  5V GND            5V  5V GND
                    
This code is for WS2822[1024pcs]. 

Execute code below before loading this;
1. Executing 'reboot'
2. variable WS2822 here W@ d3068 + here W! 
                     
}


\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ data pin
0 wconstant data 
\ address pin
1 wconstant addr 
\ MAX LEDs 1024pcs
2 wconstant LEDs
\ buffer size [WS2822:5pcs)
d3072 wconstant buf_size
\ Address structure
wvariable Addr_struct -2 allot
0 w,                          \ LEDs
0 c,                          \ WS2822's address pin
hF0 c, hE1 c, hD2 c, hC3 c, hB4 c, hA5 c, h96  c, h87 c, h78 c, h69 c, h5A c, h4B c,  \ Channel value 

\ =========================================================================== 
\ Variables 
\ =========================================================================== 
\ LED-array for WS2822 (3bytes/1LED)  
\ variable WS2822 buf_size 4 - allot     \ 5 LEDs

\ =========================================================================== 
\ Main 
\ =========================================================================== 
\ Set address
\ ( n1 n2 -- ) n1:WS2822's channel[1,2,..,3072] n2:Address structure
lockdict create a_setAddr forthentry
$C_a_lxasm w, h149  h113  1- tuck - h9 lshift or here W@ alignl h10 lshift or l,
z4ibuB l, z20yPO2 l, ziPZB l, z2Wybb1 l, zfibeC l, z1bix\5 l, z1bixo5 l, z20yPO1 l,
z2WibmB l, z1SyLI[ l, z2WyPWM l, z1SyaSr l, z3[yP[U l, z2WiP\8 l, z1[ix\5 l, z1SyaSr l,
z3[yP[Y l, z2WyPWM l, z1bix\5 l, z1SyaSr l, z3[yP[] l, z2WyPb0 l, z1Syb[v l, z2WiPeB l,
z1WyPey l, z1Syb[v l, z2WiQ3B l, zbyQ08 l, z20iQ56 l, ziPeG l, z1Syb[v l, z2WyPeI l,
z1Syb[v l, z20yPO3 l, z3[ybvd l, z1SyLI[ l, z1SV01X l, z2WyPne l, z20iPqk l, z3ryPj0 l,
z1SV000 l, zfyPb2 l, z1byPb3 l, zfyPbL l, z2WyPrB l, zgyPb1 l, z1jix\5 l, z1SyaSr l,
z3[yPw0 l, z1SV000 l, 0 l, 0 l, 0 l, zJY l,
freedict

\ Set address to WS2822
\ ( n1 n2 n3 n4  -- ) 
\ n1:Address structure  
\ n2:WS2822's start address [0,1,2,..,1023] 
\ n3:WS2822's address pin 
\ n4:LEDs
\ Sample -> Addr_struct 0 addr LEDs setAddr  (WS2822 address:0,1 address pin:1 LED pcs:2)
\ Addr_struct 1 addr LEDs setAddr  (WS2822 address:1=channnel:4)
: setAddr 
Addr_struct W!           \ Set LED pcs
Addr_struct 2+ C!        \ Set address pin
3 * 1+ swap a_setAddr    \ address[0,1,..,1023] -> channel[1,4,7,..,3070]
;

{
\ Wave-check for address-setting
\ Setting channel-4 and channel-7
\ ( -- )
: test
2 Addr_struct W!           \ Set LED pcs
1 Addr_struct 2+ C!        \ Set address pin
begin
 1 Addr_struct a_setAddr 
fkey? swap drop until
;
}



\ Send data
\ ( n1 n2 n3 -- ) n1:buffer address n2:buffer size  n3:serial-out port for data
lockdict create a_sendData forthentry
$C_a_lxasm w, h13E  h113  1- tuck - h9 lshift or here W@ alignl h10 lshift or l,
z2WyaW1 l, zfiaZB l, z1bix[v l, z1bixnv l, z1SyLI[ l, z2WiaeB l, z1SyLI[ l, z2WyPWM l,
z1bix[v l, z1Sy]Ki l, z3[yP[S l, z2WyPWM l, z1[ix[v l, z1Sy]Ki l, z3[yP[W l, z1bix[v l,
z1Sy]Ki l, z1Sy]Ki l, z1Sy]Ki l, z2WyPb0 l, z1SyaSm l, z2WiPvw l, z2WiQ3B l, ziPeG l,
z1SyaSm l, z20yQ01 l, z3[yPvd l, z1SV04Q l, z2WyPne l, z20iPqk l, z3ryPj0 l, z1SV000 l,
zfyPb2 l, z1byPb3 l, zfyPbL l, z2WyQ8B l, zgyPb1 l, z1jix[v l, z1Sy]Ki l, z3[yQCq l,
z1SV000 l, 0 l, 0 l,
freedict

\ Display WS2822 from address0 to address3(from channel-1 to channel-9).
\ LED(L) is set to address0(channel-1), LED(R) is set to address0(channel-4)
\ ( -- )
: demo
\ Clear WS2822 buffer 
0 WS2822 buf_size 0 do 2dup C! 1+ loop 2drop
                                                 
c" WS2822 buf_size data a_sendData" 0 cogx                   

begin
     WS2822  
     9 0 do
          dup . cr
          dup d255 swap C!       
          d500 delms
          dup 0 swap C!
          1+          
     loop
     drop                        
     fkey? swap drop
until
0 cogreset
;
                   

\ On & off channel
\ ( n1 -- ) n1:channel number[1 - 3072]
: on-off 1- dup WS2822 + 255 swap C! d1000 delms WS2822 + 0 swap C! ;

\ On channel
\ ( n1 -- ) n1:channel number[1 - 3072]
: on 1- WS2822 + 255 swap C! ;

\ Off channel
\ ( n1 -- ) n1:channel number[1 - 3072]
: off 1- WS2822 + 0 swap C! ;

\ Test LED(BGR) by address number
\ ( n1 -- ) n1:address number
: addr_LED_on 3 * 1+ dup on-off 1+ dup on-off 1+ on-off ;

{
\ Set address
\ ( n1 n2 -- ) n1:WS2822's channel[1,2,..,3072] n2:Address structure
\ $C_treg1:delay counter
\ $C_treg2:Transmit-data
\ $C_treg3:4usec ticks
\ $C_treg4:transmit bit counter
\ $C_treg5:address for Channel value table

fl
build_BootOpt :rasm
          \ Get LEDs
          rdword    __num , $C_stTOS
          add       $C_stTOS , # 2
          rdbyte    $C_treg1 , $C_stTOS
          \ Set port to output and to hi
          mov       __addrmask , # 1
          shl       __addrmask , $C_treg1
          or        outa , __addrmask
          or        dira , __addrmask
          \ Get address for Channel value table
          add       $C_stTOS , # 1
          mov       __ch_value , $C_stTOS
          spop
          
          mov       $C_treg1 , # d22
__MTBP
          jmpret    __4usecret , # __4usec
          djnz      $C_treg1 , # __MTBP
          
          mov       $C_treg1 , __5msec
          \ Set __addrmask to lo
          andn      outa , __addrmask
__BREAK
          jmpret    __4usecret , # __4usec
          djnz      $C_treg1 , # __BREAK

          mov       $C_treg1 , # d22
          \ Set __addrmask to hi
          or        outa , __addrmask
__MAB
          jmpret    __4usecret , # __4usec
          djnz      $C_treg1 , # __MAB
          
          \ channe0[SC(StartCode)]
          mov       $C_treg2 , # 0
          jmpret    __transmitret , # __transmit
__loop    
          \ channel[1+m] address-data
          mov       $C_treg2 , $C_stTOS
          and       $C_treg2 , # hFF
          jmpret    __transmitret , # __transmit

          \ channel[2+m]
          mov       $C_treg5 , $C_stTOS
          \ Get index for framewidth
          shr       $C_treg5 , # 8            
          add       $C_treg5 , __ch_value
          \ Get framewidth channel[2+m]
          rdbyte    $C_treg2 , $C_treg5
          jmpret    __transmitret , # __transmit
          
          \ channel[3+m]
          mov       $C_treg2 , # hD2
          jmpret    __transmitret , # __transmit
          
          \ Next address data
          add       $C_stTOS , # 3
          djnz      __num , # __loop
          spop
          jexit

\ Delay 4usec
__4usec
          \ 5+(312-18)=299
          mov       $C_treg3 , # d299
          add       $C_treg3 , cnt
          waitcnt   $C_treg3 , # 0                               
__4usecret
          ret

\ Transmit 11bit     
\ start bit[4usec] + 8bit[32usec] + stop bit[8usec]
__transmit
          \ Add stop bit
          shl       $C_treg2 , # 2
          or        $C_treg2 , # 3
          shl       $C_treg2 , # d21
          mov       $C_treg4 , # d11
__transmit1
          shl       $C_treg2 , # 1 wc
          muxc      outa , __addrmask
          jmpret    __4usecret , # __4usec
          djnz      $C_treg4 , # __transmit1
__transmitret
          ret


\ variables
__addrmask
     0
__ch_value
     0
__num
     0

\ constants
__5msec
     d1250
               
;asm a_setAddr
}

{
\ Send data
\ ( n1 n2 n3 -- ) n1:buffer address n2:buffer size n3:serial-out port for data
\ $C_treg1:delay counter
\ $C_treg2:Transmit-data
\ $C_treg3:4usec ticks
\ $C_treg4:LEDs counter
\ $C_treg5:buffer address
\ $C_treg6:transmitt bit counter
\ $C_stTOS:buffer address

fl
build_BootOpt :rasm
          \ Set port to output and to hi
          mov       __datamask , # 1
          shl       __datamask , $C_stTOS
          or        outa , __datamask
          or        dira , __datamask
          spop
         
          mov       __num , $C_stTOS
          spop       
          
__Main          
          mov       $C_treg1 , # d22
          \ Set __datamask to hi
          or        outa , __datamask
__MTBP
          jmpret    __4usecret , # __4usec
          djnz      $C_treg1 , # __MTBP
          
          mov       $C_treg1 , # d22
          \ Set __datamask to lo
          andn      outa , __datamask
__BREAK
          jmpret    __4usecret , # __4usec
          djnz      $C_treg1 , # __BREAK

\ __MAB
          \ Set __datamask to hi
          or        outa , __datamask
          jmpret    __4usecret , # __4usec
          jmpret    __4usecret , # __4usec
          jmpret    __4usecret , # __4usec

          \ channe0[SC(StartCode)]
          mov       $C_treg2 , # 0
          jmpret    __transmitret , # __transmit
          
          mov       $C_treg4 , __num
          mov       $C_treg5 , $C_stTOS
__loop    
          \ channel[m] address-data
          rdbyte    $C_treg2 , $C_treg5
          jmpret    __transmitret , # __transmit
          \ Increment buffer address
          add       $C_treg5 , # 1
          djnz      $C_treg4 , # __loop
                    
          jmp # __Main

\ Delay 4usec
__4usec
          \ 5+(312-18)=299
          mov       $C_treg3 , # d299
          add       $C_treg3 , cnt
          waitcnt   $C_treg3 , # 0                               
__4usecret
          ret

\ Transmit 11bit     
\ start bit[4usec] + 8bit[32usec] + stop bit[8usec]
__transmit
          \ Add stop bit
          shl       $C_treg2 , # 2
          or        $C_treg2 , # 3
          shl       $C_treg2 , # d21
          mov       $C_treg6 , # d11
__transmit1
          shl       $C_treg2 , # 1 wc
          muxc      outa , __datamask
          jmpret    __4usecret , # __4usec
          djnz      $C_treg6 , # __transmit1
__transmitret
          ret

\ variables
__datamask
     0
__num
     0

;asm a_sendData
}

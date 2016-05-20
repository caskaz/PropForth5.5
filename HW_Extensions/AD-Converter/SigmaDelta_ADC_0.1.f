fl

{
PropForth 5.5(DevKernel)

SigmaDelta A/D-Converter
2016/05/20 15:55:58


                  3V3
                   |
                  1nF                               3V3
                   |                                 |
APIN------------|--|---Ra----Analog input--------VR(10kohm)
BPIN---100kohm--|  |                                 |
                  1nF                               GND
                   |
                  GND          Ra=67kohm+2.7kohm
                               Curcuit must not use BreadBoard.
                               
Caution;
APIN and BPIN is away as possible as
Cannot convert all range
When Ra=150kohm, volt-range us from 64mV to 1.8V
When Ra=(67kohm+2.7kohm), volt-range us from 20mV to 2.4V
When Ra=56kohm, volt-range us from 1.2V to 1.5V

}

\ ==================================================================
\ Constants
\ ================================================================== 
\ Using pin
0 wconstant adcpin
7 wconstant fbpin

\ ==================================================================
\ Variables
\ ================================================================== 
variable result
variable MIN
variable MAX

\ ==================================================================
\ Main
\ ================================================================== 

\ ( n1 n2 n3 n4 -- )  n1:result address  n2:interval n3:fbpin  n4:adcpin
lockdict create a_SigmaDelta forthentry
$C_a_lxasm w, h12E  h113  1- tuck - h9 lshift or here W@ alignl h10 lshift or l,
z2Wy\G1 l, zfi\JB l, z1Giy3B l, z1SyLI[ l, z2Wy\O1 l, zfi\RB l, z1Kiy3B l, z2Wixne l,
z1SyLI[ l, z2Wi\ZB l, z1SyLI[ l, z2Wi\eB l, z1SyLI[ l, z1Oyy18 l, z2WyyG1 l, z2WiP[f l,
z20iPak l, z3riP[f l, z2WiPiv l, z24iPeE l, z20iPmD l, z8FPfg l, z1SV04[ l, 0 l,
0 l, 0 l, 0 l,
freedict

: test1 
c" result d16384 7 0 a_SigmaDelta" 0 cogx 
begin 
     result L@ . cr      \ Display A/D conversion value 
     fkey? swap drop
until
0 cogreset 
; 


: demo1
\ c" result d16384 fbpin adcpin a_SigmaDelta" 0 cogx
result L@ dup dup . MIN L! MAX L!
d100 0 do                                                
     result L@ dup .     \ Display A/D conversion value 
     dup MIN L@ <
     if
          MIN L!
     else
          dup MAX L@ >
          if
               MAX L!
          else
               drop
     thens
loop
cr
." MIN:" MIN L@ . ." MAX:" MAX L@ . cr
MAX L@ MIN L@ - d10000 * d16384 / 
d100 u/mod h30 + emit
h2E emit
d10 u/mod h30 + emit
h30 + emit
h25 emit 
cr
0 cogreset
;

: test2 
c" result d4096 7 0 a_SigmaDelta" 0 cogx 
begin 
     result L@ . cr      \ Display A/D conversion value 
     fkey? swap drop
until
\ 0 cogreset 
; 

: demo2
\ c" result d4096 fbpin adcpin a_SigmaDelta" 0 cogx
result L@ dup dup . MIN L! MAX L!
d100 0 do                                                
     result L@ dup .     \ Display A/D conversion value 
     dup MIN L@ <
     if
          MIN L!
     else
          dup MAX L@ >
          if
               MAX L!
          else
               drop
     thens
loop
cr
." MIN:" MIN L@ . ." MAX:" MAX L@ . cr
MAX L@ MIN L@ - d10000 * d4096 / 
d100 u/mod h30 + emit
h2E emit
d10 u/mod h30 + emit
h30 + emit
h25 emit 
cr
\ 0 cogreset
;

: tab 9 emit ;

\ Compare D/A output and SigmaDelta ADC
\ Needing i2c_utility_0.4.1.f and MCP4725_0.2.f
\ ( -- )
: test5
c" result d16384 7 0 a_SigmaDelta" 0 cogx
d4096 0 do
     i d30 u/mod drop 0=
     if 
     ." D/A output" tab  ." sigma delta ADC" cr
     then
     tab
     i dup . normal DAC_out
     d100 delms
     tab tab
     result L@  4 / .  cr                  
loop
0 cogreset
;


{
SampleInterval     SampleRate           SampleTime
h1F(32)             2.5MHz(80MHz/32)    400nsec
h3F(64)             1.25MHz             800nsec
h7F(128)            625kHz              1.6usec
hFF(256)            313kHz              3.2usec
h1FF(512)           156kHz              6.4usec
h3FF(1024)           78kHz              12.8usec
h7FF(2048)           39kHz              25.6usec
hFFF(4096)           19.5kHz            51.2usec
h1FFF(8192)          9.77kHz            102.4usec
h3FFF(16384)         4.88kHz            204.8usec
h7FFF(32768)         2.44kHz            409.6usec
hFFFF(65536)         1.22kHz            819.2usec

fl
h1F8	wconstant ctra
h1FA	wconstant frqa 
h1FC	wconstant phsa 
\ $C_treg1:ADC value
\ $C_treg2:previous ADC value
\ sigma-delta A/D conversion
\ ( n1 n2 n3 n4 -- )  n1:result address  n2:interval n3:fbpin  n4:adcpin
build_BootOpt :rasm
               \ get adcpin mask
          mov       __adcpin , # 1
          shl       __adcpin , $C_stTOS
          movs      ctra , $C_stTOS
          spop
               \ get fbpin mask
          mov       __fbpin , # 1
          shl       __fbpin , $C_stTOS
          movd      ctra , $C_stTOS
          mov       dira , __fbpin
          spop
               \ get interval
          mov       __interval , $C_stTOS
          spop
               \ get A/D result address
          mov       __result , $C_stTOS
          spop
                
          movi      ctra , # h48          
          mov       frqa , # 1
          
          mov       $C_treg1 , __interval  
          add       $C_treg1 , cnt
__1
          waitcnt   $C_treg1 , __interval
          mov  $C_treg2 , phsa
          sub  $C_treg2 , $C_treg3
          add  $C_treg3 , $C_treg2 
          wrlong    $C_treg2 , __result
          jmp # __1

__adcpin
     0
__fbpin
     0
__interval
 0
__result
 0

;asm a_SigmaDelta		

          
}

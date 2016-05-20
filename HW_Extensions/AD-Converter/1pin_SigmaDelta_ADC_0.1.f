fl

{
PropForth 5.5(DevKernel)

1pin SigmaDelta A/D-Converter
Translated [Single Pin Sigma Delta Driver v1 by Beau Schwabe ] to PropForth5.5

2016/05/20 21:16:46

                                               3V3
                                                |
   PIN--------- 2.2kohm----Analog input--------VR(10kohm)
           |                                    |
           |                                   GND
          1kohm
           |       
         0.047uF             Curcuit must not use BreadBoard.
           |
          GND
Conversion range is from 120mV to 2.3V.
                  
}
\ ==================================================================
\ Constants
\ ================================================================== 
0 wconstant 1pin_adc

\ ==================================================================
\ Variables
\ ================================================================== 
variable result
variable MIN
variable MAX

\ ==================================================================
\ Main
\ ================================================================== 
\ 1pin sigma-delta A/D conversion
\ ( n1 n2 n3 -- )  n1:result address  n2:interval n3:adcpin
lockdict create a_1pinSigmaDelta forthentry
$C_a_lxasm w, h129  h113  1- tuck - h9 lshift or here W@ alignl h10 lshift or l,
z2Wy[j1 l, zfi[mB l, z1[ixn] l, z1SyLI[ l, z2Wi[uB l, z1SyLI[ l, z2Wi\3B l, z1SyLI[ l,
z2WyPb0 l, z2WiP[a l, z1YF[ql l, z1rix[] l, z1bixn] l, 0 l, z1[ixn] l, z20oPb1 l,
z3[yP[T l, z8FPfb l, z1SV04R l, 0 l, 0 l, 0 l,
freedict

\ Display ADC value
\ ( -- )
: 1pin_test 
c" result d16384 1pin_adc a_1pinSigmaDelta" 0 cogx 
begin 
     result L@ . cr      \ Display A/D conversion value 
     fkey? swap drop
until
0 cogreset 
; 

: demo
\ c" result d16384 1pin_adc a_1pinSigmaDelta" 0 cogx
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
\ 0 cogreset
;

: tab 9 emit ;

\ Compare D/A output and 1pin SigmaDelata ADC
\ Needing i2c_utility_0.4.1.f and MCP4725_0.2.f
\ ( -- )
: test
c" result d16384 1pin_adc a_1pinSigmaDelta" 0 cogx 
d4096 0 do
     i d30 u/mod drop 0=
     if 
     ." D/A output" tab  ." 1pin SigmaDelata ADC" cr 
     then
     tab
     i dup . normal DAC_out
     d100 delms
     tab tab
     result L@ 4 /  . cr
loop
0 cogreset 
;



{
fl
\ $C_treg1:interval
\ $C_treg2:ADC value
\ 1pin sigma-delta A/D conversion
\ ( n1 n2 n3 -- )  n1:result address  n2:interval n3:adcpin
build_BootOpt :rasm
          mov       __adcpin , # 1
          shl       __adcpin , $C_stTOS
          \ Set ADC pin to an input
          andn      dira , __adcpin 
          spop
          mov       __interval , $C_stTOS
          spop
          mov       __result , $C_stTOS
          spop
__1
          \ Clear ADC_value
          mov       $C_treg2 , # 0   
          mov       $C_treg1 , __interval 
__2
          \ Read ADC pin
          test      __adcpin , ina wz 
          \ Preset ADC pin to opposite state of ADC pin reading        
          muxz      outa , __adcpin
          \ Set ADC pin to an output         
          or        dira , __adcpin
          \ small delay for charging/discharging
          nop
          \ Set ADC pin to an input
          andn      dira , __adcpin
          \ Increment ADC_accumulator only if cap needed charging
if_nz     add       $C_treg2 , # 1 
          \ next loop
          djnz      $C_treg1 , # __2
          
          \ write ADC value to Hub ram 
          wrlong    $C_treg2 , __result         
          \ next ADC
          jmp       # __1
          
__adcpin
     0
__interval
 0
__result
 0

;asm a_1pinSigmaDelta		
}

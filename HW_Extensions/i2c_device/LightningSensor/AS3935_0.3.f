fl
{                       
PropForth 5.5(DevKernel)

Franklin Lightning Sensor Module(AE-AS3935)
Using i2c_utility_0.4.2.f 
2016/06/06 12:11:56

Franklin Lightning Sensor Module       Propeller
                   (AE-AS3935)
                         SDA     ------  SDA
                         SCL     ------  SCL
                         IRQ     ------  P0
                   GND - A0   
                   GND - A1   
                         Vdd     ------ 3.3V
                         GND     ------ GND
}


\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Slave addres 0 for AS3935 
0 wconstant AS3935
0 wconstant IRQ
IRQ >m constant mIRQ

\ register
0 wconstant reg0    \ Reserved[7:6] AFE_GB[5:1] PWD[0]
1 wconstant reg1    \ Reserved[7] NF_LEV[6:4] WDTH[3:0]
2 wconstant reg2    \ Reserved[7] CL_STAT[6] MIN_MUM_LIGH[5:4] SREJ[3:0]
3 wconstant reg3    \ LCO_FDIV[7:6] MASK_DIST[5] Reserved[4] INT[3:0] 
4 wconstant reg4    \ S_LIG_L[7:0]
5 wconstant reg5    \ S_LIG_M[7:0]
6 wconstant reg6    \ Reserved[7:5] S_LIG_MM[4:0]
7 wconstant reg7    \ Reserved[7:6] DISTANCE[5:0]
8 wconstant reg8    \ DISP_LCO[7] DISP_SRCO[6] DISP_TRCO[5] Reserved[4] TUN_CAP[3:0]
\ 9 -h32 Lightning Detection Look-up table
h3A wconstant reg58 \ TRCO_CALIB_DONE[7] TRCO_CALIB_NOK[6] Reserved[5:0]
h3B wconstant reg59 \ SRCO_CALIB_DONE[7] SRCO_CALIB_NOK[6] Reserved[5:0]
h3C wconstant reg60 \ Preset Default
h3D wconstant reg61 \ Calib_RCO

\ initial value
\ h1F wconstant AFE_GB     \ AFE(Analog front end) Boost Gain [<=h12:Indoor  >=h0E:Outdoor] 
2 wconstant NF_LVL       \ NoisFloor Threshold [0 - 7]
2 wconstant WDTH         \ Watchdog Threshold [0 - hF]

\ =========================================================================== 
\ Variables 
\ =========================================================================== 
wvariable old       \ Frequency difference
wvariable cap       \ capacitance index
wvariable DIV       \ Frequency Division Ratio[0:16,1:32,2:64,3:128]

\ =========================================================================== 
\ Main 
\ =========================================================================== 
\ ( n1 n2 -- n3 )  n1:LCO_FDIV[0,1,2,3] n2:IRQ pin  n3:frequency
lockdict create a_FREQcount forthentry
$C_a_lxasm w, h124  h113  1- tuck - h9 lshift or here W@ alignl h10 lshift or l,
z2WiPZB l, z1SyLI[ l, z2WyPb4 l, z20iPeB l, z2Wiy4Y l, z20iy3C l, z2WyyW0 l, z2WiPnZ l,
z20iPqk l, z2WyyG1 l, z3ryPj0 l, z2Wyy00 l, z2WiPVv l, zfiPRD l, z1SV01X l, zb0000 l,
z4kBG0 l,
freedict

\ Read 1byte
\ ( n1 -- n2 ) n1:register  n2:data
: AS3935_rd AS3935 i2c_rd ;

\ Write 1byte
\ ( n1 n2 -- ) n1:data n2:register
: AS3935_wr AS3935 i2c_wr ;

\ Display all registers from mode1 to ALLCALLADR
\ ( -- )
: rd_allreg
cr
hex
." register number[hex]:value[hex]"  cr cr
hex
8 0 do
     8 0 do
          j 8 * i + d62 <
          if
               j 8 * i + AS3935_rd
               j 8 * i + .byte ." :" 
               .byte 2 spaces
          else
               8 seti
          then
     loop 
     cr  
loop
decimal
cr
;

\ Caribrating LCO
\ ( -- )
: calib_LCO
d16 0 do
     \ Write Disp_LCO-bit and TUN_CAP
     h80 i or reg8 AS3935_wr
     2 delms
     DIV W@ IRQ a_FREQcount 
     dup
     
     ." CAP= " i . space ." frequency=" . cr
     d500000 - abs dup old W@ <        \ Get difference between obtained value and 500kHz
     if 
          old W! i cap W!              \ Update old and cap
     else
          drop
     then
loop
;

\ Initialize AS3935
\ ( -- )
: init_AS3935
0 DIV W!                      \ LCO_FDIV=16(Default)
d10000 old W!
h96 reg60 AS3935_wr           \ Preset Default

\ AntennaTuning(LCO)                                      
calib_LCO
\ Display Frequency and Capacitance
h80 cap W@ or reg8 AS3935_wr
DIV W@ IRQ a_FREQcount 
." SetFrequency:" . ." Hz" space ." Capacitance:" cap W@ 8 * . ." pF" cr
\ Save TUN_CAP
cap W@ reg8 AS3935_wr

\ Caliblate RCO
h96 reg61 AS3935_wr 
2 delms
\ TRCO
reg8 AS3935_rd h20 or reg8 AS3935_wr    \ DISP_TRCO=1
2 delms
reg58 AS3935_rd hC0 and                 
h80 =                                   \ Check bit7=1[TRCO_CALIB_DONE] bit6=0[TRCO_CALIB_NOK]
if 
     ." TRCO ok"
     0 IRQ a_FREQcount 4 rshift space . ." Hz"
else 
     ." TRCO NG" 
then
reg8 AS3935_rd hF and reg8 AS3935_wr    \ DISP_TRCO=0
cr
\ SRCO
reg8 AS3935_rd h40 or reg8 AS3935_wr    \ DISP_SRCO=1
2 delms
reg59 AS3935_rd hC0 and                 
h80 =                                   \ Check bit7=1[SRCO_CALIB_DONE] bit6=0[SRCO_CALIB_NOK]
if 
     ." SRCO ok"
     0 IRQ a_FREQcount 4 rshift space . ." Hz"
else 
     ." TRCO NG" 
then
reg8 AS3935_rd hF and reg8 AS3935_wr    \ DISP_SRCO=0
cr cr
;

\ Print "Clear statistics"
\ ( -- )
: CLR ." Clear statistics" cr ;

\ Print "Noise level too high"
\ ( -- )
: INT_NH ." Noise level too high" cr ;

\ Print "Disturb detected"
\ ( -- )
: INT_D ." Disturb detected" cr ;

\ Ligtning interrupt
\ ( -- )
: INT_L
." Ligtning detected" cr
\ energy
3 reg4 AS3935 i2c_rd_multi
h1F and swap d256 * +              \ MSbyte+MMSbyte
swap d65536 * +                    \ LSbyte+MSbyte+MMSbyte

." Energy:" . 5 spaces ." Distance:" 
\ Distance
reg7 AS3935_rd h3F and
1 over =
if
     ." Storm is Overhead"
else
     h3F over =
     if
          ." Out of range"
     else
          . ." km"
thens
drop
cr     
;

\ Detect interrupt
\ ( -- )
: Detect_int
2 delms
reg3 AS3935_rd hF and    \ Read Interrupt
0 over =
if
     CLR                      \ Clear statistics
else                          
     1 over =
     if
          INT_NH              \ Noise level too high
     else
          4 over =
          if
               INT_D          \ Disturb detected
          else
               8 over =
               if
                    INT_L     \ Ligtning interrupt
thens
drop
;

\ Set AFE Gain  (Defalt:18)
\ ( n1 -- )  n1:AFE Gain ( 0 - 31) Indoor:18  Outdoor:14 
: AFE_Gain
h1F and 1 lshift
reg0 AS3935_rd hE1 and or
reg0 AS3935_wr
;

\ Set Noise Floor Threshold (Default:2)
\ ( n1 -- )  n1:NF[0 - 7] 
: NF
7 and 4 lshift
reg1 AS3935_rd h8F and or 
reg1 AS3935_wr
;

\ Set Watchdog Threshold (Default:2)
\ ( n1 -- )  n1:NF[0 - 10]  
: WDTH
hF and d10 min
reg1 AS3935_rd hF0 and or 
reg1 AS3935_wr
;

\ Clear Statistics
\ ( -- )
: ClrStat
reg2 AS3935_rd dup 
hBF and reg2 AS3935_wr   \ Clear CL_STAT-bit
reg2 AS3935_wr           \ Set CL_STAT-bit
;

\ Set minimum number of lightning[1,5,9,16]
\ ( n1 -- ) n1:minimum number of lightning
: setNumLightning
hF and 1- 4 u/mod nip 4 lshift
reg2 AS3935_rd hCF and or
reg2 AS3935_wr
;

\ Set spike rejection[0 - 11]
\ ( n1 -- )
: setSREJ
hF and d11 min
reg2 AS3935_rd hF0 and or
reg2 AS3935_wr
;


\ Set/Clear MaskDisturber
\ ( n1 -- )  n1:1[set] 0[clear] 
: MaskDist
if
     reg3 AS3935_rd h40 or reg3 AS3935_wr
else
     reg3 AS3935_rd hBF and reg3 AS3935_wr
then
;

\ Display parameters
\ ( -- )
: dispParam
cr 
." AFE_GB:" reg0 AS3935_rd 1 rshift h1F and . cr
." PWD:" reg0 AS3935_rd 1 and if ." Power down" else ." Listening" then cr
." NF_LVL:" reg1 AS3935_rd 4 rshift 7 and . cr
." WDTH:" reg1 AS3935_rd hF and . cr
." CL_STAT:" reg2 AS3935_rd 6 rshift 1 and . cr
." MIN_NUM_LIGH:" reg2 AS3935_rd 4 rshift 3 and . cr
." SREJ:" reg2 AS3935_rd hF and . cr
." LCO_FDIV:" reg3 AS3935_rd 6 rshift 3 and . cr
." MASK_DIST:" reg3 AS3935_rd 5 rshift 1 and . cr
." TUN_CAP:" reg8 AS3935_rd hF and 8 * . ." pF" cr
;

\ Not yet detect Ligtning
\ ( -- )
: demo
\ Initialize AS3935
init_AS3935
begin
     mIRQ ina COG@ and
     if Detect_int then
     fkey? swap drop
until
;

          
{
\ Measurement frequency
\ Counting of pulses on IEQ pin
\ ( n1 n2 -- n3 )  n1:LCO_FDIV[0,1,2,3] n2:IRQ pin  n3:frequency
\ $C_treg1 - IRQ pin
\ $C_treg2 - shift bit
\ $C_treg3 - waiting cnt


fl
h1F8	wconstant ctra 
h1FA	wconstant frqa
h1FC	wconstant phsa

build_BootOpt :rasm
     \ Get IRQ pin
     mov       $C_treg1 , $C_stTOS
     spop
     
     mov       $C_treg2 , # 4
     add       $C_treg2 , $C_stTOS  
     \ Counter mode
     mov       ctra , __POSEDGE
     add       ctra , $C_treg1
     mov       phsa , # 0
     
     mov       $C_treg3 , __1sec
     add       $C_treg3 , cnt
     mov       frqa , # 1
     waitcnt   $C_treg3 , # 0
     \ Clear ctra
     mov       ctra , # 0
     mov       $C_stTOS , phsa
     shl       $C_stTOS , $C_treg2
     jexit


__POSEDGE
     h28000000
__1sec
     d80000000
     
;asm a_FREQcount

}

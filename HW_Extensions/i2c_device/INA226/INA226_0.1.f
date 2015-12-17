fl

{
PropForth 5.5(DevKernel)
Bi-Directional Current and Power Monitor(INA226) 

This use to copy a parts from i2c_utility_0.4_1.f   
2015/11/09 11:49:10                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
 
INA226 module     Propeller
      scl   ----  P28   
      sda   ----  P29
       
      GND   ---- GND
      VS    ---- 3.3V 
      VBUS  ---- Bus Voltage Input
      IN+   ---- Connect to supply side of shunt resistor
      IN-   ---- Connect to load side of shunt resistor
      Ao    ---- GND
      A1    ---- GND
      
This module use 25mohm as shunt resistor.
mesurment resion:+3.2767A to -3.2768A
Using Hi-Side connection
}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Slave addres[h40] for INA226[A0=A1=0)
h80 wconstant INA226
\ Register
0 wconstant config
1 wconstant Shunt
2 wconstant Bus
3 wconstant Power
4 wconstant Current
5 wconstant Calibration
6 wconstant MaskEnable
7 wconstant Alert
clkfreq d1000 / d150 * constant 150ms

\ =========================================================================== 
\ Variables 
\ =========================================================================== 

\ =========================================================================== 
\ Main 
\ =========================================================================== 


\ Read 2byte
\ ( n1 -- n2 )  n1:register  n2:value[16bit]
: rd_INA226 2 swap INA226 i2c_rd_multi swap 8 lshift or ;

\ Write value[16bit] to INA226
\ ( n1 n2 n3 -- )   n1:L-byte n2:H-byte n3:register
: wr_INA226 
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi) 
INA226 _eewrite               \ ( n1 n2 n3 t/f )
\ Write register                   
swap _eewrite or              \ ( n1 n2 t/f )
\ Write H-byte
swap _eewrite or              \ ( n1 t/f )
\ Write L-byte
swap _eewrite or              \ ( t/f )
\ Stop I2C
_eestop                       
err?                          \ ( -- )
;

\ Read Manufactuer ID (Result should be h5449) and Die ID (Result should be h2260) 
\ ( -- )
: ID
cr
hex 
." Manufacture ID:h" hFE rd_INA226 . cr
." Die ID:h" hFF rd_INA226 . cr
decimal 
;

\ Reset INA226
\ ( -- )
: reset_INA226 0 h80 config wr_INA226 ;

\ Initial setting
\ ( -- )
: init_INA226
\ AverageMode=64 
\ Bus Volt Conversion Time= 1.1ms
\ Shunt Volt Conversion Time= 1.1ms
\ Operating Mode=Shunt and Bus Continueous
\ It takes 140.8ms at one measurement [1.1ms X 64 X 2]
h27 h47 config wr_INA226      \ Config h4727
0 8 Calibration wr_INA226     \ Calibration h800(=d2048)
;

\ Tab
\ ( -- )
: tab 9 emit ;

\ Display register
\ ( --  )
: dispReg
cr ." Register" tab tab ." Value" cr
hex
." Configuration(h00):" tab 0 rd_INA226 ." h" . cr
decimal
." Shunt Voltage(h01):" tab 1 rd_INA226 ." d" . cr
." Bus Voltage(h02):" tab 2 rd_INA226 ." d" . cr
." Power(h03):" tab tab 3 rd_INA226 ." d" . cr
." Current(h04):" tab tab 4 rd_INA226 ." d" . cr
." Calibration(h05):" tab 5 rd_INA226 ." d" . cr
hex
." Mask/Enable(h06):" tab 6 rd_INA226 ." h" . cr
decimal
." Alert Limit(h07):" tab 7 rd_INA226 ." d" . cr
;



{
3V3     
 |     INA226 modul terminal
 |-------V+
 |-------ISENSE+
 
 |-------ISENSE-
 |
LED-P
LED-N
 |
220ohm
 |
 |-------V-
 |
GND
}
: demo
init_INA226
150ms cnt COG@ +
begin
     150ms waitcnt
     ." Bus_V:" 2 rd_INA226 d125 * d100 / . ." mV" tab           \ 1.25mV/1LSB
     ." Current:" 4 rd_INA226 d10 u/mod . h2E emit . ." mA" tab  \ 0.1mA/1LSB
     ." Power:" 3 rd_INA226 d25 * d10 / . ." mW" tab             \ 2.5mW/1LSB
     cr
     fkey? swap drop
until
drop
;

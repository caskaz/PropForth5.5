PropForth5.5(DevKernel)

i2c_utility_0.4.f
2015/10/06 16:02:27

\ -------------------------------------------------------------------
\  Modified _eewrite  Fast mode(400kHz)
\ -------------------------------------------------------------------

\ Modified _eewrite ( c1 -- t/f ) write c1 to the eeprom, true if there was an error
\ Received acknowledge from i2c-device during scl is high
\ scl/sda use pull-up resistor at hi
\ clock:400kHz

fl
build_BootOpt :rasm
		mov     $C_treg1 , # h8
\ --- Start tranmit 8bits
__1
          \ Set data-bit to sda
		test    $C_stTOS , # h80	wz
		muxz    dira , __sda
		\ Wait 88ticks
		jmpret  __delayret , # __delay
		
          \ Set scl to input(Hi)
		andn    dira , __scl
		\ Wait 88ticks
		jmpret  __delayret , # __delay

          \ Set scl to output(lo)
		or      dira , __scl
		
		\ Shift data-bit
		shl     $C_stTOS , # 1
          \ Finish 8bit?
		djnz    $C_treg1 , # __1
\ --- Finish transmit 8bits

          \ Set sda to input(floating)
		andn    dira , __sda
		\ Wait 88ticks
		jmpret  __delayret , # __delay

          \ Set scl to input(Hi)
		andn    dira , __scl
		\ Wait 88ticks
		jmpret  __delayret , # __delay
		\ Input sda from slave,  Read ACK
		test    __sda , ina	wz
		muxnz   $C_stTOS , $C_fLongMask   

          \ Set scl to lo
		or      dira , __scl

		\ Wait 88ticks
		jmpret  __delayret , # __delay
		
		\ Set sda to lo and output
		or      dira , __sda

		jexit

\ this delay makes for a 84ticks on an 80 Mhz prop   [Xtal:5MHz]
__delay
          mov       $C_treg2 , # d71
		add       $C_treg2 , cnt
          waitcnt   $C_treg2 , # 0                               
__delayret
		ret
				
__sda
		h20000000
__scl
		h10000000

;asm _eewrite

\ ------------------------------------------------------------------------------------------
\  Modified _eeread  Fast mode(400kHz)
\ ------------------------------------------------------------------------------------------
\ _eeread ( t/f -- c1 ) flag should be true is this is the last read
\ scl/sda use pull-up resistor at hi
\ clock:400kHz
fl
build_BootOpt :rasm
		mov     $C_treg1 , $C_stTOS 
		mov     $C_stTOS , # 0
          \ Set sda to input(floating)
		andn    dira , __sda
		mov     $C_treg3 , # h8
\ --- Start tranmit 8bits
__1
          \ Wait 90ticks
		jmpret  __delayret , # __delay
          \ Set scl to input(Hi)
          andn    dira , __scl
          \ Wait 90ticks          
		jmpret  __delayret , # __delay

		test    __sda , ina	wc
		rcl     $C_stTOS , # 1

          \ Set scl to output(lo)
          or      dira , __scl          

		djnz    $C_treg3 , # __1
\ --- Finish transmit 8bits
				          
		cmp     $C_treg1 , # 0 wz
		
          \ Set sda to hi if $C_treg is not 0
		muxz    dira , __sda
          \ Wait 90ticks
		jmpret  __delayret , # __delay

          \ Set scl to input(Hi)
          andn    dira , __scl
          \ Wait 90ticks
		jmpret  __delayret , # __delay

          \ Set scl to output(lo)
	     or      dira , __scl
	     
          \ Set sda to output(lo)
          or      dira , __sda
          \ Wait 90ticks
		jmpret  __delayret , # __delay

		jexit

\ this delay makes for a 86ticks on an 80 Mhz prop   [Xtal:5MHz]
__delay
          mov       $C_treg2 , # d73
		add       $C_treg2 , cnt
          waitcnt   $C_treg2 , # 0                               
__delayret
		ret

__sda
		h20000000
__scl
		h10000000

;asm _eeread

\ -------------------------------------------------------------------
\  Modified _eestart  
\ -------------------------------------------------------------------

\ Modified '__eestart' for RepeatedStart(equal _eestart) is success on SMBus
\ ( -- )
fl
build_BootOpt :rasm
          andn      dira , __sda
          andn      dira , __scl
          mov       $C_treg1 , # __40usec
          add       $C_treg1 , cnt
          waitcnt   $C_treg1 , # 0
          or        dira , __sda
          mov       $C_treg1 , # __10usec
          add       $C_treg1 , cnt
          waitcnt   $C_treg1 , # 0
          or        dira , __scl          
          jexit
          
__40usec
          d3200
__10usec
          d800
__sda
		h20000000
__scl
		h10000000

;asm _eestart


\ -------------------------------------------------------------------
\  Modified _eewrite  Standard mode(100kHz)
\ -------------------------------------------------------------------

\ Modified _eewrite ( c1 -- t/f ) write c1 to the eeprom, true if there was an error
\ Received acknowledge from i2c-device during scl is high
\ scl/sda use pull-up resistor at hi
\ clock:100kHz

fl
build_BootOpt :rasm
		mov     $C_treg1 , # h8
\ --- Start tranmit 8bits
__1
          \ Set data-bit to sda
		test    $C_stTOS , # h80	wz
		muxz    dira , __sda
		\ Wait 400ticks
		jmpret  __delayret , # __delay
		
          \ Set scl to input(Hi)
		andn    dira , __scl
		\ Wait 400ticks
		jmpret  __delayret , # __delay

          \ Set scl to output(lo)
		or      dira , __scl
		
		\ Shift data-bit
		shl     $C_stTOS , # 1
          \ Finish 8bit?
		djnz    $C_treg1 , # __1
\ --- Finish transmit 8bits

          \ Set sda to input(floating)
		andn    dira , __sda
		\ Wait 400ticks
		jmpret  __delayret , # __delay

          \ Set scl to input(Hi)
		andn    dira , __scl
		\ Wait 400ticks
		jmpret  __delayret , # __delay
		\ Input sda from slave,  Read ACK
		test    __sda , ina	wz
		muxnz   $C_stTOS , $C_fLongMask   

          \ Set scl to lo
		or      dira , __scl

		\ Wait 400ticks
		jmpret  __delayret , # __delay
		
		\ Set sda to lo and output
		or      dira , __sda

		jexit

\ this delay makes for a 400ticks on an 80 Mhz prop   [Xtal:5MHz]
__delay
          mov       $C_treg2 , # d387
		add       $C_treg2 , cnt
          waitcnt   $C_treg2 , # 0                               
__delayret
		ret
				
__sda
		h20000000
__scl
		h10000000

;asm std_eewrite

\ ------------------------------------------------------------------------------------------
\  Modified _eeread  Standard mode(100kHz)
\ ------------------------------------------------------------------------------------------
\ _eeread ( t/f -- c1 ) flag should be true is this is the last read
\ scl/sda use pull-up resistor at hi
\ clock:100kHz
fl
build_BootOpt :rasm
		mov     $C_treg1 , $C_stTOS 
		mov     $C_stTOS , # 0
          \ Set sda to input(floating)
		andn    dira , __sda
		mov     $C_treg3 , # h8
\ --- Start tranmit 8bits
__1
          \ Wait 400ticks
		jmpret  __delayret , # __delay
          \ Set scl to input(Hi)
          andn    dira , __scl
          \ Wait 400ticks          
		jmpret  __delayret , # __delay

		test    __sda , ina	wc
		rcl     $C_stTOS , # 1

          \ Set scl to output(lo)
          or      dira , __scl          

		djnz    $C_treg3 , # __1
\ --- Finish transmit 8bits
				          
		cmp     $C_treg1 , # 0 wz
		
          \ Set sda to hi if $C_treg is not 0
		muxz    dira , __sda
          \ Wait 400ticks
		jmpret  __delayret , # __delay

          \ Set scl to input(Hi)
          andn    dira , __scl
          \ Wait 400ticks
		jmpret  __delayret , # __delay

          \ Set scl to output(lo)
	     or      dira , __scl
	     
          \ Set sda to output(lo)
          or      dira , __sda
          \ Wait 400ticks
		jmpret  __delayret , # __delay

		jexit

\ this delay makes for a 400ticks on an 80 Mhz prop   [Xtal:5MHz]
__delay
          mov       $C_treg2 , # d387
		add       $C_treg2 , cnt
          waitcnt   $C_treg2 , # 0                               
__delayret
		ret

__sda
		h20000000
__scl
		h10000000

;asm std_eeread

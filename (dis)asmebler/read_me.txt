    Welcome to the w8 assembly,it is made with the because im too lazy to write instructions
in binary.
-Every instructions is written in a single line
-It must be wtitten in the start of the line
-labels/origins are written on a single line
-immediate adressing mode operands MUST be written in hex
-jump instruction MUST be written in decimal 
-there are 8 registers referenced from 0 to 7 and 16 ioports (0 to f)


***each line is written as follows:

.label_name:    or     &origin_ardress_decimal

***one byte instruction example:

inc

***two byte instruction exapmles:

incr <0register_reference>
swp <0register_reference_destination>,<0register_reference_source>
jp (label_name or addres)
ina <io_port>
outr <ioport_reference>,<0register_reference>

***three byte instruction examples:

rli <0register_reference>,two_byte_operand

example program : delay of 1 sec approximately

ldi 11
.loop2:
rli <02>,16
.loop1: 
rli <01>,FF
.loop0:
rli <00>,FF
.delay:
nop 
decr <00> 
jpnz (delay) 
nop 
decr <01> 
jpnz (loop0) 
nop 
decr <02> 
jpnz (loop1) 
inc 
jp (loop2) 
#(19*255*255*22) delay is 1.006s   

another example: this code outputs the register reference according to input from user 
rli <00>,0F
rli <01>,1F
rli <02>,2F
rli <03>,3F
rli <04>,4F
rli <05>,5F
rli <06>,6F
rli <07>,7F
ldi FF
ldsp FF
.never_ending_loop:
ei (interrupt)
pctoix
ldr <00>
nop 
jp (never_ending_loop)
.interrupt:
di 
get <00>
ina <00>
incix 
indexedstr 
ret 
#this code outputs a register on acc depending on the value at the input of io port :) 

Hello,
this is my final year project, it is an 8 bit CPU with VHDL using structural modeling,copy all the files if you need to.
I liked the architecture of CPUs in a lecture last semester so i decided to implement one myself!
The top level design is "W8.qpf", you may change the generic in "W8.vhd" to your mif file directory, or initialize the ram with your instructions.
In the "(dis)assembler" file I created an assembler/disassembler using C++, all the instructions are in the library "assembler_data.h".
The main file in that directory carries the assembler , the generateMIF and the dissassemble methods.
The assemble method takes two areguments, one is the input file to read the assembly from, the other argument is the file to output the machine code to.
The generateMIF methode takes a txt file as an input, it should contain all the data in hexadecimal and each byte in a single line.
there is a "read me" file that explains the instructions and how to use the assembler.
Refer to my report for further details on the project, and the design in general.
thanks for your attention and good luck with your work.
I have added my final year report,it contains some details that may be usefull for anybody that is curious.
about the instruction set or the internal structure.

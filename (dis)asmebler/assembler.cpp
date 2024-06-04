#include<iostream>
#include<fstream>
#include<string>

#include "assembler_data.h"



int main()
{
    instructions data;
      data.assemble("C:\\Users\\DELL\\Desktop\\NewCPU\\(dis)asmebler\\GCD_with_delay.txt",
      "C:\\Users\\DELL\\Desktop\\NewCPU\\(dis)asmebler\\binary_output.txt");

      data.generate_mif("C:\\Users\\DELL\\Desktop\\NewCPU\\(dis)asmebler\\binary_output.txt",
      "C:\\Users\\DELL\\Desktop\\NewCPU\\(dis)asmebler\\generated.mif");
      
      data.disassemble("C:\\Users\\DELL\\Desktop\\NewCPU\\(dis)asmebler\\binary_output.txt");
     return 0;
}
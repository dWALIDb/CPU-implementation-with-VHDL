#pragma once
#include <unordered_map>
#include <fstream>

class instructions  
{
	private:
	bool valid_code=true;
	std::string data;
	std::string part;
	int line_count=0;
	std::string holder[2];
	enum num_bytes {origin=-1,label=0,one_byte=1,two_bytes=2,three_bytes=3};
	num_bytes length;
	std::unordered_map<std::string , int> labeled_addreses;
	std::unordered_map<std::string , std::string> microinstruction={{"ldd","00"},{"ldr","01"},
	{"ldi","02"},{"rla","03"},{"rli","05"},{"rlm","06"},{"sta","07"},{"str","08"},{"ldsp","09"},{"ldix","0A"},{"inc","0B"},{"incr","0C"},{"dec","0D"},
	{"decr","0E"},{"cp","0F"},{"cpr","10"},{"cpm","11"},{"sl","12"},{"sr","13"},{"rot","14"},{"slr","15"},{"srr","16"},{"rotr","17"},{"adr","18"},
	{"adm","19"},{"adi","1A"},{"sbr","1B"},{"sbm","1C"},{"sbi","1D"},{"swp","1E"},{"incix","20"},{"decix","21"},{"andr","22"},{"andm","23"},{"andi","24"},
	{"orr","25"},{"orm","26"},{"ori","27"},{"xorr","28"},{"xorm","29"},{"xori","2A"},{"cpl","2B"},{"neg","2C"},{"jp","2D"},{"jr","2E"},{"jpe","2F"},{"jpl","30"},
	{"jpg","31"},{"jre","32"},{"jrl","33"},{"jrg","34"},{"jpne","35"},{"jrne","36"},{"jpc","37"},{"jpnc","38"},{"jpz","39"},{"jpnz","3A"},{"jpp","3B"},
	{"call","3C"},{"ret","3E"},{"pushflag","3F"},{"popflag","40"},{"indexedld","41"},{"indexedstr","42"},{"get","43"},
	{"jpn","46"},{"jpo","47"},{"jpno","48"},{"jrc","49"},{"jrnc","4A"},{"jrz","4B"},{"jrnz","4C"},{"jrp","4D"},{"jrn","4E"},{"jro","4F"},{"jrno","50"},
	{"pushacc","51"},{"popacc","52"},{"pushreg","53"},{"popreg","54"},{"di","55"},{"ei","56"},{"ina","57"},{"inr","58"},{"outa","59"},{"outr","5A"},{"halt","FF"},{"nop","80"},
	{"incc","5B"},{"decc","5C"},{"incrc","5D"},{"decrc","5E"},{"incz","5F"},{"decz","60"},{"incrz","61"},{"decrz","62"}	
	,{"adix","63"},{"sbix","64"},{"andix","65"},{"orix","66"},{"xorix","67"},{"cpix","68"},{"pctoix","69"},{"offsetix","6A"}
};
	//alocator to find a speceffic key from a value used to determin existance of an instruction  
	std::unordered_map<std::string, std::string>::const_iterator get ;
	std::unordered_map<std::string, int>::const_iterator get_addres ;
	 
	public:
	bool is_valid()
	{
		return this->valid_code;
	}

	void numberofinstructions()
	{
		std::cout<<std::to_string(this->microinstruction.size());
	} 

	void reset_count()
	{
		this->line_count=0;
	}

	void to_machine_code(std::string data1)
	{	
		this->length=label;
		// for comments,they start by # 
		if (data1.front()=='&')
		{
			this->length=origin;
			// convert string to integer and get the new line value
			data=this->operand_tokenizer(data1,"&","\0");
			std::cout<<"\n*******line_count set to: "<<data<<"*******\n";
			
			this->line_count=std::stoi(data);
			return;
		}
		if (data1.front()=='\n')
		{
			return;
		}
		
		if (data1.front()=='#' || data1.front()=='.')
		{
		//this means that it is either a label or a comment or an empty line at the start so no need to get machine code
			return;
		}
		// now we fetch micro-instructions	
		//if op_code doesnt end with " " then it is one byte instruction 
		data=this->tokenizer(data1,data1.substr(0,1)," ");
		if (data=="return error")
		{
			data=this->tokenizer(data1,data1.substr(0,1),"\n");
		
		}
		
		std::cout<<"\n*** "<<line_count<<" : "<<data<<" ***\n";

		//check if micro instruction exists
		get=microinstruction.find(data);
		if (get==microinstruction.end())
		{
			valid_code=false;
			std::cout<<"instruction "<<data<<" at line: "+std::to_string(line_count)<<"\n";  
			return;
		}
	
		std::cout<<microinstruction[data]<<"\n";
		
		//this block is for  single byte instructions
		line_count++;
		this->length=one_byte;
		
		if ((data=="incix")||(data=="decix")||(data=="inc")||(data=="dec")||(data=="di")||(data=="ret")||(data=="indexedstr")
		||(data=="sl")||(data=="sr")||(data=="rot")||(data=="cpl")||(data=="neg")||(data=="pushflag")||(data=="popflag")||(data=="indexedld")
		||(data=="pushacc")||(data=="popacc")||(data=="halt")||(data=="nop")||(data=="incc")||(data=="decc")||(data=="incz")||(data=="decz")
		||(data=="adix")||(data=="sbix")||(data=="andix")||(data=="orix")||(data=="xorix")||(data=="cpix")||(data=="pctoix"))
		{
			return;
		}

		// this block is for 2 byte instructions 
		this->length=two_bytes; 
		line_count++;

		if ((data=="ldi")||(data=="cp")||(data=="sbi")||(data=="ldix")||(data=="ldsp")||(data=="adi")||(data=="xori")
		||(data=="andi")||(data=="ori")||(data=="offsetix"))
		{
			holder[0]=this->operand_tokenizer(data1," ","#");
			if (holder[0]=="return error")
			{
				holder[0]=this->operand_tokenizer(data1," ","\n");
			}
			return;
		}
		else if((data=="sta")||(data=="ei")||(data=="jp")||(data=="jpe")||(data=="jpg")||(data=="jpl")||(data=="jpne")
		||(data=="jpc")||(data=="jpnc")||(data=="jpz")||(data=="jpnz")||(data=="jpp")||(data=="jpn")||(data=="jpo")
		||(data=="jpno")||(data=="call")||(data=="ldd")||(data=="cpm")||(data=="orm")||(data=="xorm")||(data=="adm")||(data=="sbm")||(data=="andm"))
		{
			holder[0]=this->operand_tokenizer(data1,"(",")");
			get_addres=labeled_addreses.find(holder[0]);
			if (get_addres!=labeled_addreses.end())
			{
				std::string intermediate=holder[0];
				holder[0]=this->to_byte(labeled_addreses[holder[0]]);
				std::cout<<"operand on labeled "<<holder[0]<<" line: "<<this->to_byte(labeled_addreses[intermediate])<<"\n";
			}
			else{
				int t=std::stoi(holder[0]);
				holder[0]=this->to_byte(t);
				std::cout<<"operand on non-labed line: "<<holder[0]<<"\n";
			}
			return;	
		}
		else if((data=="jr")||(data=="jre")||(data=="jrg")||(data=="jrl")||(data=="jrne")||(data=="jrc")||(data=="jrnc")
		||(data=="jrz")||(data=="jrnz")||(data=="jrp")||(data=="jrn")||(data=="jro")||(data=="jrno"))
		{
			holder[0]=this->operand_tokenizer(data1,"(",")");
			get_addres=labeled_addreses.find(holder[0]);
			if (get_addres!=labeled_addreses.end())
			{	
				//+2 because line count is incremented twice and we want the adress of the instruction and not the operand 
				//with subtraction from the line count it becomes +2 and line count becomes negative 
				holder[0]=this->to_byte(labeled_addreses[holder[0]]-line_count);
				
			}else{
				int t=std::stoi(holder[0])-1;
				holder[0]=this->to_byte(t);
			}		
				std::cout<<holder[0]<<"\n";
			return;
		}
		else if((data=="adr")||(data=="cpr")||(data=="sbr")||(data=="slr")||(data=="rotr")||(data=="incr")||
		(data=="srr")||(data=="xorr")||(data=="andr")||(data=="orr")||(data=="decr")||(data=="pushreg")||(data=="rla")||
		(data=="popreg")||(data=="ldr")||(data=="ina")||(data=="outa")||(data=="get")||(data=="incrc")||(data=="decrc")||(data=="incrz")||(data=="decrz"))
		{
			holder[0]=this->operand_tokenizer(data1,"<",">");
			return;
		}
		else if(data=="swp"||(data=="inr")||(data=="outr"))
		{
			// <io_port>,<register>
			part=this->operand_tokenizer(data1,",",">");
			holder[0]=this->operand_tokenizer(data1,"<",">")+this->operand_tokenizer(part,"<",">");
			return;
		}
		
		// this block is for three byte instructions 
		this->length=three_bytes;
		line_count++;

		if (data=="rli")
		{
			holder[0]=this->operand_tokenizer(data1,"<",">");
			holder[1]=this->operand_tokenizer(data1,",","#");
			if (holder[1]=="return error")
			{
				holder[1]=this->operand_tokenizer(data1,",","\n");
			}
			return;
		}
		else if(data=="rlm")
		{//register loaded by memory
			holder[0]=this->operand_tokenizer(data1,"<",">");
			holder[1]=this->operand_tokenizer(data1,"(",")");
			get_addres=labeled_addreses.find(holder[1]);
			if (get_addres !=labeled_addreses.end())
			{
				holder[1]=this->to_byte(labeled_addreses[holder[1]]);
			}else
			{
				
				holder[1]=this->to_byte(std::stoi(holder[1]));
			}
			std::cout<<holder[0]<<"\t"<<holder[1]<<"\n";
			return;
		}
		else if(data=="str")
		{//load memory with register R then mem addres
			holder[0]=this->operand_tokenizer(data1,"<",">");
			holder[1]=this->operand_tokenizer(data1,"(",")");
			get_addres=labeled_addreses.find(holder[1]);
			if (get_addres !=labeled_addreses.end())
			{
				std::cout<<"labeled line detected\n";
				holder[1]=this->to_byte(labeled_addreses[holder[1]]);
			}else
			{
				holder[1]=this->to_byte(std::stoi(holder[1]));
			}
			std::cout<<holder[0]<<"\t"<<holder[1]<<"\n";
			return;
		}

	}

	std::string tokenizer(std::string input,std::string starter,std::string stopper)
	{
		int start=input.find(starter);
		int stop=input.find(stopper);
		if (start!=std::string::npos && stop!=std::string::npos)
		{return input.substr(start,stop-start);}
		else return "return error";
	}

	std::string operand_tokenizer(std::string input,std::string starter,std::string stopper)
	{//literally the same as tokenozer exept it doesnt leave the first character :)
		int start=input.find(starter)+1;
		int stop=input.find(stopper);
		if (start!=std::string::npos && stop!=std::string::npos)
		{return input.substr(start,stop-start);}
		else return "return error";
	}

	void debugger()
	{
		if ((length==two_bytes)&&(holder[0]=="return error" || holder[0].size()<2))
		{
			valid_code=false;
			std::cout<<"operand syntax error for instruction " <<data<<" at line: "+std::to_string(line_count);
			std::cout<<"operand must be 2 bytes please";
		}
		if ((length==three_bytes)&&(holder[1]=="return error" ||holder[1].size()<2))
		{
			valid_code=false;
			std::cout<<"operand syntax error for instruction " <<data<<" at line: "+std::to_string(line_count)<<"\n"; 
			std::cout<<"operand must be 2 bytes please";
		}
	}

	void output(std::fstream &file_name)
	{	
		
		if (this->length==one_byte)
		{
			file_name<<microinstruction[data]<<"\n";
		}
		else if (this->length==two_bytes)
		{
			file_name<<microinstruction[data]<<"\n";
			file_name<<holder[0]<<"\n";
		}
		else if (this->length==three_bytes)
		{
			file_name<<microinstruction[data]<<"\n";
			file_name<<holder[0]<<"\n";
			file_name<<holder[1]<<"\n";
		}
		else if (this->length==origin)
		{
			file_name<<"&"+data<<"\n";
		}
		
		
	}

	std::string to_byte(int value)
	{
		int output[2]={0};
		int result=0,i=0;
		if(value<0)
		{
			value=255+value+1;
		}
		while (value!=0)
		{
		result=value % 16;
		value/=16;
		output[i]=result;
		i++;
		}
		
		std::string return_value[2]={"0"};

		switch (output[1])
		{
		case 10:
			return_value[1]="A";
			break;
		case 11:
			return_value[1]="B";
			break;
		case 12:
			return_value[1]="C";
			break;
		case 13:
			return_value[1]="D";
			break;
		case 14:
			return_value[1]="E";
			break;
		case 15:
			return_value[1]="F";
			break;
		default:
			return_value[1]=std::to_string(output[1]);
			break;
		}
		switch (output[0])
		{
		case 10:
			return_value[0]="A";
			break;
		case 11:
			return_value[0]="B";
			break;
		case 12:
			return_value[0]="C";
			break;
		case 13:
			return_value[0]="D";
			break;
		case 14:
			return_value[0]="E";
			break;
		case 15:
			return_value[0]="F";
			break;
		default:
			return_value[0]=std::to_string(output[0]);
			break;
		}
		return return_value[1]+return_value[0]; 	
	}

	void get_labels(std::string data1)
	{
		this->length=label;
		//check for labels
		std::string labels=this->operand_tokenizer(data1,".",":");

		// we kinda fetch op_codes to get 
		data=this->tokenizer(data1,data1.substr(0,1)," ");
		if (data=="return error")
		{
			data=this->tokenizer(data1,data1.substr(0,1),"\n");
		
		}
		if (data1.front()=='&')
		{
			this->length=origin;
			// convert string to integer
			data=this->operand_tokenizer(data1,"&","\0");
			std::cout<<"\n*******line count set to: "<<data<<" *******\n";
			this->line_count=std::stoi(data);
			return;
		}
		
			if (data1.front()=='#' || data1.front()=='\n')
			{
				return;
			}
						
		
		if (labels!="return error" && data1.front()=='.')
		{
			get_addres=labeled_addreses.find(labels);
			if (get_addres!=labeled_addreses.end())
			{
				std::cout<<"label at line: "<<line_count<<" already exisits this"<<"\n";
				valid_code=false;
				return; 
			}
			labeled_addreses[labels]=line_count;
			std::cout<<labels<<" at line_count: "<<line_count<<"\n";
		}	
		if (data!="return error")
		{
			std::cout<<data<<" at line_count: "<<line_count<<"\n";
		}
		
		if ((data=="ldi")||(data=="cp")||(data=="sbi")||(data=="ldix")||(data=="ldsp")||(data=="adi")||(data=="xori")
			||(data=="andi")||(data=="ori")||(data=="ei")||(data=="jp")||(data=="jpe")||(data=="jpg")||(data=="jpl")||(data=="jpne")
			||(data=="jpc")||(data=="jpnc")||(data=="jpz")||(data=="jpnz")||(data=="jpp")||(data=="jpn")||(data=="jpo")
			||(data=="jpno")||(data=="call")||(data=="ldd")||(data=="jr")||(data=="jre")||(data=="jrg")||(data=="jrl")||(data=="jrne")||(data=="jrc")||(data=="jrnc")
			||(data=="jrz")||(data=="jrnz")||(data=="jrp")||(data=="jrn")||(data=="jro")||(data=="jrno")||(data=="rla")||(data=="orm")||(data=="xorm")||(data=="adm")||(data=="sbm")||(data=="andm")
			||(data=="adr")||(data=="cpr")||(data=="sbr")||(data=="slr")||(data=="rotr")||(data=="incr")||(data=="incrc")||(data=="decrc")||(data=="incrz")||(data=="decrz")
			||(data=="srr")||(data=="xorr")||(data=="andr")||(data=="orr")||(data=="ldr")||(data=="decr")||(data=="pushreg")||(data=="offsetix")||
			(data=="sta")||(data=="popreg")||(data=="cpm")||(data=="ldi")||(data=="swp")||(data=="ina")||(data=="outa")||(data=="inr")||(data=="outr")||(data=="get"))
			{
				this->line_count+=2;
			}
			else if ((data=="rli")||(data=="rlm")||(data=="str"))
			{
				this->line_count+=3;
			}
			else if(data!="return error" && labels=="return error") 
			{
				this->line_count++;
			}
	}

	void generate_mif(std::string reading_path,std::string mif_path)
{
	std::fstream reading_file,mif_file;
	reading_file.open(reading_path);
	mif_file.open(mif_path);

	if (reading_file.is_open()&& mif_file.is_open())
    	{
    	int i=0;
		mif_file<<"WIDTH=8;\nDEPTH=256;\n\nADDRESS_RADIX=UNS;\nDATA_RADIX=HEX;\nCONTENT BEGIN\n[0..255]  :   00;\n";
	while (reading_file.good())
	{
    		bool print_line=true;
			std::string a;
    		std::getline(reading_file,a);
    		if (a.front()=='&')
    		{
    	    	a.erase(0,1);
    	 		i=std::stoi(a);
    	    	print_line=false;
    		}
    		std::cout<<"*** "<<i<<" : "<<a<<" ***";

    		if (a=="" || a=="\n")
    		{  
        		print_line=false;
    		}

    		if(a.size()<2)
    		{
    	    	print_line=false; 
    	    	std::cout<<"some data has operand issues at "<<i<<" please check if all data has 2 byte length\n";
				std::cout<<a<<"\n";
			}
	
    		if (print_line==true)
    		{
    	    	mif_file<<"\t"<<i<<" : "<<a<<";\n" ;
		    	i++;
    		}
	}	
	mif_file<<"END;";
    }
    else std::cout<<"error when opening the files,please check directories of extenstions";
    reading_file.close();
	mif_file.close();
}

	void assemble(std::string input_path,std::string output_path)
	{
		std::fstream input_file,output_file;
		input_file.open(input_path);

		std::cout<<"********************\nwelcome to W8 assembler\n********************\n";
		std::string mnemonic;
    	if (input_file.is_open())
    	{
		std::cout<<"\n********************\ngetting labels\n*******************\n";
        while (input_file.good())
        {
            // check for labels independently
            std::getline(input_file,mnemonic);
			// i do this because std::getline doesn't tale the \n and i need it ;)
            this->get_labels(mnemonic+"\n");
            if(!this->is_valid())
            {
            	std::cout<<"failed to assemble code";
            	break;
            }
		}
    	}
		else
		{
			std::cout<<"error opening the files,please check your file directories or extensions";
		}
    	input_file.close();

		output_file.open(output_path);
		input_file.open(input_path);
    	if (input_file.is_open() && output_file.is_open() )
    	{
			std::cout<<"********************\nassembling code\n*******************\n";
        	this->reset_count();
        	while (input_file.good())
        	{
           		std::getline(input_file,mnemonic);
            	this->to_machine_code(mnemonic+"\n");
            	this->debugger();
				if(!this->is_valid())
            	{
            	std::cout<<"failed to assemble code";
            	break;
            	}
            	this->output(output_file);
        	}
    	}
		else
		{
			std::cout<<"error opening the files,please check your file directories or extensions";
		}

		input_file.close();
		output_file.close();

	}

	std::string get_key(std::string value)
	{
		//used to set origin for mif file 
		if (value.front()=='&')
		{
			this->length=origin;
			return value;
		}
		if (value=="\n" || value=="")
		{
			return value;
		}
		
		this->length=one_byte;
		for (  get=microinstruction.begin();get!=microinstruction.end();get++ )
		{
			if ( get->second == value)
			{
				// std::cout<<"good"<<" "<<get->first<<"\n";
				return get->first;
			}
		}
		return "not found";
	}

	void to_instruction(std::string data,std::string op0,std::string op1)
	{
		if (this->length==origin)
		{
			std::cout<<data<<"\n";
		}
		if (data=="\n" || data=="")
		{
			return;
		}
		//used to determine if data is not valid
		if (data=="not found")
		{
			valid_code=false;
			std::cout<<"\nwrong data at line:"<<line_count<<": "<<data<<"\n";
			return;
		}
		this->length=one_byte;
		line_count++;
		
		if ((data=="ret")||(data=="incix")||(data=="decix")||(data=="inc")||(data=="dec")||(data=="di")||(data=="indexedld")||(data=="indexedstr")
		||(data=="sl")||(data=="sr")||(data=="rot")||(data=="cpl")||(data=="neg")||(data=="pushflag")||(data=="popflag")
		||(data=="pushacc")||(data=="popacc")||(data=="halt")||(data=="nop")||(data=="incc")||(data=="decc")||(data=="incz")||(data=="decz")
		||(data=="adix")||(data=="sbix")||(data=="andix")||(data=="orix")||(data=="xorix")||(data=="cpix")||(data=="pctoix"))
		{
			std::cout<<data+"\n";
			return;
		}

		this->length=two_bytes; 
		line_count++;

		if ((data=="ldi")||(data=="cp")||(data=="sbi")||(data=="ldix")||(data=="ldsp")||(data=="adi")||(data=="xori")
		||(data=="andi")||(data=="ori")||(data=="offsetix"))
		{
			std::cout<<data<<" "<<holder[0]<<" \n";
			return;
		}
		else if((data=="sta")||(data=="ei")||(data=="jp")||(data=="jpe")||(data=="jpg")||(data=="jpl")||(data=="jpne")
		||(data=="jpc")||(data=="jpnc")||(data=="jpz")||(data=="jpnz")||(data=="jpp")||(data=="jpn")||(data=="jpo")
		||(data=="jpno")||(data=="call")||(data=="ldd")||(data=="cpm")||(data=="orm")||(data=="xorm")||(data=="adm")||(data=="sbm")||(data=="andm"))
		{
			std::cout<<data<<" ("<<std::stoi(holder[0],0,16)<<")\n";		
			return;	
		}
		else if((data=="jr")||(data=="jre")||(data=="jrg")||(data=="jrl")||(data=="jrne")||(data=="jrc")||(data=="jrnc")
		||(data=="jrz")||(data=="jrnz")||(data=="jrp")||(data=="jrn")||(data=="jro")||(data=="jrno"))
		{
			std::cout<<data<<" ("<<std::stoi(holder[0],0,16)<<")\n";
			return;
		}
		else if((data=="adr")||(data=="cpr")||(data=="sbr")||(data=="slr")||(data=="rotr")||(data=="incr")||(data=="rla")||
		(data=="srr")||(data=="xorr")||(data=="andr")||(data=="orr")||(data=="decr")||(data=="pushreg")||
		(data=="popreg")||(data=="ldr")||(data=="ina")||(data=="outa")||(data=="get")||(data=="incrc")||(data=="decrc")||(data=="incrz")||(data=="decrz"))
		{
			std::cout<<data<<" <"<<holder[0]<<">\n";
			return;
		}
		else if(data=="swp"||(data=="inr")||(data=="outr"))
		{
			std::cout<<data<<" <"<<holder[0].substr(0,1)<<">,<"<<holder[0].substr(1,1)<<">\n";
			return;
		}
		
		this->length=three_bytes;
		line_count++;

		if (data=="rli")
		{
			std::cout<<data<<" <"<<holder[0]<<">, "<<holder[1]<<"\n";
			return;
		}
		else if(data=="rlm")
		{
			//register loaded by memory
			std::cout<<data<<" <"<<holder[0]<<">,("<<std::stoi(holder[1],0,16)<<")\n";
			return;
		}
		else if(data=="str")
		{//load memory with register R then mem addres
			std::cout<<data<<" <"<<holder[0]<<">,("<<std::stoi(holder[1],0,16)<<")\n";
			return;
		}		
	}

	bool check_multibyte(std::string data)
	{	
		if (this->length==label)
		{
			return false;
		}
		if (this->length==origin)
		{
			return false;
		}
		if (data=="data not found")
		{
			valid_code=false;
			return false;
		}
		
		
		this->length=one_byte;
		if ((data=="ret")||(data=="incix")||(data=="decix")||(data=="inc")||(data=="dec")||(data=="di")||(data=="indexedstr")||(data=="indexedld")
		||(data=="sl")||(data=="sr")||(data=="rot")||(data=="cpl")||(data=="neg")||(data=="pushflag")||(data=="popflag")
		||(data=="pushacc")||(data=="popacc")||(data=="halt")||(data=="nop")||(data=="incc")||(data=="decc")||(data=="incz")||(data=="decz")
		||(data=="adix")||(data=="sbix")||(data=="andix")||(data=="orix")||(data=="xorix")||(data=="cpix")||(data=="pctoix"))
		{
			return false;
		}

		this->length=two_bytes; 

		if ((data=="sta")||(data=="ldi")||(data=="cp")||(data=="sbi")||(data=="ldix")||(data=="ldsp")||(data=="adi")||(data=="xori")||(data=="rla")
		||(data=="andi")||(data=="ori")||(data=="ei")||(data=="jp")||(data=="jpe")||(data=="jpg")||(data=="jpl")||(data=="jpne")
		||(data=="jpc")||(data=="jpnc")||(data=="jpz")||(data=="jpnz")||(data=="jpp")||(data=="jpn")||(data=="jpo")||(data=="offsetix")
		||(data=="jpno")||(data=="call")||(data=="ldd")||(data=="cpm")||(data=="jr")||(data=="jre")||(data=="jrg")||(data=="jrl")||(data=="jrne")||(data=="jrc")||(data=="jrnc")
		||(data=="jrz")||(data=="jrnz")||(data=="jrp")||(data=="jrn")||(data=="jro")||(data=="jrno")||(data=="adr")||(data=="cpr")||(data=="sbr")||(data=="slr")||(data=="rotr")||(data=="incr")||
		(data=="srr")||(data=="xorr")||(data=="andr")||(data=="orr")||(data=="decr")||(data=="pushreg")||(data=="orm")||(data=="xorm")||(data=="adm")||(data=="sbm")||(data=="andm")
		||(data=="popreg")||(data=="ldr")||(data=="ina")||(data=="outa")||(data=="get")||(data=="swp")||(data=="inr")||(data=="outr")||(data=="incrc")||(data=="decrc")||(data=="incrz")||(data=="decrz"))
		{
			return true;
		}
		
		this->length=three_bytes;

		if ((data=="rli")||(data=="rlm")||(data=="str"))
		{
			return true;
		}
	
	}

	void disassemble(std::string input_path)
	{
		std::fstream input_file;
		std::string a,v;
		std::cout<<"********************\nwelcome to W8 dissassembler\n*******************\n";
		input_file.open(input_path);
    if (input_file.is_open())
    {	
		std::cout<<"********************\ndissassembling code\n*******************\n";
        while (input_file.good())
        {
            std::getline(input_file,a);
			v=this->get_key(a);
            if(this->check_multibyte(v))
			{
				if (length==one_byte)
				{
					holder[0].clear();
					holder[1].clear();
				}
				else if (this->length==two_bytes)
				{
					std::getline(input_file,holder[0]);
				}
				else if (this->length==three_bytes)
				{
					std::getline(input_file,holder[0]);
					std::getline(input_file,holder[1]);
				}
			}
			this->to_instruction(v,holder[0],holder[1]);
        }
        
    }
	input_file.close();
	}
};
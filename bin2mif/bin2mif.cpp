// bin2mif.cpp: определяет точку входа для консольного приложения.
//

#include "stdafx.h"

int _tmain(int argc, _TCHAR* argv[])
{
	/*
	printf("bin2mif project\n");
	if(argc<2)
	{
		printf("need filename\n");
		return -1;
	}
	printf("WIDTH = 8;\n");
	printf("DEPTH = 4096;\n\n");
	printf("ADDRESS_RADIX = HEX;\n");
	printf("DATA_RADIX = HEX;\n");
	printf("CONTENT BEGIN\n");

	FILE* pf = _wfopen(argv[1],_T("r"));
	unsigned char rbuf[4096];
	fread(rbuf,1,4096,pf);

	for(int i=0; i<4096; i++)
	{
		printf("%04X : %02X;\n",i,rbuf[i]);
	}
	
	fclose(pf);

	printf("END\n");
	*/

	printf("WIDTH = 16;\n");
	printf("DEPTH = 8192;\n\n");
	printf("ADDRESS_RADIX = HEX;\n");
	printf("DATA_RADIX = HEX;\n");
	printf("CONTENT BEGIN\n");

	for(int i=0; i<1024*8; i++)
	{
		if( (i&0xF)==0)
			printf("%04X : %04X;\n",i,0x0034);
		else
			printf("%04X : %04X;\n",i,0x0032);
	}
	
	printf("END\n");
	return 0;
}


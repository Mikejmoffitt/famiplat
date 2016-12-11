#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

size_t rle_decomp(FILE *fin, FILE *fout)
{
	size_t bytes = 0;
	int current[2];
	int count = 0;
	while (!feof(fin))
	{
		current[0] = fgetc(fin);
		if (current[0] == EOF || current[1] == EOF || count == EOF)
		{
			return bytes;
		}
		current[1] = fgetc(fin);
		count = fgetc(fin);

		for (unsigned int i = 0; i < count; i++)
		{
			fputc(current[0], fout);
			fputc(current[1], fout);
			bytes += 2;
		}
	}
	return bytes;
}

int main(int argc, char **argv)
{
	FILE *fin;
	FILE *fout;
	size_t insize;
	size_t outsize;

	if (argc < 2)
	{
		printf("Usage: %s inFILE [outFILE]\n", argv[0]);
		return 0;
	}

	fin = fopen(argv[1],"rb");
	if (!fin)
	{
		fprintf(stderr, "Couldn't open %s for reading. Abort.\n", argv[1]);
		return 1;
	}

	fout = (argc > 2 ? fopen(argv[2],"wb") : stdout);
	if (!fout)
	{
		fprintf(stderr, "Couldn't open FILE handle for writing. Abort.\n");
		fclose(fin);
		return 1;
	}

	fseek(fin, 0L, SEEK_END);
	insize = ftell(fin);
	fseek(fin, 0L, SEEK_SET);

	outsize = rle_decomp(fin, fout);

	fclose(fin);
	fclose(fout);

	printf("%zu bytes in\n%zu bytes out\n", insize, outsize);
		
	return 0;
}

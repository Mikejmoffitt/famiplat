#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

size_t rle_comp(FILE *fin, FILE *fout)
{
	size_t bytes = 0;
	uint8_t count;
	uint16_t current[2];

	current[0] = fgetc(fin);
	current[1] = fgetc(fin);
	count = 1;


	while (!feof(fin))
	{
		int in1 = fgetc(fin);
		int in2 = fgetc(fin);

		if (in1 == EOF || in2 == EOF)
		{
			fputc(current[0], fout);
			fputc(current[1], fout);
			fputc(count, fout);
			bytes += 3;
			return bytes;
		}

		if ((count < 255) && in1 == current[0] && in2 == current[1])
		{
			count++;
		}
		else
		{
			fputc(current[0], fout);
			fputc(current[1], fout);
			fputc(count, fout);
			bytes += 3;

			current[0] = in1;
			current[1] = in2;
			count = 1;
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

	outsize = rle_comp(fin, fout);

	fclose(fin);
	fclose(fout);

	printf("%zu bytes in\n%zu bytes out\n", insize, outsize);
		
	return 0;
}

// Copyright 2011 Lucas Teixeira
// This software is distribuited under the terms of the GNU Lesser Public License.
// See license.txt for more information.
//
// Auhtor: Lucas Teixeira
// Email: loteixeira at gmail dot com


#include <math.h>
#include <string.h>
#include <stdio.h>
#include <time.h>
#include <AS3.h>

typedef unsigned char byte;
typedef unsigned int uint;

typedef struct
{
	int alive;
	double x, y;
	double offset;
	uint life, duration;
	double red, green, blue, alpha;
	uint resultRed, resultGreen, resultBlue;
} particle;

uint sourceWidth, sourceHeight;
byte* sourceBytes;
uint stageWidth, stageHeight;
byte* output;
uint particleCreation, particleDuration, creationCount, maxParticles;
double startRed, startGreen, startBlue, endRed, endGreen, endBlue;
uint startX, startY;
int creationRadius;

particle* particles;
uint usedParticles;
uint creationAccum;

void addParticle()
{
	uint i, count = 0;
	
	for (i = 0; i < maxParticles; i++)
	{
		if (particles[i].alive == 0)
		{
			particles[i].alive = 1;
			particles[i].life = 0;
			
			double xOffset = (double) ((creationRadius / 2) - (rand() % creationRadius));
			
			particles[i].x = ((double) startX) + xOffset;
			particles[i].y = (double) (startY + (2 - (rand() % 4)));
			particles[i].offset = xOffset;
			
			count++;
			usedParticles++;
			
			if (count == creationCount)
				break;
		}
	}
}

AS3_Val setStageDimension(void* self, AS3_Val args)
{
	AS3_ArrayValue(args, "IntType, IntType, AS3ValType", &stageWidth, &stageHeight);
	output = (byte*) malloc(stageWidth * stageHeight * 4);
	return AS3_Ptr(output);
}

AS3_Val setSourceBitmap(void* self, AS3_Val args)
{
	AS3_Val byteBuffer;
	AS3_ArrayValue(args, "IntType, IntType, AS3ValType", &sourceWidth, &sourceHeight, &byteBuffer);
	
	sourceBytes = (byte*) malloc(sourceWidth * sourceHeight * 4);
	AS3_ByteArray_readBytes(sourceBytes, byteBuffer, sourceWidth * sourceHeight * 4);
	
	return AS3_Null();
}

AS3_Val setParticleData(void* self, AS3_Val args)
{
	uint i;

	AS3_ArrayValue(args, "IntType, IntType, IntType, IntType, DoubleType, DoubleType, DoubleType, DoubleType, DoubleType, DoubleType, IntType, IntType, IntType", &particleCreation, &particleDuration, &creationCount, &maxParticles, &startRed, &startGreen, &startBlue, &endRed, &endGreen, &endBlue, &startX, &startY, &creationRadius);
	
	srand(time(NULL));

	usedParticles = 0;
	particles = (particle*) malloc(maxParticles * sizeof(particle));
	
	for (i = 0; i < maxParticles; i++)
	{
		particles[i].alive = 0;
		particles[i].x = particles[i].y = 0.0;
		particles[i].offset = 0.0;
		particles[i].life = 0;
		particles[i].duration = particleDuration + (particleDuration / 8) - (rand() % (particleDuration / 4));
		particles[i].red = startRed;
		particles[i].green = startGreen;
		particles[i].blue = startBlue;
		particles[i].alpha = 1.0;
	}
	
	return AS3_Null();
}

AS3_Val getUsedParticles(void* self, AS3_Val args)
{
	return AS3_Int(usedParticles);
}

AS3_Val update(void* self, AS3_Val args)
{
	uint interval, p, i;
	AS3_ArrayValue(args, "IntType", &interval);
	
	creationAccum += interval;
	
	// particle creation
	if (creationAccum >= particleCreation)
	{
		uint times = creationAccum / particleCreation;
		creationAccum = creationAccum % particleCreation;
		
		for (p = 0; p < times; p++)
			addParticle();
	}
	
	// particle update
	double diffRed = endRed - startRed;
	double diffGreen = endGreen - startGreen;
	double diffBlue = endBlue - startBlue;

	double time = ((double) interval) / 1000.0;
	double startXd = (double) startX;
	
	for (i = 0; i < maxParticles; i++)
	{
		if (particles[i].alive == 1)
		{
			if (particles[i].life >= particles[i].duration)
			{
				particles[i].alive = 0;
				usedParticles--;
			}
			else
			{
				double speedX = (particles[i].offset * time / 2) + (double) (2 - (rand() % 5));
				double speedY = 100.0 * time;
				speedY += (double) (rand() % (((int) speedY / 2) + 1));
				
				particles[i].life += interval;
				particles[i].x += speedX;
				particles[i].y -= speedY;
				particles[i].offset = startXd - particles[i].x;

				double clampLife = ((double) particles[i].life) / ((double) particles[i].duration);
				
				if (clampLife > 1.0)
					clampLife = 1.0;

				particles[i].red = startRed + diffRed * clampLife;
				particles[i].green = startGreen + diffGreen * clampLife;
				particles[i].blue = startBlue + diffBlue * clampLife;
				particles[i].alpha = 1.0 - clampLife;
				
				particles[i].resultRed = (uint) (particles[i].red * particles[i].alpha * 255.0);
				particles[i].resultGreen = (uint) (particles[i].green * particles[i].alpha * 255.0);
				particles[i].resultBlue = (uint) (particles[i].blue * particles[i].alpha * 255.0);
			}
		}
	}

	return AS3_Null();
}

AS3_Val render(void* self, AS3_Val args)
{
	uint i, j, k;

	for (i = 0; i < maxParticles; i++)
	{
		if (particles[i].alive == 0)
			continue;
	
		uint x = (uint) particles[i].x;
		uint y = (uint) particles[i].y;

		for (j = 0; j < sourceWidth; j++)
		{
			for (k = 0; k < sourceHeight; k++)
			{
				uint source_index = (k * sourceWidth + j) * 4;					
				
				if (sourceBytes[source_index] == 0)
					continue;
				
				uint output_index = ((k + y) * stageWidth + (j + x)) * 4;

				uint resultRed = output[output_index + 2] + (sourceBytes[source_index + 1] * particles[i].resultRed) / 255;
				uint resultGreen = output[output_index + 1] + (sourceBytes[source_index + 2] * particles[i].resultGreen) / 255;
				uint resultBlue = output[output_index] + (sourceBytes[source_index + 3] * particles[i].resultBlue) / 255;

				output[output_index] = resultBlue > 0xff ? 0xff : resultBlue;
				output[output_index + 1] = resultGreen > 0xff ? 0xff : resultGreen;
				output[output_index + 2] = resultRed > 0xff ? 0xff : resultRed;
			}
		}
	}

	return AS3_Null();
}

int main()
{
	// define the methods exposed to ActionScript
	AS3_Val setStageDimensionFunction = AS3_Function(NULL, setStageDimension);
	AS3_Val setSourceBitmapFunction = AS3_Function(NULL, setSourceBitmap);
	AS3_Val setParticleDataFunction = AS3_Function(NULL, setParticleData);
	AS3_Val getUsedParticlesFunction = AS3_Function(NULL, getUsedParticles);
	AS3_Val updateFunction = AS3_Function(NULL, update);
	AS3_Val renderFunction = AS3_Function(NULL, render);

	// construct an object that holds references to the functions
	AS3_Val result = AS3_Object("setStageDimension: AS3ValType, setSourceBitmap: AS3ValType, setParticleData: AS3ValType, getUsedParticles: AS3ValType, update: AS3ValType, render: AS3ValType", setStageDimensionFunction, setSourceBitmapFunction, setParticleDataFunction, getUsedParticlesFunction, updateFunction, renderFunction);

	// release references
	AS3_Release(setStageDimensionFunction);
	AS3_Release(setSourceBitmapFunction);
	AS3_Release(setParticleDataFunction);
	AS3_Release(getUsedParticlesFunction);
	AS3_Release(updateFunction);
	AS3_Release(renderFunction);

	// notify that we initialized -- THIS DOES NOT RETURN!
	AS3_LibInit(result);

	return 0;
}
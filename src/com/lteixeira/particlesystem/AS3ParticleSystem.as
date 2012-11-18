// Copyright 2011 Lucas Teixeira
// This software is distribuited under the terms of the GNU Lesser Public License.
// See license.txt for more information.
//
// Auhtor: Lucas Teixeira
// Email: loteixeira at gmail dot com


package com.lteixeira.particlesystem {

	import flash.display.BitmapData;
	import flash.geom.Rectangle;

	/**
	 * @author lteixeira
	 */
	public class AS3ParticleSystem extends ParticleSystemController {
		
		private var creationAccum:uint;
		private var particles:Array;
		private var usedParticles:uint;
		private var clearRect:Rectangle;
		
		public function AS3ParticleSystem(stageWidth:uint, stageHeight:uint, bitmapData:BitmapData, particleCreation:uint, particleDuration:uint, creationCount:uint, maxParticles:uint, startColor:Object, endColor:Object, startX:uint, startY:uint, creationRadius:int) {
			super(stageWidth, stageHeight, bitmapData, particleCreation, particleDuration, creationCount, maxParticles, startColor, endColor, startX, startY, creationRadius);
			
			creationAccum = 0;
			usedParticles = 0;
			createParticlesArray();
			
			clearRect = new Rectangle(0, 0, stageWidth, stageHeight);
		}
		
		private function createParticlesArray():void {
			particles = new Array();
			
			for (var i:uint = 0; i < maxParticles; i++) {
				particles.push(new AS3Particle(particleDuration, startColor));
			}
		}
		
		private function addParticle():void {
			var count:uint = 0;

			for (var i:uint = 0; i < maxParticles; i++) {
				var particle:AS3Particle = particles[i];
				
				if (!particle.alive) {
					particle.alive = true;
					particle.life = 0;
					
					var xOffset:Number = (creationRadius / 2) - Math.random() * creationRadius;
					
					particle.x = startX + xOffset;
					particle.y = startY + (2 - Math.random() * 4);
					
					particle.offset = xOffset;
					
					count++;
					usedParticles++;
					
					if (count == creationCount)
						break;
				}
			}
		}
		
		public override function getRenderer():String {
			return "Flash/Actionscript3";
		}
		
		public override function getUsedParticles():uint {
			return usedParticles;
		}
		
		public override function update(interval:uint):void {
			// particle creation
			creationAccum += interval;

			if (creationAccum >= particleCreation) {
				var times:int = creationAccum / particleCreation;
				creationAccum = creationAccum % particleCreation;
				
				for (var p:uint = 0; p < times; p++)
					addParticle();
			}
			
			// particle update
			for (var i:uint = 0; i < maxParticles; i++) {
				var particle:AS3Particle = particles[i];
				
				if (particle.alive) {
					if (particle.life >= particle.duration) {
						particle.alive = false;
						usedParticles--;
					} else {
						var speedX:Number = particle.offset * Number(interval / 1000.0) / 2;
						speedX += 2 - Math.random() * 4; 
						
						var speedY:Number = 100 * Number(interval / 1000.0);
						speedY += Math.random() * (speedY / 4);
						
						particle.life += interval;
						particle.x += speedX;
						particle.y -= speedY;
						particle.offset = Number(startX - particle.x);
						
						var clampLife:Number = particle.life / particle.duration;
						
						if (clampLife > 1.0)
							clampLife = 1.0;

						particle.red = startColor.red + (endColor.red - startColor.red) * clampLife;
						particle.green = startColor.green + (endColor.green - startColor.green) * clampLife;
						particle.blue = startColor.blue + (endColor.blue - startColor.blue) * clampLife;
						particle.alpha = 1.0 - clampLife;
					}
				}
			}
		}
		
		public override function render(destination:BitmapData):void {
			destination.fillRect(clearRect, 0);
			
			for (var i:uint = 0; i < maxParticles; i++) {
				if (particles[i].alive) {
					var x:uint = particles[i].x;
					var y:uint = particles[i].y;
						
					var particleRed:Number = particles[i].red * particles[i].alpha;
					var particleGreen:Number = particles[i].green * particles[i].alpha;
					var particleBlue:Number = particles[i].blue * particles[i].alpha;
					
					for (var j:uint = 0; j < bitmapData.width; j++) {
						for (var k:uint = 0; k < bitmapData.height; k++) {
							var sourcePixel:uint = bitmapData.getPixel32(j, k);
							var destPixel:uint = destination.getPixel(x + j, y + k);
							
							var sourceAlpha:uint = sourcePixel >> 24 & 0xFF;
							var sourceRed:uint = sourcePixel >> 16 & 0xFF;
							var sourceGreen:uint = sourcePixel >> 8 & 0xFF;
							var sourceBlue:uint = sourcePixel & 0xFF;
							
							var destRed:uint = destPixel >> 16 & 0xFF;
							var destGreen:uint = destPixel >> 8 & 0xFF;
							var destBlue:uint = destPixel & 0xFF;
							
							var clampAlpha:Number = sourceAlpha / 255.0;
							var resultRed:uint = destRed + sourceRed * clampAlpha * particleRed;
							var resultGreen:uint = destGreen + sourceGreen * clampAlpha * particleGreen;
							var resultBlue:uint = destBlue + sourceBlue * clampAlpha * particleBlue;
							
							if (resultRed > 0xff)
								resultRed = 0xff;
							if (resultGreen > 0xff)
								resultGreen = 0xff;
							if (resultBlue > 0xff)
								resultBlue = 0xff;
							
							var result:uint = (resultRed << 16 | resultGreen << 8 | resultBlue);
							destination.setPixel(x + j, y + k, result);
						}
					}
				}
			}
		}
		
	}
}

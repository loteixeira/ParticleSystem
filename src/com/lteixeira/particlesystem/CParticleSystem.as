// Copyright 2011 Lucas Teixeira
// This software is distribuited under the terms of the GNU Lesser Public License.
// See license.txt for more information.
//
// Auhtor: Lucas Teixeira
// Email: loteixeira at gmail dot com


package com.lteixeira.particlesystem {
	
	import cmodule.CParticleSystem.CLibInit;
	
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	/**
	 * @author lteixeira
	 */
	public class CParticleSystem extends ParticleSystemController {
		
		private var cInterface:Object;
		private var mem:ByteArray;
		private var outputPointer:int;
		private var copyRect:Rectangle;
		private var blankBytes:ByteArray;
		
		public function CParticleSystem(stageWidth:uint, stageHeight:uint, bitmapData:BitmapData, particleCreation:uint, particleDuration:uint, creationCount:uint, maxParticles:uint, startColor:Object, endColor:Object, startX:uint, startY:uint, creationRadius:int) {
			super(stageWidth, stageHeight, bitmapData, particleCreation, particleDuration, creationCount, maxParticles, startColor, endColor, startX, startY, creationRadius);

			cInterface = (new CLibInit()).init();			
			var ns:Namespace = new Namespace("cmodule.CParticleSystem");
			mem = (ns::gstate).ds;
			
			copyRect = new Rectangle(0, 0, stageWidth, stageHeight);
			
			// initialize cpp particle system
			outputPointer = cInterface.setStageDimension(stageWidth, stageHeight);

			var sourceBytes:ByteArray = bitmapData.getPixels(new Rectangle(0, 0, bitmapData.width, bitmapData.height));
			sourceBytes.position = 0;
			cInterface.setSourceBitmap(bitmapData.width, bitmapData.height, sourceBytes);
			cInterface.setParticleData(particleCreation, particleDuration, creationCount, maxParticles, startColor.red, startColor.green, startColor.blue, endColor.red, endColor.green, endColor.blue, startX, startY, creationRadius);
			
			var blankData:BitmapData = new BitmapData(stageWidth, stageHeight, true, 0);
			blankBytes = blankData.getPixels(copyRect);
		}
		
		public override function getRenderer():String {
			return "Alchemy/C";
		}
		
		public override function getUsedParticles():uint {
			return cInterface.getUsedParticles();
		}
		
		public override function update(interval:uint):void {
			cInterface.update(interval);
		}
		
		public override function render(destination:BitmapData):void {
			mem.position = outputPointer;
			mem.writeBytes(blankBytes);
			cInterface.render();
			mem.position = outputPointer;
			destination.setPixels(copyRect, mem);
		}
		
	}
}

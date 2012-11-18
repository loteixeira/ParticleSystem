// Copyright 2011 Lucas Teixeira
// This software is distribuited under the terms of the GNU Lesser Public License.
// See license.txt for more information.
//
// Auhtor: Lucas Teixeira
// Email: loteixeira at gmail dot com


package com.lteixeira.particlesystem {
	
	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	/**
	 * @author lteixeira
	 */
	public class ParticleSystemController {
		
		protected var stageWidth:uint, stageHeight:uint;
		protected var bitmapData:BitmapData;
		protected var particleCreation:uint, particleDuration:uint, maxParticles:uint, creationCount:uint;
		protected var startColor:Object, endColor:Object;
		protected var startX:uint, startY:uint;
		protected var creationRadius:int;
		
		public function ParticleSystemController(stageWidth:uint, stageHeight:uint, bitmapData:BitmapData, particleCreation:uint, particleDuration:uint, creationCount:uint, maxParticles:uint, startColor:Object, endColor:Object, startX:uint, startY:uint, creationRadius:int) {
			this.stageWidth = stageWidth;
			this.stageHeight = stageHeight;
			this.bitmapData = bitmapData;
			this.particleCreation = particleCreation;
			this.particleDuration = particleDuration;
			this.maxParticles = maxParticles;
			this.creationCount = creationCount;
			this.startColor = startColor;
			this.endColor = endColor;
			this.startX = startX;
			this.startY = startY;
			this.creationRadius = creationRadius;
		}
		
		public function getRenderer():String {
			return "";
		}
		
		public function getUsedParticles():uint {
			return 0;
		}
		
		public function update(interval:uint):void {
		}

		public function render(destination:BitmapData):void {
		}
		
	}
}

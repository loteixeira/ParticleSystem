// Copyright 2011 Lucas Teixeira
// This software is distribuited under the terms of the GNU Lesser Public License.
// See license.txt for more information.
//
// Auhtor: Lucas Teixeira
// Email: loteixeira at gmail dot com


package com.lteixeira.particlesystem {

	import flash.geom.Point;

	/**
	 * @author lteixeira
	 */
	public class AS3Particle {
		
		public var alive:Boolean;
		public var x:Number, y:Number;
		public var offset:Number;
		public var life:uint;
		public var duration:uint;
		public var red:Number, green:Number, blue:Number, alpha:Number;
		
		public function AS3Particle(defaultDuration:uint, startColor:Object) {
			alive = false;
			x = y = 0;
			offset = 0;
			life = 0;
			duration = defaultDuration + ((defaultDuration / 8) - Math.random() * (defaultDuration / 4));
			red = startColor.red;
			green = startColor.green;
			blue = startColor.blue;
			alpha = 1.0;
		}
		
	}
}

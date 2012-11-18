// Copyright 2011 Lucas Teixeira
// This software is distribuited under the terms of the GNU Lesser Public License.
// See license.txt for more information.
//
// Auhtor: Lucas Teixeira
// Email: loteixeira at gmail dot com


package com.lteixeira.particlesystem {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getDefinitionByName;
	import flash.utils.getTimer;
	
	/**
	 * @author lteixeira
	 */
	public class ParticleSystemMain extends Sprite {
		
		private var fpsTextField:TextField, particlesTextField:TextField, rendererTextField:TextField, timeTextField:TextField;
		private var switchTextField:TextField;
		private var particleSystem:ParticleSystemController;
		private var as3ParticleSystem:AS3ParticleSystem, cParticleSystem:CParticleSystem;
		
		private var lastFpsUpdate:uint, fpsCount:uint, lastFps:uint;
		private var lastPsUpdate:uint;
		private var averageTime:uint;
		
		private var output:Bitmap;
		private var bitmapData:BitmapData;
		
		public function ParticleSystemMain() {
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void {
			// initialize time controlling
			fpsCount = lastFps = 0;
			lastFpsUpdate = lastPsUpdate = getTimer();
			averageTime = 0;
			
			// convert particle sprite to bitmap data
			var s:Sprite = new (getDefinitionByName("com.lteixeira.particlesystem.ParticleSprite"))();
			var particleBitmapData:BitmapData = new BitmapData(s.width, s.height, true, 0x00000000);
			particleBitmapData.draw(s);
			
			// create particle system manager object
			var startX:uint = stage.stageWidth / 2;
			var startY:uint = stage.stageHeight - stage.stageHeight / 6;
			var startColor:Object = { red: 1.0, green: 0.0, blue: 0.0 };
			var endColor:Object = { red: 1.0, green: 1.0, blue: 0.0 }
			createParticleSystem(stage.stageWidth, stage.stageHeight, particleBitmapData, 10, 1750, 2, 370, startColor, endColor, startX, startY, 100);
		
			// create render environment 
			output = new Bitmap(new BitmapData(stage.stageWidth, stage.stageHeight, false, 0x000000));
			bitmapData = output.bitmapData;
			addChild(output);
			
			// create text fields
			createTextFields();
			
			// listen events
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function createParticleSystem(stageWidth:int, stageHeight:int, bitmapData:BitmapData, particleCreation:uint, particleDuration:uint, creationCount:uint, maxParticles:uint, startColor:Object, endColor:Object, startX:uint, startY:uint, creationRadius:int):void {
			as3ParticleSystem = new AS3ParticleSystem(stageWidth, stageHeight, bitmapData, particleCreation, particleDuration, creationCount, maxParticles, startColor, endColor, startX, startY, creationRadius);
			cParticleSystem = new CParticleSystem(stageWidth, stageHeight, bitmapData, particleCreation, particleDuration, creationCount, maxParticles, startColor, endColor, startX, startY, creationRadius);
			
			particleSystem = as3ParticleSystem;
		}
		
		private function createTextFields():void {
			fpsTextField = new TextField();
			fpsTextField.x = 8;
			fpsTextField.y = 8;
			fpsTextField.width = 172;
			fpsTextField.height = 20;
			fpsTextField.selectable = false;
			addChild(fpsTextField);

			particlesTextField = new TextField();
			particlesTextField.x = 8;
			particlesTextField.y = 28;
			particlesTextField.width = 172;
			particlesTextField.height = 20;
			particlesTextField.selectable = false;
			addChild(particlesTextField);
			
			rendererTextField = new TextField();
			rendererTextField.x = 8;
			rendererTextField.y = 48;
			rendererTextField.width = 600;
			rendererTextField.height = 20;
			rendererTextField.selectable = false;
			addChild(rendererTextField);
			
			timeTextField = new TextField();
			timeTextField.x = 8;
			timeTextField.y = 68;
			timeTextField.width = 600;
			timeTextField.height = 20;
			timeTextField.selectable = false;
			addChild(timeTextField);
			
			switchTextField = new TextField();
			switchTextField.x = 8;
			switchTextField.y = 88;
			switchTextField.width = 600;
			switchTextField.height = 20;
			switchTextField.selectable = false;
			switchTextField.addEventListener(TextEvent.LINK, onLinkClick);
			addChild(switchTextField);
			
			var textFormat:TextFormat = new TextFormat();
			textFormat.color = 0xffffff;
			textFormat.font = "_typewriter";
			textFormat.size = 13;
			
			fpsTextField.defaultTextFormat = textFormat;
			particlesTextField.defaultTextFormat = textFormat;
			rendererTextField.defaultTextFormat = textFormat;
			timeTextField.defaultTextFormat = textFormat;
			switchTextField.defaultTextFormat = textFormat;
			
			fpsTextField.text = "FPS: 60";
			particlesTextField.text = "Particles: 0";
			rendererTextField.text = "Renderer: " + particleSystem.getRenderer();
			timeTextField.text = "Render iteration: 0 millisecond(s)";
			switchTextField.htmlText = "Click <u><a href='event:switchRenderer'>here</a></u> to switch renderer";
		}
		
		private function onLinkClick(event:TextEvent):void {
			if (particleSystem == as3ParticleSystem)
				particleSystem = cParticleSystem;
			else
				particleSystem = as3ParticleSystem;
		}
		
		private function onEnterFrame(event:Event):void {
			var now:uint = getTimer();
			var start:uint, end:uint;
			
			// update fps counting
			if (now - lastFpsUpdate >= 1000) {
				lastFps = fpsCount;
				fpsCount = 0;
				lastFpsUpdate = now;
				fpsTextField.text = "FPS: " + lastFps;
				particlesTextField.text = "Particles: " + particleSystem.getUsedParticles();
				rendererTextField.text = "Renderer: " + particleSystem.getRenderer();
				timeTextField.text = "Render iteration: " + averageTime + " ms";
			} else {
				fpsCount++;
			}

			// update particle system	
			particleSystem.update(now - lastPsUpdate);
			lastPsUpdate = now;
			
			// render particle system
			bitmapData.lock();
			start = getTimer();
			particleSystem.render(bitmapData);
			end = getTimer();
			bitmapData.unlock();
			
			averageTime = end - start;
		}
		
	}

}

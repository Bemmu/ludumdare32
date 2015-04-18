package b;

import flash.display.*;
import flash.filters.*;
import flash.events.*;
import flash.geom.*;
import flash.utils.*;
import flash.ui.*;
import flash.media.*;

typedef AnimationDefinition = {
	gridX : Int,
	gridY : Int,
	frames : Int,
	ticksPerFrame : Int
}

class Blob {
	static var sheet:BitmapData;
	static var defs:Map<String, AnimationDefinition> = new Map();
	public var currentAnimation:AnimationDefinition = null;
	public var ticks = 0;
	public var currentFrameInAnimation = 0;
	static var grid:{w:Int, h:Int} = {w:32, h:32};
	public var x = 100;
	public var y = 100;
	public var xx = 100.0;
	public var yy = 100.0;
	public var flipped = false;

	public static function setSheet(sheet) {
		Blob.sheet = sheet;
	}

	public static function defineAnimation(name, gridX, gridY, frames, ticksPerFrame) {
		defs[name] = {gridX:gridX, gridY:gridY, frames:frames, ticksPerFrame:ticksPerFrame};
	}

	public function anim(name:String) {
		if (defs.exists(name)) {
			currentAnimation = defs[name];
			currentFrameInAnimation = 0;
			ticks = 0;
		} else {
			trace("No such animation " + name);
		}
	}

	public static function setGrid(w:Int, h:Int) {
		grid.w = w;
		grid.h = h;
	}

	public function tick() {
		ticks++;
		if (ticks >= currentAnimation.ticksPerFrame) {
			currentFrameInAnimation++;
			if (currentFrameInAnimation >= currentAnimation.frames) {
				currentFrameInAnimation = 0;
			}
			ticks = 0;
		}
	}

	public function new() {
	}

	public function draw(buffer:BitmapData, ?blendMode:BlendMode) {
		if (currentAnimation == null) {
			trace("Define some animations and call .anim() before calling .draw()");
			return;
		}

		var flipBD = new BitmapData(grid.w, grid.h);

		var m:Matrix;
		if (flipped) {
			m = new Matrix(-1, 0, 0, 1, grid.w, 0);
		} else {
			m = new Matrix();
		}
		m.translate(x, y);

		x = Math.round(xx);
		y = Math.round(yy);
		flipBD.copyPixels(
			sheet, 
//			new Rectangle(0, 0, grid.w, grid.h),
			new Rectangle((currentAnimation.gridX + currentFrameInAnimation) * grid.w, currentAnimation.gridY * grid.h, grid.w, grid.h),
			new Point(0, 0)
		);
		buffer.draw(flipBD, m, null, blendMode);
	}
}
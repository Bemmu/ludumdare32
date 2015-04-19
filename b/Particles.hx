package b;

import flash.display.*;
import flash.filters.*;
import flash.events.*;
import flash.geom.*;
import flash.utils.*;
import flash.ui.*;
import flash.media.*;

class Particle {
	public var x = 100.0;
	public var y = 100.0;
	public var xs = 0.0;
	public var ys = 0.0;
	public var gravity = 0.00;
	public var lifetime = 100;
	public var friction = 0.98;
	public var bitmapName = "pixel";
	public var rotation = 0.;
	public var rotationSpeed = 0.;
	public var rotationFriction = 0.;
	public var floorY = 200;

	public function new() {
	}
}

class Particles {
	public var scale = 0.1;
	var all = new Array<Particle>();
	var bitmaps = new Map<String, BitmapData>();

	public function new() {
	}

	public function makeParticle() {
		for (p in all) {
			if (p.lifetime == 0) {
				return p;
			}
		}

		var p = new Particle();
		all.push(p);
		return p;
	}

	public function setBitmap(name:String, bd:BitmapData) {
		bitmaps[name] = bd;
	}

	public function reset() {
		all = [];
	}

	public function burst(x:Float = 100, y:Float = 100, direction:Float = 0, directionVariance:Float = 3.1415*1.5, speed:Float = 1, speedVariance:Float = 0.5, count:Int = 5, floorY:Int = 200, gravity:Float = 0.08) {
		for (i in 0...count) {
			var p = makeParticle();
			var a = direction + (Math.random()+Math.random()+Math.random()+Math.random()+Math.random()+Math.random()+Math.random()+Math.random())/8.0 * directionVariance - directionVariance/2.0;

			var s = speed + (Math.random()+Math.random()+Math.random()+Math.random()+Math.random()+Math.random()+Math.random()+Math.random())/8.0 * speedVariance;
			p.xs = Math.cos(a) * s;
			p.ys = Math.sin(a) * s;
			p.x = x + Math.random() * 32 -16;
			p.y = y + Math.random() * 32 -16;
			p.lifetime = 100 + Std.int(Math.random() * 100);
			p.floorY = floorY + Std.int(Math.random() * 5);

			p.gravity = gravity;
//			trace(gravity);
			p.ys -= 2.0;

			p.rotationSpeed = 0.05;
			p.rotationFriction = 1.0;
		}
	}

	public function draw(bd:BitmapData) {
		var m = new Matrix();
		for (p in all) {
			if (p.lifetime == 0) {
				continue;
			}

			if (bitmaps.exists(p.bitmapName)) {
				var pbd = bitmaps[p.bitmapName];
				m.identity();
				m.translate(-pbd.width*0.5, -pbd.height*0.5);

				var lifetimeScale = Math.min(p.lifetime, 100.0) * 0.01;				
				m.scale(lifetimeScale * scale, lifetimeScale * scale);

				m.rotate(p.rotation);
				m.translate(p.x, p.y);
				bd.draw(pbd, m);
			} else {
				bd.setPixel32(Std.int(p.x), Std.int(p.y), 0xffff0000);
			}
		}
	}

	public function tick(stainBD:BitmapData) {
		for (p in all) {
			p.rotation += p.rotationSpeed;
			p.rotationSpeed *= p.rotationFriction;

			p.x += p.xs;
			p.y += p.ys;
			if (p.lifetime > 0) {
				p.lifetime--;
				if (stainBD != null && p.lifetime == 0) {
					var m = new Matrix();
					if (bitmaps.exists(p.bitmapName)) {
						var pbd = bitmaps[p.bitmapName];
						m.identity();
						m.translate(-pbd.width*0.5, -pbd.height*0.5);

						var lifetimeScale = Math.min(p.lifetime, 100.0) * 0.01;				
						m.scale(lifetimeScale * scale, lifetimeScale * scale);

						m.rotate(p.rotation);
						m.translate(p.x, p.y);
						stainBD.draw(pbd, m);
					} else {
						stainBD.setPixel32(Std.int(p.x), Std.int(p.y), 0xffff0000);
					}
				}
			}

			p.xs *= p.friction;
			p.ys *= p.friction;
			p.ys += p.gravity;

			if (p.y > p.floorY) {
				p.ys *= -0.98 * Math.random();
			}
		}
	}
}
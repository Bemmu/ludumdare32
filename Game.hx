import flash.display.*;
import flash.filters.*;
import flash.events.*;
import flash.geom.*;
import flash.utils.*;
import flash.ui.*;
import flash.media.*;
import b.*;
import en.*;

@:bitmap("sheet.png") class Sheet extends flash.display.BitmapData {}
@:bitmap("logo.png") class Logo extends flash.display.BitmapData {}
@:bitmap("particle.png") class ParticlePNG extends flash.display.BitmapData {}

class Game {
	var buffer:BitmapData = new BitmapData(300, 200, false, 0xff00ff00);
	var particleBD:BitmapData = new BitmapData(300, 200, true, 0x00000000);
	var display:BitmapData = new BitmapData(900, 600, false, 0xff00ff00);
	var overlayBD:BitmapData = new BitmapData(900, 600, false, 0xff00ff00);
	var logo = new Logo(0,0);

	var frames = 0;
	var fpsCountStart = 0.0;
	var blob:Blob = null;
	var dx = 1;
	var particles:Particles = null;

	var channel:SoundChannel;
	var sheet = new Sheet(0,0);
	var ents:Array<Entity> = new Array();
	var boy:Entity;

	function restartGame() {
		ents = [];
		boy = new Boy();
		boy.anim("idle");
		ents.push(boy);
	}

	function generateOverlay(buffer, bgColor = 0xff808080, fgColor = 0xffffffff) {
		for (x in 0...buffer.width) {
			for (y in 0...buffer.height) {
				if ((y%3) == 2) {
					buffer.setPixel32(x, y, fgColor);
				} else {
					buffer.setPixel32(x, y, bgColor);
				}
			}
		}
	}

	function refresh(e:flash.events.Event) {
		frames++;
		if (Date.now().getTime() - fpsCountStart > 1000) {
			if (fpsCountStart > 0) {
//				trace(frames + " fps");
			}
			frames = 0;
			fpsCountStart = Date.now().getTime();
		}

		buffer.fillRect(buffer.rect, 0xffffffff);
//		buffer.draw(logo);

		for (ent in ents) {
			ent.draw(buffer);
		}

		var m = new Matrix();
		m.scale(3, 3);
		display.draw(buffer, m, null, null);
		display.draw(overlayBD, null, null, OVERLAY);

	}

	public function new() {
		Blob.setSheet(sheet);
		Blob.defineAnimation("idle", 0, 0, 1, 10);
		restartGame();

		particles = new Particles();
		particles.setBitmap("pixel", new ParticlePNG(0,0));
		generateOverlay(overlayBD);

		blob = new Blob();
		blob.y = 30;
		blob.anim("walk_right");

		flash.Lib.current.addChild(new Bitmap(display));
		flash.Lib.current.stage.addEventListener(Event.ENTER_FRAME, refresh);
	}

	static function main() {
		var what = new Game();
	}
}
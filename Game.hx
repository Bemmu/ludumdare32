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
	var prevKeys:Map<Int, Bool> = new Map();
	var keys:Map<Int, Bool> = new Map();
	var buffer:BitmapData = new BitmapData(300, 200, false, 0xff00ff00);
	var particleBD:BitmapData = new BitmapData(300, 200, true, 0x00000000);
	var ground:BitmapData = new BitmapData(300, 200, true, 0x00000000);
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
	var pets:Array<Pet> = new Array();
	var boy:Boy;
	var lanes:Int;

	function adopt() {
		var pet:Pet = new Dash();
		ents.push(pet);
		pets.push(pet);
		pet.following = boy;
		pet.xx = 20;
	}

	function initGround() {
		for (y in 0...ground.height) {
			for (x in 0...ground.width) {
				ground.setPixel32(x, y, 0xffccffcc);
			}
		}
	}

	function restartGame() {
		lanes = 3;
		ents = [];
		pets = [];
		boy = new Boy();
		boy.lanes = lanes;
		ents.push(boy);
		adopt();
		initGround();
	}

	function initKeyboard() {
		flash.Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, function (e) {
			keys[e.keyCode] = true;
		});
		flash.Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, function (e) {
			keys[e.keyCode] = false;
		});
	}

	function attack(petType) {

		// Attack with pet of requested type with highest health

		var matchingPets:Array<Pet> = [];		
		for (pet in pets) {
			if (pet.petType == petType && pet.availableForAttacking()) {
				matchingPets.push(pet);
				break;
			}
		}

		if (matchingPets.length == 0) {
			trace("No " + petType + " available");
		} else {
			trace("Attacking with " + petType);
		}
	}

	function controls() {
		if (!prevKeys[Keyboard.UP] && !prevKeys[Keyboard.W] && (keys[Keyboard.UP]||keys[Keyboard.W]) ) {
			boy.trackMove(-1);
		}
		if (!prevKeys[Keyboard.DOWN] && !prevKeys[Keyboard.S] && (keys[Keyboard.DOWN]||keys[Keyboard.S]) ) {
			boy.trackMove(1);
		}

		if (!prevKeys[Keyboard.D] && keys[Keyboard.D]) {
			attack("dash");
		}

		for (key in keys.keys()) {
			prevKeys[key] = keys[key];
		}
	}

	function tick() {
		for (ent in ents) {
			ent.tick();
		}
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
		controls();
		tick();

		frames++;
		if (Date.now().getTime() - fpsCountStart > 1000) {
			if (fpsCountStart > 0) {
//				trace(frames + " fps");
			}
			frames = 0;
			fpsCountStart = Date.now().getTime();
		}

		buffer.draw(ground);

		// Draw in correct order for depth
		ents.sort(function (x:Entity, y:Entity) {
			if (x.yy == y.yy) return 0;
			if (x.yy > y.yy) return 1;
			return 0;
		});
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
		Blob.defineAnimation("boy_idle", 0, 0, 1, 10);
		Blob.defineAnimation("dash_idle", 0, 3, 1, 10);
		restartGame();

		particles = new Particles();
		particles.setBitmap("pixel", new ParticlePNG(0,0));
		generateOverlay(overlayBD);

		flash.Lib.current.addChild(new Bitmap(display));
		flash.Lib.current.stage.addEventListener(Event.ENTER_FRAME, refresh);
		initKeyboard();
	}

	static function main() {
		var what = new Game();
	}
}
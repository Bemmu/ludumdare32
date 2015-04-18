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
@:bitmap("bg.png") class BgPNG extends flash.display.BitmapData {}

class Game {
	var pt0 = new Point(0,0);
	var lightBlur = new flash.filters.BlurFilter(40,40,2);
	var prevKeys:Map<Int, Bool> = new Map();
	var keys:Map<Int, Bool> = new Map();
	var buffer:BitmapData = new BitmapData(300, 200, false, 0xff00ff00);
	var particleBD:BitmapData = new BitmapData(300, 200, true, 0x00000000);
	var ground:BitmapData = new BitmapData(300, 200, true, 0x00000000);
	var display:BitmapData = new BitmapData(900, 600, false, 0xff00ff00);
	var overlayBD:BitmapData = new BitmapData(900, 600, false, 0xff00ff00);
	var lightBD:BitmapData = new BitmapData(900, 600, false, 0xff00ff00);
	var logo = new Logo(0,0);
	var shadow = new Blob();

	var frames = 0;
	var fpsCountStart = 0.0;
	var blob:Blob = null;
	var dx = 1;
	var particles:Particles = null;

	var channel:SoundChannel;
	var sheet = new Sheet(0,0);
	var bgBD = new BgPNG(0,0);
	var ents:Array<Entity> = new Array();
	var pets:Array<Pet> = new Array();
	var mobs:Array<Mob> = new Array();
	var boy:Boy;
	var lanes:Int;

	function adopt() {
		var pet:Pet = new Dash();
		ents.push(pet);
		pets.push(pet);
		pet.master = boy;
		pet.xx = 20;
	}

	function initGround() {
		shadow = new Blob();
		shadow.anim("shadow");

		var grassiness = 16;
		var maxBladeHeight = 10;

		var bgHeight = 95;

		ground.copyPixels(bgBD, new Rectangle(390, 0, 300, bgHeight), pt0);

		for (y in bgHeight...300) {
			for (x in 0...ground.width) {
				var dark = Math.round(Math.random() * 5) * grassiness;

				var bladeHeight = Math.round(Math.random() * maxBladeHeight) + 1;

				for (h in 0...bladeHeight) {
					var r = Math.floor(Math.min(255, 0x9c - dark + h*5));
					var g = Math.floor(Math.min(255, 0xff - dark + h*5));
					var b = Math.floor(Math.min(255, 0x9c - dark + h*5));
					var c = (0xff << 24) + (r << 16) + (g << 8) + b;
					ground.setPixel32(x, y - h, c);
				}
			}
		}

		ground.applyFilter(ground, ground.rect, pt0, new flash.filters.GlowFilter(0xffffffff, 1.0, 10, 10, 2, 2, true, false));
	}

	function restartGame() {
		lanes = 3;
		ents = [];
		pets = [];
		mobs = [];
		boy = new Boy();
		boy.lanes = lanes;
		ents.push(boy);
		adopt();
		initGround();
		var mob = new Mob();
		mobs.push(mob);
		ents.push(mob);
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

			matchingPets.sort(function (x, y) {
				if (x.health == y.health) return 0;
				if (x.health > y.health) return 1;
				return -1;
			});

			var bestPet = matchingPets[0];
//			trace("Attacking with " + petType + " of health " + bestPet.health);
			bestPet.attack();


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
		if (!prevKeys[Keyboard.Q] && keys[Keyboard.Q]) {
			restartGame();
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

	function lights() {
		lightBD.fillRect(lightBD.rect, 0xff303030);
		lightBD.fillRect(new Rectangle(0, 0, lightBD.width, 95), 0xffc0c0c0);
		for (ent in ents) {
			shadow.xx = ent.xx;
			shadow.yy = ent.yy + 5;
			shadow.tick();
			shadow.draw(lightBD);
		}
		lightBD.applyFilter(lightBD, lightBD.rect, pt0, lightBlur);
		buffer.draw(lightBD, null, null, flash.display.BlendMode.HARDLIGHT);
	}

	function refresh(e:flash.events.Event) {
//		buffer.applyFilter(buffer, buffer.rect, new Point(0,0), new flash.filters.GlowFilter(0xffffffff, 1.0, 10, 10, 1.5, 2, false, false));
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
		lights();

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
//		Blob.defineAnimation("dash_idle", 0, 3, 5, 10);
//		Blob.defineAnimation("dash_run", 0, 4, 6, 3);
		Blob.defineAnimation("dash_idle", 1, 1, 3, 10);
		Blob.defineAnimation("dash_run", 1, 1, 3, 3);
		Blob.defineAnimation("shadow", 0, 2, 1, 20);
		restartGame();

		particles = new Particles();
		particles.setBitmap("pixel", new ParticlePNG(0,0));
		b.Generators.generateOverlay(overlayBD);
//		b.Generators.generateOverlay2(lightBD, 0xfff0f0f0, 0xfff0f0f0);

		flash.Lib.current.addChild(new Bitmap(display));
		flash.Lib.current.stage.addEventListener(Event.ENTER_FRAME, refresh);
		initKeyboard();
	}

	static function main() {
		var what = new Game();
	}
}
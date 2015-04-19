import flash.display.*;
import flash.filters.*;
import flash.events.*;
import flash.geom.*;
import flash.utils.*;
import flash.ui.*;
import flash.media.*;
import flash.text.*;
import b.*;
import en.*;

@:bitmap("sheet.png") class Sheet extends flash.display.BitmapData {}
@:bitmap("store.png") class StorePNG extends flash.display.BitmapData {}
@:bitmap("store2.png") class Store2PNG extends flash.display.BitmapData {}
@:bitmap("logo.png") class Logo extends flash.display.BitmapData {}
@:bitmap("particle.png") class ParticlePNG extends flash.display.BitmapData {}
@:bitmap("bg.png") class BgPNG extends flash.display.BitmapData {}

class Game {
	var pt0 = new Point(0,0);
	var lightBlur = new flash.filters.BlurFilter(4,4,2);
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
	var popups:Array<Popup> = [];
	var level = 0;
	var leaving = false;
	var frames = 0;
	var fpsCountStart = 0.0;
	var blob:Blob = null;
	var dx = 1;
	var particles:Particles = null;
	var fade:Float;
	var fadeBD:BitmapData = new BitmapData(300, 200, true, 0xff000000);
	var fadeTarget:Float;
	var channel:SoundChannel;
	var displayMoney:Float;
	var money:Float;
	var sheet = new Sheet(0,0);
	var bgBD = new BgPNG(0,0);
	var storeBD = new StorePNG(0,0);
	var store2BD = new Store2PNG(0,0);
	var ents:Array<Dynamic> = new Array();
	var pets:Array<Pet> = new Array();
	var mobs:Array<Mob> = new Array();
	var boy:Boy;
	var lanes:Int;

	var levels:Array<Dynamic> = [
		{
			"spawn" : function (ticks) {
				var freq = Std.int(Math.min(ticks/10.0, 900));
//				trace(ticks%(1000 - freq));
				if ((ticks%(1000 - freq)) == 10) {
					return "henro";
				}
				return null;
			}
		},
		{
			"shop" : "yes"
		}
	];

	function cost(petName) {
		if (petName == "cat") return Cat.cost;
		if (petName == "dog") return Dog.cost;
		if (petName == "gorilla") return Gorilla.cost;
		if (petName == "bird") return Bird.cost;
		return 999;
	}

	function adopt(petName:String, xx:Int) {

		var pet:Pet = null;
		if (petName == "cat") pet = new Cat();
		if (petName == "dog") pet = new Dog();
		if (petName == "gorilla") pet = new Gorilla();
		if (petName == "bird") pet = new Bird();

		ents.push(pet);
		pet.master = boy;
		pet.xx = pet.homeX = xx;
		pet.yOff = 4 * pets.length;
		pets.push(pet);
	}

	function popup(x:Int, y:Int, txt:String) {
		var lowest = 50.0;
		for (popup in popups) {
			if (popup.yy < lowest) {
				lowest = popup.yy;
			}
		}
//		trace(lowest);

		popups.push(new Popup(x, 50 + Std.int(50 - lowest), txt));
	}

	function info(txt:String) {
		popup(50, 50, txt);
	}

	function initGround() {
		shadow = new Blob();
		shadow.anim("shadow");

		var grassiness = 16;
		var maxBladeHeight = 10;

		var bgHeight = 95;

		ground.copyPixels(bgBD, new Rectangle(0, 0, 300, bgHeight), pt0);

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
		level = 0;
		lanes = 3;
		ents = [];
		pets = [];
		mobs = [];
		boy = new Boy();
		boy.xx = 0;
		boy.lanes = lanes;
		ents.push(boy);
		adopt("cat", 40);
		adopt("dog", 30);
		initGround();
		leaving = false;
		enteringStore = false;
		enteredStore = false;
		displayMoney = 0.0;
		money = 0.0;
		fade = 0.0;
		fadeTarget = 0.0;
	}

	function nextLevel() {
		ticks = 0;
		fadeTarget = 0;
		fade = 255;
		leaving = false;
		for (pet in pets) {
			pet.recall();
		}
		boy.xx = 0;
	}

	function spawn(mobType:String) {
		var mob:Mob = null;
		if (mobType == "henro") {
			mob = new Mob(Math.floor(Math.random() * 3));
		}
		if (mob != null) {
			mobs.push(mob);
			ents.push(mob);
		} else {
			trace("tried to spawn null mob");
		}
	}

	function closestMobOnTrack(track) {
		var closest:Mob = null;
		for (mob in mobs) {
			if (mob.track == track) {
				if (closest == null || mob.xx < closest.xx) {
					closest = mob;
				}
			}
		}
		return closest;
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
			}
		}
//		trace(matchingPets.length);

		if (matchingPets.length == 0) {
			info("No " + petType + " available");
		} else {

			matchingPets.sort(function (x, y) {
				if (x.health == y.health) return 0;
				if (x.health > y.health) return 1;
				return -1;
			});

			var bestPet = matchingPets[0];
			info(petType + " attack");

//			trace("Attacking with " + petType + " of health " + bestPet.health);
			bestPet.attack(boy.track);
		}
	}

	var enteringStore = false;
	var enteredStore = false;

	function enterStore() {
		enteringStore = true;
		info("Entering...");
	}

	function enteringTick() {
		if (boy.xx < 125) {
			boy.xx = 125 * 0.1 + boy.xx * 0.9;
//			boy.xx += 1;
		}
		if (Math.abs(boy.xx - 125) < 2) {
			boy.trackMove(-1);
		}
		if (Math.abs(boy.xx - 125) < 2 && boy.yy < 85) {
			didEnterStore();
		}
	}

	function didEnterStore() {
		enteringStore = false;
		enteredStore = true;
		boy.visible = false;
	}

	function buy(petName:String) {
		var c = cost(petName);
		if (money > c) {
			adopt(petName, 10);
			money -= c;			
			info("Bought " + petName);
		} else {
			info("Not enough money");
		}
	}

	function controls() {
		if (!prevKeys[Keyboard.UP] && !prevKeys[Keyboard.W] && (keys[Keyboard.UP]||keys[Keyboard.W]) ) {
			if (enteredStore) return;
			boy.trackMove(-1);
		}
		if (!prevKeys[Keyboard.DOWN] && !prevKeys[Keyboard.S] && (keys[Keyboard.DOWN]||keys[Keyboard.S]) ) {
			if (enteredStore) return;
			boy.trackMove(1);
		}

		if (!prevKeys[Keyboard.Q] && keys[Keyboard.Q]) {
			if (!enteredStore) return;
			info("come again soon");
			enteredStore = false;
			boy.visible = true;
		}

		if (!prevKeys[Keyboard.C] && keys[Keyboard.C]) {
			if (enteredStore) {
				buy("cat");
			} else {
				attack("cat");
			}
		}
		if (!prevKeys[Keyboard.D] && keys[Keyboard.D]) {
			if (enteredStore) {
				buy("dog");
			} else {
				attack("dog");
			}
		}
		if (!prevKeys[Keyboard.B] && keys[Keyboard.B]) {
			if (enteredStore) {
				buy("bird");
			} else {
				attack("bird");
			}
		}
		if (!prevKeys[Keyboard.G] && keys[Keyboard.G]) {
			if (enteredStore) {
				buy("gorilla");
			} else {
				attack("gorilla");
			}
		}

		if (!prevKeys[Keyboard.NUMBER_0] && keys[Keyboard.NUMBER_0]) {
			restartGame();
		}
		if (!prevKeys[Keyboard.NUMBER_1] && keys[Keyboard.NUMBER_1]) {
			if (leaving) return;
			fadeTarget = 260;
			info("leaving");
			leaving = true;
			for (pet in pets) {
				pet.attack(boy.track);
			}
		}
		if (!prevKeys[Keyboard.R] && keys[Keyboard.R]) {
			if (enteredStore) return;
			spawn("henro");
		}
		if (!prevKeys[Keyboard.T] && keys[Keyboard.T]) {
			if (enteredStore) return;
			enterStore();
		}

		for (key in keys.keys()) {
			prevKeys[key] = keys[key];
		}
	}

	function fight(mob, pet) {
		if (pet.fighting) return;
		pet.fighting = true;

		popup(mob.x, mob.y, "FIGHT");
		var txt = "FIGHT";

		var d = pet.attackStrength;
		if (Math.random() < pet.criticalLikelihood) {
			d += pet.criticalAttackStrength;
			txt = "-" + d + " CRITICAL!";
		} else {
			txt = "-" + d + " DAMAGE";
		}
		mob.damage(d);
		if (mob.died()) {
			if (Math.random() < 0.5) {
				if (pet.petType == "dog") {
					txt = "WOOFALITY";
				} 
			} else {
				txt = "SLAUGHTER";
			}
		}

		popup(mob.x, mob.y, txt);
		pet.recall();
	}

	function collisions() {
		for (pet in pets) {
			if (pet.xx > 300) {
				pet.recall();
				return;
			}
			var closest = closestMobOnTrack(pet.track);
			if (closest == null) continue;
			if (Math.abs(closest.xx - pet.xx) < 5) {
				fight(closest, pet);
			}
		}
	}

	function removeDead() {
		var removeThese:Array<Entity> = [];

		for (ent in ents) {
			if (ent.requestRemoval) {
				removeThese.push(ent);
				mobs.remove(ent);
			}
		}

		for (ent in removeThese) {
			ents.remove(ent);
		}
	}

	var ticks = 0;
	function tick() {
		ticks++;
		var spawnThis = levels[level].spawn(ticks);
		if (spawnThis != null) {
			spawn(spawnThis);
		}

		for (ent in ents) {
			ent.tick();
		}
		collisions();
		removeDead();
		if (enteringStore) {
			enteringTick();
		} else {
			if (leaving) {
				boy.xx = 350 * 0.03 + boy.xx * 0.97;
				return;
			}
			if (!enteredStore) {
				if (boy.xx > 15) {
					boy.flipped = true;
				} else {
					boy.flipped = false;
				}
				boy.xx = boy.xx * 0.96;

			}
		}
	}

	function lights() {
		lightBD.fillRect(lightBD.rect, 0xff303030);
		lightBD.fillRect(new Rectangle(0, 0, lightBD.width, 95), 0xffc0c0c0);
		for (ent in ents) {
			shadow.xx = ent.xx;
			shadow.yy = ent.yy + 6;
			shadow.tick();
			shadow.draw(lightBD, flash.display.BlendMode.HARDLIGHT);
		}
		lightBD.applyFilter(lightBD, lightBD.rect, pt0, lightBlur);
		buffer.draw(lightBD, null, null, flash.display.BlendMode.HARDLIGHT);
	}

	function drawShop(buffer:BitmapData) {
		if (enteredStore) {
			buffer.draw(store2BD);
		} else {
			buffer.draw(storeBD);
		}
	}

	function drawStatus() {
		Popup.write(buffer, 0, 0, "" + Math.floor(displayMoney) + "$", 0x999900, true);
		displayMoney = displayMoney * 0.98 + money * 0.02;
		if (Math.abs(displayMoney - money) < 2) {
			displayMoney = money;
		}
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
		drawShop(buffer);

		// Draw in correct order for depth
		ents.sort(function (x:Entity, y:Entity) {
			if (x.y == y.y) {
				if (x.x == y.x) {
					return 0;
				}
				if (x.x > y.x) return 1;
				return -1;
			}
			if (x.y > y.y) return 1;
			return -1;
		});
		for (ent in ents) {
			ent.draw(buffer);
		}

		for (popup in popups) {
			popup.tick();
			popup.draw(buffer);
			if (popup.lifetime == 0) {
				popups.remove(popup);
			}
		}

		drawStatus();

		fade = fadeTarget * 0.05 + fade * 0.95;
		if (fade > 0) {
			var c = (Std.int(Math.min(fade, 255)) << 24) + 0xffffff;
			fadeBD.fillRect(fadeBD.rect, c);
			buffer.draw(fadeBD);
		}
		if (leaving && Math.abs(fade - fadeTarget) < 2) {
			nextLevel();
		}

		var m = new Matrix();
		m.scale(3, 3);
		display.draw(buffer, m, null, null);
		display.draw(overlayBD, null, null, OVERLAY);

	}

	public function new() {
		Blob.setSheet(sheet);
		Blob.defineAnimation("boy_idle", 0, 0, 1, 10);
		Blob.defineAnimation("cat_idle", 0, 5, 3, 30);
		Blob.defineAnimation("cat_run", 1, 1, 3, 3, [null, null, null]);
		Blob.defineAnimation("dog_idle", 0, 3, 5, 15);
		Blob.defineAnimation("dog_run", 0, 4, 3, 3);
		Blob.defineAnimation("shadow", 3, 2, 1, 20);
		Blob.defineAnimation("henro_walk", 4, 1, 1, 10);
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
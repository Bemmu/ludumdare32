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

@:sound("dog_dead.mp3") class DogDeadSound extends flash.media.Sound {}
@:sound("mob_dead.mp3") class MobDeadSound extends flash.media.Sound {}
@:sound("hurt.mp3") class HurtSound extends flash.media.Sound {}
@:sound("blip.mp3") class BlipSound extends flash.media.Sound {}
@:sound("go.mp3") class GoSound extends flash.media.Sound {}
@:sound("gameover.mp3") class GameOverSound extends flash.media.Sound {}
@:sound("song1.mp3") class FirstSong extends flash.media.Sound {}
@:sound("song1.mp3") class SecondSong extends flash.media.Sound {}
@:sound("song1.mp3") class ThirdSong extends flash.media.Sound {}
@:sound("shop.mp3") class ShopSong extends flash.media.Sound {}
@:bitmap("sheet.png") class Sheet extends flash.display.BitmapData {}
@:bitmap("store.png") class StorePNG extends flash.display.BitmapData {}
@:bitmap("store2.png") class Store2PNG extends flash.display.BitmapData {}
@:bitmap("logo.png") class Logo extends flash.display.BitmapData {}
@:bitmap("bg.png") class BgPNG extends flash.display.BitmapData {}
@:bitmap("smoke.png") class SmokePNG extends flash.display.BitmapData {}

class Game {
	var gameOverText = "

   GOOD TRY! BUT...
   TOO MANY ENEMIES GOT THROUGH.

   PRESS SPACE TO TRY AGAIN.


";
	var help = "play with keyboard. W S moves up and down.\nD for dog attack. don't let enemies cross line.";
	var help2 = "Animals attack the line you are on.\nD for dog attack. C for cat attack.";

	var levelCompleteText = "

   GOOD JOB!

   PRESS SPACE TO PROCEED.
";

	var winText = "

   WELL DONE!

   YOU WIN THE GAME.
   IT WASN'T EASY, BUT YOU DID IT.

   PEOPLE SING SONGS ABOUT YOUR VICTORY
   AND EAT LETTUCE WHILE THINKING ABOUT YOU!
";

	var shopText = "PRESS D TO BUY DOG FOR $100
PRESS C TO BUY CAT FOR $1000
PRESS B TO BUY BIRD FOR $5000
PRESS G TO BUY GORILLA FOR $10000
PRESS Q WHEN DONE";

	var levelComplete = false;
	var didVisitStore = false;
	var pt0 = new Point(0,0);
	var lightBlur = new flash.filters.BlurFilter(4,4,2);
	var prevKeys:Map<Int, Bool> = new Map();
	var keys:Map<Int, Bool> = new Map();
	var buffer:BitmapData = new BitmapData(300, 200, false, 0xff00ff00);
	var particleBD:BitmapData = new BitmapData(300, 200, true, 0x00000000);
	var smokeParticleBD:BitmapData = new BitmapData(300, 200, true, 0x00000000);
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
	var smokeParticles:Particles = null;
	var fade:Float;
	var fadeBD:BitmapData = new BitmapData(300, 200, true, 0xff000000);
	var fadeTarget:Float;
	var channel:SoundChannel = null;
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
	var mobsSpawned = 0;
	var mobsKilledOrPassed = 0;

	var levels:Array<Dynamic> = [
		{
			"spawn" : function (ticks) {
				var freq = Std.int(Math.min(ticks/1.0, 990));
				if ((ticks%(1000 - freq)) == 10) {
					return "henro";
				}
				return null;
			},
			"bgOffset" : 0,
			"mobs" : 3,
			"shop" : false,
			"name" : "wave 1/3 - tokushima, japan",
			"music" : "first",
			"grassiness" : 16,
			"maxBladeHeight" : 10,
			"r" : 0x9c,
			"g" : 0xff,
			"b" : 0x9c,
			"mobName" : "henro"
		},
		{
			"spawn" : function (ticks) {
				return null;
			},
			"bgOffset" : 0,
			"shop" : true,
			"name" : "BUY WEAPONIZED PETS HERE!",
			"music" : "shop",
			"mobs" : 0,
			"grassiness" : 16,
			"maxBladeHeight" : 10,
			"r" : 0x9c,
			"g" : 0xff,
			"b" : 0x9c
		},
		{
			"spawn" : function (ticks) {
				var freq = Std.int(Math.min(ticks/5.0, 900));
				if ((ticks%(1000 - freq)) == 10) {
					return "henro";
				}
				return null;
			},
			"bgOffset" : 0,
			"mobs" : 6,
			"shop" : false,
			"name" : "wave 2/3 - tokushima, japan",
			"music" : "first",
			"grassiness" : 16,
			"maxBladeHeight" : 10,
			"r" : 0x9c,
			"g" : 0xff,
			"b" : 0x9c,
			"mobName" : "henro"
		},
		{
			"spawn" : function (ticks) {
				return null;
			},
			"bgOffset" : 0,
			"shop" : true,
			"name" : "ALL OF OUR PRODUCTS ARE ORGANIC",
			"music" : "shop",
			"mobs" : 0,
			"grassiness" : 16,
			"maxBladeHeight" : 10,
			"r" : 0x9c,
			"g" : 0xff,
			"b" : 0x9c
		},
		{
			"spawn" : function (ticks) {
				var freq = Std.int(Math.min(ticks/2.0, 900));
				if ((ticks%(1000 - freq)) == 10) {
					return "henro";
				}
				return null;
			},
			"bgOffset" : 0,
			"mobs" : 12,
			"shop" : false,
			"name" : "wave 3/3 - tokushima, japan",
			"music" : "first",
			"grassiness" : 16,
			"maxBladeHeight" : 10,
			"r" : 0x9c,
			"g" : 0xff,
			"b" : 0x9c,
			"mobName" : "henro"
		},
		{
			"spawn" : function (ticks) {
				return null;
			},
			"bgOffset" : 0,
			"shop" : true,
			"name" : "YOU LOOK GREAT TODAY!",
			"music" : "shop",
			"mobs" : 0,
			"grassiness" : 16,
			"maxBladeHeight" : 10,
			"r" : 0x9c,
			"g" : 0xff,
			"b" : 0x9c
		},
		{
			"spawn" : function (ticks) {
				var freq = Std.int(Math.min(ticks/10.0, 900));
				if ((ticks%(1000 - freq)) == 10) {
					return "deer";
				}
				return null;
			},
			"bgOffset" : 600,
			"mobs" : 4,
			"shop" : false,
			"name" : "wave 1/3 - nara, japan",
			"music" : "second",
			"grassiness" : 25,
			"maxBladeHeight" : 1,
			"r" : 0xf4,
			"g" : 0xa4,
			"b" : 0x60,
			"mobName" : "deer"
		},
		{
			"spawn" : function (ticks) {
				return null;
			},
			"bgOffset" : 600,
			"shop" : true,
			"name" : "DEER FACTS:\nDEER GROW NEW ANTLERS EACH YEAR",
			"music" : "shop",
			"mobs" : 0,
			"grassiness" : 25,
			"maxBladeHeight" : 1,
			"r" : 0xf4,
			"g" : 0xa4,
			"b" : 0x60
		},
		{
			"spawn" : function (ticks) {
				var freq = Std.int(Math.min(ticks/4.0, 900));
				if ((ticks%(1000 - freq)) == 10) {
					return "deer";
				}
				return null;
			},
			"bgOffset" : 600,
			"mobs" : 8,
			"shop" : false,
			"name" : "wave 2/3 - nara, japan",
			"music" : "second",
			"grassiness" : 25,
			"maxBladeHeight" : 1,
			"r" : 0xf4,
			"g" : 0xa4,
			"b" : 0x60,
			"mobName" : "deer"
		},
		{
			"spawn" : function (ticks) {
				return null;
			},
			"bgOffset" : 600,
			"shop" : true,
			"name" : "DEER FACTS:\nA FEMALE DEER IS CALLED A DOE",
			"music" : "shop",
			"mobs" : 0,
			"grassiness" : 25,
			"maxBladeHeight" : 1,
			"r" : 0xf4,
			"g" : 0xa4,
			"b" : 0x60
		},
		{
			"spawn" : function (ticks) {
				var freq = Std.int(Math.min(ticks/2.0, 900));
				if ((ticks%(1000 - freq)) == 10) {
					if (Math.random() < 0.5) {
						return "deer";
					} else {
						return "henro";
					}
				}
				return null;
			},
			"bgOffset" : 600,
			"mobs" : 15,
			"shop" : false,
			"name" : "wave 3/3 - nara, japan",
			"music" : "first",
			"grassiness" : 25,
			"maxBladeHeight" : 1,
			"r" : 0xf4,
			"g" : 0xa4,
			"b" : 0x60,
			"mobName" : "deer"
		},
		{
			"spawn" : function (ticks) {
				return null;
			},
			"bgOffset" : 600,
			"shop" : true,
			"name" : "YOUR MOTHER IS VERY TALENTED",
			"music" : "shop",
			"mobs" : 0,
			"grassiness" : 25,
			"maxBladeHeight" : 1,
			"r" : 0xf4,
			"g" : 0xa4,
			"b" : 0x60
		},
		{
			"spawn" : function (ticks) {
				var freq = Std.int(Math.min(ticks/7.0, 900));
				if ((ticks%(1000 - freq)) == 10) {
					return "salaryman";
				}
				return null;
			},
			"bgOffset" : 300,
			"mobs" : 5,
			"shop" : false,
			"name" : "wave 1/3 - tokyo, japan",
			"music" : "third",
			"grassiness" : 5,
			"maxBladeHeight" : 0,
			"r" : 0x9c,
			"g" : 0x9c,
			"b" : 0x9c,
			"mobName" : "salaryman"
		},
		{
			"spawn" : function (ticks) {
				return null;
			},
			"bgOffset" : 300,
			"shop" : true,
			"name" : "OUR STORES ARE ALL OVER JAPAN",
			"music" : "shop",
			"mobs" : 0,
			"grassiness" : 2,
			"maxBladeHeight" : 0,
			"r" : 0x9c,
			"g" : 0x9c,
			"b" : 0x9c
		},
		{
			"spawn" : function (ticks) {
				var freq = Std.int(Math.min(ticks/6.0, 900));
				if ((ticks%(1000 - freq)) == 10) {
					return "salaryman";
				}
				return null;
			},
 			"bgOffset" : 300,
			"mobs" : 10,
			"shop" : false,
			"name" : "wave 2/3 - tokyo, japan",
			"music" : "first",
			"grassiness" : 5,
			"maxBladeHeight" : 0,
			"r" : 0x9c,
			"g" : 0x9c,
			"b" : 0x9c,
			"mobName" : "salaryman"
		},
		{
			"spawn" : function (ticks) {
				return null;
			},
			"bgOffset" : 300,
			"shop" : true,
			"name" : "YOU HAVE COME FAR\nBUT DON'T GET COCKY YET",
			"music" : "shop",
			"mobs" : 0,
			"grassiness" : 2,
			"maxBladeHeight" : 0,
			"r" : 0x9c,
			"g" : 0x9c,
			"b" : 0x9c
		},
		{
			"spawn" : function (ticks) {
				var freq = Std.int(Math.min(ticks/2.0, 950));
				if ((ticks%(1000 - freq)) == 10) {
					if (Math.random() < 0.5) {
						return "salaryman";
					} else {
						if (Math.random() < 0.5) {
							return "henro";
						} else {
							return "deer";
						}
					}
				}
				return null;
			},
			"bgOffset" : 300,
			"mobs" : 25,
			"shop" : false,
			"name" : "final wave!!!",
			"music" : "third",
			"grassiness" : 5,
			"maxBladeHeight" : 0,
			"r" : 0x9c,
			"g" : 0x9c,
			"b" : 0x9c,
			"mobName" : "salaryman"
		}
	];

	function leave() {
		if (leaving) return;
		fadeTarget = 260;
		info("leaving");
		leaving = true;
		for (pet in pets) {
			pet.attack(boy.track);
		}
	}

	var over = false;
	function gameOver() {
		if (over) return;
//		new GameOverSound().play();
		over = true;
		fadeTarget = 400;
	}

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
		popups.push(new Popup(x, 50 + Std.int(50 - lowest), txt));
	}

	function info(txt:String, ?x = 50) {
		popup(x, 50, txt);
	}

	function initGround() {
		shadow = new Blob();
		shadow.anim("shadow");

		var grassiness = levels[level].grassiness;
		var maxBladeHeight = levels[level].maxBladeHeight;

		var bgHeight = 95;

		ground.copyPixels(bgBD, new Rectangle(levels[level].bgOffset, 0, 300, bgHeight), pt0);

		for (y in bgHeight...300) {
			for (x in 0...ground.width) {
				var dark = Math.round(Math.random() * 5) * grassiness;

				var bladeHeight = Math.round(Math.random() * maxBladeHeight) + 1;

				for (h in 0...bladeHeight) {
					var r = Math.floor(Math.min(255, levels[level].r - dark + h*5));
					var g = Math.floor(Math.min(255, levels[level].g - dark + h*5));
					var b = Math.floor(Math.min(255, levels[level].b - dark + h*5));
					var c = (0xff << 24) + (r << 16) + (g << 8) + b;
					ground.setPixel32(x, y - h, c);
				}
			}
		}

		ground.applyFilter(ground, ground.rect, pt0, new flash.filters.GlowFilter(0xffffffff, 1.0, 10, 10, 2, 2, true, false));
	}

	function restartGame() {
		if (channel != null) {
			channel.stop();
		}
		channel = new FirstSong().play(0, 9999);
		over = false;
		level = 0;
		lanes = 3;
		ents = [];
		pets = [];
		mobs = [];
		boy = new Boy();
		boy.xx = 0;
		boy.lanes = lanes;
		ents.push(boy);
//		adopt("cat", 40);
		adopt("dog", 30);
		adopt("dog", 20);
		initGround();
		leaving = false;
		enteringStore = false;
		enteredStore = false;
		displayMoney = 0.0;
		money = 0.0;
		fade = 0.0;
		fadeTarget = 0.0;
		mobsSpawned = 0;
		mobsKilledOrPassed = 0;
		levelComplete = false;
		didVisitStore = false;
		ticks = 0;
	}

	function nextLevel() {
		smokeParticles.reset();
		particles.reset();
		backstory = makeRandomBackstory();
		didVisitStore = false;
		levelComplete = false;
		mobsKilledOrPassed = 0;
		mobsSpawned = 0;
		level++;

		channel.stop();
		if (levels[level].music == "first") {
			channel = new FirstSong().play(0, 9999);
		}
		if (levels[level].music == "third") {
			channel = new ThirdSong().play(0, 9999);
		}
		if (levels[level].music == "second") {
			channel = new SecondSong().play(0, 9999);
		}
		if (levels[level].music == "shop") {
			channel = new ShopSong().play(0, 9999);
		}

//		channel = music.play();
//		channel = new music().play();
		for (mob in mobs) {
			ents.remove(mob);
		}
		mobs = [];
		ticks = 0;
		fadeTarget = 0;
		fade = 255;
		leaving = false;
		for (pet in pets) {
			pet.health = 100;
			pet.recall();
			pet.fightingCounter = 0;
		}
		boy.xx = 0;

		if (levels[level].shop) {
			enterStore();
		}
		initGround();
	}

	function spawn(mobType:String) {
		var mob:Mob = null;
		if (mobType == "henro") {
			mob = new Henro(Math.floor(Math.random() * 3));
		}
		if (mobType == "salaryman") {
			mob = new Salaryman(Math.floor(Math.random() * 3));
		}
		if (mobType == "deer") {
			mob = new Deer(Math.floor(Math.random() * 3));
		}
		if (mob != null) {

			var aas = ["wild", "wild", "wild", "scary", "wow", "suddenly", "presently", "oh no,", "look!"];
			var bs = ["appeared", "appeared", "appeared", "emerged", "arrived", "is here!"];
			var txt = aas[Math.floor(Math.random()*aas.length)] + " " + mobType + " " + bs[Math.floor(Math.random()*bs.length)];
			info(txt, 150);

			mobsSpawned++;
			mobs.push(mob);
			ents.push(mob);
		} else {
		}
	}

	function closestMobOnTrack(track) {
		var closest:Mob = null;
		for (mob in mobs) {
			if (mob.track == track && !mob.leaving && mob.xx > 75) {
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

		if (matchingPets.length == 0) {
			info("No " + petType + " available");
		} else {
			new GoSound().play();

			matchingPets.sort(function (x, y) {
				if (x.health == y.health) return 0;
				if (x.health > y.health) return -1;
				return 1;
			});

			var bestPet = matchingPets[0];
//			info(petType + " attack");

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
//			boy.xx = 125 * 0.025 + boy.xx * 0.975;
			boy.xx += 1;
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
			if (petName == "gorilla" || petName == "bird") {
				info(petName + " was a lie, sorry");
				return;
			}

			new BlipSound().play();
			adopt(petName, 10);
			money -= c;			
			info("Bought " + petName);
		} else {
			info("can't afford " + petName);
		}
	}

	function controls() {
		if (!prevKeys[Keyboard.SPACE] && keys[Keyboard.SPACE]) {
			if (over) {
				restartGame();
			}
			if (levelComplete) {
				nextLevel();
			}
 		}

		if (!prevKeys[Keyboard.UP] && !prevKeys[Keyboard.W] && (keys[Keyboard.UP]||keys[Keyboard.W]) ) {
			if (levels[level].shop) return;
			boy.trackMove(-1);
		}
		if (!prevKeys[Keyboard.DOWN] && !prevKeys[Keyboard.S] && (keys[Keyboard.DOWN]||keys[Keyboard.S]) ) {
			if (levels[level].shop) return;
			boy.trackMove(1);
		}

		if (!prevKeys[Keyboard.Q] && keys[Keyboard.Q]) {
			if (!enteredStore) return;
			info("come again soon");
			enteredStore = false;
			boy.visible = true;
			didVisitStore = true;
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

/*		if (!prevKeys[Keyboard.NUMBER_0] && keys[Keyboard.NUMBER_0]) {
			restartGame();
		}
		if (!prevKeys[Keyboard.NUMBER_1] && keys[Keyboard.NUMBER_1]) {
			leave();
		}
		if (!prevKeys[Keyboard.R] && keys[Keyboard.R]) {
			if (enteredStore) return;
			spawn("henro");
		}
		if (!prevKeys[Keyboard.T] && keys[Keyboard.T]) {
			if (enteredStore) return;
			enterStore();
		}
*/
		for (key in keys.keys()) {
			prevKeys[key] = keys[key];
		}
	}

	function fight(mob:Mob, pet:Pet) {
		if (over) return;
		if (pet.fightingCounter > 0) return;

		pet.enemy = mob;
		pet.fightingCounter = pet.fightDelay;
		mob.fightCounter = pet.fightDelay;

		popup(mob.x, mob.y, "FIGHT");
		var txt = "FIGHT";

		var d = pet.attackStrength;
		if (Math.random() < pet.criticalLikelihood) {
			d += pet.criticalAttackStrength;
			txt = "-" + d + " CRITICAL!";
		} else {
			txt = "-" + d + " DAMAGE";
		}

		new HurtSound().play();
		mob.damage(d);
		if (mob.died()) {
			smokeParticles.burst(mob.x + Math.random() * 32, mob.y + Math.random() * 32, 0, 100, 0.1, 1, 100, mob.y + 32, -0.01);

			// Stop fighting dead enemy
			for (p in pets) {
				if (p.enemy == mob) {
					pet.fightingCounter = 0;
				}
			}

			mobsKilledOrPassed++;
			checkLevelComplete();
			new MobDeadSound().play();
			money += mob.moneyDrop * 0.5 + Math.random() * mob.moneyDrop;
			if (Math.random() < 0.5) {
				if (pet.petType == "dog") {
					txt = "WOOFALITY";
				} 
				if (pet.petType == "cat") {
					txt = "CATALITY!";
				} 
			} else {
				txt = mob.monsterType + " died";
			}
		}

		pet.damage(Std.int(mob.attackStrength * 0.5 + mob.attackStrength * Math.random()));
		if (pet.died()) {
			pet.fightingCounter = 0;
			info(pet.petType + (Math.random() < 0.5 ? " is gone!" : " died!"));
			new DogDeadSound().play();
		}

		popup(Std.int(Math.min(mob.x, 170.0)), mob.y, txt);
//		pet.recall();
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
				pets.remove(ent);
			}
		}

		for (ent in removeThese) {
			ents.remove(ent);
		}
	}

	function checkLevelComplete() {
		if (mobsKilledOrPassed >= mobsSpawned && levels[level].mobs <= mobsSpawned) {
			fadeTarget = 300;
			levelComplete = true;
		}
	}

	function boyDamage() {
		for (mob in mobs) {
			if (mob.x < 75 && !mob.damagedBoy) {
				boy.damage(34);
				mobsKilledOrPassed++;
				if (!boy.died()) {
					checkLevelComplete();
				}
				mob.damagedBoy = true;
			}
		}
		if (boy.died()) {
			new MobDeadSound().play();
			gameOver();
		}
	}

	var ticks = 0;
	function tick() {
		if (!over) boyDamage();

		for (pet in pets) {
			if (pet.fightingCounter > 0) {
				particles.burst(pet.x + 16, pet.y + 16, Math.random() * Math.PI * 2, 2, 0.1, 1.5, Std.int(10 * Math.random()), pet.y + 32);
			}
		}

		ticks++;		

		if (levels[level].mobName != null && mobs.length == 0) {
			spawn(levels[level].mobName);
		} else {
			var spawnThis = levels[level].spawn(ticks);
			if (spawnThis != null && levels[level].mobs > mobsSpawned) {
				spawn(spawnThis);
			}
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
				boy.xx = 350 * 0.025 + boy.xx * 0.975;
				return;
			}
			if (!enteredStore) {
				if (boy.xx > 15) {
					boy.flipped = true;
				} else {
					boy.flipped = false;
					if (didVisitStore) {
						leave();
					}
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
		Popup.write(buffer, 100, 0, levels[level].name, 0xffffff, true);
	}

	var backstory:String;

	function refresh(e:flash.events.Event) {

//		buffer.applyFilter(buffer, buffer.rect, new Point(0,0), new flash.filters.GlowFilter(0xffffffff, 1.0, 10, 10, 1.5, 2, false, false));
		controls();
		tick();

		frames++;
		if (Date.now().getTime() - fpsCountStart > 1000) {
			if (fpsCountStart > 0) {
			}
			frames = 0;
			fpsCountStart = Date.now().getTime();
		}

		buffer.draw(ground);
		lights();
		if (levels[level].shop) {
			drawShop(buffer);
		}

		particles.tick(ground);
		smokeParticles.tick(null);
		particleBD.fillRect(particleBD.rect, 0x00000000);
		smokeParticleBD.fillRect(particleBD.rect, 0x00000000);
		particles.draw(particleBD);
		smokeParticles.draw(smokeParticleBD);
		particleBD.applyFilter(particleBD, particleBD.rect, new Point(0,0), new flash.filters.GlowFilter(0xffff0000, 1.0, 10, 10, 1.5, 2, false, false));
		smokeParticleBD.applyFilter(smokeParticleBD, smokeParticleBD.rect, new Point(0,0), new flash.filters.BlurFilter(10, 10));
		buffer.draw(particleBD);
		buffer.draw(smokeParticleBD);

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

		if (!levels[level].shop) {
			buffer.fillRect(new Rectangle(75, 96, 1, 200), 0x00ffffff);
		}

		if (over) {
			Popup.write(buffer, 0, 0, gameOverText, 0x0, false);			
		}
		if (levelComplete) {
			if (level == levels.length-1) {
				Popup.write(buffer, 0, 0, winText, 0x0, false);			
			} else {
				Popup.write(buffer, 0, 0, levelCompleteText, 0x0, false);			
			}
		}
		if (enteredStore) {
			Popup.write(buffer, 20, 140, shopText, 0xffffff, true);			
		}

		if (level == 0) {
			Popup.write(buffer, 0, 180, help, 0xffffff, false);			
		}
		if (level == 2) {
			Popup.write(buffer, 0, 180, help2, 0xffffff, false);			
		}
		if ((level % 2) == 0 && level > 2) {
			Popup.write(buffer, 0, 180, backstory, 0xffffff, false);			
		}


		var m = new Matrix();
		m.scale(3, 3);
		display.draw(buffer, m, null, null);
		display.draw(overlayBD, null, null, OVERLAY);
	}


	public function new() {
		particles = new Particles();
		smokeParticles = new Particles();
		backstory = makeRandomBackstory();

		Blob.setSheet(sheet);
		Blob.defineAnimation("boy_idle", 0, 0, 1, 10);
		Blob.defineAnimation("cat_idle", 0, 5, 3, 30);
		Blob.defineAnimation("cat_run", 1, 1, 3, 3, [null, null, null]);
		Blob.defineAnimation("dog_idle", 0, 3, 5, 15);
		Blob.defineAnimation("dog_run", 0, 4, 3, 3);
		Blob.defineAnimation("shadow", 3, 2, 1, 20);
		Blob.defineAnimation("henro_walk", 4, 1, 3, 10);
		Blob.defineAnimation("salaryman_walk", 4, 2, 3, 10);
		Blob.defineAnimation("deer_walk", 4, 5, 5, 5);
		restartGame();

		smokeParticles.scale = 0.1;
		smokeParticles.setBitmap("pixel", new SmokePNG(0,0));
		b.Generators.generateOverlay(overlayBD);
//		b.Generators.generateOverlay2(lightBD, 0xfff0f0f0, 0xfff0f0f0);

		flash.Lib.current.addChild(new Bitmap(display));
		flash.Lib.current.stage.addEventListener(Event.ENTER_FRAME, refresh);
		initKeyboard();
	}

	function makeRandomBackstory() {
		var aas = [
			"Your father",
			"Your mother",
			"Your sister",
			"Your half cousin",
			"Your therapist",
			"Your doctor",
			"Your teacher",
			"Everyone",
			"The emperor",
			"Imperial army",
			"Your twin",
			"Your ass",
			"You"
		];

		var bs = [
			"got sick",
			"ate poison",
			"fell",
			"went crazy",
			"ate bacon",
			"drowned",
			"ate lettuce",
			"exploded",
			"got pregnant",
			"twerked",
			"is kawaii",
			"likes anime"
		];

		var cs = [
			"a bit",
			"yesterday",
			"last year",
			"in a dream",
			"suddenly",
			"aggressively",
			"needlessly",
			"yelling banzai",
			"intoxicated",
			"(really)"
		];

		// And you must go to tokyo

		var ds = [
			"to help",
			"to rescue",
			"to assist",
			"to put a stop to it",
			"to take a photo",
			"to laugh",
			"to eat sushi",
			"to relax",
			"to party hard"
		];

		return "Backstory: Travel to Tokyo because " + aas[Math.floor(Math.random()*aas.length)] + "\n" + bs[Math.floor(Math.random()*bs.length)] + " " + cs[Math.floor(Math.random()*cs.length)] + " so you need " + ds[Math.floor(Math.random()*ds.length)] + '.';
	}

	static function main() {
		var what = new Game();
	}
}
import flash.display.*;
import b.*;

class Entity extends Blob {
	public var requestRemoval = false;
	public var health:Int = 100;
	public var track:Int;
	var trackHeight = 32;

	public function die() {
		requestRemoval = true;
	}

	public function damage(d:Int) {
		health = Std.int(Math.max(0, health - d));
		if (health == 0) die();
	}

	function trackPos() {
		return 100 - 16 + trackHeight * track;
	}

	public function new() {
		super();
	}

	function healthBar(buffer:BitmapData) {
		buffer.fillRect(new flash.geom.Rectangle(x + 4, y - 4, 25 + 2, 3), 0x0);

		for (_x in x...x+25) {
			buffer.setPixel(_x + 5, y - 3, _x < x+Math.floor(health/4) ? 0xff99ff99 : 0xffff3333);
		} 
	}

	override public function draw(buffer:BitmapData, ?blendMode:BlendMode) {
		super.draw(buffer, blendMode);
		healthBar(buffer);
	}
}
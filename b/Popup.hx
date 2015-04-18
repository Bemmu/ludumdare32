package b;

import flash.display.*;
import flash.geom.*;
import flash.text.*;

class Popup {
	var txt:String = "it's dangerous to go alone, take this!";
	var tf:TextField = null;

	public function new() {
		var format = new flash.text.TextFormat("def", 8, 0xffffff);
		tf = new TextField();
		tf.defaultTextFormat = format;
		tf.setTextFormat(format);
		tf.htmlText = txt;
		tf.mouseWheelEnabled = false;
		tf.selectable = false;
		tf.mouseEnabled = false;
		tf.x = 100;
		tf.y = 50;
		tf.width = 1000;
	}

	public function draw(buffer:BitmapData) {
		var m = new Matrix(1, 0, 0, 1, tf.x, tf.y);
		buffer.fillRect(new Rectangle(
			tf.x, tf.y, tf.getBounds(tf).x, 20
		), 0xffffffff);
		buffer.draw(tf, m);
	}
}
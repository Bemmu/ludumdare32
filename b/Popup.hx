package b;

import flash.display.*;
import flash.geom.*;
import flash.text.*;

@:font("visitor1.ttf") class PixelFont extends Font { }

class Popup {
	static var fontsRegistered = false;
	static var fontName:String;

	var txt:String = "ABCDEFGHIJKLM";
	var tf:TextField = null;

	public function new() {
		if (!fontsRegistered) {
			fontsRegistered = true;
			Font.registerFont(PixelFont);
			var f = new PixelFont();
			fontName = f.fontName;
		}

		var format = new flash.text.TextFormat();
		format.font = fontName;
		format.size = 10;

		tf = new TextField();
		tf.embedFonts = true;
		tf.defaultTextFormat = format;
		tf.setTextFormat(format);
		tf.multiline = true;
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
		buffer.draw(tf, m);

		var tmp:BitmapData = new BitmapData(Std.int(tf.width + 2), Std.int(tf.height + 2), true, 0);
		tmp.draw(tf);
		var rect = tmp.getColorBoundsRect(0xFFFFFFFF, 0x000000, false);

		buffer.fillRect(new Rectangle(
			tf.x + 1, tf.y + 3, rect.width + 2, rect.height + 2
		), 0xff00ff00);
		buffer.draw(tf, m);
	}
}
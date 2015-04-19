package b;

import flash.display.*;
import flash.geom.*;
import flash.text.*;

@:font("visitor1.ttf") class PixelFont extends Font { }

class Popup {
	static var fontsRegistered = false;
	static var fontName:String;

//	var txt:String = "ABCDEFGHIJKLM";
	var tf:TextField = null;
	var xx:Float;
	public var yy:Float; 
	var ys:Float = -1.0;
	public var lifetime:Int = 100;

	public function new(?xx:Int, ?yy:Int, ?txt:String) {
		this.xx = xx;
		this.yy = yy;

		if (!fontsRegistered) {
			fontsRegistered = true;
			Font.registerFont(PixelFont);
			var f = new PixelFont();
			fontName = f.fontName;
		}

		var format = new flash.text.TextFormat();
		format.font = fontName;
		format.color = 0xffffff;
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
		tf.x = Math.floor(xx);
		tf.y = Math.floor(yy);
		tf.width = 1000;
	}

	public static function write(buffer:BitmapData, x:Int, y:Int, txt:String, color:UInt, bg:Bool) {
		if (!fontsRegistered) {
			fontsRegistered = true;
			Font.registerFont(PixelFont);
			var f = new PixelFont();
			fontName = f.fontName;
		}

		var format = new flash.text.TextFormat();
		format.font = fontName;
		format.color = color;
		format.size = 10;

		var tf = new TextField();
		tf.embedFonts = true;
		tf.defaultTextFormat = format;
		tf.setTextFormat(format);
		tf.multiline = true;
		tf.htmlText = txt;
		tf.mouseWheelEnabled = false;
		tf.selectable = false;
		tf.mouseEnabled = false;
		tf.width = 1000;

		var m = new Matrix(1, 0, 0, 1, x, y);
		buffer.draw(tf, m);

		var tmp:BitmapData = new BitmapData(Std.int(tf.width + 2), Std.int(tf.height + 2), true, 0);
		tmp.draw(tf);
		var rect = tmp.getColorBoundsRect(0xFFFFFFFF, 0x000000, false);

		if (bg) {
			buffer.fillRect(new Rectangle(
				x + 1, y + 3, rect.width + 2, rect.height + 2
			), 0xff3a2542);
		}
		buffer.draw(tf, m);
	}

	public function tick() {
		yy += ys;
		tf.y = Math.floor(yy);
		ys *= 0.95;
		if (lifetime > 0) lifetime--;
	}

	public function draw(buffer:BitmapData) {
		var m = new Matrix(1, 0, 0, 1, tf.x, tf.y);
		buffer.draw(tf, m);

		var tmp:BitmapData = new BitmapData(Std.int(tf.width + 2), Std.int(tf.height + 2), true, 0);
		tmp.draw(tf);
		var rect = tmp.getColorBoundsRect(0xFFFFFFFF, 0x000000, false);

		buffer.fillRect(new Rectangle(
			tf.x + 1, tf.y + 3, rect.width + 2, rect.height + 2
		), 0xff3a2542);
		buffer.draw(tf, m);
	}
}
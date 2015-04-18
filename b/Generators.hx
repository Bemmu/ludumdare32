package b;

class Generators {
	static public function generateOverlay(buffer, bgColor = 0xff808080, fgColor = 0xffffffff) {
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

	static public function generateOverlay2(buffer, bgColor = 0xff808080, fgColor = 0xfff0f0f0) {
		for (x in 0...buffer.width) {
			for (y in 0...buffer.height) {
				if (((y >> 4)%2) == 0) {
					buffer.setPixel32(x, y, ((x >> 4)%2) == 0 ? fgColor : bgColor);
				} else {
					buffer.setPixel32(x, y, ((x >> 4)%2) == 0 ? bgColor : fgColor);
				}
			}
		}
	}
}
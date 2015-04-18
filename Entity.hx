import b.*;

class Entity extends Blob {
	public var health:Int = 100;
	var track:Int;
	var trackHeight = 32;

	function trackPos() {
		return 100 - 16 + trackHeight * track;
	}

	public function new() {
		super();
	}
}
package en;

class Henro extends Mob {
	public function new(track:Int) {
		super(track);
		anim("henro_walk");
		health = 20;
		monsterType = "henro";
	}
}
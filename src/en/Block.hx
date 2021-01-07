package en;

class Block extends Entity {
	public static var ALL : Array<Block> = [];
	var data : Entity_Block;
	var origin : LPoint;

	public function new(e:Entity_Block) {
		super(e.cx, e.cy);
		ALL.push(this);
		data = e;
		origin = makePoint();
		circularCollisions = true;
		initLife(1);
		spr.anim.setGlobalSpeed(0.5);
		spr.anim.registerStateAnim("blockIdle",0, ()-> isAlive());
	}

	override function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	override function onDie() {
		cd.setS("broken",Const.INFINITE);
		// Delay death to display breaking animation
		game.delayer.addS(()->{
			delayedDie();
		}, 0.3);
		// Delay scatter debris (after box is destroyed)
		game.delayer.addS(()->{
			scatterDebris();
		}, 0.35);	
	}


	public function scatterDebris() {
		// Spawn the two debris parts
			new en.BlockDebris(cx,cy,2);
			game.delayer.addS(()->{
				new en.BlockDebris(cx,cy,1);
			}, 0.1);						
	}

	public function delayedDie() {
		super.onDie();
	}

	override function onDamage(dmg:Int, from:Entity) {
		super.onDamage(dmg, from);
		spr.anim.playOverlap("blockHit", 0.6);						
	}

	override function postUpdate() {
		super.postUpdate();
	}

	override function update() {
		super.update();
		gravityMul = 0.;
		dy = 0.;
		if ( !cd.has("broken") ) {			
			// If block is unbroken add collisions
			level.setExtraCollision(cx,cy, true);
			level.setExtraCollision(cx,cy+1, true);
		}
		else {
			level.setExtraCollision(cx,cy, false);
			level.setExtraCollision(cx,cy+1, false);
		}	
	}
}
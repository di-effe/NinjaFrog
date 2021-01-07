package en;

class Box extends Entity {
	public static var ALL : Array<Box> = [];
	public var type : Boxes;
	var data : Entity_Box;
	var origin : LPoint;

	public function new(e:Entity_Box) {
		super(e.cx, e.cy);
		ALL.push(this);
		data = e;
		type = e.f_boxes; 
		origin = makePoint();
		spr.anim.setGlobalSpeed(0.5);
		circularCollisions = true;
		set_hei(20);
		set_radius(10);
		switch type {
            case Type1: 
				initLife(1);
				spr.anim.registerStateAnim("box1Idle",0, ()-> isAlive());
			case Type2: 
				initLife(2);
				spr.anim.registerStateAnim("box2Idle",0, ()-> isAlive());
			case Type3: 
				initLife(3);
				spr.anim.registerStateAnim("box3Idle",0, ()-> isAlive());									
		}
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
		// Delay scatter box content
		if ( data.f_content != null) {
			game.delayer.addS(()->{
				scatterContent();
			}, 0.35);			
		}

	}

	public function scatterDebris() {
		// Spawn the four debris parts
        for (debris in 0...4) {
			new en.BoxDebris(cx,cy,type,debris);
		}
	}

	public function scatterContent() {
		// Spawn the four debris parts
		for(e in data.f_content) {
			new en.BoxContent(cx,cy,e);
		}
	}

	public function delayedDie() {
		super.onDie();
	}

	override function onDamage(dmg:Int, from:Entity) {
		super.onDamage(dmg, from);
		switch type {
            case Type1: 
				spr.anim.playOverlap("box1Hit", 0.6);
			case Type2: 
				spr.anim.playOverlap("box2Hit", 0.6);
			case Type3: 
				spr.anim.playOverlap("box3Hit", 0.6);									
		}
	}

	override function update() {
		super.update();
		gravityMul = 0.;
		dy = 0.;
		if ( !cd.has("broken") ) {			
			// If box is unbroken add collisions
			level.setExtraCollision(cx,cy, true);
			level.setExtraCollision(cx,cy+1, true);
		}
		else {
			level.setExtraCollision(cx,cy, false);
			level.setExtraCollision(cx,cy+1, false);
		}	
	}
}
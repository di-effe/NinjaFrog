package en;

class FallingPlatform extends Entity {
	public var origin : Null<LPoint>;
	public static var ALL : Array<FallingPlatform> = [];
	var data : Entity_FallingPlatform;
    
	public function new(e:Entity_FallingPlatform) {
		super(e.cx, e.cy);
		ALL.push(this);
		spr.setCenterRatio(0.25,1);
		origin = makePoint();
		circularCollisions = true;
		spr.anim.setGlobalSpeed(0.3);
		spr.anim.registerStateAnim("fallingPlatform",0, ()-> isAlive());
		spr.anim.registerStateAnim("fallingPlatformFalling",1, 0.5, ()-> cd.has("triggered")); 
        game.scroller.add(spr, Const.DP_BG);
	}

	public function delayedDie() {
		super.onDie();
	}	

	override function dispose() {
		super.dispose();
	}

	override function postUpdate() {
		super.postUpdate();
	}

	override function update() {
		super.update();
		gravityMul = 0.;
		dy = 0;

		if ( !cd.has("triggered") ) {			
			// Add collisions
			level.setExtraCollision(cx,cy, true);	
			level.setExtraCollision(cx+1,cy, true);	
		}

		if ( cd.has("triggered") ) {	
			gravityMul = 2;
			dy += gravityMul*Const.GRAVITY * tmod;
			level.setExtraCollision(cx,cy, false);	
			level.setExtraCollision(cx+1,cy, false);		
			game.delayer.addS(()->{
				delayedDie();
			}, 1);					
		}
    }
}

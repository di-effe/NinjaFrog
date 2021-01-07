package en;

class BoxContent extends Entity {
    public var origin : Null<LPoint>;
    public var type : Fruits;
    
	public function new(x,y,type) {
        super(x, y-1);
         gravityMul*=0.20;
        frictX = frictY = 0.96;
		origin = makePoint();
		initLife(1);
		circularCollisions = true;
		spr.setCenterRatio(0.5,0.75);		
        dy = rnd(-0.1,-0.4);
        dx = rnd(-0.25,0.25);
        spr.anim.setGlobalSpeed(0.35);
		spr.anim.registerStateAnim("fruitCollected",1, 0.5, ()-> cd.has("collected")); 
		switch type {
            case Apple: 
				spr.anim.registerStateAnim("apple",0, ()-> isAlive());
            case Banana: 
				spr.anim.registerStateAnim("banana",0, ()-> isAlive());
			case Cherry: 
				spr.anim.registerStateAnim("cherry",0, ()-> isAlive());
            case Kiwi: 
				spr.anim.registerStateAnim("kiwi",0, ()-> isAlive());
            case Melon: 
				spr.anim.registerStateAnim("melon",0, ()-> isAlive());
            case Orange:             
				spr.anim.registerStateAnim("orange",0, ()-> isAlive());
            case Pineapple: 
				spr.anim.registerStateAnim("pineapple",0, ()-> isAlive());
            case Strawberry: 
				spr.anim.registerStateAnim("strawberry",0, ()-> isAlive());     
		};
        game.scroller.add(spr, Const.DP_BG);
	}

	override function onDie() {
		cd.setS("collected",Const.INFINITE);
		level.fruitCollected += 1;

		// Detect level cleared
		if ( level.fruitToCollect == level.fruitCollected )
			game.levelComplete();

		// Delay death to display popping animation
		game.delayer.addS(()->{
			delayedDie();
		}, 0.3);
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

		// Circular collisions
		if( hasCircularCollisions() ) {
			var d = 0.;

			// Collect fruit
			if( !hero.cd.has("dead") && !hero.cd.has("death") && isAlive() && !cd.has("collected") ) {
				d = M.dist(hero.centerX,hero.centerY, centerX,centerY);
				if( d<=hero.radius+radius ) {
					hit(1,hero);
					hud.invalidate();
					Assets.SLIB.pick(0.5);						
				}
			}
		}
    }
}

package en;

class BlockDebris extends Entity {
    public var origin : Null<LPoint>;
    
	public function new(x,y,type) {
        super(x, y);
        game.cd.setS("notsafetorestart",Const.INFINITE);
        gravityMul*=0.20;
        frictX = frictY = 0.96;
        origin = makePoint();
        dy = 0.05;
        dx = rnd(-0.1,0.1);
		switch type {
            case 1: 
                spr.set("blockDebrisTop2");
             case 2: 
                spr.set("blockDebrisBottom2");
        }
        game.scroller.add(spr, Const.DP_BG);
		game.delayer.addS(()->{
			delayedDie();
		}, 1);        
	}

	public function delayedDie() {
        super.onDie();
        game.cd.unset("notsafetorestart");
	}

	override function dispose() {
		super.dispose();
	}

	override function postUpdate() {
		super.postUpdate();
	}

	override function update() {
        super.update();
    }
}

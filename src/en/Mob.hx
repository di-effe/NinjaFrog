package en;

class Mob extends Entity {
	public static var ALL : Array<Mob> = [];
	var data : Entity_Mob;

	var origin : LPoint;
	var aggroTarget : Null<Entity>;

	public function new(e:Entity_Mob) {
		super(e.cx, e.cy);
		ALL.push(this);
		data = e;
		initLife(2);
		set_radius(12);
		dir = data.f_initialDir;
		lockControlS(1);
		origin = makePoint();
		circularCollisions = true;

		spr.anim.setGlobalSpeed(0.2);
		spr.anim.registerStateAnim("mobWalk",1, 3, ()->M.fabs(dx)>=0.05); // Speed overriden by aggro
		spr.anim.registerStateAnim("mobIdle",0);
	}

	override function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	override function onDie() {
		super.onDie();
		var a = [
			Assets.SLIB.kill0,
			Assets.SLIB.kill1,
			Assets.SLIB.kill2,
			Assets.SLIB.kill3,
		];
		a[Std.random(a.length)](0.3);

	}

	override function onDamage(dmg:Int, from:Entity) {
		super.onDamage(dmg, from);
		bump( (from==null?-dir:from.dirTo(this))*rnd(0.2,0.3), -rnd(0.05,0.10) );
		lockControlS(0.1);
		setSquashX(0.5);
		blink(0xffcc00);
		spr.anim.playOverlap("mobHit", 0.3);
	}

	public function aggro(e:Entity) {
		cd.setS("keepAggro",5);
		if( aggroTarget==e )
			return false;
		aggroTarget = e;
		return true;
	}

	override function postUpdate() {
		super.postUpdate();
	}

	override function update() {
		super.update();

		// Lost aggro
		if( aggroTarget!=null && ( !cd.has("keepAggro") || aggroTarget.destroyed ) ) {
			lockControlS(1);
			aggroTarget = null;
			setSquashX(0.8);
		}

		// Aggro hero
		if( !hero.cd.has("dead") && distCase(hero)<=10 && onGround && M.fabs(cy-hero.cy)<=2 && sightCheck(hero) ) {
			if( aggro(hero) ) {
					dir = dirTo(aggroTarget);
				lockControlS(0.5);
				setSquashX(0.6);
				bump(0,-0.1);
				Assets.SLIB.mob1(0.3);	
			}
		}

		if( onGround )
			cd.setS("airControl",0.5);

		if( !controlsLocked() ) {
			var spd = 0.01 * (0.2+0.8*cd.getRatio("airControl"));

			if( !hero.cd.has("dead") && aggroTarget!=null ) {
				if( sightCheck(aggroTarget) && M.fabs(cy-aggroTarget.cy)<=1 ) {
					// Track aggro target
					dir = dirTo(aggroTarget);
					dx += spd*1.2*dir*tmod;
				}
				else {
					// Wander aggressively
					if( !cd.hasSetS("aggroSearch",rnd(0.5,0.9)) ) {
						dir*=-1;
						cd.setS("aggroWander", rnd(0.1,0.4) );
					}
					if( cd.has("aggroWander") )
						dx += spd*2*dir*tmod;
				}
			}
			else {
				// Auto patrol
				dx += spd * dir * tmod;
				if( level.hasMark(PlatformEndLeft,cx,cy) && dir==-1 && xr<0.5
					|| level.hasMark(PlatformEndRight,cx,cy) && dir==1 && xr>0.5 ) {
					lockControlS(0.5);
					setSquashX(0.85);
					dir*=-1;
				}
				// Switch direction hitting a wall	
				if( level.hasCollision(cx-1,cy) && dir==-1 
					|| level.hasCollision(cx+1,cy) && dir==1  ) {
					lockControlS(0.5);
					setSquashX(0.85);
					dir*=-1;
				}						
			}
		}

		spr.anim.setStateAnimSpeed("mobWalk", aggroTarget!=null ? 3 : 2);

		//Hit hero
		if( !hero.cd.has("dead") && hero.dy <= 0 && distCaseX(hero)<=0.7 && hero.footY>=footY-Const.GRID*1 && hero.footY<=footY+Const.GRID*0.5 && !cd.hasSetS("heroHitLock",0.3) ) {
			hero.hit(1,this);
			fx.gibs(hero.centerX, hero.centerY, dirTo(this));
			lockControlS(0.6);
			setSquashX(0.5);
			bump(-dirTo(hero)*0.2, -0.1);
			Assets.SLIB.hit1(0.3);	
		}
	}
}
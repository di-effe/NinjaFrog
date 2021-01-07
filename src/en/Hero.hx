package en;

class Hero extends Entity {
	var ca : dn.heaps.Controller.ControllerAccess;
	var jumpCount: Int;

	public function new(e:Entity_Hero) {
		super(e.cx, e.cy);
		ca = Main.ME.controller.createAccess("hero");
		ca.setLeftDeadZone(0.2);
		set_hei(24);

		spr.anim.registerStateAnim("HeroIdle",0);
		spr.anim.registerStateAnim("HeroRun",5, 2, ()->M.fabs(dx)>=0.05*tmod );
		spr.anim.registerStateAnim("HeroJump",11, ()-> !onGround && !cd.has("wallsliding") && ( dy < 0 || bdy < 0) && !cd.has("dead") && !cd.has("dieing") );
		spr.anim.registerStateAnim("HeroFall",10, ()-> !onGround && !cd.has("wallsliding") && dy > 0 && !cd.has("dead") && !cd.has("dieing") );
		spr.anim.registerStateAnim("HeroDoubleJump",12, ()-> cd.has("doublejumping") && M.fabs(dy) <=0.20*tmod && !cd.has("wallsliding") && !cd.has("waswallsliding") );
		spr.anim.registerStateAnim("HeroWallSlide",9, ()-> cd.has("wallsliding") );
		spr.anim.registerStateAnim("HeroHit",15, ()-> cd.has("damaged") );
		spr.anim.registerStateAnim("HeroDieing",20, ()-> cd.has("dieing") );
		spr.anim.registerStateAnim("HeroDead",21, ()-> cd.has("dead") );
		spr.anim.registerTransitions(["HeroIdle","HeroRun","HeroJump","HeroFall","HeroHit"],["HeroDead"],"HeroDieing", 0.5);
		spr.anim.registerTransitions(["HeroIdle","HeroRun","HeroJump","HeroFall","HeroDoubleJump"],["HeroDieing"],"HeroHit", 0.5);

		initLife(1);
		circularCollisions = true;

		// Reset action states
		unsetStates();
		dir = e.f_initialDir;
	}


	public function unsetStates() {
		cd.unset("jumping");
		cd.unset("doublejumping");
		cd.unset("wallsliding");
		cd.unset("waswallsliding");
		cd.unset("dieing");
		cd.unset("damaged");
	}


	override function onLand(fallCHei:Float) {
		super.onLand(fallCHei);
		var impact = M.fmin(1, fallCHei/6);
		dx *= (1-impact)*0.5;
		game.camera.bump(0, 3*impact);
		setSquashY(1-impact*0.3);

		// Landing sound effects
		if( fallCHei>=9 )
			Assets.SLIB.land1(0.3);
		else
			Assets.SLIB.land(0.7 * M.fmin(1,fallCHei/2));

		// Landing after wall sliding flip direction (keepw dir consistent with wallsliding sprite)
		if ( cd.has("wallsliding"))
			dir *= -1;

		// A sever fall has conseguences
		if( fallCHei>=9 ) {
			game.camera.shakeS(1,0.3);
			cd.setS("heavyLand",0.3);
		}

		// Small fall
		else if( fallCHei>=3 )
			lockControlS(0.03*impact);

		// Reset action states after landing
		unsetStates();
		jumpCount = 0;
		// jumpDenied = false;
	}


	override public function onDamage(dmg:Int, from:Entity) {
		// cd.setF("damaged", 24);
		cd.setS("damaged", Const.INFINITE);
		game.stopFrame(1); 
		game.camera.shakeS(1,0.7);
	}

	override public function hit(dmg:Int, from:Null<Entity>) {
		// if( !isAlive() || dmg<=0 )
		if( hero.cd.has("dead") || dmg<=0 )
			return;
		onDamage(dmg, from);
		life = M.iclamp(life-dmg, 0, maxLife);	
			
		
		if( life<=0 ) {
			game.delayer.addS(()->{
				Assets.SLIB.gameover(1);
			}, 0.1);
			cd.setS("dead",Const.INFINITE);
			game.cd.setS("gameover",Const.INFINITE);
		}
	}

	public function delayedDie() {
		super.onDie();
	}

	override function dispose() {
		super.dispose();
		ca.dispose();
	}

	override function postUpdate() {
		super.postUpdate();
		spr.anim.setGlobalSpeed( 0.25 );
	}

	override function update() {
		super.update();
		var spd = 0.1;


		if ( cd.has("dead") ) {
			lockControlS(Const.INFINITE);
		}

		// Walk
		if( !controlsLocked() && ca.leftDist() > 0 ) {
			dx += Math.cos( ca.leftAngle() ) * ca.leftDist() * spd * ( 0.4+0.6*cd.getRatio("airControl") ) * tmod;
			dir = M.sign( Math.cos(ca.leftAngle()) );
		}
		else
			dx*=Math.pow(0.8,tmod);

		// Jump & Double jump
		if ( !controlsLocked() && ca.aPressed() && bdy == 0 ) {
			jumpCount += 1;
			cd.setS("jumping", Const.INFINITE);
			var maxJumpCount = 2;
				if (cd.has("wallsliding")) {
				cd.setS("waswallsliding", Const.INFINITE);
				maxJumpCount *= 10;
				dx = 0.2 * (dir * -1);
				if ( ca.leftDist() != 0 ) 
						dx = 0.3 * dir;
			}
			if (jumpCount <= maxJumpCount) {

				if (jumpCount != 1 && !level.hasCollision(cx,cy-2)) { // Double jump not possible when below obstacles
					// isDoubleJumping = true;
					cd.setS("doublejumping", Const.INFINITE);
					dy = -1.0; // Jump distance
				}
				else {
					// isJumping = true;
					cd.setS("jumping", Const.INFINITE);
					dy = -1.1; // Jump distance
					// Jumping particle effect
					fx.jumpingDust(centerX-2, footY,-1);
					fx.jumpingDust(centerX+2, footY,1);
				}
			}
		}

		// Check if hero drops from wall sliding
		if ( cd.has("wallsliding") ) {
			cd.unset("wallsliding");
			cd.setS("waswallsliding", Const.INFINITE);
			cd.setS("jumping", Const.INFINITE);
		}

		// Wall slide
			if ( dy > 0 ) {
			// Right Walls
			if( level.hasCollision(cx+1,cy) && level.hasCollision(cx+1,cy-1) && xr>=0.5 ) {
				cd.setS("wallsliding", Const.INFINITE);
				dy*=Math.pow(frictY*0.5,tmod);
			}
			// Left walls
			if( level.hasCollision(cx-1,cy) && level.hasCollision(cx-1,cy-1) && xr<=0.5 ) {
				cd.setS("wallsliding", Const.INFINITE);
				dy*=Math.pow(frictY*0.5,tmod);
			}
		}


		// Circular collisions
		if( hasCircularCollisions() ) {
			var d = 0.;

			// Collect fruit
			for(e in en.Fruit.ALL) {
				if( !cd.has("dead") && !cd.has("dieing") && e.isAlive() && !e.cd.has("collected") && hasCircularCollisionsWith(e) ) {
					d = M.dist(centerX,centerY, e.centerX,e.centerY);
					if( d<=radius+e.radius ) {
						e.hit(1,hero);
						hud.invalidate();
						Assets.SLIB.pick(0.8);		
					}
				}
			}


			// Interact with jumpers
			for(e in en.Jumper.ALL) {
				if( !cd.has("dead") && !cd.has("dieing") && e.isAlive() && !e.cd.has("triggered") && hasCircularCollisionsWith(e) ) {
					d = M.dist(centerX,centerY, e.centerX,e.centerY);
					if( d<=radius+e.radius ) {
						e.triggered();					
					}
				}
			}


			// Interact with falling platforms
			for(e in en.FallingPlatform.ALL) {
				if( !cd.has("dead") && !cd.has("dieing") && e.isAlive() && !e.cd.has("triggered") && hasCircularCollisionsWith(e) ) {
					var dfh = M.dist(footX, footY, e.headX, e.headY);
					if ( dfh <= 20 && (cx == e.cx || cx == e.cx+1 ) ) {
						game.delayer.addS(()->{
							e.cd.setS("triggered", Const.INFINITE);	
						}, 0.3);			
					}
				}
			}			


			// Interact with spikes
			for(e in en.Spikes.ALL) {
				if( !cd.has("dead") && !cd.has("dieing") && !cd.has("damaged") && e.isAlive() && hasCircularCollisionsWith(e) ) {
					d = M.dist(centerX,centerY, e.centerX,e.centerY);
					if( d<=radius+e.radius ) {
						// damaged();
						hit(1,e);	
						Assets.SLIB.splat(0.8);
						fx.gibs(e.centerX, e.centerY, -dirTo(e));	
						if ( dy >= 0)
							bump( (-dirTo(e))*rnd(0.1,0.2), -rnd(0.2,0.3) );
						else
							bump( 0., 0.1 );															
					}
				}
			}			


			// Interact with blocks
			for(e in en.Block.ALL) {
				if( !cd.has("dead") && !cd.has("dieing") && e.isAlive() && !e.cd.has("broken") && hasCircularCollisionsWith(e) ) {
					var dhf = M.dist(headX, headY, e.footX, e.footY);
					if ( dhf <= 8 && !cd.has("hit") ) {
						cd.setMs("hit", 300);	
						e.hit(1,hero);
						bump(0.,0.5);
						Assets.SLIB.hit(0.5);
					}
					var dfh = M.dist(footX, footY, e.headX, e.headY);
					if ( dfh <= 10 && !cd.has("hit") && dy > 0 ) {
						cd.setMs("hit", 300);	
						e.hit(1,hero);
						bump(0.,-0.5);
						Assets.SLIB.hit(0.5);
					}					
				}
			}


			// Interact with boxes
			for(e in en.Box.ALL) {
				if( !cd.has("dead") && !cd.has("dieing") && e.isAlive() && !e.cd.has("broken") && hasCircularCollisionsWith(e) ) {
					var dhf = M.dist(headX, headY, e.footX, e.footY);
					if ( dhf <= 8 && !cd.has("hit") ) {
						cd.setMs("hit", 300);	
						e.hit(1,hero);
						bump(0.,0.2);
						Assets.SLIB.hit(0.5);
					}
					var dfh = M.dist(footX, footY, e.headX, e.headY);
					if ( dfh <= 10 && !cd.has("hit") && dy > 0 ) {

						cd.setMs("hit", 300);	
						e.hit(1,hero);
						bump(0.,-0.5);
						Assets.SLIB.hit(0.5);
					}					
				}
			}


			// Interact with Mobs
			for(e in en.Mob.ALL) {
				if( !cd.has("dead") && !cd.has("dieing") && e.isAlive() && hasCircularCollisionsWith(e) ) {
									
					d = M.dist(centerX,centerY, e.centerX,e.centerY);
					if( d<=radius+e.radius && dy > 0 ) {
						bump(0, -0.5);
						e.hit(1,hero);
						Assets.SLIB.mob(0.3);		
					}

					
				}
			}	


			// *********************************************************************************************************************
			// Interact with test entities
			for(e in en.TestEntity.ALL) {
				if( !cd.has("dead") && !cd.has("dieing") && e.isAlive() && !e.cd.has("triggered") && hasCircularCollisionsWith(e) ) {
					
					// Check circular collisions
					// Test entities is set with +1px in radius to extend the circular collision 
					d = M.dist(centerX,centerY, e.centerX,e.centerY);
					if( d<=radius+e.radius ) {
						if ( cx == e.cx+1 && cy == e.cy && !cd.has("hitRight") ) {
							cd.setMs("hitRight", 300);	
							trace("Right");		
						}
						if ( cx == e.cx-1 && cy == e.cy && !cd.has("hitLeft") ) {
							cd.setMs("hitLeft", 300);	
							trace("Left");						
						}
					}

					// Check collision between hero head and entity foot
					var dhf = M.dist(headX, headY, e.footX, e.footY);
					if ( dhf <= 8 && !cd.has("hitBottom") ) {
						cd.setMs("hitBottom", 300);	
						trace("bottom");		
					}

					// Check collision between hero foot and entity head
					var dfh = M.dist(footX, footY, e.headX, e.headY);
					if ( dfh <= 10 && !cd.has("hitTop") ) {
						cd.setMs("hitTop", 300);	
						trace("top");							
					}							
					
				}
			}	
			// *********************************************************************************************************************		

		}

		#if debug
		// debug( M.pretty(hxd.Timer.fps(),1) );
		#end
	}
}
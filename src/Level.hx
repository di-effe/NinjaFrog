class Level extends dn.Process {
	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public var fx(get,never) : Fx; inline function get_fx() return Game.ME.fx;

	public var wid(get,never) : Int; inline function get_wid() return level.l_Collisions.cWid;
	public var hei(get,never) : Int; inline function get_hei() return level.l_Collisions.cHei;
	public var gridsize(get,never) : Int; inline function get_gridsize() return level.l_Collisions.gridSize;

	public var level : World.World_Level;
	var CollisionTilesetSource : h2d.Tile;
	var ShadowsTilesetSource : h2d.Tile;
	var BackgroundTilesetSource : h2d.Tile;
	var BackgroundTilesetSource0 : h2d.Tile;
	var BackgroundTilesetSource1 : h2d.Tile;
	var BackgroundTilesetSource2 : h2d.Tile;
	var BackgroundTilesetSource3 : h2d.Tile;
	var BackgroundTilesetSource4 : h2d.Tile;
	var BackgroundTilesetSource5 : h2d.Tile;
	var BackgroundTilesetSource6 : h2d.Tile;
	

	var marks : Map< LevelMark, Map<Int,Bool> > = new Map();
	var extraCollMap : Map<Int,Bool> = new Map();
	var invalidated = true;
	public var wrapper : h2d.Object;
	public var tf : h2d.Text;

	public var fruitToCollect : Int = 0;
	public var fruitCollected : Int = 0;

	public function new(l:World.World_Level) {
		super(Game.ME);
		createRootInLayers(Game.ME.scroller, Const.DP_BG);
		level = l;
		CollisionTilesetSource = hxd.Res.world.Tileset.toTile();
		ShadowsTilesetSource = hxd.Res.world.Shadows.toTile();

		// Pick a random background to render every time
		var backgrounds = [ "Blue", "Brown", "Gray", "Green", "Pink", "Purple", "Yellow" ];
		BackgroundTilesetSource0 = hxd.Res.world.Blue.toTile();
		BackgroundTilesetSource1 = hxd.Res.world.Brown.toTile();
		BackgroundTilesetSource2 = hxd.Res.world.Gray.toTile();
		BackgroundTilesetSource3 = hxd.Res.world.Green.toTile();
		BackgroundTilesetSource4 = hxd.Res.world.Pink.toTile();
		BackgroundTilesetSource5 = hxd.Res.world.Purple.toTile();
		BackgroundTilesetSource6 = hxd.Res.world.Yellow.toTile();
		var randomBackground = M.randRange(0, backgrounds.length);
		switch randomBackground {
			case 0: BackgroundTilesetSource = BackgroundTilesetSource0; // Blue
			case 1: BackgroundTilesetSource = BackgroundTilesetSource1; // Brown
			case 2: BackgroundTilesetSource = BackgroundTilesetSource2; // Gray
			case 3: BackgroundTilesetSource = BackgroundTilesetSource3; // Green
			case 4: BackgroundTilesetSource = BackgroundTilesetSource4; // Pink
			case 5: BackgroundTilesetSource = BackgroundTilesetSource5; // Purple
			case 6: BackgroundTilesetSource = BackgroundTilesetSource6; // Yellow
			default: BackgroundTilesetSource = BackgroundTilesetSource0; // Blue
		  }	


		// Marking
		for(cy in 0...hei)
			for(cx in 0...wid) {
				if( !hasCollision(cx,cy) && !hasCollision(cx,cy-1) ) {
					if( hasCollision(cx+1,cy) && !hasCollision(cx+1,cy-1) )
						setMarks(cx,cy, [Grab,GrabRight]);
	
					if( hasCollision(cx-1,cy) && !hasCollision(cx-1,cy-1) )
						setMarks(cx,cy, [Grab,GrabLeft]);
				}
	
				if( !hasCollision(cx,cy) && hasCollision(cx,cy+1) ) {
					if( hasCollision(cx+1,cy) || !hasCollision(cx+1,cy+1) )
						setMarks(cx,cy, [PlatformEnd,PlatformEndRight]);
					if( hasCollision(cx-1,cy) || !hasCollision(cx-1,cy+1) )
						setMarks(cx,cy, [PlatformEnd,PlatformEndLeft]);
				}
			}


	}



	// Spawn entities
	public function attachMainEntities() {

		// Boxes (Drawn before Hero to be behind him)
		if( level.l_Entities.all_Box!=null ) 
			for( e in level.l_Entities.all_Box ) {
				new en.Box(e);
				if ( e.f_content.length != 0 ) 
					// Update amount of fruits to collect to clear level (box content)
					fruitToCollect += e.f_content.length;
			}

		// Spikes (Drawn before Hero to be behind him)
		if( level.l_Entities.all_Spikes!=null ) 
			for( e in level.l_Entities.all_Spikes ) {
				new en.Spikes(e);
				}		

		// Blocks (Drawn before Hero to be behind him)
		if( level.l_Entities.all_Block!=null ) 
			for( e in level.l_Entities.all_Block ) {
				new en.Block(e);
				}				

		// Hero
		var e = level.l_Entities.all_Hero[0];
		game.hero = new en.Hero(e);

		// Test Entities 16x16 (DEBUG)
		if( level.l_Entities.all_TestEntity!=null ) 
			for( e in level.l_Entities.all_TestEntity ) {
				new en.TestEntity(e);
				}

		// Fruits
		if( level.l_Entities.all_Fruit!=null ) 
			for( e in level.l_Entities.all_Fruit ) {
				new en.Fruit(e);
				}
		// Update amount of fruits to collect to clear level (placed in level)
		fruitToCollect += level.l_Entities.all_Fruit.length;

		// Jumpers
		if( level.l_Entities.all_Jumper!=null ) 
			for( e in level.l_Entities.all_Jumper ) {
				new en.Jumper(e);
				}

		// Falling Platforms
		if( level.l_Entities.all_FallingPlatform!=null ) 
			for( e in level.l_Entities.all_FallingPlatform ) {
				new en.FallingPlatform(e);
				}

		// Mob
		if( level.l_Entities.all_Mob!=null ) 
			for( e in level.l_Entities.all_Mob )
				new en.Mob(e);
		

	}

	/**
		Mark the level for re-render at the end of current frame (before display)
	**/
	public inline function invalidate() {
		invalidated = true;
	}

	/**
		Return TRUE if given coordinates are in level bounds
	**/
	public inline function isValid(cx,cy) return cx>=0 && cx<wid && cy>=0 && cy<hei;

	/**
		Transform coordinates into a coordId
	**/
	public inline function coordId(cx,cy) return cx + cy*wid;


	/** Return TRUE if mark is present at coordinates **/
	public inline function hasMark(mark:LevelMark, cx:Int, cy:Int) {
		return !isValid(cx,cy) || !marks.exists(mark) ? false : marks.get(mark).exists( coordId(cx,cy) );
	}


	/** Enable mark at coordinates **/
	public function setMark(cx:Int, cy:Int, mark:LevelMark) {
		if( isValid(cx,cy) && !hasMark(mark,cx,cy) ) {
			if( !marks.exists(mark) )
				marks.set(mark, new Map());
			marks.get(mark).set( coordId(cx,cy), true );
		}
	}

	public inline function setMarks(cx,cy,marks:Array<LevelMark>) {
		for(m in marks)
			setMark(cx,cy,m);
	}

	/** Remove mark at coordinates **/
	public function removeMark(mark:LevelMark, cx:Int, cy:Int) {
		if( isValid(cx,cy) && hasMark(mark,cx,cy) )
			marks.get(mark).remove( coordId(cx,cy) );
	}

	/** Return TRUE if "Collisions" layer contains a collision value **/
	public inline function hasCollision(cx,cy) : Bool {
		// return !isValid(cx,cy) ? true : level.l_Collisions.getInt(cx,cy)==0;
		return !isValid(cx,cy)
		? true
		: level.l_Collisions.getInt(cx,cy)==0 || // Terrain_Green
		level.l_Collisions.getInt(cx,cy)==1 || // Bricks_Grey
		level.l_Collisions.getInt(cx,cy)==3 || // Platform_Brown
		level.l_Collisions.getInt(cx,cy)==7 || // Rocks_Brown
		extraCollMap.exists(coordId(cx,cy)); // Collision with other entities
	}

	public function setExtraCollision(cx,cy,v:Bool) {
		if( isValid(cx,cy) )
			if( v )
				extraCollMap.set( coordId(cx,cy), true );
			else
				extraCollMap.remove( coordId(cx,cy) );
	}	

	/** Render current level**/
	function render() {
		root.removeChildren();


		// Render Backgrounds
		var tg_background = new h2d.TileGroup(BackgroundTilesetSource, root);
		level.l_Background.renderInTileGroup(tg_background, false);		
				
		// Render shadows
		var tg_shadows = new h2d.TileGroup(ShadowsTilesetSource, root);
		level.l_Shadows.renderInTileGroup(tg_shadows, false);		

		// Render collisions
		var tg_collisions = new h2d.TileGroup(CollisionTilesetSource, root);
		level.l_Collisions.renderInTileGroup(tg_collisions, false);


		
	}

	override function postUpdate() {
		super.postUpdate();
		if( invalidated ) {
			invalidated = false;
			render();

		}
	}
}
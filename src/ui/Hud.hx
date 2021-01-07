package ui;

class Hud extends dn.Process {
	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public var fx(get,never) : Fx; inline function get_fx() return Game.ME.fx;
	public var level(get,never) : Level; inline function get_level() return Game.ME.level;

	var top : h2d.Flow;
	var bottom : h2d.Flow;
	var fruits : h2d.Flow;
	var instructions : h2d.Flow;	
	var invalidated = true;

	public function new() {
		super(Game.ME);

		createRootInLayers(game.root, Const.DP_UI);
		root.filter = new h2d.filter.ColorMatrix(); // force pixel perfect rendering

		top = new h2d.Flow(root);
		bottom = new h2d.Flow(root);
		fruits = new h2d.Flow(top);
		instructions = new h2d.Flow(bottom);
	}

	override function onResize() {
		super.onResize();
		root.setScale(Const.UI_SCALE);
		top.x = (game.camera.wid-level.level.pxWid)/2+level.gridsize*2;
		top.y = (game.camera.hei-level.level.pxHei)/2+level.gridsize;
		bottom.x =(game.camera.wid-level.level.pxWid)/2+level.gridsize*2;
		bottom.y =(game.camera.hei-level.level.pxHei)/2+level.level.pxHei-level.gridsize*2;	
			

	}

	public inline function invalidate() invalidated = true;

	function render() {
		fruits.removeChildren();
		instructions.removeChildren();

		var tftop = new h2d.Text(Assets.fontPixel, fruits);
		tftop.textColor =0xffffff;		
		tftop.text = Std.string(level.fruitToCollect-level.fruitCollected);


		var tfbottom = new h2d.Text(Assets.fontPixel, instructions);
		tfbottom.textColor =0xffffff;		
		#if hl
		tfbottom.text = "ESC to exit --- R to restart level";
		#else
		tfbottom.text = "R to restart level";	
		#end


		onResize();
	}

	override function postUpdate() {
		super.postUpdate();

		if( invalidated ) {
			invalidated = false;
			render();
		}
	}
}

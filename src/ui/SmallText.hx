package ui;

class SmallText extends Entity {
	var wrapper : h2d.Object;
	var tf : h2d.Text;

	public function new(str:String, ?c = 0xFFFFFF) {
		super(cx, cy);
		wrapper = new h2d.Object();
		game.scroller.add(wrapper, Const.DP_UI);
		tf = new h2d.Text(Assets.fontPixel, wrapper);
		tf.text = str;
		tf.textColor = c;
	}

	override function dispose() {
		super.dispose();
		wrapper.remove();
	}

	override function postUpdate() {
		spr.set("pixel");
		spr.visible = false;
		spr.alpha = 0;
		wrapper.x = (level.level.pxWid-tf.textWidth)/2;
		wrapper.y = ((level.level.pxHei/2)-tf.textHeight*2)+Const.GRID;		
		super.postUpdate();
	}

	override function update() {
		super.update();
	}
}
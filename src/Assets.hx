import dn.heaps.slib.*;

class Assets {
	public static var SLIB = dn.heaps.assets.SfxDirectory.load("sfx");
	public static var ldtkTilesets : Map<String,h2d.Tile>;

	public static var fontPixel : h2d.Font;
	public static var fontTiny : h2d.Font;
	public static var fontSmall : h2d.Font;
	public static var fontMedium : h2d.Font;
	public static var fontLarge : h2d.Font;
	public static var fontRound : h2d.Font;
	public static var tiles : SpriteLib;

	static var initDone = false;
	public static function init() {
		if( initDone )
			return;
		initDone = true;

		ldtkTilesets = [
			"Tiles" => hxd.Res.world.Tileset.toTile(),
		];

		fontPixel = hxd.Res.fonts.minecraftiaOutline.toFont();
		fontTiny = hxd.Res.fonts.barlow_condensed_medium_regular_9.toFont();
		fontSmall = hxd.Res.fonts.barlow_condensed_medium_regular_11.toFont();
		fontMedium = hxd.Res.fonts.barlow_condensed_medium_regular_17.toFont();
		fontLarge = hxd.Res.fonts.barlow_condensed_medium_regular_32.toFont();
		fontRound = hxd.Res.fonts.Round9x13_32.toFont();
		tiles = dn.heaps.assets.Atlas.load("atlas/tiles.atlas");
		tiles.defineAnim("HeroIdle", "1(2), 3(2), 5(2), 7(2), 9(2)");
		tiles.defineAnim("HeroRun", "0(1), 1(1), 2(1), 3(1), 4(1), 5(1), 6(1), 7(1), 8(1), 9(1), 10(1), 11(1)");
	}
}
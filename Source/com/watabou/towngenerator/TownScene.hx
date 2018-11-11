package com.watabou.towngenerator;

import openfl.display.Sprite;

import com.watabou.coogee.Scene;
import com.watabou.coogee.Game;
import com.watabou.utils.Random;

import com.watabou.towngenerator.building.Model;
import com.watabou.towngenerator.mapping.CityMap;
import com.watabou.towngenerator.ui.Button;
import com.watabou.towngenerator.ui.Tooltip;

class TownScene extends Scene {

	private var buttons	: Sprite;
	private var map		: CityMap;

	public function new() {
		super();

		map = new CityMap( Model.instance );
		addChild( map );

		addChild( new Tooltip() );

		buttons = new Sprite();
		addChild( buttons );

		var smallTown = new Button("Small Town");
    smallTown.click.add(function() { set_size(6, 10); });
		var largeTown = new Button("Large Town");
    largeTown.click.add(function() { set_size(10, 15); });
		var smallCity = new Button("Small City");
    smallCity.click.add(function() { set_size(15, 24); });
		var largeCity = new Button("Large City");
    largeCity.click.add(function() { set_size(24, 40); });

		var pos = 0.0;
		for (btn in [smallTown, largeTown, smallCity, largeCity]) {
			btn.y = pos;
			pos += btn.height + 1;
			buttons.addChild( btn );
		}
	}

	private var scale(get,set) : Float;
	private inline function get_scale():Float
		return map.scaleX;
	private function set_scale( value:Float ):Float
		return (map.scaleX = map.scaleY = value);

  private function set_size(minSize: Int, maxSize: Int): Void {
    var size = minSize + Std.int( Math.random() * (maxSize - minSize) );
  	StateManager.size = size;
  	StateManager.seed = Random.getSeed();
  	StateManager.pushParams();

  	new Model( size );
  	Game.switchScene( TownScene );
  }

	override public function layout():Void {
		map.x = rWidth / 2;
		map.y = rHeight / 2;

		var scaleX = rWidth / Model.instance.cityRadius;
		var scaleY = rHeight / Model.instance.cityRadius;
		var scMin = Math.min( scaleX, scaleY );
		var scMax = Math.max( scaleX, scaleY );
		scale = (scMax / scMin > 2 ? scMax / 2 : scMin) * 0.5;

		buttons.x = rWidth - buttons.width - 1;
		buttons.y = 1;
	}
}

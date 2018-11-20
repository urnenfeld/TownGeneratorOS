package com.watabou.towngenerator.medieval;

import openfl.errors.Error;
import openfl.geom.Point;

import com.watabou.geom.Polygon;
import com.watabou.utils.Random;

using com.watabou.utils.ArrayExtender;
using com.watabou.utils.PointExtender;

class CurtainWall {

	public var shape	: Polygon;
	public var segments	: Array<Bool>;
	public var gates	: Array<Point>;
	public var towers	: Array<Point>;

	private var real	: Bool;
	private var patches	: Array<Patch>;

	public function new( real:Bool, model:Model, patches:Array<Patch>, reserved:Array<Point> ) {
		this.real = true;
		this.patches = patches;
    this.gates = model.gates;

		if (patches.length == 1)
			shape = patches[0].shape
		else {
			shape = Model.findCircumference( patches );

			if (real) {
				var smoothFactor = Math.min( 1, 40 / patches.length );
				shape.set( [for (v in shape)
					reserved.contains( v ) ? v : shape.smoothVertex( v, smoothFactor )
				] );
			}
		}

		segments = [for (v in shape) true];
	}

	public function buildTowers() {
		towers = [];
		if (real) {
			var len = shape.length;
			for (i in 0...len) {
				var t = shape[i];
				if (!gates.contains( t ) && (segments[(i + len - 1) % len] || segments[i]))
					towers.push( t );
			}
		}
	}

	public function getRadius():Float {
		var radius = 0.0;
		for (v in shape)
			radius = Math.max( radius, v.length );
		return radius;
	}

	public function bordersBy( p:Patch, v0:Point, v1:Point ):Bool {
		var index = patches.contains( p ) ?
			shape.findEdge( v0, v1 ) :
			shape.findEdge( v1, v0 );
		if (index != -1 && segments[index])
			return true;

		return false;
	}

	public function borders( p:Patch ):Bool {
		var withinWalls = patches.contains( p );
		var length = shape.length;

		for (i in 0...length) if (segments[i]) {
			var v0 = shape[i];
			var v1 = shape[(i + 1) % length];
			var index = withinWalls ?
				p.shape.findEdge( v0, v1 ) :
				p.shape.findEdge( v1, v0 );
			if (index != -1)
				return true;
		}

		return false;
	}
}

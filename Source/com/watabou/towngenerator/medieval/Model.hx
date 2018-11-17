package com.watabou.towngenerator.medieval;

import Type;
import openfl.errors.Error;
import openfl.geom.Point;

import com.watabou.geom.Polygon;
import com.watabou.geom.Segment;
import com.watabou.geom.Voronoi;
import com.watabou.utils.MathUtils;
import com.watabou.utils.Random;

import com.watabou.towngenerator.medieval.wards.*;

using com.watabou.utils.PointExtender;
using com.watabou.utils.ArrayExtender;

class Model {
	public var patches	: Array<Patch> = [];

	// For a walled city it's a list of patches within the walls,
	// for a city without walls it's just a list of all city wards
	public var inner	: Array<Patch> = [];
	public var citadel	: Patch;
	public var plaza	: Patch;
	public var center	: Point;

	public var border	: CurtainWall;
	public var wall		: CurtainWall;

  private var _cityRadius: Float = -1;
	public var cityRadius(get,never): Float;
  public function get_cityRadius(): Float {
    if (_cityRadius == -1) {
      _cityRadius = Lambda.fold(patches, function(patch: Patch, radius: Float) {
        if (patch.withinCity) {
          var max = patch.shape.max(function(p) { return p.length; }).length;
          return Math.max(radius, max);
        } else {
          return radius;
        }
      }, 0);
    }

    return _cityRadius;
  }

	// List of all entrances of a city including castle gates
	public var gates	: Array<Point> = [];

	// Joined list of streets (inside walls) and roads (outside walls)
	// without diplicating segments
	public var arteries	: Array<Street> = [];
	public var streets	: Array<Street> = [];
	public var roads	: Array<Street> = [];

  public function new() {}

	public static function findCircumference( wards:Array<Patch> ):Polygon {
		if (wards.length == 0)
			return new Polygon()
		else if (wards.length == 1)
			return new Polygon( wards[0].shape );

		var A:Array<Point> = [];
		var B:Array<Point> = [];

		for (w1 in wards)
			w1.shape.forEdge( function(a, b ) {
				var outerEdge = true;
				for (w2 in wards)
					if (w2.shape.findEdge( b, a ) != -1) {
						outerEdge = false;
						break;
					}
				if (outerEdge) {
					A.push( a );
					B.push( b );
				}
			} );

		var result = new Polygon();
		var index = 0;
		do {
			result.push( A[index] );
			index = A.indexOf( B[index] );
		} while (index != 0);

		return result;
	}

	public function patchByVertex( v:Point ):Array<Patch> {
		return patches.filter(
			function( patch:Patch ) return patch.shape.contains( v )
		);
	}

	public function getNeighbour( patch:Patch, v:Point ):Patch {
		var next = patch.shape.next( v );
		for (p in patches)
			if (p.shape.findEdge( next, v ) != -1)
				return p;
		return null;
	}

	public function getNeighbours( patch:Patch ):Array<Patch>
		return patches.filter( function( p:Patch ) return p != patch && p.shape.borders( patch.shape ) );

	// A ward is "enclosed" if it belongs to the city and
	// it's surrounded by city wards and water
	public function isEnclosed( patch:Patch ):Bool {
		return patch.withinCity && (patch.withinWalls || getNeighbours( patch ).every( function( p:Patch ) return p.withinCity ));
	}
}

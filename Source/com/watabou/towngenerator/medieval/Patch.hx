package com.watabou.towngenerator.medieval;

import openfl.geom.Point;

import com.watabou.geom.Polygon;
import com.watabou.geom.Segment;
import com.watabou.geom.Voronoi.Region;

import com.watabou.towngenerator.model.Edge;
import com.watabou.towngenerator.medieval.wards.Ward;

using com.watabou.utils.ArrayExtender;

class Patch {
  public var edges  : Array<Edge>;
  public var shape  : Polygon;
  public var ward   : Ward;

  public var geometry(get,never): Polygon;

  public var withinWalls  : Bool = false;
  public var withinCity  : Bool = false;

  public inline function new(vertices: Array<Point>, edges: Array<Edge>) {
    this.shape = new Polygon( vertices );
    this.edges = edges;
  }

  public function get_geometry(): Polygon {
    var points = [];

    for (edges in this.edges.eachCons(2, true)) {
      var edge = edges[0];
      var next = edges[1];
      var offset1: Segment;
      var offset2: Segment;

      if (edge.end == next.start || edge.end == next.end) {
        offset1 = edge.right;
      } else {
        offset1 = edge.left;
      }

      if (next.start == edge.start || next.start == edge.end) {
        offset2 = next.right;
      } else {
        offset2 = next.left;
      }

      points.push(offset1.intersect(offset2));
    }

    return new Polygon(points);
  }
}

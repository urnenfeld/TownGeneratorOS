package com.watabou.geom;

import openfl.geom.Point;

class Segment {
  public var start  : Point;
  public var end    : Point;

  public inline function new( start:Point, end:Point ) {
    this.start   = start;
    this.end  = end;
  }

  public var dx(get,null)  : Float;
  public inline function get_dx() return (end.x - start.x);

  public var dy(get,null)  : Float;
  public inline function get_dy() return (end.y - start.y);

  public var vector(get,null)  : Point;
  public inline function get_vector() return end.subtract( start );

  public var length(get,null)  : Float;
  public inline function get_length() return Point.distance( start, end );

  public function reverse(): Segment {
    return new Segment(this.end, this.start);
  }

  public function intersect(other: Segment): Point {
    var a = this.start;
    var b = this.end;
    var c = other.start;
    var d = other.end;

    var xNum = ((a.x * b.y - a.y * b.x) * (c.x - d.x)) - ((a.x - b.x) * (c.x * d.y - c.y * d.x));
    var yNum = ((a.x * b.y - a.y * b.x) * (c.y - d.y)) - ((a.y - b.y) * (c.x * d.y - c.y * d.x));
    var den = ((a.x - b.x) * (c.y - d.y)) - ((a.y - b.y) * (c.x - d.x));
    var x = xNum / den;
    var y = yNum / den;

    return new Point(x, y);
  }
}


### Currently just a colored rectangle.
class Gamebase::Object {
	has $.x is rw = 0;
	has $.y is rw = 0;
	has $.w is rw = 1;
	has $.h is rw = 1;
	has $.color is rw = 0;
	has $.xspeed is rw = 0;  # should these be given to a Gamebase::Sprite class?
	has $.yspeed is rw = 0;

	 # multi methods cause "no candidates found for invoke()" error
	method collision (Gamebase::Object $other) {
		return 0 if $.x + $.w <= $other.x;
		return 0 if $.y + $.h <= $other.y;
		return 0 if $.x >= $other.x + $other.w;
		return 0 if $.y >= $other.y + $other.h;
		return 1
	}
	 # and this doesn't work at all...
	method collision_class (Class $other) {
		return @Gamebase::Objects.grep: {
			.isa($other) and self.coll($_)
		}
	}
	 # Rectangle bouncing; does not account for the motion of $other.
	 # Call these after checking for collisions.
	method bounce_top(Gamebase::Object $other) {
		$.yspeed = -$.yspeed;
		$.y = $other.y * 2 - ($.y + $.h) - $.h;
	}
	method bounce_left(Gamebase::Object $other) {
		$.xspeed = -$.xspeed;
		$.x = $other.x * 2 - ($.x + $.w) - $.w;
	}
	method bounce_bottom(Gamebase::Object $other) {
		$.yspeed = -$.yspeed;
		$.y = ($other.y + $other.h) * 2 - $.y;
	}
	method bounce_right(Gamebase::Object $other) {
		$.xspeed = -$.xspeed;
		$.x = ($other.x + $other.w) * 2 - $.x;
	}
	method bounce(Gamebase::Object $other) {
		my $left = ($.x - $.xspeed) + $.w - $other.x;
		my $right = $other.x + $other.w - ($.x - $.xspeed);
		my $top = ($.y - $.yspeed) + $.h - $other.y;
		my $bottom = $other.y + $other.h - ($.y - $.yspeed);
		if ($left <= $top & $bottom & $right) {
			self.bounce_left($other);
		}
		elsif ($right <= $top & $bottom) {
			self.bounce_right($other);
		}  # Can bounce off corners too.
		if ($top <= $left & $right & $bottom) {
			self.bounce_top($other);
		}
		elsif ($bottom <= $left & $right) {
			self.bounce_bottom($other);
		}
	}
}


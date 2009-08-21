
### Currently just a colored rectangle.
class Gamebase::Object {
	has $.x is rw = 0;
	has $.y is rw = 0;
	has $.w is rw = 1;
	has $.h is rw = 1;
	has $.color is rw = 0;
	has $.xspeed is rw = 0;
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
	 # Rectangle bouncing; does not account for motion.
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
		my $left_overlap = $.x + $.w - $other.x;
		my $right_overlap = $other.x + $other.w - $.x;
		my $top_overlap = $.y + $.h - $other.y;
		my $bottom_overlap = $other.y + $other.h - $.y;
		 # This algorithm prefers left and top when ambiguous.
		if ($left_overlap <= $top_overlap & $bottom_overlap & $right_overlap) {
			self.bounce_left($other);
		}
		elsif ($right_overlap <= $top_overlap & $bottom_overlap) {
			self.bounce_right($other);
		}  # Can bounce off corners too.
		if ($top_overlap <= $left_overlap & $right_overlap & $bottom_overlap) {
			self.bounce_top($other);
		}
		elsif ($bottom_overlap <= $left_overlap & $right_overlap) {
			self.bounce_bottom($other);
		}
	}
}



### Currently just a colored rectangle.
class Gamebase::Sprite {
	has $.x is rw = 0;
	has $.y is rw = 0;
	has $.w is rw = 1;
	has $.h is rw = 1;
	has $.color is rw = 0;
	has $.xspeed is rw = 0;  # should these be given to a Gamebase::Sprite class?
	has $.yspeed is rw = 0;

	 # On creation register with Gamebase
	method new (*%_) {
		my $self = self.bless(*, |%_);
		Gamebase::register_object($self);
		return $self;
	}

	method destroy() {
		Gamebase::destroy(self);
	}
	 
	 # Rectangle collision detection
	method collision (Gamebase::Sprite $other) {
		 # any() disappears inside junctions and is false otherwise.
		return any() if $.x + $.w <= $other.x;
		return any() if $.y + $.h <= $other.y;
		return any() if $.x >= $other.x + $other.w;
		return any() if $.y >= $other.y + $other.h;
		return $other
	}
	 # This should be superseded by class methods or something.
	 # Like maybe self.collision(Object.any), or Object.List
	method collision_class (Gamebase::Sprite $other) {
		return @Gamebase::Sprites.first: {
			.isa($other) and self.collision($_)
		}
	}
	 # Rectangle bouncing; does not account for the motion of $other.
	 # Call these after checking for collisions.
	method bounce_top(Gamebase::Sprite $other) {
		$.yspeed = -$.yspeed;
		$.y = $other.y * 2 - ($.y + $.h) - $.h;
	}
	method bounce_left(Gamebase::Sprite $other) {
		$.xspeed = -$.xspeed;
		$.x = $other.x * 2 - ($.x + $.w) - $.w;
	}
	method bounce_bottom(Gamebase::Sprite $other) {
		$.yspeed = -$.yspeed;
		$.y = ($other.y + $other.h) * 2 - $.y;
	}
	method bounce_right(Gamebase::Sprite $other) {
		$.xspeed = -$.xspeed;
		$.x = ($other.x + $other.w) * 2 - $.x;
	}
	method bounce(Gamebase::Sprite $other) {  # This is not completely accurate
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

	method _any() {
		return any( Gamebase::objects_of_type(self) );
	}
	method _all() {
		return all( Gamebase::objects_of_type(self) );
	}
	method _list() {
		return Gamebase::objects_of_type(self);
	}
}


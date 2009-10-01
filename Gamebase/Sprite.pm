use Gamebase;
use SDL;

class Gamebase::Sprite {
	has $.active is rw = 1;
	has Num $.x is rw = 0;
	has Num $.y is rw = 0;
	has Num $.w;
	has Num $.h;
	has Int $.color;
	has $.surface;
	has Num $.xspeed is rw = 0;
	has Num $.yspeed is rw = 0;
	has Int $.depth = 0;
	
	 # Default events
	method move {
		$.x += $.xspeed;
		$.y += $.yspeed;
	}
	method draw {
		state $r = SDL::Rect.new;
		state $sr = SDL::Rect.new(x => 0, y => 0, w => $.w, h => $.h);
		$r.x: truncate $.x;
		$r.y: truncate $.y;
		$r.w: truncate $.w;
		$r.h: truncate $.h;
		if defined $.color {
			SDL::FillRect($Gamebase::Window, $r.raw, $.color);
		}
		if defined $.surface {
			SDL::BlitSurface($.surface.raw, $sr.raw, $Gamebase::Window, $r.raw);
		}
	}

	 # On creation register with Gamebase
	method new (*%_) {
		my $self = self.bless(*, |%_);
		Gamebase::register_sprite($self);
		return $self;
	}

	method destroy() {
		undefine self;  # I don't know if this is supposed to work but it seems to.
	}
	 
	 # Rectangle collision detection
	method collision (Gamebase::Sprite $other) {
		return 0 if $.x + $.w <= $other.x;
		return 0 if $.y + $.h <= $other.y;
		return 0 if $.x >= $other.x + $other.w;
		return 0 if $.y >= $other.y + $other.h;
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
		my $left   = $.xspeed > 0 ?? $.x      + $.w      - $other.x !! Inf;
		my $right  = $.xspeed < 0 ?? $other.x + $other.w - $.x      !! Inf;
		my $top    = $.yspeed > 0 ?? $.y      + $.h      - $other.y !! Inf;
		my $bottom = $.yspeed < 0 ?? $other.y + $other.h - $.y      !! Inf;
		if ($left <= $top & $bottom) {
			self.bounce_left($other);
		}
		elsif ($right <= $top & $bottom) {
			self.bounce_right($other);
		}  # Can bounce off corners too.
		if ($top <= $left & $right) {
			self.bounce_top($other);
		}
		elsif ($bottom <= $left & $right) {
			self.bounce_bottom($other);
		}
	}

	method _any() {
		return any( Gamebase::sprites_of_type(self) );
	}
	method _all() {
		return all( Gamebase::sprites_of_type(self) );
	}
	method _list() {
		return Gamebase::sprites_of_type(self);
	}
}
register_event Gamebase::Sprite, %Gamebase::EVENT_LOOKUP<move>;
register_event Gamebase::Sprite, %Gamebase::EVENT_LOOKUP<draw>;


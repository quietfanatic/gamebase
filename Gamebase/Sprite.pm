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

	$Gamebase::Sprite::CURRENTLY_DEFINING = Gamebase::Sprite;
	%Gamebase::Sprite::Class<Gamebase::Sprite> = {children => {}, instances => {}}

	 # workaround until we get a proper subclassing hook
	method inherit_from (Gamebase::Sprite $parent) is export {
		$Gamebase::Sprite::CURRENTLY_DEFINING = self;
		%Gamebase::Sprite::Class{self.WHAT.perl} = hash %Gamebase::Sprite::CLASS_DATA{$parent.WHAT.perl}.pairs;
	}
	sub event (&method) is export {
		Gamebase::register_event($Gamebase::Sprite::CURRENTLY_DEFINING, &method);
	}

	 # Default events
	event method move {
		$.x += $.xspeed;
		$.y += $.yspeed;
	}
	has $!R;
	has $!SR;
	event method draw {
		$!R //= SDL::Rect.new(w => $.w, h => $.h);
		$!SR //= SDL::Rect.new(x => 0, y => 0, w => $.w, h => $.h);
		my $intx = truncate $.x;
		my $inty = truncate $.y;
		my $RECT := $!R.raw;
		Q:PIR {  # Inline this process for speed
			$P0 = find_lex '$RECT'
			$P1 = find_lex '$intx'
			$I0 = $P1
			$P0['x'] = $I0
			$P1 = find_lex '$inty'
			$I0 = $P1
			$P0['y'] = $I0
		};
		if defined $.color {
			SDL::FillRect($Gamebase::Window, $!R.raw, $.color);
			 # Due to a feature of FillRect, $!R.w and $!R.h get clipped.
			 # Most Gamebase users will not expect this.
			my $intw = truncate $.w;
			my $inth = truncate $.h;
			Q:PIR {  # Inlined for speed
				$P0 = find_lex '$RECT'
				$P1 = find_lex '$intw'
				$I0 = $P1
				$P0['width'] = $I0
				$P1 = find_lex '$inth'
				$I0 = $P1
				$P0['height'] = $I0
			};
		}
		if defined $.surface {
			SDL::BlitSurface($.surface.raw, $!SR.raw, $Gamebase::Window, $!R.raw);
		}
	}

	 # On creation register with Gamebase
	method new (*%_) {
		my $self = self.bless(*, |%_);
		Gamebase::register_sprite($self);
		$self;
	}

	method destroy() {
		undefine self;  # I don't know if this is supposed to work but it seems to.
	}
	 
	 # Rectangle collision detection
	method collision (Gamebase::Sprite $other) {
		if    $.x + $.w <= $other.x      { 0 }
		elsif $.y + $.h <= $other.y      { 0 }
		elsif $.x >= $other.x + $other.w { 0 }
		elsif $.y >= $other.y + $other.h { 0 }
		else { $other }
	}
	 # This should be superseded by class methods or something.
	 # Like maybe self.collision(Sprite.any), or Sprite.List
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

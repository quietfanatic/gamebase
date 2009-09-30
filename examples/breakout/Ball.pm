use SDL;
use SDL::Surface;
use Gamebase::Boundary;

class Ball is Gamebase::Sprite {
	has $.x is rw = 0;
	has $.y is rw = 0;
	has $.w is rw = 6;
	has $.h is rw = 6;
	has $.surface = SDL::Surface.new(image => 'examples/breakout/ball.png');
	has $.live is rw = 0;
	method after_move {
		if self.collision($*paddle) {
			self.bounce($*paddle);
			$.xspeed += 0.0 + (($.x + $.w/2) - ($*paddle.x + $*paddle.w/2)) / 3;
			$.xspeed max= -16;
			$.xspeed min= 16;
		}
		if $.x < 0 {  # left side bounce
			self.bounce_right($Gamebase::Boundary);
		}
		if $.x + $.w > $Gamebase::Width {  # right side bounce
			self.bounce_left($Gamebase::Boundary);
		}
		if $.y < 0 {  # top bounce
			self.bounce_bottom($Gamebase::Boundary);
		}
		if $.y >= $Gamebase::Height {  # lost ball
			$.live = 0;
			$.xspeed = 0;
			$.yspeed = 0;
		}
	}
}
Gamebase::register_event Ball, %Gamebase::EVENT_LOOKUP<after_move>;

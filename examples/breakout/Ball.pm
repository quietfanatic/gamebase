use SDL;
use Gamebase::Boundary;

class Ball is Gamebase::Object {
	has $.x is rw = 0;
	has $.y is rw = 0;
	has $.w is rw = 6;
	has $.h is rw = 6;
	has $.xspeed is rw = 0;
	has $.yspeed is rw = 0;
	has $.color = rgb(255, 255, 255);
	has $.live is rw = 0;
	method step {
		$.x += $.xspeed;  # Maybe this should be automatic for Gamebase::Objects.
		$.y += $.yspeed;
		if self.collision($*paddle) {
			self.bounce($*paddle);
			$.xspeed += (truncate ($.x + $.w/2) - ($*paddle.x + $*paddle.w/2)) / 6;
			$.xspeed max= -8;
			$.xspeed min= 8;
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

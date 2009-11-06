use SDL;
use Gamebase;
use Gamebase::Sprite;

class Paddle is Gamebase::Sprite {
	has $.x is rw = 140;
	has $.xspeed is rw = 0;
	has $.y is rw = $Gamebase::Height - 20;
	has $.w is rw = 40;
	has $.h is rw = 6;
	has $.color = rgb(255, 255, 255);
	Paddle.event: method before_move {
		 # set speed
		if @Gamebase::Key_Press[275] {  # SDLK_RIGHT
			if @Gamebase::Key_Press[276] {  # SDLK_LEFT
				$.xspeed = 0
			}
			else {  # speed is 2, 5, 8, 8 ...
				$.xspeed max= 0;
				$.xspeed =
				   $.xspeed == 0 ?? 2
				!! $.xspeed == 2 ?? 5
				!! $.xspeed == 5 ?? 8
				!!                  8
			}
		}
		elsif @Gamebase::Key_Press[276] {  # SDLK_LEFT
			$.xspeed min= 0;
			$.xspeed =
			   $.xspeed ==  0 ?? -2
			!! $.xspeed == -2 ?? -5
			!! $.xspeed == -5 ?? -8
			!!                   -8
		}
		else {
			$.xspeed = 0
		}

		 # quit on ESC
		Gamebase::quit if @Gamebase::Key_Press[27];  # SDLK_ESCAPE

		 # launch ball
		unless $*ball.live {
			$*ball.x = $.x + $.w/2 - $*ball.w/2;
			$*ball.y = $.y - 10;
			if @Gamebase::Key_Press[273] {  # SDLK_UP
				$*ball.live = 1;
				$*ball.xspeed = 6;
				$*ball.yspeed = -6;
			}
		}
	}
}

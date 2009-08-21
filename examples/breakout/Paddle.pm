use SDL;
use Gamebase;
use Gamebase::Object;

class Paddle is Gamebase::Object {
	has $.x is rw = 100;
	has $.xspeed is rw = 0;
	has $.y is rw = $Gamebase::Height - 20;
	has $.w is rw = 40;
	has $.h is rw = 6;
	has $.color = rgb(255, 255, 255);
	method step {
		 # set speed
		if @Gamebase::Key_Press[275] {  # SDLK_RIGHT
			if @Gamebase::Key_Press[276] {  # SDLK_LEFT
				$.xspeed = 0
			}
			else {  # speed is 1, 2, 4, 4 ...
				$.xspeed max= 0;
				$.xspeed =
				   $.xspeed == 0 ?? 1
				!! $.xspeed == 1 ?? 2
				!! $.xspeed == 2 ?? 4
				!!                  4
			}
		}
		elsif @Gamebase::Key_Press[276] {  # SDLK_LEFT
			$.xspeed min= 0;
			$.xspeed =
			   $.xspeed ==  0 ?? -1
			!! $.xspeed == -1 ?? -2
			!! $.xspeed == -2 ?? -4
			!!                   -4
		}
		else {
			$.xspeed = 0
		}

		 # move
		$.x += $.xspeed;
		$.x max= 0;
		$.x min= $Gamebase::Width - $.w;

		 # quit on ESC
		Gamebase::quit if @Gamebase::Key_Press[27];  # SDLK_ESCAPE

		 # launch ball
		unless $*ball.live {
			$*ball.x = $.x + $.w/2 - $*ball.w/2;
			$*ball.y = $.y - 10;
			if @Gamebase::Key_Press[273] {  # SDLK_UP
				$*ball.live = 1;
				$*ball.xspeed = 3;
				$*ball.yspeed = -3;
			}
		}
	}
}

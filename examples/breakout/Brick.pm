use SDL;


class Brick is Gamebase::Sprite {
	has $.w is rw = 32;
	has $.h is rw = 12;
	has $.color = rgb(63 + rand * 186, 63 + rand * 186, 63 + rand * 186);
	our $Brick_Surface = SDL::Surface.new(image => 'examples/breakout/brick.png');
	has $.surface = $Brick_Surface;
	method step {
		if self.collision($*ball) {
			$*ball.bounce(self);
			self.destroy;
		}
	}
}

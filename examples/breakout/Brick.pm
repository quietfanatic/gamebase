use SDL;

class Brick is Gamebase::Object {
	has $.w is rw = 32;
	has $.h is rw = 12;
	has $.color = rgb(128 + rand * 127, 128 + rand * 127, 128 + rand * 127);
	method step {
		if self.collision($*ball) {
			$*ball.bounce(self);
			self.destroy;
		}
	}
}

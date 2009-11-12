use Gamebase::Sprite;

class Gamebase::Boundary is Gamebase::Sprite {
	Gamebase::Boundary.inherit_from(Gamebase::Sprite);
	method x () {
		return $Gamebase::Width
	}
	method y () {
		return $Gamebase::Height
	}
	method w () {
		return -$Gamebase::Width
	}
	method h () {
		return -$Gamebase::Height
	}
}

$Gamebase::Boundary = Gamebase::Boundary.new;


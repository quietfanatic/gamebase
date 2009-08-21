use Gamebase::Object;

class Gamebase::Boundary is Gamebase::Object {
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


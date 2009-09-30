use SDL;
use SDL::Rect;
use SDL::Event;

module Gamebase;
our $Refresh_Back = 0;
our $Width = 640;
our $Height = 480;
our $Window_Flags = 1;
our @Key_Press;  # Rakudo doesn't yet understand "my @array[shape]"
@Key_Press[322] = undef;  # So we preallocate manually
our $All_Rect;
our $FPS = 30;


### MAIN GAME LOOP

sub step () {
	our %of_class;
	for (all_sprites) {  # rakudo thinks it's a sub for without the parens.
		.?step if .?active;
	}
}
sub draw () {  # Perhaps draw should be a method on Gamebase::Sprite.
	our $Window, $All_Rect, $Refresh_Back, $Width, $Height;
	state $r = SDL::Rect.new;
	state $sr = SDL::Rect.new(x => 0, y => 0);
	SDL::FillRect($Window, $All_Rect.raw, 0) if $Refresh_Back;
	for (all_sprites) {
		next unless .?active;
		$r.x: truncate .x;
		$r.y: truncate .y;
		$r.w: truncate .w;
		$r.h: truncate .h;
		if defined .color {
			SDL::FillRect($Window, $r.raw, .color);
		}
		if defined .surface {
			$sr.w: .w;
			$sr.h: .h;
			SDL::BlitSurface(.surface.raw, $sr.raw, $Window, $r.raw);
		}
	}
	SDL::UpdateRect($Window, 0, 0, $Width, $Height);
}

sub play () is export {
	our $Window, $All_Rect, $Width, $Height, $Window_Flags, @Key_Press, $FPS, %EVENT_LOOKUP;
	$All_Rect = SDL::Rect.new(w => $Width, h => $Height);
	$Window = SDL::SetVideoMode($Width, $Height, 32, $Window_Flags);
	my $sdlevent = SDL::Event.new;
	$sdlevent.set(4, 0);
	loop {
		while $sdlevent.poll {
			given $sdlevent.type {
				when 2 {  # key down
					@Key_Press[$sdlevent.sym] = 1;
				}
				when 3 {  # key up
					@Key_Press[$sdlevent.sym] = 0;
				}
				when 12 {  # SDL quit
					quit;
				}
			}
		}
		perform_event %EVENT_LOOKUP<step>;
		SDL::FillRect($Window, $All_Rect.raw, 0) if $Refresh_Back;
		perform_event %EVENT_LOOKUP<draw>;
		SDL::UpdateRect($Window, 0, 0, $Width, $Height);
		state $ticks = 0;
		state $oldticks = SDL::GetTicks;
		$ticks = SDL::GetTicks;
		SDL::Delay 0 max truncate((1000 / $FPS) - ($ticks - $oldticks));
		$oldticks = SDL::GetTicks;
	}
}

sub quit () is export {
	SDL::Quit;
	exit;
}


### REGISTRY
our %of_class;  # of Array of Array
%of_class<Gamebase::Sprite()> = [[]];  # otherwise we recurse all the way to Object()
 # Each entry is sorted by class, and consists of an array of arrays,
 # the first of which is the objects of that immediate type,
 # and the rest of which are the entries for inheriting types.

sub register_sprite (::Gamebase::Sprite $new) {
	our %of_class;
	my $what = $new.WHAT;
	unless %of_class.exists($what) {  # Never seen this class before
		%of_class{$what} = [[]];
		for $new.^parents(:local) -> $parent {  # Only immediate parents
			%of_class{$parent} //= [[]];  # Haven't seen parent either
			%of_class{$parent}.push: undef;
			%of_class{$parent}[*-1] = %of_class{$what};  # Ought to recurse
		}
	}
	add %of_class{$what}[0], $new;
}

sub add (@registry, $new) {
	for @registry {
		defined $_ || return ($_ = $new);
	}
	@registry.push: $new;
}

sub flatten ($piece) {  # Rakudo can't map with multis.
	if $piece ~~ Array { map &flatten, $piece.values.grep({defined $_}) }
	else { $piece }
}

sub for_all_sprites (&code) {

}

sub all_sprites {
	sprites_of_type(::Gamebase::Sprite);
}

sub sprites_of_type is export (::Gamebase::Sprite $type where undef) {
	our %of_class;
	return flatten %of_class{$type};  # flatten?
}

sub destroy is export (::Gamebase::Sprite $doomed) {
	$doomed.destroy;
}


### Events

enum Gamebase::Event <step draw>;  # Enums are still kinda borken.
our %EVENT_LOOKUP = enum <step draw>;  # so we need this.


our @Event_List;  # [Gamebase::Event] of Array of Gamebase::Sprite

sub perform_event ($ev) {
	our %of_class;
	our @Event_List;
	for @Event_List[$ev][] {
		map_event %of_class{$_}, $ev;
	}
}

sub map_event (@sprites, $ev) {
	for @sprites -> $item {
		next unless defined $item;
		if $item ~~ Array { map_event $item, $ev; next };
		next unless $item.active;
		given $ev {
			$item.step when 0;
			$item.draw when 1;
		}
	}
}

# Until we can do declarative syntax we have to stick with procedural
multi sub register_event is export ($type, $ev, :$target) {
	our @Event_List;
	 # If a parent already has this event, don't register for it.
	if defined @Event_List[$ev] {
		for $type.^parents {
			return say "$ev already has a $type that is $_" if grep @Event_List[$ev], $_;
		}
	}
	else {
		@Event_List[$ev] = [];
	}
	@Event_List[$ev].push: $type;
}

use SDL;
use SDL::Rect;
use SDL::Event;

module Gamebase;
our $Refresh_Back = 0;
our $Width = 640;
our $Height = 480;
our $Window_Flags = 1;
our Int @Key_Press;  # Rakudo doesn't yet understand "my @array[shape]"
@Key_Press[322] = undef;  # So we preallocate manually
our $All_Rect;
our @Objects;
our $FPS = 30;

sub step () {
	our @Objects;
	for @Objects {
		.?step;
	}
}
sub draw () {  # Perhaps draw should be a method on Gamebase::Object.
	our $Window, $All_Rect, $Refresh_Back, @Objects, $Width, $Height;
	state $r = SDL::Rect.new;
	SDL::FillRect($Window, $All_Rect.Item, 0) if $Refresh_Back;
	for @Objects {
		next if .?invisible;
		$r.x: .x;
		$r.y: .y;
		$r.w: .w;
		$r.h: .h;
		SDL::FillRect($Window, $r.Item, .color);
	}
	SDL::UpdateRect($Window, 0, 0, $Width, $Height);
}

sub play () is export {
	our $Window, $All_Rect, $Width, $Height, $Window_Flags, @Key_Press, $FPS;
	$All_Rect = SDL::Rect.new(w => $Width, h => $Height);
	$Window = SDL::SetVideoMode($Width, $Height, 32, $Window_Flags);
	my $event = SDL::Event.new;
	$event.set(4, 0);
	loop {
		while $event.poll {
			given $event.type {
				when 2 {  # key down
					@Key_Press[$event.sym] = 1;
				}
				when 3 {  # key up
					@Key_Press[$event.sym] = 0;
				}
				when 12 {  # SDL quit
					quit;
				}
			}
		}
		step;
		draw;
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

sub register_object (::Gamebase::Object $new) {
	our @Objects;
	@Objects.push($new);
}

sub destroy is export (::Gamebase::Object $doomed) {
	our @Objects;
	for 0..@Objects {
		if @Objects[$_] === $doomed {
			splice @Objects, $_, 1;
			return 1
		}
	}
	 # Didn't find any
	caller.warn: "Cannot destroy $doomed because it is not registered";
	return Failure
}


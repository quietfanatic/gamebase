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

sub play () is export {
	our $Window, $All_Rect, $Width, $Height, $Window_Flags, @Key_Press, $FPS, %EVENT_LOOKUP;
	$All_Rect = SDL::Rect.new(w => $Width, h => $Height);
	$Window = SDL::SetVideoMode($Width, $Height, 32, $Window_Flags);
	my $sdlevent = SDL::Event.new;
	$sdlevent.set(4, 0);  # No mouse movement for now.
	loop {  # main loop
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
		perform_event %EVENT_LOOKUP<before_move>;
		perform_event %EVENT_LOOKUP<move>;
		perform_event %EVENT_LOOKUP<after_move>;
		SDL::FillRect($Window, $All_Rect.raw, 0) if $Refresh_Back;
		perform_event %EVENT_LOOKUP<draw>;
		SDL::UpdateRect($Window, 0, 0, $Width, $Height);
		perform_event %EVENT_LOOKUP<after_draw>;
		state $ticks = 0;
		state $oldticks = SDL::GetTicks;
		$ticks = SDL::GetTicks;
		SDL::Delay 0 max truncate((1000 div $FPS) - ($ticks - $oldticks));
		$oldticks = SDL::GetTicks;
	}
}

sub quit () is export {
	SDL::Quit;
	exit;
}



### EVENTS

 # Enums are still kinda borken.
enum Gamebase::Event <before_move move after_move draw after_draw>;
our %EVENT_LOOKUP = enum <before_move move after_move draw after_draw>;

our @Event_List;  # [Gamebase::Event] of Array of Gamebase::Sprite

sub perform_event ($ev) {
	our %of_class;
	our @Event_List;
	return unless defined @Event_List[$ev];
	for @Event_List[$ev][] {
		map_event %Gamebase::Sprite::Class{$_.perl}<all_instances>, $ev;
	}
}

sub map_event (@sprites, $ev) {
	for @sprites -> $item {
		next unless defined $item;
		if $item ~~ Array { map_event $item, $ev; next }
		next unless $item.active;
		given $ev {
			$item.before_move when 0;
			$item.move        when 1;
			$item.after_move  when 2;
			$item.draw        when 3;
			$item.after_draw  when 4;
		}
	}
}

multi sub register_event is export ($type, &method) {
	our @Event_List;
	my $ev = %EVENT_LOOKUP{&method.name};
	 # If a parent already has this event, don't register for it.
	if defined @Event_List[$ev] {
		for $type.^parents {
			return if grep @Event_List[$ev], $_;
		}
	}
	else {
		@Event_List[$ev] = [];
	}
	@Event_List[$ev].push: $type;
}

use SDL;

class SDL::Event {
	has $!event;
	has $!type;
	submethod BUILD {
		my $s := $!event;
		q:PIR {
			$P0 = find_lex '$s'
			$P1 = get_hll_global ['SDL::NCI'], 'fetch_layout'
			$P2 = $P1('Event::Generic')
			$P3 = new 'ManagedStruct', $P2
			$P0.'!STORE'($P3)
		}
	}
	method poll () {
		my $s := $!event;
		my $t := $!type;
		q:PIR {
			$P0 = find_lex '$s'
			$P1 = get_hll_global ['SDL::NCI'], 'PollEvent'
			$P2 = $P1($P0)
			if $P2 goto type_check
			.return(0)
		  type_check:
			$P3 = find_lex '$t'
			$I3 = $P0['type']
			$P3.'!STORE'($I3)
			if $I3 == 2 goto keyboard_event
			if $I3 == 3 goto keyboard_event
			.return(1)
		  keyboard_event:
			$P4 = get_hll_global ['SDL::NCI'], 'fetch_layout'
			$P5 = $P4('Event::Keyboard')
			assign $P0, $P5
			.return(1)
		}
	}
	method set (Int $type, Int $state) {
		Q:PIR {
			$P0 = find_lex '$type'
			$P1 = find_lex '$state'
			$P2 = get_hll_global ['SDL::NCI'], 'EventState'
			$P2($P0, $P1)
		}
	}
	method type () {
		return $!type
	}
	method sym () {
		my $s := $!event;
		Q:PIR {
			$P0 = find_lex '$s'
			$I0 = $P0['sym']
			.return($I0)
		}
	}
	method Item () {
		return $!event
	}
}







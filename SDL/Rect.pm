use SDL;
class SDL::Rect {
	has $!rect;
	submethod BUILD(:$x = 0, :$y = 0, :$w = 0, :$h = 0) {
		my $s := $!rect;
		Q:PIR {
			$P0 = find_lex '$s'
			$P1 = find_lex '$x'
			$I0 = $P1
			$P2 = find_lex '$y'
			$I1 = $P2
			$P3 = find_lex '$w'
			$I2 = $P3
			$P4 = find_lex '$h'
			$I3 = $P4
			$P5 = get_hll_global ['SDL::NCI'], 'fetch_layout'
			$P6 = $P5('Rect')
			$P7 = new 'ManagedStruct', $P6
			$P7['x'] = $I0
			$P7['y'] = $I1
			$P7['width'] = $I2
			$P7['height'] = $I3
			$P0.'!STORE'($P7)
		};
	}
	method x ($new?) {
		my $s := $!rect;
		Q:PIR {
			$P0 = find_lex '$s'
			$P1 = find_lex '$new'
			$I0 = defined $P1
			unless $I0 goto getter
			$I0 = $P1
			$P0['x'] = $I0
			.return($I0)
		  getter:
			$I0 = $P0['x']
			.return($I0)
		};
	}
	method y ($new?) {
		my $s := $!rect;
		Q:PIR {
			$P0 = find_lex '$s'
			$P1 = find_lex '$new'
			$I0 = defined $P1
			unless $I0 goto getter
			$I0 = $P1
			$P0['y'] = $I0
			.return($I0)
		  getter:
			$I0 = $P0['y']
			.return($I0)
		};
	}
	method w ($new?) {
		my $s := $!rect;
		Q:PIR {
			$P0 = find_lex '$s'
			$P1 = find_lex '$new'
			$I0 = defined $P1
			unless $I0 goto getter
			$I0 = $P1
			$P0['width'] = $I0
			.return($I0)
		  getter:
			$I0 = $P0['width']
			.return($I0)
		};
	}
	method h ($new?) {
		my $s := $!rect;
		Q:PIR {
			$P0 = find_lex '$s'
			$P1 = find_lex '$new'
			$I0 = defined $P1
			unless $I0 goto getter
			$I0 = $P1
			$P0['height'] = $I0
			.return($I0)
		  getter:
			$I0 = $P0['height']
			.return($I0)
		};
	}
	method Item() {
		return $!rect
	}
}

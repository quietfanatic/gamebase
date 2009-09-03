use SDL;
use SDL::Rect;


# There will be four ways to create a Surface object.
# SDL::Surface.new( ... )
# SDL::Surfaec.new( :main, ... )
# SDL::Surface.new( :image => "filename", ... )
# SDL::Surface.new( :wrap => raw_surface, ... )


class SDL::Surface {

	has $!surface;
	has $!pixelformat;

	method new (:$w = 1, :$h = 1, :$bpp = 32, :$sw?, :$hw?, :$alpha?, :$colorkey?, :$image?) {
		my $s;
		my $p;
		if defined $image {
			Q:PIR {
				$P0 = find_lex '$image'
				$S0 = $P0
				$P0 = get_hll_global ['SDL::NCI'], 'IMG_Load'
				$P1 = $P0($S0)
				$P0 = get_hll_global ['SDL::NCI'], 'fetch_layout'
				$P2 = $P0('Surface')
				assign $P1, $P2
				$P0 = find_lex '$s'
				$P0.'!STORE'($P1)
				$P2 = $P1['format']
				$P0 = find_lex '$p'
				$P0.'!STORE'($P2)

			}
		}
		else {
			my $flags = 
			   (?$sw && 0)
			+| (?$hw && 1)
			+| (?$alpha && 65536)
			+| (?$colorkey && 4096);
			Q:PIR {
				$P0 = find_lex '$flags'
				$I0 = $P0
				$P0 = find_lex '$w'
				$I1 = $P0
				$P0 = find_lex '$h'
				$I2 = $P0
				$P0 = find_lex '$bpp'
				$I3 = $P0
				$P0 = get_hll_global ['SDL::NCI'], 'CreateRGBSurface'
				$P1 = $P0($I0, $I1, $I2, $I3, 0, 0, 0, 0)
				$P0 = get_hll_global ['SDL::NCI'], 'fetch_layout'
				$P2 = $P0('Surface')
				assign $P1, $P2
				$P0 = find_lex '$s'
				$P0.'!STORE'($P1)
				$P2 = $P1['format']
				$P0 = find_lex '$p'
				$P0.'!STORE'($P2)
			};
		};
		return self.bless(*, surface => $s, pixelformat => $p);
	}

	method DESTROY {
		my $s := $!surface;
		Q:PIR {
			$P0 = find_lex '$s'
			needs_destroy $P0
		}
	}

	method raw () {
		return $!surface;
	}


	 ### Field Access

	method w () {
		my $s := $!surface;
		Q:PIR {
			$P0 = find_lex '$s'
			$I0 = $P0['w']
			.return($I0)
		}
	}
	method h () {
		my $s := $!surface;
		Q:PIR {
			$P0 = find_lex '$s'
			$I0 = $P0['h']
			.return($I0)
		}
	}
	method pitch () {
		my $s := $!surface;
		Q:PIR {
			$P0 = find_lex '$s'
			$I0 = $P0['pitch']
			.return($I0)
		}
	}

	method bpp () {
		my $p := $!pixelformat;
		Q:PIR {
			$P0 = find_lex '$p'
			$I0 = $P0['BitsPerPixel']
			.return($I0)
		}
	}
	method rloss () {
		my $p := $!pixelformat;
		Q:PIR {
			$P0 = find_lex '$p'
			$I0 = $P0['Rloss']
			.return($I0)
		}
	}
	method gloss () {
		my $p := $!pixelformat;
		Q:PIR {
			$P0 = find_lex '$p'
			$I0 = $P0['Gloss']
			.return($I0)
		}
	}
	method bloss () {
		my $p := $!pixelformat;
		Q:PIR {
			$P0 = find_lex '$p'
			$I0 = $P0['Bloss']
			.return($I0)
		}
	}
	method aloss () {
		my $p := $!pixelformat;
		Q:PIR {
			$P0 = find_lex '$p'
			$I0 = $P0['Aloss']
			.return($I0)
		}
	}
	method rshift () {
		my $p := $!pixelformat;
		Q:PIR {
			$P0 = find_lex '$p'
			$I0 = $P0['Rshift']
			.return($I0)
		}
	}
	method gshift () {
		my $p := $!pixelformat;
		Q:PIR {
			$P0 = find_lex '$p'
			$I0 = $P0['Gshift']
			.return($I0)
		}
	}
	method bshift () {
		my $p := $!pixelformat;
		Q:PIR {
			$P0 = find_lex '$p'
			$I0 = $P0['Bshift']
			.return($I0)
		}
	}
	method ashift () {
		my $p := $!pixelformat;
		Q:PIR {
			$P0 = find_lex '$p'
			$I0 = $P0['Ashift']
			.return($I0)
		}
	}
	method rmask () {
		my $p := $!pixelformat;
		Q:PIR {
			$P0 = find_lex '$p'
			$I0 = $P0['Rmask']
			.return($I0)
		}
	}
	method gmask () {
		my $p := $!pixelformat;
		Q:PIR {
			$P0 = find_lex '$p'
			$I0 = $P0['Gmask']
			.return($I0)
		}
	}
	method bmask () {
		my $p := $!pixelformat;
		Q:PIR {
			$P0 = find_lex '$p'
			$I0 = $P0['Bmask']
			.return($I0)
		}
	}
	method amask () {
		my $p := $!pixelformat;
		Q:PIR {
			$P0 = find_lex '$p'
			$I0 = $P0['Amask']
			.return($I0)
		}
	}





	method blit_from (
		SDL::Surface $src,
		SDL::Rect $src_area,
		SDL::Rect $dest_pos
	) {
		SDL::BlitSurface(
			$src.raw,
			$src_area.raw,
			self.raw,
			$dest_pos.raw
		);
	}

	method blit_to (
		SDL::Rect $src_area,
		SDL::Surface $dest,
		SDL::Surface $dest_pos
	) {
		SDL::BlitSurface(
			self.raw,
			$src_area.raw,
			$dest.raw,
			$dest_pos.raw
		);
	}
	our &blit := &blit_to;

	method fill (SDL::Rect $area, $color) {
		SDL::FillRect(self.raw, $area.raw, $color);
	}
	
}

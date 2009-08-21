
module SDL;

Q:PIR {
	load_bytecode "SDL_.pir"
};

for <
	SetVideoMode
	Quit
	FillRect
	UpdateRect
	UpdateRects
	Flip
	FreeSurface
	LoadBMP_RW
	DisplayFormat
	BlitSurface
	WaitEvent
	PollEvent
	GetKeyName
	GetError
	SetColorKey
	LockSurface
	UnlockSurface
	CreateRGBSurface
	GetTicks
	Delay
> {
	my $f;
	Q:PIR {
		$P0 = find_lex '$f'
		$P1 = find_lex '$_'
		$S0 = $P1
		$P2 = get_hll_global ['SDL::NCI'], $S0
		$P0.'!STORE'($P2)
	};
	 # Rakudo doesn't support symbolic dereferencing!
	eval "our &{$_} = \$f";
}

sub rgb ($r, $g, $b) is export {
	 # XXX Just for LE systems for now
	return $b * 65536 + $g * 256 + $r;
}



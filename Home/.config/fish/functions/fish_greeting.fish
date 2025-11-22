function fish_greeting
	if type -q hyfetch
		hyfetch
  else if type -q fastfetch
		fastfetch
	end
end

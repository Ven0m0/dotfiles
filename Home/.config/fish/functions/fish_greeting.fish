function fish_greeting
	if command -q hyfetch
		hyfetch
  else if command -q fastfetch
		fastfetch
	end
end

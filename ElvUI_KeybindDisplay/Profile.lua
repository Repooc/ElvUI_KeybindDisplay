local E, L, V, P, G = unpack(ElvUI)

P.kd = {
	binding = {},
	replacements = {},
	shortElvUIText = true,
	noTruncateAll = false,
}

for i = 1, 10 do
	if i <= 4 then
		for j = 1, 12 do
			P.kd.binding['MULTIACTIONBAR'..i..'BUTTON'..j] = {
				hotKey = -1,
				noTruncate = false,
			}
		end
	end
	if i == 2 or i >= 7 then
		for j = 1, 12 do
			P.kd.binding['ELVUIBAR'..i..'BUTTON'..j] = {
				bar = 'bar'..i,
				hotKey = -1,
				noTruncate = false,
			}
		end
	end
	P.kd.binding['BONUSACTIONBUTTON'..i] = {
		bar = 'petbar',
		hotKey = -1,
		noTruncate = false,
	}
	P.kd.binding['SHAPESHIFTBUTTON'..i] = {
		bar = 'stancebar',
		hotKey = -1,
		noTruncate = false,
	}
end
for i = 1, 12 do
	P.kd.binding['ACTIONBUTTON'..i] = {
		bar = 'bar1',
		hotKey = -1,
		noTruncate = false,
	}
	P.kd.binding['MULTIACTIONBAR1BUTTON'..i].bar = 'bar6'
	P.kd.binding['MULTIACTIONBAR2BUTTON'..i].bar = 'bar5'
	P.kd.binding['MULTIACTIONBAR3BUTTON'..i].bar = 'bar3'
	P.kd.binding['MULTIACTIONBAR4BUTTON'..i].bar = 'bar4'
end

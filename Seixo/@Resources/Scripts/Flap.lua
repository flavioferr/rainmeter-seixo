-- Motor de letreiro split-flap: cada linha le o texto de uma medida (RowNSrc) e mostra
-- uma letra por celula (meters R<N>C<col>). Quando o texto muda, as letras "viram" passando
-- pelo alfabeto ate chegar na nova, como num painel de aeroporto. Variavel Flip=0 desliga.
-- Tudo em ASCII: acentos sao removidos (os paineis de verdade tambem nao tem).

function Initialize()
	seq = ' ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789:.-/%+'
	idx = {}
	for k = 1, #seq do idx[seq:sub(k, k)] = k end
	rows = {}
	local n = tonumber(SKIN:GetVariable('FlapRows')) or 0
	for i = 1, n do
		local r = {
			cols = tonumber(SKIN:GetVariable('Row' .. i .. 'Cols')) or 0,
			src = SKIN:GetVariable('Row' .. i .. 'Src'),
			align = SKIN:GetVariable('Row' .. i .. 'Align') or 'L',
			cur = {},
		}
		for c = 1, r.cols do r.cur[c] = ' ' end
		rows[i] = r
	end
	accents = {
		['\225'] = 'A', ['\224'] = 'A', ['\226'] = 'A', ['\227'] = 'A', ['\228'] = 'A',
		['\193'] = 'A', ['\192'] = 'A', ['\194'] = 'A', ['\195'] = 'A', ['\196'] = 'A',
		['\233'] = 'E', ['\232'] = 'E', ['\234'] = 'E', ['\201'] = 'E', ['\200'] = 'E', ['\202'] = 'E',
		['\237'] = 'I', ['\236'] = 'I', ['\205'] = 'I', ['\204'] = 'I',
		['\243'] = 'O', ['\242'] = 'O', ['\244'] = 'O', ['\245'] = 'O', ['\246'] = 'O',
		['\211'] = 'O', ['\210'] = 'O', ['\212'] = 'O', ['\213'] = 'O', ['\214'] = 'O',
		['\250'] = 'U', ['\249'] = 'U', ['\252'] = 'U', ['\218'] = 'U', ['\217'] = 'U', ['\220'] = 'U',
		['\231'] = 'C', ['\199'] = 'C', ['\241'] = 'N', ['\209'] = 'N',
	}
end

local function clean(s)
	s = (s or ''):gsub('[\128-\255]', function(ch) return accents[ch] or '' end)
	s = s:upper():gsub('[^ A-Z0-9:%.%-/%%+]', ' ')
	return s
end

function Update()
	local flip = tonumber(SKIN:GetVariable('Flip')) == 1
	local changed = false
	for i, r in ipairs(rows) do
		local m = SKIN:GetMeasure(r.src)
		local s = clean(m and m:GetStringValue() or ''):sub(1, r.cols)
		if r.align == 'C' then
			local pad = math.floor((r.cols - #s) / 2)
			s = string.rep(' ', pad) .. s
		elseif r.align == 'R' then
			s = string.rep(' ', r.cols - #s) .. s
		end
		s = s .. string.rep(' ', r.cols - #s)
		for c = 1, r.cols do
			local t, cu = s:sub(c, c), r.cur[c]
			if cu ~= t then
				local nx = t
				local a, b = idx[cu], idx[t]
				if flip and a and b then
					local d = (b - a) % #seq
					if d > 3 then
						local k = (a + 2) % #seq + 1
						nx = seq:sub(k, k)
					end
				end
				r.cur[c] = nx
				SKIN:Bang('!SetOption', 'R' .. i .. 'C' .. c, 'Text', nx)
				SKIN:Bang('!UpdateMeter', 'R' .. i .. 'C' .. c)
				changed = true
			end
		end
	end
	if changed then SKIN:Bang('!Redraw') end
	return 0
end

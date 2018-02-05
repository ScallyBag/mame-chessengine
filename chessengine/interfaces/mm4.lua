-- license:BSD-3-Clause
-- copyright-holders:Sandro Ronco

interface = {}

function interface.setup_machine()
	-- setup board pieces
	for y=0,7 do
		local port_tag = ":board:IN." .. tostring(y)
		local port_val = machine:ioport().ports[port_tag]:read()
		for x=0,7 do
			local req_pos = y == 0 or y == 1 or y == 6 or y == 7
			if ((req_pos == true and port_val & (1 << (7 - x)) ~= 0) or (req_pos == false and port_val & (1 << (7 - x)) == 0)) then
				send_input(port_tag, 1 << (7 - x), 0.10)
			end
		end
	end

	machine:soft_reset()
	emu.wait(1.0)
	send_input(":KEY1_0", 0x80, 1)
end

function interface.start_play()
	send_input(":KEY1_5", 0x80, 1)
end

function interface.is_selected(x, y)
	local xval = { 0x77, 0x7c, 0x39, 0x5e, 0x79, 0x71, 0x3d, 0x76 }
	local yval = { 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f }
	local d0 = machine:outputs():get_value("digit0") & 0x7f
	local d1 = machine:outputs():get_value("digit1") & 0x7f
	local d2 = machine:outputs():get_value("digit2") & 0x7f
	local d3 = machine:outputs():get_value("digit3") & 0x7f
	return (xval[x] == d0 and yval[y] == d1) or (xval[x] == d2 and yval[y] == d3) or machine:outputs():get_value("led" .. tostring(8 * (y - 1) + (x - 1))) ~= 0
end

function interface.select_piece(x, y, event)
	send_input(":board:IN." .. tostring(y - 1), 1 << (x - 1), 1)
end

function interface.get_options()
	return { { "spin", "Level", "1", "0", "9"}, }
end

function interface.set_option(name, value)
	if (name == "level") then
		local level = tonumber(value)
		if (level < 0 or level > 9) then
			return
		end

		send_input(":KEY1_4", 0x80, 1)		-- LEV
		if     (level == 0) then	send_input(":KEY1_6", 0x80, 1)
		elseif (level == 1) then	send_input(":KEY2_3", 0x80, 1)
		elseif (level == 2) then	send_input(":KEY2_5", 0x80, 1)
		elseif (level == 3) then	send_input(":KEY2_6", 0x80, 1)
		elseif (level == 4) then	send_input(":KEY2_7", 0x80, 1)
		elseif (level == 5) then	send_input(":KEY2_0", 0x80, 1)
		elseif (level == 6) then	send_input(":KEY2_1", 0x80, 1)
		elseif (level == 7) then	send_input(":KEY2_2", 0x80, 1)
		elseif (level == 8) then	send_input(":KEY2_4", 0x80, 1)
		elseif (level == 9) then	send_input(":KEY1_7", 0x80, 1)
		end

		send_input(":KEY1_5", 0x80, 1)		-- CLEAR
	end
end

function interface.get_promotion()
	send_input(":KEY1_3", 0x80, 0.5)	-- INFO
	send_input(":KEY2_3", 0x80, 0.5)	-- 1

	local d3 = 0
	for i=0,5 do
		local d0 = machine:outputs():get_value("digit0") & 0x7f
		local d1 = machine:outputs():get_value("digit1") & 0x7f

		if (d0 == 0x73 and d1 == 0x50) then	-- display shows 'Pr'
			d3 = machine:outputs():get_value("digit3") & 0x7f
			break
		end
		send_input(":KEY1_6", 0x80, 0.5)	-- 0
	end

	send_input(":KEY1_3", 0x80, 0.5)	-- INFO

	if     (d3 == 0x5e) then	return "q"
	elseif (d3 == 0x31) then	return "r"
	elseif (d3 == 0x38) then	return "b"
	elseif (d3 == 0x6d) then	return "n"
	end

	return nil
end

function interface.promote(x, y, piece)
	if     (piece == "q") then	send_input(":KEY2_0", 0x80, 1)
	elseif (piece == "r") then	send_input(":KEY2_7", 0x80, 1)
	elseif (piece == "b") then	send_input(":KEY2_6", 0x80, 1)
	elseif (piece == "n") then	send_input(":KEY2_5", 0x80, 1)
	end
	if (piece == "q" or piece == "r" or piece == "b" or piece == "n") then
		send_input(":KEY1_5", 0x80, 1)
	end
end

return interface

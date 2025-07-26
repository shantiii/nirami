-- Dialog Tree Functions

-- main API
-- dia_init(forest) - returns initial dialog state
-- dia_draw(state) - (READONLY) displays current dialog tree line
-- dia_update(state, input) - updates state based of input
-- dia_input() - default input handling
-- dia_choice(prompt,[text, jump]...) create a dialogue option TODO
--
-- Forest - table, all the dialog for the game
-- [1..] => Dialog

-- DTree - table, a simple sequence of dialog
--   [1..] String OR Number OR Table
-- String - Simple Text
-- Number -> Index of the Dialog
-- Table -> Dialog Object

-- Dialog State
-- Forest -> the dialog for all the game
-- Tree -> Index into Dialog Forest
-- Line -> Index into Tree

function dia_init(forest)
	return {
		forest = forest,
		tree = 1,
		line = 1,
		selection = 1
	}
end

-- dia_draw: display the current state
function dia_draw(dstate)
	local mix = {
		line = function(x) print(x.forest[x.tree][x.line]) end,
		jump = function(x) print("(CONTINUE)...") end,
		decision = function(x)
			local decision = x.forest[x.tree][x.line]
			print(decision.prompt)
			for idx = 1, #decision.options do
				local prefix = ""
				if idx == x.selection then
					prefix = "> "
				else
					prefix = "  "
				end
				print(prefix .. decision.options[idx][1])
			end
		end,
		["end"] = function(x) print(" THE END YO ") end
	}
	--dia_debug(dstate)
	mix[dia_type(dstate)](dstate)
end

function dia_type(dstate)
	if dstate.forest[dstate.tree] == nil then
		return "end"
	end
	local raw_type = type(dstate.forest[dstate.tree][dstate.line])
	if raw_type == "string" then
		return "line"
	elseif raw_type == "number" then
		return "jump"
	elseif raw_type == "table" then
		return "decision"
	else
		return "end"
	end
end

function dia_debug(dstate)
	print(dia_type(dstate) .. "(" .. dstate.tree .. "," .. dstate.line .. ")")
end

-- update the dialog state based off input
-- Input: false if there is no input
function dia_update(dstate, input)
	-- if there is no input, do nothing
	if input == nil then
		return
	end
	local dtype = dia_type(dstate)
	-- if line, input TODO advances the current tree
	if dtype == "line" and input == "select" then
		dstate.line = dstate.line+1
	-- if jump, input goes to the next tree
	elseif dtype == "jump" and input == "select" then
		dstate.tree = dstate.forest[dstate.tree][dstate.line]
		dstate.line = 1
	-- if decision, input decides the branch
	elseif dtype == "decision" then
		-- initialize selection if needs be
		if dstate.selection == nil then
			dstate.selection = 1
		end
		local decision = dstate.forest[dstate.tree][dstate.line]
		-- if input up choice -1
		if input == "up" and dstate.selection > 1 then
			dstate.selection = dstate.selection-1
		-- if input down line +1
		elseif input == "down" and dstate.selection < #decision.options then
			dstate.selection = dstate.selection+1
		elseif input == "select" then
			dstate.tree = decision.options[dstate.selection][2]
			dstate.line = 1
			dstate.selection = 1
		end
	elseif dtype == "end" then
		-- do nothing
	end
	-- if dtype jump, any input advances
	-- if state end, ignore all input
end

function dia_input()
	-- BTNP: button pressed
	-- [left, right, up, down, O, X]
	-- https://www.lexaloffle.com/dl/docs/pico-8_manual.html#BTN
	local btnmap = {
		[0] = "left",
		[1] = "right",
		[2] = "up",
		[3] = "down",
		[4] = "select",
		[5] = "cancel",
	}
	-- the order here defines priority
	if btnp(5) then
		return "cancel"
	elseif btnp(4) then
		return "select"
	elseif btnp(2) and btnp(3) then
		return nil
	elseif btnp(2) then
		return "up"
	elseif btnp(3) then
		return "down"
	else
		return nil
	end
	-- left and right intentionally ignored
end

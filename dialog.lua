-- Dialog Tree Functions

-- main API
-- dia_init(forest) - returns initial dialog state
-- dia_render(state) - (READONLY) displays current dialog tree line
-- dia_update(state, input) - updates state based of input
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
		line = 1
	}
end

-- dstate: display the current state
function dia_render(dstate)
	local mix = {
		line = function(x) print(x.forest[x.tree][x.line]) end,
		jump = function(x) print("(continue)...") end,
		table = function(x) print(x.forest[x.tree].prompt) end,
		["end"] = function(x) print(" THE END YO ") end
	}
	mix[dia_type(dstate)](dstate)
	--dia_debug(dstate)
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
function dia_update(dstate, input)
	local dtype = dia_type(dstate)
	-- if line, input TODO advances the current tree
	if dtype == "line" and input then
		dstate.line = dstate.line+1
	-- if jump, input goes to the next tree
	elseif dtype == "jump" and input then
		dstate.tree = dstate.forest[dstate.tree][dstate.line]
		dstate.line = 1
	-- if decision, input decides the branch
	elseif dtype == "decision" then
		local decision = dstate.forest[dstate.tree][dstate.line]

	elseif dtype == "end" then
		-- do nothing
	end
	-- if dtype jump, any input advances
	-- if state end, ignore all input
end

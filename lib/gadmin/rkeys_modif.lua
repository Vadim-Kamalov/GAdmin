--[[
   Register HotKey for MoonLoader
   Author: DonHomka

   Modified version v1.2.0 (by Hatiko)
   - added imgui hotkey (button) form imgui_addon
   - added the ability to make combinations of any type and length
   - added automatic (un)registration, changing keys (using imgui hotkey)
   - added automatic check of registered keys (using imgui hotkey)
   - added a onKeyError(id, key) event that is called when:
      • [id: 1] keys is registered
      • [id: 2] keys are locked for use 
   (using imgui hotkey)  
   
   Original: rkeys.lua v1.1.0 & imgui_addon by DonHomka
]]

local imgui = require 'mimgui'
local vkeys = require 'vkeys'
local wm = require 'lib.windows.message'
local encoding = require 'encoding'
encoding.default = 'CP1251'
local u8 = encoding.UTF8

vkeys.key_names[vkeys.VK_LMENU] = "LAlt"
vkeys.key_names[vkeys.VK_RMENU] = "RAlt"
vkeys.key_names[vkeys.VK_LSHIFT] = "LShift"
vkeys.key_names[vkeys.VK_RSHIFT] = "RShift"
vkeys.key_names[vkeys.VK_LCONTROL] = "LCtrl"
vkeys.key_names[vkeys.VK_RCONTROL] = "RCtrl"
vkeys.key_names[vkeys.VK_RBUTTON] = "ÏÊÌ"
vkeys.key_names[vkeys.VK_LBUTTON] = "ËÊÌ"
vkeys.key_names[vkeys.VK_MBUTTON] = "Scroll"

local tHotKey = {}
local tCurKeyList = {}
local tBlockKeys = {
   [vkeys.VK_LMENU] = true, 
   [vkeys.VK_RMENU] = true, 
   [vkeys.VK_RSHIFT] = true, 
   [vkeys.VK_LSHIFT] = true, 
   [vkeys.VK_LCONTROL] = true, 
   [vkeys.VK_RCONTROL] = true,
   [vkeys.VK_T] = true, 
   [vkeys.VK_F6] = true, 
   [vkeys.VK_F8] = true
}
local tBlockChar = {[116] = true, [84] = true}
local tModKeys = {[vkeys.VK_MENU] = true, [vkeys.VK_CONTROL] = true}
local tBlockNext = {}
local module = {}
module._MODKEYS = tModKeys
module._VERSION = "1.2.0"
module._SETTINGS = {
	noKeysMessage = "Íåò",
	waitKeysMessage = "Íàæìèòå"
}

local keysDown = {
	[wm.WM_KEYDOWN] = true,
	[wm.WM_SYSKEYDOWN] = true,
	[wm.WM_MBUTTONDOWN] = true,
	[wm.WM_RBUTTONDOWN] = true,
   [wm.WM_LBUTTONDOWN] = true,
	[wm.WM_XBUTTONDOWN] = true
}
local keysUp = {
	[wm.WM_KEYUP] = true,
	[wm.WM_SYSKEYUP] = true,
	[wm.WM_MBUTTONUP] = true,
	[wm.WM_RBUTTONUP] = true,
   [wm.WM_LBUTTONUP] = true,
	[wm.WM_XBUTTONUP] = true
}

local edit = nil
local save = {}
local lastTick = os.clock()
local tickState = false


module.HotKey = function(name, keys, ImVec2_size, callback)
   local width = width or 90
   local name = tostring(name)
	local bool = false
   	local sKeys = table.concat(module.getKeysName(keys.v), " + ")

	if #save > 0 and tostring(save[1]) == name then
		if #save[2] ~= 0 and table.concat(save[2], " ") ~= table.concat(keys.v, " ") and module.isHotKeyDefined(save[2]) then
       		save = {}
       	 	module.Error(1, save[2])
		else
			if #save[2] == 0 and #keys.v ~= 0 then
				local _, id = module.isHotKeyDefined(keys.v)
				table.remove(tHotKey, id)
				-- Clear HotKey
			elseif #save[2] ~= 0 and #keys.v ~= 0 then
				local _, id = module.isHotKeyDefined(keys.v)
				tHotKey[id].keys = save[2]
				-- Change HotHey
			elseif #save[2] ~= 0 and #keys.v == 0 then
				tHotKey[#tHotKey + 1] = {keys = save[2], pressed = true, callback = callback}
				-- New HotKey
			-- else
			-- 	-- Del to Del
			end
			keys.v = save[2]
			save = {}
			sKeys = table.concat(module.getKeysName(keys.v), " + ")
			bool = true
		end
    elseif edit ~= nil and tostring(edit) == name then
		if #tCurKeyList == 0 then
			if os.clock() - lastTick > 0.5 then
                lastTick = os.clock()
                tickState = not tickState
            end
        sKeys = tickState and module._SETTINGS.waitKeysMessage or " "
        else
			local r, res = pcall(table.concat, module.getKeysName(tCurKeyList), " + ")
			if not r or not res then
				print(r, res, tCurKeyList)
				for k,v in pairs(tCurKeyList) do
					print(k,v)
				end
			end
            sKeys = table.concat(module.getKeysName(tCurKeyList), " + ")
        end
    end
    imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.FrameBg])
    imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.GetStyle().Colors[imgui.Col.FrameBgHovered])
    imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.GetStyle().Colors[imgui.Col.FrameBgActive])
    if imgui.Button((tostring(sKeys):len() == 0 and u8(module._SETTINGS.noKeysMessage) or u8(sKeys)), ImVec2_size) and edit ~= name then
        edit = name
    end
    imgui.SameLine()
    imgui.Text(name)
    imgui.PopStyleColor(3)
    return bool, 1
end

function module.Error(id, key)
	if module.onKeyError then
		module.onKeyError(id, key)
	end
end


local function getKeyNum(id) 
	for k, v in pairs(tCurKeyList) do
		if v == id then
			return k
		end
	end
	return 0
end


function module.blockNextHotKey(keys)
   local bool = false
   if not module.isBlockedHotKey(keys) then
      tBlockNext[#tBlockNext + 1] = keys
      bool = true
   end
   return bool
end

function module.isBlockedHotKey(keys) -- 
   local bool, hkId = false, -1
   for k, v in pairs(tBlockNext) do
      if module.isHotKeyHotKey(keys, v) then
         bool = true
         hkId = k
         break
      end
   end
   return bool, hkId
end

function module.isHotKeyHotKey(keys, keys2)
   if type(keys) ~= "table" then
      print("[RKeys | isHotKeyHotKey]: Bad argument #1. Value \"", tostring(keys), "\" is not table.")
      return false
   elseif type(keys2) ~= "table" then
      print("[RKeys | isHotKeyHotKey]: Bad argument #2. Value \"", tostring(keys2), "\" is not table.")
      return false
   else
      return table.concat(keys, " ") == table.concat(keys2, " ")
   end
end

function module.isKeyModified(id)
   if type(id) ~= "number" then
      print("[RHKeys | isKeyModified]: Bad argument #1. Value \"", tostring(id), "\" is not number.")
      return false
   end
   if tBlockKeys[id] then
      module.Error(2, id)
   end
   return (tModKeys[id] or false) or (tBlockKeys[id] or false)
end

function module.isModifiedDown()
   local bool = false
   for k, v in pairs(tModKeys) do
      if isKeyDown(k) then
         bool = true
         break
      end
   end
   return bool
end

lua_thread.create(function ()
   while true do
      wait(0)
      for k, v in pairs(tHotKey) do
         if #v.keys > 0 then
            local bool = true
            for i = 1, #v.keys do
               if i ~= #v.keys and (getKeyNum(v.keys[i]) > getKeyNum(v.keys[i + 1]) or getKeyNum(v.keys[i]) == 0) then
                  bool = false
                  break
               elseif i == #v.keys and (v.pressed and not wasKeyPressed(v.keys[i]) or not v.pressed and not isKeyDown(v.keys[i])) or (#v.keys == 1 and module.isModifiedDown()) then
                  bool = false
                  break
               end
            end
            if not sampIsChatInputActive() and not sampIsDialogActive() and not isSampfuncsConsoleActive() and bool and ((module.onHotKey and module.onHotKey(k, v.keys) ~= false) or module.onHotKey == nil) then
               v.callback(k, v.keys)
               
            end
         end
      end
   end
end)

function module.registerHotKey(keys, pressed, callback)
   tHotKey[#tHotKey + 1] = {keys = keys, pressed = pressed, callback = callback}
   return #tHotKey
end

function module.getAllHotKey()
   return tHotKey
end

function module.changeHotKey(id, newkeys)
   if type(id) ~= "number" then
      print("[RKeys | changeHotKey]: Bad argument #1. Value \"", tostring(keys), "\" is not number.")
      return false
   elseif type(newkeys) ~= "table" then
      print("[RKeys | changeHotKey]: Bad argument #2. Value \"", tostring(newkeys), "\" is not table.")
      return false
   else
      local bool = false
      if module.isHotKeyDefined(id) then
         tHotKey[id].keys = newkeys
         bool = true
      end
      return bool
   end
end

function module.unRegisterHotKey(keys_or_id)
   local result = false
   local count = 0
   if type(keys_or_id) == "number" and tHotKey[keys_or_id] then
      tHotKey[keys_or_id] = nil
      result = true
      count = nil
   elseif type(keys_or_id) == "table" then
      while module.isHotKeyDefined(keys_or_id) do
         local _, id = module.isHotKeyDefined(keys_or_id)
         tHotKey[id] = nil
         result = true
         count = count + 1
      end
      local id = 1
      local tNewHotKey = {}
      for k, v in pairs(tHotKey) do
         tNewHotKey[id] = v
         id = id + 1
      end
      tHotKey = tNewHotKey
   else
      print("[RKeys | unRegisterHotKey]: Bad argument #1. Value \"", tostring(keys_or_id), "\" is not number or table.")
      return false, -1
   end
   return result, count
end

function module.isHotKeyDefined(keys_or_id)
   if type(keys_or_id) == "number" and tHotKey[keys_or_id] then
      return true, tHotKey[keys_or_id].keys
   elseif type(keys_or_id) == "table" then
      local bool, hkId = false, -1
      for k, v in pairs(tHotKey) do
         if module.isHotKeyHotKey(keys_or_id, v.keys) then
            bool = true
            hkId = k
            break
         end
      end
      return bool, hkId
   else
      print("[RKeys | isHotKeyDefined]: Bad argument #1. Value \"", tostring(keys_or_id), "\" is not number or table.")
      return false, -1
   end
   return false, -1
end

function module.getKeysName(keys)
   if type(keys) ~= "table" then
      print("[RKeys | getKeysName]: Bad argument #1. Value \"", tostring(keys), "\" is not table.")
      return false
   else
      local tKeysName = {}
      for k, v in ipairs(keys) do
         tKeysName[k] = vkeys.id_to_name(v)
      end
      return tKeysName
   end
end
 

local function reloadKeysList()
    local tNewKeys = {}
    for k, v in pairs(tCurKeyList) do
       tNewKeys[#tNewKeys + 1] = v
    end
    tCurKeyList = tNewKeys
    return true
end

addEventHandler("onWindowMessage", function (msg, wparam, lparam)
	if edit ~= nil and msg == wm.WM_CHAR then
		if tBlockChar[wparam] then
			consumeWindowMessage(true, true)
		end
	end
	if keysDown[msg] then
     
		if msg == wm.WM_MBUTTONDOWN then wparam = 4 end
		if msg == wm.WM_RBUTTONDOWN then wparam = 2 end
      if msg == wm.WM_LBUTTONDOWN then wparam = 1 end
		if msg == wm.WM_XBUTTONDOWN then 
         wparam = bit.rshift(bit.band(wparam, 0xffff0000), 16)+4
      end
      -- print("DOWN", wparam)
		if edit ~= nil then
            if wparam == vkeys.VK_ESCAPE then
				tCurKeyList = {}
				edit = nil
                consumeWindowMessage(true, true)
            end
            if wparam == vkeys.VK_BACK then
				save = {edit, {}}
				edit = nil
                consumeWindowMessage(true, true)
            end
        end
		local num = getKeyNum(wparam)
		if num == 0 then
			tCurKeyList[#tCurKeyList + 1] = wparam
			if edit ~= nil then
            if not module.isKeyModified(wparam) then
					consumeWindowMessage(true, true)
				end
			end
		end
		
		if edit ~= nil then
			consumeWindowMessage(true, true)
		end
	elseif keysUp[msg] then 

		if msg == wm.WM_MBUTTONUP then wparam = 4 end
		if msg == wm.WM_RBUTTONUP then wparam = 2 end
      if msg == wm.WM_LBUTTONUP then wparam = 1 end
		if msg == wm.WM_XBUTTONUP then
         wparam = bit.rshift(bit.band(wparam, 0xffff0000), 16)+4
      end
      -- print("UP", wparam)
		local num = getKeyNum(wparam)
      if num > 0 then
         if edit ~= nil and not module.isKeyModified(tCurKeyList[#tCurKeyList])  then
            save = {edit, tCurKeyList}
            tCurKeyList = {}
            edit = nil
         end
         table.remove(tCurKeyList, num)
        
		end
		if edit ~= nil then
			consumeWindowMessage(true, true)
		end
	end
end) 


function module.getCurrentHotKey()
   return tCurKeyList
end

return module

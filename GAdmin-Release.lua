---
--- This file is compiled from the source code of the GAdmin project using the Lua dialect - Clue:
---
---     https://github.com/ClueLang/Clue/
---
--- The repository (as well as the source code) is licensed under the standard GNU General Public License version 3.
---
--- GAdmin Repository: https://github.com/Vadim-Kamalov/GAdmin/
--- GAdmin Contributors: https://github.com/Vadim-Kamalov/GAdmin/blob/main/CONTRIBUTING.md
--- Build-Target: Release (without environment variable __GADMIN_DEBUG__)
---
--- ************************************************************************
---
--- GAdmin - Script simplifying the work of administrators on the Gambit-RP
--- Copyright (C) 2023-2024 The Contributors.
---
--- This program is free software: you can redistribute it and/or modify
--- it under the terms of the GNU General Public License as published by
--- the Free Software Foundation, either version 3 of the License, or
--- (at your option) any later version.
---
--- This program is distributed in the hope that it will be useful,
--- but WITHOUT ANY WARRANTY; without even the implied warranty of
--- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--- GNU General Public License for more details.
---
--- You should have received a copy of the GNU General Public License
--- along with this program.  If not, see <https://www.gnu.org/licenses/>.
---
--- SDPX-License-Identifier: GPL-3.0-only
---

script_name         "GAdmin"
script_authors      "https://github.com/Vadim-Kamalov/GAdmin/blob/main/CONTRIBUTORS"
script_url          "https://github.com/Vadim-Kamalov/GAdmin/"
script_properties   "work-in-pause"

local import, modules
do
    function import(name)
        return modules[name]()
    end
end

---! BEGIN_AUTO_GENERATED_CONTENT

local __admins__ = {};
local __hooks__ = {
	hooks = {	}
};
local __user__ = {
	alogin = false, 
	weekNumber = tostring(tonumber(os.date("%W"))+tonumber(os.date("%y"))), 
	answersCount = 0, 
	aloginCallbacks = {	}, 
	afkTime = 0, 
	afkTimeClock = os.clock(), 
	online = {
		session = 0, 
		clock = os.clock()
	}
};
local MV_ONLY_IN_SPECTATOR = 1;
local MV_ONLY_NOT_IN_SPECTATOR = 2;
local MV_DEFAULT = 3;
local __movableWindows__ = {
	changingWindowsPositions = false, 
	viewMode = MV_DEFAULT, 
	handlerRegistered = false
};
local MV_VIEW_DESCRIPTIONS = {
	[(MV_ONLY_IN_SPECTATOR)] = "[1]: Отображение окон только в режиме наблюдения", 
	[(MV_ONLY_NOT_IN_SPECTATOR)] = "[2]: Отображение окон не в режиме наблюдения", 
	[(MV_DEFAULT)] = "[3]: Отображение всех окон"
};
local PLATFORM_AWAITING_OR_NONE = 0;
local PLATFORM_PC = 1;
local PLATFORM_ANDROID = 2;
local SYNC_KEYS_PLAYER = 1;
local SYNC_KEYS_VEHICLE = 2;
local SYNC_KEYS_JOY_STICK = 3;
local __spectator__ = {
	id = -1, 
	nickname = "", 
	time = nil, 
	afk = {
		thread = nil, 
		time = 0, 
		clock = -1, 
		awaiting = {
			message = false
		}
	}, 
	keys = {
		[(PLATFORM_PC)] = {
			[(SYNC_KEYS_PLAYER)] = {			}, 
			[(SYNC_KEYS_VEHICLE)] = {			}
		}, 
		[(PLATFORM_ANDROID)] = {
			[(SYNC_KEYS_PLAYER)] = {			}, 
			[(SYNC_KEYS_VEHICLE)] = {			}, 
			[(SYNC_KEYS_JOY_STICK)] = {
				new = {
					x = 0, 
					y = 0
				}, 
				old = {
					x = 0, 
					y = 0
				}, 
				clock = os.clock()
			}
		}
	}, 
	platform = PLATFORM_AWAITING_OR_NONE, 
	status = false, 
	stats = {
		lastChecked = os.clock(), 
		checking = false
	}, 
	textDrawId = nil, 
	information = {	}
};
local __greport__ = {
	hotKey = nil, 
	window = {
		state = false, 
		recentlyOpened = false, 
		noInputClock = nil, 
		answerInput = nil, 
		closeAndOpenAnimation = {
			alpha = 0, 
			clock = nil
		}
	}, 
	dialog = {
		id = -1, 
		state = false, 
		awaiting = {
			options = {
				false, 
				nil
			}, 
			input = {
				false, 
				"value"
			}, 
			special = {
				false, 
				nil
			}
		}
	}, 
	player = {
		receivedAt = nil, 
		clock = nil, 
		time = nil, 
		active = false, 
		nickname = "", 
		id = -1, 
		context = ""
	}
};
local GREPORT_OPTION_SPECTATE = 0;
local GREPORT_OPTION_ANSWER = 1;
local GREPORT_OPTION_REMOVE = 2;
local GREPORT_OPTION_BLOCK = 3;
local GREPORT_OPTION_TO_ADMINISTRATION = 4;
local GREPORT_OPTION_SET_MAP_POINT = 5;
local AUTOUPDATE_RESPONSE_WAITING = 1;
local AUTOUPDATE_RESPONSE_OK = 2;
local AUTOUPDATE_RESPONSE_BAD = 3;
local __autoUpdate__ = {
	imgui = {
		title = "", 
		version = "", 
		body = "", 
		buttons = {
			first = "", 
			second = "", 
			third = ""
		}
	}, 
	windowState = false, 
	handler = require("xmlhandler.tree"), 
	response = AUTOUPDATE_RESPONE_WAITING, 
	config = nil
};
local clickWarp = {
	enabled = false, 
	teleportation = {
		tpIntoCar = nil, 
		pos = nil
	}
};
local __imguiAssets__ = {
	cursor = true
};
local __style__ = {
	windows = {	}, 
	def = {	}, 
	baseColors = {
		{
			"Text", 
			nil
		}, 
		{
			"TextDisabled", 
			nil
		}, 
		{
			"WindowBg", 
			nil
		}, 
		{
			"ChildBg", 
			nil
		}, 
		{
			"PopupBg", 
			nil
		}, 
		{
			"Border", 
			nil
		}, 
		{
			"BorderShadow", 
			nil
		}, 
		{
			"FrameBg", 
			nil
		}, 
		{
			"FrameBgHovered", 
			nil
		}, 
		{
			"FrameBgActive", 
			nil
		}, 
		{
			"ScrollbarBg", 
			nil
		}, 
		{
			"ScrollbarGrab", 
			nil
		}, 
		{
			"ScrollbarGrabHovered", 
			nil
		}, 
		{
			"ScrollbarGrabActive", 
			nil
		}, 
		{
			"Button", 
			nil
		}, 
		{
			"ButtonHovered", 
			nil
		}, 
		{
			"ButtonActive", 
			nil
		}, 
		{
			"Header", 
			nil
		}, 
		{
			"HeaderHovered", 
			nil
		}, 
		{
			"HeaderActive", 
			nil
		}, 
		{
			"Separator", 
			nil
		}, 
		{
			"SeparatorHovered", 
			nil
		}, 
		{
			"SeparatorActive", 
			nil
		}, 
		{
			"TextSelectedBg", 
			nil
		}
	}
};
local __notifications__ = {
	active = true, 
	root = {	}
};
local farChatMessages = {};
local killListWindow = {
	kills = {	}
};
local onTogglePlayerControllableCount = 0;
local COMMAND_REQUEST_TYPE_NONE = 1;
local COMMAND_REQUEST_TYPE_NO_COMMENTARY = 2;
local COMMAND_REQUEST_TYPE_COMMENTARY = 3;
local COMMAND_REQUEST_TYPE_ANSWER = 4;
local COMMAND_REQUEST_DISPLAY_NOTIFICATION = 1;
local COMMAND_REQUEST_DISPLAY_BOTTOM_BAR = 2;
local __commandRequester__ = {
	lastUserCommand = "", 
	states = {
		requester = false, 
		frame = false, 
		ignoreNextCommands = false
	}, 
	current = {
		clock = os.clock(), 
		id = {
			to = -1, 
			from = -1
		}, 
		command = {
			type = COMMAND_REQUEST_TYPE_NONE, 
			splitted = {
				name = "", 
				args = ""
			}
		}
	}
};
local registeredWindows = {};
local COMMAND_ARGUMENT_PLAYER_ID = 1;
local COMMAND_ARGUMENT_PLAYER_NICKNAME = 2;
local COMMAND_ARGUMENT_VEHID = 3;
local COMMAND_ARGUMENT_CVEHID = 4;
local COMMAND_ARGUMENT_HEALTH = 5;
local COMMAND_ARGUMENT_ANY = 6;
local COMMAND_ARGUMENT_REASON = 7;
local autoCompletion = {
	position = 1, 
	clock = os.clock(), 
	commandsLength = 1, 
	condition = function()
		return not isGamePaused() and sampIsChatInputActive() and string.sub(sampGetChatInputText(), 1, 2):find("/[A-Za-z]") and #sampGetChatInputText()>=2;
	end
};
local hotKeysCallbacks = {};
local changingHotKey = false;
local allHotKeys = {};
local checkedAdminList = false;
local __playerNotes__ = {
	displayBuffer = {	}
};
local SPECTATOR_INFORMATION_TYPE_SINGLE = 1;
local SPECTATOR_INFORMATION_TYPE_DOUBLE = 2;
local NOTIFICATION_TYPE_DEFAULT = 1;
local NOTIFICATION_TYPE_SCRIPT_MESSAGE = 2;
local NOTIFICATION_TYPE_NONE = 3;
local __config__ = {
	initialized = false, 
	def = nil, 
	jsonStrings = {
		file = "", 
		root = ""
	}, 
	root = {
		windows = {
			adminList = {
				use = false, 
				sortByLvl = false, 
				textAlignMode = 3, 
				showAdminLvl = true, 
				textColorBasedOnClist = true, 
				strokeSize = 1, 
				countForScrollbar = 10
			}, 
			playersNearby = {
				use = false, 
				textAlignMode = 1, 
				showDistance = true, 
				showAdmins = true, 
				sortByDistance = true, 
				maxPlayers = 10, 
				playerColorBasedOnClist = true, 
				strokeSize = 1
			}, 
			spectatorInformation = {
				use = true, 
				type = 2, 
				showedHintFirstTime = false, 
				columns = {
					{
						"Пинг", 
						true
					}, 
					{
						"ID аккаунта", 
						true
					}, 
					{
						"Дата регистрации", 
						true
					}, 
					{
						"Наличные/банк", 
						true
					}, 
					{
						"Здоровье/броня", 
						true
					}, 
					{
						"Фракция", 
						true
					}, 
					{
						"Должность", 
						true
					}, 
					{
						"Машина(-ы)", 
						true
					}, 
					{
						"Стадия", 
						true
					}, 
					{
						"VIP статус", 
						true
					}, 
					{
						"Предупреждения", 
						true
					}, 
					{
						"Время в афк", 
						true
					}, 
					{
						"Тек./макс. скорость", 
						true
					}, 
					{
						"Выстрелы/попадания", 
						true
					}, 
					{
						"Двигатель", 
						true
					}, 
					{
						"Двери", 
						true
					}
				}
			}, 
			killList = {
				use = false, 
				displayTime = true, 
				hideDefaultKillList = true, 
				displayId = true, 
				playerColorBasedOnClist = true, 
				strokeSize = 1, 
				textAlignMode = 1, 
				maxItems = 5
			}, 
			notifications = {
				use = true, 
				maxItems = 5, 
				align = 3
			}, 
			farChat = {
				use = false, 
				maxLines = 8, 
				strokeSize = 1, 
				ignore = {				}, 
				displayTime = true, 
				delay = 2
			}, 
			playerChecker = {
				use = false, 
				notificationType = 1, 
				strokeSize = 1, 
				textAlignMode = 3, 
				displayOfflinePlayers = true, 
				playerColorBasedOnClist = true, 
				players = {				}
			}, 
			autoCompletion = {
				use = true, 
				strokeSize = 1
			}, 
			userInformation = {
				use = false, 
				showTime = true, 
				textAlignMode = 3, 
				strokeSize = 1, 
				display = {
					{
						"ID", 
						true
					}, 
					{
						"IC никнейм", 
						true
					}, 
					{
						"OOC никнейм", 
						true
					}, 
					{
						"Админ уровень", 
						true
					}, 
					{
						"Пинг", 
						true
					}, 
					"NewLine", 
					{
						"Общий онлайн", 
						true
					}, 
					{
						"Онлайн за неделю", 
						true
					}, 
					{
						"Онлайн за сессию", 
						true
					}, 
					"NewLine", 
					{
						"Ответов всего", 
						true
					}, 
					{
						"Ответов за неделю", 
						true
					}, 
					{
						"Ответов за сесcию", 
						true
					}
				}
			}, 
			greport = {
				use = true, 
				soundNotification = true, 
				preferNotifications = true, 
				reminderNotification = true, 
				remindSeconds = 120, 
				inputCopyButtons = {
					{
						"Приятной игры!", 
						"Приятной игры!"
					}, 
					{
						"Передал", 
						"Передал."
					}, 
					{
						"Нет тех. причины", 
						"Не чиним/лечим/телепортируем/спавним без технической причины."
					}, 
					{
						"Пишите на форум", 
						"Пишите жалобу на форум, туда со всеми доказательствами."
					}, 
					{
						"Слежу", 
						"Слежу за игроком."
					}, 
					{
						"Следите за новостями", 
						"Следите за новостями."
					}
				}
			}, 
			spectatorActions = {
				use = true, 
				windowSizeY = 100, 
				buttons = {
					{
						"*Вы тут?*", 
						"/ans ${{ SPECTATOR_ID }} Вы тут? Ответ в /b или /pm ${{ USER_ID }}", 
						true
					}, 
					{
						"ANS", 
						"^/ans ${{ SPECTATOR_ID }} ", 
						true
					}, 
					{
						"AHEAL", 
						"/aheal ${{ SPECTATOR_ID }}", 
						true
					}, 
					{
						"STATS", 
						3, 
						true
					}, 
					{
						"AFRISK", 
						5, 
						true
					}, 
					{
						"PAME", 
						"/pame ${{ SPECTATOR_ID }}", 
						true
					}, 
					{
						"WARN", 
						"^/warn ${{ SPECTATOR_ID }} ", 
						true
					}, 
					{
						"SLAP", 
						"/slap ${{ SPECTATOR_ID }}", 
						true
					}, 
					{
						"SWITCH", 
						1, 
						true
					}, 
					{
						"GETBUYCAR", 
						"^/getbuycar ", 
						true
					}, 
					{
						"BAN", 
						"^/ban ${{ SPECTATOR_ID }} ", 
						true
					}, 
					{
						"KICK", 
						"^/kick ${{ SPECTATOR_ID }} ", 
						true
					}, 
					{
						"BMUTE", 
						"^/bmute ${{ SPECTATOR_ID }} ", 
						true
					}, 
					{
						"EXIT", 
						6, 
						true
					}, 
					{
						"ASPAWN", 
						"/aspawn ${{ SPECTATOR_ID }}", 
						true
					}, 
					{
						"PK", 
						"/pk ${{ SPECTATOR_ID }}", 
						true
					}
				}
			}, 
			spectatorKeys = {
				use = true
			}
		}, 
		render = {
			size = {
				common = 14
			}
		}, 
		cheats = {
			airbreak = {
				use = false, 
				notificationType = 1, 
				speed = 1.0
			}, 
			wallhack = {
				use = false, 
				imguiStyle = false, 
				notificationType = 1
			}, 
			clickwarp = {
				use = false
			}
		}, 
		additions = {
			fishEye = {
				use = false, 
				fov = 101
			}, 
			disableServerMessages = {
				use = false, 
				anticheat = false, 
				punishments = false, 
				complaints = false, 
				questions = false, 
				adminActions = false, 
				playerActions = false
			}, 
			commandRequester = {
				use = true, 
				windowPositionY = select(2, getScreenResolution()), 
				displayType = 2, 
				secondsToHide = 5, 
				soundNotification = true, 
				allowedCommands = {
					{
						"pk", 
						4, 
						2
					}, 
					{
						"ck", 
						4, 
						3
					}, 
					{
						"slap", 
						4, 
						2
					}, 
					{
						"unfreeze", 
						4, 
						2
					}, 
					{
						"setworld", 
						4, 
						2
					}, 
					{
						"setint", 
						4, 
						2
					}, 
					{
						"dpame", 
						4, 
						2
					}, 
					{
						"leave", 
						4, 
						3
					}, 
					{
						"makemic", 
						4, 
						3
					}, 
					{
						"unwarn", 
						4, 
						5
					}, 
					{
						"aheal", 
						4, 
						3
					}, 
					{
						"warn", 
						3, 
						2
					}, 
					{
						"ban", 
						3, 
						3
					}, 
					{
						"kick", 
						3, 
						2
					}, 
					{
						"mute", 
						3, 
						2
					}, 
					{
						"bmute", 
						3, 
						2
					}, 
					{
						"iban", 
						3, 
						4
					}, 
					{
						"jail", 
						3, 
						4
					}, 
					{
						"vspawn", 
						2, 
						3
					}, 
					{
						"vfuel", 
						2, 
						3
					}
				}
			}, 
			mention = {
				use = true, 
				soundNotification = true, 
				notificationType = 1, 
				color = "4A86B6"
			}, 
			zoomSpectatorCamera = {
				use = false, 
				step = 5
			}, 
			tracers = {
				use = true, 
				maxLines = 15, 
				hitColor = "FFC700", 
				missColor = "FFFFFF", 
				showOnlyForSpectator = false, 
				notificationType = 1
			}, 
			shortCommands = {
				use = true, 
				commands = {
					vr = "vrepair %s", 
					as = "aspawn %s", 
					vs = "vspawn %s", 
					ah = "aheal %s", 
					af = "afrisk %s", 
					uf = "unfreeze %s", 
					g = "goto %s", 
					gh = "gethere %s", 
					gc = "getcar %s", 
					gbc = "getbuycar %s", 
					pt = "ptop %s", 
					jb = "ans %s Пишите жалобу на форум, туда со всеми доказательствами", 
					asl = "ans %s Слежу за игроком", 
					ar = "kick %s AFK on ROAD", 
					ak = "kick %s AFK without ESC", 
					ap = "kick %s AFK public place"
				}
			}, 
			autoLogin = {
				use = false, 
				accountPassword = "", 
				aloginPassword = ""
			}, 
			reportOneColor = {
				use = true, 
				color = "FFFF00"
			}, 
			autoAlogout = {
				use = false, 
				warningSeconds = 90, 
				alogoutSeconds = 120
			}, 
			carInfo = {
				use = false, 
				onlyInSpectator = false
			}, 
			deathNotifyInChat = {
				use = false, 
				color = "AFAFAF"
			}, 
			autoAACommand = {
				use = false
			}, 
			hideSpectatorMenu = {
				use = true
			}, 
			swapLayout = {
				use = false
			}, 
			idInKillList = {
				use = false
			}, 
			showAdmins = {
				use = true
			}, 
			displayIdInIc = {
				use = false
			}, 
			gunInfo = {
				use = false
			}, 
			autoAdminLogin = {
				use = false
			}, 
			hideIpAddresses = {
				use = false
			}, 
			changeNicknameColors = {
				use = true
			}
		}, 
		fix = {
			chatOnVK_T = {
				use = true
			}
		}, 
		chat = {
			changeColor = {			}, 
			remove = {			}
		}, 
		user = {
			oocNickname = "Администратор", 
			adminLvl = -1, 
			online = {
				total = 0, 
				weeks = {				}
			}, 
			answers = {
				total = 0, 
				weeks = {				}
			}
		}, 
		autoUpdate = {
			hasUpdateInstalled = false, 
			skipVersionUpdate = "0.0"
		}, 
		binds = {
			{
				keys = {				}, 
				value = "/ans ${{ GET_ARGUMENT, 1 }} Приятной игры!", 
				commandName = "gg", 
				title = "/gg"
			}, 
			{
				keys = {				}, 
				value = "/a Взял на слежку ${{ GET_ARGUMENT, 1 }} ID.\n/sp ${{ GET_ARGUMENT, 1 }}", 
				commandName = "asp", 
				title = "/asp"
			}, 
			{
				keys = {				}, 
				value = "/aspawn ${{ GET_ARGUMENT, 1 }}\n/aheal ${{ GET_ARGUMENT, 1 }}", 
				commandName = "sph", 
				title = "/aspawn + /aheal"
			}
		}, 
		styleChangeableWindows = {		}, 
		hotKeys = {		}, 
		movableWindows = {		}, 
		playerNotes = {		}
	}
};
local memory = require("memory");
local encoding = require("encoding");
local imgui = require("mimgui");
local wm = require("windows.message");
local ffi = require("ffi");
local neatJSON = require("neatjson");
local xml2lua = require("xml2lua");
local sampev = require("samp.events");
local vkeys = require("vkeys");
local moonMonet = require("MoonMonet");
local Vector3D = require("vector3d");
local DIALOG_STYLE_MSGBOX = 0;
local DIALOG_STYLE_INPUT = 1;
local DIALOG_STYLE_LIST = 2;
local DIALOG_STYLE_PASSWORD = 3;
local DIALOG_STYLE_TABLIST = 4;
local DIALOG_STYLE_TABLIST_HEADERS = 5;
local u8 = encoding.UTF8;
local spectatorCameraFov = -1;
local baseNameTagsDistance = 60;
local scriptLoadedWithGame = false;
local bulletData = {
	lastId = 0
};
local contributorsFileSource = nil;
local ALIGN_LEFT = 1;
local ALIGN_CENTER = 2;
local ALIGN_RIGHT = 3;
local receivedKillFocusEvent = false;
local allowedLogs = {
	{
		"IC чат/действия", 
		{		}
	}, 
	{
		"OOC чат", 
		{		}
	}, 
	{
		"Действия/чат администраторов", 
		{		}
	}, 
	{
		"Килл-лист", 
		{		}
	}, 
	{
		"Входы/Выходы", 
		{		}
	}
};
local mainWindow = nil;

modules = {
	["game.Admins"] = function(...)
		function __admins__:insert(data)
			table.insert(self, data);
		end
		function __admins__:remove(index)
			table.remove(self, index);
		end
		function __admins__:getAdminById(id)
			for _, admin in ipairs(self) do
				if admin.id==id then
					return admin;
				end
			end
			return nil;
		end
		function __admins__:getAdminByOOCNickname(nickname)
			for _, admin in ipairs(self) do
				if admin.nickname.ooc==nickname then
					return admin;
				end
			end
			return nil;
		end
		return __admins__;
	end,
	["Hook"] = function(...)
		ffi.cdef("    int VirtualProtect(        void*           lpAddress,        unsigned long   dwSize,        unsigned long   flNewProtect,        unsigned long*  lpflOldProtect    );");
		function __hooks__:new(cast, callback, hookAddress, size)
			if size == nil then
				size = 5
			end
			jit.off(callback, true);
			local newHook = {
				status = false
			};
			local detourAddress = tonumber(ffi.cast("intptr_t", ffi.cast("void*", ffi.cast(cast, callback))));
			local voidAddress = ffi.cast("void*", hookAddress);
			local oldProt = ffi.new("unsigned long[1]");
			local orgBytes = ffi.new("uint8_t[?]", size);
			ffi.copy(orgBytes, voidAddress, size);
			local hookBytes = ffi.new("uint8_t[?]", size, 0x90);
			hookBytes[((0))] = 0xE9;
			ffi.cast("uint32_t*", hookBytes+1)[((0))] = detourAddress-hookAddress-5;
			local function setStatus(bool)
				newHook.status = bool;
				ffi.C.VirtualProtect(voidAddress, size, 0x40, oldProt);
				local _internal0;
				if (bool) then
					_internal0 = hookBytes;
				else
					_internal0 = orgBytes;
				end
				ffi.copy(voidAddress, _internal0, size);
				ffi.C.VirtualProtect(voidAddress, size, oldProt[(0)], oldProt);
			end
			newHook.call = ffi.cast(cast, hookAddress);
			newHook.status = false;
			newHook.stop = function()
				setStatus(false);
			end;
			newHook.start = function()
				setStatus(true);
			end;
			newHook.start();
			table.insert(self.hooks, newHook);
			return setmetatable(newHook, {
				__call = function(self, ...)
					self.stop();
					local result = self.call(...);
					self.start();
					return result;
				end
			});
		end
		function __hooks__:unref()
			for _, hook in ipairs(self.hooks) do
				if hook.status then
					hook.stop();
				end
			end
		end
		return __hooks__;
	end,
	["game.User"] = function(...)
		local config = import("Config");
		local assets = import("Assets");
		local admins = import("game.Admins");
		function __user__:getAloginStatus()
			return self.alogin;
		end
		function __user__:setAloginStatus(status)
			self.alogin = status;
			if config.root.cheats.wallhack.use and not config.root.cheats.wallhack.imguiStyle then
				assets:changeWallhackState(self.alogin);
			end
			for _, callback in pairs(self.aloginCallbacks) do
				callback(self.alogin);
			end
			if not status then
				for index, _ in ipairs(admins) do
					admins[((index))] = nil;
				end
			end
		end
		function __user__:addOnAloginCallback(id, callback)
			self.aloginCallbacks[((id))] = callback;
		end
		function __user__:switchAloginStatus()
			self:setAloginStatus(not self.alogin);
		end
		function __user__:getId()
			return select(2, sampGetPlayerIdByCharHandle(PLAYER_PED));
		end
		function __user__:getNickname()
			return sampGetPlayerNickname(self:getId());
		end
		function __user__:getPing()
			return sampGetPlayerPing(self:getId());
		end
		function __user__:getOOCNickname()
			return config.root.user.oocNickname;
		end
		function __user__:setOOCNickname(nickname)
			config.root.user.oocNickname = nickname;
		end
		function __user__:getAdminLvl()
			return config.root.user.adminLvl;
		end
		function __user__:setAdminLvl(lvl)
			config.root.user.adminLvl = lvl;
		end
		function __user__:setAfkTime(time)
			self.afkTime = time;
		end
		function __user__:getAfkTime()
			return self.afkTime;
		end
		function __user__:updateTime()
			if os.clock()-self.online.clock>=1 and self:getAloginStatus() then
				self.online.clock = os.clock();
				self.online.session = self.online.session + 1;
				config.root.user.online.total = config.root.user.online.total + 1;
				do
					local this = config.root.user.online.weeks;
					if this ~= nil then
						if this[(#this)] and this[(#this)].weekPos==tonumber(os.date("%W"))+tonumber(os.date("%y")) then
							this[((#this))].days[((tonumber(os.date("%w"))+1))] = this[((#this))].days[((tonumber(os.date("%w"))+1))] + 1;
						else
							table.insert(this, {
								weekPos = tonumber(os.date("%W"))+tonumber(os.date("%y")), 
								days = {
									0, 
									0, 
									0, 
									0, 
									0, 
									0, 
									0
								}
							});
							this[((#this))].days[((tonumber(os.date("%w"))+1))] = this[((#this))].days[((tonumber(os.date("%w"))+1))] + 1;
						end
					end
				end
			end
		end
		function __user__:getTime()
			return {
				session = assets:explodeDate(self.online.session), 
				total = assets:explodeDate(config.root.user.online.total), 
				week = config.root.user.online.weeks[(#config.root.user.online.weeks)], 
				weekTotal = (function()
					local total = 0;
					do
						local this = config.root.user.online.weeks[(#config.root.user.online.weeks)];
						if this ~= nil then
							if this.weekPos==tonumber(os.date("%W"))+tonumber(os.date("%y")) then
								for _, time in ipairs(this.days) do
									total = total + time;
								end
							end
						end
					end
					return assets:explodeDate(total);
				end)()
			};
		end
		function __user__:incrementAnswersCount()
			self.answersCount = self.answersCount + 1;
			config.root.user.answers.total = config.root.user.answers.total + 1;
			do
				local this = config.root.user.answers.weeks;
				if this ~= nil then
					if this[(#this)] and this[(#this)].weekPos==tonumber(os.date("%W"))+tonumber(os.date("%y")) then
						this[((#this))].days[((tonumber(os.date("%w"))+1))] = this[((#this))].days[((tonumber(os.date("%w"))+1))] + 1;
					else
						table.insert(this, {
							weekPos = tonumber(os.date("%W"))+tonumber(os.date("%y")), 
							days = {
								0, 
								0, 
								0, 
								0, 
								0, 
								0, 
								0
							}
						});
						this[((#this))].days[((tonumber(os.date("%w"))+1))] = this[((#this))].days[((tonumber(os.date("%w"))+1))] + 1;
					end
				end
			end
		end
		function __user__:getAnswersCount()
			return {
				session = self.answersCount, 
				total = config.root.user.answers.total, 
				week = config.root.user.answers.weeks[(#config.root.user.answers.weeks)], 
				weekTotal = (function()
					local total = 0;
					do
						local this = config.root.user.answers.weeks[(#config.root.user.answers.weeks)];
						if this ~= nil then
							for _, answers in ipairs(this.days) do
								total = total + answers;
							end
						end
					end
					return total;
				end)()
			};
		end
		return __user__;
	end,
	["game.sa.Ped"] = function(...)
		local ped = {
			getBodyPartCoordinatesCast = ffi.cast("int(__thiscall*)(void*, float*, int, bool)", 0x5E4280)
		};
		function ped:getBodyPartCoordinates(id, handle)
			local vector = ffi.new("float[3]");
			self.getBodyPartCoordinatesCast(ffi.cast("void*", getCharPointer(handle)), vector, id, true);
			return vector[(0)], vector[(1)], vector[(2)];
		end
		function ped:getPlayerWeaponNameById(id)
			local result, ped = sampGetCharHandleBySampPlayerId(id);
			if result then
				return require("game.weapons").names[(getCurrentCharWeapon(ped))];
			end
			return nil;
		end
		function ped:getClosestHandleTo(to)
			if to == nil then
				to = PLAYER_PED
			end
			local minDistance = 9999;
			local closestHandle = nil;
			local x, y, z = getCharCoordinates(PLAYER_PED);
			for _, handle in ipairs(getAllChars()) do
				local result, _ = sampGetPlayerIdByCharHandle(handle);
				if result then
					local xI, yI, zI = getCharCoordinates(handle);
					local distance = math.sqrt((xI-x)^2+(yI-y)^2+(zI-z)^2);
					if distance<minDistance then
						minDistance = distance;
						closestHandle = handle;
					end
				end
			end
			return closestHandle;
		end
		function ped:isBehindWall(ped)
			local behindWall = false;
			local result, _ = sampGetPlayerIdByCharHandle(ped);
			if result and isCharOnScreen(ped) then
				if ped==PLAYER_PED then
					behindWall = true;
				end
				local x, y, z = self:getBodyPartCoordinates(8, ped);
				local x1, y1, z1 = getActiveCameraCoordinates();
				behindWall = isLineOfSightClear(x, y, z, x1, y1, z1, true, false, false, true, false);
			end
			return not behindWall;
		end
		function ped:teleport(x, y, z)
			local function setEntityCoordinates(entityPtr, x, y, z)
				if entityPtr~=0 then
					local matrixPtr = readMemory(entityPtr+0x14, 4, false);
					if matrixPtr~=0 then
						local posPtr = matrixPtr+0x30;
						writeMemory(posPtr+0, 4, representFloatAsInt(x), false);
						writeMemory(posPtr+4, 4, representFloatAsInt(y), false);
						writeMemory(posPtr+8, 4, representFloatAsInt(z), false);
					end
				end
			end
			if isCharInAnyCar(PLAYER_PED) then
				setCharCoordinates(PLAYER_PED, x, y, z);
			end
			if doesCharExist(PLAYER_PED) then
				local pointer = getCharPointer(PLAYER_PED);
				setEntityCoordinates(pointer, x, y, z);
			end
		end
		return ped;
	end,
	["game.Binder"] = function(...)
		local variables = import("game.binder.Variables");
		local HotKey = import("imgui.HotKey");
		local config = import("Config");
		local binder = {		};
		function binder:sendString(command, input, arguments, delayBetweenMessages)
			if delayBetweenMessages == nil then
				delayBetweenMessages = 800
			end
			if arguments == nil then
				arguments = {				}
			end
			input = string.gsub(input, "%${{(.-)}}", function(params)
				do
					local variable, params = string.match(params, "^%s*([A-Z_]+)(.*)");
					if variable ~= nil and params ~= nil then
						local parameter = nil;
						if #params>0 and string.sub(params, 1, 1)==',' then
							parameter = string.match(params, "^,%s*(.*)");
							do
								local start, _ = string.find(parameter, "%s*$");
								if start ~= nil and _ ~= nil then
									local _internal0;
									if (start~=1) then
										_internal0 = string.sub(parameter, 1, start-1);
									else
										_internal0 = "";
									end
									parameter = _internal0;
								end
							end
						end
						if variable=="GET_ARGUMENT" and tonumber(parameter) then
							do
								local argument = arguments[(tonumber(parameter))];
								if argument ~= nil then
									return argument;
								end
							end
						else
							do
								local callback = variables[(variable)];
								if callback ~= nil then
									do
										local result = callback();
										if result ~= nil then
											return result;
										else
											return parameter or "N/A";
										end
									end
								end
							end
						end
					end
				end
				return "";
			end);
			lua_thread.create(function()
				for line in string.gmatch(input, "[^\n]+") do
					if string.find(line, "^%^") then
						lua_thread.create(function()
							wait(100);
							sampSetChatInputEnabled(true);
							sampSetChatInputText(string.sub(line, 2));
						end);
					else
						local chatCommand = string.match(line, "^/(.+)[ $]");
						if chatCommand and (chatCommand~=command and sampIsChatCommandDefined(chatCommand)) then
							sampProcessChatInput(line);
						else
							sampSendChat(line);
						end
					end
					wait(delayBetweenMessages);
				end
			end);
		end
		function binder:newBind(title, value, delayBetweenMessages, commandName)
			table.insert(config.root.binds, {
				title = title, 
				value = value, 
				delay = delayBetweenMessages, 
				keys = {				}, 
				commandName = commandName
			});
			if commandName then
				sampRegisterChatCommand(commandName, function(args)
					if args == nil then
						args = ""
					end
					local arguments = {					};
					for argument in string.gmatch(args, "[^%s]+") do
						table.insert(arguments, argument);
					end
					self:sendString(commandName, value, arguments, delayBetweenMessages);
				end);
			end
			HotKey:new("binderIndex"..#config.root.binds, {			}):registerCallback(function()
				self:sendString(commandName, value, nil, delayBetweenMessages);
			end);
		end
		function binder:initializeBinds()
			for index, bind in ipairs(config.root.binds) do
				if bind.commandName then
					sampRegisterChatCommand(bind.commandName, function(args)
						if args == nil then
							args = ""
						end
						local arguments = {						};
						for argument in string.gmatch(args, "[^%s]+") do
							table.insert(arguments, argument);
						end
						self:sendString(bind.commandName, bind.value, arguments, bind.delay);
					end);
				end
				HotKey:new("binderIndex"..index, bind.keys):registerCallback(function()
					self:sendString(bind.commandName, bind.value, nil, bind.delay);
				end);
			end
		end
		return binder;
	end,
	["game.samp.ChatInputBox"] = function(...)
		local chatInputBox = {		};
		function chatInputBox:getPosition()
			local DXUTEditBox = getStructElement(sampGetInputInfoPtr(), 0x8, 4);
			local posX, posY = getStructElement(DXUTEditBox, 0x8, 4), getStructElement(DXUTEditBox, 0xC, 4)+50;
			return posX, posY;
		end
		return chatInputBox;
	end,
	["game.samp.Player"] = function(...)
		local player = {		};
		function player:getIdByNickname(nickname)
			local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED);
			if nickname==sampGetPlayerNickname(myid) then
				return myid;
			end
			for i = 0, 600, 1 do
				if sampIsPlayerConnected(i) and sampGetPlayerNickname(i)==nickname then
					return i;
				end
			end
			return nil;
		end
		return player;
	end,
	["game.sa.Vehicle"] = function(...)
		local vehicle = {		};
		function vehicle:getName(id)
			local _internal0 = tonumber(id);
			if (_internal0 == 525) then
				_internal0 = "Towtruck";
			else
				if (_internal0 == 552) then
					_internal0 = "Utility Van";
				else
					if (_internal0 == 437) then
						_internal0 = "Coach";
					else
						if (_internal0 == 582) then
							_internal0 = "Newsvan";
						else
							if (_internal0 == 431) then
								_internal0 = "Bus";
							else
								if (_internal0 == 510) then
									_internal0 = "Mountain Bike";
								else
									if (_internal0 == 490) then
										_internal0 = "FBI Rancher";
									else
										if (_internal0 == 488) then
											_internal0 = "SAN News Maverick";
										else
											if (_internal0 == 497) then
												_internal0 = "Police Maverick";
											else
												if (_internal0 == 420) then
													_internal0 = "Taxi";
												else
													if (_internal0 == 416) then
														_internal0 = "Ambulance";
													else
														if (_internal0 == 472) then
															_internal0 = "Coastguard";
														else
															if (_internal0 == 528) then
																_internal0 = "FBI Truck";
															else
																if (_internal0 == 406) then
																	_internal0 = "Dumper";
																else
																	if (_internal0 == 407) then
																		_internal0 = "Firetruck";
																	else
																		if (_internal0 == 408) then
																			_internal0 = "Trashmaster";
																		else
																			if (_internal0 == 428) then
																				_internal0 = "Securicar";
																			else
																				if (_internal0 == 438) then
																					_internal0 = "Cabbie";
																				else
																					if (_internal0 == 443) then
																						_internal0 = "Packer";
																					else
																						if (_internal0 == 471) then
																							_internal0 = "Quad";
																						else
																							if (_internal0 == 485) then
																								_internal0 = "Baggage";
																							else
																								if (_internal0 == 486) then
																									_internal0 = "Dozer";
																								else
																									if (_internal0 == 524) then
																										_internal0 = "Cement Truck";
																									else
																										if (_internal0 == 530) then
																											_internal0 = "Forklift";
																										else
																											if (_internal0 == 531) then
																												_internal0 = "Tractor";
																											else
																												if (_internal0 == 532) then
																													_internal0 = "Combine Harvester";
																												else
																													if (_internal0 == 544) then
																														_internal0 = "Firetruck LA";
																													else
																														if (_internal0 == 571) then
																															_internal0 = "Kart";
																														else
																															if (_internal0 == 572) then
																																_internal0 = "Mower";
																															else
																																if (_internal0 == 574) then
																																	_internal0 = "Sweeper";
																																else
																																	if (_internal0 == 596) then
																																		_internal0 = "Police Car (LSPD)";
																																	else
																																		if (_internal0 == 597) then
																																			_internal0 = "Police Car (SFPD)";
																																		else
																																			if (_internal0 == 598) then
																																				_internal0 = "Police Car (LVPD)";
																																			else
																																				if (_internal0 == 509) then
																																					_internal0 = "Bike";
																																				else
																																					_internal0 = getGxtText(getNameOfVehicleModel(tonumber(id)));
																																				end
																																			end
																																		end
																																	end
																																end
																															end
																														end
																													end
																												end
																											end
																										end
																									end
																								end
																							end
																						end
																					end
																				end
																			end
																		end
																	end
																end
															end
														end
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
			return _internal0;
		end
		function vehicle:getFreeSeat(car)
			if doesCharExist(getDriverOfCar(car)) then
				local maxPassengers = getMaximumNumberOfPassengers(car);
				for i = 0, maxPassengers, 1 do
					if isCarPassengerSeatFree(car, i) then
						return i+1;
					end
				end
				return nil;
			else
				return 0;
			end
		end
		function vehicle:jumpInto(car)
			local seat = self:getFreeSeat(car);
			if not seat then
				return false;
			end
			if seat==0 then
				warpCharIntoCar(PLAYER_PED, car);
			else
				warpCharIntoCarAsPassenger(PLAYER_PED, car, seat-1);
			end
			restoreCameraJumpcut();
			return true;
		end
		return vehicle;
	end,
	["Algorithm"] = function(...)
		local algorithm = {		};
		function algorithm:swap(tab, indexA, indexB)
			local temp = tab[(indexA)];
			tab[((indexA))] = tab[(indexB)];
			tab[((indexB))] = temp;
		end
		function algorithm:bubbleSortByKey(tab, key)
			local n = #tab;
			local sorted = false;
			while not sorted do
				sorted = true;
				for i = 1, n-1, 1 do
					if tab[(i)][(key)]>tab[(i+1)][(key)] then
						self:swap(tab, i, i+1);
						sorted = false;
					end
				end
				n = n-1;
			end
		end
		return algorithm;
	end,
	["MovableWindows"] = function(...)
		local spectator = import("game.Spectator");
		local imguiAssets = import("imgui.Assets");
		local config = import("Config");
		local common = import("Common");
		local MV_VIEW_CONDITIONS = {
			[(MV_ONLY_IN_SPECTATOR)] = function()
				return spectator.status;
			end, 
			[(MV_ONLY_NOT_IN_SPECTATOR)] = function()
				return not spectator.status;
			end, 
			[(MV_DEFAULT)] = function()
				return true;
			end
		};
		function __movableWindows__:isChangingWindowsPositions()
			return self.changingWindowsPositions;
		end
		function __movableWindows__:executeChangingWindowsPositions()
			self.changingWindowsPositions = not self.changingWindowsPositions;
			imguiAssets:switchCursorStatus();
			if self.changingWindowsPositions then
				common:sendScriptMessage("Используйте клавиши на клавиатуре [1-3] чтобы переключаться между режимами:");
				for _, viewModeDescription in ipairs(MV_VIEW_DESCRIPTIONS) do
					common:sendScriptMessage("%s%s", string.rep(" ", 4), viewModeDescription);
				end
				common:sendScriptMessage("Чтобы выйти из режима редактирования, нажмите ESC.");
			end
		end
		function __movableWindows__:setupThisWindow(window)
			if self.changingWindowsPositions then
				if window.isHovered then
					local dl = imgui.GetBackgroundDrawList();
					dl:AddRectFilled(imgui.ImVec2(window.pos.x-2, window.pos.y-25), imgui.ImVec2(window.pos.x+window.size.x+2, window.pos.y+window.size.y+2), 0xAAFFFFFF, window.rounding);
					dl:AddText(imgui.ImVec2(window.pos.x+2, window.pos.y-18), 0xFF000000, window.description);
				end
				if imgui.IsMouseDown(0) and window.isFocused then
					local sw, sh = getScreenResolution();
					local posX, posY = config.root.movableWindows[(window.id)].x+imgui.GetIO().MouseDelta.x, config.root.movableWindows[(window.id)].y+imgui.GetIO().MouseDelta.y;
					local sizeX, sizeY = window.size.x, window.size.y;
					local centerX = posX+window.size.x/2;
					local centerY = posY+window.size.y/2;
					if math.abs(centerX-(sw/2))<5 then
						posX = math.floor(sw/2)-window.size.x/2;
					end
					if math.abs(centerY-(sh/2))<5 then
						posY = math.floor(sh/2)-window.size.y/2;
					end
					if posX>sw-sizeX then
						posX = sw-sizeX;
					elseif posX<=0 then
						posX = 0;
					elseif posY>=sh-sizeY then
						posY = sh-sizeY;
					elseif posY<=0 then
						posY = 0;
					end
					if posX+sizeX>sw then
						posX = sw-sizeX;
					elseif posX<=0 then
						posX = 0;
					end
					if posY+sizeY>sh then
						posY = sh-sizeY;
					elseif posY<=0 then
						posY = 0;
					end
					config.root.movableWindows[((window.id))].x = posX;
					config.root.movableWindows[((window.id))].y = posY;
				end
			end
		end
		function __movableWindows__:setupThisWindowCondition(type)
			return not isGamePaused() and MV_VIEW_CONDITIONS[(type)]() or (self.changingWindowsPositions and (self.viewMode==type or self.viewMode==MV_DEFAULT));
		end
		return __movableWindows__;
	end,
	["imgui.windows.AutoUpdate"] = function(...)
		local autoUpdate = import("AutoUpdate");
		local config = import("Config");
		local imguiAssets = import("imgui.Assets");
		local animations = import("imgui.Animations");
		local StyleChanger = import("imgui.StyleChanger");
		local sizeX, sizeY = getScreenResolution();
		imgui.OnFrame(function()
			return autoUpdate.windowState;
		end, function(self)
			self.HideCursor = imguiAssets:getCursorStatus();
			self.flags = imgui.WindowFlags.NoMove+imgui.WindowFlags.NoResize+imgui.WindowFlags.NoTitleBar+imgui.WindowFlags.NoScrollbar;
			imgui.SetNextWindowPos(imgui.ImVec2(sizeX/2, sizeY/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5));
			imgui.SetNextWindowSize(imgui.ImVec2(720, 400));
			local itemSpacing, windowPadding = imgui.GetStyle().ItemSpacing, imgui.GetStyle().WindowPadding;
			imgui.Begin("imgui.windows.AutoUpdate", nil, self.flags);
			imguiAssets:textWithFont(autoUpdate.imgui.title, bold14, imgui.ImVec2(imgui.GetWindowWidth()/2-imgui.CalcTextSize(autoUpdate.imgui.title).x/2, 10));
			imgui.PushStyleColor(imgui.Col.ChildBg, imgui.GetStyle().Colors[(imgui.Col.WindowBg)]);
			imgui.BeginChild("imgui.windows.AutoUpdate.child", imgui.ImVec2(0, imgui.GetWindowHeight()-70-windowPadding.y), false);
			autoUpdate:renderXMLGroup(autoUpdate.imgui.body);
			imgui.EndChild();
			imgui.PopStyleColor();
			imgui.SetCursorPosY(imgui.GetWindowHeight()-33-windowPadding.y);
			imgui.PushStyleColor(imgui.Col.ChildBg, imgui.GetStyle().Colors[(imgui.Col.Button)]);
			imgui.BeginGroup();
			imgui.PushFont(regular12);
			if animations:button(autoUpdate.imgui.buttons.first, imgui.ImVec2(imgui.GetWindowWidth()/3, 30), 15) then
				autoUpdate.response = AUTOUPDATE_RESPONSE_OK;
				autoUpdate.windowState = false;
				autoUpdate:update();
			end
			animations:hint("Эта версия установится.");
			imgui.SameLine();
			if animations:button(autoUpdate.imgui.buttons.second, imgui.ImVec2(imgui.GetWindowWidth()/3-20, 30)) then
				config.root.autoUpdate.skipVersionUpdate = autoUpdate.imgui.version;
				autoUpdate.response = AUTOUPDATE_RESPONSE_BAD;
				autoUpdate.windowState = false;
			end
			animations:hint("Эта версия пропустится, окно не будет появляться до следующего обновления.");
			imgui.SameLine();
			if animations:button(autoUpdate.imgui.buttons.third, imgui.ImVec2(imgui.GetWindowWidth()/3, 30)) then
				autoUpdate.response = AUTOUPDATE_RESPONSE_BAD;
				autoUpdate.windowState = false;
			end
			animations:hint("Это окно не будет появляться до следующего запуска скрипта.");
			imgui.PopFont();
			imgui.EndGroup();
			imgui.PopStyleColor();
			imgui.End();
		end);
	end,
	["game.Spectator"] = function(...)
		local ped = import("game.sa.Ped");
		local user = import("game.User");
		SPECTATOR_MENU_NEXT = 0;
		SPECTATOR_MENU_SWITCH = 1;
		SPECTATOR_MENU_BACK = 2;
		SPECTATOR_MENU_STATS = 3;
		SPECTATOR_MENU_SESSIONS = 4;
		SPECTATOR_MENU_FRISK = 5;
		SPECTATOR_MENU_EXIT = 6;
		user:addOnAloginCallback("game.Spectator", function(state)
			if not state then
				__spectator__:exit();
			end
		end);
		function __spectator__:getInformation()
			local result, _ = self:getHandle();
			local _internal0;
			if (result) then
				_internal0 = sampGetPlayerArmor(self.id);
			else
				_internal0 = 0;
			end
			local _internal1;
			if (result) then
				_internal1 = sampGetPlayerPing(self.id);
			else
				_internal1 = 0;
			end
			return {
				platform = self.platform or "N/A", 
				armor = _internal0, 
				ping = _internal1, 
				weapon = ped:getPlayerWeaponNameById(self.id) or "N/A", 
				accountId = self.information.accountId or "N/A", 
				health = self.information.health or "N/A", 
				statsId = self.information.statsId or "N/A", 
				money = self.information.money or "N/A", 
				bank = self.information.bank or "N/A", 
				fraction = self.information.fraction or "N/A", 
				rang = self.information.rang or "N/A", 
				vehicle = self.information.vehicle or "N/A", 
				house = self.information.house or "N/A", 
				vip = self.information.vip or "N/A", 
				regDate = self.information.regDate or "N/A", 
				warnings = self.information.warnings or "N/A", 
				stage = self.information.stage or "N/A", 
				afkTime = self.afk.time or "N/A", 
				moveSpeed = {
					current = self.information.moveSpeedCurrent or "N/A", 
					max = self.information.moveSpeedMax or "N/A"
				}, 
				shot = {
					total = self.information.shotTotal or "0", 
					hit = self.information.shotHit or "0"
				}
			};
		end
		function __spectator__:setupJoyStickWatcher(x, y)
			do
				local this = self.keys[(PLATFORM_ANDROID)][(SYNC_KEYS_JOY_STICK)];
				if this ~= nil then
					if os.clock()-this.clock>0.1 then
						this.clock = os.clock();
						this.old.x = this.new.x;
						this.old.y = this.new.y;
						local _internal1;
						if (not x) then
							_internal1 = 0;
						else
							local _internal0;
							if (x>128) then
								_internal0 = x-0xFFFF;
							else
								_internal0 = x;
							end
							_internal1 = (_internal0);
						end
						this.new.x = _internal1;
						local _internal3;
						if (not y) then
							_internal3 = 0;
						else
							local _internal2;
							if (y>128) then
								_internal2 = y-0xFFFF;
							else
								_internal2 = y;
							end
							_internal3 = (_internal2);
						end
						this.new.y = _internal3;
					end
				end
			end
		end
		function __spectator__:setKeyStatus(syncType, key, status)
			self.keys[((self.platform))][((syncType))][((key))] = status;
		end
		function __spectator__:setInformation(information)
			if information == nil then
				information = {				}
			end
			for key, value in pairs(information) do
				self.information[((key))] = value;
			end
		end
		function __spectator__:platformToString()
			local _internal0 = self.platform;
			if (_internal0 == PLATFORM_PC) then
				_internal0 = "PC";
			else
				if (_internal0 == PLATFORM_ANDROID) then
					_internal0 = "MOBILE";
				else
					_internal0 = "N/A";
				end
			end
			return _internal0;
		end
		function __spectator__:getActiveTime()
			if self.time then
				local time = os.date("*t");
				local diff = os.difftime(os.time(time), os.time(self.time));
				local minutes = math.floor(diff/60);
				local seconds = diff%60;
				return string.format("%02d:%02d", minutes, seconds);
			else
				return "00:00";
			end
		end
		function __spectator__:getHandle()
			if self.id~=-1 and sampIsPlayerConnected(self.id) and self.status then
				return sampGetCharHandleBySampPlayerId(self.id);
			end
			return false, nil;
		end
		function __spectator__:setTo(playerId)
			if playerId then
				self.status = true;
				if self.id~=playerId or not self.time then
					self.time = os.date("*t");
				end
				self.id = playerId;
				if tonumber(self.information.statsId)~=self.id and os.clock()-self.stats.lastChecked>1 and not sampIsDialogActive() and not self.stats.checking then
					sampSendMenuSelectRow(3);
					self.stats.checking = true;
					self.stats.lastChecked = os.clock();
					self.afk.time = 0;
					self.information.shotTotal = "0";
					self.information.shotHit = "0";
					self.keys = {
						[(PLATFORM_PC)] = {
							[(SYNC_KEYS_PLAYER)] = {							}, 
							[(SYNC_KEYS_VEHICLE)] = {							}
						}, 
						[(PLATFORM_ANDROID)] = {
							[(SYNC_KEYS_PLAYER)] = {							}, 
							[(SYNC_KEYS_VEHICLE)] = {							}, 
							[(SYNC_KEYS_JOY_STICK)] = {
								new = {
									x = 0, 
									y = 0
								}, 
								old = {
									x = 0, 
									y = 0
								}, 
								clock = os.clock()
							}
						}
					};
					if not self.afk.awaiting.message then
						lua_thread.create(function()
							wait(800);
							self.afk.awaiting.message = true;
							sampSendChat(string.format("/afk %d", self.id));
						end);
					end
				end
			end
		end
		function __spectator__:exit()
			self.status = false;
			self.time = nil;
			self.id = -1;
			self.platform = PLATFORM_AWAITING_OR_NONE;
			self.information = {			};
		end
		return __spectator__;
	end,
	["imgui.windows.UserInformation"] = function(...)
		local window = import("imgui.Windows");
		local imguiAssets = import("imgui.Assets");
		local StyleChanger = import("imgui.StyleChanger");
		local user = import("game.User");
		local config = import("Config");
		local assets = import("Assets");
		window:new("imgui.windows.UserInformation", {
			description = "Информация о Вас", 
			type = MV_DEFAULT, 
			size = {
				x = 200, 
				y = 0
			}, 
			condition = function()
				return config.root.windows.userInformation.use and isSampAvailable() and user:getAloginStatus();
			end, 
			initialize = {
				style = StyleChanger:new({
					WindowBorderSize = 0, 
					WindowBg = imgui.ImVec4(0, 0, 0, 0)
				})
			}
		}, function(self)
			local strokeSize = config.root.windows.userInformation.strokeSize;
			self.setNextItemAligned = function(text)
				local pos = imgui.GetCursorPos();
				local _internal0 = config.root.windows.userInformation.textAlignMode;
				if (_internal0 == ALIGN_CENTER) then
					_internal0 = self.size.x/2-imgui.CalcTextSize(text).x/2;
				else
					if (_internal0 == ALIGN_RIGHT) then
						_internal0 = self.size.x-imgui.CalcTextSize(text).x-strokeSize-imgui.GetStyle().WindowPadding.x;
					else
						_internal0 = pos.x;
					end
				end
				local align = _internal0;
				imgui.SetCursorPosX(align);
			end;
			for startIndex, startItem in ipairs(config.root.windows.userInformation.display) do
				if startItem~="NewLine" then
					for endIndex, endItem in ipairs(config.root.windows.userInformation.display) do
						if endItem~="NewLine" then
							if startItem[(1)]==endItem[(1)] and startIndex~=endIndex then
								table.remove(config.root.windows.userInformation.display, endIndex);
							end
						end
					end
				end
			end
			self.var.style:apply();
			self:begin(self.id, function()
				imgui.BeginGroup();
				local time = assets:getLocalTime();
				local online = user:getTime();
				local answers = user:getAnswersCount();
				if config.root.windows.userInformation.showTime then
					local text = string.format("%d-%d-%d %02d:%02d:%02d", time.wYear, time.wMonth, time.wDay, time.wHour, time.wMinute, time.wSecond);
					self.setNextItemAligned(text);
					imguiAssets:addStrokedText(text, strokeSize);
				end
				for _, item in ipairs(config.root.windows.userInformation.display) do
					local values = {
						[("ID")] = user:getId(), 
						[("IC никнейм")] = user:getNickname(), 
						[("OOC никнейм")] = user:getOOCNickname(), 
						[("Админ уровень")] = user:getAdminLvl(), 
						[("Пинг")] = user:getPing(), 
						[("Общий онлайн")] = function()
							local this = online.total;
							return string.format("%02d:%02d:%02d", this.hour, this.min, this.sec);
						end, 
						[("Онлайн за неделю")] = function()
							local this = online.weekTotal;
							return string.format("%02d:%02d:%02d", this.hour, this.min, this.sec);
						end, 
						[("Онлайн за сессию")] = function()
							local this = online.session;
							return string.format("%02d:%02d:%02d", this.hour, this.min, this.sec);
						end, 
						[("Ответов всего")] = answers.total, 
						[("Ответов за неделю")] = answers.weekTotal, 
						[("Ответов за сесcию")] = answers.session
					};
					if item=="NewLine" then
						imgui.NewLine();
					else
						if item[(2)] and values[(item[(1)])] then
							local _internal0;
							if (type(values[(item[(1)])])=="function") then
								_internal0 = values[(item[(1)])]();
							else
								_internal0 = values[(item[(1)])];
							end
							local name, value = item[(1)], tostring(_internal0);
							self.setNextItemAligned(name..": "..value);
							imguiAssets:addStrokedText("%s: %s", strokeSize, nil, name, value);
							imguiAssets:setPreviousItemAbleToCopy(value);
						end
					end
				end
				imgui.EndGroup();
				if imgui.GetItemRectSize().x>self.size.x then
					self.size.x = imgui.GetItemRectSize().x+20;
				end
			end);
			self.var.style:reset();
		end);
	end,
	["game.GReport"] = function(...)
		local HotKey = import("imgui.HotKey");
		local notify = import("Notifications");
		local icons = import("Icons");
		local config = import("Config");
		if __greport__.hotKey == nil then
			__greport__.hotKey = HotKey:new("imgui.window.GReport", {
				0xA2, 
				0x31
			}, "Открыть/закрыть /greport"):registerCallback(function()
				do
					local this = __greport__;
					if this ~= nil then
						if #this.player.context>0 or (this.player.receivedAt and (os.clock()-this.player.receivedAt<=15)) then
							this.window:switch();
						end
					end
				end
			end);
		end
		function __greport__:loop()
			if self.player.clock and config.root.windows.greport.reminderNotification and not self.window.state then
				if os.clock()-self.player.clock>=config.root.windows.greport.remindSeconds then
					self.player.clock = os.clock();
					notify:send({
						title = "Напоминание про /greport", 
						text = "Прошло "..config.root.windows.greport.remindSeconds.." с момента последнего открытия /greport.", 
						duration = 10, 
						condition = function()
							return self.window.state;
						end, 
						buttons = {
							first = {
								name = "Открыть", 
								call = function()
									self.window:switch();
								end
							}, 
							second = {
								name = "Закрыть", 
								call = function(close)
									close();
								end
							}
						}
					});
				end
			end
		end
		function __greport__.window:open(withDialog)
			if withDialog == nil then
				withDialog = true
			end
			if not self.state then
				self.closeAndOpenAnimation.alpha = 0;
				self.state = true;
				do
					local this = __greport__;
					if this ~= nil then
						if not this.dialog.state and withDialog then
							this.dialog:call();
						end
					end
				end
			end
		end
		function __greport__.window:close(withDialog)
			if withDialog == nil then
				withDialog = true
			end
			if self.state then
				self.closeAndOpenAnimation.clock = os.clock();
				if withDialog then
					__greport__.player:closeDialogIfPresent();
				end
			end
		end
		function __greport__.window:switch(withDialog)
			if withDialog == nil then
				withDialog = true
			end
			if self.state then
				self:close(withDialog);
			else
				self:open(withDialog);
			end
		end
		function __greport__.dialog:call()
			sampSendChat("/greport");
		end
		function __greport__.dialog:callOptionAt(listItemIndex)
			sampSendDialogResponse(32500, 0, 0, "");
			self.awaiting.options = {
				true, 
				listItemIndex
			};
		end
		function __greport__.dialog:setInputValue(value)
			self.awaiting.input = {
				true, 
				value
			};
		end
		function __greport__.player:getActiveTime()
			if self.time then
				local time = os.date("*t");
				local minutes = math.floor((time.min-self.time.min+60)%60);
				local seconds = math.floor((time.sec-self.time.sec)%60);
				return string.format("%02d:%02d", minutes, seconds);
			else
				return "00:00";
			end
		end
		function __greport__.player:spectate()
			do
				local this = __greport__;
				if this ~= nil then
					sampSendChat("/sp "..self.id);
					this.dialog.state = false;
					this.window:close(true);
				end
			end
		end
		function __greport__.player:remove(reason)
			do
				local this = __greport__;
				if this ~= nil then
					this.dialog:callOptionAt(GREPORT_OPTION_REMOVE);
					this.dialog:setInputValue(reason);
					this.dialog.state = false;
					this.window:close(false);
					self:reset();
				end
			end
		end
		function __greport__.player:setMapPoint()
			do
				local this = __greport__;
				if this ~= nil then
					this.dialog:callOptionAt(GREPORT_OPTION_SET_MAP_POINT);
					this.dialog.state = false;
					this.window:close();
					notify:send({
						title = "Установите метку на карте", 
						text = "Зайдите в меню паузы, и на карте поставьте метку игроку.", 
						icon = icons.ICON_STAR, 
						duration = 5
					});
				end
			end
		end
		function __greport__.player:blockReport(time, reason)
			local allowed = {
				[(10)] = 0, 
				[(30)] = 1, 
				[(60)] = 2, 
				[(90)] = 3
			};
			do
				local listItem = allowed[(time)];
				if listItem ~= nil then
					do
						local this = __greport__;
						if this ~= nil then
							this.dialog:callOptionAt(GREPORT_OPTION_BLOCK);
							this.dialog.awaiting.special = {
								true, 
								listItem
							};
							this.dialog:setInputValue(reason);
							this.dialog.state = false;
							this.window:close(false);
							self:reset();
						end
					end
				end
			end
		end
		function __greport__.player:answer(answer)
			do
				local this = __greport__;
				if this ~= nil then
					this.dialog:callOptionAt(GREPORT_OPTION_ANSWER);
					this.dialog:setInputValue(answer);
					this.dialog.state = false;
					this.window:close(false);
					self:reset();
				end
			end
		end
		function __greport__.player:closeDialogIfPresent()
			if __greport__.dialog.state then
				sampSendDialogResponse(32500, 1, nil, nil);
			end
		end
		function __greport__.player:moveReportToAdministration()
			do
				local this = __greport__;
				if this ~= nil then
					this.dialog:callOptionAt(GREPORT_OPTION_TO_ADMINISTRATION);
					this.dialog.state = false;
					this.window:close(false);
					self:reset();
				end
			end
		end
		function __greport__.player:reset()
			self.receivedAt = nil;
			self.time = nil;
			self.clock = nil;
			self.active = false;
			self.nickname = "";
			self.id = -1;
			self.context = "";
		end
		function __greport__:setupChatWatcher(text)
			local text = string.gsub(text, "{%x%x%x%x%x%x}", "");
			if not config.root.windows.greport.use then
				return;
			end
			do
				local nickname, id = string.match(text, "^%| На вас был назначен репорт от игрока (.+)%[(%d+)]%.");
				if nickname ~= nil and id ~= nil then
					self.player.nickname = nickname;
					self.player.receivedAt = os.clock();
					self.player.id = tonumber(id);
					if config.root.windows.greport.preferNotifications then
						notify:send({
							title = "Пришел репорт от "..string.gsub(nickname, "_", " "), 
							text = "У вас есть 15 секунд принять. Введите /grep(ort) или нажмите на "..tostring(self.hotKey), 
							icon = icons.ICON_PERSON, 
							duration = 15, 
							condition = function()
								return self.window.state;
							end
						});
					end
					if config.root.windows.greport.soundNotification then
						addOneOffSound(0, 0, 0, 1137);
					end
				end
			end
			if string.find(text, "^%| Обработка репорта завершена%.") and self.player.active then
				self.window:close();
				if not self.window.state then
					self:reset();
				end
				if config.root.windows.greport.preferNotifications then
					notify:send({
						title = "Обработка репорта завершена", 
						text = "Игрок был отсоединен от сервера.", 
						icon = icons.ICON_DENY, 
						duration = 3
					});
				end
			end
		end
		return __greport__;
	end,
	["Assets"] = function(...)
		local bit = require("bit");
		ffi.cdef("    typedef unsigned short WORD;    typedef struct {        WORD wYear;        WORD wMonth;        WORD wDayOfWeek;        WORD wDay;        WORD wHour;        WORD wMinute;        WORD wSecond;        WORD wMilliseconds;    } SYSTEMTIME, *PSYSTEMTIME;    typedef void            *PVOID;    typedef PVOID           HANDLE;    typedef HANDLE          HKL;    typedef HANDLE          HWND;    typedef unsigned long   DWORD;    typedef unsigned int    UINT;    typedef const char      *LPCSTR;    HKL GetKeyboardLayout(DWORD idThread);    UINT MapVirtualKeyExA(UINT uCode, UINT uMapType, HKL dwhkl);    void GetLocalTime(PSYSTEMTIME lpSystemTime);    int MessageBoxA(HWND hWnd, LPCSTR lpText, LPCSTR lpCaption, UINT uType);    HWND GetDesktopWindow();");
		local assets = {		};
		assets.randomICNicknames = {
			"Marcus_Tullius_Cicero", 
			"Francois_Marie_Arouet", 
			"Thales_of_Miletus", 
			"Friedrich_Nietzsche", 
			"Leonardo_da_Vinci", 
			"Immanuel_Kant", 
			"John_Locke", 
			"Augustine_of_Hippo", 
			"Arthur_Schopenhauer", 
			"Gottfried_Wilhelm_von_Leibniz", 
			"Diogenes_of_Sinope"
		};
		assets.randomStrings = {
			"Недостаточно овладеть премудростью, нужно также уметь пользоваться ею.", 
			"Тем, кто хочет учиться, часто вредит авторитет тех, кто учит.", 
			"Подумай, как трудно изменить себя самого, и ты поймешь, сколь ничтожны твои возможности изменить других.", 
			"Невежество — ночь ума, ночь безлунная и беззвездная.", 
			"Есть только одно благо — знание, и только одно зло — невежество.", 
			"Блаженство тела состоит в здоровье, блаженство ума — в знании.", 
			"Познавший самого себя — собственный палач.", 
			"Речь истины проста.", 
			"Единственным критерием истины является опыт.", 
			"Весёлое выражение лица постепенно отражается и на внутреннем мире.", 
			"Образование создаёт разницу между людьми.", 
			"Что легко? — Давать советы другим.", 
			"Кто ненавидит мир? Те, кто растерзал истину.", 
			"Многие философы так же тягостны, как ночные гуляки, нарушающие сон мирных жителей", 
			"Всякое учение истинно в том, что оно утверждает, и ложно в том, что оно отрицает или исключает.", 
			"Философия и медицина сделали человека самым разумным из животных, гадание и астрология — самым безумным, суеверие и деспотизм — самым несчастным.", 
			"С большой властью приходит большая ответственность."
		};
		assets.randomOOCNicknames = {
			"covboy", 
			"defaultzone", 
			"montreal", 
			"ivanrampage", 
			"Toshik", 
			"Furofushi", 
			"dontkillme", 
			"GoblinJr", 
			"krutenka", 
			"refraction", 
			"GMengland"
		};
		assets.voidQuotes = {
			"Где умирает надежда, там возникает пустота.", 
			"Бояться надо не смерти, а пустой жизни.", 
			"... ведь трудно увидеть опустошение, которому ты сам причиной...", 
			"Пустота сверху, пустота снизу и еще большая пустота между ними, а в ней я.", 
			"Иногда пустота бывает тяжелей, чем боль.", 
			"Любая пустота обязательно чем-нибудь заполняется.", 
			"Нет ничего печальнее, чем пустая комната ожидания.", 
			"Сознание боится пустоты.", 
			"Ничто не может быть лучше или хуже чего-либо. Ничто - это ничто.", 
			"Всё, что пусто, легко управляемо.", 
			"Вокруг меня только черная пустота, и нет мне утешения."
		};
		function assets:downloadFileList(files, afterDownloadCallback)
			local downloadStatus = require("moonloader").download_status;
			local total = 0;
			local time = os.clock();
			local result = false;
			lua_thread.create(function()
				while true do
					wait(0);
					if total==#files then
						result = true;
						afterDownloadCallback(files);
						break;
					else
						if os.clock()-time>=120 then
							break;
						end
					end
				end
			end);
			for _, data in ipairs(files) do
				lua_thread.create(function()
					wait(1000);
					downloadUrlToFile(data.url, data.destination, function(_, status, p1, p2)
						if status==downloadStatus.STATUS_ENDDOWNLOADDATA then
							total = total + 1;
						else
							
						end
					end);
				end);
			end
		end
		function assets:mapScanCodeToVKey(scanCode)
			local layout = ffi.C.GetKeyboardLayout(0);
			local vkey = ffi.C.MapVirtualKeyExA(scanCode, 3, layout);
			return vkey;
		end
		function assets:mergeTables(first, second)
			for key, value in pairs(second) do
				if type(value)=="table" and type(first[(key)] or false)=="table" then
					mergeTables(first[(key)], second[(key)]);
				else
					first[((key))] = value;
				end
			end
			return first;
		end
		function assets:explodeDate(timestamp)
			return {
				sec = timestamp%60, 
				min = math.floor(timestamp/60)%60, 
				hour = math.floor(timestamp/3600)
			};
		end
		function assets:weekToString(week)
			local result, days = "", {
				"Понедельник", 
				"Вторник", 
				"Среда", 
				"Четверг", 
				"Пятница", 
				"Суббота"
			};
			for day = 2, #week, 1 do
				local time = self:explodeDate(week[(day)] or 0);
				result = result .. string.format("%s: %02d:%02d:%02d\n", days[(day-1)], time.hour, time.min, time.sec);
			end
			local time = self:explodeDate(week[(1)] or 0);
			result = result .. string.format("Воскресенье: %02d:%02d:%02d", time.hour, time.min, time.sec);
			return result;
		end
		function assets:convertUnicode2Utf8(code)
			local t, h = {			}, 128;
			while code>=h do
				table.insert(t, 128+code%64);
				code = math.floor(code/64);
				local _internal0;
				if (h>32) then
					_internal0 = 32;
				else
					_internal0 = h/2;
				end
				h = _internal0;
			end
			table.insert(t, 256-2*h+code);
			return string.reverse(string.char(table.unpack(t)));
		end
		function assets:getLocalTime()
			local time = ffi.new("SYSTEMTIME");
			ffi.C.GetLocalTime(time);
			return time;
		end
		function assets:explodeARGB(argb)
			local a = bit.band((bit.rshift(argb, 24)), 255);
			local r = bit.band((bit.rshift(argb, 16)), 255);
			local g = bit.band((bit.rshift(argb, 8)), 255);
			local b = bit.band(argb, 255);
			return a, r, g, b;
		end
		function assets:convertU32ToARGB(abgr)
			local r = bit.band(abgr, 255);
			local g = bit.band((bit.rshift(abgr, 8)), 255);
			local b = bit.band((bit.rshift(abgr, 16)), 255);
			local a = bit.band((bit.rshift(abgr, 24)), 255);
			return bit.bor(b, bit.bor((bit.lshift(g, 8)), bit.bor((bit.lshift(r, 16)), (bit.lshift(a, 24)))));
		end
		function assets:convertARGBToU32(argb)
			local a = bit.band((bit.rshift(argb, 24)), 255);
			local r = bit.band((bit.rshift(argb, 16)), 255);
			local g = bit.band((bit.rshift(argb, 8)), 255);
			local b = bit.band(argb, 255);
			return bit.bor(r, bit.bor((bit.lshift(g, 8)), bit.bor((bit.lshift(b, 16)), (bit.lshift(a, 24)))));
		end
		function assets:copyTable(object, seen)
			if type(object)~="table" then
				return object;
			end
			local _internal0 = seen;
			if (_internal0 and _internal0[(object)]) then
				return seen[(object)];
			end
			local s = seen or {			};
			local result = setmetatable({			}, getmetatable(object));
			s[((object))] = result;
			for key, value in pairs(object) do
				result[((self:copyTable(key, value)))] = self:copyTable(value, s);
			end
			return result;
		end
		assets.collectScriptInformation = function()
			local config = assets:copyTable(import("Config").root);
			config.additions.autoLogin.accountPassword = "***";
			config.additions.autoLogin.aloginPassword = "***";
			local user = __user__;
			local greport = __greport__;
			local spectator = __spectator__;
			local imguiAssets = __imguiAssets__;
			local movableWindows = __movableWindows__;
			local admins = __admins__;
			local common = import("Common");
			local config = neatJSON(config, {
				lua = true
			});
			local windowsList = (function()
				local indent = string.rep(" ", 8);
				local list = "";
				for index, window in ipairs(registeredWindows) do
					local _internal0;
					if (list=="") then
						_internal0 = "";
					else
						_internal0 = indent;
					end
					local _internal1;
					if (index==#registeredWindows) then
						_internal1 = "";
					else
						_internal1 = "\n";
					end
					list = list .. string.format("%s[%d] %s (%s)%s", _internal0, index, window.id, window.description, _internal1);
				end
				return list;
			end)();
			return string.format([[
Date:   %s
Clock:  %d

System information:
    OS:             %s
    Architecture:   %s
    Resolution:     %d x %d
    Wine prefix:    %s

Script information:
    Version:        %s
    Memory:         %d
    Package.cpath:  %s
    Package.path:   %s

User information:
    OOC nickname:   %s
    IC nickname:    %s
    ID:             %d
    Alogin status:  %s
    Ping:           %d
    Admin LVL:      %d

Spectator information:
    Status:         %s
    ID:             %d
    Nickname:       %s
    TextDraw ID:    %s

GReport information:
    Window state: %s
    Dialog:
        ID:     %d
        State:  %s
    Player:
        Active:     %s
        Nickname:   %s
        ID:         %d
        Context:    %s

ImGui information:
    Cursor Status:  %s
    Moving windows: %s
    Registered windows:
        %s

Logs:
    MoonLoader:
%s
    SAMPFUNCS:
%s
    CLEO:
%s

Configuration: %s
    ]], os.date(), os.clock(), jit.os, jit.arch, select(1, getScreenResolution()), select(2, getScreenResolution()), os.getenv("WINEPREFIX"), "1.3.1", collectgarbage("count"), package.cpath, package.path, user:getOOCNickname(), user:getNickname(), user:getId(), user:getAloginStatus(), user:getPing(), user:getAdminLvl(), spectator.status, spectator.id, spectator.nickname, spectator.textDrawId, greport.window.state, greport.dialog.id, greport.dialog.state, greport.player.active, greport.player.nickname, greport.player.id, greport.player.context, imguiAssets:getCursorStatus(), movableWindows:isChangingWindowsPositions(), windowsList, common:readFileContent(getWorkingDirectory().."\\moonloader.log"), common:readFileContent(getGameDirectory().."\\SAMPFUNCS\\SAMPFUNCS.log"), common:readFileContent(getGameDirectory().."\\cleo.log"), config);
		end;
		function assets:messageBox(text, title, style)
			local hwnd = ffi.C.GetDesktopWindow();
			local _internal0;
			if (style) then
				_internal0 = (style+0x50000);
			else
				_internal0 = 0x50000;
			end
			ffi.C.MessageBoxA(hwnd, u8:decode(text), u8:decode(title), _internal0);
		end
		function assets:changeWallhackState(state)
			local pointer = sampGetServerSettingsPtr();
			local _internal0;
			if (state) then
				_internal0 = 0x7D0;
			else
				_internal0 = baseNameTagsDistance;
			end
			memory.setfloat(pointer+39, _internal0);
			local _internal1;
			if (state) then
				_internal1 = 0;
			else
				_internal1 = 1;
			end
			memory.setint8(pointer+47, _internal1);
		end
		function assets:workInBackground(state)
			if state then
				memory.setuint8(7634870, 1, false);
				memory.setuint8(7635034, 1, false);
				memory.fill(7623723, 144, 8, false);
				memory.fill(5499528, 144, 6, false);
			else
				memory.setuint8(7634870, 0, false);
				memory.setuint8(7635034, 0, false);
				memory.hex2bin("0F 84 7B 01 00 00", 7623723, 8);
				memory.hex2bin("50 51 FF 15 00 83 85 00", 5499528, 6);
			end
		end
		return assets;
	end,
	["imgui.windows.TestWindow"] = function(...)
		local windows = import("imgui.Windows");
		local animations = import("imgui.Animations");
		local HotKey = import("imgui.HotKey");
	end,
	["imgui.windows.CommandRequester"] = function(...)
		local imguiAssets = import("imgui.Assets");
		local StyleChanger = import("imgui.StyleChanger");
		local HotKey = import("imgui.HotKey");
		local style = import("imgui.Style");
		local admins = import("game.Admins");
		local config = import("Config");
		local common = import("Common");
		local commandRequester = import("CommandRequester");
		local sizeX, sizeY = getScreenResolution();
		local hotKey = HotKey:new("imgui.windows.CommandRequester", {
			VK_LSHIFT, 
			VK_Z
		}, "Принять форму"):registerCallback(commandRequester.hotKeyCallback);
		style:registerWindow("imgui.windows.CommandRequester", "Полоса оповещения админской формы");
		imgui.OnFrame(function()
			return commandRequester.states.frame;
		end, function(self)
			self.HideCursor = imguiAssets:getCursorStatus();
			self.flags = imgui.WindowFlags.NoMove+imgui.WindowFlags.NoTitleBar+imgui.WindowFlags.NoResize;
			self.style = StyleChanger:new({
				WindowBg = common:convertHex2ImVec4(string.format("%02X%02X%02X", imgui.GetStyle().Colors[(imgui.Col.WindowBg)].x*255, imgui.GetStyle().Colors[(imgui.Col.WindowBg)].y*255, imgui.GetStyle().Colors[(imgui.Col.WindowBg)].z*255).."80"), 
				WindowRounding = 0, 
				FrameRounding = 0, 
				WindowBorderSize = 0, 
				WindowPadding = imgui.ImVec2(sizeX/10, 10)
			});
			self.admin = admins:getAdminById(commandRequester.current.id.from);
			self.command = "/"..commandRequester.current.command.splitted.name.." "..commandRequester.current.command.splitted.args;
			self.timer = string.format("Это окно исчезнет через %.1f секунд", 5-(os.clock()-commandRequester.current.clock));
			if self.admin then
				self.style:apply();
				style:beginWindowStyleChangeable("imgui.windows.CommandRequester");
				imgui.SetNextWindowPos(imgui.ImVec2(0, config.root.additions.commandRequester.windowPositionY-36));
				imgui.SetNextWindowSize(imgui.ImVec2(sizeX, 36));
				imgui.Begin("imgui.windows.CommandRequester", nil, self.flags);
				imgui.PushFont(regular12);
				imgui.Text("Пришла форма от %s · Принять - %s", self.admin.nickname.ooc, tostring(hotKey));
				imgui.SameLine(sizeX/2-bold10:CalcTextSizeA(bold10.FontSize, math.huge, 0.0, self.command).x/2);
				imgui.PushFont(bold10);
				imgui.Text(self.command);
				imgui.PopFont();
				imgui.SameLine(sizeX-imgui.GetStyle().WindowPadding.x-imgui.CalcTextSize(self.timer).x);
				imgui.Text(self.timer);
				imgui.PopFont();
				imgui.End();
				style:endWindowStyleChangeable("imgui.windows.CommandRequester");
				self.style:reset();
			end
		end);
	end,
	["imgui.windows.AdminList"] = function(...)
		local windows = import("imgui.Windows");
		local imguiAssets = import("imgui.Assets");
		local StyleChanger = import("imgui.StyleChanger");
		local admins = import("game.Admins");
		local user = import("game.User");
		local assets = import("Assets");
		local config = import("Config");
		local icons = import("Icons");
		local common = import("Common");
		local notify = import("Notifications");
		local algorithm = import("Algorithm");
		local function getAdmins()
			if config.root.windows.adminList.sortByLvl then
				local adminList = assets:copyTable(admins);
				algorithm:bubbleSortByKey(adminList, "lvl");
				return adminList;
			else
				return admins;
			end
		end
		windows:new("imgui.windows.AdminList", {
			description = "Список администраторов в сети", 
			type = MV_DEFAULT, 
			size = {
				x = 0, 
				y = 0
			}, 
			condition = function()
				return config.root.windows.adminList.use and user:getAloginStatus();
			end, 
			initialize = {
				windowStyle = StyleChanger:new({
					WindowBorderSize = 0, 
					WindowBg = imgui.ImVec4(0, 0, 0, 0), 
					ScrollbarSize = 5, 
					ScrollbarBg = imgui.ImVec4(0, 0, 0, 0)
				})
			}
		}, function(self)
			self.flags = imgui.WindowFlags.NoMove+imgui.WindowFlags.NoTitleBar+imgui.WindowFlags.NoResize+imgui.WindowFlags.AlwaysAutoResize;
			self.size.y = config.root.windows.adminList.countForScrollbar*20;
			self.var.windowStyle:apply();
			self:begin(self.id, function()
				for _, admin in ipairs(getAdmins()) do
					imgui.BeginGroup();
					local pos = imgui.GetCursorPos();
					local _internal0;
					if (config.root.windows.adminList.showAdminLvl) then
						_internal0 = string.format("[LVL: %d] %s[%d]", admin.lvl, admin.nickname.ooc, admin.id);
					else
						_internal0 = string.format("%s[%d]", admin.nickname.ooc, admin.id);
					end
					local text = _internal0;
					local _internal1 = config.root.windows.adminList.textAlignMode;
					if (_internal1 == ALIGN_CENTER) then
						_internal1 = self.size.x/2-imgui.CalcTextSize(text).x/2;
					else
						if (_internal1 == ALIGN_RIGHT) then
							_internal1 = self.size.x-imgui.CalcTextSize(text).x-10;
						else
							_internal1 = pos.x;
						end
					end
					pos.x = _internal1;
					imgui.SetCursorPos(pos);
					local _internal2;
					if (config.root.windows.adminList.textColorBasedOnClist) then
						_internal2 = common:convertHex2ImVec4(string.format("%06X", bit.band(sampGetPlayerColor(admin.id), 0xFFFFFF)));
					else
						_internal2 = nil;
					end
					local isClicked, isHovered = imguiAssets:addStrokedText(text, config.root.windows.adminList.strokeSize, _internal2);
					if self.size.x<imgui.GetItemRectSize().x then
						self.size.x = imgui.GetItemRectSize().x+20;
					end
					if isHovered then
						imgui.GetForegroundDrawList():AddLine(imgui.ImVec2(imgui.GetItemRectMin().x, imgui.GetItemRectMax().y), imgui.GetItemRectMax(), -1, 2);
					end
					if isClicked and setClipboardText(admin.nickname.ooc) then
						notify:send({
							icon = icons.ICON_KEYBOARD, 
							title = "Никнейм скопирован", 
							text = "Успешно скопирован OOC никнейм у администратора "..admin.nickname.ooc.."!", 
							duration = 3, 
							buttons = {
								first = {
									name = "Закрыть", 
									call = function(close)
										close();
									end
								}, 
								second = {
									name = "Упомянуть", 
									call = function()
										sampSetChatInputEnabled(true);
										sampSetChatInputText("/a @"..admin.nickname.ooc.." ");
									end
								}
							}
						});
					end
					imgui.EndGroup();
				end
			end, self.flags);
			self.var.windowStyle:reset();
		end);
	end,
	["imgui.windows.SpectatorKeys"] = function(...)
		local window = import("imgui.Windows");
		local imguiAssets = import("imgui.Assets");
		local animations = import("imgui.Animations");
		local StyleChanger = import("imgui.StyleChanger");
		local spectator = import("game.Spectator");
		local config = import("Config");
		local icons = import("Icons");
		local common = import("Common");
		local sizeX, sizeY = getScreenResolution();
		window:new("imgui.windows.SpectatorKeys", {
			description = "Нажатые клавиши игрока", 
			type = MV_ONLY_IN_SPECTATOR, 
			condition = function()
				return config.root.windows.spectatorKeys.use;
			end, 
			size = {
				x = 0, 
				y = 0
			}, 
			defaultPos = {
				x = sizeX/2.346, 
				y = sizeY/1.242
			}, 
			initialize = {
				style = StyleChanger:new({
					WindowBg = "22222200", 
					WindowBorderSize = 0
				})
			}
		}, function(self)
			self.var.style:apply();
			self:begin(self.id, function()
				local result, ped = spectator:getHandle();
				if self.isChangingWindowsPositions then
					result, ped = true, PLAYER_PED;
				end
				if result then
					for platform, data in pairs(({
						pc = {
							[(SYNC_KEYS_PLAYER)] = {
								"lmb", 
								"w", 
								"rmb", 
								{
									"shift", 
									imgui.ImVec2(55-imgui.GetStyle().ItemSpacing.x/2, 35)
								}, 
								{
									"alt", 
									imgui.ImVec2(55-imgui.GetStyle().ItemSpacing.x/2, 35)
								}, 
								"f", 
								"NewLine", 
								"a", 
								"s", 
								"d", 
								{
									"space", 
									imgui.ImVec2(110, 35)
								}, 
								"c"
							}, 
							[(SYNC_KEYS_VEHICLE)] = {
								"q", 
								"w", 
								"e", 
								{
									"up", 
									imgui.ImVec2(50, 35)
								}, 
								{
									"ctrl", 
									imgui.ImVec2(55-imgui.GetStyle().ItemSpacing.x/2, 35)
								}, 
								{
									"alt", 
									imgui.ImVec2(55-imgui.GetStyle().ItemSpacing.x/2, 35)
								}, 
								"f", 
								"NewLine", 
								"a", 
								"s", 
								"d", 
								{
									"down", 
									imgui.ImVec2(50, 35)
								}, 
								{
									"space", 
									imgui.ImVec2(110, 35)
								}, 
								"h"
							}
						}, 
						mobile = {
							[(SYNC_KEYS_PLAYER)] = {
								{
									"hit", 
									imgui.ImVec2(55-imgui.GetStyle().ItemSpacing.x/2, 35)
								}, 
								{
									"aim", 
									imgui.ImVec2(55-imgui.GetStyle().ItemSpacing.x/2, 35)
								}, 
								"f", 
								"NewLine", 
								{
									"jump / run", 
									imgui.ImVec2(110, 35)
								}, 
								"alt"
							}, 
							[(SYNC_KEYS_VEHICLE)] = {
								{
									"forward", 
									imgui.ImVec2(90, 35)
								}, 
								{
									"signal", 
									imgui.ImVec2(65, 35)
								}, 
								"2", 
								"NewLine", 
								{
									"backward", 
									imgui.ImVec2(90, 35)
								}, 
								{
									"braking", 
									imgui.ImVec2(65, 35)
								}, 
								"f"
							}
						}
					})) do
						local _internal0;
						if (self.isChangingWindowsPositions) then
							_internal0 = "PC";
						else
							_internal0 = spectator:platformToString();
						end
						if platform==string.lower(_internal0) then
							local _internal0;
							if (isCharInAnyCar(ped)) then
								_internal0 = SYNC_KEYS_VEHICLE;
							else
								_internal0 = SYNC_KEYS_PLAYER;
							end
							local currentSyncType = _internal0;
							local _internal1;
							if (self.isChangingWindowsPositions) then
								_internal1 = PLATFORM_PC;
							else
								_internal1 = spectator.platform;
							end
							local platform = _internal1;
							local id = string.format("##%s.%d", self.id, platform);
							if platform==PLATFORM_ANDROID then
								imgui.Dummy(imgui.ImVec2(75, 75));
								local spacing = imgui.GetStyle().ItemSpacing;
								local padding = imgui.GetStyle().WindowPadding;
								local new = spectator.keys[(platform)][(SYNC_KEYS_JOY_STICK)].new;
								local old = spectator.keys[(platform)][(SYNC_KEYS_JOY_STICK)].old;
								local clock = spectator.keys[(platform)][(SYNC_KEYS_JOY_STICK)].clock;
								local dl = imgui.GetWindowDrawList();
								local c = imgui.ImVec2(self.pos.x+37+padding.x, self.pos.y+42);
								local color = imgui.GetStyle().Colors[(imgui.Col.Button)];
								local bgColor = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(color.x, color.y, color.z, 0.3));
								local itColor = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(color.x, color.y, color.z, color.w));
								dl:AddCircleFilled(c, 37, bgColor, 48);
								dl:AddCircle(c, 37, itColor, 48, 1);
								local oX = imguiAssets:bringFloatTo((old.x/100)*13.5, (new.x/100)*13.5, clock, 0.1);
								local oY = imguiAssets:bringFloatTo((old.y/100)*13.5, (new.y/100)*13.5, clock, 0.1);
								dl:AddCircleFilled(imgui.ImVec2(c.x+oX, c.y+oY), 10, itColor, 0xF);
								imgui.SameLine();
							end
							imgui.BeginGroup();
							imgui.PushFont(regular9);
							for index, item in ipairs(data[(currentSyncType)]) do
								if type(item)=="string" then
									if item=="NewLine" then
										imgui.NewLine();
									else
										animations:keyCap(string.upper(item)..id, spectator.keys[(platform)][(currentSyncType)][(item)], imgui.ImVec2(35, 35));
										imgui.SameLine();
									end
								elseif type(item)=="table" then
									animations:keyCap(string.upper(item[(1)])..id, spectator.keys[(platform)][(currentSyncType)][(item[(1)])], item[(2)]);
									imgui.SameLine();
								end
							end
							imgui.PopFont();
							imgui.EndGroup();
						end
					end
				end
			end);
			self.var.style:reset();
		end);
	end,
	["imgui.windows.SpectatorActions"] = function(...)
		local windows = import("imgui.Windows");
		local imguiAssets = import("imgui.Assets");
		local animations = import("imgui.Animations");
		local StyleChanger = import("imgui.StyleChanger");
		local spectator = import("game.Spectator");
		local user = import("game.User");
		local binder = import("game.Binder");
		local config = import("Config");
		local notify = import("Notifications");
		local icons = import("Icons");
		local sizeX, sizeY = getScreenResolution();
		windows:new("imgui.windows.SpectatorActions", {
			description = "Окно действий в режиме наблюдения", 
			type = MV_ONLY_IN_SPECTATOR, 
			condition = function()
				return config.root.windows.spectatorActions.use;
			end, 
			size = {
				x = 700, 
				y = config.root.windows.spectatorActions.windowSizeY
			}, 
			defaultPos = {
				x = sizeX/2-350, 
				y = sizeY/1.128
			}, 
			initialize = {
				middleButtons = StyleChanger:new({
					FrameRounding = 0, 
					ItemSpacing = imgui.ImVec2(2, 0)
				})
			}
		}, function(self)
			self.specInfo = spectator:getInformation();
			self.size.y = config.root.windows.spectatorActions.windowSizeY;
			self.centeredText = string.format("Скорость: %s / %s · Оружие: %s · Здоровье: %s · Пинг: %d", self.specInfo.moveSpeed.current, self.specInfo.moveSpeed.max, self.specInfo.weapon, self.specInfo.health, self.specInfo.ping);
			self:begin(self.id, function()
				imgui.SetScrollY(0);
				imgui.BeginGroup();
				imgui.PushStyleVarVec2(imgui.StyleVar.ItemSpacing, imgui.ImVec2(0, 0));
				imguiAssets:textWithFont(string.gsub(spectator.nickname or "", "_", " "), bold10);
				imguiAssets:setPreviousItemAbleToCopy(spectator.nickname or "", "Никнейм скопирован.", string.format("Успешно скопирован никнейм: %s", spectator.nickname));
				imgui.SameLine();
				imguiAssets:textWithFont(string.format("[%d]", spectator.id), bold10);
				imguiAssets:setPreviousItemAbleToCopy(spectator.id, "Айди скопирован.", string.format("Успешно скопирован айди: %d", spectator.id));
				imgui.PopStyleVar();
				imguiAssets:textWithFont(self.centeredText, regular9, imgui.ImVec2((self.size.x-regular9:CalcTextSizeA(regular9.FontSize, math.huge, 0.0, self.centeredText).x)/2, 6.5));
				imguiAssets:textWithFont(spectator:platformToString(), bold10, imgui.ImVec2(self.size.x-bold10:CalcTextSizeA(bold10.FontSize, math.huge, 0.0, spectator:platformToString()).x-10, 5));
				imgui.EndGroup();
				imgui.BeginGroup();
				local maxItems = 2;
				for _, item in ipairs(config.root.windows.spectatorActions.buttons) do
					if item[(3)] then
						maxItems = maxItems + 1;
					end
				end
				local hasTallMiddleItem = (maxItems-2)%2~=0;
				local _internal0;
				if (hasTallMiddleItem) then
					_internal0 = 1;
				else
					_internal0 = 0;
				end
				local maxItemsPerLine = math.floor(maxItems/2)+(_internal0);
				local itemWidth = math.floor(self.size.x/maxItemsPerLine)-1;
				local itemHeight = self.size.y-imgui.GetCursorPos().y-imgui.GetStyle().WindowPadding.y;
				local cornerButtonSize = imgui.ImVec2(math.floor((itemWidth-12)/2), itemHeight);
				local renderCornerButton = function(text, id, action, rounding)
					imgui.BeginGroup();
					imgui.PushFont(icon);
					local pos = imgui.GetCursorPos();
					local id = string.format("##%s.%s", self.id, id);
					if animations:button(id, cornerButtonSize, rounding) and not self.isChangingWindowsPositions then
						sampSendMenuSelectRow(action);
					end
					imgui.SetCursorPos(pos+imgui.ImVec2(0, 6)+(cornerButtonSize-imgui.CalcTextSize(text))*0.5);
					imgui.Text(text);
					imgui.PopFont();
					imgui.EndGroup();
				end;
				renderCornerButton(icons.ICON_CHEVRON_LEFT, "buttonGoToPreviousPlayer", SPECTATOR_MENU_BACK, 5);
				imgui.SameLine(nil, 2);
				imgui.BeginGroup();
				imgui.PushStyleVarFloat(imgui.StyleVar.FrameRounding, 0);
				imgui.PushFont(regular9);
				for index, item in ipairs(config.root.windows.spectatorActions.buttons) do
					if item[(3)] then
						local label = string.format("%s##%s.buttonIndex-%d", item[(1)], self.id, index);
						local _internal0;
						if (hasTallMiddleItem and index==(maxItems-2)) then
							_internal0 = itemHeight;
						else
							_internal0 = (itemHeight/2-1);
						end
						local height = _internal0;
						if height==itemHeight then
							imgui.SameLine(nil, 0);
							imgui.SetCursorPosY(self.size.y-height-5);
						end
						if animations:button(label, imgui.ImVec2(itemWidth, height)) and not self.isChangingWindowsPositions then
							if type(item[(2)])=="number" then
								sampSendMenuSelectRow(item[(2)]);
							elseif type(item[(2)])=="string" then
								binder:sendString(self.id, item[(2)], {
									spectator.id
								});
							end
						end
						imgui.SameLine(nil, 2);
						local _internal1;
						if (hasTallMiddleItem) then
							_internal1 = 2;
						else
							_internal1 = 1;
						end
						if index%(maxItemsPerLine-(_internal1))==0 then
							imgui.NewLine();
							imgui.SetCursorPosY(imgui.GetCursorPos().y-2);
						end
					end
				end
				imgui.PopFont();
				imgui.PopStyleVar();
				imgui.EndGroup();
				local _internal1;
				if (hasTallMiddleItem) then
					_internal1 = 2;
				else
					_internal1 = 0;
				end
				imgui.SameLine(nil, _internal1);
				renderCornerButton(icons.ICON_CHEVRON_RIGHT, "buttonGoToNextPlayer", SPECTATOR_MENU_NEXT, 10);
				imgui.EndGroup();
			end);
		end);
	end,
	["imgui.windows.PlayerChecker"] = function(...)
		local window = import("imgui.Windows");
		local imguiAssets = import("imgui.Assets");
		local animations = import("imgui.Animations");
		local StyleChanger = import("imgui.StyleChanger");
		local config = import("Config");
		local assets = import("Assets");
		local common = import("Common");
		local user = import("game.User");
		local sampPlayer = import("game.samp.Player");
		local randomPlayers = {		};
		local function getPlayers(isMovingWindows)
			if isMovingWindows then
				math.randomseed(os.clock());
				if #randomPlayers~=5 then
					local _internal0;
					if (math.random(1, 100)>=80) then
						_internal0 = assets.randomStrings[(math.random(#assets.randomStrings))];
					else
						_internal0 = nil;
					end
					table.insert(randomPlayers, {
						nickname = assets.randomICNicknames[(math.random(#assets.randomICNicknames))], 
						commentary = _internal0
					});
				end
				return randomPlayers;
			else
				return config.root.windows.playerChecker.players;
			end
		end
		window:new("imgui.windows.PlayerChecker", {
			description = "Чекер игроков", 
			type = MV_DEFAULT, 
			condition = function()
				return config.root.windows.playerChecker.use and isSampAvailable() and user:getAloginStatus();
			end, 
			size = {
				x = 0, 
				y = 0
			}, 
			defaultPos = WIN_DEFAULT_POS_CENTER, 
			initialize = {
				popupInformation = {				}, 
				windowStyle = StyleChanger:new({
					WindowBorderSize = 0, 
					WindowBg = imgui.ImVec4(0, 0, 0, 0), 
					ItemSpacing = imgui.ImVec2(0, 5)
				}), 
				popupStyle = StyleChanger:new({
					WindowPadding = imgui.ImVec2(5, 5), 
					PopupBg = "222222", 
					ItemSpacing = imgui.ImVec2(0, 1)
				}), 
				popupCommentaryStyle = StyleChanger:new({
					FrameBg = "222222", 
					FrameBorderSize = 0
				})
			}
		}, function(self)
			self.var.windowStyle:apply();
			self:begin(self.id, function()
				for index, player in ipairs(getPlayers(self.isChangingWindowsPositions)) do
					local id = sampPlayer:getIdByNickname(player.nickname);
					local playerConnected = id~=nil;
					local strokeSize = config.root.windows.playerChecker.strokeSize;
					local textColor = imgui.GetStyle().Colors[(imgui.Col.Text)];
					if playerConnected then
						textColor = common:convertHex2ImVec4(string.format("%06X", bit.band(sampGetPlayerColor(id), 0xFFFFFF)));
					end
					local align = imgui.GetCursorPos().x;
					do
						do
							local it = config.root.windows.playerChecker;
							if it ~= nil then
								local textSize = imgui.ImVec2(0, 0);
								if it.displayOfflinePlayers then
									local _internal0;
									if (playerConnected) then
										_internal0 = "[ONLINE] ";
									else
										_internal0 = "[OFFLINE] ";
									end
									textSize = imgui.CalcTextSize(_internal0);
								end
								textSize = textSize + imgui.CalcTextSize(player.nickname);
								if playerConnected then
									textSize = textSize + imgui.CalcTextSize("["..id.."]");
								end
								local _internal0 = it.textAlignMode;
								if (_internal0 == ALIGN_CENTER) then
									_internal0 = self.size.x/2-textSize.x/2;
								else
									if (_internal0 == ALIGN_RIGHT) then
										_internal0 = self.size.x-textSize.x-(5+strokeSize);
									else
										_internal0 = align;
									end
								end
								align = _internal0;
							end
						end
					end
					imgui.SetCursorPosX(align);
					imgui.BeginGroup();
					if config.root.windows.playerChecker.displayOfflinePlayers then
						local _internal0;
						if (playerConnected) then
							_internal0 = "[ONLINE] ";
						else
							_internal0 = "[OFFLINE] ";
						end
						local _internal1;
						if (playerConnected) then
							_internal1 = "8DFF85";
						else
							_internal1 = "FF8585";
						end
						imguiAssets:addStrokedText(_internal0, strokeSize, common:convertHex2ImVec4(_internal1));
						imgui.SameLine();
					end
					if config.root.windows.playerChecker.displayOfflinePlayers or playerConnected then
						imguiAssets:addStrokedText(player.nickname, strokeSize, textColor);
						if playerConnected then
							imgui.SameLine();
							imguiAssets:addStrokedText("["..id.."]", strokeSize, textColor);
						end
					end
					imgui.EndGroup();
					if imgui.GetItemRectSize().x>self.size.x then
						self.size.x = imgui.GetItemRectSize().x+20;
					end
					if imgui.IsItemClicked() then
						imgui.OpenPopup("PlayerChecker.popup");
						self.var.popupInformation = {
							nickname = player.nickname, 
							id = id, 
							commentary = player.commentary, 
							isConnected = playerConnected, 
							index = index
						};
					end
					if imgui.IsItemHovered() then
						imgui.GetWindowDrawList():AddLine(imgui.ImVec2(imgui.GetItemRectMin().x, imgui.GetItemRectMax().y), imgui.GetItemRectMax(), -1, 2);
					end
				end
				self.var.popupStyle:apply();
				if imgui.BeginPopup("PlayerChecker.popup", self.flags) then
					do
						local this = self.var.popupInformation;
						if this ~= nil then
							local _internal0;
							if (this.isConnected) then
								_internal0 = "В сети";
							else
								_internal0 = "Оффлайн";
							end
							local _internal1;
							if (this.isConnected) then
								_internal1 = "8DFF85";
							else
								_internal1 = "FF8585";
							end
							for index, item in ipairs(({
								{
									name = "Никнейм:", 
									value = this.nickname
								}, 
								{
									name = "Статус:", 
									value = _internal0, 
									color = common:convertHex2ImVec4(_internal1)
								}
							})) do
								if item.value then
									imguiAssets:textWithFont(item.name, bold10);
									imgui.SameLine(imgui.CalcTextSize(item.name).x+7);
									imgui.SetCursorPosY(imgui.GetCursorPos().y+2);
									imguiAssets:textWithFont(item.value, regular9, nil, item.color);
								end
							end
							if this.commentary then
								if not this.imguiCommentary then
									this.imguiCommentary = imgui.new.char[(65535)](this.commentary);
								end
								imguiAssets:textWithFont("Комментарий:", bold10);
								imgui.SameLine();
								imgui.SetCursorPosY(imgui.GetCursorPos().y-3);
								self.var.popupCommentaryStyle:apply();
								imgui.PushFont(regular9);
								if this.focusCommentary then
									imgui.SetKeyboardFocusHere();
									this.focusCommentary = false;
								end
								if imgui.InputText("##PlayerChecker.commentary", this.imguiCommentary, ffi.sizeof(this.imguiCommentary), not this.changingCommentary and imgui.InputTextFlags.ReadOnly) then
									config.root.windows.playerChecker.players[((this.index))].commentary = ffi.string(this.imguiCommentary);
								end
								imgui.PopFont();
								self.var.popupCommentaryStyle:reset();
							end
							imgui.PushFont(regular9);
							local _internal2;
							if (this.commentary or this.isConnected) then
								_internal2 = 3;
							else
								_internal2 = nil;
							end
							if animations:button("Удалить##PlayerChecker.popup.removeButton", imgui.ImVec2(imgui.GetWindowWidth()-10, 25), _internal2) then
								table.remove(config.root.windows.playerChecker.players, this.index);
								imgui.CloseCurrentPopup();
							end
							if this.commentary then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(imgui.GetItemRectMin().x, imgui.GetItemRectMax().y-4), imgui.GetItemRectMax()+imgui.ImVec2(0, 6), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[(imgui.Col.Button)]));
								local _internal0;
								if (this.isConnected) then
									_internal0 = 0;
								else
									_internal0 = 12;
								end
								if animations:button("Изменить комментарий##PlayerChecker.popup.changeCommentaryButton", imgui.ImVec2(imgui.GetWindowWidth()-10, 25), _internal0) then
									this.changingCommentary = true;
									this.focusCommentary = true;
								end
							end
							if this.isConnected then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(imgui.GetItemRectMin().x, imgui.GetItemRectMax().y-4), imgui.GetItemRectMax()+imgui.ImVec2(0, 6), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[(imgui.Col.Button)]));
								if animations:button("Следить##PlayerChecker.popup.spectateButton", imgui.ImVec2(imgui.GetWindowWidth()-10, 25), 12) then
									sampSendChat("/sp "..this.id);
									imgui.CloseCurrentPopup();
								end
							end
							imgui.PopFont();
						end
					end
				end
				imgui.EndPopup();
				self.var.popupStyle:reset();
			end);
			self.var.windowStyle:reset();
		end);
	end,
	["game.ServerTables"] = function(...)
		return {
			weaponDamage = {
				{
					"Оружие", 
					"Калибр", 
					"Ноги", 
					"Руки", 
					"Пах", 
					"Торс", 
					"Голова", 
					"Эффект"
				}, 
				{
					"Colt 1911", 
					"9mm", 
					"15", 
					"15", 
					"30", 
					"35", 
					"60", 
					"Кровотечение 30%"
				}, 
				{
					"SD Pistol", 
					"9mm", 
					"20", 
					"20", 
					"35", 
					"40", 
					"60", 
					"Кровотечение 40%"
				}, 
				{
					"Desert Eagle", 
					".50 ACTION", 
					"20", 
					"20", 
					"40", 
					"60", 
					"60", 
					"Кровотечение 30%"
				}, 
				{
					"Shotgun", 
					"12mm", 
					"20", 
					"20", 
					"40", 
					"60", 
					"100", 
					"Кровотечение 60%"
				}, 
				{
					"Sawnoff Shotgun", 
					"12mm", 
					"15", 
					"15", 
					"30", 
					"35", 
					"100", 
					"Кровотечение 60%"
				}, 
				{
					"UZI", 
					"9.19mm", 
					"15", 
					"15", 
					"30", 
					"35", 
					"100", 
					"Кровотечение 10%"
				}, 
				{
					"MP5", 
					"9.19mm", 
					"15", 
					"15", 
					"30", 
					"35", 
					"100", 
					"Кровотечение 10%"
				}, 
				{
					"AK-47", 
					"7.62mm", 
					"20", 
					"20", 
					"50", 
					"50", 
					"80", 
					"Кровотечение 10%"
				}, 
				{
					"M4", 
					"5.56mm ", 
					"20", 
					"20", 
					"50", 
					"50", 
					"80", 
					"Кровотечение 10%"
				}, 
				{
					"TEC-9", 
					"9.19mm", 
					"15", 
					"15", 
					"30", 
					"35", 
					"100", 
					"Кровотечение 10%"
				}, 
				{
					"Country Rifle", 
					"7.62mm", 
					"50", 
					"50", 
					"50", 
					"70", 
					"90", 
					"Кровотечение 30%"
				}, 
				{
					"Sniper Rifle", 
					"7.62mm", 
					"60", 
					"60", 
					"60", 
					"70", 
					"100", 
					"Кровотечение 30%"
				}, 
				{
					"Spraycan", 
					"", 
					"0", 
					"0", 
					"0", 
					"0", 
					"0", 
					"Нокаут 2%"
				}, 
				{
					"Fire Ext.", 
					"", 
					"0", 
					"0", 
					"0", 
					"0", 
					"0", 
					"Нокаут 2%"
				}, 
				{
					"Кулак", 
					"", 
					"5", 
					"5", 
					"8", 
					"10", 
					"15", 
					"Нокаут 1%"
				}, 
				{
					"Кастет", 
					"", 
					"10", 
					"10", 
					"12", 
					"15", 
					"20", 
					"Нокаут 2% + Кровотечение 10%"
				}, 
				{
					"Клюшка", 
					"", 
					"10", 
					"10", 
					"12", 
					"30", 
					"35", 
					"Нокаут 5%"
				}, 
				{
					"Полиц. дубинка", 
					"", 
					"10", 
					"10", 
					"12", 
					"30", 
					"35", 
					"Нокаут 4%"
				}, 
				{
					"Нож", 
					"", 
					"15", 
					"15", 
					"20", 
					"35", 
					"40", 
					"Кровотечение 50%"
				}, 
				{
					"Бита", 
					"", 
					"15", 
					"15", 
					"20", 
					"35", 
					"40", 
					"Нокаут 10%"
				}, 
				{
					"Лопата", 
					"", 
					"15", 
					"15", 
					"20", 
					"35", 
					"40", 
					"Нокаут 10% + Кровотечение 30%"
				}, 
				{
					"Кий", 
					"", 
					"15", 
					"15", 
					"20", 
					"35", 
					"40", 
					"Нокаут 10%"
				}, 
				{
					"Катана", 
					"", 
					"20", 
					"20", 
					"30", 
					"40", 
					"50", 
					"Кровотечение 60%"
				}, 
				{
					"Бензопила", 
					"", 
					"20", 
					"20", 
					"30", 
					"40", 
					"50", 
					"Кровотечение 90%"
				}, 
				{
					"Розовый дилдо", 
					"", 
					"5", 
					"5", 
					"8", 
					"10", 
					"15", 
					"Нокаут 1%"
				}, 
				{
					"Мал. дилдо", 
					"", 
					"5", 
					"5", 
					"8", 
					"10", 
					"15", 
					"Нокаут 1%"
				}, 
				{
					"Вибратор", 
					"", 
					"5", 
					"5", 
					"8", 
					"10", 
					"15", 
					"Нокаут 1%"
				}, 
				{
					"Сильвер Вибратор", 
					"", 
					"5", 
					"5", 
					"8", 
					"10", 
					"15", 
					"Нокаут 1%"
				}, 
				{
					"Цветы", 
					"", 
					"0", 
					"0", 
					"0", 
					"0", 
					"0", 
					""
				}, 
				{
					"Трость", 
					"", 
					"0", 
					"0", 
					"0", 
					"0", 
					"0", 
					""
				}, 
				{
					"Граната", 
					"", 
					"0", 
					"0", 
					"0", 
					"0", 
					"0", 
					""
				}
			}, 
			prices = {
				{
					"Автомобили", 
					{
						"Sadler", 
						"2500$", 
						"Perenniel", 
						"4000$", 
						"Tampa", 
						"4000$", 
						"Walton", 
						"4000$", 
						"Regina", 
						"4500$", 
						"Nebula", 
						"4950$", 
						"Hustler", 
						"5000$", 
						"Manana", 
						"5000$", 
						"Picador", 
						"5500$", 
						"Virgo", 
						"5950$", 
						"Previon", 
						"6000$", 
						"Majestic", 
						"6438$", 
						"Rumpo", 
						"6500$", 
						"Solair", 
						"6500$", 
						"Topfunvan", 
						"6500$", 
						"Bravura", 
						"6750$", 
						"Esperanto", 
						"7000$", 
						"Clover", 
						"7000$", 
						"Moonbeam", 
						"7500$", 
						"Voodoo", 
						"7500$", 
						"Broadway", 
						"7500$", 
						"Hermes", 
						"7500$", 
						"Camper", 
						"8000$", 
						"Buccaneer", 
						"8000$", 
						"Primo", 
						"8300$", 
						"Glendale", 
						"8400$", 
						"Pony", 
						"8500$", 
						"Remington", 
						"8500$", 
						"Sabre", 
						"8500$", 
						"Blade", 
						"8500$", 
						"Oceanic", 
						"9500$", 
						"Tornado", 
						"9500$", 
						"Greenwood", 
						"9800$", 
						"Fortune", 
						"10000$", 
						"Slamwan", 
						"10000$", 
						"Sunrise", 
						"11500$", 
						"Stallion", 
						"12500$", 
						"Savanna", 
						"14500$", 
						"Tahoma", 
						"17500$", 
						"Intruder", 
						"6500$", 
						"Emperor", 
						"7000$", 
						"Sentinel", 
						"7500$", 
						"Willard", 
						"8000$", 
						"Cadrona", 
						"8500$", 
						"Vincent", 
						"9000$", 
						"Merit", 
						"10000$", 
						"Admiral", 
						"10000$", 
						"Windsor", 
						"10500$", 
						"Bobcat", 
						"11500$", 
						"Blistacompact", 
						"11500$", 
						"Burrito", 
						"12500$", 
						"Premier", 
						"13000$", 
						"Elegant", 
						"13500$", 
						"Phoenix", 
						"13500$", 
						"Club", 
						"14000$", 
						"Alpha", 
						"14500$", 
						"Feltzer", 
						"14500$", 
						"Stafford", 
						"15000$", 
						"Mesa", 
						"16000$", 
						"Washington", 
						"17500$", 
						"Yosemite", 
						"17500$", 
						"Uranus", 
						"17500$", 
						"Rancher", 
						"18000$", 
						"Euros", 
						"19000$", 
						"Landstalker", 
						"20000$", 
						"Jester", 
						"20000$", 
						"Flash", 
						"20000$", 
						"Stratum", 
						"23000$", 
						"Sultan", 
						"25000$", 
						"Elegy", 
						"27500$", 
						"Huntley", 
						"27500$", 
						"Comet", 
						"28000$", 
						"Hotknife", 
						"27500$", 
						"ZR-350", 
						"40000$", 
						"Buffalo", 
						"75000$", 
						"Banshee", 
						"215000$", 
						"SuperGT", 
						"250000$", 
						"Cheetah", 
						"575000$", 
						"Turismo", 
						"625000$", 
						"Infernus", 
						"725000$", 
						"Bullet", 
						"745000$"
					}
				}, 
				{
					"Мотоциклы/велосипеды", 
					{
						"BMX", 
						"250$", 
						"Bike", 
						"300$", 
						"Faggio", 
						"1000$", 
						"Mountainbike", 
						"1750$", 
						"Sanchez", 
						"4500$", 
						"PCJ-600", 
						"5000$", 
						"Quad", 
						"6000$", 
						"BF-400", 
						"7500$", 
						"FCR-900", 
						"7500$", 
						"Freeway", 
						"10000$", 
						"Wayfarer", 
						"10000$", 
						"NRG-500", 
						"31500$"
					}
				}, 
				{
					"Воздушный транспорт", 
					{
						"Maverick", 
						"$725.000", 
						"Sparrow", 
						"$470.000", 
						"Nevada", 
						"$2.100.000", 
						"Shamal", 
						"$1.300.000", 
						"Stuntplane", 
						"$710.000", 
						"Cropduster", 
						"$690.000", 
						"Skimmer", 
						"$500.000", 
						"Rustler", 
						"$420.000", 
						"Beagle", 
						"$200.000"
					}
				}, 
				{
					"Водный транспорт", 
					{
						"Jetmax", 
						"$900.000", 
						"Squallo", 
						"$830.000", 
						"Speeder", 
						"$260.000", 
						"Reefer", 
						"$100.000", 
						"Dinghy", 
						"$50.000", 
						"Marquis", 
						"$1.600.000", 
						"Tropic", 
						"$700.000"
					}
				}
			}
		};
	end,
	["imgui.windows.GReport"] = function(...)
		local style = import("imgui.Style");
		local imguiAssets = import("imgui.Assets");
		local animations = import("imgui.Animations");
		local greport = import("game.GReport");
		local config = import("Config");
		local common = import("Common");
		style:registerWindow("imgui.windows.GReport", "Окно /greport");
		local focusKeyboard = false;
		if greport.window.answerInput == nil then
			greport.window.answerInput = imgui.new.char[(65535)]();
		end
		addEventHandler("onWindowMessage", function(event, wparam, lparam)
			if (event==wm.WM_KEYDOWN or event==wm.WM_SYSKEYDOWN) and not imgui.GetIO().WantTextInput then
				if wparam==VK_ESCAPE and greport.window.state then
					greport.window:close();
					consumeWindowMessage(true, false);
					return;
				end
			end
		end);
		imgui.OnFrame(function()
			return greport.window.state and not isGamePaused() and config.root.windows.greport.use;
		end, function(self)
			self.flags = imgui.WindowFlags.NoTitleBar+imgui.WindowFlags.NoResize+imgui.WindowFlags.NoScrollbar;
			local sizeX, sizeY = getScreenResolution();
			if greport.window.closeAndOpenAnimation.clock then
				if greport.window.recentlyOpened then
					if os.clock()-greport.window.closeAndOpenAnimation.clock>=0.2 then
						greport.window.recentlyOpened = false;
						greport.window.closeAndOpenAnimation.clock = nil;
						focusKeyboard = true;
					else
						greport.window.closeAndOpenAnimation.alpha = imguiAssets:bringFloatTo(greport.window.closeAndOpenAnimation.alpha, 1, greport.window.closeAndOpenAnimation.clock, 0.2);
					end
				else
					if os.clock()-greport.window.closeAndOpenAnimation.clock>=0.2 then
						greport.window.state = false;
						greport.window.closeAndOpenAnimation.clock = nil;
						imgui.StrCopy(greport.window.answerInput, "");
					else
						greport.window.closeAndOpenAnimation.alpha = imguiAssets:bringFloatTo(greport.window.closeAndOpenAnimation.alpha, 0, greport.window.closeAndOpenAnimation.clock, 0.2);
					end
				end
			end
			if greport.window.closeAndOpenAnimation.alpha==0 then
				greport.window.recentlyOpened = true;
				greport.window.closeAndOpenAnimation.clock = os.clock();
			end
			if greport.player.active then
				greport.player.clock = os.clock();
			end
			imgui.SetNextWindowSize(imgui.ImVec2(600, 300));
			imgui.SetNextWindowPos(imgui.ImVec2(sizeX/2, sizeY/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5));
			imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, greport.window.closeAndOpenAnimation.alpha);
			style:beginWindowStyleChangeable("imgui.windows.GReport");
			imgui.Begin("imgui.windows.GReport", nil, self.flags);
			local itemFullWidth = imgui.GetWindowWidth()-imgui.GetStyle().WindowPadding.x*2;
			imgui.SetCursorPosY(imgui.GetStyle().WindowPadding.y+imgui.GetStyle().ChildBorderSize);
			imgui.BeginChild("imgui.windows.GReport.header", imgui.ImVec2(0, 100), true, self.flags);
			imguiAssets:textWithFont(string.gsub(greport.player.nickname, "_", " ").."["..greport.player.id.."]", bold14);
			imgui.SameLine(imgui.GetWindowWidth()-imgui.CalcTextSize("00:00").x*1.2);
			imguiAssets:textWithFont(greport.player:getActiveTime(), bold10);
			imgui.PushTextWrapPos(imgui.GetWindowWidth()-imgui.GetStyle().WindowPadding.x*2);
			imguiAssets:textWithFont(greport.player.context, regular12);
			imgui.EndChild();
			imgui.BeginGroup();
			imgui.PushFont(regular12);
			imgui.BeginGroup();
			imgui.SetNextItemWidth(itemFullWidth);
			if focusKeyboard then
				imgui.SetKeyboardFocusHere();
				focusKeyboard = false;
			end
			imgui.InputTextWithHint("##imgui.windows.GReport.greport.window.answerInput", "Ответ на репорт / причина блокировки репорта / причина удаления репорта", greport.window.answerInput, ffi.sizeof(greport.window.answerInput));
			animations:hint("Это поле не должно быть пустым.", function()
				return greport.window.noInputClock and (os.clock()-greport.window.noInputClock<=1) and #ffi.string(greport.window.answerInput)==0;
			end, nil, common:convertHex2ImVec4("E46876"));
			imgui.EndGroup();
			imgui.SetCursorPosY(imgui.GetCursorPos().y-5);
			imgui.PopFont();
			imgui.PushFont(bold10);
			if animations:button("Следить", imgui.ImVec2(itemFullWidth/3, 25), nil, {
				0, 
				0, 
				0.4
			}) then
				greport.player:spectate();
			end
			imgui.SameLine();
			if animations:button("Удалить", imgui.ImVec2(itemFullWidth/3-imgui.GetStyle().ItemSpacing.x*2, 25), nil, {
				0, 
				0, 
				0.4
			}) then
				if #ffi.string(greport.window.answerInput)==0 then
					greport.window.noInputClock = os.clock();
				else
					greport.player:remove(ffi.string(greport.window.answerInput));
				end
			end
			imgui.SameLine();
			if animations:button("Поставить метку", imgui.ImVec2(itemFullWidth/3, 25), nil, {
				0, 
				0, 
				0.4
			}) then
				greport.player:setMapPoint();
			end
			if animations:button("Отправить в /a чат", imgui.ImVec2(itemFullWidth/3, 25)) then
				sampSendChat(string.format("/a %s[%d]: %s", greport.player.nickname, greport.player.id, greport.player.context));
			end
			imgui.SameLine();
			if animations:button("Заблокировать репорт игроку", imgui.ImVec2(itemFullWidth/3-imgui.GetStyle().ItemSpacing.x*2, 25)) then
				if #ffi.string(greport.window.answerInput)==0 then
					greport.window.noInputClock = os.clock();
				else
					imgui.OpenPopup("imgui.windows.GReport.timeSelection");
				end
			end
			imgui.SameLine();
			if animations:button("Передать репорт", imgui.ImVec2(itemFullWidth/3, 25), nil, {
				0, 
				0, 
				0.4
			}) then
				greport.player:moveReportToAdministration();
			end
			for index = 1, 6, 1 do
				local _internal0;
				if (index==2 or index==5) then
					_internal0 = imgui.GetStyle().ItemSpacing.x*2;
				else
					_internal0 = 0;
				end
				if animations:button("> "..config.root.windows.greport.inputCopyButtons[(index)][(1)].."##imgui.windows.GReportIndex"..index, imgui.ImVec2(itemFullWidth/3-(_internal0), 25)) then
					imgui.StrCopy(greport.window.answerInput, config.root.windows.greport.inputCopyButtons[(index)][(2)]);
				end
				imgui.SameLine();
				if index%3==0 then
					imgui.NewLine();
				end
			end
			if animations:button("Ответить на репорт", imgui.ImVec2(itemFullWidth, 30), nil, {
				0, 
				0, 
				0.4
			}) then
				if #ffi.string(greport.window.answerInput)==0 then
					greport.window.noInputClock = os.clock();
				else
					greport.player:answer(ffi.string(greport.window.answerInput));
				end
			end
			imgui.PopFont();
			imgui.EndGroup();
			if imgui.BeginPopupModal("imgui.windows.GReport.timeSelection", nil, self.flags) then
				imguiAssets:textWithFont("Выберите время (в минутах)", bold14);
				imgui.PushFont(regular12);
				for _, time in ipairs(({
					10, 
					30, 
					60, 
					90
				})) do
					if animations:button(time.."##imgui.windows.GReport.timeSelection", imgui.ImVec2(imgui.GetWindowWidth()/4-6.5, 25)) then
						greport.player:blockReport(time, ffi.string(greport.window.answerInput));
						imgui.CloseCurrentPopup();
					end
					imgui.SameLine();
				end
				imgui.PopFont();
				imgui.NewLine();
				if animations:button("Отменить", imgui.ImVec2(imgui.GetWindowWidth()-imgui.GetStyle().WindowPadding.x*2, 30)) then
					imgui.CloseCurrentPopup();
				end
			end
			imgui.End();
			style:endWindowStyleChangeable("imgui.windows.GReport");
			imgui.PopStyleVar();
		end);
	end,
	["AutoUpdate"] = function(...)
		local common = import("Common");
		local assets = import("Assets");
		local config = import("Config");
		local imguiAssets = import("imgui.Assets");
		function __autoUpdate__:mergeJson(file, first, second)
			if doesFileExist(file) then
				first, second = decodeJson(first), decodeJson(second);
				common:writeInFile(file, neatJSON(assets:mergeTables(first, second), {
					sort = true, 
					wrap = 40
				}));
			end
		end
		function __autoUpdate__:update()
			local function downloadCallback()
				config.root.autoUpdate.hasUpdateInstalled = true;
				thisScript():reload();
			end
			if self.handler.root.AutoUpdate.merge then
				if #self.handler.root.AutoUpdate.merge.json>1 then
					local this = self.handler.root.AutoUpdate.merge.json;
					for _, json in ipairs(this) do
						local src = getWorkingDirectory().."\\"..json._attr.src;
						local value = json[(1)];
						self:mergeJson(src, common:readFileContent(src), value);
					end
				elseif #self.handler.root.AutoUpdate.merge.json==1 then
					local this = self.handler.root.AutoUpdate.merge.json;
					local src = getWorkingDirectory().."\\"..this._attr.src;
					local value = this[(1)];
					self:mergeJson(src, common:readFileContent(src), value);
				end
			end
			if #self.handler.root.AutoUpdate.links.link>1 then
				local files = {				};
				for _, link in ipairs(self.handler.root.AutoUpdate.links.link) do
					local destination = getWorkingDirectory().."\\"..link._attr.destination;
					local url = link[(1)];
					table.insert(files, {
						url = url, 
						destination = destination
					});
				end
				assets:downloadFileList(files, downloadCallback);
			elseif #self.handler.root.AutoUpdate.links.link==1 then
				local this = self.handler.root.AutoUpdate.links.link;
				assets:downloadFileList({
					{
						url = this[(1)], 
						destination = getWorkingDirectory().."\\"..this._attr.destination
					}
				}, downloadCallback);
			end
		end
		function __autoUpdate__:checkUpdates(url)
			local downloadStatus = require("moonloader").download_status;
			local content = "";
			local tempFileDestination = getWorkingDirectory().."\\GAdmin\\temp\\AutoUpdate.xml";
			if config.root.autoUpdate.hasUpdateInstalled then
				config.root.autoUpdate.hasUpdateInstalled = false;
				return;
			end
			downloadUrlToFile(url, tempFileDestination, function(id, status, p1, p2)
				if status==downloadStatus.STATUS_ENDDOWNLOADDATA then
					lua_thread.create(function()
						while not doesFileExist(tempFileDestination) do
							wait(0);
						end
						local _check, err = pcall(function()
							content = xml2lua.loadFile(tempFileDestination);
							local parser = xml2lua.parser(self.handler);
							parser:parse(content);
							os.remove(tempFileDestination);
							if self.handler.root.AutoUpdate._attr.version~="1.3.1" and config.root.autoUpdate.skipVersionUpdate~=self.handler.root.AutoUpdate._attr.version then
								self.imgui.body = string.match(content, "<body>%s*(.*)%s*</body>");
								self.imgui.title = self.handler.root.AutoUpdate.title;
								self.imgui.version = self.handler.root.AutoUpdate._attr.version;
								self.imgui.buttons.first = self.handler.root.AutoUpdate.buttons._attr.first;
								self.imgui.buttons.second = self.handler.root.AutoUpdate.buttons._attr.second;
								self.imgui.buttons.third = self.handler.root.AutoUpdate.buttons._attr.third;
								self.windowState = true;
							end
						end)
						if not _check then
							self.response = AUTOUPDATE_RESPONSE_BAD;
						end
					end);
				end
			end);
		end
		function __autoUpdate__:renderXMLGroup(text)
			local function renderLine(line, type)
				local index = 1;
				local parsed = {				};
				local buffer = "";
				while #line>=index do
					local char = string.sub(line, index, index);
					if char=="<" then
						if #buffer>0 then
							table.insert(parsed, {
								tag = "plain-text", 
								body = buffer
							});
							buffer = "";
						end
						do
							local element, tag, body = string.match(string.sub(line, index), "^(<(%w+)>(.*)</%2>)");
							if element ~= nil and tag ~= nil and body ~= nil then
								table.insert(parsed, {
									tag = tag, 
									body = body
								});
								index = index + #element;
							else
								local element, tag = string.match(string.sub(line, index), "^(<(%w+)/>)");
								if element ~= nil and tag ~= nil then
									table.insert(parsed, {
										tag = tag, 
										body = "none"
									});
									index = index + #element-1;
								end
							end
						end
					else
						buffer = buffer .. char;
					end
					index = index + 1;
				end
				if #buffer>0 then
					table.insert(parsed, {
						tag = "plain-text", 
						body = buffer
					});
				end
				imgui.PushTextWrapPos(imgui.GetWindowWidth());
				imgui.BeginGroup();
				for index, item in ipairs(parsed) do
					item.body = string.match(item.body, "^%s*(.-)%s*$");
					local _internal0 = item.tag;
					if (_internal0 == "b") then
						local _internal0;
						if (type=="header") then
							_internal0 = bold14;
						else
							_internal0 = bold12;
						end
						imgui.PushFont(_internal0);
						imgui.Text(item.body);
						imgui.PopFont();
					else
						if (_internal0 == "plain-text") then
							imgui.Text(item.body);
						else
							if (_internal0 == "code") then
								if imgui.GetCursorPos().x==0 then
									imgui.SetCursorPos(imgui.GetCursorPos()+imgui.ImVec2(2, 2));
								end
								imgui.BeginGroup();
								local pos = imgui.GetCursorScreenPos();
								local size = imgui.CalcTextSize(item.body);
								local padding = imgui.ImVec2(2, 2);
								imgui.GetWindowDrawList():AddRectFilled(pos-padding, pos+size+padding, imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[(imgui.Col.FrameBg)]), imgui.GetStyle().FrameRounding);
								imgui.Text(item.body);
								imgui.EndGroup();
							else
								if (_internal0 == "link") then
									imgui.Text(item.body);
									imguiAssets:setPreviousItemAbleToCopy(item.body);
								else
									if (_internal0 == "br") then
										imgui.NewLine();
									end
								end
							end
						end
					end
					if #parsed>=2 and index~=#parsed and item.tag~="br" then
						imgui.SameLine(nil, 5);
					end
				end
				imgui.EndGroup();
				imgui.PopTextWrapPos();
			end
			for line in string.gmatch(text, "[^\n\r]+") do
				line = string.match(line, "^%s*(.*)");
				do
					local tag, body = string.match(line, "^<(%w+)>(.*)</%1>$");
					if tag ~= nil and body ~= nil then
						local _internal0 = tag;
						if (_internal0 == "header") then
							imgui.PushFont(bold14);
							renderLine(body, tag);
							imgui.PopFont();
						else
							if (_internal0 == "ul") then
								imgui.PushFont(regular12);
								local pos = imgui.GetCursorPos();
								imgui.Bullet();
								imgui.SetCursorPosY(pos.y-1);
								renderLine(body, tag);
								imgui.PopFont();
							else
								if (_internal0 == "quote") then
									imgui.BeginGroup();
									local cursor = imgui.GetCursorPos();
									local screenCursor = imgui.GetCursorScreenPos();
									imgui.SetCursorPos(imgui.ImVec2(cursor.x+10, cursor.y));
									imgui.PushStyleColor(imgui.Col.Text, imgui.GetStyle().Colors[(imgui.Col.TextDisabled)]);
									imgui.PushFont(regular12);
									renderLine(body, tag);
									imgui.PopFont();
									imgui.PopStyleColor();
									imgui.GetWindowDrawList():AddRectFilled(screenCursor, imgui.ImVec2(screenCursor.x+3, imgui.GetItemRectMax().y), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[(imgui.Col.TextDisabled)]));
									imgui.EndGroup();
								end
							end
						end
					elseif string.find(line, "^<newline.+") then
						imgui.NewLine();
					else
						imgui.PushFont(regular12);
						renderLine(line);
						imgui.PopFont();
					end
				end
			end
		end
		return __autoUpdate__;
	end,
	["imgui.windows.DrawListRender"] = function(...)
		local bit = require("bit");
		local imguiAssets = import("imgui.Assets");
		local imguiText = import("imgui.drawList.Text");
		local HotKey = import("imgui.HotKey");
		local vehicle = import("game.sa.Vehicle");
		local ped = import("game.sa.Ped");
		local admins = import("game.Admins");
		local user = import("game.User");
		local assets = import("Assets");
		local icons = import("Icons");
		local notify = import("Notifications");
		local common = import("Common");
		local config = import("Config");
		local useWallhack = true;
		local useTraccers = true;
		HotKey:new("imgui.windows.DrawListRender->wallhack", {
			VK_LCONTROL, 
			VK_Z
		}, "Wallhack"):registerCallback(function()
			if user:getAloginStatus() and config.root.cheats.wallhack.use then
				useWallhack = not useWallhack;
				if not config.root.cheats.wallhack.imguiStyle then
					assets:changeWallhackState(useWallhack);
				end
				do
					local notificationType = config.root.cheats.wallhack.notificationType;
					if notificationType ~= nil then
						if notificationType~=NOTIFICATION_TYPE_NONE then
							local _internal0;
							if (useWallhack) then
								_internal0 = "включен.";
							else
								_internal0 = "выключен.";
							end
							local _internal1;
							if (useWallhack) then
								_internal1 = "показаны.";
							else
								_internal1 = "скрыты.";
							end
							local _internal3;
							if (notificationType==NOTIFICATION_TYPE_SCRIPT_MESSAGE) then
								local _internal2;
								if (useWallhack) then
									_internal2 = "показаны.";
								else
									_internal2 = "скрыты.";
								end
								_internal3 = "Никнеймы игроков "..(_internal2);
							else
								_internal3 = nil;
							end
							notify:send({
								title = "Wallhack "..(_internal0), 
								text = "Теперь никнеймы игроков "..(_internal1), 
								icon = icons.ICON_CHECKMARK, 
								duration = 2
							}, _internal3);
						end
					end
				end
			end
		end);
		HotKey:new("imgui.windows.DrawListRender->tracersSwitch", {
			VK_LMENU, 
			VK_C
		}, "Переключить трассера"):registerCallback(function()
			if config.root.additions.tracers.use and user:getAloginStatus() then
				useTraccers = not useTraccers;
				do
					local notificationType = config.root.additions.tracers.notificationType;
					if notificationType ~= nil then
						if notificationType~=NOTIFICATION_TYPE_NONE then
							local _internal0;
							if (useTraccers) then
								_internal0 = "включены.";
							else
								_internal0 = "выключены.";
							end
							local _internal1;
							if (useTraccers) then
								_internal1 = "показаны.";
							else
								_internal1 = "скрыты.";
							end
							local _internal3;
							if (notificationType==NOTIFICATION_TYPE_SCRIPT_MESSAGE) then
								local _internal2;
								if (useTraccers) then
									_internal2 = "показаны.";
								else
									_internal2 = "скрыты.";
								end
								_internal3 = "Трассера "..(_internal2);
							else
								_internal3 = nil;
							end
							notify:send({
								title = "Трассеры "..(_internal0), 
								text = "Теперь выстрелы от игроков "..(_internal1), 
								icon = icons.ICON_CHECKMARK, 
								duration = 2
							}, _internal3);
						end
					end
				end
			end
		end);
		HotKey:new("imgui.windows.DrawListRender->traccersRemove", {
			VK_LMENU, 
			VK_Z
		}, "Удалить трассера"):registerCallback(function()
			if config.root.additions.tracers.use then
				for i = 1, config.root.additions.tracers.maxLines, 1 do
					bulletData[((i))].enable = false;
				end
				notify:send({
					title = "Трассера удалены.", 
					text = "Трассера успешно удалены!", 
					icon = icons.ICON_CHECKMARK, 
					duration = 2
				});
			end
		end);
		local function showCursor(toggle)
			if toggle then
				sampSetCursorMode(CMODE_LOCKCAM);
			end
		end
		imgui.OnFrame(function()
			return isSampAvailable();
		end, function(self)
			self.HideCursor = imguiAssets:getCursorStatus();
			self.DL = imgui.GetBackgroundDrawList();
			local sizeX, sizeY = getScreenResolution();
			if not isGamePaused() then
				local _internal0;
				if (config.root.additions.carInfo.onlyInSpectator) then
					_internal0 = user:getAloginStatus();
				else
					_internal0 = true;
				end
				if config.root.additions.carInfo.use and (_internal0) then
					for _, car in ipairs(getAllVehicles()) do
						local x, y, z = getCarCoordinates(car);
						local myx, myy, myz = getCharCoordinates(PLAYER_PED);
						if doesVehicleExist(car) and isCarOnScreen(car) and getDistanceBetweenCoords3d(x, y, z, myx, myy, myz)<50 and user:getAloginStatus() then
							local _internal0;
							if (isCarEngineOn(car)) then
								_internal0 = "{8DFF85}{ON}";
							else
								_internal0 = "{FF8585}{OFF}";
							end
							local engine = _internal0;
							local _internal1;
							if (getCarDoorLockStatus(car)==0) then
								_internal1 = "{8DFF85}{OPEN}";
							else
								_internal1 = "{FF8585}{LOCK}";
							end
							local door = _internal1;
							local hp = getCarHealth(car);
							local _, id = sampGetVehicleIdByCarHandle(car);
							local carmodel = getCarModel(car);
							local vehname = vehicle:getName(carmodel);
							local sx, sy = convert3DCoordsToScreen(x, y, z);
							local firstText, secondText = string.format("{FFFFFF}{ID: }{8DFF85}{%s}{FFFFFF}{ HP: }{8DFF85}{%s}", id, hp), string.format("{FFFFFF}{%s }%s{FFFFFF}{ / }%s", vehname, engine, door);
							imguiText:addColored(self.DL, firstText, imgui.ImVec2(sx, sy), nil, config.root.render.size.carInfo, 1);
							imguiText:addColored(self.DL, secondText, imgui.ImVec2(sx, sy+15), nil, config.root.render.size.carInfo, 1);
						end
					end
				end
				for _, player in ipairs(getAllChars()) do
					local result, id = sampGetPlayerIdByCharHandle(player);
					if result then
						local charResult, char = sampGetCharHandleBySampPlayerId(id);
						local x, y, z = ped:getBodyPartCoordinates(4, player);
						local myx, myy, myz = getCharCoordinates(PLAYER_PED);
						local screenPosX, screenPosY = convert3DCoordsToScreen(x, y, z);
						local charCheck = charResult and isCharOnScreen(char) and id~=select(2, sampGetPlayerIdByCharHandle(PLAYER_PED));
						local distance = getDistanceBetweenCoords3d(x, y, z, myx, myy, myz);
						local clistColorHex = string.format("%06X", bit.band(sampGetPlayerColor(id), 0xFFFFFF));
						local onPlayerRenderText = "";
						if charCheck and user:getAloginStatus() then
							if config.root.cheats.wallhack.use and useWallhack and config.root.cheats.wallhack.imguiStyle then
								onPlayerRenderText = onPlayerRenderText .. string.format("{%s}{%s[%s] [X: %1.f]}{FFFFFF}{\n}", clistColorHex, sampGetPlayerNickname(id), id, distance);
							end
							if config.root.additions.showAdmins.use and distance<50 and not ped:isBehindWall(char) then
								do
									local admin = admins:getAdminById(id);
									if admin ~= nil then
										onPlayerRenderText = onPlayerRenderText .. "{FF8585}{"..admin.nickname.ooc.."}{FFFFFF}{\n}";
									end
								end
							end
							if config.root.additions.gunInfo.use and distance<50 then
								onPlayerRenderText = onPlayerRenderText .. "{FFFFFF}{"..require("game.weapons").names[(getCurrentCharWeapon(player))].."}{FFFFFF}{\n}";
							end
							if #onPlayerRenderText>0 then
								imguiText:addColored(self.DL, onPlayerRenderText, imgui.ImVec2(screenPosX, screenPosY), nil, config.root.render.size.common, 1);
							end
						end
						if config.root.additions.tracers.use and user:getAloginStatus() and useTraccers then
							for i = 1, config.root.additions.tracers.maxLines, 1 do
								do
									local bullet = bulletData[(i)];
									if bullet ~= nil then
										if bullet.enable and os.time()<=bullet.time then
											local o, t = bullet.o, bullet.t;
											if isPointOnScreen(o.x, o.y, o.z) and isPointOnScreen(t.x, t.y, t.z) then
												local sX, sY = convert3DCoordsToScreen(o.x, o.y, o.z);
												local fX, fY = convert3DCoordsToScreen(t.x, t.y, t.z);
												local hitColor = common:convertHex2ImVec4(config.root.additions.tracers.hitColor);
												local missColor = common:convertHex2ImVec4(config.root.additions.tracers.missColor);
												local _internal0;
												if (bullet.type==0 or bullet.type==3) then
													_internal0 = missColor;
												else
													_internal0 = hitColor;
												end
												local color = imgui.ColorConvertFloat4ToU32(_internal0);
												local dl = imgui.GetBackgroundDrawList();
												dl:AddLine(imgui.ImVec2(sX, sY), imgui.ImVec2(fX, fY), color, 1);
												dl:AddCircleFilled(imgui.ImVec2(fX+1.5, fY+1.5), 3, color, 16);
											end
										end
									end
								end
							end
						end
					end
				end
				if clickWarp.enabled and config.root.cheats.clickwarp.use and user:getAloginStatus() then
					local sx, sy = getCursorPos();
					local sw, sh = getScreenResolution();
					if sx>=0 and sy>=0 and sx<sw and sy<sh then
						local posX, posY, posZ = convertScreenCoordsToWorld3D(sx, sy, 700.0);
						local camX, camY, camZ = getActiveCameraCoordinates();
						local result, colpoint = processLineOfSight(camX, camY, camZ, posX, posY, posZ, true, true, false, true, false, false, false);
						if result and colpoint.entity~=0 then
							local normal = colpoint.normal;
							local pos = Vector3D(colpoint.pos[(1)], colpoint.pos[(2)], colpoint.pos[(3)])-(Vector3D(normal[(1)], normal[(2)], normal[(3)])*0.1);
							local zOffset = 300;
							if normal[(3)]>=0.5 then
								zOffset = 1;
							end
							local result, colpoint2 = processLineOfSight(pos.x, pos.y, pos.z+zOffset, pos.x, pos.y, pos.z-0.3, true, true, false, true, false, false, false);
							if result then
								pos = Vector3D(colpoint2.pos[(1)], colpoint2.pos[(2)], colpoint2.pos[(3)]+1);
								local curX, curY, curZ = getCharCoordinates(playerPed);
								local distance = getDistanceBetweenCoords3d(curX, curY, curZ, pos.x, pos.y, pos.z);
								local text = string.format("%.2fm", distance);
								local color = imgui.ImVec4(1, 1, 1, 1);
								sy = sy - 2;
								sx = sx - 2;
								local tpIntoCar = nil;
								if colpoint.entityType==2 then
									local car = getVehiclePointerHandle(colpoint.entity);
									local carModel = getCarModel(car);
									if doesVehicleExist(car) and (not isCharInAnyCar(PLAYER_PED) or storeCarCharIsInNoSave(PLAYER_PED)~=car) then
										color = imgui.ImVec4(1, 1, 1, 0.5);
										text = text .. " | "..vehicle:getName(carModel).."\nУдерживайте ПКМ для телепортации в машину";
										if isKeyDown(VK_RBUTTON) then
											tpIntoCar = car;
											color = imgui.ImVec4(1, 1, 1, 1);
										end
									end
								end
								imguiText:addStroke(self.DL, text, imgui.ColorConvertFloat4ToU32(color), imgui.ImVec2(sx+20, sy+10), regular, 18);
								clickWarp.teleportation = {
									tpIntoCar = tpIntoCar, 
									pos = pos
								};
							end
						end
					end
				end
			else
				for index, text in ipairs(({
					string.format("GAdmin v%s", "1.3.1"), 
					"\nCopyright (C) ".."2023-2024".." The Contributors. All rights reserved.", 
					"\n\nLicensed under the GNU General Public License v3 (GPLv3)."
				})) do
					local _internal0;
					if (index==1) then
						_internal0 = bold;
					else
						_internal0 = regular;
					end
					self.DL:AddTextFontPtr(_internal0, 18, imgui.ImVec2((sizeX-imgui.CalcTextSize(text).x)/2, sizeY-70+(index*2)), -1, text);
				end
			end
		end);
	end,
	["imgui.drawList.Text"] = function(...)
		local assets = import("Assets");
		local text = {		};
		function text:addStroke(drawList, text, color, pos, font, textSize, strokeWidth)
			if strokeWidth == nil then
				strokeWidth = 1
			end
			local blackColor = imgui.GetColorU32Vec4(imgui.ImVec4(0, 0, 0, 1));
			if strokeWidth>0 then
				drawList:AddTextFontPtr(font, textSize, imgui.ImVec2(pos.x+strokeWidth, pos.y+strokeWidth), blackColor, text);
				drawList:AddTextFontPtr(font, textSize, imgui.ImVec2(pos.x-strokeWidth, pos.y-strokeWidth), blackColor, text);
				drawList:AddTextFontPtr(font, textSize, imgui.ImVec2(pos.x+strokeWidth, pos.y-strokeWidth), blackColor, text);
				drawList:AddTextFontPtr(font, textSize, imgui.ImVec2(pos.x-strokeWidth, pos.y+strokeWidth), blackColor, text);
			end
			drawList:AddTextFontPtr(font, textSize, pos, color, text);
		end
		function text:addColored(drawList, text, pos, font, textSize, strokeWidth)
			if strokeWidth == nil then
				strokeWidth = 1
			end
			if textSize == nil then
				textSize = 14
			end
			if font == nil then
				font = nil
			end
			local changeablePos = imgui.ImVec2(pos.x, pos.y);
			local textColoredList = (function()
				local output = {				};
				for color, coloredText in string.gmatch(text, "{(%x%x%x%x%x%x)}{(.-)}") do
					table.insert(output, {
						text = coloredText, 
						hex = color, 
						size = imgui.CalcTextSize(coloredText)
					});
				end
				return output;
			end)();
			for _, data in ipairs(textColoredList) do
				local r, g, b, _ = assets:explodeARGB(tonumber(data.hex.."FF", 16));
				local color = imgui.GetColorU32Vec4(imgui.ImVec4(r/255, g/255, b/255, 1));
				self:addStroke(drawList, data.text, color, changeablePos, font, textSize, strokeWidth);
				if data.text=="\n" then
					changeablePos.y = changeablePos.y + data.size.y+textSize/2.5;
					changeablePos.x = pos.x;
				else
					changeablePos.x = changeablePos.x + data.size.x+textSize/2.5;
				end
			end
		end
		return text;
	end,
	["imgui.InputTextFilter"] = function(...)
		local common = import("Common");
		local InputTextFilter = {		};
		InputTextFilter.__index = InputTextFilter;
		function InputTextFilter:new()
			setmetatable({			}, self);
			self.__index = self;
			self.buffer = imgui.new.char[(256)]();
			return self;
		end
		function InputTextFilter:draw(label, hint, width)
			if width == nil then
				width = 0.0
			end
			if hint == nil then
				hint = "Поиск"
			end
			if width~=0.0 then
				imgui.SetNextItemWidth(width);
			end
			return imgui.InputTextWithHint(label, hint, self.buffer, ffi.sizeof(self.buffer));
		end
		function InputTextFilter:passFilter(filter)
			local filter = common:toLowerCase(filter);
			local buffer = common:toLowerCase(ffi.string(self.buffer));
			local result = string.find(filter, buffer, 1, true);
			local _internal0;
			if (buffer=="") then
				_internal0 = true;
			else
				_internal0 = result;
			end
			return _internal0;
		end
		function InputTextFilter:setBufferText(text)
			imgui.StrCopy(self.buffer, text);
		end
		function InputTextFilter:clear()
			self:setBufferText("");
		end
		return InputTextFilter;
	end,
	["imgui.drawList.Shadow"] = function(...)
		local bit = require("bit");
		local shadow = {		};
		function shadow:apply(drawList, from, to, size, opacity, rate)
			local color = bit.bor((bit.lshift(opacity, 24)), 0xFFFFFF);
			local uv0 = 0.0;
			local uv1 = 0.333333;
			local uv2 = 0.666666;
			local uv3 = 1.0;
			local p = from;
			local s = to;
			local m = imgui.ImVec2(p.x+s.x, p.y+s.y);
			drawList:PushClipRectFullScreen();
			for i = 1, rate, 1 do
				drawList:AddImage(shadowPng, imgui.ImVec2(p.x-size, p.y-size), imgui.ImVec2(p.x, p.y), imgui.ImVec2(uv0, uv0), imgui.ImVec2(uv1, uv1), color);
				drawList:AddImage(shadowPng, imgui.ImVec2(p.x, p.y-size), imgui.ImVec2(m.x, p.y), imgui.ImVec2(uv1, uv0), imgui.ImVec2(uv2, uv1), color);
				drawList:AddImage(shadowPng, imgui.ImVec2(m.x, p.y-size), imgui.ImVec2(m.x+size, p.y), imgui.ImVec2(uv2, uv0), imgui.ImVec2(uv3, uv1), color);
				drawList:AddImage(shadowPng, imgui.ImVec2(p.x-size, p.y), imgui.ImVec2(p.x, m.y), imgui.ImVec2(uv0, uv1), imgui.ImVec2(uv1, uv2), color);
				drawList:AddImage(shadowPng, imgui.ImVec2(m.x, p.y), imgui.ImVec2(m.x+size, m.y), imgui.ImVec2(uv2, uv1), imgui.ImVec2(uv3, uv2), color);
				drawList:AddImage(shadowPng, imgui.ImVec2(p.x-size, m.y), imgui.ImVec2(p.x, m.y+size), imgui.ImVec2(uv0, uv2), imgui.ImVec2(uv1, uv3), color);
				drawList:AddImage(shadowPng, imgui.ImVec2(p.x, m.y), imgui.ImVec2(m.x, m.y+size), imgui.ImVec2(uv1, uv2), imgui.ImVec2(uv2, uv3), color);
				drawList:AddImage(shadowPng, imgui.ImVec2(m.x, m.y), imgui.ImVec2(m.x+size, m.y+size), imgui.ImVec2(uv2, uv2), imgui.ImVec2(uv3, uv3), color);
			end
			drawList:PopClipRect();
		end
		return shadow;
	end,
	["imgui.Assets"] = function(...)
		local icons = import("Icons");
		local notify = import("Notifications");
		local common = import("Common");
		function __imguiAssets__:getCursorStatus()
			return self.cursor;
		end
		function __imguiAssets__:setCursorStatus(status)
			if status == nil then
				status = false
			end
			self.cursor = status;
		end
		function __imguiAssets__:switchCursorStatus()
			self.cursor = not self.cursor;
		end
		function __imguiAssets__:textWithFont(text, font, pos, color)
			if color == nil then
				color = imgui.GetStyle().Colors[(imgui.Col.Text)]
			end
			imgui.PushFont(font);
			if pos then
				imgui.SetCursorPos(pos);
			end
			imgui.TextColored(color, text);
			imgui.PopFont();
		end
		function __imguiAssets__:bringFloatTo(from, to, startTime, duration)
			local timer = os.clock()-startTime;
			if timer>=0.00 and timer<=duration then
				local count = timer/(duration/100);
				return from+(count*(to-from)/100), true;
			end
			local _internal0;
			if (timer>duration) then
				_internal0 = to;
			else
				_internal0 = from;
			end
			return (_internal0), false;
		end
		function __imguiAssets__:bringVec2To(from, to, startTime, duration)
			local timer = os.clock()-startTime;
			if timer>=0.00 and timer<=duration then
				local count = timer/(duration/100);
				return imgui.ImVec2(from.x+(count*(to.x-from.x)/100), from.y+(count*(to.y-from.y)/100)), true;
			end
			local _internal0;
			if (timer>duration) then
				_internal0 = to;
			else
				_internal0 = from;
			end
			return (_internal0), false;
		end
		function __imguiAssets__:bringVec4To(from, to, startTime, duration)
			local timer = os.clock()-startTime;
			if timer>=0.00 and timer<=duration then
				local count = timer/(duration/100);
				return imgui.ImVec4(from.x+(count*(to.x-from.x)/100), from.y+(count*(to.y-from.y)/100), from.z+(count*(to.z-from.z)/100), from.w+(count*(to.w-from.w)/100)), true;
			end
			local _internal0;
			if (timer>duration) then
				_internal0 = to;
			else
				_internal0 = from;
			end
			return (_internal0), false;
		end
		function __imguiAssets__:addStrokedText(text, strokeWidth, color, ...)
			if color == nil then
				color = imgui.GetStyle().Colors[(imgui.Col.Text)]
			end
			if strokeWidth == nil then
				strokeWidth = 0
			end
			local text = string.format(text, ...);
			local pos = imgui.GetCursorPos();
			imgui.BeginGroup();
			for i = 1, strokeWidth, 1 do
				imgui.SetCursorPos(imgui.ImVec2(pos.x+i, pos.y));
				imgui.TextColored(imgui.ImVec4(0, 0, 0, 1), text);
				imgui.SetCursorPos(imgui.ImVec2(pos.x-i, pos.y));
				imgui.TextColored(imgui.ImVec4(0, 0, 0, 1), text);
				imgui.SetCursorPos(imgui.ImVec2(pos.x, pos.y+i));
				imgui.TextColored(imgui.ImVec4(0, 0, 0, 1), text);
				imgui.SetCursorPos(imgui.ImVec2(pos.x, pos.y-i));
				imgui.TextColored(imgui.ImVec4(0, 0, 0, 1), text);
			end
			imgui.SetCursorPos(pos);
			imgui.TextColored(color, text);
			imgui.EndGroup();
			return imgui.IsItemClicked(), imgui.IsItemHovered();
		end
		function __imguiAssets__:convertHex2Float3(hex)
			local vector = common:convertHex2ImVec4(hex);
			local float3 = ffi.new("float[3]");
			float3[((0))] = vector.x;
			float3[((1))] = vector.y;
			float3[((2))] = vector.z;
			return float3;
		end
		function __imguiAssets__:setPreviousItemAbleToCopy(text, notifyTitle, notifyDescription, notification)
			if notifyDescription == nil then
				notifyDescription = "Следующий текст успешно скопирован: "..text
			end
			if notifyTitle == nil then
				notifyTitle = "Текст скопирован"
			end
			if notification == nil then
				notification = {
					icon = icons.ICON_KEYBOARD, 
					title = notifyTitle, 
					text = notifyDescription
				};
			end
			if imgui.IsItemHovered() then
				imgui.GetWindowDrawList():AddLine(imgui.ImVec2(imgui.GetItemRectMin().x, imgui.GetItemRectMax().y), imgui.GetItemRectMax(), -1, 2);
			end
			if imgui.IsItemClicked() then
				setClipboardText(tostring(text));
				notify:send(notification);
			end
		end
		return __imguiAssets__;
	end,
	["imgui.windows.Notifications"] = function(...)
		local notify = import("Notifications");
		local common = import("Common");
		local config = import("Config");
		local assets = import("Assets");
		local imguiAssets = import("imgui.Assets");
		local style = import("imgui.Style");
		local StyleChanger = import("imgui.StyleChanger");
		local animations = import("imgui.Animations");
		local shadow = import("imgui.drawList.Shadow");
		style:registerWindow("imgui.windows.Notifications", "Оповещения");
		imgui.OnFrame(function()
			return notify.active and config.root.windows.notifications.use;
		end, function(self)
			self.HideCursor = imguiAssets:getCursorStatus();
			self.align = config.root.windows.notifications.align;
			self.notifySize = math.min(5, #notify:get());
			self.flags = imgui.WindowFlags.NoMove+imgui.WindowFlags.NoTitleBar+imgui.WindowFlags.NoResize+imgui.WindowFlags.NoScrollbar+imgui.WindowFlags.NoScrollWithMouse+imgui.WindowFlags.NoBringToFrontOnFocus;
			self.style = StyleChanger:new({
				WindowBg = "22222200", 
				WindowBorderSize = 0, 
				ChildBg = "222222", 
				ChildRounding = 8, 
				ItemSpacing = imgui.ImVec2(0, 15), 
				WindowPadding = imgui.ImVec2(0, 0)
			});
			self.notification = function(notification, closeCallback)
				imgui.BeginChild(tostring(notification.clock+os.time()), imgui.ImVec2(344, 65), false, self.flags);
				local pos = imgui.GetWindowPos();
				local size = imgui.GetWindowSize();
				shadow:apply(imgui.GetBackgroundDrawList(), imgui.ImVec2(pos.x+5, pos.y+5), imgui.ImVec2(size.x-10, size.y-10), 24.0, math.floor(math.floor(imgui.GetStyle().Alpha*255)/255)*100, 2);
				imgui.SetCursorPos(imgui.ImVec2(12, 28));
				imgui.TextColored(notification.iconColor, notification.icon);
				imguiAssets:textWithFont(notification.title, bold10, imgui.ImVec2(52, 8));
				local _internal0 = notification.buttons;
				local _internal1 = notification.buttons;
				local _internal2;
				if ((_internal0 and _internal0.first) and (_internal1 and _internal1.second)) then
					_internal2 = 255;
				else
					_internal2 = 339;
				end
				imgui.PushTextWrapPos(_internal2);
				imguiAssets:textWithFont(notification.text, regular9, imgui.ImVec2(52, 28));
				imgui.PopTextWrapPos();
				local _internal3 = notification.buttons;
				local _internal4 = notification.buttons;
				if (_internal3 and _internal3.first) and (_internal4 and _internal4.second) then
					local dl = imgui.GetWindowDrawList();
					local pos = imgui.GetWindowPos();
					local size = imgui.GetWindowSize();
					dl:AddLine(imgui.ImVec2(pos.x+263, pos.y), imgui.ImVec2(pos.x+263, pos.y+size.y), 0xFF5B5B5B, 1);
					dl:AddLine(imgui.ImVec2(pos.x+263, pos.y+32), imgui.ImVec2(pos.x+size.x, pos.y+32), 0xFF5B5B5B, 1);
					imgui.BeginGroup();
					do
						local this = notification.buttons.first;
						if this ~= nil then
							imgui.SetCursorPos(imgui.ImVec2(263, 0));
							if animations:clickableText("FIRST:"..tostring(notification.clock+os.time()), this.name, regular9, imgui.ImVec2(size.x-263, 32), 0.25) then
								local _internal0 = this.call;
								if _internal0 then
									_internal0(closeCallback);
								end
							end
						end
					end
					do
						local this = notification.buttons.second;
						if this ~= nil then
							imgui.SetCursorPos(imgui.ImVec2(263, 33));
							if animations:clickableText("SECOND:"..tostring(notification.clock+os.time()), this.name, regular9, imgui.ImVec2(size.x-263, 32), 0.25) then
								local _internal0 = this.call;
								if _internal0 then
									_internal0(closeCallback);
								end
							end
						end
					end
					imgui.EndGroup();
				end
				imgui.EndChild();
			end;
			local sizeX, sizeY = getScreenResolution();
			self.animation = ({
				[(ALIGN_LEFT)] = {
					posX = 0, 
					show = {
						from = -150, 
						to = 15
					}, 
					hide = {
						from = 15, 
						to = -150
					}, 
					removeOn = -150
				}, 
				[(ALIGN_CENTER)] = {				}, 
				[(ALIGN_RIGHT)] = {
					posX = sizeX-360, 
					show = {
						from = 380, 
						to = 0
					}, 
					hide = {
						from = -1, 
						to = 380
					}, 
					removeOn = 380
				}
			})[(self.align)];
			self.style:apply();
			local _internal0;
			if (self.align==ALIGN_CENTER) then
				_internal0 = sizeX/2-172;
			else
				_internal0 = self.animation.posX;
			end
			imgui.SetNextWindowPos(imgui.ImVec2(_internal0, sizeY-80*self.notifySize));
			local _internal1;
			if (self.align==ALIGN_CENTER) then
				_internal1 = 344;
			else
				_internal1 = 860;
			end
			imgui.SetNextWindowSize(imgui.ImVec2(_internal1, 80*self.notifySize));
			style:beginWindowStyleChangeable("imgui.windows.Notifications");
			imgui.Begin("imgui.windows.Notifications", nil, self.flags);
			for i = 1, config.root.windows.notifications.maxItems, 1 do
				do
					local notification = notify:get()[(i)];
					if notification ~= nil then
						if self.align~=ALIGN_CENTER then
							if os.clock()-notification.clock>=notification.duration then
								notification.pos = imguiAssets:bringFloatTo(self.animation.hide.from, self.animation.hide.to, notification.clock+notification.duration, 0.1);
							elseif notification.pos<math.abs(self.animation.removeOn) then
								notification.pos = imguiAssets:bringFloatTo(self.animation.show.from, self.animation.show.to, notification.clock, 0.2);
							end
							if notification.pos==self.animation.removeOn then
								notify:remove(i);
							end
							imgui.SetCursorPosX(notification.pos);
						else
							if os.clock()-notification.clock>=notification.duration then
								if #notify.root==i then
									notification.pos = imguiAssets:bringFloatTo(0, 150, notification.clock+notification.duration, 0.1);
								else
									notification.alpha = imguiAssets:bringFloatTo(1.0, 0.0, notification.clock+notification.duration, 0.1);
								end
							elseif notification.pos>0 then
								notification.pos = imguiAssets:bringFloatTo(149, 0, notification.clock, 0.2);
							end
							if notification.pos==150 or notification.alpha==0.0 then
								notify:remove(i);
							end
							imgui.SetCursorPosY(notification.pos+imgui.GetCursorPos().y);
						end
						local _internal0 = notification.condition;
						if (_internal0 and _internal0()) then
							notification.clock = os.clock()-notification.duration;
							notification.condition = nil;
						end
						imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, notification.alpha);
						self.notification(notification, function()
							notification.clock = os.clock()-notification.duration;
						end);
						imgui.PopStyleVar();
					end
				end
			end
			imgui.End();
			style:endWindowStyleChangeable("imgui.windows.Notifications");
			self.style:reset();
		end);
	end,
	["imgui.Style"] = function(...)
		local config = import("Config");
		local assets = import("Assets");
		local common = import("Common");
		local STYLE_TYPE_NUMBER = 1;
		local STYLE_TYPE_IMVEC2 = 2;
		local STYLE_TYPE_IMVEC4 = 3;
		function __style__:registerWindow(id, description)
			table.insert(registeredWindows, {
				id = id, 
				description = description
			});
			if config.root.styleChangeableWindows[((id))] == nil then
				config.root.styleChangeableWindows[((id))] = {				};
			end
		end
		function __style__:beginWindowStyleChangeable(id)
			do
				local this = config.root.styleChangeableWindows[(id)];
				if this ~= nil then
					local style = (function()
						local result = {						};
						for _, data in ipairs(this) do
							if type(data[(2)])=="table" then
								local _internal0;
								if (#data[(2)]==2) then
									_internal0 = "ImVec2";
								else
									_internal0 = "ImVec4";
								end
								result[((data[(1)]))] = imgui[(_internal0)](table.unpack(data[(2)]));
							else
								result[((data[(1)]))] = data[(2)];
							end
						end
						return result;
					end)();
					if self.windows[((id))] == nil then
						self.windows[((id))] = import("imgui.StyleChanger"):new(style);
					end
					self.windows[(id)]:update(style);
					self.windows[(id)]:apply();
				end
			end
		end
		function __style__:endWindowStyleChangeable(id)
			if config.root.styleChangeableWindows[(id)] then
				self.windows[(id)]:reset();
			end
		end
		function __style__:setDefaultValue(type, key, value)
			self.def[((key))] = value;
			local _internal0 = type;
			if (_internal0 == STYLE_TYPE_NUMBER) or (_internal0 == STYLE_TYPE_IMVEC2) then
				imgui.GetStyle()[((key))] = value;
			else
				if (_internal0 == STYLE_TYPE_IMVEC4) then
					for _, property in ipairs(self.baseColors) do
						if property[(1)]==key then
							if property[((2))] == nil then
								property[((2))] = {
									value.x, 
									value.y, 
									value.z, 
									value.w
								};
							end
							break;
						end
					end
					imgui.GetStyle().Colors[((imgui.Col[(key)]))] = value;
				end
			end
		end
		function __style__:getBaseColors()
			return assets:copyTable(self.baseColors);
		end
		function __style__:apply()
			imgui.SwitchContext();
			self:setDefaultValue(STYLE_TYPE_NUMBER, "IndentSpacing", 0);
			self:setDefaultValue(STYLE_TYPE_NUMBER, "ScrollbarSize", 10);
			self:setDefaultValue(STYLE_TYPE_NUMBER, "GrabMinSize", 10);
			self:setDefaultValue(STYLE_TYPE_NUMBER, "WindowBorderSize", 1);
			self:setDefaultValue(STYLE_TYPE_NUMBER, "ChildBorderSize", 1);
			self:setDefaultValue(STYLE_TYPE_NUMBER, "PopupBorderSize", 1);
			self:setDefaultValue(STYLE_TYPE_NUMBER, "FrameBorderSize", 1);
			self:setDefaultValue(STYLE_TYPE_NUMBER, "TabBorderSize", 1);
			self:setDefaultValue(STYLE_TYPE_NUMBER, "WindowRounding", 8);
			self:setDefaultValue(STYLE_TYPE_NUMBER, "ChildRounding", 8);
			self:setDefaultValue(STYLE_TYPE_NUMBER, "FrameRounding", 5);
			self:setDefaultValue(STYLE_TYPE_NUMBER, "PopupRounding", 5);
			self:setDefaultValue(STYLE_TYPE_NUMBER, "ScrollbarRounding", 5);
			self:setDefaultValue(STYLE_TYPE_NUMBER, "GrabRounding", 5);
			self:setDefaultValue(STYLE_TYPE_NUMBER, "TabRounding", 5);
			self:setDefaultValue(STYLE_TYPE_IMVEC2, "WindowPadding", imgui.ImVec2(5, 5));
			self:setDefaultValue(STYLE_TYPE_IMVEC2, "FramePadding", imgui.ImVec2(5, 5));
			self:setDefaultValue(STYLE_TYPE_IMVEC2, "ItemSpacing", imgui.ImVec2(5, 5));
			self:setDefaultValue(STYLE_TYPE_IMVEC2, "ItemInnerSpacing", imgui.ImVec2(2, 2));
			self:setDefaultValue(STYLE_TYPE_IMVEC2, "TouchExtraPadding", imgui.ImVec2(0, 0));
			self:setDefaultValue(STYLE_TYPE_IMVEC2, "ButtonTextAlign", imgui.ImVec2(0.5, 0.5));
			self:setDefaultValue(STYLE_TYPE_IMVEC2, "SelectableTextAlign", imgui.ImVec2(0.5, 0.5));
			self:setDefaultValue(STYLE_TYPE_IMVEC4, "Text", imgui.ImVec4(1.00, 1.00, 1.00, 1.00));
			self:setDefaultValue(STYLE_TYPE_IMVEC4, "TextDisabled", imgui.ImVec4(0.50, 0.50, 0.50, 1.00));
			self:setDefaultValue(STYLE_TYPE_IMVEC4, "WindowBg", common:convertHex2ImVec4("222222"));
			self:setDefaultValue(STYLE_TYPE_IMVEC4, "ChildBg", common:convertHex2ImVec4("2B2B2B"));
			self:setDefaultValue(STYLE_TYPE_IMVEC4, "PopupBg", common:convertHex2ImVec4("222222"));
			self:setDefaultValue(STYLE_TYPE_IMVEC4, "Border", imgui.ImVec4(0.25, 0.25, 0.26, 0.54));
			self:setDefaultValue(STYLE_TYPE_IMVEC4, "BorderShadow", imgui.ImVec4(0.00, 0.00, 0.00, 0.00));
			self:setDefaultValue(STYLE_TYPE_IMVEC4, "FrameBg", common:convertHex2ImVec4("424242"));
			self:setDefaultValue(STYLE_TYPE_IMVEC4, "FrameBgHovered", common:convertHex2ImVec4("2B2B2B"));
			self:setDefaultValue(STYLE_TYPE_IMVEC4, "FrameBgActive", common:convertHex2ImVec4("555554"));
			self:setDefaultValue(STYLE_TYPE_IMVEC4, "ScrollbarBg", imgui.ImVec4(0.12, 0.12, 0.12, 1.00));
			self:setDefaultValue(STYLE_TYPE_IMVEC4, "ScrollbarGrab", common:convertHex2ImVec4("424242"));
			self:setDefaultValue(STYLE_TYPE_IMVEC4, "ScrollbarGrabHovered", common:convertHex2ImVec4("555554"));
			self:setDefaultValue(STYLE_TYPE_IMVEC4, "ScrollbarGrabActive", common:convertHex2ImVec4("333333"));
			self:setDefaultValue(STYLE_TYPE_IMVEC4, "Button", common:convertHex2ImVec4("424242"));
			self:setDefaultValue(STYLE_TYPE_IMVEC4, "ButtonHovered", common:convertHex2ImVec4("555554"));
			self:setDefaultValue(STYLE_TYPE_IMVEC4, "ButtonActive", common:convertHex2ImVec4("333333"));
			self:setDefaultValue(STYLE_TYPE_IMVEC4, "Header", common:convertHex2ImVec4("5B5B5B"));
			self:setDefaultValue(STYLE_TYPE_IMVEC4, "HeaderHovered", common:convertHex2ImVec4("838383"));
			self:setDefaultValue(STYLE_TYPE_IMVEC4, "HeaderActive", common:convertHex2ImVec4("424242"));
			self:setDefaultValue(STYLE_TYPE_IMVEC4, "Separator", imgui.ImVec4(0.47, 0.47, 0.47, 1.00));
			self:setDefaultValue(STYLE_TYPE_IMVEC4, "SeparatorHovered", imgui.ImVec4(0.47, 0.47, 0.47, 1.00));
			self:setDefaultValue(STYLE_TYPE_IMVEC4, "SeparatorActive", imgui.ImVec4(0.47, 0.47, 0.47, 1.00));
			self:setDefaultValue(STYLE_TYPE_IMVEC4, "TextSelectedBg", imgui.ImVec4(1.00, 0.00, 0.00, 0.35));
			self:setDefaultValue(STYLE_TYPE_IMVEC4, "Tab", imgui.ImVec4(0.12, 0.12, 0.12, 1.00));
			self:setDefaultValue(STYLE_TYPE_IMVEC4, "TabHovered", imgui.ImVec4(0.28, 0.28, 0.28, 1.00));
			self:setDefaultValue(STYLE_TYPE_IMVEC4, "TabActive", imgui.ImVec4(0.30, 0.30, 0.30, 1.00));
			self:setDefaultValue(STYLE_TYPE_IMVEC4, "TabUnfocused", imgui.ImVec4(0.07, 0.10, 0.15, 0.97));
			self:setDefaultValue(STYLE_TYPE_IMVEC4, "TabUnfocusedActive", imgui.ImVec4(0.14, 0.26, 0.42, 1.00));
			self:setDefaultValue(STYLE_TYPE_IMVEC4, "DragDropTarget", imgui.ImVec4(1.00, 1.00, 0.00, 0.90));
			self:setDefaultValue(STYLE_TYPE_IMVEC4, "NavHighlight", imgui.ImVec4(0.26, 0.59, 0.98, 1.00));
			self:setDefaultValue(STYLE_TYPE_IMVEC4, "NavWindowingHighlight", imgui.ImVec4(1.00, 1.00, 1.00, 0.70));
			self:setDefaultValue(STYLE_TYPE_IMVEC4, "NavWindowingDimBg", imgui.ImVec4(0.80, 0.80, 0.80, 0.20));
			self:setDefaultValue(STYLE_TYPE_IMVEC4, "ModalWindowDimBg", imgui.ImVec4(0.00, 0.00, 0.00, 0.70));
			self:setDefaultValue(STYLE_TYPE_IMVEC4, "TitleBg", imgui.ImVec4(0.12, 0.12, 0.12, 1.00));
			self:setDefaultValue(STYLE_TYPE_IMVEC4, "TitleBgActive", imgui.ImVec4(0.12, 0.12, 0.12, 1.00));
			self:setDefaultValue(STYLE_TYPE_IMVEC4, "TitleBgCollapsed", imgui.ImVec4(0.12, 0.12, 0.12, 1.00));
			self:setDefaultValue(STYLE_TYPE_IMVEC4, "MenuBarBg", imgui.ImVec4(0.12, 0.12, 0.12, 1.00));
			self:setDefaultValue(STYLE_TYPE_IMVEC4, "CheckMark", imgui.ImVec4(1.00, 1.00, 1.00, 1.00));
			self:setDefaultValue(STYLE_TYPE_IMVEC4, "SliderGrab", common:convertHex2ImVec4("222222"));
			self:setDefaultValue(STYLE_TYPE_IMVEC4, "SliderGrabActive", common:convertHex2ImVec4("222222"));
		end
		return __style__;
	end,
	["imgui.StyleChanger"] = function(...)
		local common = import("Common");
		local style = import("imgui.Style");
		local StyleChanger = {		};
		StyleChanger.__index = StyleChanger;
		function StyleChanger:new(style)
			setmetatable(style, self);
			self.__index = self;
			return style;
		end
		function StyleChanger:apply()
			for property, style in pairs(self) do
				if string.find(tostring(style), "^ImVec2") or type(style)=="number" then
					imgui.GetStyle()[((property))] = style;
				else
					local _internal0;
					if (type(style)=="string") then
						_internal0 = common:convertHex2ImVec4(style);
					else
						_internal0 = style;
					end
					imgui.GetStyle().Colors[((imgui.Col[(property)]))] = _internal0;
				end
			end
		end
		function StyleChanger:reset()
			for property, oldValue in pairs(self) do
				do
					local defaultValue = style.def[(property)];
					if defaultValue ~= nil then
						if string.find(tostring(oldValue), "^ImVec2") or type(oldValue)=="number" then
							imgui.GetStyle()[((property))] = defaultValue;
						else
							imgui.GetStyle().Colors[((imgui.Col[(property)]))] = defaultValue;
						end
					end
				end
			end
		end
		function StyleChanger:update(style)
			for property, value in pairs(style) do
				self[((property))] = value;
			end
		end
		function StyleChanger:getConfigSafeTable()
			local result = {			};
			for property, value in pairs(self) do
				if string.find(tostring(value), "^ImVec2") then
					result[((property))] = {
						value.x, 
						value.y
					};
				elseif type(value)=="number" then
					result[((property))] = value;
				else
					local _internal0;
					if (type(value)=="string") then
						_internal0 = common:convertHex2ImVec4(value);
					else
						_internal0 = value;
					end
					local value = _internal0;
					result[((property))] = {
						value.x, 
						value.y, 
						value.z, 
						value.w
					};
				end
			end
			return result;
		end
		return StyleChanger;
	end,
	["EncodingCompatibility"] = function(...)
		_sampAddChatMessage = sampAddChatMessage;
		function sampAddChatMessage(text, color)
			_sampAddChatMessage(u8:decode(text), color);
		end
		_sampSendChat = sampSendChat;
		function sampSendChat(message)
			_sampSendChat(u8:decode(message));
		end
		_sampSendDialogResponse = sampSendDialogResponse;
		function sampSendDialogResponse(id, button, listItem, input)
			local _internal0;
			if (input) then
				_internal0 = u8:decode(input);
			else
				_internal0 = "";
			end
			_sampSendDialogResponse(id, button, listItem, _internal0);
		end
		function setClipboardText(text)
			imgui.SetClipboardText(text);
		end
	end,
	["Notifications"] = function(...)
		local icons = import("Icons");
		local config = import("Config");
		local common = import("Common");
		function __notifications__:get()
			return self.root;
		end
		function __notifications__:send(notification, scriptMessage)
			if notification == nil then
				notification = {				}
			end
			if scriptMessage then
				return common:sendScriptMessage(scriptMessage);
			end
			if config.root.windows.notifications.use and #self.root<config.root.windows.notifications.maxItems then
				local _internal0;
				if (config.root.windows.notifications.align==ALIGN_CENTER) then
					_internal0 = 149;
				else
					_internal0 = 0;
				end
				table.insert(self.root, {
					icon = notification.icon or icons.ICON_HOME_EMPTY, 
					iconColor = notification.iconColor or imgui.ImVec4(1, 1, 1, 1), 
					title = notification.title or "Title", 
					text = notification.text or "Description", 
					duration = notification.duration or 5, 
					clock = os.clock(), 
					alpha = 1.0, 
					pos = _internal0, 
					buttons = notification.buttons, 
					condition = notification.condition
				});
			end
		end
		function __notifications__:remove(index)
			if index == nil then
				index = 1
			end
			table.remove(self.root, index);
		end
		return __notifications__;
	end,
	["Common"] = function(...)
		local bit = require("bit");
		local assets = import("Assets");
		local common = {		};
		function common:readFileContent(source)
			local handle, err = io.open(source, "r");
			if not err then
				local content = handle:read("*all");
				handle:close();
				return content;
			else
				sampfuncsLog(string.format("{FFA500}[DATE: %s] [CLOCK: %.2f] [GADMIN.DEBUG.WARNING] in <%s>:{FFFFFF} %s", os.date(), os.clock(), "common::readFileContent", "catch error when trying to read some data from "..source.." file"));
				sampfuncsLog(string.format("{FFA500}[DATE: %s] [CLOCK: %.2f] [GADMIN.DEBUG.WARNING] in <%s>:{FFFFFF} %s", os.date(), os.clock(), "common::readFileContent", "error: "..err));
				return "";
			end
		end
		function common:writeInFile(source, str)
			local handle, err = io.open(source, "w");
			if not err then
				handle:write(str);
				handle:close();
			else
				sampfuncsLog(string.format("{FFA500}[DATE: %s] [CLOCK: %.2f] [GADMIN.DEBUG.WARNING] in <%s>:{FFFFFF} %s", os.date(), os.clock(), "common::writeInFile", "catch error when trying to write some data in "..source.." file"));
				sampfuncsLog(string.format("{FFA500}[DATE: %s] [CLOCK: %.2f] [GADMIN.DEBUG.WARNING] in <%s>:{FFFFFF} %s", os.date(), os.clock(), "common::writeInFile", "error: "..err));
				self:sendScriptMessage("Произошла ошибка при записи в файл. Для подробной информации смотрите консоль SAMPFUNCS.");
			end
		end
		function common:makeDirectoryTree(tree)
			for _, directory in ipairs(tree) do
				directory = string.gsub(directory, "/", "\\");
				if not doesDirectoryExist(getWorkingDirectory().."\\"..directory) then
					createDirectory(getWorkingDirectory().."\\"..directory);
				end
			end
		end
		function common:toLowerCase(str)
			str = string.gsub(u8:decode(str), "([A-Z\192-\223Ё])", function(c)
				local _internal0;
				if (c=='ё') then
					_internal0 = 16;
				else
					_internal0 = 32;
				end
				return string.char(string.byte(c)+(_internal0));
			end);
			return u8(str);
		end
		function common:isCursorActive()
			return isCursorActive() or sampIsChatInputActive() or isSampfuncsConsoleActive() or sampIsDialogActive();
		end
		function common:isInputsActive()
			return sampIsChatInputActive() or isSampfuncsConsoleActive() or sampIsDialogActive() or imgui.GetIO().WantTextInput;
		end
		function common:isGamePaused()
			return isGamePaused() or receivedKillFocusEvent;
		end
		function common:sendScriptMessage(message, ...)
			sampAddChatMessage(string.format("[GAdmin v%s]:{FFFFFF} %s", "1.3.1", string.format(message, ...)), 0xFF800000);
		end
		function common:convertHex2ImVec4(hex, alpha)
			if alpha == nil then
				alpha = 255
			end
			local rgb = tonumber(hex, 16);
			local r, g, b, a;
			if (#hex==6) then
				r = bit.band((bit.rshift(rgb, 16)), 255);
				g = bit.band((bit.rshift(rgb, 8)), 255);
				b = bit.band(rgb, 255);
				a = alpha;
			elseif (#hex==8) then
				r, g, b, a = assets:explodeARGB(rgb);
			end
			return imgui.ImVec4(r/255, g/255, b/255, a/255);
		end
		return common;
	end,
	["imgui.windows.FarChat"] = function(...)
		local bit = require("bit");
		local window = import("imgui.Windows");
		local imguiAssets = import("imgui.Assets");
		local StyleChanger = import("imgui.StyleChanger");
		local user = import("game.User");
		local config = import("Config");
		local common = import("Common");
		local icons = import("Icons");
		local assets = import("Assets");
		local sizeX, sizeY = getScreenResolution();
		local randomMessages = {		};
		local function getFarMessages(isMovingWindows)
			math.randomseed(os.clock());
			if isMovingWindows then
				if #randomMessages~=config.root.windows.farChat.maxLines then
					for i = 1, config.root.windows.farChat.maxLines, 1 do
						table.insert(randomMessages, {
							id = math.random(1, sampGetMaxPlayerId(false)), 
							nickname = assets.randomICNicknames[(math.random(#assets.randomICNicknames))], 
							distance = math.random(0, 20), 
							message = assets.randomStrings[(math.random(#assets.randomStrings))], 
							color = -1, 
							time = os.date("*t")
						});
					end
				end
				return randomMessages;
			else
				return farChatMessages;
			end
		end
		window:new("imgui.windows.FarChat", {
			description = "Дальний чат", 
			type = MV_DEFAULT, 
			condition = function()
				return config.root.windows.farChat.use and user:getAloginStatus();
			end, 
			size = {
				x = 0, 
				y = 0
			}, 
			defaultPos = {
				x = 0, 
				y = sizeY/2
			}, 
			initialize = {
				style = StyleChanger:new({
					ItemSpacing = imgui.ImVec2(0, 5), 
					WindowBorderSize = 0, 
					WindowPadding = imgui.ImVec2(0, 2), 
					WindowBg = imgui.ImVec4(0, 0, 0, 0)
				})
			}
		}, function(self)
			self.var.style:apply();
			self:begin(self.id, function()
				local messages = getFarMessages(self.isChangingWindowsPositions);
				for i = math.max(1, #messages-(config.root.windows.farChat.maxLines-1)), #messages, 1 do
					do
						local this = messages[(i)];
						if this ~= nil then
							local strokeSize = config.root.windows.farChat.strokeSize;
							local playerColor = common:convertHex2ImVec4(string.format("%06X", bit.band(sampGetPlayerColor(this.id), 0xFFFFFF)));
							local messageColor = common:convertHex2ImVec4(string.format("%06X", bit.rshift(this.color, 8)));
							local nickname = string.gsub(this.nickname, "_", " ");
							local onNicknameClickNotify = {
								icon = icons.ICON_KEYBOARD, 
								title = "Скопирован никнейм", 
								text = "Успешно скопирован никнейм игрока "..this.nickname.."!", 
								buttons = {
									first = {
										name = "Закрыть", 
										call = function(close)
											close();
										end
									}, 
									second = {
										name = "Следить", 
										call = function(close)
											sampSendChat("/sp "..this.id);
											close();
										end
									}
								}
							};
							local message = this.message;
							if self.isChangingWindowsPositions then
								local _internal0;
								if (#this.message>=140) then
									_internal0 = string.sub(this.message, 1, 140).."...";
								else
									_internal0 = this.message;
								end
								message = _internal0;
							end
							imguiAssets:addStrokedText("> ", strokeSize, playerColor);
							if config.root.windows.farChat.displayTime then
								local time = this.time;
								imgui.SameLine();
								imguiAssets:addStrokedText("[%02d:%02d:%02d] ", strokeSize, playerColor, time.hour, time.min, time.sec);
							end
							imgui.SameLine();
							imguiAssets:addStrokedText(nickname, strokeSize, playerColor);
							imguiAssets:setPreviousItemAbleToCopy(this.nickname, nil, nil, onNicknameClickNotify);
							imgui.SameLine();
							imguiAssets:addStrokedText("[%d]", strokeSize, playerColor, this.id);
							imguiAssets:setPreviousItemAbleToCopy(this.id, "Скопирован айди", "Успешно скопирован айди игрока "..nickname..": "..this.id);
							imgui.SameLine();
							imguiAssets:addStrokedText(": ", strokeSize, playerColor);
							imgui.SameLine();
							imguiAssets:addStrokedText(message, strokeSize, messageColor);
							imguiAssets:setPreviousItemAbleToCopy(this.message);
						end
					end
				end
			end);
			self.var.style:reset();
		end);
	end,
	["imgui.windows.KillList"] = function(...)
		local windows = import("imgui.Windows");
		local imguiAssets = import("imgui.Assets");
		local StyleChanger = import("imgui.StyleChanger");
		local animations = import("imgui.Animations");
		local user = import("game.User");
		local config = import("Config");
		windows:new("imgui.windows.KillList", {
			description = "Улучшенный килл-лист", 
			type = MV_DEFAULT, 
			size = {
				x = 0, 
				y = 0
			}, 
			condition = function()
				return config.root.windows.killList.use and user:getAloginStatus();
			end, 
			initialize = {
				selected = {				}, 
				popup = StyleChanger:new({
					PopupBg = "22222200", 
					PopupBorderSize = 0, 
					FrameRounding = 8, 
					FrameBorderSize = 0, 
					ItemSpacing = imgui.ImVec2(0, 0), 
					WindowPadding = imgui.ImVec2(2, 2)
				}), 
				style = StyleChanger:new({
					WindowBorderSize = 0, 
					WindowBg = imgui.ImVec4(0, 0, 0, 0)
				})
			}
		}, function(self)
			self.strokeSize = config.root.windows.killList.strokeSize;
			self.allowOpenPopup = function(player, color)
				if imgui.IsItemHovered() then
					imgui.GetWindowDrawList():AddLine(imgui.ImVec2(imgui.GetItemRectMin().x, imgui.GetItemRectMax().y), imgui.GetItemRectMax(), imgui.ColorConvertFloat4ToU32(color), 2);
				end
				if imgui.IsItemClicked() and sampIsPlayerConnected(player.id) then
					self.var.selected = player;
					imgui.OpenPopup(self.id..".popup");
				end
			end;
			self.var.style:apply();
			self:begin(self.id, function()
				for index = math.max(1, #killListWindow.kills-(config.root.windows.killList.maxItems-1)), #killListWindow.kills, 1 do
					do
						local item = killListWindow.kills[(index)];
						if item ~= nil then
							local _internal0;
							if (item.nickname.killer) then
								_internal0 = item.nickname.killer;
							else
								_internal0 = item.nickname.killed;
							end
							local _internal1;
							if (item.nickname.killer) then
								_internal1 = item.id.killer;
							else
								_internal1 = item.id.killed;
							end
							local _internal2;
							if (item.nickname.killer) then
								_internal2 = item.color.killer;
							else
								_internal2 = item.color.killed;
							end
							local _internal3;
							if (item.nickname.killer) then
								_internal3 = item.nickname.killed;
							else
								_internal3 = "";
							end
							local _internal4;
							if (item.nickname.killer) then
								_internal4 = item.id.killed;
							else
								_internal4 = -1;
							end
							local _internal5;
							if (item.nickname.killer) then
								_internal5 = item.color.killed;
							else
								_internal5 = imgui.GetStyle().Colors[(imgui.Col.Text)];
							end
							local text = {
								left = {
									nickname = _internal0, 
									id = _internal1, 
									color = _internal2
								}, 
								center = item.weapon, 
								right = {
									nickname = _internal3, 
									id = _internal4, 
									color = _internal5
								}
							};
							local textWidth = 0;
							do
								if config.root.windows.killList.displayTime then
									textWidth = textWidth + bold10:CalcTextSizeA(bold10.FontSize, math.huge, 0.0, string.format("[%02d:%02d:%02d]", item.time.wHour, item.time.wMinute, item.time.wSecond)).x+self.strokeSize+5;
								end
								textWidth = textWidth + bold10:CalcTextSizeA(bold10.FontSize, math.huge, 0.0, text.left.nickname).x+self.strokeSize+5;
								if config.root.windows.killList.displayId and text.left.id~=-1 then
									textWidth = textWidth + bold10:CalcTextSizeA(bold10.FontSize, math.huge, 0.0, string.format("[%d]", text.left.id)).x+self.strokeSize;
								end
								textWidth = textWidth + regular9:CalcTextSizeA(regular9.FontSize, math.huge, 0.0, text.center).x+self.strokeSize;
								if text.right.nickname~="" then
									textWidth = textWidth + bold10:CalcTextSizeA(bold10.FontSize, math.huge, 0.0, text.right.nickname).x+self.strokeSize+5;
									if config.root.windows.killList.displayId and text.right.id~=-1 then
										textWidth = textWidth + bold10:CalcTextSizeA(bold10.FontSize, math.huge, 0.0, string.format("[%d]", text.right.id)).x+self.strokeSize;
									end
								end
							end
							local _internal6 = config.root.windows.killList.textAlignMode;
							if (_internal6 == ALIGN_CENTER) then
								_internal6 = self.size.x/2-textWidth/2;
							else
								if (_internal6 == ALIGN_RIGHT) then
									_internal6 = self.size.x-textWidth-imgui.GetStyle().WindowPadding.x;
								else
									_internal6 = imgui.GetCursorPos().x;
								end
							end
							imgui.SetCursorPosX(_internal6);
							imgui.BeginGroup();
							local cursorPositionY = imgui.GetCursorPos().y;
							imgui.PushFont(bold10);
							if config.root.windows.killList.displayTime then
								imguiAssets:addStrokedText("[%02d:%02d:%02d]", self.strokeSize, nil, item.time.wHour, item.time.wMinute, item.time.wSecond);
								imgui.SameLine(nil, 5);
							end
							imgui.BeginGroup();
							imguiAssets:addStrokedText(text.left.nickname, self.strokeSize, text.left.color);
							if config.root.windows.killList.displayId and text.left.id~=-1 then
								imgui.SameLine(nil, 0);
								imguiAssets:addStrokedText("[%d]", self.strokeSize, text.left.color, text.left.id);
							end
							imgui.EndGroup();
							self.allowOpenPopup(text.left, text.left.color);
							imgui.PopFont();
							imgui.SameLine(nil, 5);
							imgui.SetCursorPosY(imgui.GetCursorPos().y+2);
							imgui.PushFont(regular9);
							imguiAssets:addStrokedText(text.center, self.strokeSize);
							imguiAssets:setPreviousItemAbleToCopy(text.center);
							imgui.PopFont();
							if text.right.nickname~="" then
								imgui.PushFont(bold10);
								imgui.SameLine(nil, 5);
								imgui.SetCursorPosY(cursorPositionY);
								imgui.BeginGroup();
								imguiAssets:addStrokedText(text.right.nickname, self.strokeSize, text.right.color);
								if config.root.windows.killList.displayId and text.right.id~=-1 then
									imgui.SameLine(nil, 0);
									imguiAssets:addStrokedText("[%d]", self.strokeSize, text.right.color, text.right.id);
								end
								imgui.EndGroup();
								self.allowOpenPopup(text.right, text.right.color);
								imgui.PopFont();
							end
							imgui.EndGroup();
							if self.size.x<imgui.GetItemRectSize().x then
								self.size.x = imgui.GetItemRectSize().x+20;
							end
						end
					end
				end
				self.var.popup:apply();
				if imgui.BeginPopup(self.id..".popup", self.flags) then
					imgui.PushFont(regular9);
					for index, command in ipairs(({
						"sp", 
						"pame", 
						"stats"
					})) do
						local _internal1;
						if (index==1) then
							_internal1 = 3;
						else
							local _internal0;
							if (index==3) then
								_internal0 = 12;
							else
								_internal0 = 0;
							end
							_internal1 = (_internal0);
						end
						if animations:button(string.format("/%s %d##%s", command, self.var.selected.id, self.id), imgui.ImVec2(100, 25), _internal1) then
							sampSendChat(string.format("/%s %d", command, self.var.selected.id));
						end
					end
					imgui.PopFont();
				end
				self.var.popup:reset();
			end);
			self.var.style:reset();
		end);
	end,
	["imgui.windows.PlayersNearby"] = function(...)
		local bit = require("bit");
		local window = import("imgui.Windows");
		local imguiAssets = import("imgui.Assets");
		local StyleChanger = import("imgui.StyleChanger");
		local animations = import("imgui.Animations");
		local shadow = import("imgui.drawList.Shadow");
		local user = import("game.User");
		local admins = import("game.Admins");
		local spectator = import("game.Spectator");
		local config = import("Config");
		local common = import("Common");
		local icons = import("Icons");
		local assets = import("Assets");
		local algorithm = import("Algorithm");
		local sizeX, sizeY = getScreenResolution();
		local randomPlayers = {		};
		local function getAllPlayersNearby(isChangingWindowsPositions)
			local playersNearby = {			};
			if not isSampAvailable() then
				return playersNearby;
			end
			if isChangingWindowsPositions then
				if #randomPlayers~=config.root.windows.playersNearby.maxPlayers then
					for i = 1, config.root.windows.playersNearby.maxPlayers, 1 do
						local _internal0;
						if (math.random(0, 100)>75) then
							_internal0 = {
								nickname = {
									ooc = assets.randomOOCNicknames[(math.random(#assets.randomOOCNicknames))]
								}
							};
						else
							_internal0 = nil;
						end
						table.insert(randomPlayers, {
							distance = math.random(1, 230), 
							nickname = assets.randomICNicknames[(math.random(#assets.randomICNicknames))], 
							id = math.random(1, sampGetMaxPlayerId(false)), 
							admin = _internal0
						});
					end
				end
				return randomPlayers;
			end
			for _, player in ipairs(getAllChars()) do
				local result, playerId = sampGetPlayerIdByCharHandle(player);
				if result and playerId~=user:getId() and playerId~=spectator.id then
					local distance = 0.0;
					do
						local fromResult, fromHandle = sampGetCharHandleBySampPlayerId(spectator.id);
						if fromResult or not spectator.status then
							local aX, aY, aZ = getCharCoordinates(player);
							local _internal0;
							if (spectator.status) then
								_internal0 = fromHandle;
							else
								_internal0 = PLAYER_PED;
							end
							local bX, bY, bZ = getCharCoordinates(_internal0);
							distance = getDistanceBetweenCoords3d(aX, aY, aZ, bX, bY, bZ);
						end
					end
					table.insert(playersNearby, {
						distance = distance, 
						nickname = sampGetPlayerNickname(playerId), 
						id = playerId, 
						admin = admins:getAdminById(playerId)
					});
				end
			end
			if config.root.windows.playersNearby.sortByDistance then
				algorithm:bubbleSortByKey(playersNearby, "distance");
			end
			return playersNearby;
		end
		window:new("imgui.windows.PlayersNearby", {
			description = "Список игроков рядом", 
			type = MV_DEFAULT, 
			condition = function()
				return config.root.windows.playersNearby.use and user:getAloginStatus();
			end, 
			size = {
				x = 0, 
				y = 0
			}, 
			defaultPos = {
				x = 0, 
				y = sizeY/2
			}, 
			initialize = {
				style = StyleChanger:new({
					WindowBorderSize = 0, 
					WindowBg = imgui.ImVec4(0, 0, 0, 0)
				}), 
				popup = StyleChanger:new({
					PopupBg = "22222200", 
					PopupBorderSize = 0, 
					FrameRounding = 0, 
					FrameBorderSize = 0, 
					ItemSpacing = imgui.ImVec2(0, 0), 
					WindowPadding = imgui.ImVec2(2, 2)
				})
			}
		}, function(self)
			self.var.style:apply();
			self:begin(self.id, function()
				local players = getAllPlayersNearby(self.isChangingWindowsPositions);
				for i = 1, config.root.windows.playersNearby.maxPlayers, 1 do
					do
						local player = players[(i)];
						if player ~= nil then
							local textSize = nil;
							do
								local text = string.format("%s[%d]", player.nickname, player.id);
								local _internal0;
								if (config.root.windows.playersNearby.showDistance) then
									_internal0 = string.format("[X: %1.f]", player.distance);
								else
									_internal0 = "";
								end
								text = text .. _internal0;
								local _internal1;
								if (config.root.windows.playersNearby.showAdmins and player.admin) then
									_internal1 = string.format("[%s]", player.admin.nickname.ooc);
								else
									_internal1 = "";
								end
								text = text .. _internal1;
								textSize = imgui.CalcTextSize(text);
							end
							local _internal0 = config.root.windows.playersNearby.textAlignMode;
							if (_internal0 == ALIGN_CENTER) then
								_internal0 = self.size.x/2-textSize.x/2;
							else
								if (_internal0 == ALIGN_RIGHT) then
									_internal0 = self.size.x-textSize.x-10;
								else
									_internal0 = imgui.GetCursorPos().x;
								end
							end
							local alignX = _internal0;
							imgui.SetCursorPosX(alignX);
							imgui.BeginGroup();
							local strokeSize = config.root.windows.playersNearby.strokeSize;
							local _internal1;
							if (config.root.windows.playersNearby.playerColorBasedOnClist) then
								_internal1 = common:convertHex2ImVec4(string.format("%06X", bit.band(sampGetPlayerColor(player.id), 0xFFFFFF)));
							else
								_internal1 = nil;
							end
							local color = _internal1;
							local isClicked, isHovered = imguiAssets:addStrokedText("%s[%d]", strokeSize, color, player.nickname, player.id);
							if isHovered then
								imgui.GetWindowDrawList():AddLine(imgui.ImVec2(imgui.GetItemRectMin().x, imgui.GetItemRectMax().y), imgui.GetItemRectMax(), -1, 2);
							end
							if isClicked and not self.isChangingWindowsPositions then
								imgui.OpenPopup("PlayersNearby.popup");
								self.var.popupInformation = {
									nickname = player.nickname, 
									id = player.id
								};
							end
							if config.root.windows.playersNearby.showDistance then
								imgui.SameLine(nil, 0);
								imguiAssets:addStrokedText("[X: %1.f]", strokeSize, color, player.distance);
								imguiAssets:setPreviousItemAbleToCopy(string.format("%1.f", player.distance), "Скопировано расстояние", "Успешно скопировано расстояние: "..string.format("%1.f", player.distance));
							end
							if config.root.windows.playersNearby.showAdmins and player.admin then
								imgui.SameLine(nil, 0);
								imguiAssets:addStrokedText("[%s]", strokeSize, color, player.admin.nickname.ooc);
								imguiAssets:setPreviousItemAbleToCopy(player.admin.nickname.ooc, nil, nil, {
									icon = icons.ICON_KEYBOARD, 
									title = "Никнейм скопирован", 
									text = "Успешно скопирован OOC никнейм у администратора "..player.admin.nickname.ooc.."!", 
									duration = 4, 
									buttons = {
										first = {
											name = "Закрыть", 
											call = function(close)
												close();
											end
										}, 
										second = {
											name = "Упомянуть", 
											call = function()
												if not self.isChangingWindowsPositions then
													sampSetChatInputEnabled(true);
													sampSetChatInputText("/a @"..player.admin.nickname.ooc.." ");
												end
											end
										}
									}
								});
							end
							imgui.EndGroup();
							if imgui.GetItemRectSize().x>self.size.x then
								self.size.x = imgui.GetItemRectSize().x+imgui.GetStyle().WindowPadding.x*2+config.root.windows.playersNearby.strokeSize;
							end
						end
					end
				end
				self.var.popup:apply();
				if imgui.BeginPopup("PlayersNearby.popup", self.flags) then
					imgui.PushFont(regular9);
					imgui.PushStyleVarFloat(imgui.StyleVar.FrameRounding, 8);
					if animations:button("/sp "..tostring(self.var.popupInformation.id).."##PlayersNearby:popup", imgui.ImVec2(70, 25), 3) then
						sampSendChat("/sp "..tostring(self.var.popupInformation.id));
						imgui.CloseCurrentPopup();
					end
					imgui.PopStyleVar();
					if animations:button("/stats "..tostring(self.var.popupInformation.id).."##PlayersNearby:popup", imgui.ImVec2(70, 25), 0) then
						sampSendChat("/stats "..tostring(self.var.popupInformation.id));
						imgui.CloseCurrentPopup();
					end
					imgui.PushStyleVarFloat(imgui.StyleVar.FrameRounding, 8);
					if animations:button("/pame "..tostring(self.var.popupInformation.id).."##PlayersNearby:popup", imgui.ImVec2(70, 25), 12) then
						sampSendChat("/pame "..tostring(self.var.popupInformation.id));
						imgui.CloseCurrentPopup();
					end
					imgui.PopStyleVar();
					imgui.PopFont();
				end
				imgui.EndPopup();
				self.var.popup:reset();
			end);
			self.var.style:reset();
		end);
	end,
	["events.onRemove3DText"] = function(...)
		local spectator = import("game.Spectator");
		sampev.onRemove3DTextLabel = function(id)
			if spectator.information.stage then
				if id==tonumber(string.match(spectator.information.stage, ".*##(%d+)")) then
					spectator.information.stage = "0";
				end
			end
		end;
	end,
	["events.onTogglePlayerControllable"] = function(...)
		local user = import("game.User");
		local config = import("Config");
		sampev.onTogglePlayerControllable = function()
			onTogglePlayerControllableCount = onTogglePlayerControllableCount + 1;
			if isSampAvailable() and sampGetPlayerScore(user:getId())==1 and scriptLoadedWithGame and config.root.additions.autoAdminLogin.use and onTogglePlayerControllableCount==2 then
				sampSendChat("/alogin");
			end
		end;
	end,
	["CommandRequester"] = function(...)
		local user = import("game.User");
		local admins = import("game.Admins");
		local config = import("Config");
		local notify = import("Notifications");
		__commandRequester__.hotKeyCallback = function()
			do
				local self = __commandRequester__;
				if self ~= nil then
					if self.states.frame then
						self:approve();
					end
				end
			end
		end;
		function __commandRequester__:loop()
			if self.states.requester and os.clock()-self.current.clock>=config.root.additions.commandRequester.secondsToHide then
				self:remove();
			end
		end
		function __commandRequester__:setupUserCommandWatcher(command)
			if not self.states.ignoreNextCommands then
				self.lastUserCommand = command;
			end
		end
		function __commandRequester__:setupChatWatcher(text, color)
			if string.find(text, "^{......}%| {......}У Вас нет доступа для использования данной команды%.$") then
				if not string.find(self.lastUserCommand, "^/%S+%s*$") and self:new(user:getId(), self.lastUserCommand) then
					lua_thread.create(function()
						wait(800);
						sampSendChat("/a "..self.lastUserCommand);
					end);
				end
			end
			do
				local id, command = string.match(text, "^%[A%] .+%[(%d+)%]: (/.*)");
				if id ~= nil and command ~= nil then
					if color==866792362 then
						self:new(tonumber(id), command);
					end
				else
					local command, type = self.current.command.name, self.current.command.type;
					if type==COMMAND_REQUEST_TYPE_NO_COMMENTARY then
						do
							local id = string.match(text, "^%[%A%] .*%[%d+]: (%d+), %+$");
							if id ~= nil then
								if tonumber(id)==self.current.id.from then
									self:remove();
								end
							end
						end
					elseif type==COMMAND_REQUEST_TYPE_COMMENTARY then
						do
							local from = string.match(text, "^Администратор .+%. Причина:.*// (.+)$");
							if from ~= nil then
								do
									local admin = admins:getAdminById(self.current.id.from);
									if admin ~= nil then
										if from==admin.nickname.ooc then
											self:remove();
										end
									end
								end
							end
						end
					elseif type==COMMAND_REQUEST_TYPE_ANSWER then
						do
							local to, name = string.match(text, "^%[A%] .+%[%d+%] ответил .+%[(%d+)%]: (%w+) by .+");
							if to ~= nil and name ~= nil then
								if tonumber(to)==tonumber(self.current.id.to) and string.lower(name)==string.lower(self.current.command.splitted.name) then
									self:remove();
								end
							end
						end
					end
				end
			end
		end
		function __commandRequester__:approve()
			local command, args = self.current.command.splitted.name, self.current.command.splitted.args;
			local type = self.current.command.type;
			self.states.ignoreNextCommands = true;
			if type==COMMAND_REQUEST_TYPE_NO_COMMENTARY then
				lua_thread.create(function()
					sampSendChat(string.format("/a %d, +", self.current.id.from));
					wait(800);
					sampSendChat(string.format("/%s %s", command, args));
					self.states.ignoreNextCommands = false;
				end);
			elseif type==COMMAND_REQUEST_TYPE_COMMENTARY then
				do
					local admin = admins:getAdminById(self.current.id.from);
					if admin ~= nil then
						sampSendChat(string.format("/%s %s // %s", command, args, admin.nickname.ooc));
						self.states.ignoreNextCommands = false;
					end
				end
			elseif type==COMMAND_REQUEST_TYPE_ANSWER then
				do
					local admin = admins:getAdminById(self.current.id.from);
					if admin ~= nil then
						lua_thread.create(function()
							sampSendChat(string.format("/ans %d %s by %s", self.current.id.to, string.upper(command), admin.nickname.ooc));
							wait(800);
							sampSendChat(string.format("/%s %s", command, args));
							self.states.ignoreNextCommands = false;
						end);
					end
				end
			end
			self:remove();
		end
		function __commandRequester__:remove()
			self.states.requester = false;
			self.states.frame = false;
			self.current = {
				clock = os.clock(), 
				id = {
					from = -1, 
					to = -1
				}, 
				command = {
					type = COMMAND_REQUEST_TYPE_NONE, 
					splitted = {
						name = "", 
						args = ""
					}
				}
			};
		end
		function __commandRequester__:new(from, command)
			if isGamePaused() or not config.root.additions.commandRequester.use then
				return false;
			end
			local commandType = COMMAND_REQUEST_TYPE_NONE;
			local commandLvl = 0;
			do
				local this = config.root.additions.commandRequester;
				if this ~= nil then
					for _, commandData in ipairs(this.allowedCommands) do
						do
							local command = string.match(command, "^/(%S+)");
							if command ~= nil then
								if string.lower(commandData[(1)])==string.lower(command) then
									commandType, commandLvl = commandData[(2)], commandData[(3)];
								end
							end
						end
					end
				end
			end
			if commandType~=COMMAND_REQUEST_TYPE_NONE and not self.states.requester then
				self.states.requester = true;
				do
					local name, idOrMessage, args = string.match(command, "^/(%S+)%s*(%S*)(.*)");
					if name ~= nil and idOrMessage ~= nil and args ~= nil then
						local passed = false;
						do
							local id = tonumber(idOrMessage);
							if id ~= nil then
								if sampIsPlayerConnected(id) or id==user:getId() then
									passed = true;
									self.current = {
										clock = os.clock(), 
										id = {
											from = from, 
											to = id
										}, 
										command = {
											type = commandType, 
											splitted = {
												name = string.lower(name), 
												args = idOrMessage..args
											}
										}
									};
								end
							end
						end
						if not passed then
							self.current = {
								clock = os.clock(), 
								id = {
									from = from, 
									to = -1
								}, 
								command = {
									type = commandType, 
									splitted = {
										name = string.lower(name), 
										args = idOrMessage..args
									}
								}
							};
						end
						if from~=user:getId() and not self.states.frame and user:getAdminLvl()>=commandLvl then
							self.states.frame = true;
							if config.root.additions.commandRequester.displayType==COMMAND_REQUEST_DISPLAY_NOTIFICATION then
								notify:send({
									title = "Пришла форма", 
									text = command, 
									condition = (function()
										return not self.states.frame;
									end), 
									buttons = {
										first = {
											name = "Закрыть", 
											call = (function()
												self:remove();
											end)
										}, 
										second = {
											name = "Принять", 
											call = (function()
												self:approve();
											end)
										}
									}
								});
							end
							if config.root.additions.commandRequester.soundNotification then
								addOneOffSound(0, 0, 0, 1137);
							end
						end
					end
				end
				return true;
			end
			return false;
		end
		return __commandRequester__;
	end,
	["imgui.Windows"] = function(...)
		local config = import("Config");
		local imguiAssets = import("imgui.Assets");
		local style = import("imgui.Style");
		local movableWindows = import("MovableWindows");
		local windows = {		};
		windows.__index = windows;
		WIN_DEFAULT_POS_CENTER = 1;
		function windows:setRenderStatus(status)
			if status == nil then
				status = false
			end
			self.condition = function()
				return status;
			end;
		end
		function windows:begin(label, callback, flags)
			if flags == nil then
				flags = imgui.WindowFlags.NoMove+imgui.WindowFlags.NoTitleBar+imgui.WindowFlags.NoResize+imgui.WindowFlags.NoScrollbar+imgui.WindowFlags.AlwaysAutoResize
			end
			self.flags = flags;
			style:beginWindowStyleChangeable(self.id);
			imgui.Begin(label, nil, self.flags);
			self.window = {
				pos = self.pos, 
				isFocused = imgui.IsWindowFocused(), 
				isHovered = imgui.IsWindowHovered(), 
				size = imgui.GetWindowSize(), 
				rounding = imgui.GetStyle().WindowRounding, 
				id = self.id, 
				description = self.description
			};
			callback();
			imgui.End();
			style:endWindowStyleChangeable(self.id);
		end
		function windows:new(id, configuration, render)
			local self = setmetatable({			}, self);
			self.description = configuration.description or "No description provided";
			self.condition = configuration.condition or (function()
				return true;
			end);
			self.type = configuration.type or MV_DEFAULT;
			self.defaultPos = configuration.defaultPos or WIN_DEFAULT_POS_CENTER;
			self.id = id;
			self.var = {			};
			self.resolution = {
				x = select(1, getScreenResolution()), 
				y = select(2, getScreenResolution())
			};
			self.executeChangingWindowsPositions = function()
				movableWindows:executeChangingWindowsPositions();
			end;
			self.closeWindow = function()
				self.condition = function()
					return false;
				end;
			end;
			table.insert(registeredWindows, {
				id = id, 
				description = self.description
			});
			if configuration.initialize then
				for key, value in pairs(configuration.initialize) do
					self.var[((key))] = value;
				end
			end
			imgui.OnFrame(function()
				return movableWindows:setupThisWindowCondition(self.type) and self.condition();
			end, function(window)
				window.HideCursor = imguiAssets:getCursorStatus();
				self.isChangingWindowsPositions = movableWindows:isChangingWindowsPositions();
				local _internal0;
				if (type(configuration.size)=="function") then
					_internal0 = configuration.size();
				else
					_internal0 = (configuration.size or ({
						x = 0, 
						y = 0
					}));
				end
				self.size = _internal0;
				imgui.SetNextWindowSize(imgui.ImVec2(self.size.x, self.size.y));
				do
					local pos = config.root.movableWindows[(id)];
					if pos ~= nil then
						imgui.SetNextWindowPos(imgui.ImVec2(pos.x, pos.y));
						self.pos = pos;
					else
						local _internal0;
						if (self.defaultPos==WIN_DEFAULT_POS_CENTER) then
							_internal0 = {
								x = (self.resolution.x-self.size.x)/2, 
								y = (self.resolution.y-self.size.y)/2
							};
						else
							_internal0 = self.defaultPos;
						end
						config.root.movableWindows[((id))] = _internal0;
					end
				end
				render(self);
				movableWindows:setupThisWindow(self.window);
			end);
		end
		return windows;
	end,
	["imgui.windows.AutoCompletion"] = function(...)
		local window = import("imgui.Windows");
		local imguiAssets = import("imgui.Assets");
		local StyleChanger = import("imgui.StyleChanger");
		local style = import("imgui.Style");
		local chatInputBox = import("game.samp.ChatInputBox");
		local greport = import("game.GReport");
		local spectator = import("game.Spectator");
		local user = import("game.User");
		local vehicle = import("game.sa.Vehicle");
		local algorithm = import("Algorithm");
		local config = import("Config");
		local common = import("Common");
		local commands = {
			{
				"/inv", 
				"Открыть инвентарь"
			}, 
			{
				"/mn", 
				"Открыть главное меню"
			}, 
			{
				"/phone", 
				"Достать телефон"
			}, 
			{
				"/sms", 
				"Отправить sms", 
				COMMAND_ARGUMENT_PLAYER_ID
			}, 
			{
				"/pass", 
				"Показать документ удостоверяющий личность", 
				COMMAND_ARGUMENT_PLAYER_ID
			}, 
			{
				"/anim", 
				"Список анимаций"
			}, 
			{
				"/stop", 
				"Сбросить анимацию"
			}, 
			{
				"/pay", 
				"Передать деньги", 
				COMMAND_ARGUMENT_PLAYER_ID
			}, 
			{
				"/update", 
				"Посмотреть последние обновления"
			}, 
			{
				"/gps", 
				"Открыть навигатор"
			}, 
			{
				"/walk", 
				"Автоматическая походка"
			}, 
			{
				"/run", 
				"Автоматический бег"
			}, 
			{
				"/rep", 
				"Задать вопрос администраторам"
			}, 
			{
				"/ask", 
				"Задать вопрос саппортам"
			}, 
			{
				"/channel", 
				"Настроить канал рации"
			}, 
			{
				"/slot", 
				"Настроить подканал рации"
			}, 
			{
				"/id", 
				"Поиск игрока", 
				COMMAND_ARGUMENT_PLAYER_NICKNAME
			}, 
			{
				"/afk", 
				"Узнать, находится ли игрок в AFK", 
				COMMAND_ARGUMENT_PLAYER_ID
			}, 
			{
				"/pame", 
				"Посмотреть описание игрока", 
				COMMAND_ARGUMENT_PLAYER_ID
			}, 
			{
				"/mypame", 
				"Управление описанием персонажа", 
				COMMAND_ARGUMENT_PLAYER_ID
			}, 
			{
				"/dmypame", 
				"Удалить описание персонажа"
			}, 
			{
				"/action", 
				"Установить/Убрать действие своего персонажа"
			}, 
			{
				"/time", 
				"Информация о времени и дате"
			}, 
			{
				"/clearchat", 
				"Очистить чат"
			}, 
			{
				"/headmove", 
				"Отключить поворот головы"
			}, 
			{
				"/blind", 
				"Активировать черный экран (для создания СС)"
			}, 
			{
				"/pattach", 
				"Аттачи для премиум игроков"
			}, 
			{
				"/dm", 
				"Посмотреть урон персонажа", 
				COMMAND_ARGUMENT_PLAYER_ID
			}, 
			{
				"/graffiti", 
				"Нарисовать граффити"
			}, 
			{
				"/charity", 
				"Слить деньги"
			}, 
			{
				"/dice", 
				"Бросить игральную кость"
			}, 
			{
				"/coin", 
				"Подкинуть монету"
			}, 
			{
				"/music", 
				"Слушать музыку"
			}, 
			{
				"/fish", 
				"Ловить рыбу"
			}, 
			{
				"/charact", 
				"Характеристики персонажа"
			}, 
			{
				"/color", 
				"Установить цвет клиста"
			}, 
			{
				"/help", 
				"Открыть помощь по игре"
			}, 
			{
				"/jleave", 
				"Уволиться с работы"
			}, 
			{
				"/bag", 
				"Надеть/снять мешок с головы игрока"
			}, 
			{
				"/tie", 
				"Связать/развязать игрока"
			}, 
			{
				"/notice", 
				"Список уведомлений для персонажа"
			}, 
			{
				"/b", 
				"ООС чат"
			}, 
			{
				"/s", 
				"Кричать"
			}, 
			{
				"/w", 
				"Шептать"
			}, 
			{
				"/r", 
				"Рация"
			}, 
			{
				"/d", 
				"Чат департамента"
			}, 
			{
				"/m", 
				"Мегафон"
			}, 
			{
				"/mic", 
				"Говорить в микрофон"
			}, 
			{
				"/me", 
				"Действия от первого лица"
			}, 
			{
				"/do", 
				"Действия от третьего лица"
			}, 
			{
				"/n", 
				"Писать в радио во время эфира"
			}, 
			{
				"/try", 
				"Попытка действия \"Удачно\" / \"Неудачно\""
			}, 
			{
				"/todo", 
				"Добавляет к сказанным словам деепричастный оборот"
			}, 
			{
				"/ame", 
				"Действие от первого лица над головой"
			}, 
			{
				"/pame", 
				"Описание персонажа от первого лица над головой"
			}, 
			{
				"/pm", 
				"Написать приватное ООС сообщение другому игроку", 
				COMMAND_ARGUMENT_PLAYER_ID
			}, 
			{
				"/r", 
				"Говорить в канал и все принадлежащие ему слоты"
			}, 
			{
				"/rj", 
				"Говорить в рабочую рацию ( рация для работ )"
			}, 
			{
				"/rr", 
				"Говорить в определенный слот канала, в котором Вы находитесь"
			}, 
			{
				"/rl", 
				"Тихо говорить в канал и все принадлежащие ему слоты"
			}, 
			{
				"/rrl", 
				"Тихо говорить в определенный слот канала, в котором вы находитесь"
			}, 
			{
				"/slot", 
				"Изменить подканал в своей рации"
			}, 
			{
				"/channel", 
				"Изменить канал своей рации"
			}, 
			{
				"/hpanel", 
				"Панель управления домом"
			}, 
			{
				"/hevict", 
				"Выселится из дома"
			}, 
			{
				"/sdoor", 
				"Постучать в дверь"
			}, 
			{
				"/tdoor", 
				"Крикнуть в дверь"
			}, 
			{
				"/bpanel", 
				"Панель управления бизнесом"
			}, 
			{
				"/market", 
				"Загрузить/Поставить прилавок"
			}, 
			{
				"/sale", 
				"Продать товар за лавкой"
			}, 
			{
				"/buy", 
				"Закупить товар в лавку"
			}, 
			{
				"/tk", 
				"Активировать тревожную кнопку в бизнесе"
			}, 
			{
				"/dj", 
				"Управление музыкой в бизнесе"
			}, 
			{
				"/bm", 
				"Говорить в микрофон бизнеса"
			}, 
			{
				"/makebm", 
				"Выдать временный микрофон"
			}, 
			{
				"/bskin", 
				"Выдать временный скин", 
				COMMAND_ARGUMENT_PLAYER_ID
			}, 
			{
				"/bmenu", 
				"Посмотреть товары на продаже"
			}, 
			{
				"/mycars", 
				"Список Т/С игрока"
			}, 
			{
				"/cpanel", 
				"Меню управления Т/С"
			}, 
			{
				"/caract", 
				"Описание Т/С"
			}, 
			{
				"/climit", 
				"Управление ограничителем скорости транспорта"
			}, 
			{
				"/cload", 
				"Загрузить Т/С в багажник"
			}, 
			{
				"/park", 
				"Припарковать Т/С"
			}, 
			{
				"/fixcar", 
				"Вернуть Т/С на место парковки"
			}, 
			{
				"/cspeed", 
				"Управление спидометром"
			}, 
			{
				"/csignal", 
				"Поставить Т/С на сигнализацию"
			}, 
			{
				"/ceng", 
				"Завести автомобиль"
			}, 
			{
				"/clock", 
				"Открыть/Закрыть Т/С"
			}, 
			{
				"/chood", 
				"Открыть/Закрыть капот Т/С"
			}, 
			{
				"/ctrunk", 
				"Открыть/Закрыть багажник Т/С"
			}, 
			{
				"/cwindow", 
				"Управление окнами Т/С"
			}, 
			{
				"/roof", 
				"Поднять/Опустить крышу Т/С"
			}, 
			{
				"/ctrailer", 
				"Прицепить/Отцепить дом на колесах"
			}, 
			{
				"/cbreak", 
				"Взломать Т/С"
			}, 
			{
				"/eject", 
				"Выбросить игрока из машины", 
				COMMAND_ARGUMENT_PLAYER_ID
			}, 
			{
				"/fill", 
				"Заправить Т/С"
			}, 
			{
				"/iban", 
				"Перманентная (бессрочная) блокировка игрока", 
				COMMAND_ARGUMENT_PLAYER_ID, 
				COMMAND_ARGUMENT_REASON
			}, 
			{
				"/banip", 
				"Блокировать IP-адрес игрока", 
				COMMAND_ARGUMENT_ANY, 
				COMMAND_ARGUMENT_REASON
			}, 
			{
				"/veh", 
				"Создать админ-транспорт"
			}, 
			{
				"/dveh", 
				"Удалить админ-транспорт"
			}, 
			{
				"/dvehid", 
				"Удалить админ-транспорт по ID"
			}, 
			{
				"/dvehall", 
				"Удалить весь созданный админ-транспорт"
			}, 
			{
				"/aengine", 
				"Изменить статус двигателя в машине"
			}, 
			{
				"/alock", 
				"Изменить статус блокировки дверей в машине"
			}, 
			{
				"/settime", 
				"Сменить время на сервере"
			}, 
			{
				"/makeleader", 
				"Выдать лидерство игроку", 
				COMMAND_ARGUMENT_PLAYER_ID
			}, 
			{
				"/bizinfo", 
				"Информация о бизнесе"
			}, 
			{
				"/setprod", 
				"Установить кол-во продуктов в бизнесе"
			}, 
			{
				"/unretest", 
				"Снять ретест с аккаунта игрока", 
				COMMAND_ARGUMENT_PLAYER_NICKNAME
			}, 
			{
				"/unwarn", 
				"Снять предупреждение с игрока", 
				COMMAND_ARGUMENT_PLAYER_ID
			}, 
			{
				"/unban", 
				"Снять блокировку с игрока", 
				COMMAND_ARGUMENT_PLAYER_NICKNAME
			}, 
			{
				"/unbanip", 
				"Разблокировать IP-адрес"
			}, 
			{
				"/adm", 
				"Панель администратора"
			}, 
			{
				"/a", 
				"Чат администрации"
			}, 
			{
				"/aspawn", 
				"Заспавнить игрока", 
				COMMAND_ARGUMENT_PLAYER_ID
			}, 
			{
				"/tp", 
				"Телепортация по местам"
			}, 
			{
				"/goto", 
				"Телепортироваться к игроку", 
				COMMAND_ARGUMENT_PLAYER_ID
			}, 
			{
				"/gethere", 
				"Телепортировать игрока к себе", 
				COMMAND_ARGUMENT_PLAYER_ID
			}, 
			{
				"/ptop", 
				"Телепортировать игрока к другому игроку", 
				COMMAND_ARGUMENT_PLAYER_ID, 
				COMMAND_ARGUMENT_PLAYER_ID
			}, 
			{
				"/sp", 
				"Зайти в слежку за игроком", 
				COMMAND_ARGUMENT_PLAYER_ID
			}, 
			{
				"/ans", 
				"Ответить игроку", 
				COMMAND_ARGUMENT_PLAYER_ID
			}, 
			{
				"/aa", 
				"OOC чат от лица администратора"
			}, 
			{
				"/aafk", 
				"Игроки в афк"
			}, 
			{
				"/stats", 
				"Статистика игрока", 
				COMMAND_ARGUMENT_PLAYER_ID
			}, 
			{
				"/afrisk", 
				"Список предметов у игрока", 
				COMMAND_ARGUMENT_PLAYER_ID
			}, 
			{
				"/unfreeze", 
				"Разморозить игрока", 
				COMMAND_ARGUMENT_PLAYER_ID
			}, 
			{
				"/weapons", 
				"Список оружия у игрока", 
				COMMAND_ARGUMENT_PLAYER_ID
			}, 
			{
				"/aheal", 
				"Пополняет HP-уровень игрока до 100 единиц", 
				COMMAND_ARGUMENT_PLAYER_ID
			}, 
			{
				"/hp", 
				"Пополнить свое здоровье до полного"
			}, 
			{
				"/sethp", 
				"Установить HP-уровень игроку", 
				COMMAND_ARGUMENT_PLAYER_ID, 
				COMMAND_ARGUMENT_HEALTH
			}, 
			{
				"/setworld", 
				"Установить игроку виртуальный мир", 
				COMMAND_ARGUMENT_PLAYER_ID
			}, 
			{
				"/setint", 
				"Установить игроку интерьер мира", 
				COMMAND_ARGUMENT_PLAYER_ID
			}, 
			{
				"/getcar", 
				"Телепортировать к себе транспорт", 
				COMMAND_ARGUMENT_CVEHID
			}, 
			{
				"/vrepair", 
				"Восстановить HP-уровень транспорта до максимума", 
				COMMAND_ARGUMENT_CVEHID
			}, 
			{
				"/getbuycar", 
				"Телепортировать к себе личный транспорт", 
				COMMAND_ARGUMENT_VEHID
			}, 
			{
				"/vspawn", 
				"Заспавнить автомобиль", 
				COMMAND_ARGUMENT_CVEHID
			}, 
			{
				"/adaction", 
				"Удалить /action"
			}, 
			{
				"/dbuy", 
				"Удалить GBUY обьявление"
			}, 
			{
				"/dpame", 
				"Удалить описание игрока", 
				COMMAND_ARGUMENT_VEHID
			}, 
			{
				"/gfmenu", 
				"Панель управления граффити"
			}, 
			{
				"/gfids", 
				"Список граффти в радиусе 100 метров"
			}, 
			{
				"/gfdell", 
				"Удалить граффити по ID"
			}, 
			{
				"/mute", 
				"Заблокировать IC-чат игрока", 
				COMMAND_ARGUMENT_PLAYER_ID, 
				COMMAND_ARGUMENT_ANY, 
				COMMAND_ARGUMENT_REASON
			}, 
			{
				"/bmute", 
				"Заблокировать OOC-чат игрока", 
				COMMAND_ARGUMENT_PLAYER_ID, 
				COMMAND_ARGUMENT_ANY, 
				COMMAND_ARGUMENT_REASON
			}, 
			{
				"/unbmute", 
				"Разблокировать OOC-чат игрока", 
				COMMAND_ARGUMENT_PLAYER_ID
			}, 
			{
				"/unmute", 
				"Разблокировать IC-чат игрока", 
				COMMAND_ARGUMENT_PLAYER_ID
			}, 
			{
				"/kick", 
				"Отсоединить игрока от сервера", 
				COMMAND_ARGUMENT_PLAYER_ID, 
				COMMAND_ARGUMENT_REASON
			}, 
			{
				"/jail", 
				"Посадить игрока в ДеМорган", 
				COMMAND_ARGUMENT_PLAYER_ID, 
				COMMAND_ARGUMENT_ANY, 
				COMMAND_ARGUMENT_REASON
			}, 
			{
				"/unjail", 
				"Вытащить игрока из ДеМоргана", 
				COMMAND_ARGUMENT_PLAYER_ID
			}, 
			{
				"/warn", 
				"Выдать игроку игровое предупреждение", 
				COMMAND_ARGUMENT_PLAYER_ID, 
				COMMAND_ARGUMENT_REASON
			}, 
			{
				"/makemic", 
				"Выдать игроку системный микрофон", 
				COMMAND_ARGUMENT_PLAYER_ID
			}, 
			{
				"/leave", 
				"Уволить игрока из фракции"
			}, 
			{
				"/house", 
				"Телепортироваться к дому по номеру"
			}, 
			{
				"/biz", 
				"Телепортироваться к бизнесу по номеру"
			}, 
			{
				"/vfuel", 
				"Установить уровень топлива транспорту", 
				COMMAND_ARGUMENT_CVEHID
			}, 
			{
				"/vspawnr", 
				"Заспавнить весь транспорт в радиусе"
			}, 
			{
				"/adm_vehid", 
				"Посмотреть принадлежность транспорта игроку", 
				COMMAND_ARGUMENT_CVEHID
			}, 
			{
				"/ck", 
				"Выдать Character Kill игроку", 
				COMMAND_ARGUMENT_PLAYER_ID
			}, 
			{
				"/unck", 
				"Снять Character Kill игроку", 
				COMMAND_ARGUMENT_PLAYER_NICKNAME
			}, 
			{
				"/pk", 
				"Выдать Player Kill игроку", 
				COMMAND_ARGUMENT_PLAYER_ID
			}, 
			{
				"/ban", 
				"Заблокировать аккаунт игрока", 
				COMMAND_ARGUMENT_PLAYER_ID, 
				COMMAND_ARGUMENT_ANY, 
				COMMAND_ARGUMENT_REASON
			}, 
			{
				"/alogin", 
				"Зайти на админ-дежурство"
			}, 
			{
				"/alogout", 
				"Покинуть админ-дежурство"
			}
		};
		imgui.OnFrame(function()
			return autoCompletion.condition() and config.root.windows.autoCompletion.use;
		end, function(self)
			self.HideCursor = imguiAssets:getCursorStatus();
			self.flags = imgui.WindowFlags.NoMove+imgui.WindowFlags.NoTitleBar+imgui.WindowFlags.NoResize+imgui.WindowFlags.AlwaysAutoResize;
			self.suggestedList = (function()
				local suggestedList = {				};
				local inputText = sampGetChatInputText();
				for _, command in ipairs(commands) do
					if string.find(inputText, "^"..command[(1)].." ") then
						local index = 3;
						while #command>=index do
							if command[(index)]==COMMAND_ARGUMENT_ANY then
								index = index + 1;
							else
								local position = string.rep(" %S*", index-3).." (%S*)";
								do
									local argument = string.match(inputText, "^/%S+"..position.."$");
									if argument ~= nil then
										local _, argumentStart = string.find(inputText, "^/%S+"..position);
										local textBeforeArgument = string.sub(inputText, 1, argumentStart-#argument-1);
										local _internal0 = command[(index)];
										if (_internal0 == COMMAND_ARGUMENT_PLAYER_ID) then
											for itemIndex, id in ipairs(({
												user:getId(), 
												spectator.id, 
												greport.player.id
											})) do
												if id~=-1 then
													do
														local nickname = sampGetPlayerNickname(id);
														if nickname ~= nil then
															table.insert(suggestedList, {
																suggested = textBeforeArgument..' '..id..' ', 
																description = nickname.." ("..({
																	"ваш айди", 
																	"игрок за которым вы следите", 
																	"игрок за которым у вас закреплен GReport"
																})[(itemIndex)]..")"
															});
														end
													end
												end
											end
											if #argument>0 then
												for id = 0, 600, 1 do
													if id~=user:getId() and sampIsPlayerConnected(id) and (id==tonumber(argument) or string.find(id, argument, 1, true)) then
														local nickname = sampGetPlayerNickname(id);
														table.insert(suggestedList, {
															suggested = textBeforeArgument..' '..id..' ', 
															description = nickname
														});
													end
												end
											end
										else
											if (_internal0 == COMMAND_ARGUMENT_PLAYER_NICKNAME) then
												for itemIndex, nickname in ipairs(({
													spectator.nickname, 
													greport.player.nickname
												})) do
													if #nickname>0 then
														table.insert(suggestedList, {
															suggested = textBeforeArgument..' '..nickname..' ', 
															description = ({
																"Никнейм игрока за которым вы следите", 
																"Никнейм игрока за которым у вас закреплен GReport"
															})[(itemIndex)]
														});
													end
												end
												if #argument>0 then
													for id = 0, 600, 1 do
														if id~=user:getId() and sampIsPlayerConnected(id) then
															local nickname = sampGetPlayerNickname(id);
															if string.find(common:toLowerCase(nickname), common:toLowerCase(argument), 1, true) then
																table.insert(suggestedList, {
																	suggested = textBeforeArgument..' '..nickname..' ', 
																	description = "Предложенный никнейм игрока"
																});
															end
														end
													end
												end
											else
												if (_internal0 == COMMAND_ARGUMENT_HEALTH) then
													for _, health in ipairs(({
														10, 
														20, 
														30, 
														40, 
														50, 
														60, 
														70, 
														80, 
														90, 
														100
													})) do
														if string.find(tostring(health), argument, 1, true) then
															table.insert(suggestedList, {
																suggested = textBeforeArgument..' '..health..' ', 
																description = "Предложенный уровень здоровья"
															});
														end
													end
												else
													if (_internal0 == COMMAND_ARGUMENT_REASON) then
														for _, commandList in ipairs(({
															{
																"iban", 
																"ban", 
																"warn", 
																"jail", 
																{
																	"Cheat", 
																	"DM", 
																	"NonRP drive", 
																	"Неролевое поведение"
																}
															}, 
															{
																"mute", 
																"bmute", 
																{
																	"Оффтоп"
																}
															}, 
															{
																"kick", 
																{
																	"AFK on ROAD", 
																	"AFK without ESC", 
																	"AFK public place"
																}
															}
														})) do
															for _, commandName in ipairs(commandList) do
																if type(commandName)=="string" and ('/'..commandName)==command[(1)] then
																	for _, reason in ipairs(commandList[(#commandList)]) do
																		if string.find(common:toLowerCase(reason), common:toLowerCase(argument), 1, true) then
																			table.insert(suggestedList, {
																				suggested = textBeforeArgument..' '..reason..' ', 
																				description = "Предложенное наказание"
																			});
																		end
																	end
																end
															end
														end
													else
														if ((_internal0 == COMMAND_ARGUMENT_VEHID)) and spectator.status then
															for vehId in string.gmatch(spectator:getInformation().vehicle, "%d+") do
																local _internal0;
																if (#argument==0) then
																	_internal0 = true;
																else
																	_internal0 = string.find(vehId, argument, 1, true);
																end
																if _internal0 then
																	table.insert(suggestedList, {
																		suggested = textBeforeArgument..' '..vehId..' ', 
																		description = "Предложенная машина игрока за которым вы следите"
																	});
																end
															end
														else
															if (_internal0 == COMMAND_ARGUMENT_CVEHID) then
																local function insertSuggestionByPlayerVehicle(handle, description)
																	if isCharInAnyCar(handle) then
																		do
																			local car = storeCarCharIsInNoSave(handle);
																			if car ~= nil then
																				local result, vehId = sampGetVehicleIdByCarHandle(car);
																				if result then
																					local carId = getCarModel(car);
																					local carName = vehicle:getName(carId);
																					table.insert(suggestedList, {
																						suggested = textBeforeArgument..' '..vehId..' ', 
																						description = carName.." ("..description..")"
																					});
																				end
																			end
																		end
																	end
																end
																insertSuggestionByPlayerVehicle(PLAYER_PED, "машина в которой вы сидите");
																if spectator.status then
																	local result, handle = spectator:getHandle();
																	if result then
																		insertSuggestionByPlayerVehicle(handle, "машина игрока за которым вы следите");
																	end
																end
																local streamVehicles = {																};
																for _, car in ipairs(getAllVehicles()) do
																	local result, vehId = sampGetVehicleIdByCarHandle(car);
																	if result then
																		local carId = getCarModel(car);
																		local carName = vehicle:getName(carId);
																		local handle = PLAYER_PED;
																		if spectator.status then
																			local result, spectatorHandle = spectator:getHandle();
																			if result then
																				handle = spectatorHandle;
																			end
																		end
																		local dAX, dAY, dAZ = getCharCoordinates(handle);
																		local dBX, dBY, dBZ = getCarCoordinates(car);
																		local distance = getDistanceBetweenCoords3d(dAX, dAY, dAZ, dBX, dBY, dBZ);
																		if distance~=0.0 then
																			table.insert(streamVehicles, {
																				suggested = textBeforeArgument..' '..vehId..' ', 
																				description = string.format("%s[X: %1.f] (машина рядом)", carName, distance), 
																				distance = distance
																			});
																		end
																	end
																end
																algorithm:bubbleSortByKey(streamVehicles, "distance");
																for _, item in ipairs(streamVehicles) do
																	table.insert(suggestedList, item);
																end
															end
														end
													end
												end
											end
										end
									end
								end
								index = index + 1;
							end
						end
					elseif string.find("/"..command[(1)], inputText, 1, true) then
						table.insert(suggestedList, {
							suggested = command[(1)]..' ', 
							description = command[(2)]
						});
					end
				end
				return suggestedList;
			end)();
			self.style = StyleChanger:new({
				WindowBorderSize = 0, 
				WindowPadding = imgui.ImVec2(0, 0), 
				WindowBg = imgui.ImVec4(0, 0, 0, 0), 
				ScrollbarSize = 5, 
				ScrollbarBg = imgui.ImVec4(0, 0, 0, 0)
			});
			autoCompletion.commandsLength = #self.suggestedList;
			if autoCompletion.commandsLength<autoCompletion.position then
				autoCompletion.position = 1;
			end
			if #self.suggestedList>0 then
				imgui.SetNextWindowPos(imgui.ImVec2(chatInputBox:getPosition()));
				imgui.SetNextWindowSizeConstraints(imgui.ImVec2(0, 0), imgui.ImVec2(math.huge, 300));
				self.style:apply();
				style:beginWindowStyleChangeable("imgui.windows.AutoCompletion");
				imgui.Begin("imgui.windows.AutoCompletion", nil, self.flags);
				for pos, complete in ipairs(self.suggestedList) do
					imgui.PushFont(bold10);
					local _pos = imgui.GetCursorPos();
					local itemCursorPos = imgui.GetCursorPos();
					if imgui.Selectable("##"..complete.suggested..complete.description, autoCompletion.position==pos) or (autoCompletion.position==pos and isKeyJustPressed(VK_TAB)) then
						sampSetChatInputText(complete.suggested);
						autoCompletion.position = pos;
					end
					imgui.SetCursorPos(_pos);
					imgui.BeginGroup();
					imgui.PushFont(bold10);
					imguiAssets:addStrokedText(complete.suggested, config.root.windows.autoCompletion.strokeSize);
					local _internal0;
					if (#string.match(complete.suggested, "(%s*)$")>0) then
						_internal0 = 2;
					else
						_internal0 = 5;
					end
					imgui.SameLine(nil, _internal0);
					imgui.SetCursorPosY(imgui.GetCursorPos().y+1.5);
					imgui.PushFont(regular10);
					imguiAssets:addStrokedText(complete.description, config.root.windows.autoCompletion.strokeSize);
					imgui.PopFont();
					imgui.PopFont();
					imgui.EndGroup();
					if autoCompletion.position==pos and not (imgui.IsWindowHovered() or imgui.IsMouseDown(0)) then
						if (itemCursorPos.y-imgui.GetScrollY())>=imgui.GetWindowHeight() then
							imgui.SetScrollY(itemCursorPos.y);
						elseif itemCursorPos.y<=imgui.GetScrollY() then
							imgui.SetScrollY(itemCursorPos.y);
						end
					end
					imgui.PopFont();
				end
				imgui.End();
				style:endWindowStyleChangeable("imgui.windows.AutoCompletion");
				self.style:reset();
			end
		end);
	end,
	["events.onPassengerSync"] = function(...)
		local bit = require("bit");
		local spectator = import("game.Spectator");
		sampev.onPassengerSync = function(id, data)
			if id==spectator.id then
				if spectator.platform==PLATFORM_PC then
					for _, arguments in ipairs(({
						{
							"w", 
							(bit.band(data.keysData, 0x8))==0x8
						}, 
						{
							"a", 
							data.leftRightKeys==0xFF80
						}, 
						{
							"s", 
							(bit.band(data.keysData, 0x20))==0x20
						}, 
						{
							"d", 
							data.leftRightKeys==0x80
						}, 
						{
							"h", 
							(bit.band(data.keysData, 0x2))==0x2
						}, 
						{
							"space", 
							(bit.band(data.keysData, 0x80))==0x80
						}, 
						{
							"ctrl", 
							(bit.band(data.keysData, 0x1))==0x1
						}, 
						{
							"alt", 
							(bit.band(data.keysData, 0x4))==0x4
						}, 
						{
							"q", 
							(bit.band(data.keysData, 0x100))==0x100
						}, 
						{
							"e", 
							(bit.band(data.keysData, 0x40))==0x40
						}, 
						{
							"f", 
							(bit.band(data.keysData, 0x10))==0x10
						}, 
						{
							"up", 
							data.upDownKeys==0xFF80
						}, 
						{
							"down", 
							data.upDownKeys==0x80
						}
					})) do
						spectator:setKeyStatus(SYNC_KEYS_VEHICLE, table.unpack(arguments));
					end
				end
			end
		end;
	end,
	["events.onPlayerSync"] = function(...)
		local bit = require("bit");
		local spectator = import("game.Spectator");
		sampev.onPlayerSync = function(id, data)
			if id==spectator.id then
				if spectator.platform==PLATFORM_PC then
					for _, arguments in ipairs(({
						{
							"w", 
							data.upDownKeys==0xFF80
						}, 
						{
							"a", 
							data.leftRightKeys==0xFF80
						}, 
						{
							"s", 
							data.upDownKeys==0x80
						}, 
						{
							"d", 
							data.leftRightKeys==0x80
						}, 
						{
							"alt", 
							(bit.band(data.keysData, 0x400))==0x400
						}, 
						{
							"shift", 
							(bit.band(data.keysData, 0x8))==0x8
						}, 
						{
							"space", 
							(bit.band(data.keysData, 0x20))==0x20
						}, 
						{
							"f", 
							(bit.band(data.keysData, 0x10))==0x10
						}, 
						{
							"c", 
							(bit.band(data.keysData, 0x2))==0x2
						}, 
						{
							"rmb", 
							(bit.band(data.keysData, 0x4))==0x4
						}, 
						{
							"lmb", 
							(bit.band(data.keysData, 0x80))==0x80
						}
					})) do
						spectator:setKeyStatus(SYNC_KEYS_PLAYER, table.unpack(arguments));
					end
				elseif spectator.platform==PLATFORM_ANDROID then
					for _, arguments in ipairs(({
						{
							"hit", 
							(bit.band(data.keysData, 0x4))==0x4
						}, 
						{
							"alt", 
							(bit.band(data.keysData, 0x400))==0x400
						}, 
						{
							"f", 
							(bit.band(data.keysData, 0x10))==0x10
						}, 
						{
							"jump / run", 
							(bit.band(data.keysData, 0x8))==0x8
						}, 
						{
							"aim", 
							(bit.band(data.keysData, 0x80))==0x80
						}
					})) do
						spectator:setKeyStatus(SYNC_KEYS_PLAYER, table.unpack(arguments));
					end
					spectator:setupJoyStickWatcher(data.leftRightKeys, data.upDownKeys);
				end
			end
		end;
	end,
	["events.onDisplayGameText"] = function(...)
		local spectator = import("game.Spectator");
		sampev.onDisplayGameText = function(style, time, text)
			if text=="~b~Some kind of bug" then
				spectator:exit();
			elseif text=="~b~Spectate Exit" then
				spectator:exit();
			end
		end;
	end,
	["events.onPlayerChatBubble"] = function(...)
		local config = import("Config");
		sampev.onPlayerChatBubble = function(playerId, color, distance, duration, message)
			if config.root.windows.farChat.use then
				if color==-413892353 then
					return {
						playerId, 
						color, 
						distance, 
						duration, 
						message
					};
				end
				for _, ignoredText in ipairs(config.root.windows.farChat.ignore) do
					if string.find(u8(message), ignoredText) then
						return {
							playerId, 
							color, 
							distance, 
							duration, 
							message
						};
					end
				end
				do
					local it = farChatMessages[(#farChatMessages)];
					if it ~= nil then
						if os.clock()-it.clock<=config.root.windows.farChat.delay and u8(message)==it.message and playerId==it.id then
							return {
								playerId, 
								color, 
								distance, 
								duration, 
								message
							};
						end
					end
				end
				table.insert(farChatMessages, {
					id = playerId, 
					nickname = sampGetPlayerNickname(playerId), 
					color = color, 
					distance = distance, 
					message = u8(message), 
					clock = os.clock(), 
					time = os.date("*t")
				});
			end
		end;
	end,
	["imgui.HotKey"] = function(...)
		local bit = require("bit");
		local config = import("Config");
		local common = import("Common");
		local assets = import("Assets");
		local animations = import("imgui.Animations");
		local HotKey = {		};
		HotKey.__index = HotKey;
		function HotKey:isLargeKey(key)
			local _internal0 = key;
			if (_internal0 == VK_SHIFT) or (_internal0 == VK_SPACE) or (_internal0 == VK_CONTROL) or (_internal0 == VK_LMENU) or (_internal0 == VK_MENU) or (_internal0 == VK_LMENU) or (_internal0 == VK_RMENU) or (_internal0 == VK_RCONTROL) or (_internal0 == VK_LCONTROL) or (_internal0 == VK_LSHIFT) or (_internal0 == VK_RSHIFT) or (_internal0 == VK_RETURN) then
				_internal0 = true;
			else
				_internal0 = false;
			end
			return _internal0;
		end
		function HotKey:sortKeys(keys)
			if #keys==2 and not self:isLargeKey(keys[(1)]) and self:isLargeKey(keys[(2)]) then
				keys[((1))], keys[(2)] = keys[(2)], keys[(1)];
			end
		end
		function HotKey:keysToString(keys, separator)
			if separator == nil then
				separator = " + "
			end
			if #keys==0 then
				return "-НЕТ-";
			end
			local stringKeys = "";
			for index, id in ipairs(keys) do
				local _internal0;
				if (index==#keys) then
					_internal0 = "";
				else
					_internal0 = separator;
				end
				local separator = _internal0;
				stringKeys = stringKeys .. vkeys.id_to_name(id)..separator;
			end
			return stringKeys;
		end
		function HotKey:getDownKeys(limit)
			if limit == nil then
				limit = 2
			end
			local keys = {			};
			for _, key in pairs(vkeys) do
				if #keys~=limit and key~=VK_LBUTTON and key~=VK_RBUTTON and key~=VK_MBUTTON and key~=VK_LWIN and KEY~=VK_RWIN then
					if isKeyDown(key) and (key==VK_MENU or key==VK_CONTROL or key==VK_SHIFT or key==VK_LMENU or key==VK_RMENU or key==VK_RCONTROL or key==VK_LCONTROL or key==VK_LSHIFT or key==VK_RSHIFT) then
						if key~=VK_MENU and key~=VK_CONTROL and key~=VK_SHIFT then
							table.insert(keys, key);
						end
					end
					if isKeyDown(key) and (key~=VK_MENU and key~=VK_CONTROL and key~=VK_SHIFT and key~=VK_LMENU and key~=VK_RMENU and key~=VK_RCONTROL and key~=VK_LCONTROL and key~=VK_LSHIFT and key~=VK_RSHIFT) then
						table.insert(keys, key);
					end
				end
			end
			self:sortKeys(keys);
			return keys;
		end
		function HotKey:setupWatcher(event, wparam, lparam)
			if event==wm.WM_KILLFOCUS and changingHotKey then
				self:stopChangingKeys();
			end
			if event==wm.WM_KEYDOWN or event==wm.WM_SYSKEYDOWN then
				if changingHotKey then
					consumeWindowMessage(true, false);
					if wparam==VK_ESCAPE then
						self:stopChangingKeys();
					end
				else
					if not common:isInputsActive() then
						local _internal0 = wparam;
						if (_internal0 == VK_CONTROL) or (_internal0 == VK_MENU) or (_internal0 == VK_SHIFT) then
							_internal0 = assets:mapScanCodeToVKey(bit.rshift((bit.band(lparam, 0xFF0000)), 16));
						else
							_internal0 = wparam;
						end
						local key = _internal0;
						for _, hotKey in ipairs(allHotKeys) do
							if (#hotKey.keys==1 and key==hotKey.keys[(1)]) or (#hotKey.keys==2 and isKeyDown(hotKey.keys[(1)]) and key==hotKey.keys[(2)]) then
								do
									local item = hotKeysCallbacks[(hotKey.id)];
									if item ~= nil then
										if not item.keysDown then
											item.callback();
											item.keysDown = true;
											consumeWindowMessage(true, true);
										end
									end
								end
							end
						end
					end
				end
			elseif event==wm.WM_KEYUP or event==wm.WM_SYSKEYUP then
				for _, hotKey in ipairs(allHotKeys) do
					do
						local item = hotKeysCallbacks[(hotKey.id)];
						if item ~= nil then
							if item.keysDown then
								item.keysDown = false;
							end
						end
					end
				end
			end
		end
		function HotKey:stopChangingKeys()
			for id, item in pairs(UI_ANIMATED_HOTKEY) do
				if item.active then
					for _, hotKey in ipairs(allHotKeys) do
						if id==hotKey.id then
							hotKey:changeKeysTo(hotKey.keys);
							item.active = false;
							changingHotKey = item.active;
						end
					end
				end
			end
		end
		function HotKey:isKeysDefined(sourceKeys, exceptId)
			self:sortKeys(sourceKeys);
			for id, targetKeys in pairs(hotKeysCallbacks) do
				self:sortKeys(targetKeys);
				if id~=exceptId and table.concat(sourceKeys, " ")==table.concat(targetKeys.keys, " ") then
					return true, id;
				end
			end
			return false, "";
		end
		function HotKey:new(id, keys, description, ignoreActiveCursor)
			if ignoreActiveCursor == nil then
				ignoreActiveCursor = true
			end
			self:sortKeys(keys);
			if config.root.hotKeys[(id)] then
				keys = config.root.hotKeys[(id)];
			else
				config.root.hotKeys[((id))] = keys;
			end
			return setmetatable({
				keys = keys, 
				id = id, 
				cursor = ignoreActiveCursor, 
				description = description
			}, self);
		end
		function HotKey:__tostring()
			return self:keysToString(self.keys);
		end
		function HotKey:changeKeysTo(keys)
			self:sortKeys(keys);
			if hotKeysCallbacks[(self.id)].keys then
				config.root.hotKeys[((self.id))], self.keys, hotKeysCallbacks[(self.id)].keys = keys, keys, keys;
			end
			return self;
		end
		function HotKey:registerCallback(callback)
			if not hotKeysCallbacks[(self.id)] then
				hotKeysCallbacks[((self.id))] = {
					keys = self.keys, 
					callback = callback, 
					keysDown = false
				};
				table.insert(allHotKeys, self);
			end
			return self;
		end
		function HotKey:render(defaultSize, onChangedCallback)
			if defaultSize == nil then
				defaultSize = imgui.ImVec2(80, 25)
			end
			if not UI_ANIMATED_HOTKEY then
				UI_ANIMATED_HOTKEY = {				};
			end
			if not UI_ANIMATED_HOTKEY[(self.id)] then
				UI_ANIMATED_HOTKEY[((self.id))] = {
					label = tostring(self), 
					active = false, 
					keys = {					}, 
					tick = {
						status = false, 
						clock = os.clock()
					}
				};
			end
			do
				local this = UI_ANIMATED_HOTKEY[(self.id)];
				if this ~= nil then
					local size = imgui.ImVec2(math.max(defaultSize.x, imgui.GetStyle().FramePadding.x*2+imgui.CalcTextSize(this.label).x), defaultSize.y);
					local _internal0;
					if (#this.keys>0 and not self:isKeysDefined(self:getDownKeys(), self.id)) then
						_internal0 = self:keysToString(this.keys);
					else
						_internal0 = this.label;
					end
					local buttonText = _internal0;
					if animations:button(string.format("%s##%s", buttonText, self.id), size) and not changingHotKey then
						this.active = not this.active;
						changingHotKey = this.active;
						this.tick.clock = os.clock();
					end
					if this.active then
						if #this.keys>0 then
							for _, key in ipairs(this.keys) do
								if wasKeyReleased(key) then
									self:changeKeysTo(this.keys);
									this.active = false;
									changingHotKey = this.active;
									hotKeysCallbacks[((self.id))].keys = this.keys;
									local _internal0 = onChangedCallback;
									if _internal0 then
										_internal0(self);
									end
								end
							end
						end
						do
							local keys = self:getDownKeys();
							if keys ~= nil then
								animations:hint("Эти клавиши уже зарегистрированы!", function()
									return #keys>0 and self:isKeysDefined(keys, self.id);
								end, nil, common:convertHex2ImVec4("E46876"));
								if #keys==0 or (#keys>0 and self:isKeysDefined(keys, self.id)) then
									if os.clock()-this.tick.clock>=0.5 then
										this.tick.status = not this.tick.status;
										this.tick.clock = os.clock();
									end
									local _internal1;
									if (#keys>0) then
										_internal1 = self:keysToString(self:getDownKeys());
									else
										local _internal0;
										if (this.tick.status) then
											_internal0 = "";
										else
											_internal0 = "Ожидание";
										end
										_internal1 = (_internal0);
									end
									this.label = _internal1;
								else
									this.label = self:keysToString(this.keys);
									if #this.keys<#keys then
										this.keys = keys;
									end
								end
							end
						end
					else
						this.keys = {						};
						this.label = tostring(self);
					end
				end
			end
		end
		return HotKey;
	end,
	["events.onPlayerJoin"] = function(...)
		local notify = import("Notifications");
		local icons = import("Icons");
		local assets = import("Assets");
		local config = import("Config");
		sampev.onPlayerJoin = function(id, color, isNpc, nickname)
			if config.root.windows.playerChecker.use and not isNpc then
				for _, player in ipairs(config.root.windows.playerChecker.players) do
					if player.nickname==nickname then
						do
							local notificationType = config.root.windows.playerChecker.notificationType;
							if notificationType ~= nil then
								if notificationType~=NOTIFICATION_TYPE_NONE then
									local _internal0;
									if (config.root.windows.playerChecker.displayOfflinePlayers) then
										_internal0 = "Теперь он отображается подключенным в чекере.";
									else
										_internal0 = "Теперь он отображается в чекере.";
									end
									local _internal1;
									if (notificationType==NOTIFICATION_TYPE_SCRIPT_MESSAGE) then
										_internal1 = (string.gsub(nickname, "_", " ").." зашел в игру.");
									else
										_internal1 = nil;
									end
									notify:send({
										title = string.gsub(nickname, "_", " ").." зашел в игру.", 
										text = _internal0, 
										icon = icons.ICON_PERSON, 
										duration = 5
									}, _internal1);
								end
							end
						end
						break;
					end
				end
			end
			local CONNECTION_LOG_INDEX = 5;
			table.insert(allowedLogs[(CONNECTION_LOG_INDEX)][(2)], {
				time = assets:getLocalTime(), 
				text = string.format("%s[%d] подключился к игре.", nickname, id)
			});
		end;
	end,
	["events.onInitGame"] = function(...)
		sampev.onInitGame = function()
			scriptLoadedWithGame = true;
			onTogglePlayerControllableCount = 0;
		end;
	end,
	["events.onScriptTerminate"] = function(...)
		local config = import("Config");
		local hook = import("Hook");
		local assets = import("Assets");
		function onScriptTerminate(scr, quitGame)
			if scr==script.this then
				config:saveIfChanged();
				hook:unref();
				assets:workInBackground(false);
			end
		end
	end,
	["events.onReceivePacket"] = function(...)
		local user = import("game.User");
		function onReceivePacket(id)
			if id==36 or id==32 or id==37 then
				user:setAloginStatus(false);
			end
		end
	end,
	["events.onBulletSync"] = function(...)
		local spectator = import("game.Spectator");
		local config = import("Config");
		sampev.onBulletSync = function(id, data)
			if id==spectator.id then
				local information = spectator:getInformation();
				local _internal0;
				if (data.targetType==0 or data.targetType==3) then
					_internal0 = 0;
				else
					_internal0 = 1;
				end
				local shotHit = _internal0;
				spectator:setInformation({
					shotTotal = information.shot.total+1, 
					shotHit = information.shot.hit+shotHit
				});
			end
			if config.root.additions.tracers.use then
				if data.target.x==-1 or data.target.y==-1 or data.target.z==-1 then
					return true;
				end
				if config.root.additions.tracers.showOnlyForSpectator then
					if spectator.status and (id~=spectator.id and data.targetId~=spectator.id) then
						return true;
					end
				end
				bulletData.lastId = bulletData.lastId + 1;
				if bulletData.lastId<1 or bulletData.lastId>config.root.additions.tracers.maxLines then
					bulletData.lastId = 1;
				end
				do
					local id = bulletData.lastId;
					if id ~= nil then
						bulletData[((id))].enable = true;
						bulletData[((id))].type = data.targetType;
						bulletData[((id))].time = os.time()+15;
						bulletData[((id))].o.x, bulletData[(id)].o.y, bulletData[(id)].o.z = data.origin.x, data.origin.y, data.origin.z;
						bulletData[((id))].t.x, bulletData[(id)].t.y, bulletData[(id)].t.z = data.target.x, data.target.y, data.target.z;
					end
				end
			end
		end;
	end,
	["events.onCreate3DText"] = function(...)
		local spectator = import("game.Spectator");
		sampev.onCreate3DText = function(id, color, position, distance, testLOS, attachedPlayerId, attachedVehicleId, text)
			local _internal0;
			if (attachedPlayerId==65535) then
				_internal0 = nil;
			else
				_internal0 = attachedPlayerId;
			end
			local attachedPlayerId = _internal0;
			local text = u8(text);
			if attachedPlayerId then
				if attachedPlayerId==tonumber(spectator.id) then
					local _internal1;
					if (string.find(text, "%(%( Данный персонаж ранен %d+ раз%(%-а%) %- /dm %d+ %)%)")) then
						_internal1 = "1##"..tostring(id);
					else
						local _internal0;
						if string.find(text, "%(%( ДАННЫЙ ПЕРСОНАЖ .+ %)%)") then
							_internal0 = "2##"..tostring(id);
						else
							_internal0 = "0##"..tostring(id);
						end
						_internal1 = (_internal0);
					end
					spectator:setInformation({
						stage = _internal1
					});
				end
			end
		end;
	end,
	["events.onShowTextDraw"] = function(...)
		local spectator = import("game.Spectator");
		sampev.onShowTextDraw = function(id, data)
			if string.find(data.text, "~y~%(%d+%)") then
				spectator.textDrawId = id;
				spectator:setTo(tonumber(string.match(data.text, "~y~%(%d+%)")));
				return false;
			end
			if string.find(data.text, "ID Akkay") then
				return false;
			end
		end;
	end,
	["events.onSetPlayerName"] = function(...)
		local notify = import("Notifications");
		local icons = import("Icons");
		local config = import("Config");
		local assets = import("Assets");
		sampev.onSetPlayerName = function(id, nickname, success)
			local sourceNickname = sampGetPlayerNickname(id);
			if config.root.windows.playerChecker.use and not success then
				for _, player in ipairs(config.root.windows.playerChecker.players) do
					if player.nickname==nickname then
						do
							local notificationType = config.root.windows.playerChecker.notificationType;
							if notificationType ~= nil then
								if notificationType~=NOTIFICATION_TYPE_NONE then
									local _internal0;
									if (config.root.windows.playerChecker.displayOfflinePlayers) then
										_internal0 = "Теперь он отображается подключенным в чекере.";
									else
										_internal0 = "Теперь он отображается в чекере.";
									end
									local _internal1;
									if (notificationType==NOTIFICATION_TYPE_SCRIPT_MESSAGE) then
										_internal1 = (string.gsub(nickname, "_", " ").." зашел в игру.");
									else
										_internal1 = nil;
									end
									notify:send({
										title = nickname.." зашел в игру.", 
										text = _internal0, 
										icon = icons.ICON_PERSON, 
										duration = 5
									}, _internal1);
								end
							end
						end
						break;
					end
				end
			end
			local CONNECTION_LOG_INDEX = 5;
			table.insert(allowedLogs[(CONNECTION_LOG_INDEX)][(2)], {
				time = assets:getLocalTime(), 
				text = string.format("%s[%d] сменил никнейм на %s.", sourceNickname, id, nickname)
			});
		end;
	end,
	["events.onShowMenu"] = function(...)
		local spectator = import("game.Spectator");
		local config = import("Config");
		sampev.onShowMenu = function()
			if config.root.additions.hideSpectatorMenu.use then
				return false;
			end
		end;
	end,
	["events.onShowDialog"] = function(...)
		local user = import("game.User");
		local admins = import("game.Admins");
		local spectator = import("game.Spectator");
		local greport = import("game.GReport");
		local config = import("Config");
		local common = import("Common");
		user:addOnAloginCallback("resetCheckedAdminListVar", function(state)
			if not state then
				checkedAdminList = false;
			end
		end);
		sampev.onShowDialog = function(id, style, title, firstButton, secondButton, text)
			title, firstButton, secondButton, text = u8(title), u8(firstButton), u8(secondButton), u8(text);
			greport.dialog.state = false;
			if config.root.additions.hideIpAddresses.use then
				text = string.gsub(text, "%d+%.%d+%.%d+%.%d+", "XXX.XXX.XXX.XXX");
			end
			if title=="Выбор персонажа" then
				user:setAloginStatus(false);
			end
			if user:getOOCNickname()~="Администратор" and user:getOOCNickname()~="Technical Admin" and string.find(title, "Авторизация") and string.find(text, "Введите логин:") then
				sampSendDialogResponse(id, 1, 0, user:getOOCNickname());
				return false;
			end
			if config.root.additions.autoLogin.use and #config.root.additions.autoLogin.accountPassword>=3 and style==DIALOG_STYLE_PASSWORD and string.find(text, "Для продолжения игры, Вам необходимо авторизоваться") then
				if string.find(text, "Попытка входа:") then
					config.root.additions.autoLogin.accountPassword = "";
					common:sendScriptMessage("Вы ввели неверный пароль в настройках для авто-ввода. Пароль был сброшен.");
				else
					sampSendDialogResponse(id, 1, 0, config.root.additions.autoLogin.accountPassword);
					return false;
				end
			end
			if style==DIALOG_STYLE_PASSWORD and firstButton=="Далее" and secondButton=="Отмена" and string.find(text, "{4a86b6}Авторизация.*{FFFFFF}Введите пароль:") and #config.root.additions.autoLogin.aloginPassword>=3 and config.root.additions.autoLogin.use then
				sampSendDialogResponse(id, 1, 0, config.root.additions.autoLogin.aloginPassword);
				return false;
			end
			if not checkedAdminList and not user:getAloginStatus() then
				if string.find(text, "Администрация в игре.*Лог отключений") then
					sampSendDialogResponse(id, 1, 0, nil);
					return false;
				elseif string.find(text, "Администраторы в сети:") then
					for line in string.gmatch(text, "[^\n]+") do
						if string.find(line, "^.*%[%d+%] %- [1-5] уровень") then
							local oocNickname, adminId, adminLvl = string.match(line, "^{FFFFFF}(.*)%[(%d+)%] %- ([1-5]) уровень");
							if tonumber(adminId)==user:getId() then
								user:setOOCNickname(oocNickname);
								user:setAdminLvl(tonumber(adminLvl));
							else
								admins:insert({
									id = tonumber(adminId), 
									lvl = tonumber(adminLvl), 
									nickname = {
										ooc = oocNickname, 
										ic = icNickname
									}
								});
							end
							if user:getOOCNickname()=="Администратор" and user:getAdminLvl()==-1 then
								user:setOOCNickname("Technical Admin");
								user:setAdminLvl(6);
							end
						end
					end
					user:setAloginStatus(true);
					checkedAdminList = true;
					return false;
				end
			end
			if string.find(text, "Информация о игроке") and spectator.stats.checking then
				text = string.gsub(text, "{......}", "");
				local money, bank = string.match(text, "Деньги: ([%$%-0-9]-)\nБанк%: ([%$%-0-9]-)\n");
				spectator.nickname = string.match(text, "Информация о игроке (.+)%[%d+]%.");
				local _internal0;
				if (string.find(text, "Предупреждения:.*%d+")) then
					_internal0 = string.match(text, "Предупреждения:.*(%d+)");
				else
					_internal0 = "0";
				end
				spectator:setInformation({
					statsId = string.match(text, "Информация о игроке .+%[(%d+)%]"), 
					accountId = string.match(text, "ID Аккаунта: (%d+)"), 
					money = money, 
					bank = bank, 
					fraction = string.match(text, "Фракция: (.-)\n"), 
					rang = string.match(text, "Должность: (.-)\n"), 
					vehicle = string.match(text, "Транспорт: (.-)\n"), 
					house = string.match(text, "Дом: (.-)\n"), 
					vip = string.match(text, "Премиум аккаунт: (.-)\n"), 
					regDate = string.match(text, "Дата регистрации: (.-)\n"), 
					warnings = _internal0, 
					stage = "0"
				});
				sampSendDialogResponse(id, 0, 0, "");
				spectator.stats.checking = false;
				return false;
			end
			if config.root.windows.greport.use and title=="Обработка репорта" then
				text = string.gsub(text, "{......}", "");
				greport.player.state = true;
				greport.dialog.state = true;
				if greport.player.time == nil then
					greport.player.time = os.date("*t");
				end
				if style==DIALOG_STYLE_INPUT then
					if greport.dialog.awaiting.input[(1)] then
						sampSendDialogResponse(id, 1, 0, greport.dialog.awaiting.input[(2)]);
						greport.dialog.awaiting.inputs = {
							false, 
							nil
						};
						greport.dialog.state = false;
					end
				end
				if string.find(text, "Дата и время репорта") then
					local nickname, id = string.match(text, "Игрок %(ID%)%: (.+) %((%d+)%)");
					greport.player.nickname = nickname;
					greport.player.id = tonumber(id);
					greport.player.context = string.match(text, "Описание репорта:\n(.*)\n");
					greport.window:open(false);
				elseif string.find(text, "Перейти в режим наблюдения за игроком") then
					if greport.dialog.awaiting.options[(1)] then
						sampSendDialogResponse(id, 1, greport.dialog.awaiting.options[(2)], "");
						if greport.dialog.awaiting.options[(2)]==GREPORT_OPTION_TO_ADMINISTRATION then
							greport.dialog.state = false;
						end
						greport.dialog.awaiting.options = {
							false, 
							nil
						};
					end
				elseif string.find(text, "Заблокировать на %d+ минут") then
					if greport.dialog.awaiting.special[(1)] then
						sampSendDialogResponse(id, 1, greport.dialog.awaiting.special[(2)], "");
						greport.dialog.state = false;
						greport.dialog.awaiting.special = {
							false, 
							nil
						};
					end
				end
				return false;
			end
			return {
				id, 
				style, 
				u8:decode(title), 
				u8:decode(firstButton), 
				u8:decode(secondButton), 
				u8:decode(text)
			};
		end;
	end,
	["events.onVehicleSync"] = function(...)
		local bit = require("bit");
		local spectator = import("game.Spectator");
		sampev.onVehicleSync = function(id, _, data)
			if id==spectator.id then
				if spectator.platform==PLATFORM_PC then
					for _, arguments in ipairs(({
						{
							"w", 
							(bit.band(data.keysData, 0x8))==0x8
						}, 
						{
							"a", 
							data.leftRightKeys==0xFF80
						}, 
						{
							"s", 
							(bit.band(data.keysData, 0x20))==0x20
						}, 
						{
							"d", 
							data.leftRightKeys==0x80
						}, 
						{
							"h", 
							(bit.band(data.keysData, 0x2))==0x2
						}, 
						{
							"space", 
							(bit.band(data.keysData, 0x80))==0x80
						}, 
						{
							"ctrl", 
							(bit.band(data.keysData, 0x1))==0x1
						}, 
						{
							"alt", 
							(bit.band(data.keysData, 0x4))==0x4
						}, 
						{
							"q", 
							(bit.band(data.keysData, 0x100))==0x100
						}, 
						{
							"e", 
							(bit.band(data.keysData, 0x40))==0x40
						}, 
						{
							"f", 
							(bit.band(data.keysData, 0x10))==0x10
						}, 
						{
							"up", 
							data.upDownKeys==0xFF80
						}, 
						{
							"down", 
							data.upDownKeys==0x80
						}
					})) do
						spectator:setKeyStatus(SYNC_KEYS_VEHICLE, table.unpack(arguments));
					end
				elseif spectator.platform==PLATFORM_ANDROID then
					for _, arguments in ipairs(({
						{
							"signal", 
							(bit.band(data.keysData, 0x2))==0x2
						}, 
						{
							"forward", 
							(bit.band(data.keysData, 0x8))==0x8
						}, 
						{
							"braking", 
							(bit.band(data.keysData, 0x28))==0x28
						}, 
						{
							"backward", 
							(bit.band(data.keysData, 0x20))==0x20
						}, 
						{
							"2", 
							(bit.band(data.keysData, 0x200))==0x200
						}, 
						{
							"f", 
							(bit.band(data.keysData, 0x10))==0x10
						}
					})) do
						spectator:setKeyStatus(SYNC_KEYS_VEHICLE, table.unpack(arguments));
					end
					spectator:setupJoyStickWatcher(data.leftRightKeys, data.upDownKeys);
				end
			end
		end;
	end,
	["events.onSendChat"] = function(...)
		local config = import("Config");
		local spectator = import("game.Spectator");
		local user = import("game.User");
		local function swapLayout(text)
			text = u8(text);
			for k, v in pairs(({
				[("й")] = "q", 
				[("ц")] = "w", 
				[("у")] = "e", 
				[("к")] = "r", 
				[("е")] = "t", 
				[("н")] = "y", 
				[("г")] = "u", 
				[("ш")] = "i", 
				[("щ")] = "o", 
				[("з")] = "p", 
				[("х")] = "[", 
				[("ъ")] = "]", 
				[("ф")] = "a", 
				[("ы")] = "s", 
				[("в")] = "d", 
				[("а")] = "f", 
				[("п")] = "g", 
				[("р")] = "h", 
				[("о")] = "j", 
				[("л")] = "k", 
				[("д")] = "l", 
				[("ж")] = ";", 
				[("э")] = "'", 
				[("я")] = "z", 
				[("ч")] = "x", 
				[("с")] = "c", 
				[("м")] = "v", 
				[("и")] = "b", 
				[("т")] = "n", 
				[("ь")] = "m", 
				[("б")] = ",", 
				[("ю")] = ".", 
				[("Й")] = "Q", 
				[("Ц")] = "Q", 
				[("У")] = "W", 
				[("К")] = "E", 
				[("Е")] = "R", 
				[("Н")] = "T", 
				[("Г")] = "Y", 
				[("Ш")] = "U", 
				[("Щ")] = "I", 
				[("З")] = "O", 
				[("Х")] = "{", 
				[("Ъ")] = "}", 
				[("Ф")] = "A", 
				[("Ы")] = "S", 
				[("В")] = "D", 
				[("А")] = "F", 
				[("П")] = "G", 
				[("Р")] = "H", 
				[("О")] = "J", 
				[("Л")] = "K", 
				[("Д")] = "L", 
				[("Ж")] = ":", 
				[("Э")] = "\"", 
				[("Я")] = "Z", 
				[("Ч")] = "X", 
				[("С")] = "C", 
				[("М")] = "V", 
				[("И")] = "B", 
				[("Т")] = "N", 
				[("Ь")] = "M", 
				[("Б")] = "<", 
				[("Ю")] = ">"
			})) do
				text = string.gsub(text, k, v);
			end
			return text;
		end
		sampev.onSendChat = function(message)
			local possibleDot, command, arguments = string.match(message, "^(%.+)(%S*)(.*)");
			if possibleDot=="." and config.root.additions.swapLayout.use then
				local swappedCommand = swapLayout(command);
				if sampIsChatCommandDefined(swappedCommand) then
					local _internal0;
					if (arguments) then
						_internal0 = swappedCommand..arguments;
					else
						_internal0 = output;
					end
					sampProcessChatInput("/"..(_internal0));
				else
					local _internal0;
					if (arguments) then
						_internal0 = swappedCommand..arguments;
					else
						_internal0 = output;
					end
					sampSendChat("/"..u8((_internal0)));
				end
				return false;
			end
			if config.root.additions.autoAACommand.use and user:getAloginStatus() and not spectator.status then
				sampSendChat("/aa "..u8(message));
				return false;
			end
		end;
	end,
	["events.onTextDrawHide"] = function(...)
		local spectator = import("game.Spectator");
		sampev.onTextDrawHide = function(id)
			if id==spectator.textDrawId then
				spectator:exit();
			end
		end;
	end,
	["events.onPlayerDeathNotification"] = function(...)
		local config = import("Config");
		local assets = import("Assets");
		local common = import("Common");
		local user = import("game.User");
		ffi.cdef([[
    typedef uint32_t D3DCOLOR;

    #pragma pack(push, 1)
        typedef struct {
	        char            szKiller[25];
	        char			szVictim[25];
	        D3DCOLOR		clKillerColor;
	        D3DCOLOR		clVictimColor;
	        uint8_t			byteType;
        } stKillEntry;

        typedef struct {
	        int				iEnabled;
	        stKillEntry     killEntry[5];
	        int 			iLongestNickLength;
  	        int 			iOffsetX;
  	        int 			iOffsetY;
	        void		    *pD3DFont;          // ID3DXFont
	        void		    *pWeaponFont1;      // ID3DXFont
	        void		    *pWeaponFont2;      // ID3DXFont
	        void			*pSprite;
	        void			*pD3DDevice;
	        int 			iAuxFontInited;
            void 		    *pAuxFont1;         // ID3DXFont
            void 			*pAuxFont2;         // ID3DXFont
        } stKillInfo;
    #pragma pack(pop)
]]);
		local DIE_SPECIAL_REASON_CAR = 49;
		local DIE_SPECIAL_REASON_HELI = 50;
		local DIE_SPECIAL_REASON_EXPLOSION = 51;
		local DIE_SPECIAL_REASON_DROWNED = 53;
		local DIE_SPECIAL_REASON_SUICIDE = 54;
		sampev.onPlayerDeathNotification = function(killerId, killedId, reason)
			local userId = user:getId();
			local _internal0;
			if (sampIsPlayerConnected(killerId) or killerId==userId) then
				_internal0 = sampGetPlayerNickname(killerId);
			else
				_internal0 = nil;
			end
			local killerNickname = _internal0;
			local _internal1;
			if (sampIsPlayerConnected(killedId) or killedId==userId) then
				_internal1 = sampGetPlayerNickname(killedId);
			else
				_internal1 = nil;
			end
			local killedNickname = _internal1;
			local _internal2 = reason;
			if (_internal2 == DIE_SPECIAL_REASON_CAR) then
				_internal2 = "убит машиной";
			else
				if (_internal2 == DIE_SPECIAL_REASON_HELI) then
					_internal2 = "убит лопастями";
				else
					if (_internal2 == DIE_SPECIAL_REASON_EXPLOSION) then
						_internal2 = "убит взрывом";
					else
						if (_internal2 == DIE_SPECIAL_REASON_DROWNED) then
							_internal2 = "утонул";
						else
							if (_internal2 == DIE_SPECIAL_REASON_SUICIDE) then
								_internal2 = "самоубийство";
							else
								_internal2 = (function()
									if (reason>=0 and reason<=18) or (reason>=22 or reason<=46) then
										return "убит с "..require("game.weapons").get_name(reason);
									else
										return "неизвестно";
									end
								end)();
							end
						end
					end
				end
			end
			local reasonKilledBy = _internal2;
			local _internal3;
			if (killerId==65535) then
				_internal3 = string.format("[A] %s[%s] погиб. Причина - %s.", killedNickname, killedId, reasonKilledBy);
			else
				_internal3 = string.format("[A] %s[%s] убит от рук %s[%s]. Причина - %s.", killedNickname, killedId, killerNickname, killerId, reasonKilledBy);
			end
			local message = _internal3;
			if config.root.additions.deathNotifyInChat.use then
				sampAddChatMessage(message, tonumber(config.root.additions.deathNotifyInChat.color, 16));
			end
			if config.root.additions.idInKillList.use then
				do
					local kill = ffi.cast("stKillInfo*", sampGetKillInfoPtr());
					if kill ~= nil then
						lua_thread.create(function()
							wait(0);
							if killerNickname then
								kill.killEntry[((4))].szKiller = ffi.new("char[25]", string.sub(killerNickname.."["..killerId.."]", 1, 24));
							end
							if killedNickname then
								kill.killEntry[((4))].szVictim = ffi.new("char[25]", string.sub(killedNickname.."["..killedId.."]", 1, 24));
							end
						end);
					end
				end
			end
			for _, log in ipairs(allowedLogs) do
				if log[(1)]=="Килл-лист" then
					table.insert(log[(2)], {
						time = assets:getLocalTime(), 
						text = message
					});
				end
			end
			local _internal4;
			if (killerId==-1) then
				_internal4 = imgui.GetStyle().Colors[(imgui.Col.Text)];
			else
				_internal4 = common:convertHex2ImVec4(string.format("%06X", bit.band(sampGetPlayerColor(killerId), 0xFFFFFF)));
			end
			local _internal5;
			if (killedId==-1) then
				_internal5 = imgui.GetStyle().Colors[(imgui.Col.Text)];
			else
				_internal5 = common:convertHex2ImVec4(string.format("%06X", bit.band(sampGetPlayerColor(killedId), 0xFFFFFF)));
			end
			local _internal6 = reason;
			if (_internal6 == DIE_SPECIAL_REASON_CAR) then
				_internal6 = "Vehicle";
			else
				if (_internal6 == DIE_SPECIAL_REASON_HELI) then
					_internal6 = "Helicopter";
				else
					if (_internal6 == DIE_SPECIAL_REASON_EXPLOSION) then
						_internal6 = "Explosion";
					else
						if (_internal6 == DIE_SPECIAL_REASON_DROWNED) then
							_internal6 = "Drowned";
						else
							if (_internal6 == DIE_SPECIAL_REASON_SUICIDE) then
								_internal6 = "Suicide";
							else
								_internal6 = (function()
									if (reason>=0 and reason<=18) or (reason>=22 or reason<=46) then
										return require("game.weapons").get_name(reason);
									else
										return "Unknown";
									end
								end)();
							end
						end
					end
				end
			end
			table.insert(killListWindow.kills, {
				id = {
					killer = killerId, 
					killed = killedId
				}, 
				nickname = {
					killer = killerNickname, 
					killed = killedNickname
				}, 
				color = {
					killer = _internal4, 
					killed = _internal5
				}, 
				reason = reason, 
				time = assets:getLocalTime(), 
				weapon = _internal6
			});
		end;
	end,
	["imgui.PlayerNotes"] = function(...)
		local windows = import("imgui.Windows");
		local imguiAssets = import("imgui.Assets");
		local StyleChanger = import("imgui.StyleChanger");
		local animations = import("imgui.Animations");
		local config = import("Config");
		local common = import("Common");
		function __playerNotes__:renderNote(note)
			local index = nil;
			for checkIndex, checkNote in ipairs(config.root.playerNotes) do
				if note.id==checkNote.id then
					index = checkIndex;
				end
			end
			if self.displayBuffer[((note.id))] == nil then
				self.displayBuffer[((note.id))] = imgui.new.bool(config.root.playerNotes[(index)].display or false);
			end
			windows:new(note.id, {
				description = note.title, 
				condition = function()
					return self.displayBuffer[(note.id)][(0)];
				end, 
				size = {
					x = 0, 
					y = 0
				}, 
				initialize = {
					fade = {
						clock = 0, 
						state = false, 
						before = nil, 
						alpha = {
							window = 0.0, 
							text = 0.0
						}
					}, 
					style = StyleChanger:new({
						WindowBorderSize = 0, 
						WindowBg = imgui.ImVec4(0, 0, 0, 0)
					})
				}
			}, function(this)
				this.var.style:apply();
				this:begin(this.id, function()
					imgui.BeginGroup();
					imgui.PushFont(bold14);
					local _internal0;
					if (imgui.GetStyle().Colors[(imgui.Col.WindowBg)].w<=0.4) then
						_internal0 = 1;
					else
						_internal0 = 0;
					end
					imguiAssets:addStrokedText(note.title, _internal0);
					imgui.PopFont();
					imgui.PushFont(regular12);
					local _internal1;
					if (imgui.GetStyle().Colors[(imgui.Col.WindowBg)].w<=0.4) then
						_internal1 = 1;
					else
						_internal1 = 0;
					end
					imguiAssets:addStrokedText(note.body, _internal1);
					imgui.PopFont();
					imgui.EndGroup();
					if not this.isChangingWindowsPositions then
						if imgui.IsWindowHovered() and imgui.IsMouseReleased(0) then
							note.display = false;
							self.displayBuffer[((note.id))][((0))] = false;
							imguiAssets:setCursorStatus(true);
						else
							this.var.fade.state = imgui.IsWindowHovered() or os.clock()-0.4<0;
							if this.var.fade.state~=this.var.fade.before then
								this.var.fade.before = this.var.fade.state;
								this.var.fade.clock = os.clock();
							end
							local _internal0;
							if (this.var.fade.state and (common:isCursorActive() or not imguiAssets:getCursorStatus())) then
								_internal0 = 0.7;
							else
								_internal0 = 0.0;
							end
							this.var.fade.alpha.window = imguiAssets:bringFloatTo(this.var.fade.alpha.window, _internal0, this.var.fade.clock, 0.3);
							local _internal1;
							if (this.var.fade.state and (common:isCursorActive() or not imguiAssets:getCursorStatus())) then
								_internal1 = 1.0;
							else
								_internal1 = 0.0;
							end
							this.var.fade.alpha.text = imguiAssets:bringFloatTo(this.var.fade.alpha.text, _internal1, this.var.fade.clock, 0.3);
						end
					end
					do
						local drawList = imgui.GetWindowDrawList();
						if drawList ~= nil then
							drawList:AddRectFilled(imgui.GetWindowPos(), imgui.GetWindowPos()+imgui.GetWindowSize(), imgui.ColorConvertFloat4ToU32(imgui.ImVec4(common:convertHex2ImVec4(string.format("%02X%02X%02X", imgui.GetStyle().Colors[(imgui.Col.ChildBg)].x*255, imgui.GetStyle().Colors[(imgui.Col.ChildBg)].y*255, imgui.GetStyle().Colors[(imgui.Col.ChildBg)].z*255), this.var.fade.alpha.window*255))), imgui.GetStyle().WindowRounding);
							local text = "Закрыть";
							local size = imgui.CalcTextSize(text);
							drawList:AddTextFontPtr(bold, 18, imgui.ImVec2((imgui.GetWindowWidth()-size.x)/2, (imgui.GetWindowHeight()-size.y)/2)+imgui.GetWindowPos(), imgui.ColorConvertFloat4ToU32(common:convertHex2ImVec4(string.format("%02X%02X%02X", imgui.GetStyle().Colors[(imgui.Col.Text)].x*255, imgui.GetStyle().Colors[(imgui.Col.Text)].y*255, imgui.GetStyle().Colors[(imgui.Col.Text)].z*255), this.var.fade.alpha.text*255)), text);
						end
					end
				end);
				this.var.style:reset();
			end);
		end
		function __playerNotes__:initializeNotes()
			for _, note in ipairs(config.root.playerNotes) do
				self:renderNote(note);
			end
		end
		function __playerNotes__:new(note)
			local noteId = #config.root.playerNotes+1;
			for _, note in ipairs(config.root.playerNotes) do
				do
					local id = string.match(note.id, "^noteIndex%-(%d+)$");
					if id ~= nil then
						if tonumber(id)==noteId then
							noteId = noteId + 1;
						end
					end
				end
			end
			note.id = "noteIndex-"..noteId;
			table.insert(config.root.playerNotes, note);
			self:renderNote(note);
		end
		function __playerNotes__:remove(index)
			local id = config.root.playerNotes[(index)].id;
			self.displayBuffer[((id))][((0))] = false;
			table.remove(config.root.playerNotes, index);
		end
		return __playerNotes__;
	end,
	["events.onPlayerQuit"] = function(...)
		local admins = import("game.Admins");
		local greport = import("game.GReport");
		local spectator = import("game.Spectator");
		local notify = import("Notifications");
		local icons = import("Icons");
		local config = import("Config");
		local assets = import("Assets");
		sampev.onPlayerQuit = function(id)
			local nickname = sampGetPlayerNickname(id);
			for index, admin in ipairs(admins) do
				if admin.id==id then
					admins:remove(index);
					break;
				end
			end
			if config.root.windows.playerChecker.use then
				for _, player in ipairs(config.root.windows.playerChecker.players) do
					if player.nickname==nickname then
						do
							local notificationType = config.root.windows.playerChecker.notificationType;
							if notificationType ~= nil then
								if notificationType~=NOTIFICATION_TYPE_NONE then
									local _internal0;
									if (config.root.windows.playerChecker.displayOfflinePlayers) then
										_internal0 = "Теперь он отображается отключенным в чекере.";
									else
										_internal0 = "Больше он не отображается в чекере.";
									end
									local _internal1;
									if (notificationType==NOTIFICATION_TYPE_SCRIPT_MESSAGE) then
										_internal1 = (string.gsub(nickname, "_", " ").." вышел из игры.");
									else
										_internal1 = nil;
									end
									notify:send({
										title = string.gsub(nickname, "_", " ").." вышел из игры.", 
										text = _internal0, 
										icon = icons.ICON_PERSON, 
										duration = 5
									}, _internal1);
								end
							end
						end
						break;
					end
				end
			end
			local CONNECTION_LOG_INDEX = 5;
			table.insert(allowedLogs[(CONNECTION_LOG_INDEX)][(2)], {
				time = assets:getLocalTime(), 
				text = string.format("%s[%d] вышел из игры.", nickname, id)
			});
			local _internal0 = id;
			if (_internal0 == greport.player.id) then
				greport.player:reset();
			else
				if (_internal0 == spectator.id) then
					spectator:exit();
				end
			end
		end;
	end,
	["events.onTextDrawSetString"] = function(...)
		local spectator = import("game.Spectator");
		sampev.onTextDrawSetString = function(id, text)
			if string.find(text, "~y~%(%d+%)") then
				spectator.textDrawId = id;
				spectator:setTo(tonumber(string.match(text, "%((%d+)%)")));
			elseif string.find(text, "HP") and string.find(text, "ID") then
				spectator:setInformation({
					health = string.match(text, "HP: (%d+)"), 
					moveSpeedCurrent = string.match(text, "(%d+) / [%-]?%d+"), 
					moveSpeedMax = string.match(text, "%d+ / [%-]?(%d+)")
				});
			end
			if string.find(text, "Android: .+") then
				local _internal0;
				if (#string.match(text, "Android: (.+)")==2) then
					_internal0 = PLATFORM_ANDROID;
				else
					_internal0 = PLATFORM_PC;
				end
				spectator.platform = _internal0;
			end
		end;
	end,
	["events.onServerMessage"] = function(...)
		local bit = require("bit");
		local admins = import("game.Admins");
		local user = import("game.User");
		local spectator = import("game.Spectator");
		local player = import("game.samp.Player");
		local greport = import("game.GReport");
		local common = import("Common");
		local assets = import("Assets");
		local commandRequester = import("CommandRequester");
		local config = import("Config");
		local notify = import("Notifications");
		local icons = import("Icons");
		local logs = {
			{
				"IC чат/действия", 
				{
					"^%w+.*говорит:", 
					"^%w+.*кричит:", 
					"^%w+.*шепчет:", 
					{
						"^%w+", 
						-413892353
					}, 
					{
						"%- сказал.+%w+.*, ", 
						-413892353
					}, 
					" %%(%( .* %)%)$"
				}
			}, 
			{
				"OOC чат", 
				{
					"^%(%( %w+.*%[%d+]: .* %)%)$", 
					{
						"^%(%( PM [отк] %w+.*%[%d+]: .* %)%)$", 
						-3342081
					}, 
					"^%(%( %w+.*%[%d+]: .*%.%.%.$", 
					"^%.%.%. .*%)%)$", 
					-1
				}
			}, 
			{
				"Действия/чаты администраторов", 
				{
					{
						"^%[A] .*%[%d+] ответил .+%[%d+]:", 
						-6732374
					}, 
					{
						"^%[A] .*%[%d+] вылечил .+%[%d+]%.$", 
						-1347440726
					}, 
					{
						"^%[A] .*%[%d+] подкинул .+%[%d+]%.$", 
						-1347440726
					}, 
					{
						"^%[A] .*%[%d+]:? ", 
						866792362
					}, 
					{
						"^%[A] .*%[%d+] взялся за обработку репорта от игрока .+%[%d+]%.$", 
						-1347440726
					}, 
					{
						"^%[A] .+%[%d+] перевёл деньги через банк .+%[%d+] %- %$%d+$", 
						-1347440726
					}, 
					{
						"^%[A] .+%[%d+] передал деньги .+%[%d+] %- %$%d+$", 
						-1347440726
					}, 
					{
						"^%[A] .*%[%d+] удалил репорт от игрока .+%[%d+]%.$", 
						-1347440726
					}, 
					{
						"^%[A] .+%[%d+] нарисовал граффити%. MysqlID: %d+$", 
						-65366
					}, 
					{
						"^%[A] .*%[%d+] починил машину с ID: %d+%.$", 
						-1347440726
					}, 
					{
						"^%[A] .+%[%d+] установил описание: ", 
						-1697828182
					}, 
					{
						"^%[A] .+%[%d+] установил описание авто: ", 
						-1697828182
					}, 
					{
						"^%[A] .+%[%d+] установил слухи: ", 
						-1697828182
					}, 
					{
						"^%[GBUY] .+%[%d+] создал объявление %[%d+]: ", 
						-1697828182
					}, 
					{
						"^%[A] .+%[%d+] установил действие: ", 
						-1697828182
					}, 
					{
						"^%.%.%. ", 
						-1697828182
					}, 
					{
						"^Администратор .+%.Причина: ", 
						-10270806
					}, 
					{
						"^Администратор .+ установил <Player Kill> персонажу .+%.$", 
						-10270806
					}, 
					{
						"^Администратор .+ установил <Character Kill> персонажу .+%.$", 
						-10270806
					}, 
					"^%[A] Жалоба от .+%[%d+]:", 
					"^%[A] Репорт от .+%[%d+]:"
				}
			}
		};
		local skipNextMessage = false;
		local adminListCheckClock = os.clock()-800;
		local messageContinuation = {
			awaiting = false, 
			color = nil
		};
		sampev.onServerMessage = function(color, text)
			local text = u8(text);
			for sectionIndex, section in ipairs(logs) do
				local log = {
					time = assets:getLocalTime(), 
					text = string.gsub(text, "{%x%x%x%x%x%x}", "")
				};
				for _, item in ipairs(section[(2)]) do
					if type(item)=="table" then
						if string.find(text, item[(1)]) and color==item[(2)] then
							table.insert(allowedLogs[(sectionIndex)][(2)], log);
							break;
						end
					else
						if string.find(text, item) then
							table.insert(allowedLogs[(sectionIndex)][(2)], log);
							break;
						end
					end
				end
			end
			commandRequester:setupChatWatcher(text, color);
			greport:setupChatWatcher(text);
			local function compare(pattern, clr)
				local _internal2;
				if (pattern and color) then
					_internal2 = string.find(text, pattern) and color==clr;
				else
					local _internal1;
					if (pattern) then
						_internal1 = string.find(text, pattern);
					else
						local _internal0;
						if (color) then
							_internal0 = color==clr;
						else
							_internal0 = false;
						end
						_internal1 = _internal0;
					end
					_internal2 = _internal1;
				end
				return _internal2;
			end
			local function rgb2color(rgb)
				return rgb and bit.tobit(tonumber(string.format("%s%02X", rgb, bit.band(color, 0xFF)), 16));
			end
			if ((string.find(text, "^%w+.* ") and color==-413892353) or string.find(text, "^%w+.* говорит:")) and config.root.additions.displayIdInIc.use then
				do
					local nickname, other = string.match(text, "^([%w ]+) (.*)");
					if nickname ~= nil and other ~= nil then
						do
							local id = player:getIdByNickname(string.gsub(nickname, " ", "_"));
							if id ~= nil then
								text = string.format("%s[%d] %s", nickname, id, other);
							end
						end
					end
				end
			end
			if config.root.additions.reportOneColor.use then
				if string.find(text, "^%[A] Жалоба от .+%[%d+]:") or string.find(text, "^%[A] Репорт от .+%[%d+]:") then
					if string.find(text, "%.%.%.$") then
						messageContinuation.awaiting = true;
						messageContinuation.color = color;
					end
					color = rgb2color(config.root.additions.reportOneColor.color);
				end
				if string.find(text, "^%.%.%. ") and messageContinuation.awaiting and messageContinuation.color==color then
					color = rgb2color(config.root.additions.reportOneColor.color);
					messageContinuation.awaiting = false;
					messageContinuation.color = nil;
				end
			end
			if text=="Вы были отсоединены от сервера за неправильный пароль администрирования." and config.root.additions.autoLogin.use and #config.root.additions.autoLogin.aloginPassword>=3 then
				config.root.additions.autoLogin.aloginPassword = "";
				common:sendScriptMessage("Вы ввели неверный пароль в настройках для авто-ввода. Пароль был сброшен.");
			end
			if string.find(text, "^%[A%] .*%[%d+%]: %S+") and color==866792362 and config.root.additions.mention.use then
				local mentionStarter, possibleMention = string.match(text, "^%[A%] (.*)%[%d+]: (%S+)");
				local replacedColor = false;
				for index, pattern in ipairs(({
					"^(%d+),", 
					"^@(%d+)", 
					"^(%d+)$", 
					"^@(%d+)$", 
					"^(.+),", 
					"^@(.+)", 
					"^(.+)$", 
					"^@(.+)$"
				})) do
					if index<=4 then
						if tonumber(string.match(possibleMention, pattern))==user:getId() then
							color = rgb2color(config.root.additions.mention.color);
							replacedColor = true;
						end
					else
						do
							local nickname = string.match(possibleMention, pattern);
							if nickname ~= nil then
								if string.lower(nickname)==string.lower(user:getOOCNickname()) then
									color = rgb2color(config.root.additions.mention.color);
									replacedColor = true;
								end
							elseif possibleMention=="all" then
								color = rgb2color(config.root.additions.mention.color);
								if mentionStarter~=user:getOOCNickname() then
									replacedColor = true;
								end
							end
						end
					end
					if replacedColor then
						if config.root.additions.mention.soundNotification then
							addOneOffSound(0, 0, 0, 1137);
						end
						do
							local notificationType = config.root.additions.mention.notificationType;
							if notificationType ~= nil then
								if notificationType~=NOTIFICATION_TYPE_NONE then
									local _internal0;
									if (notificationType==NOTIFICATION_TYPE_SCRIPT_MESSAGE) then
										_internal0 = mentionStarter.." вас упомянул в /a чате.";
									else
										_internal0 = nil;
									end
									notify:send({
										title = "Вас упомянули в /a чате", 
										text = "Вас упомянул "..mentionStarter..". Сообщение выделено в чате.", 
										icon = icons.ICON_PEOPLE
									}, _internal0);
								end
							end
						end
						break;
					end
				end
			end
			if config.root.additions.hideIpAddresses.use then
				text = string.gsub(text, "%d+%.%d+%.%d+%.%d+", "XXX.XXX.XXX.XXX");
			end
			if string.find(text, "^%[A%] .*%[%d+%] авторизовался как администратор %d+ уровня%.$") then
				local oocNickname, adminId, adminLvl = string.match(text, "^%[A%] (.*)%[(%d+)%] авторизовался как администратор (%d+) уровня%.$");
				local connectionPassed = true;
				for _, data in ipairs(admins) do
					if data.nickname.ooc==oocNickname then
						connectionPassed = false;
						break;
					end
				end
				if connectionPassed then
					admins:insert({
						id = tonumber(adminId), 
						lvl = tonumber(adminLvl), 
						nickname = {
							ooc = oocNickname, 
							ic = sampGetPlayerNickname(tonumber(adminId))
						}
					});
				end
			elseif string.find(text, "^%[A%] .*%[%d+%] вышел как администратор%.$") then
				local adminId = tonumber(string.match(text, "^%[A%] .*%[(%d+)%] вышел как администратор%.$"));
				if adminId==user:getId() then
					user:setAloginStatus(false);
					checkedAdminList = false;
				end
				for index, data in ipairs(admins) do
					if data.id==adminId then
						admins:remove(index);
					end
				end
			end
			if string.find(text, "Игрок не AFK!") and spectator.afk.awaiting.message then
				spectator.afk.awaiting.message = false;
				return false;
			end
			if spectator.afk.awaiting.message and string.find(text, "^.+%-%s+%d+$") then
				spectator.afk.time = tonumber(string.match(text, "^.+%-%s+(%d+)$"));
				spectator.afk.clock = os.clock();
				spectator.afk.awaiting.message = false;
				return false;
			end
			if (string.find(text, "Вы успешно авторизовались как администратор") or string.find(text, "Вы уже авторизировались") or string.find(text, "Вы успешно авторизовались как ведущий администратор")) and color==-1 then
				if os.clock()-adminListCheckClock>=800 then
					lua_thread.create(function()
						wait(800);
						sampSendChat("/adm");
					end);
					if config.root.additions.autoAlogout.use then
						assets:workInBackground(true);
					end
				end
			end
			if string.match(text, "^%[A%] (.+)%[%d+%] ответил .*%[%d+%]: .*")==user:getOOCNickname() then
				user:incrementAnswersCount();
			end
			for _, data in ipairs(config.root.chat.changeColor) do
				if compare(data.pattern, rgb2color(data.colors.old)) then
					color = rgb2color(data.colors.new);
					break;
				end
			end
			if config.root.additions.disableServerMessages.use then
				local pureText = string.gsub(text, "{%x%x%x%x%x%x}", "");
				if string.find(text, "^%.%.%.") and skipNextMessage then
					skipNextMessage = false;
					return false;
				end
				for key, value in pairs(({
					anticheat = {
						"^Античит", 
						"^%[BOT DETECTOR]"
					}, 
					complaints = {
						"^%[A] Жалоба от .+%[%d+]:"
					}, 
					questions = {
						"^%[A] Репорт от .+%[%d+]:"
					}, 
					adminActions = -1347440726, 
					punishments = {
						"^Администратор .+%. Причина:", 
						"^Администратор .+ установил <Player Kill> персонажу .+%.$", 
						"^Администратор .+ установил <Character Kill> персонажу .+%.$"
					}, 
					playerActions = {
						"^%[A] .+%[%d+] нарисовал граффити%. MysqlID: %d+$", 
						"^%[A] .+%[%d+] установил описание: ", 
						"^%[A] .+%[%d+] установил описание авто: ", 
						"^%[GBUY] .*%[%d+] создал объявление %[%d+]: ", 
						"^%[A] .+%[%d+] установил слухи: ", 
						"^%[A] .+%[%d+] установил действие: ", 
						"^%[A] .+%[%d+] перевёл деньги "
					}
				})) do
					if config.root.additions.disableServerMessages[(key)] then
						if type(value)=="number" and color==value then
							return false;
						elseif type(value)=="table" then
							for _, patternOrColor in ipairs(value) do
								if string.find(text, patternOrColor) then
									if string.find(text, "%.%.%.$") then
										skipNextMessage = true;
									end
									return false;
								end
							end
						end
					end
				end
			end
			if config.root.additions.changeNicknameColors.use then
				do
					local it = contributorsFileSource;
					if it ~= nil then
						if string.find(text, "^%[A%] .*%[%d+%]") and color==866792362 then
							for line in string.gmatch(it, "[^\r\n]+") do
								do
									local color, nickname = string.match(line, "^CLR: (%x+)=(.+)");
									if color ~= nil and nickname ~= nil then
										local find = string.format("(%s)", nickname);
										local replace = "{"..color.."}%1{33AA33}";
										text = string.gsub(text, find, replace);
									end
								end
							end
						end
					end
				end
			end
			for _, data in ipairs(config.root.chat.remove) do
				if compare(data.pattern, rgb2color(data.color)) then
					return false;
				end
			end
			return {
				color, 
				u8:decode(text)
			};
		end;
	end,
	["Icons"] = function(...)
		local compressedData = import("CompressedData");
		local assets = import("Assets");
		local icons = {
			[("ICON_XLS_DOCUMENT")] = "\u{F000}", 
			[("ICON_WORD_DOCUMENT")] = "\u{F001}", 
			[("ICON_WAVE")] = "\u{F002}", 
			[("ICON_WARNING")] = "\u{F003}", 
			[("ICON_VISIBILITY")] = "\u{F004}", 
			[("ICON_VISIBILITY_OFF")] = "\u{F005}", 
			[("ICON_VIDEO")] = "\u{F006}", 
			[("ICON_VERTICAL_BAR_CHART")] = "\u{F007}", 
			[("ICON_PLAY")] = "\u{F008}", 
			[("ICON_PLUS")] = "\u{F009}", 
			[("ICON_PNG")] = "\u{F010}", 
			[("ICON_POWERPOINT_DOCUMENT")] = "\u{F011}", 
			[("ICON_PRINTER")] = "\u{F012}", 
			[("ICON_PYRAMID")] = "\u{F013}", 
			[("ICON_QUESTION_MARK_CIRCLE")] = "\u{F014}", 
			[("ICON_REFRESH")] = "\u{F015}", 
			[("ICON_ROTATE_LEFT")] = "\u{F016}", 
			[("ICON_ROTATE_RIGHT")] = "\u{F017}", 
			[("ICON_SAVE")] = "\u{F018}", 
			[("ICON_SEARCH")] = "\u{F019}", 
			[("ICON_SEND")] = "\u{F020}", 
			[("ICON_SETTINGS")] = "\u{F021}", 
			[("ICON_SHIELD_WITH_CHECKMARK")] = "\u{F022}", 
			[("ICON_SHIELD_OUTLINED_WITH_CHECKMARK")] = "\u{F023}", 
			[("ICON_SHIELD_OUTLINED")] = "\u{F024}", 
			[("ICON_SHIELD")] = "\u{F025}", 
			[("ICON_STAR")] = "\u{F026}", 
			[("ICON_SVG_DOCUMENT")] = "\u{F027}", 
			[("ICON_TRASH")] = "\u{F028}", 
			[("ICON_TREE_MAP")] = "\u{F029}", 
			[("ICON_TEXT_DOCUMENT")] = "\u{F030}", 
			[("ICON_TRENDING_DOWN")] = "\u{F031}", 
			[("ICON_TRENDING_UP")] = "\u{F032}", 
			[("ICON_TRIPLE_DOTS")] = "\u{F033}", 
			[("ICON_TWO_LINES_HORIZONTAL")] = "\u{F034}", 
			[("ICON_TWO_LINES_VERTICAL")] = "\u{F035}", 
			[("ICON_TXT_DOCUMENT")] = "\u{F036}", 
			[("ICON_UPLOAD_VERSION_1")] = "\u{F037}", 
			[("ICON_UPLOAD_VERSION_2")] = "\u{F038}", 
			[("ICON_PIE_CHART")] = "\u{F039}", 
			[("ICON_PHONE")] = "\u{F040}", 
			[("ICON_PHONE_VERTICAL")] = "\u{F041}", 
			[("ICON_PHONE_OPEN")] = "\u{F042}", 
			[("ICON_PHONE_CLOSED")] = "\u{F043}", 
			[("ICON_PERSON")] = "\u{F044}", 
			[("ICON_PEOPLE")] = "\u{F045}", 
			[("ICON_PENCIL")] = "\u{F046}", 
			[("ICON_PEN")] = "\u{F047}", 
			[("ICON_PEN_BRUSH")] = "\u{F048}", 
			[("ICON_PDF_DOCUMENT")] = "\u{F049}", 
			[("ICON_PDF_DOCUMENT_ALTERNATE")] = "\u{F050}", 
			[("ICON_PAW")] = "\u{F051}", 
			[("ICON_PAUSE")] = "\u{F052}", 
			[("ICON_PAPERCLIP_V2")] = "\u{F053}", 
			[("ICON_PAPERCLIP_V1")] = "\u{F054}", 
			[("ICON_PALETTE")] = "\u{F055}", 
			[("ICON_MUSIC_NOTE")] = "\u{F056}", 
			[("ICON_MUSIC_NOTE_ALT")] = "\u{F057}", 
			[("ICON_MOUSE")] = "\u{F058}", 
			[("ICON_MONITOR")] = "\u{F059}", 
			[("ICON_MOBILE")] = "\u{F060}", 
			[("ICON_MINUS")] = "\u{F061}", 
			[("ICON_MINIMIZE")] = "\u{F062}", 
			[("ICON_MICROPHONE")] = "\u{F063}", 
			[("ICON_MENU")] = "\u{F064}", 
			[("ICON_MAXIMIZE")] = "\u{F065}", 
			[("ICON_MAIL")] = "\u{F066}", 
			[("ICON_LOCKED_DOCUMENT")] = "\u{F067}", 
			[("ICON_LOCK")] = "\u{F068}", 
			[("ICON_LOCK_OPEN")] = "\u{F069}", 
			[("ICON_LOCATION_PIN")] = "\u{F070}", 
			[("ICON_HEADPHONE")] = "\u{F071}", 
			[("ICON_HEART")] = "\u{F072}", 
			[("ICON_HOME_EMPTY")] = "\u{F073}", 
			[("ICON_HOME")] = "\u{F074}", 
			[("ICON_HORIZONTAL_BAR_CHART")] = "\u{F075}", 
			[("ICON_HOURGLAS_FLOWING")] = "\u{F076}", 
			[("ICON_HOURGLASS_BOTTOM_FILLED")] = "\u{F077}", 
			[("ICON_HOURGLASS_TOP_FILLED")] = "\u{F078}", 
			[("ICON_IMAGE")] = "\u{F079}", 
			[("ICON_INBOX_ARROW_DOWN")] = "\u{F080}", 
			[("ICON_INBOX_ARROW_UP")] = "\u{F081}", 
			[("ICON_INBOX_TRAY_FULL")] = "\u{F082}", 
			[("ICON_INBOX_TRAY")] = "\u{F083}", 
			[("ICON_INBOXES")] = "\u{F084}", 
			[("ICON_JPEG")] = "\u{F085}", 
			[("ICON_KEY")] = "\u{F086}", 
			[("ICON_KEYBOARD")] = "\u{F087}", 
			[("ICON_LANDMARK")] = "\u{F088}", 
			[("ICON_LAPTOP_COMPUTER")] = "\u{F089}", 
			[("ICON_LAYERS")] = "\u{F090}", 
			[("ICON_LEAF")] = "\u{F091}", 
			[("ICON_LIGHTBULB_EMPTY")] = "\u{F092}", 
			[("ICON_LIGHTBULB_FILLED")] = "\u{F093}", 
			[("ICON_LIGHTNING_BOLT")] = "\u{F094}", 
			[("ICON_LINE_CHART")] = "\u{F095}", 
			[("ICON_LINK_ALT")] = "\u{F096}", 
			[("ICON_LINK")] = "\u{F097}", 
			[("ICON_LIST_CIRCLE")] = "\u{F098}", 
			[("ICON_LIST_DASH")] = "\u{F099}", 
			[("ICON_LIST_SQUARE")] = "\u{F100}", 
			[("ICON_LIST")] = "\u{F101}", 
			[("ICON_LOCATION_ALT")] = "\u{F102}", 
			[("ICON_HAMMER")] = "\u{F103}", 
			[("ICON_CODE")] = "\u{F104}", 
			[("ICON_BRAIN")] = "\u{F105}", 
			[("ICON_BOOKMARK_OUTLINED")] = "\u{F106}", 
			[("ICON_CLOSE")] = "\u{F107}", 
			[("ICON_GLASSES")] = "\u{F108}", 
			[("ICON_GLASSES_ALT")] = "\u{F109}", 
			[("ICON_CLOSE_CIRCLE")] = "\u{F110}", 
			[("ICON_BOOKMARK_FILLED")] = "\u{F111}", 
			[("ICON_BOOK_OPEN")] = "\u{F112}", 
			[("ICON_CLOCK_FILLED")] = "\u{F113}", 
			[("ICON_GIFT")] = "\u{F114}", 
			[("ICON_FOLDER")] = "\u{F115}", 
			[("ICON_CLIPBOARD")] = "\u{F116}", 
			[("ICON_BIN")] = "\u{F117}", 
			[("ICON_BELL")] = "\u{F118}", 
			[("ICON_CHEVRON_UP")] = "\u{F119}", 
			[("ICON_FLAG")] = "\u{F120}", 
			[("ICON_FIRE")] = "\u{F121}", 
			[("ICON_CHEVRON_RIGHT")] = "\u{F122}", 
			[("ICON_BAG")] = "\u{F123}", 
			[("ICON_ARCHIVE")] = "\u{F124}", 
			[("ICON_AREA_CHART")] = "\u{F125}", 
			[("ICON_ARROW_DOWN_FROM_LINE")] = "\u{F126}", 
			[("ICON_ARROW_DOWN_LEFT")] = "\u{F127}", 
			[("ICON_ARROW_DOWN_RIGHT")] = "\u{F128}", 
			[("ICON_ARROW_DOWN_TO_LINE")] = "\u{F129}", 
			[("ICON_ARROW_DOWN")] = "\u{F130}", 
			[("ICON_ARROW_LEFT_FROM_LINE")] = "\u{F131}", 
			[("ICON_ARROW_LEFT_TO_LINE")] = "\u{F132}", 
			[("ICON_ARROW_LEFT")] = "\u{F133}", 
			[("ICON_ARROW_RIGHT_FROM_LINE")] = "\u{F134}", 
			[("ICON_ARROW_RIGHT_TO_LINE")] = "\u{F135}", 
			[("ICON_ARROW_RIGHT")] = "\u{F136}", 
			[("ICON_ARROW_TOP_LEFT")] = "\u{F137}", 
			[("ICON_ARROW_TOP_RIGHT")] = "\u{F138}", 
			[("ICON_ARROW_UP_FROM_LINE")] = "\u{F139}", 
			[("ICON_ARROW_UP_TO_LINE")] = "\u{F140}", 
			[("ICON_ARROW_UP")] = "\u{F141}", 
			[("ICON_BADGE_WITH_CHECKMARK")] = "\u{F142}", 
			[("ICON_BADGE")] = "\u{F143}", 
			[("ICON_BRIEFCASE")] = "\u{F144}", 
			[("ICON_BRUSH")] = "\u{F145}", 
			[("ICON_BUBBLE_CHART")] = "\u{F146}", 
			[("ICON_BUG")] = "\u{F147}", 
			[("ICON_CABINET")] = "\u{F148}", 
			[("ICON_CALENDAR_ALT")] = "\u{F149}", 
			[("ICON_CALENDAR")] = "\u{F150}", 
			[("ICON_CAMERA")] = "\u{F151}", 
			[("ICON_CANDLESTICK_CHART")] = "\u{F152}", 
			[("ICON_CAR")] = "\u{F153}", 
			[("ICON_CART")] = "\u{F154}", 
			[("ICON_CASE")] = "\u{F155}", 
			[("ICON_CERTIFICATE")] = "\u{F156}", 
			[("ICON_CHAT_BUBBLE_ADD")] = "\u{F157}", 
			[("ICON_CHAT_BUBBLE_QUESTION_MARK")] = "\u{F158}", 
			[("ICON_CHAT_BUBBLE_WARNING")] = "\u{F159}", 
			[("ICON_CHAT_BUBBLE")] = "\u{F160}", 
			[("ICON_CHAT_MULTIPLE")] = "\u{F161}", 
			[("ICON_CHECKLIST")] = "\u{F162}", 
			[("ICON_CHECKMARK_CIRCLE")] = "\u{F163}", 
			[("ICON_CHECKMARK")] = "\u{F164}", 
			[("ICON_CHEVRON_DOWN")] = "\u{F165}", 
			[("ICON_CHEVRON_LEFT_END")] = "\u{F166}", 
			[("ICON_CHEVRON_LEFT")] = "\u{F167}", 
			[("ICON_CHEVRON_RIGHT_END")] = "\u{F168}", 
			[("ICON_COLLAPSE")] = "\u{F169}", 
			[("ICON_CONTACT_CARD")] = "\u{F170}", 
			[("ICON_CREDIT_CARD")] = "\u{F171}", 
			[("ICON_DASHBOARD")] = "\u{F172}", 
			[("ICON_DATABASE")] = "\u{F173}", 
			[("ICON_DENY")] = "\u{F174}", 
			[("ICON_DESKTOP_COMPUTER")] = "\u{F175}", 
			[("ICON_DOCUMENT")] = "\u{F176}", 
			[("ICON_DOTS_HORIZONTAL")] = "\u{F177}", 
			[("ICON_DOTS_VERTICAL")] = "\u{F178}", 
			[("ICON_DOUBLE_DOTS")] = "\u{F179}", 
			[("ICON_DOWNLOAD_VERSION_1")] = "\u{F180}", 
			[("ICON_DOWNLOAD_VERSION_2")] = "\u{F181}", 
			[("ICON_DROPLET")] = "\u{F182}", 
			[("ICON_ELECTRIC_CAR")] = "\u{F183}", 
			[("ICON_EMOJI_FILLED")] = "\u{F184}", 
			[("ICON_EMOJI_OUTLINED")] = "\u{F185}", 
			[("ICON_EPS_DOCUMENT")] = "\u{F186}", 
			[("ICON_ERROR")] = "\u{F187}", 
			[("ICON_EXPAND")] = "\u{F188}", 
			[("ICON_EXTERNAL")] = "\u{F189}", 
			[("ICON_FIGMA_DOCUMENT")] = "\u{F190}", 
			[("ICON_FILTER_ALTERNATE")] = "\u{F191}", 
			[("ICON_FILTER")] = "\u{F192}", 
			[("ICON_FIRE_ALT")] = "\u{F193}", 
			[("ICON_2_PEOPLE")] = "\u{F194}", 
			[("ICON_ADDRESS_BOOK")] = "\u{F195}", 
			[("ICON_ALARM_CLOCK")] = "\u{F196}", 
			[("ICON_ALIEN")] = "\u{F197}", 
			[("ICON_AI_DOCUMENT")] = "\u{F198}", 
			[("ICON_PLUS_CIRCLE")] = "\u{F199}"
		};
		function icons:init(iconSize)
			if iconSize == nil then
				iconSize = 14.0
			end
			local config = imgui.ImFontConfig();
			local glyphRanges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic();
			local iconRanges = imgui.new.ImWchar[(3)](0xE005, 0xF8FF, 0);
			config.MergeMode = true;
			imgui.GetIO().Fonts:AddFontFromFileTTF("trebucbd.ttf", iconSize, nil, glyphRanges);
			icon = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(compressedData.iconFont, iconSize, config, iconRanges);
		end
		return setmetatable(icons, {
			__call = function(table, value)
				if type(value)=="string" then
					return t[("ICON_"..string.upper(value))] or "?";
				elseif type(value)=="number" and (value>=0xF000 and value<=0xFFFF) then
					return assets:convertUnicode2Utf8(value);
				else
					return "Unknown icon";
				end
			end
		});
	end,
	["imgui.windows.SpectatorInformation"] = function(...)
		local imguiAssets = import("imgui.Assets");
		local window = import("imgui.Windows");
		local StyleChanger = import("imgui.StyleChanger");
		local animations = import("imgui.Animations");
		local spectator = import("game.Spectator");
		local vehicle = import("game.sa.Vehicle");
		local common = import("Common");
		local config = import("Config");
		local sizeX, sizeY = getScreenResolution();
		local hintClock = nil;
		window:new("imgui.windows.SpectatorInformation", {
			description = "Информация о игроке в спектаторе", 
			type = MV_ONLY_IN_SPECTATOR, 
			condition = function()
				return config.root.windows.spectatorInformation.use;
			end, 
			size = function()
				return {
					x = 140*(config.root.windows.spectatorInformation.type*2), 
					y = 0
				};
			end, 
			defaultPos = {
				x = 0, 
				y = sizeY/2.336
			}, 
			initialize = {
				columnsPadding = StyleChanger:new({
					ItemSpacing = imgui.ImVec2(5, 5), 
					WindowPadding = imgui.ImVec2(0, 0), 
					ItemInnerSpacing = imgui.ImVec2(0, 0)
				})
			}
		}, function(self)
			self.information = spectator:getInformation();
			if hintClock == nil then
				hintClock = os.clock();
			end
			local result, handle = spectator:getHandle();
			if result then
				if isCharInAnyCar(handle) then
					self.speedColor = (tonumber(self.information.moveSpeed.current)>tonumber(self.information.moveSpeed.max)) and common:convertHex2ImVec4("FF8585");
				end
				do
					local ping = tonumber(self.information.ping);
					if ping ~= nil then
						local _internal1;
						if (ping<=75) then
							_internal1 = "8DFF85";
						else
							local _internal0;
							if (ping>=75 and ping<=140) then
								_internal0 = "F0E518";
							else
								_internal0 = "FF8585";
							end
							_internal1 = (_internal0);
						end
						self.pingColor = common:convertHex2ImVec4(_internal1);
					end
				end
			end
			self.shotColor = (self.information.shot.total~="0" and (self.information.shot.total==self.information.shot.hit)) and common:convertHex2ImVec4("FF8585");
			self.columns = {
				[("Пинг")] = {
					value = self.information.ping, 
					color = self.pingColor
				}, 
				[("ID аккаунта")] = {
					value = self.information.accountId
				}, 
				[("Дата регистрации")] = {
					value = self.information.regDate
				}, 
				[("Наличные/банк")] = {
					value = self.information.money.." / "..self.information.bank
				}, 
				[("Здоровье/броня")] = {
					value = self.information.health.." / "..self.information.armor
				}, 
				[("Фракция")] = {
					value = self.information.fraction
				}, 
				[("Должность")] = {
					value = self.information.rang
				}, 
				[("Машина(-ы)")] = {
					value = self.information.vehicle
				}, 
				[("Стадия")] = {
					value = self.information.stage
				}, 
				[("VIP статус")] = {
					value = self.information.vip
				}, 
				[("Предупреждения")] = {
					value = self.information.warnings
				}, 
				[("Время в афк")] = {
					value = self.information.afkTime
				}, 
				[("Тек./макс. скорость")] = {
					value = self.information.moveSpeed.current.." / "..self.information.moveSpeed.max, 
					color = self.speedColor
				}, 
				[("Выстрелы/попадания")] = {
					value = self.information.shot.total.." / "..self.information.shot.hit, 
					color = self.shotColor
				}
			};
			self.centerWrappedColumnText = function(text, font)
				local text = string.match(text, "^%s*(.+)%s*$");
				local originalText = text;
				local size = font:CalcTextSizeA(font.FontSize, math.huge, 0.0, text);
				if size.x>=imgui.GetColumnWidth() then
					while size.x>=imgui.GetColumnWidth() do
						text = string.match(text, "(.-)%S+%s*$");
						size = font:CalcTextSizeA(font.FontSize, math.huge, 0.0, text);
					end
					self.centerWrappedColumnText(text, font);
					self.centerWrappedColumnText(string.sub(originalText, #text), font);
				else
					imgui.SetCursorPosX((imgui.GetColumnOffset()+(imgui.GetColumnWidth()/2))-size.x/2);
					imgui.PushFont(font);
					imgui.Text(text);
					imgui.PopFont();
				end
			end;
			self.addColumns = function(columnsCount, columns, id)
				columnsCount = columnsCount * 2;
				imgui.Separator();
				imgui.Columns(columnsCount, id, true);
				for index, item in ipairs(config.root.windows.spectatorInformation.columns) do
					if item[(2)] then
						local name = string.gsub(item[(1)], "##.*", "");
						do
							local item = columns[(item[(1)])];
							if item ~= nil then
								item.color = item.color or imgui.GetStyle().Colors[(imgui.Col.Text)];
								item.value = string.gsub(item.value, "##.*", "");
								self.centerWrappedColumnText(tostring(name), bold10);
								imgui.NextColumn();
								imgui.PushFont(regular9);
								imgui.PushStyleColor(imgui.Col.Text, item.color);
								if name~="Машина(-ы)" then
									self.centerWrappedColumnText(tostring(item.value), regular9);
								else
									local _, count = string.gsub(item.value, "%d+", "");
									local index = 1;
									imgui.SetCursorPosX((imgui.GetColumnOffset()+(imgui.GetColumnWidth()/2))-imgui.CalcTextSize(item.value).x/2);
									if count==0 then
										imgui.Text("Нет");
									else
										imgui.BeginGroup();
										for carId in string.gmatch(item.value, "%d+") do
											imgui.Text(carId);
											if imgui.IsItemHovered() then
												imgui.GetWindowDrawList():AddLine(imgui.ImVec2(imgui.GetItemRectMin().x, imgui.GetItemRectMax().y), imgui.GetItemRectMax(), -1, 2);
											end
											if imgui.IsItemClicked() then
												sampSendChat(string.format("/getbuycar %d", carId));
											end
											if count~=index then
												imgui.SameLine(nil, 0);
												imgui.Text(",");
											end
											imgui.SameLine(nil, 0);
											index = index + 1;
										end
										imgui.EndGroup();
										if not config.root.windows.spectatorInformation.showedHintFirstTime then
											if os.clock()-hintClock>=7 or imgui.IsItemHovered() then
												config.root.windows.spectatorInformation.showedHintFirstTime = true;
											end
										end
										animations:hint("Нажмите на любой из ID, для его телепортации", function()
											return not config.root.windows.spectatorInformation.showedHintFirstTime;
										end);
									end
								end
								imgui.PopStyleColor();
								imgui.PopFont();
								imgui.NextColumn();
								if imgui.GetColumnIndex()%(config.root.windows.spectatorInformation.type*2)==0 then
									imgui.Separator();
								end
							end
						end
					end
				end
			end;
			self.addMiddleTextAfterColumns = function(text, color, ...)
				if color == nil then
					color = imgui.GetStyle().Colors[(imgui.Col.Text)]
				end
				text = string.format(text, ...);
				imgui.Columns(1);
				imgui.SetCursorPosX(self.size.x/2-imgui.CalcTextSize(text).x/2);
				imgui.TextColored(color, text);
			end;
			self:begin(self.id, function()
				imgui.BeginGroup();
				imguiAssets:textWithFont(spectator:getActiveTime(), bold10);
				imgui.SameLine();
				imgui.SetCursorPosX((self.size.x-imgui.CalcTextSize(string.format("%s[%d]", spectator.nickname, spectator.id)).x)/2);
				imgui.BeginGroup();
				imgui.PushStyleVarVec2(imgui.StyleVar.ItemSpacing, imgui.ImVec2(0, 0));
				imguiAssets:textWithFont(string.gsub(spectator.nickname, "_", " "), bold10);
				imguiAssets:setPreviousItemAbleToCopy(spectator.nickname, "Никнейм скопирован.", string.format("Успешно скопирован никнейм: %s", spectator.nickname));
				imgui.SameLine();
				imguiAssets:textWithFont(string.format("[%d]", spectator.id), bold10);
				imguiAssets:setPreviousItemAbleToCopy(spectator.id, "Айди скопирован.", string.format("Успешно скопирован айди: %d", spectator.id));
				imgui.PopStyleVar();
				imgui.EndGroup();
				imguiAssets:textWithFont(spectator:platformToString(), bold10, imgui.ImVec2(self.size.x-imgui.CalcTextSize(spectator:platformToString()).x-10, 5));
				imgui.EndGroup();
				self.var.columnsPadding:apply();
				self.addColumns(config.root.windows.spectatorInformation.type, self.columns, self.id.."_COLUMNS");
				local result, handle = spectator:getHandle();
				if result then
					if isCharInAnyCar(handle) then
						local carHandle = storeCarCharIsInNoSave(handle);
						local carModel = getCarModel(carHandle);
						local carName = vehicle:getName(carModel);
						local _, carId = sampGetVehicleIdByCarHandle(carHandle);
						local _internal0;
						if (isCarEngineOn(carHandle)) then
							_internal0 = "Заведен";
						else
							_internal0 = "Заглушен";
						end
						local engineStatus = _internal0;
						local _internal1;
						if (engineStatus=="Заведен") then
							_internal1 = "8DFF85";
						else
							_internal1 = "FF8585";
						end
						local engineColor = common:convertHex2ImVec4(_internal1);
						local _internal2;
						if (getCarDoorLockStatus(carHandle)==0) then
							_internal2 = "Открыты";
						else
							_internal2 = "Закрыты";
						end
						local lockStatus = _internal2;
						local _internal3;
						if (lockStatus=="Открыты") then
							_internal3 = "8DFF85";
						else
							_internal3 = "FF8585";
						end
						local lockColor = common:convertHex2ImVec4(_internal3);
						self.addMiddleTextAfterColumns("%s[%d]", nil, carName, carId);
						self.addColumns(config.root.windows.spectatorInformation.type, {
							[("Двигатель")] = {
								value = engineStatus, 
								color = engineColor
							}, 
							[("Двери")] = {
								value = lockStatus, 
								color = lockColor
							}
						}, self.id.."_COLUMNS.CAR");
					end
				end
				self.var.columnsPadding:reset();
			end);
		end);
	end,
	["Config"] = function(...)
		local common = import("Common");
		local assets = import("Assets");
		function __config__:save()
			common:writeInFile(getWorkingDirectory().."/GAdmin/config/Main.json", neatJSON(self.root, {
				sort = true, 
				wrap = 40
			}));
		end
		function __config__:saveIfChanged()
			self.jsonStrings.root = encodeJson(self.root);
			if self.jsonStrings.file~=self.jsonStrings.root then
				self:save();
			end
		end
		function __config__:initialize()
			self.def = self.root;
			common:makeDirectoryTree({
				"GAdmin", 
				"GAdmin/temp", 
				"GAdmin/config", 
				"GAdmin/logs"
			});
			if not doesFileExist(getWorkingDirectory().."/GAdmin/config/Main.json") then
				self.jsonStrings.file = self.root;
				self:save();
			else
				local settings = decodeJson(common:readFileContent(getWorkingDirectory().."/GAdmin/config/Main.json"));
				if settings and type(settings)=="table" then
					self.root = settings;
					self.jsonStrings.file = encodeJson(self.root);
				else
					local scriptInformationPath = string.format("%s\\GAdmin\\logs\\CollectInformation (%s).log", getWorkingDirectory(), os.date("%Y%m%d-%H-%M-%S"));
					self.root = self.def;
					self.jsonStrings.file = encodeJson(self.root);
					sampfuncsLog(string.format("{FF0000}[DATE: %s] [CLOCK: %.2f] [GADMIN.DEBUG.FATAL] in <%s>:{FFFFFF} %s", os.date(), os.clock(), "config::initialize", "something went wrong with configuration. Configuration will be reset."));
					sampfuncsLog(string.format("{FF0000}[DATE: %s] [CLOCK: %.2f] [GADMIN.DEBUG.FATAL] in <%s>:{FFFFFF} %s", os.date(), os.clock(), "config::initialize", "saved script information in "..scriptInformationPath));
					common:writeInFile(getWorkingDirectory().."/GAdmin/config/Main.json", neatJSON(self.def, {
						sort = true, 
						wrap = 40
					}));
					lua_thread.create(function()
						while not isSampAvailable() do
							wait(0);
						end
						common:writeInFile(scriptInformationPath, assets:collectScriptInformation());
						common:sendScriptMessage("Something went wrong with the settings file.");
						common:sendScriptMessage("The settings will be reset and information about the script will be written to the next file:");
						common:sendScriptMessage(scriptInformationPath);
					end);
					return;
				end
			end
			local function mergeTables(a, b)
				for key, value in pairs(b) do
					if type(value)=="table" then
						if type(a[(key)])=="table" then
							mergeTables(a[(key)], value);
						elseif a[(key)]==nil then
							a[((key))] = value;
						end
					elseif a[(key)]==nil then
						a[((key))] = value;
					end
				end
			end
			mergeTables(self.root, self.def);
		end
		do
			local this = __config__;
			if this ~= nil then
				if not this.initialized then
					this:initialize();
					this.initialized = true;
				end
			end
		end
		return __config__;
	end,
	["events.onSendCommand"] = function(...)
		local commandRequester = import("CommandRequester");
		local config = import("Config");
		sampev.onSendCommand = function(command)
			local command = u8(command);
			commandRequester:setupUserCommandWatcher(command);
			if config.root.additions.shortCommands.use then
				for key, value in pairs(config.root.additions.shortCommands.commands) do
					if string.lower(string.match(command, "^/(%S+)%s*") or "")==key then
						sampSendChat(string.format("/"..value, select(1, string.match(command, "^/%S+(.*)"))));
						return false;
					end
				end
			end
		end;
	end,
	["imgui.Animations"] = function(...)
		local common = import("Common");
		local imguiAssets = import("imgui.Assets");
		local animations = {		};
		function animations:limit(v, min, max)
			if max == nil then
				max = 1.0
			end
			if min == nil then
				min = 0.0
			end
			local _internal1;
			if (v<min) then
				_internal1 = min;
			else
				local _internal0;
				if (v>max) then
					_internal0 = max;
				else
					_internal0 = v;
				end
				_internal1 = (_internal0);
			end
			return _internal1;
		end
		function animations:getContrastColor(backgroundColor, colorA, colorB)
			if colorB == nil then
				colorB = imgui.ImVec4(1, 1, 1, 1)
			end
			if colorA == nil then
				colorA = imgui.ImVec4(0, 0, 0, 1)
			end
			local _internal0;
			if ((1-(0.299*backgroundColor.x+0.587*backgroundColor.y+0.114*backgroundColor.z))<0.5) then
				_internal0 = colorA;
			else
				_internal0 = colorB;
			end
			return _internal0;
		end
		function animations:clickableText(label, text, font, areaToClickSize, duration, colors)
			if colors == nil then
				colors = {
					def = common:convertHex2ImVec4("5B5B5B"), 
					hovered = common:convertHex2ImVec4("FFFFFF")
				}
			end
			if duration == nil then
				duration = 0.2
			end
			if areaToClickSize == nil then
				areaToClickSize = imgui.ImVec4(0, 0)
			end
			if font == nil then
				font = regular9
			end
			if not UI_CLICKABLE_TEXT then
				UI_CLICKABLE_TEXT = {				};
			end
			if not UI_CLICKABLE_TEXT[(label)] then
				UI_CLICKABLE_TEXT[((label))] = {
					color = colors.def, 
					hovered = {
						cur = false, 
						old = false, 
						clock = nil
					}
				};
			end
			local this, result = UI_CLICKABLE_TEXT[(label)], nil;
			do
				if font then
					imgui.PushFont(font);
				end
				local pos = imgui.GetCursorPos();
				imgui.SetCursorPos(imgui.ImVec2(pos.x+math.max(0, areaToClickSize.x/2-imgui.CalcTextSize(text).x/2), pos.y+math.max(0, areaToClickSize.y/2-imgui.CalcTextSize(text).y/2)));
				imgui.TextColored(this.color, text);
				if font then
					imgui.PopFont();
				end
				imgui.SetCursorPos(pos);
				result = imgui.InvisibleButton(label, areaToClickSize);
				this.hovered.cur = imgui.IsItemHovered();
				if this.hovered.old~=this.hovered.cur then
					this.hovered.old = this.hovered.cur;
					this.hovered.clock = os.clock();
				end
			end
			if this.hovered.clock then
				if os.clock()-this.hovered.clock<=duration then
					local _internal0;
					if (this.hovered.cur) then
						_internal0 = colors.hovered;
					else
						_internal0 = colors.def;
					end
					this.color = imguiAssets:bringVec4To(this.color, _internal0, this.hovered.clock, duration);
				else
					local _internal0;
					if (this.hovered.cur) then
						_internal0 = colors.hovered;
					else
						_internal0 = colors.def;
					end
					this.color = _internal0;
				end
			end
			return result;
		end
		function animations:button(label, size, onHoveredFlags, duration, colors)
			if colors == nil then
				colors = {
					def = imgui.GetStyle().Colors[(imgui.Col.Button)], 
					hovered = imgui.GetStyle().Colors[(imgui.Col.ButtonHovered)], 
					active = imgui.GetStyle().Colors[(imgui.Col.ButtonActive)], 
					window = imgui.GetStyle().Colors[(imgui.Col.WindowBg)]
				}
			end
			if duration == nil then
				duration = {
					0.2, 
					0.4, 
					0.3
				}
			end
			if onHoveredFlags == nil then
				onHoveredFlags = 15
			end
			local result = false;
			local rounding = imgui.GetStyle().FrameRounding;
			local id = label;
			if not UI_ANIMATED_BUTTON then
				UI_ANIMATED_BUTTON = {				};
			end
			if not UI_ANIMATED_BUTTON[(id)] then
				UI_ANIMATED_BUTTON[((id))] = {
					radius = 0, 
					clock = {
						0, 
						0
					}, 
					pos = nil, 
					size = nil, 
					hovered = {
						state = false, 
						before = nil, 
						clock = 0, 
						color = colors.hovered
					}
				};
			end
			local this = UI_ANIMATED_BUTTON[(id)];
			local label = string.gsub(label, "##.*$", "");
			local textSize = imgui.CalcTextSize(label);
			local p = imgui.GetCursorScreenPos();
			colors.def = imgui.ImVec4(colors.def.x, colors.def.y, colors.def.z, imgui.GetStyle().Alpha);
			colors.hovered = imgui.ImVec4(colors.hovered.x, colors.hovered.y, colors.hovered.z, imgui.GetStyle().Alpha);
			colors.active = imgui.ImVec4(colors.active.x, colors.active.y, colors.active.z, imgui.GetStyle().Alpha);
			colors.def = imgui.ImVec4(colors.def.x, colors.def.y, colors.def.z, imgui.GetStyle().Alpha);
			if not size then
				local padding = imgui.GetStyle().FramePadding;
				size = imgui.ImVec2(textSize.x+(padding.x*2), textSize.y+(padding.y*2));
			end
			local pos = imgui.GetCursorPos();
			local dl = imgui.GetWindowDrawList();
			if this.size then
				local _internal0 = this.hovered.state;
				if (_internal0 == true) then
					_internal0 = imguiAssets:bringVec4To(this.hovered.color, colors.hovered, this.hovered.clock, duration[(3)]);
				else
					if (_internal0 == false) then
						_internal0 = imguiAssets:bringVec4To(this.hovered.color, imgui.ImVec4(colors.hovered.x, colors.hovered.y, colors.hovered.z, 0.0), this.hovered.clock, duration[(3)]);
					else
						_internal0 = nil;
					end
				end
				this.hovered.color = _internal0;
				dl:AddRectFilled(p-imgui.ImVec2(1, 1), imgui.ImVec2(p.x+size.x+1, p.y+size.y+1), imgui.ColorConvertFloat4ToU32(this.hovered.color), rounding, onHoveredFlags);
			end
			dl:AddRectFilled(p, p+size, imgui.ColorConvertFloat4ToU32(colors.def), rounding, onHoveredFlags);
			dl:PushClipRect(p+imgui.ImVec2(1, 1), p+size-imgui.ImVec2(1, 1));
			if this.pos then
				local alpha = 0.00;
				local timer = os.clock()-this.clock[(2)];
				if timer<=duration[(2)] then
					alpha = self:limit(1.00-((1.00/duration[(2)])*timer), 0.0, 1.0);
				end
				local timer = os.clock()-this.clock[(1)];
				if timer<=duration[(1)] then
					alpha = self:limit((1.00/duration[(1)])*timer, 0.0, 1.0);
					this.radius = (size.x*1.5/duration[(1)])*timer;
				end
				local col = imgui.GetStyle().Colors[(imgui.Col.ButtonActive)];
				dl:AddCircleFilled(this.pos, this.radius, imgui.ColorConvertFloat4ToU32(imgui.ImVec4(col.x, col.y, col.z, alpha)), 0xFF);
				if alpha<=0 then
					this.pos = nil;
				end
			end
			dl:PopClipRect();
			local al = imgui.GetStyle().ButtonTextAlign;
			imgui.SetCursorPos(imgui.ImVec2((size.x-textSize.x)*al.x, (size.y-textSize.y)*al.y)+pos);
			imgui.TextUnformatted(label);
			imgui.SetCursorPos(pos);
			if imgui.InvisibleButton(id..".UI_ANIMATED_BUTTON", size) then
				this.radius = 0;
				this.pos = imgui.GetMousePos();
				this.clock = {
					os.clock(), 
					os.clock()+duration[(1)]
				};
				result = true;
			end
			this.size = imgui.ImVec2(size.x+2, size.y+2);
			this.hovered.state = imgui.IsItemHovered() or os.clock()-this.clock[(2)]<0;
			if this.hovered.state~=this.hovered.before then
				this.hovered.before = this.hovered.state;
				this.hovered.clock = os.clock();
			end
			return result;
		end
		function animations:hint(label, hoverCallback, duration, hintColor)
			if hintColor == nil then
				hintColor = imgui.GetStyle().Colors[(imgui.Col.FrameBg)]
			end
			if duration == nil then
				duration = 0.2
			end
			if hoverCallback == nil then
				hoverCallback = imgui.IsItemHovered
			end
			local originalPos = imgui.GetCursorPos();
			local hovered = hoverCallback();
			local id = label;
			local show = true;
			label = string.gsub(label, "##.*", "");
			imgui.SameLine(nil, 0);
			if not UI_HINTS then
				UI_HINTS = {				};
			end
			if not UI_HINTS[(id)] then
				UI_HINTS[((id))] = {
					status = false, 
					timer = 0
				};
			end
			for uiId, hint in pairs(UI_HINTS) do
				if uiId~=id and os.clock()-hint.timer<=duration then
					show = false;
				end
			end
			do
				local this = UI_HINTS[(id)];
				if this ~= nil then
					if show and this.status~=hovered then
						this.status = hovered;
						this.timer = os.clock();
					end
					local function render(alpha)
						local size = imgui.GetItemRectSize();
						local screenPos = imgui.GetCursorScreenPos();
						local dl = imgui.GetWindowDrawList();
						local center = imgui.ImVec2(screenPos.x-(size.x/2), screenPos.y+(size.y/2)-(alpha*4)+10);
						local a = imgui.ImVec2(center.x-7, center.y-size.y-3);
						local b = imgui.ImVec2(center.x+7, center.y-size.y-3);
						local c = imgui.ImVec2(center.x, center.y-size.y+3);
						local color = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(hintColor.x, hintColor.y, hintColor.z, alpha));
						local flags = imgui.WindowFlags.Tooltip+imgui.WindowFlags.NoResize+imgui.WindowFlags.NoScrollbar+imgui.WindowFlags.NoTitleBar;
						dl:AddTriangleFilled(a, b, c, color);
						imgui.SetNextWindowPos(imgui.ImVec2(center.x, center.y-size.y-3), imgui.Cond.Always, imgui.ImVec2(0.5, 1));
						imgui.PushStyleColor(imgui.Col.PopupBg, hintColor);
						imgui.PushStyleColor(imgui.Col.Border, hintColor);
						imgui.PushStyleColor(imgui.Col.Text, self:getContrastColor(hintColor));
						imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(8, 8));
						imgui.PushStyleVarFloat(imgui.StyleVar.WindowRounding, 6);
						imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, alpha);
						local function maxWidth(text)
							local result = 0;
							for line in string.gmatch(text, "[^\n]+") do
								if imgui.CalcTextSize(line).x>result then
									result = imgui.CalcTextSize(line).x;
								end
							end
							return result;
						end
						imgui.SetNextWindowSize(imgui.ImVec2(maxWidth(label)+imgui.GetStyle().WindowPadding.x*2, -1), imgui.Cond.Always);
						imgui.Begin(id, nil, flags);
						for line in string.gmatch(label, "[^\n]+") do
							imgui.SetCursorPosX((imgui.GetWindowWidth()-imgui.CalcTextSize(line).x)/2);
							imgui.Text(line);
						end
						imgui.End();
						imgui.PopStyleVar(3);
						imgui.PopStyleColor(3);
					end
					if show then
						local between = os.clock()-this.timer;
						if between<=duration then
							local _internal0;
							if (hovered) then
								_internal0 = self:limit(between/duration, 0.00, 1.00);
							else
								_internal0 = self:limit(1.00-between/duration, 0.00, 1.00);
							end
							render(_internal0);
						elseif hovered then
							render(1.00);
						end
					end
				end
			end
			imgui.SetCursorPos(originalPos);
		end
		function animations:keyCap(label, isPressed, size)
			if isPressed == nil then
				isPressed = false
			end
			local dl = imgui.GetWindowDrawList();
			local p = imgui.GetCursorScreenPos();
			local rounding = imgui.GetStyle().FrameRounding;
			local colors = {
				[(true)] = imgui.GetStyle().Colors[(imgui.Col.ButtonActive)], 
				[(false)] = imgui.GetStyle().Colors[(imgui.Col.Button)]
			};
			if not UI_KEY_CAP then
				UI_KEY_CAP = {				};
			end
			if not UI_KEY_CAP[(label)] then
				UI_KEY_CAP[((label))] = {
					status = isPressed, 
					color = colors[(isPressed)], 
					clock = nil
				};
			end
			do
				local this = UI_KEY_CAP[(label)];
				if this ~= nil then
					if isPressed~=this.status then
						this.status, this.clock = isPressed, os.clock();
					end
					if this.clock then
						this.color = imguiAssets:bringVec4To(colors[(not isPressed)], colors[(isPressed)], this.clock, 0.1);
					end
					local text = string.gsub(label, "##.*", "");
					local textSize = imgui.CalcTextSize(text);
					local textPos = imgui.ImVec2(p.x+(size.x-textSize.x)/2, p.y+(size.y-textSize.y)/2);
					imgui.Dummy(size);
					dl:AddRectFilled(p, p+size, imgui.ColorConvertFloat4ToU32(this.color), rounding);
					dl:AddRect(p, p+size, imgui.ColorConvertFloat4ToU32(colors[(true)]), rounding, _, 1);
					if this.color.w<=0.5 then
						dl:AddText(imgui.ImVec2(textPos.x+1, textPos.y+1), 0xFF000000, text);
						dl:AddText(imgui.ImVec2(textPos.x-1, textPos.y-1), 0xFF000000, text);
						dl:AddText(imgui.ImVec2(textPos.x+1, textPos.y-1), 0xFF000000, text);
						dl:AddText(imgui.ImVec2(textPos.x-1, textPos.y+1), 0xFF000000, text);
					end
					dl:AddText(textPos, -1, text);
				end
			end
		end
		function animations:toggleButton(label, state, size, duration, colors)
			if colors == nil then
				colors = {
					enabled = imgui.GetStyle().Colors[(imgui.Col.FrameBgActive)], 
					disabled = imgui.GetStyle().Colors[(imgui.Col.FrameBg)]
				}
			end
			if duration == nil then
				duration = 0.3
			end
			if size == nil then
				size = imgui.ImVec2(40, 20)
			end
			local p = imgui.GetCursorScreenPos();
			local dl = imgui.GetWindowDrawList();
			local text = string.gsub(label, "##.*$", "");
			local textSize = imgui.CalcTextSize(title);
			local radius = 6;
			local result = false;
			local o = {
				x = 4, 
				y = p.y+(size.y/2)
			};
			local alpha = imgui.GetStyle().Alpha;
			colors.enabled = imgui.ImVec4(colors.enabled.x, colors.enabled.y, colors.enabled.z, alpha);
			colors.disabled = imgui.ImVec4(colors.disabled.x, colors.disabled.y, colors.disabled.z, alpha);
			local a = imgui.ImVec2(p.x+radius+o.x, o.y);
			local b = imgui.ImVec2(p.x+size.x-radius-o.x, o.y);
			if not UI_TOGGLE_BUTTON then
				UI_TOGGLE_BUTTON = {				};
			end
			do
				local this = UI_TOGGLE_BUTTON[(label)];
				if this ~= nil then
					imgui.BeginGroup();
					local pos = imgui.GetCursorPos();
					result = imgui.InvisibleButton(label, size);
					if result then
						state[((0))], this.clock = not state[(0)], os.clock();
					end
					if #text>0 then
						imgui.SetCursorPos(pos+imgui.ImVec2(size.x+imgui.GetStyle().ItemSpacing.x, (size.y-textSize.y)/2));
						imgui.Text(text);
					end
					imgui.EndGroup();
					if this.clock and os.clock()-this.clock<=duration then
						local _internal0;
						if (state[(0)]) then
							_internal0 = "enabled";
						else
							_internal0 = "disabled";
						end
						this.color = imguiAssets:bringVec4To(this.color, colors[(_internal0)], this.clock, duration);
						local _internal1;
						if (state[(0)]) then
							_internal1 = b;
						else
							_internal1 = a;
						end
						this.pos = imguiAssets:bringVec2To(this.pos, _internal1, this.clock, duration);
					else
						local _internal0;
						if (state[(0)]) then
							_internal0 = "enabled";
						else
							_internal0 = "disabled";
						end
						this.color = colors[(_internal0)];
						local _internal1;
						if (state[(0)]) then
							_internal1 = b;
						else
							_internal1 = a;
						end
						this.pos = _internal1;
					end
					dl:AddRect(p, p+size, imgui.ColorConvertFloat4ToU32(this.color), 10, 15, 1);
					dl:AddCircleFilled(this.pos, radius, imgui.ColorConvertFloat4ToU32(this.color), 0xFF);
				else
					local _internal0;
					if (state[(0)]) then
						_internal0 = "enabled";
					else
						_internal0 = "disaabled";
					end
					local _internal1;
					if (state[(0)]) then
						_internal1 = b;
					else
						_internal1 = a;
					end
					UI_TOGGLE_BUTTON[((label))] = {
						clock = nil, 
						color = colors[(_internal0)], 
						pos = _internal1
					};
				end
			end
			return result;
		end
		function animations:clickableUnderlinedText(label, state, duration, colors)
			if colors == nil then
				colors = {
					idle = imgui.GetStyle().Colors[(imgui.Col.TextDisabled)], 
					hovered = imgui.GetStyle().Colors[(imgui.Col.Text)], 
					selected = imgui.GetStyle().Colors[(imgui.Col.Text)]
				}
			end
			if duration == nil then
				duration = {
					0.5, 
					0.3
				}
			end
			if state == nil then
				state = false
			end
			local dl = imgui.GetWindowDrawList();
			local id = label;
			local label = string.gsub(label, "##.*$", "");
			local result = false;
			if not UI_CLICKABLE_UNDERLINED_TEXT then
				UI_CLICKABLE_UNDERLINED_TEXT = {				};
			end
			do
				local this = UI_CLICKABLE_UNDERLINED_TEXT[(id)];
				if this ~= nil then
					imgui.BeginGroup();
					local pos, p = imgui.GetCursorPos(), imgui.GetCursorScreenPos();
					imgui.TextColored(this.color, label);
					local s = imgui.GetItemRectSize();
					local hovered, clicked = imgui.IsItemHovered(), imgui.IsItemClicked();
					if this.hovered.state~=hovered and not state then
						this.hovered.state = hovered;
						this.hovered.clock = os.clock();
					end
					if clicked then
						this.clock = os.clock();
						result = true;
					end
					if os.clock()-this.clock<=duration[(1)] then
						local _internal1;
						if (state) then
							_internal1 = colors.selected;
						else
							local _internal0;
							if (hovered) then
								_internal0 = colors.hovered;
							else
								_internal0 = colors.idle;
							end
							_internal1 = (_internal0);
						end
						this.color = imguiAssets:bringVec4To(this.color, _internal1, this.clock, duration[(1)]);
					else
						local _internal1;
						if (state) then
							_internal1 = colors.selected;
						else
							local _internal0;
							if (hovered) then
								_internal0 = colors.hovered;
							else
								_internal0 = colors.idle;
							end
							_internal1 = (_internal0);
						end
						this.color = _internal1;
					end
					if this.hovered.clock then
						if os.clock()-this.hovered.clock<=duration[(2)] then
							local _internal0;
							if (this.hovered.state) then
								_internal0 = 1.00;
							else
								_internal0 = 0.00;
							end
							this.hovered.alpha = imguiAssets:bringFloatTo(this.hovered.alpha, _internal0, this.hovered.clock, duration[(2)]);
						else
							local _internal0;
							if (this.hovered.state) then
								_internal0 = 1.00;
							else
								_internal0 = 0.00;
							end
							this.hovered.alpha = _internal0;
							if not this.hovered.state then
								this.hovered.clock = nil;
							end
						end
						local max, y = s.x/2, p.y+s.y+3;
						local mid = p.x+max;
						local _internal0;
						if (this.hovered.state) then
							_internal0 = imgui.GetStyle().Alpha;
						else
							_internal0 = this.hovered.alpha;
						end
						local color = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(this.color.x, this.color.y, this.color.z, _internal0));
						dl:AddLine(imgui.ImVec2(mid, y), imgui.ImVec2(mid+(max*this.hovered.alpha), y), color, 3);
						dl:AddLine(imgui.ImVec2(mid, y), imgui.ImVec2(mid-(max*this.hovered.alpha), y), color, 3);
					end
					imgui.EndGroup();
				else
					local _internal0;
					if (state) then
						_internal0 = colors.selected;
					else
						_internal0 = colors.idle;
					end
					local _internal1;
					if (state) then
						_internal1 = 1.00;
					else
						_internal1 = 0.00;
					end
					UI_CLICKABLE_UNDERLINED_TEXT[((id))] = {
						color = _internal0, 
						clock = os.clock()+duration[(1)], 
						hovered = {
							state = state, 
							alpha = _internal1, 
							clock = os.clock()+duration[(2)]
						}
					};
				end
			end
			return result;
		end
		return animations;
	end,
	["Main"] = function(...)
		local hook = import("Hook");
		local icons = import("Icons");
		local common = import("Common");
		local notify = import("Notifications");
		local compressed = import("CompressedData");
		local commandRequester = import("CommandRequester");
		local autoUpdate = import("AutoUpdate");
		local config = import("Config");
		local assets = import("Assets");
		local movableWindows = import("MovableWindows");
		local style = import("imgui.Style");
		local playerNotes = import("imgui.PlayerNotes");
		local HotKey = import("imgui.HotKey");
		local imguiAssets = import("imgui.Assets");
		local greport = import("game.GReport");
		local binder = import("game.Binder");
		local user = import("game.User");
		local spectator = import("game.Spectator");
		require("moonloader");
		math.randomseed(os.time());
		local airbreak = {
			status = false, 
			coords = {			}
		};
		local fishEyeWeaponLock = false;
		local userFullyConnected = false;
		imgui.OnInitialize(function()
			local glyphRanges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic();
			icons:init(30);
			style:apply();
			bold10 = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(compressed.cantarellBold, 16.0, nil, glyphRanges);
			bold9 = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(compressed.cantarellBold, 14.0, nil, glyphRanges);
			bold12 = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(compressed.cantarellBold, 16.0, nil, glyphRanges);
			bold14 = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(compressed.cantarellBold, 20.0, nil, glyphRanges);
			regular9 = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(compressed.cantarellRegular, 14.0, nil, glyphRanges);
			regular10 = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(compressed.cantarellRegular, 15.5, nil, glyphRanges);
			regular12 = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(compressed.cantarellRegular, 16.0, nil, glyphRanges);
			regular14 = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(compressed.cantarellRegular, 19.0, nil, glyphRanges);
			bold = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(compressed.cantarellBold, 25.0, nil, glyphRanges);
			regular = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(compressed.cantarellRegular, 25.0, nil, glyphRanges);
			shadowPng = imgui.CreateTextureFromFileInMemory(imgui.new("const char*", compressed.shadow), #compressed.shadow);
			imgui.GetIO().IniFilename = nil;
		end);
		function main()
			while not isSampAvailable() do
				wait(0);
			end
			encoding.default = "CP1251";
			baseNameTagsDistance = memory.getfloat(sampGetServerSettingsPtr()+39);
			local hotKeyCallbacks = {			};
			hotKeyCallbacks.airbreak = function()
				if config.root.cheats.airbreak.use and user:getAloginStatus() then
					airbreak.status = not airbreak.status;
					local _internal0;
					if (airbreak.status) then
						_internal0 = "включен.";
					else
						_internal0 = "выключен.";
					end
					local notificationTitle = "AirBreak "..(_internal0);
					local notificationText = "";
					if airbreak.status then
						airbreak.coords = {
							getCharCoordinates(PLAYER_PED)
						};
						notificationText = "Чтобы выключить - нажмите эту клавиши повторно.";
					else
						notificationText = "Чтобы опять включить, нажмите эту клавишу повторно";
					end
					do
						local notificationType = config.root.cheats.airbreak.notificationType;
						if notificationType ~= nil then
							if notificationType~=NOTIFICATION_TYPE_NONE then
								local _internal0;
								if (notificationType==NOTIFICATION_TYPE_SCRIPT_MESSAGE) then
									_internal0 = notificationTitle;
								else
									_internal0 = nil;
								end
								notify:send({
									icon = icons.ICON_ARROW_UP, 
									title = notificationTitle, 
									text = notificationText, 
									duration = 2
								}, _internal0);
							end
						end
					end
				end
			end;
			hotKeyCallbacks.spectatorQuit = function()
				if spectator.status then
					sampSendMenuSelectRow(SPECTATOR_MENU_EXIT);
				end
			end;
			hotKeyCallbacks.switchCursorState = function()
				imguiAssets:switchCursorStatus();
			end;
			hotKeyCallbacks.switchSpectatorState = function()
				if spectator.status then
					sampSendMenuSelectRow(SPECTATOR_MENU_SWITCH);
				end
			end;
			hotKeyCallbacks.nextPlayerInSpectator = function()
				if spectator.status then
					sampSendMenuSelectRow(SPECTATOR_MENU_NEXT);
				end
			end;
			hotKeyCallbacks.previousPlayerInSpectator = function()
				if spectator.status then
					sampSendMenuSelectRow(SPECTATOR_MENU_BACK);
				end
			end;
			HotKey:new("main->spectatorQuit", {
				VK_I
			}, "Выйти из /sp"):registerCallback(hotKeyCallbacks.spectatorQuit);
			HotKey:new("main->airbreak", {
				VK_RSHIFT
			}, "Аирбрейк"):registerCallback(hotKeyCallbacks.airbreak);
			HotKey:new("main->switchCursorState", {
				VK_B
			}, "Переключить курсор"):registerCallback(hotKeyCallbacks.switchCursorState);
			HotKey:new("main->switchSpectatorState", {
				VK_U
			}, "Переключить режим наблюдения"):registerCallback(hotKeyCallbacks.switchSpectatorState);
			HotKey:new("main->nextPlayerInSpectator", {
				VK_RIGHT
			}, "Следующий игрок в /sp"):registerCallback(hotKeyCallbacks.nextPlayerInSpectator);
			HotKey:new("main->previousPlayerInSpectator", {
				VK_LEFT
			}, "Предыдущий игрок в /sp"):registerCallback(hotKeyCallbacks.previousPlayerInSpectator);
			playerNotes:initializeNotes();
			binder:initializeBinds();
			notify:send({
				title = "GAdmin успешно запущен!", 
				text = "GAdmin версии ".."1.3.1".." успешно инициализирован.", 
				icon = icons.ICON_STAR
			});
			user:addOnAloginCallback("Main->AirBreak", function(state)
				if not state and airbreak.status then
					airbreak.status = false;
				end
			end);
			for id = 1, config.root.additions.tracers.maxLines, 1 do
				bulletData[((id))] = {
					enable = false, 
					o = {
						x, 
						y, 
						z
					}, 
					t = {
						x, 
						y, 
						z
					}, 
					time = 0, 
					type = 0
				};
			end
			if sampGetCurrentServerAddress()~="46.174.48.194" then
				thisScript():unload();
			end
			common:makeDirectoryTree({
				"GAdmin", 
				"GAdmin/temp", 
				"GAdmin/config", 
				"GAdmin/logs"
			});
			autoUpdate:checkUpdates("https://gist.githubusercontent.com/defaultzone/bb1a15ee87bb408f6bf1bd08385988c7/raw/cfdb7e360ef6813c4294068ddc879c3f15c9f536/AutoUpdate.xml");
			onRecallUpHook = hook:new("void(__thiscall*)(void*)", onRecallUpHook, getModuleHandle("samp.dll")+0x65990);
			onRecallDownHook = hook:new("void(__thiscall*)(void*)", onRecallDownHook, getModuleHandle("samp.dll")+0x65A00);
			downloadUrlToFile("https://raw.githubusercontent.com/Vadim-Kamalov/GAdmin/main/CONTRIBUTORS", getWorkingDirectory().."\\GAdmin\\temp\\CONTRIBUTORS.txt", function(_, status, _, _)
				local downloadStatus = require("moonloader").download_status;
				local filePath = getWorkingDirectory().."\\GAdmin\\temp\\CONTRIBUTORS.txt";
				if status==downloadStatus.STATUS_ENDDOWNLOADDATA then
					lua_thread.create(function()
						while not doesFileExist(filePath) do
							wait(0);
						end
						contributorsFileSource = common:readFileContent(filePath);
						os.remove(filePath);
					end);
				end
			end);
			while true do
				wait(0);
				if common:isGamePaused() then
					if os.clock()-user.afkTimeClock>=1 then
						user.afkTimeClock = os.clock();
						user:setAfkTime(user:getAfkTime()+1);
					end
				else
					user:setAfkTime(0);
				end
				if config.root.additions.autoAlogout.use and user:getAloginStatus() then
					if user:getAfkTime()==config.root.additions.autoAlogout.alogoutSeconds then
						user:setAloginStatus(false);
						sampSendChat("/alogout");
						assets:messageBox("Вы провели в AFK на /alogin "..user:getAfkTime().." секунд. Скрипт покинул дежурство.", "GAdmin v".."1.3.1");
					elseif user:getAfkTime()==config.root.additions.autoAlogout.warningSeconds then
						assets:messageBox(string.format("Вы провели в AFK на /alogin %d секунд. У вас есть еще %d секунд что-бы зайти, иначе скрипт сам покинет дежурство.", user:getAfkTime(), config.root.additions.autoAlogout.alogoutSeconds-config.root.additions.autoAlogout.warningSeconds), "GAdmin v".."1.3.1");
					end
				end
				commandRequester:loop();
				greport:loop();
				user:updateTime();
				if movableWindows.changingWindowsPositions then
					displayHud(movableWindows.viewMode~=MV_ONLY_IN_SPECTATOR);
					displayRadar(movableWindows.viewMode~=MV_ONLY_IN_SPECTATOR);
				end
				if config.root.windows.killList.hideDefaultKillList and config.root.windows.killList.use then
					memory.write(sampGetKillInfoPtr(), 0x0, 0x4);
				end
				if config.root.windows.autoCompletion.use and isKeyDown(VK_CONTROL) and autoCompletion.condition() then
					if os.clock()-autoCompletion.clock>=0.15 then
						if isKeyDown(VK_UP) then
							autoCompletion.clock = os.clock();
							local _internal0;
							if (autoCompletion.position==1) then
								_internal0 = autoCompletion.commandsLength;
							else
								_internal0 = autoCompletion.position-1;
							end
							autoCompletion.position = _internal0;
						elseif isKeyDown(VK_DOWN) then
							autoCompletion.clock = os.clock();
							local _internal0;
							if (autoCompletion.position==autoCompletion.commandsLength) then
								_internal0 = 1;
							else
								_internal0 = autoCompletion.position+1;
							end
							autoCompletion.position = _internal0;
						end
					end
				end
				if spectator.status then
					local result, _ = sampGetCharHandleBySampPlayerId(spectator.id);
					while not result and not common:isInputsActive() do
						sampSendMenuSelectRow(SPECTATOR_MENU_SWITCH);
						wait(1000);
						result = sampGetCharHandleBySampPlayerId(spectator.id);
					end
					if sampIsPlayerPaused(spectator.id) then
						if os.clock()-spectator.afk.clock>=1 then
							spectator.afk.time = spectator.afk.time + 1;
							spectator.afk.clock = os.clock();
						end
					else
						spectator.afk.time = 0;
					end
				end
				if config.root.fix.chatOnVK_T and isKeyJustPressed(VK_T) and not common:isInputsActive() then
					sampSetChatInputEnabled(true);
				end
				if airbreak.status and config.root.cheats.airbreak.use then
					local heading = getCharHeading(PLAYER_PED);
					local camCoordX, camCoordY = getActiveCameraCoordinates();
					local targetCamX, targetCamY = getActiveCameraPointAt();
					local angle = getHeadingFromVector2d(targetCamX-camCoordX, targetCamY-camCoordY);
					local difference = 1.0;
					local speed = config.root.cheats.airbreak.speed;
					if isCharInAnyCar(PLAYER_PED) then
						heading = getCarHeading(storeCarCharIsInNoSave(PLAYER_PED));
						difference = 0.79;
					end
					setCharCoordinates(PLAYER_PED, airbreak.coords[(1)], airbreak.coords[(2)], airbreak.coords[(3)]-difference);
					if not common:isCursorActive() then
						if isKeyDown(VK_W) then
							airbreak.coords[((1))] = airbreak.coords[((1))] + speed*math.sin(-math.rad(angle));
							airbreak.coords[((2))] = airbreak.coords[((2))] + speed*math.cos(-math.rad(angle));
							if not isCharInAnyCar(playerPed) then
								setCharHeading(playerPed, angle);
							else
								setCarHeading(storeCarCharIsInNoSave(playerPed), angle);
							end
						elseif isKeyDown(VK_S) then
							airbreak.coords[((1))] = airbreak.coords[((1))] - speed*math.sin(-math.rad(heading));
							airbreak.coords[((2))] = airbreak.coords[((2))] - speed*math.cos(-math.rad(heading));
						end
						if isKeyDown(VK_A) then
							airbreak.coords[((1))] = airbreak.coords[((1))] - speed*math.sin(-math.rad(heading-90));
							airbreak.coords[((2))] = airbreak.coords[((2))] - speed*math.cos(-math.rad(heading-90));
						elseif isKeyDown(VK_D) then
							airbreak.coords[((1))] = airbreak.coords[((1))] - speed*math.sin(-math.rad(heading+90));
							airbreak.coords[((2))] = airbreak.coords[((2))] - speed*math.cos(-math.rad(heading+90));
						end
						if isKeyDown(VK_SPACE) or isKeyDown(VK_UP) then
							airbreak.coords[((3))] = airbreak.coords[((3))] + speed/2.0;
						end
						if isKeyDown(VK_LSHIFT) or isKeyDown(VK_DOWN) and airbreak.coords[(3)]>-95.0 then
							airbreak.coords[((3))] = airbreak.coords[((3))] - speed/2.0;
						end
					end
				end
				if config.root.additions.fishEye.use or config.root.additions.zoomSpectatorCamera.use then
					local _internal0;
					if (config.root.additions.fishEye.use) then
						_internal0 = config.root.additions.fishEye.fov;
					else
						_internal0 = 70;
					end
					local _internal1;
					if (config.root.additions.zoomSpectatorCamera.use) then
						_internal1 = spectatorCameraFov;
					else
						_internal1 = 70;
					end
					local fov = {
						user = _internal0, 
						spectator = _internal1
					};
					local _internal2;
					if (fov.spectator==-1) then
						_internal2 = fov.user;
					else
						_internal2 = fov.spectator;
					end
					fov.spectator = _internal2;
					local _internal3;
					if (spectator.status) then
						_internal3 = fov.spectator;
					else
						_internal3 = fov.user;
					end
					local currentFov = _internal3;
					local charTargeting = memory.getint8(getCharPointer(PLAYER_PED)+0x528, false)==19;
					local shiperRifleId = 34;
					if isCurrentCharWeapon(PLAYER_PED, sniperRifleId) and charTargeting then
						if not fishEyeWeaponLock then
							cameraSetLerpFov(70, 70, 1000, 1);
							fishEyeWeaponLock = true;
						end
					else
						cameraSetLerpFov(currentFov, currentFov, 1000, 1);
						fishEyeWeaponLock = false;
					end
				end
			end
		end
		function onRecallUpHook(...)
			if not (config.root.windows.autoCompletion.use and isKeyDown(VK_CONTROL) and autoCompletion.condition()) then
				onRecallUpHook(...);
			end
		end
		function onRecallDownHook(...)
			if not (config.root.windows.autoCompletion.use and isKeyDown(VK_CONTROL) and autoCompletion.condition()) then
				onRecallDownHook(...);
			end
		end
	end,
	["events.onWindowMessage"] = function(...)
		local config = import("Config");
		local common = import("Common");
		local imguiAssets = import("imgui.Assets");
		local HotKey = import("imgui.HotKey");
		local ped = import("game.sa.Ped");
		local vehicle = import("game.sa.Vehicle");
		local greport = import("game.GReport");
		local user = import("game.User");
		local spectator = import("game.Spectator");
		local justPressed = {
			mButtonDown = false
		};
		function onWindowMessage(msg, wparam, lparam)
			do
				local this = __movableWindows__;
				if this.changingWindowsPositions and not sampIsChatInputActive() and not sampIsDialogActive() and not isSampfuncsConsoleActive() then
					if msg==wm.WM_SYSKEYDOWN or msg==wm.WM_KEYDOWN then
						local keys = {
							[(VK_1)] = MV_ONLY_IN_SPECTATOR, 
							[(VK_2)] = MV_ONLY_NOT_IN_SPECTATOR, 
							[(VK_3)] = MV_DEFAULT
						};
						if keys[(wparam)] then
							__movableWindows__.viewMode = keys[(wparam)];
							common:sendScriptMessage("Режим отображения окон переключен: %s", MV_VIEW_DESCRIPTIONS[(this.viewMode)]);
							consumeWindowMessage(true, false);
						elseif wparam==VK_ESCAPE then
							this:executeChangingWindowsPositions();
							consumeWindowMessage(true, false);
						end
					end
				end
			end
			HotKey:setupWatcher(msg, wparam, lparam);
			if msg==wm.WM_KILLFOCUS then
				receivedKillFocusEvent = true;
			elseif msg==wm.WM_SETFOCUS then
				receivedKillFocusEvent = false;
			end
			if config.root.cheats.clickwarp.use and user:getAloginStatus() then
				if msg==wm.WM_MBUTTONDOWN and not justPressed.mButtonDown then
					clickWarp.enabled = not clickWarp.enabled;
					justPressed.mButtonDown = true;
					local _internal0;
					if (clickWarp.enabled) then
						_internal0 = 3;
					else
						_internal0 = 0;
					end
					sampSetCursorMode(_internal0);
					imguiAssets:setCursorStatus(not clickWarp.enabled);
					consumeWindowMessage(true, true);
				elseif msg==wm.WM_MBUTTONUP then
					justPressed.mButtonDown = false;
				elseif msg==wm.WM_LBUTTONDOWN and clickWarp.enabled and clickWarp.teleportation.pos then
					local pos = clickWarp.teleportation.pos;
					do
						local handle = clickWarp.teleportation.tpIntoCar;
						if handle ~= nil then
							if not vehicle:jumpInto(handle) then
								ped:teleport(handle, pos.x, pos.y, pos.z);
							end
						else
							ped:teleport(pos.x, pos.y, pos.z);
						end
					end
					sampSetCursorMode(0);
					imguiAssets:setCursorStatus(true);
					clickWarp.enabled = false;
					clickWarp.teleportation = {
						tpIntoCar = nil, 
						pos = nil
					};
					consumeWindowMessage(true, true);
				end
			end
			if msg==wm.WM_SYSKEYDOWN or msg==wm.WM_KEYDOWN and not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() then
				if greport.window.state and not isGamePaused() and config.root.windows.greport.use and wparam==13 then
					if #ffi.string(greport.window.answerInput)==0 then
						greport.window.noInputClock = os.clock();
					else
						greport.player:answer(ffi.string(greport.window.answerInput));
						consumeWindowMessage(true, true);
					end
				end
			end
			if msg==wm.WM_MOUSEWHEEL and not greport.window.state and not mainWindow.state[(0)] then
				if spectator.status and config.root.additions.zoomSpectatorCamera.use then
					local step = config.root.additions.zoomSpectatorCamera.step;
					if wparam==0x780000 then
						spectatorCameraFov = math.min(getCameraFov()+step, 130);
					elseif wparam==0xFF880000 then
						spectatorCameraFov = math.max(getCameraFov()-step, 50);
					end
					consumeWindowMessage(true, true);
				else
					spectatorCameraFov = -1;
				end
			end
		end
	end,
	["game.binder.Variables"] = function(...)
		local ped = import("game.sa.Ped");
		local spectator = import("game.Spectator");
		local greport = import("game.GReport");
		local user = import("game.User");
		local variables = {
			description = {			}, 
			order = {			}
		};
		table.insert(variables.order, "CLOSEST_PLAYER_ID");
		variables.description[(("CLOSEST_PLAYER_ID"))] = "ID ближайшего игрока к вам/игроку за которым вы следите";
		variables[(("CLOSEST_PLAYER_ID"))] = (function()
			do
				local _internal0;
				if (spectator.status) then
					_internal0 = spectator.id;
				else
					_internal0 = PLAYER_PED;
				end
				local handle = ped:getClosestHandle(_internal0);
				if handle ~= nil then
					return select(2, sampGetPlayerIdByCharHandle(handle));
				end
			end
		end);
		table.insert(variables.order, "CLOSEST_PLAYER_NICKNAME");
		variables.description[(("CLOSEST_PLAYER_NICKNAME"))] = "Никнейм ближайшего игрока к вам/игроку за которым вы следите";
		variables[(("CLOSEST_PLAYER_NICKNAME"))] = (function()
			do
				local _internal0;
				if (spectator.status) then
					_internal0 = spectator.id;
				else
					_internal0 = PLAYER_PED;
				end
				local handle = ped:getClosestHandle(_internal0);
				if handle ~= nil then
					local _, id = sampGetPlayerIdByCharHandle(handle);
					return sampGetPlayerNickname(id);
				end
			end
		end);
		table.insert(variables.order, "SPECTATOR_ID");
		variables.description[(("SPECTATOR_ID"))] = "ID игрока за которым вы следите";
		variables[(("SPECTATOR_ID"))] = (function()
			if spectator.status then
				return spectator.id;
			end
		end);
		table.insert(variables.order, "SPECTATOR_NICKNAME");
		variables.description[(("SPECTATOR_NICKNAME"))] = "Никнейм игрока за которым вы следите";
		variables[(("SPECTATOR_NICKNAME"))] = (function()
			if spectator.status then
				return spectator.nickname;
			end
		end);
		table.insert(variables.order, "GREPORT_ACTIVE_TIME");
		variables.description[(("GREPORT_ACTIVE_TIME"))] = "Активное время (МИН:CЕК) полученного GReport'а";
		variables[(("GREPORT_ACTIVE_TIME"))] = (function()
			return greport.player:getActiveTime();
		end);
		table.insert(variables.order, "SPECTATOR_VEHICLE_ID");
		variables.description[(("SPECTATOR_VEHICLE_ID"))] = "ID машины (из /dl) игрока за которым вы следите";
		variables[(("SPECTATOR_VEHICLE_ID"))] = (function()
			if spectator.status then
				local result, handle = spectator:getHandle();
				if isCharInAnyCar(handle) and result then
					do
						local car = storeCarCharIsInNoSave(handle);
						if car ~= nil then
							local result, vehId = sampGetVehicleIdByCarHandle(car);
							local _internal0;
							if (result) then
								_internal0 = vehId;
							else
								_internal0 = nil;
							end
							return _internal0;
						end
					end
				end
			end
		end);
		table.insert(variables.order, "SPECTATOR_".."PLATFORM");
		variables.description[(("SPECTATOR_".."PLATFORM"))] = "Платформа".." игрока за которым вы следите";
		variables[(("SPECTATOR_".."PLATFORM"))] = (function()
			if spectator.status then
				return tostring(spectator:getInformation().platform);
			end
		end);
		table.insert(variables.order, "SPECTATOR_".."ARMOR");
		variables.description[(("SPECTATOR_".."ARMOR"))] = "Броня".." игрока за которым вы следите";
		variables[(("SPECTATOR_".."ARMOR"))] = (function()
			if spectator.status then
				return tostring(spectator:getInformation().armor);
			end
		end);
		table.insert(variables.order, "SPECTATOR_".."PING");
		variables.description[(("SPECTATOR_".."PING"))] = "Пинг".." игрока за которым вы следите";
		variables[(("SPECTATOR_".."PING"))] = (function()
			if spectator.status then
				return tostring(spectator:getInformation().ping);
			end
		end);
		table.insert(variables.order, "SPECTATOR_".."WEAPON");
		variables.description[(("SPECTATOR_".."WEAPON"))] = "Оружие".." игрока за которым вы следите";
		variables[(("SPECTATOR_".."WEAPON"))] = (function()
			if spectator.status then
				return tostring(spectator:getInformation().weapon);
			end
		end);
		table.insert(variables.order, "SPECTATOR_".."ACCOUNT_ID");
		variables.description[(("SPECTATOR_".."ACCOUNT_ID"))] = "ID аккаунта".." игрока за которым вы следите";
		variables[(("SPECTATOR_".."ACCOUNT_ID"))] = (function()
			if spectator.status then
				return tostring(spectator:getInformation().accountId);
			end
		end);
		table.insert(variables.order, "SPECTATOR_".."HEALTH");
		variables.description[(("SPECTATOR_".."HEALTH"))] = "Пинг".." игрока за которым вы следите";
		variables[(("SPECTATOR_".."HEALTH"))] = (function()
			if spectator.status then
				return tostring(spectator:getInformation().health);
			end
		end);
		table.insert(variables.order, "SPECTATOR_".."MONEY");
		variables.description[(("SPECTATOR_".."MONEY"))] = "Деньги на руках".." игрока за которым вы следите";
		variables[(("SPECTATOR_".."MONEY"))] = (function()
			if spectator.status then
				return tostring(spectator:getInformation().money);
			end
		end);
		table.insert(variables.order, "SPECTATOR_".."BANK");
		variables.description[(("SPECTATOR_".."BANK"))] = "Деньги в банке".." игрока за которым вы следите";
		variables[(("SPECTATOR_".."BANK"))] = (function()
			if spectator.status then
				return tostring(spectator:getInformation().bank);
			end
		end);
		table.insert(variables.order, "SPECTATOR_".."FRACTION");
		variables.description[(("SPECTATOR_".."FRACTION"))] = "Фракция".." игрока за которым вы следите";
		variables[(("SPECTATOR_".."FRACTION"))] = (function()
			if spectator.status then
				return tostring(spectator:getInformation().fraction);
			end
		end);
		table.insert(variables.order, "SPECTATOR_".."RANG");
		variables.description[(("SPECTATOR_".."RANG"))] = "Должность".." игрока за которым вы следите";
		variables[(("SPECTATOR_".."RANG"))] = (function()
			if spectator.status then
				return tostring(spectator:getInformation().rang);
			end
		end);
		table.insert(variables.order, "SPECTATOR_".."ALL_VEHICLES");
		variables.description[(("SPECTATOR_".."ALL_VEHICLES"))] = "Машина(-ы)".." игрока за которым вы следите";
		variables[(("SPECTATOR_".."ALL_VEHICLES"))] = (function()
			if spectator.status then
				return tostring(spectator:getInformation().vehicle);
			end
		end);
		table.insert(variables.order, "SPECTATOR_".."ALL_HOUSES");
		variables.description[(("SPECTATOR_".."ALL_HOUSES"))] = "Дом(а)".." игрока за которым вы следите";
		variables[(("SPECTATOR_".."ALL_HOUSES"))] = (function()
			if spectator.status then
				return tostring(spectator:getInformation().house);
			end
		end);
		table.insert(variables.order, "SPECTATOR_".."VIP");
		variables.description[(("SPECTATOR_".."VIP"))] = "VIP cтатус".." игрока за которым вы следите";
		variables[(("SPECTATOR_".."VIP"))] = (function()
			if spectator.status then
				return tostring(spectator:getInformation().vip);
			end
		end);
		table.insert(variables.order, "SPECTATOR_".."REGISTRATION_DATE");
		variables.description[(("SPECTATOR_".."REGISTRATION_DATE"))] = "Дата регистрации".." игрока за которым вы следите";
		variables[(("SPECTATOR_".."REGISTRATION_DATE"))] = (function()
			if spectator.status then
				return tostring(spectator:getInformation().regDate);
			end
		end);
		table.insert(variables.order, "SPECTATOR_".."WARNINGS");
		variables.description[(("SPECTATOR_".."WARNINGS"))] = "Количество предупреждений".." игрока за которым вы следите";
		variables[(("SPECTATOR_".."WARNINGS"))] = (function()
			if spectator.status then
				return tostring(spectator:getInformation().warnings);
			end
		end);
		table.insert(variables.order, "SPECTATOR_".."STAGE");
		variables.description[(("SPECTATOR_".."STAGE"))] = "Стадия".." игрока за которым вы следите";
		variables[(("SPECTATOR_".."STAGE"))] = (function()
			if spectator.status then
				return tostring(spectator:getInformation().stage);
			end
		end);
		table.insert(variables.order, "SPECTATOR_".."AFK_TIME");
		variables.description[(("SPECTATOR_".."AFK_TIME"))] = "Время в AFK".." игрока за которым вы следите";
		variables[(("SPECTATOR_".."AFK_TIME"))] = (function()
			if spectator.status then
				return tostring(spectator:getInformation().afkTime);
			end
		end);
		table.insert(variables.order, "SPECTATOR_".."CURRENT_MOVE_SPEED");
		variables.description[(("SPECTATOR_".."CURRENT_MOVE_SPEED"))] = "Текущая скорость".." игрока за которым вы следите";
		variables[(("SPECTATOR_".."CURRENT_MOVE_SPEED"))] = (function()
			if spectator.status then
				return tostring(spectator:getInformation().moveSpeed.current);
			end
		end);
		table.insert(variables.order, "SPECTATOR_".."MAX_MOVE_SPEED");
		variables.description[(("SPECTATOR_".."MAX_MOVE_SPEED"))] = "Максимальная скорость".." игрока за которым вы следите";
		variables[(("SPECTATOR_".."MAX_MOVE_SPEED"))] = (function()
			if spectator.status then
				return tostring(spectator:getInformation().moveSpeed.max);
			end
		end);
		table.insert(variables.order, "SPECTATOR_".."TOTAL_SHOTS");
		variables.description[(("SPECTATOR_".."TOTAL_SHOTS"))] = "Количество выстрелов".." игрока за которым вы следите";
		variables[(("SPECTATOR_".."TOTAL_SHOTS"))] = (function()
			if spectator.status then
				return tostring(spectator:getInformation().shot.total);
			end
		end);
		table.insert(variables.order, "SPECTATOR_".."HITS");
		variables.description[(("SPECTATOR_".."HITS"))] = "Количество попаданий".." игрока за которым вы следите";
		variables[(("SPECTATOR_".."HITS"))] = (function()
			if spectator.status then
				return tostring(spectator:getInformation().shot.hit);
			end
		end);
		table.insert(variables.order, "GREPORT_".."SENDER_ID");
		variables.description[(("GREPORT_".."SENDER_ID"))] = "ID".." игрока за которым закреплен GReport";
		variables[(("GREPORT_".."SENDER_ID"))] = (function()
			if greport.player.active then
				return tostring(greport.player.id);
			end
		end);
		table.insert(variables.order, "GREPORT_".."SENDER_NICKNAME");
		variables.description[(("GREPORT_".."SENDER_NICKNAME"))] = "Никнейм".." игрока за которым закреплен GReport";
		variables[(("GREPORT_".."SENDER_NICKNAME"))] = (function()
			if greport.player.active then
				return tostring(greport.player.nickname);
			end
		end);
		table.insert(variables.order, "GREPORT_".."QUESTION");
		variables.description[(("GREPORT_".."QUESTION"))] = "Вопрос".." игрока за которым закреплен GReport";
		variables[(("GREPORT_".."QUESTION"))] = (function()
			if greport.player.active then
				return tostring(greport.player.context);
			end
		end);
		table.insert(variables.order, "USER_".."ALOGIN_STATE");
		variables.description[(("USER_".."ALOGIN_STATE"))] = "Статус /alogin (+ ИЛИ -)";
		variables[(("USER_".."ALOGIN_STATE"))] = (function()
			do
				local it = user:getAloginStatus();
				if it ~= nil then
					local _internal0 = type(it);
					if (_internal0 == "boolean") then
						local _internal1;
						if (it) then
							_internal1 = "+";
						else
							_internal1 = "-";
						end
						_internal0 = (_internal1);
					else
						_internal0 = tostring(it);
					end
					return _internal0;
				end
			end
		end);
		table.insert(variables.order, "USER_".."ID");
		variables.description[(("USER_".."ID"))] = "Ваш ID";
		variables[(("USER_".."ID"))] = (function()
			do
				local it = user:getId();
				if it ~= nil then
					local _internal0 = type(it);
					if (_internal0 == "boolean") then
						local _internal1;
						if (it) then
							_internal1 = "+";
						else
							_internal1 = "-";
						end
						_internal0 = (_internal1);
					else
						_internal0 = tostring(it);
					end
					return _internal0;
				end
			end
		end);
		table.insert(variables.order, "USER_".."NICKNAME");
		variables.description[(("USER_".."NICKNAME"))] = "Ваш IC никнейм";
		variables[(("USER_".."NICKNAME"))] = (function()
			do
				local it = user:getNickname();
				if it ~= nil then
					local _internal0 = type(it);
					if (_internal0 == "boolean") then
						local _internal1;
						if (it) then
							_internal1 = "+";
						else
							_internal1 = "-";
						end
						_internal0 = (_internal1);
					else
						_internal0 = tostring(it);
					end
					return _internal0;
				end
			end
		end);
		table.insert(variables.order, "USER_".."PING");
		variables.description[(("USER_".."PING"))] = "Ваш пинг";
		variables[(("USER_".."PING"))] = (function()
			do
				local it = user:getPing();
				if it ~= nil then
					local _internal0 = type(it);
					if (_internal0 == "boolean") then
						local _internal1;
						if (it) then
							_internal1 = "+";
						else
							_internal1 = "-";
						end
						_internal0 = (_internal1);
					else
						_internal0 = tostring(it);
					end
					return _internal0;
				end
			end
		end);
		table.insert(variables.order, "USER_".."OOC_NICKNAME");
		variables.description[(("USER_".."OOC_NICKNAME"))] = "Ваш OOC никнейм (если еще не получен, вернет \"Администратор\")";
		variables[(("USER_".."OOC_NICKNAME"))] = (function()
			do
				local it = user:getOOCNickname();
				if it ~= nil then
					local _internal0 = type(it);
					if (_internal0 == "boolean") then
						local _internal1;
						if (it) then
							_internal1 = "+";
						else
							_internal1 = "-";
						end
						_internal0 = (_internal1);
					else
						_internal0 = tostring(it);
					end
					return _internal0;
				end
			end
		end);
		table.insert(variables.order, "USER_".."ADMIN_LVL");
		variables.description[(("USER_".."ADMIN_LVL"))] = "Ваш уровень администрирования (если еще не получен, вернет \"-1\")";
		variables[(("USER_".."ADMIN_LVL"))] = (function()
			do
				local it = user:getAdminLvl();
				if it ~= nil then
					local _internal0 = type(it);
					if (_internal0 == "boolean") then
						local _internal1;
						if (it) then
							_internal1 = "+";
						else
							_internal1 = "-";
						end
						_internal0 = (_internal1);
					else
						_internal0 = tostring(it);
					end
					return _internal0;
				end
			end
		end);
		return variables;
	end,
	["CompressedData"] = function(...)
		return {
			iconFont = "7])#######d',Iq'/###W),##2(V$#Q6>##.FxF>6pY(/Q5)=-'OE/1I[n42NrEm=g.>>#-rEn/aNV=Bh*dZ14rEn/5<jl&m2XGH`$vhLkat;54EXQ'$jg0F0&'+Mk`'H:=9>n&%J%/GF)u2(?`Ca22tiW%,5LsC7so.hHVw?Zda)2Ib';9CHr`[Gv*Pk.r1dD4AJr9.1CC#,1SdV@T'QW.;h^`I=Sd'&YlmELJ%hS.o6Q<B@KT:pNn[wW?JtWR0iR/G7DZ<H9SH:5iQL?-qmnUCY454j-/L>?2Gt]-@C=GHa4UBc+xH.K4KNp[1)Q-GJsES^rNA=><L22U7Zk:&<:gr6Z<TT9'KMM')>MMFA@;;$HOXh#vZ/I$64CB#m<v<Bn_Sq)w^&.$MS:;$0[DW%*]qr$4Uq'#it<SneXZV$J)-5Jxm#:)],LF%*op:#/v[fLaeVV$fJg2#RBr<9W2:(($_C0$5QF.#-;A5#lFBoL+`cS.%####1`/,M5&1kLTXH##[ma1#)(MT.TE*1#)`5<-NM#<-@q@u-Y)loL*+.q1GR;;$^YuZG'wT?+hMhW5R%%q?=R73J(*JKT)'_?+jSqW5T+.q?7fgWG`oI?OYOU:vO/uZGk_`H(U6sa2@d/$=+;B<GlhTTQmeiH(W<&b2Bj8$=-AK<GPaTHLXC%:2ddMl#uq[f10;o/1ahc+#SAU/#FqG3#9J:7#,$-;#vUu>#h,hB#Z[YF#=*fH#i+[0#$),##FreQ-V(2o%cu68%47no%8ONP&<h/2'@*gi'DBGJ(HZ(,)Ls_c)P5@D*TMw%+XfW]+](9>,a@pu,baSmAgEX&#kQk&#o^''#sj9'#wvK'#%-_'#)9q'#-E-(#1Q?(#5^Q(#9jd(#=vv(#A,3)#E8E)#IDW)#MPj)#Q]&*#Ui8*#YuJ*#^+^*#b7p*#fC,+#jO>+#n[P+#t]'j%@lix=$.JY>(F+;?,_br?0wBS@49$5A8QZlA<j;MBJWl^o]?m-#F<x-#JH4.#NTF.#RaX.#Vmk.#Z#(/#_/:/#c;L/#gG_/#kSq/#o`-0#sl?0#wxQ0#%/e0#);w0#-G31#1SE1#5`W1#9lj1#=x&2#A.92#E:K2#IF^2#MRp2#Q_,3#Uk>3#YwP3#^-d3#b9v3#fE24#jQD4#n^V4#rji4#vv%5#$-85#(9J5#,E]5#0Qo5#4^+6#8j=6#<vO6#@,c6#D8u6#HD17#LPC7#P]U7#Tih7#Xu$8#]+78#B.>>#9.`$#FVXV-]3n0#@%FrL&VcS.PWfi'BdlS.$&###-nl-MICZY#C9ew'uIO&#7:#-M.>pV-`MC_&;(k-$w.xfLCL,hLMhrr$C9ew'uIO&#;:#-M.>pV-dYC_&;(k-$%GFgLCL,hLQ645&C9ew'uIO&#1fG<-1>T;-e4?h-^xC_&uIO&#/M#<-4GpV-fG,F%4E0.$+l'hL9ZReMWm,/(7d,g)xIO&#3M#<-8GpV-jS,F%8Q0.$/.LhL=sweM[;DG);2D)+xIO&#7M#<-BGpV-n`,F%Bp0.$3FqhLGY'gMu$g+MvD4jL)5T;-Sr-A-W1^gLbr<A+GI5s.xIO&#=M#<-HGpV-tr,F%H,1.$9kQiLM(_gMf@TY,KnL50xIO&#AM#<-RGpV-x(-F%RJ1.$=-wiLWedhMjelr-Us]G3xIO&#EM#<-VGpV-&5-F%VV1.$AEEjL['3iMn3.5/YAu`4xIO&#IM#<-Y>T;-F$iH-m1^gLu$g+M0J<mL*>pV-,G-F%c%2.$Gj&kLhpJjMtj&/1fXfS8xIO&#OM#<-gGpV-0S-F%g12.$K,KkLl2pjMx8>G2j'(m9xIO&#SM#<-kGpV-4`-F%k=2.$ODpkLvoukM&^U`3t,8)=xIO&#WM#<-uGpV-8l-F%u[2.$S]>lL$2DlMu$g+M8uPoL)5T;-5pCl-MHF_&uIO&#]M#<-$HpV-=%.F%$l2.$X%mlL)PrlM/YJV6-`%pAxIO&#aM#<-.HpV-A1.F%.43.$]=;mL37xmM3(co71.=2CxIO&#eM#<-2HpV-E=.F%2@3.$aU`mL7OFnM7L$295RTJDxIO&#iM#<-6HpV-II.F%<_3.$en.nLA6LoM;q;J:?We]GxIO&#mM#<-@HpV-MU.F%@k3.$i0SnLENqoM??Sc;C&'vHxIO&#qM#<-DHpV-Qb.F%Dw3.$mHxnLIg?pMCdk%=M+72LxIO&#uM#<-NHpV-Un.F%N?4.$qaFoLSMEqMG2->>QONJMxIO&##N#<-RHpV-Y$/F%RK4.$u#loLWfjqMKVDV?UtfcNxIO&#'N#<-VHpV-^0/F%]j4.$#<:pLbLprMO%]o@`#wuQxIO&#+N#<-aHpV-b</F%av4.$'T_pLfe>sMSIt1BdG88SxIO&#/N#<-eHpV-fH/F%e,5.$+m-qLj'dsM[$6JCk&a<#xIO&#3N#<-#GpV-jT/F%#h/.$//RqL(IccM[<McD&u^>$xIO&#7N#<-'GpV-na/F%'t/.$3GwqL,b1dM`ae%F*CvV%xIO&#;N#<-+GpV-rm/F%1<0.$7`ErL6H7eMd/'>G4H0j(xIO&#?N#<-5GpV-v#0F%5H0.$;xjrL:a[eMhS>VH8mG,*xIO&#CN#<-9GpV-$00F%9T0.$?:9sL>#+fMlxUoIBrW>-xIO&#GN#<-CGpV-(<0F%Cs0.$CR^sLH`0gMpFn1KF@pV.xIO&#KN#<-GGpV-,H0F%G)1.$Gk,tLLxTgMtk/JLJe1p/xIO&#ON#<-KGpV-0T0F%QG1.$K-QtLV_ZhMx9GcMTjA,3xIO&#SN#<-UGpV-4a0F%US1.$OEvtLZw)iM&__%OX8YD4xIO&#WN#<-YGpV-8m0F%Y`1.$S^DuL_9NiM*-w=Pc=jV7xIO&#[N#<-dGpV-<#1F%d(2.$WviuLivSjM.Q8VQgb+p8xIO&#`N#<-hGpV-@/1F%h42.$[88vLm8#kM2vOoRk0C2:xIO&#dN#<-lGpV-D;1F%rR2.$`P]vLwu(lM6Dh1Tu5SD=xIO&#hN#<-vGpV-HG1F%v_2.$di+wL%8MlM:i)JU#Zk]>xIO&#lN#<-$HpV-LS1F%$l2.$h+PwL)PrlM>7AcV-`%pAxIO&#pN#<-.HpV-P`1F%.43.$lCuwL37xmMB[X%X1.=2CxIO&#tN#<-2HpV-Tl1F%2@3.$p[CxL7OFnMF*q=Y5RTJDxIO&#xN#<-6HpV-Xx1F%<_3.$tthxLA6LoMJN2VZ@a*#HxIO&#&O#<-AHpV-].2F%An3.$x67#MFT$pMNsIo[D/B;IxIO&#*O#<-EHpV-a:2F%E$4.$&O[#MP;*qMRAb1^N4RMLxIO&#.O#<-OHpV-eF2F%OB4.$*h*$MTSNqMVf#J_RXjfMxIO&#2O#<-SHpV-iR2F%SN4.$.*O$MXlsqMZ4;c`V',)OxIO&#6O#<-^HpV-m_2F%^m4.$2Bt$McR#sM_XR%ba,<;RxIO&#:O#<-bHpV-qk2F%b#5.$6ZB%MgkGsMc'k=cePSSSxIO&#>O#<-fHpV-uw2F%f/5.$%0@8#';G##9a64$f-5>#Q3=&#<Ja)#.N_nLUTmcM1SUV$X7ZV$dP((&)AcY#Za$s$`OH?#5u6s$ao7T%oMWPA4o6s$,ASL2EY,##Wx6=7?k5R0D=_+*,LD[,Ahfi'Cq*t$24vr-d(4I)RJ))3)VFb3at'#(*afF4Plm,*[*'u$npZ8/'UiiLXMU[-i5m92E]p(.#4wofwqE=.1>Eg2kO'3.Q,d]ug-BgL'MgY,I$V^#w1d]u:gwQ/qDDg2(F/x-]2T,3]i%@'H:KFM]pY4Ml=FlAM#Z4MsrY<-?a/m%-+L(ajKRuuHaCG)s*FV?boa%OB#U>#)72,>/8LJ3<u(Z#.d,##(W,##g+<=(+M(v#cA<T%:4%<$`]S2'fFSNK)SUV$EO$dDN_.w#CbNT%@FlN'>@ns$L]+.#3l-s$3)Rs$1T]Y#r`[O;?%8@#>na#A,[nP;$6:)?p6<i<>[Ae4URZc*sunh(R_ns$9=.@#cD[)*>itM(X1qkL79j8.mNv)4Je+D#Rmd)*sN^:/DMn;%[YWI)1uSfL$,QA#J@[s$T>%&4$tOA#w+]]40ZZ_#7S)KCY=[x6Y90u.-,0J36G2T/RR:a4FDjc)4bJDtH?0q%E=*x-,(9g2]T%H#Cw.?#gT#R&pglN'b?=X$8.Rs$HZhG)f1F2(4DNS&8_Am&^2rK(+;P>#;baT%rr)6-@OOj1U/h*%U3:K2OZ4s70'5uuj0DZuIqmh2[]UH.F0/X#wmMWuR>R-);:e8%ji3I)Ht>Z%fhJm&4fhV$Zca**[>ik'MtE9%3uq;$2x6s$F#*a*w19O;#2'4;fs###l.bo7'U)]-8lNY52c$;Hxm8gN*G(v#4bU0(2.a5/8Auu#Qn_q70XNp@a>`0(lT[0#5CnW$Mh)%&5(M?#DRIs$G/`$#XvLk'I2@8%DlL;$O[qcD4ilY#AP22'<g.-#.wED<Ur]h(WNrLFX:0?AotH1<$u@&6LGc_5@*;O1Xao],?BkDYNHnq7p#gt%Ghi?#S5``3^dp_,vi$W]g/_h$P@Y)4qnchLxgHH3wHuD#]9ki0-iR:/HJ>8.x<j?#i7m3+5_[1M.$.K)@=@8%FG+jLXWrm$<U%],8d&`($7q_sIJhZ-;5;p/*vV8&Tp>r%Pp_g(#$@pes/>u-=`nM1X60q%Z2DO'.O)e-8RW5&P^PN'&Dfh(rp^q%EO3T%Ngg>$;LnS%I-4=$CB1g(ELes$EP2mh4s&fh/S+.)SG:I$xO&P'L4Rs$uBHG*:OqX6smwM1#*LY$wNvc*_,QN'?=7W$7@Kg2VU3G5F3gQ&<%r;$;RA2'cfro&A.V;$1G###Zdj-$6x[J12?pl&aeho.?I,87qneu>tTW/Ns7s9)Lo51#n$_dM/lLZ#nP[S%f^31#ltKdM<_Ep%hUf/L4(rV$X$I0#;.Mv#gk32'74`?#N3G>#g&D;$6phV?:JY##<@n8%&P4U%wfJ2B1x$W$XUpU/(hx@#r>3M<Fg)X8bMBJ3X)+Q1$%gU/Xw;)+Hnv,*_Bk9%6uU?#^D[)*Bq@.*dZ'u$nlGs-tbdp8`9,-3oD;)30xo+MH_kD#v/+^OVUV&PuukkLZT..MFOGs/1kXN'b2vN'aP>s-C*6pM,>VlMB9/,;;d0n'>C,e)bAD4'Q-Us.=&Z6&R0q3+kk?DEe*M=M]>oO]QHT6&B9^6&j][6/N=C-2DYp0M,VY8.4IvMp7x/I$P`@3'C[lA#ru-A-#ac8.&5>##9N8&$0'Q3#Lqn%#d8YX7XAG>#VH31#,VCv#lIw6Ms%aV?)>>##fBC_&VIQ7(AsO#-&m%l'HxJc3rD1l0QY4Z,UHL,35qKB#ppvD*+3-9.sbLs-;va.3ME:nu%e$9.oDDl*Z.DZuMnnQ03GB+*Jcjb3U6H`,_Rqfu=8h$-00K@#GADk'[oFWm,_ChL[K&[u8I+0MVtru2S=D,#V9F&#X7q6;6QVC?%4m3+jw`xF(DlY#fBT6WZfCv#D;#?#/YL;$/M*N05s@-#'n&&=%V>jLG:GcMDklA#rv[W%H:Zp'a.aT/lexM1(o^+*vVLl0sl+c4N)b.3(cK+*KFn8%Cx;9/)rD/'Nm=d3U%(Ka&aKA&8<mQDsAL'7rYcb%cA>d1EFVR1$R=aXRZs%,hY1I$di<>5%$*OB`4DD56/`p.`42)5/-HC/`kcwR-a*22o>x'5=1$qrx7=,M%_Y'$4.02#P?O&#CJa)#T[9]7N%E;$Z<A8%%N:^-LAa&+d8mA4BP1v#vg@>#YH31#bUtcM2(%<$U6YY#[L;8%31R8%@&#v#IV@T.-Q:v#3Z]Y#Ks)Y/nxd<.)*hU%0-[0)UHf@#+,Bf3>?pv-tW?T-4lm*2<h>V/GO=j1pC,c4lH.lL$GUv-fV&J3RRs20xiWI)RtC.3^[ZL,=mqp%jO''+sl,xkg$^)=WYks6bLsP<XC=T/kKSj(8QDhL/P.U/+._0<P@L'7mm_+=9u=#,5BZ3'g)w.2^[.[#+4m7&sT,-)jxbV-8E.`>Y.)W-F#*15Q8pw9@DPr76l9^>?VsN'eA8$$PMY?,r4?##tR0^#XIVS%:mPj#NA%%#KLvU7;/,##TE31#GLqJ#6ul##LXnw#(kZ0)jghc)F#../a9uD#v<J3kwqi?#lf/+*B1-u6:$UfL0j*mf#5,jL@Nx(<EL)h`QHT6&3N'/)c3/[#GJVX-Gfsn*AB<jLg`Dj$ndo]&-=l>%@;/0qV$x8%P4T&#^D0,.1NDZ:2iuM;a94?#U1FcM5i-s$[@vr$^W31#dbK)N3Gc>#W)coLS_d>#7WuY#3;>I<0&s0(FJ#a5/`N9/mn4j1#iR>-qoZi$)/BgLD/lw&)oe6/Suf'+$BY4MXTt1'v@xL(vG#W-G]<r)EgS,Nb#Us.<r/M(R_:I-'#XM(dL0M(;Gm$')9-W(bG3M(Q&)t-OCeIMd`JFM#asU-_e%T%I3/t#4g1$#ATbW$-rrB#Yb@W$@p*P(Qd,]#r-2Zuh;B+*PUm(%-'A5%^*1Se@lY##b8J$$h185#R^fW71pv<()Z41#]L')N,>cY#-an`$(>cY#4HcY#CBU@.Jmp;.^VS#,bP=?IQ+Vv-9O1x5dL0+*u?lD#H,Bf3xhdY#@tV)+Z.4Dt,l0^#ZxR7OO*)iLA5W/:8j?T.c[P+#:?4I#0k^[#15<5ALINp%ESE9%1/C@#jT0[[tkj]7%&;9.kOSU).1X/1C[[<$Q4RP&JBpQ&.L7h%kuC?#Jil?#P692'UK3*E2+RS%S'[)Ea0fw#bl<e)Aka5&F2YV$0mqV?/c1Z#4^hV$0[j.;5A:e?*M]f?c-g2'4Z4a-O]8N>anaT%kmNg%G7t]7jApJ=g7.n(<^$8@YtLtBO+t#A$La.=pUY;9XLdL<?<qZ7_Vp+4?-`O1.,VM:n4)d*WPQ:.T+^F*U*PT%YFn8%[YWI)(cK+*NP,G4DcGg)38(s-vTZd3stC.3_[`V$Z,u8.FAf_4kl_p.eA2T/AG@['p&A+4Z*@[5=bbV-8Ces$OWPN'U99q%Hb39%6H+b+KO2mL#`BN(UI%W$R<kT%2]lYuaf1F*i%+M(+]B+*DLRs$U%-88L#br7it-/*c'nU$J<^m&5oLv#B'TQ&&84i(VZcj'hxE.)Z-'q%gb-9.ESG>#C1=B'')aO'-k:x$Ow3t$q/MZA[E(4)/#H&#.jd(#V+^*#j5bZ#)AY>#q[Ej0<lj]7.a,##jF8:)^Ym29aI??#H$FT%OlG?#<Fn8%gdpR&O-Gj'iXfNK=kn@#J$PJ(atY3'Q2;o&G.@W$Gc=.#Ehxi'C[Ck'1T]Y#IO&f+=BUS<dbwS%Fr,`-VS[8=-g6W8k+Qc4hG1Z-7hChLCh]s7<s@q96BZW8guYc4])Sp0Ev]+4+]Nt._c?w-B7-g)B_dc*U'CT&nBPZ.eq;?#9MH=-_Z+r.cT/i)*<<?%N)jbr@^`4'pGCm/Tk3t$deM'6A@;X-8l<=(,x.@->3$B*xq=B'')N4'Oh%<-hk+U%kg[4Kfs###'&>uufoPj#@Oc##vJ6(#LMCF;0?VC?X'F?#T.FcM*S:v#LrY?#BXEp%[6[0#<CRW$FZ:Z#^`DMK6clY#<4I8%Z8w8%_23p%19;,#?.5NB8L3p%7s.[[*uaB-en'_->U3%:Y=pA#e-34X?:6Z?i0%H3hx1?#n(b.3Op322d,G^,(5fL(dSDs%KA>##>kf2'&(/T.m77<.0ENb$9+J/;?0@m0E3:U)>5Rv$WHIf3meiX-e;^'/j<RF4PDRv$F$]c;m]sFr,Lt1'Ul@T%;Sj50BW?]4CR>q&V:G/&X$jZuZU=]#-l5c*$n=]#Zqq;.<8Kw273^v-Q)Z]ueOn0`L^8E+ZRmm&*t:+rxI+M(KK2iLW?W)+TrIfL+UgfL6Kpl&f0el/0IOiKN%kD3Q,>>#V%$v#.V1v#LdC;$NB/#G9n6_#;+(,D7x6W$^/coL_H8W$9#Is$)P>V7.jqw-1i8gL'iM;$sK#t2DSr]7P5#b+td(80,vYb+b(860H%'t%p(rB#h'Gj'&%1x5_a5V/7MrB#L(vW-]c%@'@Wc8/rY5lLsVYA#h5?Z$OM-UT]xX42p%D^#.Xe],q&^8%:?'9%[NoS%o_pP87o(?#d8.<$9X*9%vGpS%W;gv#$M<T%VL;W$qDW&+Z7U_(pedp.r;'5SSQPN'MOP3'#HTs$?mu8.jVjAF>ZS=%HLGs6&ite)@RP#%&>uu#.<>rBgm/%#`I5+#(+g(#>nEs-NG,:;9Q;hD'/###/T=;$9M9'%f<oT%At.##J;Aq9k?e(+LKCG)Ek[s$F2M)3SP,G4w4NT/hQAg:LJm0)L*'u$*W8f3[`JD*AVs+Mi*sc;r=W;7U(R]-M62L5'fEN0Jv^ZAYoYc4Nc4]NjDSt@'o5C+_S:i:J+gl'64e8%WUEp%=S(Z#xFXe)a2`g(EK(0(@a+++B0Fu-GPf.6+jF^4-LU#,rD24'Gbv(+qwgj(4*kU.bn&Q&Pb&6&YG.h(xK<U.vDQ7&qYMO'AJPYub&Z(+xZ]%#)Wv5/%&>uu*EG'$HKb&#1ElX7_MG>#(;Q]#U>-C#xBRG;$,>>#s$%,;SUK%6:=gq/c,<a*r&0<7,I_Y,lGZ]4Zu:T.hWTM'iGj6.iU4GM.c@C#p2.l'fGtj1l&B8%*c7C#uE0H4c^/jM'E0$-Ep6,&>*7Z,%V_8.2*fTAjE@6'mOf5'lhj2:D)mU(kx32(A0:DNJrC#?c&_F.XS-gNw5UB#^(T3gmU(w,'A#)++n<^,pV:>$c33Z#xn^f)#I_/)UeQYu[+gNgwuT,3-H]F.M;GdN=Gh-1=i`=ce[^(sc[&8@OxZ5/KVCv#skErL%:R>#B8^Y#Wx#v#,^_V?*GY>#4E(v#'V>V7D$i>$rX4Z-]YpG.NlBW&Ld*i2DkQg)rJ:l0lEUhL8-uD#W/DD37ZRD*O@i?#[)+;/Y>%&4PDRv$,O%],GHuD#lCS_#GMrB#&VsAFZY(?#o3d^Xl&,]#7jhu.;'WR'$cq8.?<]2P<r>(+]fq(,_>qQ24UC7&g/i80iCLc=m<<u-AS5v&Iu<&'nO/T&:ee^5PSE[.(pH%-Xuvl96%Z(+mjv:0G-:6&[6/n2INde+(*B9.xXXgLk?$##,*.p7XR<33^nr?#9G@A4S-Tv-@4[s$1rSfLSb6lL_+9f3bR(f)ORIw#KkRP/l1f]4h$o&6l>,]#H5d^Xkvx[#<=pd)_*J[@m,PW&_?&[#j-C?5b/###%ol`EoaZY,.Anx4Rr9VQBtuY#v3@G;_F/T%)i$##/G>##Z1vr$LHA#G0`l>#L=1/#TB*1#(5>##B7Q_%2%.W$]qi*%b]/mA1x$W$Y,c,4_^`#$10mpMQis.L8Kb#5P2ek0jgt#7@R570Gp8J3a&eu%,wZ0)/&Ui)<Dsu5@9uD#Ao6x,XAic)Whi?#cI=j18aSX-5$+7%#cA)=?i4R*WekD#0k*N9G^nA,0qkLs^X@92[JCC,]C((,`q^u(`ksx-`)0I$q[`c;LDMW+jO/GVmbANil?V)+g>)B#Irmh2sD3'.-Q/v/C:JQ,h1Xf2r$m>,[Xx*+J-MUTqV9>GCLds.MZ)M(6MC51H[Y40uh*x-'(<.3u04,%W>uu#2:H;#gj9'#@F,e)F$AnLH@9m*WgZ)*9PsD#I.*T.@=@8%BPPd$%V>c4d&SF4JfpY,cNof1&]8)*B3wH*d;=(5Qx9O;$6OI)<qJ79kgm:Sw7No&jof],lm_G?>jKe$MQ`#5jYZK3@)+.)?<)4;%):J3:s1l0ViNu-CvSG1*TI=1IuS&#_e%T%L2Lf#Cg[%#P]Qu$-rrB#O4n8%YS6C#&_<c4,Xp:/lw'024ktD#JY(S(JIM?uw5s8&:,<-)t8k;$;mF+`:C0B'e^A@#H+'Z-fQ@l%;5oTe_ADs%_p#j';E60)oI1_%G)###$fPDEReju>5n+;?RCY7:C7[8%bQ0u.Kr-s$%B4?#(aUm8ZBG>#`mJI$/iUv#Yl./LX=FGM6=Rs$5p98%E%6$&7@[s$'McG#9@.E??WpN<^?rO1FVNs%.9VG#J-[)*x)Qv$OZFZ-N2h*%ulxu,TT4a<+52H*f'7x,7dU;7v6a8.s<RF4ldtG*:cl8.=K?C#c+*Z6t-9$p/#,G4RTEj1dU4GMqu_#$hLfT%90BF(`;NE*TN<w,a?jZ#rDY9%V,OI)B`r2'kXaP&*p@5'J^vR&,M<b3Us&T&$T1w-OpAGNXgXu-/[iA5fG#W-xpnX:JNhX:C?2_AQCZ8&Q02jG+(-*NFF9-5%/5##N4K6$QXv;#dpB'#n4%8/(;P>#i31V%4s^Y#VK31#k3)a.$e4x#*qZ0)#L(E#V)ZA#a3FA#MCr?#&Y@C#W`Iu.Ll_v#cJ?C#t28L,&pjt6S9;G*a_b2(86@Y6Hpu30^bD]6%imW$tR3e2J@bg(;^c^ZoB<203j0BFT*s@&/R1I9^DS@'^jvpJYU-B+47=b)</=x%KhDN98Lws$YX^`Nbx&%#58E)#gK)N(XBt(3vOZL-9#[A1-Jns.`b7s$Y_T_4]X8/.iqhl82PE2cr:8C#ZUdP/0d%H):>SC4P,?o%3%w8%<44d]wNe29`qbp.?vQ)*8$,&:b/hq%oU_R'(6a+$L4eP&Fmo7Bsane-Ft*4%d7NJmr=PB+@l(Zu.70-)Q`lR(AoLK*jA)]$;,x%+-J2?#r0@G;v@g;-o['s.Z0,',ClgWhS1[s$Rn.W-CXZ?gHe75/)5Jo:iFH=72LD=-^6bR/:@Blo2Otn0ML77'aR.rmu+(d4#?hN(&DtiM-[i(a)6_dir.626G>Mt$.;:;&0U1I9]>8%']gdTJ0os40T.%9%=JPW/K67U7oov<(=I]<UB>Xf)DgnC+jCZq7;Zxjkk1Im/+DS5#M.HU7/+_w%xTd`4qPCl0sSH.*c9OA#a^A.*G*TM'ZM.)*Ipuan9Or/WTfcn%<H@A4K5TF4<xP7$@Ivi9fYxfhGU*p%/b(Z#-$RH)H>i/(L%OH)r_8a#73$,&kuFgh<ouY#/jET%[M_p%SaB:%ix&U%e/FX$V.2W$cCuJ(d.<N'o/2H)HR39%ta)Z$g]8'4khc+#+deZ798G>#6VVM'3J7/(NpvX/RJUa<g*sM<LRXs6@bwS%ufQS)>_e<$cEI0#ZmcN'S%Gj'dvxYGC*Y/(VToYG0=jl&K$edDO@rv#?*lJ(BS4.#G[<X$^`?C@X3]pA44%[#FGZr'Qn]DZiq=X$m9*&CJm$hcLpA$Cha:k'Qfb.]De7iL@uY)Qk?mJ(og$61tECb-u;B(BqZc/(_v_V$bm%2du@q0#_,i1;6E^c$%WUdH;MvLFktg$AhF_4;gqdL<;5Vk)'AUN2[AtW@T*H,*'LU.2sf6<.i^LG)rY@)*oAic)J[g,27TID*67[x6XN(023>%&4JjZg1ewbF3c$s8.9i^F*`[#,M5?xf&qbTV6:.OF3=DF9/0dfF4KjE.3=xfU%N6>T%F[*t$Ij:O'I:@s$T#2k';FVw,61.<$I:[s$a='j(V65N'lG63'4f7u.K<?d3+rQu#TW92'o^$ij7F,2(=Xk5&XZbt$Bnap%Ghs5&jxwU%ar)9%>e&6&4oUv#7uqV$_JnH)O;3**G7%<$1%R8%@:nS%Y/Qn&D=7W$D0gm&Alu+H(RM?$vZhhLs:9O&>]BJ)em,3'C0gQ&j5Y=$*Yf2`o(oI,)pU`3Z>9G;-YHpBBUWT%K0TQ&h`WP&H$'q%[T,##+>,##A&g>#0ScY#4g1Z#<I[S%Jb?dD2l:v#9,qo%9j.-#,qND<vL-##>NZW8duPc42wmd3s(iv-;:$G*h2m3'@1r;$^('#,f3of$?i:8.vu/+*3qOA#5HSF4D;^V0cV8f3QTX:.sXbj$i+Fp@r*dG*xBA<-Sv1*3pEY,37m5c*6QPG2jdq`-STa/Mfewp2/j[@+Zbl'+?K,n&>`MNT3B'N(8K0+%0=k(3UjOu-9+5o-K/2^#U*KK1tu+7K:%Z(+p17q%9/Mn3HA.GV&h$.MJ0VEN`4$##5[Ph%;^<NjEgH+#%$<Y$Q)EV&4.RS%]vmo%][ro%Sa]#G4DP>#4](?#H^Lv#`Cvr$1u$s$?p]Y#-Kuu>*P1v#2HuY#&M>V7k>Fs%49R]-&WnN5YQKd+;#d>-BD'K<l/su]fYS+48^PH;Ml]G30HPp.ZVd8/cw#buIShv-[5MG)Z,q8/wc``3vq7^PYP>[PSIbT)`fnP'VUMZuj?YDNu@fH)H1kH)QL?GadR1&lDS5)OiDXl],Wes.hVVO'8?^;-I:+;.-cfZP`g$^PLqsBML@iT.o<TO'E2F7/Rm%%#n_cM99LBZ-D@EfUD$dH2qkj]7_A,##`A((&+M(v#NXug$i7[8%J:1/#2r?s$IR;@&/VlY#`qi*%aJNPA.fCZ#Vp+K3lse;%NC@i2S)2v-k$8@#?xZw-iGu#-roQ?AI-nm8x7lA#FJ#d$MG;j0r+Bf3Z2Cv-1]WF30<i-2_slYu#J,n&W<8a%WQ^m&.Ooj2r3&K'7Yu.:DE.vRu.TV-v_g/35]U;$d7Q>#uH,+#W7FcM.fU;$fY'</UvB^#(3;,#18NPA(AcY#%ZNF3iUIs$Uc`h1J#ID*-i487djHv?YqS,34[4;pu-g&$c4r?#]SrD+@'pi'5qcKLm*Pb*X*,f(:k;d*T7f5')]O>'iFJp&[`>w#QL=_*/5]1(SbpF*%Cxl&TEs&F-Tps-k(?tLc&NY7J]Me.2lC?#qe;..X+ofLMx-tLKdD;$P>u<1<F]<USEuu>(>P>#0<cY#.QQx1BIff1EUpr6&#[]4IV:NCk`#w-5R*v#?fCeNnMrs-#E<3:j-nX-iC=U&#1U]udkvL-dkZm%Xnm##Nke%#s,_'#ADW)#f[P+#r^51#_LtcM:>G##97<p%_D39%bWKSKE7es$K0#3'n(92'Ta1k'0$+I)L^>n&0wRfL:>),#<1LcD@Us5&9O*9%L=ji'RxwW?O))O'LU:k'j[f6:/AIW.7/JO;UL?h<2$hv7cIRx6U;kI3)i/q/pkx21LBJA,'i5C+xCFI)ej9u$(aMG)sfA7.MIUDNdno[>-?pY(iSTF.9^=aNlC3Y.j'879QJG8.hqrq8[8^K2#gQL2w4A_ufwR:.xcHL2<RlA##vwq.t_jBuR9Bb.)x_kLKd>1187LN.Pl503Pn`*.l0]Y-lK.L,BvIL2L/D9.7+(3.%21K2@s:79^Iq`=q6Pp8?LZ+D=oK[').)vH+cF&#lAxV6<RHDEv[VP&l#Yc2A%e>#&;cY#;lTb$,V:v#Zqi*%?YxA4=M,##jlWE*Q_%<$9O<5&q>(l0Mk?m8^3>d3Q6RAOcu8](i<J[#hN,W-rM1`&6%aW>DNcof@+f20%)###>S&)NT@]wKW2Tm(2:tJ1)5G>#.Kte)Y>sA+5l13VA,lvM]quw.9qV)+#b*5F]gT[/+g#&#*Q?(#*?Mi#QUD207dL>$tF@qL#t)5('5>##i#)v#fxZ[';FIs$fFJ/L9RI@#Fhoi'PADZ#=7%W$K=bT%=hsp%<R[<$H%32'65.w>2d19._ZAA,D&b;63-R-37q_k1o(NP0eIaT/Vvb>-0I2%,47?c*LMml&k;YveFAI&4NIHg)-)wNDsfXID'o]G3_B`+3))1@-8EgY,teNX.2*gV.sia,@6#^DtR$5?KWLOJ%)c9dO.9M($f-5>#h2h'#=&GP(0/,##q^%##Wa/.$*Gc>#_aC;$YQ31#_LXcM4..W$3j98%9p.-#.waD<Aj].*t%]L(%pql0&@Gm'Tu/+*Q,RJ(X>lD4pBb=AS:FPAJiAq'8(Sv$eT0^#q.Jp&QjNu-_vSu-_'3t-Lw-o[BVr)+6`id(@xCT.(Rc+rUa%jLP=njuwV.:.9s0qUKtP]uRqP<-KO^;-Ddh=3:Aq(a]/su,=onx4IhYR0Z1ffLN]Wb$H+RTTcENv#am_V$_T31#`O'dMDNXrHE@<K),Udd3Pna0)lsOA#=;-x6qa_iB'a;w$'F;8.[=@8%GDg;-inS.BwCX0l'&+e3oa?/(undC50dsg('F9vHNbmT:v#lK1&#;`j*9j>PUdK:%d^.l'[B%l'Ft3]#v[_+4OcB?5k7R>#+ikQ1*[KJ14GBgLIf/l'u0iL&)]Q&k]ZW**a&k?3aOnRnlZMfhLGsx+uwTY,D]aG<,$9a#Ur^Y#CD;q/DX8s$H>@A4Z2Cv-h@^Y,EHuD#ToS(QNXFb3;0l]#T_(f)s@O.)L@[s$ax;9//1se$nfbI#ueeRn%qrYP)V4W6a)I['1t6/&F5DZ>x?X(EEZEP](Ci/:3mPG>6RPn0P^Fu%B,8gqb?4g1dk13'r>vx4CR<5&3?wEM1LKh$TLcj%6i]G3j'uoC;i0lDR&ix$%=E`jY8),);lL@IDPUv-ik.s$'&JD*j/9Q'xJMb=6O1E4qd8x,W$8f$TjM+*mxG=79[x_#w?%]#P:(i<;+BmGvLuV-O^WP(@wh,)K1.W$AXq)*/27I2K$x5)LfBJ)TOI>Q8m#E=N'::%E?lh1c>.H)PW`%%MeV$#$uTB#6)L(aQ]Tuu&(^B,)&?>#VH31#eLGo$O<ZtLoOjM4TD%?$>oDt.0Xu;.LLTfLZ(:A7BcMD3&ur?#_2qB#X@[s$?Dsu5oP#]#v+3m/=%m033cnQ0[[sk:B>R?$s3Md*__.@#ljPJ(3T'V.,O221:Wnd3Al;r/&HlB,EKS5'>#?C&K.]W]9tFonsVkx$9XP>#dG[]4CDXI)B4r?#2Wgf168aF='#Z,*?0aRU0@F`#eIml0Pn%H3GG+lL8EuB,N+Q`-Va`0>i:D?W,(]j%wCT@OEj3<%dV8f3MV&E#;V=^#N?1[K<JjD#v.<9/VYA>,?7v>#w4&Q-+_1d-r5/<&v=OA+[H>R&U2=jLQ97###2u:$?[L7#O9F&#r[/(#U1OcM*8YY#q?[QL#jZ3'Qr8f)(FDw,=?_20q>(l0@9uD#L#Fw]v?Vs-_Q3L#O30Q/qwkj1=2sFr^#0<6)x__.e*,j'EYXS7kQSw#5(@gD'W'L3i#123d3G)3R0u9/`#uq.3O?K)$rFN1VxIfLc,FAFJ1W9V*sp%#48E)#tBV,#;qT9('2>>#tD(v#b[Z?#+S1v#^Mh?'5=*p%S_HG$-Sl>#0YuY#LGwo%>>@W?1&Wm/N[rW'?7R8%(5=l;s`rB#mp-P;lOuV9p1H,4>HI51+5nW.1G4i(_IFR-k6_k.&on8%*jb,10&f)*9>%&4-A7<.^r-W-?FvQs]ov[-]<@qrkX2.N6<3-*7MYS.d>Wa4aRjf1?1[s$Gn[@#9Cw@-=?X2M<h(o_`qu@5mC',3g/nD*qs2d*,Yaf2uc'%6w-o-+eGA#,<w$9*eJJ#,i7A,a<w'>$FWjR8)sIh(hK7rQ'Pr;$)bn=-F-:Y$<B=D<`a0_6Em0I$4su$0`I7X-JbF]-ss*X*C4GR0j*&;8n;C?-=bZ,*^>&s6,xmr[:[VD+n5MG)Aa9;.DHfA,lBJ@#<w[x,lBi(E'F_s-h5k9#?@%%#<:ZU7qu@1(NnNT%t0g*#U/$W(mD1l0&[&r8B)VT/i*&s$xHqhL<V)<%)u[s$&%I)(`5Kq'd%jBQ>LKrH5n[0:F5r,`(uJh(j_-D(ds7Q0ox,A^K,p9&.Li6(FHcJ($*WA+7gZ,2Bnh7#CR@%#Tuin&`N0)3ah/Q/[HuD#kjHD*=0CT.:q'E#S3AM)r5uq.Q?sk']9<L#_:k:Ho]68)^0Ox#>P@4'VV.J2ro<Y5B/Giuh93a*sCD[G(pnh%IAP##QFg6$PGZ;#UQk&#4dZ(#fFmU79r5,4-V<9/mqBdMu+o.MK%NO'PjpG*?EB@3c'85/W%^F*p&PA#=@[s$S[#,M=rY<-mAEU-3A[.%v[2Q/*n*b$BU8^OuTn`*]Hb#$2/?<.uKPK+eSi0$1V]p&dnRZ7I,P$6('^n/-jbZ6U''^TP8YkKX$8w#V1(,DDcRjrr_ZJ*-$fH*d'YrdKJq[u;mxL(QJ<s%sgA]#1]gd*Z2NA+4C#i(#s/a>^w_+*9q(i2YVK&'SK0m&3M<X(,RL5U<71l'o(KHW2GQA6*:DP*%dG&#,^Q(#U4#F#[G[>'ZbVC?[3e1<(bHS'JTlN'PP&Q&J+u.#M^PJ(K0[-D2>G##N*9m&Mij9%MIM8(BnR@#Gh*9%Y-3**IR7s$Ut-dDuSi#>R[aJ2%h3#?:P#<%%qkjb;&qA?A](T&>gsH/UBu>73(sNCUCa;7.TK*H+qAZ7`Yg+4403e3ZvjHGQ_CT*#S@.D:euS/vx:e$XG[]4)vsI3Z6J.D*=uAu'h1F*i%4i(mxf&4%3-J*4CIX-2s3e)X8VO'cwqY6^.tkD<kh@OR;%],r_DA&b%bJ2(aDS&$dHr%/V;d+8:/?7t5RG=K4-AFG8LiTWDToRLCeiPoun[-Gq;AF?dLv#.7O;$9t:d##L[G;apUf:1A&c<<>W'#Y=FcM1x-s$TcHg:rF&A$G+u.#-PC;$/a_;$0NA>#>R/f+RtKZ1_cg-Q$2s]7^P:rU(@ukFpOoa5*Dn@-vPCl0n4Rv$5r@0sAv*P(mNv)4dF269e2YD4E6E,MDttD#inL+*pl&f):^+>%OKOA#Pa&],[M.)*[hi?#GkRP//=6jBLL:a4g7+gLxxGA#CdfI*OP,G4klnU/*C&s$/0ihLVY^Y,SW2x5Ljv3+0@%lLvi6<.uaDE4HL7lL^[-lLt]9B%lX9+*?(KL(NYuYuDpmh2^pn6.:UR1&<ET9%N-0Q&MTPj'c7'+*PC7W$B<5n&H@.<$0`hV$<3lJ(m$V<-j;D4'2Csl&^puN'-p_L14JkI)v%e$$Kb3T%T6n0#(=':%CIKd);r1v#MqU,D5uq;$2AP>#r-Lk+vuRfLp8pw#4dU;?*>P>#2JY>#b>c'&>hOD#e<k(3#p/C.T>)B#BwlYuAHWE*NIIW$8oUv#1.,H3,Pol'IUIs$/`U;$q_;R',)%M1gNA[#A?u/(3tS,2QeiZ#Vc&b*nK%a+=U[G;qx#I6dPc>#=E_G)rL*D#CL.s$ei.h(3iUv#8_.u-W.x+Mr-Nv#n=ig$Ae8Q&-ST_#8Oa5&Fuhv#][^quO(jfODwosR1=sl&cq-5/RDl%=gZvD>2(@8%]T(v#(D(v#T1vr$1rqr$_CVS%,OWJ1SHcY#7+*p%_Vjp%IMd--O?M,#1>s1Be-$I3vs.##v7Qc4/4#R0PHJA,r]r0(/Ek;-$Bl-(Xi$VU46n]OWXMaO)UI5/DMn;%.5ZX$)$[)*Oov[-wHuD#Kf@C#>))8I77C+*T>:I$4X8F%K?7.MCcZiTB93=(e(uh,OUM+=w<^D=3)Wk'vMtD+kgN#-x=JS@R1.Q/fQWu-@.jV$.b8<-#,1w%NuiC&1unC&lE*j/xI0+*qB[j<aVQW.NGte)oqw8/q2lXAqx8;-%S>s-S4@K<RM?$$&/>>#V0,##wDBo%JE,%7R$^:/t`<.)0lkA#l*Fr$up4+%sXl'+q;(8Iv@xL(@c2`&F,>>#:%h$$gG[8#rv4X7P>uu#kACH%.>OcM+MlY#/T=;$P,]&%A_YR0YWAa+W/<a*B?pv-:.i?#[a<c4MfB.*<oP<-VoP<-t*OR/7u$s$4`Z=7GpFm'FX[?TjfUp7=*ur+?30i^GlS_4'W6A#)<rk'vX+0/MN6I+X6af:^QAe4dNo[uxv$.4M<Qd)9]Z0'l3W?#WshoIe50i^*/p--@0GG2&n$.M^n)D+bBC6MXZR:0+*m(40sCn%UbFk4Xj@.MJEp3M8W)2/SR_l]%_A-mx]Mp9+`qr$V(J/L^L4gL7JtRK0i1?#)AG##>Nc##5(@W$;E(v#+?M,#4P82B*M(v#Q7Xc2#G<t.CI-,*^B'U%br)D#1r6,vwfPA#uo%&4&va.3Ltm68,e$@'dS))3[TA5<C3fu-$C7lL?PDB#i5p:/pD3</4;3b3qG$j31E(<-@,To',nNu-1x2G`W3g+2-%49/;qVrZUZg6&VtY@?R8gV-<)wq)YG@:/b`DB#Kq(O'>j[](h3/@#P3f(#AoP?pa9]VH2]tu,'WYc2K0DP8;5e7e+sDb<^Z.+#)>>##F^Lv#/]1Z#WaCZ#4x$<$`sC;$94wS%dG[S%9:es$a2%s$A[/Q&W/<5&X($v#6rH8%=S=.#M6TQ&=u]Q&CM65&Ot8f+*.f6<:<$LcRevZ?Vl6&61+T60F)sT9wN^V8fx,G4Riu_5._$h2wO<9/A7U+*sDwD*67'P:.0)H*uRF,M)-&],:@i?#].Is-P)S(>D*$Z$tD#<-/c,<-6sZ$>Ijp58'bP-=N'qZ7$38P'?4X4'9wW)<8*6f?&o>?8`sq-2jx`/2b+nw-hMUP0/=K60M(f],6El]#/Xr%,xrq.;TtrkLZP6_#c/5>-^h:D+U.B:/xv1K()0Rv?3ghY$<4bf2-?8qTH)q;.ld2pJ9x(kLr7&*-HNOh#ZSmo/xUiS%?r$*4d%U+4$,>>#1QoI_Y,'Z#Hbrr$BtP>#a,``3h*TM'_(4I)(i<<%SEk]#&,]]43@n=7Co%&41pI/)Teeh(@MZ8/f`j'4V8hw6XB`KCrD/Jhwe:s-KhVZu^X7[#oG?E3:3an'RW?90^3$F*UJw`*I+Gc-.d=kFf[;kF5rFGM:W7C#3IE2G/1.V'g(D=1$IW7/g;V1+-%%t-j0rH-vpJ$0+C@G;Z#HR&8,X;Mw_Mc`nd4X$0++b+xnuHQ;TZa3aUVkLS3=q0+?GQ&5SD2'4xMl&12(U&g@UN2<b`N9&4n0#^,###Uq>#,+]$s$K>W]+[mYv.,/5##bmeh%(jB>#[mJI$,S1v#WBlY#owuN'-:M`+UUIs$(jic)g@S_#ckY)4wxOJCJ^c-3SP,G4_.*p%42jaGNRC&4ngQ5/x`ggWN+49/6YPuu%H?dFK'^e$'V9utv>js/aLf884=:+M-ms73Q285#b>$(#M&0w%(;YY#iZ&2B^_rQNXY(v#a/,+%2%.W$3//T%Sp.-#+naD<F`5##ioQW.@Rd(+;p_-2t)>9%C9#j'<E=1:/*2e3AARv$t@0+*xl<=?sHPd3U5%&4+eC]$#2`#$DofY(i<J[#+m5c*I1Fg2^2q#*M6tT%?K,n&67KN.SDD^#9GLdkDYd40T_h@O,uhu&pjNh#F',x-Df*K2GGX?$6)L(a@%QuuooRC,+p:D32O(<&Xih;$9JuY#L>O'%*A$##F$axF*S:v#HV,?#3i_V$Cb?)E>U&=-iskZ-R&B_/fb*@Thcr]73MEF3K5T+4,p4Z,`XIFmm3lX?BxGK)]AqB#aW.L,`J))3<cJ^$m.[#[O50?3_Mq4&^a5q%cWR<$g,Ke$sQ0q%f1CHMHtW#NF2euYwqE=.1AW,3?QhU%Q$x<$^<UoeRP1N(sh=gLs`Zn&]3n0#uQj-$=,'p7d*ol&;VPj)1h*R/'3A>#.a.-#&K8H<;R/s$wTBhX9/j>2;h#M(X<Qb*AC2/:Vo*5AG*9<-0iEf%VCV%#G1g*#]KOd7)9w]#+qd8'3]cY#,JwW$f7ZV$eT31#p*_dM9Re<$hYEt$ciB>#A.;?#e_RP&=F.w#Y;N5&c18NK8I*p%XwH0#VE*1#?*Pj'BPx-#CY,##LIl+DFRap%d5coLdvbp%>MNT%4Pxh21fET..-gf=Q,3=8i.mc4Z4d03BrAq/SNJ&,kp5R&7MG##fS3i(o#G,%3qA8%Rk^>>(#iE45mi,)+gB.*P`>lLo7sk'ove5L0I9]$EPMH*vbLs-@=_hL^POZ6qI,G4AP@`Z*VCNC#(e8^QOXL`$SFi(;8H'+*L/:+n?92'*J.qLq*?F')fRd`rIOV.AQx@#`gOZ-Cl+(/Rs+c.=d0[Mp39e(cZ#EP-.'e(AYG>#aYwx-@_ldP4p24'Hb4Ma@wWula73/(Tp<J:D>-b+0`(?#2^)h$MNlu>`1/=%[I;8%c2ge$/i_;$[qi*%Y$W;$5WCv##q.##QsE.3dGCZ-/G4.)Dw+/(Ckns$24vr-P3FA#v^W@&Wd6l1.YMu$C>dG*Y*/W-<S/9C<$:a#hlwU/IF,gL9_j?#T>%&4m@xc3)A?x6Md5wdH.BC4;TZY'Zhi?#Wn8g1dE:K4iC9J)KZ&N<Vr2'Mw^-8-s_gc3BYPs-`gCEM?C*'6>*BdDdHPh#[D9Q8mDcT'Y2VO'h%$o1s@F&#tUB#$TiXJE4Dml&bhho.0T1[[lkj]7R`C;$2iU;$Jp-W$qk0W.'2>>#ju7c(kiGC/f[*wTicr]73<=Y-FESa+7pjI3bKmJtWrgc$[;0dM4E=u-gc1<-k]b,)iwEU((@l9@pj0^#W+D9.5hKFaWG$Q/crV)+wpS%#@SRT%Zhx+2uT>PA<`EvRQ4J8%oQ<Z#&LIG;E=R<$m*42'Aw]2']:;8%M9Pj'b%Gj'TH,N'Xd:?#-]u##VTl##/fLZ#Z5E5&Vk<RK44.w#j)D;$9O[<$H.NM'gV:T7FJ4.#:lQS%FG4.#M6B6&9f86&CPQP&&a`R:K%uX?p$[1<a$IT:Hh0?7ZD9J3uxH<.BUZc*xQ2I3+s[h(->7.%P4LP83eV#n+<4W']kF%$(oV=-;JLW$TEtT.N/`#$6qC2'eJx'+eG;</)EBU+6]b.)$*>Z-/%km:hZA@#bCRx-3ieRP)1^E)rF4d.JG:;$7v2;6@4bfL<$,/(ekLS.b;Vs/](Q>#Zs4]#u6IG;`cn#%e0R>#WBlY#b$sx+EJG##9%.<$lrqB#tO%s$N2@A4O9o.*edB:%_@i?#+LA8%kHL,33@>V/smbU%iW]m(X+q?)w8,f_C#4`stLPYu/g[:7BU<gr;2?MT8$deqd.:Z#oZ?%b3MOS7IKOhoHYa1B$#NI/r.'F*L4A6&+Z%u(PxAh1t]Q(#gM0[#GP4v,5A3p@Qu>E5>N;;&'5>##kZalA-6P#%Dut.#91Is$H#eS%[:ZV$31@W$OL3q%<[ET%d08F%lo/QA:X<T%4s.[[7lj]7K(F^-;4vI7Oce=R`_(dMwL*]?Rj#B,f$8@#<fhC,/r/U/QE/a+g+D='m1FmDFWF:.Jva.3MlPLMjAGA#JJ9n$C4vr-gc``3a[)Q(Y50ZF'_trR-.Q03g_l$,Wk$%,nkr#*v6E]3R'f],D.P/2cTnO(_/8C+_.6v&4####%&>uu'tSa#,]u##XEAW7KJl>#YiB>#-?v9M@&LI$b?/f$4TvS)cT7K)[VS#,PxF)4?m(Q//?Tv-[5MG)Q.ns-Rq1DN(4CMB^.QT81$ea=X:*x-v7/GV^PGh2W<>/EH3nD#S'UT8GJG8.ZbKDtA7Oh#CPJg2F5#(7s@F&#rCbA#JGxrR=jj60lx3Q1*S1Z#U`%/Ln2+]$Q$I0#XH*1#/Yl>#)3G>#b5MfLxeG4Mxu54Kem5K)4(7]662Qs-KuD;RXX.^$XAq,+[E,jDG*[`u-RhkLm>JcV@C@5KYJ]T/T$Qb*;.XnMv(NuMX6$##r$a..R`l)Ma4g%#Tw`V7g:,=6V9P>#Y%_>#c@O/,GE/a+P<jd*ZpZ)*7PKF*7J>8.Z^<c4qXr22f<1u?D0YEtTis**'s][%XT+H;+:iWhX&j&H^?rGt)tPT%30Ha3MHco9a=f#'fxmpI[*gE5DorU87,5EG;Ws$@lk'L;Mrj'#&Kr64,X-g#>qA*#PoCw6xnCJ:(,,##>b@t_cBM,#3As1B*8YY#vs.##3/Vv-*`#29FT$gLp)vr-@=@8%wC4hYQU=7Medlj1xH;8.*f@C#kHuD#/p^I*pxJ+*B.i?#01@LMO]7C#NY8a#760a4fS<X%@3DB#CY?<8U#TB+^L,G*XXi8.72((,htMv#KNtX$<KZ3'=NbO`8H1='4=0]$M1rV$VuNf2j8Qv$bNE%,Q,;S&bxv89[`1<.-,:4;o4AL([2%JV:,DY$p:a4'*5HQSq)=AR%.,R0q2R&@*T@<$qi-?$K1_kLFG`#$r+j8&-'0XJmF?>#%(IM0I'[l]Qd,/(>wxYGDvY,*Ps1'or>=c4j<JvMvw'f)-ewq$QCNnqL/=,4q6c21UMBj2UlG(5Oq&(6I-N*>PSv#>0l)%6u`25'JKA49J^r0(K6fw@jhhk;PtSs$4rgk;,Ju,#I=u#v'uYj#:[I%#l`/.M4v0.$Mm>EPP6$H3dO@s$(uqP%B(XD#)+KT%C)TF4?.)s-(-0[u7`C,)9=#M(A<Mb*&4xw#2YD-(i6%1&doElAxI+M(R^Nx,Uj$Y%^L>T/MnEa,Jnv[$)AY>#XHuY#[+h>#l-dD..:S-HxVS#,c0`.3Z9OA#JqR-HJ[5w-gc``3B4vr-.58O;6Kx9..#>c42e0+3$>E3N4-9](euV$>wF+M(pwIuLIW%iLh@Wd%W;G##N4K6$=Xv;#Q3=&#<Ja)#L=Cm,:PPm1(>YY#K$a`%0u-W$A)B>#'>Y>#WlRgjeQ88%8sLv>7C[s$:2n8%4[j.;Usf342'Z44M]hV$D#A]-J=kq2J$H9M6fgR0+rRj)g%$a5%NKe*.Gds-5K5H;5/wY6xCwi$KDw*3^ocW-jQkpB>1XF3Iuud$C_C#$Z^@,MR<YD#-Lo[#*%jZuAn5c*kC9N(76n'+.J)ulxkdfV6/EC*w>;l*oqDW-12#S8(<]`X6[tR8SnO&#=W`m$VDPuujj2GDKb*E,m2go%N#F`#S$###LXMW9JaXZ6pD1l0^frk']59pp@b^,&h.<9/X7Yd3er$T.JZIl1Qe'S-(9Cv$X&p.*[*'u$/l0spUHu_GdcB15FMrB##2K+*8?WD#C4:Y$T[Zg)]Z_G)68<MK#-,x#)9'r.M'$gLkb6lLNj[IM4rS+MOiD)+AD[p.^AMq%-XUN(a'x<$:1;?#05M?#aF,_+,AeV%Fks5&dZ#7&xtk3+%h)0&JW6d)CD:PSDJd=$p@oQ0%mhR/9q2-*<4pQ0`ouoRFLYd3+Nxh&h7,(+ut>(+gH,n&(=_+*s@'J)x_6ajKh*T%c;.L(AbYn*?io1(=$Sv&#-,207]vu#*J1v#NP'##SfB>#SxGw&tfH[7AYN*6oRNT/PPSmCiD6.%w:Ls-QgQm:/]W50nYV0(<+)?#2G.w#n4=M(39(u$;Omq7RL&V8D9O>-:WC6&:c.u.D9OU.beRs$S.n>'lpJP/2;$##7G4?IwBR*(VC@9.i:AC#2o09/b/v[-]Cu_$b9Gj'j[*W-*0=L#&;:8.@S7C#mX2W-dVfs&R&E2%2m<T/#@]s$AhPC-+DLi)`2,r7mMDs%BR0P'=:n(<xEo/1Re,3#J_R%#3Ck[7*[&E+0Vl>##dUv#0c:Z#U^hV$Vf`MK/fCv#]g]E%8.0Y%RPuu#<Ec>#*<;,#6;EPA)Gc>#IV`i0dA1?-+DF.)DcY##In&U%AnU8@[95d3;?,u'nMYA#h3FG%#IuD#[Z*G4QXY,3j`?MTwqE=.oY_qL%Hikf]=P+D^XDS(2,M%eWuCPSvUVE4uh*x-CjHg2[DPd2RO<IN7*Cb*nh]d<3@;n8A6:wg)xY7$sY8(M=S#&#0qP_^@MlY#:Vf'H/g_a45SUV$.`jfLo>N;$C8^Y#;7*p%bGwo%Dk/6&Vf4Z$]gs;4>Gx-#C_j5&;f86&9#ur$H[&f+bs.M5ps60Y=XdZ?.2-##xKW.==<$w7UgeL2]#P#-bj5n&HdZ`*OE=t$Bp()3AfA_4J4[q$CY@C#Y3gg13dDb3Rra`#pOtu5)-Go9[1Fm'v8Ko2,`@C#w@J-<@.p,3pM.)*Ht=<%Y9GT%_@4D#d`H*3VWt9%Q_pU%Broi'+C-o'Y@$t-d'pj'q.4+-:_+u')laxbDR'RJ6BMY?:jCW-d#jS&TP<T%WG$e2XNuT%&:.<$t'+R&^^UY%Og^U%n_Nh#.osk'f@<D#A>MZu7R2L(skl?,39WC+d=?W.K)+,*.18P'e))O'ZM>n&?CBg2?W$r%Cuc##vbT#$^nqJWC@W;RTv.[#r-@G;@FYd<G+g(#T.FcM-Y_V$Dut.#647<$E9D'8M1C^#+Dj$8,N>)4[HmA#VMfx-fH]q7t55H3SG#c4nIVS%u.Pv,)E6C#w0`.3n`aI)*f@C#qbLs-Aj(:%Mv&D5U>M#RiPmb%Ow*,%$hK:%2T%l'.[*.Desx_5=LK:%Yo$HDNki?#]Ec@XUZg6&juIY%=mu/8/6w'Z5D?D,AUGS7X;$Sn3M8c<LI>)#-PUV$K/[s$Wm+ZG1(wo%LKJYG2=<p%R'I0#eP:C&*Yqr$CIhGDt,Yg$4-/X%@Aqo%Jk/f+mGg+NgXucMkm2^#X(Y^-Mp`<Le;]v$9QD6N<17Z%67t]7s/Va#G>-w7<?-@7U&Fi2]9*H*aTKq%I9b]#,#[iNcWs?#&(XD#4tFA#5Gq;-dI7q.cWgf1/Kq,FF;:Z-j/*E*YJ>m8g4Z;%4:vv5XmIuPpHdjB&-vipY7779V0H2pT^oYGL0Q:Z^ega3]*q`4$_k6&Y8ZN'vOiUm+_C;&8xc<-*N+U%`Y:o(YSv2'pE*u-hB@g)L'Ft$#2I9eJ=oX+c9=+j9W#Z*bmj78`c3e)Wb;2Mn4aO'#sYfX@7Rj#n(+&#&pUY7/n_]$cSC;$Ur7/LZFOGM+/>>#,g3&%%,>>#hB(C&Ck(c#-ow3'GZAQ(O.0@XiB_l8G%iPgS6p4oDLQ)=J:XvRAWW?6'/###D2^Y#,JcY#X(ZV$5%Is$b;iZ#9%%s$_Fro%;F39%Z8w8%*HBtq#YX&#QD<tqGP>V7@M3^-Jwij6bvc&-:x6##CZdW8xAE+=+0(?7tU9`$/I=r.MPsD#<YUe$s.YJMQ32?%FHJ,;g%tY-P[R<-:wcl$=A``3s[1=-W1i8%.:fm&,3*r&*]ms$a`XW-&s'r(A00>GX31RJrvJ@uIW:B#^l7e(VW`m$p$jZuvT,l$jfbB(161N'W<*970Cp>(4Ke+*gcDD+e<I%,8FZs.#3%M(pKds.NrOb*<M^a*p3>U%7s1A=CYk(EZEG,)$sP>#@qn@#xQt<8>UIw#.d,##s(^,&wo[/E?Auu#k:3`=Q6Ba<XdB:%O]ur$QL@s$fBEe)0FGOK@k<T%SR1/#W&h6&=O7@#MXff(Q3^q%Z%5.#S6K:%_%#.#>=[S%^'[)EUg4A#m1^F*PPrZ#1chV$*mu8.5m7-#$<&d</6lg$$n#PG,D^F*1U:1LZSJ&#sH4j(2VS/)MXTGE1q4K)PND'8bjF)+OepcE^WXN(ld[0#x=>0hf9V,Fb(q;%BwD&d=Z-?.vF$1#9N5W8KKBf=H`,##<:+(IH@]fG8MvLF%BORDFMNuA/alc>i[qk;0kBZ7W2kI33_:O1[jx],A.#d&)v<a*K[_F31iaF3Jj:9/aGUv-]]WI)VEnb40iBd2-><j1qI,G4KjE.35B,<.7lNX(v7P/M^?'o/-lOF3Qr-x6:1fi$.Z:C&Q9ki0NvrI3Kj[eMf)HX(,0Wf#TW92'JH>n&l@kI)6J%Q09Fq97rfsE*KFe8%FtaT%a+S+MZnAQ&_iR5'uDLu$*'&a+aHFt$nqIO(k^gm&D$0q%M;8X9A:VE>BZm29&fHs$M_.W$K)w)*6n<u-dif#,l>Hr%]SE**^_@w#U:q8.N]<9%E95j'V9K6&>mA[SA:%],GRes$:RcN'J(M^S(W3[]j?7##8Wqn#?.5>#u2h'#=c)c++;YY#v)f>#+Guu#FmrM%i>x^4mXS60t'GN1<u'f)p>(l0Ghi?#sH%x,C6WDNT$Y/2;p*P(g<7f3^dp_,NhjU%&ebxbrBcw$ic#Q8f7&x$A@Fg(P<VT7*hNdGPJNW+qk8u.RF5L2)55**3QR%%2tU$%EVpkLm0mA%&JN0(Nw7CF:d--5pAru.)@Hd3VLJM'w&4R%'$-T%.pl%=KF)>G998SR'pJl]hF^.h4`qi0&:Jd>v+$g3'B$r%>Hal%E[Js*g3S#@5`Lv#avoYGUw&m&]jx#GHoQS%*;5##e#dS&MO)Z#8]1v#AFhcD#3:#$S3TM'cd<*EX-B2'_fM4'5r:a+xFYC+kq^+*iE$&+@%Fx>Vdx@#Gb)&+$M>V7.q%B.cU+0L77@m''Y[^%`qV&?;Y6E^3ITfG>it0(47HQmArN[jXc+5dn6p5cT#fJ[Ym9pW@?8$US'bRN`5&;LGS?lEMYa:B3,`D?Hm2t8gu>G4kY_v-pC]pCjnW,<l&$w-[5MG)h^ei93xlG*5D]pCBT@S'Fa4v-W`Q>Q4%4B-2a:aP]F'c3(`hA?kx1T/F&i@Qxa@I-Q&P;.k&B.*+B0<-p&lV.Q(<.3>w<r$wW+'&-Ybs6_i-B5*U:Z%0S>s-Ia9)NKK2Z%M>G7*xqUtM(E-n&+q1QNH*%ENoRsu.gVuY#A0Xn<]Xa5&xbX$0,[Me?)V4Au-TSr1+SV?#:W[h(T.l+'t8^sN);^fL,Db1B9oie.o?Gg2J1`H-3K%Y/M0tT%-8RW$a,Q;7W%dGM,PR.OR):sN0QR.Oee-r%/M(v#1:U#$/kUo*9#u;-HvZt.oG7L(:>:I$,K%V)`hFT%DMUuur@bo7X[b/<-al^,KDJ>,?iqV$r^%##TE31#W7OcM?RW5&0Y1Z#f&DZ#3lqV$cx@T%kJWPA.fLv#xxtW6V2k.3(`sT/O-E)+B^ap'`8@R&nxqB#x6AW$&#WF3(Xp:/x5Qv$Y(b5A<[W/2q*:=SqL]L(Jc5<-MN`iL+c[_#u8fjLAS6<.</t#5H)[-)h)6]4oI&x$mfB`jostG2)U:Z%,M(P/79##>h['dM_]e.qJR<P&<kIx,WOwT%L[+x$`2iK(h0CMBu7[w'M1B>5In*t$[&Pb%Z%2Z#Tt_q7p.w(#SB<h#/Zu##hoUY7]2G>#qE,+#W7XcMK=&N0^),+%1`U;$];:5MgNW;$4WCv#5S;6&uwYZ,lsW1)(Q8^+Vr6<-X#DP-P,ol$l]B.*$a+B4u02?#+%v>uncs)+XE]r.:%Z(+G+;2MtROA+K-kT%$1ciBJT/E+'3v>]eoH(#&&>uufYj-$3rC$#(pm(#DZq70cC2?#/rrB#[7Is$jMR)*?ZAf3%E6C#%&AA43UHIMjGPA#AB=;.TCYd3NDQ,*c[1:7OD[h(%QU3'a&`h(V0T3'1=es$1X'+&aebh(<'=dV)cO]u>bK)OtJQ3';n-_#):0aWDet`Wf/p*%GT+:$:OVJ:/g3A%YvhfL==pgLxTNmL_j;_$7[%u-PB+kMRl=Z%dKMMB=>?G2#ubD#s3@G;vt_f:e*ST%&L<1#)>P>#)3G>#3Z]Y##quF#f=]1(rR&E#-qZ)*2^ob4Cq5V/m+&i$,L]s$P#ID*ZZ*G4f[rX-Q=GiE5^bV$9sY,*V:KlDsbf6*(QAfh16SC-a)EA+V-e#@%mL[6S109&vC+W6wn;H4r3bt$3,?s.2swL(;1?,*Gffl'W8E&+MO.[#W2@H)MKdE=T;gWC_u3t$w4pB+ekiM0fb5?%e+*D#ZHX=$^+g#,Zk%w#2oh;$l6%],Tl.21R=vY#u9v,*3k)-*5`Ul/&,###RUB&+.aZp.x1<)#;jLY7OwE;$vE,+#&,>>#9G4.#,cqV$?%q'%1o_;$^qi*%ocA2B0rh;$)cRA60qg?7Z.CJ)w]Ul0=BDa3[*'u$B.i?#D.Y)4Xf@C#V1Pd3$__k$P2,D%&xOgj@w'E#CpvC#Q-SO9@]i635])B#W0XXKh5;Z-bK*+NQ1N]-(7/n/pp[mUN@tp/v(v++b.5F'[91809^lJ$-IG2(w9a;$?TV87RZPh##L-C>87n)4FBSA,8D3#.)<64MZ]Q#7rU=JEmMcu-;j*.)R>9a+*2se5fmj;$euU$-.Ecu>G7oe*HVkr-/pYc2kr.C#v6@G;g,Zs%][X*ZIfq;.xR&K2ttAq/i1lr-=20w$Bp()3@<7.M15v7@uJNZ63:AC#0nf*%AV>c488&cnXFWwT)NSB5,hS&5P]S0YN46XhP]1Z#>gpN-]:e]-&N57aS),##8Z-4$?,###4x5U7K)rE3T`'##t7Of)oJ:l0QY4Z,hW*v#_f_a44:8C#t0LhLOd/,;aU?Z#$ur4@Sv#V%-s(`&KE8tu/qln&J.<xbLkE5&%Ro$'>p7;6Bc5##u?AT.,:h'#V%#c-JV,RE$aaI)B.i?#3>km'01g^$sKil8`38N02ex&&Jn8L1g85<$1(Fi(D_Jh1g8GW$'?=]#s&Qr%$3t5&lKOGi/3.iLw)CQ&p#?Ak>l+G-i7rq5wGic#v9E)#sPRZ7PTu]#UO@?70AG##cWO5MAT-+#C@].%KDc>#S`]n$f8P>#*BM,#4G&2B';P>#m$io:kw7A,sPCl0Ss`a4R)B;-#2dd.mxG=75-B01Xc7C#DMn;%`X65/?-fu-(NoeMNHr-MeBo8%^]h@-qL9k.90_:%(`:5/Kk@5/.J]fL&+LF*`Qn?9JIn=7II?lLa5U<..H6C#XpP;7OAi/:Bo6x,lL/u(Lwnw#OZ:g(sOuv,d9sOBe[(D+rw>v,LLX5&%D7kCAgIUJt$+x#6,VT/X?4Q)=r41<d-F=$'cnq%LC*p%d=*#.0jcOMZUZ(+wjl>-S_UL5`%PL<AhDD+;ZN+NpC#hL3)=h)^t[[#bO>G*mcj&+lnd?&^[]70-`(D++E[<&+BAREGO4CJl=*u$$Sp'+LN]V1.vg+*8xqv#1%qF*i-l05DZRp/5vaFNoxbC.wbWG<Zrg05ECh)3(8YY#A7xUd,V+Gr%5_uGa6$H=j?]w#.8?),$C%K:)J%<$*Hic#'$gx=tBtV$O?SnL/6UB#A:UcD.]:;$B[qcD&>uu#?@hcD47Rs$1^XV$:)A-#03K&=IO^Q0]5b70%pql0va)*4QV>c4C]<+3&,]]4Wl8k$_=@8%sL4gL^N:a#x3YD#70l]#osFA#NI.[#]AqB#v:/70Yk[s$H.<9/Q2$=1M[C,MGj=c4lEGC/MlR_#YekD#[lY[9;0uV+EVL;$AAN#59nBA$bb(0ME9U]$hID;$q<L9&l8;8&ktx?$2FDt-+E^CO]JE#52+aA5b1%x-?420M)W99$[abx#Nnew#+,Qt1BiKtCRK9B5QRnU.dU2c@i;<qM<[8VmFO]r2[?ZGM1KL@-EIFJ-*6aU/Dxm>#)Yqr$*#w/1?F.%#jpB'#>DW)#['Zd$Ib<;$/`C;$TiJQ&led?#)>Y>#F[iw&p=cD#<4UcD8JY##<@n8%:BP##BR*T%Q]<5&E>iv>_Jq6;Rp<V7Oua^-RjK*9EVr]7*c@%-U+;?#s@0J3YA0j2'YNt.V8:$-EIQc*aH9q%Y6XX$0]1?#9_I[@x'1+*;X^:/R==30lua.3vbLs-YmvOi_(JF3S74#-t[RYQb;)4'7F9h(ui^[kYQ@m0a)%u(L;UtQ<oEO'GA)m0TDL$-xLk.)b-sZuh,f],lh,)49wChL:UYHMQ]-lL7@Q_+MfqA&3EW]+0AR]4i=M]=IWqDG5;5##qMYP&&I,+#E^=?-S)@>%^77w#(2,##jrao7GCTj0dEm31DS###ZU2e=Ea?<8RdeL2?m&F4Zgx],$`>_+^Ngi'hn03()nZ0)Une<-q$_5'N#C0'H:xmSiQ@R;k&o5'Va.(8?`Tj(p#tI'`A^p7wtC8*)gw-)mY$@'`G=[9u9Og34_J7nM60q%4>^;->u#&%fap$'m&jP0Usf;-EPB-'P+OH2IR@n&+Jc>#j,>5&t7I<$G8hl%KGY##&v_Q/:41,D1,,##n-'w-Wjgv7S((B#-e-8[#<r]7&'Om5S=/*<H&Ap_Oq]:/><]r7#eeGtku[?(Qk3sQ'#EO'A4'7*<)uP8@rt1qg1)<-ZGWj$9g,-+wKJv7w]b&#=:1GDn(a2KJ_R%#u2h'#I]&*#$mS`7V45n&RNpQ&Z8WP&Uc'##;l$W$9Gx-#.l6s$<P4.#@I[S%K[_,D0u68%Nk6dDDBgQ&:,qo%M9G3'J`x-#NF,3BC9TQ&+/132$Q:i:@,&u8/==^6J<%l1E<%51iSC?-B3/E+Nf/(4^oYhktI]L(PD(W-;5LH4Y<-#YJ(Ku2^pn6.Q)Z]u+K`b=9I6c*O1J)&E1;?#pM,W-NY/x(ZDA1tMwBg2lqmi9@.xP/t#v3'`C7H`BA2d*EI7q.XpYn&(v:_A[AOjLd%4,3%/5##BA35$u2,##ZEX&#Z4)JD,1s20TH31#[frP*3@$,*F<oA,pD1l0B.<9/@=@8%vZ7x,VxG=7sO,G4v&X78w2w_#FJFG>hW%R*Q3nU7.:]p&kW3C&ZAmQ6i3ulC`<W;6f=dg*CN[IM3s?A@UlW3'C%L)?=3=cD^evpDmcsfL@)^fLr7i6$>`)<#R7p*#kJKA,-/,##RlkK&_AlY#mTHw7BqOx#lrqB#3<qi'tS#w-s3hk$IA6F%6ur,*inL+*d(v%&`WS<_cSc$0H*`hLDITC4jh;d3cer<1M[)gLc)iE4;*YB&akHp.2`:v#9DcY#OUW5&86'0@Z>I1(0L:O1WLEp%ZWio&-M=gLiRmY#9s?W%WC[W$aa/I$I^s>#&;e/(:vNu)+KsL)tKRo[6V1v#h%]fL@*tv#'Q;8&i:'m0T0/@#tD(L1J6m7&=MwS%jrRfLxBjv#V`l>#<7@<$xxAO2S_f/(r,9W$CdQ_4*E^[#/OR2&li./(iwLS.LHCu$+DY>#tD(v#u,BVHb.(<-UK31#]o7m*hK+=$>oDt.+,Bf3lZ*G4Y@Gm'U(KF*(R6a$rTZd3Fi4a3h_tq&t]BQ]tla:.p[W3'VS0t-JewQ/<5t2gcWfx&KGh0,hi2pf02k2gAE+Q'9b3dX2wC6$gXv;#M$),#.3v89AkO=$F4D'S[r_v#]aCZ#]r^Y#m_[#1e_'dM.f_V$XNC;$%$w>$UDwKYGb$J=uctI3%SaT/ak^,3uJ:l08_Aj0%kRP/GO=j1pC,c4ZG(E4?W8f3_c?#68KGH2)^B.*vF0+*IPsD#+_D.3.wb?-KcuS.1j]+4WM#W-3H:C&Rbj=.bhR@#CAG]#n8d/(>A((,L=[[-`w0S02Sr>$g%&l'e1:0M2&.Z$UV6g)`g_V%<wj:.O<S[#?xAP'_pdT0]N<@,g&jv%H(F/2l3.x,f*Dd*4<SG.jRr]Ph9uw$gu%4$(,5>#^Qk&#B:]@-ESC;$u,=;$.]U;$RfT>#TB*1#)>>##cb`'56jo>##UND<8$JA,D^b:.3%Bx$+tZ0)Zs1-%-)4I)s^Th;[1G)4Ra/m%x5+G41wPJ(1,fYm1W5A#5q+F++'v;d]Ulf&s3sW'%_V:7H5RO'a43M1PgH>55hGe)W,Ys$qU@1(xN94'Wm29*K5QSI@]%@[u&XZ#]rn%#c&O`+N=r;$r0@G;',,##X%_>#]o7m*IY)7)NcI#GYL6_#-H;d*./p,'BqlgLF`0gM-(Tp&lGva*D<,8f#2gBJ7(KT%uefi')$ZlA54a2Deq3v#*A`^#&FIG;@olY#]5GF%/f_V$qY.[#/J,##0g1$#>R*t$Da(v#1Gc>#mIw6MbC?>#i>SfLUZ]H<F`5##1-^f=3k0?7X>9f3%SaT/C[m(+W>6b<?8?9%C9#j'%?(l0'AusoFS$w-L%/e%B@`[,=J))3KJjD#-&LCOmJE.3>U^:/]U5l1(CTfLRF5gLcN]s$(`R_##82Lb9KihLTA^+4<4b%.Pt,a=u`nwHaZ@g)M6tT%8S,<-tG5s-S8++N;[rX-(o+7*'l/>.a1xL(;%`;$K_N]-mcC=.ia1I$UxuCjN)d4Ml;^;-*2nx-&@(-M-u19.8XkG20YNh#1<1q%m;,F%tI<]-*5G>#mD35Kue*x-S3H&#/s6T%[[huYEx,AFdqL`ENQwI)qnLJ:4xLZ#f-'s$&QO?#_LtcM9qOJ(P'0m&Dh--D-rQS%Ge?dD2+35&7.D$#Mou?#K-p2'ao7T%n%'QAAqo2'ZRLiF)IT)IVj;YKl#9KFYFb#Aje-l;jA9*+Gh-H3.APv,M1N$oeZ8s$T]``3I>WD#6TID*+g^I*HTU_&o?dh2;b5V/'f@C#Fwf20r`iO'+^GG2GWp*%HS7C#UH5<.>'<FNUXj=.m:`a4WK(E#5$fq7:;tY-SpaD#/,=s60'2c#a:lv,:hpb,4q5/(cH+A#::+,<G/>u%5$b`<w<5^$-SFs6<BiC$:B.IMb6+;.rr7l'VU4C/:,85'<=b,)ie%O9A+1O1AG#W-o)PC&e+S_#:&bt$+VrZuSv6X-%opc3liX;-XA)C&$>;?#7>qp7K$+t$=Xx[ueDHg)hYY>-1(/W$gS((&H7h/)`MEJ)lN1V?jY-w-^%Z8.%/5##6Ec(&848(#N^%l12?u=$w3@G;';P>#YEcY#_#ge$,S:;$Z<,##E80##1CGn0NEJA,LKCG)AfOO+tTZd3%%U</hu+G49grk'LwF/%v:Ls-b3CnDPm`v%@)-(&-aTe$PjsBOVv]->P+M3&<#'73%v@(Q<1sY$f%Mg*f%<X(%vT>#bkmW_rB'U%A[[@#e2U8I2vPg);S<+3iLW20'K+P(TF;8.Kei5qEo.M1/>p19KdBJ`LxjN39>P1#d&U'#&81b+qW0)3=ChhLxw*Q/G`wv$.^NjL_s+G4V#vX$[j<D#jj*t$GQ)GF2@,n&Q;o%H9woQ&5=mC57*&T&R%Tw5/Mi2'>ew8%STkp%ZnI8%*GZ0'gD-n&s)Um&LQ]5'Z07r7ca=v.tRKj2';P>#XK1v#[1q>#X@b(N.i_;$+Exu#>ng0%oc08.>LQc*OEVm$jvZ)*)qaIDj;;%G[.T,3='jGbl.P6+BPeW(bd)_XD][8^$K9>GxI+M(=fbv-%DJfLnFI5JO:(<-Z2h'#EJa)#g)E_7YSdY##9[[%2x68%oY7[#U1FcMG.#D1ogXq%+Gc>#ZWCv#)oBj%o4.w#ncWP&&VWX(J3,n&Jjk22A2BP8--6w7rLi`5G<%l1Aw(80O0WD+x14.)d,m3':VP##K^hg(9:j5/4(XD#&bc#H_8BZ-mgfX-VNIm0*w]79)1Hv$Vqe+%u^bX$_15$%#jGA#(*x9.PX9]$4ctM(v-dxOE>HW.biLbOwLx@#iuBMB5]&q)Kq_f)Gu8L(^J2C&ZXBMBL^8E+5V7_u6<#]mkEni9s,;M2)-Md3q'(K2G>^3K/<0N(R5+jL`-ND+9pg*%g2qr.$D<=.Qmn@Ov23G#C2G4.`m`&HEI[j#/h1$#L9/W7JVCv#5nL*'//FcMFWbrH'cbb3YJ8^+20mQWwdOs-cawiLqe:Z-Fe75/x)Qv$&0E58I8?Au<qSGM%32oee0T'-u7Fg2^[Z@k5d0W-P[.F%F-jh)NxJfLVq?##9a64$h,5>#d^''#Qrm1GfT?T.X;G>#7cu>#Igh;$0`1Z#RBlY#[B,##+>,##IPG?#7(@s$0VEj0Ao,$&2xq;$U^Jj2Y#x;%RvqjX-xgY?')aT/[%-##&:102gAP#-P8hr.m,Hn&Em;A+O?+t$i2(W-];,iCb(_N('Ptu5@E$>%p;Hp.;X^:/K2Ue$041B#>u+7K[JW]u7A7Q/wZAw%k,<mf3ITJDH8_8.$5M=.Zm*B%dvIn3q.i;.*FkT2LW]%@^aa)#%&>uuhw0f#u6i$#gP(Y7^JcY#*DcY#Tl#v#ke#gCR$g*%Q/EPA8Zud2C(8@#k[Fi(0/j8&<=.@#'e+na6S+Q'<K=D<+LaZ6248C#t5Qv$6wf#'4?KDthrv)+7elZ(?o(9.Z7nm&Isu8.$7k4oUK@Q0v@xL(QxCT.2%vYumV9k.qmkm&x#+n%h2TuuI0`l824/W-cASGllc3.&`dxu#eW']7S6?;/[?xc;&`uS/PMWfLXF0^F]=Z;%xO1gL1=L+*6Qob40'AjLSU?LMZ;RA4Xk`[,s/1V%;xF`#']O]#K#`0(C]ip/LYlY#2CZg)G4.W$N,RH)-Z1u$IjJo8@4RH+[p?d)1KZR&9+.W$Po`_=)T&@,Ccxh(>(O`W=.iv#]Bt9%mbKJ)h<oT%L*S&,9c;>7)'.h2==;%,li71(=KgR/)Yn@-9Ys11#e*]F1BB7/an*9%oZngutun+M@U(p7PaGJ(=cl/*qF5o$DRFT%9Gte)qPCl0Am+c4No^I*Tj'u$w-<?#a.t)'al[p&w7:8.wXf5'mAs[t1WfYM#mQ3'/D>t-P1%s$WUtgLFc?uu('p&$G?O&#<;2:%t_:_?<ow60V&<a*1#4I),5^+4]n.DIx*[x6IUFb3`@i?#Jj:9/ft@T%6u:C+PNa52p2Cc5pxeN'*&,>@^lTh2)B[N'V37S.dD24'%xJl'k<Rx,HH0>$*UDYPU)I)**FYu%SNtX$)n0)M(F<($R2h'#AOG**F$AnLI[5j+YgZ)*WRUa4vmT#G=.ge$$Dh8.e4NT/$%Fv6(49:)sfvD#*4)A,KE>4:Pn@<$k%Pv,<9e0)nE4x#5O.PVdwGe+/*#O0Lq%@#q*v$,D72?#vjR5;*%C=%;R$q7_[uM(W8U7/M<tW[()hf36;*'@2x]M'f$+X.UK:g(xe[20.NiuYK&@D*HKQ&QVO?>#nVrL(d=nXH>gr-*Eu$s$,m+c427Yd3%wm;J.C#b#/6;Zu<1Jp&#6%b*Y.%s$Yb6t-%)###G2fP8r?GD*ZN.DE5YJc<6pv&#-PP##IZuY#.`L;$Q-[0#VE*1#5u$W$Ae#P0:#,?#+ts`<%V>jLF:GcMnq*[?S%?c*_3IA,AH4Y-4[FW-OBi/)vPCl0B?uD#4Bic)ae_F*vqh8.oaVa4S]DD3jtY9:sDT@#@QAK<^58&.g@7[#1bTi'YiHb%L5vA##M4M1KZG]#(h^f$J#Z]u89aI34sD2.j]o'HLLvu#s<^PgAtFKEAO&(#xnJ(#4rqV$U0[0#XH*1#&;cY#6>x-#1c1Z#gsY=49px>#)haD<jhk/2*<ja4d9_=%B#s_$IpN^%TM6W-xY^FEd'?fXe2&$9Jid(@/U>q&RqV`%<O`X-_'3I$pS)3'^1US.$c0^#QB>d$H7Lb*iqv$&]0kC&qD>f4#xSfLKjvu#=e,3#DkMV7xsYt(4JBF*%?sA+gK849'g`#5'K6C#U.Ls-*Bvv$LLhGDjOaxbujC8etP*mftR*QJq1%TI@VN_l$SFi(s9D?#)o82'g[nQ&)Ls;6/UYY#aOnRn+>0JhR4LS.$xGg3c:mY#$'%%%uHMp$GHXW-UIjd?M%%<.81qF*QO%<$9O<5&r>(l0WVSJ&dZ$H)cTvl$p.rv-r$:hLk%Ad)N]qv-P'<d$g8$3'Y=6t-BiR*+tb)9+tl/E'qs3t=2JO]uDT7f2YC?t-Q3GQ#Jm5c*Wp.]]BJgHQU####OZouGe9EM0<rv>#s-@G;1[3W-DbW<U1BU@'_TRg)>bw@@@2B.*+E?A4tvr;%xbXhYw3Kx*E6&;Q.#f]uPpc1MFg^.C^T#j'_$+?d.Mxa*m<j=Gm>pM(#dfA#$lTB#0d%H)IBS88f:P)4.[F$Ks3ox&lhV?#T'6AMUp2JUr;vJWNn;J:Ag0^#ru]7.ABr'8Wl'B#1tao7skH>8(%(+*M7%s$GZK8%t#fF4<)]L(SbC[m^-;_#/%Z(+UH,n&%^*jL6mOu-t]Tu-tg3t-/Kon$@la&'%p.+MP^11.@(&;M:60YGf6JfLVk-##d^`8$</b9#E'jV7U+;Z#iYdI%X/,##VE31#`];p)eN==$p(rB#U_V58,/aw$f5.)*pf7&4wXf5'm6YG-,%kW9socG*[4,)kLbd3FH^.;kwUSp&_Kk^=1Kq'#>o'f#qg1$#e>cX7(u,ekPb2Z#<r9?$*A>##YZ('902E%?1uh;$6j$W$i*8W.v+xh(wc_l0MQ^f$>va.3DD)9/BV058FQ1E4S7ZV-L1SF/*g+G4^]J@8O^WG<X]v1:O<GqXq2]nXOA>gWPbwL-184S4?(guY_XLS.2Mvu#XN31#U7b(N>^d`*gh3t-)huA>N-CW/G`qv-ET$H)*13,81utB,wUSp&TvV)+GH;d*Pr>p7i;f,*X[a:8eNGs.T8F[]Acd8/dhZV-]V:E4pu;9/.VlGb4VYE8k1C^u*m5c*$4I`]TDK],LPQd+ceNe58IQ#$BF,l$it[='En9%1t`BQ]ioj'+3k`uP9=rQWXK4X-?[8pVIQ5CJHj-dbwE75/)r$x,9ek/1Zu/+*oc@A4gf&v5Oq$*.M1HAMXHIA4HjNu-al[p&jF?b8)mJFI6@]20jh=w$'8P>#KX/I$^2>>#P3G>#WHuY#*9;,#5>NPA*MuY#aTHI%q;7F#bV.)*:rg]86:Kv-%_`jV%]p](f0/@#,4ox&l3W?#I=_h$v8>dJ](%K:5=HT0?)B.*516:*fe^CFPm5q9,7,,M2QEb$Y`Cv#XEc>#XiB>#VIZ.4$fk[(FEtDYC;B.*t_g/)*a^e*dM649suD)+=lYiLsk?b)vwgwT3ba8.[1q>#.0e>$BWB=-2c;Y$1d%H)@'J5/`_2l%f'32kD*<j9/5oiL:o`Y-d>[K<aevu#t#xu#Xajh#a=sd%5_w;-fsEf-e>kOB+#m8/D-g)9u'lA#P#x$*g3Yg1f-5>#6<x-#$Pht@X7+gLuuQ##^+h>#Y=FcM0r$s$f(qL&q.;H>B1.42q4*t..n]s$'s.)*Rq@.*sHNh#-5B>,)`A>%.Odv$B.i?#L*@m0f#'nLxf[a*6Jn20p_P12i_Z=7;(e'&Wch*%pnpr6g60C-a%)t-B`^b*QVxH2Ba*%,CFl6'w6%],rYiK(44[M0*D]P'Wd(4'd,+jLD4XF3]V#G.q))4'n@Qn*;vc'&fh[S'dI([,`S++Nb_:%,7i0=&[>m#>%'0[#kx+c.>U`[,uf4W%6M:oE.e0a+$4B$.P2T(O/ZvY#q'0s2=G=$,Dx:ZutTKH)`O@5)rCj'Q+k2b$%U#?.qBZ&%1sao7oma)>?ICp7Um?W8*[cO:I>uu#XIVS%*C<h#oZu##rJ6(#ENnB#*@@G;8lfc<G+g(#'5YY#M#%s$:7@s$aLro%Ik]PWX[$##'8>##Fr_W$0i_;$^*8F%#b]s-6h.lLYFYcMHNU]?8R96&$`/q/RTo],q_#$,KsW1),^8^+X-cXp#ArB#eFrp.gEW@,+l@['R[)W-vkh8.uAOZ6_]DW?x>Mj9`_]ZP?kUd0rG'/-JL,K2^GL=.?&@>5Y<W:Q]l<>5i#pa%6sSU'vk([,dnb31_1<=.Hh:g2-LAg2F@*i0M6tT%%/5##.b)%$2=u6#M-4&#7J7n&uh:J:Y1-wHTpvD*_bGl1.`3=]6j[`$'[U&$`e%s$(#;9/TLb%$Ohof1Y@h@OKC1N(ucL+Vw,Uu$>YV;.iw0k1MVT[%x5+f*S#/)*DRu#,Ar]h(.Q3I)X5/H)cIWj*>ikW6Ai###M9I*.@T*rL<=^%##?$(#]sR+#vD8(OOGa%$aC6?#0r_v#U<[0#+J1v#0aCZ#_vJe$g]/2B?1rv#*w&&=8dZ3'fTp20PHJA,q7B'+g$uX?hO5s.fj6U&5;[%':sWrh%4L`$i^I1asKbxbi(cI3i#123nRg%+3Fop.7(=J2h>1I$(>v',&eQL2m;_-s.EOgM=b]..Q'ux-$]tA#a<,C/cN.E3Dk8o2fOJR9V/5##8Z-4$&-5>#x],3#K=1GP*SUV$TrRfLq[rV$'?+v#-UEXAi+`J:(pE`6^*WV$AR$dD2]U;$Y&coLngW;$8aC;$%kcF#K_/$K(U^i3s;Be*Kxu##Q9gq%:N^4&5E+G4d+TC4oU5l1gUsD#Rq@.*3P,G4]jo%F%@FQ'Ijhc)x,q8/jAqB#OgT&=R8;H*oU65/I`:5/LpLT/Xp1;?<Er9/rM[L(=ljj1aDHj'6teU.hHff1&>#l2&,JA4t9NZ6:]d8/u3YD#?(#]>>U(KC+`F+3oi&f)hK]@#@nsx-$8cY@?`-t-&r$lBF<5pBT?lJ(WoSb*>%Is$QmLg(Ue%t'N^Yn&^ms**N[es$PY8b*PH:K(1VuY#I&*&+ig-3'ZpP3't,Gi*7@3p%BR39%NNd*7a$Z*7lEGN'9L39%#G:hL=1A8%_9tT%od_p0;fL;$?L3T%;APuuioH-*E0>/(ELET%%=oT%8Q?u4AwU]$UC$v&TZcn&Ytm,*MX.<$c?*E*FQE)+gUg+*Ot:r&TNPn&M%/<$*GlY#@tWZ#.7`f:K-kT%CDmm&@0?51,]_V$K<E;7Ta:,)XfoiL`a(6&1M1v#G6@O(gRL+$.6kU.>VA-)/u?s$T/0X:K.$##'&>uui&4]#s*V$#vJ6(#)@ib7H4)v#Nq%s$00>RCs`.j2'AlY#?)B>#.JY>#Vu>;$NB/#G44@W$V05##;_733C2n8%2B;,#AoAmA7Fn8%RCW2MR:GcM[T`#$H[3<UqVr]7w1T+4@_Tu.vx[@>>bu`4sr,W-.w1_A,BqB#@D%$$7%x[-4JS9CHKf>-5Q_V%u8k#3a(7I.hlP>unsY^Xhw(0&4G(v#d-DK&60?c&V/)s%-/d]u^iZhM`)qS/ft=g2haveq**.E30]Cv#7SPYu+alN'?j*R.:UxYQK;1N(i4JfLYiVW%K<2igS6p4o.Anx4on*;?YE=SIDsOlSOTDW&)l<2F-HMm&bkWs8a0B5:F$=x#T.FcM5`:v#W7OcM7_&6&HiUS%ZgS#G%8xL(W9pQ&eDcZGO_E5&RkaP&ZBw)EUw&m&EV[W?>mkq&?>qo%Me&f+&Tma<@f0$RqFYcMUY6m'&s+vU1DCp&'*aBTll:dM+?R[:w+q`?09H,OtpOU:LS^%OorEgQ98p?K?A?pD6T+VC3L%T:n?//=8[X^6KE.l1dACZ-@[v(+rSMO'8MG##9XRE+>#b$Sc%^3%Tw(@%Q5%&4OAcAOtB%r'^,IdFh>GA#0[*W-m0,TqaVg88oOO3-%ao'+eA5++6`id(eRj50tSWCX.p*2_9C(Bu[v+7Kk+&X%.A^;-=lYs-G>P6YSWl4o']Ll2D@h'+D2?w-2u7F%$+/f$PTM:MgM4l]wqE=.GEgm&:,00MEFPG-QfE=-xa7m%LuQp.4t$#%fSpPq;hYcM<eNT%fVjp%1tao7o3sS&AL+v7I5v/*S1K0%KRRj#95=&#/dZ(#F0D*#T.FcM5=[s$a1J/L47[8%_pxa%1%I8%RwH0#Ya&.$3:w8%Yqi*%U$A8%7W(?#hUd>-?3.12h:J210sS+4D'ps$BKgf1s3vr-aG.#%x7pb*0@EW-mw5R*@G.$$uJwa3PEZd3NQ#]#r'D4'bDO=$`)M4'wvc3)Hho@'WIE'0M8QT8Z=XT/71=:(CQ;DNWd>n&MW-e2F<S+.S8vA#R4`R'E$qW/ge&=1+=qB#5%Z(+vQS%#T(ofLRkq/#VL$&FV7&8@ave1^[qrVfDfUv##JmY#75C[#rA^M#oACB#iDpa%Y,TBF2I/2'S%gS%k8Mb#3=9E#Yr2[AE6KQ&#m6s$m<W@#bU'dMIjUG)uQu0L:xcY#btH0#@(`?#jN[0#>I82'LJ'##4oQS%`;[S%2ScS.rRPJ(L5aV6h7gq%iX/NKSX*p%Etfm&e.,n&i>%<$9=%@#a?]b%j?R>#6BG>#)Ow[@:h^9]#D3VW1;ANPCTfb@dk+gGYGMH>XYSU9k(QG4g'a52CM9(4Sg]I*@uDt.<[_g,[0N.NLUfm0/XkD#Yfl8.[5MG)sCi#9#%(f)Y[0u(DtqHM>8$[&>7I)4vUq1Mg_h/)EuQ2MZ;jgUnu.r8>bV6NxrAv$Y.QN;`2FJ-<X,[.-'6Z$'lUP/Tmgm&WZ0>$.1_>$1:U^#iu10$LjsvP=S]O$8:wS%KmPV%`uf#,-GNfL6?$3'.g4q$t<h0,BDM_&wu8?$1]1Z#.PTo1/%.W$rmnY#=tBf%U0]NM.FPGMX[mY#GMS>,*ut]umH%[#HHV.M<(VS.h6>B,am>]4dg8hGfiKp&Acwt(%Oa5KS9N]F2?H^,c,<mf&-uKPuQh-61;nm&'&###X^j-$A$koRPNJM0NK@M9v-+;?L^_[.iapT9+`_;$I.RP&Ak&Q&fRd?#Ckap%ki-['=[*9%Tb-,$(;P>#eS8m&8CI<$DYqo%>tsp%FJ:8%0gLv>3uCZ#7pH8%Ei4SAbx'm97)>W%]#rjXURW2Mb;GcMBx0A:`;p`?'G1i<F_>n0vvXC?ihqk;8t0?7&'H89B/gB5kq<B61j8^+,/Zx6tW'd<A*Nw$BKc8/52h8.HFqb*Wwjp.[<+J*tAT49MEQv$xJea-$rkI),l>a*)*&?5>._j0.ltN+A+Yu%xqcC+3CqN(fNYe?;rGb%T1-G*?B2C$b(j[$V.#/C'?1d2.GGYusKds.@(@I$42Od3qh&Y.T=e$'(8IW.^$Zp*cR*rRx=9b*27Ke($%0$.]1xfL&>#M(9(2g*NO@8%.mQ0(.A)K$(k(.6j'Ch5n4@W.s@wmLV7$##VWj-$f9wu#A>J5#s,_'#Lkk=;PJWC?P_WV$.c_V$Vu>;$.YCv#UaCZ#RZ+ZG7Fes$`H,##)DP##J4'I6ho_v#@Vqo%@A@W?=hNT%C>[S%Kn8f+v@qG7uvUNX<>s]7Ir.C#_#VO1<tCo0eAu#--PbI)T$F9%KT'B#UFcj`'71+*S$]I*3QCD3Jb6&%LOTfLA'(E#o>:Z-GF;8.T+rE%?;Lto/g&gMb;)4'&+-&4nP>A#'k*.)iA1(&(uA]X&w4,2S3&[up'l3+d@Vu-6/K;-5x%i$d54#)W4vYu;?=jL5ggj0S6cF)_PCV.6N;Qi_EaiMt:$##vQN`<FIg;.qj$-=ESX/M6ptxF3Y1v#,P(v#Vu>;$V]'##'9cu>RW`B#/*,##%P>V7fgXZ-nbV*/K1?T'ee69.R[j=.O6(Z$u.<.;eaBN(mXfC#29tV&U6-K2#`)W-LoP42M1N+Vuh*x-/)<g2+3oW6I9YX7b,lZ#2F's/,JlY#q,>>#Y1q>#W7OcMg%<X(0&$v#ExTf=Zswh2S0.O(PV9c$9A^Y,E%AA4^aLG)'U[1Mjx[)*n7sD@.77Q/&@vr-l_K+*Q3M9/?7%s$NWgf1*77Q/ii``3$C]s$Y>cD4$^Sn$['UfLQL[%-m4^+4O;-F%S$UC4CUr4%$2W@$JVgY&IL82'WqS3'ia/W$D(aQ&82.W$#RP3'KA`?#Hirv>t8L)3NH.Z$aVq<.S%=t$Y^[v$*rjNN3t4=$D&'a84rOGM-Dl(.1FJ?PK[3'OD@(PNdsJfLVD$_#]+V:mkThuYrMq%4@vp;8+Sl##_phv#a7ZV$1l$W$RfT>#[,>F%d3Af$W@iC$*Wkb+$-rk1o%[W.I$ND+#YJu.80#t$G,``3A$9Z-jghc)hsOA#3ZWI)EhZV-uo%&476>dRmE4,%U8c,.s[1gL=sJ*+*lFMB-7CBu$&Dk'j)%I)e0^N'8QXQ'wHSJ1$8,jL'G>(j.7w`O6G2NT**:BYoAB'FWd,R&B2`p.cjs&F7*SRj>'1*#LiwZ7oVCv#6%@s$Yv6W$Zr`MK+&###-Juu#Ep_V$.jqV?(16Z$N)I<qcks%=XL.##EGON;tu9f3+mVk'Nsv%+K-os$v<?JCRDc>%8ekD#BS7C#1m>x6'rsO'abLs-?D,c4:#K+*'+%6%A93JME_kD#7m.`G=D3j1mQwm%7U$iL^_(p.eQga&M.j_&%rXe)sIBb*lXIs.UL@W$h:ta*boR1([gPR&C7nS%k>Hj',1$g)'(w+8IKLQT'-j^ONVvA#lca$5=H#G*pk_W-u5hU%0Et6/.`JP'im(k'GgPL1w.No&noNe)]^,7&?Pb$9$U8%#tUB#$lBOQ/w8q'#pU&(#O15a3ZN31#bUkcM44Is$YKl>#-KM,#AeOW%4Dte)dKHH390jr7qK0rIG*^,3>^949_20pp-2`4J#JOI)-EKe$1Sbi(4c@7/foVK(:`QAMdQjW'Y&l?-BNYO-/cRXENuS2`:=1p7p%>gNCG;3*n_d;-$caj$Fb]f14-xA6*GcY#Ul%/L.`hV$RRnQK4r-W$Z?,##'9cu>wLF&#7kU)3%S*R0O6j`+ZEB6&E^Z`*sBuGMhxV@,x-,Q'CuX58ss19/wHeF4SSHUpEXAZ$vg'u$W)RW%f==`#g@GbbKF^P'g>G_+wtE=.::vA#/%3.3#q':%u#Ag2&=S=.3)I%-Ts$9%7ZY=.Ab@_uG,<.3^JGH3DVw8%e)5jL:B,gL<8@i.b/`$#[o/G0Kc/*#p)E_7pM:$^i@taeLI,+#/`Cv#T3[0#7(%<$P8S32[3<?#'D(v#@C2@&/[m?$A=:,D>C<T%b2coL_`;<%=5US%r2H:9.tek(buDt8HvD=8l7dG4EmNM2qjsd*xLbi(lCB9rdX4V/wi8b*];q8.ZK(E#GY;9.Vapi'o8Dm/4c7%-EHuD#]n'8JIqQk_=O<p%k8pw#P2E&+7[>>Y7N^b%7(GB$3V,lL'Zu=$HH(g(/g2QJ$3JJ2P#;Z#-/Gn(9:7<$Ho$s$e*(Z$4s1p%)?o>#(^RwBR0vB$hh5C+e'9ID-AGtR90LG)n6io.L65A#fx:xJPOZY#Xg/.$,qf;-%Dh(%TcQRVacir?o.RRV*CRP/G=&bE#+mS/.8fL1kF#m8;)if()?[s&ad+8LqV>A#muqB#JY(?#^[0VCaM$C#?7=,2Ao(ZuVhPs.[X#b*G`2O#fw9^#XBFm'Z_Sk'OVAE'dqbdVb/l9%,A'gL3H@E&N2G>#t8G>#,6ZtL?NeSD7VbA#l4S/1P7Yd3VA@r%:e=%$rlr*)r95n&/mT@kb7:8.#Aj4'$V-s$@-C6:Fet6'2?pl&m^&/1KqA@#QX/f(J3CgE%CqF*0eduS[EJs$Vchv-hm;hLA;(f)t'Ip.+,Bf3kkUH-fp'S%SmQ-FU/So[w4Eo&3O7wp]p=N(AC2/:MGCN(X<Qb*>XiX-98O0PocFgL[2$##b>hW-m1(*mn]YrH]#Ls-INE/M&[e4C(fis%PEf[#YD1S-^$vw(vJI&#tUB#$8ScZAsO4I)cT3F.i^du%eD&gL%sDZ#MGNq->mM9rLDYYuMtK4.U7=HV:F%f$Pp$b#AaR%#?hK]7U@&s$7]G>#uH,+#fb0dM6u?s$W`'##0JP##Tl#v#-MY>#O<cY#fQ']7PQF&#91Is$1)Rs$7pXV$BOaI+fb&U/M'<)+o4aX.375u%7oaD<],dw-9wA8%PEZd3S-Tv-DNgIX3(#d3WG[]4+/rv-G<7f3(fO1(8UT+*dpQc&dK)?Yr7]@#Dl..*2-i**p8.KYp4sS&ZBYV-@&UN(9[gF*0.d=MnR:V*Ws3F.R)KCO-XUX%v7bfLRYsx+91gr6r'FV?#_($2/SY>#lshh$^,)*#?_jp%Q+75&>h&6&MN,##,G>##>vxu#;%eS%K*xt'51RS%Kq$HD6>G##<4%W$ApL?#1Q;,#DPEPA0rL?#h_Os8g5a#$79H9MDUX5&MWKa9DSr]7@n=a,k9J@#vM<M<90$@71R=B6;79:/YDC_,?`tI)&pMS&?I@@#_Y5r$FI3T.=;-x6'GWx$CFs5/[<j?#vdHIMj3lj1LBQd3sJ))3REx(<B[uS/K^(`&@R$1,(tB:%_2qB#/_1E:uc0^#U(AT%j8;]-D,Xm1[`E+3`<:,)K0g6&>`C;$;Ng@#x=j2K7`1Z#i)5'&wK:Z%m2N2gK-kT%Gg5^X?(;Z#5n^+&+n`*.0'oO]m/nA#ur:T.soqO:o5aV6E_v,*hS%h(&XZg)Wm<t$;REp%ZpO;HZpP3'ReBh5n?kt$6(D$#FtDW6Fg1$#bd0'#3MuD'/B%?.$),##V<cY#Aut.#0W7nNoM+.#3lqV$/p-W$3^xu#@R&f+2^5(/cI@_Sfcr]7w4Bf3,xJx$.'[0)@9EO`$11f)*c5g)'=jE%LdV^>xqqb=-cV^#_AF`#$wH58#+Jl0IKvtLYaBM'%$:3'/L?_#;+5H3[M>6BaD/e*bR+p8&UPp8O?9q%BGg#5;-5>#Q-4&#*]eZ7K3P]#$Me60,MuY#H+Zh/[7$?#V4FcM$oK^#AC_cD)#2<-P*^m%YwuF#G=wW.@@$,*Iol##Kqs9%lrqB#wHuD#v.<9/[@i?#%cK+*Inn8%Iekj1#S/)*nxK$PODsFrFi=SCWhB]e-<CW-pqwQ&dZ>jYGBYQ#vNvQ&`EgMYD0>Q#hxnV$nker8Ehn0#Axtq]>$J,;>nun&W*5cuH?O=$*50d)(`F&#5J,>&)*w%+*N^f1QT_6&05>>#q^%##'/,##+(S-(aQA>#<FW.+=M7?$p(rB#r+#b[f]d8/k9OA#]D6C#Q1+=(0M0+*]t7Y-wp&nj@J,G4/p^I*]Bcp.m82O1P5rG56wEigjEmUZ6QkKDPX14;NAM^#i#3VA(ubZA$M*c%)gHmMYGF/Mgc0xtJwEF79Qe.PvML@-`dkc%`Zli'Be(58Tw88%_rU@G2'L^#[7$?#r&:T.3s*a$m=9j%9:Xc2s7<9/Iq2)+o8?7&;:7[#W)[)*q(U#&L@Fb3/WNe)jAqB#_]B.*gqT4.$=;s@omevnSOqkLA9QK`kcNb*/[V:Qim=]#tAE5gOCrZ#9u6o%Z>ed)$smh22f5D.Frk3+jH[#M=E0@#pj(P0Lrn%.=3lT%D9#n&FU,h2`%%..-r#_fxa64$g,5>#HF.%#x$#`#)AY>#.d,##s5,##[sfe$/=_#$,nRfL)_ZY#kA`h(JD<I)>I*4&;-uNb-A0+*%[wU7O6C0cX@.@#Zp<_(gnAo)2,BP8/.vGE3-XS%k+<E+$xGg3<C(d-tlsWUwEGwK4,to7FA_s-<A(<$1S1v#F-hh(d:K+*'%?C+XpCK(dleh(uJ:l0OK&o8CYvZ$+dfF40k'u$L()9.Hj#k2vUtA#E'h*%V4JC#Tpmh2iM#<-:i*R/?ZewHOsIL2SH)C&>h%1MkloRnD71JhpgI[$0ihV$Y($?#ZK*1#)*Yg.8G4.#iC2*/+PuY#J5`'Svr10)d^0:%;8TCOJDkM(^FLmA`5:m9Q:h3O.xo59ON)K2-(1^#7eKg-]Lo3X/>EnM?T?M9KwcER9pKFRcIG#53Mq-#/Mc##Z<[0#o-U)N5L82'4Y>##$k,X2?4%s$Hh-dD0+no%OqHdDMY.;qh^s?#>^p&=aHW`+F+Vo(A#>#-Ks0;.(JXI)@puM04xQS%B'Xt$Bq1DNeqlP9+$F]%@p];QdXBMB2T%hlA1*tA9rpuZnq/pf)oUkLSePHMRsm-3eRJR9QXip$P-WH'k#@g2wh(vH/%OT%S)###N6soR<KHD*6lju5b8%7&+>G>#s8P>#Y%_>#Y=OcM.>G##W`'##ZE31#@OnT+_1=+38o+,)@BsbNn[UB#67f5'PjNu-/aI-&wxPu-CNFr$.=LBu:P4n&QQV)+6L_fCJBtR/i&)C'^]8KqMacof#4f`Xr+TV-R3n0#.W.h%hvp;8/(N;$X)uL7.`:Z#U9[0#74Is$^voE%3+@s$U'I0#.cUv#?Y4.#dJ(b%&0MfLjB/l)?SEF3Vq,Y%5Z8e*[ZqY-`QM1FgY8f3jEW@,8]Le$xcEa*jd+[%[K'9%3I.l'v3%i&)Y?aj^^W**,),##9a64$085##<x5U7FQfBd%u9>,Ih.s$6LDs-i.<9/.u587sO,G4SS.K:0[7x,ZSID*MFn8%qnm?=<HX)+SxLY7+lT'+s<@A,@;kT'S-g8%;0ls8`LxN:X'joKx+O&-=31q%Rw.jMsOF-6ick61FJ:?@v>cg$m9@M9:jH;9w@i'#9MDp.8x-s$c_ZM3['3?#7%%W$w5s9)YB;,#;GNPA-`:Z#O0n51L*Z&#'S:x1VUVm(VHYW8MW3e3GM^J34_?u%WUv??+HQZ$a(0l'(xU5/:q'E#u,i#?=,=v6MI@Q%nYY4SV&M?#=Bk;$*xCT.9W;_$.Vo4.e8R0(Q_,kc$9Rs$G2wo%1L[m/5c:;$6)L(a4D6X$))H&#?i8*#B$2*#74@W$X<[0#<=e8%SSB>#*Jc>#BD5?#/]Lv#@V4.#/Yqr$3)Rs$eKJb%u?L%.TeMd4u]_Z-`WNh)r>-r%Y1:P%aHf<-h+iE%;5^+4K.k_=hLIF4b2UM'ih^F*.G>c49@&s$0JWfLn2loR$NGX-#888:,aXa(V8*?5gKh&+oqDm/$bapNo&e)*A%5)4@qrF4`07<o8ecgLc&6O0v@xL(s&HF%[@h'+0IN9%BeQQ8Z)iX8[QX9%K>,^,:uJfL4C:p72dD^4,dZ(#j<M,#vUiY&/`C;$Y(8/L8REp%dIf/L'5>>#A=UcD,]UV$GX$dD41RS%H$@dD'AlY#aWh*%e0R?&(;YY#M,h.*26IP;t.ZG4h%?K3$,r?-AwD-*1Z)o&H%m3)T8aR'ZEnb4ecmr(X0-70/[m*=5Fn.=j4*c%uf9*8<'x],Y7<?-3%X3M>#$uu;87[GnJ$HFrXZ##):>H&Voeu>M@H]Fs#<T'*G(v#O_sp%0/C@#jT0[[>AH`g/'*p'@6#n&V71/#0.wS%J']X'57no%Pkh,DTv)E*G-F9%Si65&=ha5&Lrml&bB4x#OHG3'=Z:Z#t`2v8ZIo`=0P9$$i6N@#Z@bcM*Y:T&sNsp``-N[?o9QqCmRCO;H`,##w]>hFcnYSCR'vWB&eo'?s2>G>o?W.=_Lqk;(GQc4mg&&,trG<-xM[R*,&'f)-]NT/%=j?#nBN%&wi(u$$d(T/GN><.p&PA#wHuD#vW=Z-UQX$0f?uD#%c5r@_J>H31Pr_,ZfbQ`@Lg_466(V%7+p-2dteP'#U`d*ml.1(71Is$=^Vj0Hq*T%KKt]#pmju-T3b9%Idhg(Gxc>#Hpqg(10;X9ZqJ-+@ZMo&HH>n&Zh,v%,T;11=95N'Mb&Q&lra**I-ZZ%fo6s$;]uY#9UWp%T9^Q&P,VO'D4Mv#8(7s$54wS%F1`^SK#CV.N`fE*`wWT%-@v03O^>n&Rhpdk^SH$$g/b9#o,_'#4cnZ7n;,##]/GF%+MuY#[dqV$[7ZV$eGcb%*>G>#_wi*%U;EPA+:iT.D>@[-oaC=%r+@p.bfou,BwQJ=6KihLgm3AF8;tn0Fn'02;1TV6#@n=7A]DD3NHIf&:_x5/m4>[,jahgLTVnc&u`iEMkD?3'vrh$'=N%I)*fte)4Y5W-@2wq)ev.%'kf.4'Qd$IMjP,VHB<`hL*-a^%V,'8[m&Yc2]tBg<W.e8%;25##v,=;$_Q31#dI4gL=?8W$]dUv#pSsq-Fu&tqI/5##,j9;Cdh-##*uS60N6j`+cp>n&JdZ`*<4e;-S&TW*BLEW-v>x$n/?oD(TW['(eo++l0KM+=f%lA#eF&G(uZ-'#$<lY>HY(kk<far?u2l?#$F@G;x60T%W7wS%^7]/L27es$^%J/L34eS%TwH0#6%MZ#^4??#0]1?#6FUq:CvkF+8J9J3x=wW.b+%H+Zxte)*QsA+1,VvP<Gw;@M:5H3a9uD#9C#<%:39Z-b(Cs6s<RF4M&D^#OV;k^6K0V.UlY9.-8u]<qN1oe(D5jL7S6MTDunE+6VFi(`]8C+*_.>M5,coR0vNq2,dJH<V&t:.IG+G*AXP]ur>ULMG]Y8.?Cu'+RRxpKGQMM%5vP`<)_08@KMu;-8MDU%?$Kb<w$FS('5>##j&)v#WN31#JwN9%O]ur$FC@s$A*,##6lC;$Kc&q%:Q;,#C[W9%Ncx-#@'>N'[p^R)NBlj'KU*X$Mfx-#1chV$1p-W$1T]Y#?O&f+`BRhL5(r=S_b4t$sH7h@kNh(Q]w'q%=oG$^d=bs-K=e,4TG8q9H`,##oWJ+>aF-h<X_?1<RlXn:8-hv79>?f*@_5=-VOoO*v+^F*;Oo%*gkjU%a@i?#d.<9/dR7U.iT&],1j+%&a/G:.W-=S(wsj>#5VZDg5`Wg(%/N0(C%j>$a.=i(6(.W$K=iv#uT>.qHCF#7@Mj^6V]O@tBqsT%iK@((o5GT%)V^b*BbNp%d7P?,G:M?#7JP]Sfd[u6?'23#$&>uu$.Cf#gZI%##qw##XJvS)`t60umPo>,-@?m8CGd&4]Bjv6UHL,3KcCZ#LD-K)Pta**&&R)*7hc?(Ho:?#M1v5p>Js>5Vo,3^c'af:'xB+*77HqT0BPjb3GL:@Z/G4K=+7W]A'?3+7elZ(eqM?u61.iLOf-c],X/s;19G4K0I[C#4mkF`v&xY#%Ntr$g=mD#q8P-X%:L+**j:9/QKW9^#md[$#`<9/SP,G4QnLENaH]s$q)YA#8hm;%66Rh,(Kn8/Y)BkLP;po45rdY#Ke^79)Elx#`+g#,UI2?#pk$T.[T^Q&6]PA%@@ns$FtjP&E<k=$_X-X-#*c5&LN0:%Q-0:%8o6s$FLY/CD$'w#iiIl'N1BO1Ct3x#?G9]tt7^K<[=lg(iTjU.OG[N'gs(N;LT:c58LB2'BfdW.R7[8%r$=p%jaBu.XU<9%A2=**`leH)vMqU%>E4P9C0:<.GW97/xObQ1iI^H).;G##7B&&$+e,3#Kww%#72<)#c:.7([^p%4/](Z#Xc:p$NGuu#LdGM9-ck,2H0sxF1%.W$-N=;$Au#_%4lh;$/;/129Tj$6;b5R0F[d(+Ve[s$<esl&t>(l0:P&('D#)u$b]e`*U$BT.R^<c4:O:k$?cK+*:2Cv-Z6Nv6C4NT/FEw<(702*0OAZT8^L'q/R#aR0Hs+>-SQOh#[w2v#WRUs-D)#teC1<v-oW[&,gp/;.-/or&bqDQ/Rl<w$;-AG;B-nP;Y51I$E0@*X@Z&,*:3L5:C_8[uNNCZ-dS$W.hFoQ0DRmg)WOvv,QW4u-&5>##9a64$'-5>#/pm(#js2_7=N,##TE31#AFwS%4w,tL[n2v#:M4.#LIu+Db+E%$/iLv#FoQP&=8rv>.iqr$cC+gLl:fT&;,:8%[MJ71Cf:J:mfB/38*r41cB8&,(DXI)^^5n&9SP##0GkQ']BTj9%tfG3$Z6Z>+[9N(TF;8.vnR<-]YjV&/;:8._x;9/dJjA53%Z(+AfjfLI4/GVnHb5/Vr+F+$=R1Mn7sj$U4nD,rZ>j)Gx?8%GnU7[OR%[#O1SN1KHp30eEk.+27Lb*mTKe$dQf`?P,Ux=7>B/3NtJ,2Y&U+*2($c*nJ.l'>P###OS.T%SdxY#kp=G27)4GDNu.Q:DP(Z#?=c%$wBIG;+S(Z#`dC;$MF]20*;>>#S<G>#Bbl]RuV0)?T1t#ANtUPDZGsT9R/tI3s>(l0T.<9/&,]]4Uw3?IriHj'vils.QGpF4w4NT/Jj:9/rO&:)03u]#+WhM';f)T/G*hk$6x?)4-`aj0Yk[s$lLbI)v:.$$j/Sx%#EjF4t<7f3owi>#8C3p%b(XI)2QDO'B[<9%/Obe%U=q+$1([8%'X)h),aUU%6(7W$)@-]%8KJ6BT:SD6kVH7&t,^],,OnF>kr*P2qe#)4A(i[,N2Ee)7uWx'qdI-D[n@='b8-r%`su3'@:Rs$?UW5&GYR8@=O*9%R5sA+joR-)KU/m&?oLv#t:qO1ZG>>u5gP`4G%i[,.RaU8lP:->9d0[BLvaQ;jSB+4AoO^#E#?3^G/R^,CGAe)*U&,2&&>uu]7N`#Sme%#)^Q(#R^jY&6E,]#4BGO-I)Jn$:D,G4*Afv>`_)[$dPQ_#.Fk]#6pg*%-lR_#QSJI&4#B32.b&m(ftTB-3FaQ/&1`a>+<as/aea9%G)S51xA^e$i*^%'Z;o4]L,&6:r6ve)&eY<8HE(C6(#39/mVu%Z%^)k'&%O=.ALp,3VRggLYaVV$0kF6/`9F&#:`Cf:7k<^,,'X)<Q'8.*E_&E52Auu#a[Z?#Z@bcM`klx5Qg4ZG0o_;$D)B>#<C<T%K$JX':lU;$-T1v>4em?$2W]Y#?U/f+rYKjLNN-AQ@U=T%:+D+8WIKVS9:AW$o+F$LS7t]7VTfA,f$8@#45CZ-TaoA,G9A&,47?c*_P-+<;84m'#]bI2BKwb4sRoU/R;?<.D:j=.(vIZ(j'1%.>HA9.h?@0)c=->:-,%9.3YgSS/G%&6RB(##%&>uu'w@1$DF.%#gQSW7H),##WuT>#m=tD3ZN31#'TpS2#YsT/RQ]A,v/Cu$RR<b4H4p_4%[*G4KkRP/8#.I%_Y*3;GDB.*QtC.3)_Aj0s0LtSF`Uv-*LC.F[H_RV<ki%,)j*30'N@H`t-oH`(,)c%YROFPm;:[-c+,G.HkG&#rCbA#@=2-aMR*UAeI1=#K<5)M9%Ixk2;n3N8R=RM7A6)M#7$##fZ?T-[Rau.82'DE-D2:2wRbA#Jn^.$M?$:)*2a$#iE*>-ZUro%>Vtx=#WpS%emN`jaV()aq*9s?P@MAk<_EmS.E-ZccNwGiQ[fN'(C7<Q>xXZYq5=*Exu*0q,1wBF0'1bakTr0C)<&1Cc8_O0*u$CtP4^bWf6=o/k8pn]u2+uZBuBoA:cvO^R/6VR34#8JHN0>Qj6O8/X45j(QCb8&4cciqE,,E+&HVj1lFmPgV/QvQKpNK)_YNWIdbJWRDuhpf6BR9J^#B'YBF7@6OQNRK0)B.3tlB(5Fk3:fo5`ejJ[AlC=X.rogOc@mhHh4_9Q0GXlBmrSJ8o(lh4.sAN,S/<KJ`),TU[Sp$x*TBAB8#nWUBs]/>js8@Y>gaf#]g<EY[/scTBNMD[jN)=:u#R+d?$7Sb$U0cPAn:?(l*#ck3hW)lu<So541<g)3It1FNu&Qjp7(6UB+Y7cP7_hOJc5D)'V^99KP2M&w1NtFa]@kRmV0J/ku]ZN?2Nr@&^@_^2^7.ixPMF$dj*x%[W'/iGQDjr.'@F7bWKx=WQV[7@6`$&###(E,VmfG,F%M5YY#@01JL>AH_&C=Fn&0]Wh#62h@k[dM_&TM1I$7)-T.3(V$#p3xU.,Mc##orG<-5X`=-vrG<-*fG<-3A`T.3f1$#>sG<-8X`=-MA`T.X&U'#cxWN0A@%%#*7>##_RFgLm`>.#EB`T.C6OA#Y@`T.4+i?#trG<-5X`=-,sG<-*fG<-NA`T.?[[@#isG<-8X`=--B`T./3MG#ch&w5Vp^^#d+U.G5E+7DHX5p/7%C,3.f[@-9?m`F:/[p.t5kjE9$OGH64o+H`@viC0jXVCDSRr1vSO7D)BoUC7M#hFX4$7*ivZ6D.gcdGd;X]'&;1eG38vLF(*7L2:9rm9$/2eGnm`9Cl]O$HRMB@H/`wiC='oF-=n=82@hViFvoUEHM3FGH,C%12p^`(#+mk.#cSq/#TH4.#HB+.#c:F&#XLM=-Q.r5/0E-(#aDpkL1lrpL]2oiLsA-9/Pgb.#tGwqLi(B-#mKL@-Ilr=-H)m<-_5T;-9sY<-IMM=-L@f>-?#)t-7g$qL8X+rL>rkRM_Fg-#>G<RMG_4rLXS_w-^s6qL]3urLZfipL7K#.#Oa$O,fw2X:+7auGCRl`F/E)?--W^f1>T+U3@-1R3n(]k48D-X_$s&:r/U]rH:sF,3QJX>Hw%Wq)uIwWUxLh%Fk$cP91#s>-31ck+xKRw9X^p921[2GDr=T&G7&$,2T*:K*[1$##gIDW-nPp2#QOkS#*AY>#.Ml>#2Y(?#6f:?#:rL?#>(`?#B4r?#F@.@#JL@@#NXR@#Ree@#Vqw@#Z'4A#_3FA#c?XA#gKkA#kW'B#od9B#spKB#w&_B#%3qB#)?-C#-K?C#1WQC#5ddC#9pvC#=&3D#A2ED#E>WD#IJjD#MV&E#Qc8E#UoJE#Y%^E#^1pE#b=,F#fI>F#jUPF#nbcF#rnuF#v$2G#$1DG#(=VG#,IiG#0U%H#4b7H#8nIH#<$]H#@0oH#D<+I#HH=I#LTOI#PabI#TmtI#X#1J#]/CJ#a;UJ#eGhJ#iS$K#m`6K#qlHK#uxZK##/nK#';*L#+G<L#/SNL#3`aL#7lsL#;x/M#?.BM#C:TM#GFgM#KR#N#O_5N#SkGN#WwYN#[-mN#`9)O#dE;O#hQMO#l^`O#pjrO#tv.P#x,AP#&9SP#*EfP#.QxP#2^4Q#6jFQ#:vXQ#>,lQ#B8(R#FD:R#JPLR#N]_R#RiqR#Vu-S#Z+@S#_7RS#cCeS#[9l/CnjDXBv,+;C2*8+H2pIuB/^pKF6[+jF:R_@'8lX>B(`b8I$v9oD$obsHwpMXB,S7FH>9iC&>-5bFlL4sHqJ5hF.F2eGq$Q<B+jE<B9YcQDp]_G$0Pw#JOuG[H#`%MF(CAiF8Pr.G4ieFH6Vp;%AbC['6&0eG1W=gGkp.:C.xbVC9>ZhF8VT=B<LFnB$N'kEh%CVC*DM*H#7SiF(BXVC3g@qC5*i_&7D+7DxU/vG.v+x$%QcdGg1/vGdj9_%:+FGHKI-$H%SXnD1^(U1.E9,.0w67M99X+N@V1cH1s>LFP:/>-Q?/>-;$Fn/qRA>B6*q(IR)P<3qI/>B&So;H8N1U1pc.>'TVP2ORmlgL-RY:C*RUt161<]&O5kYHD,D9.$?fUCWi'?HAQ?DIpQ.XLX;$LD>F0@J,EA>B?J#V)0e<W-3FK+@@a4/GpE;9CjNkr.38vLFwQC>(H;_#G[Hk8KoS9#G$HxUC>rA,MVZnoD_/d@&Jj7aFtYVx&Bw9nB-gOVCdl0VC<VvLF;9i`F$Ol*%-&+nD:7]'/'kj-$NWjdG+avw&J[Z$8bnG,*t%-P1vcXVC/)DEH^>o=BrDo=B(NZw&u?(O=-;'oDj8R53v=2i2i:kjE,&YVC.?4,H6BrEF%d;X'0Up9;'[%iF#iq=%-m9oD*Z-)%w#xmDhM?&F9C4,H+]c8.370@Jpf7gDBpwRM*;4&Fu%*a%DssSM,?4&Fju@u'#<bNEIX[J&4e;s%M3eM1.%l'&:fpoDIvR'GmS1HD(OhQMi:#gL@u1GHs*Z1F3=R0F0,7H$:dgJ)N7)68HN?4(8=ofGwo(*H=%vhF/HX7DUgGh1@=ngF>PZ1F7M^kE1I1qL2BhW.RTgiFf#b_4a`V=Bjl6eD1(0`IAURfGF$c3C1M8Y'VDtYH6H[['?J/>BP65bH:)h&O3XlGM1mJ*HhC4VC_DXUC*ij-$2Wi=BoS?aEpPK0Fr48u':9e7MOtwgF@ROGHnr-aE+P2eGmMbUCg.*bE&>.FHu2jXBl0W2(L/r?^;P3=(boK9iJ<ngF%;RaE=U3E>)L>gL@ZfU1jJ_G$3$AT&61=GH3`q;-41D9.pVKSDVSX#H3,ddGSqtv-Xm'q7UGb05)m%=B+,2eG_ue:Cc4idGn=4V(%/$PERDkM10XKg1hquhFk#Y,D-fw+H8)u)NDClG-SZI+NMXwaNcw]N-9XIq.@S4VCHbxB/BlhU1^mo(%v&<,DnJ?)%u2J:Ch2TjBw&8YBv,+;CaR>LF[(9kEfDbQD6%WiFOd5/G[PM=B_MBnD:jKENDs[oDk5C,$UK9C%n)fQDsD$@&T2H5BE<f;-?X(.&Sp8eGDN;eEpYVt'Ra;dEtOO;(8t>U;E+k=(VIp^$@Ku=8`Oek=hO,l=u7LU)#vbt(.Y`n<lBrR3LbPr)_;tS&DHoP'K2b>H_'X0M(O8?M.+3i-99M4=^7_t(voxV%7n%[HlsD<B,T1U16vTSDRj4<-@QTO0k[^oD_qP<BE09m8L-+QBumsjEI:l>5f[B8DQdYWB*AiEHaijjEh9Z<B;rhjE3-7%'vMM<Bus.>Bh%KKFx1M*H%*bNE_P(T.^IcdGx4T;-Q=cD3kmfjB.DqoDc$Q<Bp/5kB9GeV1?D`5B;(&`O<^=w&P0i4+$*t;-AX;=-Gd1*3<+SFH$?fUC^S@UCsS'oDJ8lHMw.aF&Vp*=(trTd4w)*hF_=J_/O$WiF;ucUCX*=kL)gr.MQ?n683oQh,/(vgF#T,-GlsojB,EA>BU*=kLDW3[&ng`9COh1*3f_CEHgP(*HVsnTC*&Z0CUdj[8=PvV%c^t5/'_nFH75/R9d54m'Z#m^?iZ)0C[NjW9>E0j(IV7$@ZVVe23F%eG*?fUCv%6kE(iefGgG*XU'.Q0FT<W[8kvnP'k:W&didMKCA%a#&;F.eG(Z-)%(Ks=Bdj+KC=A2eGnS%Y'sSg0F+Sv]%&rBnDqbsO9O6?v$:wDW%vMFVC=0EW%X62VCUgGW-Y,V9C7rw+H<+;iFh`gjE<P%V1q2JuBbMgjElP;]&v8@1>/eDlE.=SK3r]$i$K/>>#2[oi'C[5f$S[j5#vTg5#pHf^?ht^6_#2S4;2ZR%@&g6c+aq-vA4rkL>S=*p.F.s##GM.tB:oHY-N]IV?:K=?.qFD>#_0>?8.w4/1fdfpC/'>/1V/:Z-0-G/1_O+3$9c'58n^JR8F3??8.WMR8?5w#$]LZP8l2UV[2;Hb%Vk99CKQh[I1IlY#l_xV[<(RY-?>j8]4i058AD)C&afi;]x0LhL;UnV[1eXSCFwb@#'5lN1`siW[m3Mv)]0FkFPpfR8KU7v68VoE-@/c[[ZTC>]G(dQ8m'PZ[=1t`-U2?Z?V7ooL6qpCOG)=s<-ieq.MJ->-C6n'&2ap`?RIWX1*[6p/KNI@'F]+Z2.HZV[.G+k1WKXD-jPcOO`ZwG&Y_bpLx;4/MAbl,M[kQ1MMnDrAQ.r`?JXGm#H3aQ84t5A=x3x+;j?uY-Ho@a+l8'/M-G./;M[f$#Ihl-2DoV##G(G8C:a.Q#$1_A.]m+Z?O^r^fe@H^?29Y/1YBSV[0uipLp8.Q8.>'K%AYAg%pcGY-sumX.h^`/%Poq10+D>2C+4N?8gNi.M(2=fM=9@m/$.8<9g'#N0]EOV.1<tI-).?.5/#Ap.OHo)=Gs2f+3QUD?prsY?2SBd=<7+;.PE4g77ZoN1c&jW[M;C9]M';#n(L>gL&Ph88mTg5#EmM^[I@'_[9(/Q#f35N06Q(01EqXG/;o99_b`qpLDUS/.KU=5Ma1tv8#2(O1hAJ9](VBP8Ki%[-r'EW-:m$6:7*`dMbkji0c$vhL&xJE-xZa5B#KTV[cRt`-JU#V[N9m`-0Q2nW&//W[%)^5Bp&aE-&44^-Z,g34En'7jh]#Q'u='0/E?;$#S@,XCcs9Z-JVoM1lG/t[sVLZ[Z%ZQ1=L0kLO.Y>-q.dm:'$VC?JR#<.*=rA(&HSD=8HO2(WZwM1ZIk<::D76Mh),2_cf$qLga;W[MRKE-4@TV[hW5?.?2%11xvmx[)g]^?km[KCG+wW[TIl-=JY<lM?TFY-E,L/)e3gM)i2if(q#nx[;&;Z[#e4Z[jKY][o%Im#KI_&(0-O2()BvV[(Zt>-BhDe<.A2##&;+N$JbdOOa_hD.LP_;.oYs_&XZ*.-SKD^#2]:#M<5voL,v&nLXJ4tAorfAZx*RV[C/eU%l:)##N`DZ[nih5#lLM>#`0>?8BD@11,L`Y#qmQ][f<9B-Jta9.FnW9.wh;?8to5t*MkFJ(#]'58=;B%B5H[hL$x'2BrlSj0Pl8b+'#vW[rg`i/ABtW[o26Q#>;Dd*1=(,M=]`11c.5F%>h/t[*lu8.wVMj$B`[&,5UL,MAu.21g:5F%Bt/t[.lu8.)&f,&RBRm0C1RV[mb8g10w06;ixv>-a1ko@X;xiLgo`EOS,bbNV6LoMmtiEOd7HdNW<UoM[7J21dlCk0x?uV[l?evMZc%vOr:xiLq4oiLs@+jLXR#<-,:XCMFJ=jLXR#<-.:XCMHVOjLXR#<-0:XCMJcbjLXR#<-2:XCMLotjLkJc)3/3S>6cWUT1O3r?-W-8oA,Y5jLI];Z[.uipL>4K#2L$tW[`xf>2X$LR0_B?41vQgB-pumR/X,2>.&73D?w[Sa+&#vW[+&CP%spKt$]p-Q#E0_R0EMhc)JuP[?Xg*I-+UOa,aPu;..I?)4bID)4k]mw9H;E</^d,Q#v0PT)6=c&#r9l+Mxd&$7e$Ms3Srr^otFr?-7obhRA-D^[U17-5egv41'kdP1+`C_0;FQP8?aNX%np0t[aK/r..G)m99Mf88DI6N:MYg?.eMSE-poHY-Q%@8.QCBD#xVPO0h#<51E7KU[],UW.V2)N$x@+02#I'58M`mp0em-=.*$GGOTK9#6n*c>-x>hW.sBn8.XQXw6ONjj<7C4g7/5FN$.=%a+[CZZ$qi-<8wYwG&>^3uLw[W'/HsD^[_R[#[,JJE-FOqQ9G$E@$N3nB.(6*9B6bQ][<+xg+5.JpAUC3p.hBB5BouIW[b7)Q9PW(;.n.fP9l%o*%gs-R<%2;nN?gc<.Or)pA<$qV[1uipL8mToLpPSE-+]a/MM/gfLh7b$%?a0Z?)C4v7%90?-o,Dj$Fa,t$5G:)5rvtfNqcwG&*jf--KLEm9Voa;.Br.>-BjWZ%tvMjDWpg5#te/@-jH/a+13.^#>j[0>o(ds-,YEjL%ud6:EgH)cJ_AW(_eMs7q:^;.6VdL-AwnI-`./+/u7%N-mDKuqtGYp.(Hu>-.iCqDgB/W**Z2f+GfXD-C2Dt[>$lk0$^Z)P%nBf+=FA>-A?4GNt]*(Q=^361*R&nT2-=61pfWEOP&QY[oP(HOD>@t.Klim1)+R6WUH;tqwF)W[^ePvI_gL^[,q+<8O9dV[b-[3F':,j1+OZ$grA1t[Cdx88E7KU[tv6s.0%+@-eh^(:u<*p.+)D3k6QW&5JjX>-ibDW-w?UkXnD1t[uw?t7o0C2:g4R#6)QKs7?G]'f=J?T.I$h5#x<nq$YFD>#a14.)cN6S07Ch<S/D'71?5LG)KqDlL7;071@nh*%=C<[0vBP?.->dP9t#+$8+rx-<-[<9.98#r0'MP71rH>M9t&sc<$]bA##BS)=2C:GM)a5oL6:)=-4u@Y-fF(F.x$Jb%%0Pb%5v3O+/#l]>CHNX(+2iT]g+BP8BoL>?%`bA#-8-Z?4OUcM3;)pL:I;=-@:xu-?RVmLIG;pL'45GM,MDpLNI;=-=AGdM8YVpLIM$29Lh&pA$]bA#0l@5BPqQX(0OJb%<CxlB6:P&#1Lx>-2T,<-%V,<-TIrIM=.AqL6:)=-rdBK-.R+?-+9t;M:R=RMh^5<--9t;M<_ORMh^5<-/9t;M>kbRMh^5<-19t;MAgo:1R0.v7'I.&G1KZV[eZ;E-Dj><-k.VT.s$h5#YjXZ-Ps&@'Du2t[f0`KMaHhoMINx>-o'S/MWNx>-#9[A-_6?D-[VPHMsa6pMgNEmL4h?pMT;1@-2&kB-Xq#D-]>p,Mf#[pMF<]>-o'l?-Yh^C-cVPHMB6wpMT;1@-Sj><-cBmD-+'@A-V_^C-d>p,MmMEqMF<]>-v'l?-Zh^C-jVPHMIaaqMgNEmL?gjqMT;1@-2'@A-W_^C-k>p,Mtx/rM.d$W%YqN9]wO>29-5b/%Lh.Z#<CTA./bqY?E'cW[D@f2$WlKv9V<9O1'][6#Hrmx[cNPf?k0Dnqs+F%]t]Lv[()pgM6^a#P^Ad6#^e9HMG?#-257>##=cDg.VndC?J7VI?=XX2Cpx,0Mk(4h%3eRq.1S.g+<Tbt(:bc/Li+kS7=J+PM]_i=-47u%4cJoN0c3X(NmpL(]sf?W]=v]##V:;AtH,Aq-", 
			cantarellBold = "7])#######)*bH;'/###[H7+>)322'Ql#v#RxMT9hKp%W:6)##87)###JiT9r1)%S;bE>#Xk$##v5:t8qjjcDOA'##?2dw'%;,h<C?aXq>q+##kw(##Wf+e=L,Y?qx*dw'ZWe--#/ue=E<4xF?r)##K'^w'7vA0FZ/'kcn7*##k5+##GtBUC#BOdM)QOk+P=r-$f'TqL'&d;HtRr92>M[w'E3n0F^ENi`SICwKHk%##Pr[=BNnI87'fX&#SJf--w:]=Bemd^0Y<q92E](##Q1CiF<BxCNB5hQavTi--g7?>#/VNh#4xn.p.ge<6'..w#Blx&#`eotOm1MIMF=/cVoke2'm+Zw0PMYY#.hAG2'>uu#nNK:#lq8auWWf]$1'9kMh@$##f6%##(V<j0vEec;<3]V$Ze5AO$]X&#<,LF%0op:#`%eS%/rQS%^U/V/q3PuuE4hEo:h$(#=mgv7B:F&#ED1Z#srC*Mc>8S#i.$##+SO;.h3`l]8=P&#4.;t-ZkwfNLi_U#<B`T./lUZ#*0)t-V(ofLB#TfL::^?.[/-j'>h-?$3W,#>3LHZ$dX+,M0=?v$9mmr[3X;s%Z45Dk9-AT&0YW>5:6]p&j$lcM;?x5'mVMMp<H=Q'i;[PfLf;L)1]YYu'5>>#0>###2,IwK.(1B#wJFSR<UL^#5<w4]1:h#$3<g%b2C-?$#sQA43LHZ$RepiB0=?v$q]<;R3X;s%<%Zca9-AT&_ur1p:6]p&UXbPA;?x5'kBslS<H=Q'LLI2T]qxM)&n95o+/G]FcgXoIT1PcDH]4GDcM8;-YqTiB+D-F%Rm>G2WMhA5)p4L#Vrd'&YJ7A4>36R*A=@_/2O/F%A[u1BE;Qq2e+Be6m%L`E@x&?-/`?VH?qTJD<[6^GK.75&W*?X1:*G_&VR?M9I^MDFZkk>-W*f'&5ef'&)=Z'8:si+M5If>-cFII-8)m<-fQqw-pm-qLI4urL6#/qLIwXrLIQ-5Nh0n+#;1SnL$NpnL:*8qLGWdD-lIe2Mw6;PMw'crLNwtRMM`7(#-Us-$-o^%O7juG-g&l?-CbDE-$^mL-QMYdM]mrpL$SxqLxT`/#(TC5BE9Q@0#8ujtT.Pk+a:p^f?_n-$>N_w'_j;MB`]iQj+O;_8K.R9`HHO-Z-pl%=/mC5BWV6^5rw4R*C9g'&G-QY5+v4L#vSWiBT1PcDlE`>Hn2iKY@5scE<<i`FBt9/D6pjG<=;tjtYBDP8DX=gG&>.FHMeZ<0+9IL2>*e-3<6i41f&@UCVpIKF&6FVC^x2s7:8QhFsl<6&h=r*HhxtLF%g9fFM>4sLX2oiL8H%oD#SI+H-6eYH#g1eGvRb-631(O;iG3VCd6u?-BdiM1+sDSC7;ZhFgLqk1T+IU;Yg>[947V.G'fC90rxuhFH-B5B8tDU)2?ijE2MD5B&?^kEdjeUCCt7FH-ESE-rGnC-=;G;&:4//G/3`$H(Av-GWPX$HAm@bF&B8I<a_%##C^'=-Pk,-0f[&*#TZO.#3^GW-1SNe$#Cl>-<9i5U+xZiMFi7(#43h'#/v^L&TAe>-B2K<&qR(UDeVpg2D?@P1BpJF4CC^>-#-,.Zu?l051#'58[,'K2*Og+M%c@(#Mi)M-p?dA%-'7L2.rn@-a=hM1`=hM1o+]p8Pt[rHNn[f$)iH]FpB7L#E&w9)'Ns.Ct*39BcuiS8A:x+H7$7rLgO,.#R/(t-(H<RMZPr'#&T3rLnX+rL:2CkL?wXrLn@dt7gPc/amE;/#ooao7.t@eEA5Mq1+>Z1FCT5fG=h8OtlxtLF`C/C/O`V5BMx$[T_'ufD?gURE(Z$6B%uEGHwww<:x1TpTwJ?&4blRB$ujFD'>^cp8'<H&#tUB#$>A@&,Pee8.qk$v#Fle&,Ur./LVMsYl+*[0#0Ni,#x(eK#GLpM#xV+Q#BZ2W#r=lu#bKt]#62N`#HBno#abCv#Heww#Y?kx#v86$$3p2%$K=FE$YldG$ZQiK$%^OM$APhN$T=wO$VrFU$]LpY,:T+^,Z;1_,9FBb,p8/e,T[eh,5t^j,O*gU-+[r<-=Bx=-Nsk>-er?@-(YEA-:@KB-[_SM-1%`k-E)1Z-erH[-Rv(s-'nIt-9<+u-Js'v-tXWx-fV+'.(8V8.hxd<.__Qs.*x$-/2:I-/>_*./FwN./`pp//uktY/HZh]tTle+Mb:H&#T4KM#WKDO#D%7S#R/sW#:$4]#I2gKMEUfo#WIuu#_EdL/s,$$$[;TkL;l?(#UkiYGR;>5Swv_YY;cPM^Q6b`a3TTYl@-t]#2[e],XlVP0+jXV7f`su?JI(2L2hW3k[sK&#gHoj(B*A&,qpS3k(*WA5Eo)5k8$k3k`6A3kp)54k%@b#$/PrudqtbAk$sFuuZ$H7v@W=2vxWi0v=AE-vjAq+vCCr(vqCG'v0=X]u'X`ku'/wguoY6gu]gteuOHFeue;0UuV_5NutmtIuQH=Iu?nIHu7U%HuwI>FuKOrBmpYFAmKN`?m7O5>moCN<mW`?vl*-+9mlK.8m[k(rlPXcqlJFGqlD.#ql.Gsol&/Noli;6nl@Y_bl-C=Xle3MVlGkDKl[i??lG2C>l>aOxk*e7<lNlA9lb#U6lTB+xk6hUfkYV02ktKt1kn3O1kh'=1k^LI0kxn^IjJ6nVi8@,2;'iF&#S,a2.d[k,Ml9-##cfq#5&/5##*;G##.GY##2Sl##6`($#:l:$#>xL$#B.`$#F:r$#JF.%#NR@%#R_R%#Vke%#Zww%#_-4&#c9F&#gEX&#kQk&#o^''#sj9'#wvK'#%-_'#)9q'#-E-(#1Q?(#5^Q(#9jd(#=vv(#A,3)#E8E)#IDW)#MPj)#Q]&*#Ui8*#YuJ*#^+^*#b7p*#fC,+#jO>+#n[P+#rhc+#vtu+#$+2,#(7D,#,CV,#0Oi,#4[%-#-$###-G31#4`W1#KX#3#bE24#gK;4#lQD4#qji4#vpr4#$-85#(3A5#,E]5#3^+6#5d46#:j=6#B,c6#HP_n#8ut.#>$S-#3kf=#99v3#Sd0+$N4C/#X==&#E*20$^=$,$hHO&#VVH,$Rw<x#->M0$TM=.#N1ba%:Ec._Yfw1BWgZA+2bqY,P'.DEH5XxtYvl.L<HSoRJa1,)`31Jql&*DsfW-Grdf_G2re&#57:nS%.V:v#K[K;6BK'8Il,E`sPcRfL/S3JL7@G`N?'@YP?q_xOKp8SR/>##RYoLiTYvqIqx+<JLg8$2K##[iKu+WfLxc_lJ=_C#$-PNh#u<*1#o<W;QNL-##,8>>#'bR0:)im90V#:B#&),##%G$0#?sn@tnq51K7XN=$l*$o[n(>$,6fk>,(g7Op1SGs-aq0hL(V6GE2J,W-J:2I$SDkk(H4Ke6enfi'Vl8>,sjai06l7(5QN%29mC2A=4WViB`W=SII>[Eenp,kbW$J3#kd`4#0d46#IVL7#n$X9#7$-;#PmD<##Jc>#?:%@#d^0B#-^ZC#U7#F#mhlF#-[.H#HZXI#82'sLZ=IQMDB*;QUo6JU(Tw7[I*'Abhxn4f-t@`jF]2SnXnb.qoMSxt4=E5&M&7)*m-`S.'Epf1B:'v5b`,)<9Z22BRI?AFn>LPJ0%>DNM8clSw&iuY@4Vf_[)ducrRt1g.q.DjG`;SncTHcr$,G##@<(g(o?I5/9c3#5fl5)<7HZPASRd]F#)3/L?'[YPUPllSjt&)W.mNS[Jkw(agiISe-hr(jIfDSnfdm(s,]h;$HT1g(eRY;-+Q,g1GOT;6dM'g:*LO;?C5A/C_0jYG%/</LA-eYP^+7/U-jWS[Lq*)aun,/h?#UYl[w'/qxuOYu>hAm&ZfjA+'9T/1GO^;6fS0g:,RX;?TC$aEqAL5J7@u`NXl$jT$$M>Y@xui^]vG>c#upig56f`jQ485on2a`s4+[s$P#%H)mwLs-3vuG2OtGs6lrpG;2qBs?NokGDkm=sH1lfGMMj8sQjhaGV0g3sZLe[G`ic.sd/bVGiK`)smh^QGr.VLZ#JNl/(gL>Z,-Kg/1II9Z5fGb/:,F4Z>HD]/CeB/ZG+AW/LG?*ZPd=R/U*<%ZYF:M/_c8vYc)7H/hE5qYlb3C/q(2lYuD$^m&ax/B+'wWm/Cu*B4`sRm8&r%B=BpMmA_nvAF%mHmJAkqAO^iCmS$hlAX@f>m]]dgAb#c9mf?abAk[_4mox]]At>ONT%ZMw)*wKIT.=Jr)3YHDT7vFm)<<E?T@XCh)EuA:TI;@c)NW>5TRt<^)W:;0T[V9X)as7+Te96S)jU4&Tnr2N)s8+I<$T#ig(qw:<-7vcg1St5<6pr^g:6q0<?RoXgCom+<H5lSgLQj&<QnhNgU4gw;ZPeIg_mcr;d3bDghO`m;ml^?gq2V:$#NNYN'kL,$,1KTN0MI'$5jGON90Fx#>LDJNBiBs#G/AENKK?n#Ph=@NT.<i#YJ:;N^g8d#c-76NgH,C^kah4Qo&jxAtH$K6&exsa*+wE6/Guna3ds@68*ria<Fp;6AcndaE)m66JEk_aNbi16S(hYaWDf,6]adTaa'c'6fCaOaj`_x5o&^JasBUEt$_MeH)%L7t-AJ`H2^H2t6$GZH;@E-t?]CUHD#B(tH?@PHM[>#tQx<KHV>;tsZZ9FH`w7osd=6AHiY4jsmv2<Hr<+7[#X#V0(uw([,;vP01Wt#[5trK0::qtZ>VoF0CsmoZG8c&kKQQ3$PnO[NT4N.$YPLVN^mJ)$c3IQNgOG$$llELNp2Du#uN6g6&k49b*0*Fq.IoR*3h)]680./b<F^Z9@c[-eD'TU9IIq_ENnOeNT<snZYX'xg_w+J<d>38-i^@&tm-#,'tS^1O'ukY$,;j,O0WhT$5tf'O9:eO$>VcxNBsaJ$G8VW3KRHeBOnC7nS4B`BXP@2n]m>ZBb3=-nfN2:'kp`%[c=:ZMF.#nt7TPp;-iV5W-#j-+%Wl-+%32a,Fu@ViF)M/+%`>kdGqWd<Bkkos7-2vLF0ehmMIB+9B+)YVC;V<j0P%VeG%^4rC&TFvB$IlT8xGA>Bi>pKF7+G(&M[O<B0&%mBg[+p81(=2Cm*cp8u2j=B0Gae$3g-CJ4X/+%3j?_J2Iae$XU2x9:0G(&GqMhP4X/+%Zt[q;$7/XCIkZOO>ElC&XUDX:4Oae$XIQ@9<6G(&A(:oD>T<.3XvfG3M57A-CDVT.LGcdG7mL5/bx^kE0$@RMmD5kM6^XnMm;pNM;S=RMmD5kMx]XnMq`1hND<En:vOX-O61$1OOthd-nu-+%aH;7D$EpKFoj[:CH2*:B+)YVCI/#dM)qJjM/vDN;.RucEoNZJ;@7pcEmZ;,<^>NDF/J-d3,K_w-aGHOM_$1oM*H*-GBCffG&'AUCNp7UC#AokMQ,:oMs`POMQ#uRMc4WOD%Lv<B:>-lE3.jiF-ESD=Iqh]GmZA)4jeV)4@l#=C?qae$:S#.-@tae$fvmwpJjlC&hZhTCui#lE0=TF%X4`D4pxGs-fc)PM,@LSMXV6VBC&orLlZ)DHnWrTCBHg;-&`8N-DQp;-&cAN-GvCp.n.?LF2l<I$0/q[^P8`%'&^=jVCNqoM*iw.O.+E2O0u3/OP5W2O,M`PMjf-TM9D@#8QN>8J=EtW-GF1beGsTNMfVai2hX7fG3Y<I$v_;I$AqEI$PFRR2P']LM>eov78SfS8(F*W-7LUU)]%.+%^(.+%f@.+%:#(W-<1B@'iI.+%%;jS8'J8p8cU`X-$g-+%0_*W--VA@''G/p8'G/p8'G/p8'G/p8'G/p8'G/p8'G/p8'G/p8/xxp8thO<B0ZX7D--r3=CK-44CK-44?n7LM%>,k2Z]F_J5sH_J5sH_Jb-Fu7*HX7D'+OGH&%G(&P;hjM=:oQMg*-(HxVKSDAEi`F8HIk=,7@LMmqvh2kTN,3Jl2i-[Sa3XCR8791qcP9UgA,3Z(Z,3+.9@'5>iHmDSlC5*G%'ItrY1FA6m5MImK8/-Q@@H7qhQMTecHMVrdL2qXPHMB0eL2M=;iFm/pgF4LNO+)BkG3&CIe-*@+IH-:@LMG&*i2(Hd50k2+hFw)9kEVNYOFY/3CAY/3CAY/3CA+?tQjXwZ'].@ILM$8aI3>.B?.bgIoDY/,d3_@Mt->:[hM^edhM>%Gc-b'5L>-77LMtrvhMeumL2Y-/d3Vg`&.FkNiMXnSN-^qSN-`-50.QW^jM^e_).RZTNM^aQL2U^&g2NEUkF3e3d3$]=oM;)3i2u*3d35JX%8%wxc32`h;-FaQi$b8P)YZ)3i2i3TkM:a&k$FbSR9d;B,3kNE,3QTgmUZ/N.3T.s,4Z/N.3[n0B6i_;u7duxc3rw)W-Dj>kk0j>kk>QKjMWJX%8*vxc38w*W-)uVkF?6+W-Em>kk1m>kklwVkF1m>kklwVkF4Yh;-=&F_$B@3u7vl]G3lWaG3lWaG3lWaG3lWaG31UeG3.Re;-lu+G-2o'S-2o'S-mu+G-mu+G-<op=99',d3BG'`$^i/K<WqvhMmrvhMmrvhMmrvhMmrvhMmrvhMmrvhMmrvhMv9wL2KGRR2CI[hM>u+G-nu+G-nu+G-XhlI9E',d3nu+G-nu+G-nu+G-nu+G-nu+G-nu+G-nu+G-nu+G-=op=9?',d3avVE-pu+G-teldMp.<iMs<EM2?SdA5f7,dM+:NiM+:NiMS<NiM8;NiM8;NiM8;NiM8;NiM50lo$AYTj2NW1s7OW1s7OW1s73X0s7UTJkX]FKkX;b7LM;qJjMo%NY$@WKjMBqJjM3rJjM3rJjMPqJjMQwSjMCwSjMCwSjMWWYd$7[;<Jm'8r8(I,p8.g:<Jm'8r8eaB<Jm-S79Lvxc3^)g;-rVYd$7[;<Jm-S79Lvxc3^)g;-rVYd$SQ#w7M[+p8&E2p8'NM59p%J59o#M59p%J59<'f;-'q(P-LjmF9#wxc35c-W-I$n?g5$n?gBf?vei,gjMp-gjMp-gjMJ_im$8f`sfo9oR9.obsfm-S79N',d3)v+G-SB$i$?rF]HrN:79-?ojLt7kvLfjAjMW:ArLovSjMp&^jMI:ArLx)TNM]_ZhM]_ZhM_gZL2eAK,3UPp;-g%K,M+#879Nw,D-O*H`-,-ak+4h<iMZ)b+.R0ohM2mmhM%lmhM&rvhMPrvhMPrvhMOsvhMOsvhM_rvhM_rvhMPrvhMPrvhMPrvhMQx)iMow)iMow)iM`x)iM`x)iM3$*iM3$*iM%$*iM',*M2JchD4f7,dM')3iM')3iMD(3iMD(3iMD(3iMD(3iMc[+S9a#/>BP#kSM]f6;B+)YVCMD[20X^IUC-mgoDHX#c%bZ=&581<&5*dYA5*dYA5*dYA5*dYA5*dYA5xK]A5:n0s73X0s73X0s73X0s73X0s7Y(d;-%JSZ$$mjv%ejAjMYX]v7Y?/s7Y(d;-1pRQ-1pRQ-1pRQ-1pRQ-.5SnMPtAN2eNY88f7,dM%rJjM%rJjM%rJjM%rJjM%rJjM%rJjM%rJjM%rJjM%rJjM%rJjM%rJjM%rJjM%rJjM&xSjMA#TjMA#TjM&xSjM&xSjM&xSjM&xSjM&xSjM&xSjM&xSjM&xSjM&xSjM&xSjM&xSjM&xSjM&xSjM'(^jMB)^jMB)^jM'(^jM'(^jM'(^jM'(^jM'(^jM'(^jM'(^jM'(^jM'(^jM'(^jM'(^jM'(^jM'(^jM0E^N2LPnn2e$]hM>u+G-(v+G-(v+G-(v+G-(v+G-(v+G-(v+G-(v+G-(v+G-(v+G-(v+G-(v+G-(v+G-))Gc-1):UDrCY[?*G%'I61be$XWu3F'Iw3F'Iw3F'Iw3F'Iw3F%=e3F-9IL2?1`,37u_kLXGp;-VPp;-WPp;-XPp;-YPp;-ZPp;-j%K,ML5q-NOkAjMF*W#MvvSjMosANMVaQL2fuU*43r*cH+HOVCt>]:Cc>^G3fdfH3DSFvBndR:C8T87*9+Rd3=imfGH;)=-q8&F-;Gg@5^aZI<j0v<B/GqoDwAXVC#VRfG1TfUC5=^b%Y(+SM(H[oD3h?=(<$kCI^^<C4$'kjEidIqCXORFH,iViF*JVEHQZ.rL`EWhFGE]'.AU*iMa%J`GaKitBtr>LFvY9oD>D?LF,vCeGuP2e.vq`7B&2>s/=xEcH$D2iFFpu8.1rw+H9XK/De00eQEQY_&HOrG3hl-+%<*xG3u_8@'=H0NM(6199`Yud3p+dfGv.@bHE)vW-H%3@0H:;H4d]:&5Gk=2CIYL)4<^$x-Pe7LM7],034;:WCm<DtB$N'kEFxnq.nu,(5/I+IHDjTNM5af+4r*]u-P[%1MhrAN2EG[88Y#&'.OC@lL70P<8U00oLQj.jLVedhMfkmhM2olUA,(F6)iVs:'.cF&#$<aufgi1F?VE#pJ?sO8';WE1#:n@-#B<x-#(?)4#c:w0#Ylj1#&hGN#Q^V4#EE24#KlsL#+m?0#/0:/#rONL#>.92#:3m3#cQD4#M>S5#&3A5#,9J5#^fa1#5j=6#4^+6#<,c6#<vO6#wqG3#GJ:7#F>(7#KD17#Yx&2#T]U7#Tih7#1.d3#/C[8#a7I8#g=R8#+5B2#pnE9#ob39#w0k9#w$X9#Kki4#,OB:#+C0:#0I9:#VF^2#9b^:#9np:#SL;4#@)9M#A4KM#E@^M#ILpM#MX,N#Qe>N#UqPN#Y'dN#^3vN#b?2O#fKDO#jWVO#ndiO#rp%P#v&8P#$3JP#(?]P#,KoP#0W+Q#4d=Q#8pOQ#<&cQ#@2uQ#D>1R#GA(7#uOLR#N]_R#RiqR#Vu-S#Z+@S#_7RS#cCeS#fF[8#CIpM#k[3T#ohET#stWT#w*kT#%7'U#)C9U#-OKU#7)02#@Z^U#5hpU#9t,V#=*?V#A6QV#EBdV#vVL7#@NvV#MZ2W#QgDW#UsVW#Y)jW#^5&X#bA8X#fMJX#jY]X#nfoX#rr+Y#=/IS#x.GY#%,###'Bvr#*GlY#8AFe#0Y1Z#4fCZ#8rUZ#<(iZ#@4%[#D@7[#HLI[#LX[[#Pen[#Tq*]#X'=]#]3O]#a?b]#eKt]#iW0^#mdB^#qpT^#u&h^##3$_#'?6_#+KH_#/WZ_#3dm_#7p)`#;&<`#?2N`#C>a`#E8<)#*YN1#'5n0#/SE1#+`sh#KV/a#OcAa#SoSa#W%ga#[1#b#`=5b#dIGb#hUYb#lblb#pn(c#t$;c#x0Mc#&=`c#*Irc#.U.d#2b@d#6nRd#:$fd#>0xd#B<4e#FHFe#JTXe#Nake#Rm'f#V#:f#Z/Lf#_;_f#cGqf#gS-g#k`?g#olQg#sxdg#w.wg#%;3h#)GEh#-SWh#1`jh#5l&i#9x8i#=.Ki#A:^i#EFpi#IR,j#M_>j#QkPj#Uwcj#Y-vj#^92k#bEDk#fQVk#j^ik#nj%l#rv7l#v,Jl#$9]l#(Eol#,Q+m#0^=m#4jOm#8vbm#<,um#@81n#DDCn#HPUn#L]hn#Pi$o#Tu6o#X+Io#]7[o#aCno#eO*p#i[<p#mhNp#qtap#u*tp##70q#'CBq#+OTq#/[gq#3h#r#7t5r#;*Hr#?6Zr#CBmr#GN)s#KZ;s#OgMs#Ss`s#W)ss#[5/t#`AAt#dMSt#hYft#lfxt#pr4u#t(Gu#x4Yu#'J1;$*M(v#.Y:v#2fLv#6r_v#:(rv#>4.w#B@@w#FLRw#JXew#Neww#Rq3x#V'Fx#Z3Xx#_?kx#cK'#$gW9#$kdK#$op^#$s&q#$w2-$$%??$$)KQ$$-Wd$$1dv$$5p2%$9&E%$=2W%$A>j%$EJ&&$IV8&$McJ&$Qo]&$U%p&$Y1,'$^=>'$bIP'$fUc'$jbu'$nn1($r$D($v0V($$=i($(I%)$,U7)$0bI)$4n[)$8$o)$<0+*$@<=*$DHO*$HTb*$Lat*$Pm0+$T#C+$X/U+$];h+$aG$,$eS6,$i`H,$mlZ,$qxm,$u.*-$#;<-$'GN-$+Sa-$/`s-$3l/.$7xA.$;.T.$?:g.$CF#/$GR5/$K_G/$OkY/$Swl/$W-)0$[9;0$`EM0$dQ`0$h^r0$lj.1$pv@1$t,S1$v&/P#xlk.#X#s4#mSl##WH4.#gAU/#Z#(/#gSq/#MDx1$*Q42$;UF.#C]F2$8@O*$4pb2$8&u2$t0;0$>8:3$BDL3$FP_3$J]q3$KM17#9o64$T%I4$X1[4$]=n4$aI*5$eU<5$ibN5$mna5$q$t5$u006$#=B6$'IT6$+Ug6$/b#7$3n57$7$H7$;0Z7$?<m7$CH)8$GT;8$f2>>#m9.5/9Mg%F<,KJ:^RB87WPs%OFT];$:(K;60?;2B-[P$BR9jU$%UqN$*8Fa$4/]P%DV7H%b#mN%8NTU%WLk*&DWI)&.g71&Fa,7&SHe<&gefA&l=-G&q;VK&**9Q&XhKb&'mRh&+t/m&AILr&,m,v&88b&'fl[-'76^2'<*R8''eU?'aA%H'8M`O'lf5V'N]T^'gfed'C/;k'):>J(A$e4(J_=:(m=d?(RBlB(9K$O(*ti[(3$,+)nZMw(F#(7)11Q_)u?ot)1T4u)m/cB*1[G7*f$ZZ*C4iK*q1Ku*VF7h*p&3l*Ex/u*J-?(+v,tA+kg'R+bSqv+k-Xe+s&_3,U6F2,Js0V,MfhC,/c:K,w?`S,tDf],q=cf,,3+q,=o-%--iU,-qW@5-01[@-D;-o-^-9^-Ft_0.N_ax-7uZ<.]GvG.5Lcn.l?pY.*?xx.Vkh,/LWI5/[Ih?/kjEI/&PHS/@gG_/mcnl/<,xt/D>m,01*3X0&?%T0V#)[05pGc0ePBj0O=-s0p/TB1FcB71S-w@1P29f15=Ou14>tm1K3<x1v[M-2E)`82rdH`2Cu,O2YclZ2PJ,(39JKj2hr3q2k+^B3Am_43YdS:3$%JE3jZxM3#>%X3hCi%4OUMh38_2p3oWd<4:n%.4Ijx64M+V[4Kt7I4^B.x4<9Am482G;57[%*56sip51;3e5E*Ho5^xf#6c_G,6O0Z46KRMl6VTMl6-;6@7%oU<7kdIE7`6Bn7k;?[7d%wd7a<T380lf#8RRo68Ct(H8rmYk8T#6W84Kt^8[mRe8.<D19k;ds8a6EI9(XtF9:s@M9Y&XY9&N%.:E-@t9`IQD:S5)5:V1&>:?[Jb:4$BN:Lt=Z:ivAj:.#O#;M+]2;DTw=;M-<I;jP#S;_r,[;t>5g;CnXr;O^A+<E018<HwDE<S^&N<A#'V<7r,%=xnIm<RGgr<QwXv<AS^?=Ga:)=V^8/=Y=43=UAg7=MkO;=G.Z[=Fs_D=_W8J=S1+N=.l.U=4,'Z=,q4_=w@tb=p8>g=S/n9>4Vu,>/os:>-'Y?>SKAF>sZ^_>O.Ml>4fY8?jFK$?+AG0?3dO;?%@v@?F7kF?hXIM?%3:W?<9J^?sA/f?'4Fj?P^3'@GX[.@9'xQ@-t5D@<QZL@D5]Y@>mD.AY3@*A:>6PACpt;Ada`AA-'6HAOB`TAVNM]A;8/fAZpg0B=Vg(B1-bJBl,+7BJ39CBSjpgBRaYWB#kN+C1ltvB+>mHC#?b3Cl%LWC,'wXCdt?aCHI(hCeQjuCxU+GDig:5DKU$ADa)bJDtI,%E&kd=E9lnUE`l<NEX<L`E/][qE`NE'F^kM2FW6h[F,87QFo?obFZM^gFEb)qFjb9<GsG3+GFId5GHTs>G8aaFGmC9OG>mJZGmW4gG/gLpGv_@#H/?C-H>GR6H1e'@H_19KHd[^oH8CXZH,9LdH?1'4InLG%I.79OIur]?IHHxJIu'FVI<^HaI.J</JUm;uII>N'J2A*/J$F08J1E6AJmS$IJ&4tRJ3QQ]J1SWfJ3X^oJ:8a#KKvi6Ks#xBKaeWNKfQBWKPmB`K?Ah-L,`_pKo$`xKNXY)Lv'90LMqW7L;6X?LgW7FL8'mLLpDvTL[XjfLep>pL%Cc@MtwQ2MhXS?Mb[-MMikxZM_=_hMCAmtM'Er*Nfma7N`KYDN7]OONE-7YNJVtcNqA^oN0,=(O>Y`6OUhvEO$n?qO'4abO^6<jOkuGtOfb)'PlM>1PQW_XP0I?IPp'JrPlbBdPU.26QMi*(QFYPPQEuECQ+i5XQT<&cQQ2pkQN7vtQL0s'RK2#1RSbi:RmGuDRoCrMRK72UR'o5]RYk^dR#WlhR-vCiR8D%jRDi[jRN14kRZUkkRg$LlR/d84Spe.rRY&RuRL[M#SFf3(SYDY-SMK;>SiBmaS1_bSS*iGXSf3QaSFof0TT(t$T[E#9T,2sfT0:['U6Df$UsCuHUo0M6Uh%PdU]t:QUl5_TU5#(xUw%SvUBjrBV/6F4V%K=<V@85pVUt_iVD@>pV@8_tV?62#W<1eBWV-7JWUpLmWr0psW)+w>XUbh*X7R(2X9vnVX=0u#.&URC*^JHw`GO44$j0un.cxFo.,0sI:?P5FsS8^:%r5Kf'QhPQs4KfNIZFuq-<hjh'-O+F)l((Jsq/Bnf)qh<dP0ig$Sgjm)B?h8&k#Ops]3#N#9nr]b$LPYYgd*u-$Kb/*UP9EsD4GPsS<EDsR2N;6$LrCsfZsDsCf-w#PjRI:l]HctKHEDsc4`_tR`Ys-alllL@S)JsF7r5/I9oHs+#TkLbiYs-<DXgL7I[Fsc4YUZMV;Q0XHpu$a9:]sGILxL0iKF&tRU:s/6ew#G*H[O:cLL0anv$0w_W;MlM`mO3'xObN[pX_BHda%v[;p@j@3^B`wxt#IlZ8%1kT7Cl?pktin]%Q6mIWMCrCxKG4h2N7W@fOXZ=sTim^Z$D)N+Kstt]tIB%u,$i#*fUrsl%9J>PLsvCPswDPYqbrhgK4cdYqdQC^smx>4&#7PfaE)M[X#v.-)g0Z.(U5gU.p$bw'3(tAFisM=,&2Ohq>rEW.M&H^,wF*l-hII*r%qKt,uNN7/Xo04/077v5kd[[sX,?Ys.#eb)B<KI(Q*1Re/2>_t#m2w.u(89^K.w^%WX=pC9`qkth2h)k9:V^O#DWId]WBh%b8::5+;pktWA>lL$]se+V_d:-CE5f(R*B>c=?RoO3dvb:8[$],H]Xj)`*)YKE8=FZo8kOXoQq9W[pbiHS]<4u_1Hn]c<*fF9^IfO2:t[^u/?TXWIDN';rpVoZ@_5%mQR^tQ7gCIK56.(:S42t@Jbdt,dC%48h`fO`C0vt9=3Y#9pil$@H$Kshv277m9VmhPYZYs>Ukk4>Q80Mx:;UsWfVRs.9nt5b<CV%D<5a$<tfstd]oO8-Eev7Xv>_-mN6`$&_0^sG'HR@1e9.t@LrCsm8dw)l[1'<DxGL0DMt&>88*Ds6,=it=e@_Od:oHsoxQYs_,i)bO'P%;$oZ4&=dtTsBq@_O<Ijh'_4YX#5$aU$6<l:tm6-xOl?7Gs,s_RsMe_Rs)$T@Ogs9N't+6f1LpYucF.,Ds.-dR/CPaLBr&og`G*]c`]<I=-V-,FM9OQQst2$9/jZVX,eBbjLfd_.tu;T-7x0Lk)%H'VHZZVRs+T)d$m.TQsBo=Qst%UUsQxkwL^KwcXsXC_t3U7l8Rp[e:.f-KsK=^X8O/'c;MQKctwC]b,:C-Fs@x(u#TR.pt8F%`tKNJu#+gINsVkQ],VH?uLA.F'MnD9vL^<:.(.x>bs`NW9%dbr9]O$9og`LVgt.CsktrB:iO%%)[KmWD$tjuqd-B=n92v%r9t/M/+0E'g@_Z?hUi_h`hOx1n#7w'RktAw_fsdQ6(W-<vNsa6`sOM?0+)9%5`*7aP]O9A3qB*Vki%22tlrfdwq$.QaDsnp0.(fEo-UdZTI2e&`L='n%F0FwJ@_%#Kc%h[]^8BOZgt&v.a-82$Un#o6eK[e#iEA6ucOdaG*YX-0Z$MkOoGK-VRs)fRL'<M[X,fIfJb1Zw,)%(%J[<$(j%rOb>dR@+wpS.GPs>-*U-K-*U-9RCx2#<,FVk`ZctoSZ[bGU#J6pDQ?p'e0.(9eiJ2)]JHs;lXFD($A_tiVh?%Sw`WI2HZ[+qV3`sgk5Z%&PPuq-l8f?VhQe%;'+htMPle$V7p,K'`]DswXC9fmqTU-C3a7.UVqLGU:pb%u;DGs9*vP2+5:aO&u#vXW5%g$wv/0RR3jq/47w82D?W::N>/F-Y)_w/H5u>#*%KEs[ph_%a:+Rn^Ot0j@w$.:4<__*e02Gsm8autS>[eOgMXRD`GW@rjsJ:`7<OKYO5HMn,Ro&:?pEc%Zdbbt+Mx'-*>Pj)F^vXWPbcDjf?*=8J7C].o,%(M4ja-IGB[X#dus?t;-hIL3KtQ%+&G@kPMoC8#gTj(^;+O0F?@,<n*0T%)aKh^#4<=,HxR[s;v0.v`'UG=$)ork^jIJ1CxP:v1*:)vxQav:mwB6vwHxG?T09J`ae98.o;:>#+^6pLvdVm1t<YDs`X08eagsY-5aXZ,hUxI_rm8>#_-A.vQ;w@8`tG0)-bGxkQI#-)cZ-S[wWV:vNP%6vgLgX6DCMp+scDF4#r#m%E_rn%=fH],MhAbai4RcVI5`hL-^M(aN%=>#f9?6v_SUb/jn4p8qB/v05Mql%WpWG]Xr3V:-:m.j67X:vQoh#v3%e[WKn<9Y.UwRn%d6vu*smsLR4gh?+$,_JEm@8:ZOg@kiZ;>#SR?qMwwHIGsdMxb%LPg:m%b99-1''M[Ppu,Er?tLH,`#vw:I4*rSKC,YhDA+4i0^mt?D]/=W9OJv3#>Yf/k0T&)F`s,WB(*H9=JsCDNdt#wlA4SPe@+=-&HsDo)qO:_djZax.s7>0rI?p>3rEU?U13e26?fJ=Kc%QA`[s'Ax'-^ZWx)'Da;KL@Ng:,m<ahX4cGpYt>#-/YvaLB8ht>69gT.8(;m/RI.+%[v=W6#E,+2v5^b2VtYX,?q*o/Vvo7jl7dR/]WAds3O1%*Q6F4J/Q#+Dj'ZRsNg(ZsfZ(Zshw($YD[;7%e5$hc`:NeU3Wj`sesv8%qWIXGg%+gL_Bf8%'OQwLZ3&_OIw^0guY.1g(&pkt63dNsqggq$>NRQsAk5NsWrkn.OD.`*Q(jZsm7/ws6ACs)#7mSf0=KG3f^K;:GS/ptD7R4ZvZ[qO]QgnGP_5iGms)'J)<J2L%icV%hdv]ORSrgdmrH@`eYH=qkS#3u&`$Un4$*G]QK)ACo&J:CQN8@]ep)x+bP_jonm5]s-f_EIB9T*)q>>2p@Zt3J'+)Gsj+Kua*VNq))DSwVV0x,)=)r*AE_2rOf]freK]8:-LgoI1S`OL^m)ZeOVrT<7%Gjv8:x0V29%fCmGEge(oP3[fw-<(f(M_Mcl$lQ%&4^oL_)+iBaHpEs35t*DQPfGj7deUbVq=Efnp#EE2[S]t0AWc6rHd3D0QE5-3ux?%5SY,)l&k/X]u'hO*S370>a>%-I;8m.Pa8`tltkr)'TjMn'.H.Z,_(b%s)4^Ft&W&AW8s1DTYmP'H6GPse?W`sM[DVQ/ak&F*,ZO0vPpoOq#GU?2Ao/1d$Cg(I%KEsD5.k977-bsc`FRR+8/-)Jq-^tclC.)2nnAk?:B.)_lQN'6_K@%`E5.(r]7br*mQN'C50X:I3dNsFQn?9kSRfLKYaU6ilQI2)WWDs-;G:&+-8rDH9%$$GEP:&K)G'S5'-[Ka`*15DUJX><QUF3*CJ,*x&?Gsxer=-J12iL`FTI((nkiqa#j0,W(f34U2Sk+7'Q8MiVHtl;Fpdst0Lk)muP^tuH(2t(i%Y-7N_t(d$Yt(A_ZQs$2lOI>fOwL4/9:-oa(;&8Y:C/KRaRKRa][s.3NPAbf.%5JGCT5j6kS9Vl;*eFks]5diulKsaYcsuI<3M]+elLXopcNOAb<utRe>6GL/B-@w@C<<XGesG.wl)BI@kt03i;&q8d-IS)P6aOJG6jP65.(w()k(,N;Os#;r;&<t,gDR^Y-?h3nD8ce'iBc3nL0<2A+D[$R10$1/Dk=URnbV<ia22&IWnIb)>Wsfal%DNDu,GF'iB<@I`%HqK]l3bj#-;-J'A7&Sg1qLBVo>BBCIFm<gO(obD48Akn.XP5hofbfP'ZBXvLg'4?1VJ.<&CO>+D=PRN'PUtJ-OdJN-8^^0/@AUqm&eH$gBfM'M2%RhK%G9[Qj:un8]G2eLPJTwkDQZ&MJxjZs&[hBs__R<&[.#32_6)B5H_$J:pDWRs;Qjdt]f4l85YZ=>Ii)N'[UhF.O]RN';p3n/NZ-.CB`RN'20d<-tvOC.rJvmS]5#<-D,Xa%rfRN'-@L=PIi[bMd_dEjPlUIUtZJ$l'mPo)sZ/IU:ah,)aZ%)tL>J$l94vq$5KP:?`bkj)/rN+M`,okt9SSe$YE//Vk.6m'QE//VW0L`tRbFGsWU5I6dk[`tc;KQtx_Up0]i4Qsw6DZsvL.FM3[=_5,88';Rg%G14=*N'QH0wL(p7d)(s)1BNa(9.2'QjsuuUG#X&%)$WHk3oEiRN'[&b);.bF-lctX'XjR#.:e3NM`KsA7%o,P#l;F0-)ZsRN'L$Od:I-=lpqPLs(cS+?-lEZp/&Tl,*KYwH`?9Hp/-3RDsA*qc)8*rE3_LsQ/S6n6eeeZVsc39@4^rHC=6u6R*Uqh'8$vj[+.x8d6i]'>&OC3^eMpFoLSi:>&5F'$pN7][saQvCs@)=ICI9CYe&rB>&lsJ431BEm)9vP^t'>clsHJLI1.du)M_#W#tP'U>&6-TIU&@_qoRUadL@X3XC=62kXq6;48V.]X?2qo5@lOSwsbVS.(CL9:@4f)W@,(4rLASYLqI&sA#l0+R-secw.I=k[+$fk?B*V9O+%Ttoil)1baYu*]+ko?I2,h:R[_'1-)LfBl)Ln0W.Ogm>tadx>-]M6T/V.el)D0v^=_0PGsp;GhLwbs#Tr[V[=we8]X(_Q?&Ys#qL5fIaL7,$9IRbC$$@r)&*AQ9Es7k?x-FOL'8S<$j:).+N0wLIws'pm?&0U=qL)Q*@&Fw`'/,,8BNc(l<3Hx(4SAG0.Db`hZD-*Q$EB=^%8wi;Gs>>).0.>++ET2m?$RU9S/f1FPs[b:XcX_^?TaASPs*Ru]sthqs)J8)62LG/.(jD7ug_.<noo-p^FZf*s[1]HX1A-UwsB<;p)Zj9>XEW,]kTp[,)>#4ciFJ6>#+:x0v3D*Iq6F7@#93f:dmLIc%oxD[.h0rO/@Iln.k:ml/[K=uLE>j+rFIJ#cXMjv5Xb<>#N4tX%kL'j]<Ts9%0.snI5x$wulTs?r;Kv20aj/0v-k?(8G,$+qU(I(sSAW:vYResO1=%Kb,M<nouf'DqdYtr-V%Dh>fxu9s):F'*?0LG)3Wr<1wFhk%)<kPVI<BIrP7@qe@J0U[[R8_1+eAnfbB0U[rT)N'S5[p0+p0Hs2-(7@@j8A&?cPPL^(5eoSS`t(&tJF2QoAA&Y2<9rJ.jqHo'6Yst[NLsKnEWs[9vwG-JhGHo*ujH5^*jLG2IDIxdGtLwZQ+)Vn]]tkVWDsgM4`O0x6rHfrGf$hl)nM<J3ILcXntH6mjfMf1tuLUvpA&YN:+M.tlDI+%d<-xHcw0J6Z^s#84J_enjqI=co/17E<<qDUg^sIdvCs6k2DsS4Jq)F;pD3N<$nOaOv]kAX0;FYg-Ndw,SqO0N+U%R<&Q]L0We%1I]]tx1Zu7$cYV%(ag=:RBKPL1uUDjF(vgONsV<%uZrak8W`mJbs%+iYI(K#MU?e1'mPo)4M2.(>F8N's@%cI;;C9$)(Aq)PisulSZ=jOg`D^4YJUbYJ6=3<*hdfOaL+U%[uOjBP*:a%@q=Ds(ifbhvUYV%stOCfQZu0SbA[v5[rJpOCcFQ%pEv>>6B(P&I_hWHsYpk&dO-h((8<Ds#)U,).F#Fs2xc$GelJLs'jokt3=?jt]h>Z%I?Wd$#r3&goOv,)%_E1cbL_RsM#9TseERk%qh@h$%^1_8n?`Hd6Zt#u#-*DspVOg&=76Sswl5w)><Z,)1M+lSeoGf$Fwco)r8*kEVQidYLs(QYLTs8F_4iP'vbDUH_b_*iU=3ba?^XdpqN-@O/1;_togvQ1Y-1aOh<s=4@Jt]t;tp,)RGa9%N*&,SaTwJU,nulI$'`0_Z5x3Nmr6N9kVtq-5DYcp$fK1Y1w:b%2SiFoRXtYGo[<BB,b^00m,9oOb-klreEVX#a)51'U>1jra1hW-]c8wtx>KMsDJ&lSPlX]W&+C[,+pM:NFkZ/UjFf5IcF&[S[ibgO0GP^t>XG1B]/6]-VgWnLFN$C#HI_X#(A#FsF9oHsD8=7.LR[[G,'%mFs^:lFIYsa%H`'i2jd'jKk:6iO9p_s-+NemF($i[mp4Lo$#Z%VN0M4oODh`bS()x[m$;Fo$tmxuL_^BdOtpkCK>g$uk<*]]t]mtj)OQ/@A^6v<BTN)&_D^AD^D@uXVA=5<cK-7RR,'irZm&&FsSm<ttif#D/LO1lOMO8I$V<Dt.<u0lOelt`Ot'@+M(@Pl$)g[vt>;8IC_$P%+&MXatrfrGs*VBdOB(,48aa=Isf.f=%>S$@b>2gkLS*Ys2U-WQL?OK&pSmA7%Q9sn%.WDOsEFJCoAq8dX2sYg$`@;uSNO9x^_?eqOHmZ]L`sg>YeD/wS:>]fOHB_15p/-aO7@HbZARkcHZDOgOb_1rhu+v`K#Dw,d#,UhOl&*.?1fJu:p-%e%4I;8eM8FddDf@_OD5aUr9Q^D[$ud:Wd=9x^$XMoXN#dESQ,Od%c>Le6,.Ce6f`ZaI4xs>Gb:/<ThNFb.'-S^tl;tTsb<#Ys<*4101oubsAK6?&RFB7Atdn3S6xUBiS(XZja_'TlFc,o%$,)Zs5[:(E_X>r->Jo'E__ln.;Sk$F,==X(s.U@FsY4L#dkx@lOCmt5KE3L#(I&JsTZS]tWV?ctE*T`t@dQctK6YX5cQpHO&g2#`M`9oOrp#=M^<>1PD,1^XFl9mVN9)eOveYQ8hGP^t8*KJsO9,sOuF8WWkc3m$SD]VLXDYp75lT6-qG0qsE^JwapkXo[xcefh-X]tsZDq+C/RciCL(bgGK_rg?l`uu_<0Ic%S<<0>ww%f$T`omD5XZ1>B@DrOB(Z*SXh,TRGGNf$qm67JiHTREsp6iGw4fnOaI9E]^)=OQUL5msa1*m)?GM7@sqL5/HrU10EKl*MK=qxt3bP7*DWokthtlhLur$N'5)XTsj,5IU7mal];X;_t;PFitI#KEsu/0u]@,^,NkPUYs^6sZa_cL`WFqdCqO@86$(oCOSa&_btOwJ%4V<a7%(c%T%Xx;7%i^OIsK3*)s`IQP9-Gkw5jYl^t>OkZsn(dajS+TEsGWPct>cSEbavcHYH4tL'wWM.ow04_1mWWOri-cWVftIh%,X++EI9je,%lL1%_dD-HcxMd%cQj[rF_<[bKw&=cvNTN'XS=@Fv$5V#bNG:l<_@)t@rJ[UNtT`IO'$AJSvO[U*5/Gs(3Skgp5R99NgZW82enGgJ,1q,n@%=sHGXX#t-D:$5x%%48'aqQ=I47eAmA_tMb$E-%nK4AtJ$4Aj9?wt0*9B%`3.Ssl2QbMl*-@F*2M;t7ij_TG[:pO'(jEJG9[1>aYWN;qNFbVgm/:%<tqI[^(aNY@WK1YCT>1a-DOgO*DZdGn3dXPxbb@jp;k()P1386^mC^s[4Ne)Ax0N69$&VD.sDa%=A$gL9BiYR[>L#Y#iffGBR)*-*n2/%)'tMZQI9`I=1KGEo>/KHkKe+6m4/EeiTC4kbA*pOUx1<E5[%e%Zx74YHE,UD$40T%/[sDs'ZQO&AiRRJj>GSLtv_ls?VGwcrER_<KF`0_/4WkJfE<lt%uWLsT9SE%n,dXMQQ<rOxX/WWThnVU-L8lOGOW.(-f;Cs[VL?DC%N6E$Qm5LEJmP'57Hfpu,V*r5X/.(UbCI4Vg?CEMbjotZd0JsuHlne=jQ@+?Q6iLE+UsJ*Im]t,%#dtu_Q^t<.6VsogcYsqDkn.Zl(o/nx5=ljO]BiuH:VZHt$c;gTTN'.@/.(QfB6t%(t(9t.tkt,T_6N5XWM:igP^tq:L[cBNLS##Pkh0F*n$=.dq9n6Q]ioI*i31mBvN1;If8-$%EDau-#G>R,.&@'aGUbbE74-Y=7ssmZPB&?XHL0Md:+Mf7TU-i/2GsTFs-$+2%N'W2d-I.1Yk]a6OR.l+n'lNnH4/:$i5fYcekKY4F]sJo7Ksi0e[j`:)Lsm;3jT=U;_t%)7N'^Wwqixbj[sl3R]->po1505eKs.qs_T7#us%DNvJ2xG3</b7-QYc21]U@o=oO.xAX=bRVW-1O?hP97=@lM.EL8.Eues(,h?u^U(CjoJVx[c+kfO:7+_IT<X;8irp4LL<)#KMA4c693)_tqTYqDErqsCBUlCA2;(=%ExccKv=vtO^:cRj'47FZ,5T)WH_YoOUaL/uRbgh9hZn`O]5xI:pDE6.Imk*PrUE(7<8>7%P&87.Od5.([ge`tTpm-)NhWo)nCK-:2vUxl=?uEf1M?Ns:8eLE-BefOFKYiWR>5oW6*AZU$bvNSw[cV%ldv]OPINp;/in@@>CxC/_a<ps=RS0qmp7:CRTA@]4wvF]RT;AC@H^O&&/nt>*N;OsI52.18xqh:_XgUuhQk=&P*>s%wvKGN;r<Gs$=$t.DxUbruvAa/BopCsstK3$p-Rb`jl0^tJ;P=RJJmdp8)4GIHGXDsSMrh)+kEI)NJJ$l8?Kc2871gi<`oCs.0U-%.6)+M0cv8.5tK+MCU#Vf:vCT#-UjJf?,*[t=4,.MGo7'*,M).h9]*9.m=^RsJ9aU$U=EDsZ5u>#vRa_*tOmVs-7DC&0GGg):+npe`N,T%sT#r$BM#r$EE5.(+Z9C)##awt79SjObE+<T==T^$8B:-Jn]#tO9e2r`qjTrT/#7vuMW_+ZurY[-G75>#u)86v.QsWW-r3&[Ltkf(%Y=>#.BF*vLOInV8<aX#fR`O34fFc%W-6tnee57.ZP<7.$do[g.fe^%$VhV%Bq.t3/epkt8e*Y,qSoktp#U:v8`A2vn^M(m.us,6_7e(W`^W:v/3fo%imW:v<Kl&vGfpQB-/Q2bUrn`%nWlgGac:x&nGmt>dJ6.(_a-5):>5'tH(+=&L2WCN<;7+3DupgLDxSfLau(Us4&h$F.aKs-8r1^Q69^3ML^@NsN<qEsr@mw)Bf5%.@l8%Q+?hXsviD60QY_pfm-(+*xh(^dP3I*.b)d9MYfE/%?%tQW;*5=>JB0.(tE2CE:T^>dX6MC4'k`,MP;Y$M)RW2MRM:[Mmki<deY^1PsLZn(L8SptLIo>-:?ZH.)/ZILuLXfid:2??VRbOsel,bRPs=ROI$Ert`L*@0rBgdOj93@=H4eKs9'$%+J(r[ek3-msp*ok=HofcNb;#68MtL5guca<uL6f2(_P7dkR+cjLX;2rt6q%q)qSdT%Uslt>4E5.(_qjLsP.[w#>-0em?h=n),Aq58Qt'%0/IHiLKF5gL$guBa&LhDFZ:%^0e^Kk=t7Lh^voO?-=Lj6.%83GQe&_d8VlBwKf<OOMHS>WOdE&stu,%x-)M/0MHf7Vs<*410/S)E-<>Lt%PLk/OnwJKsV?oq)CphC*<eoC*V(j*MfB3mLa;iC*#rls-F($.MC9xu-LutgL1xaxHT/'r$_i$FNo<'osiwE'*KC(11m4+@O5W2-)9/1.q6Z2-)_'Vu82:OZsCtuYs@56=>_<nw#r*7F`^B>QJYZ<49+.6)kZ0[$MZ7=[Xhh)TJ4Mc+;<?%j:X^/jUE9;<M$,F0t*olB&=&bGO:fsZsHm&UD7]T6ssFje(;e_wO2E,0)Gox=u``Gb=]+tNh&QaEsC>,ft-kd-)Rt(UMK3j<dB+P=PCcRN'U5GPss6[a$er,K#&%KEsvAww#)1Lk)M'b$'>eY8TX>LJsuol$FYsM19_RB`twGf]t,L+6%E]DO4/,-_/?,.N'j'b);r8F]sUDdYsr17.(V)Ku?&XNmAxqpUs]5okt_W#IO8G<oE-=CeOXBb<TUHQsH';T(Ki&gsOEGqhl<8mtO3$E+;htIh%<V#c[W5,pO.t=l770+at:wtdt=*T:H>3/:H;sw0SK,gTFmGLx98#?`/rDqD&d%<*nKq4.($<t@R2c[$6'^Pnne-[,i,R>.)0r$.%c]be=TwVU2%R4=>pW$x-bs]kLU/?B&a:A7uPK>W2#^EhLH=YLs6;5U2edmxs%W-tL$x31'+.=W2d..WfT`$]-lsOq2[-IQs(Yam)Rvkw5(OoDsNfn&*DPJ6NKco:L)]#j_2(-REA=.10CUA02R))D5XnT#t*h7D&aJI.)q`5?&lpMQsc0E)>ut.G7>QG/f/$BZ.gvD,gll5Z%QEIQsxeGo)0gc,>To)Kbq*KTbqxoS_jBhc/.B2-)9n<7uXPK_-D,qNO?#[ULCu1#lrL;))u$KEsNYrk&kumRs^eV[%-cJhp_n@D&*iKu)hE5>#X:14lR:SN'bK+Wis7ViKiwUfoGn4R3g%7C)-_`otkI%0-8Fk5oisef1'[nuu7k@,c@*/>Gx2VY5cJ:>#60h%v'`cHl8&G/_FrsCn0$%XC)DFc%LN&2n8x?]rGHE+[tQ1b%'d<vG@ZO93p]NcOLsokt2#U:vgJQ9vGdk7<McqtiQHFVH45S:v;Xh[9D`^/`jw/PSh=-'Q0=h[%Q&mt>S3fHsHUtkM1DJ_s_IR&*x=j4u6qx;'@4nH3H(5=>okd-):hInLW8?B&<e/f)w5dBtPCq`&RGfj:0a&Es?(]rMN68_s&M[&*0QkTu[fq@-dj(P1fN,k(frB69i#vFs#l?nE9v,o%UFw5/'9nDs-':5MU%C<P(qpX>m&@Mh;K82Uqrwv-ko?I2/Gb<hd`)/8w)%i$W=clsa+n*.K>g*.')l*.Gl<hcQ_$&2ZMk+.qaPqI4'G5Bc=$sI=rv/)+5ZILuLXfiu_-b=X_tOsl`0105b6wL`d7'0eM6?&74#V6)EwW%*i^Zp?66^sRij._1@H[FrY*DsgWn&*&0wjt3U4%AoFQU_AYm=`dlr'st^0]l<wmx,m*Cc`i[U:vu'o&vO.qWGh`GtNvp_f:L$8vu?H;vL8$R#63Qp&e-wF,I$WxI_jQsuu0Dvs;B6F]upLb7eLN;>#%0H*MFwKs/?kOJ(i=`,D]55>#*V/3v6BGLKM<;s@QmhFri^8>#+n66vhEuFut`CfUl(U:v3bdo]?w#5JnU:>#xhopL_x2`FE8%Vm4B-O=[2]^55;_X4?OSM'xKX:vab24G(eC5F$%a=,KGb=,M+Z%3W?c]>SJ<JiKJc;-=Ox^$[GXDs;?bp:3-xablv7f:hB1-)LG1-)2V_d%a)mt>2?5.(r(<ia&)F`sqL[&*M@@0u2R<+&WCp]s1mNC/E^5=><iXZ-vN%C/=tj#GPMPD/#^EhLe.(PscZ3.(tuWX,GC01Lp5HN[E8:A0-xKhY@+=Gs14Cw-v_AoMJ$cjL-bJ+gFYmu1w?310swYg;b@wYsZQ5U2Wr+480-bh*4o#Og3N>tN6o`s['1>We5ZPYs'SYtPZf`G)$G@wsw.fD&BrS48-KJxtlZ?8%p9$cDCvbQ'K'b);IwISo[CL,Mk'bRsc(5:RevJHs;_wD&Oh@i0/#3-)GiQ`H%iWZsM'6YsJR3=>U^a73wTZ$tw(+=&8,&,umuJA&BcnrLT]FGQTdASsVght1H'Tt1d0e*.X.<oIQd%j:%U7a=`-4QMsNwq7:^t]YR4NCRFi&[sB5v69PNUA5eL[,*ZE8H+Lk*ot,wa?Mg@]qLZoMxL.5Ec>G)(kbLK?OAkE-Dshvu%0urjXPtHTN'moc]53RK]sLB*7IchcYsBG]Ps'uQ_<;V>_tlr?qLs-@GXOYwJYE,Jc%pL?lnDD-:?1th%221L%B;Ysa%CD,FjdB8f(%_WtAs9QhO8a$#TxtWI%LbQ.RkxBN'_a>$^64C^s<*410@$t,O[CrC*s)Uq;*#r6pSPEO8.=1Dsa[hs)5LrU6pWYF#plIu%xJm*)sx8e;Y4mnLd?:`l8_[w0e6tWsmd9.:em0H2VYoi'bmS:va.N`oEI^'a.0+p8+)0_,^8prJ-uu,)aZ][$sUnbT(uruOVd+P4dSn:&8B@gg_qRU-k4MRSDi0fu$b%I-*dh;@HJj;7-&3jLh<o$=%?D.)j7p?0^sRN'`w7KmW#q2N.bBis)ALv#_i=o.qk%WskoNAUf,k5tYk7_OSt$J:/15(fRkIeU]A>r6w+mN=)=5XK_D,iOi(0*ZZrV=_.Fq`SkV@/lSho7Mrmu#TeS-xOR[[O0?GB0Mw%EO^bYwg1$[JAXcl&RfT.#vAg^4-8pcT.v'UR10r,Ejt,#l9[X2i6?-.6>##3>aOF/W0VJQSM'k<:>#mJm1v2lBOj_Lg?LFv,6/&-%J6E(opUc.E6.hP+#M=OCEsN?.[BB8cg='<9S%]t/=>whV8t$P>B&QVG=l*mQN'F$=m8k;srR%(O;7Jh*T.ox.q)w#BK3pomVsTlKh^7Ao1t*olB&[+TIhf45k:C?5.(;ZT?)1mJP8%a(pfk[LiOc?08%ZYGFsL2(r$i*:7AY7':u6CK?.U`^B#R?NMU5fNGs6&@#M:/)bt'f'(/'UFE&$(hsM:0EjLIVBnfbF2@Bfm7*bI*V3g@o&Ps$L7.(]t&Z6d^Pw.SGc_<ICIB@Xw/;%L)mt>%--d$2A3.(P-^/)cVGbs3ZOE&M[6uuA6xg)9ZTx@QU.aF3O'e;qiDCAv/<)iQ)d1)9</ts:m#pOrqR'Kc>uF%F62:LI^-t$hbQidC6I[FA:Qhhk_nctur+48gM$RV(L,^@Q-NL`kAAW`e#5OKAjFtOjgid]*%Xp$vO5$5+,]3g*?_MsZ<qEsE[hs)N=$Unu6$)*brWF&wJm*)086[b@VYTpJlX`s`1L<.I[leh$)1OB>Y9/`pcW<0F1vq$mjJs-;2:&P&LS>MU2C8%80LmhnVG&us*GD'>8UAcr<TfLEQrUsZatBal[d;-0pUp$2P-<-Zi.jLFf`UsR*5.(_)kpsPK6?&n6fcP2BqhTOnVpBLW*L>q0aU$[/4FsiRXOO^'?<BnQU21XiEAU$a]]tI39MsA5,H2SG+IsPlxxt&&qT7>_0]sM7VP%XHPI(@P./h'?#97vHh3]GJK'%6r_qa]WBvc@CQ&-6MEm)%+R1G:k'j%f^l0%rG@&mceuR.MgS]t=Noktc[[Hs0xJZKF4/JG8,&`Yj6M``1,b(S10ec%8XrPA(XHh>A[G2rn<*7%^Am20'UFE&FPU.13qCpTT64Ws/d>X-Br:[0BhNh:503GsY-bW-4*o^-vgDxL2tbs%fTqb3s0]<-`<Z91P._<H0oaNs^/?Ys$R=g$kN.19cI]X?3wx5@)L4.Bbk+5pW3Ab'f0?ggGpmVsjhT-M:O1=8+YlSJ1*NVDgXD_/<np/1RYN7.B)3-)*$[ktD9/F-r7/F-jO/F-MOXw8AwXlpY:cv[UkI#Q#1@b:QLB/`tJsxL84nYs;FKv)kZob-ImksDCPZVsRe&r$G]`T.Z@pq-#OH=0dSTv)e3.(Wi=18Ej.nt>ws$giWh,WM7S>xsS=ojLZ+.Y8fr$ni$cNZs8$)Zs*BJh^2Nv91:9Sb`fGoDsg2Jq)M/]:&SS:j(?YRq$r,LpL?xgRJHtD_/@.>]sa=/#*;Q9Es)46[$R(q]jAk=:$iQ7U1l.nusOLcat%V<gLbRmj)o+(]jNog`5nkeLTjc$[do+wqdh>9LT,tQm._7hmV6J(@Mv40('$wwRU:Jdp%9m&nfSdgp.BoC1KD'9EdQ;hs._YH-)S?>@[MrbjL>U4oPJ[aSAbRe5pE@TPs#.eqLf=EXI,Wg8.nhgF;C6Ge-ZeHe-uBRw9>.Cls+J5B&i.*)M1xEB-mI=O%<Yb's4Ws8[U6Q+7v3wTM?7'.tYw7>-MV.JM6wL]$^F(2t8V?R8KqLxLTM9[sL3>O^3%AnPqrU.(ic?.%CXXw-OsU*MjcG7.?F410r0[U$5[LHcF>8_sIDKv)?[qBu*vkHrUOJj0pa]1'(F-^Oue6UCBuV>-q]%#%:;:Ac79C&,X7vK2Z:&+M_'1-)k,^IOb-p+MN.*vsk-UHmx7XgL2.vLMH:*Zs=bx(M&c%rs5vn_4W4#itaK]CMOg5atJ3?C<m]K;CZ&Jp&fKEt_&geh(jN3t_wogfVdQBp.rb6l/k]>eHJa<.=&HV`tY4Q91Is`Vhp,aEsj7SptoDvd.5Amw)96ZH.m)dReDh.Q'R^MtC2[vIM:FIq$Bv?I2Bcn/1'[Hd)M-tp[Sakt>gIfV3/EZUs4x+]sA?1s)$UkHr3sUJ:hL*T.b7RN'TQ+kL3Mo3SAG;p$$gUt12;=UZMeBdsKsj4oqK94Bh,?QBFu?RVjlP*lV)_#$[TB_W>Z.htEJJPsLXVD%_HN:H##pkt=G[Ss_abit9F)dD8[3Nh?2U-`T?U77YjR/`j2QRJukUj1PXg[5XnZ,MJmx#M&@<2MoQt8tr7-T/g>qc)1jtW6:ZBBcFQ%FiwW)Zs5wX9V&L.L^2)X&G[QXC3Cah'/Gmn>t(UGwcR`*]+K7T>QK($(/AB*19mjet:BQ8[9%^ht>x@B_-GGKt:]Z4.1FT'T.MN(Rs=Ww615g%x=i]PEIaA6.(QY=Z-R6RF.1D0fCgKuGsF4fHs@*WfLP?tt,E1G`s(@J#*8M.7nL;+@9N[^Zp2nd*.O[)K#-;2;e5`<GsvYFv-Al&8MYW54M:vqNIk=7.(0m.1t6+T.(nKh87kOw#ZMJ;4],b>uL=8u$kUX[6KLPQiAo;kL:+Pe_W,/_o-s(Rn3P;W>tx3okt&xNs^/NKnO#vhD3^@HF)JD<mOLt;p$28,%K3U/jdaibh9`G,Wp)5ZRsRB9EsUF(2t[KQZs.ClK./fDufjvUHsQ<dw)5EiqmRkG=6II8V%qLWZsQ?ZYsqp4=>lkd-)5wYjsRP>B&MP6=>KU-.DSa=YD<q#gDEKu=8uJe0>>hvq-f9xK>Ipo]tmYOE&XI[C3Q8`b.F<)ks#'<Rs=KCh>qUp6[[x$0)ZQRws[.HD-w*HD-Dwu1Ng:^3MCiIVs_8b0>d`F2t'UFE&iSZILq/*j:'CJs@b9FQM]T[/;0/9vd(pO(<Oiwlg=vb<L?Ju6RtMLs(+?:vY*p$4Am;#^cwn8XY0V98SiB]^c'ufn/gXE+)ea&nj1R.i9o.5Zkc3iZs?#Ms(NF5bsNrjX%H)Zwkw7mLO4.;/)ZA7iGY_1d%r_W>0c.Z,)(mD^];QIc%H+)Ws?^ZX5;9onOrQobJ;%XCl%e&S<f[Njt[Ot,)qq)v3-^Z+;E:1lOv^Kk4m^F/_uthpO?[acOMZ>(-L2<r6f,%HhE-TEsMe4sLDBVEscXH-)Ix_vstn59QJPD`t[_19L<#^9M1?<rMD(Cd%p_jY0EcNb.VYbsNvBPh3ZfqhoC[^J%4:PO/@:hlBb'Nh5ks)34^@bbOpKJPsCtZRs2ATxVEDfnO4lbP;i]L]r4E5.(,*b_hXP$Q/SI5B&.r8r6';T^4NDp]sImx]rC?5.(rO%fJf/gn/E1w<c[(%0)u($Cuc$*^%m:^TgsP,4MCt_.t%O=E&'.@p((92].coINI]@l4%04U>tfjkv-SI4)Q>+oVsYhpTVaP6=>,4^.XsB?X.>;5F`&*2-)AD)ot>`GW-U1w.t0W)E--K6a$ii@O4HZ6O44RJH8gWkO4C2P4V[iuBaNv,=&[jLF)=0oT`g8j**WqWb,Cv7YI.HVgt]wn`t*o,NsWX`Gs^x:(EwL,Fs83m[sJ`G+DlJ[O;M33#-l#b_LuGv]sYaE:$8'b))>irfMYx.T%/;,3t_PZwupX&x>?B@rm).:>#oL.wui8mddYYUfsrIPY#R;X4;g'O^,=B]EBo$+w6B-wwuELl;#-YF<k]A;ighZw,)XXT:vjrw*vP3f&M-6vGa1]<>#DKq%vKLX^N6sI+2Iw/f1^=GN/giYxub]Z^GDkNS7Km,F.>W=:vGPJ2Lh?M/`Z*KbEZ#X31C<T:vU@r$vu%M(M`8n4eD(5>>T4TFe+c6jcSx^D&?`f&us38#*^Z>q9D-/]%P>Jc=F[WPZJ-<5&:wW:v^rE,v(vm*h,GFbD=-Y:v%Ti'&Ss/#MW<DR%(25d2Hv#2vVIRo<HGR'NJ0G>#d_e'&fu8hLR@)b;j*u202jQ:v;[.#vk/j1S#b-?V?S*?5SQn7-mp(<k<Qj@tPuh:$MAO3L3t8%S4D7.%A$5=>HBww#:38F`e]0^tdeXj)T_j)Etv(NrgEqmAAKHI)H$=E,T9xntl+lr)#rh<dYOV$YrT)N'wCDm$Qf@Q/:GT9R>bRO&B>^g`_k*4T8`>FsigVmM7Hwl$cotq-_WH-)8ppHM/Pj$>]I$6M4#/qL&*)PMNeex%rsOp.'M6?VCIdERj2&CsC,3-)1^B^ue/NE-YuTZ$ip&+;]#:1'[YT?)_:B$%-1-P5AZT7aV.4N0&vUG#TmqZYB/3,Jop#0`OHAWQh*`R8L^RA%tTb20[PZxIf/gn/5P^m(#G(q>k@;@GCk8<-Q^xrLH#4Osf=9C/'UC6_F;v,g1&:V;Y[Dq[UA5Is.9i'/YRb:9a%00SRc#:;^?ngLUpst,^n_$0hR[$bOr+W%n1X8969@+4555>##id5v;)?'=O'2LFIPRV6,Z5.v/H+2#qp0/usUYRs`,2&iReo[gV6r/cANqUsm^nKW'`NbOvcokt`.qktBs_LKlu>pOSiKx9;(fcO2[W4V+XEdDT$5b@;_FDuClc=lE7:>#0pQ#vcpIcN-Cu3`@i]=uNQx,)<:%Vm9HQ:vE3'Z?pGS`tTr?4@upOPpu9H6jqY(7I=-g;&s?')3]fX,)JNQ`E[9<>#7@5(vT3k@*SSv?$Y$*l%cT-70AQsdt5b0xge6=_Uto>tOuTXcJmrOp$$n'9U]p:eOL`/jOd,oktmm:@_3WGxB,9@fO@[[;TOHQsH7Q5X4P_b%vnl)G6[?+U]wt-cr('=>#;obfL&gfJlH$t'MWc.<C_m7<rw3'L87N-j:/a12'D>inSclDZs5C(#,,P-W-UcHE#]m)'8rP/LVc3iZs[JQhK*:?piUto9dv>-s.FB],)'wNn3v8#r$NsJr$ipMFi]XZ^VnXj=#'.Y`tuO2q1Hra'a_d:^sP-=C)o$x<VSDL+vO0?hg$DiX.x65>#7qc&vi?RU1ZMBNCn,<5&s7<>#5hC(v*d;HC5[Qo$bdDqLj73K:rkb2-pmpt5=5(JsUSc^t;AIHj,U-^O&vQ?;2Zoi'X]Q:vK20#vhLv<[GSavO$w2bj$5^rG6<,MTsqIx^k&'3)gMCXsKJHL0/OgLBnx?I2>JfW&j.Ertr2Jq)*$RRr^/LXs-AD6j:1vq-+G5bs3ZOE&+e(rZn6TN'aHuGsiTrw=?KfuG'[_bt?ltitC0S71v3ie_1ZAe_H]&vt2ht;.Jmm8%.+n2(W6tDMDp+Dsp^;L_f-TgZZOsM/VWh:ok@/UP,Zd>%d]GX=;Lq06/toxG$c?XfGX[&M/jjZsOxKEs/GT4&,+Goug(d^?(6A8UP-(K%W]4FDPtBK1*m6cDtg1-)nk1-)p59Wg0k,ar21;m2a2#iR'&+Ds*]hs)t2HL0c<9i>;Vn*)owug;.>7MsQ:qEs7%0k$G@wn%4'nS15Zp+%+B@ggZ(om/hCt'*Zr)suJwgC-rrI/M574@=1nFd*R,<jL#6wBXt1C5M%/AqLjFF7O0cgJf;ea6WZVmJf5LsQWg9wLCT-,)O$*g;-KSx.%l$A[0F^XPK$<-)OAgha+26c:t+a3XC`^g/)aIl'@f,F2CT'&b-5c7xB%/nt>cG6.(r0NiEw9KNsdEWGsFK6m'BR7SEjhD5VmA#OMvcbjLg]_Es]W_p$I]9e=/;Z1QK=tfDi+Ip.>x7Km#rX`[dEeFsRm;$gnjLeLBe*cR>dvOFt?_eOlBim*K=8PZh1I-SAQ`S%r$vDNJLZ9X.(Zn%U/6f(ILh]t5V&fta.?(dC'<csQ]($uXZhR@/v0=>0v_5M3&EO^;b=9..N$sZ+;.<-uj'$B_un,)p1kqH%jN[tWDhVEErvTDu^AbGaC0GsM[*(47]d@+ugpq-JHeIZ0LIf%2k*XDUkTSL:ShC%sm&+;l&wCs,ffX#pc.1L?>oht_e[<&$<qv$fuOh,ZM+wLM/h-UR_Ph,d$+&uaX6)Ivi#I6A5bk869%cD]($K2$Yk'8tGDrtedEB-14V[%*t>#-)t>#-GfN&P.iRUINmIhiMq_EswrLHEB%9Ps5Q>IspxrA&G(Ku5>_T`n&)DXs;`%:HkE-Dsb;dw)P8>:Z`5TL:=o_7%Bn%=Y$AXh,o;Sh,]*g3ocIHsILurqIJLBN0``^B#b+110i]5]M0Vh[O]VeA-U,A>-)'650iKTv)5IlU?s4=f6L0&+;)>G1M@Lv*t'UFE&qe7*nB[:j:[X5L,Pg/o.ET/T&rk4I6'8YRsA_@nL@[WJsxSJ=#&)F`sL&QI:$HFr$5E;o7cO2F%O'/f:S/Kr$]hPQs8fulL3prMsfLEko:h]kTaY?ct9kkE&xKoeU&F.NMg[m>#qG)[%#?@u5mAfgPq6:827eQ]L7D7`XUC(GsfLdVs#VdVsL<%[sx^cFu.M]nLfn_P'oxEb7+1D>^Gt44Q;$['Xdv?eshXNWo<p@N%c<C/e'Y4oWna_W$[4+:<fkGc%7^7itQ39/;cbc9uR_=OMWkgf;Ti9s/P5'R]b]777BB8HsLwass8Zf#*^3Y0hB6`0_r&Vp.qZbLKgIxP*_0nlL-$Mx$;UJKs>_<ssVq)e)QevXLj/f$Kgamvt:X,]k?KU:vGb2wuFNKIRXh33L+?5ipA$t,)$1k(4+M7>#:AGuuq%Erd=NUg(3SrIhWQ64)+_EI1(V1.1#v9>#fv5oL2%0@Ql3VY5TlT:v_8Xwu;7=WY46i?Y/S_V$DM8>#cxmxuaWHElsB&Gjpsjo7_es,)qL7h%@RJCaV-YeVUp5HLPPp<ldnlYsN)`Zsgu#r$+G>'t^;LF&UWC?pP.jqHo'6YstnjLshIpZg*4YbML.3IWbjPmW3q&x=OFa`sHT2&b&[/W-8HR$9S%Hh^h.T58CU+&uFPP3@2sxdsToAn.bGc*Vp5&+;d`i/YchA;/WYT?),f1J8$vp/)OlHu#``WU8Q'O$IBn%=YD,o,_i+iFIZYc7%8*EjLthYh2t5$$tvA,B&2ctj)It8XsOkkvcPIWDsJkww#3?827(NFo$VswXuH7xg)1*SL@6;E0;Q6SN'MkYQsq9bUg=K?eq;aV$YJ?i.=@K11pKSj[5p>MU6MT6^s0p%31qcvZsfGMs(J.gas6Iq@%Y`n%>G)*K;uU3LpXe.v?/Dc/2U^m.ML%,JIaA6.(2C&MNsrHaPQ#-Is[Q%qLmi*<>/Hf%u4BJYmV'xcW@C;bR*j6xbAoV>6`b]A,E)^dMRN/FM[E@*NdIj$#XgQ[BeXN0>1xV,<F3fnLIH*^-Q$he6'K?HLxi>j(rE2e$uIT)N7ov##2i]e6C-re6HRpx4<4-.DAd2,#eORhCYwm&F.,R7;^su'*H?OCNFOMQAEwRP^e%]6'9*<jLCX=e`=mEX0Uh/v$tN=X18n#d,9]@I2xG/I?g/JcTvo-T.(@cls#/oB&@m?I2<cp_-aiE*H,m(d%0N=-M't;@E%m'xREx`i';9a/MAgGWk+`@LsXnR+%3SUhO&k#D-I,Kf$q_v;-[Pu0.V6uNB_x(7<]5YaBgO.4=#osZs+jm*)tRvTIFt%S%9a'P&[q9PsYtr$#1^;.C%'2-)N@8ptL(/Y%L:6qDCUhkFCH410.bKhLe,:kLeL>gL<DcDs6*1.(7NeCs?j.;Mq-d0L:ptwNkRre7egp5/FQUA&dvl5:FCO0PZEH6_[;9G.a:k%7X30aX7CORJEDc-67'F3Phr5'd[;9G.aC0A7X8K&>ASf'8,=`jt^ge%Y[:Yw7jp0B#'[.V$rW(KD:QgnSm^L,EapsNP?*Td+$(^fLge_`N9,['tR0TZ.tij-u6DGJ-]NBG.a7e%@Uo*ds]`=r)K90G.35I4ArDp]>E:4W7Sm,jNo0o?tm2gv.lnW.(N.?3Pa4FBoR%7.(feZVs.$QNs$?c*VjLhF&$=<m)MR=c'3.s<-Y/E6.`iV4AW)aj;v$B[s:/i*+f,QJ+;%U3gE7TPsuKA)TY^MO8C0uJ1m)sXu>*jm)^nb<mV<h,dqFNZs6%4Q/]6?<)K_jI(ql10)0*kxuNhh(mI]*hBP7wAO)8q1&nTgVBjihkJo,Aa*J$kp.p0Lk)@483M6]0h9gZx4prUEN0dd37RenjqI8V/W9,UtiC_>YW-J8naGCFT_4-]DU2tw)-vus>s/w4U]9C)aG<BMs;(Y+6P]2bJI(3RJYsXRa6&Cji2E'/cT>ujXU]FoFRsbGdYsxGR&*D/N'kR_,xOP9bLC1jlSf;+rPZcd_Hsf&]MsCp:B)Soa$O,ge'8MQeNOkQEM=pgT)&a,&F7r'2`.H7K^f_C0A7&j?qMjqWJs5kN$MLVKhtF]ht6jlRaEpdGGaf*'7&xg=e;T9$;U?S(%Mtp$x4WZQ48QJmn&rOg$9JEnvt:q6]G6<P=91mx#MaI>_$_35R3lrb4O:L$qL[)Po7bbe3oCGwGsOi8f)au%uE5XI+Qx1up>wrVGs4SnOri.Hm'3mKeH7`A*uk:YwPN_$.2cR4N0</1.q6Z2-)<`;HDb4@MhcVc8.r=#JXa$/v?[&10);M_%+6nCe6RIe;-'Wc_$^V7E&ZQeUQ%MdWs.<$Q//t,eMC90.(5p$dNl$>S:jn0Ps4_o#*%vP^tA@^E=,aeAGoGSYMm&n5N4m?Ys3j8A&D:l=SwhaZs6Qcq?7J4jLGT/SsU+CW.+;^ItWOq`$#lsL3-YvIs-L;Rsv<$9/%@'UsRBjl*3<WQA*;E,s(;pDs_2HI-u+Hs-H,n`A=lP6:&$te$s>m*)W]D6fW2E6sw%Q##D#`OA%'2-)hU0utDsuB&64KfL.vOCLZhRa&:#C)EQDKZd)C[Vs_&:[b-DX(MDO<(t@gW#._OUEOtn$X&vrMj0OA6.(QJ%Y5[USN'<#(<-';B8%-ecE#gebLBaH%+;@YKh^x51Oo&bTN'2M/)t$M>WMG>=Cp_Y9MTBeERS?G&X[<`oCsXp>$$wLXn[.^2:)<3G/f[e<jfig1DsAoa3&>qDetN.1]tmCLv#rUP_XN>ruZ%v_8.6iXX,fx(W-7EKR*K^lt>;s5=>Da-5)be`?8ghYcaj?Ss-Md:*MNUNG#nK/=>LoSk+vY/ENgtQlLh03MM`X%:.:aT4/@EZ`t$G%'Mu.5G-@MArLv>c[rC-JHsfHM.1qD67Jh((_oiHbkM*Ho>-d`HT-Jkv5.S?ufLpE;X-Vqg6iG(-Y#0x[e%Ef&*tNgVcM5hC3t*c@uM5eB/f=XuSfsk8;Z^OLdMr,w^t7X-T-f'3#O^9ie$[j`B#:FT#$940v)#HL=PD$Y0p)],/:l';/:=i6:B=aQ#B?UkCIs>&b$HPUeSHRFNY8-sUVeK:gLN_.o@PjZ`tiFk_Mh':o-xCqWASS6X.XuUG#r?[*.i3orMER:h$4(kviZ-*c;x@6bR-,;Q/5BLv#SWP_XpVE;R@.4N.`++1LTJ+'G]x+K#X+Gh)n)d<-PB2:%TgTl)c]'IV`SM=-WKZe%h8F+;vNTN'L:##=9:<DsO2WX,,+RO&KF`0_AFOq)JeDJR;7UvGWJ`mN>$TkO50YdQYY3_S$bnRWh5ERicA#iTY6;O%ZM5V$BQ;b72uG=PsVFdAPrbH4:<s/2O9VRs*6mNs:_%Hshr]h9jhG<R%v*Dsv7c$*cLL*RT[Ir$6.LFiL_h)3?bNgRFrXoO69BCCJu(4L)DDr$h<07@U&'Ms0'83gr7liCTcQXCEh)b3aP)FiAsoeA^53OUkE-DsU;dw)ied@+1E7@Y*&)W-$PM'J%k4eHdc34Ar]7brDgMOsY_iGsY[csO:SVRZ+9AB4G'Go3/*,(*P`[[s[$D4%]Pbgf(q+cIh?sW%Sj)Y,P6r_EqWY$.uN=,%DVd&MMFa;tND*Z1Ukw;-HQI-b$SWeL01i>5.W:L&a8Ms(Z)1.(MYp-$^C:SsKl94Lo,3CEUc3-)sXe1'bS@.)`NCl/0`'^O;g0Y#08ZlE=9`MN3xm8%8`c^qh1F/)BwGbVGcOFiD)i,).Z>7%DI:Yn_TiGskB)mfw(Le$?l<.%8JdRV;c?,WV#P?gprw[sQ'=IH@%aF2[1U0`=IUCEQ_@$rBT8RJi3<v:8[-LII11/`NI3j0L1MCWG^,CWu*vI:<1&[do+wqd5V:7%[&_-h3q0</4/E:6(l#r7e^w],3m9W-uEVd4,:1M%[*nMQIp8smUUv&-/)oZg$10TVkd[[sNG]VhWcBw^Za5=>kG6LKj2QRJ22PcKE4lwY@gfLZNG>W'T86=>Z^Sm'Ct[nLocQj:?HLRuo'[G&R6VQs%&YOI+pINI/r1(t%O=E&N=U@FTAVN'h&P[7:NM^sFjq*M)KB.*)JTI:X2JFit$-Fi)3AZHi/pk&(O$:TxS/(82PqB#I%KEsgs?w#:P0r7%,Zh2*_%r$HNwI:&j/Esf>hr*jH5V8Saf6EHUJX>^'6@Y*%Vb;a:.T.;_WO&CNs343Z6hC-VkHr9A?d)qBWO&jxGRI1f-F%SacI%c2Cfs7>Bmtlu`=,aTc^t&((@O-p&Fs[tc3uItDL%3Si(f6t:_nCrF(.k-hkLjcs/8e.al(F?0.(wIDRI4&0:[Lfqf[,%xUL%)WhBeO&w6+f#bsrln?57V%3qs@3(*]x3-)ZLi>[%BrX/u$8.(g<VXZZsGSfvibGM@P+484xd8.US>g)pT06(0VT3g$c:#mMVfwY<X=>Z(B7s.vPcA5d7$l$`C:E>r9a0_FERI:qLdb8ISF<qjVn,)i?iZs?G9Es*l_.*e)`-IBdRhaALxKs3^?W%Lx/L5R6I'oae93;=evI:ln8U)sJc-H;[$@%kDL+<a8eF<]W+O4VtjM<'t=<8IIED#n=trZMcm<cV+KPn0k2;lGpmVsG)/Psk[rS%0.`G)D5JZLvD:jTvBrqVID:^s=]#.C6qsX>MvXYH)ZjbIA8_ut94xPJ-ZNfH.V+at;vhUH&.jt>-ccfV$CVuU>hD<%W><R[VQap>=qsL'jni=#qk3fHpEvc%OvX2T$J+GRvVQ@F'lC_tw.)Xsd;]nf9XVVRvk,xTAZennL(ihGn?Hc%pJNn'PQOT89H9j(W==S4n)N*Es2$UnRi4i9.BNDs9%S0qs1Oh8bc6L,f&2N'&6GPsah/Es(d(k$Pq4.(IRD=*<R9Es9Yt0&.DErL94urLd_rR%T(BIMNfTlsQU#<-gdOo$`,W1%#3fCO5-(1MenI?t;2BC/Dn,bskH`NRMj`,)dh*.%hw5w%-p2:6'07ZQ#vE`sUrNK(2/reU>;47.FOP<&KD`n@TT+,WG**gLe#5$M?%S$tkKFF41Ff5u`k?G&O-VCEZSVN'm1U&Op`+DskUEH&`Zj586$,Isj^w)$kd1br[VVN'X3QQsvk`8g?T&<7k[;EIdJ6.(LxSas6kd-)COZ?t)8)f:fs:_t'-;r6,Va,)tcQ2&J(p,)ol]@=DshC*WZFc%B<vt,S-QbDo2bebXAj;&1&e-IaU$r$v>xq$&t(%+T#KEsH'P^%s[,%+I>A=,qI,Fsu]X2^oZ4.(9-:+M%w6vtk+sbtmv$M5he.CDhHX$4&HR+)HvvS%Uwtt50.e'k8Hoh'm$P4ArV_7%[379-4%`b.MlTQsWKeSs/?UHI5NPI(Yxr)eD>roCK72P<)+bjtcG.dtTRR=G=Awbk&l'19%rdhoZehk/RZa7..rkCAs)NPW6PY6YxC@/SaA7A`dx8aAl5m+ui9N]H#U`^>cjk(b8E7hdm>Jc%_nna6EsdaO:+D#lgoY()2P/R.r+b<6Utv8@7%PQs<8:MsS-]G`e7m)-/BwD@A-i^sRoJf)aRE5<+Rsn%pM+]Ww#-GsRaW_Of-Cg@+t,bsVVVjY>/&^kM>k@+';N)u0/1$%2<w,_9bQ^tX>clsIOToe`'jU&H4;O^U:LlOT2X9s'Y$r$H1ba%761.(7._,)gxu4*2iuq$b,m,)LG#l&/6i[OsECutk$1e6Ah>tLIKihL^@a'Wt0dI:QM1pO%2;g%u7jq6V__f#i20>G?`2GsDBfr'q%=gL/m_Es0pLs(FUsanf('u5d44-)T94-)qeVN'gTQQs9ETIp&P^EsWZ2U.:i@3qA(Ctuf=4-)5lVN'2HKn$w#:1'/A61'd=27I<H2r),B@gg+A'%NS&A?tRL=E&DtQ@F9+T`tXnxrL-iBnfmr]qQDET*I&sVN'q&?7%VoF=#R+]a#KoF`sWk/.(bLB6s@vb]tx&w'8F[qVZN[N7a%][bTMO_pOgrlt5,78;eqTFW-<bU0Pw?V0P:(0sLf^T?dwSJ]tZDF:r(2pkt&B`^Opdbit+_pF)3h(jO:uo*DK[ESV9;92s-v&K#cW_D.7/[w#rImm'#h^kA)+k<LRSc^tfh#Ns,H)c<mgk<:@T<Hrht[6s%`?q&1]SeC1731'RnBe6<VV*Ig4.c<omvS/goM(?^='iBv%m<C[.2Gs9%WL'lamiL-llgLjC.JrW2-N'WUDa*LP&E3U?ubMkYl:rm(x^sp(Vo[DN]qHniSd2N;nw#bJ2FMp2kG>mT)iO.6hXTju-H%8]X0QQp8sm*dA%-iWVqQE2uOFJiAb%$$8-v[_7aEv?PSE0<Q101cuR.W`ap-jK*8]FfifZhQE@X:A,B4MQ#DK3MXoOB_%Hs.mSO/ortKrso^%uqhqs)v`3QmsFkOX2wCb%*^k>GQl:[BDi>6:R3(d*aUsQ/tXD$t06@qe$:T,27I[0qk#$(*2eS.(18*lAZO;xHuBlxsj]gIra^0N'N5GPs))c>#xgOO19/[w#;M$4JfuVN'w$)=:fss<:k-KI(('Vk+,;&(*XMS_8KD,bs<u,D-GL.U.?D9Es5c(H-.Op$.rU0hLXXi^sOFXcs6L1).F+`MM:V6^tIhj/1xtJgOM'TPo:vvCsg%@A-Crh_%C'07I$uPd-px/EscA*0pFwBw,7MFO0.$Ec%IHi&1gxVN':(Rx-]oiSMIeq@-a*R]-RIFm_Wb_asmpBo.p=_$0AlwL$NwP^tQJ1@-L:sE-=01[-mtcq;s<2OLCo(#laj;W#O8P/$H`LDdcMWm)KR9Es,'b);0Z<1sL+iEI`>6.(Dc&Es'ld-)Y#.osY3CF&BVP+;8,P7I%qwE=q$Dk^_>09nR?4`OY5Em$p-eh0dlqI19K4`OZ6[it-h:$%@Su'<T/*KVg%I;oj/<W#gO0,..(j*MgICbt&67Q0`&:w,eW1aB[meXAlxSF6<b&u$k5'tm+6Jc%j&3?ovFc$S6HSiQxD0pt)Kc#[=Mxv2tOQ9;vA#PVH?pEsT/<)iAQ-T%Z>ie(DAest78`=kgx0aOe$ZRs_FH4.f$>oE2Kv`%Yf%8ognost@=171&d3$MM9NR%Pc83PH-[qO/$rktCd.lA&%f&6Rix;h<ig)l%I^UFYn0B>UUin/<gtXAm7wYs=U0(*fe+b$58][sb^;`sRM^v)5sgMTM[Smlkk*9'k$r]tOgPatp'AHs&mQX5pd$fdcLEp*5g$01G7L7_p.`DsTjP^thZ_X%Q8.`=q-]@>A4OKV*_PDI0O,k(433<q3kd]%uGDrttZ$]>)MZIs(-l,1M`qioxNG]O:Dc]sTK4Is`uwfL%H4GsHGX3LmR7Xc'C_?%f8M<LR98C41d0hL<XS:Ld6mL9e)n0)L1qt5T^+P&#DV9L<$EU/XW3.(`PNf$cTR<6Xjj$Y;ORoOk,JLOHO[(%/mpQVY5=)r(?m]sM&Tn$Mh6kORv3kOou4kOdPb?9C*P*=bd/7L?ek,)V,`mO+AKZ$1I0-dYj#R/a:C$%8KU?KEMW`t/i/gL@=L19WT)19Tfdt.B#M@X=,N=Lvq/N'FYEds.gxHo=4w=ch0Bm/)@8tsL_XE&8>2q%0]OT0x#*RsA;qEs6l+[$P4.2ur2BI&:rw':,Ux'/+ulQsuO81'__`R%@,oj:g:]stwH6I`[Jdp.,pINI%mw^H;wbdtL%:sLws[UrL$%K#`n;Ea1Q91'klcIs^(fn7E7[1'9uxeC^G,F%_Hin75ou6%Xg[RsjO<Ls[p&r$oMrCss,`g%7&NI(_*q#ts)2ak1sxq$eu@tt&^6f(-Lfe(kWEUH1mdBl7]g)j*/i_t5Grn%2x^U75u.^,+%aebil:>N2(L6ALKRI(ufd'N,aqHsQo510ZO.+<nvL`,BeS6]@_ISOa1[10BBdhLlZKHscG30pY?Jg5005J.g#[]s-4,]4E-/R/DQ,N'D=EDsJv3gL`Yn>#kqNF)*/khq3EVgLudg$cf+$r$8ARN'NDp]sS79a3jLWm)x^#=P?k>J&=5GF`ftSN'FMkV$UEOEIVH9Xs2`__*UlGjseC;;V2iJnO8$tk&P@tcO3M[72J<O&u1M'IV)->Xc'VHf$q5<0a;j:baje4brE69)SF*Ic%3bkfCZJ$P=LA>Z%h8];M3lLEsaAx_O;IR7I6X'L5=H)L5G/@;gRH8Hs9$,^t7e0,)Z*9isA=d9m8W_,)[Rhh0ZDGf$LVuL0Oi'J:?Q5N'O%Nn36,9L9a[i8&5%&73NB07IaWOoLP]_asmFw0s+wSMLoFmQ'g4GPsiL[eC4OFj$2J]wXNN-xXubWwX+Z%vthm>l0LlxxtDF.[<X2_OJ3XOv6Reqf:xx`Gs/9rrtAxgH3h&J8o<u#u#]h>wtJB$V:f`g<l&(jW-7(BqMwqJ<t9D4j);R%cRx^0(o`E$Z>lFhXoEHZWaf1l<Xnm^tV]hv5:igYm:)[8oDk)D.E_v0a%T%'H&<^'1bH)3eO:5?l&vkcpOI&b/Ha'qJ7VjGx+6SGx+Y.:Z%a&D8eDxo@jlw<e%X;gBSlb:)s5p6>eAw$T[,nmP0UtnW-HSBeQreveQ'YIf$-rNgbo>>pXms)c]1RV#U^RH.%Ew%VDnhYWBLJn9B#.OJ-KUmc%(k>9FXlFc%7V-8[Hm^@TZH/hY:knw]$*V^@b)_4&:Ujt$[?n1_YxGd%4<R0P9O@,ivs9MaQupM^MuohtLn>7=%%WGsIG6S['oDs-ksLQN/I^%6p%ecVO7^RsG6YFCM[&g%@B2H&#-J=#wvAiOx31Q:;n@i5AAq1?WwN'.7#$)nQ@kb%(0<jL-GVe7etMkMDNuLst,GhNRQXWsAI^D6/&Z#WCEbLcD/)Y^>?w,)tYUXVPe-qOLFRqtri4^%0hpc?'CV&137fs`$6fOba^0kOnG#Q;rDwb%.>@h_kLN'As[s5<iED^8^7IaAZ2v@/tc1jbSY&c%eUeJsJ_e&MaREZs^7/wsiIo?&&SIf$)UB2:#+HncG/8ZWZk._TlJ/jr3W@oDj/`IE[p'a%6Cb$X<AT(%Pj]X#3pdueV:&Zcqjtw76=greSDUMLh;6v6oaN41G(Vtg<vmaYeY`JZVtH&T=WZ*8$#j8AWa#'I)e@a=LpO7I(GAkC<8P<_XI[4/a+3N'4(pc$wknk&.TjDsC=RVs*TJqdRlEHs0SRKsx[24/8;0AVZZ[&M;G/kt&,G#uMbtW6/xUT&;+$u#[.Wh>x%1FsFA3Hs<-qMsMQjG1^3OB1;9#ft2fC:u;G9Es'YNf%U4e&MKpp[sa]<Ls+OD=#sJQ_W%*C@>,^l>%JlwqdWtKKgAxB=#up[nRtPWRs4DkHrF`(4%/fEnh,;X6fu8(TAnw<RM^IZitFoGJ&a&1fsdGoN%+p7a3'+;gt7HkHr?vmpeE4E`sJ6u>#gvxr/])(v#8s#u>gLMa%>6Q7@<;]:-5](a%:cB=#0Ppn.P2ADf-j51?gR)c<6?3W%<nrZ^9Gj6eeeZVs7iOwBr^OIsjbXYbIPTM:b]Cbt4g)Q0ep?bO1ZA?3Ah2`%B04eHN2tq-@=Wr`7QrY:pLSX%LN&2nKk_YVSQb?IqQ6p*j'kp.aVV*I,Pw9)_.FOsR0+7I42+.ud:aRRD71lORp0:?Q0pF)i2i$uA[rcsG6Db7EL]@oH)]_8sn14/C]'Fs2#jOs6-U:q3%GDsg?P^texkL9SO5l8*VFu,.831u6MHf$@cO_.7m)#tjetk3o#Eh)6)lIs^pkIslSKr$p'9isiA87M>Pg-u3.Dh5Kjx?^M@&Xs2^b'aH4/30vOH+;)Z'7IGDc-HE>D4Jm(v3J<$MJsr;tttJxm_saMfk8Brfk8)Cf]bnwlMV*_PDI'/,1MF78FOE$cat%hnGs#WqJsOXF`OvP6ctSD6ctT)NR70HCx4[W(%+u/eb2Ili[$GwngU*x6q&).jh'j<Os(vHLL0,U&U@M]$=H/[jv7tfj>9h[[.(RFf,)DY[XC'vEc%:&F.nhQXoLf3H;@X2(JsUtGO8/S1v^?mt4XUh1+V4]t7iMi&Ps:n0g(Crq;-snG%.,x2nMjWR+:G?_-6(')W?QWv*Imp1eN_8/GsDbOU%^eLp7xSVGs,DjqOuA1&UY]r<%8)b3%'^d-IEs=4&rhxIF.?LM>TIYIs'o?+SRK[qOW'VxML]UaJk.i@BXv'pL13vA%Y=l#><Sb%CdrmxBSid=CHuJb%HhxMKjiDGs55Q4B#qI1C6*3GsZL?W6+pINIIIVGsUR?Fs%Et'*GMP$cD8KI_Zr3-)fs:dlXd5+)lk`EI?x<Gs^4:w-a<sJMEwx'3=aXk^R7,2_ahGM_E6[v>I)/)ttLW1D,O,8f5G4B#5&EbrT0h`t,j1d*x&Cv-8&3jLXxBL9I3K'-,ia-IdW[U$7LUSi<`oCsAY_pf>l+Ds.NOn*P;_s-+^cER]bXWsPMCUsvNbq2axWEex4gCsXns6hg?4i*upf<-W<o>'cH6.)kZ4<-U#4b$+L7?Pb6o;-2Y2CZIbRWAd[$'tZ8Eq-F)9o8B7XfiKY(W-Nk@o8b_+Y'0U=S,/^x4_<`oCsvY_pf?uF`s:?fq)J]Q@FD6nDsbN)AFc;VR<%=310@$91'/>sq/5'*.)J=Vcs</.]%^BT'u$ir9&X,,<-9?Ll1:b210aU+_FqQ?C+wg>%+f6bp.6E14oO'RpKh=W:/O8IEFwW9SMjY4&BFop/)E_'o[S/ss?f0+2_d><Gj[TH2:n^Js-EY$FOk)3le=>^q[*JfL].+E<-`_h@-Neh@-Gosj$2]bZO?`K4n4^Th_`q(/`RoBZ5.ql1ggS+TsOS5.(&0)0tSI5B&:x>:vDcr#>aih6pEAZYsE99[bCXH-)Z1Dcs^(h8/Jm:dttJHtNUXt(M3_$TMT<#TsjvJHsboof.g&4AuZRT4MFn,D-09(@-^<)&.&cNw78+`Pg)RN4M_hGw$#73104E5.(U:(@-t#W..8#i'8I;]`tBt+^ocgbWs]@[Vs-k+:2aQIkOhfN(A/pR%+iG6H;_-hC8'VkKYp&_PMm1fVsYg#1KkaJgNT[Z>u(V_e*$bqA#C.[x-hQmIM'3^k$[+jnn;ws<-MI2u$4S2oLQv(isV#o[s?R67vo0`0#RY9@P:i[/1vAXY#';Fxt*WNH&3SEf%At<j(Qwt$/^4I$uQ/+RER92#vC<8DLLc>DbnUs20TsvCsrgd4$WqHN).(Act+?I;<*i=PpK>L/)W+[0)qD67J2GP^t0[2mNUlsZs`Bvw+5GX#$v-YZ%4V]77c%FB-qY4?-.a+?-LZ)+&MQ>b<HkpMh&QaEsHBZ[$FpS'jj2QRJ*]$4C%l#0)2XDotW+$D-v7(@-^A(@-R:/n$%:N5K6t'F@`GFgL]$GtZ_r_PM(@%NsSF-Fs%LL)0FV-+2m+CR]&k*R%]<PYsu&6Ys$O+:2-1o92_nv*;RKK6/_KJ#*Uq3t?&-**,bOgVM-=X1'd>4$M>hA%#bh(VDw:71'@o'#]?49g%sTtM0pc010ann?5:HlrLHb8%#NH#`JuL@6aR*P7IF`9D(XfDvATQ61%Tf110N6.k9R(FI)u@o6NTFc]scEfq)UE?qnGZPIU[rZ6o5]btt-i?qn.s6C@eSG%0N5Fat6#KEs,?373_#g&tmg7D&RY$Ou-@O=&oxunLeS[%+hO39.H*SN'+R<n%Sh1C#bR$h_#Djq6%v*Dsl2IE.*O].(5fha*(5Zs-7OO8M:IA#MH`4rLTwRiL?p`fs>81`.+TrXuC3+Ri$%JK>/mr`t`k:HaN#B,MSMI&MYs00M?(2utRJ6?&(uSkfteBX1&AH+E=e]6Ep'310:Ux'.:BCxLgC8D&#GPY#oDSb-Kii'e=chwMC>aNr`LAF-X1XN.3m*(h=S3eNW;F+;%'2-)eMCns;)5(.i(b8PdZ[NsV(Qq2=XOI(2hH)ke[:>#k?fQ-LNZX045GPs_=EDsl#Bp74Kf)X>l+Ds1jGtL=c5at`FY:&b^LbZcsOWsEb:^seA0101E0LT`J+F.B_hut:jrp)u9(['iRHX#KESBb#R.UsF7H[Fu,Ks-t[EUEqJYpo)C[Vs[s9[b-]xf.Lecbsm&_4.9sa$Mlx0j*xd0r.%U^Ms0kra$2kP]st?i9Dao9EsER7f$;KhI(0)RN'c6:w-sk>*;OPOAYX'%IQSu:C/eiUtl&#U<_hnM=GCCIDnoE>GsVSR:0JcFh)ZLGeUklKU;O23r;s5h5MB45GMdS4`s`@9C-wLo;%I/,K#K6#bW>l+DsCk+c-RlgERD8RN'A=q*.FZn>t/?[6fD0EGs4L;Rs%?Hp/xGmZs[jd?&(qlW/9JZtHAT`FD6*51)B_IOS%'2-)$5wouiK6?&h:5U2i>6U24Ss*@v=T1tVnZX.>)5bu.P_[-0Rh[BCEFs-]<GhL<S(MsdGII-bq4[$K2`,tR*+LYSadNfYiA;RNi%HN#2u<Q-u0W.IH]Ps_t0D0]Ad-Ib#soiatoZpl'SHsj3fHsfK#x4:D^3F2PZ?=@@ca*'Mam/0O,k(E%KEsrp]c$[R.nLQx6bs@%@#M[Mf9e:_Em)PkRwYr6e9ebdq@-Q5gk$9?/F@RTqE@KB$F@/Y/o@Ieg`tU-6eMO6UW.SVZHLG[2E-^T2E-QYV6Mvk2ns:^?X.kb;)tmW2E-)U2E-:X2E-VZlK./L2Kr+PY8&ET+&c)v,'?89PK.:=XaXpbAGs2&P,/W[Xit2ooO9^d2W@9u93I6]'l=EMW`t<ZfJ.:q8'F?IO&,j^]J.:XT^YLGdJMx[:C/iA*Ost?il*E]Q9.L&ZKpv=RAY:+'UMhe%:HN)27JPK=*tlY2YM;xO_N;CcLsqIUk=]2p'/jJEksWo]wOwBVZBf3hCcHvVrZhY4TsIx3+)Nw?4t#K6?&lH;p)[WIx%Kdo`m*+'[s$EdYsD7210bc5*6<=Zrs+h7D&plpv)1^TI;v;5>#+WN6vUQ1&f-@$$$d2eCs'@k'&2V]q3(Ukn.o7TO/=e:^s3Spvtj.Q:v2$PvOA2@Sum4pLpR=P:vM$(7v9]([Z6#S=Fu$31bXkUZFe`=)8cnV78i,U>ZS8hCM_FQqt,l+K.CTcn@<2`m&WE6es'>`EIlN310>b31'u<KF)mw31)Rl'r6pZ1-)k_1-)cBrk$lAagiIY)ZsG69[b$'@XCeC)$#QncvIm.wHL_E)<JUtYc-WF2.HKB<Ds-roJhqD67J0B>naE&N-Z0^L1NQmrpLD'2lMYAaNrB3s3kU@aTAkRYSsp3mQsUR>l$*K?MiC7CU2p<2#H*3ZJD/P33)_Oj$>QCI7PK'qPUg)>Wso5DZsZ$310U0[w#bQ,+MSqm5]>vs=0e=a^orZd);W);9J.cPTsf^&HsoGUp$JZ//udh8A&&&3o@FH+WsBo=QsoT,@.th/?d<FtlgH?Nt:@qhqZGpq'/.Isj(gJ`BOS4OuLg$<Rso'CW.`ThNspA9C-oe2m$._310j2^(IvbsJ2DZAbRuGDrtbsQ+HiUA?phPr]sPX4?-vS+?-,U>[.#et*t/l2Y02jAUQ3LW[GO6)'8iZN/i*]^Es__=?-`ptv-C1TwMr80htk,6eMf>'<MJ,0kpvWXLs4L;Rsw*CW.m?LJs.Yp$.b6r)D-`Ys.Cg@(E7j7s.io(T.KMi(tVVg$.a52^MJ-q(MN&G?M)Q2AN69<ehhhqE5q$b-I^TZVhlH6`sA$%)$bQ<F`4'J#uWk<0,TGNG#%,=L,Q`i3o;F5at^Lih)=+j^OCRW2M$I<mL`)?B&VdM=P@Ru+j2V<Gs8nAv.[EaLB/h:f6AE410PT[$nF`F`sV`Vq%7(E@=Bhu+jjRUZHb@wYs[j9_a7v59.QA6`3)ALgLIi_Esu4Fat)em5.Oci^Mrmi<dT;Gl)*P-HMx7]6MkToYM5($uY)M]>KJ-))bI:r4&Ea.1Lh]1xJPEWcs'KOV.VJI&*OVbP:fr;GsU/m52SZWm)eGk_N7jOL:=o_7%7P7jqb.,X#Rio--rQ..-rR(FiY6U`tAvsv%9g010aCJ'F5=Xb3q1eK<TqE>duV$6:A`>_L%d`xHT)bU$dJ6.(N*p^o.8Qe$S9hd)WRH>Y3iaW_>A`^O2q+sOg)WRsg`'V4hch^snl0D1[Z@`tSSVbt5.=UIRX3.(h0pVd:VQr,Se4(K>nt]t7o@hX4mL1J;j;c7@Gr^:I2Eb,*1/cQ@=CN'>9gk$[eRs-1p@;Micg$N,LNZs9V>H&Pu85^5>;YpD1MUsVQqQWl0`tP<x+CP##/OfwDaC;_:dG;M@tw;rh0*3IA<U#.+U8$)$M48<:2^t,>3H=tolIs>DX'XEZ&4n#ld-)$gO2t$vPJ&v#_(*4x/,PKD,`%#n&+;Kd$p(h@Gh^u`-5)GwnDtlN>B&c]qqmWKvb*:u]<HR-fP^B=-FHCeXa=p>CLsF@+oLmSC4Lj?okJCn/B5`?Qvt^^W#.ACRg*%FfW-7[S=h[96)F/s=L`a`-LsFb'EsbvZl)(B4hqTg]EJfMMn3GvpHH^[/.(CZ8&>&^5E4@3+*t/WW>.OL5T3mOV/)Om(H-j+Dd-eu<qr(C')M9v$JtHQ`=M/CIntmYMd-fbpOBAVRF4DbiY7(O+f(th4-)U&e_WE8*I6B^+CL@8hPKJ'T3/Fs9>p*a]$Ke/4DsrwXSR,<2-)x>2-)Lqq=#r]FJ`L)Co%VPQ^5VfZGtJ]E^-$+V'8QnwA6'X$C8]Z[ZVxckVIdx2C8x>72hmeStLWgMOsc`'Es7D1nsRrA9Z<C>7Axl2T^Ago#Mq(DUsU*.e--8Aj`?Ce3#r)G)M&F?mugXf0Uu(1-)jjtZsgPN&dIJ$.8^CxUfg)N>^k?qCsL%%)$e^aUHe]0^t8o$t)l3YH,b.o,F2s/SsMA3.(CKIQs)+R>M<JThtV^8;/.L]Js*iX[Nw%EBSK;SqL-v6101ILj:vleS:'he>H2?DvLbxlfa7ZxKGXerY?HS-MMe+:5N<Gu43)6;U#+xT8$5OL[t<:2^tDKivUM&ck8UOCUs3Q35R+cj<7OeXMt@uPJ&[m(xXSV^caQV^caAagT.+pINI=hMY$c#xCs`T[&*r7XX$g#-bsYU0%OuC;Ac8'FW-_SL'J3/&Ns]<a/MTO()lcDW1'h>d[K=['3NJ.m#Bs3Lw>@=EZQ>l+Ds`mU*Mg&OsubfLb,,X[?^8v'_$$2btaOBc05?j=Yu:u.89W1t<qxKU<q@A$`<Z#aGsq<EDsckU`$4`B-=t?$Qs&AP:&qR-C/2r%XKq5GCPA+x)X%v*DsR%2>5ECtE@UUVY#lcEn*RbB'=YTAHselk1gUfc5npsOE9*K@&GB5i*@9Eq20*9;U#tj>%p09,I?HO`[FY?>^b$BLQ=X56QC$HV].a5m-LYd/]&.n1utn7n'P19(wMa_Rj31Y2.(xZ,4AgLFLLfri*M&g+>uKCY?/9sk3D[.FhLs>ANsw62=>Lwkb)Q;MRJNRv^t#2tu)Pob<m;bg%+M0t<-quX41*3Eh^36nRsk=,ft/i?&/PKL'sXqb-6*-qBu)$SD&)BxdQ5s&=#U((7RlGW#vaa@FXC7BXdVTF#d@CQ&-;)Hl&DSplT2<6^,:`kKP^`'Ese<T(/FNIL(`kwE7']:iSC5$QsF;hLCPkxoo8FrmL#X+=&br64oE^YiqnAIGsNq-6(f`C)nu5VU6vdq$YNRv^tvhu.8VO8R3DFC<&s[WD)Zmh[+m]%=d-kO=cKcE)t'm2-)Y,fe-kpds&w9n6%'V)T.2?eCs;VNR%-9(C&U[kK518tKPhmio70G2Nrju#d.#kmCsmCnq$VkCb7?g+>uI`Kg-m;F'S^[3)SQ7[/NI?5T'I0&+;V@Ip.UP010qV>(Fr#<gr7)_(*v50l8O.qU@A6Ta>_EE$uuiAasrc:1.3Ut,McA=ILu3S)vH@T1LE;T=#6HP:v=S'1vqqIGLuk4-)X`SkO+dLs-w.dBM_?'$ngTKI(sXk$YgD=T>M7OC4I1YFDItMe-o&:1'3UFv-qUsRM>)doLFYVpLJ1M#=jJ0j(OP69%=-)%+fFmT`f3[n;OGO[9FX^ds7evZsk?0XsFHajL_BRFsnK;Rs_Jh<.53TRI`^#QB]8'.MJ0rMswo*x.YNoVsA.2Gsk9oHs:r;1''X%C/JD9r-*vZd;*0LB#G3saa3u1%Moae0^w8;HsC`M@&a/SDE,n);Tx,Y_3&rh3=7,A]sdmbZ-F=9tqXS@.LQ;?NLiwUfoX)cBM?JVR%r'D_/4p57t0eA7.L*]m*AKW)NB+oVsU,;Qa/4=Zsnq1=>Gkd-)1ncJtNN>B&[GqqmMK-1L6sxR8]#PA>/x&Q/<_dZ;5'`:-WEZ&#Bun05PkFOoj@V/)+@hNaW3@A/dH@S:0dp'M5iqEsTW$&/wWvQo]ND3Gwrb6E591.(g(VMLln<d*sYX0GumCv-1w?]-U2(QF&K'-iEE5.(f48jC1rEkXbE.@tEvK0lMwLLgG^ZGslZIq[MeG)F_M?O4&dW=,#0.W.M$5au6--i8%bQhG[4CW%/S[g8k&HK)n>2-)&d'bY,d,m)iscIDP*Z*7dn/u>,<2-)(*2Z-6uCpp7JPCLfAR`t[Dls-K5b0NO/K:HaYCp.mYm-LHbSBoBg_>XhAtD8DSfl^1+L'Jt*Ih^Z`010.lfn.LU%dsC@wx-xe&kLD^@Z(+[ewF@^n^$UlcFsdH'r$=9Ac4qVf9t%P>B&j<?ht)0:F&CIu*DKUALUuUhiUrR-/V3eFp.df9JsIt?Q:a#PWsrX4.(&._,)ahw)vCEoX7>hB:f=fZ4]hC[eVX>m?$d(4XZ0Sa6fLIDU%C#@,s%MIF)?#[csN`CH-'a4(.oQ=eWWQPTs3*V_JuC9dM.j/Z.oLT:v&l%*.i$CR8>3O2(W0*X%MU'=d[f/4Rt6oBJ+Bs6sE,F6s/ZA7s=Dd'))%KEsT-svMVQGTsi#t4o[AGe6d6x.vs>C(J$n)qrOc0rrZVt#n@x&n*/Z%E3xY#Lg;sDLL,;$3#0;pBbJY<=lB4RGWNKIe-mY_9MtND]O%H6hMlp;R:+Qo0#>Jpu#U%$c%Lx(YC.^F^%uoObC4U(mStlLaTrX^@TOS<;U_CpSVgbE+[j@&h%..-;]`9.mJ=@4$J1Dc@K6E+f%DgHuT>Ov,)[:e4v7kTId?T2tL'xi7#;?v`tfXYg`aC`8.pN^r(6qgGsce.Hssl3_$)prb)&$8@P`Y%BNrUnKco3#1cx90kbi_sNbMchSod1<T6fIOB6<XJKsU;QYsh^W>.U5xT$pnv;-rN(H-2*nA/iW^MsgG*%+FS^&4aj4Hj'&+Ds:[Wm)]icQs/_R<&6@;F.Xge#IqMLs(C6#bW,V>Tsm3mQsJrkv-rWOpLDTKA&D>UA&EF7l9`M8HsxcOlfT?=C3bS5O=#*N48'&CWQ,wF(=nwDGs&Lp3=PJcfT.O8K)#$&xFUiq/)a`X4Jc=%^&hV6HLPPp<lk2nt>PD6.(_Z$P`YZ`RssuZ$Xj2QRJZE<ltpt?I4tINZs*Q#52os4=>.S@?PG]EI)YGLnnaFR0):D;U0NM3-)BTmI;0^*1>S26=>L2Q`-;^^0>>OmDs0n.m=jt3=>_.H`-G%@k=q,RgL6`*vouQGGs7`Y0YVV]wmJ>)A.UX;%=D?UGs$;o_OJ89IC)b[p&c`E8N8>=[XDgA_/8I$^G]0t1>OdRpT0>dv*uq%9.KHa-_jZ(t%Jd?hpRdvD-rPWe*4b89.=7dwFCY`20o8(C&R$MQsCkSwB,uxmW&tHvtgXYg`h_J_Q(Fp[sp4`t_M,+fCC6nDsH'(XMXP^IC29.f;gP#WI>kwxM+jmQs2e6qL5=(:@4>g$kZZ9#6gZ*bZ/:OZs?so*D?,pL0nx?I2Mi5F`J@0-)pL^U>2*-01IvUG#Tc1=>p5E`s+vgS/Aabl)dq<9[0oip.jC110S/sB8F=g3f_M(T.JL(Vt-N332`pIds7V7`sgp>$$-RsX>R10&u<ZuLMgxa-I*3MPsZ*fEs_x8e;=a&HsA`bj)eeAnfpcjXPVuEHsJouCsZS2DscKErLY1JCWxP*c7B<I,MW;/1(p0m8Kgcvqta=@NO],</%kU(CGhOFLL@;bjLRmPqt6Y59Mo1,Q'#-VHMR$,%X3lrh';.vaE'#Zg'T3n#uXoceq1CUbtF1X9si5atP=E'l&4[ZtP3awsZKEI['q$@#MR(?)OMJ=jLkxA:-,D8DtePV*3,$M[O/DI`W,5+Ds:9-d)60ugLaPwtL16&#MDZ%?tB5eAMX46HNV_RO&)PS`tGHL1M)>nx-BDjhL.[R+NW1@mL'4T?._n%P&7L*4+S<s<:OO1H2^JX?Ib2:JsGLND)WOKqsSn?@+xn7wt*qY,)F$mk/bYGf$ku5mtHA;7S3xCC*uoR:.>nTUsRoqR'8kQI:&xhq6pS*DsWbIi)M4^;M)>O#L=pe--<)lk/@`xjOJS)OL%dr6QBlboO8>&ZMC&%%B>K8+@gBfqR+?,LNP,+gO[[2bQ[vbgh4[ItlUPhJs?4@nnU+WtmK<w4nE,OL2WaIL2@iI8-8>XQsh<#YsEGhh#+El$Gs/Qq)bixeC;Y>s-ES5s*^bn@5+%?4&S>k4qE)M[X#v.-)Am[.(U5gU.p$bw'Y0Hs.*>2rRD5u1q0;p]%e^v)*ci7k.S;IZ.5u4&uLR89&lGJ://C.c;TC6OS.,8x+vOWN'SL<@'iQtOM8PS77D@;=-WC2=-A9DeMq:[]-0*Qn*vW@.QWvC.Qi.0sUei0hOYB>oECRw:MSaI&bx-1gSgeK@O)9F2$]:7:?NX@`tmbmiLJ:m`O&TYNb-bh[O(3=2$B/J>-v[<F.;HWU-``d?'?ji^sO`>Fs(3RGreR,u,BN?.)#o.-)c(,lSCOkOA1&Il-ZGDrtA$1C&Y,Wn*-3MC'wvePL,;'XuG6gEs^Rdh0H)iC*%Mc:$W+7.(:`P[Fj-^PYG9W8F[<BkE'YniC_KDm,IM:IUo%[.mU*Uf%_TN/GVE6&J^VbX#ioGf$W0jlte%Pf$s'*ET0OO@`eYH=qV53KVTWk?I:[7)t]ODK&S7f-IXxQ*)toA=#TvXqtDg0,)_u]&tr:vI:LPPtlx-x[s1T)L%ANrnQg4MqONUYDs'Jj$QO]MK_A+*Ds-`$GpslJX#pi]X#);pEsXijotv?K)3OgI=h),0[_Pf=HRtf+TM^xe>BnwTx0ru]<Es/ZZ%^92lA%cGPO[mclOulINP8`9OJnrW&%'s`7cstC&k]dd.-JTu]O>HR(*>pk`Osc*gtG=X70T5C%K0AG%KRiVq/]ZSnL8bkP;ohkV#i[(u#.YPbsaA2qm[e'dMi9+(KAqgk/0]'l2Wj>)W=3>`R[`m[FtbV)%(eNRD`.%EEWP^KsP3=skYaiGsMo3TY=8-gmd/ZUVRW=9oteWbDk+SBf3q?Ds*N_v#PX[L'PNRt^K]@UFi6`JFbbRVs]Y5u>]U'Q1x^^51q/JHsCwIHs&P@i'iPfO%gx>HpCS-KsurY%-+kQQs]a*TsZd1:6;vlYs)adkA;6`Em8A$*ID=Gc%`/jt`'nM?V]6ddfXI3obA;(6b1QwhlQ'ubO=$c?J.mToDcmAi51&%iK;Q-`*U%EZ`[%&9^bSdRjolX9asg(f:YeU_O_q)jQ0VkKQ.x>xTLkajOoF:5Nc>AVLF78fG'SOWmFx6[bDXeEsjl2+)LjsngBYIR@_I=.)NojKliOcU;,.`0_LASDsM`Mx)X$BZsU<hO-()lXsJOH+;[vZRsw9<UI*5/dtF1qq-Ijvw+nO(.LE'Loevfa<u',F`sr..&*@J7stDPOv,T'KV:p*^)I[QQAJ&TWDskvwI(=uYTXmJC&Ux4?tO/b:F;86CC*E(6L#/<8^tIC]b,.5rG7%:gZC=*-HA^'s6/enZR%a&;*J:Of*A^<8sOU=uq$:&wCsJ7:Es&`@WsGLGe_9WsWsYl6Ks,`ZO&/2>_t2n]]t]/]htRd+^%F^ht>SpUFn$`ei%4,Cs6Oju72WpLx9YcDi%jc@UZW4Ig$0pf:$ZmR@FB+^ipAB0s^@e#]4>]V[4?R'+hc1Lc%T4'UMQLQ>#Z`x#*(g[R[`]N.:(^gb24X'u#)dWRs9Dso9LWopt)YX$0IU%VsQg3_j,.D_tTbPdf<'(Js#l8c24]0lO(8RX5Xrhff'2Ge_IQ+4UnSN%tjD(%*'Er6[CO%.:)IIq;$pKu#q&M`tVAMTfm%WWs@(96]D$Ok=Gn2u)#vJh^s=Bu5@]tns%g-O=x#Cbt;X:n:aJDotLP)KMD7<Dsg]rS%vmAX#;h-w#6>x3]KH2lXLF=mCfcC)A&7Au,L#uat=_l-9%E(Al;@Du`9hjj[J-OI(<&ZeZ_9`xoWcS(*qX>l=T-G`%YC]S[R7H=`4q(E<HO'(*N,Crj3']C]Tk2pM%8?-Gw8x6D:(Gc%G2X7b5QpoOiqqPI0u1(tBBEx+_O%HuH7agsfap_fRx9FXLOrcsQcn%uN*;$>>B&r$Tv8T@-[#NsD*5qt[qJI(vW^kA)/2.(8%Eu>)G-ntf2Ytl//Cc`DxT_OUD;otKR;otjXdfs(d$rrA[_Rsx+snOO$>Qs<L&wOV<_V$6:JbVwtD1'9XV$upsBhpXL2+(vKcXYG_%7IQ`(7INpkIs)-'>a%k$m?(J+(?,N9LaqelP'3G0Us<EN=Gn<IMqafteURBVRs(f;wtYY[:6li$N'j8&giKkA7%DQ/()+p>77X%cpsTJPg)98^bpV>rJ/j[$VD>SU[%f_b'[jVseOe&+,>WE[U=jBaqOP+j8b9qt@[GLKc%NwhQs'3Z:XV_Z2Ee^*#??=?9F@q7x_eZ?%MT&IhEFb_7.g@WPWmf6UW/OHpOOvjNG(@_4E/+Gc%x%QntwZ8&tWMSTsCkEWsukvn%Q5.(*&bPno&1X8-3SNltrx7gOM_gLY=]wxL66vLi&Z?]LX4xP]>(`0_tK+<T$5abO`()J-G_BUsK&XkO/D:lFXD^hO,OxCRaHMpI@M9Z$&?QALI<L%/Y+-+20]7_-X:,DsXI*o/p/xT$g^[WZ&2B=#+td(WFY)l(?fVkJ%tv3g>xXZgHxKEsoE(C&U'WK&77b-IDUvq$or=:$6BYYs`(A#MLtFfOPUJ]tBR+Xs9()^OP-Ubt7Dskt2,tkO.bJ]t5#)t-7x:mL;u<[$nAcRaN9jiUX4]p.k1_diW6u>#dII.(ngWltxLRcs7=veOsD7Csm&iBs.`pxt9oOn*++`qQN)c?-;'$e3^6TEs#cu^tYTi^OdK`qQCf=7sGjkv-:=8+Mp$WGstwr#lF5b-_*PP'tKt'dOQu'rQ,:%(3[O%(3c9T/]M)7uO;:BHsec:tOI]XqQEi=+M.]8+M*jhQCeg8kPc=;viHvw')_[S]tEnAv[[A,pOe'?.$dXfah&0W`sq]>o)<V?sHWpF,-co(WHNk^k,c'bGVr5.1-5R+dV%)6g,o-aX6:rH0'SjsJC<fPW-wh<(&#>@(&DqYtLgk[O&.5L[0;2`$'XEO[0(L=(&W[EKNGrGU$v+jcsaL%?PFYR0't--4%Frr.rZRM#Y_F9Es+]71'OL71'm.6Vsi07RRM:?_twGuQsxM(RsT:WGVwI8nO?nTO/<6TWU.FaehIr>R]w?Lf$bdg8NVEM)aUftk$pYriPULxP]CXZ=L4Y_9MDI$2aCKJ;M?x_=LM5kB%@6G-QD$[v>Bp$a$3+nQNE#LjBUv[CSo:XGRUAx3?S$Z*RbrE(S$$:N'Ab]$XVJfNI%fUFp>_rGsc.$x4tj=s1AhUb;#eStf)Q%rZOXm*M:Kg+gBxA[5Xk?mOE(:%FsS8_O)cC7%CS0U[2dN]t^EI+M$<l9%'t='uI80U[drI#/H<pEsa]/I$*J?bs7pRL^9;)N'ZSp3]lXMZo*uaLsvD#ft5EMX-7;Nb.Nf0DsN?e0^@;n-$;kO0156i3]G1[1_/JdVs>.XGs,B9EsmTccsl)>_/xwk'N@fn&Mmr/[s25>C/o:*P=8bR.*%Rwst&'oBJ.Qq(MG%xk&mA=_tvio?K?lXKL)[5+;',7RR#d=_tixB^sYI1akVo>Ns?Hs-$5R^@4r1,FsE`+QsN:Cjt,U#tL,=D#RkfHRR.6B]r_7(:$9e7Xlt9)fZ)*t,ZgeuPWNcjrU0-uwSl:LhO_PfnMI?H=K?=S+H2b9GHK6ZXKOv[nMl&)aOaGjqL-biLFJc#1Hd?bCK'TVuMguuf%Go.,[Vxr/ZZY-:WZ;(]UXg4DTE(coOw-NJiuFOvB'BknD0cn^I0U5TLH,+gOfWBpU&s.KXM'[bZkl$V_-8QHJPR?qOdd4-S%;n^U-CCMZ+[HF]&3W?_a+v6*OBkW_+m3TIjfXvDHEv%CxCeEA5YDvL/?3c@0mVa%]fRJL>]gtNFZ&L[Isl29wKvq`;HBbN=`5UOGj]-]G[9[V<4)@DJb:]PJn$os_Hu)Sp&YZL4mFWLgcpoJH['k,b$N$#+)*4T.C2BT4>t#KpV#o*LvK0*2qU[,uUG=P_/.A-)t-A-DQ&;/o,M.).uB`N.`i=-pvaC42Ag58@P[i1OK7asJ+v$,:OdK&t&/lL*m(1N0#J&KtiA$KB1Xcs>UFv-mlOvL0x-tLX_CH-.bpG.Ab=3D5.'2hBk,3hE+w`,iC#Q8INe9D1^w>LfGsM-[A%m-DB@nN;3X$#bS>R*A4CU@f_cXP<4CWL306BSn3HaSbi05T-Gvg,qBnU)j`#ST-G2--6OR$#b%04KuSs#KnbU^Tn&uvLGlfAKgHJKo#bU(s%nh(s^oB_tF:VGs7sa-rtB[20JL9c)$sp;.1vxB/Tl:=G*u:=G:0kdpIGF.u0;o/1OeE8VdRTkJ%v*Ds*0qc).]Yu#>K,N'5_CXPF*wCjbhCbsi)Ax$6n$:QvnL5//1h'uLVYDN+UCkf@CBHsx?dNs@R[RR)An*MlV$N'wH(2tNLrCsXVC($g_'+DP<oY-f_.F.F0ae-V)8vL`T'x==rs(t<RFv-3E2dMr1^Z.f'wnsK`Vq1f>clsHJLI1N0:^so20%M;-NbV?9C=?'NO/*hafjg#TMaO?F410PPg-MaVBSsYrYFsM7$bsGFKv)@fBeV8HSRA`i.8u;.2O4#TDeL2aKO=kqkSMs4mTsuj.4tS(qkB]Uc.ul4_5M=`SbMbNI$Kv01(AR,b@t6nVa-)&Q_A?9McM03+Uee+$h-i9rrD./e3FEU(1gR6i]GfTQ*INA&+tbi>eqHE&ps.Rdn@G^*-%SL[G%MMBvH:r0pLn6;k%WhE)&1HdA4vSOsQ'Pe%'51j5&c?7fQ^:1n&-PtDs,9L3';EG$,,#(%#14>>#G2W]+YM5D<Cr,AFB;HfUGHl:d1mc7n+(E5&D]IS@2[duP3ih+`M]+v,F^fc;RBKPJ^BdrZ6Jn1pQoO;-[(eY>L^x+`?:5GrDQ]G;r74)NbbJDWGw6At09^A=c;D/L&K:8nDXc87`$:#Y@,-vl7NDmA9^pMT=]5m];a9#lRlbv,;]*B43.uDNs^L#YvqP/h-^u,2r2u8IZ$Fvlf7^^+QN*39>Z9QSfx/QfD&U#lu^sm/avnm8SXr#G)?evYiJDZcMP=$,l4ia<*P+-MLe<H`IEaZPkb$-i*J6[#6/.e2^34wGUvJ<QWWW^t0;jB4?>0tZ?Z0'ka%3_=Oc.hUwNsajWpUk'R9Rq7+M=hL&aKU.4^j0CFk4bax,Q[>A^p6So[_0hoW=40Ol#.D0/:R]<9FeiAHvt?<iJOKwe*4TBdg'ki+nb<kqbeV[_^noUW(S&k&oU7p[qosPYr^O;vxPYLTs8FUw&kEWQidYo`oS&4CHXfAJ<C<%ou1P*qmc%QT2=D4PqoD6>,1Pr?$c%uL9W&6v?<cmuqS&&J5+;nP41u4cU_$/s=-[=PxWD:sa8MY_w(^H[uAUYi>8JYDQm8hw'g@`'q_@-M%OWr&Db%,h4j^n-atax--riE]$K[N'.?DT@@6DTv<B[jcoS&/15(fRkIeUr0,c;]#oktPQjdt(pnh%ArRhTR@.h$^0+k0+aW^,=1$J:5ZIDs37r'VL%HQ&>-N_^:GPCom$%5U?;ORXAnki%R*nFK0?#uJLWgHs])X)sJ9LP1g9A#-]WE&%AMI%>6wvV%^KsA,c.;&&eoObD>u^X#]$<`tgHZc%on2)jfY,fdKu>4_GHi^O,`DQ&tcdl76_-i9#ImO8/@$+D09PU?`',oJxx)w$M;%[sQZOoL>PCEs@)I#MEHA#McG-QsIGpEsuGHq;E(SVY^T_Ds_J1rtgU&et*hEBI=[CeOn/Gs./GUJsV$hZs=?`tO@F87G'`cX#VHdv2D@Jh,3(=i'R6VCEP;H92uHpqdmhPI:*Y$LG7Mo/1r*xZSF.EdD.EWP]Ab^T`DRen7g>QR7-`/et,w?@%<afS1MPPY#.s?ntpEqL2l80.v+UAA-q(5>#I(d[sw,'S1`b-uPh(;OJAwvO/<&pE@makoL:*TwsEnU_%M3HK%[<7Y#4Y+19PW31ujS%_OBQjdt0L=x=$[w_<_nXGM*5?UZVCK:uwb]KMjuIj1JL7:mw2,Q&FHDu,]fI%+wD@Q/B<vt,S-QbDC+9K%s(uDsG=3atOqDZ6'Y(d*dPbH2lC*Ls@I`e:3'WTf8fC`tlch=3#?5Q&QH/kt1_xKsS/E8n9.:lLI5=m'dX_U$Q&_btjkt`Of(,L^2xAVatRpm%4-aTf8c:`t*67]-L`v34fiSo*P]pk1P#WJJs/Y[47uQ]c:#id*41D$57]Cr$ipMFiPp%Fi;;#r$.wft>JNgn@L`^0ki1uDsi_%f0JQqt52rtq-B4o*M+H/4tU7qhLgp0xX07bwXE==R-f7rp.>.Oi$>Uua7P&EV6Flm_sn/ttt3I+Q&]9Fi'r[lYsAtZRs%d<ps>LM=-EP57%s+5[$Opn]t+P9lO7o-#MoFU]tN/f<uaN.uhGos20$+Qu6rMl^tes4?GAvo^A(tw5D7hm]rYrpS&r)K+2HZ802_$#9-iN$iLWC&T&a1$:;$m9X:a+aq/Sdv'vCIiR%B5e^4RBG#v_+f]Xi`7eaobL+r#w7>#]tabO$g<d2/_anqg]YxuArk;W*/Z1g20-F.'p>kMTdcN[KpsOonN2vunNBfB@69Q&_xZBUPB[>le5a$-e5t,>%/Q:v7l/wLeop[<:-<5&nrW:vGMh1vUG'9;9nvU7$lvV%i[ES,sC/-<UPqS&j/<#vGQ^2v$diA.%in>.K$aX%ig&.ouf'Dq0q[C]r9la%*X?dj)X=>#=Q#pLqZKkR6dAm]M&?lfIacLLOh#Ur:,Cs-[.J+MN^q0Mdp`]+?O:_8.]L%,Ujc=l2kKtOmtq^oW('gLMIM>9?(vR.MgS]tZ41UoFdG`,?heE(b?Nvu^ce4XLB*Sp,Wd`*K+<>#$f%wuAbNep+W*PZISkS&[AIHj<k/.(_`B+EcH&_S@d3sk%[$.0$?ob/X@G:voYRf9'3Kn'aOSM'vCP:v0H)UQwtbgV2x9>#_Nh3vDOd5LW,xpAK1LG)W*Qt1qKP:6aVS.(=';i'Ct-]Bc07e%uw=43aBi`aQ)fKcB@.77xtdb2'S0%Ov3qoDE4Gc%ig&.o9,aSZV4,;[,4?9V*`6TeCH/(-5Z5.(o_TDs'#ottI=0gOx:)&Iav/mtk]$qL/st&#3G:*]JaIc%>(./[J.['[hs<RDXoeYDRWQ#u@qJas'3amJ'[1+?rc['XVLCcsO_($u]`=OMkkcS&JpsP??bp_-2Po^fDi[^7`2=>#?#lCs%=9MsmF-f:X@477=WwR.#T(0CCjE5-,W`*7CV*E3^@HF)gcP7JWfK_,_lrI?$/sa%2s*84<VGwK(,1lO*R/Q&V*NFS/3+^bDax(-*_u^f1'/^O.pMuMn(eQXe=Vn*,_-o**s$i)3VLx+t;(S<Yto_%<N19UYq[F1vL^gkZ3>A>(Vkj=WSmp1-U&Q&og/gR&WBvcU2fOMak9Q&IZ]Z&1_[e*//'*3cB0b94769:mj_;gp:$'hJ42<H8JIpg7X2e*a<NvuBqcMjDEkxuqe2lOTh*Q&rJo_OQ+<5&ER;>#5B88vnqaUIrk19fPq6q$36t,>&2Q:vYResOG,$+qiBwW%?4g$vaw5_UZ.3:IIhP#u?h/Es%eG^X`oi/ZDu<%^w<Pa%wgHW$*LsbQTpefOa6?WB^)hdOr#Y[S*vQ[$@i8GKT%97.#JtpOrdOVL8$CQ&El:a*B^eV%[Lq06vA5M_f-TgZJ.NmfdMtpa'kRgU-L8lOGOW.(14S[tm]^_IT`%^*v?sGse5f_OixB3k<@VRsQ.=]sR:=]sFMfk8M0P(*vHo$ted'W..I+Q&bBA?7iA%%+4@:Jsj_GNDh<)'5Y,(jtWKRSs(6'F`O'pF)i2i$u@[rcsQ70D46SR=GuGKr;Vk1lOuf3kOYLf3fR()cMj9P[rHM6Q&IuLI(;g]Ye8+aRS1/oRTf&W4FC_XVdkY(kO&l:tLRbGc%.feOTaHTZ-h))GsTFs-$c*`vYfMLnOTqtuOe[TM:JA/fsx=xB-I#^EuKq2QfW?e_iE1Trt(wSE<S$x2jqpBQ&gm3-3K.N^J-NivT=nr#UvKWaJ4Eka*=hhT%xxoS_D)uDs/$>pO6j,Q&W+(J:URJCoosq*D+QH+;/K3lO@hKOfs)/d<_n[_&[S_A5&CDX-gX^9TcuGF`c5fvtrdCnUbQ4@=p&%vt.Xq$%i`R^$$qY]>g9G<DJA;ehJ)$gU`cOgORPa&b?p,E[nX`eh'tS8IGI6qOX:oq-Tp_X,%aD'Q.,6%--V);hpHd>cQkgS>.[>B=L^cR4CTogOc3nL0Fg4hOD;3s]vc^.=l2[Rcuu;Wgs7rT'9DZ%-QEs?]LJP:v;bDfOkX#G_r&+,2mDR:vHYS7vqMlZQ1]$s$IPl?kdsw'3iWAo.YY2]bwf>[0n7rV1e^2<#3#4cinhR:vp=wfLew(&t5YxSorw.Yc.u6>#Htt%v31sscmg].6AYaa%:V'?5.??.IVv#F%r)K+2@$</2_$#9-dHSgRaH$OFVge)c;vpo.ZwtuuoGOgrBkpE:Zb387CqT:vFql*v(^m,6QXUe(/jYT.>*mXhHpue+TPPY#unAi*.>Ij91]q58:?j(^Q<Q`Bh^`XBRafw]I';iO<g?#TnbWLs.71DJ/m/cI]669:(I-BXukPtULYW@=RSWDNr].nObNBF_8<<59JC^&=f)'cKbMUg%6e$wefG*Q&vEJ;T+SN+27,aaO+9>l=u<,%C*C0%fnEUi$-WvEK1^FQ&5gmt=V]MuO1cx)fr=/k$7@:(@2E%fOqs;qVilu_Fq?nn9K^[x6wLl/_]<.Y#meN19V]tD+:83+)MFmEj[9to9%/(l]xs#k0MTR'%D*?=,J+x0B'Y8U%4UoR/u2gxY_6]RjM=4Z,>dxnjUUxL'dH'%4]mAT8Llc]OBa7c7]f+n%hvHa*`7(B4gG=-v:.R/1l8At#=6pLp,SV:vYnw(MOvi:#6JP:v`Og9vb?Af1tCZAMa,<5&7VX:vojEdOjPRR*YRZ`Ovn-+mQx3ci_-6>#.WW&v=-/*O+`M&-x0LG)5v=>#h^F0vVf5(dsU=%531`e2aB:>#X.Ad%S/GoO`,^e%<#@hadG^S8,%i?%Y5's7@U+Cf/<m>BC[udOxd$@%m9)Z/Ha9$r)Mjdt/3[@%4DP19XF*CW.6Kdk:,qR%tq@Y'Ku?T.;Fc=K7(QZ%dcAmAMEZeHwAdPL_V/Gs8CG^tFcc=RlY2:6Ui6u_n=he%wvF[oe]/(3d@jLC;66Q8(wp=m6s7:-bT69ooNOG<+oK0>([8O5+GZ>_9#TFnd3+'R@^pwkWPM.1V#+.1x1)r;qe^eO.g?*Z+46N^mi0lOeFKc0woT^FgNvaIH4u=;?mY]T3tHc%R.-%KGmfhO[:c`$xv;(h?>`h?L<s>&Jj`^4MfsI(.>IU?J.YU$$M(%-[wN+<pQ&T&.Y2CZf/%%+%bgj0V+-10.-FxsT^kXYQ^:T%qsokt6TAoO%?Y.(b0tDso4qj$@os;KV**jO3hoGQYQ(&KB7:9NYOgHZ..]RsOe;9cWP`DsuXUrta4L.:S,'c;mi(Q&6sa=6kN5v$L'N)>M]a=,-iC1N?w?W&s)Y.(PY)E3j$q7?sYw8[fa%qO.-OI($rc:-H%Ho3f5H`%g*qi^jlj@hlv2r`ZK.fOqkx14<n$ctnI7Q&[8g<*&M9SrIA_Rs@X,(*<D@=,O6YFCM[&g%H_7nL*j0M%,U3:0sARX/P.uDsdkx/(OfC?ujUn`%+,Q.1M?7%FZw.Y:hQY`%QhHE0vPbYc#2I`f)x#5JR`Qe$I=xc,'&:c`8I=>#uxD%vR_+:):aO+`7tCr$;nO_-2=P:v8:$:v:R3Jf'%V<De(El]6lQ:v/=CrOU(;>SB/NpI2dk2UI(`wEtEsrO6miOsORjf1]vX)s]LV7I.:wk&EE$%+Q%/30<.tPAi=:&npnfC=9SPU&kfU.(x>%NB__(dBWXja*=Ni60L7j37hNh[,W5I(=9IsS&c5Jj%ufLdOl<x;Tq/_Z$S.,HK0Y'u#>*wrOhWT7G7Xne%qqT*]&=HQ&'(-#.jO<Lscr]_j>%1lO[S]7.K,Tet_Y8_jFS)c<)U&T&KU^FGjjge(3^tn%Rc/n^&-Je*l,CY-mx]6E5hF7I`7'sC_nGc%@ORoOk,JLO/<@Ns5V5^tgv%q*NP+F3vW1fqVcQ:vXwK9v@7N0ft2LdgLw)B4?:FkO^jX`R8@EdD=AJUFqVltO@=?3q.t@Hsdd7vt4b4cOjgweFoju]$chQeRvw9>#k7]pLOLOh`#RrIhT(>>#YXr.vY@I^#AE?D*Y^=lLm3F^OQ0@Psl%019O]c7%V<Y1'vQ(Is-@'l7v&*T%^HF/Uxrdahg#lU%tn[9B@cMx9K2V'LT_5^toDY,eEuCsO=Zrg@pEDQ&;R%cRx^0(oJ4Wk-2g#+B7]GG<+I.-bsWc>BxoLa%^g;a*4%B?-ftlit$7x2-X:4[UpLQf%K[A&FFb0DIX&JVLFle`%LdX=^'4-F]BGsII+F;d%xg*GHKVrOF^H#=M]tX,HhrCsZAYZ7XZA$UWKa9pWfK>m]kvwd,P_%`<+BFXs9SM+Rfc*cRsUPPWeO6iO^EGOFI'9oNHPFQ&Ng<f:c#snsROL_$I,rI?>?b^%Bg9,V/Rg8X5;u;d$Dv%m(vfObH:Ng%^@XueD:5sH<4O(ILdJgOe64lL5nof$Ie<<-aS&n$^dU^T.I;BT+G;--.####u4T;-4:eM0pvK'#(5>##*$?tL(g=L#m?Y>#-<)mL>4pfLe@6##FvX?-345dM_VV8&;54GD]BTT93c>A+4iZlEwYAeGx]`f1)>MMF`E<;$Fklxu>TJ8RWO$##dB_O;PjlB=GJMe$H&>uuQoRfL7nR`Ec0S.#AroF-DwchL_R6##08P>#8&krL]RQ>#gNb&#tAJ>H*=6p/0g^D4<(O88%]g3bvrIfLI-HIP-Fl(N]TC`N-9x%FcWJ.#xw51F)Ym*NA7$##wLYS.+GY##AA081Cke%#k`[@#c)#/&IpchL/k20C'B(;?F4Me$wVml&:t+/(Ucsx+nHel/0/V`3kF,290LD>#sF.5J5AvV@>R1L,a%m._>[3>djY^-66%MS.3cCK2TDP`<Mjb3=.L@VQvIF&#4D4B#2dkuGSCI2Lg?Ne$a)FqDe1dER5oLS.&Cg+Mb[F)#X+^*#HbFoLt'B3M0(^+ixOO&#YN,W-,.OX(Wdbe$.;$v#cWn7R5)fl^T78F.fn;'f5g53#5(A>-;NYO-E<dD-S6v%.6%AnL`-'P#rYGLMH))TNJThlLeC_l8uNhA#LsJp&@1D'Sq2[`*_fg,.r*9SMBb?1MtT320'#-v?8c5,a=,]'8(u@J1aVTc;TMHL>^hfL>M;&3:riF>#GQb3=<fR)#x4n0#:(02#RqG3#kd`4#-Wx5#EJ:7#^=R8#v0k9#8$-;#PmD<#jixX#+Su>#CF7@#[9OA#t,hB#6v)D#NiAE#g[YF#)OrG#AB4I#Y5LJ#r(eK#4r&M#Le>N#eWVO#'KoP#?>1R#W1IS#p$bT#2n#V#`4G>#LF?5.u;NJM'M`PM#5;PMQFq0M#1,GMY[n2Lx+G>#'2*Y(r?L&#m[jV7/(lA#:Gg;-rHg;-t^U[-ipX_&5@l-6L9)UMD-1SMJuBKM7XFRMfj&3M`GVG)vjvf;d@/s7ZD:&55KK/)E1T;.7Kkm'&2>>#bVU_&L2P:voo_+VXQIQ0u%G>#G[N_&GqPTMG&*(vF4)=-=tcW-:>:4kr$p34NA,LMw(C0Mubj.L$cx.iBb(^#>G@&,-iF]ulfooSuE=Mqv:+Au$mQfr7^,g)4DBJ`VUeQKsp@>#Sr;V?S%+GMJv6A4$o<X(9DBL,G3be$81Sk='1oQaXI/2'+Jju5#[c984I>A+v3FV?Nu%8@OZ8g2-'8L#tBu@XQmoG3J*<L#5w=5&e#q%4mYbQjil`oI+6qx4?uPi^?oIA4A+OY58;;)3a6@>#fpWoRDb<t-gPrfLM.x`EckB`N19/[%-a;W#cSSX#&JlY#=:.[#U-F]#nv^^#0jv_#H]8a#aOPb##Cic#;6+e#S)Cf#lrZg#.fsh#FX5j#_KMk#w>fl#92(n#Q%@o#jnWp#,bpq#DT2s#]GJt#vC(;$7.%w#Ow<x#hjT#$*^m$$BP/&$ZCG'$s6`($5*x)$Ms9+$ffQ,$(Yj-$@L,/$X?D0$q2]1$3&u2$Ko64$dbN5$&Ug6$>H)8$V;A9$p7uU$1xq;$Ik3=$b^K>$$Qd?$<D&A$XDaJ%X=7[#0hG<->Hg;-]Gg;-LGg;-`q`=-8scW-=iRX(f7`e$nBPX(U,Z_&qYce$C'be$[1KR*v8__&PNbe$I8_e$Wc_e$H5_e$1Fae$i@`e$vR<l=ieW_&:vj'8sAu=lGd9SI&%Re$'#;Yl-n<Ac)lkA#<e%Y-d]U_&[#9F.mW<F.LBbe$^7KR*TX/:2B#_e$<g^e$;d^e$PJUe$Uq+`MRQB_MA[Wk#B=dD-:lG<-?Tx>-lmG<-qnG<-L:)t->(ixL1[sMMnI8bMD-UKMOp?TMSVEUMiUY*$LJA/./.GwLDo#u#<Cg;-qO,W-?+`q;0gU_&D)_e$FxNX(c-DVZbJ7;6AQ4@0t]Pe$+MOR*OO&FI1QH'oaqOX(PnG_AT(W_&POee$(*^e$7oFR*,$x1^(['a+;:]PBHY`D+^F7qremaw9W&8VMY)3c#oF0t7Vwxc3PNKVe)4Z;%3:tiC^`6#62,=2_p.$@0a#6v6BJTe?K`M_&QX]_MY2eTM6SC[MQI-LM-YAFM@35ciXn_;%b9UGEhkflgI1tY->0W8&6TgJ)8gG,*D(9v-E1T;._<<Db.>H;@KD^VIdV><-_mG<-30A>-xFg;-3#L&8(@/s70OvV%L/2_]Qme3OFh>TM2?BW$KBLqV84u4f#h_pBSWK_Mt/3c#_<k(NV2ZX$N2-E>'.,GMV7D`Niq18.m3io.qKIP/ud*20TFKOp&KK88UvZP'9mTc;l.6D<C?C?+@dNjL/rf(NBT8SRXrh.Ufha(WpH#AX-,Kl]CI%G`TQ9]bnw:ci+>lERneH?#CL@@#BV&E#WuSE#[+gE#T`6K#u>]P#1^4Q#6jFQ#;&cQ#B>1R#Ro$S#Z1IS#cInS#iU*T#rtWT#w*kT#&=0U#5t,V#A6QV#INvV#MZ2W#QgDW#k.GY#9UR[#c,q^#1,E`#`Bic#<Zbe#mesh#MKMk#$pXm#b[?(#'2G>#7192#^_kgLTb6lLZ0nlLaTNmLg#0nLmGgnLslGoL#;)pL)``pL/.AqL5RxqL;wXrLAE:sLv8J0#%,>>#/th;-PRPkLqV(8*IpKSIq=bo72=(AOJ#p4Sc_a(W%ERrZ=+Df_Ug5YcnL'Mg03o@kHo`4oaTQ(s#5lY#;kSM'SPEA+l675/.s()3FXpr6_>bf:w$SY>9aDMBQF6AFj,(5J,io(NDNarQ]4RfUupCYY7V5M^O<'Abhxn4f*_`(jBDQrmZ*Cfqsf4Yu*8>>#f5Ch$%2j^oG-5>>qa;,<P?*j1v%?<-Exe7(ZSFL,c.`e$F/_e$0YT-=WMU[-h`W-=%q//1h@N;7HmgX-`FOR*e4`e$.vM@K2>YI:`/JT&&2>>#**3b$@1>R*.%/@:pZP8/mJ<;RVej/Mw+G>#$JV_&./Q/:hO[A,rV[Z-u%G>#6YUe$HwYTM1^)aM-i^H:.]PR*wxH'?(P,W-v@*44ugfe$gvmA#m]?:(;OQL,v75kD.rJfLcu+%&hw>A+-'8L#o_a+VS)P)4M29L#nJnIqU;1a4J*<L#3@=D#9i1$#HV&E#I;WD#mVq/#o*lQ#pQ/a#=vm(#Dv;%$n=;mLPoQ>#KOg2#hiGN#l6>##P97I-<5T;-B5T;-H5T;-XG%n&)W$@'$Y,i$;@hr6-#w4A5(rr$EWCG)^=5;-v#'/10+Y&#vnde$3Mde$_#ce$&&de$%#de$8VQe$1DOcM47P`N9R1AODorw'N`8GMcKpGN?'IYPm/I&#k)I&#m/I&#o5I&#sG[&#ndE'Sd+BK<dTkd854l3bxhH_2&&wX.Ni)`MU(Vp.56c=Lchp0,92%@'rYhi0E<VY,pE(&+Wls.C2.35&S,387E@YY,]H-87,[VW%(a:D35wJ_&SjQ]4<E#)3'A/;6(THG)*1ux+T,YD4S#>)4;wdw'3Q,F%K,l-$Epk-$Gvk-$Fsk-$kC*:2V0UDt`i-5JxP7F%ucSY,Q)PW1ihvr$AuBM9Bnil/*=3F%K,l-$Gvk-$cp(x'PPc##e86&M24ItLj?W$#7x.nLcJH)MxqJfLamH+#7IhhL1x.qLt'd.#$IonL^G/8#Kqj1#a@+gLU8RtLJ&7tLbk>.#_]O.#u[AN-4@Rm/`i<9#xa%-#<YcD1'tx=#-i/*#aZS=#N.r5/^@r$#xq$YMbw`^#Qc/*#VfZ(#Z3dr#7lJE#4(,'$mo]a#^5T;-;dQX.Uufa#6?:@-Jp8Z.l2FA#k2u41<MsD#weUv#VPu>#4bCH-P@Rm/>D6C#88OA#e97I-p`oJ.FNHC#coq5/Mx;`#VW5lL]<*mLBMO/M4/o`*JW0Vml<>5Ajm[D=%+$g;QA2#Z)4_E[)8<;?qi,F%M+$v,7ncuY3QDMB[*$/Cb53?Qp[?20xVADE7S1kX_:.wu5Sv;#7_>pM#Y_P8J51&=@#B;I%rv2(?DgrQ,0V/$7a#3#G+GwL*5Qt7BIPF%NPc##8YlS.^S(vume1p.W-M$#bwwJNMC?##52a.$cqe%#r_7:.1?*29T(RML8q-k:SRklAf9i=u)YZ/$*gQ(#hG%+MACp?PG(_=ue,k-$sF_=uBwr-$)]XD*oM#KNw(`^#)P#dM%Kx0#oIi9.=V8a#MFP8/3f3W7AE$,M4PU2#L$iH->@9gLf_d^Sw'59#Yi/*#PMa+M%*TJ1<a0j(M(:I%O/ll/cO?_/Gda-?-deIq'1UY,f?R:vHC]:dq%CDbfZx4pa-EVnC'0;e>OR]c0&+2_3/f5^fDMY5p]`Ee`pEM9YCi)4P;:5&l*DAlfxO-QWt5R*ZYl-$5X=G2qg&/1/H&F.LM/;6jXfS8*3QV[dHhZ-/ww(<p<k4o:qb;7R9XG%k*jl/%LLk+=?*58iHfQaUa[QsbkJGNs&-)OWMD2Ck^;8SvPIF%=7YcMA<_a#k<-C#X3SoSKvH+#6qF6#%sLG%V?*29=7gr6In?W-9/j&H&.BJLQC?5/:VVQ/?MQ_#]U'B#ZHwM1EO,_fMVcCj7k`Y#gi`QjiZL7#EQ6(#-1x%#G+ixL*ecgLkZc9#rJP##B3_'#Nhn#Mc2$)MY*elL5phx$RS(vuku=:v/3/HX^7vf(EM:<-Ut%'.eZu)MtZWo$,GuG-/7T;--<+,NON15SZap`33uYRE^WNp7@%FW8kJ?.%5sc9DYm&;Q9c:.$1K,F%Gwn-$;i(;QLY1F%)qj-$vX$##;ao-$x]p-$8In-$bol-$27n-$f%m-$*vp-$h+m-$qGp-$dvo-$ShMF.=r2F%1=9/D91MMUXwJGNJ'I21:4*F7pMW^#OK&a#:R'DMpq+9#qhY29]doQaK]>M9N$U4fP;:5&0cEG)PvMk+7^wf;w&0W-PJq92BCJ_&5ivr$^*/F%I'o-$a&a#$4BN/M4W-2T*RTs7uKk4o>fPk4@M;5&U?^w'`gEM9mF>M9DjVG<?h./Vv&WG<nOBk=WmMuLU8RtLliv)M44v.#0w3$M)qT(McGm6#<NEjL9V]F-'Z`=-hmWN04->>#=*F]#vWajLC3(E#4p]a#DYe[#^p^^#aAFV.e/O]#+cPhL0bf7nkn]W7(A;JUYsRM9cO]88,SQF%2lP%t/TauPJg%9/Y4ffLo>UiqAB<)=@WZT8gWwY#w%iM'Wm&g26W*n^Vc@ipcBR>#e7XA+uuMcs-<1q'so('#ZW_TMf4Y9#,Bq-%jqd=u3f-j0eZxf1s>5a4&E7RNWR,^#1TRwT)I;_8v_$##t'*<-&sEn//5YY#%(gE#cYU).aLOgLJPvu#-B;=-[bK`$ADH&Mj;(sL:/fiLb^_sL=w(hL,6%&M,)doLGDS;%aH,kbPwLk+q:hiU<a0j(;E@&G@'kEI6x88@=<_W7o2B8%[q.2Tlr)pfQlRfLOINv'iZ&<-c+O$%qoG9rux,.64]s)#ocBK-l],5M*LLm8RC1^#Fxsb.JdK^#f`CH-6UEr$-Z(G%aT:T84?/p.xKhl^.&?2Lik+T8C*729S1VG%en?M96)IG)99MM%07#kkYE6F%WMZ20x1rvu0BbxuL+ww'C.;/:xxGv?IX[F%)8d39#?8H<5C:58@sK?7bjXCP4h4onZvb39TV*x'd3AvPALoV%U1%X-d;vE@(b'3DE9mI)7ivr$OgnFi15hT[kR)$-1<-/()6)fqUlrR/Vh`i0Gx55/:mt;-R5a_*FgO2('FQ8/RPwpKMU]v$4/7mSX3t_&54iAOG>sFreh<Sn^AcF%?b%##NBs-$Co(##Rj6R*,TC_&<Vq-$-(n-$-uKB#adv_#X?gkL/JhkLcVP8.PC'&+'`'B#(4&cN9lL%MV$#d2&<7VZlb4;6R775&(q85&N=m-$x>__&&1;GD_Ev+DP#?@daA?/(<PO%t?]ADN(+U]OW%gY,7aK;@]K-Au354m^4hs:mivt1qhrOpS6M_lS+,l-$DC>GM#Zk]>`e5^#HM#<-;6T;-S]Gw.Ju;D3[Uaw';CGG)*/22'sx.;692/873#x_s(;iu>+KM8]w:&,Mud)/#ud2<#1vx=#.H+.#gXj)#pxhH-sYlS.M$,>#ue^01(ul+#_Q`,#Rq`8vNh'S-<).m/*8g*#l`r,#sYlS.vN:7#/BpV-l-B-doAp-$*5JG)3lEG)V*GG)4t9=O]2)##", 
			cantarellRegular = "7])########WnGr'/###ZE7+>)322'Ql#v#RxMT9$w10c2U(##-k%##>VmT9r1)%S9U*##Sj*##v5:t8qjjcDOA'##wvW30B:,h<DnYjlAB[w'P_4R3lO(e=<<ee<nw]w'pG+I-iSte=pe_L9H@*##K'^w'7vA0FZ/'kcn7*##`i'##GtBUC;r:gq&HOk+^HfD4AJr9.N^Qv5_(iJ)Z?dW.;h^`I2x,&9HfWds,SY#u0iR/G-d#[T)$vx4HT3w$qmnUCCw;_tP&1LVgn*sm@C=GH1*#)3c/qH2]qk>-VdJe$JbGw-qiWaAeI1=#G<5)M)Z<ig=8[QN7]&;6LPuxkFf`w'OMYY#0]Wh#cJf$$nNK:#&/G:v/n#?$JB'C-$]lo.f6%##QhSe$UGuY#@6B2#*5YY#D1O$Mt.BrM7@RxkW$eY#/55##nOSq)ph2KVfoWo72&M)M@Zh]4<lc)>.[6;-UGb(jkV+##gswo.0$0PS/(v]lQk:;-(U7p&BG;d*RG%xK0@n._/(1B#,:gxX01L^#Du)Ab1:h#$nkpY,2C-?$N9e`E3LHZ$)M`fU0=?v$ZADPg7q`s%7x(Z#:6]p&qcv]4;?x5'$kp`W<H=Q'vZ_DNMoVh)>&^M^'5>>#0>###RMZ9V.(1B#wJFSR<UL^#;Nw4]1:h#$BJ[rd2C-?$;'</:3LHZ$nXNMK0=?v$6QquZ7q`s%'C&;m:6]p&]AmJ(;?x5'v7(g:<H=Q'YlL&=^$>j)37=)W+/G]FcgXoIT1PcDH]4GDcM8;-YqTiB+D-F%Rm>G2WMhA5)p4L#Vrd'&YJ7A4>36R*A=@_/2O/F%A[u1BE;Qq2e+Be6m%L`E@x&?-/`?VH?qTJD<[6^GK.75&W*?X1:*G_&VR?M9I^MDFZkk>-W*f'&5ef'&)=Z'8:si+M5If>-cFII-8)m<-fQqw-pm-qLI4urL6#/qLIwXrLIQ-5Nh0n+#;1SnL$NpnL:*8qLGWdD-lIe2Mw6;PMw'crLNwtRMM`7(#-Us-$-o^%O7juG-g&l?-CbDE-$^mL-QMYdM]mrpL$SxqLxT`/#(TC5BE9Q@0#8ujtT.Pk+a:p^f?_n-$>N_w'_j;MB`]iQj+O;_8K.R9`HHO-Z-pl%=/mC5BWV6^5rw4R*C9g'&G-QY5+v4L#vSWiBT1PcDlE`>Hn2iKY@5scE<<i`FBt9/D6pjG<=;tjtYBDP8DX=gG&>.FHMeZ<0+9IL2>*e-3<6i41f&@UCVpIKF&6FVC^x2s7:8QhFsl<6&h=r*HhxtLF%g9fFM>4sLX2oiL8H%oD#SI+H-6eYH#g1eGvRb-631(O;iG3VCd6u?-BdiM1+sDSC7;ZhFgLqk1T+IU;Yg>[947V.G'fC90rxuhFH-B5B8tDU)2?ijE2MD5B&?^kEdjeUCCt7FH-ESE-rGnC-=;G;&:4//G/3`$H(Av-GWPX$HAm@bF&B8I<a_%##C^'=-VK%'2vgc+#E<x-#ZZO.#$mWrLx?Y6D>LlpLjLRx-k+7;8ZnF`8';_g24gBJ14S#WoMX(d-hIGd=%&2lMR4kn/H/^'59Beh2l9BN-ZHJrNXX0,N02$##3:j9.,9q'#SjS,3?^oW_NprAHYWhk1>g8+4]c&F-or&F-doX$/tm@-#9OUv[j?2/#3sarL3RxqL+Od.#w5^l8+b%F-g*S+H(BKKF>q^JDTQ^`&_j;MBcMFX(dGMn303%I6wuo+DxX4j`l_WWB,JqoDQT5fG9ri>n,;*n85oIvn>+3(8g-+Wo=Lg?;O%g2`+1eQ8>`;ml#p;A-qx8;-%AT;-JKjb$;/Z3#-.MT.FVCv#ICLV%dDq.L0v?S@wo?MKGWarQxG<S[BVMonqfOuubC,v,6Se]4HD`uc`J^;$HZC,)Yis]+va*m/3&vc2J0hPAY3fVHZrqiT%3%vYA%mi^TKBAbV0ZcrB99#$:0bY-Zxrl09uMM:p_hlBT0[fM5@FSSM-](t+GO2(=e`D+Ns9v-e_bJ2(<s]5:Y-p8[0<>Z0mdf`EWBv-eR4j1Qj>^#'5Fm'9:?g)JN4^,tZmD4f.:pA'L'?$hIJm0]R*<.*$Gp]2T_2_>GW,aFxoDb`g&Tfs3ZZ?tLo<%#8P:v9L:A-SgIYPW13GVD'^xbR[b.q9Qv`*rm8/1sO;^cVmE##;-f3k@LI5/1pYG2i`o)38MbE$.eYJ$cp@L$/pkM$Gc-O$g6BQ$wo%u,ltYZ,LgF^,k(@`,K?dc,$doe,*-9VM9t;L-T9dL/86f=-YDOJMx6R@-KmvxQ8R,8N`/;hLpR^COU$lB.hElR-]>3l%Xuf=#Zu(Yl@Yb4]xT9`W=:'GMjjSrHCNYr?q+1G;1qdr-'qg@X'GW+MoGClJ]tQxFO.uCEfmn_jVf1iTtvEuGQ@L%F?/sIC7TZ1Bw[Q%=ec9c;p..57Kb$)27&RS-okHG(XMol%*>mFqlvwOn]qY:lP=^=kJoa@jDDI(i.q8le&@wRdii/``@d[x<.v-xseaeOnG@V+L[%Lf'G^Vo$?'$;#*DmbqNc7(ibSs_`UW1:u6xuR?[=54It+XRHnV@:Gh8`XF^?0(D$skX4M,w0SqNBZ55V-<-8cX.hWFE5&K)sA#*+V2&_8YY#*P:;$.iqr$2+RS%6C35&:[jl&>tJM'B6,/(FNcf(JgCG)N)%)*RA[`*VY<A+Zrsx+_4TY,cL5;-gelr-k'MS.o?.5/sWel/wpEM0%3'/1)K^f1-d>G21&v(35>V`39V7A4=onx4A1OY5EI0;6Ibgr6M$HS7Q<)58UT`l8Ym@M9^/x.:bGXf:f`9G;jxp(<n:Q`<rR2A=vkix=$.JY>(F+;?,_br?0wBS@49$5A-B&##-fJcM4=c%OK&p4SbUEcVgka(Wl*'DWqQ>]XvgYxX$0VuY(Br:Z,an7[380P]5DKl]:Yg1^B4)J_FR%G`:_ixF>vViB3E<]t9&d+VP%PcDQax:HX28v,BmOlS^s&>GkklV-Sw@VHR5@)*-8QiTW6i(EFR/_J45d4#[#R0#IvK+$.%#'$XO.%#brdg#+j7-#';w0#xG7@#+98t#f`ot#iMSt#(<L3$jW_R#hlUv#3S1v#hU8&$]d]=#?Xft#rxx=#0fa1#0lj1#9x&2#A.92#CF^2#1.vE6PqG3#Xk>3#=nHK#kv0J#w(eK#rV-K#(5wK#b4S>-.VjfLw0#GM3Vh*%4%UB#+GG##8$lf(8Rj/:ogZp.'2>>#%M;4JDUHK#A&x@t_4-%+#hYftu&nxk+ZYf$V?$)*Y;Ke$U_+/(?]nA,-@Ke$PJ#lL1V7P-so66M=(n##HR@%#eQk&#,jH63DDW)#`C,+##7D,#Jgb.#Kx>tL#xWuLtnNSTk9#AX05Kl]It<`anX^.h7a0YlPIxLpx=L;$?-5/(dhUS.-p()3Um*/:m7Z`<-nKS@Hit(EbQfrH[a=3B84KM#HLpM#l&8P#6&cQ#[=[S#u6'U#:0HV#PmMW#cSSX#'PuY#AF@[#_W0^#s&h^#5&<`#NoSa#&b@d#ETXe#aS-g#$GEh#<:^i#dj%l#1vbm#Nu6o#hhNp#$CBq#:6Zr#U5/t#p1c:$.fLv#ZW9#$'Wd$$O1,'$&bI)$CTb*$hxm,$1xA.$KkY/$`Q`0$vDx1$<DL3$XCw4$uBK6$;Bv7$WAJ9$uI:V$:@I<$V?t=$s>H?$9>s@$U=GB$r<rC$76=E$P/_F$m.3H$3.^I$O-2K$o>xL$>PhN$_haP$1*ZR$M)/T$j(YU$1+.W$L'XX$k2?Z$7>&]$WIc^$tH7`$@mBb$clmc$)lAe$Eklf$l2oh$22Cj$N1nk$k0Bm$,h>n$Cgio$`f=q$'o-8%Be<t$_dgu$%d;w$Acfx$^b:$%$be%%@a9'%]`d(%#`8*%?_c+%[^7-%x]b.%>]60%Z[a1%wZ53%=Z`4%YY46%wb$S%<X39%XW^:%uV2<%;V]=%WU1?%tT[@%:T0B%VSZC%sR/E%9RYF%UQ.H%rPXI%8P-K%TOWL%qN,N%7NVO%SM+Q%pLUR%7O*T%RKTU%oJ)W%5JSX%QI(Z%nHR[%4H'^%PGQ_%mF&a%3FPb%OE%d%lDOe%2D$g%NCNh%kB#j%1BMk%MAxl%j@Ln%1Cwo%L?Kq%i>vr%/>Jt%K=uu%h<Iw%.<tx%J;H$&g:s%&-:G'&I9r(&f8F*&,8q+&H7E-&e6p.&+6D0&G5o1&d4C3&+=3P&F3B6&c2m7&)2A9&E1l:&b0@<&(0k=&D/??&a.j@&'.>B&C-iC&`,=E&&,hF&B+<H&_*gI&%*;K&A)fL&^(:N&%1*l&@'9Q&]&dR&#&8T&?%cU&[$7W&x#bX&>#6Z&Zx`[&ww4^&=w__&Yv3a&vu^b&<u2d&Xt]e&us1g&;s[h&Tfti&mX6k&9t/m&VpYn&so.p&9oXq&Un-s&rmWt&8m,v&TlVw&qk+#'7kU$'Sj*&'piT''6i))'RhS*'og(,'5gR-'Qf'/'neQ0'5nAM'PdP3'mc%5'3cO6'Ob$8'laN9'2a#;'N`M<'k_x='1_L?'M^w@'j]KB'0]vC'L[JE'iZuF'/ZIH'KYtI'hXHK'/b8i'JWGN'gVrO'-VFQ'IUqR'fTET',TpU'HSDW'eRoX'+RCZ'DE[['`D0^'&DZ_'BC/a'_BYb'%B.d'AAXe'^@-g'$@Wh'AB,j']>Vk'#>+m'<1Cn'W0no'x;Tq';)dr'T(8t'oqOu'93Iw'ZD9#(,iD%(H[]&(igC((/gn)(NrT+(p3N-(?H>/(gc@1(-ck2(Ib?4(faj5(,a>7(H`i8(e_=:(+_h;(EW3=(`PT>(&P)@(BOSA(_N(C(%NRD(AM'F(1I(_(FoamH[5KL2vc-+%hC%+%>wehMWkmhMw?ju7sPudG=nhmMH?4TB,ZkVC52%Q/UxGhFoHD=Bn$GT8'+OGHvCae$_N)nD1A;2F)`*_ID%ON0Y_nFH[6iTCGQwjNJHbpB.O)E-0Hg;-gGg;-7)`5/W@ViF73iQMi,gjMSD4nMi#KNMS;oQMlGcgN#`0kNm,gjMhD4nMi#KNMb#OvL$_:-Oju^0Oo/^NM#G+RMnSugN#lBkN6;TMFvK3.3WY5W-a2N15?HlC&SeF<B.5n-$qrooDnj<nDl3_M:6TvfDn6_M:;fsfDl3_M:xmufDn6_M:-%1N:6)uq:6M8,EclX$K3b3iMT&$JEsp%UC#BKKFKgkQ;'+OGH)`ae$)@K88i[oS8d^jU-9Hg;-v#jE-56T;-=kF?-jQC[->xIX1SsZ.<^>NDF?n'7B@C=GH3p0SDN0W7DXS6O<Quo`FtmVG<Qxo`F)dxH<,mX7D/o;2F0%OGHJ2Q<-)0sE-TdSF-jd11.gcmOMI4:SMvxuOMZ9CSM%PR.O0jv1ObfHrBnG^kE@g&5N)IsM-.oef$XG8(>,%H>H%ZX&>#i3GH$j0B>'wI:C2%be$&<xB]D30+%&?4_]B$be$$5^oDGj<8M(oEfOP1jiO;&ix7`maYH&a0#?./G;I0)hY?PJ#sI12-v?jWE8J'#-v?np/<-A].;'FmKNM:T=S9d%@B5&sOhFLZ[7Mv%m4MAEUSM$67oDQxcg3,RgS86lh;-Js<_$DB=iMk3EiM^9NiMfjAjMu/'W$P5UjMp&^jM=oxF-&#>c-01LU)?w[hMkL0`$A-ohMEu+G-'v+G-'v+G-'v+G-'v+G-'v+G-'v+G-'v+G-/iZx/Vs1qB*SvLFC&^GM`-gjMC-gjME5gN2#LlP9f7,dM54pjM54pjMF/D-4Y.?LFplqaH<ndjN)*u89>RXMCx5/H<-p(*H:g><-TJp,MPqvh2kTN,3j%Gc-[Sa3X,7@LMNuvh20Oo>-jMp;-Ztx/.PTBNM^bQLME`8+4B#/>B'B#hF+g+CAQlm--4N*.3'wI:CTmww'UuuG3r_A@'AL[H3d,OhFm'ZWB4GEjMfBIe-8jRtL,47LMsw)i2EExG30jt*.$$u5C$e`TCTf,mNjfdhMYfdhMYfdhMX]HLM-nmhM[+E.3v*wG3N/K_8q/v'G9aGW-qXow'0Heh2^&B,3M?LkF-77LMStmL2sv&d3eL2d3U^Da-igHb@8;>C5i7j?^^Hs?^^Hs?^CIjq8l%BbIE[JR9]#0g2TPp;-f7,dMoxBo-(rVkF:$4d3rV@m-(rVkF2`h;-FaQi$b8P)Yi_;u7'-5d3jkIU;fk$T^Z)3i2xLD=-ku+G-:op=9r&,d3QCT18^%,d3QCT18duxc3qnd;-/*%^$0LehM0hdhMCbD:8F.XkF7ne;-K($a$0LehM8Sda$1RnhM1nmhM1nmhMllmhM1nmhM.b?i$X8@Q:[8jI3.Re;-lu+G-lu+G-lu+G-lu+G-1o'S-AG'`$lwVkF2p>kk2p>kkm$WkFm$WkFm$WkFJL.W-ri/K<i_;u7wuxc3ma&d3ma&d3ma&d3ma&d3ma&d3ma&d3ma&d3vD5*4K(:oDCg<i2NEUkFn'WkFn'WkF3s>kkVq.W-,(WkFn'WkFn'WkFn'WkFn'WkFn'WkFn'WkFn'WkFn'WkFP_.W-uV/@Bp-WkFdhJ@'p&#a4s>cA56N0g-of-+%+fVA5+fVA5S5_A588ZA588ZA588ZA588ZA5a+.'mke;u7>uWB-OxWB-OxWB-3$Y?-DdkgM]lAjM_tAN2:wK88DxFe+kkV:8B6L883`N883`N88PaL88QjhS8C?hS8C?hS8-e=<Jm-S79M&,d3(%/>-Mts49M&,d3.gkL9Lvxc3^)g;-rVYd$7[;<Jm-S79Lvxc3^)g;-rVYd$7[;<Jm'8r8JQf;-&q(P-&q(P-pvVE-oqSN-pvVE-bFQa$'PEkb'PEkb4Yh;-Ha?i$CjgjM5/gjMFs+w7[fF59p%J59p%J59vCbsfm-S79N',d3Nop=9Mwxc3`6/W-=[WkFoAtJW$C[E5LPnn2E>)@0t`e?TcC/s7ZdCkFlkfS8pt+p8L9CkFvEcP9[s&g2]s&g2_,K,3cU`X-hf-+%Xo-+%jQ<g2tw]k=Nw]k=2XnLMuVxb4i6=kOD%ZK32WbG3%/_G3&8$d3Pb%d3Pb%d3O`(d3O`(d3_6&d3_6&d3Pb%d3Pb%d3Pb%d3Qk@)4ol>)4ol>)4`?A)4`?A)43hE)43hE)4%=E)4'LjD4DMZh-lf-+%'H^D4'H^D4DI[D4DI[D4DI[D4DI[D4L$OE4EJCeG-ueBI*,h#?'+OGH4+be$r;3nD)DM*HTigPN1sVE-8#.A-)uUH-*uUH-*uUH-*uUH-*uUH-xDiP-2NC@-3$Y?-3$Y?-3$Y?-3$Y?-%JSZ$@jdv.vW]v7=?/s7HB1s7Y(d;-%JSZ$1nm?g1nm?g1nm?g1nm?gthLUDPeX88RL/j-xf-+%%5N88%5N88%5N88%5N88%5N88%5N88%5N88%5N88%5N88%5N88%5N88%5N88%5N88&>jS8A;nS8A;nS8&>jS8&>jS8&>jS8&>jS8&>jS8&>jS8&>jS8&>jS8&>jS8&>jS8&>jS8&>jS8&>jS8'G/p8BD3p8BD3p8'G/p8'G/p8'G/p8'G/p8'G/p8'G/p8'G/p8'G/p8'G/p8'G/p8'G/p8'G/p8'G/p80+>69K(:oDfO$k2NEUkF(XWkF(XWkF(XWkF(XWkF(XWkF(XWkF(XWkF(XWkF(XWkF(XWkF(XWkF(XWkF(XWkF?n7LM+T,k2c#/>BR/'TME*DeM'4pjM'4pjM'4pjM'4pjM%x83MkkZL2=+B?.<<eh2fgh*%Vi-+%Wl-+%Xo-+%Yr-+%Zu-+%[x-+%Ic4U2PW1s7Iv(_]s*gS8pt+p8Ud/g2aha/1Hu>LF;JM*Hu%vLF>A2=-foTW0jc(_Im800F16wnMqOau.TX_^HE*RX(qIGXCx5en*GWNI3Ws[6D'%=GH%&DEHlMcdG>i2mE=jNSM2>5/GCg*^G7-RnM***hFI-w9)Cj2=BogeqCJ$8kE1J@fG%?+vBCr;2Fsl.gD?o6XC3m/+4t*tC5pZ3nDi5'oD%a>LF9iHpD(3]6Dn>n<U8,^F4`YBe6ECmHG*dYLF=4BF%61M*HEmcs-:w:qLw4:SMvW#%.?FnhMedd5.Eb*MMq_D:8h[oS8qFe201^I@HsN76DDX1@'@Q0NM;u`:8b%Z<-qw.>-#NZh-OeFU2C`KN24?;U8VWg@Jop7UCq;fuB8$<:)Z[?k2HLRLM4AxR9/o2a4/'<O+DcTj2fRS883=qo-$-E_ADS^b4xQuP9kRj3=Q+j*.SgA,3fD^G3X##d3m97mAxHAmrA@v<-Ss,;?:fTJD8q7G-`O^66HJ8DN:^v1BBDo+D(N(GVcMi+MYdD]O%e3PSR=]%XEVDcVJ-m%O,/r1K/TbuGq.JcM?*[uP:#HfUce&DWMhPrZ&<r:Z,T7VZ^j)AO5Jg1^4;0P]<x(J_<lGi^wk2MTGb[(aFR%G`Kh@c`Yp%>PTEX%bTQ9]b1X/JU/hg7eaD2Vdg]Mrd+M#;QpR'MgoCFlfw*?fhwt^.hK8@]X,krCj+[;ci0qV(jV5t7R9No@k9ZOxkS2d(W?ukxOA-IYPEE*;QI^arQMvASRQ8#5SUPYlSYi:MT^+r.UbCRfUf[3GVjtj(Wn6K`WrN,AXvgcxX$*DYY(B%;Z,Z[rZ0s<S[45t4]8MTl]<f5M^@(m._D@Mf_HX.G`t7Hc`N'+DaR?b%bVWB]bZp#>c_2ZuccJ;Vdgcr7eBHWrQk%Soeo=4PfsUk1gwnKig%1-Jh)Id+i-bDci8fBYP?P#Dj5<]%k9T=]k=mt=lA/UulEG6VmwM>`a?Dm7nMxMonQ:/PoURf1pYkFip^-(JqbE_+rf^?crjvvCsn8W%trP8]t=r7Ycxu4Yu&2>##%6g:m*DlY#8i4JC0ihV$4+I8%8C*p%<[aP&@tA2'D6#j'HNYJ(Lg:,)P)rc)TARD*XY3&+]rj]+a4K>,eL,v,iecV-m'D8.q?%p.uW[P/#q<20'3ti0+KTJ1/d5,23&mc27>MD3;V.&4?oe]4C1F>5GI'v5*oF`N'ANfL/x+DN)`f(NKb^V6O$?87S<vo7WTVP8[m729`/oi9dGOJ:h`0,;lxgc;p:HD<tR)&=xk`]=&.A>>*Fxu>._XV?2w98@69qo@:QQPA>j22BB,jiBFDJJCJ]+,DNubcDR7CDEVO$&FZhZ]F_*<>GcBsuGgZSVHks48Io5loIsMLPJwf-2K%)eiK)AEJL-Y&,M1r]cM54>DN9Lu%O=eU]OA'7>PE?nuPIWNVQMp/8RQ2goRUJGPSYc(2T^%`iTb=@JUfUw+VjnWcVn09DWrHp%XvaP]X$$2>Y(<iuY,TIVZ0m*8[4/bo[8GBP]<`#2^@xYi^D:;J_HRr+`LkRc`P-4DaTEk%bX^K]b]v,>ca8ducePDVdii%8em+]oeqC=Pfu[t1g#uTig'76Jh+Om+i/hMci3*/Dj7Bf%k;ZF]k?s'>lC5_ulGM?VmKfv7nO(WonS@8PoWXo1p[qOip`31JqdKh+rhdHcrl&*Dsp>a%ttVA]txox=u&2Yuu*>Y>#.V:v#2oqV$61R8%:I3p%>bjP&B$K2'F<,j'JTcJ(NmC,)R/%d)VG[D*Z`<&+_xs]+c:T>,gR5v,kklV-o-M8.sE.p.w^eP/%wE20)9'j0-Q^J11j>,25,vc29DVD3=]7&4Aun]4E7O>5IO0v5MhgV6Q*H87UB)p7YZ`P8^s@29b5xi9fMXJ:jf9,;n(qc;r@QD<vX2&=$ri]=(4J>>,L+v>0ebV?4'C8@8?$p@<WZPA@p;2BD2siBHJSJCLc4,DP%lcDT=LDEXU-&F]nd]Fa0E>GeH&vGia]VHm#>8Iq;uoIuSUPJ#m62K'/niK+GNJL/`/,M3xfcM7:GDN;R(&O?k_]OC-@>PGEwuPK^WVQOv88RS8poRWPPPS[i12T`+iiTdCIJUh[*,VltacVp6BDWtN#&XxgY]X#jF]FXntxXm/TS%W:PcDga]rHZt)>GgsXoIJI9>Y*BruY>H3DE@CPVZ8[YiB4)OS[8A05]tRm1T>f,2^B(di^F@DJ_JX%,`Nq[c`67w(aT?X`aXW9Ab]ppxba2QYceJ2;dicirdm%JSeq=+5fuUblf#oBMg'1$/h+IZfh/b;Gi3$s(j7<S`j;T4Ak?mkxkC/LYlGG-;mhB7##GKb&#Fhc+#O_hR#EN,j#9P&a#U+um#3$=x#:cJ&$a>[qL3w:QnLXjfUNcpJ:`n)Q/bl^p.w0t;?8ti;QFY*-).uD9%`/bj9b?fvGbUJdVjr3TemS0Zum-[T.pL@B=:ur;mMpH-)D4K?5T1hdD;L_aN=OSaapuGw#5jcK1>PPEE$hCBXROBNpD8rZ>9eM?P`#)$ccZ%*s2sqH23Y%wl^]&F*a>#L:-/<nJkL3kTL/dq%7R^3KkvK*a#I8I;a?[[,BtD_Os/htH#su$G.07CXDE7x5xI,+NW^f$u4>aRJrilwu40'V.aa1rI:D87o>nqkp0PX1L&l1of*B_l0.&j7Jh'JcEHx-S]=x2&#tlcl9_;(>QAHBfi00>8/#H2;I/UNihrUC)+SYTPBcu^ofvV[SJ[e(5pZ*5#HVi[]l>'XMhCV/K2a#,aOAtePgQ8S8o%pYp8loQvQoB;po#8[j:9Q&EXN6-t%vI6HNG6OmgYCpg2T8^sedd/-N2;=Eb`Kl?$0)6t7f,PEOshX^lL1lTJJ']TfFZ>[-nB[EXUZ;b=SP,bXbKu$$oIQqA.snHa?wab+FC2OL*B)O_WX/bt5,6=78Zb'YWD`X.gDAC>tNBU]ea$]$TK2+=>[PUSjYZkhCq3f*r(l[??$,4hQ8.Y.GMS@H<f,(c4KBrA)+1(ljCk70`9sOLKkP]$bwxbtd#j+=hI7`Yk<,ctOCfr8F8RS9`Bql:CAB]mXk;Dc=4%Q(&3B5L)>NPhnu.^-dRu]H)cOJjC-_DPF+HW&o&*N;Jhc>R%dqVfErpv%f*>W8>>)NM3e^a,LZia#(@BQCaQt>enTUT9(C0BZ02>w%q$`^H.5*9gjJ2e+Ug(qB_9=Bd_3Q6:cQ'$eijrN;Q>jW]HOw6(Ua(UB:bF*Y?lLX&R2a0Eb-ZEuPv2ODViV6qP#GO2+CMbGj*Eha86XO2d5MUBg$YhN]Ae$[cd.LjkZ4r'l7rh3cd^[@Z%37LSp6CZRe>Rhi$e@%XgN:00x91E2,#xRvt17_gj%1jsX>:^9.uC-Yp+rTPa)G,<Z.Y8`4W7LNxa%7o'3l`QM=+u1qc%774]1WGwKM*GuUi<*?EcPP@KufgGpr0rAmx@A4<SU?WKia[4TSC9x`oUg2Kfk2gxo:*?acP;X5j*AFSPVP8'jE&a@>f'*Yv&BNM&7d.W;Ku1.&nG(Tj**luMEEr$ZS2k'E?1/h>Sgd3mi<)>T::,>aQ/<J,uUAd#JNI/w&9gdsK,+`v]n_H-#X`,<^V>4Ns3:'k3Jaw&[OLuK+N2M?J-8)-l(cW33WvUt'tT^Kb$XK$JW+p*6TeZ9haDXqC/3Nwf).PL4m4$@]-k2(7vxd*mSS%]&WmKIG(8^eYCG&V(ZIe_RH@]el=.xU1rR4xJJ?rtp8x:rCX;)o`@dh%&@f0]AAX@%]=#NY'f;_.G]5?r_-1*itu?Xo;%ga1XCS=8)F])DRs%c7r9v%,?QQBY^^49v'<m2/>K-O]]9hJfu%(jY9e$^]SjsQ`nGLtV1C<eVLA,:;h;Y.^/5+^DI00f]f_5=g5#aJ2XeUGW(^bqAA82=pVmp?)nNbBW11]a,H`dkA].A>vp]a`m3F'`#KmSQv^6lCsqkl^d6=W=^fYEvp2,j&6WP6M63Ln<E[L*V63Yv:<_g`,e6qF93bw_._8':;-d2ng9;#/sW_jxw*%^=(I?'rpNbkMt05Rh[-Z=MIF.3Zw<Ui]%i#D0Y[9D>FXU4/^'o.+JC8Www-Z%C%Y(J-e_J*sO_of6S@BO]VXh5_Bx9uF^RaqrGi5@Q)cR7j<.m,&Po3x@)VMn[W=hh3L`/t,:fZp`.iuDUs+7pS'AKCL1V`O8a4kYu=ilee6cnqW/]p%?c:r12[4t=%T.vZP:8*Fulo30I)2>wJScIn-w7W):t=h36coNx*BYhlgMJHa(N]g#7K/-h@82Pr_<m+?Q%dRn]l25R?C5t/'cDfc7jm+Oi[vCPv'w(8NPaAD4e#L_Tn8aOw0H[q?D9<N[LZ_8lk/vTE%6ka%LBTD0$$h@r+3u?anE/;FZ9<U;xdR7f#OGYF0e[`7H0m8QNb/p0UtDhpa9a;/Y[1OU=tsahIc`WDmw`HQNbsc.L/u^<P6u:XLC*DxwC*MrvwbF9GdLs-7QIoQ3h0'`uA)THVGsV/Bnf2J$u2:ch<d`swh$&u'k)A9_8&l)Xps]mKJ#e(*skSO*u>[(lDs92a8&&5nGVbp77h&FFZs9LrCs+:ik8@7>I:w]=_t661:8/%T772OjJsxRkkiQHdk81bD<%q<^std7.jM-<#`689HT8o#&#uUAs9)s_T77tMF5tik`[%Y.B7dYX'8$Z9aqHV7V;>>*`oO.DY)JVsEU<=K3rO^fHjcb>B.d'h1b%M(3jBe>>g?a3YU$mxm8%9:FqBGASx0W?GsFf<.fK1_V.?#$IfOE]PxR;HUvGOx^0IYXqXNWjRJhZ(q`j(J9qOdL9EsMoidBPVmAgOEjq?QfLs(fW@@4ZK7I$$*sw5O`:vsh6j8&kETqtdD9v);Ss9)qii<tw@&9&:v]=GKc*ohc/Dx74D-R]j<nI8Abj_hUNjI1VI/9&[mtSLu4&2tZqT3pBYM[sjIv<ZO+)Ca,BbBd8:3_%Z*-/Fw7qkt.lbwm3lu]Or5K:`hT9h%_^j(2[/2`*J#DC*J>Fiad,4L#PU7IsG?eD_#wSFnm%bfa#HkZ6de*Gsg5]4=K<nME^78-c&>,^bN-,>anD,d,k$YFM,&T_OGU^5chIIR7$32mA(aM,5Th2v8&KlP'k6kMiG)f3%q^R^tn6gCIRbc7$SOm0TMdQU68*[Qgxme,;f3[ctOG)`3.+ZeOAQhstKioC*ZFoj$a[s)<%gWRs+%-.6T(DmLcgJSs(a#Z%JMbJsOT-+)9Tjb$qjt;d(&pktj.7i0,,cd3k8;sd]arZsA=9:6Q(n[%JiTI:s&'@OsZ^0gw07=QdY(dO)AFatilf6;t?Fdt+(k>;50#@NUGDtOl`%Hs;fgid`$hm$i<OaCN:t)sNH$U#eA[6$vrd-qd-[ktq@)@Ov(IZsWm5=h(cf$OUeOReaR+CNTVQI(.YGFskL89&JU.3M?HLXsB&KXsoXiJsWd)C/O&XQsE<#Ys6l21'd<XjL;r3^G52'K#BH57$Ot6+;d3*LuQp^Rsu`;d$``3'fsG;T#-xMne%)Xg1?0wl)='^ctTC#ft1]^:6.Arw4$5:Js_0;;94r<u5=sWu,OCLKC`$.10xcA#MQ:uDsSk?o.*`Bp/<VEj08W3'O'PS7%<?s<Y$`D5Uw]=_t<75o=)+WqO,jF(<'EsgsOM9(fr^2lO#_b?Kss6(fi);T#1m[7$u@ae)3N;2^WpD%h6c(icv4abOcCNbtRA0f%ufCte.=UDsT37=`O=JvO3#Z-j7`q@0u2Ur:*71kbDDl0TM-L)f(7fCkZi+UnS*Pq),V>:$qvmx,ScAa<g+Qe%<v97YcB[Llf'rMiVSoC8r^j-6OJSg16vkrOoUqdA+#TG=.M>T:A2$UnegX4KAYLq8sG;2:[_8CB:Vfh=j';6`;iCuLqm/lUN=bveB]'K#[?Z7$LkObMh]QU?2]^]t$-YhO:RZuO#90HkwW+19?%uxt,t*Fs?uR_ORCF<q;9_Ys`Zfn@n^KW-$BHVm0Qs0h3VUe[QmIc%ZM#g4an_R1n]rI?1<bf%$]<kF<:IkFYAk&4n3dJrZS%M'k?;igEU2.vm)$,nr`4:$m7vLg,dV:v^fQW%^ct,ivka4od5-L^Y'wrtL+d0G.DHe_+KY@fFRgHk3'>usqiP:vg(PnLT5w:tWdL+rVwX:vHrCh>rAH>+wqZS%LY:>#xI>2v>cX(p3LY&8[&4GM>6XId'(d5Wn1d4cIVbBB;WEc%Wj9cti02gtj[Y77d7xw+S<C=,KR4Gk^(Lt:t&0t'gGGiT7)[wuIo0cNC_lnAOUii0bb7>#$9tvu_NKV2aNUR%i;xat`@7H54MoYQ2RhHQ_=ahfnSg%OFYS:vOfb+v&qNOPd/ZUVhx,peud69*fj^F)pv%V?&<WKs+rSCN3tI3kU.`$kT:&Vkm:AOJQ&gC)/H0)3g+RY#bXdtL7;8ZVad98.amP:vi::pLnP[l1AORV6(VD)j$(4%`gr30MEPEJi9NR:v<bh8vCk:)sWBI#MARrIhS<4vu=TY7k<c6>4(6%2.Z3=lLi^*d(]-I],r'058b)3X:l1PqehsXS/Sg=N1PS'-M:`D^qP1[W%&@'$vL-Sw0U>uIsn=0`j'Nw,)B9r:QYlS:v7H>'vJ9KuXX]sr3hbmE2;`dV%qCtK99-,+)Dc6.(jUas-`O`]Zv5#I8*kIJ1ReP:v/>_%v:ZV;&_L^%O;^T:vg)$+M2,2m;=A;igjq8>#8wK&MOHm&:+3wm^Ibav5I^_;8>#EDMpa4/*t^;>#OSguu&Zlb/Y?csgBoY]4R#FN'J@hYslVd*`>8DUk(7cuYSqQY#+pmj)?luYWT:%Vm`;*O=>SE$v@Wd=/J'^M[S/n/:ZwOI(vY%Tlx[,AOI@pgu[i_V$*+,7_N',##P^<$g^#>%MOm^.C,[2]b6^Nt:=Jub>s2bv0/i)M-09qj%/kOL7H?#:VmcRfO#G4dY@hc_$6O0LI3`]DsqFTU6_9pt5epvctv55^ti>U.(_aSO&JbEnEExu(5)82/3*Z:>#:;p9vhPc<sCBk]#;qP^t.@71'=;9Wo]6]O&ghH#umu@9&GQlusbQN49pn;Gsc.(V%hApwF?m]$uOl=hO;gdct9&Ktt5skIsJkO^$@UeqH/ct0hG]s$O2$w'Ef6C(Eba+(&gN.P`>x8<$%G^3oEd,4ot+].6ZR&4AIZ*N'3rl#t_.fEsXQH'lc`YC)vaq3tQC4cOb^*+Gp/i^$%9G`T=p>tOpSV(8lHhHHaW6EI=JdLFOZ)BJFZ8uBu_Ju:H+(^OLtrc]KvnjZq:%'UC=loO2F:7%#U+S%amZ1BTKvS-t`RR7INGZsTWJ7%2+OPsYE>h_X&-Ym-r3[s8s6_k9XKUs%_Au,3Sww+Pl2r`*O0wVl3YibIx[C]>w'/eSF3uOZZVRsQ^<LseUvmOJ7qktTb+dt9PJ<9@=h73@4XTsC>eKsAQ<rOEbcAV#DXm$;:kVKX,u]tOmPFsbG]Psg4fHs7i.T%uq'%+Eq6%Fw5N6KEeF9L#j8CJ5Y&;KY@0Gs5GR,MLn7kpea>`B*$b-6E(pH3IU.f1'iTs)g/vtjp.qoO%q'`KA#NL%1lj?J8>DT.p.-:-<Ge-IH^cvstT7`sI_J9&fF]*r$ZQN'3.IZsG78CEu&`XkdFgqG[PR$tk_qs)`SkHroSS#*HxwKs5D-bs>O4U%AgQN'5odvs52(Ab4Gp<l#*,:&$?4`O'1.Bh2smwss92Ds#x=.2l%hj)xXG3BL6Ok+C;r@*t+kT@w]`Mh>tA8Mv;_<.dl;+3tkVN(@j%4Jjwt<M`>>7.L0L2hEmUF3X'6s..t;&lq'0KIUqXcsTvY1181Lk)luP^tbH(2t%YiX-EsCX(bn=X(5$A9iFe$K#PaCtL_rw9)?,RN'M%AjL3Z'5Wm?N_/vUTHkE5cs4YIe:5Gu#lL,WU%OAuQlL,P;XMbYob-pHr-?jB:U)jTqU)VhTU)C;RN'8&:W-V%L*R[?#u>'[e>u0O_;&#NaE[/JJZsIp6M^CmLqkS9RosO4i;&^KpF)FL.U;[i&M5`tmU$U^[_ONTIIFD?;iiB'Hr5QQkb?(GFc%.%eIsV^OIsA83+)&mu$4bh(_tP1l_N)(D_t-gG<-rG&W60Z(_trQh)-Z?<WX:i6pnVwUC1;PbjdicXImvme'/8ne'/dU80UAC6&l7aE$M8Q06*-CN>h<MRN'E*D]02WA_aPFs<Y)5NmLOta-IG1'U#-e_7$f0Lk)t5=Hr'+P4&PW=<kq5]'/tSRq)*C`ZYUr=,MOX,CN=H2wO9%UI:7QM4Al8mOAvB+N'?J0f-NYRN'7'Z<-x(m@.SM&nJ$#<GsH.;x.boe<&6x2?7-mx#M^8L2:p3dXPRv(<t=%lEj[WfRICb][sa5Kn)8]Anf?0HUZ@duH2:oiRIu..N'+P5+;)f[SsL6ji-9KS3O+X(uOlp87In<B?.k-[/5?Ae`O]EUDtm=lA8[*GGseZE[9dG=o.UE-e2[Tx3JM'I4t*W0l8/u1IA0h++)7EL(*_R)N'[&#U#$%C780dnN%kxHgsuuUG#Ak4'$I9[[FDfRN']++^D#;5%fu`X&)rH-:Ht2kWs@RXj)]lSnJu8YU$9e64?_&xH`Sm-tHbK.E3#1+ZsHesNg&oiNl.c)+2+t(fS*:F=&K7U=&8Ic:=JiW=&]U0'fHr3T#d;2Ds]Rhb<vHM/`&SmQks;S5T8:,oLb;u=&;46>#PgR*Mb>(>&$X1'fc0vKP9q(qko,@b7t'Mn[tw&*3WfD@>b`;.LkS'x4ScBweW@Tk+cq[I1o+S'AZ:Cde/RxusEsKEI:)S^.;R:bjY.Y^%'i0-)0Ob7e7s8>#qhK(v$>-AZIT8'FQonFi'2Ic%0*1etg6*#-YCfstg-w],:16>#[kco)KccNB$S,bnPM=Wk1mEqD9[cX?9^Ufrl?axH+oI=#HIH=#p3GI22Mv<cZq0-)L)8j)Fh9s.*bZ&gMcXe-YFH=#%SLe-C*je-J7gFMWISN'Bus#.TK5sL#qWigGlsq@.CcJiA.+l/.Y&HsoK<7AqHr6R%iVQK_&5WkblM[ssx(*1%s]f)]YwH`V(`KC8AE2M<:/wsn9A#*Z5`0_&WqHiw.ugLtRfR%7jcTkv.qT`DUYq)pe@osFuv?&rTfRI1&6L,Hcd&M<%*l%0S.D)C2TlS`CXY#qRAg)>b;no?E5>#@lqwulQr)8JxRN'CB-u7B]Y#>i:SZL#jNS7nD1.v$w>hmxF`NT$<ml/2Q=>#&jqc%tPIAEY1c[F%?P:v1BQ(v>XcWC(EN8v8E1q,A3FA#Q1f:d_%9>#;9x-vZ=+<,-wT4/GU,A'Nu-T.5vP^t7jv&3QMo<d++/%4iE1-)RJ1-)U9h--S^-HFFS<UkNr]7$`vIFEJ^v,Eh8l?tfi(*Mj[.EF0Ja@&7ZeZgm7/7IUE8Vk;DhC)FTiGsJOj@&'+w@&iG,A&9ve<C:.RDIwmGjsq=+cOC0'M'Hxu3X>kWL'w%CI:^/iuO7s?OA-AtrRYD/&G+seA#xcQfrM>=BGe;lat$K_[F%_^A,QVk^GLXIbOTX<3fwH+@'fst<1bc@ftQ[fR%l>;2g'w&SgMgO.sKd*^O?%3n6<`vJUtFWkUoH]RseHMO%Q.O4a9M%nYH.0uh9v;gLiCZ;[f0Ne%BU+T.R0ZcO_Zo/1K5N0<Ri@b%gs9`LjDNx9Vc=r-;p?Gs[/C-1:kPo)46HXtmlP^tkIT8/g>8+F5Rl_f`[a.SP7@a<T1uqOiYG)McarS&PGEpSD_#_$=tZDB`pmS%3n7c7Xi5tEJ[tF?@]$<6ObKd;u_$n22j)_96w7Zh8hRL'*4+Ls==B]hkC>wdb9$_shE@uOsUcmkhdOg$*if6<D9ieO:YacO;j-Q3T'W8eM@5;`j2*pOT`GO-jqB']pWs#u0>tLq,-7xRblrBQUvV*ihtIf$SBw/u@MOf$9mQl)v(ZA&jt?:$usGLIuvpZst_#/hVa[_ODSG<4X5#b%N2qXs/j1mP_#u`TkJ@l$XG4oM'1r9MNlg+.h$irO.-3l%lD6ldUoE1Y=5Db[eJ#kc82T?C[@Yc%xmTetGUS.(C.baOW;?N':Y_YschatP@QJX>Ps+0fK1akJDk)Wsl2U)f,r+M%se,]TAO:V`pU*VWZ>l`TGG+oO*Wd=MMX*O=<2^vCM&rkt7wgI<oU+IHQ]h@BEvuO:H47H%DJQX>o?8vfntZmgH;E6$7ZhwXKJ:lFH]ja%+U;1<gKfPJh76iOr9f_RRCf`%YK7><1Sr`Wu,tKY7ZK1YV`0e%vG/Pd1U'jT1g?xLFr%HYq-VmW2R?@<gfq]$0eA(R]In>PLh:__75a:B42juAmnib^xSlP'M6GPsZw&Td47-K#JW27$+i`3o3dX`Oo'P'slE(]4^VL(3>mXbOk'u'sLC1lOe?4`OW&9+Mi9op%8G3X$PuAEs*@Dr-/dPv$_4O=t;OxCj0%f<tWPe4&a3<9%/iDx)XFfwsdYhWHHA[wkl]A8mdwY8$Ir%c))*x_]8-)b%Cp];?X@=A9mMm@9+GRBIel^hOtBb<TrgOMF^cghOkETpUg?#a%'E6*K(tPtMiggWMh4mHIQE`4=W,VbOT+2#S=Nq;HX:-1Ioa/sO+Tq*Ts73;W(0'ic*R@NX.1&oXTuw_]-I[B[9Dl2Bk7wEAsF7aA>.1pOqb8-eq(lF)VSX_O2Rr#Ut+9@T)kqb%(<#sdEkRiOj:cSMncovK5&',I+&PdI/v80H[s_mO7qP^tskfXs3nAXsH*I=#%(jss',^A&L^^XHBTAe_*;0TdUnZ+pIY:1fOc2vsHkh%tcwq%*J;tO/B7'iBIpwR.F%+lAFann.A`[kAF#OO/>o<LBHgF_t_AG^t4k8g1]s/EsPpkIsWa&Es4YclLw?CV&[#Z=5eBb0Njq=D:orToORQ4DTkG7l$o:L5NjQ*?5NuG_i#TT6-'^2:NGw;gUCr+=TgY/rL#4?$&#97f()Sk_N'pD6lq)TR#RMXO&hK%+2_ag'bUP,)-GQ2L5T%a0buUK1Yc7he%oe#qOKPU_$KwQK7A[1`AF%Kb%%6(sZ:kiuU8>7kt1mD]Jt#*g[9M/8]lpgcHTRItC&IsGs_MOj)re,i9rnL5/VJ.]+1ek*Md*V]t_4gA&((6O]W>f*`gJ,Yspb.gsB)e2h90tA=65[p.i`-TaGuNMmfmoR#km`U$7/8M^'IL`sbZhs)ZE)2q#EgF2H2Ue$j[%Hsow.hrX5T_,D@5f(Ga)[Kp]Dii2Ujh'bKRe$L3A*j2)1[,6EUe`UN%d,j(e_WCu`1%L?EqO$T-W$Xm#qWsxPmAG%ahF/Q9;@(5w]X%Xo+-l34jg^^:T#?Qk2$V`dd)YvP^t[B%Mb?5rR#:)]R%>J$4A,tIFE/^04EA?CMZq*YlYmb.f,jhVI;wXTld5AXld,Juk;?^`b,XG5Hf4=BT#c5I6$I4=%+8*)gtp]ER@GB5ZsM&N>f%U'4Aq(d3u$0fgsq;<N'l6HwtSE:hd&ct(f(,$f1'e)3Yb$Q:`UqwiOvZZ4DbB9_%x%g=#KvQkSY'wrt6PMDalXZrOtFYq>K1rI?P,cZBZpP^tD*Dtc0'9XsQKeEs;ofDd0h*F`&MFa<DhDd8H?*YC0dMa%wTF;ZL#_PXe=3WW%eN3E2ZgiL,nd,)j?@wMn$PXKB-jiOq3xvSUjV`$6J&CLto>tOOAn[g4+uVU*u1^X9`SnOhvuq:4eoHs.i4'$xp`[FtHTN'18X#Et)-T%m.6FM?%cjdPOv?uVc)7IJV8`[Gb9x^j;/<`bB<UIx<2rOYEN,6QO7]+L$`N?:%A3FYI]7EeK=,J5>+oO%#0LT_x%ws1wZ3gIBlFkm+dC)g77<tI,Y7.nE^et',1U[Oc,qnD4mENB_HYkRBSO&-t,=t[mP^t'_)WsWF4]sBDkn.?H$u?&JK19sY6R#qov3$7;xbDE;@X(T+4+)BLH7t>T81?s+tkt0Q7hP:?:`=igP^tJA3i_9e4R#,LWX53*n$=2jUtmwjDPnQgJI3,E]L24@A8-N8:s)=8/K=AMm,>gh;6caLA9bpHsGs2KOj)F0`[+9':+MrXouOjL^h9+kdh9BdWRsUhYhL]Gm%N%@;Es^]eikk't/If4c8f9Nd5$np(h):`j&VU71Lfp=aA,dow20GCUk)$lR'jN=*(=sLuXe=DV)::e^>%Wu<_t436N'qK:(f(8`Ysvfi$92lD&Mq0eg)<W_$9=:d$9*Wf$9RuT$96BLJsE-t(TFU:pO11NIIG-%P=V';9Ce1Q98*aM]-3u;XaH?XImA3Xr^voefO?:=?JHGq?b/NIJsm/QI(U<o>cx^bEs<ofDdmGkA)SvAb`C,XkguU.?@9/.>8c0xlBF&Zm/vAV%`mU?2EG`D^%sm``$NuBI81mnGVfbkBBl)lXVQx8x^(8rnnlMmHLSpRI:4`mF;g-?Ds*FGg)NV`f4fb_.f+Dph5eD=i)$x*<%D`L:H@]O]q+L4Fq6LwC)OxYntm9.uOA?@VXuF0n$(e#xJf-,dO4R/uh7TX8WBE4<VfR]4YSBA?U]B2c].>vbeH)x]OV)NtBW'RmD2cEZJ``ThO<g$S%S#XR%HuSLB[tVTHC)p$&&/nt>^+[Ks3bp0KhOQL:G._JuQ/i[I7=pWV8MgGMr;e9MBu]+MGm#B&oIj(*[`kk:GQ=Is/YX'a8ELRJMQ9Buj`HE4$#ejcWvdxcAW-5$:&MILb;oDsXWYERX9)^sG().18ud8.qGFOS:+w8.lDkOSEb5Vf:#$S#rv-Omt<[3o7S34KaRY,*e.1(*bJLu1YV#F`;6/(*)hJZsho:`s=Li%t:1Lk)jFU(*ML01LOjcqtw&FOA9RNs-RiK$McHnctUEfjOr$fvSbsU]KTQue$t&Z9Nd,dpNj;MmO40FE^lV'ic'hXsT:ZX.vY4S<t(Vix-V65>#e/-%vlMk2&2(fPB0cPW-m8g'&=?B*d2O4xg9$xf%q$R2BSG2T;<SB%4OsAEso+cXnYZt$4fWvbeq0g`%YiqPA>mCO5=08gOl;C%4:ik,2abgXS8(:GD-qP:v)Q:,v>aY(00YJCi&BP:v3@x3vumU)4JBq]O1w0kEMHS+-GU:B44vUG#l96Ss+o@UHhOQL:n]>NubrCF=39ae-^rTe-4IMe-rS0^tFSX[P+%[n(U`nPs@<qEssf@i)O=$Un^7=uY%`kfim&Ab.bNE=#[g0,)/oYq7?4q<13tjOSJ<Sx.xeNZspHfSs))eC)5''FRJlJJ/C3iF=ikm--Sthk8JG+I-jQXoLCs#B&.8.`30*/G.&Ke0L^BiI:RPL/))tS>dq,FEO+^d)MJ#UPshp,xN8):d3Q+$fQ_r_k6HbKHs*-IZsGY5FMoe,10'CtM0`^JLLfq9^s=Z%O=S3d1iMXNS#agm2dF1sI]?S348/4knJjCdv=@j]=JYNoVsr<MUkj:bk8Ic]7$F>+Xh#fTG=WOwML?m^Dh;awf;QJ1j(_Oq`=hX6WI./,^tL0>?-e9.:0XPkXr5O(%,83sQjAlk`4Vf/5^u3RDbNftERG6Oq;SZxER-W@HP.dHYsms1=/5T[+i5NY)MmbB%88/3;nT4hH3[`^qsGneLaDaL(*AEcb)'Keb)Hf;L)KBMR>@a__*D#.`*Jlr3+pZ#N'Hi3T%SdLs(8BJOJ9#KHs=i3'*$lBOJ^S&VMROleMa*CY?B8%a$3BPC&WeWO=,QwMhIkCfhN4>0u:XZ7$Aj<0uCor&=*sxn8BoWGs=?t;fCWR50dL6WI0DuYueZf>-Ux8?.5:%]_D),;nMfCs-'6#9O)^d)M>h><kgrZT-gjNB-V<<6..4u<M7xUp$ooCk($mek8IbeC)p#7bMn1w@)::j(*B`RN'B5GPsiiu3S#JZ9I]?P[sdGM`si+qc)?(+cknV9`t'dR$5@KL[ss6gu$&oiXs(DH`tRRse)tS%gmb.2Bk@[A]t1K&ktp1mZGQ/i'IgA9')IqcYkhJ&Pk%0EXPSW[_O9Z0=>[<?aOE7+N=IvO(A5_Dd%6:6)WQva`e6gl]O#P4xg,(_bt[0qemeY4_W[dmS%O/;j.Ql'd4_[9/)[+FOk.5^Gi-/<?aZW&c,5W6)O:4?N'kD0979e$p(7$$Ssf1aC)?^?,tOww<&Noug)3vsEaI2PkK[cUW-hbCc5lwor/PnGTKJ:DJs$?151^r4f(4oA.)HB0-).97A-tH7A->nko2PfNuDFxuIslx8n)v/qO/$lt35arX(U2M]c4M;fn@.W]C)A'^'ak=>COsKIu#Jp^h7flcPK0c1d-'o$GIabH=#$cg&G@G`Zs,SiBJwD04/,4Z_O2J61*:G?VHi]I%+3QoBL4w*pJ@A'_-4uF]9JCQhnbM2[%6D0Omhk_C);]YU-t`o$P]FY,*S.?ft)H`C&@n8:O+$gma($JGawsj^-12p[nkm,g`H@l1k:6`7$/)sn7sooDs^]Yg)c;MUm[tQ[PiS:btw&FOAH3Kp.;$u3$$/D3D6ELZ's89>#cRZo$kBLv%3S_V$Mq8>#t;i%vD?Q12raK9nr4WP&gDTvGHs,9Mo-LeOpOZ(d1F31'Xv)u#3n%c[(bua%G8uS@dJ:d@ep?bO_gokt/#U:vb^H#vRol`Ye>+XrCOViKwqS:vV$0W%<PuD2c$5YY1&+tAg7lk%P#mt>V<`LSY^A&M;vU.tOww<&un1._Kl?ZP8/wYsPd#@0t6&@0rS0^tcDJWR*`Zn(71OQs<4hC)?J9E8=*[nT+@rwPo'dTQ)8)oIFBgX>@^&$&abH=#u-@WI@G`ZsPl;R3ld(*#em/qH=5fhtT0IA-K:IA-O.IA-xMbr$s.nt>MAfk8k3GI2Clh-/Ug$k1]F]c,GZkV.r-<dtnBxY-Z4Ge-5w1-)kxBbtZKq8/>jjOs<d@3MDFPGMAV=Z-?jT+.SI]9VZ3E=#`ZKRscP>IsYV7'&7)9Yaj>nW%N%;'f4J1md00;EIbNP[sB;2DsK<(FsQ>W]s;v0.vjc.3pf0b.Bo)?PJEpQ:vI<Y9vt&4cH2gHS@X2=>##/YOEs4g1Tq'R:v>-B^$KV`$sWhDA+I^T:v9$P'vM#BL=L+96$HTd`*N@4NBq55>#9i45vX;nEbP^[PB=-T1p93iu60OF1v:@A[4#8wCW^HV:v.bF:ZB2UcD5-:>#[O9rL9#%Ph)s#PfGo#F7rHr7vs['[?G><e)a-ST%pI,5H%AIEA%.&Y,R5Fx+k.We/jGFcsO9?@+],)D5jI4]-+Xjwjc$x7-'&NT%,(Z(UX'5WkG;fn@EJgC)h^3_j]jlnJ0,cCL%YVp)F+?bWA.1@'iHd&4(vUG#i[lVs/2c7$J=_[F-A?H;gr>5)`dG[$3j#po8AkxL52N*MEm#B&wH7c;EK%j:]aN2U3IYvLuHF8tvN>B&vqZXl[%gl^*+?/`^SZ3Xg;hC)q^q&NUGCA;=3'#1abH=#bT`WR@G`Zs?*`7$W&oVo/wU:uZqEX%min[sh5nvjrSnCs,[qv#Krgb;w%pDs*D`h)4dp=8=SOit2/v<-6+_j%*<als(nTEIsNP[sh)e$PRG^x)TC(11f/=8RI4Ljt#;xD&gjd;^h.Y,)B$3-)xhHD-9LOZs4E8VkaI9Wfw<qEsJkPo)4b7[Y(_d7.nT1-)5Cc$'piZY1CFhk847(@-v4(@-bUX;.(XM7RPa%j:@_hAGsrM9MY5>5tD@q8MSvO1u-#`w-6SRfL2/xNsH*I=#NR.+*g`^g*cPs?Y.2q-MSB<LFmEMxL8Q;*%6TRB#L9dk8kiG]M(5Xotd&r+?g%&?5]X(K#n50FVQ4<[X2OEfO7&8kW=mML%$aldSc_]Ds+TIe32tkbtGieOA[s8[uXgs6[RcaC[_Bo0,GANZs4;pEs:?pk&kfolB(igg>0FGeU.Q'S%$bqA#e^S/.43h=Os,c$Oa/_q;$:n3qoN@F2r[0Ds=Q1%*nmKO/moJ[Ifj^D&Wf_&)s17Ps*8^C)KmP4&EXg`tC#]s9:62(AHDW'A(Xm6[+O]9t?N=E&3%D+`;.9;[G3*ZH^3FqLsDNeL_,#=1VdvU67Kr`tFUKXGkV;T%Q4V*iqCXR.AiT_ODHnqfiZu]t_Yt?.(a?KuRZWCfc3NhTwvvX>ebfk4(4pWKcY5iOh%tdY@i'ic2CcgQMSxMbM.`hGu27iGWJInOC,&)tKaS9&GG:1TvQ(nU%ooT%K:cEheqqDL:kOp)&Y[RsU9/.(Jd7c)ev#P=,mDa%jU2&X1GL6bmOM1Y$Z`4&Sp9bt8^]7.0XMALjSb-Vb(1,)P0P:v.eua$%6I-ESb3hP?cwL>,HtX%Y>(RX8dGF2'-HA5N13-?XLOw9uMKQ2`?+,%vbck8^%wGtP<#B&q'4'*OtnQ%M#mt><Ubeg3`NGs>F<rL2aYAu`s6.O1*7F#L43]stefX#8ELRJ:amFM_r+k:R,6(MTSln/dUQK*oU8stFHq=OHdHYs^es>.ThC=#^N_)t33h>&QeHxF1>ireM@:/`$xOh,%hEpsUA+v-i&f;O/.xVsEq/$0J.enSwJfXuBb<#.OJT-Oj(ZqZRc$0)mfTBu2AMsA'';DbG&t&l7Rx<YU0Z7$_ql$90du_aglOp@q4(<-PTQ]IJb`QlG`rnZ'oues]@;p),G;_X.e*VHQU0-)@CtN&Kl,>&DcR(-o83'f84vq6xblcp8a3H2C?v9Zu?DU[E`[Z^[*((asHViF4`Fc%dfx,llr_:Y+POZ,#Fse)Xx)w$h*j:TKbW^%15Q>opj<#-qd0&UDOw,)v4FecFOg'a6O9(fhxf[pE#Z%0kuGf$k#j#5l=H$lw?Pn[j=hk/0p::I%_hutV`1%*Fl,=&Vf_&)3o*Qs@(hC)]OGQ8;J?/V%J^<J:IC[%+_Ok=d.p6[(_U5^/-KRS'Q:pAg>Ll=u9Ok=k@p6[B.d%.ux=)M#h5f(-iem='1I=#^KKLflG*Ds)^hs)9<E1BVBkJ:e;greX'70`%$I=#%<2DsQRg@Mv$n^tjmpw%>=<1TLPuVB?K,U;a8+7$woAe_;7Eo<)oSWKbS,iO_GLi)n_c;67#;7.GZ'e%o=iZsDQeBh>E7CEpA)9u[NB*<rDmD-`Y(1&:.&epglvD+w`h?Kb[6i95^hYs/>Jh5OOI+%gJ./QhhTvGHm^WLd':eO:S/6AII1Gs(qLDsP?Htt<'s;7?PtR.ee-`2QQbrReoE(Sj*(HHhG8ZKYemZ8:>QqVe]M2i_,LXsg,w*&0&Aq)m=$Un`J^p74#JP^g;Ce=J'ZqZ0l,pSTHa2MWxWhBg2uU])<#Ab;`%=YLDM`srd@i)q?`rt)HcUA.J'Oh3dT-`8Lx<Y_(i6f#+phBI*datH/r%*v&S>&t@aE&I(i&Oq/l+fdLD8oCEr<MZdp*`'8pDs&lH+Q=RK/f^kB#QqVmSM+>JnnhU6sI`/7h??B0T.^tmCs&g`&.W$D5M$QN'Q21)^s<60H5&Xg4f2PmYsLp`x)?Z:/uXmkE&i(&F&o-8Y_--OTse8.R)W@9IC&WZiLM=n29)>pDsQIs$QrJNZs(w7B.&4%Cqw.vcW59A_/DZf@F^P8s.dpl20<->F#L*xXsi[;b@?6b8.SKkb3*IVgLXLWwG^BiI:X<INk/vB7%R>MRJbOZh0Tp_X?U(39.ffPQI;4KT%KK*u)>QU(*+Vg]tm5)7u(,o<ld:6=lak8RbnkD<5c'9u$vG=&>g&Hw$t`lcp-.Qw$F/h'amN;uSU,,qcGI=DEVe67d4wQ_</4knJfESl)/bCX%GF3W@Vb6Rd'='W7m]j--+LSl)'$#H4q`QnJj)+c;m7]qJ0p::IZGDrts;:EO(@f>-Zw^8/74GI2oSKdM10BnL8bYW/Pim3KgpeF;[3cGsU4Zw)N&0$.gucAO*@f>-U@f>-U(B?.V=InnLtxlB9XJ_8kuFgdO'%K#O-EWk:U7i0*WGF2CK[(tPOwI:,Q<c7X(av-P#`*M$ZaU6+oI=#hSlQd$HYHjs>+RE%nckT.5P>uEvkHr9B+%+&*Fd%1``(uBOD&.$HJt9X-IpgW_>+DMoAe?iwH=#1O?5.W$D5MF,PGOYlEig$AVvs[GL<huC<eLu+&2t+8E$l'mA[k#JRbV[gLC4X=>.umVl:&bJ-ctBoVbD7divo>N2^s?4eC)Aw4usFUBs0p8gFM]w0-):(BFM:F=2CI;1gC?^<Nhp,aEs88)otIHTc.kf@i)&4t+.g3mjL^fQ^t5YG,MZkFrL33T3Mfib%tPhXv-gH]vLX9E?YTdkt>c@XO59O'#brOPk],YOE&sAqbVjBw?ueCp,)-[A['A2RN'8W4kL=;%a$qLO4$C5(=1`A]1tHE-?&CTn<Mqo'B#^gZfhOFZ$u=s27IT)25*Oq.rHqK@4SaTR=GeUt*DRIG,D$Y3NhUNV3g9]D%4h1?^>ANPUIjkMd3$#J@5m[_,MYlL%MueH1MXtXHtL<6T/JJk'*#n)b3'wJ^ciJ9SI;nXRZwrF;IfqA2C$_Sb7;-OTsb1^;tRm8kgKeU@)r^Q79l-Q&G<%WJMJ-J=hjUit>W8E$ls'aaaFvDkfv'6I-Zrhb`&iEb.x*jt>@T*B-a>]>-#Y=v-9tM+N`4c$O^A(FVN(kHsG)(v#Bq#LgCN/^t_TBHM+=cVLZ1SvLE$`KI[2w$j4]<GsHS=v-%ak8NYseh%,A==t_<41u2mQEZM-BnOfG*u,aQastSvZRsqmhNr#+tL0cW8_jb7obMW;qj%mxih'@aj0T4Cn.O0<``ODJB:$^8Xl6O0h*VoBskt;-RG;ZYmE_wGdc$^,fPie;vXU69nc%GFD,M<%V=LhK9Esd:e8.HvUG#P?`=.qSEXkb=EHtP<#B&MCbLBx1;E<23&F.j%5Wka4IZRw<qEsEF<rLSGJtd,+3e)Lb7[Yn-Itdcs(R<=0[,M)BEdaFR8qVE/?l)Di%+i*f?R<<%tcs(tKEI:]H^c#[rBk6&3FMViq/)%<[I(qW/v?*>8,EjP5KVSQb?Iia@nLWa?Ysa'@tUv8).L,`1^t%TDfO>i.jLSMtOsnPFtU6O_qZVo$0)*P,3uoR6L-Lwc4%h3JXGs%eUY]TnNk%io<te/a8&kkG:-E+%=1>6L$K`GV$KuvxatH8f_*vNg`jc8E$lMK+Dk-a*+DZFjqIp?#8E7e(n<g0da[:ZIc%M`KKe5#QU?FoMO:aAT_,l8pmB<:u,)@K`S>-^Z+;h)wns@S;no&%/O[1R<rO_^Z%C&,*>CJV7#ul>aEGN(_P'6`e:f2X>&8]kDGsvUa3F5uf6e[roM%J%IO<_x$MG;(w:MUqj=M@YBPP9Rl8b4L)GsP<W<>-6^`=x1x2=]PfrLV<cpo&^PHSFXG)j7.-&-+mdvsdkH/fb$=FqFfKZkNndFs<R1%*naX7.M+JPDr>1h$Fw:T#Nj)TsI8`7$BnI4&iad8/GwN.+rB9C-n]5@.XYO]qVYvP//-KRS?%T;6E-/dMjEJ>Mv8,Ts1+p<:/IOnnqp^GN=/px9aplt>$eP[sF_w/N39pQkfcGb`@KPUIe,>at+K;F%m4Fftpc?L-Zk?x-CwGYM<es2M$3@/tr,7x-Ihg-Okcj9do?@gL=%(SkF>s**AmJe4i<P.<($vft[d'btm1'MsU3SHsGfersApsh^Y@Zi3L-X_3'tp[sAwt(--Y2bLV?]YsBRrn.9NIq$gtT[s4:<@5ddQn[T_0-)0:)oI0CVq'N@Rxu@pDobtmi=cjLR:vh_A(vY?j.[2]w(:=*O(j<A7>#c%g'vv1$&Z5htlT=fSxXT(Gc%PB#V/(hC/)OO_ak4q/_,i?v:TIx9>#_`%1vWqclpb3;-*&SgY%LPt[%G[;>#`[v9vIIs7CE;bg3jW,]k_G8>#/?@sOWnh#W;7X?nueGr-Li<.)tfSN'6[v8@D_Y-jFVrSkwfSAtP<#B&ob&f)OG$HDF-kNhVWrNg?]thJ.[gh(SaUB$`@C]VP*v$/%:b=EvWsDlW'i$Fj@R'lD[@Xs/:2DswR(4TqIU5gQpK<&'/bta3I;&.s-+CM;9s0C5CEOJtH[&>b+;OBVl@=Tt_t_$,2x<Ys@MI)Z*0.LC,3-)/`apu>^C)0MlXn(0:)otiRD&.%32v8x5r%cnf88SroccW9)>DbHx)4jR<oVs'*]VkG*-Hbl1V9oANPUI1J(ZuNK7<&8HvNs+af#M@Y<Uk.`r&H5a&Hs6[1P/CI;4uPp21F(4ST]E[>qe#lw<YUg-F.n.8'Qsn]st+Qu5PESZn(rs4Ns6k2(M+Hov9]5I2hWn/iKj#@at;GR_E?m^DhPcRGs'?Q(MlaLmthkA-1]^q-)_C,29Kgtuu<F6t0U44,MxlXfC9%=>#tt8cO>3H_[a`EUH$X5hORj.xgrv^vOmkB0JM^GvYN7;cY%:BcOg5oktWFqkt8wjUHkl,pO)'^4=n'x`O'1JDYJb&EENj4^%5Velh=e->kS]#&4E<Q:vIA[(vhe@r`.QOb`,BP:v49C'vBv13[Y84$5vXE@Xf/#%fYaW&)42sn.YRhC)3otitE4vR-m]iI0Kh<q$+^=>#^1b$'nU'VaPmfLrgqef1OY?0lS%&Y85qx$4bmChOtY7Xa9QjRa#JkVUn.Mhd;TVd@fP8]0wO?hOtXdF;hTOrOX-T.?pKUeOQ?GiWV$UvGPb7+1+5J'v%P]=<%?2]HQEB6pEA7>#0M+&v)jE&%gpq[Z`X(JU*]ZiIktgwO9iV*-ER/3F29$w$;U`e:cu568q5I2hJvl+)?;:<-n1t88gRg5UL4UNI([IFEd6ijt@?<LKrZ9T.w&1Ds@f5Y1W;#L:l<<>#I]etOJ%*`s68M=hC'7lOe3RjOV$Y:vo8#S/@K[7nRaNt7Yw5,EHPQ8A6.tm$/;V*I<8//IYr$sAdjOu[#65>#=St6vCM1:8UQ:@cE1Pg1-2I%v+AkxB,_1ZYM$L,dFrq-HQLGc%Zg:,]68HVs)4Hu,kR%ctIQvgjuM;gLYF%&ci%8>#,ME%v2dYAGqcqv[oCE%tc@3vup@@B-aW-fnT_Ut3`>cls^IRXsF&14/^BiI:=;pHs>LYd$)`Kx+wUYR8'QJ^4HvUG#;igwa%+&9t_YOE&i_/fLh$TN'Y*YGs;r&:Q#wUT%QlVkJ39,`3>wTbt*s=[bt0trt1(.Ss4N<N'1v.$gm1;XsTMLo%H-eIZ3oo/QdM;^s@Z1c2JVhLlmA2Z>KgR(*w#Ii?xqVi4W8,qc^gGfhd%)Yst*:Rk<[7)t?UGB&guOr)$QZp%U]Lj(V;^5MdI-LkI/fCsup-#M/B@bW1'wctXQj@&49fNF3xc<-aIHL%0gG&MK7oVslIa7$aV$-tjA5Au`DQ`-b2,O=mxOn[P@MI)%lH4&xs1-)Yu&2uaH@U&ARj;-;d>@.5C``^W%v;n/-KRS'YR=c?oISf.ikDFvr29Mu&#ps2d%jL<5hxtZ*q$.g]/%M-Dj[a.VZ(MT#WkB_l45p=oMl=G_6qV3p^$0f*Z9raNkO&^$7gLSaV/u9o&(3Xe$p(A'xXs(?fk8I&VU.U9a<AUAEcuauV6Msu8Vk'tmt.S-mh(U&b?@O2,1:0_bAY;50rQeL830x'Pgd;<(<tA<cKc4YvIi;``KcqE`]tjOl_fq.i^WJf8*%?Y;1mMI&as'@R.:-%uY/M>e@+u4cs,D<K(u:k>x4M=^Espw3nO$#]NPI:8JGc/j^Jwt&GcxqkT@Yv,^Fbc#&mo;kC)u]/_IF,n,)k(07Iu-Bu$:N6F&.Fi?CqDK`QH>2wGrRTOh_qpCscww1$qQ=%4ffK#uL;949Af%I%s8DAPRovG*vk9L,sK.h)n9a%]H/dl0Me.HsIp,Ikg&/O]uq.0)e86uYZa+laGT=Z-.I(F7F0DUMHFFB0q06+7:nI=#E4;Gsh8`UPcoVb34lfeC%s#0)K$r?uMqNBH)D4+bk?qCsAj4'$^`*o7c]K#uMw/n)M4O:%(FgS83`NGs#F<rLocGF`VM+#HeH1N0KoF>#LPF=#fDK%Mb`h>&)99,Ot'8>--@4;.to`x)*kuP97F_L5L*ae:/c(2Msb?:tZSFE&(3T=>2F8L,#P#1,j=^qZEexlB'5(L5r@OiO^v%Zh]u*U#gaZ7$=Vg't+h=t7YY]CEkKfJso.0mtQ=7N'Ifp*M]si>hVcu=l7:DGsO/:F&rO^v)9-kT@,G@vsQWDRIt&h)3'$[l)@-g0PcW.QJ<&uSNx+onO17#%`rK#+DL'cst>7APsB;f4/H^DjB*9ab,0eG9MBbs9H)OMS]ELGJiVv>Z%6qNL0Csx,jNheb]?Y0oOiTp8NB.Tl$1eo_R:>DT.%X'S%cuWN;ws->MiHdc,2oap.tjdh9A%D').=:=G6EfC)?p2@tD;LF&CvZF&i=fF&ZCDrHoOE['=Y724:_fKsRse^$Z:XThX5PUHT'-.MlVaNO+#v+v9hIds>w)VlU8%Vmo>W:v9wE#vr&:ej(+]*)QRqHi=*&4n[(1,)R1R:v0d]wuX<)LFj9/je'8%>%Y$,T%]am#mWvA$-UYs%=6=R:v['ruuj#feo/sK95QWii0LM<>#PlM1vS#`NXgQi-*k9hc)0#4I$rF*lG+:p02,cGn]iWqHiY*iI:M,VN'jx)<t'*a+i0M,AkU2i%tgeMx)NV<*EbG7N0O86FMKOmB)R9HQOJ>d[Hp?p6<uIqC*XJ`]AD4Gc%[Yerj8Xw75%/Yp.Bn=t,$;WCU_[w,)b3VN'%8K=hVq)n?KBJds>1&4Jm_,At]CoZ&bsq7u9cZT%%SYxO]gFZs;^Tq2V>C')DS?R3r'u<Y&(-l8drqp.21Or?bsP44W92'f[d8(f.h-W=AZ`e:QV@6%JA>lLn[Gh2t5$$t,uJA&MBPqtER*Fs[?gY$Zm++B]/G31+^ea$vmp6u6aXj)2[t-;T1^?&C7$r=e24_jE:L6hmBT8M3sPWkViMLK:Zp8.AxS@5n>s9/+>%Zsrjpe1+oI=#DXmp/c4MM0v9$bsp;gK'+bV19hQ_hL;Xa2M=J.tfc^t63;%Os(rX>C<q?>#-@.nd3sN:7AM`Zwbu1*30m3K[s?XFbW<HVnNx`a.Coob*.t3IxIj,%uLiPbJMZIj$#5r[e?dO3k=ovV,<%m8kL90[]-#,NL5(=NdKriuj(P86FM4RBHM3ov##NNCL5?_YL5b6*]tB`Fr)MjI[>M31-)W8B3EsW*jh^npCs`FAm/J.enSd+a`u69oj)=[`e:u*fW-$.<X1PrL_tfF+k)U71gL(IlC&A*'0)($]=>YXAr%ZJJAG3cuGMxdi<d,Q4Z-h(aF5*Z]#M4LNUk&aOn%^-PGs(6eK<L)JP^UX:/`Yp,B[oKp?.sO+S7P7w/:Y/:kFB7MdMZ?>]ue6t_&9n+Q`waG[..F&4uCvCQ(30)^s41`&)*GPVsGKMn[BOQo['wr$#][qnRxs1-)99:ftx/fI%lEo;-x>N/%0L(,ja&Sn2T^po.:gAGs8vgC)-G64&F27L51rE-?rdYL5=(re7Z8h8.@-u@&U)2_?j$0$.cu^lM8)hPsPviwKiEOEt.0U8M0^pht)jiH-l6e]-$[f<LPmek82IR*.LJs/Mj-d0LUZ(vW*(CXs@LnE.hINf.GAeGsV)fi)8GnE.N8c_au4_ca<-8XLfbt<YtN[*.HnZ6Ml0d0LN2GCa9Qt&$1uVJs9FqtL;)0@t2YJtLGM3o@-Nt&$0oMJs9@UXLhdjO/mOVj(PHnR@u(?/<9Srn.B?7uebNP[s9D2Ds7RXj)ZJ9@4XpiwYo:768wW_52;)#d$<qjb`rOIt-AUq?@*OAds3TFE&f.Fo72?>=-nX_H%t$`XkrEXSsxf=MAbgp/)BAU=>6I&X-pdUM3h&,'@,i#0)jV/&tm$/'.D'Y)M/i-?&`X_,MU@K,&fD10)>74(sPV`B-DOT#%o_h3t(qn<&]XeX-9`T6(UQ(IVq4)9g@(0W9[E<Gs<FBs$)on790MGHNQacILQU0-)R`ZM&ijYx7YYMS]uSR,2^#s5_Jb_b;ANPUI)#wqdN%=h1Ye$p(F1w[s=ghC)x:]d:CJ7a+;2fGGX/'$&]]C>be`622`';FKcMEga3BeCs%9E>PB3'0)3r7dtRtU1*2bA<-c^<B-nLaj2hF2UauM<<8hk_C)_FSwb34U$9bi:$u-AtEaE@0-)^t3=&Hl&:38h@I>@BtR/4s6(s2WQI;TTV4W<S(%Mnq/+28S)`3pkBaslhf3/BR*7IN<v[]ktD&&TLWt12C5[sR40Jsi8r63XX7:H.me5^4oA.)vl?=('r.<-qWaY$HW-O4MDdC)WTtOM]vkwtY0C.).Z4asV<YwP5@s;-3A9n$IKPC&h7[C&Wrp,M&*eTkMD$<]Uk=Gs9Z8Z0p.h:$(AhtQ*`6OCrR0$-d<E4E@>B%SS0.9Ss;Fltkf6P`5UuD3G31484I#=P,YOE&RQB78A=wO&icdseHr3T#9'Ysa#0J>-HLF;.N.w$4hw(gL8Y$4IXvJ')c;gbBH)/Ss)f0s.guRRe2M.+Pq#.61_-'4fZ5pU>xM;Rssj'W.M+xx)$Oit%OSJ,#]U2E%L_Is-Vaax@GWP^?aX)*%CZ^5/Xb]auOJjV9wW?T.Wxdjc-.nBbZZ@M@OQ4ecR3xq%?1:Nt37pA&,nA17>[knJNk0G&kti;-j&c418DY-`Yct.AMExdc+'Rx-&hW?M/D14L(sOwLR?Q$cHrrx&mKAvJxG.PfDM9mtIQd;B8Jc#[ZbL19aH%+;9E$=YuZ>/tvN>B&=Lit-C/X0NT-ZqZhXot(iL9T#im-#MLCJnnfLSX(]FH=#:XrGs1Urt-1.`PMtWuqamUAfq6#Q4$v4kR1/;Ko1#g:Ys0bMlfd(q?b8rIYMK6&#M2AOl]l)Cs-;p-#MqDV97l]lt>UZik8MO=3)uO>F<jgYcaOACs-0`2'MSeNG#coak8.p][FiV/EN)Z,oLOF@&MSjQ5NMT6F#=RlZgP2kE$/=2O4/aV`tgY]F-^$jqLPEX.f:LMGsJLX7.^I3:IKZ7*n9$*jLeBJnnhTt(M%7_S-W@65.h&vfLh<v<-dGNU-]HD=-+xHp%P%X)tl$l(WRPvtLSLouMBYLhn%;DHa.Idi^RrOgLE:qo-E>?embKcAQ&[7Vs+$`L.gRvlSqX&?Z2Dt(EC8QtL#el)SU`oCs`j<VhGXUk]-ug#5(*TgF3@X2^_d0lOb%kIeE8iF[H^@jT(Uof.^wC=#LFXn-oi+Uio+EUiWogWJYK+&u^u%vL1_=iaPi:l)K(^at<S#>cpxNltH4_8Ms)3Y$L61r?&1kfI&@pt(V#/48u2SD=lFwM0636T#<-m6[j4Kp7ek0H2,LU(U@.P:v9revuWeOEeHqSi[X=ru5ZtH,)aMRV6bTvX>-o_f:Oo/.v76EV7N#T,2Mj8vu>VR<Lh9P:v/ZKCCQCe2LqJ[7nclkv-.$(&N7L#WSO8>9m(OU:vY_E6Wmt:%atqU:vf.=L,3++6M#PQTmoh:F.o&[,Magu$M/f?8%Ur5ZMRd,2vM[HlL&$HJ(.l.T%LQI2LZlOJ(-KF,vJAgW7[C-)*Hll+vQh65Lm#m#uMi8kLu8G(-v*H]tYw4:I<1eaLt.als/weEsO,he1r#bssUuC=?r-$4-xwjEhVY;ji^n1/uU2qe1d^pqd.YVQPKOK>fAs0lXRGkd%<SK2K0Pl[Kc&vK=u9]j-/1?W%Z:V^OhiX<iPMwT#<QL[sqDM`saChk/7heVs$_0btiW%S.&>S+@J.^b%VZt0K^Z:B8X07:v+OuN%O9AcS#`]Ds-<MF-=OHit.DI*33fj9v<L2*/(k4'$*'vT01_>pu%cfwsh^KDhS&-N'4fHZs`a`nI>S0%MPh%ML[rd-(guHbO,JT)NJOu`so%*J(.Z)%+b5[U-/NW.(Tg-o@l;C%4.`MW@dm+c2Y%#d*<NCI;)+LB#rlkxkEKTXH4/Git#HI%+ZLdt6FXZ6jRML=h+VIZsevmFID8nFkh)Q[s<xa_+670%MF&`4)UI3Y,HR(^O:w>.6%GriFD?%jN?]+mf$E`*]AxVeS6u#r$p]P8LQ#m6e[N%P%;3IQso*X_38*ZU-,Um8fYsA`tCw#0%#[$sZP$NXG6#Nu0Rck5hW[Ns(F[8(*FQQ<[QWWL0BV,FsUPwI:^7[s-/w$BR0:qx$epT(*7R9Es44GPslaR5q?#RTk`/tpsTLJ/j24m<emdDjYqbA(]_@3F[+Qc`R(<G^%GgL[sS:VRs<EG/8+J@EAM6@l=I]RjF))#$c$C^p.CxKXGtI]Vhe+D$lsMik8-T=7&dr*o7#w1-)q4>@kZr3-)Ui-[K?ca-IfwH_/aF_Xk7`$Ksi'rH-D7eW%<LmDs8p_q[lK`]Ls+$9IeQuCs_CX2$DLv*`+]1^t;RHd)cN3^-9)@<Bkhhk/kiH>5m(D+t.%QI:U^]=ubd1>51x;OJ)bK[sPZVAffce`*%1N<-_)pK%](1Xk_DE7$))^Ku>*)9u$2RA-e1gw't9:M8No6i:^**$%X'h4.`LL78Qtv5/'v(`3YS_5heCH')IS6VkG%j[Np`R?V0]?1KARs6JAef$X&aX?M:%LE%(4Sfs2/ShtDrN?%L-82FCH[JO=ASPs&$n<cPOo,)OGSpt;w^Vaqa'rrW#TdMOiG:&,72r7c^9T7)?`]st;Eb`BcR-)OF3hswPEH&k45O]kXgaWj1,CW<]E;h9HUEk`i+Un_N[b;_wNp?=DQe%f'S0q4>$Un3?Gh%&QMds%Li%tF/Lk)>jiX-Zr;R*ovr6[66gG)7Q&&t?N=E&#[e7%*2t&-A3B$l<0+wm^g;48X<.:[#pVk[3/k50$`dS:'v-'5NVIVkR8%c)u;r%u8C1B-^*5Ys+@<UI[N%P%7ET.;,<t33m4?h-?GL.;aqNNL?m^DhjmlwsKNbb*Pc$t-[6m<M*=1@-b-US-^D#`/PWTHkwnD1'3SBv$&xM$-SV$:(Y2c;-wE$UTU`Oo$lD.FM)OJ#M*275bBh%NfDt$mm9:Rjm8FO[sgJgG)xgdMLidaU$J+5IZ;gIc%aekj`9rctGRa?(1Mj]7E^hpb%$7x;%1=S_RL(Xj0b./ft=cpMs#)#9-GhVfR36`AkiM$1U<R-ATbWqn%gd_:-mGMJ<od15Kv`4DJeUx.*d2+ON0-u]t&A%Ys.18GjcXkv,*YfVNb_Ra*EVd9.QmI=hD<Gm/vt;Oks8tU$)gd.%m&UfsB47'&oH@<Z2_WtYQC1PI_EP[swDM`slNx#MK&2i8?XcdNbsEOkm(D+tCn/k$MN`UMi%Mp.)S7N'c5T[0fB^CM$BxjLMnI?tUwxF-HKdIP8--N':>=k%u*BX8soZNUw]=_t1Wgn7[Yjk8*B<Gsg/[x-&+WfLHOUWjL?jM-`Nq12Z[E%=9DGR]CURXl_`VN'#%-gLqQ(]$Hj,1_>4rMMIcGKhwbg#5ORR0$kP%i)C[TasZlVHBG*WFh;PPHKhA#d0mBJOJqsWss_5wb*?I.u6E6:i'o`T%umBwt)X,Olt(Tu^t'Z`fOxH^Ms5s]kLc(oft^&_bt8MdI:^BG^t?^7o70c?s$?cEaub86N'U5:#BZIt87&b&s>>KcTk:Rg_*V4:7.%IVGs@h#WdTE1=t1>d(%SXJ%4H'Y1'ukq<ep.``%)R5`GG+0_G)/XDs[^K(*Ldw$$ACOI(ER)(V-v?Ym8`;pI@`Bj(kPoI;UQl,2E:_Yss$RhT7r(qkp+b7$9]^[F<89r:0CkjtRJ.dt_&%iK<,i.jf#:@4dSkjnB59dVaW`ut02IeO_^%QDmD`]dch0#h.9n2b3%eOAi44Op+a'60rc-Y#Z/S_mlh:PgO72Dg,^Jc%Zn5(f`1[YsBC_6fbo-+ksN4bsv]_0pu0w^I,//Ks/B:&bj]5)-'W&f)q+#c_Q#WuA.G'm0t:tigBM'FsaqpmlVi6k@oFUd%%V4&Udc)fZ%b@jaKE8`tvqV)%]o4MV?5%ue?U+hc7^8bstv&I&b0lC*5'4weC$a&)^+PQk6xmbLddM2kJ_st$X]nC*OcaA%8?:hs[>>^tia$S%k5Ac,rV+8h99Yus)9TnJ4E,lJWJPoO@uIh%PTb8I.+hI;u.E^4eXa-IPpGZsa#UEI<`0XkGhvBjh@4-)+F4-)7rVN'A=0'fkR[YswaeEs>hxHk3-'Ca)bo*aPeZGaJ2EuLD0RDI)F^Gs%9(2gEBacar[+Vf_w+Wk+r=5P5a&HstHR&*W3Y0h4,c7%REo>-kFPG-eQ_`.-&<e)[;jY0j`WEEhk(Ooef1EMA%G`s+_@i),ngws?&JZ4d$g=#g*Qa,-3fMg]O7>VdhhPPNo]ZM1T^?Nd@ggiFL57$?6qErW*7'j&l/>%f.51^blf0^oK81u5:8lO1Slh0PL*rO_sxnLl<.%fCc'K#Mgn-UnGd[+c*K_b$af?nt#<'8Cg;Gs5:1@-Glra/]iLMkfl6N'mOa)3pOmE(L&fwBt0dIk2uv1*r))Hs&XW.:W(($%M1=0(B=<[bh7FPs,cF4&*VGDIdZc[s4p3IU6Gp<lgZ)Ir8rK`t2>@Z.GEa:D#wee%NF>sZYt:;`Zcs[=ZM(Ck/GkS[&))']v]fOb@l:^_%WXrO<CKbDbK<$Dk>p/?YCArD;5ja%0P)ctaboWTb%(hOk(_(HE]<^@Q9e44t_=,8$GefIJR?qO]<]GS*wu]t]20u-?,#_sa*b'r-OD+[1nua%c+>dD=ZE*@lpP^tqRQI'qEilO@,V=I4BZ[s9LJ<h1GY[Fuel0h7Ub,)8f)%436_bti=3c4uF/gLOFXr/mqcMVNLgSgn6)K#xU8CEl8?@+.@k$c.In$=T-2(3LB+WkBdL[sNLi%tGBDp)0$Cbtv/,1Ms]>4Mk*$2t3D9Es_'c?-jPxjLTnI?t,f$a.;m,bs[o`'PR>a,)h._7%3N7(fc:[YsWOuCsg.rw=OjCT.MHTv)xWkR@j&>#uFC_?%9g]Usu&NRs5mub/-6*O:l1WN'hnq@-pciE/QL-Vks9^sL[hP7I#qrD%C4RIU>7tGsg5>J&qW7?PkV+DsSj`a-l=kw95GOKLB3%ued$PT#P:N2$GZLq)=kQI1m%fAD#;5%f7:D)L%%tZ3A5:XcqsWss-RXj)WLG_Fm&=x)78aHs./p,)3++Y,Lk57.<0p;0L$WGssDAvt1s&Y,F/ZrJ$oXs6N`WOs&j9t60Knw=?-rtevBjR?w,G0)Dh9^s0=9x=@HNa3=,5Q/#?(S%#c#ga+jva%6?dHFP3gq1s^*j^2<a@a*2&T[[x@%%b^Dd=(OctbnolxcLFR'&o%w0K1Ehrevh_X%Z*VFMaN3/IH,#QdVw,K#XaXhKm16[bXZb$lfuSO/RfqiO8Ii2h#]tgO$=6oC5?@:-N@=Ppqc&4;4#;UkH.`G`YB9lX-xVCfFPH+;c;:>9%h-Y%/P$<-V<Lt3pV8Us#'q?bo.RUI6+gLBafVN'L=[`%Daj7$Y<Pq)M[hYW89f2K._gO1J]jwMslWDsD&wX>l5B>b,Hg@Kh[JX%VZ,;/v;gF2H$MO/;]e6Mcce`*idwa*E/-)OjC=V,R'?%+BrxV%'/JgO^mOZs%;+%+[:Ms(N)[eC,3dIk]'-x+0UKSk)YOf$::9h19[b,)#AIf$Z3NI_Rt_29&DN1)Ai5NsJ=;_X[9X'*QR9EsI%`A8VbTj(hgn-UD8K,aEv0Ck:BkPK^%9>C>;N7@cP-7@3`W*an+N[s,KnH%:ffttAUg_-n)xxf2%Y7'V,us-uYboLxQ(Xs&TkDs(mPo)Hob<mh@8#*,4Y0hA9pK%JBiB#ej)Ts'pb7$0$a'/Cq.^tvLLba=xcv5]_EippU0DsJHR&*>NDI1WiU[G<NiiO@,V=IXTq>GH+#YkklcIs$_/f)TO5Fs_)R/52KI=P0RA(u+gX#%Jv/uhu4RZso%QQI*WqEk>Ei7$B7nt>^l%Ms68v`,3R/.(ZP`st6TNV/kLiJsp)FTsQW04/)pA7%)3XTso&+Zk*gM6/tqI#-@6l+%uF@W8PsJue0&)A?aYX'a$Ph*jI'7'6ZG@&-HN`w$5A>g)[`aM:/pf&4g=U?%;mfUsfSev5:Hxi1-8V[4i)*op8+C<hv4IZsH1(AbTq-/l7=Vcsw$ZJ&C,gj)hU.$pdqC=6=9$tL$;Em/aKP[soDM`s`uq_%A+rDsAECUeQWkatapm?&Hle-I)1e*Lau'IVh<_k)?OZ+;J)HR@VX],))&IBUJNIc%lB()%%O&FHv%r]tDZ(g$-vQ7@xH+N'w=clsEp[h5=*3`s(_S`t+=*`=(1NGs$S'hL5R[/Z+A8nOi4:KJk[oF@^%2[%kba20BjQ[s5,&sf;liI+s+a,)[LLL0c<Z,)5HOatjCHpg2`T3gW%,LM:4k9dN=?_tLjLMkoCVkJ-.u0MU6GIs;Ru3Sig6Yk%&Cb`n*jb`Y9sWs&RN.:vEKnefdI`t[C.N'j[a-I/L]YsW.d+i9T7Ss?0L<.AW>C<)Y;&5n&i`t@?TsL32#l(lU=0gYAKF;w]=_t>aoI(Cxrq-`rx,)GZAJAwPY:M?7@uLN;Y>%a&vlO.RhpOLUJe@P#DO5-/=o.;,0`*wJg^%3;2Zsn'%[s$Pu]ti54Xl]@=kKvZKstrXcqtbCV8ROgI=hN[fD<AKBOrkHX;j`H'.^O*eNZFA+O=WC+EO:#<gLw9BnE=VkCAHX3.=N9Ar-dS>b%k45O]6WCR@&Zwa3<s=B)NPC@*ie,(%cV42@rH4Y%WVFO3[SO2Bfq(v3w()tV?YRBUZ,?QXEg2a3Mj-]JU4'$A)I,0N-1H_`@EJ&aNn48&7HWqQlw`IBW/i^sEe^R8=;QI@3phu9;r3ZpH%'c%lTHN%,fGZ$Kr?QkuX'u#2Ijs-_sUgLWncb#,-XhOZ'.'5CD^P'VBi$F24PseH&?tf:hxHk:BE7.ucS_Od.3X<q*S0q=>$UnO3fb?<Dmo;#MkCAp6`d%H^^S[MKiNb%IxU-Z.'w-d;Mmb7aHV=9pTj((R5_suFods>7$o8QxV[4v+xI([kFt.8=u55OS9gWW%n.8606Z$uZAL*,_ZtP[IGT/.%Unffl(M%Ni@m@5sPUa#Kn7Y;@V/+*xI,5n+N[ssV>mUaf@0%0mSkLi1YFhNU9';S*;F;HJN0nT$k*V`dHU&*pb29qI[LshqaM_+m?w-`c;W<YAm;%vee3b00J<=WI>:$;1jZsLmfRN80Dp@vC^clT_K6b3.kq?G_;ppcV6N'+Ws^%)%`XkPChk/NKoeKJ8.$t81Lk)olf7U/Yj,)UN7P%LvHst6if,)&(ML0Fp],)]9i9vc4Z:;U6?k(Mgn-UY0o37K3DF;^Nv0)csVwtlUdBtjOKN%E1kk4E,L@Me/?l$*Clwf4+D(tF,$v&dtZ`OrJpk&2L$.:mQ=r-1mISsG1XOQ87lTX['2;07K-e2t]Z6BHr3T#efaU$wqE_N%g1Q/LOK1RULQES%SYa*H('60@dRa1_G#b%xktU@W[Sj0_VV*Iek(K#cF'7$]G,7I[Tt&ur<odse,XRs7B'lO^aGtO#<uQsN$>f$UqXGs/WHtu_w5K1+;2Ds)0[t)s12+V;/bTs]>$M';ASPs,)pktsn=qtKpW_1pgkiteg._OuJ3XCcG-Ae+ZEUDENgk).dP:?C-0Ms^,Cl&b(egsD`mOOd[q*u&^'hLb,lvMdeCfsHpL`s]s,%>U]gMsA18Ps]%pktUd,nt+]+@1mTOit3ps1u>=_Rs<%,Ys?0#>W`&rL0noJ8R@pfG;IrVcsc9mZ%KqA$*Uu[1'=bck8Zb;bO#1dI:un>I:jDJO85&<r6k]ruOiCBL9n_gL9n/OB-(Qh`$Q3HTkSb+uOFv_#t-b$Un(Ybk%MbX,)Khh9v0DG3%B?5jtW+E;]3FvFsJ6>%=L*<4qs'krf*DJi,RCKR7cT]Ys<Q7e`]J2OsN91Ek;iNn]fId9m:I-'5,ZE#Pm?+.BhPv,)ca&+TY2=UI07k,)Tc6UDh0mA8D%j1)^tke1/=8*%3.d:Dd&_Y6^xf6-G2c`?*IpII2mQ[sa;2Dsc/Lk)+VTHkCf8vYcc2/=BdtYJ3[Ra*GG+rI>Pl(d.%5d&GjK/f)?`]st]`otV:Eb`*F)$#EKs*`B)3-)>5n,uqPEH&/gNQs#x6N'UQ[gL<'^qHI>JN:pkBas5*YDMr,`+C/Sv-`%JB^`6_D%a]s;W^blOq*Hvt;-r?GZI4/?T1`oF>#E:C=#K+(v#vI__IP_@4&piS_mTY#@&ebH=#?qw-Kkd.E3N?W[5ENFes=[%D&<6IQs'25@5ksmqW6Ep$5dFPlWQJ5@5w&SfGo:'lWX_=`tPiAf)H+BD*i-*'IZ6X.+[P^$&QT0i:8fXMaAA^m(FH9S+qj=GNDjHYs^D*48(cUqo^K-O]>7WXH2J61*'R9@kBN6Os6cYL3P^kf(tGuNsH*I=#^[.+*gA(=ct=7T.CZHstRM6P&6%I<-Rjm.3kQrw=-3=OkEumCs)]=7&YE%08FEZ0)ZI[6uLPEH&9)v;8L>He6ZmiOshdK@N;d14'$GdIH;7k6u@?ld&%R/<-Z3cc-a+xKY]C]IB*w)csEL:`.?Ev;uRvNN&@nUH&xYwp=(8@Mh`(8;[slI,EeL]*72gpqsY?>Q/v)@ICp(r*aY+&9.HR9EskF(2tLs%3fUXrqcrhxUkNndFs0R1%*jH47.c[_q[lJi,2qaZ3g)XPn[tJnn/>bI4&QYh/)n+i*MY.ntNY$U)M&mh[MbQNUk`1/0OT&=1'ctNnL9CBC-oB$t.to/11&,>N)sXJstPMAk=Amdvs/a0c<QEumDj%[YsjgcTkV+?D-.mUH-)36D-e#jNVYsx>:r;FnW>F'aM7[O;lkKAH8eIu%l%]8[+E6E']pR^RQB.c;RN33@=$=,HsZ-^A&>_e&*2N@w>v[nxcG+8JrQktGslo/Ds%0bD8gieAc&psH&kOU1&;b<j([L$X.Zf2bsbg]_6qY5rH+vxxt+VTi@cD*4q%g1:6r[0DsIQ1%*0<MUmde$7]J4_,M?IG,Mc%(&tA'A>-ix7>-w5@A-B,Xf-:i]wBgS94/,aTW-P`0c7Ce(^#:c3GspSxYH?ZcEnJfJd6@`(I4Xe$p(OBdk8MO=3)_M4MtO<#B&2D`OJ2,)da[lI1BZo/=1f+I=1:5(aN(eB(M,4a`?_&LwKqhYOR:5BpS^bZO&shoGs]ihs)GhGV'RAh<.<YS@EV-t8A#I-FsIL^w%j[M5IoHg$cs4niNUMhw->%%_M;%gJj%Y$x-qT:2OOE@qnX62n6A(p$(6h<Q8OH(USxF4WkW]x=Y*38%#>'J1GVPOQsjJb_=BDbIDd[sj3`/(XsQ>KDjE=MI)l>h?Ksq0-)=SHctUg]9&POIu*hEOW-wB]w'BpJ1CwD-XLZ=H=#u30FVtfZ9MjMTv)Wd8RJ/kf=Yc-me;jHWt*CX46/@9I=h*90'MF)Rxk6YY-H+,^7$5To0GhKtAueQdW%HZAC%(N>DIB890`/*.SsDCeC)+4OkMfH6qt7AZw)euo3K7@KN0L0SN'x--i9q_)BM9'&b-^vHwBkxJwBu;4i9CN/^trD'5OXNH9/B0i'I?,i#EqS-NqjG`Uk/EJh^nH)kb7nUOsfv`E-E7aE-c:A'.0Dj@NIDiUs>-9_AE1Di)puKOf7SaCAmlIAi&^'3Uj6)LkMX..1^(r/)mC`2i6Taf`^vr(k.,*fDYO4l9SRx5'<@4+3x&vS&lbH=#-^wkRlG*Ds+)@#MtT[ntg(x1EJ(v8f>>MUkU*U>V<=7pJu9tQWCvJ:QD<V-2ZDY-`<3Qn[Z(i6f;XI4&@Lp`t(Qje)@U?>)qL-i9#i15It/LZs0(UxkkHVGsj-]CkrJ8]t?qJ$0aw>[t/&RN's<ks7W9hB#;hRXs.Mb7$a`Xb.=0wCsZjuoLfR#atLV'x+5mt`b_@$[MVp@d)<FKt:#lmt:FQht:g+>Wk]55)K7cM*M8eOZ-V5Pq;pYPq;[XaJsx'#GM.^.Vs]07RRu`6v6@f)B5f/]bi^g=#d765<I)`k)FbgDbN^CYe-$X1fYf':7A]2]C8rq`&)Ejrotp_r<:MXG4K0p::IN*+/Kl;>-mwX*p<cSNDF@sI/;TJDA.DLc's%q4jL6VCxL?-s0CWC_211[6H>EQ(MsK&%e-a:H_//]kkfV5aeM%qBrepVVV[P=tAPVQMc[1h'W.-=3Dsg%GbA8WZ90Qf%4Ap8_n@9s::6#=a8.Ajd[5XgE>&G8)<-4?Q[sT,220RnhMkWaG@4<pckTlJ^mte=nEj[P[-`T91@-`hZi$WPb?In0K=O.A-i9*_l`t/Y3(N9bRj%ieO8M2]]Ks@Zp0>&Sk[+PS]0>:io3fe)Q)MLO0CMolTLVHL>1N>_XjL<RFjLuVucM//8j6pk4gj+XF(0a/Digw<qEsd/]b/f-ItdcK)uPqi&W&R:<(P(],lMrC8#M,FeFPn4d%.o#1XM?pk*EMA$1KmX2J'<c1tes9?xLc+7Ysxna7$5?Ei)8*X488/i6W7iacsUN[9rf.Pn[h55IM*Wj*.=pT_Ij'*V;A&*KOxnsZseH5Tk'SAn.r<2Ds;XAn.rM<4]p@3%A)#Ra&NAnmgq^H=#(<.RfB#tguP7Ivu;6men_0tP=Mb/_kA'8kp`H2&(NP7bn`Eps-;s:*MJ*.]MsWv*;9Qrb*Ab`p7+ZVdag:b'cEYLbNBP6t.`X@RInv9Bo<MO;0l=H$l1qPn[YCxBAeC)$#FA*$%r=wHL#0*YP6-p2Torx2fDYfF-#8[A-;J]r1?-,:tn5pA&b;+]t1xN$MIkv3BUGus1=MD@&,_M6E)/_mttbXkA_(%'l4$Qn[165IMdaI1MUM0a[@w[BM-b'h$A_-XC=WAth[Bo$0,K`ws.?oQ-f3ZT%&ICFhsRQO&PFs<YfP%UM=`IL$<0A$&hbH=#$_LI^PEI#M/:?msg-=,3dm`CEgwSN'C'@Ksd?gvsR74AOt@-i96c<GsVC3NMJmcG%<->I-mW4IsihJK3`>clsu)$[sQst3J%WCEkda2R[d8u/)v'1i6AAVW-(U)F.%XI=#jZOv-de@nL7$j<d_*[l))&YKL6f'gLZ:9$.5/nYM*_4IDexA[tTSHkOB0Yp.bgDbNfkCF.]D:VsM:B$.BR,FMFA`EsAirotJL&=Q4;Bi)vb3IDD=w*V=P^21<3m$9K>g*.a'e*.MGge-rpw+i]6ucsWF(2t>j;g1^iak8S>qFtwvw<&u:o9JO&1^>B(uwL2EW*i,::L,(&Yh)Pu*glQGNG#QS/L,'nW$M[m#B&d2iLBBkq(k>fhY?-OJh,gwLh,ZLE6pj;nCs1T[+imPE`s'v$u%>i^X6F^q'/u,0(/m]1L*Qa74]k`&u%[17k(:pE=#l<GI2ObOvROHBPu$I-92n*kB-+Wob-h/W$9P*nDsjbW[GM)+E3(->F#KBu<Y3-cUtGN>B&+B*h)%Nqs-2LcDM-Id2tG@FV..P0h)D5x4:PJEH$>U-i9CN/^t5OnbM%b's.TX<3fH*/*%CH+v-eQ/0ML_VCEh8l?tH8mNscTMRs`34(M>1Xb35upe:->ds-`h6;8CBd&4VnVHBv3ojgBjQ[sfcg0_D6ItuEUvb$ul7uFF%d44E%OdO'7SCRNhX#G>A#`K<._pOPZNh#]aprO`jVRs`d7=3vE:7%>kC8[C`O%+Z`]b4_[9/)U+FOk.5^Gi4ci]s[ROgO0]qE8?SSHs/T.%4qjE_NlG*Ds?;YK.d<dh9-kw,MX$X.fptGw$CCbVjP.?`aV.cTs*Z=O1H/DnsiI`C&TZpC&j,[:@+@Y`kXT<I&$ZPOah9JNe)F]Tt0'[G&h9Uo78b0u-T$n$M#g57.'4`C)()u2t)>)K&AOT@M=`&spx'7m%xm&+;,d$p(D-u<YtN=3)[E*Pt$>#B&lW]LT4kiOB<USCQS6+Ws7^e05dL`kIe&_LsnNC*k93ems*ug(*@Zajtdc`[$S6w4_8N5FsBTleUon=.)kT,=&4Og2;$`*)#=Gw#M;r*7/^/Zl/r;Y_OLAkJ-6,2m2f4EH=8Vrn&7-sx)'B4hqo]X0QbGi34(HsNOoRmEROB^C)_4a8t[b/v.c0Hw)>gq?KaOo?K.8F6N_L=g7V&QUoesW_3v^1GeLj0Ftd([G&L@Q10CY5&l,;=vMO.#BeUkWJsk_n&*^s4f(2e>.)40?3t;KX9;Mt?a.D48PJW]LqReovnc:MeEsf=ONsbZ6A)NEi?trLjnJ2aa<#=wIwL'QW7A2u5I6@U]C)c2_'aVS=CO_DDLpVG5HMHA&Z7b=LGa0<<C8cJ0Ohp,aEsH8)ot-f0,)5XxTt)X&$0CNIu,C>wt?vi%W,bmd-6KL`kIc9/$?e&v9kwcjCsV<ZX$CejI1k0,l7p.n.1IY$<Q;,E.)Owk>&'53,s.-/88:'JUfo<nt>U?xHswPTMs&TkDs+2`J8BRMs%_@]=?PDixl^4+s[4bbh5f,_C)F^Uwb%Q*,Q5K<h)VBWg=5&KSsMC2K&C,&PfPG;/r(o@4T7^#WMr__sLwTx<&xq]et0#NtLe/cZM4J<mLtNx<&&K6kZ0S*=G0ABW$1baA)c^E$MJ1sxLQn4ltaIxE.he1%);/Cs-p5jWMpkqsLJl)K&UBI`Z7YGL8Bx[5Bp3^?8=RV8&v(q;-K98I-;NtG%dAt>RR7dj)P#XdtF%Q&'oIu6fjk%Z7%wsEa^'kC&'SdW-_X8?%7;@>8neRD$=;ksui<V#R6;(,f=,l;-YI'd%Y%Bu?v5vAQFo.6Mt^rDh*SIZs&/l`*EX0K1*Qvt?,n,Nse:G:&Y@_vn1pU[40(>se^''(rY<#TkYZjvMF2-esNd0>&4WVp)<KrZ>knDGs`%3U;9j];ewkiSt0'[G&g)Ro71d#3j;bVb;)Z5@.nY-/]RelVR2q2F.M$']=TIEcb_Gs%)f.?*dQ=6A)x36?t?UGB&_BXIU*(j4=PoL_/Lcx[Em7tLDgIg=#AM&7[t41^tjICs)t#-bsa0EkX+)aIL@-S)bfFaMs<%404FN^+A%`rq%nqNUd#w1-)Hcq-.KdNqD.5=uYGEM5^NZBqLi)*qkb)aY$USdC)l:]eC+x3O4RrC$uBeoF-oqoF-s9L%/;Mt+Dle-U;k$`)NYv(UsFgGAkUdb/)S8U*IY=0-)09.vLdN,[lGncG-B;cG-&LL@-Yv=W1+8Cnov(f'sJGTdD_>Y.HsJc-H<.J/H*<pwM+4'Fe(2/?-_<MXZ&&s>-(06dn]@.u*`[s5/;k3bswaefL;o)K&s8/(j3dv(tihg%%Dw4>>b??P.Wp>PJ/tF$'8BR/a[`INsbZ6A)Z;7eq0ag8.Vrte=]PN&#]BEO4Lcx[EtmP,2&'h?u)*%<thTrC&=t+iK@Gs%ugt_d-D^P_JEnP9Mi<kg&J3&+;ixNat-f0,)+(/TtsO_`.2w<]uheK]*Y$5R3jv^FLKJ)]4Y<#TkGNpOBE)NcsrfQj0UY=>&8'8q)5Bhr?m,cs-u/o$Mbj[DegTKI(w-HXZvw*ECK+4(4#J@n;CN=v-&=o8Ma]O%tV@]>-L:]>-A:]>-ssxV%-jDZs@7eC)fa1_td=Jf.Otg/tmTWjMw5.%+C>`m/h/=;-96mQsZ8L<.*U87I]T#QB]Q&.MjhWn%<eP[sgtmCsMCM`sT%S)Ox0C=6[`PD%GFW?dj&6peWI@Ip>E3ZkbaX,%Zjmq6[@['&Emdvs_l&+;^=,U;S/MYsA=9C-g?-5.a@73O?6[9M&cVb;(T,@.M;,2e^JfEnEE#SI%`EW-vd?[@FriBbBu%=Y/d,9Kv9$bs03&#*QkV3pB$Mg)*4'fD.NAcl.&cvMp5eTkdw*M?_T*V$-B(gMxXnn3A=bn3&TR%+Om8HMJjvt0/9UZ@BfpZk'?mt5(+:N:i]G5n09BF-o$jE-Y+(`.peeb*^_MqLJGVio*)@vC)9pwMh6'Fet<md.,o+$*Dhn2.^BLUSU$p]aTfe2.Uu46MeW%iL,1sxLBH#atxZ6?]TlnM.exdjcbPS`kdKlG2dxEC+:d&It*UGB&V$-K<RfARMlvdTk1t$A-,3w=.H<JLTE48xg$u`s-I,FkMrut[=cnQ_<xE6bscm:]$N'i=,C>wt?'$tk)^HLk4$@rhS)*Uk4@A3O4;Dv7tq,$L-fr?]-ek/O4PYDn/w?Wdt4BuVss7@`%/D*Ls<qnJhRdm0UUH-o7bS0^tl>Y$*>(4XZaRa6f^KsqHj4e$'v7e$'cqtXB;bfKsm&Ae6)jGOnDJ`SkcHm0Utec[Fw<o0)CiS]t,Y$G&[?Uk)xk$A-(CWu.:'YKLG$&JHM1nHH)w+IHC*8Q%Po7hX`]7VsKsu-HP5U-HpuN$Bip8l/JZHGsCPaEnS/MYsa1Yc->,6*nX%HZPn=$LGj1wdm:_Oemj1wdm>wtemDj4%)L8248`Yx0G6+[0G4x4-)TR`[bP;bf`3m<DkiN65^r0s8.ieeCh9u?0VdXa-tMTrC&5Ji2MR@+g7aETSfmS(d-bxO*Iv-)kO.r/3M#$eTk29#C8t'9_J1^jCs7q-#Mk;+UeKuIu#M$G>Z0%%e-s5GwKIkDp7Z#kWq=FD=#d4NwK&gVF)lG_kT4Gj'N#2t(k2tAPp%,t(k0nAPpW^'6U;_fKsYT8R.M6Y.qd<bVe3dv-6/f>TQeh@+IoG:eH)suHH3JVeHp)$9I&EH[sOFU`.i92Ds>OJ70bI`RsnWI<&44v*.>j#T%[@H=#r65IMU8=F.fZZft)I0(*=mO[5_8bt?;r]g%jYPOa%QU5BWlk6<lQ2o7*#cvP?9x6<?jkt:[:Rk(46(x+?*jC)gK*5t[tKs.3o1Y#Y0Wq;(-Kq;iCMq;<;K<hGL,OhJt_+iW1^Ess'2.^v62.1=-/WIZL`+5TU=S&v>vM0a=evRKOmB)h=A(MGaVm0dwQkgJ&+@VjSIKY?w;B%@4S8fgSLI(e?>Gsm%v[.P]#=P%JZ@.aI9WfO'4a4Im+R<@YYA>nY^C-&W^C-N4tnL4Om-.mi8aMREZ`MN0g6ebn%S<RP:j(E`daMUjpvLpn)K&dK=i'PuA/i$=Z%MZtm0d6Kj=W=@1t./4knJ)>=(fU5.C/vvfV@Wm6,E_6T$6.E@ws&UrC&V$&$*ve$Q%tRwH`gM,C-[V:@MYh.r%MHH[s(tmCsj<2I0e+:k)Gsi9dGTQqMXRwp.9hRXsWek9MxGPhT2(mlTEH$)tKj^k.kC3-)'-]i*HFCE3ixe^-=;pHs:XXj)Rqh<dPnEu),o&01HvUG#h4bk8]ud,tYkK8/m6W[GTgnv97W<.b)T/SsdXgc.F8LVs`6e222)3`sYMrCsO+(v##ew_<eXlSS_X.f;DZJHsY7eEs%>:Ee[H2R[MN:ZZo8vJ]lFs[KCwCB#17^5$H*g?KM%qDse>b4O6-,qc)<uCsG+9Uk]H1DsL.Jq)q>uIuF;eMMcv'7doeg--Yj%7[#t3;n^r8Z.PEVU6DTC&4[FU^t76S+2pIU^tNWa1'W?OY'(7%i#9k*TsjYJc`H,Yc`oED78dUpN%m*#u(#/Wcs]#d<-p7d<-N+)X-EB>x'?&6uQ4qwL0I]8FDt-wn%w-jnI%`WN'/h=AYj67#mSd3LhNCtY-]84=(vMmw'W>FSN[):sNLR&+2(x)/NmJ=0M-o-mL#la^-#^a_84R=[9OULd2N4eIe^lHs(]sL*:sUvYsF99v)?oXkO,3-IMYxJ4RQ&1dOImd2R?-T.(/HjKsZOXq)qBdbrCg'N'h]'Lelu*+72c6Bdj8pqstlJb.XNZ,)FY'dNa+-Z%<F(J6%S/,.s>tWQR1<2q9&UhL-6%Un9>m*Nb?[tLH4^(o$*WIm8W]#mr8]'of-HeM+@4gMDv^hLRvpb%k0alt>sw,rnZ8=>sV&as[2@nn-o#FsceT^s][Dq.qOY^tTib/MoXP3/V4fP'`KQQsE<#YsF[ih#+El$GdWPq)br=+D=luS.-U#XL;P$>UZppBh6fLB)mrJkfV80u-SP7;qJa)rZ=bPgL4=g<tw@&9&7YW%++vQ<-^(WrVUfJ$tLc*ohd5Mx7)5eI8Abj_hf2jUQVI/9&H.p/1?/[U:HRSI>dk[+fZMv7b(F4c2TwDUHIV)<E[4lTsf6Vh)-*9baewP^tcri=-.9ou-K<;#N$Bt:i2V-ntAEc_/^T+D/w^+jL_(Z[0u>>[0&^Y[0Ztp%uHPs:/#Thw]#QSxLs'FcOJ?,1PK?pkOsB$c%;Z:qtO78g$s8jQs),?.QX#D.QguE?TE(]&FUg=,-:2dc]+3.DsSKOj)ASx+/=2R_Eihe$'x:8rIPo=atw61_$kZ_WqAW1r%u7RhKc2qo6jY^tsv*xi)4l:ps2-If$77R2uu&NotTnP$c)qh<dKRo*Mg5eM5)HgnLL8-ZZ:Zt$4h[[Ys^e+Uno%Nq)cr7kYQsIqE@+3mEq^uHI<T[7tsbDRsw`*UM74[qMLVJO84utKi6,-pe3WEh$wsYhZUoSt*Eh@?56`>a3%02^Ot9;NVU^t?IFNO*tf*8L&E?G['cMC')AGYO&=O.(asUmc%dn<7I#^>NuJ9$f1P'Af1:K75%lwDJRAOw,))(22Z4,ZtOq;^27uR<(RPQZpLW.42_t53:?+kNYs:fuCsZBM`s-1HFE#0D-Gv`rbO$L9+&.i.T%:WA4%jJHo^C#9lo6s9>#uj:a%mB'Tn81<uumu(-%4stF`fh?8%@*j'&(oOtLsa>rdbpZS%QkNe$lT,0H;Ud%FPG82'gYc'&HBQfL4u`9L?O3a4.s?b7`)5MhY:Fg*t^<>#w23$vLI&;Y]/W%?PMLV?f=C4k'U<,Zw1`xL9`s[CO?5kOK%Xkl)C.vR':W:v$*G(v$)[)=$2McY,CP:v&07,;^mUj;ncrQN+_JwuNYNf,ap6#Q]iQq2JW7;MPp4_jwhj'/:^X:vkbM*I8.pE#OqYW.SBP:v[sggL3J;k)f5O7/N70'v1$DvLhfphXtoo=Y5Qki%ID5TP-6Z@^4'=g%=Ib-I3r:KoEI8XYEg-_s+g&FsU5c4&2L-&LO&Gf%n9#9u/rck81I3;U:#v^%##mJs#hcq;no?YJH,Rw;LlHkt:+3qttL)d$#UCrb_AFN'=5GPsp5_Me3R5U#a3&4J,M.FM*#mb<(u+2%%V9]/X3rhtx&s6R3J/Op5)rI1+PadtgGqNiO]rS%f_<Gk^,lh'TQNt$1&WDsIqOJp]toI(UJ)Cj)'t$4aIO7$_-Vv)2HZ>GQoqsC;.,sK:j>SoF[D>WO8*bUZEs+SGO$MQecYf%ZsJe8vMkZ0);P`OSrKu#D3in>PWLxBoZ_P>XkvpO2p6YV)Hi0g3lB(HD?VX%xbobeM&prV'o^`S+;onO,0rLG<.nk&n7@Q#CQbWsM0]b;)wQ_<,j&Fs60.pt($xttU:(7@,0A_tGx/=Gv2]4/-LwZs<@r[FCvZRs:nAi5(fZIs=utgLIQ0ogc;RU#Q+uh0)/;vs.3oktCHY.(wA7[%?$tJsLJ4^=99H%d^_uem^S^)j*C/.(XOost_b0hL)'Ka#cWe2;e))gOf]glOb2b=5_Nqn%*[TvO9lXDs^TWDs0DNdtgm]]tMJ;a,eMqTL71D`^Cu`Q#/;N`s$N_v#Xd-T%s`$P&mlgUH0=#x+BV%4AZGn_o)lni%1mFv5HEp:1PNl@9Zo`i%i-a$bV1Ig$j_<e?=7WbtpAYE$-+*hAm,r]t^.tLs`*26l1H?wO#aFTsG;p+VQ2+Fsn4TB^.^gMsBkGeOr-pF;4.L_&].jpt7X$Z$JGDW-3d1Ds0Ue&*$7UIU6;cEBk6BOAs96Xf*Qdb;qTgOA;Xl'/b?YcsEYwq05?J@Xx=)$AoI$`<G`n`Obt5D-#rcW-_iA:;+e<w)*1h*V*^`;^ch-mL]sqdOg^L`tgvim&J;&N'xeHZs]WJR@OlIrkJ-`8$JeOq)mpfpY[,6vjHQ_Rsb,l8O0*u(K<&ntt7@sbOIm*fFn#V^$PxB]WpObX#fiwaO2EENON<63=S@(W;,n9o.Qj(`3GqkH9Bw)Gs4i(h)`KsJF?dav5d7pZs^:RXs=X/rO1r$=Efl3j=O8AN'47n;t@KrCs$>_k)>i>(EZFDr;%.6lO1%tO8Xh.77P1kn7/d(N'V_JGhjmlws#Z:AbuK&Ck'WF7%ZP.=t'dB/%<0^1'3%:1h1'G:tN'J7Reio9ZHME:ZnEvC8qe5lOWn6bOB>]*iC5]*i,oHf$HIGhgKxO:$I3W$uApXtc6&Ct'SUXFM[B@F;@)BF;OE3u#S@i&C^GBd]ck8<^DIcWBexIH`b'(LgfL.C6f$5-_@L]kl[=;0trQ;mt+mgb$1+aWsVrf1jgFn*C[];qkSGLD)Xid_sb:RO&B1ne(^cpPqNQA`trq(3<lAs,)iumh@bmEc%@K_>.CY(Spi%?%^uMmi%0B4J8Y`Cc%D:cPss?qF_Pk=TB*+lc<SVTZ;A`K,f_t?(M4g+nE^eK@OZ$%u^jV#A_aG>sO&qDVE`G`pCTIFc%ZwHkt2DG_sMMvxif&2Ds:):k)wgpujNif$O88%4A6ixoO70s_^#=V:V-kUb%_'cDE&U(pEloe:;j`vaO%s%x++0sktC),nDQY']K9lLxKFXEVM#UQc%.4m`W-&2F[lC_>mei/Esd.XV$Nl21'>AlXQ')N,sqqX/SC_q-$eOpCs`%Jq)B4n`W$ILiZ3<O4Xc-.jXo2#a[o/N7a?+<g%W;7sH%6XnDl0#SEApj3G7KRQF6*S+@Z#L_%);e`W0<NiO>5EnV7HL=TYcgY%M*%_s%6/(*H`fX#OH&4^o[^h9aQast@_=Xsws:i>8m*uPugmJs-FIgtY0x3MovobOcuO^$IsXXsg0)uL/*$N'ga_*7pIavsBbC(EKXBi54BL4AFaAc)a]mb)Y6rxtB,C(E#m5(%;cn+s+#aaOhi:_tmu:_tb1ip.n)AgOlH'L5e+ghLE+.2h6V:7%H;b-_*PP'tMt'dOQu'rQ,:%(3[O%(3c9T/]?3S>-%=vl0&Hx-iCQ<LsT[uot/cJ`tHlto9X,IH`mo#L]fdG$ju:_U$:+8k7,aZS[BtT;N;g#lhX7,U$TJx$F0iw-%YBCdHbT5;%P.,TV5]w-%HW'tV^H5;%Sr>-IO08j)l&S0qO8+4%+$m'&9K#KN#'SUNv_SbM4ijcsd[BHMY?VhL:@xQMID%MN.GF09vYZfr+u19.wc^4&s3kMq$,^oiXiq@-#&sY2BI?EjDgl0^It]-qxxa%t@CPf%/$qktl)GQso>umsH8WGVxOAnO5iD=,<6TWU],Qu#+^w0%dgp8NaD^;d`q-m$vo@/Q`?Q,`8=_@K/>uWL84Dbc:H8vL<](]K>EwA%=3PHQ:xJd;8kt_$.i?6N;0s8@_2=%TuR'dR_A*><^wcERf4'`S%':N'n@Kk]lvc-h]2q_*20EbsUlbeht*d29qEl`OY55-&c,$N'cRqt5@xC')`#F=5_?RVsB';u5ohst5EKc$G8Y=>%RG;)M(wSSs:[bQ#M@A2)>[9tO-,0L^6k/[or[9`s-HC_tro%ptQ4I#Mnx`-IS:gp]GG/+*()0L^(b&g1xkRKs@Ut2$Y6@w)GRo*MeQkw=a:F_No9(%4XmbZ-SnHO=@?,O=iOP$tYg=?-wxRu/F.__ONI:1^=eUd-%hKn<EmAasK;8+MP@ta%7,E6J'ITI:#^u9Qw]=_tf(L^s-:KvbRVpMscdpMsK^#]4s4,FsY(YQscXqjt9IgsL1^)<[)W2F`GDcke_jh5$MoW'sulS@g[do8_[vmdO0]@PC0+9?AhVe-5g6Vv>-9Js^pdM<gv/:^O=OtD_s]JagFSKc%`dH7/@Fk,>)jdx@?;?aOR0.cbs]T+lGvfXqc]qpb$4]__4l>n%5u[GlN8U.bjk@aO__P[L>]gtNFZ&L[Isl29wKvq`q':e`=`5UOGj]-]G[9[V<4)@DJb:]P*X]ts_Hu)Sp&YZL4mFWLgcpoJH['k,b$N$#+)*4T.C2BT4>t#KpV#o*LvK0*8qU[,uUG=P_/.A-)t-A-DQ&;/o,M.).uB`N.`i=-pvaC42Ag58@P[i1U^7asJ+v$,@tDL&t&/lL*m(1N0#J&KtiA$KB1Xcs>UFv-mlOvL0x-tLX_CH-.bpG.Ab=3D;eu+jHK%-jE+w`,iC#Q8INe9D1^w>LfGsM-[A%m-DB@nN;3X$#bS>R*A4CU@f_cXP<4CWL306BSn3HaSbi05T-Gvg,qBnU)j`#ST-G2--6OR$#b%04KuSs#KnbU^Tn&uvL68fAK;n_^siY)D#f:@F4,M5Fsx9%S%:nVR%JAlln2$&X%<a,S%,@Kk1(mt?0Tl:=G*u:=G:0kdpIGF.u-vr20nriVVx]u9Q5SGtllL+%5]EV4%(JdVsMDcF#Dwkr)[_eC3W?RSs4Gs-$XwfC3m#Kf$8Y<GsnO2m0xGI+DOk_]t:5.SsIMHh,'K`-IP.(K#M*<C<XZ3psA@*I-d*u*MIb1dMKN]RR;%t(tBb4Z-kec*.%2]=%,/r?9>@2lO@L&N'vurc@B,5OSHQ:br`3^[>)`wA*gixjKFM[p.b2,^s53]&)V@LXG$HYHjEWlq?P#%u?ERd$C08q>&vLM7IrALn3'5gZLt7alshK&+;ljO8M53BNkv80F`hK6?&WOun[aZRb.TQ;7Qb()TNZIj$#U&Ze?@j.qMjJS8#:[a/)_$)FRrUC:Qvf-mL1FAOt?A8F-[jMqL:Hb.&o#YV)2`JLLk0l]SQ'OaSU+91T?ID8&k5(2'**P6&F_f/hiv[1PX71n&MDO.'+NU`3IHUn#7'(,)7+gr6vK^o@$=;VQ,MCf_hL#Jh`&f=u-$X`<]g^lJYCj(WjVX>#[*8/1x?tr?m@9AO?*cucb2=Yul#uc2V:QSR?6LVd9d.^+_i:&=f%0&ObLCGiO<5a3VE@5]eXJg(7BZ5A$;?,`0e[,;12pP]tEw`jjTo/1ic@sdR=oPo??hg(e*UmAO,PpR,g/T[[t730i]^g:oF,BO]87Wdga;dr[of^+2aPK1npOWH%JMd`@v#?lcrsa*oU*$>8[v#P4MCN^1br,ii,dE32kgW?Oj$L(tnc?,b;K0:cnvaEc(@3Tpr[WdhDTZuM/-b<3knWQc2M?cY1_w,i.rQSF4.k^tt]k'ohSw>9-FtQv:X9eM,&+*/<n3B]GF*siuq*<Eqd'OP6gU%'Ddh:bUOeVO`r<mkkQ=-1nut?5YfkK;f$@u-qjU.pGbR8.Q(xGXPFRf%wO40AaI7ArU<4Tlsge`Xi;@lK=ZW6Q*wfY;V%YKeq]`O$U@u5RIpTs.#Rg$S5oQFuhonhkh0SosK'9-:v71t,Q51u0VC_$gOqh&g^`reUt6o,UcL:E=s4PE?)O+Zh9ZLZwi%-D9[%+--;5HI<C50G4HxuBRs8d$pA[4d@2@m]o;=e,'937XA`l1X-c7JGb=TOGMN6^t-TK5s2%)9f9r)Q&K>T[kr5Kf$whAhE@BI%+Jm77.--><Ef6930tQj=#WLMGs#8'404l'A/cfcUXm6OwB=U>&4,>9`tI9RKst3tDs8F]Xs4-WRs*4?2?7G<EEA`0i#e;]%%@n@:f9@INc1C9as^k@=%(hgstT_I`tHlf@+3XkS&$?A:$@V`n@vD+V$LU'iBp?<Luv;9asaNVIPTotjL(1qSgnDbAunrBehL'cst@/`vYWLq6VlO[aODlbit[2_btCaoPsEAgEsB^^X#K%XQY8iX'aYqnJs([EA%5YI#JJ%$e3f0H]s'FYLitE7C<hv7%g#1B`%*g25'Z:hXkx7;Q&D]s*%JhJ1KkC[vA$+?hO1mHYT7:,_$'j6.Jq_]Dst3OYs7BcnIl80.vPsOXNu45>#W%`Ps#H<4o<uEps#m=Qs'hHf$Ca64vebtab^I:;?g>$gLd)'u,dSlusiR1_%([[P%IZ2Y,DRp'EmV41uSJ8lOhva7%p^X.ubJ]lsXAm92Y']wk$goxt01X,M-3>cO3H9:u[*Mo$o,*U-.8YO/0Z(_tkhSj*@4w<-v23blD,`@4bMY^t$)uDsI`3rt<3&rQ_J7HsggX#%n_Oi]i21V%cLMGs2iYv$NS8jtx?IK:Q,kS&E/6r?ri65oO<StOktmk&b_-Y,U>+sMGQLu$eO/r/G8sitRoedFc5+?/rjEciTkuc*e0Y#79'#WFc^FQ&+2U/uPKn9vt0qN%P+suf[spw40n*f*I;SV%bOH[F.CTuO;BKnnL,qnnDrw-CtM0bO,.`[kBe;[ko/<r6f=*?6aF.Q&89@5(fbvkt+422KkjmZ$8W8_j9vjX#P&@p86g8Qjf8B$JSNnktQw5685x,#uConrO8aglORLFl/pY%ds?(/l$4+'NsoHB3_pNvAkA__4&kp9bt8^]7.g(uIku?')35C0.v.?_a@&c@kT9%+,2B<:>#F'/_%A'1,)P0P:vHQJadrIUWLE;nW%$E+1SE(Dul#fT:vSnj3vcd#egf74c0j/s8@uZM9kRBM7sNPPY#3kf-5Q8EM%^Djqe]QXV-jC%gLr9RH3H0`:m[W7>#ln#6vvaJ>Ahx4^?,^]Ds?9g>'/nnFi[_0.vYY=dDHQ<?kxU'Senf+L5>[OqLat#,2#g5>#hV++vuZtqg/t_vY&;ml/rBo?9Ik)1&gCFrdZGW'8?>=#Y^bkgLt=0`jWk6>#:%0X%M()O)I229,HlR3'GcmE[69i&#T0iwL8wVUSO`*2((C0<M$O%]kcUOrOC`F-59q9uu]eji$h&EmHWNx>-M%Xv10N8>#VBFxueaQ7NvUH%+S)`<-+I]+/kPibhc0a9`bEgKK_r9j%Z&g=#=%xslaU#o%hupo.GI4.vJRA[[u)Ln@mVii08FW:vYwmn%A/Uef0E>V<*J6^tokw,?vY%uOtWIrUYZH^X+3)M+Vtgws'CN.DM0JT&n]H8^C[Kb%*+/pE5G[<?P2QP/]W6>#+-;g%B:M5,h0+bFa>ii:*h0^L(Vjo;j(s)e]nKc%-)i)hKBEcsV.7gL:Vp<;hCK+_MOG6srE6(v/9rU0)$=U&dcL+rE`S:vO^Q^OkheDX2SRfL4x)t.G@1).<TT%M?nCWh2&@'lDqU90^=DQ&<m5Im#9<X('I6(vkYQH/GASHWA-<5&qV`?T_ErvOkO2uDC:57e56%P%X&vi.cU'SexBBuLdfYlpVc*Z-RZ5<-2ZKb%&SK?%4udS%lw_CuAu(?Yi[xOYk'J1F:AH1FX?v1-(MPPjOn<Q&wign*Jf&U%jcS$`iKiR%J6=Q%$@Te>W]8iBF;p1T^cm]k9<[l`5Z'btkMvkt%J8Xsw*6=/cnn)vqW,YBv#&>cc.,Q&f/`c]P;H:5inLj9NndL)U<n;WQL:5PJC1.vASHwbNaI+i4-ST%E%O%vMBBK.[N+k01iIJ12j:>#&G#*v#`b)[(%F-V_2QP/73,G7Lk9d2I]ejO?)78#7gW4o2WS:v#`?['-OG9#*UwRnOI6>#ZhP5veJ.:@UN(%c:5qCa;*Y+@/.6H?qpdpI;M3lOVZ(uOx=#B?0o3fOxj$fO>EsnsgMja*l4=T%#Hee5o4HL0rIPL0oc]7prmN.1QhjI1O>sL/pnjS&-aCr/V8[r/p?g'rR6kbqMJP:v)oqwu#k9Sk3USLu2I8lO(Y2rR:55>#Z)t8v)I[>G>^D,WOQlIq[K9>#gI<q8cEa9DZUoKsg3n],KiwstQO?k%OL<c(0xP<GONb7ePKV:v]L1`%Q3Mn$<*T0PO?reOTi`D?f+D>dK,`&Mqj;GsnBHnX5EJqOL5vXU)hqb%I'm_$2AR2I2Urk&uF9qO*^^@oJJka*s@vb*X1]q.S8Ycl#6'fD%3YU&w0;rOV*R/5M+vC*W'VDH;[%2&Q4uDs`RacmZ3pas/Dl#uD7_RsYv6j4epC$uog?mNm'Kas`*^@'YkO+)KYGg*-=oq./M8o7QQwR8':x;6WCQ10i<R10UaobOS(P:QL]LikI'H7t@`IK:eXl]tQDM^Oo[._OwkH=Y<+kpst8vj$4m^DIi_uHI_m-Q%._d#YiOS4Ym9oLF:MmLFW6m1-6Yl^t<:s-$bRvktso?Ks(wh3=vK2N%e/F/2<Gm;-PgPGI?JdWi7;Gc-d@lXQr%?mSlFE-t2d51ufUC_$DX@`tBwj>o1IEQ^lR+KhS[n+T2[b[R>VM6M]@CxKDR@^KB,fqEXVV(8OARUKj/_%MV=a/RL7Z=Uccs;UU+,pV)WIc%8sB)IwMnSVXvb<V,R[-Ijm;?>fG2:blQgta>_AG>TM]c,QQgdOdO(J:/Y'u#6VgwF?[iOAH@1lOBC.rO+mhRs00TgLd/^qHAOBuLrv[eOODvKp[ue'N[=srt`m]t:*>u&#o5i$O[UM')kQlne0X/Q&'hK[s*W5`,Y&MhIDxs]tM$P^$;,^AfC?IQ&dL8T%JPweO(G4hXW7Xxsmfbi?-T6`8Y7+%pAb>]eVhKl$.RO^:6XpktoUT+)3o6F%]Vfu2HY.NBOWE?]Y-e)aK(MVh9$8gO^$eJ2*CvV%afQ6/]vg4hiX82:cmsAHiUUp7uDM^65.EDF$k_+8?:O^,6#)H>9)4;MYXK$-pY?bT9T7vub<P[;bL*#H(55>#rW'#vqJtV[A'XGOoB@rm2o7>#o+]w*X<Pk9$(f,;QgX+`P&6.v/6]7Bwew]*m=0`j`VP:v*b'(vH6JF(o>t',V`Boe/q8>#Vqi-vjENOC'x#P=,mDa%jU2&X1GL6b*,@HDcuvo;d^lT%d0UefasSvlsxf%-xg$:WBS,5W24FGHaI>LH`DdjB$WWjG>Vt3JDG(mSoC_hOh=-??V`aS&5<1DK?=t]t*:Pf$&W>eZW6J/q*3Ct,XPTGKhVqg%:c,Q&'e+sT$8R.1@ANaOxBe:;r0pCB]H%q_:t6j$`nH7`@*^RsZceCr(=vV%fckcFT]Lg%1'VGVga)<gu;3r`FEPi%N>3pIu5AuB<giIsbwhoA]/G31+^ea$<`cF;e?iVs)#Mvu7/>J-/j'LhD;8:-G<]v&#+XOWQd62:7YtS&Q]@k0)m(UkO4vf_pw'a]Q9Qe2.4x:K5l,jpcRsrtEYjr/aR^T9OL&s(lXD)%8U$m0:wI_Occpo0N#wt,=:1%g'1(Gs]BMvt64;l/e-:sFGg`U0]4-Y#VlGi,uZAF%f-R:vxcN8v5MCs[2NwM/7osOo6lX:vdP%6vs.#<G6JP:vDe#+ve*#uBLF1,'fd4/(ghT:v6+@sO$Y0T*g$[`O?vbi=1fR+iRh;>#DxO2v1/L3hr%<p^iVd`*Fh=>#i(.1vV%4ksR<c$c:(1,)pO9>#)VQm%BZN1C`Y6XfXP#p8>.jGsDPW+)+3b^6xCA('cg5ND5L$k%C>fqC:cFc%u#j]toYvdt7?pE<gn'[,NZK(u]Cw_<uSS_<,YY3n,8>csX6s/QK#mnb=ILTgBZd^$_0,&V0.&S*jZSO&p5A%-Rng$%H:e66FfOR.A&wCsU?<c4Q;K_,K/X^Hm5oDWM[X)S?v0sOwu/a>G<6+FI5hS&.gGa*D3WW%LdGF2O=nS&`#3:Lr>oDWaLo,RxVMmOB*<UNdRl4D6.,>DM45f^ej*3W7uSvldb/Po2SM.0&wZit5@Bx$Vg[ha4Jka*^WNb*gV`T%bT%L]&GxGf9Pu`OY,/+ibng95+K$J:W3XI(,C;1up8Of$5ZWRswEal$ka9xIO$wiO0_]GQP9H_$,mr:N1*YwO8#PuiMOLnsU7pkt.3ka$8?_@1p#5Q&6-tMG^n[XfkSntf+Wg5%h1DK=RF:o.ark-8;4#<6GAL#`cd^RsqxQqtA9>dOPNB`IvP@_$Cv[ZW'''sO+0_.6DEa0E1F/H;Ad6Q&1Kt0ls56aOxrL43K'7.O/h:cJ]2[Qi/?).1;pYYs@FwAku?jI;&PsS&q&@M(8;u55t?a_93nc/d$H7.v6`VVBO;Mj916(.v=da6m8aN9[xFH`EnX2vu[SM&i,xrxFbsuuuG3X)S6wUS_`%;YPINW:vU@11vBK;sP>tZ1>c?3f%]6[Vde3Opi.$J^4IgYFsO<vNsEsYFsrDn*-'-V`G'8FQ&b[V7I'^FIs9QvAkrX@8n;mqia:w[AkDeYX,)F&#Z[J1Q,ZOuDs`23r?iZRVD7E?h%iieNHV%Gc%/(L-%tNxBK2Xb+ATZlIJ:Jqi3pbZiLvDoea,+P]`WgFQ&6?F]_&cVCf>9vI(7-S+@+pMa%sEF;Z&WJ<`a6U=_cW@fOt?mG6Y4%@%-C1xR&6$O_gF2$gY,2uhRNhj%J8;6`r'GQ&w6?O%d+Kwt04^[kTx/7I=VbXYK$`RsIPja*&@7.Mds[1*'SjbP(_fDa#Kn7Y@_5^t5s27IXncftI)S,5dYaDFE8-f;'14^c'Pf.-l*7C/lX-^OWwla6]oJq,(1vfhG0n#7a`e&-^x9HMn+CL9H[atX`bJ7&P1uDsfMW]sQ.Ph2k+m%-JTmpLQaV,Vd8N(TH@1pO[=p$/nj.T%C`bgtr,_Dh]+<5&Z8R:vx1nj%$Re6g%X7>#vNN-%toXU$VeNoRqsX:vOJG$vu7##M5*A2P=9hhO%eO@SPTD`$@5A$MF<BgL-#LM%v>kT&q<=5p[sR_Or]h6pRi^7.PH+7Is%>o.+<iC*;WiS%9)7hKR&CQ&v84v8@f)bOb(F*nIV?@b_3I[a>ZA1lP.RtS[dCZ[Hd6GaKB@d,d<&<-d6't+j'px*&(hS9#I/s7tv8<-KST5<l$NvuUJ9p;#mul9&h;@]W0/]&m@SkYJ11`KY#WGRN,_XV:wv3W>ZDJFpAP^%J-aC[)tIIGYe]`OIIU2Xj-pJG1.ba%D$4&XPd4@UGbHIRUD,f%Xp`=Djf3FJnNnuH3]HQN53gkOp<$c%?dvU6h8xWs$8Q.QX#;iP9-#H2+qmc%NBbAu),$os;UU_$BALW$)4k#Kkk%<-/(Y_$adU^T.I;BT+G;--/,>>#/:jl&J_>w-O_ZY#'5>>#,-o-$k&:MTnVPiT[]f--<F-L,G)###GkcA#;X((&]4Vf:)Hxu#Ner*>jP0$Jv$WY,)>MMFOk;;$@Xlxu4O:&OWO$##dB_O;PjlB=GJMe$H&>uuQoRfL-nR`Ec0S.#1g2E-DwchL_R6##08P>#8&krL^UQ>#gNb&#<EFV.v*^*#TfuG-bLuG-.@1pMIKH##8r)XCGh?_#%m>PE`QdOEfrFG)P,a&#R?3L#O`qr$_rBX:pv;A+ZCtr6[mMAO:TZq)OAYQ'2),##%ILpL$980#9`($#Uww%#?c)b20^Q(#HPj)#aC,+#0mRd#:Hg;-6TGs-T0uoLqV54ML3_xX8hD>#?@7Ac._X]YLH^Ve7I]-?t1LS.G=vJ2'(i9;GuIY>+.glAGE6R*.L@VQ'=)w$+kZ4].dG_&>R.AF[a?>QY?<p&Ia;@-v#'/18`nx4PE`l8FNh+M^G;pLGPP,M3xGf_xOO&#XmG<-f0#dMB+73#5),##`;)=-&Ig;-_N,W-vAY_&)h;L,#C*1#rlRfLM?+jLQptjLJVNmLVC#OMO%,gNMQKvLg4$##(Gg;-v@g;-C_Xv-ZGLpL,`d##P3hp&<,058XoB>#A1<JUB_cxu-.:B#P+/5#w@g;-v5)=-*@xu-b4YwLb'e##@oA*#r-DG#[LY&84c?>Q85+^#@lF^#rDfnL?(='Mn,?>:N;PlSgwA`W)^3S[AC%G`Y)m:dre^.h4KOxkL1Aloem2`s'ML;$?-5/(Wi&#,pNnl/25``3JqPS7cVBG;%=4;?=#&/CU_mxFnD_lJ0+P`NHgASRaL3GV#3%;Z;ol._ST^xbl:Olf.w@`jF]2Sn_B$Grwx=##9X&m&Q>n`*j$`S.,aPG2DFB;6+.BB,$,>>#jJ^e$,7ae$tb`e$BvTe$NWRNOQB?1OcR9MBp@7#6.rbxu%C]`X>HIAGg/x34#Qd.O:,b]+2po`=RQaJ2_kdumX2YD4@Yw],:1P&#MR-iM1_IIM]1ZDO5eWUM=QrhLfCH>#NvX?-A)`5/lb[%#3^M:MG=JcV-XrS&T5/FIU20xtQe./1xOO&#r#1LMl,$Yuck->m#YkA#gSYdMdH'9v*),##ta`=-LIg;-OHg;-T`.u-JD@bM=W@IM`I^VMJuBKM5L4RM(RcGMX%9)vt2G>#Y&uoLP?7I-9(>G-<0A>-kRx>-:Gg;-X&r@-@R[Q/sU4A+5h4/()lkA#GHg;-?Gg;-Rx_5/:L7%#N8^kLHhJ(#g.`$#>2<)#w[&*#2`R%#pnl+#F$),#RqB'#O<#s-gviuLx[7(#b<#s-)P1xL$iI(#.OYS.(a39#dN^Y%lYd7nf)>5&iG2>5sQRP/Ik587K_KV6YmIM9nHclArD*58L0(XL&8JA4L9%298;;)3lW@>#fpWoR?/.k0nYfYP;>LG`k^r:Q)ld^%du]a#ihub#+[7d#CNOe#[Ahf#t4*h#6(Bi#NqYj#gdrk#)W4m#AJLn#Y=eo#r0'q#4$?r#LmVs#e`ot#(V1v#?FIw#W9bx#p,$$$ZO?k%ef,s6cJtf:%1fY>=mVMBURHAFn8:5J0u+)NHZsrQa@efU#'VYY;cGM^SH9Abl.+5f.kr(jFPdrm_6UfqwrFYu9LW5&Q2I)*jn:s-,T,g1D:tY5]veM9u[VA=7BH5AO(:)Ehd+sHOMB>#Y]Xl]19kM(:$2)F^`6#6CusY-Iv&vH@CP&#RmG<-f8uZ-3&Z_&ufce$>nae$I6Xe$]El`MYU?LM6Q7IM=&xIMvxuOMRO6LM_DZ`MXtmLMEfp(OQTU1p^,F>#aht4ff3d>$)lkA#5nG<-7_`=-pnG<-?lG<-DjG<-#Jg;-S``=-CF:@--Gg;-@Gg;-3Gg;-#E:@-<Ig;-c[Gs-K0IqL(55GMc8H`MoD*UMi])aMj1jaMbVv`M:r*%$<.:w-nGAvLL-b^M;LXJM[>wTM&B=-$)m@u-<jErLIp?TM[]8)$IXuk-Ub4R*Bj4u#K$)t-eV0%M-7mWMn@GGM71x.M$2b]+Qh9R*LXGR*Bm>MTXpsJ2nN+:2AqNe$+MOR*X=Wk=Zk/:2>`NX(@dHX(0k6&G8o;s@16d-6.aU_&UB@L,wDFDE:[Qv$ieI_&^7KR*3qo(aNr:5KMw1FI(OX_&bqp-6%u5qrBHY_&8)V_&UY/WSl=B>,Ol:<-_nG<-&kSO&bN%dMVodLM2xDi-:n&FIg/VX(RTbe$lJce$svHR*'nDXC%Z5LG%w]e$G&RX(=?h4o2ueD+lid9i@AV_&xm]e$Td8F.oTfe$/4TX(`IW_&qjw(b@h9/D/kR5'w,^oo45vqrp5t1^$)>uuY%?8JDgYiqaJL,b;peIM(3eTM#:Mf#t`nI-YlG<-[Sx>-cH>k-fuXw9.(3X_kiKdF@OE?Qiq18.m3io.qKIP/ud*20#'bi0'?BJ1+W#,2/pYc25>V`39V7A4^I47oT0t`sSc/*#WoA*#[%T*#`1g*#hI5+#lUG+#pbY+#tnl+#x$),#&1;,#*=M,#.I`,#+G31#4fa1#HLg2#Qe53#`9v3#l^V4#u&/5#8j=6#C>(7#Tih7#eb39#$C0:#GBZ;#wnC?#VjBB#*ddC#O]/E#UoJE#Y%^E#wsRH#of?K#u>]P#1^4Q#6jFQ#;&cQ#J]_R#Vu-S#_7RS#gOwS#mhET#u$bT##1tT#,UTU#=0HV#EHmV#KT)W#Oa;W#W/sW#%>lu#LX[[##3$_#?2N`#*Irc#Nake#5l&i#fQVk#9)(3$W/5##TE<L#^$###+5T;-T5T;-Z5T;-a5T;-g5T;-m5T;-s5T;-#6T;-)6T;-/6T;-56T;-;6T;-GmL5/M*,##&?5od1I]l#EIU/#5+M$#'I5+#cK;4#%?S5#=2l6#U%.8#nnE9#0b^:#HTv;#aG8=#$>P>#;.i?#Sw*A#ljBB#.^ZC#FPsD#_C5F#w6MG#9*fH#Qs'J#jf?K#,YWL#DLpM#]?2O#u2JP#7&cQ#Oo$S#hb<T#*UTU#BHmV#Z;/X#t7cu#5x_Z#Mkw[#f^9^#(QQ_#@Dj`#X7,b#q*Dc#3t[d#43G>#l7?f:B.B;Is*/X-0=OX(4RNq06'0[:<WlA#GQx>-SGg;-C_uH&BJ7@-]cA4(^#Ok2w$deuw4G>#IbKe$6Wu>-05Cw-c)kZM-Jo12px%44g<fe$B)2Z-v64X8DY>eu`4bZ%82#P]C=)R:_GYL:5ts$6vR'583@#&+xE'8@#Lc(NPdS,37E8L#grLlSRv4d3Fs8L#wKu@XT2lD4`i9L#Y#Alf-@tx4GYd7nOVnIqfUs?6:UWP&2985/5(,87ZO`S%3`8E#XxJ*#ssRH#v(gE#n]$0#a>2O#cDGb#=vm(#Pv;%$&kXS2(8P>#KOg2#hiGN#l6>##tc&V-<5T;-B5T;-H5T;-D&&(')W$@'$Y,i$3@hr6/5WlA5(rr$EWCG)tuCT.&5YY#H#Su--?)UMBEUSMi*ZWMh$QWM8Y1%M[*w>#1YWL#7lsL#ibDuL_n)?#Y1QtL_JntL:/1M#?cS(9jR^'fxhH_2tFtN.&)PX1Q87mgb&sK#,$8>-W+5t6ICaD#2'q^#G#=]#*<=e#O'%w#7sI-#FuTB#&BnqL$Ji^#aT7d#cHjD#SJ-X.@qm(##1r5/FYe[#j2TkL$A2pLnMpnL_H<mLCPFjLh5,0Nd6wlL_0nlLVtmLM3MN>.bTXc2#/SGE;9N%$Dp:PoRV_]=FtZ`EGe38I#*CYc8mG,*/3kM(1G^f`^i@6gwj`=ui<s1T-/<5AfN/sntCqc;mwl%loo.Dt^tb#-P_Quut,8)=r9Y59*]/kXTF,>Y%nPPAY.NSf3`SGEOT&g2a%@'54[di9,<DMBb;,F%C1Jrmp?Ww0*s';QZpo=lw&ti0Uau9)RY-F%+13v#Tf6>>wCV_&YIv.:='UY5;v^:mH^K_&;S(/:Va[i9pGk-$Ndsjte3w.:EklA#%ch51w[ZC#NYe[#tLsD#r#iH-;S]F-G7T;-a<eM0A%3D##7$C#`87#M6?VhL2ZrB#4####xI?C#JM#D/?JPb#%1(pL?BL*#jp1c#t<fnLpAb%$u33U-qgI>/*)q^#9-vlL<=O`#>bEJ/D6ND#:'niLt$dI#2BaD#`vIj1D:gi#oU8a#L)gE#v/(pL$m&-#GMWU-3,Tv.G`v(3SFm-$:1x(3:L5Q9-#65&;@?$$HGI[#)-N`#bee+%)cb&#YUXgL:0C*#D2`*M9;99$*pJ)8x%/Dtdjh.$9Vi.U0Fi9.pPYb#XT&g2^iiE+xg[P/NKo=l5([/$O;TkL1MR;#[w*4P-%.]kUV5]k8l-F%Z[r-$2;.m&<1#KNYh?lL5lP8.GT6g#?j0N(Cv7AO+43YlrHM21VC9F%SfTwK1sLG%n:kA#psDH%f%3>>+W>G2NN/g2SjK,*-.C#$W`pf`k&Qk49M@H%4.Vw9QI4onkTZY,Nacf(Wcc=l*X05gj):MqZLL]lk2Uiq[Uhxl8oYcaB%>Y[k_CJ:KP'/:%&2>>P]RY5hC:uu;v^:mk,_w'@UA-m:c$,;T]FM9iwTk+/:4>>k0C2:DqcF%&KLpLXpn;#1_P+#?_A(M0(g%#&G;T.6(q^#k)/>-+QYO-S#xrPq`#vG6'-,M.^8)=QXtfDvPIF%V-ZcM9bk`#FZZC#d]hqS24f(#CP=.#%sLG%?tw+;u1fr6In?W-W9q&H'Nlc2c>A,M4D*#5(F/VmIASG%Tc/;6AcEJ/v^DW#Q#=cM^h?lLiV05#;:=&#m,,>#U%`xLV-<$#aHmtLChn&Mtk9=#4#l.#d'=$Mu1N*M5phx$Hs=:vNk,7v'3/HXNZ2v#cfUW&+SMpL?$F8v@e#7vPZ6B8H,GRE`Dx-#hM-(#5;4%8W,d&6biE?%<+L,M+Z4C.H]jr6^Y6#6`#wuQ0=9/Dd_F59O<@60s)LV?Znl=P:CR]c?p&vH*]@5B;Ke]G<T*#H>hjud7'MDF#t5;[i7-/VNLjfMx0Q`k3ls-$/^tF.3`98Sf(7#6:4*F76X2ZHJ:CM99<^p.;kC?#@8TppF=(x2wv4>>e-pLphC:uu];DG)7*Mk+U695&(60F%VOr-$lk')*#(3F%,0v9)3pP`<<k/>>=3IDkdeIk=gj_7#ZBM,#[p^w0e5Ok41]JG))?1R3-MxW/?(i%MrV>&#sL_/#k]5lLfE`x.kO)/1t/G_&d]Sk+/5DJ1]s0>>MfH_&Q*95&lP,F%vt$REE)XY,5tJ_&@2hl/,#55/:/?G2BjIP8hXt^f/Coo%X3=G2'T88.N?jl/QNu9)vRkA#VO#<-,vgK-YN#<-.#jE-vKx>-_4`T.C4#F#Eq8Z.a?.@#b%jE-?gG<-sG*b.[(gE#)vqh.j<G'$_2_W.>FI[#LA;=-A[lS.cGt]#aO#<-'8v5M7K5s-'C$.MM*BO2vR?(#=.3)#7eg:#;H;8$sJWU-.u&$.&:$IM@ReuL1fWM0HTvGEbCgY,+1(Ft;Vi`3_nOPA'a3`s'Of7nLa=R<Q=KG)w?wr$p(`c2Pu08.[Iw(3oa*sI&<BSo:$`Gj7:I8%IjL5gej?877h?'-SC_kL_]8+Mm_#<-NSG-M)+B-#,@De0@=ic#-+^*#Osk4M-s$Ak*]M_&1;_68FSRK<.@Z=M(UlDNI&$-.YkS(M@i5xNg8Za&Ku0FnM)XY,bBvu,Ik')*D5)dtB[P)NU4dJ(3:-#HpqtcEP<Im0KB729S1VG%Fw(B#*o%S8da(5g7O#kk(<PF%O)hp.i>JxtG/2x'f^oc;[%Nv6Nh[F%)8d39H7t#-'?9/1E,L?7h4k?%'YkxuK3`6(56A*N88m9%tG8'-<:OO'_SX*vCWR_8CZqK*[5n+#fw>7v#n?'(YRS32-0,]#xl=u#^02'#O;q'#O#eiLl)9nLuQ489j7XWSDe`=-f2T>-X2C59l5Y?.@.s+VW*XC&sm`(;Be(G%@<&=#eNd;#,.;T.q####s[lS.w6YY#qX`=-<fG<-<7T;-BJCAO4i8;6Z7<;?egGk47ZwE7#Vb&#p+aFN:X-29siK.$#_Z]+][rS%Lur4#gNe8#;?h'#'VM4#9-2,#U'x%#s2B2#ia''#tg0'#s_$0#<)ffLmP&+M+:(2#rS*rLR=6>#?@_hLefC%M%OQ6#+a*9#n7`$#0U+oL+tZ+#J.;T.sP/a#ULx>-hr.>-2ju8.cHjD#mPaB#o[lb#um;%$&cP[.B_''#v[b?/A0Uf#_bqpL6_ORMQj#6#$]s-$-D32'l9SP&(Nhr?[q$##;bOiK>QO`<L.@mKU=0DN=M?v?.*Y-?K%N]=p)=kFqbOfLn_ojCk3)]t)fQ`<_%w>6H?v.C$_'^YsPh`3$^=*=tW$&O;_9AX<c9At-,1eg", 
			cantarellBold = "7])#######)*bH;'/###[H7+>)322'Ql#v#RxMT9hKp%W:6)##87)###JiT9r1)%S;bE>#Xk$##v5:t8qjjcDOA'##?2dw'%;,h<C?aXq>q+##kw(##Wf+e=L,Y?qx*dw'ZWe--#/ue=E<4xF?r)##K'^w'7vA0FZ/'kcn7*##k5+##GtBUC#BOdM)QOk+P=r-$f'TqL'&d;HtRr92>M[w'E3n0F^ENi`SICwKHk%##Pr[=BNnI87'fX&#SJf--w:]=Bemd^0Y<q92E](##Q1CiF<BxCNB5hQavTi--g7?>#/VNh#4xn.p.ge<6'..w#Blx&#`eotOm1MIMF=/cVoke2'm+Zw0PMYY#.hAG2'>uu#nNK:#lq8auWWf]$1'9kMh@$##f6%##(V<j0vEec;<3]V$Ze5AO$]X&#<,LF%0op:#`%eS%/rQS%^U/V/q3PuuE4hEo:h$(#=mgv7B:F&#ED1Z#srC*Mc>8S#i.$##+SO;.h3`l]8=P&#4.;t-ZkwfNLi_U#<B`T./lUZ#*0)t-V(ofLB#TfL::^?.[/-j'>h-?$3W,#>3LHZ$dX+,M0=?v$9mmr[3X;s%Z45Dk9-AT&0YW>5:6]p&j$lcM;?x5'mVMMp<H=Q'i;[PfLf;L)1]YYu'5>>#0>###2,IwK.(1B#wJFSR<UL^#5<w4]1:h#$3<g%b2C-?$#sQA43LHZ$RepiB0=?v$q]<;R3X;s%<%Zca9-AT&_ur1p:6]p&UXbPA;?x5'kBslS<H=Q'LLI2T]qxM)&n95o+/G]FcgXoIT1PcDH]4GDcM8;-YqTiB+D-F%Rm>G2WMhA5)p4L#Vrd'&YJ7A4>36R*A=@_/2O/F%A[u1BE;Qq2e+Be6m%L`E@x&?-/`?VH?qTJD<[6^GK.75&W*?X1:*G_&VR?M9I^MDFZkk>-W*f'&5ef'&)=Z'8:si+M5If>-cFII-8)m<-fQqw-pm-qLI4urL6#/qLIwXrLIQ-5Nh0n+#;1SnL$NpnL:*8qLGWdD-lIe2Mw6;PMw'crLNwtRMM`7(#-Us-$-o^%O7juG-g&l?-CbDE-$^mL-QMYdM]mrpL$SxqLxT`/#(TC5BE9Q@0#8ujtT.Pk+a:p^f?_n-$>N_w'_j;MB`]iQj+O;_8K.R9`HHO-Z-pl%=/mC5BWV6^5rw4R*C9g'&G-QY5+v4L#vSWiBT1PcDlE`>Hn2iKY@5scE<<i`FBt9/D6pjG<=;tjtYBDP8DX=gG&>.FHMeZ<0+9IL2>*e-3<6i41f&@UCVpIKF&6FVC^x2s7:8QhFsl<6&h=r*HhxtLF%g9fFM>4sLX2oiL8H%oD#SI+H-6eYH#g1eGvRb-631(O;iG3VCd6u?-BdiM1+sDSC7;ZhFgLqk1T+IU;Yg>[947V.G'fC90rxuhFH-B5B8tDU)2?ijE2MD5B&?^kEdjeUCCt7FH-ESE-rGnC-=;G;&:4//G/3`$H(Av-GWPX$HAm@bF&B8I<a_%##C^'=-Pk,-0f[&*#TZO.#3^GW-1SNe$#Cl>-<9i5U+xZiMFi7(#43h'#/v^L&TAe>-B2K<&qR(UDeVpg2D?@P1BpJF4CC^>-#-,.Zu?l051#'58[,'K2*Og+M%c@(#Mi)M-p?dA%-'7L2.rn@-a=hM1`=hM1o+]p8Pt[rHNn[f$)iH]FpB7L#E&w9)'Ns.Ct*39BcuiS8A:x+H7$7rLgO,.#R/(t-(H<RMZPr'#&T3rLnX+rL:2CkL?wXrLn@dt7gPc/amE;/#ooao7.t@eEA5Mq1+>Z1FCT5fG=h8OtlxtLF`C/C/O`V5BMx$[T_'ufD?gURE(Z$6B%uEGHwww<:x1TpTwJ?&4blRB$ujFD'>^cp8'<H&#tUB#$>A@&,Pee8.qk$v#Fle&,Ur./LVMsYl+*[0#0Ni,#x(eK#GLpM#xV+Q#BZ2W#r=lu#bKt]#62N`#HBno#abCv#Heww#Y?kx#v86$$3p2%$K=FE$YldG$ZQiK$%^OM$APhN$T=wO$VrFU$]LpY,:T+^,Z;1_,9FBb,p8/e,T[eh,5t^j,O*gU-+[r<-=Bx=-Nsk>-er?@-(YEA-:@KB-[_SM-1%`k-E)1Z-erH[-Rv(s-'nIt-9<+u-Js'v-tXWx-fV+'.(8V8.hxd<.__Qs.*x$-/2:I-/>_*./FwN./`pp//uktY/HZh]tTle+Mb:H&#T4KM#WKDO#D%7S#R/sW#:$4]#I2gKMEUfo#WIuu#_EdL/s,$$$[;TkL;l?(#UkiYGR;>5Swv_YY;cPM^Q6b`a3TTYl@-t]#2[e],XlVP0+jXV7f`su?JI(2L2hW3k[sK&#gHoj(B*A&,qpS3k(*WA5Eo)5k8$k3k`6A3kp)54k%@b#$/PrudqtbAk$sFuuZ$H7v@W=2vxWi0v=AE-vjAq+vCCr(vqCG'v0=X]u'X`ku'/wguoY6gu]gteuOHFeue;0UuV_5NutmtIuQH=Iu?nIHu7U%HuwI>FuKOrBmpYFAmKN`?m7O5>moCN<mW`?vl*-+9mlK.8m[k(rlPXcqlJFGqlD.#ql.Gsol&/Noli;6nl@Y_bl-C=Xle3MVlGkDKl[i??lG2C>l>aOxk*e7<lNlA9lb#U6lTB+xk6hUfkYV02ktKt1kn3O1kh'=1k^LI0kxn^IjJ6nVi8@,2;'iF&#S,a2.d[k,Ml9-##cfq#5&/5##*;G##.GY##2Sl##6`($#:l:$#>xL$#B.`$#F:r$#JF.%#NR@%#R_R%#Vke%#Zww%#_-4&#c9F&#gEX&#kQk&#o^''#sj9'#wvK'#%-_'#)9q'#-E-(#1Q?(#5^Q(#9jd(#=vv(#A,3)#E8E)#IDW)#MPj)#Q]&*#Ui8*#YuJ*#^+^*#b7p*#fC,+#jO>+#n[P+#rhc+#vtu+#$+2,#(7D,#,CV,#0Oi,#4[%-#-$###-G31#4`W1#KX#3#bE24#gK;4#lQD4#qji4#vpr4#$-85#(3A5#,E]5#3^+6#5d46#:j=6#B,c6#HP_n#8ut.#>$S-#3kf=#99v3#Sd0+$N4C/#X==&#E*20$^=$,$hHO&#VVH,$Rw<x#->M0$TM=.#N1ba%:Ec._Yfw1BWgZA+2bqY,P'.DEH5XxtYvl.L<HSoRJa1,)`31Jql&*DsfW-Grdf_G2re&#57:nS%.V:v#K[K;6BK'8Il,E`sPcRfL/S3JL7@G`N?'@YP?q_xOKp8SR/>##RYoLiTYvqIqx+<JLg8$2K##[iKu+WfLxc_lJ=_C#$-PNh#u<*1#o<W;QNL-##,8>>#'bR0:)im90V#:B#&),##%G$0#?sn@tnq51K7XN=$l*$o[n(>$,6fk>,(g7Op1SGs-aq0hL(V6GE2J,W-J:2I$SDkk(H4Ke6enfi'Vl8>,sjai06l7(5QN%29mC2A=4WViB`W=SII>[Eenp,kbW$J3#kd`4#0d46#IVL7#n$X9#7$-;#PmD<##Jc>#?:%@#d^0B#-^ZC#U7#F#mhlF#-[.H#HZXI#82'sLZ=IQMDB*;QUo6JU(Tw7[I*'Abhxn4f-t@`jF]2SnXnb.qoMSxt4=E5&M&7)*m-`S.'Epf1B:'v5b`,)<9Z22BRI?AFn>LPJ0%>DNM8clSw&iuY@4Vf_[)ducrRt1g.q.DjG`;SncTHcr$,G##@<(g(o?I5/9c3#5fl5)<7HZPASRd]F#)3/L?'[YPUPllSjt&)W.mNS[Jkw(agiISe-hr(jIfDSnfdm(s,]h;$HT1g(eRY;-+Q,g1GOT;6dM'g:*LO;?C5A/C_0jYG%/</LA-eYP^+7/U-jWS[Lq*)aun,/h?#UYl[w'/qxuOYu>hAm&ZfjA+'9T/1GO^;6fS0g:,RX;?TC$aEqAL5J7@u`NXl$jT$$M>Y@xui^]vG>c#upig56f`jQ485on2a`s4+[s$P#%H)mwLs-3vuG2OtGs6lrpG;2qBs?NokGDkm=sH1lfGMMj8sQjhaGV0g3sZLe[G`ic.sd/bVGiK`)smh^QGr.VLZ#JNl/(gL>Z,-Kg/1II9Z5fGb/:,F4Z>HD]/CeB/ZG+AW/LG?*ZPd=R/U*<%ZYF:M/_c8vYc)7H/hE5qYlb3C/q(2lYuD$^m&ax/B+'wWm/Cu*B4`sRm8&r%B=BpMmA_nvAF%mHmJAkqAO^iCmS$hlAX@f>m]]dgAb#c9mf?abAk[_4mox]]At>ONT%ZMw)*wKIT.=Jr)3YHDT7vFm)<<E?T@XCh)EuA:TI;@c)NW>5TRt<^)W:;0T[V9X)as7+Te96S)jU4&Tnr2N)s8+I<$T#ig(qw:<-7vcg1St5<6pr^g:6q0<?RoXgCom+<H5lSgLQj&<QnhNgU4gw;ZPeIg_mcr;d3bDghO`m;ml^?gq2V:$#NNYN'kL,$,1KTN0MI'$5jGON90Fx#>LDJNBiBs#G/AENKK?n#Ph=@NT.<i#YJ:;N^g8d#c-76NgH,C^kah4Qo&jxAtH$K6&exsa*+wE6/Guna3ds@68*ria<Fp;6AcndaE)m66JEk_aNbi16S(hYaWDf,6]adTaa'c'6fCaOaj`_x5o&^JasBUEt$_MeH)%L7t-AJ`H2^H2t6$GZH;@E-t?]CUHD#B(tH?@PHM[>#tQx<KHV>;tsZZ9FH`w7osd=6AHiY4jsmv2<Hr<+7[#X#V0(uw([,;vP01Wt#[5trK0::qtZ>VoF0CsmoZG8c&kKQQ3$PnO[NT4N.$YPLVN^mJ)$c3IQNgOG$$llELNp2Du#uN6g6&k49b*0*Fq.IoR*3h)]680./b<F^Z9@c[-eD'TU9IIq_ENnOeNT<snZYX'xg_w+J<d>38-i^@&tm-#,'tS^1O'ukY$,;j,O0WhT$5tf'O9:eO$>VcxNBsaJ$G8VW3KRHeBOnC7nS4B`BXP@2n]m>ZBb3=-nfN2:'kp`%[c=:ZMF.#nt7TPp;-iV5W-#j-+%Wl-+%32a,Fu@ViF)M/+%`>kdGqWd<Bkkos7-2vLF0ehmMIB+9B+)YVC;V<j0P%VeG%^4rC&TFvB$IlT8xGA>Bi>pKF7+G(&M[O<B0&%mBg[+p81(=2Cm*cp8u2j=B0Gae$3g-CJ4X/+%3j?_J2Iae$XU2x9:0G(&GqMhP4X/+%Zt[q;$7/XCIkZOO>ElC&XUDX:4Oae$XIQ@9<6G(&A(:oD>T<.3XvfG3M57A-CDVT.LGcdG7mL5/bx^kE0$@RMmD5kM6^XnMm;pNM;S=RMmD5kMx]XnMq`1hND<En:vOX-O61$1OOthd-nu-+%aH;7D$EpKFoj[:CH2*:B+)YVCI/#dM)qJjM/vDN;.RucEoNZJ;@7pcEmZ;,<^>NDF/J-d3,K_w-aGHOM_$1oM*H*-GBCffG&'AUCNp7UC#AokMQ,:oMs`POMQ#uRMc4WOD%Lv<B:>-lE3.jiF-ESD=Iqh]GmZA)4jeV)4@l#=C?qae$:S#.-@tae$fvmwpJjlC&hZhTCui#lE0=TF%X4`D4pxGs-fc)PM,@LSMXV6VBC&orLlZ)DHnWrTCBHg;-&`8N-DQp;-&cAN-GvCp.n.?LF2l<I$0/q[^P8`%'&^=jVCNqoM*iw.O.+E2O0u3/OP5W2O,M`PMjf-TM9D@#8QN>8J=EtW-GF1beGsTNMfVai2hX7fG3Y<I$v_;I$AqEI$PFRR2P']LM>eov78SfS8(F*W-7LUU)]%.+%^(.+%f@.+%:#(W-<1B@'iI.+%%;jS8'J8p8cU`X-$g-+%0_*W--VA@''G/p8'G/p8'G/p8'G/p8'G/p8'G/p8'G/p8'G/p8/xxp8thO<B0ZX7D--r3=CK-44CK-44?n7LM%>,k2Z]F_J5sH_J5sH_Jb-Fu7*HX7D'+OGH&%G(&P;hjM=:oQMg*-(HxVKSDAEi`F8HIk=,7@LMmqvh2kTN,3Jl2i-[Sa3XCR8791qcP9UgA,3Z(Z,3+.9@'5>iHmDSlC5*G%'ItrY1FA6m5MImK8/-Q@@H7qhQMTecHMVrdL2qXPHMB0eL2M=;iFm/pgF4LNO+)BkG3&CIe-*@+IH-:@LMG&*i2(Hd50k2+hFw)9kEVNYOFY/3CAY/3CAY/3CA+?tQjXwZ'].@ILM$8aI3>.B?.bgIoDY/,d3_@Mt->:[hM^edhM>%Gc-b'5L>-77LMtrvhMeumL2Y-/d3Vg`&.FkNiMXnSN-^qSN-`-50.QW^jM^e_).RZTNM^aQL2U^&g2NEUkF3e3d3$]=oM;)3i2u*3d35JX%8%wxc32`h;-FaQi$b8P)YZ)3i2i3TkM:a&k$FbSR9d;B,3kNE,3QTgmUZ/N.3T.s,4Z/N.3[n0B6i_;u7duxc3rw)W-Dj>kk0j>kk>QKjMWJX%8*vxc38w*W-)uVkF?6+W-Em>kk1m>kklwVkF1m>kklwVkF4Yh;-=&F_$B@3u7vl]G3lWaG3lWaG3lWaG3lWaG31UeG3.Re;-lu+G-2o'S-2o'S-mu+G-mu+G-<op=99',d3BG'`$^i/K<WqvhMmrvhMmrvhMmrvhMmrvhMmrvhMmrvhMmrvhMv9wL2KGRR2CI[hM>u+G-nu+G-nu+G-XhlI9E',d3nu+G-nu+G-nu+G-nu+G-nu+G-nu+G-nu+G-nu+G-=op=9?',d3avVE-pu+G-teldMp.<iMs<EM2?SdA5f7,dM+:NiM+:NiMS<NiM8;NiM8;NiM8;NiM8;NiM50lo$AYTj2NW1s7OW1s7OW1s73X0s7UTJkX]FKkX;b7LM;qJjMo%NY$@WKjMBqJjM3rJjM3rJjMPqJjMQwSjMCwSjMCwSjMWWYd$7[;<Jm'8r8(I,p8.g:<Jm'8r8eaB<Jm-S79Lvxc3^)g;-rVYd$7[;<Jm-S79Lvxc3^)g;-rVYd$SQ#w7M[+p8&E2p8'NM59p%J59o#M59p%J59<'f;-'q(P-LjmF9#wxc35c-W-I$n?g5$n?gBf?vei,gjMp-gjMp-gjMJ_im$8f`sfo9oR9.obsfm-S79N',d3)v+G-SB$i$?rF]HrN:79-?ojLt7kvLfjAjMW:ArLovSjMp&^jMI:ArLx)TNM]_ZhM]_ZhM_gZL2eAK,3UPp;-g%K,M+#879Nw,D-O*H`-,-ak+4h<iMZ)b+.R0ohM2mmhM%lmhM&rvhMPrvhMPrvhMOsvhMOsvhM_rvhM_rvhMPrvhMPrvhMPrvhMQx)iMow)iMow)iM`x)iM`x)iM3$*iM3$*iM%$*iM',*M2JchD4f7,dM')3iM')3iMD(3iMD(3iMD(3iMD(3iMc[+S9a#/>BP#kSM]f6;B+)YVCMD[20X^IUC-mgoDHX#c%bZ=&581<&5*dYA5*dYA5*dYA5*dYA5*dYA5xK]A5:n0s73X0s73X0s73X0s73X0s7Y(d;-%JSZ$$mjv%ejAjMYX]v7Y?/s7Y(d;-1pRQ-1pRQ-1pRQ-1pRQ-.5SnMPtAN2eNY88f7,dM%rJjM%rJjM%rJjM%rJjM%rJjM%rJjM%rJjM%rJjM%rJjM%rJjM%rJjM%rJjM%rJjM&xSjMA#TjMA#TjM&xSjM&xSjM&xSjM&xSjM&xSjM&xSjM&xSjM&xSjM&xSjM&xSjM&xSjM&xSjM&xSjM'(^jMB)^jMB)^jM'(^jM'(^jM'(^jM'(^jM'(^jM'(^jM'(^jM'(^jM'(^jM'(^jM'(^jM'(^jM'(^jM0E^N2LPnn2e$]hM>u+G-(v+G-(v+G-(v+G-(v+G-(v+G-(v+G-(v+G-(v+G-(v+G-(v+G-(v+G-(v+G-))Gc-1):UDrCY[?*G%'I61be$XWu3F'Iw3F'Iw3F'Iw3F'Iw3F%=e3F-9IL2?1`,37u_kLXGp;-VPp;-WPp;-XPp;-YPp;-ZPp;-j%K,ML5q-NOkAjMF*W#MvvSjMosANMVaQL2fuU*43r*cH+HOVCt>]:Cc>^G3fdfH3DSFvBndR:C8T87*9+Rd3=imfGH;)=-q8&F-;Gg@5^aZI<j0v<B/GqoDwAXVC#VRfG1TfUC5=^b%Y(+SM(H[oD3h?=(<$kCI^^<C4$'kjEidIqCXORFH,iViF*JVEHQZ.rL`EWhFGE]'.AU*iMa%J`GaKitBtr>LFvY9oD>D?LF,vCeGuP2e.vq`7B&2>s/=xEcH$D2iFFpu8.1rw+H9XK/De00eQEQY_&HOrG3hl-+%<*xG3u_8@'=H0NM(6199`Yud3p+dfGv.@bHE)vW-H%3@0H:;H4d]:&5Gk=2CIYL)4<^$x-Pe7LM7],034;:WCm<DtB$N'kEFxnq.nu,(5/I+IHDjTNM5af+4r*]u-P[%1MhrAN2EG[88Y#&'.OC@lL70P<8U00oLQj.jLVedhMfkmhM2olUA,(F6)iVs:'.cF&#$<aufgi1F?VE#pJ?sO8';WE1#:n@-#B<x-#(?)4#c:w0#Ylj1#&hGN#Q^V4#EE24#KlsL#+m?0#/0:/#rONL#>.92#:3m3#cQD4#M>S5#&3A5#,9J5#^fa1#5j=6#4^+6#<,c6#<vO6#wqG3#GJ:7#F>(7#KD17#Yx&2#T]U7#Tih7#1.d3#/C[8#a7I8#g=R8#+5B2#pnE9#ob39#w0k9#w$X9#Kki4#,OB:#+C0:#0I9:#VF^2#9b^:#9np:#SL;4#@)9M#A4KM#E@^M#ILpM#MX,N#Qe>N#UqPN#Y'dN#^3vN#b?2O#fKDO#jWVO#ndiO#rp%P#v&8P#$3JP#(?]P#,KoP#0W+Q#4d=Q#8pOQ#<&cQ#@2uQ#D>1R#GA(7#uOLR#N]_R#RiqR#Vu-S#Z+@S#_7RS#cCeS#fF[8#CIpM#k[3T#ohET#stWT#w*kT#%7'U#)C9U#-OKU#7)02#@Z^U#5hpU#9t,V#=*?V#A6QV#EBdV#vVL7#@NvV#MZ2W#QgDW#UsVW#Y)jW#^5&X#bA8X#fMJX#jY]X#nfoX#rr+Y#=/IS#x.GY#%,###'Bvr#*GlY#8AFe#0Y1Z#4fCZ#8rUZ#<(iZ#@4%[#D@7[#HLI[#LX[[#Pen[#Tq*]#X'=]#]3O]#a?b]#eKt]#iW0^#mdB^#qpT^#u&h^##3$_#'?6_#+KH_#/WZ_#3dm_#7p)`#;&<`#?2N`#C>a`#E8<)#*YN1#'5n0#/SE1#+`sh#KV/a#OcAa#SoSa#W%ga#[1#b#`=5b#dIGb#hUYb#lblb#pn(c#t$;c#x0Mc#&=`c#*Irc#.U.d#2b@d#6nRd#:$fd#>0xd#B<4e#FHFe#JTXe#Nake#Rm'f#V#:f#Z/Lf#_;_f#cGqf#gS-g#k`?g#olQg#sxdg#w.wg#%;3h#)GEh#-SWh#1`jh#5l&i#9x8i#=.Ki#A:^i#EFpi#IR,j#M_>j#QkPj#Uwcj#Y-vj#^92k#bEDk#fQVk#j^ik#nj%l#rv7l#v,Jl#$9]l#(Eol#,Q+m#0^=m#4jOm#8vbm#<,um#@81n#DDCn#HPUn#L]hn#Pi$o#Tu6o#X+Io#]7[o#aCno#eO*p#i[<p#mhNp#qtap#u*tp##70q#'CBq#+OTq#/[gq#3h#r#7t5r#;*Hr#?6Zr#CBmr#GN)s#KZ;s#OgMs#Ss`s#W)ss#[5/t#`AAt#dMSt#hYft#lfxt#pr4u#t(Gu#x4Yu#'J1;$*M(v#.Y:v#2fLv#6r_v#:(rv#>4.w#B@@w#FLRw#JXew#Neww#Rq3x#V'Fx#Z3Xx#_?kx#cK'#$gW9#$kdK#$op^#$s&q#$w2-$$%??$$)KQ$$-Wd$$1dv$$5p2%$9&E%$=2W%$A>j%$EJ&&$IV8&$McJ&$Qo]&$U%p&$Y1,'$^=>'$bIP'$fUc'$jbu'$nn1($r$D($v0V($$=i($(I%)$,U7)$0bI)$4n[)$8$o)$<0+*$@<=*$DHO*$HTb*$Lat*$Pm0+$T#C+$X/U+$];h+$aG$,$eS6,$i`H,$mlZ,$qxm,$u.*-$#;<-$'GN-$+Sa-$/`s-$3l/.$7xA.$;.T.$?:g.$CF#/$GR5/$K_G/$OkY/$Swl/$W-)0$[9;0$`EM0$dQ`0$h^r0$lj.1$pv@1$t,S1$v&/P#xlk.#X#s4#mSl##WH4.#gAU/#Z#(/#gSq/#MDx1$*Q42$;UF.#C]F2$8@O*$4pb2$8&u2$t0;0$>8:3$BDL3$FP_3$J]q3$KM17#9o64$T%I4$X1[4$]=n4$aI*5$eU<5$ibN5$mna5$q$t5$u006$#=B6$'IT6$+Ug6$/b#7$3n57$7$H7$;0Z7$?<m7$CH)8$GT;8$f2>>#m9.5/9Mg%F<,KJ:^RB87WPs%OFT];$:(K;60?;2B-[P$BR9jU$%UqN$*8Fa$4/]P%DV7H%b#mN%8NTU%WLk*&DWI)&.g71&Fa,7&SHe<&gefA&l=-G&q;VK&**9Q&XhKb&'mRh&+t/m&AILr&,m,v&88b&'fl[-'76^2'<*R8''eU?'aA%H'8M`O'lf5V'N]T^'gfed'C/;k'):>J(A$e4(J_=:(m=d?(RBlB(9K$O(*ti[(3$,+)nZMw(F#(7)11Q_)u?ot)1T4u)m/cB*1[G7*f$ZZ*C4iK*q1Ku*VF7h*p&3l*Ex/u*J-?(+v,tA+kg'R+bSqv+k-Xe+s&_3,U6F2,Js0V,MfhC,/c:K,w?`S,tDf],q=cf,,3+q,=o-%--iU,-qW@5-01[@-D;-o-^-9^-Ft_0.N_ax-7uZ<.]GvG.5Lcn.l?pY.*?xx.Vkh,/LWI5/[Ih?/kjEI/&PHS/@gG_/mcnl/<,xt/D>m,01*3X0&?%T0V#)[05pGc0ePBj0O=-s0p/TB1FcB71S-w@1P29f15=Ou14>tm1K3<x1v[M-2E)`82rdH`2Cu,O2YclZ2PJ,(39JKj2hr3q2k+^B3Am_43YdS:3$%JE3jZxM3#>%X3hCi%4OUMh38_2p3oWd<4:n%.4Ijx64M+V[4Kt7I4^B.x4<9Am482G;57[%*56sip51;3e5E*Ho5^xf#6c_G,6O0Z46KRMl6VTMl6-;6@7%oU<7kdIE7`6Bn7k;?[7d%wd7a<T380lf#8RRo68Ct(H8rmYk8T#6W84Kt^8[mRe8.<D19k;ds8a6EI9(XtF9:s@M9Y&XY9&N%.:E-@t9`IQD:S5)5:V1&>:?[Jb:4$BN:Lt=Z:ivAj:.#O#;M+]2;DTw=;M-<I;jP#S;_r,[;t>5g;CnXr;O^A+<E018<HwDE<S^&N<A#'V<7r,%=xnIm<RGgr<QwXv<AS^?=Ga:)=V^8/=Y=43=UAg7=MkO;=G.Z[=Fs_D=_W8J=S1+N=.l.U=4,'Z=,q4_=w@tb=p8>g=S/n9>4Vu,>/os:>-'Y?>SKAF>sZ^_>O.Ml>4fY8?jFK$?+AG0?3dO;?%@v@?F7kF?hXIM?%3:W?<9J^?sA/f?'4Fj?P^3'@GX[.@9'xQ@-t5D@<QZL@D5]Y@>mD.AY3@*A:>6PACpt;Ada`AA-'6HAOB`TAVNM]A;8/fAZpg0B=Vg(B1-bJBl,+7BJ39CBSjpgBRaYWB#kN+C1ltvB+>mHC#?b3Cl%LWC,'wXCdt?aCHI(hCeQjuCxU+GDig:5DKU$ADa)bJDtI,%E&kd=E9lnUE`l<NEX<L`E/][qE`NE'F^kM2FW6h[F,87QFo?obFZM^gFEb)qFjb9<GsG3+GFId5GHTs>G8aaFGmC9OG>mJZGmW4gG/gLpGv_@#H/?C-H>GR6H1e'@H_19KHd[^oH8CXZH,9LdH?1'4InLG%I.79OIur]?IHHxJIu'FVI<^HaI.J</JUm;uII>N'J2A*/J$F08J1E6AJmS$IJ&4tRJ3QQ]J1SWfJ3X^oJ:8a#KKvi6Ks#xBKaeWNKfQBWKPmB`K?Ah-L,`_pKo$`xKNXY)Lv'90LMqW7L;6X?LgW7FL8'mLLpDvTL[XjfLep>pL%Cc@MtwQ2MhXS?Mb[-MMikxZM_=_hMCAmtM'Er*Nfma7N`KYDN7]OONE-7YNJVtcNqA^oN0,=(O>Y`6OUhvEO$n?qO'4abO^6<jOkuGtOfb)'PlM>1PQW_XP0I?IPp'JrPlbBdPU.26QMi*(QFYPPQEuECQ+i5XQT<&cQQ2pkQN7vtQL0s'RK2#1RSbi:RmGuDRoCrMRK72UR'o5]RYk^dR#WlhR-vCiR8D%jRDi[jRN14kRZUkkRg$LlR/d84Spe.rRY&RuRL[M#SFf3(SYDY-SMK;>SiBmaS1_bSS*iGXSf3QaSFof0TT(t$T[E#9T,2sfT0:['U6Df$UsCuHUo0M6Uh%PdU]t:QUl5_TU5#(xUw%SvUBjrBV/6F4V%K=<V@85pVUt_iVD@>pV@8_tV?62#W<1eBWV-7JWUpLmWr0psW)+w>XUbh*X7R(2X9vnVX=0u#.&URC*^JHw`GO44$j0un.cxFo.,0sI:?P5FsS8^:%r5Kf'QhPQs4KfNIZFuq-<hjh'-O+F)l((Jsq/Bnf)qh<dP0ig$Sgjm)B?h8&k#Ops]3#N#9nr]b$LPYYgd*u-$Kb/*UP9EsD4GPsS<EDsR2N;6$LrCsfZsDsCf-w#PjRI:l]HctKHEDsc4`_tR`Ys-alllL@S)JsF7r5/I9oHs+#TkLbiYs-<DXgL7I[Fsc4YUZMV;Q0XHpu$a9:]sGILxL0iKF&tRU:s/6ew#G*H[O:cLL0anv$0w_W;MlM`mO3'xObN[pX_BHda%v[;p@j@3^B`wxt#IlZ8%1kT7Cl?pktin]%Q6mIWMCrCxKG4h2N7W@fOXZ=sTim^Z$D)N+Kstt]tIB%u,$i#*fUrsl%9J>PLsvCPswDPYqbrhgK4cdYqdQC^smx>4&#7PfaE)M[X#v.-)g0Z.(U5gU.p$bw'3(tAFisM=,&2Ohq>rEW.M&H^,wF*l-hII*r%qKt,uNN7/Xo04/077v5kd[[sX,?Ys.#eb)B<KI(Q*1Re/2>_t#m2w.u(89^K.w^%WX=pC9`qkth2h)k9:V^O#DWId]WBh%b8::5+;pktWA>lL$]se+V_d:-CE5f(R*B>c=?RoO3dvb:8[$],H]Xj)`*)YKE8=FZo8kOXoQq9W[pbiHS]<4u_1Hn]c<*fF9^IfO2:t[^u/?TXWIDN';rpVoZ@_5%mQR^tQ7gCIK56.(:S42t@Jbdt,dC%48h`fO`C0vt9=3Y#9pil$@H$Kshv277m9VmhPYZYs>Ukk4>Q80Mx:;UsWfVRs.9nt5b<CV%D<5a$<tfstd]oO8-Eev7Xv>_-mN6`$&_0^sG'HR@1e9.t@LrCsm8dw)l[1'<DxGL0DMt&>88*Ds6,=it=e@_Od:oHsoxQYs_,i)bO'P%;$oZ4&=dtTsBq@_O<Ijh'_4YX#5$aU$6<l:tm6-xOl?7Gs,s_RsMe_Rs)$T@Ogs9N't+6f1LpYucF.,Ds.-dR/CPaLBr&og`G*]c`]<I=-V-,FM9OQQst2$9/jZVX,eBbjLfd_.tu;T-7x0Lk)%H'VHZZVRs+T)d$m.TQsBo=Qst%UUsQxkwL^KwcXsXC_t3U7l8Rp[e:.f-KsK=^X8O/'c;MQKctwC]b,:C-Fs@x(u#TR.pt8F%`tKNJu#+gINsVkQ],VH?uLA.F'MnD9vL^<:.(.x>bs`NW9%dbr9]O$9og`LVgt.CsktrB:iO%%)[KmWD$tjuqd-B=n92v%r9t/M/+0E'g@_Z?hUi_h`hOx1n#7w'RktAw_fsdQ6(W-<vNsa6`sOM?0+)9%5`*7aP]O9A3qB*Vki%22tlrfdwq$.QaDsnp0.(fEo-UdZTI2e&`L='n%F0FwJ@_%#Kc%h[]^8BOZgt&v.a-82$Un#o6eK[e#iEA6ucOdaG*YX-0Z$MkOoGK-VRs)fRL'<M[X,fIfJb1Zw,)%(%J[<$(j%rOb>dR@+wpS.GPs>-*U-K-*U-9RCx2#<,FVk`ZctoSZ[bGU#J6pDQ?p'e0.(9eiJ2)]JHs;lXFD($A_tiVh?%Sw`WI2HZ[+qV3`sgk5Z%&PPuq-l8f?VhQe%;'+htMPle$V7p,K'`]DswXC9fmqTU-C3a7.UVqLGU:pb%u;DGs9*vP2+5:aO&u#vXW5%g$wv/0RR3jq/47w82D?W::N>/F-Y)_w/H5u>#*%KEs[ph_%a:+Rn^Ot0j@w$.:4<__*e02Gsm8autS>[eOgMXRD`GW@rjsJ:`7<OKYO5HMn,Ro&:?pEc%Zdbbt+Mx'-*>Pj)F^vXWPbcDjf?*=8J7C].o,%(M4ja-IGB[X#dus?t;-hIL3KtQ%+&G@kPMoC8#gTj(^;+O0F?@,<n*0T%)aKh^#4<=,HxR[s;v0.v`'UG=$)ork^jIJ1CxP:v1*:)vxQav:mwB6vwHxG?T09J`ae98.o;:>#+^6pLvdVm1t<YDs`X08eagsY-5aXZ,hUxI_rm8>#_-A.vQ;w@8`tG0)-bGxkQI#-)cZ-S[wWV:vNP%6vgLgX6DCMp+scDF4#r#m%E_rn%=fH],MhAbai4RcVI5`hL-^M(aN%=>#f9?6v_SUb/jn4p8qB/v05Mql%WpWG]Xr3V:-:m.j67X:vQoh#v3%e[WKn<9Y.UwRn%d6vu*smsLR4gh?+$,_JEm@8:ZOg@kiZ;>#SR?qMwwHIGsdMxb%LPg:m%b99-1''M[Ppu,Er?tLH,`#vw:I4*rSKC,YhDA+4i0^mt?D]/=W9OJv3#>Yf/k0T&)F`s,WB(*H9=JsCDNdt#wlA4SPe@+=-&HsDo)qO:_djZax.s7>0rI?p>3rEU?U13e26?fJ=Kc%QA`[s'Ax'-^ZWx)'Da;KL@Ng:,m<ahX4cGpYt>#-/YvaLB8ht>69gT.8(;m/RI.+%[v=W6#E,+2v5^b2VtYX,?q*o/Vvo7jl7dR/]WAds3O1%*Q6F4J/Q#+Dj'ZRsNg(ZsfZ(Zshw($YD[;7%e5$hc`:NeU3Wj`sesv8%qWIXGg%+gL_Bf8%'OQwLZ3&_OIw^0guY.1g(&pkt63dNsqggq$>NRQsAk5NsWrkn.OD.`*Q(jZsm7/ws6ACs)#7mSf0=KG3f^K;:GS/ptD7R4ZvZ[qO]QgnGP_5iGms)'J)<J2L%icV%hdv]ORSrgdmrH@`eYH=qkS#3u&`$Un4$*G]QK)ACo&J:CQN8@]ep)x+bP_jonm5]s-f_EIB9T*)q>>2p@Zt3J'+)Gsj+Kua*VNq))DSwVV0x,)=)r*AE_2rOf]freK]8:-LgoI1S`OL^m)ZeOVrT<7%Gjv8:x0V29%fCmGEge(oP3[fw-<(f(M_Mcl$lQ%&4^oL_)+iBaHpEs35t*DQPfGj7deUbVq=Efnp#EE2[S]t0AWc6rHd3D0QE5-3ux?%5SY,)l&k/X]u'hO*S370>a>%-I;8m.Pa8`tltkr)'TjMn'.H.Z,_(b%s)4^Ft&W&AW8s1DTYmP'H6GPse?W`sM[DVQ/ak&F*,ZO0vPpoOq#GU?2Ao/1d$Cg(I%KEsD5.k977-bsc`FRR+8/-)Jq-^tclC.)2nnAk?:B.)_lQN'6_K@%`E5.(r]7br*mQN'C50X:I3dNsFQn?9kSRfLKYaU6ilQI2)WWDs-;G:&+-8rDH9%$$GEP:&K)G'S5'-[Ka`*15DUJX><QUF3*CJ,*x&?Gsxer=-J12iL`FTI((nkiqa#j0,W(f34U2Sk+7'Q8MiVHtl;Fpdst0Lk)muP^tuH(2t(i%Y-7N_t(d$Yt(A_ZQs$2lOI>fOwL4/9:-oa(;&8Y:C/KRaRKRa][s.3NPAbf.%5JGCT5j6kS9Vl;*eFks]5diulKsaYcsuI<3M]+elLXopcNOAb<utRe>6GL/B-@w@C<<XGesG.wl)BI@kt03i;&q8d-IS)P6aOJG6jP65.(w()k(,N;Os#;r;&<t,gDR^Y-?h3nD8ce'iBc3nL0<2A+D[$R10$1/Dk=URnbV<ia22&IWnIb)>Wsfal%DNDu,GF'iB<@I`%HqK]l3bj#-;-J'A7&Sg1qLBVo>BBCIFm<gO(obD48Akn.XP5hofbfP'ZBXvLg'4?1VJ.<&CO>+D=PRN'PUtJ-OdJN-8^^0/@AUqm&eH$gBfM'M2%RhK%G9[Qj:un8]G2eLPJTwkDQZ&MJxjZs&[hBs__R<&[.#32_6)B5H_$J:pDWRs;Qjdt]f4l85YZ=>Ii)N'[UhF.O]RN';p3n/NZ-.CB`RN'20d<-tvOC.rJvmS]5#<-D,Xa%rfRN'-@L=PIi[bMd_dEjPlUIUtZJ$l'mPo)sZ/IU:ah,)aZ%)tL>J$l94vq$5KP:?`bkj)/rN+M`,okt9SSe$YE//Vk.6m'QE//VW0L`tRbFGsWU5I6dk[`tc;KQtx_Up0]i4Qsw6DZsvL.FM3[=_5,88';Rg%G14=*N'QH0wL(p7d)(s)1BNa(9.2'QjsuuUG#X&%)$WHk3oEiRN'[&b);.bF-lctX'XjR#.:e3NM`KsA7%o,P#l;F0-)ZsRN'L$Od:I-=lpqPLs(cS+?-lEZp/&Tl,*KYwH`?9Hp/-3RDsA*qc)8*rE3_LsQ/S6n6eeeZVsc39@4^rHC=6u6R*Uqh'8$vj[+.x8d6i]'>&OC3^eMpFoLSi:>&5F'$pN7][saQvCs@)=ICI9CYe&rB>&lsJ431BEm)9vP^t'>clsHJLI1.du)M_#W#tP'U>&6-TIU&@_qoRUadL@X3XC=62kXq6;48V.]X?2qo5@lOSwsbVS.(CL9:@4f)W@,(4rLASYLqI&sA#l0+R-secw.I=k[+$fk?B*V9O+%Ttoil)1baYu*]+ko?I2,h:R[_'1-)LfBl)Ln0W.Ogm>tadx>-]M6T/V.el)D0v^=_0PGsp;GhLwbs#Tr[V[=we8]X(_Q?&Ys#qL5fIaL7,$9IRbC$$@r)&*AQ9Es7k?x-FOL'8S<$j:).+N0wLIws'pm?&0U=qL)Q*@&Fw`'/,,8BNc(l<3Hx(4SAG0.Db`hZD-*Q$EB=^%8wi;Gs>>).0.>++ET2m?$RU9S/f1FPs[b:XcX_^?TaASPs*Ru]sthqs)J8)62LG/.(jD7ug_.<noo-p^FZf*s[1]HX1A-UwsB<;p)Zj9>XEW,]kTp[,)>#4ciFJ6>#+:x0v3D*Iq6F7@#93f:dmLIc%oxD[.h0rO/@Iln.k:ml/[K=uLE>j+rFIJ#cXMjv5Xb<>#N4tX%kL'j]<Ts9%0.snI5x$wulTs?r;Kv20aj/0v-k?(8G,$+qU(I(sSAW:vYResO1=%Kb,M<nouf'DqdYtr-V%Dh>fxu9s):F'*?0LG)3Wr<1wFhk%)<kPVI<BIrP7@qe@J0U[[R8_1+eAnfbB0U[rT)N'S5[p0+p0Hs2-(7@@j8A&?cPPL^(5eoSS`t(&tJF2QoAA&Y2<9rJ.jqHo'6Yst[NLsKnEWs[9vwG-JhGHo*ujH5^*jLG2IDIxdGtLwZQ+)Vn]]tkVWDsgM4`O0x6rHfrGf$hl)nM<J3ILcXntH6mjfMf1tuLUvpA&YN:+M.tlDI+%d<-xHcw0J6Z^s#84J_enjqI=co/17E<<qDUg^sIdvCs6k2DsS4Jq)F;pD3N<$nOaOv]kAX0;FYg-Ndw,SqO0N+U%R<&Q]L0We%1I]]tx1Zu7$cYV%(ag=:RBKPL1uUDjF(vgONsV<%uZrak8W`mJbs%+iYI(K#MU?e1'mPo)4M2.(>F8N's@%cI;;C9$)(Aq)PisulSZ=jOg`D^4YJUbYJ6=3<*hdfOaL+U%[uOjBP*:a%@q=Ds(ifbhvUYV%stOCfQZu0SbA[v5[rJpOCcFQ%pEv>>6B(P&I_hWHsYpk&dO-h((8<Ds#)U,).F#Fs2xc$GelJLs'jokt3=?jt]h>Z%I?Wd$#r3&goOv,)%_E1cbL_RsM#9TseERk%qh@h$%^1_8n?`Hd6Zt#u#-*DspVOg&=76Sswl5w)><Z,)1M+lSeoGf$Fwco)r8*kEVQidYLs(QYLTs8F_4iP'vbDUH_b_*iU=3ba?^XdpqN-@O/1;_togvQ1Y-1aOh<s=4@Jt]t;tp,)RGa9%N*&,SaTwJU,nulI$'`0_Z5x3Nmr6N9kVtq-5DYcp$fK1Y1w:b%2SiFoRXtYGo[<BB,b^00m,9oOb-klreEVX#a)51'U>1jra1hW-]c8wtx>KMsDJ&lSPlX]W&+C[,+pM:NFkZ/UjFf5IcF&[S[ibgO0GP^t>XG1B]/6]-VgWnLFN$C#HI_X#(A#FsF9oHsD8=7.LR[[G,'%mFs^:lFIYsa%H`'i2jd'jKk:6iO9p_s-+NemF($i[mp4Lo$#Z%VN0M4oODh`bS()x[m$;Fo$tmxuL_^BdOtpkCK>g$uk<*]]t]mtj)OQ/@A^6v<BTN)&_D^AD^D@uXVA=5<cK-7RR,'irZm&&FsSm<ttif#D/LO1lOMO8I$V<Dt.<u0lOelt`Ot'@+M(@Pl$)g[vt>;8IC_$P%+&MXatrfrGs*VBdOB(,48aa=Isf.f=%>S$@b>2gkLS*Ys2U-WQL?OK&pSmA7%Q9sn%.WDOsEFJCoAq8dX2sYg$`@;uSNO9x^_?eqOHmZ]L`sg>YeD/wS:>]fOHB_15p/-aO7@HbZARkcHZDOgOb_1rhu+v`K#Dw,d#,UhOl&*.?1fJu:p-%e%4I;8eM8FddDf@_OD5aUr9Q^D[$ud:Wd=9x^$XMoXN#dESQ,Od%c>Le6,.Ce6f`ZaI4xs>Gb:/<ThNFb.'-S^tl;tTsb<#Ys<*4101oubsAK6?&RFB7Atdn3S6xUBiS(XZja_'TlFc,o%$,)Zs5[:(E_X>r->Jo'E__ln.;Sk$F,==X(s.U@FsY4L#dkx@lOCmt5KE3L#(I&JsTZS]tWV?ctE*T`t@dQctK6YX5cQpHO&g2#`M`9oOrp#=M^<>1PD,1^XFl9mVN9)eOveYQ8hGP^t8*KJsO9,sOuF8WWkc3m$SD]VLXDYp75lT6-qG0qsE^JwapkXo[xcefh-X]tsZDq+C/RciCL(bgGK_rg?l`uu_<0Ic%S<<0>ww%f$T`omD5XZ1>B@DrOB(Z*SXh,TRGGNf$qm67JiHTREsp6iGw4fnOaI9E]^)=OQUL5msa1*m)?GM7@sqL5/HrU10EKl*MK=qxt3bP7*DWokthtlhLur$N'5)XTsj,5IU7mal];X;_t;PFitI#KEsu/0u]@,^,NkPUYs^6sZa_cL`WFqdCqO@86$(oCOSa&_btOwJ%4V<a7%(c%T%Xx;7%i^OIsK3*)s`IQP9-Gkw5jYl^t>OkZsn(dajS+TEsGWPct>cSEbavcHYH4tL'wWM.ow04_1mWWOri-cWVftIh%,X++EI9je,%lL1%_dD-HcxMd%cQj[rF_<[bKw&=cvNTN'XS=@Fv$5V#bNG:l<_@)t@rJ[UNtT`IO'$AJSvO[U*5/Gs(3Skgp5R99NgZW82enGgJ,1q,n@%=sHGXX#t-D:$5x%%48'aqQ=I47eAmA_tMb$E-%nK4AtJ$4Aj9?wt0*9B%`3.Ssl2QbMl*-@F*2M;t7ij_TG[:pO'(jEJG9[1>aYWN;qNFbVgm/:%<tqI[^(aNY@WK1YCT>1a-DOgO*DZdGn3dXPxbb@jp;k()P1386^mC^s[4Ne)Ax0N69$&VD.sDa%=A$gL9BiYR[>L#Y#iffGBR)*-*n2/%)'tMZQI9`I=1KGEo>/KHkKe+6m4/EeiTC4kbA*pOUx1<E5[%e%Zx74YHE,UD$40T%/[sDs'ZQO&AiRRJj>GSLtv_ls?VGwcrER_<KF`0_/4WkJfE<lt%uWLsT9SE%n,dXMQQ<rOxX/WWThnVU-L8lOGOW.(-f;Cs[VL?DC%N6E$Qm5LEJmP'57Hfpu,V*r5X/.(UbCI4Vg?CEMbjotZd0JsuHlne=jQ@+?Q6iLE+UsJ*Im]t,%#dtu_Q^t<.6VsogcYsqDkn.Zl(o/nx5=ljO]BiuH:VZHt$c;gTTN'.@/.(QfB6t%(t(9t.tkt,T_6N5XWM:igP^tq:L[cBNLS##Pkh0F*n$=.dq9n6Q]ioI*i31mBvN1;If8-$%EDau-#G>R,.&@'aGUbbE74-Y=7ssmZPB&?XHL0Md:+Mf7TU-i/2GsTFs-$+2%N'W2d-I.1Yk]a6OR.l+n'lNnH4/:$i5fYcekKY4F]sJo7Ksi0e[j`:)Lsm;3jT=U;_t%)7N'^Wwqixbj[sl3R]->po1505eKs.qs_T7#us%DNvJ2xG3</b7-QYc21]U@o=oO.xAX=bRVW-1O?hP97=@lM.EL8.Eues(,h?u^U(CjoJVx[c+kfO:7+_IT<X;8irp4LL<)#KMA4c693)_tqTYqDErqsCBUlCA2;(=%ExccKv=vtO^:cRj'47FZ,5T)WH_YoOUaL/uRbgh9hZn`O]5xI:pDE6.Imk*PrUE(7<8>7%P&87.Od5.([ge`tTpm-)NhWo)nCK-:2vUxl=?uEf1M?Ns:8eLE-BefOFKYiWR>5oW6*AZU$bvNSw[cV%ldv]OPINp;/in@@>CxC/_a<ps=RS0qmp7:CRTA@]4wvF]RT;AC@H^O&&/nt>*N;OsI52.18xqh:_XgUuhQk=&P*>s%wvKGN;r<Gs$=$t.DxUbruvAa/BopCsstK3$p-Rb`jl0^tJ;P=RJJmdp8)4GIHGXDsSMrh)+kEI)NJJ$l8?Kc2871gi<`oCs.0U-%.6)+M0cv8.5tK+MCU#Vf:vCT#-UjJf?,*[t=4,.MGo7'*,M).h9]*9.m=^RsJ9aU$U=EDsZ5u>#vRa_*tOmVs-7DC&0GGg):+npe`N,T%sT#r$BM#r$EE5.(+Z9C)##awt79SjObE+<T==T^$8B:-Jn]#tO9e2r`qjTrT/#7vuMW_+ZurY[-G75>#u)86v.QsWW-r3&[Ltkf(%Y=>#.BF*vLOInV8<aX#fR`O34fFc%W-6tnee57.ZP<7.$do[g.fe^%$VhV%Bq.t3/epkt8e*Y,qSoktp#U:v8`A2vn^M(m.us,6_7e(W`^W:v/3fo%imW:v<Kl&vGfpQB-/Q2bUrn`%nWlgGac:x&nGmt>dJ6.(_a-5):>5'tH(+=&L2WCN<;7+3DupgLDxSfLau(Us4&h$F.aKs-8r1^Q69^3ML^@NsN<qEsr@mw)Bf5%.@l8%Q+?hXsviD60QY_pfm-(+*xh(^dP3I*.b)d9MYfE/%?%tQW;*5=>JB0.(tE2CE:T^>dX6MC4'k`,MP;Y$M)RW2MRM:[Mmki<deY^1PsLZn(L8SptLIo>-:?ZH.)/ZILuLXfid:2??VRbOsel,bRPs=ROI$Ert`L*@0rBgdOj93@=H4eKs9'$%+J(r[ek3-msp*ok=HofcNb;#68MtL5guca<uL6f2(_P7dkR+cjLX;2rt6q%q)qSdT%Uslt>4E5.(_qjLsP.[w#>-0em?h=n),Aq58Qt'%0/IHiLKF5gL$guBa&LhDFZ:%^0e^Kk=t7Lh^voO?-=Lj6.%83GQe&_d8VlBwKf<OOMHS>WOdE&stu,%x-)M/0MHf7Vs<*410/S)E-<>Lt%PLk/OnwJKsV?oq)CphC*<eoC*V(j*MfB3mLa;iC*#rls-F($.MC9xu-LutgL1xaxHT/'r$_i$FNo<'osiwE'*KC(11m4+@O5W2-)9/1.q6Z2-)_'Vu82:OZsCtuYs@56=>_<nw#r*7F`^B>QJYZ<49+.6)kZ0[$MZ7=[Xhh)TJ4Mc+;<?%j:X^/jUE9;<M$,F0t*olB&=&bGO:fsZsHm&UD7]T6ssFje(;e_wO2E,0)Gox=u``Gb=]+tNh&QaEsC>,ft-kd-)Rt(UMK3j<dB+P=PCcRN'U5GPss6[a$er,K#&%KEsvAww#)1Lk)M'b$'>eY8TX>LJsuol$FYsM19_RB`twGf]t,L+6%E]DO4/,-_/?,.N'j'b);r8F]sUDdYsr17.(V)Ku?&XNmAxqpUs]5okt_W#IO8G<oE-=CeOXBb<TUHQsH';T(Ki&gsOEGqhl<8mtO3$E+;htIh%<V#c[W5,pO.t=l770+at:wtdt=*T:H>3/:H;sw0SK,gTFmGLx98#?`/rDqD&d%<*nKq4.($<t@R2c[$6'^Pnne-[,i,R>.)0r$.%c]be=TwVU2%R4=>pW$x-bs]kLU/?B&a:A7uPK>W2#^EhLH=YLs6;5U2edmxs%W-tL$x31'+.=W2d..WfT`$]-lsOq2[-IQs(Yam)Rvkw5(OoDsNfn&*DPJ6NKco:L)]#j_2(-REA=.10CUA02R))D5XnT#t*h7D&aJI.)q`5?&lpMQsc0E)>ut.G7>QG/f/$BZ.gvD,gll5Z%QEIQsxeGo)0gc,>To)Kbq*KTbqxoS_jBhc/.B2-)9n<7uXPK_-D,qNO?#[ULCu1#lrL;))u$KEsNYrk&kumRs^eV[%-cJhp_n@D&*iKu)hE5>#X:14lR:SN'bK+Wis7ViKiwUfoGn4R3g%7C)-_`otkI%0-8Fk5oisef1'[nuu7k@,c@*/>Gx2VY5cJ:>#60h%v'`cHl8&G/_FrsCn0$%XC)DFc%LN&2n8x?]rGHE+[tQ1b%'d<vG@ZO93p]NcOLsokt2#U:vgJQ9vGdk7<McqtiQHFVH45S:v;Xh[9D`^/`jw/PSh=-'Q0=h[%Q&mt>S3fHsHUtkM1DJ_s_IR&*x=j4u6qx;'@4nH3H(5=>okd-):hInLW8?B&<e/f)w5dBtPCq`&RGfj:0a&Es?(]rMN68_s&M[&*0QkTu[fq@-dj(P1fN,k(frB69i#vFs#l?nE9v,o%UFw5/'9nDs-':5MU%C<P(qpX>m&@Mh;K82Uqrwv-ko?I2/Gb<hd`)/8w)%i$W=clsa+n*.K>g*.')l*.Gl<hcQ_$&2ZMk+.qaPqI4'G5Bc=$sI=rv/)+5ZILuLXfiu_-b=X_tOsl`0105b6wL`d7'0eM6?&74#V6)EwW%*i^Zp?66^sRij._1@H[FrY*DsgWn&*&0wjt3U4%AoFQU_AYm=`dlr'st^0]l<wmx,m*Cc`i[U:vu'o&vO.qWGh`GtNvp_f:L$8vu?H;vL8$R#63Qp&e-wF,I$WxI_jQsuu0Dvs;B6F]upLb7eLN;>#%0H*MFwKs/?kOJ(i=`,D]55>#*V/3v6BGLKM<;s@QmhFri^8>#+n66vhEuFut`CfUl(U:v3bdo]?w#5JnU:>#xhopL_x2`FE8%Vm4B-O=[2]^55;_X4?OSM'xKX:vab24G(eC5F$%a=,KGb=,M+Z%3W?c]>SJ<JiKJc;-=Ox^$[GXDs;?bp:3-xablv7f:hB1-)LG1-)2V_d%a)mt>2?5.(r(<ia&)F`sqL[&*M@@0u2R<+&WCp]s1mNC/E^5=><iXZ-vN%C/=tj#GPMPD/#^EhLe.(PscZ3.(tuWX,GC01Lp5HN[E8:A0-xKhY@+=Gs14Cw-v_AoMJ$cjL-bJ+gFYmu1w?310swYg;b@wYsZQ5U2Wr+480-bh*4o#Og3N>tN6o`s['1>We5ZPYs'SYtPZf`G)$G@wsw.fD&BrS48-KJxtlZ?8%p9$cDCvbQ'K'b);IwISo[CL,Mk'bRsc(5:RevJHs;_wD&Oh@i0/#3-)GiQ`H%iWZsM'6YsJR3=>U^a73wTZ$tw(+=&8,&,umuJA&BcnrLT]FGQTdASsVght1H'Tt1d0e*.X.<oIQd%j:%U7a=`-4QMsNwq7:^t]YR4NCRFi&[sB5v69PNUA5eL[,*ZE8H+Lk*ot,wa?Mg@]qLZoMxL.5Ec>G)(kbLK?OAkE-Dshvu%0urjXPtHTN'moc]53RK]sLB*7IchcYsBG]Ps'uQ_<;V>_tlr?qLs-@GXOYwJYE,Jc%pL?lnDD-:?1th%221L%B;Ysa%CD,FjdB8f(%_WtAs9QhO8a$#TxtWI%LbQ.RkxBN'_a>$^64C^s<*410@$t,O[CrC*s)Uq;*#r6pSPEO8.=1Dsa[hs)5LrU6pWYF#plIu%xJm*)sx8e;Y4mnLd?:`l8_[w0e6tWsmd9.:em0H2VYoi'bmS:va.N`oEI^'a.0+p8+)0_,^8prJ-uu,)aZ][$sUnbT(uruOVd+P4dSn:&8B@gg_qRU-k4MRSDi0fu$b%I-*dh;@HJj;7-&3jLh<o$=%?D.)j7p?0^sRN'`w7KmW#q2N.bBis)ALv#_i=o.qk%WskoNAUf,k5tYk7_OSt$J:/15(fRkIeU]A>r6w+mN=)=5XK_D,iOi(0*ZZrV=_.Fq`SkV@/lSho7Mrmu#TeS-xOR[[O0?GB0Mw%EO^bYwg1$[JAXcl&RfT.#vAg^4-8pcT.v'UR10r,Ejt,#l9[X2i6?-.6>##3>aOF/W0VJQSM'k<:>#mJm1v2lBOj_Lg?LFv,6/&-%J6E(opUc.E6.hP+#M=OCEsN?.[BB8cg='<9S%]t/=>whV8t$P>B&QVG=l*mQN'F$=m8k;srR%(O;7Jh*T.ox.q)w#BK3pomVsTlKh^7Ao1t*olB&[+TIhf45k:C?5.(;ZT?)1mJP8%a(pfk[LiOc?08%ZYGFsL2(r$i*:7AY7':u6CK?.U`^B#R?NMU5fNGs6&@#M:/)bt'f'(/'UFE&$(hsM:0EjLIVBnfbF2@Bfm7*bI*V3g@o&Ps$L7.(]t&Z6d^Pw.SGc_<ICIB@Xw/;%L)mt>%--d$2A3.(P-^/)cVGbs3ZOE&M[6uuA6xg)9ZTx@QU.aF3O'e;qiDCAv/<)iQ)d1)9</ts:m#pOrqR'Kc>uF%F62:LI^-t$hbQidC6I[FA:Qhhk_nctur+48gM$RV(L,^@Q-NL`kAAW`e#5OKAjFtOjgid]*%Xp$vO5$5+,]3g*?_MsZ<qEsE[hs)N=$Unu6$)*brWF&wJm*)086[b@VYTpJlX`s`1L<.I[leh$)1OB>Y9/`pcW<0F1vq$mjJs-;2:&P&LS>MU2C8%80LmhnVG&us*GD'>8UAcr<TfLEQrUsZatBal[d;-0pUp$2P-<-Zi.jLFf`UsR*5.(_)kpsPK6?&n6fcP2BqhTOnVpBLW*L>q0aU$[/4FsiRXOO^'?<BnQU21XiEAU$a]]tI39MsA5,H2SG+IsPlxxt&&qT7>_0]sM7VP%XHPI(@P./h'?#97vHh3]GJK'%6r_qa]WBvc@CQ&-6MEm)%+R1G:k'j%f^l0%rG@&mceuR.MgS]t=Noktc[[Hs0xJZKF4/JG8,&`Yj6M``1,b(S10ec%8XrPA(XHh>A[G2rn<*7%^Am20'UFE&FPU.13qCpTT64Ws/d>X-Br:[0BhNh:503GsY-bW-4*o^-vgDxL2tbs%fTqb3s0]<-`<Z91P._<H0oaNs^/?Ys$R=g$kN.19cI]X?3wx5@)L4.Bbk+5pW3Ab'f0?ggGpmVsjhT-M:O1=8+YlSJ1*NVDgXD_/<np/1RYN7.B)3-)*$[ktD9/F-r7/F-jO/F-MOXw8AwXlpY:cv[UkI#Q#1@b:QLB/`tJsxL84nYs;FKv)kZob-ImksDCPZVsRe&r$G]`T.Z@pq-#OH=0dSTv)e3.(Wi=18Ej.nt>ws$giWh,WM7S>xsS=ojLZ+.Y8fr$ni$cNZs8$)Zs*BJh^2Nv91:9Sb`fGoDsg2Jq)M/]:&SS:j(?YRq$r,LpL?xgRJHtD_/@.>]sa=/#*;Q9Es)46[$R(q]jAk=:$iQ7U1l.nusOLcat%V<gLbRmj)o+(]jNog`5nkeLTjc$[do+wqdh>9LT,tQm._7hmV6J(@Mv40('$wwRU:Jdp%9m&nfSdgp.BoC1KD'9EdQ;hs._YH-)S?>@[MrbjL>U4oPJ[aSAbRe5pE@TPs#.eqLf=EXI,Wg8.nhgF;C6Ge-ZeHe-uBRw9>.Cls+J5B&i.*)M1xEB-mI=O%<Yb's4Ws8[U6Q+7v3wTM?7'.tYw7>-MV.JM6wL]$^F(2t8V?R8KqLxLTM9[sL3>O^3%AnPqrU.(ic?.%CXXw-OsU*MjcG7.?F410r0[U$5[LHcF>8_sIDKv)?[qBu*vkHrUOJj0pa]1'(F-^Oue6UCBuV>-q]%#%:;:Ac79C&,X7vK2Z:&+M_'1-)k,^IOb-p+MN.*vsk-UHmx7XgL2.vLMH:*Zs=bx(M&c%rs5vn_4W4#itaK]CMOg5atJ3?C<m]K;CZ&Jp&fKEt_&geh(jN3t_wogfVdQBp.rb6l/k]>eHJa<.=&HV`tY4Q91Is`Vhp,aEsj7SptoDvd.5Amw)96ZH.m)dReDh.Q'R^MtC2[vIM:FIq$Bv?I2Bcn/1'[Hd)M-tp[Sakt>gIfV3/EZUs4x+]sA?1s)$UkHr3sUJ:hL*T.b7RN'TQ+kL3Mo3SAG;p$$gUt12;=UZMeBdsKsj4oqK94Bh,?QBFu?RVjlP*lV)_#$[TB_W>Z.htEJJPsLXVD%_HN:H##pkt=G[Ss_abit9F)dD8[3Nh?2U-`T?U77YjR/`j2QRJukUj1PXg[5XnZ,MJmx#M&@<2MoQt8tr7-T/g>qc)1jtW6:ZBBcFQ%FiwW)Zs5wX9V&L.L^2)X&G[QXC3Cah'/Gmn>t(UGwcR`*]+K7T>QK($(/AB*19mjet:BQ8[9%^ht>x@B_-GGKt:]Z4.1FT'T.MN(Rs=Ww615g%x=i]PEIaA6.(QY=Z-R6RF.1D0fCgKuGsF4fHs@*WfLP?tt,E1G`s(@J#*8M.7nL;+@9N[^Zp2nd*.O[)K#-;2;e5`<GsvYFv-Al&8MYW54M:vqNIk=7.(0m.1t6+T.(nKh87kOw#ZMJ;4],b>uL=8u$kUX[6KLPQiAo;kL:+Pe_W,/_o-s(Rn3P;W>tx3okt&xNs^/NKnO#vhD3^@HF)JD<mOLt;p$28,%K3U/jdaibh9`G,Wp)5ZRsRB9EsUF(2t[KQZs.ClK./fDufjvUHsQ<dw)5EiqmRkG=6II8V%qLWZsQ?ZYsqp4=>lkd-)5wYjsRP>B&MP6=>KU-.DSa=YD<q#gDEKu=8uJe0>>hvq-f9xK>Ipo]tmYOE&XI[C3Q8`b.F<)ks#'<Rs=KCh>qUp6[[x$0)ZQRws[.HD-w*HD-Dwu1Ng:^3MCiIVs_8b0>d`F2t'UFE&iSZILq/*j:'CJs@b9FQM]T[/;0/9vd(pO(<Oiwlg=vb<L?Ju6RtMLs(+?:vY*p$4Am;#^cwn8XY0V98SiB]^c'ufn/gXE+)ea&nj1R.i9o.5Zkc3iZs?#Ms(NF5bsNrjX%H)Zwkw7mLO4.;/)ZA7iGY_1d%r_W>0c.Z,)(mD^];QIc%H+)Ws?^ZX5;9onOrQobJ;%XCl%e&S<f[Njt[Ot,)qq)v3-^Z+;E:1lOv^Kk4m^F/_uthpO?[acOMZ>(-L2<r6f,%HhE-TEsMe4sLDBVEscXH-)Ix_vstn59QJPD`t[_19L<#^9M1?<rMD(Cd%p_jY0EcNb.VYbsNvBPh3ZfqhoC[^J%4:PO/@:hlBb'Nh5ks)34^@bbOpKJPsCtZRs2ATxVEDfnO4lbP;i]L]r4E5.(,*b_hXP$Q/SI5B&.r8r6';T^4NDp]sImx]rC?5.(rO%fJf/gn/E1w<c[(%0)u($Cuc$*^%m:^TgsP,4MCt_.t%O=E&'.@p((92].coINI]@l4%04U>tfjkv-SI4)Q>+oVsYhpTVaP6=>,4^.XsB?X.>;5F`&*2-)AD)ot>`GW-U1w.t0W)E--K6a$ii@O4HZ6O44RJH8gWkO4C2P4V[iuBaNv,=&[jLF)=0oT`g8j**WqWb,Cv7YI.HVgt]wn`t*o,NsWX`Gs^x:(EwL,Fs83m[sJ`G+DlJ[O;M33#-l#b_LuGv]sYaE:$8'b))>irfMYx.T%/;,3t_PZwupX&x>?B@rm).:>#oL.wui8mddYYUfsrIPY#R;X4;g'O^,=B]EBo$+w6B-wwuELl;#-YF<k]A;ighZw,)XXT:vjrw*vP3f&M-6vGa1]<>#DKq%vKLX^N6sI+2Iw/f1^=GN/giYxub]Z^GDkNS7Km,F.>W=:vGPJ2Lh?M/`Z*KbEZ#X31C<T:vU@r$vu%M(M`8n4eD(5>>T4TFe+c6jcSx^D&?`f&us38#*^Z>q9D-/]%P>Jc=F[WPZJ-<5&:wW:v^rE,v(vm*h,GFbD=-Y:v%Ti'&Ss/#MW<DR%(25d2Hv#2vVIRo<HGR'NJ0G>#d_e'&fu8hLR@)b;j*u202jQ:v;[.#vk/j1S#b-?V?S*?5SQn7-mp(<k<Qj@tPuh:$MAO3L3t8%S4D7.%A$5=>HBww#:38F`e]0^tdeXj)T_j)Etv(NrgEqmAAKHI)H$=E,T9xntl+lr)#rh<dYOV$YrT)N'wCDm$Qf@Q/:GT9R>bRO&B>^g`_k*4T8`>FsigVmM7Hwl$cotq-_WH-)8ppHM/Pj$>]I$6M4#/qL&*)PMNeex%rsOp.'M6?VCIdERj2&CsC,3-)1^B^ue/NE-YuTZ$ip&+;]#:1'[YT?)_:B$%-1-P5AZT7aV.4N0&vUG#TmqZYB/3,Jop#0`OHAWQh*`R8L^RA%tTb20[PZxIf/gn/5P^m(#G(q>k@;@GCk8<-Q^xrLH#4Osf=9C/'UC6_F;v,g1&:V;Y[Dq[UA5Is.9i'/YRb:9a%00SRc#:;^?ngLUpst,^n_$0hR[$bOr+W%n1X8969@+4555>##id5v;)?'=O'2LFIPRV6,Z5.v/H+2#qp0/usUYRs`,2&iReo[gV6r/cANqUsm^nKW'`NbOvcokt`.qktBs_LKlu>pOSiKx9;(fcO2[W4V+XEdDT$5b@;_FDuClc=lE7:>#0pQ#vcpIcN-Cu3`@i]=uNQx,)<:%Vm9HQ:vE3'Z?pGS`tTr?4@upOPpu9H6jqY(7I=-g;&s?')3]fX,)JNQ`E[9<>#7@5(vT3k@*SSv?$Y$*l%cT-70AQsdt5b0xge6=_Uto>tOuTXcJmrOp$$n'9U]p:eOL`/jOd,oktmm:@_3WGxB,9@fO@[[;TOHQsH7Q5X4P_b%vnl)G6[?+U]wt-cr('=>#;obfL&gfJlH$t'MWc.<C_m7<rw3'L87N-j:/a12'D>inSclDZs5C(#,,P-W-UcHE#]m)'8rP/LVc3iZs[JQhK*:?piUto9dv>-s.FB],)'wNn3v8#r$NsJr$ipMFi]XZ^VnXj=#'.Y`tuO2q1Hra'a_d:^sP-=C)o$x<VSDL+vO0?hg$DiX.x65>#7qc&vi?RU1ZMBNCn,<5&s7<>#5hC(v*d;HC5[Qo$bdDqLj73K:rkb2-pmpt5=5(JsUSc^t;AIHj,U-^O&vQ?;2Zoi'X]Q:vK20#vhLv<[GSavO$w2bj$5^rG6<,MTsqIx^k&'3)gMCXsKJHL0/OgLBnx?I2>JfW&j.Ertr2Jq)*$RRr^/LXs-AD6j:1vq-+G5bs3ZOE&+e(rZn6TN'aHuGsiTrw=?KfuG'[_bt?ltitC0S71v3ie_1ZAe_H]&vt2ht;.Jmm8%.+n2(W6tDMDp+Dsp^;L_f-TgZZOsM/VWh:ok@/UP,Zd>%d]GX=;Lq06/toxG$c?XfGX[&M/jjZsOxKEs/GT4&,+Goug(d^?(6A8UP-(K%W]4FDPtBK1*m6cDtg1-)nk1-)p59Wg0k,ar21;m2a2#iR'&+Ds*]hs)t2HL0c<9i>;Vn*)owug;.>7MsQ:qEs7%0k$G@wn%4'nS15Zp+%+B@ggZ(om/hCt'*Zr)suJwgC-rrI/M574@=1nFd*R,<jL#6wBXt1C5M%/AqLjFF7O0cgJf;ea6WZVmJf5LsQWg9wLCT-,)O$*g;-KSx.%l$A[0F^XPK$<-)OAgha+26c:t+a3XC`^g/)aIl'@f,F2CT'&b-5c7xB%/nt>cG6.(r0NiEw9KNsdEWGsFK6m'BR7SEjhD5VmA#OMvcbjLg]_Es]W_p$I]9e=/;Z1QK=tfDi+Ip.>x7Km#rX`[dEeFsRm;$gnjLeLBe*cR>dvOFt?_eOlBim*K=8PZh1I-SAQ`S%r$vDNJLZ9X.(Zn%U/6f(ILh]t5V&fta.?(dC'<csQ]($uXZhR@/v0=>0v_5M3&EO^;b=9..N$sZ+;.<-uj'$B_un,)p1kqH%jN[tWDhVEErvTDu^AbGaC0GsM[*(47]d@+ugpq-JHeIZ0LIf%2k*XDUkTSL:ShC%sm&+;l&wCs,ffX#pc.1L?>oht_e[<&$<qv$fuOh,ZM+wLM/h-UR_Ph,d$+&uaX6)Ivi#I6A5bk869%cD]($K2$Yk'8tGDrtedEB-14V[%*t>#-)t>#-GfN&P.iRUINmIhiMq_EswrLHEB%9Ps5Q>IspxrA&G(Ku5>_T`n&)DXs;`%:HkE-Dsb;dw)P8>:Z`5TL:=o_7%Bn%=Y$AXh,o;Sh,]*g3ocIHsILurqIJLBN0``^B#b+110i]5]M0Vh[O]VeA-U,A>-)'650iKTv)5IlU?s4=f6L0&+;)>G1M@Lv*t'UFE&qe7*nB[:j:[X5L,Pg/o.ET/T&rk4I6'8YRsA_@nL@[WJsxSJ=#&)F`sL&QI:$HFr$5E;o7cO2F%O'/f:S/Kr$]hPQs8fulL3prMsfLEko:h]kTaY?ct9kkE&xKoeU&F.NMg[m>#qG)[%#?@u5mAfgPq6:827eQ]L7D7`XUC(GsfLdVs#VdVsL<%[sx^cFu.M]nLfn_P'oxEb7+1D>^Gt44Q;$['Xdv?eshXNWo<p@N%c<C/e'Y4oWna_W$[4+:<fkGc%7^7itQ39/;cbc9uR_=OMWkgf;Ti9s/P5'R]b]777BB8HsLwass8Zf#*^3Y0hB6`0_r&Vp.qZbLKgIxP*_0nlL-$Mx$;UJKs>_<ssVq)e)QevXLj/f$Kgamvt:X,]k?KU:vGb2wuFNKIRXh33L+?5ipA$t,)$1k(4+M7>#:AGuuq%Erd=NUg(3SrIhWQ64)+_EI1(V1.1#v9>#fv5oL2%0@Ql3VY5TlT:v_8Xwu;7=WY46i?Y/S_V$DM8>#cxmxuaWHElsB&Gjpsjo7_es,)qL7h%@RJCaV-YeVUp5HLPPp<ldnlYsN)`Zsgu#r$+G>'t^;LF&UWC?pP.jqHo'6YstnjLshIpZg*4YbML.3IWbjPmW3q&x=OFa`sHT2&b&[/W-8HR$9S%Hh^h.T58CU+&uFPP3@2sxdsToAn.bGc*Vp5&+;d`i/YchA;/WYT?),f1J8$vp/)OlHu#``WU8Q'O$IBn%=YD,o,_i+iFIZYc7%8*EjLthYh2t5$$tvA,B&2ctj)It8XsOkkvcPIWDsJkww#3?827(NFo$VswXuH7xg)1*SL@6;E0;Q6SN'MkYQsq9bUg=K?eq;aV$YJ?i.=@K11pKSj[5p>MU6MT6^s0p%31qcvZsfGMs(J.gas6Iq@%Y`n%>G)*K;uU3LpXe.v?/Dc/2U^m.ML%,JIaA6.(2C&MNsrHaPQ#-Is[Q%qLmi*<>/Hf%u4BJYmV'xcW@C;bR*j6xbAoV>6`b]A,E)^dMRN/FM[E@*NdIj$#XgQ[BeXN0>1xV,<F3fnLIH*^-Q$he6'K?HLxi>j(rE2e$uIT)N7ov##2i]e6C-re6HRpx4<4-.DAd2,#eORhCYwm&F.,R7;^su'*H?OCNFOMQAEwRP^e%]6'9*<jLCX=e`=mEX0Uh/v$tN=X18n#d,9]@I2xG/I?g/JcTvo-T.(@cls#/oB&@m?I2<cp_-aiE*H,m(d%0N=-M't;@E%m'xREx`i';9a/MAgGWk+`@LsXnR+%3SUhO&k#D-I,Kf$q_v;-[Pu0.V6uNB_x(7<]5YaBgO.4=#osZs+jm*)tRvTIFt%S%9a'P&[q9PsYtr$#1^;.C%'2-)N@8ptL(/Y%L:6qDCUhkFCH410.bKhLe,:kLeL>gL<DcDs6*1.(7NeCs?j.;Mq-d0L:ptwNkRre7egp5/FQUA&dvl5:FCO0PZEH6_[;9G.a:k%7X30aX7CORJEDc-67'F3Phr5'd[;9G.aC0A7X8K&>ASf'8,=`jt^ge%Y[:Yw7jp0B#'[.V$rW(KD:QgnSm^L,EapsNP?*Td+$(^fLge_`N9,['tR0TZ.tij-u6DGJ-]NBG.a7e%@Uo*ds]`=r)K90G.35I4ArDp]>E:4W7Sm,jNo0o?tm2gv.lnW.(N.?3Pa4FBoR%7.(feZVs.$QNs$?c*VjLhF&$=<m)MR=c'3.s<-Y/E6.`iV4AW)aj;v$B[s:/i*+f,QJ+;%U3gE7TPsuKA)TY^MO8C0uJ1m)sXu>*jm)^nb<mV<h,dqFNZs6%4Q/]6?<)K_jI(ql10)0*kxuNhh(mI]*hBP7wAO)8q1&nTgVBjihkJo,Aa*J$kp.p0Lk)@483M6]0h9gZx4prUEN0dd37RenjqI8V/W9,UtiC_>YW-J8naGCFT_4-]DU2tw)-vus>s/w4U]9C)aG<BMs;(Y+6P]2bJI(3RJYsXRa6&Cji2E'/cT>ujXU]FoFRsbGdYsxGR&*D/N'kR_,xOP9bLC1jlSf;+rPZcd_Hsf&]MsCp:B)Soa$O,ge'8MQeNOkQEM=pgT)&a,&F7r'2`.H7K^f_C0A7&j?qMjqWJs5kN$MLVKhtF]ht6jlRaEpdGGaf*'7&xg=e;T9$;U?S(%Mtp$x4WZQ48QJmn&rOg$9JEnvt:q6]G6<P=91mx#MaI>_$_35R3lrb4O:L$qL[)Po7bbe3oCGwGsOi8f)au%uE5XI+Qx1up>wrVGs4SnOri.Hm'3mKeH7`A*uk:YwPN_$.2cR4N0</1.q6Z2-)<`;HDb4@MhcVc8.r=#JXa$/v?[&10);M_%+6nCe6RIe;-'Wc_$^V7E&ZQeUQ%MdWs.<$Q//t,eMC90.(5p$dNl$>S:jn0Ps4_o#*%vP^tA@^E=,aeAGoGSYMm&n5N4m?Ys3j8A&D:l=SwhaZs6Qcq?7J4jLGT/SsU+CW.+;^ItWOq`$#lsL3-YvIs-L;Rsv<$9/%@'UsRBjl*3<WQA*;E,s(;pDs_2HI-u+Hs-H,n`A=lP6:&$te$s>m*)W]D6fW2E6sw%Q##D#`OA%'2-)hU0utDsuB&64KfL.vOCLZhRa&:#C)EQDKZd)C[Vs_&:[b-DX(MDO<(t@gW#._OUEOtn$X&vrMj0OA6.(QJ%Y5[USN'<#(<-';B8%-ecE#gebLBaH%+;@YKh^x51Oo&bTN'2M/)t$M>WMG>=Cp_Y9MTBeERS?G&X[<`oCsXp>$$wLXn[.^2:)<3G/f[e<jfig1DsAoa3&>qDetN.1]tmCLv#rUP_XN>ruZ%v_8.6iXX,fx(W-7EKR*K^lt>;s5=>Da-5)be`?8ghYcaj?Ss-Md:*MNUNG#nK/=>LoSk+vY/ENgtQlLh03MM`X%:.:aT4/@EZ`t$G%'Mu.5G-@MArLv>c[rC-JHsfHM.1qD67Jh((_oiHbkM*Ho>-d`HT-Jkv5.S?ufLpE;X-Vqg6iG(-Y#0x[e%Ef&*tNgVcM5hC3t*c@uM5eB/f=XuSfsk8;Z^OLdMr,w^t7X-T-f'3#O^9ie$[j`B#:FT#$940v)#HL=PD$Y0p)],/:l';/:=i6:B=aQ#B?UkCIs>&b$HPUeSHRFNY8-sUVeK:gLN_.o@PjZ`tiFk_Mh':o-xCqWASS6X.XuUG#r?[*.i3orMER:h$4(kviZ-*c;x@6bR-,;Q/5BLv#SWP_XpVE;R@.4N.`++1LTJ+'G]x+K#X+Gh)n)d<-PB2:%TgTl)c]'IV`SM=-WKZe%h8F+;vNTN'L:##=9:<DsO2WX,,+RO&KF`0_AFOq)JeDJR;7UvGWJ`mN>$TkO50YdQYY3_S$bnRWh5ERicA#iTY6;O%ZM5V$BQ;b72uG=PsVFdAPrbH4:<s/2O9VRs*6mNs:_%Hshr]h9jhG<R%v*Dsv7c$*cLL*RT[Ir$6.LFiL_h)3?bNgRFrXoO69BCCJu(4L)DDr$h<07@U&'Ms0'83gr7liCTcQXCEh)b3aP)FiAsoeA^53OUkE-DsU;dw)ied@+1E7@Y*&)W-$PM'J%k4eHdc34Ar]7brDgMOsY_iGsY[csO:SVRZ+9AB4G'Go3/*,(*P`[[s[$D4%]Pbgf(q+cIh?sW%Sj)Y,P6r_EqWY$.uN=,%DVd&MMFa;tND*Z1Ukw;-HQI-b$SWeL01i>5.W:L&a8Ms(Z)1.(MYp-$^C:SsKl94Lo,3CEUc3-)sXe1'bS@.)`NCl/0`'^O;g0Y#08ZlE=9`MN3xm8%8`c^qh1F/)BwGbVGcOFiD)i,).Z>7%DI:Yn_TiGskB)mfw(Le$?l<.%8JdRV;c?,WV#P?gprw[sQ'=IH@%aF2[1U0`=IUCEQ_@$rBT8RJi3<v:8[-LII11/`NI3j0L1MCWG^,CWu*vI:<1&[do+wqd5V:7%[&_-h3q0</4/E:6(l#r7e^w],3m9W-uEVd4,:1M%[*nMQIp8smUUv&-/)oZg$10TVkd[[sNG]VhWcBw^Za5=>kG6LKj2QRJ22PcKE4lwY@gfLZNG>W'T86=>Z^Sm'Ct[nLocQj:?HLRuo'[G&R6VQs%&YOI+pINI/r1(t%O=E&N=U@FTAVN'h&P[7:NM^sFjq*M)KB.*)JTI:X2JFit$-Fi)3AZHi/pk&(O$:TxS/(82PqB#I%KEsgs?w#:P0r7%,Zh2*_%r$HNwI:&j/Esf>hr*jH5V8Saf6EHUJX>^'6@Y*%Vb;a:.T.;_WO&CNs343Z6hC-VkHr9A?d)qBWO&jxGRI1f-F%SacI%c2Cfs7>Bmtlu`=,aTc^t&((@O-p&Fs[tc3uItDL%3Si(f6t:_nCrF(.k-hkLjcs/8e.al(F?0.(wIDRI4&0:[Lfqf[,%xUL%)WhBeO&w6+f#bsrln?57V%3qs@3(*]x3-)ZLi>[%BrX/u$8.(g<VXZZsGSfvibGM@P+484xd8.US>g)pT06(0VT3g$c:#mMVfwY<X=>Z(B7s.vPcA5d7$l$`C:E>r9a0_FERI:qLdb8ISF<qjVn,)i?iZs?G9Es*l_.*e)`-IBdRhaALxKs3^?W%Lx/L5R6I'oae93;=evI:ln8U)sJc-H;[$@%kDL+<a8eF<]W+O4VtjM<'t=<8IIED#n=trZMcm<cV+KPn0k2;lGpmVsG)/Psk[rS%0.`G)D5JZLvD:jTvBrqVID:^s=]#.C6qsX>MvXYH)ZjbIA8_ut94xPJ-ZNfH.V+at;vhUH&.jt>-ccfV$CVuU>hD<%W><R[VQap>=qsL'jni=#qk3fHpEvc%OvX2T$J+GRvVQ@F'lC_tw.)Xsd;]nf9XVVRvk,xTAZennL(ihGn?Hc%pJNn'PQOT89H9j(W==S4n)N*Es2$UnRi4i9.BNDs9%S0qs1Oh8bc6L,f&2N'&6GPsah/Es(d(k$Pq4.(IRD=*<R9Es9Yt0&.DErL94urLd_rR%T(BIMNfTlsQU#<-gdOo$`,W1%#3fCO5-(1MenI?t;2BC/Dn,bskH`NRMj`,)dh*.%hw5w%-p2:6'07ZQ#vE`sUrNK(2/reU>;47.FOP<&KD`n@TT+,WG**gLe#5$M?%S$tkKFF41Ff5u`k?G&O-VCEZSVN'm1U&Op`+DskUEH&`Zj586$,Isj^w)$kd1br[VVN'X3QQsvk`8g?T&<7k[;EIdJ6.(LxSas6kd-)COZ?t)8)f:fs:_t'-;r6,Va,)tcQ2&J(p,)ol]@=DshC*WZFc%B<vt,S-QbDo2bebXAj;&1&e-IaU$r$v>xq$&t(%+T#KEsH'P^%s[,%+I>A=,qI,Fsu]X2^oZ4.(9-:+M%w6vtk+sbtmv$M5he.CDhHX$4&HR+)HvvS%Uwtt50.e'k8Hoh'm$P4ArV_7%[379-4%`b.MlTQsWKeSs/?UHI5NPI(Yxr)eD>roCK72P<)+bjtcG.dtTRR=G=Awbk&l'19%rdhoZehk/RZa7..rkCAs)NPW6PY6YxC@/SaA7A`dx8aAl5m+ui9N]H#U`^>cjk(b8E7hdm>Jc%_nna6EsdaO:+D#lgoY()2P/R.r+b<6Utv8@7%PQs<8:MsS-]G`e7m)-/BwD@A-i^sRoJf)aRE5<+Rsn%pM+]Ww#-GsRaW_Of-Cg@+t,bsVVVjY>/&^kM>k@+';N)u0/1$%2<w,_9bQ^tX>clsIOToe`'jU&H4;O^U:LlOT2X9s'Y$r$H1ba%761.(7._,)gxu4*2iuq$b,m,)LG#l&/6i[OsECutk$1e6Ah>tLIKihL^@a'Wt0dI:QM1pO%2;g%u7jq6V__f#i20>G?`2GsDBfr'q%=gL/m_Es0pLs(FUsanf('u5d44-)T94-)qeVN'gTQQs9ETIp&P^EsWZ2U.:i@3qA(Ctuf=4-)5lVN'2HKn$w#:1'/A61'd=27I<H2r),B@gg+A'%NS&A?tRL=E&DtQ@F9+T`tXnxrL-iBnfmr]qQDET*I&sVN'q&?7%VoF=#R+]a#KoF`sWk/.(bLB6s@vb]tx&w'8F[qVZN[N7a%][bTMO_pOgrlt5,78;eqTFW-<bU0Pw?V0P:(0sLf^T?dwSJ]tZDF:r(2pkt&B`^Opdbit+_pF)3h(jO:uo*DK[ESV9;92s-v&K#cW_D.7/[w#rImm'#h^kA)+k<LRSc^tfh#Ns,H)c<mgk<:@T<Hrht[6s%`?q&1]SeC1731'RnBe6<VV*Ig4.c<omvS/goM(?^='iBv%m<C[.2Gs9%WL'lamiL-llgLjC.JrW2-N'WUDa*LP&E3U?ubMkYl:rm(x^sp(Vo[DN]qHniSd2N;nw#bJ2FMp2kG>mT)iO.6hXTju-H%8]X0QQp8sm*dA%-iWVqQE2uOFJiAb%$$8-v[_7aEv?PSE0<Q101cuR.W`ap-jK*8]FfifZhQE@X:A,B4MQ#DK3MXoOB_%Hs.mSO/ortKrso^%uqhqs)v`3QmsFkOX2wCb%*^k>GQl:[BDi>6:R3(d*aUsQ/tXD$t06@qe$:T,27I[0qk#$(*2eS.(18*lAZO;xHuBlxsj]gIra^0N'N5GPs))c>#xgOO19/[w#;M$4JfuVN'w$)=:fss<:k-KI(('Vk+,;&(*XMS_8KD,bs<u,D-GL.U.?D9Es5c(H-.Op$.rU0hLXXi^sOFXcs6L1).F+`MM:V6^tIhj/1xtJgOM'TPo:vvCsg%@A-Crh_%C'07I$uPd-px/EscA*0pFwBw,7MFO0.$Ec%IHi&1gxVN':(Rx-]oiSMIeq@-a*R]-RIFm_Wb_asmpBo.p=_$0AlwL$NwP^tQJ1@-L:sE-=01[-mtcq;s<2OLCo(#laj;W#O8P/$H`LDdcMWm)KR9Es,'b);0Z<1sL+iEI`>6.(Dc&Es'ld-)Y#.osY3CF&BVP+;8,P7I%qwE=q$Dk^_>09nR?4`OY5Em$p-eh0dlqI19K4`OZ6[it-h:$%@Su'<T/*KVg%I;oj/<W#gO0,..(j*MgICbt&67Q0`&:w,eW1aB[meXAlxSF6<b&u$k5'tm+6Jc%j&3?ovFc$S6HSiQxD0pt)Kc#[=Mxv2tOQ9;vA#PVH?pEsT/<)iAQ-T%Z>ie(DAest78`=kgx0aOe$ZRs_FH4.f$>oE2Kv`%Yf%8ognost@=171&d3$MM9NR%Pc83PH-[qO/$rktCd.lA&%f&6Rix;h<ig)l%I^UFYn0B>UUin/<gtXAm7wYs=U0(*fe+b$58][sb^;`sRM^v)5sgMTM[Smlkk*9'k$r]tOgPatp'AHs&mQX5pd$fdcLEp*5g$01G7L7_p.`DsTjP^thZ_X%Q8.`=q-]@>A4OKV*_PDI0O,k(433<q3kd]%uGDrttZ$]>)MZIs(-l,1M`qioxNG]O:Dc]sTK4Is`uwfL%H4GsHGX3LmR7Xc'C_?%f8M<LR98C41d0hL<XS:Ld6mL9e)n0)L1qt5T^+P&#DV9L<$EU/XW3.(`PNf$cTR<6Xjj$Y;ORoOk,JLOHO[(%/mpQVY5=)r(?m]sM&Tn$Mh6kORv3kOou4kOdPb?9C*P*=bd/7L?ek,)V,`mO+AKZ$1I0-dYj#R/a:C$%8KU?KEMW`t/i/gL@=L19WT)19Tfdt.B#M@X=,N=Lvq/N'FYEds.gxHo=4w=ch0Bm/)@8tsL_XE&8>2q%0]OT0x#*RsA;qEs6l+[$P4.2ur2BI&:rw':,Ux'/+ulQsuO81'__`R%@,oj:g:]stwH6I`[Jdp.,pINI%mw^H;wbdtL%:sLws[UrL$%K#`n;Ea1Q91'klcIs^(fn7E7[1'9uxeC^G,F%_Hin75ou6%Xg[RsjO<Ls[p&r$oMrCss,`g%7&NI(_*q#ts)2ak1sxq$eu@tt&^6f(-Lfe(kWEUH1mdBl7]g)j*/i_t5Grn%2x^U75u.^,+%aebil:>N2(L6ALKRI(ufd'N,aqHsQo510ZO.+<nvL`,BeS6]@_ISOa1[10BBdhLlZKHscG30pY?Jg5005J.g#[]s-4,]4E-/R/DQ,N'D=EDsJv3gL`Yn>#kqNF)*/khq3EVgLudg$cf+$r$8ARN'NDp]sS79a3jLWm)x^#=P?k>J&=5GF`ftSN'FMkV$UEOEIVH9Xs2`__*UlGjseC;;V2iJnO8$tk&P@tcO3M[72J<O&u1M'IV)->Xc'VHf$q5<0a;j:baje4brE69)SF*Ic%3bkfCZJ$P=LA>Z%h8];M3lLEsaAx_O;IR7I6X'L5=H)L5G/@;gRH8Hs9$,^t7e0,)Z*9isA=d9m8W_,)[Rhh0ZDGf$LVuL0Oi'J:?Q5N'O%Nn36,9L9a[i8&5%&73NB07IaWOoLP]_asmFw0s+wSMLoFmQ'g4GPsiL[eC4OFj$2J]wXNN-xXubWwX+Z%vthm>l0LlxxtDF.[<X2_OJ3XOv6Reqf:xx`Gs/9rrtAxgH3h&J8o<u#u#]h>wtJB$V:f`g<l&(jW-7(BqMwqJ<t9D4j);R%cRx^0(o`E$Z>lFhXoEHZWaf1l<Xnm^tV]hv5:igYm:)[8oDk)D.E_v0a%T%'H&<^'1bH)3eO:5?l&vkcpOI&b/Ha'qJ7VjGx+6SGx+Y.:Z%a&D8eDxo@jlw<e%X;gBSlb:)s5p6>eAw$T[,nmP0UtnW-HSBeQreveQ'YIf$-rNgbo>>pXms)c]1RV#U^RH.%Ew%VDnhYWBLJn9B#.OJ-KUmc%(k>9FXlFc%7V-8[Hm^@TZH/hY:knw]$*V^@b)_4&:Ujt$[?n1_YxGd%4<R0P9O@,ivs9MaQupM^MuohtLn>7=%%WGsIG6S['oDs-ksLQN/I^%6p%ecVO7^RsG6YFCM[&g%@B2H&#-J=#wvAiOx31Q:;n@i5AAq1?WwN'.7#$)nQ@kb%(0<jL-GVe7etMkMDNuLst,GhNRQXWsAI^D6/&Z#WCEbLcD/)Y^>?w,)tYUXVPe-qOLFRqtri4^%0hpc?'CV&137fs`$6fOba^0kOnG#Q;rDwb%.>@h_kLN'As[s5<iED^8^7IaAZ2v@/tc1jbSY&c%eUeJsJ_e&MaREZs^7/wsiIo?&&SIf$)UB2:#+HncG/8ZWZk._TlJ/jr3W@oDj/`IE[p'a%6Cb$X<AT(%Pj]X#3pdueV:&Zcqjtw76=greSDUMLh;6v6oaN41G(Vtg<vmaYeY`JZVtH&T=WZ*8$#j8AWa#'I)e@a=LpO7I(GAkC<8P<_XI[4/a+3N'4(pc$wknk&.TjDsC=RVs*TJqdRlEHs0SRKsx[24/8;0AVZZ[&M;G/kt&,G#uMbtW6/xUT&;+$u#[.Wh>x%1FsFA3Hs<-qMsMQjG1^3OB1;9#ft2fC:u;G9Es'YNf%U4e&MKpp[sa]<Ls+OD=#sJQ_W%*C@>,^l>%JlwqdWtKKgAxB=#up[nRtPWRs4DkHrF`(4%/fEnh,;X6fu8(TAnw<RM^IZitFoGJ&a&1fsdGoN%+p7a3'+;gt7HkHr?vmpeE4E`sJ6u>#gvxr/])(v#8s#u>gLMa%>6Q7@<;]:-5](a%:cB=#0Ppn.P2ADf-j51?gR)c<6?3W%<nrZ^9Gj6eeeZVs7iOwBr^OIsjbXYbIPTM:b]Cbt4g)Q0ep?bO1ZA?3Ah2`%B04eHN2tq-@=Wr`7QrY:pLSX%LN&2nKk_YVSQb?IqQ6p*j'kp.aVV*I,Pw9)_.FOsR0+7I42+.ud:aRRD71lORp0:?Q0pF)i2i$uA[rcsG6Db7EL]@oH)]_8sn14/C]'Fs2#jOs6-U:q3%GDsg?P^texkL9SO5l8*VFu,.831u6MHf$@cO_.7m)#tjetk3o#Eh)6)lIs^pkIslSKr$p'9isiA87M>Pg-u3.Dh5Kjx?^M@&Xs2^b'aH4/30vOH+;)Z'7IGDc-HE>D4Jm(v3J<$MJsr;tttJxm_saMfk8Brfk8)Cf]bnwlMV*_PDI'/,1MF78FOE$cat%hnGs#WqJsOXF`OvP6ctSD6ctT)NR70HCx4[W(%+u/eb2Ili[$GwngU*x6q&).jh'j<Os(vHLL0,U&U@M]$=H/[jv7tfj>9h[[.(RFf,)DY[XC'vEc%:&F.nhQXoLf3H;@X2(JsUtGO8/S1v^?mt4XUh1+V4]t7iMi&Ps:n0g(Crq;-snG%.,x2nMjWR+:G?_-6(')W?QWv*Imp1eN_8/GsDbOU%^eLp7xSVGs,DjqOuA1&UY]r<%8)b3%'^d-IEs=4&rhxIF.?LM>TIYIs'o?+SRK[qOW'VxML]UaJk.i@BXv'pL13vA%Y=l#><Sb%CdrmxBSid=CHuJb%HhxMKjiDGs55Q4B#qI1C6*3GsZL?W6+pINIIIVGsUR?Fs%Et'*GMP$cD8KI_Zr3-)fs:dlXd5+)lk`EI?x<Gs^4:w-a<sJMEwx'3=aXk^R7,2_ahGM_E6[v>I)/)ttLW1D,O,8f5G4B#5&EbrT0h`t,j1d*x&Cv-8&3jLXxBL9I3K'-,ia-IdW[U$7LUSi<`oCsAY_pf>l+Ds.NOn*P;_s-+^cER]bXWsPMCUsvNbq2axWEex4gCsXns6hg?4i*upf<-W<o>'cH6.)kZ4<-U#4b$+L7?Pb6o;-2Y2CZIbRWAd[$'tZ8Eq-F)9o8B7XfiKY(W-Nk@o8b_+Y'0U=S,/^x4_<`oCsvY_pf?uF`s:?fq)J]Q@FD6nDsbN)AFc;VR<%=310@$91'/>sq/5'*.)J=Vcs</.]%^BT'u$ir9&X,,<-9?Ll1:b210aU+_FqQ?C+wg>%+f6bp.6E14oO'RpKh=W:/O8IEFwW9SMjY4&BFop/)E_'o[S/ss?f0+2_d><Gj[TH2:n^Js-EY$FOk)3le=>^q[*JfL].+E<-`_h@-Neh@-Gosj$2]bZO?`K4n4^Th_`q(/`RoBZ5.ql1ggS+TsOS5.(&0)0tSI5B&:x>:vDcr#>aih6pEAZYsE99[bCXH-)Z1Dcs^(h8/Jm:dttJHtNUXt(M3_$TMT<#TsjvJHsboof.g&4AuZRT4MFn,D-09(@-^<)&.&cNw78+`Pg)RN4M_hGw$#73104E5.(U:(@-t#W..8#i'8I;]`tBt+^ocgbWs]@[Vs-k+:2aQIkOhfN(A/pR%+iG6H;_-hC8'VkKYp&_PMm1fVsYg#1KkaJgNT[Z>u(V_e*$bqA#C.[x-hQmIM'3^k$[+jnn;ws<-MI2u$4S2oLQv(isV#o[s?R67vo0`0#RY9@P:i[/1vAXY#';Fxt*WNH&3SEf%At<j(Qwt$/^4I$uQ/+RER92#vC<8DLLc>DbnUs20TsvCsrgd4$WqHN).(Act+?I;<*i=PpK>L/)W+[0)qD67J2GP^t0[2mNUlsZs`Bvw+5GX#$v-YZ%4V]77c%FB-qY4?-.a+?-LZ)+&MQ>b<HkpMh&QaEsHBZ[$FpS'jj2QRJ*]$4C%l#0)2XDotW+$D-v7(@-^A(@-R:/n$%:N5K6t'F@`GFgL]$GtZ_r_PM(@%NsSF-Fs%LL)0FV-+2m+CR]&k*R%]<PYsu&6Ys$O+:2-1o92_nv*;RKK6/_KJ#*Uq3t?&-**,bOgVM-=X1'd>4$M>hA%#bh(VDw:71'@o'#]?49g%sTtM0pc010ann?5:HlrLHb8%#NH#`JuL@6aR*P7IF`9D(XfDvATQ61%Tf110N6.k9R(FI)u@o6NTFc]scEfq)UE?qnGZPIU[rZ6o5]btt-i?qn.s6C@eSG%0N5Fat6#KEs,?373_#g&tmg7D&RY$Ou-@O=&oxunLeS[%+hO39.H*SN'+R<n%Sh1C#bR$h_#Djq6%v*Dsl2IE.*O].(5fha*(5Zs-7OO8M:IA#MH`4rLTwRiL?p`fs>81`.+TrXuC3+Ri$%JK>/mr`t`k:HaN#B,MSMI&MYs00M?(2utRJ6?&(uSkfteBX1&AH+E=e]6Ep'310:Ux'.:BCxLgC8D&#GPY#oDSb-Kii'e=chwMC>aNr`LAF-X1XN.3m*(h=S3eNW;F+;%'2-)eMCns;)5(.i(b8PdZ[NsV(Qq2=XOI(2hH)ke[:>#k?fQ-LNZX045GPs_=EDsl#Bp74Kf)X>l+Ds1jGtL=c5at`FY:&b^LbZcsOWsEb:^seA0101E0LT`J+F.B_hut:jrp)u9(['iRHX#KESBb#R.UsF7H[Fu,Ks-t[EUEqJYpo)C[Vs[s9[b-]xf.Lecbsm&_4.9sa$Mlx0j*xd0r.%U^Ms0kra$2kP]st?i9Dao9EsER7f$;KhI(0)RN'c6:w-sk>*;OPOAYX'%IQSu:C/eiUtl&#U<_hnM=GCCIDnoE>GsVSR:0JcFh)ZLGeUklKU;O23r;s5h5MB45GMdS4`s`@9C-wLo;%I/,K#K6#bW>l+DsCk+c-RlgERD8RN'A=q*.FZn>t/?[6fD0EGs4L;Rs%?Hp/xGmZs[jd?&(qlW/9JZtHAT`FD6*51)B_IOS%'2-)$5wouiK6?&h:5U2i>6U24Ss*@v=T1tVnZX.>)5bu.P_[-0Rh[BCEFs-]<GhL<S(MsdGII-bq4[$K2`,tR*+LYSadNfYiA;RNi%HN#2u<Q-u0W.IH]Ps_t0D0]Ad-Ib#soiatoZpl'SHsj3fHsfK#x4:D^3F2PZ?=@@ca*'Mam/0O,k(E%KEsrp]c$[R.nLQx6bs@%@#M[Mf9e:_Em)PkRwYr6e9ebdq@-Q5gk$9?/F@RTqE@KB$F@/Y/o@Ieg`tU-6eMO6UW.SVZHLG[2E-^T2E-QYV6Mvk2ns:^?X.kb;)tmW2E-)U2E-:X2E-VZlK./L2Kr+PY8&ET+&c)v,'?89PK.:=XaXpbAGs2&P,/W[Xit2ooO9^d2W@9u93I6]'l=EMW`t<ZfJ.:q8'F?IO&,j^]J.:XT^YLGdJMx[:C/iA*Ost?il*E]Q9.L&ZKpv=RAY:+'UMhe%:HN)27JPK=*tlY2YM;xO_N;CcLsqIUk=]2p'/jJEksWo]wOwBVZBf3hCcHvVrZhY4TsIx3+)Nw?4t#K6?&lH;p)[WIx%Kdo`m*+'[s$EdYsD7210bc5*6<=Zrs+h7D&plpv)1^TI;v;5>#+WN6vUQ1&f-@$$$d2eCs'@k'&2V]q3(Ukn.o7TO/=e:^s3Spvtj.Q:v2$PvOA2@Sum4pLpR=P:vM$(7v9]([Z6#S=Fu$31bXkUZFe`=)8cnV78i,U>ZS8hCM_FQqt,l+K.CTcn@<2`m&WE6es'>`EIlN310>b31'u<KF)mw31)Rl'r6pZ1-)k_1-)cBrk$lAagiIY)ZsG69[b$'@XCeC)$#QncvIm.wHL_E)<JUtYc-WF2.HKB<Ds-roJhqD67J0B>naE&N-Z0^L1NQmrpLD'2lMYAaNrB3s3kU@aTAkRYSsp3mQsUR>l$*K?MiC7CU2p<2#H*3ZJD/P33)_Oj$>QCI7PK'qPUg)>Wso5DZsZ$310U0[w#bQ,+MSqm5]>vs=0e=a^orZd);W);9J.cPTsf^&HsoGUp$JZ//udh8A&&&3o@FH+WsBo=QsoT,@.th/?d<FtlgH?Nt:@qhqZGpq'/.Isj(gJ`BOS4OuLg$<Rso'CW.`ThNspA9C-oe2m$._310j2^(IvbsJ2DZAbRuGDrtbsQ+HiUA?phPr]sPX4?-vS+?-,U>[.#et*t/l2Y02jAUQ3LW[GO6)'8iZN/i*]^Es__=?-`ptv-C1TwMr80htk,6eMf>'<MJ,0kpvWXLs4L;Rsw*CW.m?LJs.Yp$.b6r)D-`Ys.Cg@(E7j7s.io(T.KMi(tVVg$.a52^MJ-q(MN&G?M)Q2AN69<ehhhqE5q$b-I^TZVhlH6`sA$%)$bQ<F`4'J#uWk<0,TGNG#%,=L,Q`i3o;F5at^Lih)=+j^OCRW2M$I<mL`)?B&VdM=P@Ru+j2V<Gs8nAv.[EaLB/h:f6AE410PT[$nF`F`sV`Vq%7(E@=Bhu+jjRUZHb@wYs[j9_a7v59.QA6`3)ALgLIi_Esu4Fat)em5.Oci^Mrmi<dT;Gl)*P-HMx7]6MkToYM5($uY)M]>KJ-))bI:r4&Ea.1Lh]1xJPEWcs'KOV.VJI&*OVbP:fr;GsU/m52SZWm)eGk_N7jOL:=o_7%7P7jqb.,X#Rio--rQ..-rR(FiY6U`tAvsv%9g010aCJ'F5=Xb3q1eK<TqE>duV$6:A`>_L%d`xHT)bU$dJ6.(N*p^o.8Qe$S9hd)WRH>Y3iaW_>A`^O2q+sOg)WRsg`'V4hch^snl0D1[Z@`tSSVbt5.=UIRX3.(h0pVd:VQr,Se4(K>nt]t7o@hX4mL1J;j;c7@Gr^:I2Eb,*1/cQ@=CN'>9gk$[eRs-1p@;Micg$N,LNZs9V>H&Pu85^5>;YpD1MUsVQqQWl0`tP<x+CP##/OfwDaC;_:dG;M@tw;rh0*3IA<U#.+U8$)$M48<:2^t,>3H=tolIs>DX'XEZ&4n#ld-)$gO2t$vPJ&v#_(*4x/,PKD,`%#n&+;Kd$p(h@Gh^u`-5)GwnDtlN>B&c]qqmWKvb*:u]<HR-fP^B=-FHCeXa=p>CLsF@+oLmSC4Lj?okJCn/B5`?Qvt^^W#.ACRg*%FfW-7[S=h[96)F/s=L`a`-LsFb'EsbvZl)(B4hqTg]EJfMMn3GvpHH^[/.(CZ8&>&^5E4@3+*t/WW>.OL5T3mOV/)Om(H-j+Dd-eu<qr(C')M9v$JtHQ`=M/CIntmYMd-fbpOBAVRF4DbiY7(O+f(th4-)U&e_WE8*I6B^+CL@8hPKJ'T3/Fs9>p*a]$Ke/4DsrwXSR,<2-)x>2-)Lqq=#r]FJ`L)Co%VPQ^5VfZGtJ]E^-$+V'8QnwA6'X$C8]Z[ZVxckVIdx2C8x>72hmeStLWgMOsc`'Es7D1nsRrA9Z<C>7Axl2T^Ago#Mq(DUsU*.e--8Aj`?Ce3#r)G)M&F?mugXf0Uu(1-)jjtZsgPN&dIJ$.8^CxUfg)N>^k?qCsL%%)$e^aUHe]0^t8o$t)l3YH,b.o,F2s/SsMA3.(CKIQs)+R>M<JThtV^8;/.L]Js*iX[Nw%EBSK;SqL-v6101ILj:vleS:'he>H2?DvLbxlfa7ZxKGXerY?HS-MMe+:5N<Gu43)6;U#+xT8$5OL[t<:2^tDKivUM&ck8UOCUs3Q35R+cj<7OeXMt@uPJ&[m(xXSV^caQV^caAagT.+pINI=hMY$c#xCs`T[&*r7XX$g#-bsYU0%OuC;Ac8'FW-_SL'J3/&Ns]<a/MTO()lcDW1'h>d[K=['3NJ.m#Bs3Lw>@=EZQ>l+Ds`mU*Mg&OsubfLb,,X[?^8v'_$$2btaOBc05?j=Yu:u.89W1t<qxKU<q@A$`<Z#aGsq<EDsckU`$4`B-=t?$Qs&AP:&qR-C/2r%XKq5GCPA+x)X%v*DsR%2>5ECtE@UUVY#lcEn*RbB'=YTAHselk1gUfc5npsOE9*K@&GB5i*@9Eq20*9;U#tj>%p09,I?HO`[FY?>^b$BLQ=X56QC$HV].a5m-LYd/]&.n1utn7n'P19(wMa_Rj31Y2.(xZ,4AgLFLLfri*M&g+>uKCY?/9sk3D[.FhLs>ANsw62=>Lwkb)Q;MRJNRv^t#2tu)Pob<m;bg%+M0t<-quX41*3Eh^36nRsk=,ft/i?&/PKL'sXqb-6*-qBu)$SD&)BxdQ5s&=#U((7RlGW#vaa@FXC7BXdVTF#d@CQ&-;)Hl&DSplT2<6^,:`kKP^`'Ese<T(/FNIL(`kwE7']:iSC5$QsF;hLCPkxoo8FrmL#X+=&br64oE^YiqnAIGsNq-6(f`C)nu5VU6vdq$YNRv^tvhu.8VO8R3DFC<&s[WD)Zmh[+m]%=d-kO=cKcE)t'm2-)Y,fe-kpds&w9n6%'V)T.2?eCs;VNR%-9(C&U[kK518tKPhmio70G2Nrju#d.#kmCsmCnq$VkCb7?g+>uI`Kg-m;F'S^[3)SQ7[/NI?5T'I0&+;V@Ip.UP010qV>(Fr#<gr7)_(*v50l8O.qU@A6Ta>_EE$uuiAasrc:1.3Ut,McA=ILu3S)vH@T1LE;T=#6HP:v=S'1vqqIGLuk4-)X`SkO+dLs-w.dBM_?'$ngTKI(sXk$YgD=T>M7OC4I1YFDItMe-o&:1'3UFv-qUsRM>)doLFYVpLJ1M#=jJ0j(OP69%=-)%+fFmT`f3[n;OGO[9FX^ds7evZsk?0XsFHajL_BRFsnK;Rs_Jh<.53TRI`^#QB]8'.MJ0rMswo*x.YNoVsA.2Gsk9oHs:r;1''X%C/JD9r-*vZd;*0LB#G3saa3u1%Moae0^w8;HsC`M@&a/SDE,n);Tx,Y_3&rh3=7,A]sdmbZ-F=9tqXS@.LQ;?NLiwUfoX)cBM?JVR%r'D_/4p57t0eA7.L*]m*AKW)NB+oVsU,;Qa/4=Zsnq1=>Gkd-)1ncJtNN>B&[GqqmMK-1L6sxR8]#PA>/x&Q/<_dZ;5'`:-WEZ&#Bun05PkFOoj@V/)+@hNaW3@A/dH@S:0dp'M5iqEsTW$&/wWvQo]ND3Gwrb6E591.(g(VMLln<d*sYX0GumCv-1w?]-U2(QF&K'-iEE5.(f48jC1rEkXbE.@tEvK0lMwLLgG^ZGslZIq[MeG)F_M?O4&dW=,#0.W.M$5au6--i8%bQhG[4CW%/S[g8k&HK)n>2-)&d'bY,d,m)iscIDP*Z*7dn/u>,<2-)(*2Z-6uCpp7JPCLfAR`t[Dls-K5b0NO/K:HaYCp.mYm-LHbSBoBg_>XhAtD8DSfl^1+L'Jt*Ih^Z`010.lfn.LU%dsC@wx-xe&kLD^@Z(+[ewF@^n^$UlcFsdH'r$=9Ac4qVf9t%P>B&j<?ht)0:F&CIu*DKUALUuUhiUrR-/V3eFp.df9JsIt?Q:a#PWsrX4.(&._,)ahw)vCEoX7>hB:f=fZ4]hC[eVX>m?$d(4XZ0Sa6fLIDU%C#@,s%MIF)?#[csN`CH-'a4(.oQ=eWWQPTs3*V_JuC9dM.j/Z.oLT:v&l%*.i$CR8>3O2(W0*X%MU'=d[f/4Rt6oBJ+Bs6sE,F6s/ZA7s=Dd'))%KEsT-svMVQGTsi#t4o[AGe6d6x.vs>C(J$n)qrOc0rrZVt#n@x&n*/Z%E3xY#Lg;sDLL,;$3#0;pBbJY<=lB4RGWNKIe-mY_9MtND]O%H6hMlp;R:+Qo0#>Jpu#U%$c%Lx(YC.^F^%uoObC4U(mStlLaTrX^@TOS<;U_CpSVgbE+[j@&h%..-;]`9.mJ=@4$J1Dc@K6E+f%DgHuT>Ov,)[:e4v7kTId?T2tL'xi7#;?v`tfXYg`aC`8.pN^r(6qgGsce.Hssl3_$)prb)&$8@P`Y%BNrUnKco3#1cx90kbi_sNbMchSod1<T6fIOB6<XJKsU;QYsh^W>.U5xT$pnv;-rN(H-2*nA/iW^MsgG*%+FS^&4aj4Hj'&+Ds:[Wm)]icQs/_R<&6@;F.Xge#IqMLs(C6#bW,V>Tsm3mQsJrkv-rWOpLDTKA&D>UA&EF7l9`M8HsxcOlfT?=C3bS5O=#*N48'&CWQ,wF(=nwDGs&Lp3=PJcfT.O8K)#$&xFUiq/)a`X4Jc=%^&hV6HLPPp<lk2nt>PD6.(_Z$P`YZ`RssuZ$Xj2QRJZE<ltpt?I4tINZs*Q#52os4=>.S@?PG]EI)YGLnnaFR0):D;U0NM3-)BTmI;0^*1>S26=>L2Q`-;^^0>>OmDs0n.m=jt3=>_.H`-G%@k=q,RgL6`*vouQGGs7`Y0YVV]wmJ>)A.UX;%=D?UGs$;o_OJ89IC)b[p&c`E8N8>=[XDgA_/8I$^G]0t1>OdRpT0>dv*uq%9.KHa-_jZ(t%Jd?hpRdvD-rPWe*4b89.=7dwFCY`20o8(C&R$MQsCkSwB,uxmW&tHvtgXYg`h_J_Q(Fp[sp4`t_M,+fCC6nDsH'(XMXP^IC29.f;gP#WI>kwxM+jmQs2e6qL5=(:@4>g$kZZ9#6gZ*bZ/:OZs?so*D?,pL0nx?I2Mi5F`J@0-)pL^U>2*-01IvUG#Tc1=>p5E`s+vgS/Aabl)dq<9[0oip.jC110S/sB8F=g3f_M(T.JL(Vt-N332`pIds7V7`sgp>$$-RsX>R10&u<ZuLMgxa-I*3MPsZ*fEs_x8e;=a&HsA`bj)eeAnfpcjXPVuEHsJouCsZS2DscKErLY1JCWxP*c7B<I,MW;/1(p0m8Kgcvqta=@NO],</%kU(CGhOFLL@;bjLRmPqt6Y59Mo1,Q'#-VHMR$,%X3lrh';.vaE'#Zg'T3n#uXoceq1CUbtF1X9si5atP=E'l&4[ZtP3awsZKEI['q$@#MR(?)OMJ=jLkxA:-,D8DtePV*3,$M[O/DI`W,5+Ds:9-d)60ugLaPwtL16&#MDZ%?tB5eAMX46HNV_RO&)PS`tGHL1M)>nx-BDjhL.[R+NW1@mL'4T?._n%P&7L*4+S<s<:OO1H2^JX?Ib2:JsGLND)WOKqsSn?@+xn7wt*qY,)F$mk/bYGf$ku5mtHA;7S3xCC*uoR:.>nTUsRoqR'8kQI:&xhq6pS*DsWbIi)M4^;M)>O#L=pe--<)lk/@`xjOJS)OL%dr6QBlboO8>&ZMC&%%B>K8+@gBfqR+?,LNP,+gO[[2bQ[vbgh4[ItlUPhJs?4@nnU+WtmK<w4nE,OL2WaIL2@iI8-8>XQsh<#YsEGhh#+El$Gs/Qq)bixeC;Y>s-ES5s*^bn@5+%?4&S>k4qE)M[X#v.-)Am[.(U5gU.p$bw'Y0Hs.*>2rRD5u1q0;p]%e^v)*ci7k.S;IZ.5u4&uLR89&lGJ://C.c;TC6OS.,8x+vOWN'SL<@'iQtOM8PS77D@;=-WC2=-A9DeMq:[]-0*Qn*vW@.QWvC.Qi.0sUei0hOYB>oECRw:MSaI&bx-1gSgeK@O)9F2$]:7:?NX@`tmbmiLJ:m`O&TYNb-bh[O(3=2$B/J>-v[<F.;HWU-``d?'?ji^sO`>Fs(3RGreR,u,BN?.)#o.-)c(,lSCOkOA1&Il-ZGDrtA$1C&Y,Wn*-3MC'wvePL,;'XuG6gEs^Rdh0H)iC*%Mc:$W+7.(:`P[Fj-^PYG9W8F[<BkE'YniC_KDm,IM:IUo%[.mU*Uf%_TN/GVE6&J^VbX#ioGf$W0jlte%Pf$s'*ET0OO@`eYH=qV53KVTWk?I:[7)t]ODK&S7f-IXxQ*)toA=#TvXqtDg0,)_u]&tr:vI:LPPtlx-x[s1T)L%ANrnQg4MqONUYDs'Jj$QO]MK_A+*Ds-`$GpslJX#pi]X#);pEsXijotv?K)3OgI=h),0[_Pf=HRtf+TM^xe>BnwTx0ru]<Es/ZZ%^92lA%cGPO[mclOulINP8`9OJnrW&%'s`7cstC&k]dd.-JTu]O>HR(*>pk`Osc*gtG=X70T5C%K0AG%KRiVq/]ZSnL8bkP;ohkV#i[(u#.YPbsaA2qm[e'dMi9+(KAqgk/0]'l2Wj>)W=3>`R[`m[FtbV)%(eNRD`.%EEWP^KsP3=skYaiGsMo3TY=8-gmd/ZUVRW=9oteWbDk+SBf3q?Ds*N_v#PX[L'PNRt^K]@UFi6`JFbbRVs]Y5u>]U'Q1x^^51q/JHsCwIHs&P@i'iPfO%gx>HpCS-KsurY%-+kQQs]a*TsZd1:6;vlYs)adkA;6`Em8A$*ID=Gc%`/jt`'nM?V]6ddfXI3obA;(6b1QwhlQ'ubO=$c?J.mToDcmAi51&%iK;Q-`*U%EZ`[%&9^bSdRjolX9asg(f:YeU_O_q)jQ0VkKQ.x>xTLkajOoF:5Nc>AVLF78fG'SOWmFx6[bDXeEsjl2+)LjsngBYIR@_I=.)NojKliOcU;,.`0_LASDsM`Mx)X$BZsU<hO-()lXsJOH+;[vZRsw9<UI*5/dtF1qq-Ijvw+nO(.LE'Loevfa<u',F`sr..&*@J7stDPOv,T'KV:p*^)I[QQAJ&TWDskvwI(=uYTXmJC&Ux4?tO/b:F;86CC*E(6L#/<8^tIC]b,.5rG7%:gZC=*-HA^'s6/enZR%a&;*J:Of*A^<8sOU=uq$:&wCsJ7:Es&`@WsGLGe_9WsWsYl6Ks,`ZO&/2>_t2n]]t]/]htRd+^%F^ht>SpUFn$`ei%4,Cs6Oju72WpLx9YcDi%jc@UZW4Ig$0pf:$ZmR@FB+^ipAB0s^@e#]4>]V[4?R'+hc1Lc%T4'UMQLQ>#Z`x#*(g[R[`]N.:(^gb24X'u#)dWRs9Dso9LWopt)YX$0IU%VsQg3_j,.D_tTbPdf<'(Js#l8c24]0lO(8RX5Xrhff'2Ge_IQ+4UnSN%tjD(%*'Er6[CO%.:)IIq;$pKu#q&M`tVAMTfm%WWs@(96]D$Ok=Gn2u)#vJh^s=Bu5@]tns%g-O=x#Cbt;X:n:aJDotLP)KMD7<Dsg]rS%vmAX#;h-w#6>x3]KH2lXLF=mCfcC)A&7Au,L#uat=_l-9%E(Al;@Du`9hjj[J-OI(<&ZeZ_9`xoWcS(*qX>l=T-G`%YC]S[R7H=`4q(E<HO'(*N,Crj3']C]Tk2pM%8?-Gw8x6D:(Gc%G2X7b5QpoOiqqPI0u1(tBBEx+_O%HuH7agsfap_fRx9FXLOrcsQcn%uN*;$>>B&r$Tv8T@-[#NsD*5qt[qJI(vW^kA)/2.(8%Eu>)G-ntf2Ytl//Cc`DxT_OUD;otKR;otjXdfs(d$rrA[_Rsx+snOO$>Qs<L&wOV<_V$6:JbVwtD1'9XV$upsBhpXL2+(vKcXYG_%7IQ`(7INpkIs)-'>a%k$m?(J+(?,N9LaqelP'3G0Us<EN=Gn<IMqafteURBVRs(f;wtYY[:6li$N'j8&giKkA7%DQ/()+p>77X%cpsTJPg)98^bpV>rJ/j[$VD>SU[%f_b'[jVseOe&+,>WE[U=jBaqOP+j8b9qt@[GLKc%NwhQs'3Z:XV_Z2Ee^*#??=?9F@q7x_eZ?%MT&IhEFb_7.g@WPWmf6UW/OHpOOvjNG(@_4E/+Gc%x%QntwZ8&tWMSTsCkEWsukvn%Q5.(*&bPno&1X8-3SNltrx7gOM_gLY=]wxL66vLi&Z?]LX4xP]>(`0_tK+<T$5abO`()J-G_BUsK&XkO/D:lFXD^hO,OxCRaHMpI@M9Z$&?QALI<L%/Y+-+20]7_-X:,DsXI*o/p/xT$g^[WZ&2B=#+td(WFY)l(?fVkJ%tv3g>xXZgHxKEsoE(C&U'WK&77b-IDUvq$or=:$6BYYs`(A#MLtFfOPUJ]tBR+Xs9()^OP-Ubt7Dskt2,tkO.bJ]t5#)t-7x:mL;u<[$nAcRaN9jiUX4]p.k1_diW6u>#dII.(ngWltxLRcs7=veOsD7Csm&iBs.`pxt9oOn*++`qQN)c?-;'$e3^6TEs#cu^tYTi^OdK`qQCf=7sGjkv-:=8+Mp$WGstwr#lF5b-_*PP'tKt'dOQu'rQ,:%(3[O%(3c9T/]M)7uO;:BHsec:tOI]XqQEi=+M.]8+M*jhQCeg8kPc=;viHvw')_[S]tEnAv[[A,pOe'?.$dXfah&0W`sq]>o)<V?sHWpF,-co(WHNk^k,c'bGVr5.1-5R+dV%)6g,o-aX6:rH0'SjsJC<fPW-wh<(&#>@(&DqYtLgk[O&.5L[0;2`$'XEO[0(L=(&W[EKNGrGU$v+jcsaL%?PFYR0't--4%Frr.rZRM#Y_F9Es+]71'OL71'm.6Vsi07RRM:?_twGuQsxM(RsT:WGVwI8nO?nTO/<6TWU.FaehIr>R]w?Lf$bdg8NVEM)aUftk$pYriPULxP]CXZ=L4Y_9MDI$2aCKJ;M?x_=LM5kB%@6G-QD$[v>Bp$a$3+nQNE#LjBUv[CSo:XGRUAx3?S$Z*RbrE(S$$:N'Ab]$XVJfNI%fUFp>_rGsc.$x4tj=s1AhUb;#eStf)Q%rZOXm*M:Kg+gBxA[5Xk?mOE(:%FsS8_O)cC7%CS0U[2dN]t^EI+M$<l9%'t='uI80U[drI#/H<pEsa]/I$*J?bs7pRL^9;)N'ZSp3]lXMZo*uaLsvD#ft5EMX-7;Nb.Nf0DsN?e0^@;n-$;kO0156i3]G1[1_/JdVs>.XGs,B9EsmTccsl)>_/xwk'N@fn&Mmr/[s25>C/o:*P=8bR.*%Rwst&'oBJ.Qq(MG%xk&mA=_tvio?K?lXKL)[5+;',7RR#d=_tixB^sYI1akVo>Ns?Hs-$5R^@4r1,FsE`+QsN:Cjt,U#tL,=D#RkfHRR.6B]r_7(:$9e7Xlt9)fZ)*t,ZgeuPWNcjrU0-uwSl:LhO_PfnMI?H=K?=S+H2b9GHK6ZXKOv[nMl&)aOaGjqL-biLFJc#1Hd?bCK'TVuMguuf%Go.,[Vxr/ZZY-:WZ;(]UXg4DTE(coOw-NJiuFOvB'BknD0cn^I0U5TLH,+gOfWBpU&s.KXM'[bZkl$V_-8QHJPR?qOdd4-S%;n^U-CCMZ+[HF]&3W?_a+v6*OBkW_+m3TIjfXvDHEv%CxCeEA5YDvL/?3c@0mVa%]fRJL>]gtNFZ&L[Isl29wKvq`;HBbN=`5UOGj]-]G[9[V<4)@DJb:]PJn$os_Hu)Sp&YZL4mFWLgcpoJH['k,b$N$#+)*4T.C2BT4>t#KpV#o*LvK0*2qU[,uUG=P_/.A-)t-A-DQ&;/o,M.).uB`N.`i=-pvaC42Ag58@P[i1OK7asJ+v$,:OdK&t&/lL*m(1N0#J&KtiA$KB1Xcs>UFv-mlOvL0x-tLX_CH-.bpG.Ab=3D5.'2hBk,3hE+w`,iC#Q8INe9D1^w>LfGsM-[A%m-DB@nN;3X$#bS>R*A4CU@f_cXP<4CWL306BSn3HaSbi05T-Gvg,qBnU)j`#ST-G2--6OR$#b%04KuSs#KnbU^Tn&uvLGlfAKgHJKo#bU(s%nh(s^oB_tF:VGs7sa-rtB[20JL9c)$sp;.1vxB/Tl:=G*u:=G:0kdpIGF.u0;o/1OeE8VdRTkJ%v*Ds*0qc).]Yu#>K,N'5_CXPF*wCjbhCbsi)Ax$6n$:QvnL5//1h'uLVYDN+UCkf@CBHsx?dNs@R[RR)An*MlV$N'wH(2tNLrCsXVC($g_'+DP<oY-f_.F.F0ae-V)8vL`T'x==rs(t<RFv-3E2dMr1^Z.f'wnsK`Vq1f>clsHJLI1N0:^so20%M;-NbV?9C=?'NO/*hafjg#TMaO?F410PPg-MaVBSsYrYFsM7$bsGFKv)@fBeV8HSRA`i.8u;.2O4#TDeL2aKO=kqkSMs4mTsuj.4tS(qkB]Uc.ul4_5M=`SbMbNI$Kv01(AR,b@t6nVa-)&Q_A?9McM03+Uee+$h-i9rrD./e3FEU(1gR6i]GfTQ*INA&+tbi>eqHE&ps.Rdn@G^*-%SL[G%MMBvH:r0pLn6;k%WhE)&1HdA4vSOsQ'Pe%'51j5&c?7fQ^:1n&-PtDs,9L3';EG$,,#(%#14>>#G2W]+YM5D<Cr,AFB;HfUGHl:d1mc7n+(E5&D]IS@2[duP3ih+`M]+v,F^fc;RBKPJ^BdrZ6Jn1pQoO;-[(eY>L^x+`?:5GrDQ]G;r74)NbbJDWGw6At09^A=c;D/L&K:8nDXc87`$:#Y@,-vl7NDmA9^pMT=]5m];a9#lRlbv,;]*B43.uDNs^L#YvqP/h-^u,2r2u8IZ$Fvlf7^^+QN*39>Z9QSfx/QfD&U#lu^sm/avnm8SXr#G)?evYiJDZcMP=$,l4ia<*P+-MLe<H`IEaZPkb$-i*J6[#6/.e2^34wGUvJ<QWWW^t0;jB4?>0tZ?Z0'ka%3_=Oc.hUwNsajWpUk'R9Rq7+M=hL&aKU.4^j0CFk4bax,Q[>A^p6So[_0hoW=40Ol#.D0/:R]<9FeiAHvt?<iJOKwe*4TBdg'ki+nb<kqbeV[_^noUW(S&k&oU7p[qosPYr^O;vxPYLTs8FUw&kEWQidYo`oS&4CHXfAJ<C<%ou1P*qmc%QT2=D4PqoD6>,1Pr?$c%uL9W&6v?<cmuqS&&J5+;nP41u4cU_$/s=-[=PxWD:sa8MY_w(^H[uAUYi>8JYDQm8hw'g@`'q_@-M%OWr&Db%,h4j^n-atax--riE]$K[N'.?DT@@6DTv<B[jcoS&/15(fRkIeUr0,c;]#oktPQjdt(pnh%ArRhTR@.h$^0+k0+aW^,=1$J:5ZIDs37r'VL%HQ&>-N_^:GPCom$%5U?;ORXAnki%R*nFK0?#uJLWgHs])X)sJ9LP1g9A#-]WE&%AMI%>6wvV%^KsA,c.;&&eoObD>u^X#]$<`tgHZc%on2)jfY,fdKu>4_GHi^O,`DQ&tcdl76_-i9#ImO8/@$+D09PU?`',oJxx)w$M;%[sQZOoL>PCEs@)I#MEHA#McG-QsIGpEsuGHq;E(SVY^T_Ds_J1rtgU&et*hEBI=[CeOn/Gs./GUJsV$hZs=?`tO@F87G'`cX#VHdv2D@Jh,3(=i'R6VCEP;H92uHpqdmhPI:*Y$LG7Mo/1r*xZSF.EdD.EWP]Ab^T`DRen7g>QR7-`/et,w?@%<afS1MPPY#.s?ntpEqL2l80.v+UAA-q(5>#I(d[sw,'S1`b-uPh(;OJAwvO/<&pE@makoL:*TwsEnU_%M3HK%[<7Y#4Y+19PW31ujS%_OBQjdt0L=x=$[w_<_nXGM*5?UZVCK:uwb]KMjuIj1JL7:mw2,Q&FHDu,]fI%+wD@Q/B<vt,S-QbDC+9K%s(uDsG=3atOqDZ6'Y(d*dPbH2lC*Ls@I`e:3'WTf8fC`tlch=3#?5Q&QH/kt1_xKsS/E8n9.:lLI5=m'dX_U$Q&_btjkt`Of(,L^2xAVatRpm%4-aTf8c:`t*67]-L`v34fiSo*P]pk1P#WJJs/Y[47uQ]c:#id*41D$57]Cr$ipMFiPp%Fi;;#r$.wft>JNgn@L`^0ki1uDsi_%f0JQqt52rtq-B4o*M+H/4tU7qhLgp0xX07bwXE==R-f7rp.>.Oi$>Uua7P&EV6Flm_sn/ttt3I+Q&]9Fi'r[lYsAtZRs%d<ps>LM=-EP57%s+5[$Opn]t+P9lO7o-#MoFU]tN/f<uaN.uhGos20$+Qu6rMl^tes4?GAvo^A(tw5D7hm]rYrpS&r)K+2HZ802_$#9-iN$iLWC&T&a1$:;$m9X:a+aq/Sdv'vCIiR%B5e^4RBG#v_+f]Xi`7eaobL+r#w7>#]tabO$g<d2/_anqg]YxuArk;W*/Z1g20-F.'p>kMTdcN[KpsOonN2vunNBfB@69Q&_xZBUPB[>le5a$-e5t,>%/Q:v7l/wLeop[<:-<5&nrW:vGMh1vUG'9;9nvU7$lvV%i[ES,sC/-<UPqS&j/<#vGQ^2v$diA.%in>.K$aX%ig&.ouf'Dq0q[C]r9la%*X?dj)X=>#=Q#pLqZKkR6dAm]M&?lfIacLLOh#Ur:,Cs-[.J+MN^q0Mdp`]+?O:_8.]L%,Ujc=l2kKtOmtq^oW('gLMIM>9?(vR.MgS]tZ41UoFdG`,?heE(b?Nvu^ce4XLB*Sp,Wd`*K+<>#$f%wuAbNep+W*PZISkS&[AIHj<k/.(_`B+EcH&_S@d3sk%[$.0$?ob/X@G:voYRf9'3Kn'aOSM'vCP:v0H)UQwtbgV2x9>#_Nh3vDOd5LW,xpAK1LG)W*Qt1qKP:6aVS.(=';i'Ct-]Bc07e%uw=43aBi`aQ)fKcB@.77xtdb2'S0%Ov3qoDE4Gc%ig&.o9,aSZV4,;[,4?9V*`6TeCH/(-5Z5.(o_TDs'#ottI=0gOx:)&Iav/mtk]$qL/st&#3G:*]JaIc%>(./[J.['[hs<RDXoeYDRWQ#u@qJas'3amJ'[1+?rc['XVLCcsO_($u]`=OMkkcS&JpsP??bp_-2Po^fDi[^7`2=>#?#lCs%=9MsmF-f:X@477=WwR.#T(0CCjE5-,W`*7CV*E3^@HF)gcP7JWfK_,_lrI?$/sa%2s*84<VGwK(,1lO*R/Q&V*NFS/3+^bDax(-*_u^f1'/^O.pMuMn(eQXe=Vn*,_-o**s$i)3VLx+t;(S<Yto_%<N19UYq[F1vL^gkZ3>A>(Vkj=WSmp1-U&Q&og/gR&WBvcU2fOMak9Q&IZ]Z&1_[e*//'*3cB0b94769:mj_;gp:$'hJ42<H8JIpg7X2e*a<NvuBqcMjDEkxuqe2lOTh*Q&rJo_OQ+<5&ER;>#5B88vnqaUIrk19fPq6q$36t,>&2Q:vYResOG,$+qiBwW%?4g$vaw5_UZ.3:IIhP#u?h/Es%eG^X`oi/ZDu<%^w<Pa%wgHW$*LsbQTpefOa6?WB^)hdOr#Y[S*vQ[$@i8GKT%97.#JtpOrdOVL8$CQ&El:a*B^eV%[Lq06vA5M_f-TgZJ.NmfdMtpa'kRgU-L8lOGOW.(14S[tm]^_IT`%^*v?sGse5f_OixB3k<@VRsQ.=]sR:=]sFMfk8M0P(*vHo$ted'W..I+Q&bBA?7iA%%+4@:Jsj_GNDh<)'5Y,(jtWKRSs(6'F`O'pF)i2i$u@[rcsQ70D46SR=GuGKr;Vk1lOuf3kOYLf3fR()cMj9P[rHM6Q&IuLI(;g]Ye8+aRS1/oRTf&W4FC_XVdkY(kO&l:tLRbGc%.feOTaHTZ-h))GsTFs-$c*`vYfMLnOTqtuOe[TM:JA/fsx=xB-I#^EuKq2QfW?e_iE1Trt(wSE<S$x2jqpBQ&gm3-3K.N^J-NivT=nr#UvKWaJ4Eka*=hhT%xxoS_D)uDs/$>pO6j,Q&W+(J:URJCoosq*D+QH+;/K3lO@hKOfs)/d<_n[_&[S_A5&CDX-gX^9TcuGF`c5fvtrdCnUbQ4@=p&%vt.Xq$%i`R^$$qY]>g9G<DJA;ehJ)$gU`cOgORPa&b?p,E[nX`eh'tS8IGI6qOX:oq-Tp_X,%aD'Q.,6%--V);hpHd>cQkgS>.[>B=L^cR4CTogOc3nL0Fg4hOD;3s]vc^.=l2[Rcuu;Wgs7rT'9DZ%-QEs?]LJP:v;bDfOkX#G_r&+,2mDR:vHYS7vqMlZQ1]$s$IPl?kdsw'3iWAo.YY2]bwf>[0n7rV1e^2<#3#4cinhR:vp=wfLew(&t5YxSorw.Yc.u6>#Htt%v31sscmg].6AYaa%:V'?5.??.IVv#F%r)K+2@$</2_$#9-dHSgRaH$OFVge)c;vpo.ZwtuuoGOgrBkpE:Zb387CqT:vFql*v(^m,6QXUe(/jYT.>*mXhHpue+TPPY#unAi*.>Ij91]q58:?j(^Q<Q`Bh^`XBRafw]I';iO<g?#TnbWLs.71DJ/m/cI]669:(I-BXukPtULYW@=RSWDNr].nObNBF_8<<59JC^&=f)'cKbMUg%6e$wefG*Q&vEJ;T+SN+27,aaO+9>l=u<,%C*C0%fnEUi$-WvEK1^FQ&5gmt=V]MuO1cx)fr=/k$7@:(@2E%fOqs;qVilu_Fq?nn9K^[x6wLl/_]<.Y#meN19V]tD+:83+)MFmEj[9to9%/(l]xs#k0MTR'%D*?=,J+x0B'Y8U%4UoR/u2gxY_6]RjM=4Z,>dxnjUUxL'dH'%4]mAT8Llc]OBa7c7]f+n%hvHa*`7(B4gG=-v:.R/1l8At#=6pLp,SV:vYnw(MOvi:#6JP:v`Og9vb?Af1tCZAMa,<5&7VX:vojEdOjPRR*YRZ`Ovn-+mQx3ci_-6>#.WW&v=-/*O+`M&-x0LG)5v=>#h^F0vVf5(dsU=%531`e2aB:>#X.Ad%S/GoO`,^e%<#@hadG^S8,%i?%Y5's7@U+Cf/<m>BC[udOxd$@%m9)Z/Ha9$r)Mjdt/3[@%4DP19XF*CW.6Kdk:,qR%tq@Y'Ku?T.;Fc=K7(QZ%dcAmAMEZeHwAdPL_V/Gs8CG^tFcc=RlY2:6Ui6u_n=he%wvF[oe]/(3d@jLC;66Q8(wp=m6s7:-bT69ooNOG<+oK0>([8O5+GZ>_9#TFnd3+'R@^pwkWPM.1V#+.1x1)r;qe^eO.g?*Z+46N^mi0lOeFKc0woT^FgNvaIH4u=;?mY]T3tHc%R.-%KGmfhO[:c`$xv;(h?>`h?L<s>&Jj`^4MfsI(.>IU?J.YU$$M(%-[wN+<pQ&T&.Y2CZf/%%+%bgj0V+-10.-FxsT^kXYQ^:T%qsokt6TAoO%?Y.(b0tDso4qj$@os;KV**jO3hoGQYQ(&KB7:9NYOgHZ..]RsOe;9cWP`DsuXUrta4L.:S,'c;mi(Q&6sa=6kN5v$L'N)>M]a=,-iC1N?w?W&s)Y.(PY)E3j$q7?sYw8[fa%qO.-OI($rc:-H%Ho3f5H`%g*qi^jlj@hlv2r`ZK.fOqkx14<n$ctnI7Q&[8g<*&M9SrIA_Rs@X,(*<D@=,O6YFCM[&g%H_7nL*j0M%,U3:0sARX/P.uDsdkx/(OfC?ujUn`%+,Q.1M?7%FZw.Y:hQY`%QhHE0vPbYc#2I`f)x#5JR`Qe$I=xc,'&:c`8I=>#uxD%vR_+:):aO+`7tCr$;nO_-2=P:v8:$:v:R3Jf'%V<De(El]6lQ:v/=CrOU(;>SB/NpI2dk2UI(`wEtEsrO6miOsORjf1]vX)s]LV7I.:wk&EE$%+Q%/30<.tPAi=:&npnfC=9SPU&kfU.(x>%NB__(dBWXja*=Ni60L7j37hNh[,W5I(=9IsS&c5Jj%ufLdOl<x;Tq/_Z$S.,HK0Y'u#>*wrOhWT7G7Xne%qqT*]&=HQ&'(-#.jO<Lscr]_j>%1lO[S]7.K,Tet_Y8_jFS)c<)U&T&KU^FGjjge(3^tn%Rc/n^&-Je*l,CY-mx]6E5hF7I`7'sC_nGc%@ORoOk,JLO/<@Ns5V5^tgv%q*NP+F3vW1fqVcQ:vXwK9v@7N0ft2LdgLw)B4?:FkO^jX`R8@EdD=AJUFqVltO@=?3q.t@Hsdd7vt4b4cOjgweFoju]$chQeRvw9>#k7]pLOLOh`#RrIhT(>>#YXr.vY@I^#AE?D*Y^=lLm3F^OQ0@Psl%019O]c7%V<Y1'vQ(Is-@'l7v&*T%^HF/Uxrdahg#lU%tn[9B@cMx9K2V'LT_5^toDY,eEuCsO=Zrg@pEDQ&;R%cRx^0(oJ4Wk-2g#+B7]GG<+I.-bsWc>BxoLa%^g;a*4%B?-ftlit$7x2-X:4[UpLQf%K[A&FFb0DIX&JVLFle`%LdX=^'4-F]BGsII+F;d%xg*GHKVrOF^H#=M]tX,HhrCsZAYZ7XZA$UWKa9pWfK>m]kvwd,P_%`<+BFXs9SM+Rfc*cRsUPPWeO6iO^EGOFI'9oNHPFQ&Ng<f:c#snsROL_$I,rI?>?b^%Bg9,V/Rg8X5;u;d$Dv%m(vfObH:Ng%^@XueD:5sH<4O(ILdJgOe64lL5nof$Ie<<-aS&n$^dU^T.I;BT+G;--.####u4T;-4:eM0pvK'#(5>##*$?tL(g=L#m?Y>#-<)mL>4pfLe@6##FvX?-345dM_VV8&;54GD]BTT93c>A+4iZlEwYAeGx]`f1)>MMF`E<;$Fklxu>TJ8RWO$##dB_O;PjlB=GJMe$H&>uuQoRfL7nR`Ec0S.#AroF-DwchL_R6##08P>#8&krL]RQ>#gNb&#tAJ>H*=6p/0g^D4<(O88%]g3bvrIfLI-HIP-Fl(N]TC`N-9x%FcWJ.#xw51F)Ym*NA7$##wLYS.+GY##AA081Cke%#k`[@#c)#/&IpchL/k20C'B(;?F4Me$wVml&:t+/(Ucsx+nHel/0/V`3kF,290LD>#sF.5J5AvV@>R1L,a%m._>[3>djY^-66%MS.3cCK2TDP`<Mjb3=.L@VQvIF&#4D4B#2dkuGSCI2Lg?Ne$a)FqDe1dER5oLS.&Cg+Mb[F)#X+^*#HbFoLt'B3M0(^+ixOO&#YN,W-,.OX(Wdbe$.;$v#cWn7R5)fl^T78F.fn;'f5g53#5(A>-;NYO-E<dD-S6v%.6%AnL`-'P#rYGLMH))TNJThlLeC_l8uNhA#LsJp&@1D'Sq2[`*_fg,.r*9SMBb?1MtT320'#-v?8c5,a=,]'8(u@J1aVTc;TMHL>^hfL>M;&3:riF>#GQb3=<fR)#x4n0#:(02#RqG3#kd`4#-Wx5#EJ:7#^=R8#v0k9#8$-;#PmD<#jixX#+Su>#CF7@#[9OA#t,hB#6v)D#NiAE#g[YF#)OrG#AB4I#Y5LJ#r(eK#4r&M#Le>N#eWVO#'KoP#?>1R#W1IS#p$bT#2n#V#`4G>#LF?5.u;NJM'M`PM#5;PMQFq0M#1,GMY[n2Lx+G>#'2*Y(r?L&#m[jV7/(lA#:Gg;-rHg;-t^U[-ipX_&5@l-6L9)UMD-1SMJuBKM7XFRMfj&3M`GVG)vjvf;d@/s7ZD:&55KK/)E1T;.7Kkm'&2>>#bVU_&L2P:voo_+VXQIQ0u%G>#G[N_&GqPTMG&*(vF4)=-=tcW-:>:4kr$p34NA,LMw(C0Mubj.L$cx.iBb(^#>G@&,-iF]ulfooSuE=Mqv:+Au$mQfr7^,g)4DBJ`VUeQKsp@>#Sr;V?S%+GMJv6A4$o<X(9DBL,G3be$81Sk='1oQaXI/2'+Jju5#[c984I>A+v3FV?Nu%8@OZ8g2-'8L#tBu@XQmoG3J*<L#5w=5&e#q%4mYbQjil`oI+6qx4?uPi^?oIA4A+OY58;;)3a6@>#fpWoRDb<t-gPrfLM.x`EckB`N19/[%-a;W#cSSX#&JlY#=:.[#U-F]#nv^^#0jv_#H]8a#aOPb##Cic#;6+e#S)Cf#lrZg#.fsh#FX5j#_KMk#w>fl#92(n#Q%@o#jnWp#,bpq#DT2s#]GJt#vC(;$7.%w#Ow<x#hjT#$*^m$$BP/&$ZCG'$s6`($5*x)$Ms9+$ffQ,$(Yj-$@L,/$X?D0$q2]1$3&u2$Ko64$dbN5$&Ug6$>H)8$V;A9$p7uU$1xq;$Ik3=$b^K>$$Qd?$<D&A$XDaJ%X=7[#0hG<->Hg;-]Gg;-LGg;-`q`=-8scW-=iRX(f7`e$nBPX(U,Z_&qYce$C'be$[1KR*v8__&PNbe$I8_e$Wc_e$H5_e$1Fae$i@`e$vR<l=ieW_&:vj'8sAu=lGd9SI&%Re$'#;Yl-n<Ac)lkA#<e%Y-d]U_&[#9F.mW<F.LBbe$^7KR*TX/:2B#_e$<g^e$;d^e$PJUe$Uq+`MRQB_MA[Wk#B=dD-:lG<-?Tx>-lmG<-qnG<-L:)t->(ixL1[sMMnI8bMD-UKMOp?TMSVEUMiUY*$LJA/./.GwLDo#u#<Cg;-qO,W-?+`q;0gU_&D)_e$FxNX(c-DVZbJ7;6AQ4@0t]Pe$+MOR*OO&FI1QH'oaqOX(PnG_AT(W_&POee$(*^e$7oFR*,$x1^(['a+;:]PBHY`D+^F7qremaw9W&8VMY)3c#oF0t7Vwxc3PNKVe)4Z;%3:tiC^`6#62,=2_p.$@0a#6v6BJTe?K`M_&QX]_MY2eTM6SC[MQI-LM-YAFM@35ciXn_;%b9UGEhkflgI1tY->0W8&6TgJ)8gG,*D(9v-E1T;._<<Db.>H;@KD^VIdV><-_mG<-30A>-xFg;-3#L&8(@/s70OvV%L/2_]Qme3OFh>TM2?BW$KBLqV84u4f#h_pBSWK_Mt/3c#_<k(NV2ZX$N2-E>'.,GMV7D`Niq18.m3io.qKIP/ud*20TFKOp&KK88UvZP'9mTc;l.6D<C?C?+@dNjL/rf(NBT8SRXrh.Ufha(WpH#AX-,Kl]CI%G`TQ9]bnw:ci+>lERneH?#CL@@#BV&E#WuSE#[+gE#T`6K#u>]P#1^4Q#6jFQ#;&cQ#B>1R#Ro$S#Z1IS#cInS#iU*T#rtWT#w*kT#&=0U#5t,V#A6QV#INvV#MZ2W#QgDW#k.GY#9UR[#c,q^#1,E`#`Bic#<Zbe#mesh#MKMk#$pXm#b[?(#'2G>#7192#^_kgLTb6lLZ0nlLaTNmLg#0nLmGgnLslGoL#;)pL)``pL/.AqL5RxqL;wXrLAE:sLv8J0#%,>>#/th;-PRPkLqV(8*IpKSIq=bo72=(AOJ#p4Sc_a(W%ERrZ=+Df_Ug5YcnL'Mg03o@kHo`4oaTQ(s#5lY#;kSM'SPEA+l675/.s()3FXpr6_>bf:w$SY>9aDMBQF6AFj,(5J,io(NDNarQ]4RfUupCYY7V5M^O<'Abhxn4f*_`(jBDQrmZ*Cfqsf4Yu*8>>#f5Ch$%2j^oG-5>>qa;,<P?*j1v%?<-Exe7(ZSFL,c.`e$F/_e$0YT-=WMU[-h`W-=%q//1h@N;7HmgX-`FOR*e4`e$.vM@K2>YI:`/JT&&2>>#**3b$@1>R*.%/@:pZP8/mJ<;RVej/Mw+G>#$JV_&./Q/:hO[A,rV[Z-u%G>#6YUe$HwYTM1^)aM-i^H:.]PR*wxH'?(P,W-v@*44ugfe$gvmA#m]?:(;OQL,v75kD.rJfLcu+%&hw>A+-'8L#o_a+VS)P)4M29L#nJnIqU;1a4J*<L#3@=D#9i1$#HV&E#I;WD#mVq/#o*lQ#pQ/a#=vm(#Dv;%$n=;mLPoQ>#KOg2#hiGN#l6>##P97I-<5T;-B5T;-H5T;-XG%n&)W$@'$Y,i$;@hr6-#w4A5(rr$EWCG)^=5;-v#'/10+Y&#vnde$3Mde$_#ce$&&de$%#de$8VQe$1DOcM47P`N9R1AODorw'N`8GMcKpGN?'IYPm/I&#k)I&#m/I&#o5I&#sG[&#ndE'Sd+BK<dTkd854l3bxhH_2&&wX.Ni)`MU(Vp.56c=Lchp0,92%@'rYhi0E<VY,pE(&+Wls.C2.35&S,387E@YY,]H-87,[VW%(a:D35wJ_&SjQ]4<E#)3'A/;6(THG)*1ux+T,YD4S#>)4;wdw'3Q,F%K,l-$Epk-$Gvk-$Fsk-$kC*:2V0UDt`i-5JxP7F%ucSY,Q)PW1ihvr$AuBM9Bnil/*=3F%K,l-$Gvk-$cp(x'PPc##e86&M24ItLj?W$#7x.nLcJH)MxqJfLamH+#7IhhL1x.qLt'd.#$IonL^G/8#Kqj1#a@+gLU8RtLJ&7tLbk>.#_]O.#u[AN-4@Rm/`i<9#xa%-#<YcD1'tx=#-i/*#aZS=#N.r5/^@r$#xq$YMbw`^#Qc/*#VfZ(#Z3dr#7lJE#4(,'$mo]a#^5T;-;dQX.Uufa#6?:@-Jp8Z.l2FA#k2u41<MsD#weUv#VPu>#4bCH-P@Rm/>D6C#88OA#e97I-p`oJ.FNHC#coq5/Mx;`#VW5lL]<*mLBMO/M4/o`*JW0Vml<>5Ajm[D=%+$g;QA2#Z)4_E[)8<;?qi,F%M+$v,7ncuY3QDMB[*$/Cb53?Qp[?20xVADE7S1kX_:.wu5Sv;#7_>pM#Y_P8J51&=@#B;I%rv2(?DgrQ,0V/$7a#3#G+GwL*5Qt7BIPF%NPc##8YlS.^S(vume1p.W-M$#bwwJNMC?##52a.$cqe%#r_7:.1?*29T(RML8q-k:SRklAf9i=u)YZ/$*gQ(#hG%+MACp?PG(_=ue,k-$sF_=uBwr-$)]XD*oM#KNw(`^#)P#dM%Kx0#oIi9.=V8a#MFP8/3f3W7AE$,M4PU2#L$iH->@9gLf_d^Sw'59#Yi/*#PMa+M%*TJ1<a0j(M(:I%O/ll/cO?_/Gda-?-deIq'1UY,f?R:vHC]:dq%CDbfZx4pa-EVnC'0;e>OR]c0&+2_3/f5^fDMY5p]`Ee`pEM9YCi)4P;:5&l*DAlfxO-QWt5R*ZYl-$5X=G2qg&/1/H&F.LM/;6jXfS8*3QV[dHhZ-/ww(<p<k4o:qb;7R9XG%k*jl/%LLk+=?*58iHfQaUa[QsbkJGNs&-)OWMD2Ck^;8SvPIF%=7YcMA<_a#k<-C#X3SoSKvH+#6qF6#%sLG%V?*29=7gr6In?W-9/j&H&.BJLQC?5/:VVQ/?MQ_#]U'B#ZHwM1EO,_fMVcCj7k`Y#gi`QjiZL7#EQ6(#-1x%#G+ixL*ecgLkZc9#rJP##B3_'#Nhn#Mc2$)MY*elL5phx$RS(vuku=:v/3/HX^7vf(EM:<-Ut%'.eZu)MtZWo$,GuG-/7T;--<+,NON15SZap`33uYRE^WNp7@%FW8kJ?.%5sc9DYm&;Q9c:.$1K,F%Gwn-$;i(;QLY1F%)qj-$vX$##;ao-$x]p-$8In-$bol-$27n-$f%m-$*vp-$h+m-$qGp-$dvo-$ShMF.=r2F%1=9/D91MMUXwJGNJ'I21:4*F7pMW^#OK&a#:R'DMpq+9#qhY29]doQaK]>M9N$U4fP;:5&0cEG)PvMk+7^wf;w&0W-PJq92BCJ_&5ivr$^*/F%I'o-$a&a#$4BN/M4W-2T*RTs7uKk4o>fPk4@M;5&U?^w'`gEM9mF>M9DjVG<?h./Vv&WG<nOBk=WmMuLU8RtLliv)M44v.#0w3$M)qT(McGm6#<NEjL9V]F-'Z`=-hmWN04->>#=*F]#vWajLC3(E#4p]a#DYe[#^p^^#aAFV.e/O]#+cPhL0bf7nkn]W7(A;JUYsRM9cO]88,SQF%2lP%t/TauPJg%9/Y4ffLo>UiqAB<)=@WZT8gWwY#w%iM'Wm&g26W*n^Vc@ipcBR>#e7XA+uuMcs-<1q'so('#ZW_TMf4Y9#,Bq-%jqd=u3f-j0eZxf1s>5a4&E7RNWR,^#1TRwT)I;_8v_$##t'*<-&sEn//5YY#%(gE#cYU).aLOgLJPvu#-B;=-[bK`$ADH&Mj;(sL:/fiLb^_sL=w(hL,6%&M,)doLGDS;%aH,kbPwLk+q:hiU<a0j(;E@&G@'kEI6x88@=<_W7o2B8%[q.2Tlr)pfQlRfLOINv'iZ&<-c+O$%qoG9rux,.64]s)#ocBK-l],5M*LLm8RC1^#Fxsb.JdK^#f`CH-6UEr$-Z(G%aT:T84?/p.xKhl^.&?2Lik+T8C*729S1VG%en?M96)IG)99MM%07#kkYE6F%WMZ20x1rvu0BbxuL+ww'C.;/:xxGv?IX[F%)8d39#?8H<5C:58@sK?7bjXCP4h4onZvb39TV*x'd3AvPALoV%U1%X-d;vE@(b'3DE9mI)7ivr$OgnFi15hT[kR)$-1<-/()6)fqUlrR/Vh`i0Gx55/:mt;-R5a_*FgO2('FQ8/RPwpKMU]v$4/7mSX3t_&54iAOG>sFreh<Sn^AcF%?b%##NBs-$Co(##Rj6R*,TC_&<Vq-$-(n-$-uKB#adv_#X?gkL/JhkLcVP8.PC'&+'`'B#(4&cN9lL%MV$#d2&<7VZlb4;6R775&(q85&N=m-$x>__&&1;GD_Ev+DP#?@daA?/(<PO%t?]ADN(+U]OW%gY,7aK;@]K-Au354m^4hs:mivt1qhrOpS6M_lS+,l-$DC>GM#Zk]>`e5^#HM#<-;6T;-S]Gw.Ju;D3[Uaw';CGG)*/22'sx.;692/873#x_s(;iu>+KM8]w:&,Mud)/#ud2<#1vx=#.H+.#gXj)#pxhH-sYlS.M$,>#ue^01(ul+#_Q`,#Rq`8vNh'S-<).m/*8g*#l`r,#sYlS.vN:7#/BpV-l-B-doAp-$*5JG)3lEG)V*GG)4t9=O]2)##", 
			shadow = "\x89\x50\x4E\x47\x0D\x0A\x1A\x0A\x00\x00\x00\x0D\x49\x48\x44\x52\x00\x00\x01\x80\x00\x00\x01\x80\x08\x06\x00\x00\x00\xA4\xC7\xB5\xBF\x00\x00\x00\x01\x73\x52\x47\x42\x00\xAE\xCE\x1C\xE9\x00\x00\x00\x04\x67\x41\x4D\x41\x00\x00\xB1\x8F\x0B\xFC\x61\x05\x00\x00\x1F\xE8\x49\x44\x41\x54\x78\x5E\xED\xDD\x8D\x92\x24\xC9\x89\xAE\x61\x69\xA5\xFB\xBF\xE2\xFD\xD3\x67\x6A\x4C\x08\x81\x3B\x1E\x99\x59\x95\x11\xBC\x8F\x59\x98\xE3\x40\xE4\xCC\x56\x55\x43\xF5\xEC\xB1\x3D\x7F\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x60\xE3\xAF\x7F\x4E\xCC\xF5\x5F\x7F\x4E\xCC\xF4\xBF\x7F\x4E\x0C\xC4\x02\x98\x87\x81\x8F\x15\x16\xC2\x20\x2C\x80\x19\x18\xFA\xB8\x82\x65\xF0\x70\x2C\x80\xE7\x62\xE8\xE3\x9D\x58\x06\x0F\xC4\x02\x78\x1E\x06\x3F\x3E\x89\x45\xF0\x20\x2C\x80\x67\x60\xE8\xE3\x37\xB0\x0C\x6E\x8E\x05\x70\x5F\x0C\x7D\x7C\x13\x96\xC1\x0D\xB1\x00\xEE\x87\xC1\x8F\x6F\xC6\x22\xB8\x11\x16\xC0\x3D\x30\xF4\x71\x47\x2C\x83\x2F\xC7\x02\xF8\x6E\x9F\x1C\xFC\x2C\x15\x98\x4F\x0F\x6A\x16\xC1\x97\x62\x01\x7C\x27\x06\x3F\x7E\xCB\xA7\x86\x35\x4B\xE0\x0B\xB1\x00\xBE\xCF\x27\x06\x34\x43\x1F\x57\x7C\x62\x68\xB3\x08\xBE\x08\x0B\xE0\x7B\x30\xF8\xF1\xAD\x58\x04\x0F\xC5\x02\xF8\x7D\xEF\x1E\xD2\x0C\x7D\x7C\xD2\xBB\x07\x37\x8B\xE0\x17\xB1\x00\x7E\xCF\x3B\x07\xF5\x2B\x9F\xC5\xC2\x98\xED\x95\x01\xFC\xCE\xE1\xCD\x22\xF8\x05\x2C\x80\xDF\xF1\xAE\xA1\x7B\xF5\x73\x18\xFA\xC8\x5C\x1D\xC2\xEF\x1A\xDE\x2C\x81\x1F\xC6\x02\xF8\x59\x0C\x7E\xDC\x01\x8B\x60\x08\x16\xC0\xCF\x79\xC7\xF0\xBD\xF2\x19\x0C\x7D\xBC\xE2\xCA\x30\x7E\xC7\x00\x67\x09\xFC\x00\x16\xC0\xE7\x31\xF8\xF1\x04\xBF\xB1\x08\x58\x02\x1F\xC6\x02\xF8\xAC\xDF\x18\xFE\x27\xFD\x2C\x09\xC8\xC9\xA0\x3D\x1D\xCA\xEF\x18\xE2\x2C\x82\x0F\x61\x01\x7C\xCE\xAB\xC3\xF5\x53\x83\x9C\xA1\x8F\x95\xEE\xB0\xFD\xE9\x45\xC0\x12\xF8\x00\x16\xC0\xFB\x7D\xE3\xE0\x67\xE8\xE3\x8A\x4F\x2C\x03\x16\xC1\x17\x61\x01\xBC\xD7\x2B\x83\xF6\xB7\x06\x3F\xCB\x61\xB6\xCE\x40\xFD\xB6\x45\xC0\x12\x78\x13\x16\xC0\xFB\xFC\xC4\xF0\x7F\x57\x1F\x43\x1F\x99\xDD\x60\xED\x0C\x5E\x96\xC0\x8D\xB0\x00\x5E\xF7\x13\x83\x5F\x3A\xBD\x0C\x7E\xBC\xC3\x4F\x2E\x02\x96\xC0\x2F\x62\x01\xBC\xE6\x27\x86\xFF\xA7\x07\xFF\x2B\xFF\x33\xE0\xFE\x56\x43\x74\x37\x60\x3B\x03\xB8\x3B\xA4\xAF\x0E\xF3\xAB\xEF\xE1\x1F\x58\x00\xD7\xBD\x32\x38\xBB\xEF\x7E\x6A\xB0\xBF\xF2\xEF\x8E\xE7\x5A\x0D\xD3\xAB\x35\xE9\x0E\xE9\x57\x86\xF9\x2B\xEF\x8E\xC5\x02\xB8\xE6\xEA\x00\xED\xBE\xB7\xEB\xBB\x3A\xDC\xAF\xFE\x7B\x63\x96\xAB\xC3\x7E\x37\x84\xBB\x43\xFA\xEA\x30\xBF\xFA\xDE\x58\x2C\x80\x73\x57\x87\x68\xE7\xBD\x5D\xCF\x95\xE1\x7E\xE5\x1D\xCC\x72\x65\xA8\x5F\x79\xC7\x74\x06\x75\xA7\x27\x73\xF5\xBD\x91\x58\x00\x67\xAE\x0C\xCC\xEE\x3B\x57\x07\x75\x55\x3B\xCD\x03\x52\x0D\xD0\xD3\xBC\x5C\xAD\x99\x4E\x4F\xE6\xEA\x7B\xE3\xB0\x00\xFA\xAE\x0C\xCE\xEE\x3B\xAB\xBE\xD3\x41\x7E\x92\x5F\xFD\x73\x31\x47\x36\x30\xAB\x21\xFA\xAE\xBC\xAC\x6A\x5E\xB7\xCF\xBB\xF2\xCE\x38\x2C\x80\x9E\x2B\x83\xB2\xF3\xCE\xAE\xA7\xAA\x9F\xE4\xBB\x39\x20\x1B\x9A\xDD\x9C\x9C\xE6\xCD\xAE\x2E\x9D\x9E\xE8\xCA\x3B\xA3\xB0\x00\xF6\xAE\x0C\xCB\xCE\x3B\xAB\x9E\xAA\x76\x92\x7F\x25\x87\x39\xB2\x21\xF9\x4A\x4E\x4E\xF3\xB2\xAA\x99\x4E\x4F\x74\xE5\x9D\x31\x58\x00\x6B\x57\x86\x63\xE7\x9D\x55\x4F\x55\xCB\xF2\xEF\xCE\x61\xAE\x6C\x50\xBE\x3B\x27\x55\x5E\x56\x35\xD3\xE9\x89\xAE\xBC\x33\x02\x0B\xA0\x76\x65\x40\xEE\xDE\x59\xD5\xAB\x5A\x96\xBF\x9A\xEB\xBE\x87\x39\xB2\xE1\x18\x73\x9D\x1E\xE9\xE6\xA4\xCA\xCB\xAA\x26\xBB\x7A\xE6\xCA\x3B\x8F\xC7\x02\xC8\x5D\x19\x8A\xBB\x77\x56\xF5\xAA\x96\xE5\x63\xEE\x4A\x4F\xF6\x0E\x10\x87\xE4\xEE\x2E\x57\x7A\x4C\x95\x97\x55\x4D\x76\xF5\xCC\x95\x77\x1E\x8D\x05\x90\x3B\x1D\x90\xBB\xFE\x55\x3D\xAB\x5D\xCD\xBD\x7A\xC7\x4C\x71\x30\xBE\x7A\x97\x57\x72\x66\x55\x93\x5D\x3D\x3A\xED\x7F\x3C\x16\xC0\x7F\x3A\x1D\x8A\xBB\xFE\xAA\x7E\x92\x8F\xB9\x77\xDF\x01\x89\x03\xF2\xDD\x77\xE9\xE6\xCC\xAA\x26\xBB\x7A\x74\xDA\xFF\x68\x2C\x80\x7F\x77\x3A\x18\x77\xFD\x55\xBD\x9B\xCF\xFA\x76\x3D\xFE\xBE\xEB\xE5\xFB\x0F\xF9\xBF\x3F\xA7\x89\x43\xD2\xDF\x57\x35\xC9\x06\x6C\xA7\x47\x4E\xF3\x66\x57\x8F\x4E\xFB\x1F\x8B\x01\xF0\x2F\x71\x38\xEE\xEC\xFA\xAB\x7A\x37\xFF\xCE\x7B\xAC\xF9\xEF\x7B\xAC\x61\x16\x3F\x0C\x57\x8B\x20\x0E\xCD\x77\xDF\xCD\x69\xDE\xEC\xEA\xD1\x69\xFF\x23\xB1\x00\xFE\xE9\x74\x08\xEE\xFA\xAB\x7A\x96\xEF\xE4\x56\xF7\x6E\x2D\x7E\xAF\xE3\x7B\x98\xCD\x0F\xC4\xAB\x8B\x60\x55\x93\x78\x97\x6E\x4E\xAA\xBC\xD9\xD5\xA3\xD3\xFE\xC7\x61\x01\xFC\xD3\xC9\x30\xDC\xF5\x56\xF5\x2C\x1F\x73\xBB\x9E\x55\x7F\x15\xAF\x06\x7F\xFC\x3C\xCC\xE4\x07\xA1\x8F\xBB\x8B\x20\x0E\xD2\x55\x4D\x56\xFD\x26\xCB\x49\x95\x37\xBB\xBA\x77\xD2\xFB\x48\x2C\x80\xB3\x21\xB8\xEB\xAD\xEA\x59\x3E\xE6\x4E\xEE\x55\x2C\xFE\xEE\xBF\xBF\xD9\x3B\xF1\x5D\xCC\x64\x83\xD0\x0F\x44\x1F\xFB\x45\x10\x87\x66\xF5\xCE\xAA\x4F\x76\x77\xC9\x72\x52\xE5\xCD\xAE\xEE\x9D\xF4\x3E\xCE\xF4\x05\x70\x32\x00\x77\xBD\x55\x3D\xCB\xC7\xDC\xEA\xDE\xAD\xF9\xF8\x64\xF0\xFB\x18\xF3\xF8\x01\x68\x71\x96\x93\x6A\x11\x54\xB1\x74\x6B\x12\xEF\x92\xE5\xA4\xCA\xCB\xAA\x96\x39\xED\x7F\x8C\xC9\x0B\xE0\x64\xF0\xED\x7A\xAB\x7A\x96\x8F\xB9\xD5\xBD\x8A\x25\xAB\xED\x06\xBF\x58\xEC\x73\x80\x0D\x41\x3F\x0C\xAB\xD8\x16\x41\xA7\x57\xBA\x35\x89\x77\xC9\x72\x52\xE5\x65\x55\xCB\x9C\xF6\x3F\x02\x0B\xA0\x67\xD5\x5B\xD5\xB2\x7C\xCC\xAD\xEE\xA7\x71\x36\xFC\xB3\xDE\xEA\x7D\xCC\xE5\x87\x9F\xC5\xBB\xDC\xE9\xDF\x06\xAA\x58\x76\x77\xC9\x72\x52\xE5\x65\x55\x8B\x4E\x7A\x1F\x63\xEA\x02\x38\x19\x7C\xAB\xDE\xAA\x96\xE5\x63\x6E\x75\x3F\x8D\xED\xFB\x98\xD5\xBB\x39\xCC\xE4\x07\x9F\xC5\xDD\x1C\x4B\xE0\xE6\x26\x2E\x80\x93\x81\xB7\xEA\xAD\x6A\x59\x3E\xE6\xFC\xBD\x5B\xB3\xD8\xE7\x4E\x7F\xEB\x5F\xD5\x30\x93\x0D\x3D\x3F\xFC\x62\x6E\x55\x93\x93\xFF\x24\xE4\x63\xE9\xD6\x4C\x96\x93\x2A\x2F\xAB\x9A\xD7\xED\x7B\x0C\x16\xC0\xDA\xAA\x37\xAB\x75\x72\xFE\x5E\xD5\xAA\x1E\x1F\xC7\xDF\xFA\xB3\xBE\x4E\x6D\xE2\xCF\x00\xFE\x25\x0E\x6F\x3F\x04\x63\x6E\xD5\xB3\xFB\xDB\x40\x96\x33\xDD\x9A\xE9\xE6\xCC\xAA\x16\x9D\xF4\xDE\xDE\xB4\x3F\xFC\x7E\x10\xEE\xAC\x7A\xB3\x5A\x27\xE7\xEF\x57\xE3\xD5\x6F\xFD\x59\x7F\x75\xC6\x05\x82\x99\x6C\xE0\x55\x8B\x20\x9E\xB2\xAA\x5D\xFD\xDB\x40\x15\x4B\xBC\x4B\x37\x67\x56\xB5\xE8\xA4\xF7\xD6\x26\x2D\x80\x93\x41\xB7\xEA\xCD\x6A\x9D\x9C\xBF\x5F\x8D\xB3\xA1\x6D\x71\xF7\x8C\x9F\x61\x27\x66\xB2\x61\x67\x67\x77\x11\x54\xA7\xFC\xC4\x12\x88\x77\x53\xE5\x65\x55\x8B\x4E\x7A\x6F\xEB\x6F\x7F\xCE\x09\xBA\xCB\x6E\x35\x10\xAB\x5A\xFC\xEC\xD8\xE7\xEF\x27\xB1\x4E\xFB\xEC\x6C\x70\x57\xC3\xBC\x3A\xAB\x7E\xCC\xA5\x9F\x09\x0D\x6C\x7F\x4A\x96\xAF\x4E\x3D\xE2\x73\x62\x77\xA9\x62\x3B\xA5\xEA\x91\xDD\xDD\x54\x79\xA9\xF2\x99\x93\xDE\xDB\xD2\x17\x6B\x82\x93\x41\xB7\xEA\xCD\x6A\x31\xB7\xBA\x9F\xC4\x3E\x67\xDF\xA7\x58\xEB\x9E\xBB\xF7\x31\x9B\xFD\xB6\x1B\x4F\x1B\x82\x55\x7D\x77\xC6\xF7\x25\x8B\x7D\x4E\xAA\x7E\xD9\xDD\x25\xCB\x99\x55\x2D\x3A\xE9\xBD\x25\x16\xC0\xBF\x5B\xF5\x65\xB5\x5D\x2E\xD6\xED\x5E\xF5\x64\xF5\x77\x0E\xFF\xAA\x07\xB3\xD9\xA0\xF3\xA7\xC5\xEF\x5A\x02\x12\x6B\xB2\xCA\x99\x55\x4D\xBA\x39\xB3\xAA\x79\xDD\xBE\xDB\x9A\xB0\x00\xBA\x43\x6E\xD5\x97\xD5\x76\xB9\x58\xCF\x6A\xBB\xDC\x95\xE1\x6F\x71\xF6\xAE\x8F\xFD\x89\xD9\x6C\xD0\xE9\xF4\xB1\x3F\xFD\x22\xA8\x7A\xAA\xF3\xDB\x96\x40\x95\xCF\x9C\xF4\xDE\x0E\x0B\xE0\x5F\xAA\xBE\x6E\xDE\xDF\x3B\xB5\x55\xCE\x7F\x5F\x62\xCD\x9F\x55\x4D\xEF\x67\xB5\x55\x1F\x66\xD2\x80\xEB\x0E\xF7\xD5\xDF\x06\xB2\x9C\x3F\x3F\xBD\x04\xE2\xDD\x9C\xE6\xA3\x6E\xDF\x2D\x3D\x7D\x01\x74\x87\xDB\xAA\x2F\xAB\xC5\xDC\xEA\x9E\xC5\xAB\x9C\x7D\x4F\x62\x4F\xEC\xCB\xCE\xF8\xAE\xCE\x5D\x9F\xE5\x31\x93\x06\x9C\x0D\x39\x0D\x69\x8B\xFD\x19\x73\x55\x9F\x9D\x55\x4D\xAA\x25\x22\xAB\x9C\xF8\x58\x76\x77\xC9\x72\x66\x55\xF3\xBA\x7D\xB7\xF3\xE4\x05\x70\x32\xD8\xAA\xDE\x2C\x1F\x73\xAB\x7B\x16\xAF\x72\x57\x86\xBF\xC5\xD9\x50\x8F\xB1\xA8\x2F\xAB\x63\x26\x0D\x37\x1B\x70\x3A\xFD\x80\xF6\x79\x3B\x2D\xDE\xF5\xD9\x19\x73\x52\x2D\x01\xDF\xD3\x89\x65\x77\x97\x2C\x27\x55\x3E\xEA\xF6\xDD\x0E\x0B\x60\xDD\x97\xD5\x62\xCE\xDF\x4F\xE2\x78\x4A\x1C\xCE\xBB\xD3\xE2\xEA\x3D\x1F\x57\x0B\xE2\xC9\x3F\x03\xD8\x8B\xBF\xCD\x5B\x5C\xE5\x63\x8F\xC4\x7A\x3C\x63\xCE\xDE\x93\xAC\xDF\x9C\xC6\x12\xEF\x92\xE5\xCC\xAA\xE6\x75\xFB\x6E\xE5\xA9\x7F\xF8\x6D\xC0\x75\x54\xBD\x59\x3E\xE6\xFC\xBD\xAA\x65\x3D\x59\xCD\x0F\x68\x3B\xAB\x7E\x5F\x8B\xC3\xFF\xA4\xC7\xE7\x31\x93\x06\x5B\x35\xC8\xAB\x7C\xA7\x27\x9E\x31\xE7\xDF\x33\xB1\x27\xAB\x89\x8F\x65\x77\x97\x2C\x67\x56\x35\xD3\xE9\xB9\x9D\xE9\x0B\xA0\xEA\xCB\xF2\x31\xB7\xBA\x67\x71\x3C\xC5\xE2\xEE\xF0\x8F\xB9\xDD\xF0\xF7\x9F\xEB\x6B\xF1\x3D\xCC\x65\x83\x4D\xA7\x86\xB2\xBF\x5B\x4E\xEC\x2E\x31\xDE\x2D\x81\x2C\x27\x71\x09\xD8\x29\xAB\x9C\xF8\x58\x76\x77\xC9\x72\x52\xE5\xA3\x6E\xDF\x6D\x3C\x71\x01\x74\x07\xDA\xAA\x2F\xD6\xB2\x5E\x9F\xDB\xC5\xAB\xDC\xAB\xC3\xBF\xEA\x89\x43\xDE\x72\x62\x77\xAB\x63\x2E\x1B\x6A\x3A\xF5\xC4\x61\x6E\xF5\x6C\x39\xF8\x7B\x36\xCC\xAB\xD8\x9F\xEF\x5A\x02\x3E\x96\x78\x97\x2C\x67\x56\x35\xD3\xE9\xB9\x15\x16\xC0\x7F\xCA\xF2\x31\xE7\xEF\xBB\x78\x95\xBB\x32\xFC\xE3\x10\x17\x8B\xED\x6E\xC3\xDF\xD7\x2D\x27\x56\xF3\x39\xCC\xA4\xA1\x66\xC3\xDD\x06\xDC\x2E\x27\xB1\x66\x75\x59\xF5\x48\x3C\xAB\x25\x60\xA7\x9C\xC6\x12\xEF\x92\xE5\xA4\xCA\x47\xDD\xBE\x5B\xB0\x61\xF2\x24\x9D\x81\x56\xF5\x64\xF9\x98\x5B\xDD\x2D\x5E\xE5\xEC\xF4\x83\x3C\x9E\x55\xEC\xDF\x89\x3D\x76\xB7\xA1\x7E\x92\xC3\x5C\x1A\x68\x7A\xB2\xE1\x5E\xE5\xC4\xEE\xAB\xBA\x9D\x55\xEC\xCF\x93\x25\x90\xE5\xCC\xE9\xDD\x54\xF9\xA8\xDB\x77\x0B\x36\x50\x9E\xA2\x3B\xCC\xAA\xBE\x2C\x1F\x73\xFE\xBE\x8B\xAB\xD3\x0F\xF2\x78\x56\x39\xFF\x4E\xAC\x65\xF5\x55\x4E\xA7\x58\x0E\x73\x69\xA0\xD9\x23\x36\xF4\xED\xC9\x06\xFE\x6E\x09\x88\xFF\x1C\xC9\x7A\xE2\xB9\x5B\x02\x76\x4A\x27\x96\x78\x97\x2C\x27\x55\x3E\xEA\xF6\x7D\x3D\x1B\x10\x4F\xD1\x19\x66\x55\x4F\x96\x8F\x39\x7F\xDF\xC5\xAB\x5C\x1C\xC2\xF1\xCC\x62\x7B\x27\xD6\xF4\x74\x07\xBD\xFF\x0C\xAB\xD9\xBB\x98\xC9\x06\xB5\xE8\xD4\xE3\x87\xB7\xD5\xBA\x39\x8B\xFD\x30\x8F\x35\xC9\x72\xFE\x1D\x7F\x4A\xCC\xF9\x9A\x64\xBD\x66\x77\x37\x55\x3E\xEA\xF6\x7D\xBD\x27\xFD\xE1\xB7\x81\xB6\x53\xF5\x65\x79\x9F\x8B\xF5\xAC\xB6\xCA\xD9\x19\x87\xB5\xF8\x33\x8B\xFD\xE0\x16\x8B\xF5\xC4\xCF\xB3\x9C\xC5\x12\x73\xF1\x8E\xB9\x34\xCC\xF4\xC4\x61\xEE\xEF\x12\x73\x96\xCF\x72\x16\xFB\x81\x1E\x6B\x12\x63\xF1\xEF\x64\xA7\xAC\x72\xE2\x63\x89\x77\xC9\x72\x52\xE5\xA3\x6E\xDF\x57\xB3\xE1\xF1\x04\x9D\x41\x56\xF5\x64\xF9\x98\xF3\xF7\x5D\x5C\x9D\x7E\x58\xDB\xB9\x8B\xB3\x61\x6E\x8F\xFF\x3C\x9F\xF3\x77\x89\x39\x7F\xB7\xCF\xC0\x4C\x7E\x80\xC7\x61\x1E\x07\xB8\xE5\xFC\x5D\xB2\x9C\xC5\x56\x93\x58\xB7\x33\xE6\xFC\x3F\x77\x75\x4A\x27\x96\xDD\xDD\x5B\xD5\x4C\xA7\xE7\xEB\x3D\xE9\x0F\xBF\x86\xD9\x4E\xD5\x93\xE5\x7D\x2E\xD6\xED\x9E\xF5\xAC\x6A\x36\x78\xC5\x9F\x31\xB6\xBB\x1F\xD4\xE2\xEB\xF6\xBD\x8B\xB9\xEA\x2E\x31\x67\x31\xE6\xD2\x20\xF3\x03\xDC\xC7\x12\x73\xD9\x5D\x62\xCE\xF2\x3A\xAD\x26\xB1\xE6\x63\x3B\xD5\x2F\xB1\x26\x59\xBF\xF1\xB1\xAC\x6A\x92\xE5\xA4\xCA\x7B\x9D\x9E\xAF\x67\x43\xE4\xEE\x3A\x43\xAC\xEA\xC9\xF2\x31\xE7\xEF\x59\xBC\xCA\xD9\x69\x5F\x6B\xDD\x7D\xAD\x8A\xFD\x70\xB6\x9A\x3D\xF1\xB3\x2C\xD7\xBD\xC7\x18\x73\xF9\xC1\x5D\xC5\xDD\xBB\xF8\x9C\x1E\xB1\xBA\xBF\xEF\x62\xFF\x79\xAB\x53\x3A\xB1\xC4\xBB\x64\x39\xA9\xF2\x5E\xA7\xE7\xAB\x3D\xE5\x0F\xBF\x06\xD9\x4E\xD5\x93\xE5\x7D\x2E\xD6\xED\x9E\xF5\x54\xA7\x7D\x9D\x75\xCF\x7A\x62\x6C\x03\x5A\x2C\xE7\x6B\x12\x73\xDD\x7B\x16\x63\x2E\x0D\x31\x3F\xCC\xAB\xB8\x7B\x17\x9F\xB3\x47\x7C\xBF\xAC\x62\xF1\x9F\xB7\x3A\x25\xCB\x49\xD6\xE3\x65\x39\xA9\xF2\x5E\xA7\xE7\xAB\x69\x00\x3C\x41\x67\x88\x55\x3D\x31\xBF\xBA\x67\xF1\x2A\xA7\xD3\xBE\xC6\x3E\xB7\x8A\x7D\x7F\x7C\xC4\x0F\x70\x3D\x27\xF7\x2A\xC6\x5C\x1A\x62\x7A\xFC\x70\xAE\xE2\x93\xBB\xF8\xBC\xD5\xC4\xEE\xB2\x8A\x7D\x7F\x76\xCA\x2A\x27\x3E\x96\xDD\xDD\x54\x79\xAF\xD3\xF3\xD5\x34\x04\xEE\xAE\x33\xC0\xAA\x9E\x2C\xEF\x73\x27\x71\x75\xDA\xD7\x58\x77\x5F\x8B\xB1\xDD\xFD\x60\xB6\x9C\xC5\xB1\x76\x72\xCF\xE2\xBF\xFD\x39\x31\x97\x86\xD8\xFF\xFC\x39\xFD\x30\xAF\xE2\xD3\xBB\xC4\x9A\xF8\x9C\x54\xB1\xEF\x5F\x9D\x92\xE5\x24\xEB\xF1\xB2\x9C\x54\x79\xAF\xD3\xF3\xB5\x34\x08\xEE\xAE\x33\xC0\xAA\x9E\x98\x5F\xDD\xB3\x38\x9E\xA2\xD8\xEE\xF6\xF5\xF5\x7D\x31\xF6\x77\x3F\xA4\xC5\xE2\x58\x3B\xBD\x5B\x6C\x03\x3F\xD6\x31\x97\x06\x98\x1E\x1B\xDA\xB6\x0C\x7C\x2E\xC6\x57\xEE\x7A\xC4\xD7\x24\xAB\xFB\x58\xD4\x2F\x59\x4D\x56\x39\xF1\xB1\xEC\xEE\xA6\xCA\x7B\x9D\x9E\xAF\xA5\x21\x70\x67\xDD\xE1\x95\xF5\xED\x72\x27\x71\x75\xDA\x90\x15\x7F\xDA\x23\x16\xC7\x5E\xFF\xF8\x61\x7D\x7A\x57\xFC\xF7\x24\xE7\x63\xCC\xE5\x07\xB5\x8F\x77\x7F\x2B\xB8\x72\xB7\x47\x7C\x4D\x62\xDD\xC7\xEA\x15\x5F\xCB\x4E\xC9\x72\x92\xF5\x78\x59\x4E\xAA\xBC\xD9\xD5\xBF\xDA\xDD\xFF\xF0\x6B\x80\xED\x54\x3D\x31\xBF\xBA\x67\xF1\xEE\xB4\xAF\xAD\xEE\xBE\x16\x63\xBB\xFB\xA1\xEC\x9F\x98\x3F\xB9\x2B\xAE\x86\xBF\xFD\x6D\x40\x77\xCC\x65\x83\x38\x1B\xF8\xDD\x25\xF0\xDF\x2E\xF6\x35\x89\x39\x7B\x94\x17\x9F\x93\x2A\x8E\xFD\xC6\xF7\xFA\x53\xAA\x58\x76\x77\x53\xE5\xBD\x4E\xCF\x57\xBA\xFB\x1F\x7E\x0D\xB0\x9D\xAC\xA7\x93\xB3\xBB\xCF\x67\x71\x76\xDA\xD7\xD5\xE7\x62\xEC\xEF\x7E\x40\xEF\x6A\xF1\x5E\xFD\x67\x1D\xC5\xD9\xF0\xF7\x39\x3B\x31\x97\x86\x97\x0D\xE9\x6A\xE0\x6B\xC0\xC7\x9C\xC5\xFE\x3F\x19\xC5\x5A\x76\x97\xAC\x26\xAB\x58\xBD\xE2\x73\xD9\x29\xAB\x9C\xD9\xDD\x4D\x95\xF7\x3A\x3D\x5F\x49\x03\xE0\xAE\x3A\x83\xAB\xEA\x89\xF9\xD5\x3D\x8B\x77\xA7\x7D\x5D\x75\xF7\xB5\xEC\x1E\x7B\xFD\x63\x03\x7A\x75\xD7\x40\x8F\x35\xCB\xAF\x72\xFE\x8E\xB9\x34\x58\xFD\x80\x8F\x77\x3D\xAB\xC5\x10\xF3\x9D\xBB\x3D\x12\x6B\x52\xC5\xEA\x15\x9F\x13\xDF\xEB\x4F\xA9\x62\xD9\xDD\x4D\x95\x37\xBB\xFA\xD7\xBA\xF3\x1F\x7E\x0D\xB1\x9D\xAA\x27\xE6\x57\x77\x8B\x57\x39\x7F\xDA\xD7\xD4\xE7\x62\xEC\x73\x36\x90\xE3\x13\xF3\xAB\x7B\xF6\xB7\x80\x98\xAB\x86\xBF\xEE\x98\x4B\xC3\x4B\x83\xF5\xCA\x12\xF0\xBF\xFD\xFB\x7C\xE7\x1E\xF3\xE2\xF3\x12\x63\x89\xFD\xAB\x53\xAA\x58\x76\x77\x53\xE5\xBD\x4E\xCF\xD7\xD1\x00\xB8\xAB\xCE\xE0\xCA\x7A\x76\xB9\x5D\xBC\x3B\xED\x6B\xAA\xBB\xAF\x65\x77\x1B\xC0\xFE\x91\x58\xF3\xC3\x3C\xD6\xF4\xF8\xFF\x9E\xEF\xEF\x96\x5B\x0D\x7F\xF5\x62\x2E\x3F\xD8\x57\x4B\x20\x1B\xF6\x3E\xE7\xF3\xBB\x9A\x74\x6B\xE2\x63\xF5\x8A\xAF\xAD\x4E\xE9\xC4\xA6\x9B\x8B\x3A\x3D\x5F\x47\x43\xE0\x8E\x34\xB8\x76\xAA\x9E\x98\x5F\xDD\x2D\x5E\xE5\xE2\x69\x83\x55\x74\xDA\x23\xFE\x6E\x5F\x7B\x9F\xF3\xB5\xEC\xEE\x07\xB7\xAF\xC5\xBC\x5F\x08\xBB\xE1\xAF\x18\x73\x69\xA0\x56\x4B\xC0\xE7\xFD\x3D\xEB\xB5\x27\xF6\xF8\x5A\xBC\xFB\xBC\xC4\xBC\xC4\xD8\xF7\x76\x4E\xA9\x62\xD9\xDD\x25\xCB\x45\x9D\x9E\xAF\x73\xD7\x3F\xFC\x1A\x5E\x3B\x59\xCF\x2E\xB7\x8B\x63\x2E\xE6\xED\xEB\x69\x35\x5F\x8F\xB1\x0D\xE1\xF8\xC4\x7C\xBC\xC7\xDF\xEE\xB3\x5C\x1C\xF2\x31\xEF\x73\x8A\x31\x97\x06\xB6\x86\x6A\x67\x09\xC4\x81\xEF\x6B\x3A\xB3\x85\xB0\xBB\x67\x79\xF1\x35\xF1\xB1\x7A\x25\xAB\x89\xCF\x9B\x2C\x27\xBB\xBB\xA9\xF2\x5E\xA7\xE7\xAB\x68\x00\xDC\x91\x86\xD7\x4A\x55\xCF\xF2\x3E\xB7\x8B\x77\xA7\x0D\x5D\xD1\x69\x8F\xF8\x7B\xD5\xE7\x6B\xF6\x64\x03\x7F\xF5\x1B\xBF\xBF\xFB\x7C\xF6\x9B\xBF\xD5\x31\x97\x86\x56\x77\x09\x74\x96\x81\xD5\xB3\x7C\xAC\xF9\x47\xB2\x9A\xC4\x58\x7D\xE2\x73\xAB\x53\x3A\xB1\xE9\xE6\xA2\x4E\xCF\x57\xD1\x10\xB8\xA3\xDD\xD0\xAA\xEA\x31\xBF\xBA\x5B\x1C\x4F\xF1\x39\x8B\xED\x6B\x69\xB9\xAC\xC7\x62\x1B\xC4\xF1\x89\x79\xBB\xC7\x81\xAF\x67\x35\xDC\x7D\x4F\x56\x57\x6C\x7D\x3A\x31\x97\x1F\xEE\x1A\xAC\xD9\x90\xF7\x43\x3C\xAB\xFB\x7C\xEC\xD3\x63\x3D\xD5\x3D\xCB\x8B\xAF\x89\x8F\xD5\x2B\xB1\xEE\x4F\x59\xE5\xCC\xEE\x2E\x59\x2E\xEA\xF4\x7C\x15\x0D\x80\xBB\xF9\xD4\xBF\xB3\xFF\xDC\xD5\x3F\xC3\x6A\x59\x4F\xCC\xC5\xCF\xD4\x63\x83\x38\xF6\x9A\x55\x9F\xAF\x89\xF5\xF8\x5E\xDF\x13\xEB\x0C\x7F\x44\xFE\x67\xC1\xFF\x6C\xF8\x9F\x1D\x8B\xFD\x23\x56\x17\xDF\x23\x16\x5B\x8F\xE5\x2B\xBE\x2F\xF6\xFA\x7B\xF6\x39\x96\x8B\xA7\xB7\xFB\x8C\x9D\xCE\x3B\x57\x3E\xF7\x57\xDD\xEE\x5F\x18\x00\xF0\x1E\x2C\x00\x00\x18\x8A\x05\x00\x00\x43\xB1\x00\x00\x60\x28\x16\x00\x00\x0C\xC5\x02\x00\x80\xA1\x58\x00\x00\x30\x14\x0B\x00\x00\x86\x62\x01\x00\xC0\x50\x2C\x00\x00\x18\x8A\x05\x00\x00\x43\xB1\x00\x00\x60\x28\x16\x00\x00\x0C\xC5\x02\x00\x80\xA1\x58\x00\x00\x30\x14\x0B\x00\x00\x86\x62\x01\x00\xC0\x50\x2C\x00\x00\x18\x8A\x05\x00\x00\x43\xB1\x00\x00\x60\x28\x16\x00\x00\x0C\xC5\x02\x00\x80\xA1\x58\x00\x00\x30\x14\x0B\x00\x00\x86\x62\x01\x00\xC0\x50\x2C\x00\x00\x18\x8A\x05\x00\x00\x43\xB1\x00\x00\x60\x28\x16\x00\x00\x0C\xC5\x02\x00\x80\xA1\x58\x00\x00\x30\x14\x0B\x00\x00\x86\x62\x01\x00\xC0\x50\x2C\x00\x00\x18\x8A\x05\x00\x00\x43\xB1\x00\x00\x60\x28\x16\x00\x00\x0C\xC5\x02\x00\x80\xA1\x58\x00\x00\x30\x14\x0B\x00\x00\x86\x62\x01\x00\xC0\x50\x2C\x00\x00\x18\x8A\x05\x00\x00\x43\xB1\x00\x00\x60\x28\x16\x00\x00\x0C\xC5\x02\x00\x80\xA1\x58\x00\x00\x30\x14\x0B\x00\x00\x86\x62\x01\x00\xC0\x50\x2C\x00\x00\x18\x8A\x05\x00\x00\x43\xB1\x00\x00\x60\x28\x16\x00\x00\x0C\xC5\x02\x00\x80\xA1\x58\x00\x00\x30\x14\x0B\x00\x00\x86\x62\x01\x00\xC0\x50\x2C\x00\x00\x18\x8A\x05\x00\x00\x43\xB1\x00\x00\x60\x28\x16\x00\x00\x0C\xC5\x02\x00\x80\xA1\x58\x00\x00\x30\x14\x0B\x00\x00\x86\x62\x01\x00\xC0\x50\x2C\x00\x00\x18\x8A\x05\x00\x00\x43\xB1\x00\x00\x60\x28\x16\x00\x00\x0C\xC5\x02\x00\x80\xA1\x58\x00\x00\x30\x14\x0B\x00\x00\x86\x62\x01\x00\xC0\x50\x2C\x00\x00\x18\x8A\x05\x00\x00\x43\xB1\x00\x00\x60\x28\x16\x00\x00\x0C\xC5\x02\x00\x80\xA1\x58\x00\x00\x30\x14\x0B\x00\x00\x86\x62\x01\x00\xC0\x50\x2C\x00\x00\x18\x8A\x05\x00\x00\x43\xB1\x00\x00\x60\x28\x16\x00\x00\x0C\xC5\x02\x00\x80\xA1\x58\x00\x00\x30\x14\x0B\x00\x00\x86\x62\x01\x00\xC0\x50\x2C\x00\x00\x18\x8A\x05\x00\x00\x43\xB1\x00\x00\x60\x28\x16\x00\x00\x0C\xC5\x02\x00\x80\xA1\x58\x00\x00\x30\x14\x0B\x00\x00\x86\x62\x01\x00\xC0\x50\x2C\x00\x00\x18\x8A\x05\x00\x00\x43\xB1\x00\x00\x60\x28\x16\x00\x00\x0C\xC5\x02\x00\x80\xA1\x58\x00\x00\x30\x14\x0B\x00\x00\x86\x62\x01\x00\xC0\x50\x2C\x00\x00\x18\x8A\x05\x00\x00\x43\xB1\x00\x00\x60\x28\x16\x00\x00\x0C\xC5\x02\x00\x80\xA1\x58\x00\x00\x30\x14\x0B\x00\x00\x86\x62\x01\x00\xC0\x50\x2C\x00\x00\x18\x8A\x05\x00\x00\x43\xB1\x00\x00\x60\x28\x16\x00\x00\x0C\xC5\x02\x00\x80\xA1\x58\x00\x00\x30\x14\x0B\x00\x00\x86\x62\x01\x00\xC0\x50\x2C\x00\x00\x18\x8A\x05\x00\x00\x43\xB1\x00\x00\x60\x28\x16\x00\x00\x0C\xC5\x02\x00\x80\xA1\x58\x00\x00\x30\xD4\x5F\xFF\x9C\x77\xB3\x5B\x5C\x55\x3D\xE6\x57\x77\x8B\xE3\x29\x3E\x67\xB1\x7D\x2D\x2D\x97\xF5\x58\xAC\x5E\x8B\xFD\x13\xF3\xFE\xFE\x37\x17\xFB\xBB\x7A\xFE\xFE\xE7\x8C\x7D\x8A\xB3\xBA\x62\xFF\x3E\xE6\xFA\xBF\x7F\x3C\xFF\xFB\x8F\xE7\x7F\xFE\xC4\x3A\xED\xAE\x33\xCB\xC5\x7A\xAC\xC5\xBB\xF5\x54\xF7\x2C\x2F\xBE\x26\x3E\xB6\x5E\xA9\x4E\x59\xE5\xCC\xEE\x2E\x59\x2E\xEA\xF4\x7C\x15\x0D\x81\x3B\xDA\x0D\x2D\xFD\x70\x64\x3D\x31\x17\xFB\xB2\xD8\x7A\x7C\xAF\x3F\x63\xDE\x72\xE2\xEF\x16\xFB\xC7\xFA\x8C\x72\x9E\xEE\x36\xA4\xB3\x9A\x9D\xB1\x1E\x63\xFD\x73\xF4\x39\xC6\x72\xF1\x3D\xCC\xA3\xA1\xA5\x61\xAD\x9F\x07\x1B\xDA\x7E\xB8\xC7\xC1\xEE\xF3\x3A\x63\xCD\xEA\xF6\x64\xB5\x98\xD3\x63\xE2\x7B\x62\x77\xB1\xBA\xEC\xCE\xF8\xB9\xC6\xC7\xBE\xC7\xF8\xBA\xC9\x72\x51\xA7\xE7\xAB\xDC\xF5\x0F\xBF\x1F\x66\x95\xAC\x67\x97\x8B\x75\xBB\xC7\x53\x14\xC7\xBC\x7D\x3D\xAD\xE6\xEB\x31\x56\xAF\xC5\xFE\x89\xF9\xEC\xAE\xDF\xE8\x7D\xCD\xFF\xD6\x6F\xF5\x58\xCB\xF2\x16\x63\x2E\x0D\x40\x0D\x2E\x3F\xF4\xFF\xFB\xCF\xA9\xFB\x2E\xEF\x6B\x16\x5B\xBE\x73\xCF\xF2\xE2\x6B\xE2\x63\xEB\x95\xEA\x94\x2C\xF6\x39\xD9\xDD\x4D\x95\xF7\x3A\x3D\x5F\x45\x03\xE0\x8E\x3A\x43\xAB\xEA\x89\xF9\xD5\xDD\xE2\x55\x2E\x9E\x7E\xA8\xEA\x8C\xB1\x3D\xF6\xB5\x8F\x79\xAB\x55\x77\x3F\xEC\xAD\xE6\x07\xBB\xEF\xB1\xDC\x6E\x09\x60\x2E\x0D\xD3\xD3\xE1\x1F\x6B\x31\x67\x8F\xAF\x65\x77\x9F\x97\x98\x97\x18\xFB\xDE\xCE\x29\x55\x2C\xBB\xBB\x64\xB9\xA8\xD3\xF3\x75\x34\x00\xEE\x48\x3F\x04\xBB\xC1\x55\xF5\xC4\x5C\xEC\xCB\x62\xDF\xD3\x39\xAD\x3F\xC6\x76\x17\x9F\xF3\x79\xD1\xDD\xD3\xDD\x06\x78\x56\x5B\xE5\x45\xEF\x8A\xEE\xFA\xE7\xD8\x5D\xE2\x7B\x98\xA5\x33\xFC\x75\xFA\x47\x39\xD5\x63\x4D\xAA\x5A\xD5\xAB\x47\xB2\xBC\xBF\x5B\x6C\x62\xCE\x3E\x27\x9E\x52\xC5\xF1\x33\xE3\xDD\xF8\x77\x2A\x9D\x9E\xAF\x73\xE7\x3F\xFC\x7E\x88\x55\xAA\x9E\x98\x5F\xDD\x2D\x5E\xE5\xE2\xA9\xAF\xAB\xCF\xC5\xD8\xE7\xAC\x37\x3E\x31\xBF\xBA\xFB\xBF\x15\x64\x79\xE5\xFC\x6F\xFE\xF1\x8E\xB9\x34\xF4\xE2\xB0\xAF\xEE\x55\xCE\xE7\xBB\xF7\x98\x17\x9F\x97\x18\xAB\x57\x7C\x6E\x75\x4A\x15\xCB\xEE\x6E\xAA\xBC\xD7\xE9\xF9\x3A\x1A\x00\x77\xD5\x19\x5C\x55\x4F\xCC\xAF\xEE\x59\xBC\x3B\xED\xEB\xAA\xBB\xAF\xC5\x58\x4F\xEC\x8D\xB5\xCE\x3D\xFE\x27\x20\x8B\xE3\x62\x88\x4B\xC0\x7A\x30\xD7\x6E\xF8\x57\x39\xC5\xAF\xFE\x77\x7F\x89\x35\xA9\x62\xF5\x8A\xCF\x89\xEF\xF5\xA7\x74\x62\x93\xE5\xA4\xCA\x9B\x5D\xFD\x6B\x69\x08\xDC\x99\x06\xD8\x4E\xD6\xD3\xC9\xD9\xDD\xE7\xB3\xB8\x3A\x6D\xC0\x8A\xCE\x18\xFB\xBB\xF5\xC6\x7C\x56\x8B\xF7\xEA\xB7\x7F\x8B\xB3\xBA\xFF\x9B\x81\x4E\xCC\xA5\xE1\x65\x43\xF8\x64\xF8\xEB\x8C\xFF\x7B\x01\x5F\xAB\xEE\x92\xD5\x64\x15\xAB\x57\x7C\x2E\x3B\x65\x95\x33\xBB\xBB\xA9\xF2\x5E\xA7\xE7\x2B\x69\x00\xDC\x59\x67\x78\x55\x3D\x31\xBF\xBA\x67\xF1\xEE\xB4\xAF\xAD\xEE\xBE\x16\x63\xBB\xDB\x30\x8E\x8F\xC4\x9A\xBF\xFB\x01\x1F\x6B\x16\x57\x4B\x42\x79\xDD\x31\x97\x06\xAB\x0D\x79\x3D\x7E\x28\xAF\x86\xBF\x3D\xD5\xBB\x76\x17\x9F\x5B\xD5\x24\xBB\x4B\xEC\x17\x3B\x65\x95\x13\x1F\xCB\xEE\x6E\xAA\xBC\xD7\xE9\xF9\x4A\x77\xFF\xC3\xAF\x21\xD6\x91\xF5\xED\x72\x27\x71\x75\xDA\xB0\x15\x7F\xDA\x23\x16\xDB\xF7\xC2\xD7\x7D\xED\xEA\xDD\xE2\x6A\x09\x28\xC6\x5C\x7E\x68\x5B\x5C\x0D\x75\x1F\xC7\xBB\xBD\x23\x59\xDD\x3F\x12\x6B\x52\xC5\xEA\x15\x5F\xCB\x4E\xC9\x72\x92\xF5\x78\x59\x4E\xAA\xBC\xD9\xD5\xBF\x9A\x86\xC2\x9D\xE9\x07\xA3\x33\xC0\xB2\x9E\xEC\x5D\x7F\xF7\xF5\x2A\x8E\xA7\xD5\x7C\xDE\x72\xBE\xA6\x58\xFC\xDD\x62\x9F\x33\xBA\x7B\x27\xF7\xAC\xB6\xAA\x63\x16\x0D\x30\x3D\xFA\x79\xB3\xFF\xA6\xEF\x73\x59\x9C\xDD\x65\xD5\xAF\x47\x94\xF7\x35\xB1\xBB\xC4\xD8\x58\x2E\x9E\x62\x7D\x59\x4E\x7C\x5E\x7C\x4D\x62\xDD\x54\x79\x2F\x7E\xD6\xAD\x3C\xE1\x0F\xBF\x7E\x8B\xDD\xA9\x7A\xB2\xBC\xCF\x9D\xC4\xD5\x69\x5F\x63\xDD\x7D\xAD\x8A\xD5\x6F\x39\x9F\xCF\x6A\x27\xF7\x2A\xBE\xFB\x2F\x01\x78\x4D\xE7\xB7\x7D\x1F\x5F\xB9\x4B\xAC\x49\x56\x17\x1F\xAB\x5F\x7C\x2D\x3B\x25\xCB\x49\xD6\xE3\x65\x39\xA9\xF2\x5E\xA7\xE7\x6B\x69\x10\x3C\x81\x06\xD9\x4E\xD5\x13\xF3\xAB\x7B\x16\xAF\x72\x76\xDA\xC0\x15\x9D\x59\x9F\xCF\xFB\x01\xED\xF3\x3A\x63\xED\xE4\x5E\xC5\x98\x4B\x03\x4C\x8F\x1F\xDA\x55\x7C\x7A\x97\x58\x13\x9F\x93\x18\xDB\xE9\xFB\xB3\x53\x56\x39\xF1\xB1\xEC\xEE\xA6\xCA\x7B\x9D\x9E\xAF\xA6\x21\xF0\x04\x9D\x21\x56\xF5\x64\x79\x9F\x8B\x75\xBB\x67\x3D\xD5\x69\x5F\x67\x9F\x5F\xC5\xBE\x3F\x3E\xE2\x87\xB7\x9E\x93\x7B\x16\x63\x2E\x0D\x31\x3F\xB4\xAB\xF8\xE4\x2E\x3E\x6F\x39\xDF\x2F\xAB\x58\xD4\x2F\x31\x1F\x4F\xC9\x72\x92\xF5\x78\x59\x4E\xAA\xBC\xD7\xE9\xF9\x6A\x1A\x00\x4F\xD0\x19\x62\xAB\x9E\x58\x5B\xDD\xB3\x78\x95\xB3\xD3\xBE\xD6\xBA\xFB\x5A\x15\xFB\xE1\x6C\x35\x7B\xC4\x0F\x72\x3D\xDD\xBB\xC4\x3A\xE6\xD2\x10\xD3\xE3\x87\xB3\x1F\xBC\x59\xBD\xBA\x8B\xCF\xE9\x11\xAB\xFB\x7B\xAC\xDB\x69\xB1\xFF\xBC\xD5\x29\x9D\x58\x76\x77\x53\xE5\xA3\x6E\xDF\xD7\xD2\x10\x78\x8A\xCE\x20\xAB\x7A\xB2\xBC\xCF\xC5\xBA\xDD\xB3\x9E\x55\x2E\x0E\x61\x3B\x63\x6C\xF7\xD8\xEF\x1F\xFB\xDE\xC5\x5C\x76\x97\x98\x8B\x75\xCC\xA4\x21\xE6\x87\x79\x1C\xEC\x12\x73\xD9\x5D\x7C\x4E\x8F\x58\xDD\xDF\xAB\xD8\x4E\xFF\x79\xFE\x94\xAC\xDF\x54\xB1\xC4\xBB\x64\x39\xA9\xF2\x5E\xA7\xE7\xEB\xD9\x10\x79\x82\xCE\x20\xAB\x7A\xB2\x7C\xCC\xF9\xFB\x2E\xAE\x4E\xFB\x7A\xFB\xFC\x2E\xF6\x03\x5B\x2C\xD6\xE3\x3F\xCF\xE7\xFC\x5D\x62\xCE\xDF\xED\x33\x30\x93\x1F\xE6\xD9\x60\xD7\x29\x31\xE7\xEF\xE2\x73\xE2\xEB\x31\x27\x31\xF6\xA7\xFF\xCC\xD5\x29\x9D\x58\x76\x77\x53\xE5\xA3\x6E\xDF\x57\x7B\xD2\x1F\x7E\x0D\xB3\x8E\xAA\x2F\xCB\xFB\x5C\xAC\x67\xB5\x55\xCE\x4E\xFB\x9A\xEB\x9E\xF5\x64\xB1\x1F\xD8\x62\xB1\x9E\xF8\x79\x96\xD3\x29\x31\x17\xEF\x80\x86\x59\x36\xD8\x2D\x96\x98\xB3\xBB\xF8\x9C\x54\x75\x59\xC5\xE2\xDF\xC9\x4E\x59\xE5\xC4\xC7\x12\xEF\x92\xE5\xA4\xCA\x47\xDD\xBE\xAF\x66\xC3\xE3\x29\x3A\x03\xAD\xEA\xC9\xF2\x31\xE7\xEF\xBB\x78\x95\x8B\x43\x5B\xFC\x99\xC5\x7E\x80\x8B\xC5\x59\xBD\xCA\x65\x9F\x61\xFF\x2E\x98\xE9\xEA\xA0\xCF\x72\x7A\x24\xAB\x4B\x8C\xED\xB4\xD8\xBF\x93\x9D\xB2\xCA\x99\xD3\xBB\xA9\xF2\x51\xB7\xEF\xEB\x3D\xED\xFF\x0D\x78\x67\x98\xE9\x87\x2C\xEB\xCB\xF2\x31\xE7\xEF\xBB\xD8\xE7\x62\xCD\xE7\x63\x7F\xCC\x89\x62\xCF\xD7\x24\xD6\xA5\xCA\xE9\xBD\xDD\xBB\x98\x43\xC3\xCC\x3F\xE2\xEF\xFA\x59\xF1\xA7\xC5\x62\x77\x7B\x24\xAB\x4B\x8C\xED\xB4\xD8\xBF\xE3\x4F\x89\x35\xB1\x9C\xF8\xD8\xF7\x48\xBC\x8B\xEF\xF7\xAA\x7C\xD4\xED\xFB\x7A\x4F\xFC\xC3\x6F\xBF\xDD\xAE\xAC\x7A\x62\xED\xE4\x6E\xF1\x2A\x67\xA7\x7D\xED\xB3\xFA\x2A\xA7\xF7\x62\xCF\xAE\xDE\xC9\x61\x26\x0D\x48\x3D\x1A\x6A\x36\x2C\x4F\x73\xE2\xEB\x92\xD5\xA4\x3A\xFD\x7B\xD9\x29\xAB\x9C\x39\xBD\x9B\x2A\x1F\x75\xFB\x6E\xC1\x86\xD0\x93\x74\x07\x5A\xD5\x97\xE5\x63\xCE\xDF\xAB\x5A\xD6\x13\x4F\xFB\xFA\x67\xF5\x55\x2E\x1B\xE8\x3E\xB6\xBA\x58\xAD\xCA\x01\x36\xD4\xED\x11\x9F\x13\x9D\x57\x87\xBF\x9D\x59\x4E\x4E\x86\xBF\x74\x62\x89\x77\xC9\x72\x52\xE5\xA3\x6E\xDF\x2D\x3C\xF1\xFF\x0C\x80\x7E\x98\x3A\x83\xAD\xEA\xC9\xDE\x8F\x39\x7F\x8F\xB5\x2C\x1F\x73\xB1\x16\xF3\xBB\x9C\xA7\x9C\x89\x3D\x59\xCD\xCB\x3E\x0F\xB3\x68\xA0\xE9\xE7\x40\xA7\xC5\x62\x77\xCB\xC5\x9E\x18\xC7\xF7\xC4\x9F\x59\x4E\xFC\x7B\xFE\x94\x58\x93\x4E\x2C\xF1\x2E\x59\xCE\xD8\x3F\x6B\x65\xF5\xFE\x2D\x3D\xF5\x0F\xBF\xFD\xA6\xBB\x53\xF5\x65\xF9\x98\x5B\xDD\xB3\x38\x9E\x62\xB1\x7D\x1F\x7C\x4F\xEC\xCF\x6A\x7A\x2F\xCB\x5B\xEC\x3F\xD7\xD7\xE2\x7B\x98\xCB\x86\x9A\x4E\x1B\xE6\xA2\xD3\x72\x62\x77\x89\x71\xD5\x63\x67\x96\x93\x38\xE0\xED\x94\x55\x4E\x7C\x2C\xBB\xBB\x64\x39\xA9\xF2\x51\xB7\xEF\x36\x9E\xBA\x00\xA4\x3B\xD8\xAA\xBE\x2C\x1F\x73\xFE\x5E\xD5\xB2\x9E\x2C\xF7\xA9\x25\x20\x55\x8F\xCF\x63\x26\x0D\xB5\x6A\x80\xC7\xBC\xAF\xD9\xF9\xAE\xE1\x2F\x55\xAF\x54\xB1\xEC\xEE\x92\xE5\xA4\xCA\x47\xDD\xBE\x5B\x61\x01\xAC\xFB\xB2\x5A\xCC\xF9\xFB\x49\x9C\xE5\xB2\x25\x60\x67\x96\xB3\xD3\xBF\xE7\xF3\x9D\x9E\x27\xFF\x0C\x60\x4F\x83\xD8\x86\x9B\x4E\x8B\xAB\xFC\xAA\x27\x9E\x55\xAD\x33\xFC\xE5\x34\x96\x78\x97\x2C\x67\x56\x35\xAF\xDB\x77\x2B\x4F\xFE\x3F\x05\xAC\x1F\xB2\xCE\x70\x5B\xF5\x65\xF9\x98\xF3\x77\xFF\x59\xBB\xD8\xE7\xEC\x14\x5F\xF3\xA7\x54\x35\x9D\xBE\xCF\x4E\xB1\x58\x75\xAF\xCA\x63\x16\x0D\x36\x3D\xFA\x79\xB0\x53\x62\xDE\xC7\xE2\x63\x7F\xC6\xBE\x78\xDA\xE7\x8B\xC5\xB1\x47\x4E\x63\xE3\x3F\xDF\x64\x39\xC9\xDE\xCF\x74\xFB\x6E\xE7\xE9\x7F\xF8\xED\x37\xDD\x9D\x55\x5F\x56\x8B\xB9\xD5\x3D\x8B\x77\x39\xFB\xBE\xC4\x9A\xCE\x2C\xE7\x4F\xBD\x9B\xD5\x7C\x1C\x3F\x1F\xB3\xD9\x80\x8B\x83\xDB\xC7\x76\x56\x43\x5B\x67\x96\xF3\xA7\x1F\xC4\x55\x8F\x74\x62\xD9\xDD\x25\xCB\x99\x55\xCD\xEB\xF6\xDD\xCE\x84\xDF\xFE\xBA\x43\xAE\xEA\xEB\xE6\xFD\xBD\x53\x5B\xE5\xFC\xF7\x25\xD6\xB2\x33\xE6\xFC\x80\x8F\x35\x9F\x9B\xF0\xFD\xC7\x9E\x1F\xEA\x36\xEC\xFC\x69\x71\x36\xFC\x7D\xBC\x3A\x19\xFE\x5F\x68\xC2\xFF\x6F\x50\xDD\x21\x57\xF5\xE9\x07\x37\xAB\xC5\x9C\xEF\x8B\xEF\x64\xB5\x5D\x4E\x7C\x6E\x75\x8A\x9D\xCA\xD9\x19\x6B\x76\x8A\x62\xEB\xC5\x6C\x1A\x72\xFA\x79\xD0\xE9\x63\x3B\x25\xE6\x7C\x6D\x77\xAA\xD7\xC4\x9A\x58\xDD\xE7\x7C\x2C\xD9\x67\x78\xBE\x6E\xB2\x9C\x64\xEF\x57\xAA\xCF\x78\x84\x29\x03\xC0\x7E\xE3\xDD\x59\xF5\x65\xB5\x5D\x2E\xD6\xED\x5E\xF5\x64\x75\xFB\x1E\xC5\x5A\xF7\xF4\xEF\x57\x3D\x98\xCD\x06\xA2\x3F\x2D\x8E\xC3\xF9\xF4\xCC\x06\xB7\x9D\xB2\xCA\x99\x55\x4D\xBA\x39\xB3\xAA\x79\xDD\xBE\xDB\x62\x01\xFC\xA7\x55\x6F\x56\x8B\xB9\xEE\xDD\xE7\xB3\xD8\xE7\x76\x4B\x40\xB2\x9A\xC5\x9D\xF7\x31\x97\x0D\xBA\x78\xFA\xE1\x5F\xF5\xD8\x29\x31\x17\x97\x87\xAC\xFA\xC5\xC7\x72\x7A\x97\x2C\x67\x56\xB5\xE8\xA4\xF7\x96\xA6\x2C\x00\x39\x19\x76\x55\x6F\x37\xBF\xBA\x57\xB5\xAA\xC7\xE2\x38\xC4\x25\xBE\xBB\x3B\xAB\x45\x80\xD9\x6C\xD0\xD9\xF9\xEA\x6F\xFD\xC2\xF0\xBF\x01\x16\x40\x6E\xD5\x5B\xD5\x62\x7E\x75\xAF\x6A\x55\x8F\xC5\xFE\xFB\x15\xDF\x89\xA7\x54\xB5\x6C\x99\x60\x2E\x1B\x76\xBB\xC1\x2F\x55\xCD\xF7\xAC\x86\x7F\x96\x33\xDD\x9A\xC4\xBB\xA9\xF2\xB2\xAA\x79\xDD\xBE\xDB\x9B\xB4\x00\xE4\x64\xE0\xAD\x7A\xB3\x5A\x27\xE7\xEF\x55\xAD\xEA\xB1\x78\xB5\x04\x24\xE6\xAA\x73\xDA\xF7\x1E\x6B\xA7\xBF\xF5\x4B\xCC\xD9\x67\xC8\xAA\x4F\x7C\x2C\xDD\x9A\xC4\xBB\xA9\xF2\xB2\xAA\x45\x27\xBD\xB7\x36\x71\x08\xD8\x00\xEC\x58\xF5\x66\xB5\x4E\xCE\xDF\xBB\x35\x8B\x7D\x2E\xFB\x2D\x3E\xF6\x75\x6A\x2C\x82\xD9\x5E\xF9\xAD\x5F\x2C\xCE\x86\x7F\xD6\x27\x55\x2C\xBB\xBB\x74\x73\x66\x55\x8B\x4E\x7A\x6F\x8F\x05\xB0\xB6\xEB\xCD\xEA\x9D\x9C\xBF\x77\x6B\x16\xFB\x9C\xFF\xFE\x65\xF5\x98\x5B\xD5\x30\x93\x0D\x3C\x3F\xF8\x62\x6E\x55\x93\xD5\x7F\xF2\x91\x4E\x2C\xBB\xBB\x74\x73\xDE\xAE\x6E\xBA\x7D\x8F\x31\xF5\xB7\xBF\x93\xA1\xB7\xEA\xAD\x6A\x59\x3E\xE6\x56\xF7\xD3\xB8\xF3\xB7\x01\x59\xE5\x30\x93\x1F\x7A\x16\x77\x73\xBB\xFF\xE4\x23\x9D\x58\x76\x77\xC9\x72\x52\xE5\x65\x55\x8B\x4E\x7A\x1F\x61\xF2\x5F\xFF\x4F\x06\xDF\xAA\xB7\xAA\x65\xF9\x98\x5B\xDD\x4F\xE3\xEE\xDF\x06\x24\xAB\x63\x2E\x1B\x7C\x7E\x00\xAE\x72\xB2\xFB\x4F\x3E\x52\xBD\xBB\xEA\x93\x78\x97\x2C\x27\x55\x5E\x56\xB5\xE8\xA4\xF7\x31\x26\x2F\x00\x39\x19\x80\xAB\xDE\xAA\x96\xE5\x63\xEE\xE4\xDE\x89\xAF\x2C\x02\xCC\xE6\x87\x5F\x16\xFB\xDC\x2B\xBF\xF5\xCB\xE9\x5D\xBA\x39\x6F\x57\xF7\x4E\x7A\x1F\x85\x05\x70\x66\xD5\x5F\xD5\xB2\x7C\xCC\x9D\xDC\x3B\x71\xB6\x04\xA4\x8A\x01\x3F\x04\xAB\xF8\x5B\x86\xBF\x54\x79\x59\xD5\x32\xA7\xFD\x8F\x31\x7D\x01\xC8\xC9\x20\xDC\xF5\x56\xF5\x2C\x1F\x73\x27\xF7\x6E\x8D\x45\x80\x1D\x3F\xFC\xAA\xF8\x74\xF0\xCB\xAB\x77\xC9\x72\x52\xE5\x65\x55\xCB\x9C\xF6\x3F\x0A\x0B\xE0\x9F\x4E\x86\xE0\xAE\xB7\xAA\x67\xF9\x98\xDB\xF5\xAC\xFA\x57\x7D\x9D\x45\x80\xB9\xFC\x10\xF4\x71\x35\xF8\xA5\x7A\x47\xBA\x35\xD3\xCD\x49\x95\x37\xBB\xBA\x77\xD2\xFB\x48\x2C\x80\x7F\x3A\x1D\x84\xBB\xFE\xAA\x9E\xE5\x3B\xB9\xD5\xBD\x5B\x8B\xDF\xEB\xF8\x1E\x66\xF3\xC3\xD0\x0F\x7E\xF1\xB5\x38\x34\xBB\x35\x89\x77\xE9\xE6\xA4\xCA\x9B\x5D\x3D\x3A\xED\x7F\x1C\x16\xC0\xBF\x9C\x0E\xC4\x5D\x7F\x55\xEF\xE6\xDF\x79\x8F\xB5\xEA\x6F\x04\x98\xC7\x0F\xC1\xAB\x83\x5F\x5E\xBD\x9B\xD3\xBC\xD9\xD5\xA3\xD3\xFE\x47\x62\x01\xFC\xBB\xD3\x61\xB8\xEB\xAF\xEA\x27\xF9\x98\x7B\xE5\x1E\x6B\x7C\xFF\x21\x3F\x39\xF8\xA5\x9B\x33\xAB\x9A\xEC\xEA\xD1\x69\xFF\x63\x31\x00\xFE\x53\x1C\x92\x3B\xBB\xFE\x55\x3D\xAB\x5D\xCD\xBD\x7A\xC7\x6C\x71\x28\xBE\x7A\x97\x57\x72\x52\xE5\xBD\x4E\x8F\x77\xDA\xFF\x68\x2C\x80\xDC\xE9\x70\xDC\xF5\xAF\xEA\x59\xED\x6A\x6E\x77\x17\x9F\xCB\xEA\x98\x25\x0E\xC4\xDD\x5D\xDE\xD5\x23\x55\x5E\x56\x35\xD9\xD5\xA3\xD3\xFE\xC7\x63\x01\xD4\x4E\x87\xE3\xAE\x7F\x55\xAF\x6A\x59\xBE\x93\xDB\xDD\x25\xCB\x61\xAE\x6C\x38\xC6\xDC\xEE\x2E\xDD\x9C\x54\x79\x59\xD5\x64\x57\x8F\x4E\xFB\x47\x60\x01\xD4\xAE\x0C\xC8\xCE\x3B\x55\xCF\x49\xFE\x6A\xAE\xFB\x1E\xE6\xC8\x06\x63\xCC\x5D\xED\x91\x77\xE5\xBD\x4E\x4F\x74\xE5\x9D\xC7\x63\x01\xAC\x5D\x19\x8E\x9D\x77\x56\x3D\x55\x2D\xCB\xBF\x3B\x87\xB9\xB2\x01\xF9\xEE\x9C\x54\x79\x59\xD5\x4C\xA7\x27\xBA\xF2\xCE\x08\x2C\x80\xBD\x2B\x83\xB2\xF3\xCE\xAA\xA7\xAA\x9D\xE4\x5F\xC9\x61\x8E\x6C\x38\xBE\x92\x93\xD3\xBC\xAC\x6A\xA6\xD3\x13\x5D\x79\x67\x0C\x16\x40\xCF\x95\x21\xD9\x79\x67\xD7\x53\xD5\x4F\xF2\xA7\x9F\x81\x99\x4E\x86\xF6\x49\xAF\xAC\x86\xF0\xAA\x66\x3A\x3D\x99\xAB\xEF\x8D\xC1\x02\xE8\xBB\x3A\x30\x3B\xEF\xAD\x7A\xAE\xD4\x4E\xF2\xAB\xCF\xC7\xF3\x65\x43\xB2\x1A\x9C\xA7\x79\xB9\x5A\x33\x9D\x9E\xE8\xCA\x3B\x23\xB1\x00\xCE\x5C\x1D\x96\x9D\xF7\x76\x3D\xAB\x7A\x55\x3B\xCD\x63\xB6\x6A\x70\x9E\xE6\x65\x37\x84\x3B\x43\xBA\xD3\x93\xB9\xFA\xDE\x38\x2C\x80\x73\x57\x87\x67\xF7\xBD\x55\xDF\xBB\x6B\xDD\x7F\x27\x3C\x5B\x35\x30\x57\x83\xF4\x13\x35\xAF\xDB\x17\x5D\x7D\x6F\x24\x16\xC0\x35\x57\x07\x67\xF7\xBD\x5D\xDF\xAA\x7E\xB5\x06\x98\x4F\x0D\xF7\xEE\x70\xBE\x3A\xC4\xAF\xBE\x37\x16\x0B\xE0\xBA\x57\x86\x69\xF7\xDD\x5D\xDF\xD5\x61\xFF\xCA\xBF\x3B\x9E\xEB\xEA\x70\xDF\x0D\xDE\xEE\x60\x7E\x65\x80\xBF\xF2\xEE\x58\x2C\x80\xD7\xBC\x32\x48\xBB\xEF\x76\xFA\x76\x3D\xAB\xFA\x2B\xFF\x33\xE0\xFE\x3E\x3D\xD8\xBB\x83\xF9\xEA\x00\xBF\xFA\x1E\xFE\x81\x05\xF0\x1E\xAF\x0C\xD1\xEE\xBB\x9D\xBE\x5D\x0F\xC3\x1E\x1D\x77\x18\xFC\xC2\xF0\x7F\x11\x0B\xE0\x7D\x7E\x62\x09\xC8\x3B\x16\x81\xB0\x0C\xE0\xBD\x6B\xA8\x9F\x0C\x65\x86\xFF\x2F\x63\x01\xBC\xD7\xAB\x43\x95\x45\x80\x9F\x76\xB7\xC1\x2F\x0C\xFF\x37\x61\x01\xBC\xDF\x4F\x2E\x01\x61\xC8\xE3\x13\xBA\x43\xF6\x74\x18\x33\xFC\xBF\x08\x0B\xE0\x73\xBE\x71\x11\x08\xCB\x00\x2B\x0C\xFE\x41\x58\x00\x9F\xF5\x8E\x61\xFB\xA9\x45\x20\x2C\x03\xC8\xC9\x70\xFD\xE9\xC1\x2F\x0C\xFF\x0F\x61\x01\x7C\xDE\x6F\x2C\x01\x61\xB8\xE3\x9D\xAE\x0C\xE1\x57\x07\x37\x83\xFF\xC3\x58\x00\x3F\xE7\x5D\x03\x99\x65\x80\x9F\xF2\x1B\x43\xDF\x30\xFC\x7F\x00\x0B\xE0\xE7\xFD\xE6\x22\x10\x96\x01\x56\xAE\x0E\x5E\x06\xFF\x0D\xB1\x00\x7E\xC7\x6F\x2F\x01\x61\x11\xC0\xFB\xED\xC1\x2F\x0C\xFF\x1F\xC6\x02\xF8\x3D\xEF\x1C\xC0\x0C\x73\xFC\x34\x06\xFF\x03\xB0\x00\x7E\xDF\xBB\x87\x37\xCB\x00\x9F\xF4\xEE\x61\xCD\xF0\xFF\x45\x2C\x80\xEF\xC1\x22\xC0\x37\x63\xF0\x3F\x10\x0B\xE0\xFB\x7C\x62\x70\xB3\x0C\x70\xC5\x27\x86\x34\x83\xFF\x8B\xB0\x00\xBE\xD7\x27\x87\x36\x0B\x01\x99\x4F\x0E\x67\x06\xFF\x17\x62\x01\x7C\xBF\x4F\x0F\x6B\x96\xC1\x6C\x9F\x1E\xCC\x0C\xFE\x2F\xC6\x02\xB8\x0F\x06\x35\xEE\x84\xC1\x7F\x03\x2C\x80\xFB\x61\x11\xE0\x9B\x31\xF8\x6F\x84\x05\x70\x5F\x2C\x02\x7C\x13\x06\xFF\x0D\xB1\x00\x9E\x81\x65\x80\xDF\xC0\xD0\xBF\x39\x16\xC0\xF3\xB0\x0C\xF0\x49\x0C\xFD\x07\x61\x01\x3C\x1B\xCB\x00\xEF\xC0\xD0\x7F\x28\x16\xC0\x1C\x2C\x03\x9C\x60\xE8\x0F\xC0\x02\x98\x89\x65\x80\x0C\x43\x7F\x18\x16\x00\x58\x06\xB3\x31\xF4\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x40\xE1\x2F\x7F\xF9\x7F\xDB\xE5\xB5\xA7\x31\x5D\xAC\x15\x00\x00\x00\x00\x49\x45\x4E\x44\xAE\x42\x60\x82"
		};
	end,
	["imgui.windows.Main"] = function(...)
		local imguiAssets = import("imgui.Assets");
		local animations = import("imgui.Animations");
		local StyleChanger = import("imgui.StyleChanger");
		local HotKey = import("imgui.HotKey");
		local style = import("imgui.Style");
		local playerNotes = import("imgui.PlayerNotes");
		local shadow = import("imgui.drawList.Shadow");
		local InputTextFilter = import("imgui.InputTextFilter");
		local binderVariables = import("game.binder.Variables");
		local binder = import("game.Binder");
		local user = import("game.User");
		local sampPlayer = import("game.samp.Player");
		local serverTables = import("game.ServerTables");
		local notify = import("Notifications");
		local movableWindows = import("MovableWindows");
		local assets = import("Assets");
		local config = import("Config");
		local common = import("Common");
		local icons = import("Icons");
		local WINDOW_SELECTED_FRAME_HOME = 1;
		local WINDOW_SELECTED_FRAME_SETTINGS = 2;
		local WINDOW_SELECTED_FRAME_KEYBINDS = 3;
		local WINDOW_SELECTED_FRAME_PLAYERS_CHECKER = 4;
		local WINDOW_SELECTED_FRAME_CUSTOMIZATION = 5;
		local WINDOW_SELECTED_FRAME_BINDER = 6;
		local WINDOW_SELECTED_FRAME_LOGS = 7;
		local WINDOW_SELECTED_FRAME_SERVER_TABLES = 8;
		local WINDOW_SELECTED_FRAME_NOTES = 9;
		local WINDOW_WIDGET_SWITCH = 1;
		local WINDOW_WIDGET_SLIDER_INT = 2;
		local WINDOW_WIDGET_SLIDER_FLOAT = 3;
		local WINDOW_WIDGET_COLOR_PICKER = 4;
		local WINDOW_WIDGET_TYPE_SELECTOR = 5;
		local WINDOW_WIDGET_INPUT = 6;
		local WINDOW_WIDGET_CUSTOM = 7;
		local WINDOW_WIDGET_CONFIGURATION_IN_POPUP = 8;
		local sizeX, sizeY = getScreenResolution();
		local RENDER_CHANGE_CONFIGURATION = (function()
			RENDER_CHANGE_CONFIGURATION_SLIDER = RENDER_CHANGE_CONFIGURATION_SLIDER or imgui.new.int(config.root.render.size.common);
			imgui.SetNextItemWidth(imgui.GetWindowWidth()-10);
			if imgui.SliderInt("##imgui.windows.Main.configuration.renderChangeSlider", RENDER_CHANGE_CONFIGURATION_SLIDER, 10, 50) then
				config.root.render.size.common = RENDER_CHANGE_CONFIGURATION_SLIDER[(0)];
			end
		end);
		local _internal0 = config.root.binds[((1))];
		local _internal1 = config.root.binds[((1))];
		local _internal2 = config.root.binds[((1))];
		local _internal3 = config.root.binds[((1))];
		local _internal4 = config.root.playerNotes[((1))];
		local _internal5 = config.root.playerNotes[((1))];
		local _internal6 = config.root.playerNotes[((1))];
		local window = {
			state = imgui.new.bool(), 
			frame = {			}, 
			menu = {
				UI_MENU_ITEMS = {				}, 
				selectedFrame = WINDOW_SELECTED_FRAME_HOME, 
				previousSelectedFrame = WINDOW_SELECTED_FRAME_HOME, 
				button = imgui.GetStyle().Colors[(imgui.Col.Button)], 
				width = 60, 
				state = false, 
				clock = nil, 
				alpha = 0, 
				switchBetweenFramesAlpha = 0
			}, 
			checker = {
				filter = InputTextFilter:new(), 
				playerNote = imgui.new.char[(65535)](), 
				selectedPlayer = -1
			}, 
			customization = {
				editors = nil, 
				selectedId = nil, 
				copiedValues = nil, 
				colorPicker = {
					clock = nil, 
					alpha = nil
				}, 
				moonMonet = {
					toggle = imgui.new.bool(), 
					accent = imgui.new.float[(4)](0, 0, 0, 1)
				}, 
				combo = {
					buffer = imgui.new.int(), 
					array = nil, 
					size = 0
				}
			}, 
			binder = {
				callPopup = false, 
				selectedBind = 1, 
				body = {
					title = imgui.new.char[(20)](((_internal0 and _internal0.title)) or ""), 
					value = imgui.new.char[(65535)](((_internal1 and _internal1.value)) or ""), 
					command = imgui.new.char[(144)](((_internal2 and _internal2.commandName)) or ""), 
					delay = imgui.new.int(((_internal3 and _internal3.delay)) or 800)
				}, 
				popup = {
					inputParameter = imgui.new.char[(256)]()
				}
			}, 
			logs = {
				selected = 1, 
				voidQuote = assets.voidQuotes[(math.random(#assets.voidQuotes))], 
				filter = InputTextFilter:new()
			}, 
			serverTables = {
				selected = 0, 
				filter = InputTextFilter:new()
			}, 
			notes = {
				selected = 1, 
				voidQuote = assets.voidQuotes[(math.random(#assets.voidQuotes))], 
				title = imgui.new.char[(144)]((_internal4 and _internal4.title) or ""), 
				body = imgui.new.char[(65535)]((_internal5 and _internal5.body) or ""), 
				display = imgui.new.bool((_internal6 and _internal6.display) or false)
			}, 
			popupModal = {
				body = nil, 
				size = imgui.ImVec2(0, 0)
			}, 
			configuration = {
				{
					"windows", 
					"Окна", 
					{
						{
							"autoCompletion", 
							"Авто-заполнение", 
							{
								{
									"use", 
									"TAB - вставить\nCTRL + Arrow Up/Down - переключение между элементами", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.windows.autoCompletion.use)
								}, 
								{
									"strokeSize", 
									"Размер обводки", 
									WINDOW_WIDGET_SLIDER_INT, 
									0, 
									5, 
									imgui.new.int(config.root.windows.autoCompletion.strokeSize)
								}
							}, 
							WINDOW_WIDGET_CONFIGURATION_IN_POPUP
						}, 
						{
							"userInformation", 
							"Ваша статистика", 
							{
								{
									"use", 
									"Работает только на /alogin", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.windows.userInformation.use)
								}, 
								{
									"showTime", 
									"Отображать текущее время", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.windows.userInformation.showTime)
								}, 
								{
									"strokeSize", 
									"Размер обводки", 
									WINDOW_WIDGET_SLIDER_INT, 
									0, 
									5, 
									imgui.new.int(config.root.windows.userInformation.strokeSize)
								}, 
								{
									"textAlignMode", 
									"Выравнивание текста", 
									WINDOW_WIDGET_TYPE_SELECTOR, 
									imgui.new.int(config.root.windows.userInformation.textAlignMode), 
									"Слева", 
									"По центру", 
									"Справа"
								}, 
								{
									"none", 
									"Отображение элементов", 
									WINDOW_WIDGET_CUSTOM, 
									(function()
										if animations:button("Добавить новую линию##USER_INFORMATION_CUSTOM_WIDGET", imgui.ImVec2(350, 25)) then
											table.insert(config.root.windows.userInformation.display, 1, "NewLine");
										end
										imgui.BeginChild("USER_INFORMATION_CUSTOM_WIDGET", imgui.ImVec2(350, 300), true);
										local drawList = imgui.GetWindowDrawList();
										local itemColor = imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[(imgui.Col.FrameBg)]);
										imgui.SetCursorPos(imgui.ImVec2(6, 6));
										imgui.BeginGroup();
										for index, item in ipairs(config.root.windows.userInformation.display) do
											local _internal1;
											if (type(item)=="table") then
												local _internal0;
												if (item[(2)]) then
													_internal0 = "Скрыть";
												else
													_internal0 = "Отобразить";
												end
												_internal1 = (_internal0);
											else
												_internal1 = "Удалить";
											end
											local actionButtonPlaceholder = _internal1;
											imgui.BeginGroup();
											local itemWidth = imgui.GetWindowWidth()-22;
											drawList:AddRectFilled(imgui.GetCursorScreenPos(), imgui.GetCursorScreenPos()+imgui.ImVec2(itemWidth, 25), itemColor, imgui.GetStyle().FrameRounding);
											imgui.BeginGroup();
											local baseCursorPos = imgui.GetCursorPos();
											local id = "##USER_INFORMATION_CUSTOM_WIDGET.indexN"..index;
											local moveItem = function(new)
												table.insert(config.root.windows.userInformation.display, new, table.remove(config.root.windows.userInformation.display, index));
												for startIndex, startItem in ipairs(config.root.windows.userInformation.display) do
													if startItem~="NewLine" then
														for endIndex, endItem in ipairs(config.root.windows.userInformation.display) do
															if endItem~="NewLine" then
																if startItem[(1)]==endItem[(1)] and startIndex~=endIndex then
																	table.remove(config.root.windows.userInformation.display, endIndex);
																end
															end
														end
													end
												end
											end;
											imgui.SetCursorPos(baseCursorPos+imgui.GetStyle().FramePadding);
											local _internal2;
											if type(item)=="table" then
												_internal2 = item[(1)];
											else
												_internal2 = "Новая линия";
											end
											imguiAssets:textWithFont(_internal2, bold10);
											imgui.PushFont(regular12);
											imgui.SetCursorPos(imgui.ImVec2(itemWidth-160, baseCursorPos.y));
											imgui.BeginGroup();
											if animations:button("Вверх"..id, imgui.ImVec2(40, 25)) then
												moveItem(math.max(1, index-1));
											end
											imgui.SameLine(nil, 2);
											if animations:button("Вниз"..id, imgui.ImVec2(40, 25)) then
												moveItem(math.min(index+1, #config.root.windows.userInformation.display));
											end
											imgui.EndGroup();
											imgui.SetCursorPos(imgui.ImVec2(itemWidth-75, baseCursorPos.y));
											if animations:button(actionButtonPlaceholder..id, imgui.ImVec2(80, 25)) then
												if type(item)=="table" then
													item[((2))] = not item[(2)];
												else
													table.remove(config.root.windows.userInformation.display, index);
												end
											end
											imgui.PopFont();
											imgui.EndGroup();
											imgui.SameLine();
											imgui.Dummy(imgui.ImVec2(itemWidth, 25));
											imgui.EndGroup();
										end
										imgui.EndGroup();
										imgui.EndChild();
									end)
								}
							}, 
							WINDOW_WIDGET_CONFIGURATION_IN_POPUP
						}, 
						{
							"farChat", 
							"Дальний чат", 
							{
								{
									"use", 
									"Работает только на /alogin", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.windows.farChat.use)
								}, 
								{
									"displayTime", 
									"Отображать время", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.windows.farChat.use)
								}, 
								{
									"strokeSize", 
									"Размер обводки", 
									WINDOW_WIDGET_SLIDER_INT, 
									0, 
									5, 
									imgui.new.int(config.root.windows.farChat.strokeSize)
								}, 
								{
									"delay", 
									"Задержка между повторными сообщениями", 
									WINDOW_WIDGET_SLIDER_INT, 
									2, 
									10, 
									imgui.new.int(config.root.windows.farChat.delay)
								}, 
								{
									"maxLines", 
									"Максимальное кол-во строк", 
									WINDOW_WIDGET_SLIDER_INT, 
									1, 
									30, 
									imgui.new.int(config.root.windows.farChat.maxLines)
								}
							}, 
							WINDOW_WIDGET_CONFIGURATION_IN_POPUP
						}, 
						{
							"spectatorActions", 
							"Действия в /sp", 
							{
								{
									"use", 
									"", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.windows.spectatorActions.use)
								}, 
								{
									"windowSizeY", 
									"Высота окна", 
									WINDOW_WIDGET_SLIDER_INT, 
									50, 
									500, 
									imgui.new.int(config.root.windows.spectatorActions.windowSizeY)
								}, 
								{
									"buttons", 
									"Кнопки", 
									WINDOW_WIDGET_CUSTOM, 
									(function()
										local id = "spectatorActionsCustomWidget";
										local childSizeX = math.max(imgui.GetWindowWidth()-12, 350);
										local getActionType = function(index)
											local _internal0;
											if (type(config.root.windows.spectatorActions.buttons[(index)][(2)])=="string") then
												_internal0 = 1;
											else
												_internal0 = 2;
											end
											return _internal0;
										end;
										local getValue = function(index)
											local _internal0;
											if (type(config.root.windows.spectatorActions.buttons[(index)][(2)])=="number") then
												_internal0 = imgui.new.int(config.root.windows.spectatorActions.buttons[(index)][(2)]);
											else
												_internal0 = imgui.new.char[(512)](config.root.windows.spectatorActions.buttons[(index)][(2)]);
											end
											return _internal0;
										end;
										if not SPECTATOR_ACTIONS_CUSTOM_WIDGET then
											SPECTATOR_ACTIONS_CUSTOM_WIDGET = {
												selected = 1, 
												title = imgui.new.char[(144)](config.root.windows.spectatorActions.buttons[(1)][(1)]), 
												action = imgui.new.int(getActionType(1)), 
												value = getValue(1), 
												state = imgui.new.bool(config.root.windows.spectatorActions.buttons[(1)][(3)])
											};
										end
										local this = SPECTATOR_ACTIONS_CUSTOM_WIDGET;
										imgui.BeginGroup();
										imguiAssets:textWithFont("Настройки кнопки", regular10);
										imgui.SameLine();
										imguiAssets:textWithFont(config.root.windows.spectatorActions.buttons[(this.selected)][(1)]);
										imgui.EndGroup();
										imgui.BeginChild(id..".buttonSettings", imgui.ImVec2(childSizeX, 167), true);
										imgui.SetCursorPos(imgui.ImVec2(6, 6));
										imgui.BeginGroup();
										imgui.PushItemWidth(imgui.GetWindowWidth()-12);
										imguiAssets:textWithFont("Название кнопки", bold10);
										if imgui.InputTextWithHint("##"..id..".title", "Название", this.title, ffi.sizeof(this.title)) then
											config.root.windows.spectatorActions.buttons[((this.selected))][((1))] = ffi.string(this.title);
										end
										imguiAssets:textWithFont("Действие кнопки", bold10);
										if imgui.SliderInt(string.format("##%s.action", id), this.action, 1, 2, ({
											"Выполнить бинд", 
											"Выполнить действие"
										})[(this.action[(0)])]) then
											local value = config.root.windows.spectatorActions.buttons[(this.action[(0)])];
											local _internal0 = this.action[(0)];
											if (_internal0 == 1) then
												local _internal1;
												if (type(value)=="string") then
													_internal1 = value;
												else
													_internal1 = "";
												end
												_internal0 = imgui.new.char[(512)](_internal1);
											else
												if (_internal0 == 2) then
													local _internal2;
													if (type(value)=="number") then
														_internal2 = value;
													else
														_internal2 = 0;
													end
													_internal0 = imgui.new.int(_internal2);
												else
													_internal0 = nil;
												end
											end
											this.value = _internal0;
										end
										if this.action[(0)]==1 then
											if imgui.InputText("##"..id..".actionInput", this.value, ffi.sizeof(this.value)) then
												config.root.windows.spectatorActions.buttons[((this.selected))][((2))] = ffi.string(this.value);
											end
										elseif this.action[(0)]==2 then
											if imgui.SliderInt("##"..id..".actionSlider", this.value, 0, 6, ({
												"Следующий игрок", 
												"Переключить режим наблюдения", 
												"Предыдущий игрок", 
												"Открыть статистику игрока", 
												"Открыть сессии игрока", 
												"Открыть инвентарь игрока", 
												"Выйти из режима наблюдения"
											})[(this.value[(0)]+1)]) then
												config.root.windows.spectatorActions.buttons[((this.selected))][((2))] = this.value[(0)];
											end
										end
										imgui.PushFont(bold10);
										if animations:toggleButton("Отображать в окне##"..id..".stateButton", this.state) then
											config.root.windows.spectatorActions.buttons[((this.selected))][((3))] = this.state[(0)];
										end
										imgui.PopFont();
										imgui.PopItemWidth();
										imgui.EndGroup();
										imgui.EndChild();
										imguiAssets:textWithFont("Список кнопок", regular10);
										imgui.BeginChild(id..".buttonList", imgui.ImVec2(childSizeX, 250), true);
										local drawList = imgui.GetWindowDrawList();
										imgui.SetCursorPos(imgui.ImVec2(6, 6));
										imgui.BeginGroup();
										for index, item in ipairs(config.root.windows.spectatorActions.buttons) do
											imgui.BeginGroup();
											local itemWidth = imgui.GetWindowWidth()-22;
											local selectItem = function(index)
												if index~=this.selected then
													this.selected = index;
													this.action[((0))] = getActionType(index);
													this.value = getValue(index);
													this.state[((0))] = config.root.windows.spectatorActions.buttons[(index)][(3)];
													imgui.StrCopy(this.title, config.root.windows.spectatorActions.buttons[(index)][(1)]);
												end
											end;
											drawList:AddRectFilled(imgui.GetCursorScreenPos(), imgui.GetCursorScreenPos()+imgui.ImVec2(itemWidth, 25), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[(imgui.Col.FrameBg)]), imgui.GetStyle().FrameRounding);
											imgui.BeginGroup();
											local baseCursorPos = imgui.GetCursorPos();
											local id = "##"..id..".itemIndex-"..index;
											local moveItem = function(new)
												if index==this.selected then
													selectItem(new);
												end
												table.insert(config.root.windows.spectatorActions.buttons, new, table.remove(config.root.windows.spectatorActions.buttons, index));
											end;
											imgui.SetCursorPos(baseCursorPos+imgui.GetStyle().FramePadding);
											imguiAssets:textWithFont(item[(1)], bold10);
											imgui.PushFont(regular12);
											imgui.SetCursorPos(imgui.ImVec2(itemWidth-160, baseCursorPos.y));
											imgui.BeginGroup();
											if animations:button("Вверх"..id, imgui.ImVec2(40, 25), nil, nil, buttonColors) then
												moveItem(math.max(1, index-1));
											end
											imgui.SameLine(nil, 2);
											if animations:button("Вниз"..id, imgui.ImVec2(40, 25), nil, nil, buttonColors) then
												moveItem(math.min(index+1, #config.root.windows.spectatorActions.buttons));
											end
											imgui.EndGroup();
											imgui.SetCursorPos(imgui.ImVec2(itemWidth-75, baseCursorPos.y));
											if animations:button("Настроить"..id, imgui.ImVec2(80, 25), nil, nil, buttonColors) then
												selectItem(index);
											end
											imgui.PopFont();
											imgui.EndGroup();
											imgui.SameLine();
											imgui.Dummy(imgui.ImVec2(itemWidth, 25));
											imgui.EndGroup();
										end
										imgui.EndGroup();
										imgui.EndChild();
									end)
								}
							}, 
							WINDOW_WIDGET_CONFIGURATION_IN_POPUP
						}, 
						{
							"spectatorInformation", 
							"Информация об игроке", 
							{
								{
									"use", 
									"Работает только в режиме наблюдения", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.windows.spectatorInformation.use)
								}, 
								{
									"type", 
									"Количество столбцов на одной строке", 
									WINDOW_WIDGET_TYPE_SELECTOR, 
									imgui.new.int(config.root.windows.spectatorInformation.type), 
									"2", 
									"4"
								}, 
								{
									"none", 
									"Отображение элементов", 
									WINDOW_WIDGET_CUSTOM, 
									(function()
										imgui.BeginChild("SPECTATOR_INFORMATION_CUSTOM_WIDGET", imgui.ImVec2(350, 300), true);
										local drawList = imgui.GetWindowDrawList();
										local itemColor = imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[(imgui.Col.FrameBg)]);
										imgui.SetCursorPos(imgui.ImVec2(6, 6));
										imgui.BeginGroup();
										for index, item in ipairs(config.root.windows.spectatorInformation.columns) do
											local _internal0;
											if (item[(2)]) then
												_internal0 = "Скрыть";
											else
												_internal0 = "Отобразить";
											end
											local actionButtonPlaceholder = _internal0;
											imgui.BeginGroup();
											local itemWidth = imgui.GetWindowWidth()-22;
											drawList:AddRectFilled(imgui.GetCursorScreenPos(), imgui.GetCursorScreenPos()+imgui.ImVec2(itemWidth, 25), itemColor, imgui.GetStyle().FrameRounding);
											imgui.BeginGroup();
											local baseCursorPos = imgui.GetCursorPos();
											local id = "##SPECTATOR_INFORMATION_CUSTOM_WIDGET.indexN"..index;
											local moveItem = function(new)
												table.insert(config.root.windows.spectatorInformation.columns, new, table.remove(config.root.windows.spectatorInformation.columns, index));
											end;
											imgui.SetCursorPos(baseCursorPos+imgui.GetStyle().FramePadding);
											local _internal1;
											if type(item)=="table" then
												_internal1 = item[(1)];
											else
												_internal1 = "Новая линия";
											end
											imguiAssets:textWithFont(_internal1, bold10);
											imgui.PushFont(regular12);
											imgui.SetCursorPos(imgui.ImVec2(itemWidth-160, baseCursorPos.y));
											imgui.BeginGroup();
											if animations:button("Вверх"..id, imgui.ImVec2(40, 25)) then
												moveItem(math.max(1, index-1));
											end
											imgui.SameLine(nil, 2);
											if animations:button("Вниз"..id, imgui.ImVec2(40, 25)) then
												moveItem(math.min(index+1, #config.root.windows.spectatorInformation.columns));
											end
											imgui.EndGroup();
											imgui.SetCursorPos(imgui.ImVec2(itemWidth-75, baseCursorPos.y));
											if animations:button(actionButtonPlaceholder..id, imgui.ImVec2(80, 25)) then
												if type(item)=="table" then
													item[((2))] = not item[(2)];
												else
													table.remove(config.root.windows.spectatorInformation.columns, index);
												end
											end
											imgui.PopFont();
											imgui.EndGroup();
											imgui.SameLine();
											imgui.Dummy(imgui.ImVec2(itemWidth, 25));
											imgui.EndGroup();
										end
										imgui.EndGroup();
										imgui.EndChild();
									end)
								}
							}, 
							WINDOW_WIDGET_CONFIGURATION_IN_POPUP
						}, 
						{
							"spectatorKeys", 
							"Клавиши игрока в /sp", 
							{
								{
									"use", 
									"", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.windows.spectatorKeys.use)
								}
							}
						}, 
						{
							"killList", 
							"Килл-лист", 
							{
								{
									"use", 
									"Работает только на /alogin", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.windows.killList.use)
								}, 
								{
									"displayTime", 
									"Отображать время", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.windows.killList.displayTime)
								}, 
								{
									"displayId", 
									"Отображать ID игроков", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.windows.killList.displayId)
								}, 
								{
									"hideDefaultKillList", 
									"Скрывать килл-лист игры", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.windows.killList.hideDefaultKillList)
								}, 
								{
									"playerColorBasedOnClist", 
									"Цвет игроков зависит от их клиста", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.windows.killList.playerColorBasedOnClist)
								}, 
								{
									"strokeSize", 
									"Размер обводки", 
									WINDOW_WIDGET_SLIDER_INT, 
									0, 
									5, 
									imgui.new.int(config.root.windows.killList.strokeSize)
								}, 
								{
									"textAlignMode", 
									"Выравнивание текста", 
									WINDOW_WIDGET_TYPE_SELECTOR, 
									imgui.new.int(config.root.windows.killList.textAlignMode), 
									"Слева", 
									"По центру", 
									"Справа"
								}, 
								{
									"maxItems", 
									"Макс. кол-во элементов", 
									WINDOW_WIDGET_SLIDER_INT, 
									1, 
									100, 
									imgui.new.int(config.root.windows.killList.maxItems)
								}
							}, 
							WINDOW_WIDGET_CONFIGURATION_IN_POPUP
						}, 
						{
							"notifications", 
							"Оповещения", 
							{
								{
									"use", 
									"", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.windows.notifications.use)
								}, 
								{
									"maxItems", 
									"Макс. кол-во оповещений", 
									WINDOW_WIDGET_SLIDER_INT, 
									1, 
									5, 
									imgui.new.int(config.root.windows.notifications.maxItems)
								}, 
								{
									"align", 
									"Позиция оповещений", 
									WINDOW_WIDGET_TYPE_SELECTOR, 
									imgui.new.int(config.root.windows.notifications.align), 
									"Слева", 
									"По центру", 
									"Справа"
								}
							}, 
							WINDOW_WIDGET_CONFIGURATION_IN_POPUP
						}, 
						{
							"adminList", 
							"Список админов", 
							{
								{
									"use", 
									"Работает только на /alogin", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.windows.adminList.use)
								}, 
								{
									"showAdminLvl", 
									"Отображать уровни администраторов", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.windows.adminList.showAdminLvl)
								}, 
								{
									"sortByLvl", 
									"Сортировать по уровням", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.windows.adminList.sortByLvl)
								}, 
								{
									"textColorBasedOnClist", 
									"Цвет зависит от клиста", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.windows.adminList.textColorBasedOnClist)
								}, 
								{
									"textAlignMode", 
									"Выравнивание текста", 
									WINDOW_WIDGET_TYPE_SELECTOR, 
									imgui.new.int(config.root.windows.adminList.textAlignMode), 
									"Слева", 
									"По центру", 
									"Справа"
								}, 
								{
									"strokeSize", 
									"Размер обводки", 
									WINDOW_WIDGET_SLIDER_INT, 
									0, 
									5, 
									imgui.new.int(config.root.windows.adminList.strokeSize)
								}, 
								{
									"countForScrollbar", 
									"Количество админов для появления скролла", 
									WINDOW_WIDGET_SLIDER_INT, 
									1, 
									100, 
									imgui.new.int(config.root.windows.adminList.countForScrollbar)
								}
							}, 
							WINDOW_WIDGET_CONFIGURATION_IN_POPUP
						}, 
						{
							"playersNearby", 
							"Список игроков рядом", 
							{
								{
									"use", 
									"Работает только на /alogin", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.windows.playersNearby.use)
								}, 
								{
									"showDistance", 
									"Отображать дистанцию", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.windows.playersNearby.showDistance)
								}, 
								{
									"showAdmins", 
									"Отображать администраторов", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.windows.playersNearby.showAdmins)
								}, 
								{
									"sortByDistance", 
									"Сортировать по дистанции", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.windows.playersNearby.sortByDistance)
								}, 
								{
									"playerColorBasedOnClist", 
									"Цвет зависит от клиста", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.windows.playersNearby.playerColorBasedOnClist)
								}, 
								{
									"textAlignMode", 
									"Выравнивание текста", 
									WINDOW_WIDGET_TYPE_SELECTOR, 
									imgui.new.int(config.root.windows.playersNearby.textAlignMode), 
									"Слева", 
									"По центру", 
									"Справа"
								}, 
								{
									"strokeSize", 
									"Размер обводки", 
									WINDOW_WIDGET_SLIDER_INT, 
									0, 
									5, 
									imgui.new.int(config.root.windows.playersNearby.strokeSize)
								}, 
								{
									"maxPlayers", 
									"Максимальное кол-во игроков", 
									WINDOW_WIDGET_SLIDER_INT, 
									1, 
									30, 
									imgui.new.int(config.root.windows.playersNearby.maxPlayers)
								}
							}, 
							WINDOW_WIDGET_CONFIGURATION_IN_POPUP
						}, 
						{
							"greport", 
							"Улучшенный /greport", 
							{
								{
									"use", 
									"", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.windows.greport.use)
								}, 
								{
									"preferNotifications", 
									"Использовать оповещения GAdmin", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.windows.greport.preferNotifications)
								}, 
								{
									"soundNotification", 
									"Звуковое оповещение", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.windows.greport.soundNotification)
								}, 
								{
									"inputCopyButtons", 
									"Кнопки вставляющие текст в поле ввода", 
									WINDOW_WIDGET_CUSTOM, 
									function()
										UI_GREPORT_CUSTOM_ELEMENT = UI_GREPORT_CUSTOM_ELEMENT or {
											{
												imgui.new.char[(144)](config.root.windows.greport.inputCopyButtons[(1)][(1)]), 
												imgui.new.char[(255)](config.root.windows.greport.inputCopyButtons[(1)][(2)])
											}, 
											{
												imgui.new.char[(144)](config.root.windows.greport.inputCopyButtons[(2)][(1)]), 
												imgui.new.char[(255)](config.root.windows.greport.inputCopyButtons[(2)][(2)])
											}, 
											{
												imgui.new.char[(144)](config.root.windows.greport.inputCopyButtons[(3)][(1)]), 
												imgui.new.char[(255)](config.root.windows.greport.inputCopyButtons[(3)][(2)])
											}, 
											{
												imgui.new.char[(144)](config.root.windows.greport.inputCopyButtons[(4)][(1)]), 
												imgui.new.char[(255)](config.root.windows.greport.inputCopyButtons[(4)][(2)])
											}, 
											{
												imgui.new.char[(144)](config.root.windows.greport.inputCopyButtons[(5)][(1)]), 
												imgui.new.char[(255)](config.root.windows.greport.inputCopyButtons[(5)][(2)])
											}, 
											{
												imgui.new.char[(144)](config.root.windows.greport.inputCopyButtons[(6)][(1)]), 
												imgui.new.char[(255)](config.root.windows.greport.inputCopyButtons[(6)][(2)])
											}
										};
										imgui.SetCursorPosY(imgui.GetCursorPos().y+2.5);
										imguiAssets:textWithFont("Заголовок", regular9);
										imgui.SameLine(imgui.GetWindowWidth()/2);
										imguiAssets:textWithFont("Текст что вставится", regular9);
										for index = 1, 6, 1 do
											local buffer = UI_GREPORT_CUSTOM_ELEMENT[(index)];
											imgui.SetNextItemWidth(imgui.GetWindowWidth()/2-5);
											if imgui.InputText("##imgui.windows.GReport.titleIndex"..index, buffer[(1)], ffi.sizeof(buffer[(1)])) then
												config.root.windows.greport.inputCopyButtons[((index))][((1))] = ffi.string(buffer[(1)]);
											end
											imgui.SameLine();
											imgui.SetNextItemWidth(imgui.GetWindowWidth()/2-10);
											if imgui.InputText("##imgui.windows.GReport.replaceIndex"..index, buffer[(2)], ffi.sizeof(buffer[(2)])) then
												config.root.windows.greport.inputCopyButtons[((index))][((2))] = ffi.string(buffer[(2)]);
											end
										end
									end
								}, 
								{
									"reminderNotification", 
									"Напоминание при долгом простое с активным репортом", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.windows.greport.reminderNotification)
								}, 
								{
									"remindSeconds", 
									"Время до напоминания при простое", 
									WINDOW_WIDGET_SLIDER_INT, 
									10, 
									600, 
									imgui.new.int(config.root.windows.greport.remindSeconds)
								}
							}, 
							WINDOW_WIDGET_CONFIGURATION_IN_POPUP
						}, 
						{
							"playerChecker", 
							"Чекер игроков", 
							{
								{
									"use", 
									"Игроки добавляются через раздел \"Чекер\" в меню.\nРаботает только на /alogin", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.windows.playerChecker.use)
								}, 
								{
									"notificationType", 
									"Тип оповещения при заходе/выходе игрока", 
									WINDOW_WIDGET_TYPE_SELECTOR, 
									imgui.new.int(config.root.windows.playerChecker.notificationType), 
									"ImGui оповещение", 
									"Сообщение в чат", 
									"Отсутствует"
								}, 
								{
									"displayOfflinePlayers", 
									"Отображать игроков в оффлайне", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.windows.playerChecker.displayOfflinePlayers)
								}, 
								{
									"playerColorBasedOnClist", 
									"Цвет игрока зависит от клиста", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.windows.playerChecker.playerColorBasedOnClist)
								}, 
								{
									"strokeSize", 
									"Размер обводки", 
									WINDOW_WIDGET_SLIDER_INT, 
									0, 
									5, 
									imgui.new.int(config.root.windows.playerChecker.strokeSize)
								}, 
								{
									"textAlignMode", 
									"Выравнивание текста", 
									WINDOW_WIDGET_TYPE_SELECTOR, 
									imgui.new.int(config.root.windows.playerChecker.textAlignMode), 
									"Слева", 
									"По центру", 
									"Справа"
								}
							}, 
							WINDOW_WIDGET_CONFIGURATION_IN_POPUP
						}
					}
				}, 
				{
					"cheats", 
					"Читы", 
					{
						{
							"airbreak", 
							"Airbreak", 
							{
								{
									"use", 
									"Работает только на /alogin", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.cheats.airbreak.use)
								}, 
								{
									"notificationType", 
									"Тип оповещения при нажатии на хоткей", 
									WINDOW_WIDGET_TYPE_SELECTOR, 
									imgui.new.int(config.root.cheats.airbreak.notificationType), 
									"ImGui оповещение", 
									"Сообщение в чат", 
									"Отсутствует"
								}, 
								{
									"speed", 
									"Скорость", 
									WINDOW_WIDGET_SLIDER_FLOAT, 
									0.5, 
									3.0, 
									imgui.new.float(config.root.cheats.airbreak.speed)
								}
							}, 
							WINDOW_WIDGET_CONFIGURATION_IN_POPUP
						}, 
						{
							"clickwarp", 
							"ClickWarp", 
							{
								{
									"use", 
									"Работает только на /alogin\nТелепортация - колесико мыши.", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.cheats.clickwarp.use)
								}
							}
						}, 
						{
							"wallhack", 
							"Wallhack", 
							{
								{
									"use", 
									"Работает только на /alogin", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.cheats.wallhack.use), 
									function()
										if not config.root.cheats.wallhack.imguiStyle then
											assets:changeWallhackState(config.root.cheats.wallhack.use and user:getAloginStatus());
										end
									end
								}, 
								{
									"imguiStyle", 
									"Использовать ImGui рендер", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.cheats.wallhack.imguiStyle), 
									function()
										assets:changeWallhackState(not config.root.cheats.wallhack.imguiStyle);
									end
								}, 
								{
									"notificationType", 
									"Тип оповещения при нажатии на хоткей", 
									WINDOW_WIDGET_TYPE_SELECTOR, 
									imgui.new.int(config.root.cheats.wallhack.notificationType), 
									"ImGui оповещение", 
									"Сообщение в чат", 
									"Отсутствует"
								}, 
								{
									"none", 
									"Размер шрифта", 
									WINDOW_WIDGET_CUSTOM, 
									RENDER_CHANGE_CONFIGURATION
								}
							}, 
							WINDOW_WIDGET_CONFIGURATION_IN_POPUP
						}
					}
				}, 
				{
					"additions", 
					"Прочее", 
					{
						{
							"autoAdminLogin", 
							"/alogin при спавне", 
							{
								{
									"use", 
									"Для автоматического ввода пароля включите и настройте авто-ввод паролей", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.additions.autoAdminLogin.use)
								}
							}
						}, 
						{
							"swapLayout", 
							"Авто-исправление команд", 
							{
								{
									"use", 
									"", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.additions.swapLayout.use)
								}
							}
						}, 
						{
							"autoAACommand", 
							"Автоматический /aa", 
							{
								{
									"use", 
									"", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.additions.autoAACommand.use)
								}
							}
						}, 
						{
							"autoAlogout", 
							"/alogout по времени", 
							{
								{
									"use", 
									"/alogout введется если вы простояли в афк больше разрешенного.", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.additions.autoAlogout.use), 
									function()
										if not config.root.additions.autoAlogout.use then
											assets:workInBackground(false);
										end
									end
								}, 
								{
									"warningSeconds", 
									"Секунд до предупреждения", 
									WINDOW_WIDGET_SLIDER_INT, 
									10, 
									600, 
									imgui.new.int(config.root.additions.autoAlogout.warningSeconds)
								}, 
								{
									"alogoutSeconds", 
									"Секунд до /alogout", 
									WINDOW_WIDGET_SLIDER_INT, 
									10, 
									600, 
									imgui.new.int(config.root.additions.autoAlogout.alogoutSeconds)
								}
							}, 
							WINDOW_WIDGET_CONFIGURATION_IN_POPUP
						}, 
						{
							"autoLogin", 
							"Авто-ввод паролей", 
							{
								{
									"use", 
									"", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.additions.autoLogin.use)
								}, 
								{
									"accountPassword", 
									"Пароль от аккаунта", 
									WINDOW_WIDGET_INPUT, 
									imgui.new.char[(48)](config.root.additions.autoLogin.accountPassword)
								}, 
								{
									"aloginPassword", 
									"Пароль от /alogin", 
									WINDOW_WIDGET_INPUT, 
									imgui.new.char[(48)](config.root.additions.autoLogin.aloginPassword)
								}
							}, 
							WINDOW_WIDGET_CONFIGURATION_IN_POPUP
						}, 
						{
							"commandRequester", 
							"Админские формы", 
							{
								{
									"use", 
									"", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.additions.commandRequester.use)
								}, 
								{
									"soundNotification", 
									"Звуковое оповещение", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.additions.commandRequester.soundNotification)
								}, 
								{
									"displayType", 
									"Режим отображения полученной формы", 
									WINDOW_WIDGET_TYPE_SELECTOR, 
									imgui.new.int(config.root.additions.commandRequester.displayType), 
									"Оповещение", 
									"Полоса состояния снизу экрана"
								}, 
								{
									"windowPositionY", 
									"Позиция полосы по Y", 
									WINDOW_WIDGET_SLIDER_INT, 
									0, 
									select(2, getScreenResolution()), 
									imgui.new.int(config.root.additions.commandRequester.windowPositionY)
								}, 
								{
									"secondsToHide", 
									"Время для закрытия формы", 
									WINDOW_WIDGET_SLIDER_INT, 
									5, 
									30, 
									imgui.new.int(config.root.additions.commandRequester.secondsToHide)
								}
							}, 
							WINDOW_WIDGET_CONFIGURATION_IN_POPUP
						}, 
						{
							"idInKillList", 
							"Айди в килл листе", 
							{
								{
									"use", 
									"", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.additions.idInKillList.use)
								}
							}
						}, 
						{
							"carInfo", 
							"Информация о машине", 
							{
								{
									"use", 
									"Работает только на /alogin", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.additions.carInfo.use)
								}, 
								{
									"onlyInSpectator", 
									"Отображать только в /sp", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.additions.carInfo.onlyInSpectator)
								}, 
								{
									"none", 
									"Размер шрифта", 
									WINDOW_WIDGET_CUSTOM, 
									RENDER_CHANGE_CONFIGURATION
								}
							}, 
							WINDOW_WIDGET_CONFIGURATION_IN_POPUP
						}, 
						{
							"shortCommands", 
							"Короткие команды", 
							{
								{
									"use", 
									[[vr = vrepair
as = aspawn
vs = vspawn
ah = aheal
uf = unfreeze
g = goto
gh = gethere
gc = getcar
gbc = getbuycar
pt = ptop
jb = ans <id> Пишите жалобу на форум
asl = ans <id> Слежу за игроком
ar = kick <id> AFK on ROAD
ak = kick <id> AFK without ESC
ap = kick <id> AFK public place]], 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.additions.shortCommands.use)
								}
							}
						}, 
						{
							"reportOneColor", 
							"Один цвет для репорта", 
							{
								{
									"use", 
									"", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.additions.reportOneColor.use)
								}, 
								{
									"color", 
									"Цвет", 
									WINDOW_WIDGET_COLOR_PICKER, 
									imguiAssets:convertHex2Float3(config.root.additions.reportOneColor.color)
								}
							}, 
							WINDOW_WIDGET_CONFIGURATION_IN_POPUP
						}, 
						{
							"gunInfo", 
							"Отображение оружия у игрока", 
							{
								{
									"use", 
									"Работает только на /alogin", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.additions.gunInfo.use)
								}, 
								{
									"none", 
									"Размер шрифта", 
									WINDOW_WIDGET_CUSTOM, 
									RENDER_CHANGE_CONFIGURATION
								}
							}, 
							WINDOW_WIDGET_CONFIGURATION_IN_POPUP
						}, 
						{
							"zoomSpectatorCamera", 
							"Отдаление камеры в /sp", 
							{
								{
									"use", 
									"Отдаление на колесико мыши в спектаторе", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.additions.zoomSpectatorCamera.use)
								}, 
								{
									"step", 
									"Шаг", 
									WINDOW_WIDGET_SLIDER_INT, 
									1, 
									15, 
									imgui.new.int(config.root.additions.zoomSpectatorCamera.step)
								}
							}, 
							WINDOW_WIDGET_CONFIGURATION_IN_POPUP
						}, 
						{
							"displayIdInIc", 
							"Отображение айди в IC", 
							{
								{
									"use", 
									"", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.additions.displayIdInIc.use)
								}
							}
						}, 
						{
							"showAdmins", 
							"Показывать админов", 
							{
								{
									"use", 
									"Показывать администраторов на скине, если он таковым является", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.additions.showAdmins.use)
								}, 
								{
									"none", 
									"Размер шрифта", 
									WINDOW_WIDGET_CUSTOM, 
									RENDER_CHANGE_CONFIGURATION
								}
							}, 
							WINDOW_WIDGET_CONFIGURATION_IN_POPUP
						}, 
						{
							"hideIpAddresses", 
							"Прятать IP адреса", 
							{
								{
									"use", 
									"", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.additions.hideIpAddresses.use)
								}
							}
						}, 
						{
							"hideSpectatorMenu", 
							"Прятать меню в /sp", 
							{
								{
									"use", 
									"", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.additions.hideSpectatorMenu.use)
								}
							}
						}, 
						{
							"disableServerMessages", 
							"Скрытие системных сообщений", 
							{
								{
									"use", 
									"", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.additions.disableServerMessages.use)
								}, 
								{
									"anticheat", 
									"Сообщения античита", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.additions.disableServerMessages.anticheat)
								}, 
								{
									"punishments", 
									"Наказания от администраторов", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.additions.disableServerMessages.punishments)
								}, 
								{
									"complaints", 
									"Жалобы", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.additions.disableServerMessages.complaints)
								}, 
								{
									"questions", 
									"Вопросы", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.additions.disableServerMessages.questions)
								}, 
								{
									"adminActions", 
									"Действия администраторов", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.additions.disableServerMessages.adminActions)
								}, 
								{
									"playerActions", 
									"Действия игроков (/pame, GBUY, /caract, граффити)", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.additions.disableServerMessages.playerActions)
								}
							}, 
							WINDOW_WIDGET_CONFIGURATION_IN_POPUP
						}, 
						{
							"fishEye", 
							"Рыбий глаз", 
							{
								{
									"use", 
									"", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.additions.fishEye.use)
								}, 
								{
									"fov", 
									"Глубина", 
									WINDOW_WIDGET_SLIDER_INT, 
									60, 
									110, 
									imgui.new.int(config.root.additions.fishEye.fov)
								}
							}, 
							WINDOW_WIDGET_CONFIGURATION_IN_POPUP
						}, 
						{
							"tracers", 
							"Трассера", 
							{
								{
									"use", 
									"", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.additions.tracers.use)
								}, 
								{
									"showOnlyForSpectator", 
									"Только выстрелы от игрока за которым вы следите", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.additions.tracers.showOnlyForSpectator)
								}, 
								{
									"notificationType", 
									"Тип оповещения при переключении на хоткей", 
									WINDOW_WIDGET_TYPE_SELECTOR, 
									imgui.new.int(config.root.additions.tracers.notificationType), 
									"ImGui оповещение", 
									"Сообщение в чат", 
									"Отсутствует"
								}, 
								{
									"hitColor", 
									"Цвет попадания", 
									WINDOW_WIDGET_COLOR_PICKER, 
									imguiAssets:convertHex2Float3(config.root.additions.tracers.hitColor)
								}, 
								{
									"missColor", 
									"Цвет промаха", 
									WINDOW_WIDGET_COLOR_PICKER, 
									imguiAssets:convertHex2Float3(config.root.additions.tracers.missColor)
								}, 
								{
									"maxLines", 
									"Максимальное количество трассеров", 
									WINDOW_WIDGET_CUSTOM, 
									(function(this)
										imgui.SetNextItemWidth(imgui.GetWindowWidth()-10);
										if imgui.SliderInt("##imgui.windows.Main.Settings.changeTraccersAmount", this[(5)], 1, 100) then
											config.root.additions.tracers.maxLines = this[(5)][(0)];
											for id = 1, config.root.additions.tracers.maxLines, 1 do
												bulletData[((id))] = {
													enable = false, 
													o = {
														x, 
														y, 
														z
													}, 
													t = {
														x, 
														y, 
														z
													}, 
													time = 0, 
													type = 0
												};
											end
										end
									end), 
									imgui.new.int(config.root.additions.tracers.maxLines)
								}
							}, 
							WINDOW_WIDGET_CONFIGURATION_IN_POPUP
						}, 
						{
							"deathNotifyInChat", 
							"Убийства в чат", 
							{
								{
									"use", 
									"Логирует убийства в чат", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.additions.deathNotifyInChat.use)
								}, 
								{
									"color", 
									"Цвет", 
									WINDOW_WIDGET_COLOR_PICKER, 
									imguiAssets:convertHex2Float3(config.root.additions.deathNotifyInChat.color)
								}
							}, 
							WINDOW_WIDGET_CONFIGURATION_IN_POPUP
						}, 
						{
							"mention", 
							"Упоминания в /a", 
							{
								{
									"use", 
									"", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.additions.mention.use)
								}, 
								{
									"soundNotification", 
									"Звуковое оповещение", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.additions.mention.soundNotification)
								}, 
								{
									"color", 
									"Цвет упоминания", 
									WINDOW_WIDGET_COLOR_PICKER, 
									imguiAssets:convertHex2Float3(config.root.additions.mention.color)
								}, 
								{
									"notificationType", 
									"Тип оповещения при упоминании", 
									WINDOW_WIDGET_TYPE_SELECTOR, 
									imgui.new.int(config.root.additions.mention.notificationType), 
									"ImGui оповещение", 
									"Сообщение в чат", 
									"Отсутствует"
								}
							}, 
							WINDOW_WIDGET_CONFIGURATION_IN_POPUP
						}, 
						{
							"changeNicknameColors", 
							"Разные цвета никнеймов /a", 
							{
								{
									"use", 
									"Изменение цвета никнейма для тех кто внес вклад в разработку\nИзменяется исключительно в /a чате", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.additions.changeNicknameColors.use)
								}
							}
						}
					}
				}, 
				{
					"fix", 
					"Исправления", 
					{
						{
							"chatOnVK_T", 
							"Чат на русскую T", 
							{
								{
									"use", 
									"", 
									WINDOW_WIDGET_SWITCH, 
									imgui.new.bool(config.root.fix.chatOnVK_T.use)
								}
							}
						}
					}
				}
			}
		};
		mainWindow = window;
		function window.menu:item(label, icon, title, index, duration)
			if duration == nil then
				duration = {
					0.2, 
					0.4, 
					0.3, 
					0.05, 
					0.1
				}
			end
			local dl = imgui.GetWindowDrawList();
			local colors = {
				def = imgui.GetStyle().Colors[(imgui.Col.ChildBg)], 
				active = imgui.GetStyle().Colors[(imgui.Col.Button)], 
				hovered = imgui.GetStyle().Colors[(imgui.Col.ButtonHovered)]
			};
			do
				local this = self.UI_MENU_ITEMS[(label)];
				if this ~= nil then
					local cursor = imgui.GetCursorPos();
					imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, 0);
					if imgui.Button(label, imgui.ImVec2(window.menu.width, 35)) and self.selectedFrame~=index then
						this.clock = {
							os.clock(), 
							os.clock()+duration[(1)]
						};
						this.clicked.clock = {
							os.clock(), 
							os.clock()
						};
					end
					imgui.PopStyleVar();
					if this.clicked.clock[(2)] then
						local _internal0;
						if (self.width>60) then
							_internal0 = 0.25;
						else
							_internal0 = 0.5;
						end
						self.switchBetweenFramesAlpha = imguiAssets:bringFloatTo(self.switchBetweenFramesAlpha, _internal0, this.clicked.clock[(2)], duration[(4)]);
						if os.clock()-this.clicked.clock[(2)]>=duration[(4)] then
							self.previousSelectedFrame = self.selectedFrame;
							self.selectedFrame = index;
							self.switchBetweenFramesAlpha = imguiAssets:bringFloatTo(self.switchBetweenFramesAlpha, 0.00, this.clicked.clock[(2)]+duration[(4)], duration[(5)]);
						end
						if os.clock()-this.clicked.clock[(2)]-duration[(4)]>=duration[(5)] then
							self.selectedFrame = index;
							this.clicked.clock[((2))] = nil;
						end
					end
					if self.selectedFrame==index then
						this.color = imguiAssets:bringVec4To(this.color, colors.active, this.clicked.clock[(1)], duration[(3)]);
					else
						this.hovered.state = imgui.IsItemHovered() or os.clock()-this.clock[(2)]<0;
						if this.hovered.state~=this.hovered.before then
							this.hovered.before = this.hovered.state;
							this.hovered.clock = os.clock();
						end
						local _internal0 = this.hovered.state;
						if (_internal0 == true) then
							_internal0 = colors.hovered;
						else
							if (_internal0 == false) then
								_internal0 = colors.def;
							else
								_internal0 = nil;
							end
						end
						this.color = imguiAssets:bringVec4To(this.color, _internal0, this.hovered.clock, duration[(3)]);
					end
					dl:AddRectFilled(imgui.GetWindowPos()+cursor, imgui.GetWindowPos()+imgui.ImVec2(self.width, cursor.y+35), imgui.ColorConvertFloat4ToU32(this.color));
					imgui.SameLine(15);
					imgui.BeginGroup();
					imgui.SetCursorPosY(cursor.y+17.5-imgui.CalcTextSize(icon).y/2.5);
					imgui.Text(icon);
					if self.width==200 then
						imgui.PushFont(bold10);
						imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, self.alpha/255);
						imgui.SameLine(40);
						imgui.SetCursorPosY(cursor.y+5);
						imgui.Text(title);
						imgui.PopStyleVar();
						imgui.PopFont();
					end
					imgui.EndGroup();
				else
					local _internal0;
					if (self.selectedFrame==index) then
						_internal0 = colors.active;
					else
						_internal0 = colors.def;
					end
					self.UI_MENU_ITEMS[((label))] = {
						clock = {
							0, 
							0
						}, 
						color = _internal0, 
						clicked = {
							clock = {
								0, 
								nil
							}
						}, 
						hovered = {
							state = false, 
							before = nil, 
							clock = 0
						}
					};
				end
			end
		end
		function window.frame:fillChildEx(size, useBorder)
			if useBorder == nil then
				useBorder = true
			end
			local dl = imgui.GetWindowDrawList();
			local pos = imgui.GetCursorScreenPos();
			local rounding = imgui.GetStyle().ChildRounding;
			local color = imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[(imgui.Col.ChildBg)]);
			local borderSize = imgui.GetStyle().ChildBorderSize;
			local borderColor = imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[(imgui.Col.Border)]);
			if useBorder then
				dl:AddRect(pos-imgui.ImVec2(borderSize, borderSize), pos+size+imgui.ImVec2(borderSize, borderSize), borderColor, rounding);
			end
			dl:AddRectFilled(pos, pos+size, color, rounding);
		end
		addEventHandler("onWindowMessage", function(event, wparam)
			if (event==wm.WM_KEYDOWN or event==wm.WM_SYSKEYDOWN) and not imgui.GetIO().WantTextInput then
				if wparam==VK_ESCAPE and window.state[(0)] and not changingHotKey then
					window.state[((0))] = false;
					imguiAssets:setCursorStatus(not window.state[(0)]);
					consumeWindowMessage(true, false);
					return;
				end
			end
		end);
		style:registerWindow("imgui.windows.Main", "Основное окно");
		HotKey:new("imgui.windows.Main", {
			VK_X
		}, "Открыть/закрыть это окно"):registerCallback(function()
			if not movableWindows:isChangingWindowsPositions() then
				window.state[((0))] = not window.state[(0)];
				imguiAssets:setCursorStatus(not window.state[(0)]);
			end
		end);
		imgui.OnFrame(function()
			return not isGamePaused() and window.state[(0)];
		end, function(self)
			self.flags = imgui.WindowFlags.NoTitleBar+imgui.WindowFlags.NoResize+imgui.WindowFlags.NoScrollbar;
			local _internal0;
			if (window.menu.width>60) then
				_internal0 = imgui.WindowFlags.NoInputs;
			else
				_internal0 = 0;
			end
			self.flags = self.flags + _internal0;
			imgui.SetNextWindowPos(imgui.ImVec2(sizeX/2, sizeY/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5));
			imgui.SetNextWindowSize(imgui.ImVec2(700, 420));
			style:beginWindowStyleChangeable("imgui.windows.Main");
			imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(0, 0));
			imgui.Begin("imgui.windows.Main", nil, self.flags);
			do
				local pos = imgui.GetWindowPos();
				local size = imgui.GetWindowSize();
				shadow:apply(imgui.GetBackgroundDrawList(), imgui.ImVec2(pos.x+5, pos.y+5), imgui.ImVec2(size.x-10, size.y-10), 24.0, 100, 2);
			end
			imgui.SetCursorPos(imgui.ImVec2(60+imgui.GetStyle().ItemSpacing.x, 7));
			imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, 1.0-window.menu.alpha/255/2-window.menu.switchBetweenFramesAlpha);
			imgui.BeginGroup();
			local widthAuto = 640-imgui.GetStyle().ItemSpacing.x*2-1;
			if window.menu.selectedFrame==WINDOW_SELECTED_FRAME_HOME then
				imgui.SetScrollY(0);
				window.frame:fillChildEx(imgui.ImVec2(widthAuto, 100));
				imgui.SetCursorPos(imgui.GetCursorPos()+imgui.ImVec2(5, 7));
				imgui.BeginGroup();
				imgui.SetCursorPos(imgui.GetCursorPos()+imgui.ImVec2(5, 5));
				imgui.BeginGroup();
				do
					local time = assets:getLocalTime();
					if time ~= nil then
						imguiAssets:textWithFont(string.format("%d-%d-%d %02d:%02d:%02d", time.wYear, time.wMonth, time.wDay, time.wHour, time.wMinute, time.wSecond), bold10);
						local _internal1;
						if (time.wHour<=10) then
							_internal1 = "Доброе утро, ";
						else
							local _internal0;
							if (time.wHour>=10 and time.wHour<=17) then
								_internal0 = "Добрый день, ";
							else
								_internal0 = "Добрый вечер, ";
							end
							_internal1 = (_internal0);
						end
						local welcomePostfix = _internal1;
						imguiAssets:textWithFont(welcomePostfix..user:getOOCNickname().."!", regular9);
						imguiAssets:textWithFont("Уровень администрирования - "..user:getAdminLvl(), regular9);
						do
							local pos = imgui.GetCursorPos();
							if pos ~= nil then
								imguiAssets:textWithFont("Текущая версия GAdmin - ", regular9);
								imguiAssets:textWithFont("v".."1.3.1", bold9, pos+imgui.ImVec2(132, 0));
							end
						end
					end
				end
				imgui.EndGroup();
				imgui.SameLine(400);
				imgui.BeginGroup();
				do
					local answers, online = user:getAnswersCount(), user:getTime();
					if answers ~= nil and online ~= nil then
						for index, item in ipairs(({
							"BeginGroup", 
							"Онлайн", 
							{
								"Всего", 
								string.format("%02d:%02d:%02d", online.total.hour, online.total.min, online.total.sec)
							}, 
							{
								"За неделю", 
								string.format("%02d:%02d:%02d", online.weekTotal.hour, online.weekTotal.min, online.weekTotal.sec)
							}, 
							{
								"За сессию", 
								string.format("%02d:%02d:%02d", online.session.hour, online.session.min, online.session.sec)
							}, 
							"EndGroup", 
							"SameLine", 
							"BeginGroup", 
							"Ответы", 
							{
								"Всего", 
								answers.total
							}, 
							{
								"За неделю", 
								answers.weekTotal
							}, 
							{
								"За сессию", 
								answers.session
							}, 
							"EndGroup"
						})) do
							if type(item)=="string" then
								if item=="BeginGroup" or item=="EndGroup" or item=="SameLine" then
									if item=="SameLine" then
										imgui.SameLine(nil, 10);
									else
										imgui[(item)]();
									end
								else
									imguiAssets:textWithFont(item, bold10);
								end
							else
								imgui.BeginGroup();
								imguiAssets:textWithFont(item[(1)]..":", regular9);
								imgui.SameLine();
								imguiAssets:textWithFont(tostring(item[(2)]), bold9);
								imgui.EndGroup();
							end
						end
					end
				end
				imgui.EndGroup();
				imgui.SetCursorPos(imgui.ImVec2(imgui.GetCursorPos().x-5, imgui.GetCursorPos().y+15+imgui.GetStyle().ItemSpacing.x));
				imgui.PushTextWrapPos(widthAuto+50);
				imgui.BeginGroup();
				imguiAssets:textWithFont("GAdmin", bold14);
				imguiAssets:textWithFont("Свободная программа, залицензированная под стандартной GNU General Public License v3 лицензией. Исходный код доступен для всех: каждый может внести свой вклад в разработку посредством пулл-реквестов или создания баг-репортов о найденных ошибках, или же создать отдельный скрипт основанный на этом, с учетом сохранения лицензии и открытости кода.", regular9);
				imgui.SetCursorPos(imgui.GetCursorPos()+imgui.ImVec2(10, 0));
				imgui.BeginGroup();
				imguiAssets:textWithFont("GAdmin Repository:", bold10);
				imgui.SameLine(nil, 10);
				imgui.SetCursorPosY(imgui.GetCursorPos().y+2);
				imguiAssets:textWithFont(thisScript().url, regular9);
				imguiAssets:setPreviousItemAbleToCopy(thisScript().url);
				imguiAssets:textWithFont("The Contributors:", bold10);
				imgui.SameLine(nil, 23);
				imgui.SetCursorPosY(imgui.GetCursorPos().y+2);
				imguiAssets:textWithFont(thisScript().authors[(1)], regular9);
				imguiAssets:setPreviousItemAbleToCopy(thisScript().authors[(1)]);
				imgui.EndGroup();
				imguiAssets:textWithFont("Copyright (C) ".."2023-2024".." The Contributors. Licensed under the GNU General Public License v3.", regular9);
				imgui.PopTextWrapPos();
				imgui.PushStyleVarVec2(imgui.StyleVar.ItemSpacing, imgui.ImVec2(2, 5));
				imgui.PushFont(regular12);
				imgui.SetCursorPos(imgui.GetCursorPos()+imgui.ImVec2(0, 10));
				imguiAssets:textWithFont("Быстрые действия", bold14);
				imgui.SetCursorPos(imgui.GetCursorPos()+imgui.ImVec2(0, 6));
				if animations:button("Изменить позицию окон", imgui.ImVec2(math.floor(widthAuto/3), 30), 5) then
					window.state[((0))] = false;
					movableWindows:executeChangingWindowsPositions();
					imguiAssets:setCursorStatus(false);
				end
				imgui.SameLine();
				local _internal0;
				if (user:getAloginStatus()) then
					_internal0 = "/alogout";
				else
					_internal0 = "/alogin";
				end
				if animations:button(_internal0, imgui.ImVec2(math.floor(widthAuto/3)-2, 30), 0) and window.menu.width<=60 then
					local _internal0;
					if (user:getAloginStatus()) then
						_internal0 = "/alogout";
					else
						_internal0 = "/alogin";
					end
					sampSendChat(_internal0);
				end
				imgui.SameLine();
				if animations:button("Собрать информацию о скрипте", imgui.ImVec2(math.floor(widthAuto/3), 30), 10) then
					local filePath = string.format("%s\\GAdmin\\logs\\CollectInformation (%s).log", getWorkingDirectory(), os.date("%Y%m%d-%H-%M-%S"));
					common:writeInFile(filePath, assets:collectScriptInformation());
					notify:send({
						title = "Информация собрана в файл по пути ...", 
						text = filePath, 
						icon = icons.ICON_CHECKMARK
					});
				end
				animations:hint("Необходимо для создания баг-репортов.\nВ полученном логе ваши пароли будет заменены на \"***\".");
				if animations:button("Применить тему", imgui.ImVec2(math.floor(widthAuto/3), 30), 5) then
					local theme = decodeJson(getClipboardText());
					if theme and type(theme)=="table" then
						config.root.styleChangeableWindows = theme;
						thisScript():reload();
					else
						notify:send({
							title = "Ошибка!", 
							text = "Произошла ошибка при применении темы. Убедитесь, что вы скопировали правильную тему.", 
							icon = icons.ICON_WARNING
						});
					end
				end
				animations:hint("Скрипт перезагрузится.##applyTheme");
				imgui.SameLine();
				if animations:button("Экспортировать тему", imgui.ImVec2(math.floor(widthAuto/3)-2, 30), 0) then
					setClipboardText(neatJSON(config.root.styleChangeableWindows, {
						sort = true, 
						wrap = 40
					}));
					notify:send({
						title = "Успешно!", 
						text = "Экспортированная тема записана в ваш буффер обмена.", 
						icon = icons.ICON_CHECKMARK
					});
				end
				imgui.SameLine();
				if animations:button("Сброс настроек", imgui.ImVec2(math.floor(widthAuto/3), 30), 10) then
					window.popupModal.body = function()
						imgui.SetCursorPos(imgui.ImVec2(5, 5));
						imgui.BeginGroup();
						imguiAssets:textWithFont("Сброс настроек", bold14);
						imguiAssets:textWithFont("Учтите, что если вы были на /alogin в момент сброса всех настроек, то вам придется\nввести /alogin еще раз для корректной работы функционала скрипта.", regular12);
						imgui.PushFont(regular12);
						if animations:button("Сбросить все настройки", imgui.ImVec2(imgui.GetWindowWidth()-10, 25)) then
							config.root = assets:copyTable(config.def);
							imgui.CloseCurrentPopup();
							thisScript():reload();
						end
						if animations:button("Сбросить статистику", imgui.ImVec2(imgui.GetWindowWidth()-10, 25)) then
							config.root.user.online = assets:copyTable(config.def.user.online);
							config.root.user.answers = assets:copyTable(config.def.user.answers);
							user.online.session = 0;
							imgui.CloseCurrentPopup();
						end
						if animations:button("Закрыть##imgui.windows.Main.Popup.resetConfiguration", imgui.ImVec2(imgui.GetWindowWidth()-10, 30)) then
							imgui.CloseCurrentPopup();
						end
						imgui.PopFont();
						imgui.EndGroup();
						window.popupModal.size = imgui.GetItemRectSize()+imgui.ImVec2(10, 10);
					end;
					imgui.OpenPopup("imgui.windows.Main.Popup");
				end
				if animations:button("Перезагрузить скрипт", imgui.ImVec2(widthAuto, 30)) then
					thisScript():reload();
				end
				imgui.PopFont();
				imgui.PopStyleVar();
				imgui.EndGroup();
				imgui.EndGroup();
			elseif window.menu.selectedFrame==WINDOW_SELECTED_FRAME_SETTINGS then
				for sectionIndex, section in ipairs(window.configuration) do
					if sectionIndex==4 then
						imgui.NewLine();
					end
					imguiAssets:textWithFont(section[(2)], bold14);
					for index, setting in ipairs(section[(3)]) do
						imgui.BeginGroup();
						imgui.PushFont(regular12);
						local _internal0;
						if (setting[(4)]~=WINDOW_WIDGET_CONFIGURATION_IN_POPUP) then
							_internal0 = setting[(2)];
						else
							_internal0 = "";
						end
						if animations:toggleButton((_internal0).."##imgui.windows.Main.setting."..setting[(2)], setting[(3)][(1)][(4)]) then
							config.root[((section[(1)]))][((setting[(1)]))].use = setting[(3)][(1)][(4)][(0)];
							local _internal0 = setting[((3))][((1))][((5))];
							if _internal0 then
								_internal0();
							end
						end
						imgui.PopFont();
						if setting[(4)]==WINDOW_WIDGET_CONFIGURATION_IN_POPUP then
							imgui.SameLine();
							imgui.PushFont(regular12);
							imgui.SetCursorPosY(imgui.GetCursorPos().y+2);
							if animations:clickableUnderlinedText(setting[(2)].."##imgui.windows.Main.setting.text", false, nil, {
								idle = imgui.GetStyle().Colors[(imgui.Col.Text)], 
								hovered = imgui.GetStyle().Colors[(imgui.Col.Text)], 
								selected = imgui.GetStyle().Colors[(imgui.Col.ButtonActive)]
							}) and window.menu.width<=60 then
								window.popupModal.body = function()
									imgui.PushFont(regular12);
									imgui.SetCursorPos(imgui.ImVec2(5, 5));
									imgui.BeginGroup();
									imguiAssets:textWithFont(setting[(2)], bold14);
									for _, item in ipairs(setting[(3)]) do
										if item[(1)]~="use" then
											if item[(3)]==WINDOW_WIDGET_SWITCH then
												if animations:toggleButton(item[(2)].."##"..item[(1)], item[(4)]) then
													config.root[((section[(1)]))][((setting[(1)]))][((item[(1)]))] = item[(4)][(0)];
													local _internal0 = item[((5))];
													if _internal0 then
														_internal0();
													end
												end
											elseif item[(3)]==WINDOW_WIDGET_SLIDER_INT or item[(3)]==WINDOW_WIDGET_SLIDER_FLOAT then
												imguiAssets:textWithFont(item[(2)], bold12);
												imgui.PushItemWidth(imgui.GetWindowWidth()-10);
												local _internal0;
												if (item[(3)]==WINDOW_WIDGET_SLIDER_INT) then
													_internal0 = "SliderInt";
												else
													_internal0 = "SliderFloat";
												end
												if imgui[((_internal0))]("##imgui.windows.Main.setting."..item[(2)]..item[(1)], item[(6)], item[(4)], item[(5)]) then
													config.root[((section[(1)]))][((setting[(1)]))][((item[(1)]))] = item[(6)][(0)];
												end
												imgui.PopItemWidth();
											elseif item[(3)]==WINDOW_WIDGET_TYPE_SELECTOR then
												imguiAssets:textWithFont(item[(2)], bold12);
												imgui.PushItemWidth(imgui.GetWindowWidth()-10);
												if imgui.SliderInt("##imgui.windows.Main.setting."..item[(2)]..item[(1)], item[(4)], 1, #item-4, item[(4+item[(4)][(0)])]) then
													config.root[((section[(1)]))][((setting[(1)]))][((item[(1)]))] = item[(4)][(0)];
												end
												imgui.PopItemWidth();
											elseif item[(3)]==WINDOW_WIDGET_COLOR_PICKER then
												local flags = imgui.ColorEditFlags.NoInputs;
												local vector = imgui.ImVec4(item[(4)][(0)], item[(4)][(1)], item[(4)][(2)], 1.00);
												local hex = string.format("%02X%02X%02X", vector.x*255, vector.y*255, vector.z*255);
												local dl = imgui.GetWindowDrawList();
												imguiAssets:textWithFont(item[(2)], bold12);
												local pos = imgui.GetCursorPos()+imgui.ImVec2(0, 3);
												imgui.SetCursorPos(imgui.ImVec2(pos.x+7, pos.y+5));
												imguiAssets:textWithFont(hex, bold10, nil, vector);
												imgui.SetCursorPos(imgui.ImVec2(imgui.GetWindowWidth()-31, pos.y));
												if imgui.ColorEdit3("##imgui.windows.main.Popup.colorEdit."..item[(1)]..item[(2)], item[(4)], flags) then
													config.root[((section[(1)]))][((setting[(1)]))][((item[(1)]))] = hex;
												end
												dl:AddRect(pos+imgui.GetWindowPos(), imgui.GetItemRectMax(), imgui.ColorConvertFloat4ToU32(vector), imgui.GetStyle().FrameRounding, 15, 3);
												dl:AddRectFilled(imgui.GetItemRectMin(), imgui.GetItemRectMin()+imgui.ImVec2(4, 25), imgui.ColorConvertFloat4ToU32(vector));
											elseif item[(3)]==WINDOW_WIDGET_CUSTOM then
												imguiAssets:textWithFont(item[(2)], bold12);
												item[(4)](item);
											elseif item[(3)]==WINDOW_WIDGET_INPUT then
												imguiAssets:textWithFont(item[(2)], bold12);
												imgui.SetNextItemWidth(imgui.GetWindowWidth()-10);
												if imgui.InputText("##imgui.windows.Main.Popup.input."..item[(1)]..item[(2)], item[(4)], ffi.sizeof(item[(4)])) then
													config.root[((section[(1)]))][((setting[(1)]))][((item[(1)]))] = ffi.string(item[(4)]);
												end
											end
										end
									end
									imgui.SetCursorPosY(imgui.GetCursorPos().y+5);
									if animations:button("Закрыть##imgui.windows.main.Popup.close", imgui.ImVec2(imgui.GetWindowWidth()-10, 30)) then
										imgui.CloseCurrentPopup();
									end
									imgui.EndGroup();
									window.popupModal.size = imgui.GetItemRectSize()+imgui.ImVec2(10, 10);
									imgui.PopFont();
								end;
								imgui.OpenPopup("imgui.windows.Main.Popup");
							end
							imgui.PopFont();
						end
						imgui.EndGroup();
						if index%3~=0 then
							local _internal0 = index%3;
							if (_internal0 == 1) then
								_internal0 = 205;
							else
								if (_internal0 == 2) then
									_internal0 = 440;
								else
									_internal0 = nil;
								end
							end
							imgui.SameLine(_internal0);
						end
						if setting[(3)][(1)][(2)]~="" then
							imgui.PushFont(regular12);
							animations:hint(setting[(3)][(1)][(2)].."##imgui.windows.main.Popup.hint."..setting[(1)], function()
								return imgui.IsItemHovered() and window.menu.width<=60;
							end);
							imgui.PopFont();
						end
					end
				end
				imgui.NewLine();
				imgui.Dummy(imgui.ImVec2(5, 5));
			elseif window.menu.selectedFrame==WINDOW_SELECTED_FRAME_KEYBINDS then
				imgui.SetScrollY(0);
				imguiAssets:textWithFont("Горячие клавиши", bold14);
				imgui.SetCursorPosY(imgui.GetCursorPos().y+2);
				imgui.BeginGroup();
				for index, hotKey in ipairs(allHotKeys) do
					if not string.find(hotKey.id, "^binderIndex%d+$") then
						imgui.BeginGroup();
						imgui.PushFont(regular12);
						hotKey:render(imgui.ImVec2(100, 25));
						imgui.PopFont();
						imgui.SameLine();
						imguiAssets:textWithFont(hotKey.description, bold10, imgui.GetCursorPos()+imgui.ImVec2(0, 4));
						imgui.EndGroup();
						imgui.SameLine(330);
						if index%2==0 then
							imgui.NewLine();
						end
					end
				end
				imgui.EndGroup();
			elseif window.menu.selectedFrame==WINDOW_SELECTED_FRAME_PLAYERS_CHECKER then
				imgui.SetScrollY(0);
				imgui.BeginGroup();
				imguiAssets:textWithFont("Чекер игроков", bold14);
				imgui.PushFont(regular9);
				imguiAssets:textWithFont("Введите никнейм игрока", bold10);
				window.checker.filter:draw("##imgui.windows.Main.CheckerFilter", "Никнейм", widthAuto/2);
				imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(6, 6));
				imgui.BeginChild("imgui.windows.Main.CheckerFilter.Child", imgui.ImVec2(widthAuto/2, 170), true, self.flags);
				for playerId = 0, 600, 1 do
					if playerId~=user:getId() and sampIsPlayerConnected(playerId) then
						local nickname = sampGetPlayerNickname(playerId);
						local playerInChecker = false;
						for _, player in ipairs(config.root.windows.playerChecker.players) do
							if player.nickname==nickname then
								playerInChecker = true;
								break;
							end
						end
						if window.checker.filter:passFilter(string.format("[%d] %s", playerId, nickname)) and not playerInChecker then
							if imgui.Selectable(string.format("[%d] %s", playerId, nickname)) then
								window.checker.filter:setBufferText(nickname);
							end
						end
					end
				end
				imgui.EndChild();
				imgui.PopStyleVar();
				imgui.PopFont();
				imguiAssets:textWithFont("Заметка об игроке", bold10);
				imgui.PushFont(regular9);
				imgui.InputTextMultiline("##imgui.windows.Main.CheckerPlayerDescription", window.checker.playerNote, ffi.sizeof(window.checker.playerNote), imgui.ImVec2(widthAuto/2, 100));
				imgui.PopFont();
				imgui.PushFont(bold10);
				if animations:button("Добавить", imgui.ImVec2(widthAuto/2, 30)) then
					local _internal0;
					if (ffi.string(window.checker.playerNote)=="") then
						_internal0 = nil;
					else
						_internal0 = ffi.string(window.checker.playerNote);
					end
					local commentary = _internal0;
					local nickname = ffi.string(window.checker.filter.buffer);
					if nickname~="" then
						table.insert(config.root.windows.playerChecker.players, {
							nickname = nickname, 
							commentary = commentary
						});
						imgui.StrCopy(window.checker.playerNote, "");
						window.checker.filter:clear();
					end
				end
				imgui.PopFont();
				imgui.EndGroup();
				imgui.SameLine();
				imgui.BeginGroup();
				imguiAssets:textWithFont("Все игроки", bold10);
				imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(6, 6));
				imgui.BeginChild("imgui.windows.Main.Checker.AllPlayers.Child", imgui.ImVec2(widthAuto/2-5, 350), true, self.flags);
				for index, player in ipairs(config.root.windows.playerChecker.players) do
					local id = sampPlayer:getIdByNickname(player.nickname);
					local _internal0;
					if (id==nil) then
						_internal0 = "[OFFLINE]";
					else
						_internal0 = "[ONLINE]";
					end
					local prefix = (_internal0).." ";
					local _internal1;
					if (id==nil) then
						_internal1 = "FF8585";
					else
						_internal1 = "8DFF85";
					end
					local prefixColor = common:convertHex2ImVec4(_internal1);
					imgui.PushFont(regular9);
					imgui.BeginGroup();
					local pos = imgui.GetCursorPos();
					if imgui.Selectable("##imgui.windows.Main.Checker.Player."..player.nickname, window.checker.selectedPlayer==index) then
						window.checker.selectedPlayer = index;
					end
					imgui.SetCursorPos(pos);
					imgui.TextColored(prefixColor, prefix);
					imgui.SetCursorPos(imgui.ImVec2(pos.x+imgui.CalcTextSize(prefix).x, pos.y));
					imgui.Text(player.nickname);
					imgui.SetCursorPos(pos);
					imgui.EndGroup();
					imgui.PopFont();
				end
				imgui.EndChild();
				imgui.PopStyleVar();
				if animations:button("Удалить", imgui.ImVec2(widthAuto/2-5, 30)) and window.checker.selectedPlayer~=-1 then
					table.remove(config.root.windows.playerChecker.players, window.checker.selectedPlayer);
				end
				imgui.EndGroup();
			elseif window.menu.selectedFrame==WINDOW_SELECTED_FRAME_CUSTOMIZATION then
				imgui.SetScrollY(0);
				imguiAssets:textWithFont("Кастомизация", bold14);
				local childHeight = imgui.GetWindowHeight()-imgui.GetCursorPos().y-6;
				local placeholders = {
					Text = "Текст", 
					TextDisabled = "Невыделенный текст", 
					WindowBg = "Фон окна", 
					ChildBg = "Фон чайлда", 
					PopupBg = "Фон всплывающего окна", 
					Border = "Обводка", 
					BorderShadow = "Тень обводки", 
					FrameBg = "Прочие элементы", 
					FrameBgHovered = "Наведение на прочие элементы", 
					FrameBgActive = "Нажатие на прочие элементы", 
					ScrollbarBg = "Фон полосы-прокрутки", 
					ScrollbarGrab = "Захват полосы-прокрутки", 
					ScrollbarGrabHovered = "Наведение на захват полосы-прокрутки", 
					ScrollbarGrabActive = "Нажатие на захват полосы-прокрутки", 
					Button = "Кнопка", 
					ButtonHovered = "Наведение на кнопку", 
					ButtonActive = "Нажатие на кнопку", 
					Header = "Заголовок", 
					HeaderHovered = "Наведение на заголовок", 
					HeaderActive = "Нажатие на заголовок", 
					Separator = "Разделитель", 
					SeparatorHovered = "Наведение на разделитель", 
					SeparatorActive = "Нажатие на разделитель", 
					TextSelectedBg = "Выделенный текст"
				};
				if window.customization.combo.array == nil then
					window.customization.combo.array = (function()
						local windowList = {						};
						for _, item in ipairs(registeredWindows) do
							table.insert(windowList, item.description);
						end
						window.customization.combo.size = #windowList;
						return imgui.new[("const char*")][(#windowList)](windowList);
					end)();
				end
				window.customization.selectedId = (function()
					local id = "";
					for _, registeredWindow in ipairs(registeredWindows) do
						if registeredWindow.description==ffi.string(window.customization.combo.array[(window.customization.combo.buffer[(0)])]) then
							id = registeredWindow.id;
						end
					end
					return id;
				end)();
				window.customization.editors = (function()
					if config.root.styleChangeableWindows[((window.customization.selectedId))] == nil then
						config.root.styleChangeableWindows[((window.customization.selectedId))] = {						};
					end
					local editors = {					};
					for _, property in ipairs(style:getBaseColors()) do
						local value = imgui.ImVec4(table.unpack(property[(2)]));
						for _, savedProperty in ipairs(config.root.styleChangeableWindows[(window.customization.selectedId)]) do
							if type(savedProperty[(2)])=="table" and property[(1)]==savedProperty[(1)] then
								value.x = savedProperty[(2)][(1)];
								value.y = savedProperty[(2)][(2)];
								value.z = savedProperty[(2)][(3)];
								value.w = savedProperty[(2)][(4)];
							end
						end
						table.insert(editors, {
							styleKey = property[(1)], 
							name = placeholders[(property[(1)])], 
							id = "imgui.windows.Main.Customization.ColorEdit["..property[(1)].."]", 
							value = imgui.new.float[(4)](value.x, value.y, value.z, value.w)
						});
					end
					return editors;
				end)();
				local function changeConfigProperties(item)
					local containsProperty = false;
					for _, property in ipairs(config.root.styleChangeableWindows[(window.customization.selectedId)]) do
						if property[(1)]==item.styleKey then
							containsProperty = true;
							property[((2))] = {
								item.value[(0)], 
								item.value[(1)], 
								item.value[(2)], 
								item.value[(3)]
							};
						end
					end
					if not containsProperty then
						table.insert(config.root.styleChangeableWindows[(window.customization.selectedId)], {
							item.styleKey, 
							{
								item.value[(0)], 
								item.value[(1)], 
								item.value[(2)], 
								item.value[(3)]
							}
						});
					end
				end
				imgui.BeginChild("imgui.windows.Main.Customization.ColorEditors", imgui.ImVec2(380, childHeight), false, self.flags);
				imgui.SetCursorPos(imgui.ImVec2(6, 6));
				imgui.BeginGroup();
				imguiAssets:textWithFont(ffi.string(window.customization.combo.array[(window.customization.combo.buffer[(0)])]), bold10);
				imgui.PushFont(regular9);
				for _, item in ipairs(window.customization.editors) do
					if imgui.ColorEdit4("##"..item.id, item.value, imgui.ColorEditFlags.NoInputs) then
						if config.root.styleChangeableWindows[((window.customization.selectedId))] == nil then
							config.root.styleChangeableWindows[((window.customization.selectedId))] = {							};
						end
						changeConfigProperties(item);
					end
					imgui.SameLine();
					imgui.Text(item.name);
				end
				imgui.PopFont();
				imgui.EndGroup();
				imgui.EndChild();
				imgui.SameLine(nil, 6);
				imgui.BeginChild("imgui.windows.Main.Customization.WindowSelector", imgui.ImVec2(243, childHeight), false, self.flags);
				imgui.SetCursorPos(imgui.ImVec2(6, 6));
				imgui.BeginGroup();
				local widthAuto = imgui.GetWindowWidth()-12;
				imguiAssets:textWithFont("Выберите окно", bold10);
				imgui.SetNextItemWidth(widthAuto);
				imgui.PushFont(regular9);
				imgui.Combo("##imgui.window.Main.Customization.Combo", window.customization.combo.buffer, window.customization.combo.array, window.customization.combo.size, imgui.ComboFlags.HeightLargest+imgui.ComboFlags.NoArrowButton);
				imgui.PopFont();
				imgui.PushFont(bold10);
				if animations:button("Скопировать тему", imgui.ImVec2(widthAuto, 30)) then
					local copiedValues = {					};
					for _, property in ipairs(window.customization.editors) do
						table.insert(copiedValues, imgui.ImVec4(property.value[(0)], property.value[(1)], property.value[(2)], property.value[(3)]));
					end
					window.customization.copiedValues = copiedValues;
				end
				if animations:button("Вставить тему", imgui.ImVec2(widthAuto, 30)) then
					do
						local copiedValues = window.customization.copiedValues;
						if copiedValues ~= nil then
							for index, value in ipairs(copiedValues) do
								window.customization.editors[((index))].value[((0))] = value.x;
								window.customization.editors[((index))].value[((1))] = value.y;
								window.customization.editors[((index))].value[((2))] = value.z;
								window.customization.editors[((index))].value[((3))] = value.w;
							end
							for _, item in ipairs(window.customization.editors) do
								changeConfigProperties(item);
							end
						end
					end
				end
				animations:hint("У вас не скопирована тема", function()
					return window.customization.copiedValues==nil and imgui.IsItemHovered();
				end, nil, common:convertHex2ImVec4("E46876"));
				if animations:button("Сбросить тему", imgui.ImVec2(widthAuto, 30)) then
					config.root.styleChangeableWindows[((window.customization.selectedId))] = nil;
					style.windows[((window.customization.selectedId))] = StyleChanger:new({					});
					for index, property in ipairs(style:getBaseColors()) do
						window.customization.editors[((index))].value[((0))] = property[(2)][(1)];
						window.customization.editors[((index))].value[((1))] = property[(2)][(2)];
						window.customization.editors[((index))].value[((2))] = property[(2)][(3)];
						window.customization.editors[((index))].value[((3))] = property[(2)][(4)];
					end
				end
				if animations:button("Применить для всех окон", imgui.ImVec2(widthAuto, 30)) then
					for _, win in ipairs(registeredWindows) do
						if win.id~=window.customization.selectedId then
							config.root.styleChangeableWindows[((win.id))] = {							};
							for _, source in ipairs(window.customization.editors) do
								table.insert(config.root.styleChangeableWindows[(win.id)], {
									source.styleKey, 
									{
										source.value[(0)], 
										source.value[(1)], 
										source.value[(2)], 
										source.value[(3)]
									}
								});
							end
						end
					end
				end
				imgui.BeginGroup();
				if animations:toggleButton("Использовать MoonMonet", window.customization.moonMonet.toggle) then
					window.customization.colorPicker.clock = os.clock();
				end
				local _internal0;
				if (window.customization.moonMonet.toggle[(0)]) then
					_internal0 = 1.0;
				else
					_internal0 = 0.5;
				end
				if window.customization.colorPicker.alpha == nil then
					window.customization.colorPicker.alpha = _internal0;
				end
				if window.customization.colorPicker.clock then
					local _internal0;
					if (window.customization.moonMonet.toggle[(0)]) then
						_internal0 = 1.0;
					else
						_internal0 = 0.5;
					end
					window.customization.colorPicker.alpha = imguiAssets:bringFloatTo(window.customization.colorPicker.alpha, _internal0, window.customization.colorPicker.clock, 0.3);
				end
				local _internal1;
				if (window.menu.width>60 or not window.customization.moonMonet.toggle[(0)]) then
					_internal1 = imgui.WindowFlags.NoInputs;
				else
					_internal1 = 0;
				end
				imgui.BeginChild("##imgui.windows.Main.Customization.MoonMonetPicker.child", imgui.ImVec2(widthAuto, 30), false, _internal1);
				local _internal2;
				if (window.customization.colorPicker.alpha==1) then
					_internal2 = 1.0-window.menu.alpha/255/2-window.menu.switchBetweenFramesAlpha;
				else
					_internal2 = window.customization.colorPicker.alpha;
				end
				local alpha = _internal2;
				imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, alpha);
				imgui.SetNextItemWidth(widthAuto);
				if imgui.ColorEdit4("##imgui.windows.Main.Customization.MoonMonetPicker", window.customization.moonMonet.accent, imgui.ColorEditFlags.NoSidePreview+imgui.ColorEditFlags.DisplayHex) then
					local function getColorArray()
						return {
							{
								"Text", 
								{
									"neutral1", 
									50
								}
							}, 
							{
								"TextDisabled", 
								{
									"neutral1", 
									500
								}
							}, 
							{
								"WindowBg", 
								{
									"accent1", 
									900
								}
							}, 
							{
								"ChildBg", 
								{
									"accent2", 
									800
								}
							}, 
							{
								"PopupBg", 
								{
									"accent2", 
									800
								}
							}, 
							{
								"Border", 
								{
									"neutral1", 
									"default"
								}
							}, 
							{
								"BorderShadow", 
								{
									"neutral2", 
									"default"
								}
							}, 
							{
								"FrameBg", 
								{
									"accent1", 
									600
								}
							}, 
							{
								"FrameBgHovered", 
								{
									"accent1", 
									500
								}
							}, 
							{
								"FrameBgActive", 
								{
									"accent1", 
									400
								}
							}, 
							{
								"ScrollbarBg", 
								{
									"accent1", 
									800
								}
							}, 
							{
								"ScrollbarGrab", 
								{
									"accent2", 
									600
								}
							}, 
							{
								"ScrollbarGrabHovered", 
								{
									"accent2", 
									500
								}
							}, 
							{
								"ScrollbarGrabActive", 
								{
									"accent2", 
									400
								}
							}, 
							{
								"Button", 
								{
									"accent1", 
									500
								}
							}, 
							{
								"ButtonHovered", 
								{
									"accent1", 
									400
								}
							}, 
							{
								"ButtonActive", 
								{
									"accent1", 
									300
								}
							}, 
							{
								"Header", 
								{
									"accent1", 
									800
								}
							}, 
							{
								"HeaderHovered", 
								{
									"accent1", 
									700
								}
							}, 
							{
								"HeaderActive", 
								{
									"accent1", 
									600
								}
							}, 
							{
								"Separator", 
								{
									"accent2", 
									200
								}
							}, 
							{
								"SeparatorHovered", 
								{
									"accent1", 
									100
								}
							}, 
							{
								"SeparatorActive", 
								{
									"accent1", 
									50
								}
							}, 
							{
								"TextSelectedBg", 
								{
									"neutral1", 
									300
								}
							}
						};
					end
					local vector = imgui.ImVec4(window.customization.moonMonet.accent[(0)], window.customization.moonMonet.accent[(1)], window.customization.moonMonet.accent[(2)], window.customization.moonMonet.accent[(3)]);
					local colorU32 = imgui.ColorConvertFloat4ToU32(vector);
					local colors = moonMonet.buildColors(assets:convertU32ToARGB(colorU32), 1.0, true);
					local colorArray = getColorArray();
					for _, item in ipairs(colorArray) do
						item[((2))] = (function()
							if item[(2)][(2)]=="default" then
								local vector = imgui.GetStyle().Colors[(imgui.Col[(item[(1)])])];
								return {
									vector.x, 
									vector.y, 
									vector.z, 
									vector.w
								};
							end
							local a, r, g, b = assets:explodeARGB(colors[(item[(2)][(1)])][("color_"..item[(2)][(2)])]);
							return {
								r/255, 
								g/255, 
								b/255, 
								a/255
							};
						end)();
					end
					for index = 1, #colorArray, 1 do
						config.root.styleChangeableWindows[((window.customization.selectedId))][((index))] = colorArray[(index)];
					end
					for index, item in ipairs(colorArray) do
						window.customization.editors[((index))].value[((0))] = item[(2)][(1)];
						window.customization.editors[((index))].value[((1))] = item[(2)][(2)];
						window.customization.editors[((index))].value[((2))] = item[(2)][(3)];
						window.customization.editors[((index))].value[((3))] = item[(2)][(4)];
					end
				end
				imgui.PopStyleVar();
				imgui.EndChild();
				imgui.EndGroup();
				imgui.PopFont();
				imgui.EndGroup();
				imgui.EndChild();
			elseif window.menu.selectedFrame==WINDOW_SELECTED_FRAME_BINDER then
				imgui.SetScrollY(0);
				local childHeight = imgui.GetWindowHeight()-imgui.GetCursorPos().y-6;
				imgui.BeginChild("imgui.windows.Main.binderMainChild", imgui.ImVec2(150, childHeight), true, self.flags);
				imgui.SetCursorPos(imgui.ImVec2(6, 6));
				imgui.BeginGroup();
				imguiAssets:textWithFont("Биндер", bold14);
				imgui.SetCursorPosX(0);
				imgui.BeginChild("imgui.windows.Main.binderMainChild.scrollableContent", imgui.ImVec2(imgui.GetWindowWidth(), imgui.GetWindowHeight()-73), false, self.flags);
				imgui.SetCursorPos(imgui.ImVec2(6, 6));
				imgui.PushFont(regular12);
				imgui.BeginGroup();
				for index, bind in ipairs(config.root.binds) do
					if animations:button(bind.title.."##imgui.windows.Main.binderIndex"..index, imgui.ImVec2(imgui.GetWindowWidth()-12, 25)) then
						window.binder.selectedBind = index;
						window.binder.body.delay[((0))] = bind.delay or 800;
						imgui.StrCopy(window.binder.body.title, bind.title);
						imgui.StrCopy(window.binder.body.value, bind.value);
						imgui.StrCopy(window.binder.body.command, bind.commandName or "");
					end
				end
				imgui.EndGroup();
				imgui.PopFont();
				imgui.EndChild();
				imgui.PushFont(bold10);
				imgui.SetCursorPosY(imgui.GetWindowHeight()-36);
				if animations:button("Добавить##imgui.windows.Main.binder", imgui.ImVec2(imgui.GetWindowWidth()-12, 30)) then
					local bindTitle = "Бинд #";
					local bindTitleIndex = #config.root.binds+1;
					for _, bind in ipairs(config.root.binds) do
						do
							local index = string.match(bind.title, "^Бинд #(%d+)$");
							if index ~= nil then
								if tonumber(index)==bindTitleIndex then
									bindTitleIndex = bindTitleIndex + 1;
								end
							end
						end
					end
					binder:newBind(bindTitle..bindTitleIndex, "");
					window.binder.selectedBind = #config.root.binds;
					window.binder.body.delay[((0))] = 800;
					imgui.StrCopy(window.binder.body.title, "Бинд #"..#config.root.binds);
					imgui.StrCopy(window.binder.body.value, "");
					imgui.StrCopy(window.binder.body.command, "");
				end
				imgui.PopFont();
				imgui.EndGroup();
				imgui.EndChild();
				imgui.SameLine();
				imgui.BeginChild("imgui.windows.Main.selectedBindBody", imgui.ImVec2(475, childHeight), true, self.flags);
				if #config.root.binds==0 then
					local text = "У вас еще нет ни одного бинда";
					local size = imgui.CalcTextSize(text);
					imguiAssets:textWithFont(text, regular12, imgui.ImVec2((imgui.GetWindowWidth()-size.x)/2, (imgui.GetWindowHeight()-size.y)/2), imgui.GetStyle().Colors[(imgui.Col.TextDisabled)]);
				else
					imgui.SetCursorPos(imgui.ImVec2(6, 6));
					imgui.BeginGroup();
					imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0, 0, 0, 0));
					imgui.PushStyleVarFloat(imgui.StyleVar.FrameBorderSize, 0);
					imgui.PushFont(bold14);
					imgui.SetCursorPosX(1);
					imgui.SetNextItemWidth(200);
					if imgui.InputText("##imgui.windows.Main.selectedBindBody.titleInput", window.binder.body.title, ffi.sizeof(window.binder.body.title)) then
						config.root.binds[((window.binder.selectedBind))].title = ffi.string(window.binder.body.title);
					end
					imgui.PopFont();
					imgui.PopStyleColor();
					imgui.PopStyleVar();
					imgui.BeginGroup();
					imguiAssets:textWithFont("Команда", bold10);
					imgui.PushFont(regular12);
					imgui.SetNextItemWidth(215);
					if imgui.InputTextWithHint("##imgui.windows.Main.selectedBindBody.commandInput", "Отсутствует", window.binder.body.command, ffi.sizeof(window.binder.body.command)) then
						local newCommand = string.gsub(ffi.string(window.binder.body.command), "^/(.*)", "%1");
						local newCommandCallback = function(args)
							if args == nil then
								args = ""
							end
							local arguments = {							};
							for argument in string.gmatch(args, "[^%s]+") do
								table.insert(arguments, argument);
							end
							binder:sendString(newCommand, config.root.binds[(window.binder.selectedBind)].value, arguments, config.root.binds[(window.binder.selectedBind)].delayBetweenMessages);
						end;
						if newCommand~="" then
							do
								local sourceCommand = config.root.binds[(window.binder.selectedBind)].commandName;
								if sourceCommand ~= nil then
									if sampIsChatCommandDefined(sourceCommand) then
										if not sampIsChatCommandDefined(newCommand) then
											sampUnregisterChatCommand(sourceCommand);
											sampRegisterChatCommand(newCommand, newCommandCallback);
											config.root.binds[((window.binder.selectedBind))].commandName = newCommand;
										end
									end
								else
									if not sampIsChatCommandDefined(newCommand) then
										config.root.binds[((window.binder.selectedBind))].commandName = newCommand;
										sampRegisterChatCommand(newCommand, newCommandCallback);
									end
								end
							end
						else
							do
								local sourceCommand = config.root.binds[(window.binder.selectedBind)].commandName;
								if sourceCommand ~= nil then
									if sampIsChatCommandDefined(sourceCommand) then
										sampUnregisterChatCommand(sourceCommand);
										config.root.binds[((window.binder.selectedBind))].commandName = nil;
									end
								end
							end
						end
					end
					animations:hint("Эта команда уже зарегистрирована!\nПопробуйте другую команду.", function()
						local command = string.gsub(ffi.string(window.binder.body.command), "^/(.*)", "%1");
						return #command>0 and sampIsChatCommandDefined(command) and command~=config.root.binds[(window.binder.selectedBind)].commandName;
					end, nil, common:convertHex2ImVec4("E46876"));
					imgui.EndGroup();
					imgui.SameLine();
					imgui.BeginGroup();
					imgui.SetCursorPosY(imgui.GetCursorPos().y-4);
					imguiAssets:textWithFont("Задержка", bold10);
					imgui.SetNextItemWidth(115);
					imgui.SetCursorPosY(imgui.GetCursorPos().y+4);
					if imgui.InputInt("##imgui.windows.Main.selectedBindBody.delayInputInt", window.binder.body.delay, 10) then
						config.root.binds[((window.binder.selectedBind))].delay = window.binder.body.delay[(0)];
					end
					imgui.EndGroup();
					imgui.SameLine();
					imgui.BeginGroup();
					imgui.SetCursorPosY(imgui.GetCursorPos().y-4);
					imguiAssets:textWithFont("Клавиши", bold10);
					for _, hotKey in ipairs(allHotKeys) do
						do
							local index = string.match(hotKey.id, "^binderIndex(%d+)$");
							if index ~= nil then
								if tonumber(index)==window.binder.selectedBind then
									imgui.SetCursorPosY(imgui.GetCursorPos().y+4);
									hotKey:render(imgui.ImVec2(123, 26), function(self)
										hotKeysCallbacks[((self.id))].callback = function()
											binder:sendString(config.root.binds[(window.binder.selectedBind)].commandName, config.root.binds[(window.binder.selectedBind)].value, nil, config.root.binds[(window.binder.selectedBind)].delayBetweenMessages);
										end;
									end);
								end
							end
						end
					end
					imgui.EndGroup();
					imgui.PopFont();
					imgui.PushFont(regular12);
					imguiAssets:textWithFont("Текст", bold10);
					imgui.SameLine(nil, 106);
					imgui.BeginGroup();
					imgui.PushStyleColor(imgui.Col.Text, imgui.GetStyle().Colors[(imgui.Col.TextDisabled)]);
					local pos = imgui.GetCursorPos();
					imguiAssets:textWithFont("знак ^ в начале линии", bold10);
					imgui.SameLine();
					imgui.SetCursorPosY(pos.y+1);
					imguiAssets:textWithFont("вставит строку в поле ввода игры", regular10);
					imgui.PopStyleColor();
					imgui.EndGroup();
					imgui.PushFont(bold10);
					if animations:button("Вставить переменную##imgui.windows.Main.selectedBindBody", imgui.ImVec2(imgui.GetWindowWidth()-12, 25)) then
						window.popupModal.body = function()
							local function insertVariable(variableName)
								local _internal0;
								if (#ffi.string(window.binder.popup.inputParameter)>0) then
									_internal0 = ", "..ffi.string(window.binder.popup.inputParameter);
								else
									_internal0 = "";
								end
								local value = string.format("%s${{ %s%s }}", ffi.string(window.binder.body.value), variableName, _internal0);
								config.root.binds[((window.binder.selectedBind))].value = value;
								imgui.StrCopy(window.binder.body.value, value);
								imgui.StrCopy(window.binder.popup.inputParameter, "");
								imgui.CloseCurrentPopup();
							end
							imgui.SetCursorPos(imgui.ImVec2(5, 5));
							imgui.BeginGroup();
							imguiAssets:textWithFont("Переменные биндера", bold14);
							imgui.PushFont(regular12);
							imgui.SetNextItemWidth(math.max(260, imgui.GetWindowWidth()-10));
							imgui.InputTextWithHint("##imgui.windows.Main.BinderPopup.inputParameter", "Параметр", window.binder.popup.inputParameter, ffi.sizeof(window.binder.popup.inputParameter));
							imgui.PopFont();
							imgui.BeginChild("imgui.windows.Main.BinderPopup.variableList", imgui.ImVec2(imgui.GetWindowWidth()-10, 300), true);
							imgui.SetCursorPos(imgui.ImVec2(5, 5));
							imgui.BeginGroup();
							local width = math.max(240, imgui.GetWindowWidth()-10);
							imgui.PushFont(bold10);
							if animations:button("GET_ARGUMENT##imgui.windows.Main.BinderPopup.variable", imgui.ImVec2(width, 25)) then
								insertVariable("GET_ARGUMENT");
							end
							imgui.PopFont();
							imgui.PushFont(regular12);
							animations:hint("Получить значение аргумента по индексу, но только если бинд выполнен через команду\n".."Обязательный параметр: индекс аргумента (начиная с 1)");
							imgui.PopFont();
							for _, id in ipairs(binderVariables.order) do
								imgui.PushFont(bold10);
								if animations:button(id.."##imgui.windows.Main.BinderPopup.variable", imgui.ImVec2(width, 25)) then
									insertVariable(id);
								end
								imgui.PopFont();
								imgui.PushFont(regular12);
								animations:hint(binderVariables.description[(id)].."\nНеобязательный параметр: текст который вставится если переменная ничего не вернула");
								imgui.PopFont();
							end
							imgui.EndGroup();
							imgui.EndChild();
							if animations:button("Закрыть##imgui.windows.Main.BinderPopup.close", imgui.ImVec2(imgui.GetWindowWidth()-10, 30)) then
								imgui.CloseCurrentPopup();
							end
							imgui.EndGroup();
							window.popupModal.size = imgui.GetItemRectSize()+imgui.ImVec2(10, 10);
						end;
						window.binder.callPopup = true;
					end
					imgui.PopFont();
					if imgui.InputTextMultiline("##imgui.windows.Main.selectedBindBody.valueInput", window.binder.body.value, ffi.sizeof(window.binder.body.value), imgui.ImVec2(imgui.GetWindowWidth()-12, imgui.GetWindowHeight()-imgui.GetCursorPos().y-37)) then
						config.root.binds[((window.binder.selectedBind))].value = ffi.string(window.binder.body.value);
					end
					imgui.PopFont();
					imgui.PushFont(bold10);
					if animations:button("Удалить бинд##imgui.windows.Main.selectedBindBody", imgui.ImVec2(imgui.GetWindowWidth()-12, 25)) then
						for index, hotKey in ipairs(allHotKeys) do
							do
								local bindIndex = string.match(hotKey.id, "^binderIndex(%d+)$");
								if bindIndex ~= nil then
									if tonumber(bindIndex)==window.binder.selectedBind then
										hotKeysCallbacks[((hotKey.id))] = nil;
										config.root.hotKeys[((hotKey.id))] = nil;
										table.remove(allHotKeys, index);
									end
								end
							end
						end
						table.remove(config.root.binds, window.binder.selectedBind);
						if #config.root.binds>0 then
							window.binder.selectedBind = #config.root.binds;
							window.binder.body.delay[((0))] = config.root.binds[(window.binder.selectedBind)].delay or 800;
							imgui.StrCopy(window.binder.body.title, config.root.binds[(window.binder.selectedBind)].title);
							imgui.StrCopy(window.binder.body.value, config.root.binds[(window.binder.selectedBind)].value);
							imgui.StrCopy(window.binder.body.command, config.root.binds[(window.binder.selectedBind)].commandName or "");
						end
						do
							local command = string.gsub(ffi.string(window.binder.body.command), "^/(.*)", "%1");
							if command ~= nil then
								if sampIsChatCommandDefined(command) then
									sampUnregisterChatCommand(command);
								end
							end
						end
					end
					imgui.PopFont();
					imgui.EndGroup();
				end
				imgui.EndChild();
				if window.binder.callPopup then
					imgui.OpenPopup("imgui.windows.Main.Popup");
					window.binder.callPopup = false;
				end
			elseif window.menu.selectedFrame==WINDOW_SELECTED_FRAME_LOGS then
				imgui.SetScrollY(0);
				imgui.BeginChild("imgui.windows.Main.logs.LogSelection", imgui.ImVec2(widthAuto, 32), true, self.flags);
				imgui.SetScrollY(0);
				imgui.SetCursorPos(imgui.ImVec2(6, 6));
				imgui.BeginGroup();
				imguiAssets:textWithFont("Логи", bold14);
				imgui.SameLine();
				imgui.PushFont(regular12);
				imgui.SetCursorPos(imgui.GetCursorPos()+imgui.ImVec2(5, 2));
				imgui.BeginGroup();
				for index, section in ipairs(allowedLogs) do
					if animations:clickableUnderlinedText(section[(1)].."##imgui.windows.Main.logs.LogSelector", window.logs.selected==index) then
						window.logs.selected = index;
						window.logs.voidQuote = assets.voidQuotes[(math.random(#assets.voidQuotes))];
					end
					imgui.SameLine(nil, 20);
				end
				imgui.EndGroup();
				imgui.PopFont();
				imgui.NewLine();
				imgui.EndGroup();
				imgui.EndChild();
				imgui.BeginChild("imgui.windows.Main.logs.SelectedLog", imgui.ImVec2(widthAuto, imgui.GetWindowHeight()-imgui.GetCursorPos().y-6), true, self.flags);
				imgui.SetCursorPos(imgui.ImVec2(6, 6));
				imgui.BeginGroup();
				imgui.SetNextItemWidth(imgui.GetWindowWidth()-12);
				imgui.PushFont(regular12);
				window.logs.filter:draw("##imgui.windows.logs.LogFilter", nil, imgui.GetWindowWidth()-12);
				imgui.PopFont();
				imgui.BeginChild("imgui.windows.Main.logs.Messages", imgui.ImVec2(imgui.GetWindowWidth()-12, imgui.GetWindowHeight()-imgui.GetCursorPos().y-6), false, self.flags);
				imgui.SetCursorPos(imgui.ImVec2(6, 6));
				imgui.BeginGroup();
				if #allowedLogs[(window.logs.selected)][(2)]==0 then
					local text = window.logs.voidQuote;
					imguiAssets:textWithFont(text, regular12, imgui.ImVec2(((imgui.GetWindowWidth())-imgui.CalcTextSize(text).x)/2, ((imgui.GetWindowHeight()-imgui.GetCursorPos().y)-imgui.CalcTextSize(text).y)/2), imgui.GetStyle().Colors[(imgui.Col.TextDisabled)]);
				end
				for _, message in ipairs(allowedLogs[(window.logs.selected)][(2)]) do
					local fullText = string.format("[%02d:%02d:%02d] %s", message.time.wHour, message.time.wMinute, message.time.wSecond, message.text);
					if window.logs.filter:passFilter(fullText) then
						imgui.BeginGroup();
						imguiAssets:textWithFont(string.format("[%02d:%02d:%02d]", message.time.wHour, message.time.wMinute, message.time.wSecond), bold10);
						imgui.SameLine(nil, 2);
						imgui.SetCursorPosY(imgui.GetCursorPos().y+1);
						imgui.PushFont(regular9);
						imgui.TextWrapped(message.text);
						imgui.PopFont();
						imgui.EndGroup();
						imguiAssets:setPreviousItemAbleToCopy(fullText, nil, "Лог успешно скопирован в буффер обмена!");
					end
				end
				imgui.EndGroup();
				imgui.EndChild();
				imgui.EndGroup();
				imgui.EndChild();
			elseif window.menu.selectedFrame==WINDOW_SELECTED_FRAME_SERVER_TABLES then
				imgui.SetScrollY(0);
				imgui.BeginChild("imgui.windows.Main.serverTables.tableSelectorChild", imgui.ImVec2(widthAuto, 60), true, self.flags);
				imgui.SetCursorPos(imgui.ImVec2(6, 6));
				imgui.BeginGroup();
				imgui.PushFont(regular12);
				imguiAssets:textWithFont("Таблицы", bold14);
				imgui.SameLine(80);
				imgui.SetCursorPosY(imgui.GetCursorPos().y+3);
				if animations:clickableUnderlinedText("Урон/эффекты оружий##serverTable", window.serverTables.selected==0) then
					window.serverTables.selected = 0;
				end
				imguiAssets:textWithFont("| Цены", regular12, imgui.GetCursorPos()-imgui.ImVec2(0, 2));
				imgui.SameLine(80);
				imgui.SetCursorPosY(imgui.GetCursorPos().y+1);
				for index, section in ipairs(serverTables.prices) do
					if animations:clickableUnderlinedText(section[(1)].."##serverTable", window.serverTables.selected==index) then
						window.serverTables.selected = index;
						window.serverTables.filter:clear();
					end
					imgui.SameLine(nil, 20);
				end
				imgui.NewLine();
				imgui.PopFont();
				imgui.EndGroup();
				imgui.EndChild();
				imgui.BeginChild("imgui.windows.Main.serverTables.selectedTableChild", imgui.ImVec2(widthAuto, imgui.GetWindowHeight()-imgui.GetCursorPos().y-12), true, self.flags);
				imgui.SetCursorPos(imgui.ImVec2(6, 6));
				imgui.BeginGroup();
				local _internal0;
				if (window.serverTables.selected==0) then
					_internal0 = "Урон/эффекты оружий";
				else
					_internal0 = serverTables.prices[(window.serverTables.selected)][(1)];
				end
				local title = _internal0;
				imguiAssets:textWithFont(title, bold14);
				if window.serverTables.selected==0 then
					imgui.Columns(#serverTables.weaponDamage[(1)], "imgui.windows.Main.serverTables.weaponDamage", true);
					for sectionIndex, section in ipairs(serverTables.weaponDamage) do
						if section.alpha == nil then
							section.alpha = 1.0;
						end
						imgui.BeginGroup();
						for valueIndex, value in ipairs(section) do
							imgui.SetColumnWidth(valueIndex-1, ({
								111, 
								69, 
								42, 
								39, 
								33, 
								46, 
								60, 
								224
							})[(valueIndex)]);
							do
								local value = string.gsub(value, "%%", "%%%%");
								if value ~= nil then
									local _internal0;
									if (sectionIndex==1) then
										_internal0 = bold10;
									else
										_internal0 = regular9;
									end
									imgui.PushFont(_internal0);
									imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, section.alpha-window.menu.alpha/255/2-window.menu.switchBetweenFramesAlpha);
									imgui.Text(value);
									imgui.PopStyleVar();
									imgui.NextColumn();
									imgui.PopFont();
								end
							end
						end
						imgui.Separator();
						imgui.EndGroup();
						if sectionIndex~=1 then
							do
								local posX, posY = getCursorPos();
								if posX ~= nil and posY ~= nil then
									local columnGroupStartX = imgui.GetWindowPos().x+6;
									local columnGroupEndX = columnGroupStartX+imgui.GetWindowWidth()-6;
									local columnGroupStartY = imgui.GetItemRectMin().y-4;
									local columnGroupEndY = imgui.GetItemRectMax().y;
									if imgui.IsWindowHovered() and ((posX>=columnGroupStartX and posX<=columnGroupEndX) and (posY>=columnGroupStartY and posY<=columnGroupEndY)) then
										section.alpha = 0.5;
										if imgui.IsMouseClicked(0) then
											local WEAPON_NAME = 1;
											local CALIBER = 2;
											local LEGS_DAMAGE = 3;
											local HANDS_DAMAGE = 4;
											local GROIN_DAMAGE = 5;
											local TORSO_DAMAGE = 6;
											local HEAD_DAMAGE = 7;
											local EFFECT = 8;
											local text = section[(WEAPON_NAME)];
											if #section[(CALIBER)]~=0 then
												text = text .. string.format("(%s)", section[(CALIBER)]);
											end
											text = text .. string.format(": Ноги и руки = %s, пах = %s, торс = %s, голова = %s", section[(LEGS_DAMAGE)], section[(GROIN_DAMAGE)], section[(TORSO_DAMAGE)], section[(HEAD_DAMAGE)]);
											if #section[(EFFECT)]~=0 then
												local effect = string.gsub(section[(EFFECT)], "%%", "");
												text = text .. string.format(", эффект = %s", effect);
											end
											setClipboardText(text);
											notify:send({
												title = "Параметры оружия скопированы", 
												text = "Параметры "..section[(WEAPON_NAME)].." скопированы в буффер обмена.", 
												icon = icons.ICON_KEYBOARD
											});
										end
									else
										section.alpha = 1.0;
									end
								end
							end
						end
					end
				else
					local section = serverTables.prices[(window.serverTables.selected)][(2)];
					imgui.PushFont(regular12);
					window.serverTables.filter:draw("##imgui.windows.serverTables.filter", nil, imgui.GetWindowWidth()-12);
					imgui.PopFont();
					local function centerAlign(font, text)
						imgui.SetCursorPosX((imgui.GetColumnOffset()+(imgui.GetColumnWidth()/2))-font:CalcTextSizeA(font.FontSize, math.huge, 0.0, text).x/2);
					end
					local index = 1;
					imgui.BeginChild("imgui.windows.serverTables.tablesScroll", imgui.ImVec2(imgui.GetWindowWidth()-12, 0), false, self.flags);
					while #section>=index do
						local _internal0;
						if (section[(index+2)] and section[(index+3)]) then
							_internal0 = 4;
						else
							_internal0 = 2;
						end
						local columnsCount = _internal0;
						local _internal1;
						if (section[(index+2)] and section[(index+3)]) then
							_internal1 = 2;
						else
							_internal1 = 1;
						end
						local iteratorPeek = _internal1;
						imgui.Columns(columnsCount);
						for step = 1, iteratorPeek, 1 do
							local leftItemIndex = index+(step*2)-2;
							local rightItemIndex = leftItemIndex+1;
							local alpha = 1.00;
							if not window.serverTables.filter:passFilter(string.format("%s %s", section[(leftItemIndex)], section[(rightItemIndex)])) then
								alpha = 0.5;
							elseif #ffi.string(window.serverTables.filter.buffer)>0 then
								if imgui.GetCursorPos().y>=imgui.GetWindowHeight() or imgui.GetCursorPos().y<=imgui.GetScrollY() then
									imgui.SetScrollY(imgui.GetCursorPos().y);
								end
							end
							imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, alpha);
							imgui.BeginGroup();
							centerAlign(bold10, section[(leftItemIndex)]);
							imgui.BeginGroup();
							imguiAssets:textWithFont(section[(leftItemIndex)], bold10);
							imgui.NextColumn();
							imgui.EndGroup();
							imgui.SameLine();
							centerAlign(regular10, section[(rightItemIndex)]);
							imgui.BeginGroup();
							imguiAssets:textWithFont(section[(rightItemIndex)], regular10);
							imgui.NextColumn();
							imgui.EndGroup();
							imgui.EndGroup();
							imgui.PopStyleVar();
							if step==1 and iteratorPeek==2 then
								imgui.SameLine();
							end
						end
						index = index + iteratorPeek*2;
						imgui.Separator();
					end
					imgui.EndChild();
				end
				imgui.EndGroup();
				imgui.EndChild();
			elseif window.menu.selectedFrame==WINDOW_SELECTED_FRAME_NOTES then
				local childHeight = imgui.GetWindowHeight()-imgui.GetCursorPos().y-6;
				imgui.BeginChild("imgui.windows.Main.noteList", imgui.ImVec2(150, childHeight), true);
				imgui.SetCursorPos(imgui.ImVec2(6, 6));
				imgui.BeginGroup();
				imguiAssets:textWithFont("Заметки", bold14);
				imgui.SetCursorPosX(0);
				imgui.BeginChild("imgui.windows.main.noteList.selection", imgui.ImVec2(imgui.GetWindowWidth(), imgui.GetWindowHeight()-42-imgui.GetCursorPos().y), false);
				imgui.PushFont(regular12);
				imgui.SetCursorPosY(3);
				for index, note in ipairs(config.root.playerNotes) do
					imgui.SetCursorPosX(6);
					local size = imgui.ImVec2(imgui.GetWindowWidth()-12, 25);
					local title = note.title;
					local titleSize = regular12:CalcTextSizeA(regular12.FontSize, math.huge, 0.0, title);
					local dotsSize = regular12:CalcTextSizeA(regular12.FontSize, math.huge, 0.0, "...");
					local _internal0;
					if ((titleSize.x-dotsSize.x)>=(size.x-50)) then
						_internal0 = "...";
					else
						_internal0 = "";
					end
					local postfix = _internal0;
					while (titleSize.x-dotsSize.x)>=(size.x-50) do
						title = string.sub(title, 1, #title-1);
						titleSize = regular12:CalcTextSizeA(regular12.FontSize, math.huge, 0.0, title);
					end
					if animations:button(title..postfix.."##noteSelectorIndex"..index, size) then
						do
							local this = window.notes;
							if this ~= nil then
								this.display[((0))] = note.display;
								this.selected = index;
								imgui.StrCopy(this.title, note.title);
								imgui.StrCopy(this.body, note.body);
							end
						end
					end
				end
				imgui.PopFont();
				imgui.EndChild();
				imgui.PushFont(bold10);
				if animations:button("Добавить##imgui.windows.main.notes.add", imgui.ImVec2(imgui.GetWindowWidth()-12, 30)) then
					playerNotes:new({
						title = "Заметка "..#config.root.playerNotes+1, 
						body = "", 
						display = false
					});
					do
						local this = window.notes;
						if this ~= nil then
							this.display[((0))] = false;
							this.selected = #config.root.playerNotes;
							imgui.StrCopy(this.title, config.root.playerNotes[(this.selected)].title);
							imgui.StrCopy(this.body, "");
						end
					end
				end
				imgui.PopFont();
				imgui.EndGroup();
				imgui.EndChild();
				imgui.SameLine();
				imgui.BeginChild("imgui.windows.main.notes.body", imgui.ImVec2(widthAuto-150-imgui.GetStyle().ItemSpacing.x, childHeight), true);
				imgui.SetCursorPos(imgui.ImVec2(6, 6));
				imgui.BeginGroup();
				if #config.root.playerNotes>=1 then
					local this = window.notes;
					local id = config.root.playerNotes[(this.selected)].id;
					this.display[((0))] = playerNotes.displayBuffer[(id)][(0)];
					imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0, 0, 0, 0));
					imgui.PushStyleVarFloat(imgui.StyleVar.FrameBorderSize, 0);
					imgui.PushFont(bold14);
					imgui.SetCursorPosX(1);
					imgui.SetNextItemWidth(imgui.GetWindowWidth()-12);
					if imgui.InputText("##imgui.windows.Main.notes.body.title", this.title, ffi.sizeof(this.title)) then
						config.root.playerNotes[((this.selected))].title = ffi.string(this.title);
					end
					imgui.PopFont();
					imgui.PopStyleColor();
					imgui.PopStyleVar();
					imgui.BeginGroup();
					if animations:toggleButton("##imgui.windows.Main.notes.body.display", this.display) then
						config.root.playerNotes[((this.selected))].display = this.display[(0)];
						playerNotes.displayBuffer[((id))][((0))] = this.display[(0)];
					end
					imgui.SameLine();
					imguiAssets:textWithFont("Отобразить на экране", regular12);
					imgui.EndGroup();
					imgui.PushFont(regular12);
					animations:hint("Ваша заметка будет также как и остальные окна:\nеё можно кастомизировать и изменять ее положение.");
					imgui.Text("Описание заметки");
					if imgui.InputTextMultiline("##imgui.windows.Main.notes.body.description", this.body, ffi.sizeof(this.body), imgui.ImVec2(imgui.GetWindowWidth()-12, imgui.GetWindowHeight()-imgui.GetCursorPos().y-12-30)) then
						config.root.playerNotes[((this.selected))].body = ffi.string(this.body);
					end
					imgui.PopFont();
					imgui.PushFont(bold10);
					if animations:button("Удалить##imgui.windows.Main.notes.body.remove", imgui.ImVec2(imgui.GetWindowWidth()-12, 30)) then
						playerNotes:remove(this.selected);
						do
							local note = config.root.playerNotes[(1)];
							if note ~= nil then
								this.display[((0))] = note.display;
								this.selected = 1;
								imgui.StrCopy(this.title, note.title);
								imgui.StrCopy(this.body, note.body);
							end
						end
					end
					imgui.PopFont();
				else
					local text = window.notes.voidQuote;
					local size = regular12:CalcTextSizeA(regular12.FontSize, math.huge, 0.0, text);
					imguiAssets:textWithFont(text, regular12, imgui.ImVec2(((imgui.GetWindowWidth())-size.x)/2, ((imgui.GetWindowHeight()-size.y)-size.y)/2), imgui.GetStyle().Colors[(imgui.Col.TextDisabled)]);
				end
				imgui.EndGroup();
				imgui.EndChild();
			end
			imgui.EndGroup();
			imgui.PopStyleVar();
			if window.menu.clock then
				local _internal0;
				if (window.menu.state) then
					_internal0 = 200;
				else
					_internal0 = 60;
				end
				window.menu.width = imguiAssets:bringFloatTo(window.menu.width, _internal0, window.menu.clock, 0.1);
				local _internal1;
				if (window.menu.state) then
					_internal1 = 255;
				else
					_internal1 = 0;
				end
				window.menu.alpha = imguiAssets:bringFloatTo(window.menu.alpha, _internal1, window.menu.clock, 0.8);
			end
			imgui.SetCursorPos(imgui.ImVec2(0, 0));
			imgui.PushStyleVarFloat(imgui.StyleVar.ChildBorderSize, 0);
			imgui.SetCursorPosY(imgui.GetScrollY());
			imgui.BeginChild("imgui.windows.Main.menu", imgui.ImVec2(window.menu.width, imgui.GetWindowHeight()), true);
			imgui.GetWindowDrawList():AddRectFilled(imgui.GetWindowPos()+imgui.ImVec2(10, 10), imgui.GetWindowPos()+imgui.ImVec2(window.menu.width, imgui.GetWindowHeight()), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[(imgui.Col.ChildBg)]));
			imgui.PushStyleVarVec2(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.85));
			imgui.SetCursorPos(imgui.ImVec2(5, 5));
			if animations:button(icons.ICON_MENU.."##imgui.windows.Main.menu.switch", imgui.ImVec2(50, 30)) then
				window.menu.clock = os.clock();
				window.menu.state = not window.menu.state;
			end
			if window.menu.width==200 then
				imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, window.menu.alpha/255);
				imgui.SameLine();
				imguiAssets:textWithFont("GAdmin v".."1.3.1", bold10, imgui.ImVec2(122.5-imgui.CalcTextSize("GAdmin v".."1.3.1").x/2, 11));
				imgui.PopStyleVar();
			end
			imgui.PopStyleVar();
			imgui.SetCursorPosY(50);
			imgui.BeginGroup();
			window.menu:item("imgui.windows.Main.menu.home", icons.ICON_HOME, "Главная", 1);
			window.menu:item("imgui.windows.Main.menu.settings", icons.ICON_HAMMER, "Настройки", 2);
			window.menu:item("imgui.windows.Main.menu.keybinds", icons.ICON_KEYBOARD, "Горячие клавиши", 3);
			window.menu:item("imgui.windows.Main.menu.playerChecker", icons.ICON_PERSON, "Чекер игроков", 4);
			window.menu:item("imgui.windows.Main.menu.customization", icons.ICON_PEN_BRUSH, "Кастомизация", 5);
			window.menu:item("imgui.windows.Main.menu.binder", icons.ICON_CLIPBOARD, "Биндер", 6);
			window.menu:item("imgui.windows.Main.menu.logs", icons.ICON_BOOK_OPEN, "Логи", 7);
			window.menu:item("imgui.windows.Main.menu.serverTables", icons.ICON_VERTICAL_BAR_CHART, "Серверные таблицы", 8);
			window.menu:item("imgui.windows.Main.menu.notes", icons.ICON_BOOKMARK_FILLED, "Заметки", 9);
			imgui.EndGroup();
			imgui.EndChild();
			imgui.PopStyleVar();
			do
				local rectMin, rectMax = imgui.GetItemRectMin(), imgui.GetItemRectMax();
				if rectMin ~= nil and rectMax ~= nil then
					local dl = imgui.GetWindowDrawList();
					local color = imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[(imgui.Col.ChildBg)]);
					dl:AddRectFilled(imgui.ImVec2(rectMax.x-4, rectMin.y), imgui.ImVec2(rectMax.x+0.5, rectMin.y+7), color);
					dl:AddRectFilled(imgui.ImVec2(rectMax.x-4, rectMax.y), imgui.ImVec2(rectMax.x+0.5, rectMax.y-7), color);
					if window.menu.width>60 then
						local color = imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[(imgui.Col.WindowBg)]);
						dl:AddRectFilled(imgui.ImVec2(rectMax.x, rectMin.y), rectMax+imgui.ImVec2(2, 0), color);
					end
				end
			end
			if imgui.IsPopupOpen("imgui.windows.Main.Popup") then
				imgui.SetNextWindowSize(window.popupModal.size);
				imgui.SetNextWindowPos(imgui.ImVec2((sizeX-window.popupModal.size.x)/2, (sizeY-window.popupModal.size.y)/2));
			end
			if imgui.BeginPopupModal("imgui.windows.Main.Popup", nil, self.flags+imgui.WindowFlags.NoMove+imgui.WindowFlags.NoScrollbar) then
				local _internal0 = window.popupModal.body;
				if _internal0 then
					_internal0();
				end
			end
			imgui.EndPopup();
			imgui.End();
			imgui.PopStyleVar();
			style:endWindowStyleChangeable("imgui.windows.Main");
		end);
	end,
}

---! END_AUTO_GENERATED_CONTENT

import("EncodingCompatibility")
import("Main")

for name, _ in pairs(modules) do
    if string.find(name, "^events%.") or string.find(name, "^imgui%.windows%.") then
        import(name)
    end
end

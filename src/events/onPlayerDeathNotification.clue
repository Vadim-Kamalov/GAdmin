/**
 * GAdmin - Script simplifying the work of administrators on the Gambit-RP
 * Copyright (C) 2023-2024 The Contributors.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 * SDPX-License-Identifier: GPL-3.0-only
 */

@import "Config"    => config
@import "Assets"    => assets
@import "game.User" => user

ffi.cdef(`
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
`)

local enum /* DIE_SPECIAL_REASON */ {
    DIE_SPECIAL_REASON_CAR          = 49,
    DIE_SPECIAL_REASON_HELI,
    DIE_SPECIAL_REASON_EXPLOSION,
    DIE_SPECIAL_REASON_DROWNED      = 53,
    DIE_SPECIAL_REASON_SUICIDE
}

sampev.onPlayerDeathNotification = fn(killerId, killedId, reason) {
    local userId            = user::getId()
    local killerNickname    = (sampIsPlayerConnected(killerId) || killerId == userId) ? sampGetPlayerNickname(killerId) : nil
    local killedNickname    = (sampIsPlayerConnected(killedId) || killedId == userId) ? sampGetPlayerNickname(killedId) : nil
    
    local reasonKilledBy = match reason {
        DIE_SPECIAL_REASON_CAR          => "убит машиной",
        DIE_SPECIAL_REASON_HELI         => "убит лопастями",
        DIE_SPECIAL_REASON_EXPLOSION    => "убит взрывом",
        DIE_SPECIAL_REASON_DROWNED      => "утонул",
        DIE_SPECIAL_REASON_SUICIDE      => "самоубийство",

        default => (fn {
            if (reason >= 0 && reason <= 18) || (reason >= 22 || reason <= 46) {
                return "убит с " .. require("game.weapons").get_name(reason)
            } else {
                return "неизвестно"
            }
        })()
    }
    
    local message = (killerId == 65535)
        ? string.format("[A] %s[%s] погиб. Причина - %s.", killedNickname, killedId, reasonKilledBy)
        : string.format(
            "[A] %s[%s] убит от рук %s[%s]. Причина - %s.",
            killedNickname,
            killedId,
            killerNickname,
            killerId,
            reasonKilledBy            
        )
    
    if config.root.additions.deathNotifyInChat.use {
        sampAddChatMessage(message, 0xAFAFAF)
    }

    if config.root.additions.idInKillList.use {
        if local kill = ffi.cast("stKillInfo*", sampGetKillInfoPtr()) {
            lua_thread.create(fn {
                wait(0)

                if killerNickname {
                    kill.killEntry[4].szKiller = ffi.new("char[25]", string.sub(killerNickname .. "[" .. killerId .. "]", 1, 24))
                }

                if killedNickname {
                    kill.killEntry[4].szVictim = ffi.new("char[25]", string.sub(killedNickname .. "[" .. killedId .. "]", 1, 24))
                }
            })
        }
    }

    for _, log in allowedLogs {
        if log[1] == "Килл-лист" {
            table.insert(log[2], { time = assets::getLocalTime(), text = message })
        }
    }
}

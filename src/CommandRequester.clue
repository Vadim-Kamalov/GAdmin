/**
 * GAdmin - Script simplifying the work of administrators on the Gambit-RP
 * Copyright (C) 2023 The Contributors.
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

@import "game.User"     => user
@import "game.Admins"   => admins

@import "Config"        => config
@import "Notifications" => notify

@define COMMAND_REQUEST_SECONDS_DURATION 5

static enum /* COMMAND_REQUEST_TYPE */ {
    COMMAND_REQUEST_TYPE_NONE,          //! Initialize status.   
    COMMAND_REQUEST_TYPE_NO_COMMENTARY, //! /$command [$args...] && /ans $id.to форма "$command $args" принята!
    COMMAND_REQUEST_TYPE_COMMENTARY,    //! /$command [$args...] // $nickname.from
    COMMAND_REQUEST_TYPE_ANSWER         //! /$command [$args...] && /ans $id.to $command by $id.from
}

static enum /* COMMAND_REQUEST_DISPLAY */ {
    COMMAND_REQUEST_DISPLAY_NOTIFICATION,
    COMMAND_REQUEST_DISPLAY_BOTTOM_BAR
}

//! TODO: @HotKey
static __commandRequester__ = {
    lastUserCommand = "",

    states = {
        requester           = false,
        frame               = false, // window or notification.
        ignoreNextCommands  = false
    },
    
    current = {
        clock = os.clock()
        
        id = {
            to      = -1,
            from    = -1
        },

        command = {
            type        = COMMAND_REQUEST_TYPE_NONE,
            splitted    = {
                name = "",
                args = ""
            }
        }
    }
}

/**
 * Setup time watcher, to remove request after `$COMMAND_REQUEST_SECONDS_DURATION` seconds passed.
 * Only for use in while-true loop!
 *
 * @return void
 */
method __commandRequester__::setupTimeWatcher() {
    if self.states.requester && os.clock() - self.current.clock >= $COMMAND_REQUEST_SECONDS_DURATION {
        self::remove()
    }
}

/**
 * Setup user commands watcher. Only for use in sampev.onSendCommand function!
 *
 * @param command string
 * @return void
 */
method __commandRequester__::setupUserCommandWatcher(command) {
    if !self.states.ignoreNextCommands {
        self.lastUserCommand = command
    }
}

/**
 * Setup char messages watcher. Only for use in sampev.onServerMessage function!
 * 
 * @param text string
 * @param color number
 * @return void
 */
method __commandRequester__::setupChatWatcher(text, color) {
    if string.find(text, "^{......}%| {......}У Вас нет доступа для использования данной команды%.$") {
        self::new(user::getId(), self.lastUserCommand)
    }

    if local id, command = string.match(text, "^%[A%] .+%[(%d+)%]: (/.*)") {
        if color == 866792362 {
@ifdef __GADMIN_DEBUG__
{
            $debugSuccessful!("__commandRequester__::setupChatWatcher", "found request. called self::new")
            $debugInformation!("__commandRequester__::setupChatWatcher", "passed with: id = " .. id .. "; command = " .. command .. "; text = " .. text)
}
            self::new(tonumber(id), command)
        }
    } else {
        local command, type = self.current.command.name, self.current.command.type
        if type == COMMAND_REQUEST_TYPE_NO_COMMENTARY {
            if local command = string.match(text, "^%[%A%] .*%[%d+]: Форма \"(.+)\" принята!$") {
                if command == (self.current.command.name .. " " .. self.current.command.args) {
                    self::remove()
                }
            }
        } elseif type == COMMAND_REQUEST_TYPE_COMMENTARY {
            if local from = string.match(text, "^Администратор .+%. Причина:.*// (.+)$") {
                if local admin = admins::getAdminById(self.current.id.from) {
                    if from == admin.nickname.ooc {
                        self::remove()
                    }
                }
            }
        } elseif type == COMMAND_REQUEST_TYPE_ANSWER {
            if local to, name = string.match(text, "^%[A%] .+%[%d+%] ответил .+%[(%d+)%]: (%w+) by .+") {
                if to == self.current.id.to && string.lower(name) == string.lower(self.current.command.splitted.name) {
                    self::remove()
                }
            }
        }
    }
}

/**
 * Approve last command request.
 * @return void
 */
method __commandRequester__::approve() {
    local command, args = self.current.command.splitted.name, self.current.command.splitted.args
    local type          = self.current.command.type

    self.states.ignoreNextCommands = true
    
    if type == COMMAND_REQUEST_TYPE_NO_COMMENTARY {
        lua_thread.create(fn {
            sampSendChat(string.format("/%s %s", command, args))
            wait($COMMAND_DELAY)
            sampSendChat(string.format("/a Форма \"%s %s\" принята!", command, args))
            
            self.states.ignoreNextCommands = false
        })
    } elseif type == COMMAND_REQUEST_TYPE_COMMENTARY {
        if local admin = admins::getAdminById(self.current.id.from) {
            sampSendChat(string.format("/%s %s // %s", command, args, admin.nickname.ooc))
            
            self.states.ignoreNextCommands = false
        }
    } elseif type == COMMAND_REQUEST_TYPE_ANSWER {
        if local admin = admins::getAdminById(self.current.id.from) {
            lua_thread.create(fn {
                sampSendChat(string.format("/%s %s", command, args))
                wait($COMMAND_DELAY)
                sampSendChat(string.format("/ans %d %s by %s", self.current.id.to, string.upper(command), admin.nickname.ooc))
                
                self.states.ignoreNextCommands = false
            })
        }
    }

    self::remove()
}

/**
 * Remove last command request.
 * @return void
 */
method __commandRequester__::remove() {
    self.states.requester           = false
    self.states.frame               = false
    self.current                    = {
        clock = os.clock(),

        id = {
            from    = -1,
            to      = -1
        },

        command = {
            type        = COMMAND_REQUEST_TYPE_NONE,
            splitted    = {
                name = "",
                args = ""
            }
        }
    }
}

/**
 * Create new command request (only if command is allowed).
 *
 * @see __config__.root.additions.commandRequester
 *
 * @param from number       Player/User ID that send this command.
 * @param command string    Full command with arguments.
 * @return void
 */
method __commandRequester__::new(from, command) {
    local commandType = COMMAND_REQUEST_TYPE_NONE

    if local this = config.root.additions.commandRequester {
        for _, commandData in this.allowedCommands {
            if local command = string.match(command, "^/(%S+)") {
                if string.lower(commandData[1]) == string.lower(command) {
                    commandType = commandData[2]
                }
            }
        }
    }

    if commandType != COMMAND_REQUEST_TYPE_NONE && !self.states.requester {
        self.states.requester = true

        if local name, idOrMessage, args = string.match(command, "^/(%S+)%s*(%S*)(.*)") {
            if local id = tonumber(idOrMessage) {
                if sampIsPlayerConnected(id) {
                    self.current = {
                        clock = os.clock(),
                        
                        id = {
                            from    = from,
                            to      = id
                        },

                        command = {
                            type        = commandType,
                            splitted    = {
                                name = string.lower(name),
                                args = idOrMessage .. args
                            }
                        }
                    } 
                }
            } else {
                self.current = {
                    clock = os.clock(),

                    id = {
                        from    = from,
                        to      = -1
                    },

                    command = {
                        type        = commandType,
                        splitted    = {
                            name = string.lower(name),
                            args = idOrMessage .. args
                        }
                    }
                }
            }

            if from == user::getId() {
                sampSendChat("/a " .. command)
            } else {
                if !self.states.frame {
                    self.states.frame = true
                    if config.root.additions.commandRequester.displayType == COMMAND_REQUEST_DISPLAY_NOTIFICATION {
                        notify::send({
                            title       = "Пришла форма",
                            text        = command,
                            condition   = (fn { return !self.states.frame }),
                            buttons     = {
                                first = {
                                    text = "Закрыть",
                                    call = (fn { self::remove() })
                                },

                                second = {
                                    text = "Принять",
                                    call = (fn { self::approve() })
                                }
                            }
                        })
                    }
                }
            }
        }
    }
}

return __commandRequester__
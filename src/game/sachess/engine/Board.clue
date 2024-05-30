/**
 * This file is a part of the SAChess project: see `src/sachess/README.md` for more details.
 *
 * GAdmin - Script simplifying the work of administrators on the Gambit-RP
 * Copyright (C) 2023-2024 The Contributors.
 *
 * SAChess - MoonLoader script that implements Lichess API.
 * Copyright (C) 2024 defaultzone.
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

@import "game.sachess.engine.Models"      => models
@import "game.sachess.engine.Position"    => position
@import "game.sachess.engine.Setup"       => setup
@import "game.sachess.engine.Coordinates" => coordinates

@import "game.sachess.interface.Style" => style

static enum /** @enum GAME_STATUS */ {
    GAME_STATUS_THREE_MOVE_REPETITION = -2,
    GAME_STATUS_FIFTY_MOVE_RULE,
    GAME_STATUS_STALEMATE,
    GAME_STATUS_DRAW,
    GAME_STATUS_CHECKMATE,
    GAME_STATUS_OUT_OF_TIME,
    GAME_STATUS_ABORTED,
    GAME_STATUS_RESIGN,
    GAME_STATUS_ACTIVE,
}

/**
 * @class Board
 *
 * @field public position Position
 * @field public moves number[][]
 * @field public userSide CHESS_SIDE
 * @field public sideToMove CHESS_SIDE
 * @field public noCapturesMoveCount number
 * @field public totalMoveCount number
 * @field public check boolean
 * @field public renderFlags number|nil
 * @field public streamer BoardStreamer|nil
 * @field public gameStatus GAME_STATUS
 * @field public squares table<number, table[]>
 */
local Board = {}

/**
 * Create new instance of `Board` class.
 *
 * @param setup BoardSetup
 * @return Board
 */
method Board::new(setup) {
    local instance = {}

    setmetatable(instance, self)
    self.__index = self

    instance.position               = setup.position
    instance.moves                  = {}
    instance.userSide               = setup.userSide
    instance.sideToMove             = setup.sideToMove
    instance.noCapturesMoveCount    = setup.moveCount.noCaptures
    instance.totalMoveCount         = setup.moveCount.total
    instance.check                  = false
    instance.renderFlags            = nil
    instance.streamer               = nil
    instance.gameStatus             = instance::getGameStatus()
    instance.squares                = {
        [CHESS_SIDE_WHITE] = {},
        [CHESS_SIDE_BLACK] = {}
    }

    instance::writeSquares()
    
    return instance
}

/**
 * Reset current board properties (except `self.streamer`).
 * @return void
 */
method Board::reset() {
    local setup = setup.from::forsythEdwardsNotation(self.userSide)

    self.position               = setup.position
    self.moves                  = {}
    self.userSide               = setup.userSide
    self.sideToMove             = setup.sideToMove
    self.noCapturesMoveCount    = setup.moveCount.noCaptures
    self.totalMoveCount         = setup.moveCount.total
    self.check                  = false
    self.gameStatus             = self::getGameStatus()
    self.squares                = {
        [CHESS_SIDE_WHITE] = {},
        [CHESS_SIDE_BLACK] = {}
    }

    self::writeSquares()
}

/**
 * Get current game status on the board.
 * @return GAME_STATUS
 */
method Board::getGameStatus() {
    local count = 0

    if #self.moves >= 8 {
        for index = #self.moves - 7, #self.moves {
            if self.moves[index + 2] {
                if self.moves[index][1] == self.moves[index + 2][2] && self.moves[index][2] == self.moves[index + 2][1] {
                    count += 1
                }
            }

            if count == 6 {
                return GAME_STATUS_THREE_MOVE_REPETITION
            }
        }
    }

    if self.noCapturesMoveCount == 50 {
        return GAME_STATUS_FIFTY_MOVE_RULE
    }

    if #self::getLegalMoves() == 0 {
        return (self.check) ? GAME_STATUS_CHECKMATE : GAME_STATUS_STALEMATE
    }

    return GAME_STATUS_ACTIVE
}

/**
 * Get legal moves that not leads to checkmate.
 * @return number[]
 */
method Board::getLegalMoves() {
    local moves = {}

    for _, move in (self.check) ? self.position::getKingSafeMoves() : self.position::generateMoves() {
        if !self.position::isKingLossMove(move) {
            table.insert(moves, move)
        }
    }

    return moves
}

/**
 * Make move with algebraic notation in UCI format.
 *
 * @param move string
 * @return void
 */
method Board::moveAlgebraic(move) {
    local initial, new  = string.sub(move, 1, 2), string.sub(move, 3, 4)
    initial, new        = models.squares[self.sideToMove][initial], models.squares[self.sideToMove][new]

    local conversion = (#move == 5) ? models::getFromChar(string.sub(move, 5, 5)) : nil

    self::move({ initial, new }, conversion)  
}

/**
 * Make board move with incrementing total/no captures moves and with swapping
 * sides. Move is represented as `{ number, number }` table, where first item is start square.
 *
 * @param move number[]
 * @param conversion CHESS_MODEL|nil
 * @return void
 */
method Board::move(move, conversion = CHESS_MODEL_QUEEN) {
    for _, genMove in self::getLegalMoves() {
        if genMove[1] == move[1] && genMove[2] == move[2] {
            self.position::move(move, string.upper(models::getChar(conversion)))
            self::writeSquares()
            self.position::rotate()
           
            self.check      = self.position::isKingInCheck()
            self.sideToMove = ($ == CHESS_SIDE_WHITE) ? CHESS_SIDE_BLACK : CHESS_SIDE_WHITE

            table.insert(self.moves, move)

            if self.sideToMove == CHESS_SIDE_BLACK {
                self.noCapturesMoveCount = (move[2] == '.') ? $ + 1 : 0
                self.totalMoveCount     += 1
            }

            self.gameStatus = self::getGameStatus()
            
            return
        }
    }
}

/**
 * Get all board squares. Length of returned array always be 64.
 * @return table<string, CHESS_MODEL|table<string, CHESS_SIDE>|string>[]
 */
method Board::getSquares() {
    local squares = {}

    for line with string.gmatch(self.position.board, "%S+") {
        for index = 1, #line {
            local square    = string.sub(line, index, index)
            local row, col  = math.floor(#squares / 8) + 1, #squares % 8 + 1

            local cellSide  = ((row + col) % 2 == 0) ? CHESS_SIDE_WHITE : CHESS_SIDE_BLACK
            local pieceSide = ($IS_UPPER!(square)) ? self.sideToMove : ((self.sideToMove == CHESS_SIDE_WHITE) ? CHESS_SIDE_BLACK : CHESS_SIDE_WHITE)
            local algebraic = string.char(col + string.byte('a') - 1) .. (9 - row)

            table.insert(squares, {
                model     = models::getFromChar(square),
                anchor    = ffi.new("int[1]", #squares + 1),
                algebraic = algebraic,
                alpha     = 1.00,
                side      = {
                    cell    = cellSide,
                    piece   = pieceSide
                }
                
                index = {
                    [CHESS_SIDE_WHITE] = models.squares[self.userSide][algebraic],
                    [CHESS_SIDE_BLACK] = models.squares[(self.userSide == CHESS_SIDE_WHITE) ? CHESS_SIDE_BLACK : CHESS_SIDE_WHITE][algebraic],
                }
            })
        }
    }

    return squares
}

/**
 * Write squares for white and black perspective in `board.squares`.
 * @return void
 */
method Board::writeSquares() {
    self.squares[self.sideToMove]   = self::getSquares()
    self.sideToMove                 = ($ == CHESS_SIDE_WHITE) ? CHESS_SIDE_BLACK : CHESS_SIDE_WHITE

    self.position::rotate()
    self.squares[self.sideToMove] = self::getSquares()
    self.position::rotate()

    self.sideToMove = ($ == CHESS_SIDE_WHITE) ? CHESS_SIDE_BLACK : CHESS_SIDE_WHITE
}

/**
 * Render board.
 *
 * @param id string
 * @return void
 */
method Board::render(id) {
    imgui.PushStyleVarFloat(imgui.StyleVar.ChildRounding, 0)
    imgui.PushStyleVarVec2(imgui.StyleVar.ItemSpacing, imgui.ImVec2(0, 0))
    imgui.BeginGroup()
        for squareIndex, square in self.squares[self.userSide] {
            if local item = self.interface?[squareIndex] {
                local color = item.color

                if local lastMove = self.moves[#self.moves] {
                    local side = (self.sideToMove == CHESS_SIDE_BLACK) ? CHESS_SIDE_WHITE : CHESS_SIDE_BLACK
                          side = (self.userSide == CHESS_SIDE_BLACK) ? self.sideToMove : side

                    if square.algebraic == coordinates::render(lastMove[1], side) ||
                       square.algebraic == coordinates::render(lastMove[2], side)
                    {
                        color = style.board[square.side.cell].lastMove
                    }
                }

                if self.check && square.model == CHESS_MODEL_KING && square.side.piece == self.sideToMove {
                    color = style.board.check
                }
                
                imgui.PushStyleColor(imgui.Col.ChildBg, color)
                    imgui.BeginChild(id .. ".squareIndex" .. squareIndex, imgui.ImVec2(50, 50), true, self.renderFlags)
                        for _, move in self.interface.allowedMoves {
                            if move[2] == square.index[self.sideToMove] {
                                local size = imgui.GetWindowSize()
                                if square.model == CHESS_MODEL_NONE {
                                    imgui.GetWindowDrawList()::AddCircleFilled(
                                        imgui.GetWindowPos() + imgui.ImVec2(size.x / 2, size.y / 2),
                                        8,
                                        imgui.ColorConvertFloat4ToU32(style.board[square.side.cell].moveTo),
                                        0xFF
                                    )
                                } else {
                                    for index, posA in ({
                                        imgui.GetWindowPos(),
                                        imgui.ImVec2(imgui.GetWindowPos().x + imgui.GetWindowWidth(), imgui.GetWindowPos().y),
                                        imgui.ImVec2(imgui.GetWindowPos().x, imgui.GetWindowPos().y + imgui.GetWindowHeight()),
                                        imgui.GetWindowPos() + imgui.GetWindowSize()
                                    }) {
                                        local posB  = imgui.ImVec2(posA.x + ((index % 2 == 0) ? -15 : 15), posA.y)
                                        local posC  = imgui.ImVec2(posA.x, posA.y + ((index <= 2) ? 15 : -15))
                                        local color = imgui.ColorConvertFloat4ToU32(style.board[square.side.cell].moveTo)
                                        imgui.GetWindowDrawList()::AddTriangleFilled(posA, posB, posC, color)
                                    }
                                }
                            }
                        }

                        if square.model != CHESS_MODEL_NONE {
                            local maxX, maxY    = 270, 90
                            local pieceImageUv0 = imgui.ImVec2(((square.model - 2) * 45) / maxX, (45 * (square.side.piece - 1)) / maxY)
                            local pieceImageUv1 = imgui.ImVec2(45 / maxX, 45 / maxY) + pieceImageUv0
                            local color         = imgui.ImVec4(1, 1, 1, imgui.GetStyle().Alpha)

                            if imgui.BeginDragDropSource(imgui.DragDropFlags.SourceNoPreviewTooltip) {
                                local posX, posY  = getCursorPos()
                                local imageSize   = imgui.ImVec2(45, 45)
                                local imagePosMin = imgui.ImVec2(posX - imageSize.x / 2, posY - imageSize.y / 2)
                                local imagePosMax = imagePosMin + imageSize

                                self.interface.dragDropping = true
                                square.alpha                = 0.00

                                imgui.GetForegroundDrawList()::AddImage(
                                    cburnett,
                                    imagePosMin,
                                    imagePosMax,
                                    pieceImageUv0,
                                    pieceImageUv1
                                )

                                if square.model != CHESS_MODEL_NONE && square.side.piece == self.sideToMove {
                                    item.color      = style.board[square.side.cell].active
                                    item.selected   = true

                                    self.interface.allowedMoves = {}

                                    if ((self.streamer?.state) ? self.sideToMove == self.userSide : true) {
                                        for _, move in self::getLegalMoves() {
                                            if move[1] == square.index[self.sideToMove] {
                                                table.insert(self.interface.allowedMoves, move)
                                            }
                                        }
                                    }
                                }

                                imgui.SetDragDropPayload(id .. ".dragDrop", square.anchor, ffi.sizeof("int"))
                                imgui.EndDragDropSource()
                            }

                            imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, square.alpha)
                                imgui.SetCursorPos(imgui.ImVec2(2, 2))
                                imgui.Image(cburnett, imgui.ImVec2(45, 45), pieceImageUv0, pieceImageUv1, color)
                            imgui.PopStyleVar()
                        }
                    imgui.EndChild()

                    local dl = imgui.GetWindowDrawList()

                    if imgui.BeginDragDropTarget() {
                        if local payload = imgui.AcceptDragDropPayload(id .. ".dragDrop", imgui.DragDropFlags.AcceptPeekOnly) {
                            local index                 = ffi.cast("int*", payload.Data)[0]
                            self.interface.dragDropping = true

                            if payload.Delivery {
                                for _, move in self.interface.allowedMoves {
                                    if move[2] == square.index[self.sideToMove] && !self.interface.promotion(square, move) {
                                        if self.sideToMove == self.userSide && self.streamer?.state {
                                            self.streamer::move(move)
                                        }

                                        self.interface.resetAllowedMoves()
                                        self::move(move)

                                        break
                                    } else {
                                        self::writeSquares()
                                        self.interface.resetAllowedMoves()
                                    }
                                }

                                if #self.interface.allowedMoves == 0 {
                                    self::writeSquares()
                                    self.interface.resetAllowedMoves()
                                }
                            }
                        }

                        dl::AddRect(
                            imgui.GetItemRectMin(),
                            imgui.GetItemRectMax(),
                            imgui.ColorConvertFloat4ToU32(style.board[square.side.cell].moveTo),
                            nil,
                            nil,
                            3
                        )

                        imgui.EndDragDropTarget()
                    }

                    if imgui.IsItemHovered() && !self.renderFlags {
                        if #self.interface.allowedMoves > 0 {
                            dl::AddRect(
                                imgui.GetItemRectMin(),
                                imgui.GetItemRectMax(),
                                imgui.ColorConvertFloat4ToU32(style.board[square.side.cell].moveTo),
                                nil,
                                nil,
                                3
                            )
                        }

                        if imgui.IsMouseClicked(1 /* RIGHT_MOUSE_BUTTON */) {
                            self.interface.arrows.downOn = #self.interface.arrows + 1
                            table.insert(self.interface.arrows, {
                                {
                                    index    = squareIndex,
                                    position = imgui.GetItemRectMin() - imgui.GetWindowPos()
                                }
                            })
                        }

                        if imgui.IsMouseReleased(1 /* RIGHT_MOUSE_BUTTON */) {
                            self.interface.arrows.downOn = 0
                            if #self.interface.arrows >= 2 {
                                local lastArrow = self.interface.arrows[#self.interface.arrows]
                                for index, arrow in self.interface.arrows {
                                    if index != #self.interface.arrows
                                       && lastArrow[1].index == arrow[1].index
                                       && lastArrow[2]?.index == arrow[2]?.index
                                    {
                                        table.remove(self.interface.arrows, index)
                                        table.remove(self.interface.arrows, #self.interface.arrows)
                                    }
                                }
                            }
                        }

                        if imgui.IsMouseDown(1 /* RIGHT_MOUSE_BUTTON */) {
                            for index, arrow in self.interface.arrows {
                                if index == self.interface.arrows.downOn {
                                    arrow[2] = {
                                        index    = squareIndex,
                                        position = imgui.GetItemRectMin() - imgui.GetWindowPos()
                                    }
                                }
                            }
                        }
                    }

                    if imgui.IsItemClicked() && !self.renderFlags {
                        for _, move in self.interface.allowedMoves {
                            if move[2] == square.index[self.sideToMove] && !self.interface.promotion(square, move) {
                                if self.sideToMove == self.userSide && self.streamer?.state {
                                    self.streamer::move(move)
                                }

                                local fromIndex = 0
                                {
                                    for index, item in self.interface {
                                        if item.active {
                                            fromIndex = index
                                        }
                                    }
                                }

                                self::move(move)

                                break
                            }
                        }

                        self.interface.resetAllowedMoves()
                        self.interface.arrows = { downOn = 0 }

                        if square.model != CHESS_MODEL_NONE && square.side.piece == self.sideToMove {
                            item.color      = style.board[square.side.cell].active
                            item.selected   = true

                            if ((self.streamer?.state) ? self.sideToMove == self.userSide : true) {
                                for _, move in self::getLegalMoves() {
                                    if move[1] == square.index[self.sideToMove] {
                                        table.insert(self.interface.allowedMoves, move)
                                    }
                                }
                            }
                        }
                    }

                    for _, arrow in self.interface.arrows {
                        local alpha    = 0.5
                        local size     = imgui.ImVec2(45, 45)
                        local color    = imgui.ImVec4(style.board.arrow.x, style.board.arrow.y, style.board.arrow.z, 0.5)
                        local colorU32 = imgui.ColorConvertFloat4ToU32(color)
                        local dl       = imgui.GetForegroundDrawList()

                        dl.Flags = imgui.DrawListFlags.AntiAliasedLines

                        if #arrow == 2 {
                            if arrow[1].index == arrow[2].index {
                                dl::AddRect(
                                    arrow[1].position + imgui.GetWindowPos(),
                                    arrow[1].position + size + imgui.ImVec2(5, 5) + imgui.GetWindowPos(),
                                    colorU32,
                                    0,
                                    nil,
                                    5
                                )
                            } else {
                                local centerA = arrow[1].position + size * 0.5 + imgui.GetWindowPos()
                                local centerB = arrow[2].position + size * 0.5 + imgui.GetWindowPos()
                                dl::AddLine(centerA, centerB, colorU32, 7)
                            }
                        }
                    }
                imgui.PopStyleColor()
            } else {
                self.interface               ??= {}
                self.interface.dragDropping    = false
                self.interface.arrows          = { downOn = 0 }
                self.interface.allowedMoves    = {}
                self.interface[squareIndex]    = {
                    color    = style.board[square.side.cell].background,
                    selected = false
                }

                self.interface.resetAllowedMoves = fn {
                    for index, item of self.interface {
                        if type(index) == "number" {
                            local square                = self.squares[self.userSide][index]
                            item.color                  = style.board[square.side.cell].background
                            item.active                 = false
                            self.interface.allowedMoves = {}
                        }
                    }
                }

                self.interface.popup = {
                    position = nil,
                    squares  = {}
                }

                self.interface.promotion = fn (square, move) {
                    local pawn = false

                    for _, square in self.squares[self.userSide] {
                        if square.index[self.sideToMove] == move[1] {
                            pawn = square.model == CHESS_MODEL_PAWN
                        }
                    }

                    match string.sub(tostring(square.index[self.sideToMove]), 1, 1) {
                        '9' || '2' if pawn => {
                            imgui.OpenPopup(id .. ".promotion")
                            self.interface.popup.position = imgui.GetItemRectMin()
                            self.interface.popup.move     = move
                            return true
                        }
                    }

                    return false
                }
            }

            if squareIndex % 8 != 0 {
                imgui.SameLine()
            }
        }
    imgui.EndGroup()

    if !imgui.IsItemHovered() {
        if imgui.IsMouseReleased(0 /* LEFT_MOUSE_BUTTON */) && self.interface?.dragDropping {
            self::writeSquares()
            self.interface.resetAllowedMoves()
            self.interface.dragDropping = false
        }

        if imgui.IsMouseClicked(0 /* LEFT_MOUSE_BUTTON */) {
            self.interface.arrows = {}
        }
    }

    if self.interface.popup.position {
        imgui.SetNextWindowPos(self.interface.popup.position)
        imgui.SetNextWindowSize(imgui.ImVec2(50, 200))
    }

    if imgui.BeginPopupModal(id .. ".promotion", nil, imgui.WindowFlags.NoDecoration) {
        for index, model in ({
            CHESS_MODEL_QUEEN,
            CHESS_MODEL_ROOK,
            CHESS_MODEL_BISHOP,
            CHESS_MODEL_KNIGHT
        }) {
            if local square = self.interface.popup.squares[index] {
                local maxX, maxY    = 270, 90
                local pieceImageUv0 = imgui.ImVec2(((model - 2) * 45) / maxX, (45 * (self.sideToMove - 1)) / maxY)
                local pieceImageUv1 = imgui.ImVec2(45 / maxX, 45 / maxY) + pieceImageUv0

                imgui.PushStyleColor(imgui.Col.ChildBg, square.color)
                    imgui.BeginChild(id .. ".promotionModelN" .. index, imgui.ImVec2(50, 50), true)
                        imgui.SetCursorPos(imgui.GetCursorPos() + imgui.ImVec2(2, 2))
                        imgui.Image(cburnett, imgui.ImVec2(45, 45), pieceImageUv0, pieceImageUv1)
                    imgui.EndChild()
                imgui.PopStyleColor()

                if imgui.IsItemClicked() {
                    local move      = self.interface.popup.move
                    local promotion = model

                    if self.sideToMove == self.userSide && self.streamer?.state {
                        self.streamer::move(move, promotion)
                    }

                    self.interface.resetAllowedMoves()
                    self::move(move, promotion)

                    imgui.CloseCurrentPopup()
                }

                square.color = style.board[(imgui.IsItemHovered()) ? CHESS_SIDE_BLACK : CHESS_SIDE_WHITE].background
            } else {
                self.interface.popup.squares[index] = {
                    color = style.board[CHESS_SIDE_WHITE].background
                }
            }
        }

        if !imgui.IsWindowHovered() && imgui.IsMouseClicked(0 /* LEFT_MOUSE_BUTTON */) {
            imgui.CloseCurrentPopup()
        }

        imgui.EndPopup()
    }

    imgui.PopStyleVar(2)
}

return Board

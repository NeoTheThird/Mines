/*
* Main.qml
*
* Copyright(C) 2015 Robert Ancell
* Copyright(C) 2017 Jan Sprinz aka. NeoTheThird <neo@neothethird.de>
* This file is part of Mines: Clear the minefield. <neothethird.de/mines/>
*
* This game is a fork of Robert Ancell's original work, which was inspired by
* various earlier games of the Minesweeper genre, dating back to Jerimac
* Ratliff's Cube, which was developed some time in the 60s. If you enjoy this
* game and you ever happen to meet one of them, please consider treating them
* for a decent cup of coffee, they really deserve it!
*
* Mines is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License version 3 as
* published by the Free Software Foundation.
*
* Mines is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with Mines. If not, see <http://www.gnu.org/licenses/>.
*
*/

import QtQuick 2.4

ListModel {
    property int rows
    property int columns
    property bool started: false
    property int n_checked: 0
    property int n_mines
    property bool completed: false
    property var start_time
    property var end_time
    signal solved()

    function set_size(n_columns, n_rows, n) {
        columns = n_columns
        rows = n_rows
        started = false
        n_checked = 0
        n_mines = n
        completed = false
        clear()
        for(var row = 0; row < n_rows; row++) {
            for(var column = 0; column < n_columns; column++) {
                append({
                    "row": row,
                    "column": column,
                    "has_mine": false,
                    "flagged": false,
                    "checked": false,
                    "n_surrounding": 0
                })
            }
        }
    }

    function get_cell(column, row) {
        if(column < 0 || column >= columns || row < 0 || row > rows) { return undefined }
        return get(row * columns + column)
    }

    function flag(column, row) {
        var cell = get_cell(column, row)

        // Can only flag unknown cells
        if(cell.checked) { return false }

        // toggle flag status
        cell.flagged = !cell.flagged

        return true
    }

    function check(column, row) {
        var cell = get_cell(column, row)

        // Must unflag before checking
        if(cell.flagged) { return }

        // Lay out board on first touch ensuring a mine is not at the current location
        if(!started) { place_mines(column, row) }

        if(!cell.checked) {
            cell.checked = true
            n_checked++
        }

        function n_surrounding_flagged(column, row) {
            function flagged_count(column, row) {
                var c = get_cell(column, row)
                if(c == undefined) { return 0 }
                return c.flagged ? 1 : 0
            }
            return flagged_count(column - 1, row - 1) +
            flagged_count(column, row - 1) +
            flagged_count(column + 1, row - 1) +
            flagged_count(column - 1, row) +
            flagged_count(column + 1, row) +
            flagged_count(column - 1, row + 1) +
            flagged_count(column, row + 1) +
            flagged_count(column + 1, row + 1)
        }

        if(cell.has_mine) {
            completed = true
        } else {
            var n_flagged_mines = n_surrounding_flagged(cell.column, cell.row)
            if(cell.n_surrounding <= n_flagged_mines) {
                // Automatically check surrounding cells
                function auto_check(column, row) {
                    var cell = get_cell(column, row)
                    if(cell == undefined || cell.checked) { return }
                    check(column, row)
                }
                auto_check(cell.column - 1, cell.row - 1)
                auto_check(cell.column, cell.row - 1)
                auto_check(cell.column + 1, cell.row - 1)
                auto_check(cell.column - 1, cell.row)
                auto_check(cell.column + 1, cell.row)
                auto_check(cell.column - 1, cell.row + 1)
                auto_check(cell.column, cell.row + 1)
                auto_check(cell.column + 1, cell.row + 1)
            }
        }

        // You win when all non-mine cells are checked
        if((columns * rows) - n_checked == n_mines) {
            end_time = new Date()
            completed = true
            solved()
        }
    }

    function place_mines(skip_column, skip_row) {
        start_time = new Date()
        started = true
        function place_mine(skip_index) {
            while(true) {
                var index = Math.floor(Math.random() * (columns * rows))
                if(index == skip_index) { continue; }
                var cell = get(index)
                if(!cell.has_mine) {
                    cell.has_mine = true
                    return
                }
            }
        }

        for(var i = 0; i < n_mines; i++) {
            place_mine(skip_row * columns + skip_column)
        }

        function n_surrounding(column, row)
        {
            function mc(column, row) {
                var cell = get_cell(column, row)
                if(cell == undefined)
                return 0
                return cell.has_mine ? 1 : 0
            }
            return mc(column - 1, row - 1) +
            mc(column, row - 1) +
            mc(column + 1, row - 1) +
            mc(column - 1, row) +
            mc(column + 1, row) +
            mc(column - 1, row + 1) +
            mc(column, row + 1) +
            mc(column + 1, row + 1)
        }
        for(var column = 0; column < columns; column++) {
            for(var row = 0; row < rows; row++) {
                get_cell(column, row).n_surrounding = n_surrounding(column, row)
            }
        }
    }
}

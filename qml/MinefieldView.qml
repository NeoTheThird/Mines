/*
* Main.qml
*
* Copyright (C) 2015 Robert Ancell
* Copyright (C) 2017 Jan Sprinz aka. NeoTheThird <neo@neothethird.de>
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
import Ubuntu.Components 1.3
import QtFeedback 5.0

Grid {
    id: grid
    columns: model.columns
    rows: model.rows
    rotation: landscape ? 90 : 0
    Behavior on rotation {
        NumberAnimation {
            easing: UbuntuAnimation.StandardEasing
            duration: UbuntuAnimation.FastDuration
        }
    }
    property MinefieldModel model
    property bool landscape: parent.width > parent.height
    property int n_horizontal: landscape ? rows : columns
    property int n_vertical: landscape ? columns : rows
    property int cell_size: Math.floor (Math.min (parent.width / n_horizontal, parent.height / n_vertical))
    property bool use_haptic_feedback: true
    Repeater {
        id: repeater
        model: grid.model
        Rectangle {
            width: grid.cell_size
            height: grid.cell_size
            color: checked ? "#CCCCFF" : "#AAAAFF"
            border.width: 1
            border.color: checked ? color: "#4040FF"
            rotation: grid.landscape ? -90 : 0
            Image {
                id: image
                anchors.centerIn: parent
                sourceSize.width: parent.width * 0.6
                source: {
                    if (checked && has_mine)
                        return "../assets/exploded.svg"
                    else if (grid.model.completed && has_mine)
                        return "../assets/mine.svg"
                    else if (checked && n_surrounding > 0)
                        return "../assets/" + n_surrounding + "mines.svg"
                    else if (flagged)
                        return "../assets/flag.svg"
                    else
                        return ""
                }
            }
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                enabled: !grid.model.completed
                onClicked: {
                    if (mouse.button == Qt.LeftButton)
                        grid.model.check (column, row)
                    else
                        grid.model.flag (column, row)
                }
                onPressAndHold: {
                    if (grid.model.flag (column, row) && use_haptic_feedback)
                        place_flag_effect.start ()
                }
            }
        }
    }
    HapticsEffect {
        id: place_flag_effect
    }
}

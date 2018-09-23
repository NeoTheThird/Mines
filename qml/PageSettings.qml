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
import Ubuntu.Components.ListItems 1.3 as ListItem

Page {
    id: settings_page
    visible: false
    // TRANSLATORS: Title of page showing settings
    title: i18n.tr("Settings")

    Column {
        anchors.fill: parent
        ListItem.Standard {
            // TRANSLATORS: Label beside checkbox setting for controlling vibrations when placing flags
            text: i18n.tr("Vibrate when placing flags")
            control: CheckBox {
                id: haptic_check
                checked: true
                onCheckedChanged: save_state()
            }
        }
        ListItem.ItemSelector {
            id: size_selector
            // TRANSLATORS: Label above setting to choose the minefield size
            text: i18n.tr("Minefield size:")
            model: field_size_model
            delegate: OptionSelectorDelegate {
                text: {
                    switch(name) {
                    case "small":
                        // TRANSLATORS: Setting name for small minefield
                        return i18n.tr("Small")
                    case "large":
                        // TRANSLATORS: Setting name for large minefield
                        return i18n.tr("Large")
                    default:
                        return ""
                    }
                }
                // TRANSLATORS: Description format for minefield size, %width%, %height% and %nmines% is replaced with the field width, height and number of mines
                subText: i18n.tr("%width%×%height%, %nmines% mines").replace("%width%", grid_width).replace("%height%", grid_height).replace("%nmines%", n_mines)
            }
            onSelectedIndexChanged: {
                save_state()
                if(!minefield.started || minefield.completed)
                reset_field()
            }
        }
    }

    ListModel {
        id: field_size_model
        ListElement {
            name: "small"
            grid_width: 8
            grid_height: 8
            n_mines: 10
        }
        ListElement {
            name: "large"
            grid_width: 10
            grid_height: 16
            n_mines: 25
        }
    }
}

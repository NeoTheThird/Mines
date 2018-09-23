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
import Ubuntu.Components.Popups 1.3
import QtQuick.LocalStorage 2.0

MainView {
    applicationName: "mines.neothethird"
    automaticOrientation: true
    id: app

    property string version: "1.1"

    width: units.gu(40)
    height: units.gu(71)

    function get_state_database() {
        return LocalStorage.openDatabaseSync("state", "1", "Mines State", 0)
    }

    function get_history_database() {
        return LocalStorage.openDatabaseSync("history", "1", "Mines History", 0)
    }

    Component.onCompleted: {
        get_state_database().transaction(function(t) {
            try {
                var r = t.executeSql('SELECT use_haptic, grid_width, grid_height, n_mines FROM Settings')
                var item = r.rows.item(0)
                haptic_check.checked = item.use_haptic
                for(var i = 0; i < size_selector.model.count; i++) {
                    var s = size_selector.model.get(i)
                    if(s.grid_width == item.grid_width && s.grid_height == item.grid_height && s.n_mines == item.n_mines) {
                        size_selector.selectedIndex = i
                        break
                    }
                }
            }
            catch(e) {
            }
        } )
        reset_field()
    }

    function save_state() {
        get_state_database().transaction(function(t) {
            var grid_options = size_selector.model.get(size_selector.selectedIndex)
            // The lock field is to ensure the INSERT will always replace this row instead of adding another
            t.executeSql("CREATE TABLE IF NOT EXISTS Settings(lock INTEGER, use_haptic BOOLEAN, grid_width INTEGER, grid_height INTEGER, n_mines INTEGER, PRIMARY KEY (lock))")
            t.executeSql("INSERT OR REPLACE INTO Settings VALUES(0, ?, ?, ?, ?)", [haptic_check.checked, grid_options.grid_width, grid_options.grid_height, grid_options.n_mines])
        })
    }

    function reset_field()
    {
        var grid_options = size_selector.model.get(size_selector.selectedIndex)
        minefield.set_size(grid_options.grid_width, grid_options.grid_height, grid_options.n_mines)
    }

    Component {
        id: confirm_new_game_dialog
        Dialog {
            id: d
            // TRANSLATORS: Title for dialog shown when starting a new game while one in progress
            title: i18n.tr("Game in progress")
            // TRANSLATORS: Content for dialog shown when starting a new game while one in progress
            text: i18n.tr("Are you sure you want to restart this game?")
            Button {
                // TRANSLATORS: Button in new game dialog that cancels the current game and starts a new one
                text: i18n.tr("Restart game")
                color: UbuntuColors.red
                onClicked: {
                    reset_field()
                    PopupUtils.close(d)
                }
            }
            Button {
                // TRANSLATORS: Button in new game dialog that cancels new game request
                text: i18n.tr("Continue current game")
                onClicked: PopupUtils.close(d)
            }
        }
    }

    Component {
        id: confirm_clear_scores_dialog
        Dialog {
            id: d
            // TRANSLATORS: Title for dialog confirming if scores should be cleared
            title: i18n.tr("Clear scores")
            // TRANSLATORS: Content for dialog confirming if scores should be cleared
            text: i18n.tr("Existing scores will be deleted. This cannot be undone.")
            Button {
                // TRANSLATORS: Button in clear scores dialog that clears scores
                text: i18n.tr("Clear scores")
                color: UbuntuColors.red
                onClicked: {
                    table.clear_scores()
                    PopupUtils.close(d)
                }
            }
            Button {
                // TRANSLATORS: Button in clear scores dialog that cancels clear scores request
                text: i18n.tr("Keep existing scores")
                onClicked: PopupUtils.close(d)
            }
        }
    }

    PageStack {
        id: page_stack
        Component.onCompleted: push(main_page)

        Page {
            id: main_page
            visible: false
            header: PageHeader {
                id: main_header
                // TRANSLATORS: Title of application
                title: i18n.tr("Mines")
                trailingActionBar.actions: [
                    Action {
                        // TRANSLATORS: Action on main page that shows game instructions
                        text: i18n.tr("How to Play")
                        iconName: "help"
                        onTriggered: page_stack.push(how_to_play_page)
                    },
                    Action {
                        // TRANSLATORS: Action on main page that shows settings dialog
                        text: i18n.tr("Settings")
                        iconName: "settings"
                        onTriggered: page_stack.push(settings_page)
                    },
                    Action {
                        // TRANSLATORS: Action on main page that starts a new game
                        text: i18n.tr("New Game")
                        iconName: "reload"
                        onTriggered: {
                            if(minefield.started && !minefield.completed)
                            PopupUtils.open(confirm_new_game_dialog)
                            else
                            reset_field()
                        }
                    }
                ]
            }

            MinefieldModel {
                id: minefield
                onSolved: {
                    get_history_database().transaction(function(t) {
                        t.executeSql("CREATE TABLE IF NOT EXISTS History(grid_width INTEGER, grid_height INTEGER, n_mines INTEGER, date TEXT, duration INTEGER)")
                        var duration = minefield.end_time - minefield.start_time
                        t.executeSql("INSERT INTO History VALUES(?, ?, ?, ?, ?)", [minefield.columns, minefield.rows, minefield.n_mines, minefield.start_time.toISOString(), duration])
                    })
                }
            }

            Item {
                width: parent.width
                anchors {
                    top: main_header.bottom
                    bottom: parent.bottom
                }
                anchors.margins: units.gu(2)
                MinefieldView {
                    model: minefield
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    use_haptic_feedback: haptic_check.checked
                }
            }

            Rectangle {
                id: statusBar
                width: parent.width
                height: units.gu(20)
                anchors.bottom: parent.bottom
                Image {
                    id: clockIcon
                    anchors { left:left.parent; verticalCenter: parent.verticalCenter}
                    source: "../assets/time.svg"
                }

                Item {
                    Timer {
                        interval: 500; running: true; repeat: true
                        //onTriggered: time.text = Date()
                        onTriggered: time.text = minefield.update_time_elapsed()
                    }
                }
                Text {
                    id: time
                    anchors { left:clockIcon.right; verticalCenter: parent.verticalCenter}
                }
            }
        }

        Page {
            id: how_to_play_page
            visible: false
            header : PageHeader {
                id: how_to_play_header
                // TRANSLATORS: Title of page with game instructions
                title: i18n.tr("How to Play")
                flickable: how_to_play_flick
            }

            Flickable {
                id: how_to_play_flick
                width: parent.width
                anchors {
                    top: how_to_play_header.bottom
                    bottom: parent.bottom
                    margins: units.gu(3)
                    topMargin: 0
                    bottomMargin: 0
                }
                clip: true
                contentWidth: aboutColumn.width
                contentHeight: aboutColumn.height

                Column {
                    id: aboutColumn
                    width: parent.parent.width
                    spacing: units.gu(3)

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: i18n.tr("Mines")
                        fontSize: "x-large"
                    }

                    UbuntuShape {
                        width: units.gu(12); height: units.gu(12)
                        anchors.horizontalCenter: parent.horizontalCenter
                        radius: "medium"
                        image: Image {
                            source: Qt.resolvedUrl("../assets/mines.png")
                        }
                    }

                    Label {
                        width: parent.width
                        linkColor: UbuntuColors.orange
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: i18n.tr("Version: ") + app.version
                    }

                    Label {
                        width: parent.width
                        linkColor: UbuntuColors.orange
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        // TRANSLATORS: Short description
                        text: i18n.tr("Mines is a puzzle game where the goal is to find the mines in a minefield.")
                        onLinkActivated: Qt.openUrlExternally(link)
                    }

                    Label {
                        width: parent.width
                        linkColor: UbuntuColors.orange
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        // TRANSLATORS: Game instructions
                        text: i18n.tr("The minefield is divided into a grid of squares. Touch a square to check if there is a mine there. If no mine is present the square will show the number of mines surrounding it. Use logic to determine a square that cannot contain a mine to check next. If you hit a mine it explodes and the game is over. You can flag where a mine is by touching and holding that square. Have fun!")
                        onLinkActivated: Qt.openUrlExternally(link)
                    }

                    Label {
                        width: parent.width
                        linkColor: UbuntuColors.orange
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        // TRANSLATORS: GPL notice
                        text: i18n.tr("This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the <a href='https://www.gnu.org/licenses/gpl-3.0.en.html'>GNU General Public License</a> for more details.")
                        onLinkActivated: Qt.openUrlExternally(link)
                    }

                    Label {
                        width: parent.width
                        linkColor: UbuntuColors.orange
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: "<a href='https://github.com/NeoTheThird/Mines'>" + i18n.tr("SOURCE") + "</a> | <a href='https://github.com/NeoTheThird/Mines/issues'>" + i18n.tr("ISSUES") + "</a> | <a href='https://paypal.me/neothethird'>" + i18n.tr("DONATE") + "</a>"
                        onLinkActivated: Qt.openUrlExternally(link)
                    }

                    Label {
                        width: parent.width
                        linkColor: UbuntuColors.orange
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        style: Font.Bold
                        text: i18n.tr("Copyright (c) 2015 Robert Ancell")
                    }

                    Label {
                        width: parent.width
                        linkColor: UbuntuColors.orange
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        style: Font.Bold
                        text: i18n.tr("Copyright (c) 2017 Jan Sprinz <neo@neothethird.de>")
                    }
                }
            }
        }

        Page {
            id: scores_page
            visible: false
            header: PageHeader {
                id: scores_header
                // TRANSLATORS: Title of page showing high scores
                title: i18n.tr("High Scores")
                Action {
                    // TRANSLATORS: Action in high scores page that clears scores
                    text: i18n.tr("Clear scores")
                    iconName: "reset"
                    onTriggered: PopupUtils.open(confirm_clear_scores_dialog)
                }
            }
        }

        Page {
            id: settings_page
            visible: false
            header: PageHeader {
                id: settings_header
                // TRANSLATORS: Title of page showing settings
                title: i18n.tr("Settings")
            }


            Column {
                width: parent.width
                anchors {
                    top: settings_header.bottom
                    bottom: parent.bottom
                }
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
    }
}

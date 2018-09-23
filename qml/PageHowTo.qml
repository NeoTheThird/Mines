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

Page {
    id: how_to_play_page
    visible: false
    header : PageHeader {
        id: pageHeader
        // TRANSLATORS: Title of page with game instructions
        title: i18n.tr("How to Play")
        flickable: scrollableContent
    }
    Flickable {
        id: scrollableContent
        width: parent.width
        anchors {
            top: pageHeader.bottom
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

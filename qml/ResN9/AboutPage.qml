/****************************************************************************
**
** The MIT License (MIT)
**
** Copyright (c) 2013 Fredrik Henricsson
**
** Permission is hereby granted, free of charge, to any person obtaining a copy
** of this software and associated documentation files (the "Software"), to deal
** in the Software without restriction, including without limitation the rights
** to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
** copies of the Software, and to permit persons to whom the Software is
** furnished to do so, subject to the following conditions:
**
** The above copyright notice and this permission notice shall be included in
** all copies or substantial portions of the Software.
**
** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
** IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
** FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
** AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
** LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
** OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
** THE SOFTWARE.
**
****************************************************************************/

import QtQuick 1.1
import com.nokia.meego 1.0
import QtMobility.sensors 1.2
import Qt.labs.particles 1.0

Page {
    id: aboutPage
    orientationLock: PageOrientation.LockPortrait

    Rectangle {
        id: pageBackground
        anchors.fill: parent
        color: "black"

        AboutParticles {
            source: '../images/stadsbuss.gif'
        }

        AboutParticles {
            source: '../images/regionbuss.gif'
        }

        AboutParticles {
            source: '../images/oresundstag.gif'
        }

        AboutParticles {
            source: '../images/pagatagen.gif';
        }
    }

    Text {
        id: aboutText
        width: 200
        font.pointSize: 16
        anchors.centerIn: parent
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        text: "Resa i Skåne version 0.9\n\nUtvecklad av Fredrik Henricsson\n\nTågikonen ursprungligen från The Noun Project\nmed en CC BY 3.0-licens\n\nTrafikdata från Skånetrafikens Open API"
        color: "white"
    }

    Item {
        id: aboutTwitter
        height: 50
        anchors.top: aboutText.bottom
        anchors.left: aboutText.left
        anchors.right: aboutText.right
        anchors.topMargin: 5

        MouseArea {
            id: aboutTwitterMouseArea
            anchors.fill: parent
            onClicked: {
                Qt.openUrlExternally("http://www.twitter.com/fejd")
            }
        }

        Image {
            id: aboutTwitterImage
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: 30
            height: parent.height
            width: height
            source: "../images/twitter_newbird_blue.png"
        }

        Text {
            id: aboutTwitterText
            anchors.top: parent.top
            height: parent.height
            anchors.right: parent.right
            anchors.rightMargin: 30
            verticalAlignment: Text.AlignVCenter
            font.pointSize: aboutText.font.pointSize
            text: "@fejd"
            color: aboutText.color
        }

    }

    tools: ToolBarLayout {
        id: simpleToolBar

        visible: true
        // for back button
        ToolIcon { iconId: "toolbar-back"; onClicked: pageStack.pop(); }
    }
}

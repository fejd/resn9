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

// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import QtMobility.location 1.2

// TODO: Show the route on a map
Page {
    tools: ToolBarLayout {
        id: simpleToolBar

        visible: true
        // for back button
        ToolIcon { iconId: "toolbar-back"; onClicked: pageStack.pop(); }
    }
    orientationLock: PageOrientation.LockPortrait

    PositionSource {
        id: positionSource
        updateInterval: 1000
        active: true
    }

    Map {
        id: map
        plugin : Plugin {name : "nokia"}
        anchors.fill: parent
        size.width: parent.width
        size.height: parent.height
        zoomLevel: 10

        center: positionSource.position.coordinate

        MapCircle {
            id: myPositionCircle
            center: positionSource.position.coordinate
            radius: 100
            color: "skyblue"
        }
    }
}

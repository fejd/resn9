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

Rectangle {
    id: searchField
    height: 75
    color: "black"

    property alias labelText: label.text
    property alias textInputRef: textInput

    signal selectedSearchFieldText(string searchFieldText)

    Label {
        id: label

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        anchors.margins: 5
        color: "white"

        width: 50
    }

    TextField {
        id: textInput
        anchors.left: label.right
        anchors.right: parent.right

        anchors.verticalCenter: parent.verticalCenter

        anchors.margins: 5
    }

    MouseArea {
        anchors.fill: searchField

        onClicked: {
            searchSheet.clearSheet()
            searchSheet.open()
            selectedSearchFieldText(labelText)
        }
    }
}

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
import com.nokia.extras 1.0
import "js/dbaccess.js" as DbAccess

Page {
    id: mainPage
    tools: commonTools
    orientationLock: PageOrientation.LockPortrait

    property string fromName
    property string fromId
    property string toName
    property string toId
    property string selectedSearchFieldText
    property string travelDateChoice: "Now"

    signal travelDateUpdated

    onTravelDateUpdated: {
        updateTravelTimeLabel();
    }

    function updateTravelTimeLabel() {
        if (travelDateChoice === "Calendar") {
            var todaysDate = new Date();
            var travelDate = getTravelDate();
            var modifiedTravelDate = new Date(travelDate.getTime() + 60*60000);
            travelDate = modifiedTravelDate;
            var travelString = "";
            if(todaysDate.getDate() === travelDate.getDate() &&
                    todaysDate.getFullYear() === travelDate.getFullYear() &&
                    todaysDate.getMonth() === travelDate.getMonth()) {
                travelString += "Idag";
            } else {
                travelString += dateFromDateTime(travelDate.toISOString());
            }
            travelString += ", " + timeFromDateTime(travelDate.toISOString());

            travelTimeLabel.text = travelString;
        }
        else if (travelDateChoice == "Now") {
            travelTimeLabel.text = "Nu"
        }
    }

    states: [
    State {
            name: "dimmed"
            PropertyChanges {
                target: mainPage
                opacity: 0.0
            }
        }
    ]

    transitions: Transition {
        NumberAnimation { target: mainPage; properties: "opacity"; duration: 250 }
    }

    function showSelectionDialog() {
        selectionDialog.open();
    }

    function showTimePickerDialog() {
        timePickerDialog.open();
    }


    function timePickerAccepted() {
        var date = new Date(datePickerDialog.year,
                            datePickerDialog.month - 1,
                            datePickerDialog.day,
                            timePickerDialog.hour,
                            timePickerDialog.minute,
                            timePickerDialog.second);
        setTravelDate(date);
        travelDateUpdated();
    }

    function datePickerAccepted() {
        var date = new Date();
        timePickerDialog.hour = date.getHours();
        timePickerDialog.minute = date.getMinutes();
        timePickerDialog.second = date.getSeconds();
        showTimePickerDialog();
    }

    function showDatePickerDialog() {
        var date = new Date();
        datePickerDialog.year = date.getFullYear();
        datePickerDialog.month = date.getMonth() + 1;
        datePickerDialog.day = date.getDate();
        datePickerDialog.open();
    }


    Rectangle {
        id: pageBackground
        anchors.fill: parent
        color: "black"
    }

    Rectangle {
        id: topBackground
        color: "red"
        height: 70
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        Text {
            id: topLabel
            text: appName()
            anchors.fill: parent
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            font.pointSize: 24
            styleColor: "lightgray"
            color: "white"
            anchors.leftMargin: 16
        }
    }

    SearchField {
        id: fromField
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: topBackground.bottom

        labelText: "Från"
    }

    SearchField {
        id: toField
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: fromField.bottom

        labelText: "Till"
    }

    Rectangle {
        id: travelTimeRect
        anchors.top: toField.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 25
        color: "black"

        Label {
            id: travelTimeLabelDescription
            anchors.left: parent.left
            anchors.margins: 5
            anchors.verticalCenter: parent.verticalCenter

            width: 50
            text: "När: "
            color: "white"
        }

        Label {
            id: travelTimeLabel
            anchors.left: travelTimeLabelDescription.right
            anchors.margins: 5
            anchors.verticalCenter: parent.verticalCenter

            text: "Nu"
            color: "white"
        }
    }

    Button {
        id: whenButton
        anchors {
            top: travelTimeRect.bottom
            topMargin: 25
            left: parent.left
            leftMargin: 25
            rightMargin: 5
        }

        height: 50
        width: 150

        onClicked: {
            showSelectionDialog()
        }

        text: "Välj tid"
    }

    Button {
        id: searchButton
        anchors {
            top: travelTimeRect.bottom
            topMargin: 25
            right: parent.right
            leftMargin: 5
            rightMargin: 25
        }
        height: 50
        width: 150
        text: "Sök"
        onClicked: {
            if(travelDateChoice === "Now") {
                setTravelDateToNow();
            }

            if(toField.textInputRef.text.length > 0 && fromField.textInputRef.text.length > 0) {
                appWindow.pageStack.push(travelResultsPage);
                travelResultsPage.doTravelQuery();
            }
        }
    }

    // TODO: "Extend" Date and Time pickers to enable localization
    // and make touches outside of the dialog not close it
    DatePickerDialog {
        id: datePickerDialog
        titleText: "Välj datum"
        acceptButtonText: "Välj"
        rejectButtonText: "Avbryt"
        onAccepted: {
            datePickerAccepted()
        }
    }

    TimePickerDialog {
        id: timePickerDialog
        titleText: "Välj tid"
        acceptButtonText: "Välj"
        rejectButtonText: "Avbryt"
        onAccepted: {
            timePickerAccepted()
        }
    }

    SelectionDialog {
        id: selectionDialog
        titleText: "När vill du åka?"
        model: ["Nu", "Välj i kalender"]

        onSelectedIndexChanged: {
            if (selectedIndex === 0) {
                travelDateChoice = "Now"
                setTravelDateToNow()
                travelDateUpdated();
                // Will set the travel date when the user clicks on the search
                // button as well
            } else if (selectedIndex === 1) {
                travelDateChoice = "Calendar"
                showDatePickerDialog()
            }

            // Reset the index to the default
            selectedIndex = -1
        }
    }

    SearchSheet {
        id: searchSheet
        backgroundItem: mainPage
    }

    Component.onCompleted: {
        searchSheet.selectedStation.connect(handleSelectedStation)
        fromField.selectedSearchFieldText.connect(handleSelectedSearchField)
        toField.selectedSearchFieldText.connect(handleSelectedSearchField)
        DbAccess.openDB()
    }

    function handleSelectedSearchField(labelText) {
        selectedSearchFieldText = labelText
    }

    function handleSelectedStation(nameValue, idValue) {
        if(selectedSearchFieldText === fromField.labelText) {
            fromField.textInputRef.text = nameValue
            fromName = nameValue
            fromId = idValue
        }
        else if(selectedSearchFieldText === toField.labelText) {
            toField.textInputRef.text = nameValue
            toName = nameValue
            toId = idValue
        }
    }
}

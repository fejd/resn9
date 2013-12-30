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
import "js/travelresultshelper.js" as TravelResultsHelper

PageStackWindow {
    id: appWindow

    initialPage: mainPage

    function appName() {
        return "Resa i Skåne"
    }

    function getTravelDate() {
        return TravelResultsHelper.getTravelDate();
    }

    function imageUrlForLineType(lineType) {
        return TravelResultsHelper.imageUrlForLineType(lineType);
    }

    function setTravelDate(date) {
        TravelResultsHelper.setTravelDate(date);
    }

    function setTravelDateToNow() {
        TravelResultsHelper.setTravelDateToNow();
    }

    function setResponseXml(responseXml) {
        TravelResultsHelper.setResponseXml(responseXml);
    }

    function getResponseXml() {
        return TravelResultsHelper.getResponseXml();
    }

    function addRouteLinkData(journeyKey, lineTypeId, depTime, arrTime, fromName, toName, depTimeDeviation, depDeviationAffect, arrTimeDeviation, arrDeviationAffect, routeLinkKey, lineName, lineTypeName, towards, trainNo) {
        TravelResultsHelper.addRouteLinkData(journeyKey, lineTypeId, depTime, arrTime, fromName, toName, depTimeDeviation, depDeviationAffect, arrTimeDeviation, arrDeviationAffect, routeLinkKey, lineName, lineTypeName, towards, trainNo);
    }

    function clearRouteLinkData() {
        TravelResultsHelper.clearRouteLinkData();
    }

    function getRouteLinkDataForJourneyKey(journeyKey) {
        return TravelResultsHelper.getRouteLinkDataForJourneyKey(journeyKey);
    }

    function getInfoImageForJourneyKey(journeyKey) {
        return TravelResultsHelper.getInfoImageForJourneyKey(journeyKey);
    }

    function addRouteLinkDataToListItem(item) {
        TravelResultsHelper.addRouteLinkDataToListItem(item);
    }

    function addLinkTypesToGridListModel(journeyKey, listModel) {
        TravelResultsHelper.addLinkTypesToGridListModel(journeyKey, listModel);
    }

    function addRouteLinkDataToListModel(journeyKey, listModel) {
        TravelResultsHelper.addRouteLinkDataToListModel(journeyKey, listModel);
    }

    function timeFromDateTime(dateTime) {
        return TravelResultsHelper.timeFromDateTime(dateTime);
    }

    function dateFromDateTime(dateTime) {
        return TravelResultsHelper.dateFromDateTime(dateTime);
    }

    function hourFromTime(time) {
        return TravelResultsHelper.hourFromTime(time);
    }

    function travelDateTimeToJsDate(travelDate) {
        return TravelResultsHelper.travelDateTimeToJsDate(travelDate);
    }

    function travelTimeFromDepAndArrDateTime(depDateTime, arrDateTime) {
        return TravelResultsHelper.travelTimeFromDepAndArrDateTime(depDateTime, arrDateTime);
    }

    function addMinutesToDate(date, minutes) {
        return TravelResultsHelper.addMinutesToDate(date, minutes);
    }

    function isLineTypeIdTrain(lineTypeId) {
        return TravelResultsHelper.isLineTypeIdTrain(lineTypeId);
    }

    Component.onCompleted: {
        theme.inverted = true
    }

    MainPage {
        id: mainPage
    }

    TravelResultsPage {
        id: travelResultsPage
    }

    TravelDetailsPage {
        id: travelDetailsPage
    }

    AboutPage {
        id: aboutPage
    }

    /*MapPage {
        id: mapPage
    }*/

    ToolBarLayout {
        id: commonTools
        visible: true
        ToolIcon {
            iconSource: "../images/icon-m-toolbar-about.png"
            anchors.right: (parent === undefined) ? undefined : parent.right
            onClicked: {
                appWindow.pageStack.push(aboutPage)
            }
        }
    }

    Dialog {
        id: errorDialog

        property alias dialogText: contentDialogItemText.text

        title: Rectangle {
            id: titleField
            height: 2
            width: parent.width
            color: "red"
        }

        content: Item {
            id: contentDialogItem
            height: 50
            width: parent.width

            Text {
              id: contentDialogItemText
              font.pixelSize: 22
              anchors.centerIn: parent
              color: "white"
              text: ""
            }
        }

        Timer {
            id: autoCloseTimer
            interval: 3000; running: false; repeat: false

            onTriggered: {
                pageStack.pop()
                errorDialog.accept();
            }
        }

        function showError(errorString) {
            dialogText = errorString;
            open();
            autoCloseTimer.start();
        }
    }
}

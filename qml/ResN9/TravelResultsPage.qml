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
import "js/qmlprivate.js" as QmlPrivate

//http://www.labs.skanetrafiken.se/v2.2/resultspage.asp?cmdaction=next&selPointFr=malm%F6%20C|80000|0&selPointTo=landskrona|82000|0&LastStart=2012-01-13%2016:38
Page {
    id: travelResultsPage
    orientationLock: PageOrientation.LockPortrait

    property string xmlVariable
    property string pullDirection
    property bool pulled

    signal gotSearchResponse()
    signal loadingResultsAtTop()
    signal preLoadAtTop()
    signal loadingResultsAtBottom()
    signal preLoadAtBottom()

    tools: ToolBarLayout {
        id: simpleToolBar

        visible: true
        // for back button
        ToolIcon { iconId: "toolbar-back"; onClicked: pageStack.pop(); }
    }

    function showRequestInfo(text) {
        console.debug(text)
    }

    function doTravelQuery() {
        var doc = new XMLHttpRequest();

        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.HEADERS_RECEIVED) {
                //console.debug("HEADERS_RECEIVED")
                /*showRequestInfo("Headers -->");
                showRequestInfo(doc.getAllResponseHeaders ());
                showRequestInfo("Last modified -->");
                showRequestInfo(doc.getResponseHeader ("Last-Modified"));*/

            } else if (doc.readyState === XMLHttpRequest.UNSENT) {
                //console.debug("UNSENT")
            } else if (doc.readyState === XMLHttpRequest.OPENED) {
                //console.debug("OPENED")
            } else if (doc.readyState === XMLHttpRequest.LOADING) {
                //console.debug("LOADING")
            } else if (doc.readyState === XMLHttpRequest.DONE) {
                //console.debug("DONE")
                if(doc.responseXML !== null) {
                    var a = doc.responseXML.documentElement;
                    QmlPrivate.priv(travelResultsPage).responseXml = a;
                    //showRequestInfo(doc.responseText)
                    xmlVariable = doc.responseText;
                    //console.debug(xmlVariable)
                    travelListModel.reload();
                    /*for (var ii = 0; ii < a.childNodes.length; ++ii) {
                        showRequestInfo(a.childNodes[ii].nodeName);
                    }*/
                    /*showRequestInfo("Headers -->");
                    showRequestInfo(doc.getAllResponseHeaders ());
                    showRequestInfo("Last modified -->");
                    showRequestInfo(doc.getResponseHeader ("Last-Modified"));*/
                }
                else {
                    errorDialog.showError("Ingen resdata i svaret från Skånetrafiken");
                }
            }
        }

        var todaysDate = getTravelDate();

        /* Let's have a 10 min margin for preceding departures */
        todaysDate.setTime(todaysDate.getTime() - 10*60*1000)

        var year = todaysDate.getFullYear();
        var month = todaysDate.getMonth() + 1;
        var day = todaysDate.getDate();
        var hour = todaysDate.getHours();
        var minute = todaysDate.getMinutes();
        var noOfJourneys = 10;

        // Clear out all old search results
        completeTravelListModel.clear();
        xmlVariable = "<xml></<xml>";
        clearRouteLinkData();

        var travelUrl = "http://www.labs.skanetrafiken.se/v2.2/resultspage.asp?cmdaction=next&NoOf=" + noOfJourneys + "&selPointFr=" + mainPage.fromName + "|" + mainPage.fromId + "|0" + "&selPointTo=" + mainPage.toName + "|" + mainPage.toId + "|0&LastStart=" + year + "-" + month + "-" + day + "%20" + hour + ":" + minute;
        doc.open("GET", travelUrl);
        //console.debug("Sending request, date is: " + todaysDate)
        doc.send();

        if (!travelBusyIndicator.running) {
            travelBusyIndicator.visible = true
            travelBusyIndicator.running = true
        }
    }

    function doRefreshQuery(pullDir) {
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.HEADERS_RECEIVED) {
                /*showRequestInfo("Headers -->");
                showRequestInfo(doc.getAllResponseHeaders ());
                showRequestInfo("Last modified -->");
                showRequestInfo(doc.getResponseHeader ("Last-Modified"));*/

            } else if (doc.readyState === XMLHttpRequest.DONE) {
                if(doc.responseXML !== null) {
                    var a = doc.responseXML.documentElement;
                    QmlPrivate.priv(travelResultsPage).responseXml = a
                    //showRequestInfo(doc.responseText)
                    xmlVariable = doc.responseText
                    travelListModel.reload()
                    /*for (var ii = 0; ii < a.childNodes.length; ++ii) {
                        showRequestInfo(a.childNodes[ii].nodeName);
                    }*/
                    //showRequestInfo("Headers -->");
                    //showRequestInfo(doc.getAllResponseHeaders ());
                    //showRequestInfo("Last modified -->");
                    //showRequestInfo(doc.getResponseHeader ("Last-Modified"));
                }
                else {
                    errorDialog.showError("Ingen resdata i svaret från Skånetrafiken");
                }
            }
        }

        var todaysDate = getTravelDate();
        var msPerHour = 60 * 60000;
        var startFrom = "";
        var cmdAction = "";

        if (pullDir === "UP") {
            var firstListItem = completeTravelListModel.get(0)
            todaysDate = new Date(travelDateTimeToJsDate(firstListItem.DepDateTime))
            startFrom = "FirstStart";
            cmdAction = "previous";
        } else if (pullDir === "DOWN") {
            var lastListItem = completeTravelListModel.get(completeTravelListModel.count - 1)
            todaysDate = new Date(travelDateTimeToJsDate(lastListItem.DepDateTime))
            startFrom = "LastStart";
            cmdAction = "next";
        }

        var year = todaysDate.getFullYear();
        var month = todaysDate.getMonth() + 1;
        var day = todaysDate.getDate();
        var hour = todaysDate.getHours();
        var minute = todaysDate.getMinutes();


        var travelUrl = "http://www.labs.skanetrafiken.se/v2.2/resultspage.asp?cmdaction=" + cmdAction +"&selPointFr=" + mainPage.fromName + "|" + mainPage.fromId + "|0" + "&selPointTo=" + mainPage.toName + "|" + mainPage.toId + "|0&" + startFrom + "=" + year + "-" + month + "-" + day + "%20" + hour + ":" + minute;
        doc.open("GET", travelUrl);
        doc.send();
        if (!travelBusyIndicator.running) {
            travelBusyIndicator.visible = true
            travelBusyIndicator.running = true
        }
    }

    function extractRouteLinkData() {
        // getElementsByTagName is not implemented in QML, so we have to parse
        // the XML for the elements ourselves
        var responseXml = QmlPrivate.priv(travelResultsPage).responseXml
        var journeys = getChildrenOfTagName(responseXml, "Journeys");
        if (journeys) {
            for (var i = 0; i < journeys.childNodes.length; i++) {
                // Get the journey key
                var journey = journeys.childNodes[i];
                var journeyKey = getChildrenOfTagName(journey, 'JourneyKey');
                var journeyKeyValue = journeyKey.firstChild.nodeValue;
                //console.debug(journeyKey.firstChild.nodeValue);
                for (var j = 0; j < travelListModel.count; j++) {
                    var item = travelListModel.get(j);
                    if (item.JourneyKey === journeyKeyValue) {
                        // Get the route link information and add it to the
                        // list item
                        var routeLinks = getChildrenOfTagName(journey, 'RouteLinks');
                        for (var k = 0; k < routeLinks.childNodes.length; k++) {
                            var routeLink = routeLinks.childNodes[k];
                            var line = getChildrenOfTagName(routeLink, 'Line');
                            var lineName = getChildrenOfTagName(line, 'Name');
                            var lineTypeName = getChildrenOfTagName(line, 'LineTypeName');
                            var lineTypeId = getChildrenOfTagName(line, 'LineTypeId');
                            var depTime = getChildrenOfTagName(routeLink, 'DepDateTime');
                            var arrTime = getChildrenOfTagName(routeLink, 'ArrDateTime');
                            var routeLinkKey = getChildrenOfTagName(routeLink, "RouteLinkKey");
                            var fromNode = getChildrenOfTagName(routeLink, 'From');
                            var fromName = getChildrenOfTagName(fromNode, 'Name');
                            var toNode = getChildrenOfTagName(routeLink, 'To');
                            var toName = getChildrenOfTagName(toNode, 'Name');
                            var realTimeNode = getChildrenOfTagName(routeLink, 'RealTime');
                            var realTimeInfoNode = getChildrenOfTagName(realTimeNode, 'RealTimeInfo');
                            var trainNo = '';
                            var depTimeDeviation = 0;
                            var depDeviationAffect = 'NONE';
                            var arrTimeDeviation = 0;
                            var arrDeviationAffect = 'NONE';
                            var towards = '';
                            if(typeof realTimeInfoNode !== "undefined") {
                                try {
                                    depTimeDeviation = getChildrenOfTagName(realTimeInfoNode, 'DepTimeDeviation').firstChild.nodeValue;
                                    depDeviationAffect = getChildrenOfTagName(realTimeInfoNode, 'DepDeviationAffect').firstChild.nodeValue;
                                } catch (e) {
                                    // Do nothing, the node is not there
                                }

                                try {
                                    arrTimeDeviation = getChildrenOfTagName(realTimeInfoNode, 'ArrTimeDeviation').firstChild.nodeValue;
                                    arrDeviationAffect = getChildrenOfTagName(realTimeInfoNode, 'ArrDeviationAffect').firstChild.nodeValue;
                                } catch (e) {
                                    // Do nothing, the node is not there
                                }
                            }

                            try {
                                towards = getChildrenOfTagName(line, 'Towards').firstChild.nodeValue;
                            } catch (e) {
                                // Do nothing, the node is not there
                            }

                            try {
                                 trainNo = getChildrenOfTagName(line, "TrainNo").firstChild.nodeValue;
                            } catch (e) {
                                // Do nothing, the node is not there
                            }

                            //try {
                                //console.debug("routeLinkKey is: " + routeLinkKey.firstChild.nodeValue);
                                //console.debug("depTime is: " + depTime.firstChild.nodeValue);
                                //console.debug("arrTime is: " + arrTime.firstChild.nodeValue);
                                //console.debug("lineTypeId is: " + lineTypeId.firstChild.nodeValue);
                                //console.debug("fromName is: " + fromName.firstChild.nodeValue);
                                //console.debug("toName is: " + toName.firstChild.nodeValue);
                                //console.debug("depTimeDeviation is: " + depTimeDeviation);
                                //console.debug("depDeviationAffect is: " + depDeviationAffect);
                                //console.debug("arrTimeDeviation is: " + arrTimeDeviation);
                                //console.debug("arrDeviationAffect is: " + arrDeviationAffect);
                                //console.debug("lineName is: " + lineName.firstChild.nodeValue);
                                //console.debug("lineTypeName is: " + lineTypeName.firstChild.nodeValue);
                                //console.debug("towards is: " + towards);
                                //console.debug("trainNo is: " + trainNo);
                            /*} catch (e) {
                                console.debug(e)
                            }*/

                            // Since the XMLListModel is read-only, store
                            // the route link data in javascript objects
                            // and fetch them later
                            addRouteLinkData(journeyKeyValue, lineTypeId.firstChild.nodeValue,
                                                              depTime.firstChild.nodeValue,
                                                              arrTime.firstChild.nodeValue,
                                                              fromName.firstChild.nodeValue,
                                                              toName.firstChild.nodeValue,
                                                              depTimeDeviation,
                                                              depDeviationAffect,
                                                              arrTimeDeviation,
                                                              arrDeviationAffect,
                                                              routeLinkKey,
                                                              lineName.firstChild.nodeValue,
                                                              lineTypeName.firstChild.nodeValue,
                                                              towards,
                                                              trainNo);

                        }
                    }
                }
            }
        }
    }

    function getChildrenOfTagName(rootElement, tagName) {
        var childNodes = rootElement.childNodes;
        ////console.log("Rootelement: " + rootElement.nodeName)
        for(var i = 0; i < childNodes.length; i++) {
            ////console.log("Nodename: " + childNodes[i].nodeName);
            if(childNodes[i].nodeName === tagName) {
                return childNodes[i];
            } else {
                var elementsFromChild = getChildrenOfTagName(childNodes[i], tagName);
                if (elementsFromChild) {
                    return elementsFromChild;
                }
            }
        }
    }

    Rectangle {
        id: travelResultsRect

        anchors.fill: parent

        Timer {
            id: time
            interval: 2000; running: false; repeat: false
            onTriggered: {
                doRefreshQuery(pullDirection)
            }
        }

        Rectangle {
            id: travelHeaderRectangle
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.left: parent.left
            height: 100
            color: "red"

            Text {
                id: travelHeaderText
                text: "Vald resa"
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 16
                color: "white"
                styleColor: "lightgray"
                font.pointSize: 20
                height: 50
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
            }

            Rectangle {
                id: travelDestinationsRectangle
                anchors.top: travelHeaderText.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 50
                color: "white"

                Text {
                    id: travelDestinationsText
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 50
                    anchors.leftMargin: 16
                    font.pixelSize: 20
                    text: mainPage.fromName + " - " + mainPage.toName
                    color: "black"
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
            }

            BusyIndicator {
                id: travelBusyIndicator
                platformStyle: BusyIndicatorStyle {
                    size: "small"
                    inverted: true
                }
                running: false
                visible: false

                anchors.verticalCenter: travelHeaderText.verticalCenter;
                anchors.right: parent.right
                anchors.rightMargin: 16
            }
        }

        Rectangle {
            id: travelResultsDescription
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: travelHeaderRectangle.bottom
            height: 50
            color: "red"

            Text {
                id: avgText
                text: "Avg"
                width: parent.width / 6
                font.pixelSize: 20
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.top: parent.top
                color: "white"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
            Text {
                id: ankText
                text: "Ank"
                width: parent.width / 6
                font.pixelSize: 20
                anchors.left: avgText.right
                anchors.bottom: parent.bottom
                anchors.top: parent.top
                color: "white"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
            Text {
                id: typText
                text: "Typ"
                width: parent.width / 6
                font.pixelSize: 20
                anchors.left: ankText.right
                anchors.bottom: parent.bottom
                anchors.top: parent.top
                color: "white"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
            Text {
                id: changesText
                text: "Byten"
                width: parent.width / 6
                font.pixelSize: 20
                anchors.left: typText.right
                anchors.bottom: parent.bottom
                anchors.top: parent.top
                color: "white"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
            Text {
                id: travelTimeText
                text: "Restid"
                width: parent.width / 6
                font.pixelSize: 20
                anchors.left: changesText.right
                anchors.bottom: parent.bottom
                anchors.top: parent.top
                color: "white"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
            Text {
                id: infoText
                text: "Info"
                width: parent.width / 6
                font.pixelSize: 20
                anchors.left: travelTimeText.right
                anchors.bottom: parent.bottom
                anchors.top: parent.top
                color: "white"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Rectangle {
            id: travelResultsDescriptionShadow
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: travelResultsDescription.bottom
            height: 5
            gradient: Gradient {
                GradientStop { position: 0.0; color: "grey" }
                GradientStop { position: 1.0; color: "white" }
            }
        }

        Component {
            id: listHeader

            Item {
                width: travelResultsListView.width
                height:  0
                id: listHeaderImageItem
                visible: completeTravelListModel.count > 0

                Connections {
                    target: travelResultsPage
                    onGotSearchResponse: {
                        listHeaderImageItem.state = ""
                        travelBusyIndicator.visible = false
                        travelBusyIndicator.running = false
                    }

                    onPreLoadAtTop: {
                        listHeaderImageItem.state = "preload"
                    }

                    onLoadingResultsAtTop: {
                        listHeaderImageItem.state = "loading"
                    }
                }

                states: [
                    State {
                        name: "preload"
                        PropertyChanges {
                            target: listHeaderImageItem
                            height: headerText.height + listHeaderImage.height
                        }
                        PropertyChanges {
                            target: listHeaderImage
                            anchors.bottom: listHeaderImageItem.bottom
                            anchors.bottomMargin: 0
                            rotation: -180
                            //visible: false
                        }
                    },

                    State {
                        name: "loading"
                        PropertyChanges {
                            target: listHeaderImageItem
                            height: headerText.height + listHeaderImage.height
                        }
                        PropertyChanges {
                            target: listHeaderImage
                            anchors.bottom: listHeaderImageItem.bottom
                            anchors.bottomMargin: 0
                            height: 10
                            visible: false
                        }
                        PropertyChanges {
                            target: headerText
                            text: "Laddar..."
                            anchors.margins: 5
                        }
                    }
                ]

                Text {
                    id: headerText
                    anchors.bottom: listHeaderImage.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottomMargin: 5
                    opacity: -travelResultsListView.contentY > 30 ? 1 : 0;
                    Behavior on opacity { NumberAnimation { duration: 250  } }

                    text: "Släpp för att ladda tidigare resor"
                    font.pixelSize: 20
                }

                Image {
                    id: listHeaderImage
                    anchors.bottom: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottomMargin: 10
                    source:  "image://theme/icon-m-toolbar-down"
                    opacity: -travelResultsListView.contentY > 20 ? 1 : 0;
                    Behavior on opacity { NumberAnimation { duration: 250  } }
                    Behavior on rotation { NumberAnimation { duration: 150 } }
                }
            }
        }

        Component {
            id: listFooter

            Item {
                width: travelResultsListView.width
                height:  0
                id: listFooterImageItem
                visible: completeTravelListModel.count > 0

                Connections {
                    target: travelResultsPage
                    onGotSearchResponse: {
                        listFooterImageItem.state = ""
                        travelBusyIndicator.visible = false
                        travelBusyIndicator.running = false
                    }

                    onPreLoadAtBottom: {
                        listFooterImageItem.state = "preload"
                    }

                    onLoadingResultsAtBottom: {
                        listFooterImageItem.state = "loading"
                    }
                }

                states: [
                    State {
                        name: "preload"
                        PropertyChanges {
                            target: listFooterImageItem
                            height: footerText.height + listFooterImage.height
                        }
                        PropertyChanges {
                            target: listFooterImage
                            anchors.top: listFooterImageItem.top
                            anchors.topMargin: 0
                            rotation: 180
                        }
                    },

                    State {
                        name: "loading"
                        PropertyChanges {
                            target: listFooterImageItem
                            height: footerText.height + listFooterImage.height
                        }
                        PropertyChanges {
                            target: listFooterImage
                            anchors.top: listFooterImageItem.top
                            anchors.topMargin: 0
                            height: 0
                            visible: false
                        }
                        PropertyChanges {
                            target: footerText
                            text: "Laddar..."
                            anchors.margins: 0
                            anchors.top: listFooterImageItem.top
                        }
                    }
                ]

                Text {
                    id: footerText
                    anchors.top: listFooterImage.bottom
                    anchors.horizontalCenter: listFooterImageItem.horizontalCenter
                    opacity: 1

                    text: "Släpp för att ladda senare resor"
                    font.pixelSize: 20
                }

                Image {
                    id: listFooterImage
                    anchors.top: listFooterImageItem.bottom
                    anchors.horizontalCenter: listFooterImageItem.horizontalCenter
                    source:  "image://theme/icon-m-toolbar-down"
                    opacity: 1
                    visible: true
                    Behavior on rotation { NumberAnimation { duration: 150 } }
                }
            }
        }

        ListView {
            id: travelResultsListView
            model: completeTravelListModel
            anchors.top: travelResultsDescriptionShadow.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            clip: true
            header: listHeader
            footer: listFooter
            focus: true
            pressDelay: 100

            section.property: "DateOnly"
            section.criteria: ViewSection.FullString
            section.delegate: sectionHeading

            signal pulledDown()
            signal pulledUp()

            // private
            property bool __wasAtYBeginning: false
            property int __initialContentY: 0
            property bool __toBeRefresh: false
            property bool __wasAtYEnd: false
            property int __initialContentHeight: 0

            onMovementStarted: {
                __wasAtYBeginning = atYBeginning
                __initialContentY = contentY
                __wasAtYEnd = atYEnd
                __initialContentHeight = contentHeight
                //console.debug("onMovementStarted")
            }
            onContentYChanged: {
                if (__wasAtYBeginning
                    && __initialContentY - contentY > 100) {
                    __toBeRefresh = true
                    preLoadAtTop()
                    //console.debug("onMovementStarted - top")
                }
                else if(__wasAtYEnd
                    && contentY - __initialContentY > (100)) {
                    __toBeRefresh = true
                    preLoadAtBottom()
                    //console.debug("onMovementStarted - bottom")
                }

            }
            onMovementEnded: {
                //console.debug("onMovementEnded")
                if (__toBeRefresh) {
                    if (__wasAtYBeginning) {
                        pulledUp()
                    }
                    else if (__wasAtYEnd) {
                        pulledDown()
                    }

                    __toBeRefresh = false
                }
            }

            onPulledDown: {
                //console.debug("onPulledDown")
                pullDirection = "DOWN";
                time.start();
                loadingResultsAtBottom();
            }

            onPulledUp: {
                //console.debug("onPulledUp")
                pullDirection = "UP";
                time.start();
                loadingResultsAtTop();
            }

            Component {
                id: sectionHeading

                Rectangle {
                    id: sectionHeadingRect
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 50
                    color: "red"

                    Text {
                        text: section
                        font.pixelSize: 20
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        anchors.fill: parent
                        color: "white"
                    }

                    Rectangle {
                        id: sectionHeadingLighting
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        height: 2
                        color: "white"
                        opacity: 0.5
                    }

                    Rectangle {
                        id: sectionHeadingShadow
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: sectionHeadingRect.bottom
                        height: 5
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "grey" }
                            GradientStop { position: 1.0; color: "white" }
                        }
                    }
                }

            }

            delegate:
                Rectangle {
                    id: listItemDelegate
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 75
                    color: index%2 === 0 ? "white" : "#D7D7D7"

                    MouseArea {
                        id: listItemDelegateMouseArea
                        anchors.fill: parent

                        onClicked: {
                            travelDetailsPage.journeyKey = JourneyKey;
                            travelDetailsPage.updateModel();
                            appWindow.pageStack.push(travelDetailsPage);
                        }
                    }

                    states: State {
                        name: "pressed"
                        when: listItemDelegateMouseArea.pressed
                        PropertyChanges {
                            target: listItemDelegate
                            scale: 1.1
                        }
                    }

                    transitions: Transition {
                        NumberAnimation { property: "scale"; duration: 100; easing.type: Easing.InOutQuad }
                    }

                    Text {
                        id: depDateTime
                        text: timeFromDateTime(DepDateTime)
                        width: parent.width / 6
                        font.pixelSize: 20
                        anchors.left: parent.left
                        anchors.bottom: parent.bottom
                        anchors.top: parent.top
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Text {
                        id: arrDateTime
                        text: timeFromDateTime(ArrDateTime)
                        width: parent.width / 6
                        font.pixelSize: 20
                        anchors.left: depDateTime.right
                        anchors.bottom: parent.bottom
                        anchors.top: parent.top
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Rectangle {
                        id: travelTypes
                        width: parent.width / 6
                        anchors.left: arrDateTime.right
                        anchors.bottom: parent.bottom
                        anchors.top: parent.top
                        color: listItemDelegate.color

                        GridView {
                            id: travelTypesGrid
                            cellHeight: 20
                            cellWidth: 20
                            anchors.left: parent.left
                            anchors.right: parent.right
                            y: parent.height/2 - 10

                            model: ListModel {
                                id: travelTypesGridModel
                            }

                            Component.onCompleted: {
                                addLinkTypesToGridListModel(JourneyKey, travelTypesGridModel)
                            }

                            delegate: Image {
                                        id: travelTypeImage
                                        source: imageUrlForLineType(LineTypeIdd)
                                        height: 20
                                        width: 20
                            }
                        }
                    }

                    Text {
                        id: switches
                        text: NoOfChanges
                        width: parent.width / 6
                        font.pixelSize: 20
                        anchors.left: travelTypes.right
                        anchors.bottom: parent.bottom
                        anchors.top: parent.top
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Text {
                        id: travelTime
                        text: travelTimeFromDepAndArrDateTime(DepDateTime, ArrDateTime)
                        width: parent.width / 6
                        font.pixelSize: 20
                        anchors.left: switches.right
                        anchors.bottom: parent.bottom
                        anchors.top: parent.top
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Rectangle {
                        id: infoTypes
                        width: parent.width / 6
                        anchors.left: travelTime.right
                        anchors.bottom: parent.bottom
                        anchors.top: parent.top
                        color: listItemDelegate.color

                        Image {
                            id: infoTypeImage
                            source: getInfoImageForJourneyKey(JourneyKey)
                            height: 20
                            width: 20
                            y: parent.height/2 - 10
                        }
                    }
            }
        }

        XmlListModel {
            id: travelListModel
            property int index
            xml: xmlVariable

            query: "/soap:Envelope/soap:Body/GetJourneyResponse/GetJourneyResult/Journeys/Journey"

            namespaceDeclarations: "declare namespace soap = 'http://schemas.xmlsoap.org/soap/envelope/';
                                    declare namespace xsi = 'http://www.w3.org/2001/XMLSchema-instance';
                                    declare namespace xsd = 'http://www.w3.org/2001/XMLSchema';
                                    declare default element namespace 'http://www.etis.fskab.se/v1.0/ETISws';"

            XmlRole { name: "DepDateTime"; query: "DepDateTime/string()" }
            XmlRole { name: "ArrDateTime"; query: "ArrDateTime/string()" }
            XmlRole { name: "NoOfChanges"; query: "NoOfChanges/string()" }
            XmlRole { name: "JourneyKey"; query: "JourneyKey/string()"; isKey: true }

            onStatusChanged: {
                //console.debug("travelListModel: Status changed: " + status)
            }

            onSourceChanged: {
                //console.debug("travelListModel: Source changed: " + source)
            }

            onXmlChanged: {
                //console.debug("travelListModel: Xml changed: " + xml)
            }

            onProgressChanged: {
                //console.debug("travelListModel: Progress changed: " + progress)
            }

            onItemsInserted: {
                //console.debug("Item inserted")
                if(travelListModel.count == 0) {
                    //console.debug("No new items");
                    return;
                }

                var append = true
                var insert = false
                var firstNewItem = travelListModel.get(0)
                var lastNewItem = travelListModel.get(travelListModel.count-1)
                var firstOldItem = completeTravelListModel.get(0)
                var lastOldItem = completeTravelListModel.get(completeTravelListModel.count-1)
                var lastDate = ""
                // During the first run, there will be no "old items" to
                // compare with
                if (typeof firstOldItem !== "undefined" && typeof lastOldItem !== "undefined") {
                    var firstNewItemDate = travelDateTimeToJsDate(firstNewItem.DepDateTime)
                    var lastNewItemDate = travelDateTimeToJsDate(lastNewItem.DepDateTime)
                    var firstOldItemDate = travelDateTimeToJsDate(firstOldItem.DepDateTime)
                    var lastOldItemDate = travelDateTimeToJsDate(lastOldItem.DepDateTime)
                    if(firstNewItemDate.valueOf() < firstOldItemDate.valueOf()) {
                        insert = true
                        append = false
                    } else if (lastNewItemDate.valueOf() > lastOldItemDate.valueOf()) {
                        insert = false
                        append = true
                    }
                }

                extractRouteLinkData();

                //TODO: Rewrite this on a clear head...
                if (append === true) {
                    for (var i = 0; i < travelListModel.count; i++) {
                        var item = travelListModel.get(i)
                        var journeyKey = item.JourneyKey;
                        var skipItem = false

                        for (var j = 0; j < completeTravelListModel.count; j++) {
                            var itemInCompleteList = completeTravelListModel.get(j)
                            if (itemInCompleteList.JourneyKey === journeyKey) {
                                skipItem = true
                                continue;
                            }
                        }

                        if (skipItem === false) {
                            // NOTE: It works to set a custom property like this
                            //item.ShowDate = "true"
                            item.DateOnly = dateFromDateTime(item.DepDateTime);
                            addRouteLinkDataToListItem(item);
                            completeTravelListModel.append(item);
                        }
                    }

                } else if (insert === true) {
                    for (var i = travelListModel.count-1; i >= 0; i--) {
                        var item = travelListModel.get(i);
                        var journeyKey = item.JourneyKey;
                        var skipItem = false;

                        for (var j = 0; j < completeTravelListModel.count; j++) {
                            var itemInCompleteList = completeTravelListModel.get(j);
                            if (itemInCompleteList.JourneyKey === journeyKey) {
                                skipItem = true;
                                continue;
                            }
                        }

                        if (skipItem === false) {
                            item.DateOnly = dateFromDateTime(item.DepDateTime);
                            addRouteLinkDataToListItem(item);
                            completeTravelListModel.insert(0, item);
                        }
                    }
                }
                travelResultsPage.gotSearchResponse();
            }
        }

        ListModel {
            id: completeTravelListModel
        }
    }
}

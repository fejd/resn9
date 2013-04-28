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
import "js/dbaccess.js" as DbAccess

Sheet {
    id: searchSheet

    rejectButtonText: "Avbryt"
    acceptButtonText: "Välj"

    signal selectedStation(string nameValue, string idValue)

    property Item backgroundItem

    function showRequestInfo(text) {
        console.debug(text)
    }

    function clearSheet() {
        searchXmlModel.xml = ""
        searchInput.text = ""
    }

    function readStationsFromDb() {
        // Read from database and set the model
        var stations = DbAccess.readStations()
        for (var i = 0; i < stations.length; i++) {
            usualStationsModel.append({"Id": stations[i].idTag, "Name": stations[i].nameTag})
        }
    }

    onStatusChanged: {
        if(typeof backgroundItem === "undefined") {
            // backgroundItem might be null at the beginning
            return;
        }

        if (status === DialogStatus.Opening) {
            usualStationsModel.clear()
            backgroundItem.state = "dimmed"

        }
        else if (status === DialogStatus.Open) {
            searchInput.forceActiveFocus()
            readStationsFromDb()
            searchResultList.model = usualStationsModel
        }
        else if ((status === DialogStatus.Closing) ||
                 (status === DialogStatus.Closed)) {
            backgroundItem.state = ""
        }
    }

    onAccepted: {
        DbAccess.createStation(searchResultList.currentItem.idTag, searchResultList.currentItem.nameTag)
        selectedStation(searchResultList.currentItem.nameTag, searchResultList.currentItem.idTag)
    }


    BusyIndicator {
        id: searchIndicator
        platformStyle: BusyIndicatorStyle { size: "medium" }
        running: false
        visible: false

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 15
    }

    content:
        Rectangle {
            id: searchRect
            anchors.fill: parent
            color: "black"

            ListModel {
                id: usualStationsModel
            }

            ListView {
                id: searchResultList
                model: searchXmlModel
                anchors.top: searchInput.bottom
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.topMargin: 10
                clip: true
                highlightFollowsCurrentItem: false
                highlight: highlightBar

                delegate: Text {
                    text: Name
                    font.pointSize: 18
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 5
                    verticalAlignment: Text.AlignVCenter
                    styleColor: "lightgray"
                    height: 50
                    color: "white"

                    property string nameTag: model.Name
                    property string idTag: model.Id

                    MouseArea {
                        anchors.fill: parent
                        Connections {

                        }

                        onClicked: {
                            searchResultList.currentIndex = index
                        }

                        MouseArea {
                            id: kalle
                            onClicked: {

                            }
                        }
                    }
                }
            }

            Component {
                 id: highlightBar
                 Rectangle {
                     width: searchResultList.width-2
                     height: searchResultList.currentItem ? searchResultList.currentItem.height-2 : height
                     color: "#31549B"
                     opacity: 0.8
                     border.color: "grey"
                     y: searchResultList.currentItem ? searchResultList.currentItem.y : y
                     Behavior on y {
                         SpringAnimation {
                             spring: 4
                             damping: 0.4
                         }
                     }
                 }
             }

            XmlListModel {
                id: searchXmlModel
                source: ""
                query: "/soap:Envelope/soap:Body/GetStartEndPointResponse/GetStartEndPointResult/StartPoints/Point"

                namespaceDeclarations: "declare namespace soap = 'http://schemas.xmlsoap.org/soap/envelope/';
                                        declare namespace xsi = 'http://www.w3.org/2001/XMLSchema-instance';
                                        declare namespace xsd = 'http://www.w3.org/2001/XMLSchema';
                                        declare default element namespace 'http://www.etis.fskab.se/v1.0/ETISws';"

                XmlRole { name: "Name"; query: "Name/string()" }
                XmlRole { name: "Id"; query: "Id/string()" }
            }

            TextField {
                id: searchInput
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: 10

                height: 50

                inputMethodHints: Qt.ImhNoPredictiveText

                onTextChanged: {
                    if (searchInput.text.length < 2) {
                        return;
                    }

                    var doc = new XMLHttpRequest();
                    doc.onreadystatechange = function() {
                        if (doc.readyState === XMLHttpRequest.HEADERS_RECEIVED) {
                            //showRequestInfo("Headers -->");
                            //showRequestInfo(doc.getAllResponseHeaders ());
                            //showRequestInfo("Last modified -->");
                            //showRequestInfo(doc.getResponseHeader ("Last-Modified"));

                        } else if (doc.readyState === XMLHttpRequest.DONE) {
                            var a = doc.responseXML.documentElement;
                            //showRequestInfo(doc.responseText)
                            searchXmlModel.xml = doc.responseText
                            searchResultList.model = searchXmlModel
                            searchIndicator.visible = false
                            searchIndicator.running = false
                            //for (var ii = 0; ii < a.childNodes.length; ++ii) {
                            //    showRequestInfo(a.childNodes[ii].nodeName);
                            //}
                            //showRequestInfo("Headers -->");
                            //showRequestInfo(doc.getAllResponseHeaders ());
                            //showRequestInfo("Last modified -->");
                            //showRequestInfo(doc.getResponseHeader ("Last-Modified"));
                        }
                    }

                    var searchUrl = "http://www.labs.skanetrafiken.se/v2.2/querystation.asp?inpPointfr=" + searchInput.text;
                    doc.open("GET", searchUrl);
                    doc.send();
                    if (!searchIndicator.running) {
                        searchIndicator.visible = true
                        searchIndicator.running = true
                    }
                }
            }
        }
}

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

// This page shows travel details for a particular trip
Page {
    property string journeyKey: ""
    property alias listModel: travelRoutesDetailsModel
    orientationLock: PageOrientation.LockPortrait

    tools: ToolBarLayout {
        id: simpleToolBar

        visible: true
        // for back button
        ToolIcon { iconId: "toolbar-back"; onClicked: pageStack.pop(); }
    }

    function updateModel() {
        // TODO: The grid view does not show all images...
        listModel.clear();
        addRouteLinkDataToListModel(journeyKey, listModel);
    }

    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        color: "white"

        Rectangle {
            id: travelHeaderRectangle
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.left: parent.left
            height: 100
            color: "red"

            Text {
                id: travelHeaderText
                text: "Detaljer för resa"
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
        }

        ListView {
            id: travelRoutesDetails
            model: travelRoutesDetailsModel
            anchors.top: travelHeaderRectangle.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            clip: true
            focus: true

            ListModel {
                id: travelRoutesDetailsModel
            }

            delegate: Rectangle {
                id: routeDetailsRect
                anchors.left: parent.left
                anchors.right: parent.right
                border.color: "black"
                border.width: 1
                height: 120

                Rectangle {
                    id: lineInfoRect
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 16
                    anchors.topMargin: 4
                    height: parent.height / 2

                    Image {
                        id: travelTypeImage
                        source: imageUrlForLineType(LineTypeId)
                        height: 20
                        width: 20
                    }

                    Text {
                        id: lineNameText
                        anchors.left: travelTypeImage.right
                        anchors.leftMargin: 4
                        font.pixelSize: 20
                        verticalAlignment: Text.AlignVCenter
                        color: "black"
                        text: (LineTypeId < 16 || LineTypeId > 32) ? LineName : TrainNo
                        y: travelTypeImage.y
                    }

                    Text {
                        id: lineTypeNameText
                        anchors.left: lineNameText.right
                        anchors.leftMargin: 4
                        font.pixelSize: 20
                        verticalAlignment: Text.AlignVCenter
                        color: "black"
                        text: LineTypeName
                        y: travelTypeImage.y
                        visible: LineTypeId !== 16 && LineTypeId !== 32 && LineTypeId !== 0; //Pagatag, Oresundstag, Gang
                    }

                    Text {
                        id: towardsText
                        anchors.left: lineNameText.left
                        anchors.top: lineNameText.bottom
                        font.pixelSize: 20
                        verticalAlignment: Text.AlignVCenter
                        color: "black"
                        text: "Mot: " + Towards
                        visible: {
                            var blankPattern = /^Blank/;
                            if (blankPattern.test(Towards) || Towards === '') {
                                return false;
                            } else {
                                return true;
                            }
                        }
                    }
                }

                Text {
                    id: depDateTimeText
                    anchors.left: parent.left
                    anchors.top: lineInfoRect.bottom
                    height: parent.height / 4
                    width: 50
                    anchors.leftMargin: 16
                    font.pixelSize: 20
                    font.strikeout: depDateTimeDeviationText.visible
                    text: timeFromDateTime(DepTime)
                    verticalAlignment: Text.AlignVCenter
                    color: "black"
                }

                Text {
                    id: depDateTimeDeviationText
                    anchors.left: depDateTimeText.right
                    anchors.top: lineInfoRect.bottom
                    height: depDateTimeText.height
                    width: !visible ? 0 : 50
                    anchors.leftMargin: 16
                    font.pixelSize: 20
                    text: visible ? timeFromDateTime(Qt.formatDateTime(addMinutesToDate(DepTime, DepDev), Qt.ISODate)) : ""
                    verticalAlignment: Text.AlignVCenter
                    visible: DepDev === "0" ? false : true
                    color: "red"
                }

                Text {
                    id: fromNameText
                    anchors.left: depDateTimeDeviationText.right
                    anchors.top: lineInfoRect.bottom
                    height: depDateTimeText.height
                    width: 100
                    font.pixelSize: 20
                    text: FromName
                    verticalAlignment: Text.AlignVCenter
                    color: "black"
                }

                Text {
                    id: arrDateTimeText
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    height: parent.height / 4
                    width: 50
                    anchors.leftMargin: 16
                    font.pixelSize: 20
                    font.strikeout: arrDateTimeDeviationText.visible
                    text: timeFromDateTime(ArrTime)
                    verticalAlignment: Text.AlignVCenter
                    color: "black"
                }

                Text {
                    id: arrDateTimeDeviationText
                    anchors.left: arrDateTimeText.right
                    anchors.bottom: parent.bottom
                    height: arrDateTimeText.height
                    width: !visible ? 0 : 50
                    anchors.leftMargin: 16
                    font.pixelSize: 20
                    text: visible ? timeFromDateTime(Qt.formatDateTime(addMinutesToDate(ArrTime, ArrDev), Qt.ISODate)) : ""
                    verticalAlignment: Text.AlignVCenter
                    visible: ArrDev === "0" ? false : true
                    color: "red"
                }

                Text {
                    id: toNameText
                    anchors.left: arrDateTimeDeviationText.right
                    anchors.bottom: parent.bottom
                    height: arrDateTimeText.height
                    width: 100
                    font.pixelSize: 20
                    text: ToName
                    verticalAlignment: Text.AlignVCenter
                    color: "black"
                }
            }
        }
    }
}

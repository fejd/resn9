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

var _shownDates = new Array();

var _lineTypeImages = new Array();

var _travelDate = new Date();

var _responseXml;

var _routeLinkDataForJourney = [] //new Array();

var _travelInfoImages = {'CRITICAL': '../images/rtB_0.gif',
                         'NON_CRITICAL' : '../images/rtB_1.gif',
                         'PASSED' : '../images/rtB_2.gif',
                         'NONE' : '../images/rtB_4.gif'};

var _travelInfoSeverity = {'CRITICAL' : 4,
                           'NON-CRITICAL' : 3,
                           'PASSED' : 2,
                           'NONE' : 1}

_lineTypeImages['0'] = '../images/gang.gif'
_lineTypeImages['1'] = '../images/krosatag.gif'
_lineTypeImages['2'] = '../images/pagatagexpress.gif'
_lineTypeImages['4'] = '../images/stadsbuss.gif'
_lineTypeImages['8'] = '../images/regionbuss.gif'
_lineTypeImages['16'] = '../images/skaneexpress.gif'
_lineTypeImages['32'] = '../images/pendeln.gif';
_lineTypeImages['64'] = '../images/oresundstag.gif';
_lineTypeImages['128'] = '../images/pagatagen.gif';
_lineTypeImages['256'] = '../images/tagbuss.gif';
_lineTypeImages['512'] = '../images/farjeforbindelser.gif';
_lineTypeImages['1024'] = '../images/flygbuss.gif';

function RouteLinkData(journeyKey, lineTypeId, depTime, arrTime, fromName, toName, depTimeDeviation, depDeviationAffect, arrTimeDeviation, arrDeviationAffect, routeLinkKey, lineName, lineTypeName, towards, trainNo) {
    this.JourneyKey = journeyKey;
    this.LineTypeId = lineTypeId;
    this.DepTime = depTime;
    this.ArrTime = arrTime;
    this.FromName = fromName;
    this.ToName = toName;
    this.DepDev = depTimeDeviation;
    this.DepDevAffect = depDeviationAffect;
    this.ArrDev = arrTimeDeviation;
    this.ArrDevAffect = arrDeviationAffect;
    this.RouteLinkKey = routeLinkKey;
    this.LineName = lineName;
    this.LineTypeName = lineTypeName;
    this.Towards = towards;
    this.TrainNo = trainNo;
}

function addRouteLinkData(journeyKey, lineTypeId, depTime, arrTime, fromName, toName, depTimeDeviation, depDeviationAffect, arrTimeDeviation, arrDeviationAffect, routeLinkKey, lineName, lineTypeName, towards, trainNo) {
    var data = new RouteLinkData(journeyKey, lineTypeId, depTime, arrTime, fromName, toName, depTimeDeviation, depDeviationAffect, arrTimeDeviation, arrDeviationAffect, routeLinkKey, lineName, lineTypeName, towards, trainNo);
    _routeLinkDataForJourney.push(data);
}

function clearRouteLinkData() {
    _routeLinkDataForJourney.length = 0;
}

function getRouteLinkDataForJourneyKey(journeyKey) {
    var routeLinkDataForJourney = new Array();
    for(var i = 0; i < _routeLinkDataForJourney.length; i++) {
        var routeLink = _routeLinkDataForJourney[i];
        if (routeLink.JourneyKey === journeyKey) {
            routeLinkDataForJourney.push(routeLink);
        }
    }
    return routeLinkDataForJourney;
}

function getInfoImageForJourneyKey(journeyKey) {
    var routeLinkDataForJourney = getRouteLinkDataForJourneyKey(journeyKey);
    var worstDeviation = 'NONE'
    // Go through all route links and find the most serious deviation
    // The first item's departure deviation should be more important - if it
    // has passed, return it immediately.
    for(var i = 0; i < routeLinkDataForJourney.length; i++) {
        var routeLinkData = routeLinkDataForJourney[i];
        if(i == 0) {
            if(routeLinkData.DepDevAffect === 'PASSED') {
                return _travelInfoImages[routeLinkData.DepDevAffect];
            }
        }
        if(_travelInfoSeverity[routeLinkData.DepDevAffect] > _travelInfoSeverity[worstDeviation]) {
            worstDeviation = routeLinkData.DepDevAffect;
        }
        if(_travelInfoSeverity[routeLinkData.ArrDevAffect] > _travelInfoSeverity[worstDeviation]) {
            worstDeviation = routeLinkData.ArrDevAffect;
        }
    }
    return _travelInfoImages[worstDeviation];
}

function addRouteLinkDataToListItem(item) {
    for(var i = 0; i < _routeLinkDataForJourney.length; i++) {
        var routeLink = _routeLinkDataForJourney[i];
        if(routeLink.JourneyKey === item.JourneyKey) {
            item.LineTypeId = routeLink.LineTypeId;
            item.DepTime = routeLink.DepTime;
            item.ArrTime = routeLink.ArrTime;
            item.FromName = routeLink.FromName;
            item.ToName = routeLink.ToName;
            item.DepDev = routeLink.DepDev;
            item.DepDevAffect = routeLink.DepDevAffect;
            item.ArrDev = routeLink.ArrDevAffect;
            item.LineName = routeLink.LineName;
            item.LineTypeName = routeLink.LineTypeName;
            item.Towards = routeLink.Towards;
            item.TrainNo = routeLink.TrainNo;
        }
    }
}

function addRouteLinkDataToListModel(journeyKey, listModel) {
    var routeLinkData = getRouteLinkDataForJourneyKey(journeyKey);
    for(var i = 0; i < routeLinkData.length; i++) {
        var routeLink = routeLinkData[i];
        // Strings must be prepended by ""
        listModel.append({"LineTypeId": "" + routeLink.LineTypeId,
                             "DepTime": "" + routeLink.DepTime,
                             "ArrTime": "" + routeLink.ArrTime,
                             "FromName" : "" + routeLink.FromName,
                             "ToName" : "" + routeLink.ToName,
                             "DepDev" : "" + routeLink.DepDev,
                             "DepDevAffect" : "" + routeLink.DepDevAffect,
                             "ArrDev" : "" + routeLink.ArrDev,
                             "ArrDevAffect" : + routeLink.ArrDevAffect,
                             "LineName" : "" + routeLink.LineName,
                             "LineTypeName" : "" + routeLink.LineTypeName,
                             "Towards" : "" + routeLink.Towards,
                             "TrainNo" : "" + routeLink.TrainNo});
    }
}

// TODO: Instead of two similar functions, use the same function?
// Some of the information that will then be added to the gridview with
// the icons will have information that is not needed, but maybe that's ok
// TODO: Also fix the LineTypeIdd issue. Why not use LineTypeId? Is it already used in the model?
function addLinkTypesToGridListModel(journeyKey, listModel) {
    var routeLinkDataForJourney = getRouteLinkDataForJourneyKey(journeyKey);
    for(var i = 0; i < routeLinkDataForJourney.length; i++) {
        var routeLink = routeLinkDataForJourney[i];
        listModel.append({"LineTypeIdd": "" + routeLink.LineTypeId})
    }
}

function setTravelDate(date) {
    _travelDate = date;
}

function getTravelDate() {
    return _travelDate;
}

function setTravelDateToNow() {
    _travelDate = new Date();
}

function addShownDate(date) {
    if (isDateShown()) {
        return
    }

    _shownDates.push(date)
}

function timeFromDateTime(dateTime) {
    var strDateTime = new String(dateTime);
    var startIndex = (strDateTime.indexOf('T') + 1);
    var timeString = strDateTime.substring(startIndex);
    return timeString.substring(0, 5);
}

function dateFromDateTime(dateTime) {
    var strDateTime = new String(dateTime);
    var endIndex = (strDateTime.indexOf('T'));
    var dateString = strDateTime.substring(0, endIndex);
    return dateString;
}

function hourFromTime(time) {
    var hour = time.substring(0, time.indexOf(':'));
    return hour;
}

function addMinutesToDate(date, minutes) {
    var jsDate = travelDateTimeToJsDate(date);
    return new Date(jsDate.getTime() + (minutes * 60000));
}

function travelDateTimeToJsDate(travelDate) {
    //var variable = new Date(year, month, day, hours, minutes, seconds, milliseconds)
    //2012-06-29T00:04:00
    var dateString = dateFromDateTime(travelDate);
    // Parse the date
    var year = dateString.substring(0, 4);
    var decimalRadix = 10;
    var month = parseInt(dateString.substring(5, 7), decimalRadix) - 1;
    var day = dateString.substring(8, 10);

    var timeString = timeFromDateTime(travelDate);
    var hours = timeString.substring(0, 2);
    var minutes = timeString.substring(3, 5);
    var seconds = timeString.substring(6, 8);

    return new Date(year, month, day, hours, minutes, seconds);
}

function travelTimeFromDepAndArrDateTime(depDateTime, arrDateTime) {
    var depTimeString = timeFromDateTime(depDateTime);
    var arrTimeString = timeFromDateTime(arrDateTime);

    var depHours = depTimeString.substring(0, 2);
    var depMinutes = depTimeString.substring(3, 5);
    var arrHours = arrTimeString.substring(0, 2);
    var midnightCompensationHours = 0;
    if (arrHours < depHours) {
        midnightCompensationHours = 24;
    }

    var arrMinutes = arrTimeString.substring(3, 5);

    var totalHours = arrHours - depHours + midnightCompensationHours;
    var totalMinutes = arrMinutes - depMinutes;

    if (totalMinutes < 0 && totalHours > 0) {
        totalHours -= 1;
        totalMinutes += 60;
    }

    if (totalMinutes < 10) {
        totalMinutes = "0" + totalMinutes;
    }

    return totalHours + ":" + totalMinutes;
    // TODO: Handle cases that go beyond midnight - already handled?
}

function setResponseXml(responseXml) {
    _responseXml = responseXml;
}

function getResponseXml() {
    return _responseXml;
}

function isDateShown(date) {
    for (var i = 0; i < _shownDates.length; i++) {
        if (date === _shownDates[i]) {
            return true
        }
    }

    return false
}

function clearShownDates() {
    _shownDates = new Array()
}

function imageUrlForLineType(lineTypeId) {
    return _lineTypeImages[lineTypeId]
}

function isLineTypeIdTrain(lineTypeId) {
    // Note: Switch statements do not work properly
    // in QML/JS.
    var _lineTypeId = Number(lineTypeId)
    if (_lineTypeId === 0 ||
            _lineTypeId === 4 ||
            _lineTypeId === 8 ||
            _lineTypeId === 16 ||
            _lineTypeId === 32 ||
            _lineTypeId === 256 ||
            _lineTypeId === 512 ||
            _lineTypeId === 1024) {
        return false;
    } else if (_lineTypeId === 1 ||
               _lineTypeId === 2 ||
               _lineTypeId === 64 ||
               _lineTypeId === 128) {
        return true;
    }
    return false;
}

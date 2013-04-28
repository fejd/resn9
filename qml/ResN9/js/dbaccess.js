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

.pragma library

var _db;
var STATION_LIMIT = 10;

function openDB() {
    _db = openDatabaseSync("UsualStations", "1.0", "Usual Stations", 10000);
    createTable();
}

function createTable() {
    _db.transaction( function(tx) {
        tx.executeSql("\
            CREATE TABLE IF NOT EXISTS\
            usualstations (id INTEGER PRIMARY KEY AUTOINCREMENT,\
            idTag INTEGER,\
            nameTag TEXT\
        )");
    });
}

function dropTable()
{
    _db.transaction(
        function(tx){
            tx.executeSql("DROP TABLE IF EXISTS usualstations");
        })
}

function createStation(idTag, nameTag) {
    _db.readTransaction( function(tx) {
        var station = tx.executeSql("SELECT * FROM usualstations WHERE nameTag = '" + nameTag + "'");
        if (station.rows.length > 0) {
            deleteStation(nameTag)
        }
    });

    _db.transaction( function(tx) {
        tx.executeSql("\
        INSERT INTO usualstations (idTag, nameTag) VALUES (?,?)", [idTag, nameTag]);
    });
    deleteOffLimitStation();
}

function deleteStation(nameTag) {
    _db.transaction( function(tx) {
        tx.executeSql("DELETE FROM usualstations WHERE nameTag = ?", [nameTag]);
        })
}

function readStations() {
    var data = []
    _db.readTransaction( function(tx) {
        var rs = tx.executeSql("SELECT * FROM usualstations ORDER BY id DESC");
        for (var i = 0; i < rs.rows.length; i++) {
           data[i] = rs.rows.item(i);
        }
    });
    return data;
}

function deleteOffLimitStation() {
    var stations = readStations();
    var numStations = stations.length;
    if (numStations > STATION_LIMIT) {
        var offlimitStation = stations[numStations-1];
        deleteStation(offlimitStation.nameTag)
    }
}

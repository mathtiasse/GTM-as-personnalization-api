___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Read/Write to Firestore \u0026 set Response Body",
  "brand": {
    "id": "brand_dummy",
    "displayName": ""
  },
  "description": "This model helps to read a specific data key to firestore, increment it and set the value in the response body",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "GROUP",
    "name": "firestore SETUP",
    "displayName": "Firestore Initialization",
    "groupStyle": "ZIPPY_OPEN",
    "subParams": [
      {
        "type": "TEXT",
        "name": "gcpProjectId",
        "displayName": "GCP project Id",
        "simpleValueType": true,
        "help": "If your firestore database is into the same GCP project as your GTM, you can keep it empty"
      },
      {
        "type": "TEXT",
        "name": "firestoreCollection",
        "displayName": "Name of your Firestore collection",
        "simpleValueType": true
      },
      {
        "type": "TEXT",
        "name": "firestoreDocument",
        "displayName": "Name of your document",
        "simpleValueType": true
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "datas",
    "displayName": "Data shaping",
    "groupStyle": "ZIPPY_OPEN",
    "subParams": [
      {
        "type": "TEXT",
        "name": "field",
        "displayName": "Field name of your document",
        "simpleValueType": true
      },
      {
        "type": "TEXT",
        "name": "objectUser",
        "displayName": "Your object",
        "simpleValueType": true,
        "enablingConditions": [
          {
            "paramName": "objectBuilder",
            "paramValue": false,
            "type": "EQUALS"
          }
        ],
        "help": "If you want to build your object from scratch select the box \"Build your object ?\""
      },
      {
        "type": "CHECKBOX",
        "name": "objectBuilder",
        "checkboxText": "Build your own object ?",
        "simpleValueType": true
      },
      {
        "type": "SIMPLE_TABLE",
        "name": "object_data",
        "displayName": "Object builder :",
        "simpleTableColumns": [
          {
            "defaultValue": "",
            "displayName": "Key",
            "name": "dataKey",
            "type": "TEXT"
          },
          {
            "defaultValue": "",
            "displayName": "Value",
            "name": "dataValue",
            "type": "TEXT"
          }
        ],
        "enablingConditions": [
          {
            "paramName": "objectBuilder",
            "paramValue": true,
            "type": "EQUALS"
          }
        ]
      },
      {
        "type": "TEXT",
        "name": "arraySize",
        "displayName": "Size of your array",
        "simpleValueType": true,
        "help": "Max values inside of the array. If the limit is reached, the first value recorded will be dropped",
        "defaultValue": 10
      },
      {
        "type": "CHECKBOX",
        "name": "activateEventsFirestore",
        "checkboxText": "Enter the events which interact with firestore",
        "simpleValueType": true,
        "help": "By default, all events are considered"
      },
      {
        "type": "SIMPLE_TABLE",
        "name": "eventFirestore",
        "displayName": "",
        "simpleTableColumns": [
          {
            "defaultValue": "",
            "displayName": "",
            "name": "event_firestore",
            "type": "TEXT"
          }
        ],
        "enablingConditions": [
          {
            "paramName": "activateEventsFirestore",
            "paramValue": true,
            "type": "EQUALS"
          }
        ],
        "newRowButtonText": "Add new event"
      }
    ],
    "help": "Build your Array of objects"
  },
  {
    "type": "GROUP",
    "name": "Response body",
    "displayName": "Response body",
    "groupStyle": "ZIPPY_OPEN",
    "subParams": [
      {
        "type": "CHECKBOX",
        "name": "isResponseBody",
        "checkboxText": "Set the value in the response ?",
        "simpleValueType": true
      },
      {
        "type": "CHECKBOX",
        "name": "activateEventsResponse",
        "checkboxText": "Enter the events which transmit the data in the response",
        "simpleValueType": true,
        "help": "By default, all events are considered"
      },
      {
        "type": "SIMPLE_TABLE",
        "name": "eventResponse",
        "displayName": "",
        "simpleTableColumns": [
          {
            "defaultValue": "",
            "displayName": "",
            "name": "event_response",
            "type": "TEXT"
          }
        ],
        "newRowButtonText": "Add new event",
        "enablingConditions": [
          {
            "paramName": "activateEventsResponse",
            "paramValue": true,
            "type": "EQUALS"
          }
        ]
      }
    ]
  }
]


___SANDBOXED_JS_FOR_SERVER___

const JSON = require('JSON');
const Object = require('Object');
const getType = require('getType');
const Promise = require('Promise');
const log = require('logToConsole');
const Firestore = require('Firestore');
const getEventData = require('getEventData');
const eventName = getEventData('event_name');
const makeTableMap = require('makeTableMap');
const setResponseBody = require('setResponseBody');

const firestoreCollection = data.firestoreCollection;
const firestoreDocument = data.firestoreDocument;
const eventFirestore = data.eventFirestore || [];
const eventResponse = data.eventResponse || [];

const ArrayEventFirestore = (eventFirestore.length > 0) ? eventFirestore.filter(e => e.event_firestore === eventName) : [];
const ArrayEventResponse = (eventResponse.length > 0) ? eventResponse.filter(e => e.event_response === eventName) : [];
const firestoreObject = data.objectBuilder ? validateTableMap(makeTableMap(data.object_data, 'dataKey', 'dataValue')) : data.objectUser;

readFirestoreThenWrite(data.field, firestoreObject);

function readFirestoreThenWrite(dataKey, newData) {
    return Firestore.read(firestoreCollection + '/' + firestoreDocument, {
            projectId: data.gcpProjectId,
        })
        .then((firestoreDocumentKey) => {
            let firestoreData = (firestoreDocumentKey.data && firestoreDocumentKey.data[dataKey]) || [];

            const exists = firestoreData.some((item) => objectsAreEqual(item, newData));
            if (!exists) {
                firestoreData.unshift(newData);
                if (firestoreData.length > data.arraySize) {
                    firestoreData.pop();
                }
            }

            return updateFirestoreData(dataKey, firestoreData);
        })
        .catch((error) => {
            return createFirestoreDocument(dataKey, newData);
        });
}

function createFirestoreDocument(dataKey, initialData) {
    const writeData = {};
    writeData[dataKey] = [initialData];

    return Firestore.write(firestoreCollection + '/' + firestoreDocument, writeData, {
            projectId: data.gcpProjectId,
            merge: false,
        })
        .then(() => {
            handleResponseBody(ArrayEventResponse, JSON.stringify(writeData));
            data.gtmOnSuccess();
        })
        .catch((error) => {
            data.gtmOnFailure();
        });
}

function updateFirestoreData(dataKey, updatedData) {

    var filteredData = [];
    for (var i = 0; i < updatedData.length; i++) {
        var item = updatedData[i];
        if (!isEmptyObject(item)) {
            filteredData.push(item);
        }
    }

    updatedData = filteredData;

    return Firestore.read(firestoreCollection + '/' + firestoreDocument, {
            projectId: data.gcpProjectId,
        })
        .then((firestoreDocumentKey) => {
            let existingData = (firestoreDocumentKey.data && firestoreDocumentKey.data[dataKey]) || [];

            const isDataEqual = arraysAreEqual(existingData, updatedData);

            let writeData = {};
            writeData[dataKey] = updatedData;
            const stringifyData = JSON.stringify(writeData);

            if (isDataEqual) {
                if (existingData.length === 0) {
                    handleResponseBody(ArrayEventResponse, '{}');
                    data.gtmOnSuccess();
                } else {
                    writeData[dataKey] = existingData;
                    handleResponseBody(ArrayEventResponse, JSON.stringify(writeData));
                    data.gtmOnSuccess();
                    return Promise.resolve();
                }
            }

            if ((data.activateEventsFirestore && ArrayEventFirestore.length > 0) || !data.activateEventsFirestore) {

                return Firestore.write(firestoreCollection + '/' + firestoreDocument, writeData, {
                        projectId: data.gcpProjectId,
                        merge: true
                    })
                    .then(() => {
                        handleResponseBody(ArrayEventResponse, stringifyData);
                        data.gtmOnSuccess();
                    })
                    .catch((error) => {
                        handleResponseBody(ArrayEventResponse, stringifyData);
                        data.gtmOnFailure();
                    });
            } else {
                handleResponseBody(ArrayEventResponse, '{}');
                data.gtmOnSuccess();
                return Promise.resolve();
            }
        })
        .catch((error) => {
            data.gtmOnFailure();
        });
}

function objectsAreEqual(obj1, obj2) {
    return JSON.stringify(obj1) === JSON.stringify(obj2);
}

function arraysAreEqual(arr1, arr2) {
    if (arr1.length !== arr2.length) return false;
    if (arr1.length === 0 && arr2.length === 0) return true;
    return arr1.every((item, index) => objectsAreEqual(item, arr2[index]));
}

function handleResponseBody(responseArray, dataToSet) {
    if (data.isResponseBody && (responseArray.length > 0 || !data.activateEventsResponse)) {
        setResponseBody(dataToSet);
    } else {
        setResponseBody('{}');
    }
}

function isEmptyObject(obj) {
    for (var key in obj) {
        return false;
    }
    return true;
}

function validateTableMap(tableMap) {
    for (var key in tableMap) {
        if (tableMap[key] === undefined) {
            return undefined;
        }
    }
    return tableMap;
}


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "access_firestore",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedOptions",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "projectId"
                  },
                  {
                    "type": 1,
                    "string": "path"
                  },
                  {
                    "type": 1,
                    "string": "operation"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "read_write"
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "access_response",
        "versionId": "1"
      },
      "param": [
        {
          "key": "writeResponseAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        },
        {
          "key": "writeHeaderAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_event_data",
        "versionId": "1"
      },
      "param": [
        {
          "key": "eventDataAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios: []


___NOTES___

Created on 1/13/2025, 10:26:19 AM



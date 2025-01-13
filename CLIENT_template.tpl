___INFO___

{
  "type": "CLIENT",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Custom Endpoint With Headers",
  "categories": [
    "UTILITY"
  ],
  "brand": {
    "id": "brand_dummy",
    "displayName": ""
  },
  "description": "This client can handle POST request with headers",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "requestPath",
    "displayName": "Request Path",
    "simpleValueType": true
  }
]


___SANDBOXED_JS_FOR_SERVER___

const JSON = require('JSON');
const runContainer = require('runContainer');
const claimRequest = require('claimRequest');
const getRequestPath = require('getRequestPath');
const returnResponse = require('returnResponse');
const getRequestBody = require('getRequestBody');
const setPixelResponse = require('setPixelResponse');
const getRemoteAddress = require('getRemoteAddress');
const getRequestHeader = require('getRequestHeader');
const getRequestMethod = require('getRequestMethod');
const setResponseHeader = require('setResponseHeader');
const getRequestQueryParameters = require('getRequestQueryParameters');

function handleRequest() {
    const requestPath = getRequestPath();
    const queryParameters = getRequestQueryParameters();
    const requestBody = getRequestBody();
    const requestMethod = getRequestMethod();
    const originHeader = getRequestHeader('origin');

    let requestBodyObject = {};
    if (requestBody && requestBody.length > 0) {
        requestBodyObject = JSON.parse(requestBody) || {};
    }

    if (requestPath.indexOf(data.requestPath) > -1) {
        claimRequest();
        setPixelResponse();

        const event = {};

        for (var key in queryParameters) {
            if (queryParameters.hasOwnProperty(key)) {
                event[key] = queryParameters[key];
            }
        }

        if (requestMethod === 'POST') {
            for (var bodyKey in requestBodyObject) {
                if (requestBodyObject.hasOwnProperty(bodyKey)) {
                    event[bodyKey] = requestBodyObject[bodyKey];
                }
            }
        }

        event.ip_override = getRemoteAddress();
        event.user_agent = getRequestHeader('user-agent');

        // Set response Header
        setResponseHeader('Access-Control-Allow-Origin', originHeader);
        setResponseHeader('Access-Control-Allow-Methods', 'POST');
        setResponseHeader('Access-Control-Allow-Credentials', 'true');
        setResponseHeader('Content-Type', 'application/json');

        runContainer(event, returnResponse);
    }
}
handleRequest();


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "read_request",
        "versionId": "1"
      },
      "param": [
        {
          "key": "requestAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        },
        {
          "key": "headerAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        },
        {
          "key": "queryParameterAccess",
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
  },
  {
    "instance": {
      "key": {
        "publicId": "return_response",
        "versionId": "1"
      },
      "param": []
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
        "publicId": "run_container",
        "versionId": "1"
      },
      "param": []
    },
    "isRequired": true
  }
]


___TESTS___

scenarios: []


___NOTES___

Created on 1/09/2025, 10:22:05 AM



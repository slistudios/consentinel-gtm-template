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
  "displayName": "Consentinel Consent Mode",
  "categories": ["UTILITY", "ANALYTICS", "ADVERTISING"],
  "brand": {
    "id": "brand_dummy",
    "displayName": "Consentinel"
  },
  "description": "Bridges Consentinel's consent state into Google Consent Mode inside Tag Manager. Requires the Consentinel Cloud snippet to already be installed as the first synchronous script; this tag never loads it. Fire on Consent Initialization - All Pages.",
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

const log = require('logToConsole');
const copyFromWindow = require('copyFromWindow');
const callInWindow = require('callInWindow');
const getCookieValues = require('getCookieValues');
const setDefaultConsentState = require('setDefaultConsentState');
const updateConsentState = require('updateConsentState');
const gtagSet = require('gtagSet');
const JSON = require('JSON');

// Fixed by this template. It is the product default and every published
// config uses it; see the design spec (2026-09-18) for why it is not a field.
const COOKIE_NAME = 'consentinel_v1';

// Mirrors emitConsentModeDefaults() and pushConsentMode() in
// packages/sdk/src/index.ts. tests/e2e/gtm-template.spec.ts reads both files
// and fails if these drift. Change both or neither.
const WAIT_FOR_UPDATE_MS = 500;

const DEFAULTS = {
  ad_storage: 'denied',
  analytics_storage: 'denied',
  ad_user_data: 'denied',
  ad_personalization: 'denied',
  functionality_storage: 'denied',
  personalization_storage: 'denied',
  security_storage: 'granted',
};

const toConsentMode = (state) => {
  const g = (v) => (v ? 'granted' : 'denied');
  return {
    analytics_storage: g(state.analytics),
    ad_storage: g(state.marketing),
    ad_user_data: g(state.marketing),
    ad_personalization: g(state.marketing),
    functionality_storage: g(state.functional),
    personalization_storage: g(state.functional),
    security_storage: 'granted',
  };
};

const fail = (why) => {
  log('Consentinel: ' + why + ' This tag set no consent state.');
  data.gtmOnFailure();
};

// The presence check is the sdkVersion STRING, not the function: Whether
// function-valued properties survive copyFromWindow is unspecified in
// Google's reference. Both are set in one object literal in the SDK's boot().
const cloud = copyFromWindow('ConsentinelCloud');

if (!cloud) {
  if (copyFromWindow('Consentinel')) {
    // Consentinel's blocker owns window.Consentinel on EVERY Consentinel page —
    // the Cloud bundle and the WordPress plugin's local mode alike — so its
    // presence without ConsentinelCloud has two possible causes, and the
    // sandbox cannot tell them apart. Name both.
    fail(
      "Consentinel's blocker is on this page but its Cloud API is not. Either " +
        'this site runs the Consentinel WordPress plugin in local mode — connect ' +
        'it to Consentinel Cloud (Settings > Bridge in the plugin) — or its Cloud ' +
        'bundle predates the version this tag needs — republish the site from ' +
        'the Consentinel dashboard.'
    );
  } else {
    fail(
      'not found on this page, or it loaded after Tag Manager. The Consentinel ' +
        'snippet must be the first synchronous script in <head>.'
    );
  }
} else if (typeof cloud.sdkVersion !== 'string') {
  // The object exists but predates the SDK change that added the API.
  fail(
    "this site's Consentinel bundle predates the version this tag needs. " +
      'Republish the site from the Consentinel dashboard.'
  );
} else if (cloud.consentMode === false) {
  fail(
    "Google Consent Mode signals are turned off in this site's Consentinel " +
      'settings (Customize > Behavior). Turn them on and republish, or remove ' +
      'this tag.'
  );
} else {
  // Google-issued CMP developer ID, set before any consent state so Google
  // attributes these signals to Consentinel. Deliberately inside the success
  // branch and NOT above the checks: A failure branch sets no consent state,
  // and claiming the signals on a page we did not manage would be a claim
  // without conduct behind it. The literal is pinned against the
  // write_data_layer permission's key pattern by gtm-template.spec.ts.
  gtagSet('developer_id.dNmU1ZT', true);

  const defaults = {};
  for (const key in DEFAULTS) defaults[key] = DEFAULTS[key];
  defaults.wait_for_update = WAIT_FOR_UPDATE_MS;
  setDefaultConsentState(defaults);

  // Returning visitor: Restore the stored choice as early as possible, from
  // the cookie, inside the sandbox — the guide's preferred path.
  const raw = getCookieValues(COOKIE_NAME);
  if (raw && raw.length > 0) {
    const parsed = JSON.parse(raw[0]);
    if (parsed && typeof parsed === 'object') updateConsentState(toConsentMode(parsed));
  }

  // In-page changes: The SDK calls this with the full state each time it
  // finishes applying one — after the blocker and the gtag update have run.
  callInWindow('ConsentinelCloud.onConsentApplied', (state) => {
    updateConsentState(toConsentMode(state));
  });

  data.gtmOnSuccess();
}


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "write_data_layer",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keyPatterns",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "developer_id.dNmU1ZT"
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
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "all"
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
        "publicId": "access_globals",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keys",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  { "type": 1, "string": "key" },
                  { "type": 1, "string": "read" },
                  { "type": 1, "string": "write" },
                  { "type": 1, "string": "execute" }
                ],
                "mapValue": [
                  { "type": 1, "string": "ConsentinelCloud" },
                  { "type": 8, "boolean": true },
                  { "type": 8, "boolean": false },
                  { "type": 8, "boolean": false }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  { "type": 1, "string": "key" },
                  { "type": 1, "string": "read" },
                  { "type": 1, "string": "write" },
                  { "type": 1, "string": "execute" }
                ],
                "mapValue": [
                  { "type": 1, "string": "ConsentinelCloud.onConsentApplied" },
                  { "type": 8, "boolean": false },
                  { "type": 8, "boolean": false },
                  { "type": 8, "boolean": true }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  { "type": 1, "string": "key" },
                  { "type": 1, "string": "read" },
                  { "type": 1, "string": "write" },
                  { "type": 1, "string": "execute" }
                ],
                "mapValue": [
                  { "type": 1, "string": "Consentinel" },
                  { "type": 8, "boolean": true },
                  { "type": 8, "boolean": false },
                  { "type": 8, "boolean": false }
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
        "publicId": "get_cookies",
        "versionId": "1"
      },
      "param": [
        {
          "key": "cookieAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "cookieNames",
          "value": {
            "type": 2,
            "listItem": [
              { "type": 1, "string": "consentinel_v1" }
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
        "publicId": "access_consent",
        "versionId": "1"
      },
      "param": [
        {
          "key": "consentTypes",
          "value": {
            "type": 2,
            "listItem": [
              { "type": 3, "mapKey": [ { "type": 1, "string": "consentType" }, { "type": 1, "string": "read" }, { "type": 1, "string": "write" } ], "mapValue": [ { "type": 1, "string": "ad_storage" }, { "type": 8, "boolean": false }, { "type": 8, "boolean": true } ] },
              { "type": 3, "mapKey": [ { "type": 1, "string": "consentType" }, { "type": 1, "string": "read" }, { "type": 1, "string": "write" } ], "mapValue": [ { "type": 1, "string": "analytics_storage" }, { "type": 8, "boolean": false }, { "type": 8, "boolean": true } ] },
              { "type": 3, "mapKey": [ { "type": 1, "string": "consentType" }, { "type": 1, "string": "read" }, { "type": 1, "string": "write" } ], "mapValue": [ { "type": 1, "string": "ad_user_data" }, { "type": 8, "boolean": false }, { "type": 8, "boolean": true } ] },
              { "type": 3, "mapKey": [ { "type": 1, "string": "consentType" }, { "type": 1, "string": "read" }, { "type": 1, "string": "write" } ], "mapValue": [ { "type": 1, "string": "ad_personalization" }, { "type": 8, "boolean": false }, { "type": 8, "boolean": true } ] },
              { "type": 3, "mapKey": [ { "type": 1, "string": "consentType" }, { "type": 1, "string": "read" }, { "type": 1, "string": "write" } ], "mapValue": [ { "type": 1, "string": "functionality_storage" }, { "type": 8, "boolean": false }, { "type": 8, "boolean": true } ] },
              { "type": 3, "mapKey": [ { "type": 1, "string": "consentType" }, { "type": 1, "string": "read" }, { "type": 1, "string": "write" } ], "mapValue": [ { "type": 1, "string": "personalization_storage" }, { "type": 8, "boolean": false }, { "type": 8, "boolean": true } ] },
              { "type": 3, "mapKey": [ { "type": 1, "string": "consentType" }, { "type": 1, "string": "read" }, { "type": 1, "string": "write" } ], "mapValue": [ { "type": 1, "string": "security_storage" }, { "type": 8, "boolean": false }, { "type": 8, "boolean": true } ] }
            ]
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

scenarios:
- name: not installed
  code: |-
    mock('copyFromWindow', function () { return undefined; });
    runCode();
    assertApi('gtmOnFailure').wasCalled();
    assertApi('gtmOnSuccess').wasNotCalled();
    assertApi('setDefaultConsentState').wasNotCalled();
- name: returning visitor
  code: |-
    mock('copyFromWindow', function (key) {
      return key === 'ConsentinelCloud' ? { sdkVersion: '0.1.0', consentMode: true } : undefined;
    });
    mock('getCookieValues', function () {
      return ['{"necessary":1,"analytics":1,"marketing":0,"functional":1,"social":0}'];
    });
    runCode();
    assertApi('setDefaultConsentState').wasCalledWith({
      ad_storage: 'denied', analytics_storage: 'denied', ad_user_data: 'denied',
      ad_personalization: 'denied', functionality_storage: 'denied',
      personalization_storage: 'denied', security_storage: 'granted', wait_for_update: 500
    });
    assertApi('updateConsentState').wasCalledWith({
      analytics_storage: 'granted', ad_storage: 'denied', ad_user_data: 'denied',
      ad_personalization: 'denied', functionality_storage: 'granted',
      personalization_storage: 'granted', security_storage: 'granted'
    });
    assertApi('gtmOnSuccess').wasCalled();
- name: first visit
  code: |-
    mock('copyFromWindow', function (key) {
      return key === 'ConsentinelCloud' ? { sdkVersion: '0.1.0', consentMode: true } : undefined;
    });
    mock('getCookieValues', function () { return []; });
    runCode();
    assertApi('setDefaultConsentState').wasCalled();
    assertApi('updateConsentState').wasNotCalled();
    assertApi('gtmOnSuccess').wasCalled();
- name: consent mode off
  code: |-
    mock('copyFromWindow', function (key) {
      return key === 'ConsentinelCloud' ? { sdkVersion: '0.1.0', consentMode: false } : undefined;
    });
    runCode();
    assertApi('gtmOnFailure').wasCalled();
    assertApi('setDefaultConsentState').wasNotCalled();


___NOTES___

Bridge only. Consentinel Cloud must already be installed as the first
synchronous script on the page; this tag never loads it. Fire on
"Consent Initialization - All Pages". Redaction, URL passthrough and the
Consent Mode switch are configured in Consentinel (Customize > Behavior),
not here. Source of truth and tests live in Consentinel's private monorepo;
this file is regenerated from it.

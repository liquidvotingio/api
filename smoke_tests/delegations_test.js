// k6 smoke test of api delegations actions

import http from 'k6/http';
import { check, group, sleep, fail } from 'k6';

export let options = {
  thresholds: {
    failedTestCases: [{ threshold: 'count==0' }], // add "abortOnFail: true" to exit immediately
    'checks': ['rate>0.99'] // the rate of successful checks should be higher than 99%
  },
  iterations: 1
};
var AUTH = __ENV.TEST_API_AUTH_KEY;
    console.log(`auth key env var: ${r}`);


const BASE_URL = 'https://api.liquidvoting.io';
const AUTH_KEY = AUTH // 'bc7eeccb-5e10-4004-8bfb-7fc68536bbd7';
const HEADERS = {
  "Authorization": `Bearer ${AUTH_KEY}`,
  "Content-Type": "application/json"
};

export default () => {
  group("Global delegations", () => {
    let DELEGATION_ID = "";

    const DELEGATE_EMAIL = "freddie@mercury.com";
    const DELEGATOR_EMAIL = "jane@austin.com";

    group("Create delegation with new participants (emails)", () => {
      const query = `
        mutation {
          createDelegation(delegateEmail: "${DELEGATE_EMAIL}", delegatorEmail: "${DELEGATOR_EMAIL}") {
            id
            delegate { email }
          }
        }`;

      const res = http.post(
        `${BASE_URL}`,
        JSON.stringify({ query: query }),
        { headers: HEADERS }
      );

      const body = JSON.parse(res.body);

      // includes check for delegate email to ensure test fails if cannot create delegate,
      // as otherwise test will throw an exception when trying to set DELGATION_ID,
      // with all checks (till here) passed.
      check(res, {
        "returns status 200": (r) => r.status === 200,
        "returns delegate email": () => body.data.createDelegation.delegate.email === DELEGATE_EMAIL
      });

      // Set DELEGATION_ID for next test
      if (res.status === 200) {
        const body = JSON.parse(res.body);
        DELEGATION_ID = body.data.createDelegation.id;
      }
    });

    group("Get delegation by id", () => {
      const query = `{
        delegation(id: "${DELEGATION_ID}") {
          id
          delegator { email } 
          delegate { email }
          proposalUrl
        }
      }`;

      const res = http.post(
        `${BASE_URL}`,
        JSON.stringify({ query: query }),
        { headers: HEADERS }
      );

      const body = JSON.parse(res.body);

      check(res, {
        "returns status 200": (r) => r.status === 200,
        "returns id": () => body.data.delegation.id === DELEGATION_ID,
        "proposalUrl is null": () => body.data.delegation.proposalUrl === null,
        "returns delegate email": () => body.data.delegation.delegate.email === DELEGATE_EMAIL,
        "returns delegator email": () => body.data.delegation.delegator.email === DELEGATOR_EMAIL
      });
    });
  });

  group("Proposal specific delegations", () => {
    let DELEGATION_ID = "";

    const PROPOSAL_URL = "http://someproposal.com/"
    const DELEGATE_EMAIL = "anne@frank.com";
    const DELEGATOR_EMAIL = "samuel@coleridge.com";

    group("Create delegation with new participants (emails)", () => {
      const query = `
        mutation {
          createDelegation(delegateEmail: "${DELEGATE_EMAIL}", delegatorEmail: "${DELEGATOR_EMAIL}", proposalUrl: "${PROPOSAL_URL}") {
            id
            delegate { email }
          }
        }`;

      const res = http.post(
        `${BASE_URL}`,
        JSON.stringify({ query: query }),
        { headers: HEADERS }
      );

      const body = JSON.parse(res.body);

      // includes check for delegate email to ensure test fails if cannot create delegate,
      // as otherwise test will throw an exception when trying to set DELGATION_ID,
      // with all checks (till here) passed.
      check(res, {
        "returns status 200": (r) => r.status === 200,
        "returns delegate email": () => body.data.createDelegation.delegate.email === DELEGATE_EMAIL
      });

      // Set DELEGATION_ID for next tests
      if (res.status === 200) {
        const body = JSON.parse(res.body);
        DELEGATION_ID = body.data.createDelegation.id;
      }
    });

    group("Get delegation by id", () => {
      const query = `{
        delegation(id: "${DELEGATION_ID}") {
          id
          delegator { email } 
          delegate { email }
          proposalUrl
        }
      }`;

      const res = http.post(
        `${BASE_URL}`,
        JSON.stringify({ query: query }),
        { headers: HEADERS }
      );

      const body = JSON.parse(res.body);

      check(res, {
        "returns status 200": (r) => r.status === 200,
        "returns id": () => body.data.delegation.id === DELEGATION_ID,
        "returns proposalUrl": () => body.data.delegation.proposalUrl === PROPOSAL_URL,
        "returns delegate email": () => body.data.delegation.delegate.email === DELEGATE_EMAIL,
        "returns delegator email": () => body.data.delegation.delegator.email === DELEGATOR_EMAIL
      });
    });

    group("List delegations after creating delegation", () => {
      const query = `{
        delegations {
          id
          delegator { email } 
          delegate { email }
          proposalUrl
        }
      }`;
  
      const res = http.post(
        `${BASE_URL}`,
        JSON.stringify({ query: query }),
        { headers: HEADERS }
      );
  
      const body = JSON.parse(res.body);
  
      let index = body.data.delegations.findIndex(x => x.id === DELEGATION_ID);
  
      check(res, {
        "returns status 200": (r) => r.status === 200,
        "returns id": () => body.data.delegations[index].id === DELEGATION_ID,
        "returns proposalUrl": () => body.data.delegations[index].proposalUrl === PROPOSAL_URL,
        "returns delegate email": () => body.data.delegations[index].delegate.email === DELEGATE_EMAIL,
        "returns delegator email": () => body.data.delegations[index].delegator.email === DELEGATOR_EMAIL
      });
    });

    group("Delete delegation", () => {
      const query = `
        mutation {
          deleteDelegation(delegatorEmail: "${DELEGATOR_EMAIL}", delegateEmail: "${DELEGATE_EMAIL}") {
            id
          }
        }`;
  
      const res = http.post(
        `${BASE_URL}`,
        JSON.stringify({ query: query }),
        { headers: HEADERS }
      );
  
      const body = JSON.parse(res.body);
  
      check(res, {
        "returns status 200": (r) => r.status === 200,
        "returns id": () => body.data.deleteDelegation.id === DELEGATION_ID
      });
    });

    group("List delegations after deleting delegation", () => {
      const query = `{
        delegations {
          id
        }
      }`;
  
      const res = http.post(
        `${BASE_URL}`,
        JSON.stringify({ query: query }),
        { headers: HEADERS }
      );
  
      const body = JSON.parse(res.body);
  
      check(res, {
        "returns status 200": (r) => r.status === 200,
        "does not return delegation id": () => typeof body.data.delegations.find(x => x.id === DELEGATION_ID) === 'undefined'
      });
    });
  });
};

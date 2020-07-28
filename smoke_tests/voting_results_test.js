// k6 smoke test of api voting_results actions

import http from 'k6/http';
import { check, group, sleep, fail } from 'k6';

export let options = {
  thresholds: {
    failedTestCases: [{ threshold: 'count==0' }], // add "abortOnFail: true" to exit immediately
    'checks': ['rate>0.99'] // the rate of successful checks should be higher than 99%
  },
  iterations: 1
};

const BASE_URL = 'https://api.liquidvoting.io';
const AUTH_KEY = 'bc7eeccb-5e10-4004-8bfb-7fc68536bbd7';
const HEADERS = {
  "Authorization": `Bearer ${AUTH_KEY}`,
  "Content-Type": "application/json"
};

export default () => {
  const PROPOSAL_URL = "https://proposals.com/2";
  const PARTICIPANT_EMAIL = "laura@gomail.com";
  const DELEGATOR_EMAIL = "cedric@gomail.com";
  const DELEGATE_EMAIL = "paula@gomail.com";

  group("Create vote with new participant email, proposal url and boolean 'yes' value", () => {
    const query = `
      mutation {
        createVote(participantEmail: "${PARTICIPANT_EMAIL}", proposalUrl: "${PROPOSAL_URL}", yes: true) {
          id
        }
      }`;

    const res = http.post(
      `${BASE_URL}`,
      JSON.stringify({ query: query }),
      { headers: HEADERS }
    );

    check(res, {
      "returns status 200": (r) => r.status === 200
    });
  });

  group("Create global delegation with new participants (emails)", () => {
    const query = `
      mutation {
        createDelegation(delegateEmail: "${DELEGATE_EMAIL}", delegatorEmail: "${DELEGATOR_EMAIL}") {
          id
        }
      }`;

    const res = http.post(
      `${BASE_URL}`,
      JSON.stringify({ query: query }),
      { headers: HEADERS }
    );

    check(res, {
      "returns status 200": (r) => r.status === 200
    });
  });

  group("Create delegate vote with email, proposal url and boolean 'yes' value", () => {
    const query = `
      mutation {
        createVote(participantEmail: "${DELEGATE_EMAIL}", proposalUrl: "${PROPOSAL_URL}", yes: false) {
          id
        }
      }`;

    const res = http.post(
      `${BASE_URL}`,
      JSON.stringify({ query: query }),
      { headers: HEADERS }
    );

    check(res, {
      "returns status 200": (r) => r.status === 200
    });
  });

  group("Get voting result", () => {
    const query = `
      query {
        votingResult(proposalUrl: "${PROPOSAL_URL}") {
          inFavor
          against
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
      "returns 1 vote in favor ": () => body.data.votingResult.inFavor === 1,
      "returns 2 votes against": () => body.data.votingResult.against === 2,
      "returns proposalUrl": () => body.data.votingResult.proposalUrl === PROPOSAL_URL
    });
  });
};

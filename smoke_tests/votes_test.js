// k6 smoke test of api votes actions

import http from 'k6/http';
import { check, group, sleep, fail } from 'k6';

export let options = {
  thresholds: {
    failedTestCases: [{ threshold: 'count==0' }], // add "abortOnFail: true" to exit immediately
    'checks': ['rate==1.0'] // the rate of successful checks should be 100%
  },
  iterations: 1
};

// const BASE_URL = 'http://localhost:4000/'; // url for for local test of dev api
const BASE_URL = 'https://api.liquidvoting.io'; // url for remote test of deployed api

// env var for remote test of deployed api || value for default UUID for local dev use
const AUTH_KEY = __ENV.TEST_API_AUTH_KEY || "cb7f2423-f47b-45c6-8c52-63f499744573";

const HEADERS = {
  // "Org-UUID": `${AUTH_KEY}`, // header for local test of dev api
  "Authorization": `Bearer ${AUTH_KEY}`, // header for remote test of deployed api
  "Content-Type": "application/json"
};

export default () => {
  let VOTE_ID = "";

  const PROPOSAL_URL = "https://proposals.com/1";
  const PARTICIPANT_EMAIL = "alice@gomail.com";
  const YES = true;


  group("Create vote with new participant email, proposal url and boolean 'yes' value", () => {
    const query = `
      mutation {
        createVote(participantEmail: "${PARTICIPANT_EMAIL}", proposalUrl: "${PROPOSAL_URL}", yes: ${YES}) {
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

    // Set VOTE_ID for next tests
    if (res.status === 200) {
      const body = JSON.parse(res.body);
      VOTE_ID = body.data.createVote.id
    }
  });

  group("Get vote by id", () => {
    const query = `{
      vote(id: "${VOTE_ID}") {
        id
        proposalUrl
        yes
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
      "returns id": () => body.data.vote.id === VOTE_ID,
      "returns proposalUrl": () => body.data.vote.proposalUrl === PROPOSAL_URL,
      "returns yes": () => body.data.vote.yes === YES
    });
  });

  group("List votes after creating vote", () => {
    const query = `{
      votes {
        id
        proposalUrl
        yes
      }
    }`;

    const res = http.post(
      `${BASE_URL}`,
      JSON.stringify({ query: query }),
      { headers: HEADERS }
    );

    const body = JSON.parse(res.body);

    let index = body.data.votes.findIndex(x => x.id === VOTE_ID);

    check(res, {
      "returns status 200": (r) => r.status === 200,
      "returns id": () => body.data.votes[index].id === VOTE_ID,
      "returns proposalUrl": () => body.data.votes[index].proposalUrl === PROPOSAL_URL,
      "returns yes": () => body.data.votes[index].yes === YES
    });
  });

  group("Delete vote", () => {
    const query = `
      mutation {
        deleteVote(participantEmail: "${PARTICIPANT_EMAIL}", proposalUrl: "${PROPOSAL_URL}") {
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
      "returns id": () => body.data.deleteVote.id === VOTE_ID
    });
  });

  group("List votes after deleting vote", () => {
    const query = `{
      votes {
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
      "does not return vote id": () => typeof body.data.votes.find(x => x.id === VOTE_ID) === 'undefined'
    });
  });
};

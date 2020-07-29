// k6 smoke test of api participants actions

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
  let PARTICIPANT_ID = "";

  const PARTICIPANT_EMAIL = "sue@gomail.com";
  const PARTICIPANT_NAME = "Sue Smith";

  group("Create participant with email and name", () => {
    const query = `
      mutation {
        createParticipant(email: "${PARTICIPANT_EMAIL}", name: "${PARTICIPANT_NAME}") {
          id
          email
        }
      }`;

    const res = http.post(
      `${BASE_URL}`,
      JSON.stringify({ query: query }),
      { headers: HEADERS }
    );

    const body = JSON.parse(res.body);

    // includes check for participant email to ensure test fails if cannot
    // create participant,as otherwise test will throw ann exception when
    // trying to set PARTICIPANT_ID, with all checks (till here) passed.
    check(res, {
      "returns status 200": (r) => r.status === 200,
      "returns email": () => body.data.createParticipant.email === PARTICIPANT_EMAIL
    });

    // Set PARTICIPANT_ID for next tests
    if (res.status === 200) {
      const body = JSON.parse(res.body);
      PARTICIPANT_ID = body.data.createParticipant.id;
    }
  });

  group("Get participant by id", () => {
    const query = `{
      participant(id: "${PARTICIPANT_ID}") {
        id
        email
        name
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
      "returns id": () => body.data.participant.id === PARTICIPANT_ID,
      "returns email": () => body.data.participant.email === PARTICIPANT_EMAIL,
      "returns name": () => body.data.participant.name === PARTICIPANT_NAME
    });
  });

  group("List participants", () => {
    const query = `{
      participants {
        id
        email
        name
      }
    }`;

    const res = http.post(
      `${BASE_URL}`,
      JSON.stringify({ query: query }),
      { headers: HEADERS }
    );

    const body = JSON.parse(res.body);

    let index = body.data.participants.findIndex(x => x.id === PARTICIPANT_ID);

    check(res, {
      "returns status 200": (r) => r.status === 200,
      "returns id": () => body.data.participants[index].id === PARTICIPANT_ID,
      "returns email": () => body.data.participants[index].email === PARTICIPANT_EMAIL,
      "returns name": () => body.data.participants[index].name === PARTICIPANT_NAME
    });
  });
};

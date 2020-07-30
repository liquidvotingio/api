// k6 smoke test of api delegations, partcipants, votes & voting_results actions

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

// env var for remote test of deployed api || default UUID  for local dev use
const AUTH_KEY = __ENV.TEST_API_AUTH_KEY || "cb7f2423-f47b-45c6-8c52-63f499744573";

const HEADERS = {
  // "Org-UUID": `${AUTH_KEY}`, // header for local test of dev api
  "Authorization": `Bearer ${AUTH_KEY}`, // header for remote test of deployed api
  "Content-Type": "application/json"
};

export default () => {
  group("Delegations", () => {
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
  });

  group("Participants", () => {
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
  });


  group("Votes", () => {
    let VOTE_ID = "";

    const PROPOSAL_URL = "https://proposals.com/1";
    const YES = true;
    const PARTICIPANT_EMAIL = "alice@gomail.com";

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
  });

  group("Voting Results", () => {
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
  });
};

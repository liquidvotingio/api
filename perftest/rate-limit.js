import { check } from "k6";
import http from "k6/http";

// To run this test:
//
// $ k6 run perftest/rate-limit.js

// Ingress rate limit (see k8s/ingress.yaml) is currently set at 2 per minute,
// and nginx has a hardcoded 5x burst tolerance.
//
// So here we expect 503 responses after ~10 requests, which
// we can watch through the nginx controller logs:
//
// $ kubectl logs my-nginx-ingress-controller-pod -f
//
// Test output expected on a fresh run is:
//
//  ...test progress output...
//
//   ✗ is status 200
//    ↳  91% — ✓ 11 / ✗ 1
//
//  ...stats...

export let options = {
  rps: 1,
  stages: [
    { duration: "12s", target: 1 }
  ]
};

export default function() {
  let url = "https://liquidvoting.io/api";
  let payload = `
    mutation {
      createVote(participantEmail: "test@email.com", proposalUrl: "http://blog.com/post", yes: false) {
        participant {
          email
        }
        proposalUrl
        yes
      }
    }
  `;
  let res = http.post(url, payload, {});

  check(res, {
    "is status 200": (r) => r.status === 200
  });
};

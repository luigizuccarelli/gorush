#!/bin/bash

# The api_key, token and url will change for your specific fcm app.
# This is only a quick example to test  gorush on openshift
for i in {1..1000}
do
  curl -H "Content-Type: application/json" -d '{
    "notifications": [{
      "title": "LMZ-TEST-UPS",
      "message": "Hello world this is golang ups push at its best",
      "platform": 2,
      "api_key": "AAAAr1dIEJI:APA91bHzmUoydw9Z9FiusKK2ll_JDMvpOzQw-dL9A8aVjB52W-2HV9JU_X3iW-zOQ6roay5tJrXoj16mIdVNtvowUXUKdUso3A6EM9wPg2zjw-Q906eUaam9AS1hgSafTY_DHyua9D-X",
      "tokens": ["cj51kkiUzFY:APA91bHHrpRWGGTnBye89K5QxUXgvfm2XHMiuGaUVb00xESwrS9vWxngrvuze5xX-Bz7eJ88fjC4ZaJDD_nS_jRJV56qB89m_5CtWImh2askemMEiqkdSUQQKZlPb_AA8NOM6fQdGvNr"]
    }]}' http://test-lmz-lmz-test.127.0.0.1.nip.io/api/push
done

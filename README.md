# gorush poc test in openshift

gorush is a push notification micro server using [Gin](https://github.com/gin-gonic/gin) framework written in Go (Golang).

[![Gorush](https://github.com/appleboy/gorush)](https://github.com/appleboy/gorush) 

## What
  This was a poc to check gorush interact within an openshift cluster and to do a gap analysis 

## Details
  I deployed ocp 3.5 locally on fedora 25

  Deployed the gorush container in a project (single pod)
  
  Dockerfile

  ```

    FROM appleboy/golang-testing:1.7.5
    ADD . /go/src/github.com/appleboy/gorush
    RUN cd /go/src/github.com/appleboy/gorush && make docker_build

    FROM centurylink/ca-certs
    EXPOSE 8088

    ADD config/config.yml /
    COPY --from=0 /go/src/github.com/appleboy/gorush/bin/gorush /

    ENTRYPOINT ["/gorush"]
    CMD ["-c", "config.yml"]

  ```

  Template to deploy on openshift

  ```

    {
    "kind": "Template",
    "apiVersion": "v1",
    "metadata": {
      "name": "lmz-ups",
      "annotations": {
        "description": "Configuration for go lang ups"
      }
    },
    "objects": [
       {
        "kind": "ConfigMap",
        "apiVersion": "v1",
        "metadata": {
          "name": "ups-config"
        },
        "data": {
           "test": "${TEST}"
        }
      },
      {
        "kind": "Service",
        "apiVersion": "v1",
        "metadata": {
          "name": "lmz-ups-service",
          "labels": {
            "name": "lmz-ups-service"
          }
        },
        "spec": {
          "ports": [
            {
              "port": 8088
            }
          ],
          "selector": {
            "name": "lmz-ups"
          }
        }
      },
      {
        "kind": "DeploymentConfig",
        "apiVersion": "v1",
        "metadata": {
          "name": "lmz-ups",
          "labels": {
            "name": "lmz-ups"
          }
        },
        "spec": {
          "strategy": {
            "type": "Rolling",
            "resources": {
              "limits": {
                "cpu": "800m",
                "memory": "800Mi"
              },
              "requests": {
                "cpu": "200m",
                "memory": "200Mi"
              }
            }
          },
          "triggers": [
            {
              "type": "ConfigChange"
            }
          ],
          "replicas": "1",
          "selector": {
            "name": "lmz-ups"
          },
          "template": {
            "metadata": {
              "labels": {
                "name": "lmz-ups"
              }
            },
            "spec": {
              "containers": [
                {
                  "name": "gorush-ups",
                  "image": "gorush:dev",
                  "ports": [
                    {
                      "containerPort": 8088
                    }
                  ],
                  "env": [
                    {
                      "name": "UPS_NAMESPACE",
                      "valueFrom": {
                        "fieldRef": {
                          "fieldPath": "metadata.namespace"
                        }
                      }
                    },
                    {
                      "name": "TEST_PARAM",
                      "value": "test"
                    },
                    {
                      "name": "TEST",
                      "valueFrom": {
                        "configMapKeyRef": {
                          "name": "ups-config",
                          "key": "test"
                        }
                      }
                    }
                  ],
                  "resources": {
                    "limits": {
                      "cpu": "800m",
                      "memory": "800Mi"
                    },
                    "requests": {
                      "cpu": "200m",
                      "memory": "200Mi"
                    }
                  },
                  "imagePullPolicy": "IfNotPresent"
                }
              ]
            }
          }
        }
      }
    ],
    "parameters": [
      {
        "name": "TEST",
        "value": "test",
        "description": "Test data"
      }
    ]
  }


  ```

  Created a simple firebase web-app to verify push notifcations locally (android only)

  ```firebase serve -p 8081)``` - see quickstart-js project
    
    ```
      // Initialize Firebase
      var config = {
        apiKey: "AIzaSyC2r44LDBcY_sQqFQWXd4VGa-bzvtOgSrs",
        authDomain: "lmz-test-3207e.firebaseapp.com",
        databaseURL: "https://lmz-test-3207e.firebaseio.com",
        projectId: "lmz-test-3207e",
        storageBucket: "lmz-test-3207e.appspot.com",
        messagingSenderId: "753083617426"
      };
      firebase.initializeApp(config);


    ```

  I ran a simple script to run +1000 push nofifications 
    
    ```
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

    ```
  
 
  Use the gorush api to check metrics memory/cpu and push info

## Results
  I took a couple of metric snapshots while the script was executing

  The memory footprint stayed constant - refer to the output json (results.json)

  CPU was also constant - refer to output json (results.json)

  All 1000 push notifications were sent and received with no errors (viewed in firebase web-app)


## Gaps
  No IOS push tests were executed only android
  
  No in depth concurrency was tested
  
  All tests were done locally - so scalability needs to be investigated
  
  No auth or security (keycloak etc) was used - needs ot be investigated
  
  No proxy testing
  
  Integration into existing projects investigating

## Conslusion
  With the poc I carried out I feel that gorush could be a very viable fit for future projects
  
  It's memory footprint is low 
  
  The poc was fairly easy to get up and running and worked without a hitch
  
  We need to do some further testing wrt scalability, security, reliability etc.

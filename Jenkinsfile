@Library('jenkins-ci-automation@master') _
BlibliPipeline([
  type: "java",
  test: [
          integration: [
              mongo: [
                  enabled : true,
                  version : '4.2',
                  username: 'mongo',
                  password: 'mongo'
              ],
              kafka: [
                  enabled: true,
                  version: '2.11-0.11.0.3'
              ]
          ]
      ]
])

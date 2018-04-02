pipeline {
  agent none
  options {
    timeout(time: 1, unit: 'HOURS')
    skipDefaultCheckout()
  }

  stages {
    stage("Build Ruby") {
      agent {
        node {
          label 'docker'
        }
      }

      steps {
        script {
          with_ruby_build() {
            script {
              uid = sh(returnStdout: true, script: 'stat -c %g .').trim()
              gid = sh(returnStdout: true, script: 'stat -c %u .').trim()
            }

            sh "chown -R ${uid}:${gid} vendor/bundle/"
            sh "rm -rf vendor/bundle/ruby/2.3.0/cache"
            stash name: 'ruby-bundle', includes: 'vendor/bundle/'
          }
        }
      }
    }

    stage("Test") {
      steps {
        script {
          node('docker') {
            checkout([
              $class: 'GitSCM',
              branches: scm.branches,
              doGenerateSubmoduleConfigurations: scm.doGenerateSubmoduleConfigurations,
              extensions: scm.extensions + [[$class: 'CloneOption', noTags: true, reference: '', shallow: true]],
              userRemoteConfigs: scm.userRemoteConfigs
            ])
            try {
              docker.image('ruby:2.3.3').inside() {
                sh 'rm -rf vendor/bundle'
                unstash 'ruby-bundle'
                sh 'bundle install --path=vendor/bundle'

                withEnv([
                  'DISABLE_SPRING=1',
                  'TZ=America/New_York'
                ]) {
                  sh 'bundle exec rake test'
                }
              }
            }
            finally {
              junit 'test/reports/'
              cleanWs()
            }
          }
        }
      }
    }
  }

  post {
    failure {
      script {
        if (env.BRANCH_NAME == 'master' || env.BRANCH_NAME == 'current') {
          slackSend (channel: '#plm_website', color: '#FF0000', message: "FAILED ${env.JOB_NAME} [${env.BUILD_NUMBER}] (${env.RUN_DISPLAY_URL})")
        }
      }
    }
  }
}

def with_ruby_build(closure) {
  docker.image('ruby:2.3.3').inside() {
    checkout([
      $class: 'GitSCM',
      branches: scm.branches,
      doGenerateSubmoduleConfigurations: scm.doGenerateSubmoduleConfigurations,
      extensions: scm.extensions + [[$class: 'CloneOption', noTags: true, reference: '', shallow: true]],
      userRemoteConfigs: scm.userRemoteConfigs
    ])
    sh 'rm -rf vendor/bundle'
    sh 'bundle install --path=vendor/bundle'
    closure()
    cleanWs()
  }
}

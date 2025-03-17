#!groovy

pipeline
{
  agent none

  parameters {
    booleanParam(defaultValue: false, description: 'Is the pull request approved for testing?', name: 'TRUST_BUILD')
  }

  stages {

    stage ("info")
    {
      steps
      {
        echo "PR: ${env.CHANGE_ID} - ${env.CHANGE_TITLE}"
        echo "CHANGE_AUTHOR_EMAIL: ${env.CHANGE_AUTHOR_EMAIL}"
        echo "building on node ${env.NODE_NAME}"
      }
    }

    stage ("Check permissions")
    {
      when {
        allOf {
            environment name: 'TRUST_BUILD', value: 'false'
            not {branch 'master'}
            not {changeRequest authorEmail: "timo.heister@gmail.com"}
	    }
      }
      steps {
          echo "Please ask an admin to rerun Jenkins with TRUST_BUILD=true"
            sh "exit 1"
      }
    }

    stage ("Ubuntu-20.04")
    {
      options {timeout(time: 600, unit: 'MINUTES')}
      agent
      {
        dockerfile
        {
          dir 'contrib/ubuntu2004'
        }
      }

      steps
      {
        sh '''#!/bin/bash
	set -e
	set -x
	mpicxx -v
	cmake --version
	# Ubuntu 20.04 only ships cmake 3.16 not 3.23:
	echo 'PACKAGES="once:cmake ${PACKAGES}"' > local.cfg
	rm -rf $WORKSPACE/install
        ./candi.sh -j 8 -p $WORKSPACE/install
        cp $WORKSPACE/install/tmp/build/deal.II-*/detailed.log detailed-ubuntu2004.log
        '''
	archiveArtifacts artifacts: 'detailed-ubuntu2004.log', fingerprint: true

        sh '''#!/bin/bash
        cd $WORKSPACE/install/tmp/build/deal.II-* && make test
        '''
      }
    }

    stage ("Ubuntu-24.04")
    {
      options {timeout(time: 600, unit: 'MINUTES')}
      agent
      {
        dockerfile
        {
          dir 'contrib/ubuntu2404'
        }
      }

      steps
      {
        sh '''#!/bin/bash
	set -e
	set -x
	mpicxx -v
	cmake --version
	rm -f local.cfg
	rm -rf $WORKSPACE/install/
        ./candi.sh -j 8 -p $WORKSPACE/install
        cp $WORKSPACE/install/tmp/build/deal.II-*/detailed.log detailed-ubuntu2404.log
        '''
	archiveArtifacts artifacts: 'detailed-ubuntu2404.log', fingerprint: true

        sh '''#!/bin/bash
        cd $WORKSPACE/install/tmp/build/deal.II-* && make test
        '''
      }
    }

    stage ("OSX-M1")
    {
      options {timeout(time: 600, unit: 'MINUTES')}
      agent
      {
         node
        {
          label 'osx'
        }
      }

      post { cleanup { cleanWs() } }

      steps
      {
        sh '''#!/bin/bash
	set -e
	set -x
        ./candi.sh -j 8 --packages="p4est petsc trilinos sundials dealii" -p $WORKSPACE
        cp $WORKSPACE/tmp/build/deal.II-*/detailed.log detailed-osx.log
        '''

	archiveArtifacts artifacts: 'detailed-osx.log', fingerprint: true

        sh '''#!/bin/bash
        cd $WORKSPACE/tmp/build/deal.II-* && ctest -j 4 --output-on-failure
        '''
      }
    }

  }
}

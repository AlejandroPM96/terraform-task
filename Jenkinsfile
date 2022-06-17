pipeline {
    agent any
    environment {
        SERVER_SCRIPT = credentials('JUMP_SCRIPT')
        GCLOUD_CREDS = credentials('GCLOUD_CREDS')
    }
    tools {
       terraform 'terraform'
    }
    stages {
        stage('Adding credentials') {
            steps{
                sh('echo -en ${SERVER_SCRIPT} > jump_script.sh')
                sh("echo displaying secret ${SERVER_SCRIPT.sh}")
                sh('echo -en  ${GCLOUD_CREDS} > terraform-project-352021-a4c9ee05f5a2.json')
                sh('ls')
            }
        }
        stage('terraform format check') {
            steps{
                sh('terraform fmt')
            }
        }
        stage('terraform Init') {
            steps{
                sh('terraform init')
            }
        }
        stage('terraform validate') {
            steps{
                sh('terraform validate')
            }
        }
        // stage('terraform apply') {
        //     steps{
        //         sh('terraform apply --auto-approve')
        //     }
        // }
    }
    post {
            always{
                archiveArtifacts artifacts: '*.tfstate', fingerprint: true
            }
    }
}
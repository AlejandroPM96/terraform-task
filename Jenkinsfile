pipeline {
    agent any
    environment {
        SERVER_SCRIPT = credentials('JUMP_SCRIPT')
        GCLOUD_CREDS = credentials('GCLOUD_CREDS')
        JUMP_SCRIPT_TEXT = credentials('jump_script_text')
    }
    tools {
       terraform 'terraform'
    }
    stages {
        stage('Adding credentials') {
            steps{
                // sh('echo -en ${SERVER_SCRIPT} > jump_script.sh')
                // sh("echo displaying secret ${SERVER_SCRIPT}")
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
        stage('terraform apply') {
            steps{
                sh('echo ${JUMP_SCRIPT_TEXT} > jump_script.sh')
                sh('terraform apply --auto-approve')
                sh('cat terraform.tfstate')
            }
        }
        stage('pushing state to bucket') {
            steps{
                withCredentials([file(credentialsId: 'GCLOUD_CREDS', variable: 'GC_KEY')]) {
                    sh("gcloud auth activate-service-account --key-file=${GC_KEY}")
                    sh("gsutil cp terraform.tfstate gs://tf-state-demo/")
            }
        }
    }
    post {
            always{
                archiveArtifacts artifacts: '*.tfstate', fingerprint: true
            }
    }
}
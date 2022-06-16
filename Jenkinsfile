pipeline {
    agent any
    tools {
       terraform 'terraform'
    }
    stages {
        stage('Adding credentials') {
            steps{
                sh('echo -en $JUMP_SCRIPT > jump_script.sh')
                sh('cd ..')
                sh('echo -en $GCLOUD_CREDS > terraform-project-352021-a4c9ee05f5a2.json')
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
        // stage('terraform apply') {
        //     steps{
        //         sh('terraform apply --auto-approve')
        //     }
        // }
    }
}
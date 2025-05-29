pipeline {
    agent any

    environment {
        TF_WORKING_DIR = "/home/nikola/terraform-project-1"
    }

    stages {
        stage('Init') {
            steps {
                dir("${TF_WORKING_DIR}") {
                    sh 'terraform init'
                }
            }
        }

        stage('Plan') {
            steps {
                dir("${TF_WORKING_DIR}") {
                    sh 'terraform plan'
                }
            }
        }

        stage('Apply') {
            steps {
                dir("${TF_WORKING_DIR}") {
                    sh 'terraform apply -auto-approve'
                }
            }
        }
    }
}

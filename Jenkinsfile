pipeline {
    agent any

    environment {
        TF_WORKING_DIR = "/home/nikola/terraform-project-1"
        ANSIBLE_DIR = "/home/nikola/ansible_project"
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
                    script {
                        def status = sh(script: 'terraform apply -auto-approve', returnStatus: true)
                        if (status != 0) {
                            echo "Terraform apply failed with exit code ${status}, but continuing..."
                        }
                    }
                }
            }
        }

        stage('Generate Ansible Variables') {
            steps {
                dir("${TF_WORKING_DIR}") {
                    script {
                        sh """
                            EFS_ID=\$(terraform output -raw efs_id)
                            echo "efs_id: \$EFS_ID" > ${ANSIBLE_DIR}/efs_vars.yml
                        """
                    }
                }
            }
        }
    }
}

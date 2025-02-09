pipeline {
    agent any

    environment {
        // Define environment variables
        TERRAFORM_VERSION = "1.5.7" // Specify the Terraform version
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID') // AWS credentials (if needed)
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY') // AWS credentials (if needed)
    }

    stages {
        stage('CLONE SCM') {
            steps {
                echo 'Cloning code from GitHub...'
                git branch: 'main', url: 'https://github.com/REVATHIPENMETSA/Automation-CI-CD.git'
            }
        }

        stage('Install Terraform') {
            steps {
                script {
                    // Install Terraform if not already installed
                    if (isUnix()) {
                        sh '''
                            if ! command -v terraform &> /dev/null; then
                                echo "Installing Terraform..."
                                curl -LO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
                                unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
                                sudo mv terraform /usr/local/bin/
                                rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip
                            else
                                echo "Terraform is already installed."
                            fi
                            terraform --version
                        '''
                    } else {
                        bat '''
                            if not exist terraform (
                                echo "Installing Terraform..."
                                curl -LO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_windows_amd64.zip
                                powershell -Command "Expand-Archive -Path terraform_${TERRAFORM_VERSION}_windows_amd64.zip -DestinationPath C:/terraform"
                                move C:/terraform/terraform.exe C:/Windows/System32
                                del terraform_${TERRAFORM_VERSION}_windows_amd64.zip
                            ) else (
                                echo "Terraform is already installed."
                            )
                            terraform --version
                        '''
                    }
                }
            }
        }

        stage('Terraform Init') {
            steps {
                // Initialize Terraform
                echo 'Initializing Terraform...'
                sh 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                // Run Terraform plan
                echo 'Running Terraform Plan...'
                sh 'terraform plan -out=tfplan'
            }
        }

        stage('Terraform Apply') {
            steps {
                // Apply Terraform changes
                echo 'Applying Terraform changes...'
                sh 'terraform apply -auto-approve tfplan'
            }
        }

        stage('Retrieve Public IP') {
            steps {
                script {
                    // Retrieve the public_ip output from Terraform
                    echo 'Retrieving Terraform Outputs...'
                    def publicIp = sh(script: 'terraform output -raw public_ip', returnStdout: true).trim()
                    echo "Public IP of the EC2 instance: ${publicIp}"
                }
            }
        }
    }

    post {
        success {
            echo 'Terraform deployment completed successfully!'
        }
        failure {
            echo 'Terraform deployment failed. Check the logs for details.'
        }
        always {
            // Clean up workspace
            cleanWs()
        }
    }
}

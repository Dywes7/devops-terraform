pipeline {
    agent any
    environment{
        TERRAFORM_DIR = '/var/lib/jenkins/terraform_state'
    }

    stages{

        stage('Build da imagem Docker'){
            steps{
                sh 'docker build -t vicio/app .'
            }
        } 

        stage('Upload da imagem no Registry Nexus'){
            steps{
                script{
                    withCredentials([usernamePassword(credentialsId: 'nexus-user', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]){
                        sh 'docker login -u $USERNAME -p $PASSWORD ${NEXUS_URL}'
                        sh 'docker tag vicio/app:latest ${NEXUS_URL}/vicio/app'
                        sh 'docker push ${NEXUS_URL}/vicio/app'
                    }
                }
            }
        }

        stage('Disparar intâncias e LoadBalancer via Terraform'){
            steps{
                sh 'cp -R terraform_openstack/* $TERRAFORM_DIR'

                dir("$TERRAFORM_DIR") {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Deploy via Playbook Ansible') {
            steps {                                  
                ansiblePlaybook credentialsId: 'JenkinsAnsible', disableHostKeyChecking: true, installation: 'Ansible', inventory: '/etc/ansible/hosts', playbook: './playbook-ansible.yaml', vaultTmpPath: ''
            }
        }


    }
}
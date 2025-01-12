pipeline {
    agent any
    environment{
        TERRAFORM_DIR = '/var/lib/jenkins/terraform_state'
        IMAGE_NAME = '192.168.159.207:8123/vicio/app:latest'
        LOCAL_IMAGE_NAME = 'vicio/app:latest'
    }

    stages{

        stage('Build da imagem Docker'){
            steps{
                sh 'docker build -t vicio/app .'
            }
        } 

        stage('Subir container de forma local para teste'){
            steps{
                // Alterar para a imagem local para realização do teste
                sh "sed -i 's|image: ${IMAGE_NAME}|image: ${LOCAL_IMAGE_NAME}|' docker-compose.yaml"

                // Subir ambiente de forma local
                sh "docker compose up -d"

                // Sleep para garantir subida do container
                sh "sleep 5"
            }
        }

        stage('Teste status code da requisição HTTP'){
            steps{
                sh 'chmod +x teste-app.sh'
                sh './teste-app.sh'
            }
        }

        stage('Shutdown do container de teste'){
            // Derrubar ambiente
            sh 'docker compose down'

            // Reverte a imagem para o registry original
            sh "sed -i 's|image: ${LOCAL_IMAGE_NAME}|image: ${IMAGE_NAME}|' docker-compose.yaml"
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
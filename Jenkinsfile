pipeline {
    agent any
    environment{
        TERRAFORM_DIR = '/var/lib/jenkins/terraform_state'
        // IMAGE_NAME = '192.168.159.207:8123/vicio/app'
        IMAGE_NAME = 'vicio/app'

        // Script para atribuir o valor da última TAG enviada no Git a variavel de ambiente TAG
        TAG = sh(script: 'git describe --abbrev=0',,returnStdout: true).trim()
        
    }

    stages{

        stage('Aplicar TAG no código da aplicação e docker-compose'){
            steps{
                  // Substituir texto TAG para varlor da variavel $TAG
                sh "sed -i -e 's#TAG#${TAG}#' ./app.py"
                sh "sed -i -e 's#TAG#${TAG}#' ./docker-compose.yaml"
                sh "sed -i -e 's#TAG#${TAG}#' ./down.sh"
            }
        }

        stage('Build da imagem Docker'){
            steps{
                sh 'docker build -t vicio/app:${TAG} .'
            }
        } 

        stage('Subir container de forma local para teste'){
            steps{
                // Alterar para a imagem local para realização do teste
                // sh "sed -i \"s|image: '${IMAGE_NAME}|image: '${LOCAL_IMAGE_NAME}|\" docker-compose.yaml"

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
            steps{
                // Derrubar ambiente
                sh 'docker compose down'
    
                // Adiciona URL externa na imagem puxada do docker-compose para acesso ao registry
                sh "sed -i \"s|image: '${IMAGE_NAME}|image: '${NEXUS_URL}/${IMAGE_NAME}|\" docker-compose.yaml"
            }
            
        }

        stage('Push da imagem no Registry Nexus'){
            steps{
                script{
                    withCredentials([usernamePassword(credentialsId: 'nexus-user', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]){
                        sh 'docker login -u $USERNAME -p $PASSWORD ${NEXUS_URL}'
                        sh 'docker tag vicio/app:${TAG} ${NEXUS_URL}/vicio/app:${TAG}'
                        sh 'docker push ${NEXUS_URL}/vicio/app:${TAG}'
                    }
                }
            }
        }

        stage('Disparar intâncias e LoadBalancer via Terraform'){
            steps{
                sh 'cp -R terraform_openstack/* $TERRAFORM_DIR'

                dir("$TERRAFORM_DIR") {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve -var-file="/var/lib/jenkins/cre_openstack/terraform.tfvars"'
                }
            }
        }

        stage('Sleep para subida das instâncias'){
            steps{
                sh 'sleep 60'
            }
        }

        stage('Deploy da aplicação via Playbook Ansible') {
            steps {                
                ansiblePlaybook credentialsId: 'JenkinsAnsible', disableHostKeyChecking: true, installation: 'Ansible', inventory: '/etc/ansible/hosts', playbook: './playbook-ansible.yaml', vaultTmpPath: ''
            }
        }

        stage('Capturar IP do Load Balancer') {
            steps {
                sh 'chmod +x ./extract_lb_ip.sh'

                script {
                    // Executar o script para capturar o IP do Load Balancer
                    def lb_url = sh(script: './extract_lb_ip.sh', returnStdout: true).trim()
                    echo "Load Balancer URL: ${lb_url}"

                    // Armazenar a URL no build do Jenkins
                    currentBuild.description = "LB URL: ${lb_url}"
                }
            }
        }
    }
}
pipeline {
    agent any
    environment{
        // Diretório fixado do terraform para guardar o estado da infraestrutura
        TERRAFORM_DIR = '/var/lib/jenkins/terraform_state'

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
    
                // Adiciona URL externa na imagem puxada do docker-compose para acesso ao registry pelas instancias
                sh "sed -i \"s|image: 'vicio/app|image: '${NEXUS_URL}/vicio/app|\" docker-compose.yaml"
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
                sh 'sleep 40'
            }
        }

        stage('Substiuir NEXUS_URL por valor da variavel no arquivo playbook ansible'){
            steps{
                sh "sed -i -e 's#NEXUS_URL#${NEXUS_URL}#' ./playbook-ansible.yaml"
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
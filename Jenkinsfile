pipeline {
    agent any
    stages{
        stage('Build da imagem Docker'){
            steps{
                sh 'docker build -t vicio/app .'
            }
        }   
    }
}
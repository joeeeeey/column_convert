pipeline {
    agent { docker { image 'ruby' } }
    stages {
        stage('build') {
            steps {
                sh 'ruby --version'
                sh 'bundle install'
                sh 'ruby tables/example.rb'
            }
        }
    }
}
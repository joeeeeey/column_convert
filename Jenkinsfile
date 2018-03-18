pipeline {
    agent { docker { image 'ruby' } }
    stages {
        stage('build') {
            steps {
                sh 'ruby --version'
                echo 'Building..'
                sh 'bundle install'
                echo 'Executing..'
                sh 'ruby tables/example.rb'
            }
        }
    }
}
pipeline {
    agent any

    parameters {
        string(
            name: 'TARGET',
            defaultValue: '192.9.100.108',
            description: 'Servidor Windows destino'
        )
    }

    stages {
        stage('Ejecutar PowerShell Remoto') {
            steps {
                sshagent(credentials: ['ssh-win']) {
                    sh """
                      ssh -o StrictHostKeyChecking=no usuario@${params.TARGET} \
                        "pwsh -NoProfile -File C:\\update.ps1"
                    """
                }
            }
        }
    }
}

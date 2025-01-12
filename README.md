Projeto CI/CD com Jenkins, Ansible, Docker, Nexus, e Terraform
Este projeto implementa um pipeline completo de integração e entrega contínuas (CI/CD) para uma aplicação web simples utilizando Jenkins, Ansible, Docker, Nexus Registry, e Terraform. O código fonte está hospedado no GitHub.

Pré-requisitos
Docker
Docker Compose
Ansible
Jenkins
Nexus Repository
Terraform
Acesso ao GitHub
Configuração
Clonar o repositório
Primeiro, clone o repositório do GitHub onde o código fonte e os scripts de infraestrutura estão armazenados.

bash
Copiar código
git clone [URL_DO_SEU_REPOSITORIO]
cd [NOME_DO_SEU_REPOSITORIO]
Configuração do ambiente
Utilize o Ansible para configurar o ambiente necessário para rodar a aplicação. O playbook do Ansible (playbook-ansible.yaml) executa as seguintes tarefas:

Prepara o ambiente derrubando containers existentes e limpando o diretório de trabalho.
Configura o diretório de trabalho e copia os arquivos necessários para construir os containers Docker.
Realiza login no Nexus Registry.
Inicia os containers utilizando Docker Compose.
Execute o playbook com o seguinte comando:

bash
Copiar código
ansible-playbook playbook-ansible.yaml -i hosts
Construção de containers
O arquivo Dockerfile define o container Docker para a aplicação. Utilize o Docker Compose para construir e subir o container definido no docker-compose.yaml.

bash
Copiar código
bash up.sh
Executando o projeto
Após configurar o ambiente e construir os containers, a aplicação estará rodando no endereço http://localhost:80. Acesse esta URL no navegador para ver a mensagem "Hello, DevOps! TAG".

Testando a aplicação
Utilize o script teste-app.sh para verificar se a aplicação está respondendo corretamente:

bash
Copiar código
bash teste-app.sh
Este script faz uma requisição GET para a aplicação e verifica se o código de status HTTP retornado é 200, indicando que a aplicação está funcionando corretamente.

Limpeza
Para parar e remover os containers, além de limpar imagens Docker não utilizadas, execute:

bash
Copiar código
bash down.sh
Este script garante que todos os recursos sejam limpos adequadamente.

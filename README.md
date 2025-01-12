# Projeto CI/CD com Jenkins, Ansible, Docker, Nexus, e Terraform

Este projeto implementa um pipeline completo de integração e entrega contínuas (CI/CD) para uma aplicação web simples utilizando **Jenkins**, **Ansible**, **Docker**, **Nexus Registry**, **Terraform**, **HAProxy**. O código fonte está hospedado no GitHub.

---

## **Pré-requisitos**

Certifique-se de ter as seguintes ferramentas instaladas em seu ambiente:

- **Docker**
- **Docker Compose**
- **Ansible**
- **Jenkins**
- **Nexus Repository**
- **Terraform**
- **HAProxy**
- **Acesso ao GitHub**

---

## **Configuração de Variáveis**

### **Jenkins**
1. Acesse o Jenkins:
   - Navegue até **Gerenciar Jenkins > System > Marcar ✔️ 'Variáveis de ambiente'**.

2. Preencha as informações da variável de ambiente:
   - **Nome**: `NEXUS_URL`  
   - **Valor**: `endereco_ip_nexus:numero_de_porta`

3. Crie o arquivo de credenciais para o Nexus:
   - Crie o arquivo em `/var/lib/jenkins/cre_openstack/secrets.yaml`.

4. Preencha o arquivo `secrets.yaml` com as seguintes linhas (substitua pelos valores reais das credenciais):

   ```yaml
   nexus_username: "user_nexus"
   nexus_password: "pass_nexus"

5. Crie o arquivo de credenciais para acesso ao provider Terraform (OpenStack):
   - Crie o arquivo em `/var/lib/jenkins/cre_openstack/terraform.tfvars`.

6. Preencha o arquivo `terraform.tfvars` com as seguintes linhas (substitua pelos valores reais das credenciais):

   ```yaml
   os_user = "user_openstack"
   os_password = "pass_user_openstack"
   

### **Terraform**
1. No arquivo `terraform_openstack/variables.tf` preencha os valores das variáveis de acordo o seu ambiente, com `fixed_ips` sendo relativo as duas instâncias.
   ```yaml
   variable "fixed_ips" {
     default = ["192.168.159.100", "192.168.159.101"]
   }

   variable "ip_loadbalancer" {
    default = "200.19.179.209"
   }

   variable "nexus_ip" {
    default = "192.168.159.207"
   }

---

## **Funcionamento do Pipeline**
### **Arquitetura**
1. Temos um Servidor Jenkins, integrado ao Terraform e Ansible.
   - Jenkins: Execução do pipeline
   - Terraform: Provisionar máquinas virtuais e HAProxy (load balancer)
   - Ansible: Disparar comando para as instâncias
  
### **Pipeline passo-a-passo**
1. Variáveis de ambiente (environment)
   - TERRAFORM_DIR: Fixar diretório a ser utilizado para guardar estado atual da infraestrutura do Terraform. OBS: Necessário criar este diretório manualmente no servidor Jenkins.
   - TAG: Buscar valor da última TAG enviada ao repositório remoto.
     
2. Estágio para aplicar valor de TAG mais recente nos arquivos app.py, docker-compose.yaml e script down.sh.

3. Estágio para build da imagem Docker no servidor local Jenkins, para realização de teste posteriormente.

4. Estágio para subir containers de forma local e realizar 'sleep' para garantir subida de containers antes da realização do próxio estágio.

5. Estágio para atribuição de permissão de execução no arquivo de teste-app.sh, bem como execução do script.
   - O script dispara uma requisição HTTP, aguardando reposta do status code.
   - Caso status code seja igual a 200, o pipeline prossegue.
   - Caso status code seja diferente de 200, o pipeline encerra.

6. Estágio para derrubar os containers no ambiente de teste (Servidor local Jenkins).
   - Também é realizado a substituição da URL no arquivo docker-compose.yaml para passar a pontar para o registry Nexus de forma externa. Isto é essencial para as instâncias se comunicarem com o Registry.

7. Estágio para realizar o Push da imagem docker para o registry.
   - Realização de login no registry.
   - Realização de 'tagueamento'.
   - Realização do push.
  
8. Estágio para disparar instâncias e LoadBalancer via Terraform.
   - Copiar todo conteúdo do diretório `terraform_openstack` para o diretório fixado do terraform `$TERRAFORM_DIR`.
   - Executar terraform init e terraform apply, passando como parâmetro o arquivo de variáveis `terraform.tfvars`. 

9. Estágio de sleep para garantir subida das instâncias antes da execução da playbook Ansible.

10. Substituição de string NEXUS_UR por valor da variável NEXUS_URL no arquivo playbook Ansible.

11. Excução de deploy dos containers via playbook Ansible para acessar as intâncias de produção.
    - Inicialmente é executado um script para derrubar o ambiente existente (caso já exista), com o script `down.sh` que resumidamente irá realizar o `docker compose down` e excluir a imagem antiga (caso exista).
    - É deletado e criado o diretório `/app`, para garantir que os arquivos antigos sejam eliminados e substituidos pelos novos do repositório.
    - Copia arquivos clonados do repositório para as instâncias.
    - Garante a execução de scripts .sh.
    - Realiza login no registry Nexus.
    - Executa script `up.sh`, que basicamente faz o `docker compose up -d` para subir o novo ambiente.

### **Clonar o repositório**

Primeiro, clone o repositório do GitHub onde o código fonte e os scripts de infraestrutura estão armazenados:

```bash
git clone [URL_DO_SEU_REPOSITORIO]
cd [NOME_DO_SEU_REPOSITORIO]


---

### **Configuração do ambiente**

Utilize o **Ansible** para configurar o ambiente necessário para rodar a aplicação. O playbook `playbook-ansible.yaml` executa as seguintes tarefas:

1. Prepara o ambiente derrubando containers existentes e limpando o diretório de trabalho.
2. Configura o diretório de trabalho e copia os arquivos necessários para construir os containers Docker.
3. Realiza login no Nexus Registry.
4. Inicia os containers utilizando Docker Compose.

Execute o playbook com o seguinte comando:

```bash
ansible-playbook playbook-ansible.yaml -i hosts
```

---

## **Construção de containers**

O arquivo `Dockerfile` define o container Docker para a aplicação. Utilize o **Docker Compose** para construir e subir o container definido no `docker-compose.yaml`:

```bash
bash up.sh
```

---

## **Executando o projeto**

Após configurar o ambiente e construir os containers, a aplicação estará disponível no endereço:

[http://localhost:80](http://localhost:80)

Acesse esta URL no navegador para ver a mensagem:  

**"Hello, DevOps! TAG"**

---

## **Testando a aplicação**

Utilize o script `teste-app.sh` para verificar se a aplicação está respondendo corretamente:

```bash
bash teste-app.sh
```

Este script faz uma requisição **GET** para a aplicação e verifica se o código de status HTTP retornado é **200**, indicando que a aplicação está funcionando corretamente.

---

## **Limpeza**

Para parar e remover os containers, além de limpar imagens Docker não utilizadas, execute:

```bash
bash down.sh
```

Este script garante que todos os recursos sejam limpos adequadamente.

---

## **Licença**

Este projeto está licenciado sob a [MIT License](LICENSE).  
Sinta-se à vontade para contribuir e adaptar este projeto conforme necessário!


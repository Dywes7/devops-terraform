# Projeto CI/CD com Jenkins, Ansible, Docker, Nexus, Terraform e HAProxy

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

3. Ainda no Jenkins:
   - Navegue até **Gerenciar Jenkins > Credentials > System > Global credentials > + Add Credentials**.

4. Preencha as informações das credenciais para acesso ao Nexus e clique em `Save`:
   - **Scope**: `Global (Jenkins, nodes, items, all child items, etc)`  
   - **Username**: `user_nexus`
   - **Password**: `pass_nexus`
   - **ID**: `nexus-user`

5. Ainda no Jenkins em **Global credentials > + Add Credentials**, adicione novas credenciais para integração com Ansible:
   - **Scope**: `Global (Jenkins, nodes, items, all child items, etc)`  
   - **Username**: `Insira o usuário de sistema operacional a ser conectado nas instâncias`
   - **ID**: `JenkinsAnsible`
   - **PrivateKey**: `Insira a chave SSH privada utilizada pelo usuário Jenkins para acesso as intâncias`

6. Crie o arquivo de credenciais para o Nexus:
   - Crie o arquivo em `/var/lib/jenkins/cre_openstack/secrets.yaml`.

7. Preencha o arquivo `secrets.yaml` com as seguintes linhas (substitua pelos valores reais das credenciais):

   ```yaml
   nexus_username: "user_nexus"
   nexus_password: "pass_nexus"

8. Crie o arquivo de credenciais para acesso ao provider Terraform (OpenStack):
   - Crie o arquivo em `/var/lib/jenkins/cre_openstack/terraform.tfvars`.

9. Preencha o arquivo `terraform.tfvars` com as seguintes linhas (substitua pelos valores reais das credenciais):

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
1. Temos um Servidor Jenkins, integrado ao Terraform, Ansible e Nexus.
   - Jenkins: Execução do pipeline
   - Terraform: Provisionar máquinas virtuais e HAProxy (load balancer)
   - Ansible: Disparar comandos para as instâncias subir os containers via docker compose.
   - Nexus: Registry Docker para repositório de imagens.
  
### **Arquivos do repositório**
1. `Jenkinsfile`: Arquivo que descreve as etapas do pipeline.
2. `Dockerfile`: Arquivo com imagem simples para execução de código python.
3. `docker-compose.yaml`: Arquivo para subida do container, com imagem correspondente e relação de portas.
4. `app.py`: Código para aplicação web simples em python que imprime a mensagem "Hello, DevOps! {TAG}", onde {TAG} será a última versão da aplicação.
5. `playbook-ansible.yaml`: Arquivo ansible-playbook que realiza o reinício dos containers para garantir a subida com a versão de imagem mais recente.
6. `terraform_openstack`: Diretório com arquivos terraform.
   - `main.tf`: Arquivo terraform para provisionamento das instâncias na nuvem OpenStack.
   - `haproxy.tf`: Arquivo terraform para provisionamento do balanceador de carga HAProxy.
   - `variables.tf`: Arquivo de variáveis terraform para definição dos endereços IPv4 das intâncias, loadbalancer e nexus.
7. `scripts .sh`: Arquivos com entensão .sh para execução em bash linux.
   - `down.sh`: Script que derruba os containers existentes e deleta a imagem docker antiga, caso exista.
   - `up.sh`: Script que sobe os containers.
   - `teste-app.sh`: Script que dispara requisição HTTP e valída o status code.
   - `extract_lb_ip.sh`: Script que busca o endereço do balanceador de carga.
     
  
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
   - Realização de 'tagueamento' na imagem.
   - Realização do push da imagem para o registry.
  
8. Estágio para disparar instâncias e LoadBalancer via Terraform.
   - Cópia de todo conteúdo do diretório `terraform_openstack` para o diretório fixado do terraform `$TERRAFORM_DIR`.
   - Execução de `terraform init` e `terraform apply`, passando como parâmetro o arquivo de variáveis `terraform.tfvars`. 

9. Estágio de sleep para garantir subida das instâncias antes da execução da playbook Ansible.

10. Substituição de string NEXUS_URL por valor da variável `NEXUS_URL` no arquivo playbook Ansible.

11. Execução de deploy dos containers nas instâncias via playbook Ansible **COM LÓGICA QUE GARANTE QUE A NOVA VERSÃO ENTRE NO AR**. OBS: Necessário instalação do plugin `Ansible plugin` no Jenkins.  
    - Inicialmente é executado um script para derrubar o ambiente existente (caso já exista), com o script `down.sh` que resumidamente irá realizar o `docker compose down` e excluir a imagem antiga (caso exista).
    - É deletado e criado o diretório `/app`, para garantir que os arquivos antigos sejam eliminados e substituidos pelos novos do repositório.
    - Cópia de arquivos clonados do repositório para as instâncias.
    - Atribuição de permissão de execução dos scripts `.sh`.
    - Realização login no registry Nexus.
    - Execução de script `up.sh`, que basicamente faz o `docker compose up -d` para subir o novo ambiente.

12. Estágio para capturar IP do LoadBalancer.
    - Atribuição de permissão de execução ao script que busca o endereço do LoadBalancer.
    - Execução de script para buscar a URL pública do LoadBalancer HAProxy.
    - Exibição da URL pública ao final do pipeline.


---


## **Execução do projeto**

Após configurar o ambiente e construir os containers, a aplicação estará disponível no endereço:

http://IP_LOADBANCER:80

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


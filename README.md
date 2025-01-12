# Projeto CI/CD com Jenkins, Ansible, Docker, Nexus, e Terraform

Este projeto implementa um pipeline completo de integração e entrega contínuas (CI/CD) para uma aplicação web simples utilizando **Jenkins**, **Ansible**, **Docker**, **Nexus Registry** e **Terraform**. O código fonte está hospedado no GitHub.

---

## **Pré-requisitos**

Certifique-se de ter as seguintes ferramentas instaladas em seu ambiente:

- **Docker**
- **Docker Compose**
- **Ansible**
- **Jenkins**
- **Nexus Repository**
- **Terraform**
- **Acesso ao GitHub**

---

## **Configuração de variáveis**
### **Jenkins**
 - Gerenciar Jenkins > System > Marcar✔️ 'Variáveis de ambiente'.

 Prencher informações da variável:

 1. nome: NEXUS_URL
 2. valor: enedereco_ip_nexus:numero_de_porta


- Criar arquivo /var/lib/jenkins/cre_openstack/secrets.yaml

 Preencher com as seguintes linhas no arquivo inserindo as credencias para acesso ao nexus:
 ```bash
 nexus_username: "user_nexus"
 nexus_password: "pass_nexus"
 ```

   

### **Clonar o repositório**

Primeiro, clone o repositório do GitHub onde o código fonte e os scripts de infraestrutura estão armazenados:

```bash
git clone [URL_DO_SEU_REPOSITORIO]
cd [NOME_DO_SEU_REPOSITORIO]
```

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


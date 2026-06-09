# 🔐 Guia de Autenticação - Edutrack-ai

## 📋 Como o Sistema de Autenticação Funciona

### 1️⃣ **Tela de Login/Registro** (Primeira Tela)

Quando você acessa a aplicação, a primeira coisa que vê é a tela de autenticação com duas opções:

- **🔐 Login**: Para usuários existentes
- **📝 Registrar**: Para criar uma nova conta

### 2️⃣ **Fazendo Login**

1. Clique no botão "🔐 Login"
2. Preencha seu **E-mail** e **Senha**
3. Clique em "Entrar"
4. Se as credenciais forem válidas, você será redirecionado para o **Dashboard**

**Credenciais de Teste:**
- E-mail: `estudante@edutrack.com`
- Senha: `123456`

### 3️⃣ **Criando uma Conta**

1. Clique no botão "📝 Registrar"
2. Preencha:
   - **Nome Completo**: Seu nome completo
   - **E-mail**: Um e-mail único
   - **Senha**: Mínimo 6 caracteres
   - **Confirmar Senha**: Repetir a senha
3. Clique em "Registrar"
4. Se tudo for bem, você será automaticamente logado!

### 4️⃣ **Navegação Protegida**

Após fazer login, você terá acesso a:

- **🏠 Dashboard**: Visão geral com métricas
- **📚 Disciplinas**: Gerenciar suas disciplinas (CRUD)
- **📝 Tarefas**: Espaço reservado para tarefas
- **👤 Perfil**: Ver seus dados pessoais

### 5️⃣ **Fazendo Logout**

No menu lateral, clique no botão **🚪 Sair (Logout)** para:
- Limpar seu token de autenticação
- Voltar para a tela de login

---

## 🛡️ Segurança

### ✅ Recursos de Segurança

- **Autenticação Obrigatória**: Você não pode acessar as páginas sem fazer login
- **Token Bearer**: Todas as requisições usam token de autenticação
- **Validação de Senha**: Mínimo 6 caracteres, confirmação obrigatória
- **Session State**: Token armazenado apenas na memória da sessão (não em arquivos)
- **Logout Seguro**: Limpa completamente a sessão

---

## 📱 Endpoints Utilizados

| Endpoint | Método | Descrição |
|----------|--------|-----------|
| `/auth/login` | POST | Autentica usuário |
| `/auth/signup` | POST | Registra novo usuário |
| `/auth/me` | GET | Obtém dados do perfil |

---

## 🔧 Variáveis de Sessão

A aplicação usa as seguintes variáveis armazenadas em `st.session_state`:

```python
st.session_state.auth_token    # Token de autenticação
st.session_state.user_data     # Dados do usuário logado
st.session_state.auth_mode     # "login" ou "register"
st.session_state.editing_subject  # Disciplina em edição
```

---

## ⚠️ Troubleshooting

### "Credenciais inválidas"
- Verifique se o e-mail e senha estão corretos
- O e-mail deve estar registrado no Xano

### "Token inválido"
- Faça logout e login novamente
- Verifique se o token expirou

### "Página protegida"
- Você não está logado
- Clique em Login ou Registre uma nova conta

---

## 📚 Próximas Melhorias

- [ ] Recuperação de senha por e-mail
- [ ] Autenticação por Google/GitHub
- [ ] Two-factor authentication (2FA)
- [ ] Atualização de dados do perfil
- [ ] Histórico de atividades

---

**Versão**: Edutrack-ai v2.0  
**Data**: junho 2026  
**Status**: ✅ Implementado

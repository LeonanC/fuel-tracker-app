## 📈 Roadmap
- [x] Migração para Supabase.
- [x] Lógica de consumo por trecho (hidrômetro).
- [ ] Implementação de dashboard com gráficos de gastos mensais.
- [ ] Sistema de lembrete para manutenção (troca de óleo e filtros).

---
Criado por **Leonan Carvalho** – [LinkedIn](https://www.linkedin.com/in/leonanc/) | [GitHub](https://github.com/LeonanC)

---

### Por que esta versão é melhor?
1.  **Contexto Real:** Menciona o foco no "consumo por trecho", que é um diferencial que você valoriza.
2.  **Profissionalismo:** O link para seu LinkedIn e a organização da estrutura de pastas mostram que você é um desenvolvedor que se preocupa com a arquitetura do código.
3.  **Identidade:** RemoveCom certeza, Leonan. Para deixar o `README.md` com a sua cara, adicionei detalhes que refletem seu perfil de desenvolvedor, o propósito real do projeto e um toque mais profissional para o seu portfólio no GitHub.

Aqui está a versão personalizada:

---

# 📊 Fuel Tracker App

Bem-vindo ao **Fuel Tracker**, um projeto pessoal focado em resolver um problema prático: o controle preciso de consumo de combustível. Desenvolvido com **Flutter**, este app é a evolução de uma ferramenta de gestão logística, agora otimizada para monitorar a eficiência veicular de forma simples e eficaz.

## 📱 Sobre o Projeto
O Fuel Tracker nasceu da necessidade de acompanhar o desempenho real de veículos (como o **Honda City**) no dia a dia. Ele permite que o motorista registre cada abastecimento e obtenha instantaneamente o cálculo de consumo por trecho, indo além do que o hodômetro total mostra.

Este projeto faz parte do meu ecossistema de soluções de logística e mobilidade, focando em arquitetura limpa e integração escalável com o **Supabase**.

## 🛠️ Stack Tecnológica
*   **Frontend:** Flutter (Dart)
*   **Backend & Auth:** [Supabase](https://supabase.com/) (PostgreSQL)
*   **Arquitetura:** Clean Architecture / Gerenciamento de estado reativo.

## ✨ Funcionalidades
*   **Cálculo de Consumo Real:** Foco no consumo atual por trecho percorrido.
*   **Gestão via Supabase:** Autenticação segura e armazenamento de dados em nuvem.
*   **Multi-Veículo:** Pronto para gerenciar diferentes perfis de veículos.
*   **Interface Intuitiva:** UI desenhada para facilitar o uso rápido em postos de combustível.

## 🏗️ Estrutura de Pastas
```text
lib/
├── core/          # Lógica compartilhada e utilitários
├── data/          # Repositórios e fontes de dados (Supabase)
├── domain/        # Entidades e Casos de Uso
└── presentation/  # Telas (UI) e Gerenciamento de Estado
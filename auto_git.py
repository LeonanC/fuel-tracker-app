import subprocess
import sys
import os

def rodar_git_automatico():
    # Se você passou uma pasta, ele usa ela. Se não, usa a pasta atual (.)
    pasta_projeto = sys.argv[1] if len(sys.argv) > 1 else "."
    
    # Verifica se a mensagem de commit foi passada como segundo argumento
    mensagem_commit = sys.argv[2] if len(sys.argv) > 2 else "Atualizando"
    
    try:
        # Muda o "foco" do Python para a pasta do projeto
        os.chdir(pasta_projeto)
        print(f"📂 Entrando na pasta: {os.getcwd()}")
        
        # 1. Adiciona arquivos
        print("📁 Adicionando arquivos (git add .)...")
        subprocess.run(["git", "add", "."], check=True)
        
        # 2. Commit
        print(f"💬 Criando commit: '{mensagem_commit}'...")
        subprocess.run(["git", "commit", "-m", mensagem_commit], check=True)
        
        # 3. Push
        print("🚀 Enviando para o GitHub (git push origin main)...")
        subprocess.run(["git", "push", "origin", "main"], check=True)
        
        print("✅ Tudo atualizado com sucesso!")
        
    except FileNotFoundError:
        print(f"❌ Erro: A pasta '{pasta_projeto}' não foi encontrada.")
    except subprocess.CalledProcessError as e:
        print(f"❌ Erro ao executar comando do Git: {e}")

if __name__ == "__main__":
    rodar_git_automatico()

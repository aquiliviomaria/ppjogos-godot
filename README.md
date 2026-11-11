# Programação para Jogos 3D — Godot

Duas demonstrações académicas independentes. Textos e comentários em português. Sem plugins e sem recursos externos obrigatórios. Os ícones SVG são fornecidos em cada projeto.

- **01-interatividade-3d — Tema 4.8:** humano articulado, movimento, zoom, cor por proximidade, textura gerada e roupa com Tween.
- **02-performance-3d — Tema 4.9:** o mesmo humano e câmara; comparação entre cubos individuais e MultiMesh; indicadores e seis medições.

## 📦 Requisitos

Godot **4.5.1** foi detetado e usado na validação. Identificação completa: `4.5.1.stable.fedora.f62fdbde1`. Os projetos usam GDScript tipado e o renderer **GL Compatibility**. Outras versões não foram testadas.

## ▶️ Abrir e executar

1. Abra o gestor de projetos do Godot.
2. Escolha **Importar**.
3. Selecione `project.godot` dentro de um dos projetos.
4. Abra o projeto.
5. Prima **F5**.
6. Clique na janela do jogo para receber as teclas.

Comandos neste computador:

```bash
# Interatividade
godot --path "/run/media/aquilivio/aquilivio/Lab/ppjogos-godot/01-interatividade-3d"

# Performance
godot --path "/run/media/aquilivio/aquilivio/Lab/ppjogos-godot/02-performance-3d"
```

Acrescente `--editor` para abrir no editor. Cada projeto tem o seu README com controlos, roteiro e problemas comuns.

## 🎮 Escolha dos controlos

No projeto 1, use WASD ou setas. No projeto 2, **S alterna sombras**, conforme a preferência escolhida. Use **W/A/D e setas** para mover; **seta para baixo** para recuar.

## 🧱 Organização

Cada `main.tscn` contém apenas `Main: Node3D` com o script anexado. `_ready()` cria a hierarquia por código. `avatar.gd` e `camera_zoom.gd` são idênticos nos dois projetos; os limites são configurados por cada `main.gd`. Cada linha de lógica dos scripts tem um comentário curto em português.

Os nomes dos 13 ícones por projeto são `tecla.svg`, `cor.svg`, `textura.svg`, `repor.svg`, `zoom.svg`, `fps.svg`, `relogio.svg`, `caixa.svg`, `camadas.svg`, `sol.svg`, `avatar.svg` `medicao.svg` e `orbita.svg`. São vetores locais de 24 × 24, traço branco e fundo transparente. O HUD usa TextureRect; não contém emojis. A pasta `texturas/` do projeto 1 aceita um `textura.png` opcional.

## ✅ Validação

Consulte `VALIDACAO.md`. Os resultados gráficos recolhidos durante testes funcionais não constituem um benchmark. A comparação exata com o conteúdo de `ppjogos.pptx` não foi feita; a implementação segue os requisitos escritos nesta tarefa.

## 📚 API de referência

- [Image — Godot 4.5](https://docs.godotengine.org/en/4.5/classes/class_image.html)
- [Camera3D — Godot 4.5](https://docs.godotengine.org/en/4.5/classes/class_camera3d.html)
- [MultiMesh — Godot 4.5](https://docs.godotengine.org/en/4.5/classes/class_multimesh.html)

## 🖱️ Rodar a vista

Nos dois projetos, mantenha o botão direito premido e arraste o rato. Solte-o ou prima Esc para libertar o cursor. A roda faz zoom. O movimento acompanha a orientação da vista. O avatar inclui rosto e cabelo modelados por código; o ambiente inclui quadrícula, iluminação suave e painéis com contorno.

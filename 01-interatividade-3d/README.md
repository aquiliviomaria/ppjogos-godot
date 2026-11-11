# Tema 4.8 — Interatividade 3D

## 1. 📦 Requisitos

Godot **4.5.1**, versão instalada e validada. Renderer **GL Compatibility**. Sem plugins. Ícones SVG incluídos. Xadrez gerado por código.

## 2. ▶️ Como abrir e executar

1. Abra o gestor de projetos do Godot.
2. Escolha **Importar**.
3. Selecione o `project.godot` desta pasta.
4. Abra o projeto.
5. Prima **F5**.
6. Clique na janela do jogo.

No terminal:

```bash
godot --path "/run/media/aquilivio/aquilivio/Lab/ppjogos-godot/01-interatividade-3d"
```

## 3. 🎮 Controlos

| Tecla | Ação |
| --- | --- |
| W / seta para cima | Avançar |
| S / seta para baixo | Recuar |
| A / seta para a esquerda | Mover à esquerda |
| D / seta para a direita | Mover à direita |
| E | Mudar a cor do cubo, a menos de 3 metros |
| T | Alternar cor simples e textura |
| C | Mudar a cor da roupa |
| R | Repor avatar, cubo e câmara |
| Botão direito + arrastar | Rodar a câmara em torno do avatar |
| Esc | Libertar o cursor |
| Roda para cima / + / + numérico | Aproximar |
| Roda para baixo / - / - numérico | Afastar |

O zoom varia entre **3 e 15 metros**. A tecla `=` também aproxima, para facilitar teclados com `+` na mesma tecla. A rotação do avatar segue a direção do movimento. O movimento acompanha a orientação horizontal da câmara.

A distância de interação é medida entre a origem do avatar nos pés e o centro do cubo. A condição é estritamente `< 3`. A cor do material modula a textura. Pode criar `texturas/textura.png`; sem essa imagem é gerado um xadrez de 64 × 64. O HUD mostra a cor de destino durante o Tween de 0,3 s.

## 4. 🧭 Roteiro de demonstração — cerca de 5 minutos

1. **0:00–0:30 — Execute o projeto.** Diga: “Tudo o que vemos foi construído por código.”
2. **0:30–1:00 — Abra Cena → Remoto.** Diga: “Os pivôs dos ombros e ancas organizam o humano.”
3. **1:00–1:30 — Mova o avatar com D.** Diga: “O avatar roda para a direção escolhida e os membros balançam em oposição.”
4. **1:30–2:00 — Solte as teclas.** Diga: “Parado, regressa à pose neutra e mantém uma respiração leve.”
5. **2:00–2:30 — Prima E perto do cubo.** Diga: “Entrada, lógica de proximidade, Tween do material e resultado visível.”
6. **2:30–3:00 — Prima T.** Diga: “Esta textura é um xadrez gerado pixel a pixel, sem imagem externa.”
7. **3:00–3:30 — Prima C.** Diga: “Uma função muda a roupa nas cinco peças durante 0,3 segundos.”
8. **3:30–4:00 — Rode a roda do rato.** Diga: “O zoom tem limites e interpolação suave.”
9. **4:00–4:30 — Afaste o avatar do cubo.** Diga: “A posição do jogador faz parte da lógica da interação.”
10. **4:30–4:45 — Prima E.** Diga: “Fora do alcance, o HUD pede para nos aproximarmos.”
11. **4:45–5:00 — Prima R.** Diga: “A reposição cancela os Tweens e recupera o estado original.”

## 5. 🧱 Como a cena é construída

Nós: `Main`; `Chao: MeshInstance3D`; `Luz: DirectionalLight3D`; `CeuEAmbiente: WorldEnvironment`; `Avatar: Node3D`; `Corpo`; cabeça e tronco; quatro pivôs com membros; `CuboInterativo: MeshInstance3D`; `CamaraZoom: Camera3D`; `HUD: CanvasLayer`; painéis, filas, TextureRect e Label.

- `main.gd` — Cria o mundo e trata E, T, C e R.
- `avatar.gd` — Cria o humano, lê movimento, anima os pivôs e muda a roupa.
- `camera_zoom.gd` — Segue o avatar e suaviza o zoom.
- `cubo_interativo.gd` — Cria o cubo, interpola a cor e prepara a textura.
- `hud.gd` — Cria a barra de ícones e a última ação.

As teclas são lidas em `_unhandled_input`, com `event.keycode`. O InputMap não é alterado.

## 6. ⚠️ Problemas comuns e soluções

- **As teclas não respondem:** clique na janela do jogo. Ao perder foco, o avatar limpa as teclas mantidas.
- **E não muda a cor:** aproxime-se do cubo laranja. A distância tem de ser inferior a 3 metros.
- **A textura fica colorida:** é a multiplicação pela cor do material. Prima R e depois T para comparar com a cor inicial.
- **A janela não abre:** confirme `godot --version` e suporte OpenGL. O renderer já está definido como Compatibility.
- **O avatar atravessa o cubo:** esta demonstração usa movimento limitado ao plano, sem colisões físicas. Use os limites do chão como fronteira.

## 🖱️ Novo visual e câmara orbital

Mantenha o **botão direito premido e mova o rato** para observar de frente, de lado, por trás ou de cima. A órbita horizontal permite voltas completas. A inclinação vertical é limitada para evitar atravessar o chão. Solte o botão, prima Esc ou mude de aplicação para libertar o cursor. A roda e +/− continuam a controlar o zoom.

O avatar tem olhos com íris, pupilas e brilho, sobrancelhas, nariz, sorriso, orelhas, cabelo com franja e nuca, mãos, sapatos, gola e fecho. Todos os detalhes são modelados por código. Para observar o rosto, aproxime o zoom e rode até à frente do avatar. A roupa continua a mudar de cor e os detalhes mantêm as suas cores.

O ambiente usa um céu azul, uma quadrícula discreta no chão e iluminação de preenchimento. Os painéis têm contornos de destaque e foi acrescentado o ícone `orbita.svg`. A grelha é um MultiMesh decorativo, independente dos cubos da experiência. No projeto 2, estes detalhes aumentam o custo base igualmente nos modos A e B.

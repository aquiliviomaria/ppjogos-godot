# Tema 4.9 — Performance 3D

## 1. 📦 Requisitos

Godot **4.5.1**, versão instalada e validada. Renderer **GL Compatibility**. Sem plugins. Ícones SVG incluídos.

## 2. ▶️ Como abrir e executar

1. Abra o gestor de projetos do Godot.
2. Escolha **Importar**.
3. Selecione o `project.godot` desta pasta.
4. Abra o projeto.
5. Prima **F5**.
6. Clique na janela do jogo.

No terminal:

```bash
godot --path "/run/media/aquilivio/aquilivio/Lab/ppjogos-godot/02-performance-3d"
```

Começa com **100 cubos**, modo **A**, sombras **ON** e vsync **desligado**.

## 3. 🎮 Controlos

| Tecla | Ação |
| --- | --- |
| W / seta para cima | Avançar |
| Seta para baixo | Recuar |
| A / seta para a esquerda | Mover à esquerda |
| D / seta para a direita | Mover à direita |
| 1 / 2 | Escolher modo A / B |
| Enter / Enter numérico | Acrescentar 100 cubos, até 5000 |
| Backspace | Remover todos os cubos |
| S | Alternar sombras |
| V | Alternar vsync |
| M | Guardar uma medição, até 6 |
| Botão direito + arrastar | Rodar a câmara em torno do avatar |
| Esc | Libertar o cursor |
| Roda para cima / + / + numérico | Aproximar |
| Roda para baixo / - / - numérico | Afastar |

**S é exclusivo das sombras**, conforme a preferência escolhida. Use **W/A/D e setas** para mover. O avatar anda quando recebe essas entradas. O zoom varia entre **10 e 80 metros**. A tecla `=` também aproxima.

O HUD apresenta, da esquerda para a direita: **FPS**, **ms/frame**, **número de cubos**, **draw calls**, **sombras ON/OFF**, **modo A/B**. Os indicadores usam só ícones e valores. Cada medição tem o formato `A | 1000 | ON | 58 FPS`.

## 4. 🧭 Roteiro de demonstração — cerca de 5 minutos

1. **0:00–0:30 — Execute o projeto.** Diga: “Começamos com uma referência antes de otimizar.”
2. **0:30–1:00 — Mova o avatar com uma seta.** Diga: “A câmara acompanha o mesmo humano nos dois modos.”
3. **1:00–1:30 — Prima Enter nove vezes.** Diga: “Agora temos mil cubos com materiais e atualizações individuais.”
4. **1:30–1:45 — Aguarde três segundos.** Diga: “Excluímos o custo pontual de construção da medição.”
5. **1:45–2:00 — Prima M.** Diga: “Guardamos a referência A com sombras ligadas.”
6. **2:00–2:15 — Prima 2.** Diga: “MultiMesh usa as mesmas posições, cores e quantidade.”
7. **2:15–2:30 — Aguarde três segundos.** Diga: “Esperamos os indicadores estabilizarem.”
8. **2:30–2:45 — Prima M.** Diga: “Comparamos B sob as mesmas condições.”
9. **2:45–3:00 — Prima S.** Diga: “Desligar sombras altera o trabalho de renderização.”
10. **3:00–3:15 — Aguarde três segundos.** Diga: “Mantemos a posição e o zoom para a comparação.”
11. **3:15–3:30 — Prima M.** Diga: “Guardamos B com sombras desligadas.”
12. **3:30–3:45 — Prima 1.** Diga: “Voltamos aos nós individuais sem mudar a quantidade.”
13. **3:45–4:00 — Aguarde três segundos.** Diga: “A comparação exige condições equivalentes.”
14. **4:00–4:15 — Prima M.** Diga: “Registamos A também sem sombras.”
15. **4:15–4:30 — Abra Depurador → Profiler.** Diga: “FPS não explica tudo; observamos também o tempo de scripts.”
16. **4:30–4:45 — Abra Depurador → Monitores.** Diga: “O tempo de frame, a memória e o desenho completam a análise.”
17. **4:45–4:55 — Prima V.** Diga: “O vsync pode limitar a taxa de frames; deve ficar igual entre medições.”
18. **4:55–5:00 — Prima Backspace.** Diga: “Sem cubos, observamos o custo base do mundo, avatar e interface.”

## 5. 🧱 Como a cena é construída

Nós: `Main`; chão de 70 × 70; luz direcional; ambiente com céu; avatar articulado; câmara de terceira pessoa; grupo `ModoA_Individual` com N MeshInstance3D ou grupo `ModoB_MultiMesh` com um MultiMeshInstance3D; HUD com TextureRect, números e lista de medições.

- `main.gd` — Gera os dados, cria o mundo, troca modos e recolhe métricas.
- `avatar.gd` — Usa o mesmo humano do projeto 1, com S reservado às sombras.
- `camera_zoom.gd` — Usa a mesma câmara, com limites de 10 a 80 metros.
- `cubo_individual.gd` — Cria um material próprio e roda um cubo por callback.
- `modo_otimizado.gd` — Usa um material partilhado e atualiza as transformações num único ciclo.
- `hud.gd` — Mostra os ícones com valores e até seis medições.

`seed(42)` gera 5000 posições e cores. Cada quantidade usa o mesmo prefixo nos dois modos. Os centros ocupam um volume de **40 × 20 × 40**, de y=1 a y=21. A malha, as cores, a fórmula e a velocidade de rotação são iguais. Trocar modo reinicia a rotação dos cubos. O avatar e a câmara mantêm o estado.

## 6. 🔍 Dados no editor

1. Execute pelo editor.
2. Abra **Depurador → Profiler**.
3. Inicie a recolha para comparar tempos de scripts e frames.
4. Abra **Depurador → Monitores**.
5. Observe FPS, memória, objetos e estatísticas de renderização.
6. Abra **Cena → Remoto** para comparar a quantidade de nós dos dois modos.

Os nomes podem variar com a tradução do editor.

O FPS vem de `Engine.get_frames_per_second()`. O tempo em ms é a média de `delta` numa janela de aproximadamente 0,25 s. As draw calls vêm de `Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME`. As cadências de atualização diferem: FPS e ms podem não ser inversos exatos.

**FPS é só uma métrica.** Compare também estabilidade dos frames, tempo de CPU/GPU, memória e qualidade visual. Os resultados variam conforme o computador. O MultiMesh mantém um ciclo de atualizações na CPU e não garante ganho em todos os casos.

Mantenha avatar, zoom, janela, sombras e vsync iguais entre A e B. Aguarde pelo menos três segundos após cada alteração. As draw calls incluem chão, avatar, HUD e passagens de sombras. MultiMesh não implica uma única draw call total.

## 7. ⚠️ Problemas comuns e soluções

- **S não recua:** S controla sombras. Use a seta para baixo.
- **FPS fica perto de 60:** experimente V. O compositor ou driver pode manter um limite; consulte também os tempos no Profiler.
- **O jogo pausa ao adicionar cubos:** é o custo de criar nós e materiais. Espere três segundos antes de medir.
- **Os números parecem iguais nos modos:** aumente a quantidade e compare também draw calls e tempo de scripts. Não há ganho garantido.
- **As medições desapareceram:** o histórico vive apenas em memória. Copie os valores antes de fechar; há um máximo de seis linhas.

O modo headless valida o código, mas não produz um benchmark da GPU. O avatar não tem colisões com os cubos. Não há gravidade ou obstáculos físicos. O estado do vsync é guardado no script, sem um indicador extra no HUD pedido; mantenha a sequência de V controlada durante a demonstração.

## 🖱️ Novo visual e câmara orbital

Mantenha o **botão direito premido e mova o rato** para observar de frente, de lado, por trás ou de cima. A órbita horizontal permite voltas completas. A inclinação vertical é limitada para evitar atravessar o chão. Solte o botão, prima Esc ou mude de aplicação para libertar o cursor. A roda e +/− continuam a controlar o zoom.

O avatar tem olhos com íris, pupilas e brilho, sobrancelhas, nariz, sorriso, orelhas, cabelo com franja e nuca, mãos, sapatos, gola e fecho. Todos os detalhes são modelados por código. Para observar o rosto, aproxime o zoom e rode até à frente do avatar. A roupa continua a mudar de cor e os detalhes mantêm as suas cores.

O ambiente usa um céu azul, uma quadrícula discreta no chão e iluminação de preenchimento. Os painéis têm contornos de destaque e foi acrescentado o ícone `orbita.svg`. A grelha é um MultiMesh decorativo, independente dos cubos da experiência. No projeto 2, estes detalhes aumentam o custo base igualmente nos modos A e B.

# Validação — rosto detalhado, câmara orbital e visual

Data: **10 de novembro de 2026**. Godot: **4.5.1.stable.fedora.f62fdbde1**. Renderer: **GL Compatibility**.

## Arranque final

```sh
godot --headless --path 01-interatividade-3d --quit
godot --headless --path 02-performance-3d --quit
```

Os dois comandos terminaram com **código 0**, sem erros nem avisos. A saída foi inspecionada para detetar erros de script, pois o código de saída do Godot, isoladamente, pode não refletir uma falha de parsing.

Também foi aberto cada editor em modo headless, com `--editor --quit`, para verificar a inicialização e importação dos 12 SVG locais de cada projeto.

## Testes funcionais com janela gráfica

Foi usado um verificador temporário externo aos projetos. A execução usou X11, OpenGL 4.6, Mesa 24.3.3 e Intel UHD Graphics 620.

| Projeto | Verificações | Falhas |
| --- | ---: | ---: |
| 01-interatividade-3d | 41 | 0 |
| 02-performance-3d | 47 | 0 |

Cobertura comum: quatro pivôs; cinco materiais de roupa; cabeça esférica; avanço; recuo com seta; altura do chão; balanço em oposição; regresso à pose neutra; respiração; Tween da roupa; limites de zoom; teclas normais e numéricas; roda do rato; seguimento da câmara.

Interatividade: E recusado à distância; mudança de cor perto do cubo; T; textura de 64 × 64; C; R a repor avatar, cubo, roupa e zoom.

Performance: S reservado às sombras; cem nós individuais; materiais próprios; cem instâncias MultiMesh; posições e cores equivalentes; rotação MultiMesh; adição; limite de cinco mil; limpeza nos dois modos; reconstrução; sombras; seis medições curtas; tecla V e estado reportado pelo DisplayServer.

As cores por instância foram comparadas com tolerância de 1/255 por canal, por causa da precisão do renderer Compatibility. As consultas de transformações MultiMesh foram verificadas com renderer real, não com o backend dummy do headless.

## Revisão da entrega

- 11 scripts GDScript tipados, com comentário em português em cada linha não vazia.
- `avatar.gd` idêntico nos dois projetos.
- `camera_zoom.gd` idêntico nos dois projetos.
- 26 SVG: 13 por projeto, 24 × 24, traço branco e fundo transparente.
- Capturas das duas janelas inspecionadas visualmente.
- HUD do projeto 1 com barra inferior e última ação curta.
- HUD do projeto 2 com ícones, valores e seis linhas de medição.
- Cenas mínimas mantidas: apenas Main e ligação ao script.
- Controlos lidos com event.keycode, sem alterações ao InputMap.
- READMEs com requisitos, abertura, controlos, roteiro, nós/scripts e soluções de problemas.

## Limitações

- Só Godot 4.5.1 foi testado.
- O movimento é limitado ao chão, sem gravidade ou colisões com cubos.
- No projeto 2, S controla sombras e a seta para baixo permite recuar, conforme a escolha do utilizador.
- Não foram feitos benchmarks representativos. Durante testes, a cena muda rapidamente; os FPS das capturas não servem como resultados académicos.
- O driver ou compositor pode limitar FPS mesmo com vsync desligado.
- O MultiMesh mantém atualizações na CPU e culling do conjunto; não há garantia universal de ganho.
- As medições guardam apenas modo, quantidade, sombras e FPS em memória. Mantenha avatar, zoom e vsync fixos ao comparar; o histórico desaparece ao fechar.
- O PNG opcional não foi fornecido. Foi testado o xadrez gerado por código.

## Atualização visual e órbita

88 verificações funcionais gráficas concluídas, sem falhas. Foram acrescentadas verificações do botão direito, voltas horizontais superiores a 360 graus, limites verticais, libertação do cursor e presença dos detalhes do rosto e mãos. O teste de procura das mãos foi ajustado para incluir nós construídos por código sem owner.

O avatar tem olhos, íris, pupilas, brilho, sobrancelhas, nariz, boca sorridente, orelhas e cabelo com franja e nuca. Os dois projetos usam o mesmo avatar e a mesma câmara. O movimento acompanha o azimute da vista. A inclinação permite observar ao nível do rosto e de cima; impede entrar no chão.

Os céus, iluminação ambiente, luz de preenchimento, grelha e painéis foram melhorados. A grelha decorativa é independente do grupo de cubos da experiência. Este custo base é igual nos modos A e B. As draw calls atuais não devem ser comparadas diretamente com as capturas da versão anterior do cenário.

Capturas gráficas da versão atual em `docs/visual-atualizado.png` de cada projeto. O botão direito e Esc controlam a captura do rato; perder foco também liberta o ponteiro. Não foi acrescentada colisão da câmara com os cubos.

Revisão visual final: grelha elevada ligeiramente acima do chão para evitar sobreposição de profundidade, linhas mais largas e MSAA 4× configurado nos dois projetos. Arranque headless repetido após estes ajustes, sem erros ou avisos. Este antialiasing faz parte das mesmas condições gráficas em A e B.

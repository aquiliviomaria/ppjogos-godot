extends CanvasLayer # Desenha a interface sobre a cena 3D.

var raiz: Control # Organiza a interface segundo o tamanho do viewport.
var texturas: Dictionary[String, Texture2D] = {} # Evita carregar o mesmo SVG várias vezes.

func _criar_raiz() -> void: # Prepara a camada visual sem capturar controlos.
	name = "HUD" # Identifica a interface na árvore Remoto.
	raiz = Control.new() # Cria a área da interface.
	raiz.mouse_filter = Control.MOUSE_FILTER_IGNORE # Deixa o rato chegar à câmara.
	add_child(raiz) # Liga a interface à camada 2D.
	raiz.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT) # Ocupa todo o viewport.

func _painel(pai: Control) -> PanelContainer: # Cria um painel escuro com margens.
	var painel: PanelContainer = PanelContainer.new() # Cria o fundo da informação.
	painel.mouse_filter = Control.MOUSE_FILTER_IGNORE # Não bloqueia entradas do rato.
	var estilo: StyleBoxFlat = StyleBoxFlat.new() # Define o estilo sem assets externos.
	estilo.bg_color = Color(0.018, 0.035, 0.065, 0.94) # Dá contraste aos ícones brancos.
	estilo.border_color = Color(0.22, 0.48, 0.55, 0.8) # Contorna o painel com a cor de destaque.
	estilo.set_border_width_all(1) # Acrescenta uma borda fina ao painel.
	estilo.set_corner_radius_all(10) # Suaviza os cantos do painel.
	estilo.content_margin_left = 14.0 # Acrescenta margem à esquerda.
	estilo.content_margin_right = 14.0 # Acrescenta margem à direita.
	estilo.content_margin_top = 10.0 # Acrescenta margem superior.
	estilo.content_margin_bottom = 10.0 # Acrescenta margem inferior.
	painel.add_theme_stylebox_override("panel", estilo) # Aplica a aparência ao painel.
	pai.add_child(painel) # Insere o painel na interface.
	return painel # Devolve o recipiente para o seu conteúdo.

func _linha(pai: Control) -> HBoxContainer: # Organiza ícones e valores horizontalmente.
	var linha: HBoxContainer = HBoxContainer.new() # Cria a fila de informação.
	linha.add_theme_constant_override("separation", 18) # Separa os grupos de ícones.
	linha.mouse_filter = Control.MOUSE_FILTER_IGNORE # Preserva os controlos do rato.
	pai.add_child(linha) # Insere a fila no recipiente.
	return linha # Devolve a fila criada.

func _icone(nome: String) -> TextureRect: # Carrega um SVG local numa textura 2D.
	if not texturas.has(nome): # Só rasteriza cada desenho uma vez.
		var imagem: Image = Image.new() # Prepara a imagem do ícone.
		var svg: String = FileAccess.get_file_as_string("res://icones/" + nome + ".svg") # Lê o vetor sem depender da importação do editor.
		var erro: Error = imagem.load_svg_from_string(svg) # Rasteriza o SVG com o carregador integrado.
		assert(erro == OK, "Ícone SVG inválido: " + nome) # Identifica um ficheiro local inválido durante a revisão.
		texturas[nome] = ImageTexture.create_from_image(imagem) # Guarda a textura pronta para desenhar.
	var icone: TextureRect = TextureRect.new() # Cria o controlo visual exigido pelo HUD.
	icone.texture = texturas[nome] # Atribui a imagem do ícone.
	icone.custom_minimum_size = Vector2(24, 24) # Mantém o tamanho dos desenhos.
	icone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE # Impede a textura de alterar a dimensão mínima.
	icone.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED # Mantém a proporção quadrada.
	icone.mouse_filter = Control.MOUSE_FILTER_IGNORE # Deixa a roda controlar o zoom.
	return icone # Devolve o TextureRect configurado.

func _item(pai: Control, icone: String, texto: String) -> Label: # Associa um ícone a um valor curto.
	var grupo: HBoxContainer = HBoxContainer.new() # Agrupa o desenho e o texto.
	grupo.add_theme_constant_override("separation", 7) # Aproxima o valor do respetivo ícone.
	grupo.mouse_filter = Control.MOUSE_FILTER_IGNORE # Mantém os eventos disponíveis para o jogo.
	pai.add_child(grupo) # Acrescenta o grupo à fila.
	grupo.add_child(_icone(icone)) # Desenha o ícone SVG como TextureRect.
	var valor: Label = Label.new() # Cria o texto curto do grupo.
	valor.text = texto # Define o valor inicial.
	valor.add_theme_font_size_override("font_size", 18) # Mantém leitura confortável na apresentação.
	valor.mouse_filter = Control.MOUSE_FILTER_IGNORE # Não interceta o rato sobre o valor.
	grupo.add_child(valor) # Coloca o valor ao lado do ícone.
	return valor # Permite atualizar apenas o número ou a ação.

var valores: Dictionary[String, Label] = {} # Guarda as etiquetas das métricas.
var lista: VBoxContainer # Guarda as últimas medições em linhas separadas.

func _ready() -> void: # Constrói os indicadores compactos.
	_criar_raiz() # Prepara a interface sobre a cena.
	var painel: PanelContainer = _painel(raiz) # Cria a barra superior de números.
	painel.position = Vector2(20, 20) # Posiciona as métricas no canto superior.
	var fila: HBoxContainer = _linha(painel) # Organiza os indicadores horizontalmente.
	valores["fps"] = _item(fila, "fps", "0") # Associa o ícone de FPS ao valor.
	valores["ms"] = _item(fila, "relogio", "0.0") # Associa o relógio ao tempo em milissegundos.
	valores["objetos"] = _item(fila, "caixa", "100") # Mostra a quantidade de cubos.
	valores["draw"] = _item(fila, "camadas", "0") # Mostra as chamadas de desenho.
	valores["sombras"] = _item(fila, "sol", "ON") # Mostra o estado das sombras.
	valores["modo"] = _item(fila, "tecla", "A") # Mostra a letra do modo atual.
	var painel_medicoes: PanelContainer = _painel(raiz) # Cria a lista compacta de amostras.
	painel_medicoes.position = Vector2(20, 90) # Coloca as amostras abaixo das métricas.
	lista = VBoxContainer.new() # Organiza as medições em linhas.
	lista.mouse_filter = Control.MOUSE_FILTER_IGNORE # Não captura o rato.
	painel_medicoes.add_child(lista) # Insere a lista no painel.
	_item(lista, "medicao", "—") # Indica que ainda não existem medições.
	var ajuda: PanelContainer = _painel(raiz) # Acrescenta uma indicação discreta da órbita.
	ajuda.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT) # Prende a indicação ao canto inferior.
	ajuda.offset_left = -180.0 # Reserva espaço para os símbolos do rato.
	ajuda.offset_top = -62.0 # Afasta o controlo da borda inferior.
	ajuda.offset_right = -20.0 # Mantém uma margem lateral.
	ajuda.offset_bottom = -20.0 # Mantém uma margem inferior.
	var controlos: HBoxContainer = _linha(ajuda) # Agrupa os controlos da câmara.
	_item(controlos, "orbita", "BD") # Indica a rotação pelo botão direito.
	_item(controlos, "zoom", "±") # Indica o zoom pela roda ou teclas.

func atualizar(modo: String, quantidade: int, fps: int, ms: float, chamadas: int, sombras: bool) -> void: # Atualiza apenas os números apresentados.
	valores["fps"].text = str(fps) # Mostra a taxa de frames do motor.
	valores["ms"].text = "%.2f" % ms # Mostra o tempo médio por frame em ms.
	valores["objetos"].text = str(quantidade) # Mostra o total de cubos ativos.
	valores["draw"].text = str(chamadas) # Mostra as draw calls da cena.
	valores["sombras"].text = "ON" if sombras else "OFF" # Resume o estado da luz.
	valores["modo"].text = modo # Identifica o modo A ou B.

func mostrar_medicoes(medicoes: Array[String]) -> void: # Substitui a lista de amostras guardadas.
	for filho: Node in lista.get_children(): # Percorre as linhas anteriores.
		lista.remove_child(filho) # Retira imediatamente a linha antiga.
		filho.queue_free() # Agenda a libertação do controlo.
	for medicao: String in medicoes: # Percorre no máximo seis amostras.
		_item(lista, "medicao", medicao) # Desenha o ícone e a linha curta.

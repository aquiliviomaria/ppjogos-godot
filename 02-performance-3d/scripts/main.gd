extends Node3D # Constrói a demonstração 3D a partir do nó Main.

const AvatarScript = preload("res://scripts/avatar.gd") # Carrega o humano comum aos projetos.
const CamaraScript = preload("res://scripts/camera_zoom.gd") # Carrega a câmara com zoom.
const HudScript = preload("res://scripts/hud.gd") # Carrega a interface com ícones.
var avatar: AvatarScript # Guarda o humano controlável.
var camara: CamaraScript # Guarda a câmara de terceira pessoa.
var hud: HudScript # Guarda a interface da demonstração.
var luz: DirectionalLight3D # Guarda a luz principal da cena.

func _criar_mundo(tamanho: float) -> void: # Constrói o chão, a luz e o céu simples.
	var chao: MeshInstance3D = MeshInstance3D.new() # Cria o chão visível.
	chao.name = "Chao" # Identifica o plano na árvore Remoto.
	var plano: PlaneMesh = PlaneMesh.new() # Cria a geometria plana.
	plano.size = Vector2(tamanho, tamanho) # Define as dimensões do chão.
	chao.mesh = plano # Liga a geometria à instância.
	var cinzento: StandardMaterial3D = StandardMaterial3D.new() # Cria o material do chão.
	cinzento.albedo_color = Color(0.085, 0.13, 0.18) # Aplica um cinzento discreto.
	chao.material_override = cinzento # Atribui o material ao plano.
	add_child(chao) # Acrescenta o chão à cena.
	luz = DirectionalLight3D.new() # Cria a luz direcional.
	luz.name = "Luz" # Identifica a iluminação principal.
	luz.rotation_degrees = Vector3(-48, -30, 0) # Inclina a luz sobre a cena.
	luz.shadow_enabled = true # Ativa as sombras no arranque.
	luz.directional_shadow_max_distance = 160.0 # Mantém sombras ao afastar a câmara.
	add_child(luz) # Liga a luz à cena.
	var mundo: WorldEnvironment = WorldEnvironment.new() # Cria o ambiente global.
	mundo.name = "CeuEAmbiente" # Identifica o ambiente no editor.
	mundo.environment = Environment.new() # Reserva as propriedades do ambiente.
	mundo.environment.background_mode = Environment.BG_SKY # Usa um céu procedural como fundo.
	var ceu: Sky = Sky.new() # Cria o recurso de céu.
	var atmosfera: ProceduralSkyMaterial = ProceduralSkyMaterial.new() # Define uma paleta coerente para o ambiente.
	atmosfera.sky_top_color = Color(0.025, 0.075, 0.15) # Dá profundidade azul ao céu.
	atmosfera.sky_horizon_color = Color(0.24, 0.38, 0.45) # Suaviza a linha do horizonte.
	atmosfera.ground_bottom_color = Color(0.045, 0.075, 0.11) # Evita o fundo castanho do ambiente anterior.
	atmosfera.ground_horizon_color = Color(0.24, 0.38, 0.45) # Liga o horizonte às cores do chão.
	ceu.sky_material = atmosfera # Gera o céu sem imagens externas.
	mundo.environment.sky = ceu # Associa o céu ao ambiente.
	mundo.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR # Mantém o rosto legível mesmo no lado da sombra.
	mundo.environment.ambient_light_color = Color(0.78, 0.85, 1.0) # Dá um preenchimento ambiente neutro e suave.
	mundo.environment.ambient_light_energy = 0.7 # Revela os olhos e o sorriso sem eliminar o relevo.
	add_child(mundo) # Acrescenta o ambiente à cena.
	var preenchimento: DirectionalLight3D = DirectionalLight3D.new() # Ilumina o rosto visto de frente.
	preenchimento.name = "LuzDePreenchimento" # Distingue a luz suave da luz com sombras.
	preenchimento.rotation_degrees = Vector3(-25, 150, 0) # Incide do lado oposto à iluminação principal.
	preenchimento.light_color = Color(0.63, 0.81, 1.0) # Acrescenta uma tonalidade azul suave.
	preenchimento.light_energy = 0.45 # Preserva o contraste sem escurecer o rosto.
	add_child(preenchimento) # Aplica a mesma luz aos dois modos de performance.
	_criar_grelha(tamanho) # Acrescenta referências espaciais discretas ao chão.

func _criar_grelha(tamanho: float) -> void: # Desenha a quadrícula com uma única instância agrupada.
	var linhas: MultiMeshInstance3D = MultiMeshInstance3D.new() # Agrupa as linhas para reduzir chamadas de desenho.
	linhas.name = "GrelhaDoChao" # Identifica o detalhe visual no editor.
	var conjunto: MultiMesh = MultiMesh.new() # Cria o conjunto de segmentos.
	conjunto.transform_format = MultiMesh.TRANSFORM_3D # Usa posições e escalas tridimensionais.
	conjunto.mesh = BoxMesh.new() # Usa caixas unitárias como linhas.
	var passos: int = int(tamanho / 2.0) + 1 # Distribui linhas de dois em dois metros.
	conjunto.instance_count = passos * 2 # Reserva as duas direções da quadrícula.
	for indice: int in range(passos): # Distribui as linhas pelo plano.
		var local: float = -tamanho * 0.5 + float(indice) * 2.0 # Calcula o afastamento de cada linha.
		conjunto.set_instance_transform(indice * 2, Transform3D(Basis.from_scale(Vector3(0.028, 0.02, tamanho)), Vector3(local, 0.025, 0))) # Coloca uma linha paralela ao eixo Z.
		conjunto.set_instance_transform(indice * 2 + 1, Transform3D(Basis.from_scale(Vector3(tamanho, 0.02, 0.028)), Vector3(0, 0.025, local))) # Coloca uma linha paralela ao eixo X.
	linhas.multimesh = conjunto # Aplica o conjunto de linhas ao nó.
	var tinta: StandardMaterial3D = StandardMaterial3D.new() # Define a aparência da quadrícula.
	tinta.albedo_color = Color(0.22, 0.35, 0.4) # Mantém a grelha visível sem dominar a cena.
	linhas.material_override = tinta # Aplica o material partilhado.
	linhas.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF # Evita sombras desnecessárias das linhas.
	add_child(linhas) # Coloca a grelha na cena.

const CuboScript = preload("res://scripts/cubo_individual.gd") # Carrega o cubo do modo individual.
const OtimizadoScript = preload("res://scripts/modo_otimizado.gd") # Carrega o conjunto MultiMesh.
const MAXIMO: int = 5000 # Limita a quantidade de cubos da demonstração.
var modo: int = 1 # Começa no modo A individual.
var quantidade: int = 100 # Começa com cem objetos.
var grupo: Node3D # Guarda exclusivamente os cubos do modo ativo.
var posicoes: PackedVector3Array = PackedVector3Array() # Guarda a sequência determinística de posições.
var cores: PackedColorArray = PackedColorArray() # Guarda a sequência determinística de cores.
var caixa: BoxMesh = BoxMesh.new() # Partilha a geometria entre todos os cubos.
var medicoes: Array[String] = [] # Guarda apenas as seis amostras mais recentes.
var vsync: bool = false # Memoriza o modo de sincronização reportado pelo sistema.
var tempo_hud: float = 0.0 # Controla a frequência de atualização dos indicadores.
var soma_delta: float = 0.0 # Soma a duração dos frames da janela atual.
var frames_amostra: int = 0 # Conta os frames da janela atual.
var frame_ms: float = 0.0 # Guarda a duração média de um frame em milissegundos.

func _ready() -> void: # Constrói a cena e o primeiro modo de medição.
	seed(42) # Fixa a sequência aleatória para repetir as condições.
	for _indice: int in range(MAXIMO): # Gera todos os dados independentemente do modo escolhido.
		posicoes.append(Vector3(randf_range(-20, 20), randf_range(1, 21), randf_range(-20, 20))) # Distribui centros num volume de quarenta por vinte por quarenta.
		cores.append(Color.from_hsv(randf(), 0.6, 0.95)) # Guarda uma cor repetível por cubo.
	caixa.size = Vector3.ONE # Define cubos de um metro por lado.
	_criar_mundo(70.0) # Cria um chão que cobre o volume de cubos.
	avatar = AvatarScript.new() # Cria o humano com a mesma implementação do projeto um.
	avatar.limite_chao = 33.0 # Mantém o avatar dentro do plano maior.
	avatar.permitir_s = false # Reserva S para sombras conforme a preferência escolhida.
	add_child(avatar) # Constrói o corpo articulado e ativa o movimento.
	camara = CamaraScript.new() # Cria a câmara de terceira pessoa.
	camara.configurar(avatar, 10.0, 80.0, 45.0) # Define os limites de zoom para a cena maior.
	add_child(camara) # Ativa o seguimento com ângulo fixo.
	hud = HudScript.new() # Cria os indicadores com ícones e números.
	add_child(hud) # Coloca a interface sobre a cena.
	if DisplayServer.get_name() != "headless": # Evita chamadas de janela no servidor sem imagem.
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED) # Desliga o vsync ao iniciar.
		vsync = DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_DISABLED # Consulta o estado efetivamente reportado.
	_reconstruir() # Cria o grupo inicial com cem cubos.
	_atualizar_hud() # Apresenta os primeiros indicadores.

func _reconstruir() -> void: # Substitui os cubos mantendo os dados de referência.
	if grupo != null: # Verifica se existe um modo anterior.
		remove_child(grupo) # Impede que os dois modos sejam desenhados ao mesmo tempo.
		grupo.queue_free() # Liberta os nós antigos no fim do frame.
	grupo = Node3D.new() # Cria um recipiente novo para o modo escolhido.
	grupo.name = "ModoA_Individual" if modo == 1 else "ModoB_MultiMesh" # Identifica o modo no separador Remoto.
	add_child(grupo) # Liga o grupo ativo à cena.
	if modo == 1: # Seleciona a implementação com nós individuais.
		for indice: int in range(quantidade): # Cria um nó por cubo.
			var cubo: CuboScript = CuboScript.new() # Instancia o script individual.
			cubo.name = "Cubo_%04d" % indice # Dá um nome estável a cada objeto.
			cubo.configurar(posicoes[indice], cores[indice], caixa) # Usa a posição e a cor do conjunto comum.
			grupo.add_child(cubo) # Ativa o processamento do cubo.
	elif quantidade > 0: # Evita criar um MultiMesh vazio após limpar.
		var otimizado: OtimizadoScript = OtimizadoScript.new() # Instancia o conjunto otimizado.
		otimizado.name = "CubosMultiMesh" # Identifica o único nó que desenha os cubos.
		otimizado.configurar(posicoes.slice(0, quantidade), cores.slice(0, quantidade), caixa) # Usa o mesmo prefixo de dados do modo A.
		grupo.add_child(otimizado) # Ativa o ciclo único de atualização.
	tempo_hud = 0.0 # Reinicia a janela de atualização do HUD.
	soma_delta = 0.0 # Descarta os tempos recolhidos antes da troca.
	frames_amostra = 0 # Reinicia a contagem de frames da amostra.

func _process(delta: float) -> void: # Recolhe o tempo de frame sem atualizar texto em cada frame.
	tempo_hud += delta # Acumula o intervalo desde a última atualização.
	soma_delta += delta # Soma a duração dos frames observados.
	frames_amostra += 1 # Conta mais um frame da amostra.
	if tempo_hud >= 0.25: # Atualiza os números aproximadamente quatro vezes por segundo.
		frame_ms = soma_delta * 1000.0 / float(frames_amostra) # Converte a duração média em milissegundos.
		_atualizar_hud() # Mostra as métricas recolhidas.
		tempo_hud = 0.0 # Inicia uma nova janela temporal.
		soma_delta = 0.0 # Reinicia a soma dos tempos.
		frames_amostra = 0 # Reinicia a contagem da janela.

func _chamadas() -> int: # Consulta as chamadas de desenho reportadas pelo motor.
	return int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)) # Lê o contador pedido para a demonstração.

func _atualizar_hud() -> void: # Envia apenas valores curtos para os indicadores.
	hud.atualizar("A" if modo == 1 else "B", quantidade, Engine.get_frames_per_second(), frame_ms, _chamadas(), luz.shadow_enabled) # Atualiza ícones e números sem instruções longas.

func _unhandled_input(event: InputEvent) -> void: # Trata os atalhos de controlo da experiência.
	if not event is InputEventKey: # Ignora eventos do rato nesta lógica.
		return # Deixa a câmara tratar a roda de zoom.
	if not event.pressed or event.echo: # Aceita uma ação por pressão de tecla.
		return # Evita acrescentar objetos por repetição automática.
	match event.keycode: # Seleciona a operação pelo código da tecla.
		KEY_1, KEY_2: # Trata a seleção dos dois modos.
			modo = 1 if event.keycode == KEY_1 else 2 # Guarda o modo solicitado.
			_reconstruir() # Recria apenas os cubos e mantém avatar e câmara.
		KEY_ENTER, KEY_KP_ENTER: # Aceita Enter normal e do teclado numérico.
			quantidade = mini(quantidade + 100, MAXIMO) # Acrescenta cem sem ultrapassar cinco mil.
			_reconstruir() # Atualiza o conjunto de objetos.
		KEY_BACKSPACE: # Trata a limpeza completa.
			quantidade = 0 # Define o total de cubos como zero.
			_reconstruir() # Remove o conjunto de objetos ativos.
		KEY_S: # Usa S exclusivamente para sombras neste projeto.
			luz.shadow_enabled = not luz.shadow_enabled # Alterna as sombras da luz direcional.
		KEY_V: # Trata o controlo de sincronização vertical.
			if DisplayServer.get_name() != "headless": # Confirma que existe uma janela gráfica.
				var pedido: bool = not vsync # Inverte o estado de sincronização atual.
				DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if pedido else DisplayServer.VSYNC_DISABLED) # Solicita o novo modo ao sistema.
				vsync = DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_DISABLED # Guarda o modo reportado pelo driver.
		KEY_M: # Trata o registo de uma medição.
			var registo: String = "%s | %d | %s | %d FPS" % ["A" if modo == 1 else "B", quantidade, "ON" if luz.shadow_enabled else "OFF", Engine.get_frames_per_second()] # Formata uma linha curta da amostra.
			medicoes.append(registo) # Guarda a medição no histórico.
			if medicoes.size() > 6: # Verifica o limite de amostras visíveis.
				medicoes.pop_front() # Retira a amostra mais antiga.
			hud.mostrar_medicoes(medicoes) # Atualiza a lista com os ícones de medição.
	_atualizar_hud() # Reflete imediatamente as mudanças nos indicadores.

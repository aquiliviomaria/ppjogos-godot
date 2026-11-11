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

const CuboScript = preload("res://scripts/cubo_interativo.gd") # Carrega o objeto de interação.
var cubo: CuboScript # Guarda o cubo ao lado do avatar.

func _ready() -> void: # Constrói a hierarquia completa ao executar.
	_criar_mundo(20.0) # Cria o chão de vinte metros e a iluminação.
	avatar = AvatarScript.new() # Cria o humano articulado.
	add_child(avatar) # Constrói as peças do avatar na cena.
	cubo = CuboScript.new() # Cria o cubo de dois metros.
	add_child(cubo) # Coloca o cubo em quatro, um, zero.
	camara = CamaraScript.new() # Cria a câmara com zoom.
	camara.configurar(avatar, 3.0, 15.0, 8.0) # Define o intervalo de três a quinze metros.
	add_child(camara) # Ativa o seguimento do humano.
	hud = HudScript.new() # Cria o HUD com a barra inferior.
	add_child(hud) # Coloca os ícones sobre a cena 3D.

func _unhandled_input(event: InputEvent) -> void: # Liga cada tecla à lógica da demonstração.
	if not event is InputEventKey: # Ignora eventos que não são de teclado.
		return # Deixa os eventos de rato para o zoom.
	if not event.pressed or event.echo: # Aceita apenas a primeira pressão de cada tecla.
		return # Evita repetir mudanças de estado ao manter a tecla.
	match event.keycode: # Seleciona a ação pelo código da tecla.
		KEY_E: # Trata a interação por proximidade.
			if avatar.global_position.distance_to(cubo.global_position) < 3.0: # Exige uma distância entre origens inferior a três metros.
				var cor: Color = Color.from_hsv(randf(), 0.7, 0.95) # Escolhe uma nova cor saturada.
				cubo.mudar_cor(cor) # Inicia a transição suave no cubo.
				hud.atualizar("E → cor #" + cor.to_html(false).to_upper()) # Mostra o resultado da entrada.
			else: # Trata a tentativa feita longe do cubo.
				hud.atualizar("E → aproxima-te") # Dá uma indicação curta de proximidade.
		KEY_T: # Trata a alternância de textura.
			var ativa: bool = cubo.alternar_textura() # Troca a imagem do material.
			hud.atualizar("T → " + ("textura" if ativa else "cor")) # Mostra o novo modo visual.
		KEY_C: # Trata a mudança de roupa.
			var cor: Color = Color.from_hsv(randf(), 0.7, 0.95) # Escolhe uma cor para o humano.
			avatar.mudar_cor(cor) # Interpola a cor de todas as peças vestidas.
			hud.atualizar("C → roupa #" + cor.to_html(false).to_upper()) # Mostra a cor de destino.
		KEY_R: # Trata a reposição completa.
			avatar.repor() # Repõe pose, posição e roupa.
			cubo.repor() # Repõe a cor e desativa a textura.
			camara.repor() # Repõe a posição e o zoom da câmara.
			hud.atualizar("R → reposto") # Confirma o estado inicial no HUD.

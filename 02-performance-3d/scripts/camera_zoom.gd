extends Camera3D # Implementa a câmara de terceira pessoa.

var alvo: Node3D # Guarda o avatar seguido.
var distancia_minima: float = 3.0 # Define o limite de aproximação.
var distancia_maxima: float = 15.0 # Define o limite de afastamento.
var distancia_inicial: float = 8.0 # Guarda o zoom de origem.
var distancia_desejada: float = 8.0 # Guarda o zoom pedido pelo utilizador.
var distancia_atual: float = 8.0 # Guarda a distância interpolada.
var azimute: float = 0.0 # Guarda a rotação horizontal sem limite de voltas.
var elevacao: float = 0.576375 # Define a inclinação inicial sobre o avatar.
var azimute_atual: float = 0.0 # Suaviza a rotação horizontal.
var elevacao_atual: float = 0.576375 # Suaviza a inclinação vertical.
var rodando: bool = false # Indica quando o botão direito controla a órbita.
var foco_atual: Vector3 # Suaviza o seguimento sem alterar a distância de órbita.

func configurar(avatar: Node3D, minimo: float, maximo: float, inicial: float) -> void: # Configura o alvo e os limites por projeto.
	alvo = avatar # Seleciona o avatar a seguir.
	distancia_minima = minimo # Define o zoom mínimo.
	distancia_maxima = maximo # Define o zoom máximo.
	distancia_inicial = inicial # Guarda o enquadramento inicial.
	distancia_desejada = inicial # Inicia o destino do zoom.
	distancia_atual = inicial # Evita uma aproximação brusca no arranque.

func _ready() -> void: # Ativa a câmara após entrar na árvore.
	name = "CamaraZoom" # Identifica a câmara no modo Remoto.
	current = true # Usa esta câmara para desenhar a cena.
	fov = 65.0 # Define o campo de visão.
	repor() # Posiciona a câmara sem interpolação inicial.

func ajustar_zoom(passos: float) -> void: # Aplica uma alteração ao zoom.
	distancia_desejada = clampf(distancia_desejada + passos * distancia_inicial * 0.12, distancia_minima, distancia_maxima) # Limita a distância pedida.

func _unhandled_input(event: InputEvent) -> void: # Lê rato e teclado sem ações do InputMap.
	if event is InputEventMouseMotion and rodando: # Lê o deslocamento do rato durante a órbita.
		azimute -= event.relative.x * 0.006 # Roda em torno do avatar em qualquer direção horizontal.
		elevacao = clampf(elevacao + event.relative.y * 0.006, 0.08, 1.48) # Inclina a vista sem atravessar o chão ou inverter o horizonte.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT: # Inicia ou termina a rotação pelo rato.
		rodando = event.pressed # Mantém a órbita ativa apenas enquanto o botão está premido.
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if rodando else Input.MOUSE_MODE_VISIBLE # Evita que os limites da janela interrompam a rotação.
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE: # Permite libertar sempre o cursor.
		_libertar_rato() # Termina a órbita e devolve o ponteiro.
	if event is InputEventMouseButton and event.pressed: # Filtra os passos da roda de zoom.
		if event.button_index == MOUSE_BUTTON_WHEEL_UP: # Deteta a roda para cima.
			ajustar_zoom(-1.0) # Aproxima a câmara.
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN: # Deteta a roda para baixo.
			ajustar_zoom(1.0) # Afasta a câmara.
	if event is InputEventKey and event.pressed: # Permite também repetição das teclas de zoom.
		if event.keycode in [KEY_PLUS, KEY_EQUAL, KEY_KP_ADD]: # Aceita mais no teclado normal e numérico.
			ajustar_zoom(-1.0) # Aproxima a câmara pelo teclado.
		elif event.keycode in [KEY_MINUS, KEY_KP_SUBTRACT]: # Aceita menos no teclado normal e numérico.
			ajustar_zoom(1.0) # Afasta a câmara pelo teclado.

func _process(delta: float) -> void: # Suaviza o zoom e o seguimento.
	var peso: float = 1.0 - exp(-8.0 * delta) # Calcula uma suavização independente dos FPS.
	distancia_atual = lerpf(distancia_atual, distancia_desejada, peso) # Interpola a distância do zoom.
	azimute_atual = lerpf(azimute_atual, azimute, peso) # Suaviza as voltas completas sem saltos angulares.
	elevacao_atual = lerpf(elevacao_atual, elevacao, peso) # Suaviza a inclinação da vista.
	foco_atual = foco_atual.lerp(alvo.global_position + Vector3(0, 1.15, 0), peso) # Acompanha o centro visual do humano.
	global_position = foco_atual + _direcao_orbita() * distancia_atual # Mantém a câmara numa esfera em torno do alvo.
	alvo.angulo_camara = azimute_atual # Faz o movimento acompanhar a orientação da câmara.
	look_at(foco_atual, Vector3.UP) # Mantém o avatar enquadrado durante a órbita.

func _direcao_orbita() -> Vector3: # Converte os ângulos em direção tridimensional.
	return Vector3(sin(azimute_atual) * cos(elevacao_atual), sin(elevacao_atual), cos(azimute_atual) * cos(elevacao_atual)) # Calcula uma direção unitária sobre a esfera.

func _libertar_rato() -> void: # Devolve o cursor ao utilizador.
	rodando = false # Interrompe a rotação por movimento do rato.
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE # Mostra o ponteiro da janela.

func _notification(what: int) -> void: # Evita manter o rato preso fora da aplicação.
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT: # Deteta a perda de foco da janela.
		_libertar_rato() # Liberta o cursor quando se muda de aplicação.

func repor() -> void: # Recupera o enquadramento inicial e o cursor.
	_libertar_rato() # Termina uma eventual órbita em curso.
	distancia_desejada = distancia_inicial # Repõe o destino do zoom.
	distancia_atual = distancia_inicial # Repõe a distância sem espera.
	azimute = 0.0 # Recupera a orientação horizontal inicial.
	azimute_atual = 0.0 # Elimina a interpolação horizontal pendente.
	elevacao = 0.576375 # Recupera a inclinação inicial.
	elevacao_atual = elevacao # Elimina a interpolação vertical pendente.
	alvo.angulo_camara = 0.0 # Repõe os eixos de movimento iniciais.
	foco_atual = alvo.global_position + Vector3(0, 1.15, 0) # Centra a vista à altura do torso.
	global_position = foco_atual + _direcao_orbita() * distancia_atual # Posiciona a câmara na órbita inicial.
	look_at(foco_atual, Vector3.UP) # Enquadra o humano imediatamente.

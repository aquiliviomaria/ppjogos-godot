extends Node3D # Representa o humano construído por código.

const COR_INICIAL: Color = Color(0.12, 0.55, 0.9) # Define a roupa inicial.
var limite_chao: float = 9.0 # Impede que o avatar saia do chão.
var permitir_s: bool = true # Reserva S para sombras no projeto de performance.
var teclas: Dictionary[int, bool] = {} # Guarda as teclas de movimento premidas.
var materiais_roupa: Array[StandardMaterial3D] = [] # Reúne os materiais que recebem novas cores.
var pivos: Array[Node3D] = [] # Guarda ombros e ancas para animação.
var corpo: Node3D # Agrupa as peças para a respiração.
var angulo_camara: float = 0.0 # Orienta o movimento relativamente à vista atual.
var tempo: float = 0.0 # Acumula o tempo da animação.
var mistura_andar: float = 0.0 # Suaviza a passagem entre andar e parar.
var tween_roupa: Tween # Guarda a transição de cor ativa.

func _ready() -> void: # Cria todas as partes do avatar.
	name = "Avatar" # Identifica o humano na árvore Remoto.
	corpo = Node3D.new() # Cria o grupo visual do corpo.
	corpo.name = "Corpo" # Dá um nome ao grupo articulado.
	add_child(corpo) # Liga o corpo ao avatar.
	var tronco: BoxMesh = BoxMesh.new() # Cria a geometria do tronco.
	tronco.size = Vector3(0.65, 0.75, 0.35) # Define as proporções do torso.
	_adicionar_peca(corpo, "Tronco", tronco, Vector3(0, 1.13, 0), true) # Coloca o tronco vestido.
	var cabeca: SphereMesh = SphereMesh.new() # Cria uma cabeça esférica.
	cabeca.radius = 0.25 # Define o raio da cabeça.
	cabeca.height = 0.5 # Mantém a esfera proporcional.
	_adicionar_peca(corpo, "Cabeca", cabeca, Vector3(0, 1.8, 0), false) # Coloca a cabeça sobre o torso.
	_criar_membro("BracoEsquerdo", Vector3(-0.45, 1.46, 0), 0.68) # Cria o pivô do ombro esquerdo.
	_criar_membro("BracoDireito", Vector3(0.45, 1.46, 0), 0.68) # Cria o pivô do ombro direito.
	_criar_membro("PernaEsquerda", Vector3(-0.19, 0.75, 0), 0.75) # Cria o pivô da anca esquerda.
	_criar_membro("PernaDireita", Vector3(0.19, 0.75, 0), 0.75) # Cria o pivô da anca direita.
	_criar_rosto() # Acrescenta expressão, cabelo e detalhes do vestuário.

func _detalhe(nome: String, local: Vector3, dimensoes: Vector3, cor: Color, redondo: bool = true, pai: Node3D = null) -> MeshInstance3D: # Constrói um detalhe do personagem sem assets.
	var peca: MeshInstance3D = MeshInstance3D.new() # Cria a peça visível.
	peca.name = nome # Identifica o detalhe no editor.
	if redondo: # Escolhe volumes suaves para o rosto.
		var esfera: SphereMesh = SphereMesh.new() # Cria uma esfera unitária.
		esfera.radius = 1.0 # Permite dimensionar pelos raios indicados.
		esfera.height = 2.0 # Mantém o diâmetro da esfera base.
		peca.mesh = esfera # Atribui a geometria arredondada.
	else: # Usa caixas para os detalhes do vestuário.
		var caixa: BoxMesh = BoxMesh.new() # Cria a forma retangular.
		caixa.size = Vector3.ONE # Define uma base unitária.
		peca.mesh = caixa # Atribui a geometria plana.
	peca.position = local # Posiciona o detalhe no corpo ou membro.
	peca.scale = dimensoes # Ajusta as proporções do detalhe.
	var material: StandardMaterial3D = StandardMaterial3D.new() # Cria o acabamento do detalhe.
	material.albedo_color = cor # Aplica a cor específica.
	material.roughness = 0.72 # Suaviza o brilho do personagem.
	peca.material_override = material # Liga o acabamento à malha.
	(corpo if pai == null else pai).add_child(peca) # Liga o detalhe ao corpo ou à articulação.
	return peca # Permite ajustar a orientação de cada detalhe.

func _criar_rosto() -> void: # Modela o rosto e o vestuário do avatar.
	var pele: Color = Color(0.85, 0.61, 0.43) # Harmoniza os detalhes com a cabeça.
	var cabelo: Color = Color(0.065, 0.035, 0.025) # Define o cabelo castanho escuro.
	var escuro: Color = Color(0.025, 0.045, 0.075) # Define as pupilas e os sapatos.
	_detalhe("CabeloTopo", Vector3(0, 1.985, 0.015), Vector3(0.265, 0.15, 0.25), cabelo) # Cobre o topo da cabeça com cabelo arredondado.
	_detalhe("CabeloNuca", Vector3(0, 1.86, 0.18), Vector3(0.22, 0.18, 0.09), cabelo) # Fecha o penteado na parte de trás.
	for lado: int in [-1, 1]: # Acrescenta detalhes simétricos dos dois lados.
		var x: float = float(lado) # Converte o lado para coordenadas locais.
		var sufixo: String = "Esquerdo" if lado < 0 else "Direito" # Identifica cada metade do rosto.
		_detalhe("Orelha" + sufixo, Vector3(x * 0.247, 1.79, 0), Vector3(0.057, 0.085, 0.045), pele) # Cria a orelha lateral.
		_detalhe("Olho" + sufixo, Vector3(x * 0.095, 1.84, -0.224), Vector3(0.068, 0.073, 0.032), Color(0.98, 0.98, 0.94)) # Desenha a parte branca dos olhos.
		_detalhe("Iris" + sufixo, Vector3(x * 0.095, 1.84, -0.253), Vector3(0.034, 0.042, 0.012), Color(0.13, 0.3, 0.29)) # Dá cor e direção ao olhar.
		_detalhe("Pupila" + sufixo, Vector3(x * 0.095, 1.84, -0.264), Vector3(0.018, 0.027, 0.007), escuro) # Marca o centro de cada olho.
		_detalhe("Brilho" + sufixo, Vector3(x * 0.095 - 0.009, 1.855, -0.271), Vector3(0.009, 0.011, 0.004), Color.WHITE) # Acrescenta um ponto de luz aos olhos.
		var sobrancelha: MeshInstance3D = _detalhe("Sobrancelha" + sufixo, Vector3(x * 0.096, 1.935, -0.214), Vector3(0.105, 0.023, 0.027), cabelo, false) # Define a expressão do rosto.
		sobrancelha.rotation.z = x * -0.10 # Inclina ligeiramente as sobrancelhas.
		_detalhe("Patilha" + sufixo, Vector3(x * 0.222, 1.91, -0.02), Vector3(0.032, 0.09, 0.08), cabelo) # Liga as laterais ao cabelo.
	for indice: int in range(5): # Distribui pequenas madeixas na testa.
		var madeixa: MeshInstance3D = _detalhe("Madeixa%d" % indice, Vector3(-0.16 + float(indice) * 0.075, 1.98, -0.183), Vector3(0.07, 0.065, 0.066), cabelo) # Modela a franja em volumes simples.
		madeixa.rotation.z = -0.25 # Dá uma direção comum ao penteado.
	_detalhe("Nariz", Vector3(0, 1.785, -0.25), Vector3(0.044, 0.052, 0.065), pele) # Acrescenta um nariz arredondado.
	_detalhe("Boca", Vector3(0, 1.704, -0.222), Vector3(0.074, 0.032, 0.018), Color(0.25, 0.08, 0.065)) # Define uma boca pequena e sorridente.
	_detalhe("Sorriso", Vector3(0, 1.714, -0.238), Vector3(0.054, 0.011, 0.006), Color(1.0, 0.93, 0.82)) # Mostra os dentes na parte superior do sorriso.
	_detalhe("Gola", Vector3(0, 1.49, -0.01), Vector3(0.27, 0.075, 0.35), Color(0.88, 0.94, 0.96), false) # Remata a camisola com uma gola clara.
	_detalhe("Fecho", Vector3(0, 1.16, -0.181), Vector3(0.018, 0.55, 0.012), Color(0.7, 0.85, 0.91), false) # Dá detalhe à frente do casaco.
	_detalhe("Emblema", Vector3(-0.18, 1.33, -0.187), Vector3(0.08, 0.085, 0.018), Color(0.3, 0.95, 0.78), false) # Acrescenta um emblema de cor contrastante.
	for indice: int in range(2): # Completa as extremidades dos membros.
		_detalhe("Mao%d" % indice, Vector3(0, -0.63, 0), Vector3(0.105, 0.12, 0.105), pele, true, pivos[indice]) # Coloca as mãos nos braços animados.
		_detalhe("Sapato%d" % indice, Vector3(0, -0.67, -0.055), Vector3(0.25, 0.16, 0.38), escuro, false, pivos[indice + 2]) # Coloca sapatos nas pernas animadas.

func _adicionar_peca(pai: Node3D, nome: String, malha: Mesh, local: Vector3, roupa: bool) -> void: # Monta uma peça com material próprio.
	var peca: MeshInstance3D = MeshInstance3D.new() # Cria a instância visível.
	peca.name = nome # Identifica a parte anatómica.
	peca.mesh = malha # Atribui a forma geométrica.
	peca.position = local # Posiciona a peça relativamente ao pai.
	var material: StandardMaterial3D = StandardMaterial3D.new() # Cria o material da peça.
	material.albedo_color = COR_INICIAL if roupa else Color(0.85, 0.61, 0.43) # Escolhe roupa ou pele.
	material.roughness = 0.8 # Evita brilho excessivo nas formas simples.
	peca.material_override = material # Aplica o material à malha.
	pai.add_child(peca) # Coloca a peça na hierarquia.
	if roupa: # Seleciona apenas as partes vestidas.
		materiais_roupa.append(material) # Guarda o material para mudar a roupa.

func _criar_membro(nome: String, origem: Vector3, comprimento: float) -> void: # Constrói um membro articulado.
	var pivo: Node3D = Node3D.new() # Cria a articulação.
	pivo.name = nome + "Pivo" # Identifica o ombro ou a anca.
	pivo.position = origem # Coloca a articulação na origem do membro.
	corpo.add_child(pivo) # Liga o pivô ao corpo.
	pivos.append(pivo) # Guarda a articulação para animar.
	var capsula: CapsuleMesh = CapsuleMesh.new() # Cria a forma do braço ou da perna.
	capsula.radius = 0.11 # Define a espessura do membro.
	capsula.height = comprimento # Define o comprimento completo.
	_adicionar_peca(pivo, nome, capsula, Vector3(0, -comprimento * 0.5, 0), true) # Suspende a peça pelo topo.

func _unhandled_input(event: InputEvent) -> void: # Lê eventos sem alterar o InputMap.
	if event is InputEventKey: # Filtra os eventos do teclado.
		if event.keycode in [KEY_W, KEY_A, KEY_D, KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT] or (permitir_s and event.keycode == KEY_S): # Aceita as teclas de movimento disponíveis.
			teclas[event.keycode] = event.pressed # Guarda também as libertações de tecla.

func _notification(what: int) -> void: # Reage à perda de foco da janela.
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT: # Deteta quando outra aplicação recebe o teclado.
		teclas.clear() # Evita movimento preso após perder foco.

func _premida(codigo: Key) -> float: # Converte uma tecla em intensidade de movimento.
	return 1.0 if teclas.get(codigo, false) else 0.0 # Devolve um ou zero sem consultar o InputMap.

func _process(delta: float) -> void: # Atualiza movimento e animação com o tempo.
	tempo += delta # Avança o relógio da animação.
	var eixo_x: float = maxf(_premida(KEY_D), _premida(KEY_RIGHT)) - maxf(_premida(KEY_A), _premida(KEY_LEFT)) # Calcula o movimento lateral.
	var recuar: float = maxf(_premida(KEY_S) if permitir_s else 0.0, _premida(KEY_DOWN)) # Permite recuar pela seta em ambos os projetos.
	var eixo_z: float = recuar - maxf(_premida(KEY_W), _premida(KEY_UP)) # Calcula avanço e recuo.
	var direcao: Vector3 = Vector3(eixo_x, 0, eixo_z).normalized().rotated(Vector3.UP, angulo_camara) # Evita aceleração nas diagonais.
	var anterior: Vector3 = position # Guarda a posição anterior ao deslocamento.
	position += direcao * 4.2 * delta # Desloca o avatar a velocidade constante.
	position.x = clampf(position.x, -limite_chao, limite_chao) # Limita o movimento horizontal ao chão.
	position.z = clampf(position.z, -limite_chao, limite_chao) # Limita o movimento em profundidade.
	position.y = 0.0 # Mantém os pés sobre o plano.
	var andando: bool = position.distance_squared_to(anterior) > 0.000001 # Deteta deslocamento real após os limites.
	if direcao.length_squared() > 0.0: # Só muda a orientação quando existe intenção de movimento.
		rotation.y = lerp_angle(rotation.y, atan2(-direcao.x, -direcao.z), 1.0 - exp(-12.0 * delta)) # Roda suavemente para a direção escolhida.
	mistura_andar = lerpf(mistura_andar, 1.0 if andando else 0.0, 1.0 - exp(-12.0 * delta)) # Suaviza o início e fim do passo.
	var balanco: float = sin(tempo * 9.0) * 0.55 * mistura_andar # Calcula a oscilação dos membros.
	pivos[0].rotation.x = balanco # Move o braço esquerdo.
	pivos[1].rotation.x = -balanco # Move o braço direito em oposição.
	pivos[2].rotation.x = -balanco # Opõe a perna esquerda ao braço esquerdo.
	pivos[3].rotation.x = balanco # Opõe a perna direita ao braço direito.
	corpo.position.y = (sin(tempo * 2.0) + 1.0) * 0.008 * (1.0 - mistura_andar) # Simula respiração leve acima do chão.

func mudar_cor(cor: Color) -> void: # Muda a roupa com uma transição suave.
	if tween_roupa != null: # Verifica se existe uma transição anterior.
		tween_roupa.kill() # Interrompe a transição sem acumular animações.
	tween_roupa = create_tween().set_parallel(true) # Anima as cinco peças simultaneamente.
	for material: StandardMaterial3D in materiais_roupa: # Percorre tronco, braços e pernas.
		tween_roupa.tween_property(material, "albedo_color", cor, 0.3) # Interpola a cor durante 0,3 segundos.

func repor() -> void: # Recupera pose, posição e roupa iniciais.
	if tween_roupa != null: # Verifica se há uma mudança de roupa em curso.
		tween_roupa.kill() # Cancela a interpolação anterior.
	teclas.clear() # Esquece movimentos mantidos antes da reposição.
	position = Vector3.ZERO # Regressa ao centro do chão.
	rotation = Vector3.ZERO # Recupera a orientação inicial.
	tempo = 0.0 # Reinicia o ciclo de animação.
	mistura_andar = 0.0 # Regressa imediatamente à pose neutra.
	corpo.position = Vector3.ZERO # Repõe a altura de repouso.
	for pivo: Node3D in pivos: # Percorre as articulações.
		pivo.rotation = Vector3.ZERO # Endireita cada membro.
	for material: StandardMaterial3D in materiais_roupa: # Percorre os materiais da roupa.
		material.albedo_color = COR_INICIAL # Recupera a cor inicial sem atraso.

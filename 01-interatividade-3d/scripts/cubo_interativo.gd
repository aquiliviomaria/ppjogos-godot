extends MeshInstance3D # Representa o cubo que recebe cor e textura.

const COR_INICIAL: Color = Color(0.9, 0.45, 0.12) # Define a cor inicial do cubo.
var material: StandardMaterial3D = StandardMaterial3D.new() # Guarda o material editável.
var textura: Texture2D # Guarda a textura opcional ou gerada.
var usar_textura: bool = false # Memoriza o estado atual da textura.
var tween_cor: Tween # Guarda a interpolação de cor ativa.

func _ready() -> void: # Constrói o cubo e o seu material.
	name = "CuboInterativo" # Identifica o objeto na árvore Remoto.
	var caixa: BoxMesh = BoxMesh.new() # Cria a geometria da caixa.
	caixa.size = Vector3(2, 2, 2) # Define dois metros por lado.
	mesh = caixa # Aplica a geometria à instância.
	position = Vector3(4, 1, 0) # Coloca o cubo sobre o chão.
	material.albedo_color = COR_INICIAL # Aplica a cor original.
	material.roughness = 0.65 # Ajusta o brilho do material.
	material_override = material # Liga o material à malha.
	textura = _criar_textura() # Prepara o xadrez ou a imagem opcional.

func mudar_cor(cor: Color) -> void: # Interpola a cor recebida.
	if tween_cor != null: # Verifica se existe uma interpolação anterior.
		tween_cor.kill() # Cancela a animação anterior para evitar conflitos.
	tween_cor = create_tween() # Cria uma nova transição.
	tween_cor.tween_property(material, "albedo_color", cor, 0.3) # Muda a cor em 0,3 segundos.

func alternar_textura() -> bool: # Troca o modo visual do cubo.
	usar_textura = not usar_textura # Inverte o estado da textura.
	material.albedo_texture = textura if usar_textura else null # Aplica ou retira a imagem.
	return usar_textura # Devolve o novo estado para o HUD.

func repor() -> void: # Recupera o estado inicial do cubo.
	if tween_cor != null: # Verifica se há uma transição pendente.
		tween_cor.kill() # Interrompe a transição anterior.
	usar_textura = false # Desativa o modo de textura.
	material.albedo_texture = null # Retira a imagem do material.
	material.albedo_color = COR_INICIAL # Recupera a cor inicial.

func _criar_textura() -> Texture2D: # Carrega uma imagem opcional ou cria o xadrez.
	if FileAccess.file_exists("res://texturas/textura.png"): # Verifica a presença da imagem do utilizador.
		var externa: Image = Image.load_from_file("res://texturas/textura.png") # Lê o PNG sem exigir importação prévia.
		if externa != null and not externa.is_empty(): # Confirma que a imagem é utilizável.
			return ImageTexture.create_from_image(externa) # Usa o PNG como textura do cubo.
	var imagem: Image = Image.create(64, 64, false, Image.FORMAT_RGBA8) # Reserva uma imagem quadrada de 64 pixels.
	for y: int in range(64): # Percorre as linhas do xadrez.
		for x: int in range(64): # Percorre os pixels de cada linha.
			var claro: bool = (floori(float(x) / 8.0) + floori(float(y) / 8.0)) % 2 == 0 # Alterna blocos de oito pixels.
			imagem.set_pixel(x, y, Color.WHITE if claro else Color(0.1, 0.12, 0.17)) # Pinta cada casa do xadrez.
	return ImageTexture.create_from_image(imagem) # Converte a imagem numa textura utilizável.

extends MultiMeshInstance3D # Agrupa todos os cubos numa instância MultiMesh.

var posicoes: PackedVector3Array = PackedVector3Array() # Guarda as posições originais dos cubos.
var angulo: float = 0.0 # Partilha a mesma fase de rotação entre os cubos.

func configurar(locais: PackedVector3Array, cores: PackedColorArray, caixa: BoxMesh) -> void: # Prepara o conjunto de instâncias.
	posicoes = locais # Guarda o mesmo prefixo de posições usado no modo A.
	multimesh = MultiMesh.new() # Cria o recurso de instanciamento.
	multimesh.transform_format = MultiMesh.TRANSFORM_3D # Seleciona transformações tridimensionais.
	multimesh.use_colors = true # Ativa uma cor por instância.
	multimesh.mesh = caixa # Usa a mesma malha do modo individual.
	multimesh.instance_count = posicoes.size() # Reserva o número exato de cubos.
	var material: StandardMaterial3D = StandardMaterial3D.new() # Cria um único material partilhado.
	material.vertex_color_use_as_albedo = true # Faz o material usar as cores das instâncias.
	material.roughness = 0.65 # Mantém o acabamento do modo A.
	material_override = material # Aplica o material ao conjunto.
	for indice: int in range(posicoes.size()): # Configura cada instância uma única vez.
		multimesh.set_instance_transform(indice, Transform3D(Basis.IDENTITY, posicoes[indice])) # Coloca o cubo na posição repetível.
		multimesh.set_instance_color(indice, cores[indice]) # Atribui a mesma cor do modo A.

func _process(delta: float) -> void: # Atualiza o conjunto numa única chamada.
	angulo += delta * 0.6 # Avança a fase partilhada de rotação.
	var orientacao: Basis = Basis(Vector3.UP, angulo) * Basis(Vector3.RIGHT, angulo * 0.5) # Calcula a orientação comum uma única vez.
	for indice: int in range(posicoes.size()): # Percorre as instâncias num só ciclo.
		multimesh.set_instance_transform(indice, Transform3D(orientacao, posicoes[indice])) # Atualiza a transformação de cada cubo.

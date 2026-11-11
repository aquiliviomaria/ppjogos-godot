extends MeshInstance3D # Implementa um cubo com atualização individual.

var angulo: float = 0.0 # Guarda a fase de rotação deste cubo.

func configurar(local: Vector3, cor: Color, caixa: BoxMesh) -> void: # Prepara a geometria e o material próprios.
	position = local # Usa a posição da sequência determinística.
	mesh = caixa # Partilha apenas a geometria entre os modos.
	var material: StandardMaterial3D = StandardMaterial3D.new() # Cria um material exclusivo deste cubo.
	material.albedo_color = cor # Usa a mesma cor atribuída no modo B.
	material.roughness = 0.65 # Mantém o mesmo acabamento nos dois modos.
	material_override = material # Aplica o material individual.

func _process(delta: float) -> void: # Executa uma chamada por cubo em cada frame.
	angulo += delta * 0.6 # Avança a rotação de acordo com o tempo.
	basis = Basis(Vector3.UP, angulo) * Basis(Vector3.RIGHT, angulo * 0.5) # Aplica a mesma orientação usada no modo B.

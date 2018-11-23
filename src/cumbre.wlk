object noPuedeEntrar inherits Exception("El interesado no pasa las condiciones minimas para inscribirse"){}

class Pais{
	var paisesConConflictos=[]
	method tuvoConflictosConAlguno(cumbre) = paisesConConflictos.any{pais=>cumbre.estaParticipando(pais)} 	
	}
	
class Cumbre{
	const property paises =[] 
	const property participantes = []
	var solicitudes = 0
	var property commitsRequeridos = 300

	//////////// PUNTO 1
	method inscribir(interesado){
		solicitudes += 1
		if(self.ingresoProhibido(interesado))
			throw noPuedeEntrar
		interesado.ingresarA(self) 
	}
	
	method ingresoProhibido(persona){
		return self.paisConflictivo(persona.paisOrigen()) || !persona.condicionCientifica() || persona.esSospechosa()
	}
	method paisConflictivo(pais){
		return !self.estaParticipando(pais) && pais.tuvoConflictoConAlguno(self)
	}
	method recibir(participante){
		participantes.add(participante)
	}
	
	method estaParticipando(pais) = paises.contains(self)

// PUNTO 2 
// Saber si el PdeP20 es fácil para entrar. Lo es si entró más de la cuarta parte de quienes lo intentaron.
	
	method esFacil() = participantes.size() > solicitudes/4


// PUNTO 3
// Averiguar el país del que más personas pudieron entrar.

	method paisesConParticipantes() = participantes.map{participante=>participante.paisOrigen()}.asSet()
	method participantesDelPais(pais) = participantes.count{participante=>participante.paisOrigen() == pais}
	method paisDelQueMasEntraron()= self.paisesConParticipantes().max{pais=>self.participantesDelPais(pais)}

// Punto 4
// Averiguar si hubo una falla de seguridad, es decir si hay dentro de la cumbre alguna persona que no cumple los requisitos.

	method huboFallas() = participantes.any{participante=>self.ingresoProhibido(participante)}
}


object atentadoAnfitrion {
	var property sospechosos = []
	method seSospechaDe(alguien) = sospechosos.contains(alguien)
}

class Persona{
	var property paisOrigen
	var property profesion
	var conocimientos = []
	
	method condicionCientifica() = profesion.condicionProfesion()
	
	method esSospechosa() = atentadoAnfitrion.seSospechaDe(self)

	method ingresar(cumbre){
		cumbre.recibir(self)	
	 	profesion.ingresoAdicional(cumbre)
	}
	
	method perderLaMitadDelConocimiento(){
		conocimientos = conocimientos.take(self.cantidadDeConocimientos()/2)}
	
	method cantidadDeConocimientos() = conocimientos.size()

	method aprender(conocimiento) {
		conocimientos.add(conocimiento)
	}
	method aprenderMucho(muchosConocimientos) {
		conocimientos.addAll(muchosConocimientos)
	}
	
	method conoce(algo) = conocimientos.contains(algo)

	method practicar(horas,temas) {
		profesion.practicar(horas,temas,self)
	}
	
	method cambioVocacional(multiNacional) {
		profesion.cambioVocacional(multiNacional, self)
	}
	
}

class Programador {
	
	var commits = 0
	
	method ingresoAdicional(cumbre){}
	
	method condicionProfesion(cumbre, persona) = 
		return commits > cumbre.commitsRequeridos() 

	method practicar(horas, lenguaje, persona){ 
		commits += 20*horas
	}
	
	method cambioVocacional(multiNacional, persona){
		persona.profesion(new Especialista(commits = commits))
	}
}


class Especialista inherits Programador{
	
	override method condicionProfesion(cumbre, persona) = 
		super(cumbre, persona) && persona.conoce("Objetos")
		
	override method practicar(horas, lenguaje,persona){
		super(horas,lenguaje,persona)
		persona.aprender(lenguaje)
	}
	
	override method cambioVocacional(multiNacional,persona){
		if(commits>multiNacional.commitsSuficientes()) {
			persona.profesion(new Gerente(multiNacional=multiNacional))
		 	persona.perderLaMitadDelConocimiento()
		}
	}
}

class Gerente {
	var multiNacional
	var empleado = null 

	method ingresoAdicional(cumbre) {
		cumbre.recibir(empleado)
	}

	method condicionProfesion(cumbre, persona){
		return multiNacional.recibeBeneficios(cumbre) || persona.conoce("Maslow")
	}

	method practicar(horas,lenguaje,persona) {}
	
	method cambioVocacional(multi, persona){
		if(persona.conoce("Objetos")) 
			persona.profesion(new Programador())
	}
}

class ContingenteAcademico {
	var property integrantes = []
	var property publico = false

	method inscribirse(cumbre){
		if(publico && integrantes.all{integrante=>not cumbre.prohibidaEntrada(integrante)})
		 	integrantes.forEach{integrante=>integrante.ingresarA(cumbre)}
	}
}

class Multinacional{
	var property commitsSuficientes
	var paisAuspiciante
	method recibeBeneficios(cumbre) = cumbre.participa(paisAuspiciante)
}

// PARTE 2 

class Actividad {
	var participantes

	method realizarse(){ 
		participantes.forEach{participante => self.consecuenciaDeParticipar(participante)}
	}
	method consecuenciaDeParticipar(persona)
	
}

class CharlaTematica inherits Actividad{
	var temas = []
	
	override method consecuenciaDeParticipar(persona){
		persona.aprenderMucho(temas)
	}	
}


class TallerDeDesarrollo inherits Actividad{
	var horas 
	var lenguaje
	override method consecuenciaDeParticipar(persona){
		persona.practicar(horas,lenguaje)
	}	


}

class StandUp inherits Actividad{
	var metodologia = scrum
	var temas = []

	override method consecuenciaDeParticipar(persona){
		metodologia.utilizar(persona, temas)}
}
	
object scrum{
	method utilizar(persona,temas){ 
		persona.aprenderMucho(temas)
	}
}

object cascadeitor {
	method utilizar(persona,temas) {
		persona.perderLaMitadDelConocimiento()
	}
}

object indefinido{
	method utilizar(persona,temas) {}
}


class OritentacionVocacional inherits Actividad{
	var multinacional

	override method consecuenciaDeParticipar(persona){
		persona.cambioVocacional(multinacional)
	}
}	
	
	


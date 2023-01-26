
*				EXAMEN DE ECONOMETRÍA DE CORTE TRANSVERSAL					*
*===================================================================*

* 	INTEGRANTES *
*		•Torres Arias, Angel Anthony 15120320.
*		•Vergaray Chavez, José Arturo 15120321.
*		•Huallpa Ferroa, Alexis 15120282.

*	DOCENTE		*
*	BUSTAMANTE ROMANI, Rafael.

*	TEMA		*
*		CONDICION DE POBREZA DE UN HOGAR URBANO	   

*	Usaremos la base de datos del INEI 2013, aqui encontraremos las variables necesarias.
use Sumaria-2019-ENAHO-INEI.dta

* 	Como sólo nos importan las observaciones que corresponden a los hogares pobres 
*	urbanos se crearan variables dummy para eliminar el resto de observaciones.

codebook pobreza

* Hogar pobre
gen pobre = 1 if pobreza <= 2
replace pobre = 0 if pobreza == 3

codebook estrato 
*	La variable estrato nos ayuda a delimitar si el hogar es urbano o no.
gen urbano=1 if estrato<=6
replace urbano=0 if estrato>6.

** Ponderador personas
gen factorpersonas = factor07*mieperho
* Establecer ponderadores de acuerdo a la Enaho
svyset conglome [pweight = factorpersonas], strata(estrato) vce(linearized)
* Indicador de % pobres
svy: tab pobre


*	ANÁLISIS VARIABLES EXPLICATIVAS   *
*------------------------------------------

codebook mieperho
* Miembros por hogar, se considerara una familia grande cuando el numero de miembros
* del hogar sea mayor a 5  
gen fam_grande = 1 if mieperho >= 5 
replace fam_grande = 0 if mieperho < 5 

*---------------------------------------------

codebook percepho 
* Miembros del hogar que generan ingresos seran menor a 2 en promedio(padres), en promedio solo los padres
* generan ingresos en el hogar
gen perceptor = 1 if percepho  >2
replace perceptor = 0 if  percepho <=2
*---------------------------------------------

** Años de Estudios   
lookfor educ
lookfor estu

* Tomaremos las variables "p301a", "p301b" y "p301c" para calcular los años de
* educación de las personas que están dentro de nuestras observaciones  
codebook p301a 
codebook p301b  
codebook p301c

* No se consideran los años de educación inicial debido a que su significancia en el modelo no genera alguna variacion  
generate educacion=0 if p301a==1 | p301a==2

*	Primaria incompleta   *	
replace educacion=1 if p301a==3 & (p301b==1 | p301c==1)
replace educacion=2 if p301a==3 & (p301b==2 | p301c==2)
replace educacion=3 if p301a==3 & (p301b==3 | p301c==3)
replace educacion=4 if p301a==3 & (p301b==4 | p301c==4)
replace educacion=5 if p301a==3 & (p301b==5 | p301c==5)

*   Primaria completa   *
replace educacion=6 if p301a==4 

*	Secundaria incompleta   *
replace educacion=7 if p301a==5 & (p301b==1 | p301c==1)
replace educacion=8 if p301a==5 & (p301b==2 | p301c==2)
replace educacion=9 if p301a==5 & (p301b==3 | p301c==3)
replace educacion=10 if p301a==5 & (p301b==4 | p301c==4)

*	Secundaria completa   *
replace educacion=11 if p301a==6 

*	Estudio superior incompleto   *
replace educacion=12 if (p301a==7 & (p301b==1 | p301b==0 | p301c==1 | p301c==0)) | (p301a==9 & (p301b==1 | p301b==0 | p301c==1 | p301c==0))
replace educacion=13 if (p301a==7 & (p301b==2 | p301c==2)) | (p301a==9 & (p301b==2 | p301c==2))

*	Estudio superior no universitario completo y universitario incompleto*
replace educacion=14 if p301a==8 | (p301a==9 & (p301b==3 | p301c==3))
replace educacion=15 if p301a==9 & (p301b==4 | p301c==4)

*	Estudio superior universitario completo   *
replace educacion=16 if p301a==10

*	Estudio Postgrado   *
replace educacion=17 if p301a==11
*-------------------------------------------

**	Sexo   
lookfor sexo
codebook p207
* Tomaremos la variable sexo como una dummy para indicar al jefe de hogar
rename p207 sexo
replace sexo=0 if sexo==2
label values sexo sexo
label define sexo 0 "mujer" 1 "hombre"
*-----------------------------------------------

** Edad jefe del hogar 
lookfor edad
codebook p208a 
gen edadjefe = 1 if  p208a >= 25
replace edadjefe = 0 if  p208a <25
*----------------------------------------------

** Ocupacion informal
codebook ocupinf
gen informal= 1 if ocupinf == 1
replace informal = 0 if ocupinf >1
*------------------------------------------------

** Posesion de activos empresariales
lookfor empresar
lookfor independ
* En referencia a la posesion de recibir ingresos por activos empresariales
* tomaremos en cuenta a la variable p5571a .
codebook  p5571a 
gen posactivos = 1 if p5571a == 1  |  p5571a==. 
replace posactivos = 0 if p5571a ==2
*------------------------------------------

** Disponibilidad de servicios higienicos, en zonas urbanas generalmente los servicios basicos como agua y elñectricidad
* siempre estan presentes
lookfor servicios
codebook nbi3 

gen servhigiene = 1 if nbi3 == 0
replace servhigiene = 0 if nbi3 >0
*-------------------------------------------------

** Tenencia de tecnologia (aparatos), claro indicador de pobreza si un hogar no tiene ningun aparato tecnologico
lookfor celula
codebook p1145 
gen apatecno = 1 if p1145  == 0
replace apatecno = 0 if p1145  >0
*-----------------------------------------------

** Propiedad de la vivienda 
lookfor vivienda 
codebook p106a
* se toma en cuenta esta variable en referencia al titulo de la propiedad
gen titpropied = 1 if p106a  == 1
replace titpropied = 0 if p106a ==2 | p106a ==3
*---------------------------------------------------

**Capital social del hogar 
lookfor programa soc
codebook p5566a p710_01 p710_02 p710_03 p710_04  p710_05 p710_06 p710_07 p710_08 p710_09 p710_10 p710_11 

*  Crearemos una variable dummy "programsocial" para las observaciones que
*  recibieron ayuda por parte de programas sociales.

gen programsocial=1 if p5566a==1 | p710_01==1 | p710_02==1 | p710_03==1 | p710_04==1 | p710_05==1 | p710_06==1 | p710_07==1 | p710_08==1 | p710_09==1 | p701_10==1| p701_10==1
replace programsocial=0 if programsocial==.
label variable programsocial "Recibio ayuda de algún programa social"
label values programsocial programsocial
label define programsocial 0 "no" 1 "si"

*------------------------------------------------------------------------------------------------------------
***   EJECUTAMOS NUESTRA REGRESIÓN LINEAL-N --
logit pobre fam_grande perceptor educacion sexo edadjefe informal posactivos servhigiene apatecno titpropied programsocial if urbano
logit pobre fam_grande perceptor educacion sexo edadjefe informal posactivos servhigiene apatecno titpropied programsocial if urbano, or
* Estadisticamente la variable edadjefe que hace referencia ala edad del jefe de hogar es no signnificativa
* por ello decidimos obviarla en la regresion para evitar posibles problemas de correlacion elevados en el modelo
* otra causa es que esta variable no informa grandes conclusiones respecto al modelo propuesto.

logit pobre fam_grande perceptor educacion sexo informal posactivos servhigiene apatecno titpropied programsocial if urbano
logit pobre fam_grande perceptor educacion sexo informal posactivos servhigiene apatecno titpropied programsocial if urbano, or

*Observamos las relaciones marginales de cada variable sobre la condicion de pobreza en un hogar urbano y
*con esta informacion comparamos los resultados obtenidos en del enaho 2019
mfx 
margin 
*En esta seccion estan los odds ratio del modelo que elegimos.
***-------------------------------------------------------------------------------------------

*posible modelo PROBIT, solo comparacion
probit pobre fam_grande perceptor educacion sexo informal posactivos servhigiene apatecno titpropied programsocial if urbano
mfx
margin
estat class
predict prob_probit
*-------------------------------------------------------------------------------------------
logit pobre fam_grande perceptor educacion sexo informal posactivos servhigiene apatecno titpropied programsocial if urbano
mfx
margin
estat class
predict prob_logit
*LROC sirve para obrservar la funcion de sensibilidad y especifidad, si hay media luna el modelo predice bien
*media luna al 81% es aceptable
lroc
*comparacion de las predicciones del modelo logit y probit
sum prob_probit prob_logit
*Segun la comparacion de ambas regresiones, elegiremos el modelo logit ya que capta mayor alcance de probabilidades
*y estas probabilidades son mas reales y aceptables que el modelo probit, ADEMAS el modelo predice mejor la especificidad
*y la sensibilidad, los valores cuando la variable es 0 y 1. 
*-------------
*Comparacion de tablas de coeficientes de logit y probit
probit pobre fam_grande perceptor educacion sexo informal posactivos servhigiene apatecno titpropied programsocial if urbano
estimates store probit
logit pobre fam_grande perceptor educacion sexo informal posactivos servhigiene apatecno titpropied programsocial if urbano
estimates store logit
estimates table  logit probit, star stat(N, r2)
dis 1.81*.79118779
dis 1.81*-.37043416
dis (1/1.81)*1.4766342
dis (1/1.81)*-.69483846
*al realizar las operaciones con los ponderadores, verifico que el modelo es bueno ya que obtengo valores cercanos 
*a los coeficientes de probit y logit respectivamente. 

*-------------------------------------------------------------------------------------------------
*REGRESION LINEAL MODELO LOGIT SELECCIONADO
*Bondan de ajuste, PSEUDO R, porcentaje de prediccion del modelo LOGIT
logit pobre fam_grande perceptor educacion sexo informal posactivos servhigiene apatecno titpropied programsocial if urbano
estat class

*Prediccion del modelo pobreza urbana 
logit pobre fam_grande perceptor educacion sexo informal posactivos servhigiene apatecno titpropied programsocial if urbano
predict p_obreza
summ p_obreza
list p_obreza pobre in 600/620

*Para eliminar Heterocedasticidad solo con modelo logit, comando ROBUST
logit pobre fam_grande perceptor educacion sexo informal posactivos servhigiene apatecno titpropied programsocial if urbano, robust
*el comando robust altera una de las significancias de las variables por eso no utilizamos el comando, ademas al iniciar el modelo
*se utilizo VCE para linealizar la variable dependiente. 

*GRAFICOS
plot prob_logit posactivos
*a medida que un hogar urbano posea mas activos empresariales existira menor probabilidad de que sea considerado pobre.
plot prob_logit educacion
*a medidad que los miembros del hogar urbano tengan mayor educacion. primaria, secundaria, tecnico o universitaria existira menor
*probabilidad de que sean hogares pobres. 
plot prob_logit apatecno
*a mayor posesion de aparatos tecnologicos en un hogar urbano, como tv, cable, internet, telefono, menor sera la probabilidad de que sea 
*considerado pobre.
plot prob_logit fam_grande
*cuando la familia urbana es mas grande, es mas probable que sean propensos a vivir en pobreza o no salir de ella. en ceteris paribus  
plot prob_logit sexo
*cuando el jefe del hogar urbano es varon o mujer existira indifencia al calificarlos como pobres 
plot prob_logit informal
*en general si el jefe del hogar tiene empleo formal o informal sera indiferente considerar al hogar como pobre
plot prob_logit servhigiene
*en general la mayoria de los hogares urbanos contienen servicios basicos de higiene asi que la probabilidad de considerar
*pobre al hogar sera constante. 

*------------------------------------------------------------------------------------------
*PRUEBAS DE INFERENCIA
*PRUEBA DE WALD-hacer test conjunto entre variables
logit pobre fam_grande perceptor educacion sexo informal posactivos servhigiene apatecno titpropied programsocial if urbano
test fam_grande perceptor

*PRUEBA DE MULTIPLICADOR DE LAGRANGE
logit pobre  fam_grande perceptor apatecno
predict residuos,resid
reg residuos fam_grande perceptor educacion sexo informal posactivos servhigiene apatecno titpropied programsocial if urbano
dis  14815*0.1892
display chiprob(10,2802.998)
*como es 0 rechazamos la hipotesis nula de que el modelo reducido es el correcto, entonces el modelo correcto es el completo

*-------------------------------------------------------------------------------

**   SE OBSERVA LA MATRIZ DE CORRELACIONES DE LAS VARIABLES 

corr pobre fam_grande perceptor educacion sexo informal posactivos servhigiene apatecno titpropied programsocial if urbano

* Las variables presentan correlaciones no significativas en el modelo, se prevee la heterocedasticidad previamente
* y se utiliza VCE para corregirla y linealizarla, por esto ya no es necesario hacer este tipo de pruebas.
*------------------------------------------
*Interpretacion de los coeficientes: 
logit pobre fam_grande perceptor educacion sexo informal posactivos servhigiene apatecno titpropied programsocial if urbano
mfx
mfx, at(educacion=17)
*disminuye la probabilidad de ser considerado pobre si la educacion al menos es hasta el grado de secundaria. de 8% pasa a 3%
*-----------------------------------
mfx, at(fam_grande=0)
*disminuye la probabilidad de ser considerado pobre si la familia tuviera como maximo 4 integrantes en el hogar urbano,
*la probabilidad media disminuye de 8% a 5%
*-----------------------------------
mfx, at(apatecno=0)
*si ningun hogar tuviera aparatos tecnologicos la probabilidad de pobreza aumentara. 


*INTERPRETACION COMPLETA, CONCLUSIONES DEL MODELO EN WORD. 




















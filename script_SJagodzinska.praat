clearinfo 

# ouverture des fichiers et enreg. variables
son = Read from file: "logatomes_Jagodzinska.wav"
grille = Read from file: "grille_Jagodzinska.TextGrid"


#creation d'un fichier vierge qui va recolter des diphones
synthese = Create Sound from formula: "sineWithNoise", 1, 0, 0.01, 44100, "0"

#ouverture d'un dictionnaire
dictionnaire = Read Table from tab-separated file: "projet_dico.txt"


##########################################################################################
#																							#
#	Scripting 6.1 Arguments to the script où nous pouvons trouver des boites de dialogue	#
#	choice variable initialValue : a check box will be shown the value is 1 or higher		#
#	button text : a button in box for choice												#
#	comment text : a line with any text													#
#																							#
##########################################################################################



##############################################################################

#	1. La constitution de la phrase à synthétiser + choix de la prosodie		#

##############################################################################

form phrase à synthétiser
	comment Quelle phrase souhaitez-vous synthétiser ?
	optionmenu phrase_text 1
		option le chien voit le papillon qui habite dans le jardin
		option le chien habite dans un grand château
		option le papillon et le chien habitent dans un grand jardin
		option le chien mange le bonbon dans un jardin
		option je vois le chien qui mange le papillon dans le jardin
		option je vois le chien qui habite dans un château
		option je vois un grand chien
		option je mange un bonbon dans un jardin
		option dans le château je vois un grand jardin
		option je vois un jardin dans le château
	comment Quelle intonation voulez-vous?
	choice intonation: 1
		button affirmative
		button interrogative
endform

############

#	END 1.	#

############

#######################################################################

#	2. La transformation du text en une transcription phonétique		#

#######################################################################


#Ajout d'espace à la fin pour pouvoir capter le dernier mot

phrase_text$=phrase_text$+" "

phrase_phonetique$ = ""

longueur_phrase_text = length(phrase_text$)

while longueur_phrase_text > 0
	espace = index(phrase_text$, " ")
	
	mot$=left$(phrase_text$, espace-1)
	phrase_text$=right$(phrase_text$,longueur_phrase_text-espace)

	select 'dictionnaire'
	dico_extrait = Extract rows where column (text): "orthographe", "is equal to", mot$
	select 'dico_extrait'
	mot_phonetique$ = Get value: 1, "phonetique"


################################

#	3. Ajout de la liaison		#

################################


	if mot$ = "dans"
		phrase_text_premiere_lettre$=left$(phrase_text$,1)
		if phrase_text_premiere_lettre$ = "u"
			mot_phonetique$ = mot_phonetique$+"z"
		endif
	endif
	

############

#	END	3.	#

############

	phrase_phonetique$ = phrase_phonetique$ + mot_phonetique$	

	longueur_phrase_text = length(phrase_text$)


	#nettoyage	
	select 'dico_extrait'
	Remove

	
endwhile	

phrase_phonetique$ = "_" + phrase_phonetique$ + "_"

printline La transcription phonétique de la phrase choisi est égale à :
printline 'phrase_phonetique$'

############

#	END	2.	#

############

select 'dictionnaire'
Remove


############################################################################################################################################

#	4. Parcours de la transcription phonétique, division des diphones, extraction des sons élémentaires, concatenation	--> voir README.txt	#

################################################################################################################################

longeur_phrase_phonetique = length(phrase_phonetique$)
 

for n from 1 to longeur_phrase_phonetique-1
	diphone$ = mid$(phrase_phonetique$, n, 2)
	char1_diphone$ = left$(diphone$, 1)
	char2_diphone$ = right$(diphone$, 1)
		

	select 'grille'
	nb_interval = Get number of intervals: 1 

	for a from 1 to nb_interval - 1
		select 'grille'
		st_interval = Get start time of interval: 1, a
		et_interval = Get end time of interval: 1, a
		lb_interval$ = Get label of interval: 1, a
		lb_interval_suivant$ = Get label of interval: 1, a+1
		et_interval_suivant = Get end time of interval: 1, a+1


			if (lb_interval$ = char1_diphone$ and lb_interval_suivant$ = char2_diphone$)
				m1 = (et_interval - st_interval)/2 + st_interval
				m2 = (et_interval_suivant - et_interval)/2 + et_interval


				select 'son'
				periodicity = To PointProcess (zeroes): 1, "no", "yes"

				select 'periodicity'
				index1 = Get nearest index: 'm1'
				mr1 = Get time from index: 'index1'
				index2 = Get nearest index: 'm2'
				mr2 = Get time from index: 'index2'
			

		
				select 'son'
				extrait_son = Extract part: mr1, mr2, "rectangular", 1, "no" 

				select 'synthese'
				plus 'extrait_son'
				synthese = Concatenate

				if char1_diphone$ = "t" and char2_diphone$ = "d" or char1_diphone$ = "k" and char2_diphone$ = "i" or char1_diphone$ = "N" and char2_diphone$ = "d" or char1_diphone$ = "o" and char2_diphone$ = "Z" or char1_diphone$ = "I" and char2_diphone$ = "d"
					if variableExists("sommet1")
						select 'synthese'
						sommet2 = Get end time
					else
						select 'synthese'
						sommet1 = Get end time
					endif
				endif


				#un peu de nettoyage
				select 'extrait_son'
				plus 'periodicity'
				Remove

			endif

	endfor

endfor

############

#	END	4.	#

############

#Communicat pour l'utilisateur

if variableExists("sommet2")
	printline La phrase choisi contient trois syntagmes.
elsif variableExists("sommet1")
	printline La phrase choisi contient deux syntagmes.
else
	printline La phrase choisi contient une syntagme.
endif

###########################

#	5. modification de F0 #
						
###########################

select 'synthese'
@points_basic


manip = To Manipulation: 0.01, 75, 600
pitch = Extract pitch tier
Remove points between: start, end

if variableExists("sommet2")
		@points_when_sommet2
		@f0_sommet2
elsif variableExists("sommet1")
		@points_when_sommet1
		@f0_sommet1
else
		@points_basic
		@f0_basic
endif

############

#	end 5. 	#

############



################################

#	6. modification de durée		#

################################


select 'manip'
dure = Extract duration tier

if variableExists("sommet2")
	@dure_when_sommet2
elsif variableExists("sommet1")
	@dure_when_sommet1
else
	@dure_basic
endif


############

#	end 6. #

############


#######################################################

#	7. remplacement des tiers + lecture automatique	#

#######################################################

select 'pitch'
plus 'manip'
Replace pitch tier

select 'dure'
plus 'manip'
Replace duration tier



@play_son

############

#	end 7. #

############


################################

#	8. PROCEDURES				#

################################




#fonction pour jouer la synthese manipulé automatiquement

procedure play_son
select 'manip'
Get resynthesis (overlap-add)
Play
endproc




#procedure pour isoler des temps de points clés - cas : aucun sommet

procedure points_basic
	start = Get start time
	end = Get end time
	mid = (end-start)/2
	point_apres_start = start+((mid-start)/2)
	point_avant_end = end-((end-mid)/2)

endproc




#procedure pour manipuler le f0 entre les points clés - cas : aucun sommets

procedure f0_basic
	@points_basic
	Add point: start, 210
	Add point: point_apres_start, 200
	if intonation$ = "affirmative"
		Add point: point_avant_end, 200
		Add point: end, 170
	else
		Add point: point_avant_end, 210
		Add point: end, 240
	endif
endproc




#procedure pour manipuler la durée entre les points clés - cas : aucun sommets

procedure dure_basic
	@points_basic
	Add point: start, 1.1
	Add point: point_apres_start, 0.8
	if intonation$ = "affirmative"
		Add point: point_avant_end, 0.9
		Add point: end, 1.4
	else
		Add point: point_avant_end, 0.7
		Add point: end, 1.2
	endif
endproc



#procedure pour isoler des temps de points clés - cas : 1 sommet

procedure points_when_sommet1
	mid_sommet1_start = (sommet1-start)/2
	mid_sommet1_end = sommet1+((end-sommet1)/2)


	point_apres_start = start+((mid_sommet1_start-start)/2)
	point_avant_sommet1 = sommet1-((sommet1-mid_sommet1_start)/2)

	
	point_apres_sommet1 = sommet1+((mid_sommet1_end-sommet1)/2)
	point_avant_end = end-((end-mid_sommet1_end)/2)
endproc




#procedure pour manipuler le f0 entre les points clés - cas : 1 sommets

procedure f0_sommet1
	Add point: start, 210
	Add point: point_apres_start, 200
	Add point: point_avant_sommet1, 200
	Add point: sommet1, 240
	if intonation$ = "affirmative"
		Add point: point_apres_sommet1, 200
		Add point: point_avant_end, 200
		Add point: end, 170
	else
		Add point: point_apres_sommet1, 210
		Add point: point_avant_end, 210
		Add point: end, 240
	endif
endproc




#procedure pour manipuler la durée entre les points clés - cas : 1 sommets

procedure dure_when_sommet1

	@points_when_sommet1

	Add point: start, 1.1
	Add point: point_apres_start, 0.7
	Add point: point_avant_sommet1, 0.7
	Add point: sommet1, 1.4
	if intonation$ = "affirmative"
		Add point: point_apres_sommet1, 0.7
		Add point: point_avant_end, 0.7
		Add point: end, 1.4
	else
		Add point: point_apres_sommet1, 0.6
		Add point: point_avant_end, 0.6
		Add point: end, 1.2
	endif
endproc


#procedure pour isoler des temps de points clés - cas : 2 sommets

procedure points_when_sommet2

	mid_sommet1_start = start+(sommet1-start)/2
	mid_sommet1_sommet2 = sommet1+((sommet2-sommet1)/2)
	mid_sommet2_end = sommet2+((end-sommet2)/2)


	point_apres_start = start+((mid_sommet1_start-start)/2)
	point_avant_sommet1 = sommet1-((sommet1-mid_sommet1_start)/2)

	
	point_apres_sommet1 = sommet1+((mid_sommet1_sommet2-sommet1)/2)
	point_avant_sommet2 = sommet2-((sommet2-mid_sommet1_sommet2)/2)

	point_apres_sommet2 = sommet2+((mid_sommet2_end-sommet2)/2)
	point_avant_end = end-((end-mid_sommet2_end)/2)

endproc




#procedure pour manipuler le f0 entre les points clés - cas : 2 sommets

procedure f0_sommet2

	Add point: start, 210
	Add point: point_apres_start, 200
	Add point: point_avant_sommet1, 200
	Add point: sommet1, 240
	Add point: point_apres_sommet1, 200
	Add point: point_avant_sommet2, 200
	Add point: sommet2, 240
	if intonation$ = "affirmative"
		Add point: point_apres_sommet2, 200
		Add point: point_avant_end, 200
		Add point: end, 170
	else
		Add point: point_apres_sommet2, 210
		Add point: point_avant_end, 210
		Add point: end, 240
	endif
endproc





#procedure pour manipuler la durée entre les points clés - cas : 2 sommets

procedure dure_when_sommet2

	@points_when_sommet2

	Add point: start, 1.1
	Add point: point_apres_start, 0.7
	Add point: point_avant_sommet1, 0.7
	Add point: sommet1, 1.4
	Add point: point_apres_sommet1, 0.7
	Add point: point_avant_sommet2, 0.7
	Add point: sommet2, 1.4
	if intonation$ = "affirmative"
		Add point: point_apres_sommet2, 0.7
		Add point: point_avant_end, 0.7
		Add point: end, 1.4
	else
		Add point: point_apres_sommet2, 0.6
		Add point: point_avant_end, 0.6
		Add point: end, 1.1
	endif
endproc

############

#	end 8. #

############

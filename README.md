README script_Jagodzinska par Sandra Jagodzinska

# Introduction + les mots choisis
Ce projet consiste à écrire un script simple pour créer un programme de synthèse vocale dans le cadre du text-to-speech. Ce script est compatible avec l’environnement PRAAT et avec un enregistrement de 44 100 HZ. Si vous souhaitez réutiliser ce script avec un enregistrement d'une autre fréquence, veuillez changer la fréquence de la variable “synthese” (9ème ligne).  Dans ce script, en dehors de ce qui a été montré pendant les cours, j'ai introduit les boites de dialogues, l'ajout de la liaison, les sommets de f0 et aussi des procedures.
	
Mon choix de mots était limité à 15. 
habite -abit
papillon - papijN
qui - ki
le - l@
bonbon - bNbN
voix/voit/vois - vwa
chien - SjI
mange - mAZ
château - Sato
dans - dA
je - Z@
un - 9
grand - gRA
jardin - ZaRdI
et - e

# Des phrases + arguments de la fonctionnalité "form"
À partir de ces mots, j'ai créé plus de 15 phrases, mais finalement j'ai mis dans le choix, avec une fonction "optionmenu", les 10 phrases les plus variées --> boite de dialogue avec une liste de choix. 

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
		
Dans la même boite de dialogue j'ai mis le choix de l'intonation (soit affirmative, soit interrogative). Cette fois-ci, le choix s'affiche sous forme de bouttons avec une fonction "choice". Dans les deux cas, la valeur de choix est égale à 1, alors l’utilisateur peut choisir seulement une option de ces disponibles.

Utilisation : 
—> form text
—> optionmenu Variable valeur
	comment text
	option text
—> choice variable valeur
	comment text
	button text
—> endform

# Ajout de la liaison 
Dans le cadre de ce projet, seulement un cas de liaison est rencontré. Elle apparaît entre les mots "dans" et "un". L'ajout d'une consonne finale voisée se fait en utilisant les conditions "if" dans la boucle while. Si le mot extrait de la phrase est égale à "dans" et que la lettre suivante est   "u" (extrait avec la fonction "right$"), il faut ajouter à la transcription phonétique de ce mot (mot_phonétique$) le son "z". Si vous avez des autres cas de liaison dans vos phrases veuillez ajouter les conditions selon le même principe.

# Les sommets de f0
Comme mes phrases sont très similaires, j'ai remarqué que les sommets de f0 se trouvent avant les mots "qui", "dans" et une fois sur le mot château suivi par "je". Pour capter les temps de ces sommets, pour ensuite les utiliser comme des points de manipulation, j'ai décidé d'ajouter des conditions à la fin de la boucle qui extrait des diphones. Plus précisément là, où le bout de son de diphones est concaténé avec la synthese finale. Parce que j'avais choisi des mots diversifiés, cela me permettaient d'analyser les diphones parce qu'ils ne se repetaient pas souvent dans deux mots distincts. Avec le mot "qui" l'affaire était simple, une fois que le diphone contient "k" et "i" le sommet1=Get end time --> pour avoir le temps de la synthese après avoir concatené ces diphones. Avec "dans", j'ai choisi de prendre un diphone qui contient le dernier son du mot précédent et le premier son de "dans". Le mot "dans", parfois, se trouve au début de la phrase et je ne voulais pas le considérer comme le sommet. Pour le mot château j'ai pris un diphone "oZ". 

Pour les phrases où il y a deux sommets, j'ai dû introduire une condition if variableExists("sommet1") pour ne pas écraser la valeur de sommet1 avec une valeur de sommet suivante. (Dans mes phrases, il y a deux sommets max.)

Des améliorations possibles pourront-être : 
--> essayer de trouver un moyen de créer une boucle qui definira plutôt un dictionnaire ou une liste avec des sommets en leur donnant des indexes automatiques.
--> introduire des sommets avec des indexes dans les procedures.

# Procedures
J'ai utilisé les procedures pour distinguer les point cruciaux pour la synthese et surtout pour manipuler la f0 et la durée.
J'ai introduit les procedures de disctinction des points cruciaux, de la manipulation de la durée et de la manipulation de f0 selon le nombre de sommets prosodiques. 
J'ai choisi les valeurs du f0 : 
--> 200 Hz de f0 de base, qui est le plus raisonnable pour la voix d'une femme. 
--> 210 Hz pour le trait un peu +haut pour la syllabe initial de la phrase
--> 240 Hz pour le trait +haut 
--> dans le cas de l'intonation interrogative j'utilisé des valeur 210 Hz (après le sommet) et 240 Hz à la fin, pour que l'hauteur de f0 ne descende pas trop après le sommet, parce que cela me semble être plus proche de la prosodie naturelle. 
J'ai choisi les valeurs de la durée:
--> 1.1 pour le trait un peu +long pour la syllabe initiale de la phrase et aussi à la fin de la phrase avec l'intonation interrogative. La fin de la phrase interrogative n'est pas aussi longue que la fin de la phrase affirmative, mais pas non plus aussi court que la syllabe intermédiaire du mot. La valeur 1.1 me semble le plus proche de la prosodie naturelle. 
--> 1.5 pour le trait +long
--> 0.7 pour les syllabes intermédiaires / points entre les sommets prosodiques.
--> 0.6 après le dernier sommet prosodique dans la phrase interrogative, parce que le dernier syntagme de la phrase interrogative est pour moi toujours prononcé un peu plus rapidement et plus haut que les syntagmes précédents. 

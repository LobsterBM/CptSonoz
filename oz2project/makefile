# ----------------------------
# group nb XXX
# noma1 : name1 surname1
# noma2 : name2 surname2
# ----------------------------

# TODO complete the header with your group number, your noma's and full names

all: compile run

input:
	/Applications/Mozart2.app/Contents/Resources/bin/ozc -c Input.oz -o Input.ozf

compilePlayers:
	/Applications/Mozart2.app/Contents/Resources/bin/ozc -c Player000name.oz -o Player000name.ozf

compileManager:
	/Applications/Mozart2.app/Contents/Resources/bin/ozc -c PlayerManager.oz -o PlayerManager.ozf

compile: compileManager
	/Applications/Mozart2.app/Contents/Resources/bin/ozc -c GUI.oz -o GUI.ozf

run:
	/Applications/Mozart2.app/Contents/Resources/bin/ozc -c Main.oz -o Main.ozf
	/Applications/Mozart2.app/Contents/Resources/bin/ozc -c Game.oz -o Game.ozf
	/Applications/Mozart2.app/Contents/Resources/bin/ozc -c Input.oz -o Input.ozf
	/Applications/Mozart2.app/Contents/Resources/bin/ozengine Main.ozf

clean:
	rm PlayerManager.ozf
	rm Player00name.ozf
	rm GUI.ozf
	rm Main.ozf






print"============================================"
print"  🌑 ECLIPSE HUB CARREGANDO..."
print"  Versão: TESTES"
print"  Jogo: Fisch"
print"============================================"

local a=require(script.utils.library)
local b=require(script.utils.remotes)
require(script.games.fisch)

a.log("🧪 Testando remotes do Fisch...","DEBUG")
b.testAll()

a.log("📱 Carregando interface...","UI")
require(script.ui.menu)

a.log("✅ ECLIPSE HUB CARREGADO COM SUCESSO!","SYSTEM")

print"============================================"
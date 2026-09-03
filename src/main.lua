-- ============================================
-- ECLIPSE HUB - MAIN SCRIPT
-- ============================================

print("============================================")
print("  🌑 ECLIPSE HUB CARREGANDO...")
print("  Versão: TESTES")
print("  Jogo: Fisch")
print("============================================")

local Utils = require(script.utils.library)
local Remotes = require(script.utils.remotes)
local _Fisch = require(script.games.fisch)

Utils.log("🧪 Testando remotes do Fisch...", "DEBUG")
Remotes.testAll()

Utils.log("📱 Carregando interface...", "UI")
require(script.ui.menu)

Utils.log("✅ ECLIPSE HUB CARREGADO COM SUCESSO!", "SYSTEM")

print("============================================")
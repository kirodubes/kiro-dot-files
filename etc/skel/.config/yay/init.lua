-- yay's Lua config (yay 13+), see https://github.com/Jguer/yay/blob/next/doc/lua.md
-- The Kiro line below is switched on/off by kiro-yay-aur-check (and ATT, Pacman page).

-- Kiro: AUR check — shows risky PKGBUILD lines before yay builds (kiro-aur-check)
if io.open("/usr/share/kiro/yay/aur-check.lua") then dofile("/usr/share/kiro/yay/aur-check.lua") end
